

********************************************************************************
* Projekt: Incentive Effects of Disability Benefits
* Author: Annica Gehlen
* Purpose: RDD estimates bw sensitivity employment w/ heterogeneity
********************************************************************************

do $PATH\syntax\do-rdd\_func_run_RDD_extra_heterogeneity.do


local out_path = "$D_OUT_LABOR_SUPPLY/robustness/heterogeneity/"

local path = "$PROCESS_TEMP/D_temp_labor/robustness/"
local path_out = "$D_OUT_LABOR_SUPPLY/"


* Estimate RDD model for different bandwidths for all variables.
foreach var in MEMP_rec REGEMP_rec {
	foreach cov in married single quint3 quint4 quint5 {
	
	do $PATH\syntax\do-rdd\_load_sample_rdd.do

	keep if `cov' == 1
	func_run_RDD_extra `var' 1 `path' `cov'
	func_plot_bw_sensitivity_extra `var' `path' `cov'
	graph export "`path_out'appendix_rdd_bw_`var'_`cov'.png", replace
	}
}
