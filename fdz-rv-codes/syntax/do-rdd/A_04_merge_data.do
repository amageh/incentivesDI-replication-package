
********************************************************************************
* Projekt: Incentive Effects of Disability Benefits
* Author: Annica Gehlen
* Purpose: Merge RTZN, AKVS, & RTWF
* Produces: working_sample_rtzn_rtwf_akvs.dta
*******************************************************************************


use $PROCESS_TEMP\rtzn_processed.dta, clear

********************************************************************************
* 1. Balanced panel 2012-2019
********************************************************************************

* Create yearly panel.
gen t_start = 2011
gen t_end = 2021

expand t_end - t_start + 1
by FDZ_ID, sort: gen JA = t_start + _n -1

********************************************************************************
* 2. Merge AKVS
********************************************************************************
merge 1:1 FDZ_ID JA using $PROCESS_TEMP\akvs_processed.dta

* Drop people who are not in our EM RTZN.
drop if _merge == 2
rename _merge _merge_AKVS

********************************************************************************
* 3. Merge RTWF
********************************************************************************

* MERGE  RTWF
merge m:1 FDZ_ID using $PROCESS_TEMP\rtwf_processed.dta

* Drop pensioners who are not in our EM RTZN.
drop if _merge == 2


********************************************************************************
* 4. Save sample
********************************************************************************

sort FDZ_ID JA
compress
save $PROCESS_TEMP\working_sample_rtzn_rtwf_akvs.dta, replace
