*********************************************************************************
* Projekt: Incentive Effects of Disability Benefits
* Author: Annica Gehlen
* Purpose: Plot simulated pensions against observed ones.
********************************************************************************

do $PATH\syntax\do-rdd\_load_sample_rdd.do

twoway (hist RTBT_sim, width(10)  percent color(orange%50)) ///
(hist RTBT_2014, width(10)  percent color(ebblue%50)), ///
legend(pos(6) col(2) label(1 "Simulated") label(2 "Observed") size(5)) ///
ylabel(,labsize(5)) xlabel(,labsize(5)) ///
ytitle("Percent", size(4)) xtitle("Benefits", size(4))
graph export $B_OUT/appendix_RTBT_sim_obs_hist.eps, replace
graph export $B_OUT/appendix_RTBT_sim_obs_hist.png, replace


twoway (hist RTBT_sim, width(10)  percent color(orange%50)) ///
(hist RTBT_sim_counterfact, width(10)  percent color(ebblue%50)), ///
legend(pos(6) col(2) label(1 "With reform") label(2 "Without reform") size(5)) ///
ylabel(,labsize(5)) xlabel(,labsize(5)) ///
ytitle("Percent", size(4)) xtitle("Benefits", size(4))
graph export $B_OUT/appendix_RTBT_sim_obs_hist_counterfact.png, replace
graph export $B_OUT/appendix_RTBT_sim_obs_hist_counterfact.eps, replace

