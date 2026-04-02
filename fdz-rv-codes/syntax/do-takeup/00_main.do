********************************************************************************
* Projekt: Incentive Effects of Disability Benefits
* Author: Annica Gehlen
* Analyze DI takeup of 2014 Reform
********************************************************************************
* Analysis files
clear all
set max_memory .
set scheme white_ptol

global PATH = "D:\gastwissenschaftler\gastw_5\Gehlen\PRJ2208221050\fdz-rv-codes"
global PATH_DO = "$PATH\syntax\do-takeup"
global PROCESS_TEMP = "$PATH\temp"
global OUT = "$PATH\out\A_takeup"
global PATH_AKVS = "D:\gastwissenschaftler\gastw_5\Gehlen\PRJ2901241655\rohdateien"
global DATA_LOAD = "$PROCESS_TEMP\akvs_rtzn_12-17_merged_quarterly.dta"
 

************************************************************************************
* A. Run data cleaning
************************************************************************************
* Prep data
do $PATH_DO\01_prep_data.do

************************************************************************************
* B. Run analysis
************************************************************************************
* Load programs
do $PATH_DO\_programs_takeup.do

******************************************
* 1. Descriptives all
******************************************
load_data $DATA_LOAD 60 49 -1
plot_takeup_means "50to60"

******************************************
* 2. Regressions
******************************************
* 2.1. All
load_data $DATA_LOAD 60 49 -1
coefplot_takeup "50to60" "all" "black"
load_data $DATA_LOAD 60 49 -1
regress_pooled_takeup "50to60" "all" "black"

* 2.2. Men
load_data $DATA_LOAD 60 49 1
regress_pooled_takeup  "50to60" "male" "navy"
 
* 2.3. Women
load_data $DATA_LOAD 60 49 0
regress_pooled_takeup "50to60" "female" "orange"
