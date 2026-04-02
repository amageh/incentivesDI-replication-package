********************************************************************************
* Projekt: Incentive Effects of Disability Benefits
* Author: Annica Gehlen & Sebastian Becker
* Purpose: Merge and clean RTWF data to track death
* Produces: rtwf_processed.dta
********************************************************************************

* Rename variables 
forvalues i = 12/22 {

	use $DATA/RTWF/sample_RTWF_20`i'.dta, clear
	
	rename MEGD MEGD_RTWF_20`i'
	rename RTWF_MM RTWF_MM_20`i'
	rename RTWF_JJJJ RTWF_20`i'
	
	rename FMSD FMSD_RTWF_20`i'
	rename WHOT WHOT_RTWF_20`i'
	
	sort FDZ_ID 
	qui by FDZ_ID: gen duplicate = cond(_N==1,0,_n)
	drop if duplicate > 1
	drop duplicate
	

	keep FDZ_ID *_RTWF_* RTWF_*
	compress
	save $PROCESS_TEMP/aux_rtwf_`i'_sample.dta, replace
}

* Merge all years and save.
use $PROCESS_TEMP/aux_rtwf_13_sample.dta, clear
forvalues i = 14/22 {
	
	merge 1:1 FDZ_ID using $PROCESS_TEMP/aux_rtwf_`i'_sample.dta
	drop _merge
}
compress
save $PROCESS_TEMP/rtwf_processed.dta, replace

