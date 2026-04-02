
********************************************************************************
* Projekt: Incentive Effects of Disability Benefits
* Author: Annica Gehlen
* Purpose: Descriptives employment : replacement level of DI benefits relative to last earnings
********************************************************************************
*-------------------------------------------------------------------------------
* A. PLOTS
*-------------------------------------------------------------------------------
do $PATH\syntax\do-rdd\_load_sample_panel.do

keep if dist_entry == -1 
keep if retirement_date_RTZN < ym(2015,01)
keep if retirement_date_RTZN > ym(2013,12)	

gen ANNUAL_PENSION = (RTBT_2014*12)

gen t_pension = (RTBT_2014*12)/365
gen t_emp =REGEMP_earnings_AKVS/REGEMP_days_AKVS
gen t_uemp=  (UEMP_earnings_AKVS/UEMP_days_AKVS)
gen t_obenfit=(OBENFIT_earnings_AKVS/OBENFIT_days_AKVS)

gen ANNUAL_INC = MEMP_earnings_AKVS + REGEMP_earnings_AKVS + UEMP_earnings_AKVS + OBENFIT_earnings_AKVS

gen EMP_EARNINGS = (MEMP_earnings_AKVS + REGEMP_earnings_AKVS)

gen PENSION_OVER_ALL_EARNINGS = ANNUAL_PENSION/ANNUAL_INC
replace PENSION_OVER_ALL_EARNINGS=. if ANNUAL_INC==.

gen PENSION_OVER_EMP_EARNINGS = ANNUAL_PENSION/(MEMP_earnings_AKVS + REGEMP_earnings_AKVS)
replace PENSION_OVER_EMP_EARNINGS = . if MEMP_earnings_AKVS ==. & REGEMP_earnings_AKVS==.

gen PENSION_OVER_UEMP_EARNINGS = ANNUAL_PENSION/(UEMP_earnings_AKVS)
replace PENSION_OVER_UEMP_EARNINGS = . if UEMP_earnings_AKVS ==.

gen PENSION_OVER_OBENFIT_EARNINGS = ANNUAL_PENSION/(OBENFIT_earnings_AKVS)
replace PENSION_OVER_OBENFIT_EARNINGS = . if OBENFIT_earnings_AKVS==.


gen ratio_t_pen_emp = t_pension/t_emp
gen ratio_t_pen_uemp = t_pension/t_uemp
gen ratio_t_pen_obenfit = t_pension/t_obenfit

gen annual_emp = t_emp*365
gen annual_uemp = t_uemp*365
gen annual_obenfit = t_obenfit*365


**********************************************************************************
* Plot densities

su ratio_t_* if treat==0, detail
su PENSION_OVER_ALL_EARNINGS if treat==0, detail


su ratio_t_* if treat==1, detail
su PENSION_OVER_ALL_EARNINGS if treat==1, detail

*keep if treat==0
preserve
keep if treat==0
* density on raw dtaa from 1 year before entry
twoway (kdensity PENSION_OVER_ALL_EARNINGS if PENSION_OVER_ALL_EARNINGS<2, width(0.05) lwidth(0.5) color(black)) ///
(kdensity PENSION_OVER_EMP_EARNINGS if PENSION_OVER_EMP_EARNINGS<2, width(0.05) lwidth(0.5)  color(navy) lpattern(dash)) ///
(kdensity PENSION_OVER_UEMP_EARNINGS if PENSION_OVER_UEMP_EARNINGS<2, width(0.05) lwidth(0.5) color(orange) lpattern(dash_dot)) ///
(kdensity PENSION_OVER_OBENFIT_EARNINGS if PENSION_OVER_OBENFIT_EARNINGS<2, width(0.05) lwidth(0.5) color(green) lpattern(shortdash)), ///
xtitle("DI Replacement Rate",size(12pt)) ytitle("Density", size(12pt)) ylab(,labsize(12pt)) xlab(,labsize(12pt)) ///
legend(pos(6) col(2) label(1 "All Earnings & Benefits") label(2 "Employment Earnings") ///
label(3 "Unemployment Benefits")  label(4 "Sick leave/ other benefits") size(11pt))
graph export $B_OUT/appendix_replacement_rate_raw.png, replace
graph export $B_OUT/appendix_replacement_rate_raw.eps, replace
restore

* density for earnings/benefits on daily level (i.e. adjusted by number of days actually present in each status.)
twoway ///
(kdensity PENSION_OVER_ALL_EARNINGS if PENSION_OVER_ALL_EARNINGS<2, width(0.05) lwidth(0.5) color(black)) ///
(kdensity ratio_t_pen_emp if ratio_t_pen_emp<2, width(0.05)  lwidth(0.5) color(navy%70) lpattern(dash)) ///
(kdensity ratio_t_pen_uemp if ratio_t_pen_uemp<2, width(0.05)  lwidth(0.5) color(orange%70) lpattern(dash_dot)) ///
(kdensity ratio_t_pen_obenfit if ratio_t_pen_obenfit<2, width(0.05)  lwidth(0.5) color(green%70) lpattern(shortdash)), ///
xtitle("DI Replacement Rate",size(12pt)) ytitle("Density", size(12pt)) ylab(,labsize(12pt)) xlab(,labsize(12pt)) ///
legend(pos(6) col(2) label(1 "All Earnings & Benefits") label(2 "Employment Earnings") ///
label(3 "Unemployment Benefits")  label(4 "Sick Leave/ other Benefits") size(11pt))
graph export $B_OUT/appendix_replacement_rate_cleaned.png, replace
graph export $B_OUT/appendix_replacement_rate_cleaned.eps, replace



* density for earnings/benefits on daily level (i.e. adjusted by number of days actually present in each status.)
twoway ///
kdensity PENSION_OVER_ALL_EARNINGS if PENSION_OVER_ALL_EARNINGS<2, width(0.05) lwidth(0.5) color(black) ///
xtitle("DI Replacement Rate",size(12pt)) ytitle("Density", size(12pt)) ylab(,labsize(12pt)) xlab(,labsize(12pt)) ///
legend(off)
graph export $B_OUT/appendix_replacement_rate_allincome.png, replace
graph export $B_OUT/appendix_replacement_rate_allincome.eps, replace
