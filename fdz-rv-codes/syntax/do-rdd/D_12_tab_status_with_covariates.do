


********************************************************************************
* Projekt: Incentive Effects of Disability Benefits
* Author: Annica Gehlen
* Purpose: RDD estimates exit with covariates
********************************************************************************

********************************************************************************
* Summarize coefficients rdd models
*******************************************************************************


eststo clear

global D_TEMP_STATUS = "$PROCESS_TEMP\D_temp_status"

foreach g in aall female male {
	
	do $PATH\syntax\do-rdd\_load_sample_rdd.do

	gen aall=1
	keep if `g' == 1
	matrix MAT = J(wordcount("$Y_status"), 7,.)
	local i = 1
	* Loop through variables
	foreach var in $Y_status {
		
		rdrobust `var' runn, p(1) covs($controls )
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
	matsave MAT, replace p($D_TEMP_STATUS/with_controls/) dropall
	use $D_TEMP_STATUS/with_controls/MAT.dta, replace


	* add names of variables by looping through indices
	gen c8=""
	local i = 1
	foreach var in $Y_status {
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
	drop _rowname
	gen subsample = "`g'"
	save $D_TEMP_STATUS/with_controls/MAT_`g'.dta, replace
	
}


use $D_TEMP_STATUS/with_controls/MAT_aall.dta, clear 

foreach g in female male {
	
	append using $D_TEMP_STATUS/with_controls/MAT_`g'.dta

}
export delimited using $D_OUT_STATUS/OUT_STATUS_CONTROLS.csv, replace

save $D_TEMP_STATUS/with_controls/MAT_ALL.dta, replace


