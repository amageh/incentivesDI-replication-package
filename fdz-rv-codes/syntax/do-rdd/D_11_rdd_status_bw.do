

********************************************************************************
* Projekt: Incentive Effects of Disability Benefits
* Author: Annica Gehlen
* Purpose: RDD estimates bw sensitivity pension status
********************************************************************************

* Load programs
do $PATH\syntax\do-rdd\_func_run_RDD.do
do $PATH\syntax\do-rdd\_func_plot_RDD_bw_sensitivity.do

local path = "$PROCESS_TEMP/D_temp_status/"
local path_out = "$D_OUT_STATUS/"

* Estimate RDD model for different bandwidths for all variables.
foreach var in $Y_status {
	
	func_run_RDD `var' 1 `path'
	func_plot_bw_sensitivity `var'  `path' `path_out'
	}

* Append all results to one large data frame and save.
clear 

local path = "$PROCESS_TEMP/D_temp_status/"
foreach g in $Y_status {
	
	append using "`path'/MAT_`g'.dta"
}

export delimited using "$D_OUT_STATUS/OUT_RDD_STATUS_BW.csv", replace
save "`path'/OUT_RDD_STATUS.dta", replace
