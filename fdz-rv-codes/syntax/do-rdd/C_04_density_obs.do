

********************************************************************************
* Projekt: Incentive Effects of disability benefits
* Author: Annica Gehlen
* Purpose: Density plot & reg for RDD
********************************************************************************


********************************************************************************
* 1. WORKING SAMPLE
********************************************************************************
do $PATH\syntax\do-rdd\_func_plot_RDD.do
do $PATH\syntax\do-rdd\_load_sample_rdd.do
qui keep if abs(bandwidth) <31


preserve
	gen counter = 1
	collapse (sum) counter, by(running)
	replace running = running+0.5
	egen totall=sum(counter)
	gen density = counter/totall
	
	* RUN REGRESSIONS 
	*rdbwselect counter running, p(1)
	rdrobust counter running, p(1)
	est store m1

	*rdbwselect counter running, p(2)
	rdrobust counter running, p(2)
	est store m2

	*rdbwselect counter running, p(3)
	rdrobust counter running, p(3)
	est store m3

	qui: summarize counter if running < 0
	estadd scalar controlmean = r(mean)

	estout m1 m2 m3, replace ///
	cells("b(star fmt(%9.3f))" "se(fmt(%9.3f) par)" "p(fmt(%9.3f) par([ ]))") ///
	stats(kernel p h_l N N_h_l controlmean, fmt(0 0 1 0 0) labels("Kernel" "Order poly" "Bandwidth" "N" "N(bandwidth)" "Control Mean")) ///
	collabels("(1)" "(2)" "(3)")
	
	esttab m1 m2 m3 using $C_OUT_MANIPULATION/appendix_density_tab_rdd.tex, replace ///
	cells("b(star fmt(%9.3f))" "se(fmt(%9.3f) par)" "p(fmt(%9.3f) par([ ]))") ///
	stats(kernel p h_l N N_h_l controlmean, fmt(0 0 1 0 0) labels("Kernel" "Order poly" "Bandwidth" "N" "N(bandwidth)" "Control Mean")) ///
	collabels("(1)" "(2)" "(3)")
restore



preserve
	gen counter=1
	collapse (sum) counter, by(running female)
	egen f_total=sum(counter) if female==1
	egen m_total=sum(counter) if female==0

	gen f_density = counter/f_total if female==1
	gen m_density = counter/m_total if female==0

	twoway ///
	(scatter m_density running,color(navy%50) msize(large) msymbol(t) ) ///
	 (scatter f_density running, mcolor(orange%50) msize(medium) msymbol(O) ), ///
		legend(ring(0) col(2) pos(2) bmargin(small) label(1 "Male") label(2 "Female")) ylab(0.005(0.005)0.03, labsize(11pt)) xlab(-30(6)30, labsize(11pt)) ///
		xline(0, lcolor(red) lwidth(medthick) lpattern(dash_dot)) ///
		xtitle("Entry month - reform date", size(12pt)) ///
			ytitle("Fraction of sample", size(12pt))
	graph export $C_OUT_MANIPULATION/density_plot_rdd_gender.png, replace
	graph export $C_OUT_MANIPULATION/density_plot_rdd_gender.eps, replace
	
* RUN REGRESSIONS 
	*rdbwselect counter running, p(1)
	rdrobust counter running if female==1, p(1)
	est store m1_f
	rdrobust counter running if female==0, p(1)
	est store m1_m


	*rdbwselect counter running, p(2)
	rdrobust counter running if female==1, p(2)
	est store m2_f
	rdrobust counter running if female==0, p(2)
	est store m2_m


	*rdbwselect counter running, p(3)
	rdrobust counter running if female==1, p(3)
	est store m3_f
	rdrobust counter running if female==0, p(3)
	est store m3_m

	qui: summarize counter if running < 0 & female==1
	estadd scalar controlmean_f = r(mean)
	qui: summarize counter if running < 0 & female==0
	estadd scalar controlmean_m = r(mean)

	estout m1_* m2_* m3_*, replace ///
	cells("b(star fmt(%9.3f))" "se(fmt(%9.3f) par)" "p(fmt(%9.3f) par([ ]))") ///
	stats(kernel p h_l N N_h_l controlmean_f controlmean_m, fmt(0 0 1 0 0) labels("Kernel" "Order poly" "Bandwidth" "N" "N(bandwidth)" "Control Mean F " "Control Mean M ")) ///
	collabels("(1)" "(2)" "(3)")
	
	estout m1_* m2_* m3_* using $C_OUT_MANIPULATION/appendix_density_tab_rdd_gender.tex, replace ///
	cells("b(star fmt(%9.3f))" "se(fmt(%9.3f) par)" "p(fmt(%9.3f) par([ ]))") ///
	stats(kernel p h_l N N_h_l controlmean_f controlmean_m, fmt(0 0 1 0 0) labels("Kernel" "Order poly" "Bandwidth" "N" "N(bandwidth)" "Control Mean F " "Control Mean M ")) ///
	collabels("(1)" "(2)" "(3)")
restore


********************************************************************************
* 2. Overall full DI (perm+temp)
********************************************************************************
use $PROCESS_TEMP\rtzn_processed.dta, clear

qui keep if abs(bandwidth) <31

* keep only full em
drop if EM_type!=1
gen running = (retirement_date_RTZN - ym(2014,07)) + 0.5
cap gen counter=1


* Run program for each covariate
preserve
	collapse (sum) counter, by(running)
	egen totall=sum(counter)
	gen density = counter/totall
	* RUN REGRESSIONS 	
	rdbwselect counter running, p(1)
	rdrobust counter running, p(1)
	est store m1

	rdbwselect counter running, p(2)
	rdrobust counter running, p(2)
	est store m2

	rdbwselect counter running, p(3)
	rdrobust counter running, p(3)
	est store m3

	qui: summarize counter if running < 0
	estadd scalar controlmean = r(mean)

	estout m1 m2 m3, replace ///
	cells("b(star fmt(%9.3f))" "se(fmt(%9.3f) par)" "p(fmt(%9.3f) par([ ]))") ///
	stats(kernel p h_l N N_h_l controlmean, fmt(0 0 1 0 0) labels("Kernel" "Order poly" "Bandwidth" "N" "N(bandwidth)" "Control Mean")) ///
	collabels("(1)" "(2)" "(3)")
	
	esttab m1 m2 m3 using $C_OUT_MANIPULATION/appendix_density_tab_rdd_OVERALL.tex, replace ///
	cells("b(star fmt(%9.3f))" "se(fmt(%9.3f) par)" "p(fmt(%9.3f) par([ ]))") ///
	stats(kernel p h_l N N_h_l controlmean, fmt(0 0 1 0 0) labels("Kernel" "Order poly" "Bandwidth" "N" "N(bandwidth)" "Control Mean")) ///
	collabels("(1)" "(2)" "(3)")	
restore


********************************************************************************
* 3. Overall all DI (partial + full)
********************************************************************************

use $PROCESS_TEMP\rtzn_processed.dta, clear

qui keep if abs(bandwidth) <31

* keep only full em
gen running = (retirement_date_RTZN - ym(2014,07)) + 0.5
cap gen counter=1


* Run program for each covariate
preserve
	collapse (sum) counter, by(running)
	egen totall=sum(counter)
	gen density = counter/totall
	* RUN REGRESSIONS 
	
	rdbwselect counter running, p(1)
	rdrobust counter running, p(1)
	est store m1

	rdbwselect counter running, p(2)
	rdrobust counter running, p(2)
	est store m2

	rdbwselect counter running, p(3)
	rdrobust counter running, p(3)
	est store m3

	qui: summarize counter if running < 0
	estadd scalar controlmean = r(mean)

	estout m1 m2 m3, replace ///
	cells("b(star fmt(%9.3f))" "se(fmt(%9.3f) par)" "p(fmt(%9.3f) par([ ]))") ///
	stats(kernel p h_l N N_h_l controlmean, fmt(0 0 1 0 0) labels("Kernel" "Order poly" "Bandwidth" "N" "N(bandwidth)" "Control Mean")) ///
	collabels("(1)" "(2)" "(3)")
	
	esttab m1 m2 m3 using $C_OUT_MANIPULATION/appendix_density_tab_rdd_OVERALL_alldi.tex, replace ///
	cells("b(star fmt(%9.3f))" "se(fmt(%9.3f) par)" "p(fmt(%9.3f) par([ ]))") ///
	stats(kernel p h_l N N_h_l controlmean, fmt(0 0 1 0 0) labels("Kernel" "Order poly" "Bandwidth" "N" "N(bandwidth)" "Control Mean")) ///
	collabels("(1)" "(2)" "(3)")
restore