
*******************************************************************************
* Projekt: Disability insurance & labor supply
* Purpose: define function to run RDDs for different outcomes and specifications
* Functionality:
* func_run_RDD outcome poly path
********************************************************************************

cap program drop func_run_RDD_extra

program define func_run_RDD_extra
	
	* Initiality matrix.
	matrix MAT = J(18, 10,.)

	local i = 1
	* Run specification for many bandwidths and save to matrix.
	foreach b in 2.6 3.6 4.6 5.6 6.6 7.6 8.6 9.6 10.6 11.6 12.6 13.6 14.6 15.6 16.6 17.6 18.6 {
		
		rdrobust `1' runn, h(`b') p(`2')
			
		matrix MAT[`i',1] = e(tau_cl)
	
		local pval =  2*normal(-abs(e(tau_cl) / e(se_tau_cl)))
		matrix MAT[`i', 2] = e(se_tau_cl)
		matrix MAT[`i', 3] = `pval'
		qui: summarize `1' if running < 0 & abs(runn) < `b'
		matrix MAT[`i', 4] = r(mean)
		matrix MAT[`i', 5] =  `i'
		matrix MAT[`i', 6] = e(N_h_l) + e(N_h_r)
		matrix MAT[`i', 7] = e(h_l)
		matrix MAT[`i', 8] = e(tau_cl) + 1.96*e(se_tau_cl)
		matrix MAT[`i', 9] = e(tau_cl) - 1.96*e(se_tau_cl)
		matrix MAT[`i', 10] = 1
		
		local i = `i' + 1
	}
	
	* Save info at optimal bandwidth last --------------------------------------
	*rdbwselect `1' runn, p(`2') 
	rdrobust `1' runn, p(`2') 
	
	matrix MAT[18,1] = e(tau_cl)
	local pval =  2*normal(-abs(e(tau_cl) / e(se_tau_cl)))
	matrix MAT[18, 2] = e(se_tau_cl)
	matrix MAT[18, 3] = `pval'

	qui: summarize `1' if running < 0 & abs(runn) < e(h_l)
	matrix MAT[18, 4] = r(mean)
	matrix MAT[18, 5] =  18
	matrix MAT[18, 6] = e(N_h_l) + e(N_h_r)
	matrix MAT[18, 7] = e(h_l)
	matrix MAT[18, 8] = e(tau_cl) + 1.96*e(se_tau_cl)
	matrix MAT[18, 9] = e(tau_cl) - 1.96*e(se_tau_cl)
	matrix MAT[18, 10] = 1
	
	* Print output
	matlist MAT
	
	* Save output
	matsave MAT, replace p(`3') dropall
	use "`3'/MAT.dta", replace
	
	rename c1 coef
	rename c2 se
	rename c3 pvalue
	rename c4 controlmean
	rename c5 row
	rename c6 obs
	rename c7 bw
	rename c8 upperci
	rename c9 lowerci
	rename c10 polynomial
	gen name = "`1'"
	
	save "`3'/MAT_`1'_`4'.dta", replace
	
	end
	
	
	
cap program drop func_plot_bw_sensitivity_extra

* define program (function) for rdd plots.
program define func_plot_bw_sensitivity_extra

	use "`2'MAT_`1'_`3'.dta", replace
	
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
	end
	
	
	
