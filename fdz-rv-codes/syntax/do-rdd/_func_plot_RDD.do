
********************************************************************************
* Projekt: Incentive Effects of Disability Benefits
* Purpose: Function to plot rdd means
********************************************************************************

* drop program if already defined.
cap program drop func_RDD_PLOT

* define program (function) for rdd plots.
program define func_RDD_PLOT
	
	* Compute min/max for axis widths.
	cap drop mean_all sd_all minn maxx
	egen mean_all = mean(`1')
	egen sd_all =  sd(`1')
	
	gen minn = mean_all - 0.5* sd_all
	gen maxx = mean_all + 0.5* sd_all	
	
	* Running means for markers.
	cap drop means
	cap drop means_g
	
	* mean by gender
	bys running female: egen means_g=mean(`1')
	* mean for all
	bys running: egen means=mean(`1')
	
	
	* Create and save plots:
	preserve 
	
	collapse (mean) means means_g maxx minn, by(female running)
	/*
	* 1. Plot line using lpoly & monthly means for all.
	twoway (scatter means running, mcolor(black) msize(medium) msymbol(O) ) ///
	(line maxx running, sort color(white) lpattern(dot))  ///
	(line minn running, sort color(white) lpattern(dot)), ///
	legend(off) ylab(, labsize(14pt)) xlab(-30(6)30, labsize(14pt)) ///
	xline(-0.5, lcolor(red) lwidth(medthick) lpattern(dash_dot)) ///
	ytitle(`2', size(15pt)) xtitle("Entry Month - Reform Date", size(15pt))
	
	* Save figs.
	graph export "`3'/plots/X_`1'.png", replace
	*/
	
	* 2. Plot line using lpoly & monthly means by gender.
	twoway (scatter means_g running if female==0, color(navy%60) msize(large) msymbol(t)) ///
	(scatter means_g running if female==1,  msize(medium) msymbol(O) color(orange%60))  ///
	(line maxx running, sort color(white) lpattern(dot))  ///
	(line minn running, sort color(white) lpattern(dot)), ///
	legend(ring(0) col(2) pos(2) bmargin(small) order(1 "Male" 2 "Female") size(4)) ylab(, labsize(14pt)) xlab(-30(6)30, labsize(14pt)) ///
	xline(-0.5, lcolor(red) lwidth(medthick) lpattern(dash_dot)) ///
	ytitle(`2', size(15pt)) xtitle("Entry Month - Reform Date", size(15pt))
	
	* Save figs.
	graph export "`3'/`1'_by_gender.png", replace
	graph export "`3'/`1'_by_gender.eps", replace
	
	restore
	
	end