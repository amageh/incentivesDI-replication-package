********************************************************************************
* Projekt: Disability insurance & labor supply
* Author: Annica Gehlen
* Purpose: Mortality predictors
********************************************************************************

do $PATH\syntax\do-rdd\_load_sample_rdd.do
********************************************************************************
* maybe add DG2 and kldb1988 education?
replace kldb1988_bereich = 6 if kldb1988_bereich ==-1
replace kldb1988_bereich = 6 if kldb1988_bereich ==2

gen ln_rtbt_2014 = ln(RTBT_2014)

gen GDEGPTDX_RTZN_copy = GDEGPTDX_RTZN
replace GDEGPTDX_RTZN_copy = 0.000001 if GDEGPTDX_RTZN_copy==0
gen ln_avg_pp = ln(GDEGPTDX_RTZN_copy)

label define quint_la 1 "Quintile 1" 2 "Quintile 2" 3 "Quintile 3" 4 "Quintile 4" 5 "Quintile 5"
label values quint quint_la


gen second_diagnoses = .
replace second_diagnoses = 0 if inlist(NNDG_1_RTZN, "F")
replace second_diagnoses = 1 if inlist(NNDG_1_RTZN, "I")
replace second_diagnoses = 2 if inlist(NNDG_1_RTZN, "C") 
replace second_diagnoses = 3 if inlist(NNDG_1_RTZN, "M")
replace second_diagnoses = 4 if inlist(NNDG_1_RTZN, "G")
replace second_diagnoses = 5 if inlist(NNDG_1_RTZN, "D", "E", "J", "K", "S", "T")
replace second_diagnoses = 5 if inlist(NNDG_1_RTZN, "A", "B", "H", "L", "N", "O", "P")
replace second_diagnoses = 5 if inlist(NNDG_1_RTZN, "Q","R", "Z", "U", "V", "X", "Y")
replace second_diagnoses = 5 if NNDG_1_RTZN=="0"

label define second_diagnoses 0 "Mental disorder" 1 "Circulatory system" 2 "Neoplasms" 3 "Musculoskeletal system" 4 "Nervous system" ///
5 "Other/None" 
label values second_diagnoses second_diagnoses

gen byte medical_rehab = inlist(ZLMCMS_RTZN,1,2,3,4,5,6,7,8)

gen educ = 0
replace educ = 1 if TTSC3_KLDB2010_RTZN==1
replace educ = 2 if TTSC3_KLDB2010_RTZN==2
replace educ = 3 if inlist(TTSC3_KLDB2010_RTZN,3,4,5,6)
replace educ =0 if TTSC3_KLDB2010_RTZN==9

********************************************************************************

reg dead_post_6 i.female ib(3).quint ib(0).AE_group ib(0).diagnoses_RTZN ///
ib(0).second_diagnoses ///
 ib(5).kldb1988_bereich c.AZ_FULL_CONTRIB_RTZN c.ln_avg_pp ib(0).reha_prev5y ib(0).medical_rehab , vce(robust)
 
 
coefplot, xline(0, lcolor(red)) omitted  ylabel(,labsize(small)) xlabel(, labsize(11pt)) /// 
 msize(medlarge) mlcolor(black) mcolor(gray) mlwidth(0.1) ciopts(recast(rcap) lcolor(gray)) ///
coeflabels( 1.female_RTZN ="Female" ///
ln_avg_pp = "Log Avg. Pension Points" AZ_FULL_CONTRIB_RTZN="Full contrib. times" ///
1.medical_rehab="Medical rehab" 1.reha_prev5y="LM rehab") ///
headings( ///
1.quint = "{bf:Benefit Quintile}" ///
1.AE_group = "{bf:Age Group}" ///
1.diagnoses_RTZN="{bf:Primary Diagnoses}" ///
1.second_diagnoses="{bf:Secondary Diagnoses}" ///
1.kldb1988_bereich="{bf:Occupation}" ///
AZ_FULL_CONTRIB_RTZN="{bf:Employment History}", labsize(2.5) ///
) 
graph export $B_OUT\appendix_dead6-ols-quint-coefplot.png, replace
graph export $B_OUT\appendix_dead6-ols-quint-coefplot.eps, replace

********************************************************************************
* REGRESSION TABLE
********************************************************************************
eststo clear

reg dead_post_6 ln_rtbt_2014 , vce(robust)
eststo reg1
estadd ysumm, replace
qui estadd local c_dem "No", replace
qui estadd local c_diag "No", replace
qui estadd local c_employ "No", replace

reg dead_post_6 ln_rtbt_2014 i.female ib(2).AE_group , vce(robust)
eststo reg2
estadd ysumm, replace
qui estadd local c_dem "Yes", replace
qui estadd local c_diag "No", replace
qui estadd local c_employ "No", replace

reg dead_post_6 ln_rtbt_2014 i.female ib(2).AE_group ib(0).diagnoses_RTZN ///
ib(0).second_diagnoses , vce(robust)
eststo reg3
estadd ysumm, replace
qui estadd local c_dem "Yes", replace
qui estadd local c_diag "Yes", replace
qui estadd local c_employ "No", replace

reg dead_post_6 ln_rtbt_2014 i.female ib(2).AE_group ib(0).diagnoses_RTZN ///
ib(0).second_diagnoses ///
 ib(5).kldb1988_bereich c.ln_avg_pp c.AZ_FULL_CONTRIB_RTZN ib(0).reha_prev5y ib(0).medical_rehab , vce(robust)
eststo reg4
estadd ysumm, replace
qui estadd local c_dem "Yes", replace
qui estadd local c_diag "Yes", replace
qui estadd local c_employ "Yes", replace

esttab reg* using $B_OUT\appendix_dead6-ols-log-rtbt-reg-outputs.tex, replace ///
keep(ln_rtbt_2014) ///
label cells(b(star fmt(%9.3f)) se(par)) ///
stats(ymean N c_dem c_diag c_employ, fmt(2 0 0) labels( "Dep. mean" ///
"Observations" "Demographic controls" "Diagnoses controls" "Employment controls"))


esttab reg*, replace ///
keep(ln_rtbt_2014) ///
label cells(b(star fmt(%9.3f)) se(par)) ///
stats(ymean N c_dem c_diag c_employ, fmt(2 0 0) labels( "Dep. mean" ///
"Observations" "Demographic controls" "Diagnoses controls" "Employment controls"))
