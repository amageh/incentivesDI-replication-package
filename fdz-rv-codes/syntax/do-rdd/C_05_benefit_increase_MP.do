
********************************************************************************
* Projekt: Incentive Effects of Disability Benefits
* Author: Annica Gehlen
* Purpose: Plot benefit increase by ex ante vs ex post mother pension adjustment.
********************************************************************************
* IMPORT PROGRAM FOR PLOTS
do $PATH\syntax\do-rdd\_func_plot_RDD.do

* sample select
do $PATH\syntax\do-rdd\_load_sample_rdd.do

*gen n_kids92_cat = 0 if  ZLKI12_RTZN ==0
*replace n_kids92_cat = 1 if ZLKI12_RTZN > 0

* Run estimates for pension without mother pension correction 
rdrobust RTBT_2014_mp runn, p(1)
eststo m_no_mp_all
estadd ysumm, replace

rdrobust RTBT_2014_mp runn if female==0, p(1)
eststo m_no_mp_men
estadd ysumm, replace

rdrobust RTBT_2014_mp runn if female==1, p(1)
eststo m_no_mp_women
estadd ysumm, replace

	
esttab m_no_mp_*, ///
 label cells(b(star fmt(%9.2f)) se(par)) ///
obslast se scalars(N) starlevels(* 0.05 ** 0.01 *** 0.001) ///
stats(ymean N, fmt(1 0 0) labels( "Dep. mean" ///
"Observations")) mtitle("All" "Men" "Women")

esttab m_no_mp_* using "$C_OUT_COVARIATES/appendix_benefit_increase_raw.tex", replace ///
 label cells(b(star fmt(%9.2f)) se(par)) ///
obslast se scalars(N) starlevels(* 0.05 ** 0.01 *** 0.001) ///
stats(ymean N, fmt(1 0 0) labels( "Dep. mean" ///
"Observations")) mtitle("All" "Men" "Women")

eststo clear

* Run estimates for pension with mother pension correction (baseline estimates in paper)
rdrobust RTBT_2014 runn, p(1)
eststo m_mp_all
estadd ysumm, replace

rdrobust RTBT_2014 runn if female==0, p(1)
eststo m_mp_men
estadd ysumm, replace

rdrobust RTBT_2014 runn if female==1, p(1)
eststo m_mp_women
estadd ysumm, replace
	
esttab m_mp_*, ///
 label cells(b(star fmt(%9.2f)) se(par)) ///
obslast se scalars(N) starlevels(* 0.05 ** 0.01 *** 0.001) ///
stats(ymean N, fmt(1 0 0) labels( "Dep. mean" ///
"Observations")) mtitle("All" "Men" "Women")


esttab m_mp_* using "$C_OUT_COVARIATES/appendix_benefit_increase_main_specification.tex", replace ///
 label cells(b(star fmt(%9.2f)) se(par)) ///
obslast se scalars(N) starlevels(* 0.05 ** 0.01 *** 0.001) ///
stats(ymean N, fmt(1 0 0) labels( "Dep. mean" ///
"Observations")) mtitle("All" "Men" "Women")

********************************************************************************
* DI benefit change for takeup analysis (age group 50-60 & all)
********************************************************************************
eststo clear


*LOAD rdd sample for temp + permanent recipeints with other sampling restrictions
use $PROCESS_TEMP\working_sample_rdd.dta, replace

* drop all pension types that are not a full regular EM pension
qui drop if KNEGPT_RTZN != 0
qui drop if inlist(EM_type, 2, 3, 4)
qui drop if TTSC1_KLDB1988_RTZN == 555

* drop individuals with international pension times
qui drop if vertragsrente_RTZN !=0
qui drop if FRG_times != 0

* drop people w/o german citizenship.
qui drop if german_citizen_RTZN != 1

*drop if birthdate_RTZN == .
qui drop if application_date_RTZN == .
qui drop if acceptance_date_RTZN == .
qui drop if eligible_date_RTZN == .
qui drop if retirement_date_RTZN == .

* drop ppl w/ very long processes in application/notice/ etc. to make sure we only
* look at individuals that receive a pension and know so
qui drop if dist_eli_ent > 730
qui drop if abs(dist_app_ent) > 730
qui drop if abs(dist_acc_ent) > 365

* Drop older recipients that did no (fully) benefit from the reform
qui drop if AE_RTZN > 59



* Run estimates for pension without mother pension correction  (age 50-60)
rdrobust RTBT_2014_mp runn if AE_RTZN > 49 & AE_RTZN <60, p(1)
eststo m_no_mp5060_all
estadd ysumm, replace

rdrobust RTBT_2014_mp runn if female==0 & AE_RTZN > 49 & AE_RTZN <60, p(1)
eststo m_no_mp5060_men
estadd ysumm, replace

rdrobust RTBT_2014_mp runn if female==1 & AE_RTZN > 49 & AE_RTZN <60, p(1)
eststo m_no_mp5060_women
estadd ysumm, replace

	
esttab m_no_mp5060_*, ///
 label cells(b(star fmt(%9.2f)) se(par)) ///
obslast se scalars(N) starlevels(* 0.05 ** 0.01 *** 0.001) ///
stats(ymean N, fmt(1 0 0) labels( "Dep. mean" ///
"Observations")) mtitle("All" "Men" "Women")

esttab m_no_mp5060_* using "$C_OUT_COVARIATES/appendix_benefit_increase_raw_5060_all.tex", replace ///
 label cells(b(star fmt(%9.2f)) se(par)) ///
obslast se scalars(N) starlevels(* 0.05 ** 0.01 *** 0.001) ///
stats(ymean N, fmt(1 0 0) labels( "Dep. mean" ///
"Observations")) mtitle("All" "Men" "Women")

eststo clear

* Run estimates for pension with mother pension correction 
* for age group (baseline estimates in paper for 50 to 60)
rdrobust RTBT_2014 runn if AE_RTZN > 49 & AE_RTZN <60, p(1)
eststo m_mp5060_all
estadd ysumm, replace

rdrobust RTBT_2014 runn if female==0 & AE_RTZN > 49 & AE_RTZN <60, p(1)
eststo m_mp5060_men
estadd ysumm, replace

rdrobust RTBT_2014 runn if female==1 & AE_RTZN > 49 & AE_RTZN <60, p(1)
eststo m_mp5060_women
estadd ysumm, replace

	
esttab m_mp5060_*, ///
 label cells(b(star fmt(%9.2f)) se(par)) ///
obslast se scalars(N) starlevels(* 0.05 ** 0.01 *** 0.001) ///
stats(ymean N, fmt(1 0 0) labels( "Dep. mean" ///
"Observations")) mtitle("All" "Men" "Women")


esttab m_mp5060_* using "$C_OUT_COVARIATES/appendix_benefit_increase_main_specification_50to60_all.tex", replace ///
 label cells(b(star fmt(%9.2f)) se(par)) ///
obslast se scalars(N) starlevels(* 0.05 ** 0.01 *** 0.001) ///
stats(ymean N, fmt(1 0 0) labels( "Dep. mean" ///
"Observations")) mtitle("All" "Men" "Women")

********************************************************************************
* Age analysis of temporary vs permanent recipients 

log using $C_OUT_COVARIATES/log_age_analysis_permanent_temporary.log, replace
tab AE_RTZN if AE_RTZN > 19

tab befristet

tab befristet if AE_RTZN > 49

summarize AE_RTZN if befristet ==0
local ae_mean_unbefristet = r(mean)
summarize AE_RTZN if befristet ==1
local ae_mean_befristet = r(mean)

qui twoway (kdensity AE_RTZN if befristet==0, width(1) lwidth(0.5) color(black)) ///
(kdensity AE_RTZN if befristet==1, width(1) lwidth(0.5) color(black) lpattern(dash)), ///
xline(`ae_mean_befristet', lwidth(0.5) lcolor(black) lpattern(dash)) ///
xline(`ae_mean_unbefristet', lwidth(0.5) lcolor(black) lpattern(solid)) ///
legend(pos(6) cols(2) label(1 "Permanent") label(2 "Temporary")) ///
ytitle("Density", size(12pt)) xtitle("Age", size(12pt)) ///
ylab(0(0.05)0.15,labsize(12pt)) xlab(20(10)60,labsize(12pt)) 
graph export $C_OUT_COVARIATES/appendix_age_hist_befristet.png, replace
graph export $C_OUT_COVARIATES/appendix_age_hist_befristet.eps, replace


* age group 50 to 60

preserve
qui keep if AE_RTZN > 49 & AE_RTZN < 60

summarize AE_RTZN if befristet ==0
local ae_mean_unbefristet = r(mean)
summarize AE_RTZN if befristet ==1
local ae_mean_befristet = r(mean)

qui twoway (kdensity AE_RTZN if befristet==0, width(1) lwidth(0.5) color(black)) ///
(kdensity AE_RTZN if befristet==1, width(1) lwidth(0.5) color(black) lpattern(dash)), ///
xline(`ae_mean_befristet', lwidth(0.5) lcolor(black) lpattern(dash)) ///
xline(`ae_mean_unbefristet', lwidth(0.5) lcolor(black) lpattern(solid)) ///
legend(pos(6) cols(2) label(1 "Permanent") label(2 "Temporary")) ///
ytitle("Density", size(12pt)) xtitle("Age", size(12pt)) ///
ylab(0(0.05)0.15,labsize(12pt)) xlab(50(1)60,labsize(12pt)) 
graph export $C_OUT_COVARIATES/appendix_age_hist_befristet_50to60.png, replace
graph export $C_OUT_COVARIATES/appendix_age_hist_befristet_50to60.eps, replace
restore
log close