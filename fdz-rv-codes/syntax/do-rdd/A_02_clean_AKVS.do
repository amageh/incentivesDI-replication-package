********************************************************************************
* Projekt: Incentive Effects of Disability Benefits
* Author: Annica Gehlen & Sebastian Becker
* Purpose: Merge and clean the AKVS data to track individuals after DI entry
* Produces: akvs_processed.dta
********************************************************************************


********************************************************************************
* 1. Merge data
********************************************************************************
use $DATA/AKVS/sample_AKVS_2012.dta, clear
// append the AKVS datasets
forvalues i = 12/22 {
	
	append using $DATA/AKVS/sample_AKVS_20`i'.dta
	
}


********************************************************************************
* 2. Create new variables
********************************************************************************

* Consolidate variables
* DEATH ------------------------------------------------------------------------
gen TD_AKVS = TD
*replace TD_AKVS = TD if td == .
label variable TD_AKVS "Todesdatum"


* EDUCATION --------------------------------------------------------------------
gen TTSCJA2_KLDB2010_AKVS = TTSCJA2_KLDB2010 
label variable TTSCJA2_KLDB2010_AKVS "Tätigkeitsschlüssel - Schulabschluss (KldB 2010)"
label values TTSCJA2_KLDB2010_AKVS TTSCJA2_KLDB2010


gen TTSCJA3_KLDB2010_AKVS = TTSCJA3_KLDB2010
label variable TTSCJA3_KLDB2010_AKVS "Tätigkeitsschlüssel - Ausbildungsabschluss (KldB 2010)"
label values TTSCJA3_KLDB2010_AKVS TTSCJA3_KLDB2010


* PENSIONS ---------------------------------------------------------------------
* Pension
rename TLRTJA TLRTJA_AKVS

rename RTJA RTJA_AKVS

rename VSRTJA VSRTJA_AKVS

* Pension + Work
rename TLTGJA TLTGJA_AKVS 

rename TLEGJA TLEGJA_AKVS

* EMPLOYMENT -------------------------------------------------------------------
* Stichtag Variablen
rename VSBHJA VSBHJA_AKVS

rename VSGIJA VSGIJA_AKVS

rename VSGIPHJA VSGIPHJA_AKVS

rename TTSCJA1_KLDB2010 TTSCJA1_KLDB2010_AKVS

rename TTSCJA1_KLDB1988 TTSCJA1_KLDB1988_AKVS

* Regular employment: days & earnings
gen EMP_days_AKVS = .
replace EMP_days_AKVS = BHTGJA1 + BHTGJA2 if EMP_days_AKVS == .
replace EMP_days_AKVS = 366 if EMP_days_AKVS > 366
label variable EMP_days_AKVS "Beschäftigungszeit im Berichtsjahr"

gen EMP_earnings_AKVS = .
replace EMP_earnings_AKVS = BHEGJA1 + BHEGJA2 if EMP_earnings_AKVS == .
label variable EMP_earnings_AKVS "Beschäftigungsentgelt im Berichtsjahr"

* Midijobs
gen MIEMP_days_AKVS = .
replace MIEMP_days_AKVS = BHGZTGJA 
replace MIEMP_days_AKVS = 366 if MIEMP_days_AKVS > 366
label variable MIEMP_days_AKVS " Beschäftigungszeit mit reinem Entgelt im Übergangsbereich"

gen MIEMP_earnings_AKVS = .
replace MIEMP_earnings_AKVS = BHGZEGJA if MIEMP_earnings_AKVS == .
label variable MIEMP_earnings_AKVS "Beschäftigungsentgelt im Übergangsbereich"


* Marginal employment: days & earnings
gen MEMP_days_AKVS = .
replace MEMP_days_AKVS = GIFHTGJA + GIPFTGJA + GIPHFHTGJA + GIPHPFTGJA if MEMP_days_AKVS == .
replace MEMP_days_AKVS = 366 if MEMP_days_AKVS > 366
label variable MEMP_days_AKVS "Geringfügige Beschäftigungszeit"

* To compute earnings for marginal employment, we have to distinguish between
* im/außerhalb Privathaushalt. The AKVS contains the employer contributions
* for these individuals, which we can use to compute the actual earnings for that
* year

* contributions regular minjob only employer contribs: 15%
* contributions regular minjob employer and employee contribs: 15+3.6=18.6%
* contributions privathaushalt only employer contribs: 5%
* contributions privathaushalt employer and employee contribs: 5+13.6=18.6%

gen MEMP_earnings_AKVS = 0
* Reg. Minjob (nicht privathaushalt)
replace MEMP_earnings_AKVS = MEMP_earnings_AKVS+ (GIFHBYJA*100/15)
replace MEMP_earnings_AKVS = MEMP_earnings_AKVS+ (GIPFBYJA*100/18.6)
* Privathaushalt
replace MEMP_earnings_AKVS = MEMP_earnings_AKVS+ (GIPHFHBYJA*100/5)
replace MEMP_earnings_AKVS = MEMP_earnings_AKVS+ (GIPHPFBYJA*100/18.6)
label variable MEMP_earnings_AKVS "Beiträge aufgrund einer geringfügigen Beschäftigung "


* Unemployment
gen UEMP_days_AKVS = .
replace UEMP_days_AKVS = AFGTGJA1 + AFGTGJA2 + ALHITGJA1 if UEMP_days_AKVS == .
replace UEMP_days_AKVS = 366 if UEMP_days_AKVS > 366
label variable UEMP_days_AKVS "Zeiten mit Arbeitslosigkeit (II / III) im Berichtsjahr"

gen UEMP_earnings_AKVS = .
replace UEMP_earnings_AKVS = AFGBYJA1 + AFGBYJA2 if UEMP_earnings_AKVS == .
label variable UEMP_earnings_AKVS "Höhe der beitragspflichtigen Einnahmen bei SGB III-Leistungsbezug"


* Sonstiger Leistungsbezug
gen OBENFIT_days_AKVS = .
replace OBENFIT_days_AKVS = LETGJA1 + LETGJA2 if OBENFIT_days_AKVS == .
replace OBENFIT_days_AKVS = 366 if OBENFIT_days_AKVS > 366
label variable OBENFIT_days_AKVS "Zeiten mit sonstigem Leistungsbezug im Berichtsjahr "

gen OBENFIT_earnings_AKVS = .
replace OBENFIT_earnings_AKVS = LEBYJA1 + LEBYJA2 if OBENFIT_earnings_AKVS == .
label variable OBENFIT_earnings_AKVS "Höhe der Einnahmen aus sonstigem Leistungsbezug im Berichtsjahr"


* Pension + Work
gen EMPPEN_days_AKVS = TLTGJA_AKVS 
label variable EMPPEN "Beschäftigung neben Rentenbezug"

gen EMPPEN_earnings_AKVS = TLEGJA_AKVS
label variable EMPPEN_earnings_AKVS "Entgelt aus Beschäftigung neben Rentenbezug"


* OTHER VARIABLES --------------------------------------------------------------
* Versicherungszeiten.
rename TGSUJA TGSUJA_AKVS
la var TGSUJA_AKVS "Summe aller belegten Tage im Berichtsjahr"

rename  TGSUVSJA TGSUVSJA_AKVS
la var TGSUVSJA_AKVS  "Summe der mit ausgewählten Versicherungszeiten belegten Tage im Berichtsjahr"

* Other
gen OTHER_days_AKVS = TGSUJA_AKVS - TGSUVSJA_AKVS
label variable OTHER_days_AKVS "Belegte Tage aus sonstigen Zeiten (hauptsächlich AZ)"


* Uncomment once we have all the AKVS!
*gen AZ_days_AKVS = AZTGJA
*gen AZ_type_AKVS = AZATJA

* ID and year variable
*replace FDZ_ID = fdz_id if JA == .
*replace JA = ja if JA == .


********************************************************************************
* 3. Keep only relevant variables, drop duplicates, and save data
********************************************************************************
keep FDZ_ID JA *_AKVS

drop if JA == .

sort FDZ_ID JA 
by FDZ_ID JA: gen dup = cond(_N==1, 0, _n)
drop if  dup > 1


* SAVE DATA
compress
save $PROCESS_TEMP\akvs_processed.dta, replace


********************************************************************************

