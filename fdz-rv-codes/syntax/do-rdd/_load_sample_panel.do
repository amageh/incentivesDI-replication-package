********************************************************************************
* Auxiliary file to load sample w/ sample selection
********************************************************************************

use $PROCESS_TEMP\working_sample_rtzn_rtwf_akvs.dta, clear

qui keep if abs(bandwidth) <31

qui keep if befristet==1
* drop all pension types that are not a full regular EM pension
qui drop if KNEGPT_RTZN != 0
qui drop if inlist(EM_type, 2, 3, 4)
qui drop if TTSC1_KLDB1988_RTZN == 555

* drop individuals with international pension times
qui drop if vertragsrente_RTZN !=0
qui drop if FRG_times != 0

* drop people w/o german citizenship.
qui drop if german_citizen_RTZN != 1

*drop if birthdate_RTZN == .
qui drop if application_date_RTZN == .
qui drop if acceptance_date_RTZN == .
qui drop if eligible_date_RTZN == .
qui drop if retirement_date_RTZN == .

* drop ppl w/ very long processes in application/notice/ etc. to make sure we only
* look at individuals that receive a pension and know so
qui drop if dist_eli_ent > 730
qui drop if abs(dist_app_ent) > 730
qui drop if abs(dist_acc_ent) > 365

* Drop older recipients that did no (fully) benefit from the reform
qui drop if AE_RTZN > 59

