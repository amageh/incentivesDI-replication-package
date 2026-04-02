********************************************************************************
* Analyze DI takeup of 2014 Reform: data preparation
********************************************************************************

********************************************************************************
* 1. Create Dataset
********************************************************************************

* Load AKVS Data for 2012-2017
use $PATH_AKVS/AKVS.2012.subset.dta, clear
forvalues i=13/17 {
	
	append using $PATH_AKVS/AKVS.20`i'.subset.dta
}

keep if JA - GBJA < 60 
keep if JA - GBJA > 18 

* Merge EM entry data 
merge m:1 FDZ_ID using $PROCESS_TEMP\rtzn_processed.dta, ///
 keepusing(LEAT_RTZN befristet RTBT_2014 EM_type diagnose_cat_RTZN retirement_date_RTZN TTSC1_KLDB1988_RTZN) 
drop if _merge ==2
drop _merge

save $PROCESS_TEMP\akvs_rtzn_12-17_merged.dta, replace


********************************************************************************
* 2. Create quaterly panel
********************************************************************************

* 2.1. Expand into quaterly panel
gen n_groups = 4
expand n_groups
bysort FDZ_ID JA: gen quarter= _n
drop n_groups 

gen QUARTER = yq(JA, quarter)
gen DI_YEAR = yofd(dofm(retirement_date_RTZN))
gen DI_QUARTER = qofd(dofm(retirement_date_RTZN))


format QUARTER %tq
format DI_QUARTER %tq

gen byte START_DI = QUARTER == DI_QUARTER & DI_QUARTER != . 
* Drop DI types 
* Occupation 555=Behinderte -> seems to be a miscoded special DI type 
gen byte CLEAN_DI = TTSC1_KLDB1988_RTZN == 555


* 2.2. Additional variables needed for analysis
gen START_GDI = START_DI
replace START_GDI = 0 if inlist(EM_type,2,3,4)
replace START_GDI = 0 if CLEAN_DI ==1

* Covariates
* Women (GEVS is coded weirdly in some AKVS waves)
gen byte female = inlist(GEVS,5,6,7,8,9)
replace female = 1 if GEVS == 2 & JA ==2017

* Bundesland
gen bland = WHOT/1000
replace bland = floor(bland)

* Cohort
gen cohort = 1950
replace cohort = 1960 if GBJA > 1960 & GBJA <=1970
replace cohort = 1970 if GBJA > 1970 & GBJA <=1980
replace cohort = 1980 if GBJA > 1980 & GBJA <=1990
replace cohort = 1990 if GBJA > 1990 & GBJA <=2000


gen beruf = TTSCJA1_KLDB1988
replace beruf = 0 if TTSCJA1_KLDB1988 ==.
replace beruf = beruf/100
replace beruf = floor(beruf) 

* Remove individuals with miners pensions and individuals 
* without german citizenship
gen byte kanppschaftl = VSKN == 1
gen byte german = SAVS == 0
*gen byte befristet = ZTRT_RTZN ==1

* Takeup of befristet full DI
gen START_TEMPORARY = START_GDI
replace START_TEMPORARY = 0 if befristet==0

gen START_PERMANENT = START_GDI
replace START_PERMANENT = 0 if befristet==1

drop TTSC* TGSUVOJA BHT* TD  CLEAN_DI

********************************************************************************
* 3. Save data
********************************************************************************
compress
save $PROCESS_TEMP\akvs_rtzn_12-17_merged_quarterly.dta, replace



