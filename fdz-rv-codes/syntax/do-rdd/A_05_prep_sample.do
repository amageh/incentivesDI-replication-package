
********************************************************************************
* Projekt: Incentive Effects of Disability Benefits
* Author: Annica Gehlen & Sebastian Becker
* Purpose: Add additional variables to finished sample & adjust the exitings ones
*			to panel structure
* Produces: working_sample_rtzn_rtwf_akvs.dta (overwrites file from last step)

* Note: This file only creates new variables for the merger of all the data sets/
* dynamic variables. All data prep specific to variables that come from RTZN
* is done in 01_clean_RTZN.do.
*******************************************************************************

use $PROCESS_TEMP\working_sample_rtzn_rtwf_akvs.dta, clear

********************************************************************************
* 1. Timing variables and variables related to pension spell
********************************************************************************

gen time = ym(JA, 12)
format time %tm

* Dummies indicating pension status.
// dummy that takes value one as soon as the individual receives a pension
gen byte recipient = time>= retirement_date_RTZN 
la var recipient "Dummy that is equal to one after the individual received a disability pension for the first time"
// dummy that is one from the point on at which the individual receives the acceptance letter
gen byte notef = time >= acceptance_date_RTZN 
la var notef "Dummy that is equal to one after the individual got accepted"
// dummy that indicates the time from whoch on the individual applied to receive disability pension
gen byte apply = time >= application_date_RTZN 
la var apply "Dummy that is equal to one after the individual applied"
// dummy indicating that the impairment is recognized
gen byte eligible = time >= eligible_date_RTZN
la var eligible "Dummy that is equal to one after the individual is eligible"


gen start_date_RTZN = retirement_date_RTZN
replace start_date_RTZN = acceptance_date_RTZN if acceptance_date_RTZN > retirement_date_RTZN
gen start_year = year(dofm(start_date_RTZN))

* Distance to start date of benefits (bad name: should be dist_start instead but
* would require a lot of refactoring)
gen dist_entry = JA - start_year
la var dist_entry "Start date of benefits depening on start date of pension and acceptance date"
gen dist_pension_start = JA - retirement_year_RTZN
la var dist_pension_start "Distance from date of pension"

********************************************************************************
* 2. Pension end & Death
********************************************************************************
* Variable that captures whether individual appears in the AKVS
gen byte Y_appears_AKVS = _merge_AKVS == 3
la var Y_appears_AKVS "Dummy appears in AKVS this year"


gen death_date = .
forvalues i =13/22 {
	replace death_date = ym(RTWF_20`i',RTWF_MM_20`i') if  MEGD_RTWF_20`i' == 26
	*replace death_date = ym(RTWF_20`i',RTWF_MM_20`i') - 24 if  MEGD_RTWF_2018 == 21
}

* Gen AKVS death variable that spans panel.
gen aux_death_AKVS = TD_AKVS
replace aux_death_AKVS = . if TD_AKVS==0 
*replace aux_death_AKVS = 2019 if TD_AKVS == 9999
bysort FDZ_ID: egen LAST_SEEN = max(JA) if Y_appears_AKVS==1
bysort FDZ_ID: egen DEATH_AKVS = min(aux_death_AKVS)
drop aux_death_AKVS

* Add deaths that appear in AKVS only, since we only know the year wie set death
* month to 12.
replace death_date = ym(DEATH_AKVS, 12) if death_date ==. & DEATH_AKVS !=0
* replace death date with last appearance in AKVS if death is recorded in AKVS but year is missing (=9999)
replace death_date = ym(LAST_SEEN, 12) if death_date == ym(9999,12)
format death_date %tm
la var death_date "Death date"

gen expiration_date = .
forvalues i =13/22 {
	replace expiration_date = ym(RTWF_20`i',RTWF_MM_20`i') if expiration_date == . & MEGD_RTWF_20`i' == 28
	replace expiration_date = . if expiration_date <= retirement_date_RTZN
}
format expiration_date %tm
la var expiration_date "Expiration date (for temporary pension)"

gen recovery_date = .
forvalues i =13/22 {
	replace recovery_date = ym(RTWF_20`i',RTWF_MM_20`i') if recovery_date==. & inlist(MEGD_RTWF_20`i',  27, 29)
	replace recovery_date = . if recovery_date <= retirement_date_RTZN
}
format recovery_date %tm
la var recovery_date "End date for pension due to recovery or other reason."


gen retirement_end_date = expiration_date
replace retirement_end_date = recovery_date if recovery_date < retirement_end_date & recovery_date!=.
replace retirement_end_date = death_date if death_date < retirement_end_date & death_date !=.
la var retirement_end_date "End date for pension due to death/recovery/expiration."
format retirement_end_date %tm

********************************************************************************
* 3. Covariates (static)
********************************************************************************

* -> see 01_clean_RTZN.do

********************************************************************************
* 4. Covariates (dynamic)
********************************************************************************
* Variables that change with the value of JA


* Number of months that pension payments were received in a year.
gen RTEM_months_JA = 12
replace RTEM_months_JA = 0 if time < retirement_date_RTZN
replace RTEM_months_JA = 0 if retirement_end_date < time & retirement_end_date !=. 
replace RTEM_months_JA = retirement_end_date - ym(JA,01) if retirement_end_date <=  time & retirement_end_date >= ym(JA,01)

gen byte ACCEPTED = time <= acceptance_date_RTZN
la var ACCEPTED "Dummy recived acceptance notice before Stichtag"

********************************************************************************
* 5. Outcomes
********************************************************************************
* define outcome variables, all of them are measured at the Stichtag (31.12) of
* the respective year.

* Filter EMPPEN earnings
* Clean earnings from work in Werkstädten für Menschen mit Behindeurng
* 1. get 80% of Bezugsgrösse in a given year
gen bezugsgroesse_west = .
replace bezugsgroesse_west = 31500 if JA ==2012
replace bezugsgroesse_west = 32340 if JA ==2013
replace bezugsgroesse_west = 33180 if JA ==2014
replace bezugsgroesse_west = 34020 if JA ==2015
replace bezugsgroesse_west = 34860 if JA ==2016
replace bezugsgroesse_west = 35700 if JA ==2017
replace bezugsgroesse_west = 36540 if JA ==2018
replace bezugsgroesse_west = 37380 if JA ==2019
replace bezugsgroesse_west = 38220 if JA ==2020
replace bezugsgroesse_west = 39480 if JA ==2021
replace bezugsgroesse_west = 38480 if JA ==2022
replace bezugsgroesse_west = bezugsgroesse_west*0.8

gen bezugsgroesse_ost = .
replace bezugsgroesse_ost = 26880 if JA ==2012
replace bezugsgroesse_ost = 27300 if JA ==2013
replace bezugsgroesse_ost = 28140 if JA ==2014
replace bezugsgroesse_ost = 28980 if JA ==2015
replace bezugsgroesse_ost = 30240 if JA ==2016
replace bezugsgroesse_ost = 31920 if JA ==2017
replace bezugsgroesse_ost = 32340 if JA ==2018
replace bezugsgroesse_ost = 34440 if JA ==2019
replace bezugsgroesse_ost = 36120 if JA ==2020
replace bezugsgroesse_ost = 37380 if JA ==2021
replace bezugsgroesse_ost = 37800 if JA ==2022
replace bezugsgroesse_ost = bezugsgroesse_ost*0.8

*2 compare incomes to bezugsrösse
gen aux_EMPPEN_fullyear = EMPPEN_earnings/EMPPEN_days
replace aux_EMPPEN_fullyear = aux_EMPPEN_fullyear* 365 if JA!=2016 & JA != 2020
replace aux_EMPPEN_fullyear = aux_EMPPEN_fullyear* 366 if inlist(JA, 2016, 2020)

* 3. get differente between 80% of Bezugsgrösse and Income
gen aux_diff_west = bezugsgroesse_west - aux_EMPPEN_fullyear
gen aux_diff_ost = bezugsgroesse_ost - aux_EMPPEN_fullyear

* create dummy for income very close to the Bezugsgrösse
gen byte INCOME_BEZUGSGROESSE = abs(aux_diff_ost) < 500 | abs(aux_diff_west) < 500


* 4. REPLACE EMPLYOMENT AS 0 if DUMMY IS 1
replace EMPPEN_earnings_AKVS = 0 if INCOME_BEZUGSGROESSE == 1 & dist_entry >0
replace EMPPEN_days_AKVS = 0 if INCOME_BEZUGSGROESSE==1 & dist_entry >0


*5.  Overall regular employment & earnings variable
gen REGEMP_days_AKVS = EMPPEN_days_AKVS + EMP_days_AKVS + MIEMP_days_AKVS
replace REGEMP_days_AKVS = 366 if REGEMP_days_AKVS > 366 & REGEMP_days_AKVS != .
label variable REGEMP_days_AKVS "Tage aus Beschäftigung (ohne Minijobs)"

gen REGEMP_earnings_AKVS = EMPPEN_earnings_AKVS + EMP_earnings_AKVS + MIEMP_earnings_AKVS
*replace REGEMP_earnings_AKVS = 0 if INCOME_BEZUGSGROESSE==1 & dist_entry >0
label variable REGEMP_earnings_AKVS "Entgelt aus Beschäftigung (ohne Minijobs)"



* LM outcomes
foreach var in REGEMP MEMP UEMP OBENFIT {
	
	gen Y_`var'_days = `var'_days_AKVS
	replace Y_`var'_days =0 if Y_`var'_days == .
	la var Y_`var'_days "Days in `var' this year"
	
	gen byte Y_`var' = Y_`var'_days > 0
	la var Y_`var' "Dummy `var' this year"
	
	gen Y_`var'_earnings = `var'_earnings_AKVS
	replace Y_`var'_earnings = 0 if Y_`var'_earnings == .
}

* any employment
gen Y_WORK = Y_MEMP + Y_REGEMP
replace Y_WORK = 1 if Y_WORK > 1 & Y_WORK !=.
la var Y_WORK "Dummy any employment (marginal or insured)"



gen byte Y_NONPAR = Y_REGEMP == 0 & Y_MEMP == 0 & Y_UEMP == 0 & Y_OBENFIT == 0 
la var Y_NONPAR "Dummy nonparticipation in LM this year"


* 2. Death and pensione ending.
* Alive by end of year
gen byte Y_ALIVE = ym(year(dofm(death_date)),01) > time | death_date == .
la var Y_ALIVE "Alive this year"


* pension status in AKVS
gen Y_STATUS = .
replace Y_STATUS = 1 if (RTJA_AKVS == . & dist_entry >=0) | RTJA_AKVS == 75  | RTJA_AKVS == 15 
replace Y_STATUS = 2 if (RTJA_AKVS == . & dist_entry >=0 & EM_partial==1) | RTJA_AKVS == 74 
replace Y_STATUS = 3 if RTJA_AKVS == 62 | RTJA_AKVS == 63 | RTJA_AKVS == 65 | RTJA_AKVS == 17 | RTJA_AKVS == 16
replace Y_STATUS = 4 if RTJA_AKVS == 0 
* old age retirement
gen age_now = (ym(JA,12) - birthdate_RTZN)/12
replace Y_STATUS = 3 if RTJA_AKVS==1 & age_now >=65
* status before entry
replace Y_STATUS = 4 if Y_STATUS==. & dist_entry < 0


label define status 1 "Disability pension"  2 "Partial disability pension" 3 "Old age pension" 4 "No pension" 
label values Y_STATUS status
la var Y_STATUS "Pension status as recorded in AKVS"



********************************************************************************
* 6. Save data
********************************************************************************
save $PROCESS_TEMP\working_sample_rtzn_rtwf_akvs.dta, replace





