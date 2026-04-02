
********************************************************************************
* Projekt: Incentive Effects of Disability Benefits
* Author: Annica Gehlen
* Purpose: Draw sample of EM RTZN individuals from raw datasets of RTWF & AKVS
* Raw Data: RTZN 2011-2021, RTWF 2012-2022, AKVS 2012-2021

* Instructions:
* 1. This file needs to be run by a FDZ-RV employee and draws the DI recipients 
* from our main data files
* 2. To run, adjust paths at beginning of the file

********************************************************************************

set max_memory .
********************************************************************************
* !!ADJUST PATHS BELOW!!

* INPUT FOLDERS FOR RTZN, RTWF, & AKVS
global PWD_RTZN = "XXX\RTZN"
global PWD_RTWF = "XXX\RTWF"
global PWD_AKVS = "XXX\AKVS"

* OUTPUT FOLDER FOR FILTERED DATASETS 
global PWD_OUT_RTZN = "XXX\Data\RTZN"
* OUTPUT FOLDER FOR FILTERED DATASETS WITH RELEVANT INDIVIDUALS
global PWD_OUT = "XXX\Data\RTZN"



********************************************************************************


forvalues i = 11/21 {
	
use $PWD_RTZN/OSV.RTZN.20`i'.dta, clear

keep if RTAT==1
keep if MEGD==10 
drop if GBMOVS == 0
drop if RTBE_MM == 0
drop BRNR

save $PWD_OUT_RTZN\OSV.RTZN.20`i'.EM.dta, replace
}

* RUN SCRIPT BELOW TO GENERATE SAMPLE DATASETS
********************************************************************************
* 1. GET IDS FROM RTZN
* load that RTZN 2011 data set
use $PWD_OUT_RTZN/OSV.RTZN.2011.EM.dta, clear

* append the RTZN 2014 and 2015 dataset
forvalues i = 12/21 {

	append  using $PWD_OUT_RTZN/OSV.RTZN.20`i'.EM.dta, nolabel keep(PSY FDZ_ID) force
}

* gen FDZ_ID from PSY & drop all other variables (if data still has PSY identfier)
keep PSY FDZ_ID


* next drop duplicates
sort FDZ_ID
by FDZ_ID: gen duplicate_counter1 = cond(_N==1, 0, _n)
drop if  duplicate_counter1 > 1
drop duplicate_counter1

* SAVE LIST WITH IDs to select people in other datasets
save $PWD_OUT\RTZN_IDs.dta, replace


********************************************************************************
* 2. Rentenwegfall (RTZN)

forvalues i = 12/21 {
	use $PWD_RTWF\OSV.RTWF.20`i'.dta, clear
	
	* drop duplicates for that year
	sort FDZ_ID
	by FDZ_ID: gen duplicate_counter1 = cond(_N==1, 0, _n)
	drop if  duplicate_counter1 > 1
	drop duplicate_counter1

	merge 1:1 FDZ_ID using $PWD_OUT\RTZN_IDs.dta, keep(match) nogen nolabel force
	*drop if _merge != 3
	*drop _merge

	save $PWD_OUT\sample_RTWF_20`i'.dta, replace
}
********************************************************************************
* 3. AKVS (Aktiv Versicherte)

forvalues i = 12/21 {
	
	use $PWD_AKVS\OSV.AKVS.20`i'.dta, clear
	
	*gen FDZ_ID = PSY
	* drop duplicates for that year
	sort FDZ_ID
	by FDZ_ID: gen duplicate_counter1 = cond(_N==1, 0, _n)
	drop if  duplicate_counter1 > 1
	drop duplicate_counter1

	merge 1:1 FDZ_ID using $PWD_OUT\RTZN_IDs.dta, keep(match) nogen nolabel force
	drop if _merge != 3
	drop _merge

	save $PWD_OUT\sample_AKVS_20`i'.dta, replace
}