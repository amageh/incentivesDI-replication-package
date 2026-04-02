
********************************************************************************
* Projekt: Incentive Effects of Disability Benefits
* Author: Annica Gehlen
* Purpose: RDD estimates for benefits across heterogeneity dimensions
********************************************************************************

********************************************************************************
* Summarize coefficients rdd models
*******************************************************************************

eststo clear

global D_TEMP_FIRSTSTAGE = "$PROCESS_TEMP\D_temp_firststage"


foreach g in aall age_1 age_2 age_3 female male diag_1 diag_2 diag_3 diag_4 diag_5 diag_6 quint1 quint2 quint3 quint4 quint5 occ_service occ_manufact occ_technic occ_other {
	
	* load data
	do $PATH\syntax\do-rdd\_load_sample_rdd.do
	*keep if retirement_year==2014
	gen aall=1
	keep if `g' == 1
	* Initialize matrix: number of rows must correspond to number of outcomes!!
	matrix MAT = J(wordcount("$Y_first_stage"), 7,.)
	local i = 1
	* Loop through outcome variables
	foreach var in $Y_first_stage {
		
		*run regression
		*rdbwselect `var' runn, p(1)
		rdrobust `var' runn, p(1)
	
		eststo m_`var'
		
		* save outcomes to matrix
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
	matsave MAT, replace p($D_TEMP_FIRSTSTAGE/) dropall
	use $D_TEMP_FIRSTSTAGE/MAT.dta, replace


	* add names of variables by looping through indices
	gen c8=""
	local i = 1
	foreach var in $Y_first_stage {
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
	*export delimited using $D_TEMP_FIRSTSTAGE/est_firststage_long_`g'.csv, replace
	save $D_TEMP_FIRSTSTAGE/MAT_`g'.dta, replace
		
	********************************************************************************
	* Save output matrix longitudinal using esttab
	********************************************************************************
	/*
	esttab m_*, ///
	obslast se scalars(N N_h_l N_h_r) starlevels(* 0.05 ** 0.01 *** 0.001) 

	esttab m_* using $D_TEMP_BENEFITS/est_firststage_wide_`g'.tex, replace ///
	obslast se scalars(N N_h_l N_h_r) starlevels(* 0.05 ** 0.01 *** 0.001)
	*/

}


use $D_TEMP_FIRSTSTAGE/MAT_aall.dta, clear 
foreach g in age_1 age_2 age_3 female male diag_1 diag_2 diag_3 diag_4 diag_5 diag_6 quint1 quint2 quint3 quint4 quint5 occ_service occ_manufact occ_technic occ_other {
	
	append using $D_TEMP_FIRSTSTAGE/MAT_`g'.dta

}
export delimited using $D_OUT_FIRSTSTAGE/OUT_FIRSTSTAGE_HETEROGENEITY.csv, replace

save $D_TEMP_FIRSTSTAGE/MAT_ALL.dta, replace
