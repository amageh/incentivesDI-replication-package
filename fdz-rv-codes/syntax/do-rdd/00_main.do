********************************************************************************
* Project: Incentive Effects of disability benefits
* Author: Annica Gehlen & Sebastian Becker
* Purpose: Main file to run all paper + appendix files.
*******************************************************************************

* Stata version: 18.0
* Housekeeping
clear all
set max_memory .
set matsize 5000
set scheme white_ptol

*******************************************************************************
* SET GLOBAL PATHS FOR PROJECT
*******************************************************************************
global PATH = "D:\gastwissenschaftler\gastw_5\Gehlen\PRJ2208221050\fdz-rv-codes"

global DATA = "D:\gastwissenschaftler\gastw_5\Gehlen\PRJ2208221050\data"

global PROCESS_TEMP = "$PATH\temp"

global OUTPUT = "$PATH\out"

global B_OUT= "$OUTPUT\B_descriptives"

global C_OUT_COVARIATES = "$OUTPUT\C_balancing\covariates"
global C_OUT_MANIPULATION = "$OUTPUT\C_balancing\manipulation"

global D_OUT_FIRSTSTAGE = "$OUTPUT\D_RDD_outcomes\first_stage"
global D_OUT_MORTALITY = "$OUTPUT\D_RDD_outcomes\mortality"
global D_OUT_LABOR_SUPPLY = "$OUTPUT\D_RDD_outcomes\labor_supply"
global D_OUT_STATUS = "$OUTPUT\D_RDD_outcomes\status"

*******************************************************************************

*******************************************************************************
* PROJECT CODE
*******************************************************************************

* Define globals
do $PATH\syntax\do-rdd\_define_globals.do

* A. Run data cleaning and merging ---------------------------------------------

* 1. Append different datasets and select required variables
do $PATH\syntax\do-rdd\A_01_clean_RTZN.do

do $PATH\syntax\do-rdd\A_02_clean_AKVS.do

do $PATH\syntax\do-rdd\A_03_clean_RTWF.do

* 2. Merge RTZN RTWF & AKVS data
do $PATH\syntax\do-rdd\A_04_merge_data.do

* 3. Create panel data anc compute relevant variables.
do $PATH\syntax\do-rdd\A_05_prep_sample.do

* 4. Create cross section with outcomes from panel for rdd design
do $PATH\syntax\do-rdd\A_06_prep_rdd.do


* B Descriptives ---------------------------------------------------------------


do $PATH\syntax\do-rdd\B_01_simulated_pensions.do 

do $PATH\syntax\do-rdd\B_02_employment.do 

do $PATH\syntax\do-rdd\B_03_mortality_predictors_supplmentary_analysis.do

do $PATH\syntax\do-rdd\B_04_mortality.do 

do $PATH\syntax\do-rdd\B_05_replacement_levels.do 


* C. Analysis RDD - Balancing --------------------------------------------------

* D.1. Main estimates covariatres
do $PATH\syntax\do-rdd\C_01_rdd_covariates.do

* D.2. Plots covariates
do $PATH\syntax\do-rdd\C_02_rdd_covariates_plots.do

* D.3. Manipulation of entry date
do $PATH\syntax\do-rdd\C_03_manipulation_app_entry.do

* D.4. Density of entries/applications
do $PATH\syntax\do-rdd\C_04_density_obs.do 

* (D.5. First stage estimates with and without mother pension bonus)
do $PATH\syntax\do-rdd\C_05_benefit_increase_MP.do 

* E. Analysis RDD - employment & mortality--------------------------------------

* MORTALITY
* E.1. Table mortality
do $PATH\syntax\do-rdd\D_01_tab_mortality.do

* E.2. Plots mortality
do $PATH\syntax\do-rdd\D_02_plot_mortality.do

* E.3. BW sensitivity mortality
do $PATH\syntax\do-rdd\D_03_rdd_mortality_bw

* E.8. Mortality estimates with covariates (corresponds to E_01_tab_mortality)
do $PATH\syntax\do-rdd\D_08_tab_mortality_with_covariates.do


* EMPLOYMENT
* E.4. Table employment
do $PATH\syntax\do-rdd\D_04_tab_employment.do

* E.5. Plots employment
do $PATH\syntax\do-rdd\D_05_plot_employment.do

* E.6. BW employment
do $PATH\syntax\do-rdd\D_06_rdd_employment_bw

* E.7. Employment estimates with covaraites (corresponds to E_04_tab_employment)
do $PATH\syntax\do-rdd\D_07_tab_employment_with_covariates.do


* EXIT/PENSION STATUS 
do $PATH\syntax\do-rdd\D_09_plot_pension_status.do

do $PATH\syntax\do-rdd\D_10_tab_status.do

do $PATH\syntax\do-rdd\D_11_rdd_status_bw.do

do $PATH\syntax\do-rdd\D_12_tab_status_with_covariates.do


* Further robustness ----------------------------------------------------------
do $PATH\syntax\do-rdd\D_13_robustness_heterogeneity.do

do $PATH\syntax\do-rdd\D_14_donut_manufacturing.do

* Run estimation for main outcomes on permanent DI recipients
do $PATH\syntax\do-rdd\D_15_robustness_permanent_DI.do

do $PATH\syntax\do-rdd\D_16_heterogeneity_first_stage.do

********************************************************************************

clear all
exit, clear 






