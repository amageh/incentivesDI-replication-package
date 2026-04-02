********************************************************************************
* Analyze DI takeup of 2014 Reform
* Purpose: Define programs to run regression analyses on DI takeup data
* Author: Annica Gehlen
********************************************************************************

*********************************************************************************
* Program to load dataset
*********************************************************************************
cap program drop load_data
program define load_data

	* Load data
	use `1', clear
	
	* Select age group
	drop if JA > 2016
	keep if JA - GBJA < `2' 
	keep if JA - GBJA > `3'
	
	gen AGE = JA - GBJA
	
	drop if inlist(bland, 0,99)
	
	* Sample selection
	drop VSKN 
	drop if kanppschaftl == 1
	*drop if german ==0
	replace beruf = 1 if inlist(beruf, 2,3,4,5)
	
	keep if german==1
	
	* keep only women or men
	drop if female == `4'
end



*********************************************************************************
* Program to plot raw means
*********************************************************************************

cap program drop plot_takeup_means
* define program (function) for rdd plots.
program define plot_takeup_means

	* 1. Both genders in one plot
	foreach outcome in START_GDI {
		preserve
			egen mean_all = mean(`outcome')
			egen sd_all =  sd(`outcome')
			
			gen minn = mean_all - 0.01* sd_all
			gen maxx = mean_all + 0.01* sd_all	
			
			collapse (mean) `outcome' minn maxx, by(QUARTER)

			twoway (scatter `outcome' QUARTER, c(1) color(black%60) lpattern(dash) msize(large) msymbol(O)) ///
			(line maxx QUARTER, sort color(white) lpattern(dot))  ///
			(line minn QUARTER, sort color(white) lpattern(dot)), ///
			ylab(, labsize(13pt)) ///
			xlabel(208 "2012" 212 "2013" 216 "2014" 220 "2015" 224 "2016" 228 "2017", labsize(13pt)) ///
			legend(off) ///
			xline(218, lcolor(red) lwidth(medthick) lpattern(dash_dot)) ///
			ytitle("Share of Workers Entering DI", size(15pt)) xtitle("Quarter", size(15pt)) 
			
			graph export "$OUT/01_graph_mean_`outcome'_all_`1'.png", replace
			graph export "$OUT/01_graph_mean_`outcome'_all_`1'.pdf", replace
			graph export "$OUT/01_graph_mean_`outcome'_all_`1'.eps", replace
		restore
	}

	end
	
	
	
******************************************************************************
* Programm to detrend data and run regressions on quarterly takup.
******************************************************************************

cap program drop coefplot_takeup
program define coefplot_takeup
	
	********************************************************************************
	* A. Detrend data
	********************************************************************************

	eststo clear
	gen t = QUARTER - 207
	gen POST = QUARTER > 217

	* a. Detrend genderal DI takeup
	reg START_GDI c.t i.quarter c.AGE i.beruf i.bland i.german if QUARTER <217, vce(robust)
	predict START_GDI_resid, residuals
	sum START_GDI
	gen START_GDI_d =START_GDI_resid + r(mean)
	drop START_GDI_resid

	
	********************************************************************************
	* B. Outcomes for detrended data (regressions)
	********************************************************************************

	* Estimate quarterly takeup.
	reg START_GDI_d ib(216).QUARTER, vce(robust) 
	eststo m_takeup_gdi
	estadd ysumm, replace

	* Plot coefficients in event study style graph.
	foreach m in m_takeup_gdi {
		
		coefplot (`m', c(1) msymbol(o) lcolor(`3') mlcolor(`3') mfcolor(white%0) ///
		ciopts(recast(rarea) color(`3'%20) lcolor(`3') lpattern(dash))), ///
		keep(*.QUARTER) omitted mlwidth(0.3) vertical base  ///
		rename( ///
		208.QUARTER ="12-1" 209.QUARTER ="12-2"  210.QUARTER ="12-3"  211.QUARTER ="12-4" ///
		212.QUARTER ="13-1" 213.QUARTER ="13-2"  214.QUARTER ="13-3"  215.QUARTER ="13-4" ///
		216.QUARTER ="14-1" 217.QUARTER ="14-2"  218.QUARTER ="14-3"  219.QUARTER ="14-4" ///
		220.QUARTER ="15-1" 221.QUARTER ="15-2"  222.QUARTER ="15-3"  223.QUARTER ="15-4" ///
		224.QUARTER ="16-1" 225.QUARTER ="16-2"  226.QUARTER ="16-3"  227.QUARTER ="16-4" ///
		) ///
		xlabel(1 "2012" 5 "2013" 9 "2014" 13 "2015" 17 "2016" 21 "2017", labsize(13pt)) ///
		ylabel(0.0003(0.0001)-0.0003, labsize(13pt)) ///
		xscale(range(0.5 21.5)) ///
		xline(11, lcolor(red) lwidth(medthick) lpattern(dash_dot)) ///
		yline(0, lcolor("black") lpattern("dash") lwidth(medthick)) ///
		ytitle("Coefficient", size(15pt)) xtitle("Quarter", size(15pt)) 
		
		graph export "$OUT/02_graph_estimates_`m'_`2'_`1'.png", replace
		graph export "$OUT/02_graph_estimates_`m'_`2'_`1'.pdf", replace
		graph export "$OUT/02_graph_estimates_`m'_`2'_`1'.eps", replace
	}

	* Store regression results to a tex file.
	esttab m_takeup_gdi ///
		using $OUT\02_aux_reg_quarters_takeup_`2'_`1'.tex, replace ///
		keep(*.QUARTER) label cells(b(star fmt(%9.5f)) se(par)) ///
		obslast se scalars(N) starlevels(* 0.05 ** 0.01 *** 0.001) ///
		stats(ymean N, fmt(5 0) labels( "Dep. mean" ///
		"Observations"))
	
end
	
	

********************************************************************************
* Programm to detrend data and run pooled regressions
********************************************************************************
cap program drop regress_pooled_takeup

program define regress_pooled_takeup
	
	********************************************************************************
	* A. Detrend data
	********************************************************************************
	
	eststo clear
	gen t = QUARTER - 207
	gen POST = QUARTER > 217

	* a. Detrend genderal DI takeup
	reg START_GDI c.t i.quarter c.AGE i.beruf i.bland i.german if QUARTER <217, vce(robust)
	predict START_GDI_resid, residuals
	sum START_GDI
	gen START_GDI_d =START_GDI_resid + r(mean)
	drop START_GDI_resid

	* b. Detrend genderal DI takeup
	reg START_TEMPORARY c.t i.quarter c.AGE i.beruf i.bland i.german if QUARTER <217, vce(robust)
	predict START_TEMPORARY_resid, residuals
	sum START_TEMPORARY
	gen START_TEMP_d =START_TEMPORARY_resid + r(mean)
	drop START_TEMPORARY_resid

	* c. Detrend genderal DI takeup
	reg START_PERMANENT c.t i.quarter c.AGE i.beruf i.bland i.german if QUARTER <217, vce(robust)
	predict START_PERMANENT_resid, residuals
	sum START_PERMANENT
	gen START_PERM_d =START_PERMANENT_resid + r(mean)
	drop START_PERMANENT_resid
	
	*
	
	********************************************************************************
	*  B. Outcomes for detrended data (regressions)
	********************************************************************************

	* RUN REGRESSIONS
	* 1. ALL
	* Pooled estimates.
	reg START_GDI_d i.POST if QUARTER> 211 & QUARTER <224, vce(cluster QUARTER)
	estadd ysumm, replace
	eststo bw18_d_POST
	
	* 2. TEMPORARY 
	reg START_TEMP_d i.POST if QUARTER> 211 & QUARTER <224, vce(cluster QUARTER)
	estadd ysumm, replace
	eststo bw18_d_POST_temp
	
	* 3. PERMANENT
	reg START_PERM_d i.POST if QUARTER> 211 & QUARTER <224, vce(cluster QUARTER)
	estadd ysumm, replace
	eststo bw18_d_POST_perm

	* Store pooled estimates
	esttab bw18_d_POS* ///
		using $OUT\02_reg_pooled_takeup_`2'_`1'.tex, replace ///
		drop(0.POST) label cells(b(star fmt(%9.6f)) se(par)) ///
		obslast se scalars(N) starlevels(* 0.05 ** 0.01 *** 0.001) ///
		stats(ymean N, fmt(5 0) labels( "Dep. mean" ///
		"Observations"))
		
end
