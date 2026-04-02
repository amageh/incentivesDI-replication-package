

********************************************************************************
* Projekt: Incentive Effects of Disability Benefits
* Author: Annica Gehlen
* Purpose: RDD estimates bw sensitivity employment
********************************************************************************

* Load programs
do $PATH\syntax\do-rdd\_func_run_RDD.do
do $PATH\syntax\do-rdd\_func_plot_RDD_bw_sensitivity.do
local path = "$PROCESS_TEMP/D_temp_labor/"
local path_out = "$D_OUT_LABOR_SUPPLY/"

* Estimate RDD model for different bandwidths for all variables.
foreach var in $Y_employment {
	
	func_run_RDD `var' 1 `path'
	func_plot_bw_sensitivity `var' `path' `path_out'
	}


* Append all results to one large data frame and save.
clear 
do $PATH\syntax\do-rdd\_define_globals.do
local path = "$PROCESS_TEMP/D_temp_labor/"
foreach g in $Y_employment {
	
	append using "`path'/MAT_`g'.dta"
}

export delimited using "$D_OUT_LABOR_SUPPLY/OUT_RDD_EMPLOYMENT_BW.csv", replace
save "`path'/OUT_RDD_EMPLOYMENT_BW.dta", replace
