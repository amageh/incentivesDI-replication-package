********************************************************************************
* Projekt: Incentive Effects of Disability Benefits
* Author: Annica Gehlen & Sebastian Becker
* Purpose: Prep sample for rdd and create cross sectional dataset
* Produces: working_sample_rdd.dta (main working sample)
*******************************************************************************

use $PROCESS_TEMP\working_sample_rtzn_rtwf_akvs.dta, clear

drop if abs(bandwidth) > 31

********************************************************************************
* 1. Mortality
********************************************************************************

gen alive_post_0 = death_date - start_date_RTZN > 0
gen alive_post_1 = death_date - start_date_RTZN > 12
gen alive_post_2 = death_date - start_date_RTZN > 24
gen alive_post_3 = death_date - start_date_RTZN > 36
gen alive_post_4 = death_date - start_date_RTZN > 48
gen alive_post_5 = death_date - start_date_RTZN > 60
gen alive_post_6 = death_date - start_date_RTZN > 72


forvalues i = 0/6 {
	gen dead_post_`i' = alive_post_`i' != 1
	
}

gen mortality_year1 = dead_post_1
gen byte mortality_year2 = dead_post_2
replace mortality_year2 = . if dead_post_1 == 1
gen byte mortality_year3 = dead_post_3
replace mortality_year3 = . if dead_post_2 == 1 |  dead_post_1 == 1
gen byte mortality_year4 = dead_post_4
replace mortality_year4 = . if  dead_post_3 == 1 |  dead_post_2 == 1 | dead_post_1 == 1
gen byte mortality_year5 = dead_post_5
replace mortality_year5 = . if  dead_post_4 == 1 | dead_post_3 == 1 |  dead_post_2 == 1 | dead_post_1 == 1
gen byte mortality_year6 = dead_post_6
replace mortality_year6 = . if  dead_post_5 == 1 |dead_post_4 == 1 | dead_post_3 == 1 |  dead_post_2 == 1 | dead_post_1 == 1
	
gen survival_uncond_m = .
replace survival_uncond_m = death_date - start_date_RTZN if death_date != .
replace survival_uncond_m = 72 if survival_uncond_m > 72 | survival_uncond_m == .
replace survival_uncond_m = 0 if survival_uncond_m < 0
label var survival_uncond_m "Survival time in months (unconditional, truncated at 72 months)"

gen survival_uncond_age = .
replace survival_uncond_age = (death_date - birthdate)/12
replace survival_uncond_age = 70 if death_date == . 
label var survival_uncond_age "Survival time in age (unconditional, truncated at 70 years)"


gen survival_cond_m = survival_uncond_m
replace survival_cond_m = . if death_date == .
label var survival_cond_m "Survival time in months (conditional on observed death)"


gen survival_cond_age = survival_uncond_age
replace survival_cond_age = . if death_date == .
label var survival_cond_age "Survival time in age (conditional on observed death)"


********************************************************************************
* 2. Employment
********************************************************************************
*2.1. Past employment
gen retirement_year = year(dofm(retirement_date_RTZN))

**** Time variable in panel: start date of benefits (i.e. retirement date or acceptance date,
* whichever one is later)
gen dist_ja_entry = JA - start_year

* pension status
forvalues j = 0/6 {
	egen STATUS_post`j' = sum(Y_STATUS / (dist_ja_entry==`j')), by(fdz_id_num)
	* replace with missing in years that individual is dead
	replace STATUS_post`j' = . if alive_post_`j' == 0
	
	* Create dummis for outcomes
	gen byte status_pension_post`j' = inlist(STATUS_post`j',1,2,3) 
	replace status_pension_post`j' = . if STATUS_post`j'==.
	la var status_pension_post`j' "Receives DI benefits/pension in year `j'"
	
	gen byte status_none_post`j' = inlist(STATUS_post`j',4) 
	replace status_none_post`j' = . if STATUS_post`j'==.
	la var status_none_post`j' "Receives no pension in year `j'"
}
	
	

* define earnings variables conditional on working
gen Y_total_earnings = Y_MEMP_earnings + Y_REGEMP_earnings


*wages_all earnings income (drop outcomes of people who are dead or not receiving benefits)
*  participation
foreach v in MEMP WORK REGEMP UEMP OBENFIT {
	forvalues j = 0/6 {
		egen `v'_post`j' = sum(Y_`v' / (dist_ja_entry==`j')), by(fdz_id_num)
		* replace with missing in years that individual is dead
		replace `v'_post`j' = . if alive_post_`j' == 0
		replace `v'_post`j' = . if STATUS_post`j' == 4
	}
}
* days
foreach v in MEMP REGEMP UEMP OBENFIT {
	forvalues j = 0/6 {
		egen `v'_days_post`j' = sum(Y_`v'_days / (dist_ja_entry==`j')), by(fdz_id_num)
		* replace with missing in years that individual is dead
		replace `v'_days_post`j' = . if alive_post_`j' == 0
		replace `v'_days_post`j' = . if STATUS_post`j' == 4
	}
}

* earnings of recipients (drop non-recipients in addition to dead)
foreach v in  total_earnings MEMP_earnings REGEMP_earnings {
	
	forvalues j = 0/6 {
		egen `v'_post`j' = sum(Y_`v' / (dist_ja_entry==`j')), by(fdz_id_num)
		* replace with missing in years that individual is dead
		replace `v'_post`j' = . if alive_post_`j' == 0
		replace `v'_post`j' = . if STATUS_post`j' == 4
	}
}

* Gen outcomes that doesn't exclude individuals who are not receving benefits anymore.
foreach v in MEMP WORK REGEMP UEMP OBENFIT {
	forvalues j = 3/6 {
		egen `v'_post`j'_all = sum(Y_`v' / (dist_ja_entry==`j')), by(fdz_id_num)
		* replace with missing in years that individual is dead
		replace `v'_post`j'_all = . if alive_post_`j' == 0
	}
}


foreach v in MEMP WORK REGEMP UEMP OBENFIT {
	forvalues j = 3/6 {
		egen `v'_post`j'_leavers = sum(Y_`v' / (dist_ja_entry==`j')), by(fdz_id_num)
		* replace with missing in years that individual is dead
		replace `v'_post`j'_leavers = . if alive_post_`j' == 0
		replace `v'_post`j'_leavers = . if STATUS_post`j' != 4
	}
}


********************************************************************************
* 3. Additional variables
********************************************************************************


* Create variables that cover the entire 5 years after entry
gen byte MEMP_rec = ( MEMP_post1 == 1 | MEMP_post2 == 1 | MEMP_post3 == 1 | MEMP_post4 == 1  )
replace MEMP_rec = . if ( MEMP_post1 == . & MEMP_post2 == . & MEMP_post3 == . & MEMP_post4 == . )

gen byte WORK_rec = ( WORK_post1 == 1 | WORK_post2 == 1 | WORK_post3 == 1 | WORK_post4 == 1)
replace WORK_rec = . if ( WORK_post1 == . & WORK_post2 == . & WORK_post3 == . &  WORK_post4 == . )

gen byte REGEMP_rec = ( REGEMP_post1 == 1 | REGEMP_post2 == 1 | REGEMP_post3 == 1 | REGEMP_post4 == 1 )
replace REGEMP_rec = . if ( REGEMP_post1 == . & REGEMP_post2 == . & REGEMP_post3 == . & REGEMP_post4 == . )



* AVERAGE WAGES 5 YEARS POST ACCEPTANCE
gen aux_counter_active =0
forvalues i=1/4 {
	replace aux_counter_active = aux_counter_active + 1 if total_earnings_post`i' != .
}

gen total_earnings_avg_rec = 0 
replace total_earnings_avg_rec = total_earnings_avg_rec + total_earnings_post1 if total_earnings_post1 !=.
replace total_earnings_avg_rec = total_earnings_avg_rec + total_earnings_post2 if total_earnings_post2 !=.
replace total_earnings_avg_rec = total_earnings_avg_rec + total_earnings_post3 if total_earnings_post3 !=.
replace total_earnings_avg_rec = total_earnings_avg_rec + total_earnings_post4 if total_earnings_post4 !=.

replace total_earnings_avg_rec = total_earnings_avg_rec/aux_counter_active
drop aux_counter_active

* AVERAGE MINIJOB WAGES 5 YEARS POST ACCEPTANCE
gen aux_counter_active =0
forvalues i=1/4 {
	replace aux_counter_active = aux_counter_active + 1 if MEMP_earnings_post`i' != .
}
gen MEMP_avg_rec = 0 
replace MEMP_avg_rec = MEMP_avg_rec + MEMP_earnings_post1 if MEMP_earnings_post1 !=.
replace MEMP_avg_rec = MEMP_avg_rec + MEMP_earnings_post2 if MEMP_earnings_post2 !=.
replace MEMP_avg_rec = MEMP_avg_rec + MEMP_earnings_post3 if MEMP_earnings_post3 !=.
replace MEMP_avg_rec = MEMP_avg_rec + MEMP_earnings_post4 if MEMP_earnings_post4 !=.

replace MEMP_avg_rec = MEMP_avg_rec/aux_counter_active
drop aux_counter_active


* AVERAGE INSURED JOB WAGES 5 YEARS POST ACCEPTANCE
gen aux_counter_active =0
forvalues i=1/4 {
	replace aux_counter_active = aux_counter_active + 1 if REGEMP_earnings_post`i' != .
}
gen REGEMP_avg_rec = 0 
replace REGEMP_avg_rec = REGEMP_avg_rec + REGEMP_earnings_post1 if REGEMP_earnings_post1 !=.
replace REGEMP_avg_rec = REGEMP_avg_rec + REGEMP_earnings_post2 if REGEMP_earnings_post2 !=.
replace REGEMP_avg_rec = REGEMP_avg_rec + REGEMP_earnings_post3 if REGEMP_earnings_post3 !=.
replace REGEMP_avg_rec = REGEMP_avg_rec + REGEMP_earnings_post4 if REGEMP_earnings_post4 !=.

replace REGEMP_avg_rec = REGEMP_avg_rec/aux_counter_active
drop aux_counter_active



* Create quartile variables based on simulated RTBT without reform effect
xtile quint = RTBT_sim_counterfact, nq(5)
gen byte quint1 = quint == 1
gen byte quint2 = quint == 2
gen byte quint3 = quint == 3
gen byte quint4 = quint == 4
gen byte quint5 = quint == 5


* Some additional variables (move to data cleaning )
qui gen all = 1
qui gen byte male = female !=1
qui gen byte no_kids92_RTZN = has_kids92_RTZN !=1

gen byte occ_service = kldb1988_bereich == 5
gen byte occ_manufact = kldb1988_bereich == 3
gen byte occ_technic = kldb1988_bereich == 4
gen byte occ_other = inlist(kldb1988_bereich, -1, 1, 2, 6)


*******************************************************************************
 * Keep only cross section of people.
keep if dist_ja_entry == 0
gen running = dist_entry_reform2014
qui gen runn = running + 0.5
keep if abs(bandwidth) <31

* drop small # of individuals (~ 30 people) that seem to benefit from reform 
* even though entry  is before reform
gen birthdate = retirement_date_RTZN - AE_exact_RTZN*12
gen age_au = eligible_date_RTZN - birthdate
gen age_with_zz = age_au + ZZ_1_RTZN
replace age_with_zz = age_with_zz/12
replace age_with_zz = floor(age_with_zz)

* drop small number of people with inconsistencies in supplementary time
drop if VGEGPTEM_RTZN > 0 & VGEGPTEM_RTZN != . & retirement_date_RTZN < ym(2014,07)
drop if age_with_zz > 61 & retirement_date_RTZN < ym(2014,07) & age_au <60


save $PROCESS_TEMP\working_sample_rdd.dta, replace