
********************************************************************************
* Projekt: Incentive Effects of Disability Benefits
* Author: Annica Gehlen
* Purpose: RDD plots employment
********************************************************************************

* IMPORT PROGRAM FOR PLOTS
do $PATH\syntax\do-rdd\_func_plot_RDD.do


* sample select
do $PATH\syntax\do-rdd\_load_sample_rdd.do
drop if abs(bandwidth) > 30


local out_path = "$D_OUT_LABOR_SUPPLY/"

func_RDD_PLOT MEMP_rec `""Fraction with any" "Marg. Employment""' `out_path'	
func_RDD_PLOT REGEMP_rec `""Fraction with any" "Insured Employment""' `out_path'	
func_RDD_PLOT MEMP_avg_rec `""Average Earnings from Marg." "Employment after Award""' `out_path'	
func_RDD_PLOT REGEMP_avg_rec `""Average Earnings from Ins." "Employment after Award""' `out_path'


********************
/*
local out_path = "$D_OUT_LABOR_SUPPLY/"
preserve
keep if quint5==1
gen MEMP_rec_quint5 = MEMP_rec
func_RDD_PLOT MEMP_rec_quint5 `""Fraction with any" "marg. employment""' `out_path'	
restore
*/