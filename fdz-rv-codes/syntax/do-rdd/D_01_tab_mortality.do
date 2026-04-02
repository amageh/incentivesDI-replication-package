
********************************************************************************
* Projekt: Incentive Effects of Disability Benefits
* Author: Annica Gehlen
* Purpose: RDD estimates mortality
********************************************************************************

********************************************************************************
* Summarize coefficients rdd models
*******************************************************************************

global D_TEMP_MORTALITY = "$PROCESS_TEMP\D_temp_mortality"

foreach g in aall age_1 age_2 age_3 female male diag_1 diag_2 diag_3 diag_4 diag_5 diag_6 quint1 quint2 quint3 quint4 quint5 occ_service occ_manufact occ_technic occ_other {
	
	do $PATH\syntax\do-rdd\_load_sample_rdd.do

	*keep if retirement_year==2014
	gen aall = 1
	keep if `g' == 1
	matrix MAT = J(wordcount("$Y_mortality"), 7,.)
	local i = 1
	* Loop through variables
	
	eststo clear
	
	foreach var in $Y_mortality {

		rdrobust `var' runn, p(1) 
		eststo m_`var'
		
		matrix MAT[`i',1] = e(tau_cl)
		
		local p =  2*normal(-abs(e(tau_cl) / e(se_tau_cl)))
		matrix MAT[`i', 2] = e(se_tau_cl)
		matrix MAT[`i', 3] = `p'
		
		qui: summarize `var' if running < 0
		matrix MAT[`i', 4] = r(mean)
		matrix MAT[`i', 5] =  `i'
		matrix MAT[`i', 6] = e(N_h_l) + e(N_h_r)
		matrix MAT[`i', 7] = e(h_l)
		
		local i = `i' + 1
		}
		
	********************************************************************************
	* Save output matrix
	********************************************************************************

	matrix list MAT
	matsave MAT, replace p($D_TEMP_MORTALITY/) dropall
	use $D_TEMP_MORTALITY/MAT.dta, replace


	* add names of variables by looping through indices
	gen c8=""
	local i = 1
	foreach var in $Y_mortality {
		replace c8="`var'" if c5==`i' 
		local i = `i' + 1
	}
	drop c5
	order c8 c1 c2 c3 c4 c6 c7
	* round variables
	replace c1 = round(c1,0.0001)
	replace c2 = round(c2,0.0001)
	replace c3 = round(c3,0.001)
	replace c4 = round(c4,0.001)

	* rename vars
	rename c8 Variable
	rename c1 Coefficient
	rename c2 StandardError
	rename c3 PValue
	rename c4 ControlMean
	rename c6 Observations
	rename c7 Bandwidth
	gen subsample = "`g'"
	drop _rowname
	save $D_TEMP_MORTALITY/MAT_`g'.dta, replace
}




use $D_TEMP_MORTALITY/MAT_aall.dta, clear 

foreach g in age_1 age_2 age_3 female male diag_1 diag_2 diag_3 diag_4 diag_5 diag_6 quint1 quint2 quint3 quint4 quint5 occ_service occ_manufact occ_technic occ_other {
	
	append using $D_TEMP_MORTALITY/MAT_`g'.dta

}
export delimited using $D_OUT_MORTALITY/OUT_MORTALITY_HETEROGENEITY.csv, replace
save $D_TEMP_MORTALITY/MAT_ALL.dta, replace


