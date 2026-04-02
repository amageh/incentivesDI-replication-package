* ******************************************************************************
* Main results for robustness to selection of temporary DI recipients
********************************************************************************

global D_TEMP_PERMANENT = "$PROCESS_TEMP\D_temp_permanent"

global Y_permanent_robusts MEMP_rec REGEMP_rec dead_post_6

eststo clear

foreach controls in 0 1 {
foreach g in aall female male {
	
	do $PATH\syntax\do-rdd\_load_sample_rdd_permanent.do
	*keep if retirement_year==2014
	gen aall=1
	keep if `g' == 1
	matrix MAT = J(wordcount("$Y_permanent_robusts"), 7,.)
	local i = 1
	* Loop through variables
	foreach var in $Y_permanent_robusts{
		
		*rdbwselect `var' runn, p(1) covs($controls ) kernel(uniform)
		if `controls' == 0 {
			rdrobust `var' runn, p(1)
		}
		else {
			rdrobust `var' runn, p(1) covs($controls )
		}
		
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
	matsave MAT, replace p($D_TEMP_PERMANENT/) dropall
	use $D_TEMP_PERMANENT/MAT.dta, replace


	* add names of variables by looping through indices
	gen c8=""
	local i = 1
	foreach var in $Y_permanent_robusts {
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
	save $D_TEMP_PERMANENT/MAT_`g'.dta, replace

}

use $D_TEMP_PERMANENT/MAT_aall.dta, clear 

foreach g in female male {
	
	append using $D_TEMP_PERMANENT/MAT_`g'.dta

}
export delimited using $D_OUT_LABOR_SUPPLY/appendix_OUT_PERMANENT_SAMPLE_CONTROLS`controls'.csv, replace

}

