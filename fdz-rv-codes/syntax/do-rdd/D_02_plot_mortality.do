
********************************************************************************
* Projekt: Incentive Effects of Disability Benefits
* Author: Annica Gehlen
* Purpose: RDD plots mortality
********************************************************************************

* IMPORT PROGRAM FOR PLOTS
do $PATH\syntax\do-rdd\_func_plot_RDD.do


* sample select
do $PATH\syntax\do-rdd\_load_sample_rdd.do
drop if abs(bandwidth) > 30


local PATH = "$D_OUT_MORTALITY/"

* Run program for each covariate
func_RDD_PLOT dead_post_1 `""Fraction Deceased" "1 Year Post Award""' `PATH'	
func_RDD_PLOT dead_post_2 `""Fraction Deceased" "2 Years Post Award""' `PATH'	
func_RDD_PLOT dead_post_3 `""Fraction Deceased" "3 Years Post Award""' `PATH'	
func_RDD_PLOT dead_post_4 `""Fraction Deceased" "4 Years Post Award""' `PATH'	
func_RDD_PLOT dead_post_5 `""Fraction Deceased" "5 Years Post Award""' `PATH'	
func_RDD_PLOT dead_post_6 `""Fraction Deceased" "6 Years Post Award""' `PATH'	