********************************************************************************
* Auxiliary file to define global variables
********************************************************************************
set scheme white_ptol

* Covariates
global X AE_exact_RTZN  ///
			teilhabe_prev5y reha_prev5y ///
			diag_1 diag_2 diag_3 diag_4 diag_5 diag_6 ///
			occ_service occ_manufact occ_technic occ_other /// 
			female_RTZN  ///
			AZ_FULL_CONTRIB AZ_REDUC_CONTRIB ///
		    no_check_LM UDAQ_RTZN ///
			RTBT_2014 RTBT_sim RTBT_sim_counterfact 
		
* Selected controls
global controls AE_exact_RTZN diag_2 diag_3 diag_4 diag_5 diag_6 UDAQ_RTZN occ_service occ_manufact occ_technic
		
global Y_status status_pension_post1 status_pension_post2 status_pension_post3 ///
status_pension_post4 status_pension_post5 

global Y_mortality dead_post_1 dead_post_2 dead_post_3 dead_post_4 dead_post_5 dead_post_6 

global Y_employment MEMP_rec REGEMP_rec MEMP_avg_rec REGEMP_avg_rec ///
REGEMP_earnings_post1 REGEMP_earnings_post2 REGEMP_earnings_post3 REGEMP_earnings_post4 ///
REGEMP_post1 REGEMP_post2 REGEMP_post3 ///
REGEMP_post4 MEMP_post1 MEMP_post2 MEMP_post3 MEMP_post4 ///
MEMP_earnings_post1 MEMP_earnings_post2 MEMP_earnings_post3 ///
MEMP_earnings_post4

global Y_first_stage RTBT_2014 RTBT_sim RTBT_2014_mp RTBT_sim_counterfact
