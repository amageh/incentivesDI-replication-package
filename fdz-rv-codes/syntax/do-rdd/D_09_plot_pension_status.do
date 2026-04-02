********************************************************************************
* Projekt: Incentive Effects of Disability Benefits
* Author: Annica Gehlen
* Purpose: RDD plots pension status
********************************************************************************

* IMPORT PROGRAM FOR PLOTS
do $PATH\syntax\do-rdd\_func_plot_RDD.do


* sample select
do $PATH\syntax\do-rdd\_load_sample_rdd.do
drop if abs(bandwidth) > 30


local out_path = "$D_OUT_STATUS/"

* Run program for each covariate
func_RDD_PLOT status_pension_post1 `""Fraction with Benefits" "after 1 Year""' `out_path'	
func_RDD_PLOT status_pension_post2 `""Fraction with Benefits" "after 2 Years""' `out_path'	
func_RDD_PLOT status_pension_post3 `""Fraction with Benefits" "after 3 Years""' `out_path'	
func_RDD_PLOT status_pension_post4 `""Fraction with Benefits" "after 4 Years""' `out_path'
func_RDD_PLOT status_pension_post5 `""Fraction with Benefits" "after 5 Years""' `out_path'	

func_RDD_PLOT status_none_post1 `""Fraction with no Benefits" "after 1 Year""' `out_path'	
func_RDD_PLOT status_none_post2 `""Fraction with no Benefits" "after 2 Years""' `out_path'	
func_RDD_PLOT status_none_post3 `""Fraction with no Benefits" "after 3 Years""' `out_path'	
func_RDD_PLOT status_none_post4 `""Fraction with no Benefits" "after 4 Years""' `out_path'	
func_RDD_PLOT status_none_post5 `""Fraction with no Benefits" "after 5 Years""' `out_path'
