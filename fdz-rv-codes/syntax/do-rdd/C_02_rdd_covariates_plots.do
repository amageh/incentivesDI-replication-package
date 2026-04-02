
********************************************************************************
* Projekt: Disability insurance & labor supply
* Author: Annica Gehlen
* Purpose: RDD estimates covariates 
********************************************************************************

* IMPORT PROGRAM FOR PLOTS
do $PATH\syntax\do-rdd\_func_plot_RDD.do

* sample select
do $PATH\syntax\do-rdd\_load_sample_rdd.do
*drop if abs(bandwidth) > 30

local path = "$C_OUT_COVARIATES/"


* Run program for each covariate
func_RDD_PLOT AE_RTZN "Average Age at Entry" `path'
func_RDD_PLOT occ_service "Fraction Serivce ccupation" `path'
func_RDD_PLOT occ_manufact "Fraction Manufacturing Occupation" `path'

func_RDD_PLOT RTBT_2014 "Average benefits (Euros)"  `path'
func_RDD_PLOT sumEGPT "Average Pension Credits"  `path'
func_RDD_PLOT UDAQ_RTZN `""Fraction Reinterpreted" "Rehab Application""'  `path'

func_RDD_PLOT diag_1 "Fraction with Mental Disorders"  `path'
func_RDD_PLOT diag_2 `""Fraction with Diseases" "of Circulatory System""'  `path'
func_RDD_PLOT diag_3 "Fraction with Neoplasms"  `path'
func_RDD_PLOT diag_4 `""Fraction with" "Musculoskeletal Diseases""'  `path'
func_RDD_PLOT diag_5 `""Fraction with Diseases" "of the Nervous System""'  `path'
func_RDD_PLOT diag_6 "Fraction with Other Diseases"  `path'

func_RDD_PLOT RTBT_sim "Simulated Pension" `path'
func_RDD_PLOT RTBT_sim_counterfact `""Simulated Pension in" "Absence of Reform""' `path'

func_RDD_PLOT AZ_ZZ_RTZN "Supplementary Time" `path'



