

********************************************************************************
* Projekt: Incentive Effects of Disability Benefits
* Author: Annica Gehlen
* Purpose: RDD estimates covariates
********************************************************************************

* Set path for outputs
local PATH_TEMP = "$PROCESS_TEMP/C_temp/"


* Load programs
do $PATH\syntax\do-rdd\_func_run_RDD.do
do $PATH\syntax\do-rdd\_func_plot_RDD_bw_sensitivity.do

* Estimate RDD model for different bandwidths for all variables.
foreach var in $X {
	func_run_RDD `var' 1 `PATH_TEMP'
	*func_plot_bw_sensitivity `var' `PATH_TEMP'
	}


* Append all results to one large data frame and save.
clear 
local PATH_TEMP = "$PROCESS_TEMP/C_temp/"

foreach g in $X {
	append using "`PATH_TEMP'/MAT_`g'.dta"
}

export delimited using "$C_OUT_COVARIATES/OUT_RDD_COVARIATES_BW.csv", replace


