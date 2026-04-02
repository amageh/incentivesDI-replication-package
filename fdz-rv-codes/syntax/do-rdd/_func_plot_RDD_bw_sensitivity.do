


********************************************************************************
* Projekt: Disability insurance & labor supply
* Purpose: BW sensitivity plot for RDD
* func_plot_bw_sensitivity outcome path
********************************************************************************

cap program drop func_plot_bw_sensitivity

* define program (function) for rdd plots.
program define func_plot_bw_sensitivity

	use "`2'MAT_`1'.dta", replace
	
	sum bw if row==18
	local optimal_bw = r(mean)
	
	drop if row ==18
	* Save Graphs
	gen maxx = upperci + 2*se
	gen minn = lowerci - 2*se
	twoway (line coef bw, color(black)) ///
	(line upperci bw, color(black) lpattern(dash)) /// 
	(line lowerci bw, color(black) lpattern(dash)) ///
	(line maxx bw, color(white%1) lpattern(dot)) ///
	(line minn bw, color(white%1) lpattern(dot)), ///
	yline(0, lpattern(solid)) ylabel(,labsize(11pt)) xlabel(1(3)19,labsize(11pt)) ///
	xline(`optimal_bw', lpattern(dash)) ///
	ytitle("Estimate", size(13pt)) xtitle("Bandwidth", size(13pt)) legend(off)
	graph export "`3'appendix_rdd_bw_`1'.png", replace
	graph export "`3'appendix_rdd_bw_`1'.eps", replace
	end