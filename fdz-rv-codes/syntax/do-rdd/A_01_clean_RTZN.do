********************************************************************************
* Projekt: Incentive Effects of Disability Benefits
* Author: Annica Gehlen & Sebastian Becker
* Purpose: Merge and clean RTZN files to generate one large file that
* 			contains all new entries
* Produces: rtzn_processed.dta, rtzn_ids.dta, rtzn_2012_2021.dta
********************************************************************************


********************************************************************************
* 1. Merge RTZN files
********************************************************************************

use $DATA/RTZN/OSV.RTZN.2011.EM.dta, clear
forvalues i = 12/21 {
	append  using $DATA/RTZN/OSV.RTZN.20`i'.EM.dta, force
}


********************************************************************************
** 2. Filter data set & select variables 
********************************************************************************
* Drop if not first pension 
drop if RTBE != ZTPTRTBE


********************************************************************************
** 3. Generate new variables 
********************************************************************************

* ------------------------------------------------------------------------------
* 3.1. Dates
* ------------------------------------------------------------------------------
// Generate date variables
// date of birth
gen birthdate = ym( GBJAVS,   GBMOVS)
format birthdate %tm
label var birthdate "Date of birth of the individual" 

// date at which the individual received its acceptance
gen acceptance_date = ym(BXDT_JJJJ, BXDT_MM)
label var acceptance_date "Date at which the individual was notified about its acceptance" 
gen acceptance_date_mdy = mdy(BXDT_MM, BXDT_TT, BXDT_JJJJ)

// date at which the individual actually applied for disability pension
gen application_date = ym( AQDT_JJJJ, AQDT_MM)
label var application_date "Date of application"
gen application_date_mdy = mdy(AQDT_MM, AQDT_TT, AQDT_JJJJ)

// date from which on the individual was impaired 
gen eligible_date = ym( ZTPTGSLE_JJJJ, ZTPTGSLE_MM)
label var eligible_date "Date from which on the individual was eligible."
gen eligible_date_mdy = mdy(ZTPTGSLE_MM, 1, ZTPTGSLE_JJJJ)

// date from which on the individual was empaired 
gen retirement_date = ym(  ZTPTRTBE_JJJJ, ZTPTRTBE_MM)
label var retirement_date "Date of retirement entry"
gen retirement_date_mdy = mdy(ZTPTRTBE_MM, 1, ZTPTRTBE_JJJJ)

* ------------------------------------------------------------------------------
* 3.2. Covariates
* ------------------------------------------------------------------------------
drop AE
gen AE_exact = retirement_date - birthdate
replace AE_exact = AE_exact/12
gen AE = floor(AE_exact)

label var AE_exact "Retirement date - birthdate (exact on months)"
label var AE "Retirement date - birthdate (in years)"

* Additional variable for diagnosis categorization.
gen diagnose_cat = .
replace diagnose_cat = 0 if inlist(DG_1, "F")
replace diagnose_cat = 1 if inlist(DG_1, "C", "D")
replace diagnose_cat = 2 if inlist(DG_1, "E") 
replace diagnose_cat = 3 if inlist(DG_1, "G")
replace diagnose_cat = 4 if inlist(DG_1, "M")
replace diagnose_cat = 5 if inlist(DG_1, "I")
replace diagnose_cat = 6 if inlist(DG_1, "J")
replace diagnose_cat = 7 if inlist(DG_1, "K")
replace diagnose_cat = 8 if inlist(DG_1, "S", "T")
replace diagnose_cat = 9 if inlist(DG_1, "A", "B", "H", "L", "N", "O", "P")
replace diagnose_cat = 9 if inlist(DG_1, "Q","R", "Z", "U", "V", "X", "Y")
label define diagnose_cat 0 "Mental" 1 "Neoplasms/Blood disease" 2 "Metabolism" 3 "Nerves" 4"Muscles" ///
5 "Circulatory system"  6"Respiratory system" 7 "Digestive system" 8 "Accident" 9 "Other" 
label values diagnose_cat diagnose_cat


* Additional variable for diagnosis categorization.
gen diagnoses = .
replace diagnoses = 0 if inlist(DG_1, "F")
replace diagnoses = 1 if inlist(DG_1, "I")
replace diagnoses = 2 if inlist(DG_1, "C") 
replace diagnoses = 3 if inlist(DG_1, "M")
replace diagnoses = 4 if inlist(DG_1, "G")
replace diagnoses = 5 if inlist(DG_1, "D", "E", "J", "K", "S", "T")
replace diagnoses = 5 if inlist(DG_1, "A", "B", "H", "L", "N", "O", "P")
replace diagnoses = 5 if inlist(DG_1, "Q","R", "Z", "U", "V", "X", "Y")

label define diagnoses 0 "Mental disorder" 1 "Circulatory system" 2 "Neoplasms" 3 "Musculoskeletal system" 4 "Nervous system" ///
5 "Other" 
label values diagnoses diagnoses

* Has german citizenship/ vertragsrente
gen byte german_citizen = SAVS == 0
gen byte vertragsrente = VTLDNTSCN != 0 & VTLDNTSCN != .
replace vertragsrente = 0 if VTLDNTSC == 0
gen byte FRG_times = FRGLD != 0 & VTLDNTSCN != .
gen byte diagnoses_unbalanced = inlist(DG_1, "P","Q", "R")

* detailed diagnosis
gen DG_detail = substr(DG,1, 3)

* Anrechungszeiten und Beitragszeiten for previous earnings history
gen AZ_UEMP = AJAZ_1 + AJAZ_2 + AJAZ_3 + AJAZ_4 + AJAZNL_1 + AJAZNL_2 + AJAZNL_3 + AJAZNL_4
la var AZ_UEMP "Time credit unemployment"
gen AZ_SICK = AUAZ_1 + AUAZ_2 + AUAZ_3 + AUAZ_4 + AUAZNL_1 + AUAZNL_2 + AUAZNL_3 + AUAZNL_4
la var AZ_SICK "Time credit sickness"
gen AZ_SCHOOL = SCHULAZ_1 + SCHULAZ_2 + SCHULAZ_3 + SCHULAZ_4 
la var AZ_SCHOOL "Time credit school"
gen AZ_FULL_CONTRIB = BYVLGS
la var AZ_FULL_CONTRIB "Full contribution times (BYVLGS)"
gen AZ_REDUC_CONTRIB = BYGMGS
la var AZ_REDUC_CONTRIB "Reduced contribution times (BYGMGS)"
gen AZ_ZZ = ZZGS
la var AZ_ZZ "Supplementary times (ZZGS)"


gen EGPT_FULL_CONTRIB = BYVLEGPT_1 + BYVLEGPT_2 + BYVLEGPT_3 + BYVLEGPT_4
la var EGPT_FULL_CONTRIB "EGPT full contribution times (BYVLEGPT)"
gen EGPT_REDUC_CONTRIB = BYGMEGPT_1 + BYGMEGPT_2 + BYGMEGPT_3 + BYGMEGPT_4
la var EGPT_REDUC_CONTRIB "EGPT reduced contribution times (BYGMEGPT)"


gen byte female = GEH == 2
la var female "Gender female"

* Variables about n kids before and after 1992 for mother pension corrections
gen n_kids = ZLKI12 if ZLKI12 !=0 & ZLKI12!=.
gen n_kids92 = ZLKI12
replace n_kids92 = 0 if ZLKI12 ==0 | ZLKI12==.
replace n_kids = n_kids + ZLKI36 if ZLKI36 !=0 & ZLKI36!=.
la var n_kids "Number of children"
la var n_kids92 "Number of children born before 1992"

gen byte has_kids = n_kids != .
gen byte has_kids92 = n_kids92 > 0

la var has_kids "Has children recorded in their account"
la var has_kids92 "Has children born before 1992"

********************************************************************************
** 4. Filter & label variables.
*******************************************************************************

// specify the variables that we want to keep 
#delimit;
global KEEP_VARS "SK PSY FDZ_ID PSYAT SYDT acceptance_date application_date eligible_date
retirement_date acceptance_date_mdy application_date_mdy
eligible_date_mdy retirement_date_mdy diagnoses_unbalanced female n_kids has_kids diagnoses
german_citizen UDAQ FMSD diagnose_cat diagnoses DGGDGR EGPT187AN
DGSX DG_detail RTBT RTZB AUSZB RTAT SUEPGS ZNFK1 RWJA_MM ATN BRNRN LEAT1
VGEGPTEM BYFHGS VGEGPT ZLMCMS VSJ_GRP VSMO AE_exact AE DUEPGS_GRP PSEGPTGS
TTSC1_KLDB1988 TTSC1_KLDB2010 TTSC2_KLDB2010 TTSC3_KLDB2010 TTSC4_KLDB2010 TTSC5_KLDB2010
JV1 JV2 JV3 JV123 JVTG1 JVTG2 JVTG3 JVTG123 DG_1 NNDG_1 GSLEN birthdate
RTMI MOAB ZZGS ZZEP GBJAVS GBMOVS GSLEEPDX VGEGPTDX VGEGPTEM GDEGPTDX RWJA_JJJJ
SUEGPT_1 SUEGPT_2 SUEGPT_3 SUEGPT_4 ZZEP vertragsrente RTMI FRG_times
KNBT BFMS AIMK LEAT FMSD RSCHULAZ AZ_UEMP AZ_SICK AZ_SCHOOL  AZ_FULL_CONTRIB
AZ_REDUC_CONTRIB AZ_ZZ EGPT_FULL_CONTRIB EGPT_REDUC_CONTRIB TLRT TLRTBT RTEK
ANTLRTN WZMO VAN VAZUGS VAABGS WESTOSTN ZLKI12 ZLKI36
ZZ_1 ZZ_2 ZZ_3 ZZ_4 KNEGPT
AQDT BXDT ZTRT OPXAZ VGMO GDMO n_kids92 has_kids92 ZLKI12 ZLKI36 SAVS GBLDN GBLD RTBE";
#delimit cr

// drop all variables that we identified as not necessary for our analysis
keep $KEEP_VARS

// rename all variables except the unique identifier such that the name indicates 
// that the variable stems from the RTZN dataset
foreach i of varlist _all {

	if "`i'" == "FDZ_ID" {
	continue
	}
	rename `i' `i'_RTZN
}

********************************************************************************
** 5. Drop duplicates
********************************************************************************
// if application and acceptance date is the same just drop the duplicates
sort FDZ_ID retirement_date_RTZN application_date_RTZN
by FDZ_ID retirement_date_RTZN application_date_RTZN: gen duplicate_counter2 = cond(_N==1, 0, _n)
drop if  duplicate_counter2 > 1

**********************************************
* Save entire merged RTZN w/ potentially duplicates
save $PROCESS_TEMP\rtzn_2012_2021.dta, replace
**********************************************


// next drop duplicate IDs that do not have same spell.
sort FDZ_ID retirement_date_RTZN
by FDZ_ID: gen duplicate_counter3 = cond(_N==1, 0, _n)
drop if  duplicate_counter3 > 1

// next
sort FDZ_ID
by FDZ_ID: gen duplicate_counter1 = cond(_N==1, 0, _n)
drop if  duplicate_counter1 > 1


* Drop individuals who did not start their pension between 2020 & 2010
keep if retirement_date_RTZN < ym(2020,01) & retirement_date_RTZN > ym(2010,12)


* Create numeric ID Variable.
egen long fdz_id_num = group(FDZ_ID)

********************************************************************************
* 6. Further data cleaning 
********************************************************************************
* ------------------------------------------------------------------------------
* 6.1. Variables related to pension & timing
* ------------------------------------------------------------------------------

* Format time variables.
format retirement_date_RTZN %tm
format acceptance_date_RTZN %tm
format eligible_date_RTZN %tm
format application_date_RTZN %tm

format retirement_date_mdy_RTZN %td
format acceptance_date_mdy_RTZN %td
format eligible_date_mdy_RTZN %td
format application_date_mdy_RTZN %td

* Variable for pension type.
gen EM_type = .
replace EM_type = 1 if inlist(LEAT_RTZN, 75)
replace EM_type = 2 if inlist(LEAT_RTZN, 76)
replace EM_type = 3 if inlist(LEAT_RTZN, 73,74)
replace EM_type = 4 if inlist(LEAT_RTZN, 11, 12, 13, 14, 43, 15, 71, 72)
label define em_type 1 "Regular full pension" 2 "20 year full pension" ///
3 "Partial pension" 4 "Other"

tab EM_type LEAT_RTZN
label values EM_type em_type


* Variable for distance between dates in the application process
gen dist_eli_app = application_date_mdy_RTZN - eligible_date_mdy_RTZN
la var dist_eli_app "Eligibility to application (days)"

gen dist_eli_ent = retirement_date_mdy_RTZN - eligible_date_mdy_RTZN
la var dist_eli_ent "Eligibility to entry (days)"

gen dist_app_ent = retirement_date_mdy_RTZN - application_date_mdy_RTZN
la var dist_app_ent "Application to entry (days)"

gen dist_app_acc = acceptance_date_mdy_RTZN - application_date_mdy_RTZN
la var dist_app_acc "Application to acceptance (days)"

gen dist_acc_ent = retirement_date_mdy_RTZN - acceptance_date_mdy_RTZN
la var dist_acc_ent "Acceptance to entry (days)"

gen dist_entry_reform2014 = -(ym(2014,07) - retirement_date_RTZN)
la var dist_entry_reform2014 "Months btw entry date & reform."

* calendar month of retirement
gen retirement_month_RTZN = month(dofm(retirement_date_RTZN))
gen retirement_year_RTZN = year(dofm(retirement_date_RTZN))


* Indicator for check of LM
gen byte no_check_LM = (inlist(AIMK_RTZN,1))
label variable no_check_LM "Prüfung Arbeitsmarktes (AIMK, AIMKN)"
* Indicator partial EM
gen byte EM_partial = LEAT_RTZN == 74
label variable EM_partial "Partial Pension (LEAT)"
* iIndicator erweiterte BU
gen byte EM_erweiert_BU = LEAT_RTZN == 43
label variable EM_erweiert_BU "Erweiterte BU (LEAT)"

* Treatment variable.
gen byte treat = retirement_date_RTZN >= tm(2014,07)
*gen byte post = date_em_entry <= date
la var treat "Dummy that indicates individuals that enter disability pension after 2014 m6"
gen byte control = treat == 0
 
* Bandwidth variable for sample selection (here July 2014 = 1 instead of 0)
gen bandwidth = dist_entry_reform2014
replace bandwidth = bandwidth + 1 if bandwidth >=0
la var bandwidth "Months from reform date."

* ------------------------------------------------------------------------------
* 6.2. Covariates (static)
* ------------------------------------------------------------------------------

* MISCELLANEOUS
gen byte befristet = ZTRT_RTZN == 1
la var befristet "Temporary pension"
gen byte unbefristet = befristet != 1
la var unbefristet "Permanent pension"
gen byte married = FMSD_RTZN == 2
la var married "Married"
gen byte single = married != 1
la var single "Single"
gen byte reha_prev5y = ZLMCMS_RTZN > 0 & ZLMCMS_RTZN != 9 & ZLMCMS_RTZN != .
la var reha_prev5y " Received medical rehabilitation in the past 5 years."
gen byte teilhabe_prev5y = BFMS > 0 & BFMS != 9 & BFMS != .
la var reha_prev5y " Received labor market rehabilitation in the past 5 years."

* PRIMARY DIAGNOSIS
* Small groups
gen diag = diagnose_cat_RTZN
label values diag diagnose_cat
tabulate diag, generate(diag_D_)
drop diag
label var diag_D_1 "Mental" 
label var diag_D_2 "Neoplasms/Blood disease" 
label var diag_D_3 "Metabolism" 
label var diag_D_4 "Nerves" 
label var diag_D_5 "Muscles"
label var diag_D_6 "Circulatory system"  
label var diag_D_7 "Respiratory system" 
label var diag_D_8 "Digestive system" 
label var diag_D_9 "Accident" 
label var diag_D_10 "Other" 

* Large groups
gen diag = diagnoses_RTZN
label values diag diagnoses
tabulate diag, generate(diag_)
drop diag
label var diag_1 "Mental disorder" 
label var diag_2 "Circulatory system" 
label var diag_3 "Neoplasms" 
label var diag_4 "Musculoskeletal system"
label var diag_5 "Nervous System"
label var diag_6 "Other"

* AGE GROUPS
* Large groups
gen byte age_1 = AE_RTZN < 40
label var age_1 "Below 40"
gen byte age_2 = AE_RTZN < 50 & AE_RTZN >= 40
label var age_2 "40-49"
gen byte age_3 = AE_RTZN < 60 & AE_RTZN >= 50
label var age_3 "50-59"
gen byte age_4 = AE_RTZN > 59
label var age_4 "60+"


* Smaller groups
gen byte AE_group = .
replace AE_group = 0 if AE_RTZN < 30
replace AE_group = 1 if AE_RTZN >= 30 & AE_RTZN < 40
replace AE_group = 2 if AE_RTZN >= 40 & AE_RTZN < 50
replace AE_group = 3 if AE_RTZN >= 50 & AE_RTZN < 55
replace AE_group = 4 if AE_RTZN >= 55 & AE_RTZN < 60
replace AE_group = 5 if AE_RTZN >= 60 & AE_RTZN < 62
replace AE_group = 6 if AE_RTZN >= 62
replace AE_group = . if AE_RTZN == 999

label define ae_group 0 "u30" 1 "30-39" 2 "40-49" 3 "50-54" 4 "50-59" 5 "60-61" 6 "62+"
label values AE_group ae_group

* OCCUPATIONS
* Reduce digits in occ classification (we use KlDB 1988 since it has the least missings)
gen occ_2d = .
replace occ_2d = TTSC1_KLDB1988_RTZN/10 if TTSC1_KLDB1988_RTZN > 99 
replace occ_2d = TTSC1_KLDB1988_RTZN/10 if TTSC1_KLDB1988_RTZN > 9 &  TTSC1_KLDB1988_RTZN <100
replace occ_2d = -1 if TTSC1_KLDB1988_RTZN == . | TTSC1_KLDB1988_RTZN == 0 | TTSC1_KLDB1988_RTZN == 999
replace occ_2d = floor(occ_2d)

* 1. Classify occupations into 6 categories corresponding to the "Bereiche" Level in KlDB 1988
gen kldb1988_bereich = .
replace kldb1988_bereich = 1 if occ_2d < 7 & occ_2d != -1
replace kldb1988_bereich = 2 if occ_2d > 6 & occ_2d < 10  & occ_2d != -1
replace kldb1988_bereich = 3 if occ_2d > 9 & occ_2d < 60  & occ_2d != -1
replace kldb1988_bereich = 4 if occ_2d > 59 & occ_2d < 68  & occ_2d != -1
replace kldb1988_bereich = 5 if occ_2d > 67 & occ_2d < 97  & occ_2d != -1
replace kldb1988_bereich = 6 if occ_2d > 96 & occ_2d < 100  & occ_2d != -1
replace kldb1988_bereich = -1 if occ_2d == -1

label define kldb1988_bereich 1 "Farmers and Fishers" 2 "Miners"  3 "Manufacturing" 4 "Technical Occ." 5 "Service" 6 "Other" -1 "N/A"
label values kldb1988_bereich kldb1988_bereich
label variable kldb1988_bereich "Classifcation KldB 1988 (area/highest level)"

* 2. Classify occupations into Blue & white collar
gen occupation = .
replace occupation = 1 if inlist(kldb1988_bereich, 1, 2, 3)
replace occupation = 2 if inlist(kldb1988_bereich, 4, 5, 6)
replace occupation = -1 if kldb1988_bereich == -1


label define occupation 1 "Blue Collar" 2 "White Collar"  -1 "N/A"
label values occupation occupation
label variable occupation "Occupation (blue/white collar)"


gen byte blue_collar = occupation == 1
gen byte white_collar = occupation == 2
gen byte occ_unknown = occupation == -1


* ------------------------------------------------------------------------------
* 6.2. PENSION CORRECTIONS & SIMULATION
* ------------------------------------------------------------------------------
* 1. STANDARDIZE PENSIONS
* Standardize pensions to 2014 Rentenwert (reason: RTBT is recorded for the 
* pension value at entry date, we want to standardize all pensions to the value of
* a pension point in 2014). To do so we multiply by the relative increase increase
* in pension values weighted by the share of credits east as these have a different
* pension value that credits earned in the west.
gen date_rentenwert = ym(RWJA_JJJJ_RTZN, RWJA_MM_RTZN)
format date_rentenwert %tm
gen RTBT_2014 = RTBT_RTZN 
replace RTBT_2014 = RTBT_2014 * 1.0226 * OPXAZ_RTZN + RTBT_2014 * 1.0218 * (1-OPXAZ_RTZN) if date_rentenwert <tm(2012m7)
replace RTBT_2014 = RTBT_2014 * 1.0329 * OPXAZ_RTZN + RTBT_2014 * 1.0025 * (1-OPXAZ_RTZN) if date_rentenwert <tm(2013m7)
replace RTBT_2014 = RTBT_2014 * 1.0253 * OPXAZ_RTZN + RTBT_2014 * 1.0167 * (1-OPXAZ_RTZN) if date_rentenwert <tm(2014m7)

* recursively go back to 2014 value if entry is later than 2014
replace RTBT_2014 = RTBT_2014 / 1.0420 * OPXAZ_RTZN + RTBT_2014 / 1.0345 * (1-OPXAZ_RTZN) if date_rentenwert >tm(2020m6)
replace RTBT_2014 = RTBT_2014 / 1.0391 * OPXAZ_RTZN + RTBT_2014 / 1.0318 * (1-OPXAZ_RTZN) if date_rentenwert >tm(2019m6)
replace RTBT_2014 = RTBT_2014 / 1.0337 * OPXAZ_RTZN + RTBT_2014 / 1.0322 * (1-OPXAZ_RTZN) if date_rentenwert >tm(2018m6)
replace RTBT_2014 = RTBT_2014 / 1.0359 * OPXAZ_RTZN + RTBT_2014 / 1.0190 * (1-OPXAZ_RTZN) if date_rentenwert >tm(2017m6)
replace RTBT_2014 = RTBT_2014 / 1.0595 * OPXAZ_RTZN + RTBT_2014 / 1.0425 * (1-OPXAZ_RTZN) if date_rentenwert >tm(2016m6)
replace RTBT_2014 = RTBT_2014 / 1.0250 * OPXAZ_RTZN + RTBT_2014 / 1.0210 * (1-OPXAZ_RTZN) if date_rentenwert >tm(2015m6)

* Add mother pension income to standardized benefits. Recipients get 1 pension credit
* per child born before 1992. Pension credits east are relevant in the following
* way: "EGPT (Ost) werden bei der Mütterente nur zugeordnet, wenn Kindererziehungs-
* zeiten ausschliesslich EGPT (Ost) zugeordnet worden sind." (Dünn & Stosberg, 2014)
* We approximate this rule by assigning EGPT Ost for those who have OPXAZ >= 1.

replace RTBT_2014 = RTBT_2014 + ZLKI12_RTZN*26.39 if retirement_date_RTZN < ym(2014,07) & OPXAZ_RTZN < 1
replace RTBT_2014 = RTBT_2014 + ZLKI12_RTZN*28.61 if retirement_date_RTZN < ym(2014,07) & OPXAZ_RTZN >= 1

la var RTBT_2014 "Standardized RTBT (2014)"


* Get RTBT increase standardized to 2014 w/o mother pension correction
gen RTBT_2014_mp = RTBT_RTZN 
replace RTBT_2014_mp = RTBT_2014_mp * 1.0226 * OPXAZ_RTZN + RTBT_2014_mp * 1.0218 * (1-OPXAZ_RTZN) if date_rentenwert <tm(2012m7)
replace RTBT_2014_mp = RTBT_2014_mp * 1.0329 * OPXAZ_RTZN + RTBT_2014_mp * 1.0025 * (1-OPXAZ_RTZN) if date_rentenwert <tm(2013m7)
replace RTBT_2014_mp = RTBT_2014_mp * 1.0253 * OPXAZ_RTZN + RTBT_2014_mp * 1.0167 * (1-OPXAZ_RTZN) if date_rentenwert <tm(2014m7)

* recursively go back to 2014 value if entry is later than 2014
replace RTBT_2014_mp = RTBT_2014_mp / 1.0420 * OPXAZ_RTZN + RTBT_2014_mp / 1.0345 * (1-OPXAZ_RTZN) if date_rentenwert >tm(2020m6)
replace RTBT_2014_mp = RTBT_2014_mp / 1.0391 * OPXAZ_RTZN + RTBT_2014_mp / 1.0318 * (1-OPXAZ_RTZN) if date_rentenwert >tm(2019m6)
replace RTBT_2014_mp = RTBT_2014_mp / 1.0337 * OPXAZ_RTZN + RTBT_2014_mp / 1.0322 * (1-OPXAZ_RTZN) if date_rentenwert >tm(2018m6)
replace RTBT_2014_mp = RTBT_2014_mp / 1.0359 * OPXAZ_RTZN + RTBT_2014_mp / 1.0190 * (1-OPXAZ_RTZN) if date_rentenwert >tm(2017m6)
replace RTBT_2014_mp = RTBT_2014_mp / 1.0595 * OPXAZ_RTZN + RTBT_2014_mp / 1.0425 * (1-OPXAZ_RTZN) if date_rentenwert >tm(2016m6)
replace RTBT_2014_mp = RTBT_2014_mp / 1.0250 * OPXAZ_RTZN + RTBT_2014_mp / 1.0210 * (1-OPXAZ_RTZN) if date_rentenwert >tm(2015m6)

* ------------------------------------------------------------------------------
* 2. SIMULATE PENSIONS BASED ON Grundberwertung and Vergleichsbewertungen

* A. Simulated pension amount for 2014 as is.
* 1. Get Gesamtbewertung
gen GSLEEPPDX_RTZN  = max(GDEGPTDX_RTZN, VGEGPTDX_RTZN, VGEGPTEM_RTZN)

* 2. Simulate Altersrente (i.e. exclude supplementary credits) (source: follows formula
* provided by the FDZ)
gen RTMOAGGS =  ZNFK1_RTZN * ((SUEGPT_1_RTZN - ZZ_1_RTZN * (1- OPXAZ_RTZN) * GSLEEPPDX_RTZN ) * 28.61 + (SUEGPT_2_RTZN - ZZ_1_RTZN * OPXAZ_RTZN * GSLEEPPDX_RTZN ) * 26.39)
replace RTMOAGGS = round(RTMOAGGS,0.01)
replace RTMOAGGS = 0 if RTMOAGGS < 0

* 3.Compute pension from supplementary credits using 2014 pension values.
gen ZZaddition = ZNFK1_RTZN * (ZZ_1_RTZN * (1- OPXAZ_RTZN) * GSLEEPPDX_RTZN * 28.61 + ZZ_1_RTZN * OPXAZ_RTZN * GSLEEPPDX_RTZN* 26.39)
replace ZZaddition = round(ZZaddition,0.01)
replace ZZaddition = 0 if ZZaddition < 0
*replace ZZaddition = ZNFK1_RTZN * (ZZ_1_RTZN * (1- OPXAZ_RTZN) * GSLEEPPDX_RTZN * 29.21 + ZZ_1_RTZN * OPXAZ_RTZN * GSLEEPPDX_RTZN* 27.05) if RWJA_MM_RTZN>6

* 4. Add both components for entire DI pension
gen RTBT_sim = RTMOAGGS + ZZaddition

* 5. Account for teilrente
replace RTBT_sim = RTBT_sim* (TLRTBT_RTZN/100) if TLRT_RTZN == 8
replace RTBT_sim = RTBT_sim*0.25 if TLRT_RTZN == 6
replace RTBT_sim = RTBT_sim*0.75 if TLRT_RTZN == 7
replace RTBT_sim = RTBT_sim*0.5 if TLRT_RTZN == 2

* 6. Account for partial EM
replace RTBT_sim = RTBT_sim*0.5 if EM_partial == 1

* 7. Correct for MP by adding additional pension credits for children born before 1992
replace RTBT_sim = RTBT_sim + ZLKI12_RTZN*26.39 if retirement_date_RTZN < ym(2014,07) & OPXAZ_RTZN < 1
replace RTBT_sim = RTBT_sim + ZLKI12_RTZN*28.61 if retirement_date_RTZN < ym(2014,07) & OPXAZ_RTZN >= 1


label var RTBT_sim "Simulated pension in Euros for 2014 RW"

* ------------------------------------------------------------------------------
* B. Simulated pension amount for 2014 w/o reform changes

* 1. Does not include additional Vergleichsbewertung for DI
gen GSLEEPPDX_counterfact  = max(GDEGPTDX_RTZN, VGEGPTDX_RTZN)


* 2. Compute new ZZ
gen age_at_au = eligible_date_RTZN - birthdate
gen ZZ_countfact = ZZ_1
replace ZZ_countfact = ZZ_countfact - 24 if age_at_au <= 60*12 & retirement_date_RTZN > ym(2014,06)
replace ZZ_countfact = ZZ_countfact - (62*12 - age_at_au) if age_at_au > 60*12 & age_at_au < 62*12 & retirement_date_RTZN > ym(2014,06)
replace ZZ_countfact = 0 if ZZ_countfact < 0


* 3. Compute new pension value
* Compute pension from supplementary credits
gen ZZaddition_countfact = ZNFK1_RTZN * (ZZ_countfact * (1- OPXAZ_RTZN) * GSLEEPPDX_counterfact * 28.61 + ZZ_countfact * OPXAZ_RTZN * GSLEEPPDX_counterfact* 26.39)
replace ZZaddition_countfact = round(ZZaddition_countfact, 0.01)
replace ZZaddition_countfact = 0 if ZZaddition_countfact < 0

* 4. Add up both components for entire pension (use RTMOAGGS from before, only income from supplementary credits changes)
gen RTBT_sim_counterfact = RTMOAGGS + ZZaddition_countfact

* 5. Account for teilrente
replace RTBT_sim_counterfact = RTBT_sim_counterfact* (TLRTBT_RTZN/100) if TLRT_RTZN == 8
replace RTBT_sim_counterfact = RTBT_sim_counterfact*0.25 if TLRT_RTZN == 6
replace RTBT_sim_counterfact = RTBT_sim_counterfact*0.75 if TLRT_RTZN == 7
replace RTBT_sim_counterfact = RTBT_sim_counterfact*0.5 if TLRT_RTZN == 2

* 6. Account for partial EM
replace RTBT_sim_counterfact = RTBT_sim_counterfact*0.5 if EM_partial == 1


* 7. Correct for MP by adding additional pension credits for children born before 1992
replace RTBT_sim_counterfact = RTBT_sim_counterfact + ZLKI12_RTZN*26.39 if retirement_date_RTZN < ym(2014,07) & OPXAZ_RTZN < 1
replace RTBT_sim_counterfact = RTBT_sim_counterfact + ZLKI12_RTZN*28.61 if retirement_date_RTZN < ym(2014,07) & OPXAZ_RTZN >= 1


label var RTBT_sim_counterfact "Simulated counterfactual (=no reform) pension in Euros for 2014 RW"

* ------------------------------------------------------------------------------
* Some other pension spell variables
gen sumEGPT = SUEPGS_RTZN
label var sumEGPT "Sum pension credits"

gen avgEGPT = DUEPGS_GRP_RTZN
label var avgEGPT "Avg. pension credits"


replace VGEGPTEM_RTZN = 0 if VGEGPTEM_RTZN==.
* Save main RTZN dataset
compress
save $PROCESS_TEMP\rtzn_processed.dta, replace


* Save smaller sample w/ only selection of variables
*keep FDZ_ID retirement_date_RTZN RTBT_2014 AE_RTZN EM_type GBJAVS_RTZN GBMOVS_RTZN diag_D_* acceptance_date_RTZN application_date_RTZN eligible_date_RTZN vertragsrente_RTZN FRG_times_RTZN german_citizen_RTZN dist_app_ent dist_acc_ent
*save $PROCESS_TEMP\rtzn_processed_small.dta, replace



********************************************************************************
* 7. Save Sample IDs for use with other datasets 
********************************************************************************
use $PROCESS_TEMP\rtzn_processed.dta, clear


gen year = year(dofm(retirement_date_RTZN))

keep FDZ_ID

// save the identifier dataset seperately
compress
save $PROCESS_TEMP\rtzn_ids.dta, replace
