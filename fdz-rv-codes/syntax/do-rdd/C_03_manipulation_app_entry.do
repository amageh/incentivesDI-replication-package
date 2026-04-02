
********************************************************************************
* Projekt: Incentive Effects of Disability Benefits
* Author: Annica Gehlen
* Purpose: Examine entry dates & application times in dependence of application date
********************************************************************************
do $PATH\syntax\do-rdd\_load_sample_rdd.do

local labsize = 13
local titlesize = 14
********************************************************************************
* Plot distance between application and start date as histograms
********************************************************************************
* by treatment status
twoway (hist dist_app_ent if abs(dist_app_ent) < 365 &  treat==0 & abs(bandwidth) <7, start(-360) percent width(7) color(ebblue%60)) ///
(hist dist_app_ent if abs(dist_app_ent) < 365 &  treat==1 & abs(bandwidth) <7, start(-360) percent width(7) color(orange%60)), ///
legend(pos(6) col(2) label(1 "Pre-Reform Recipients" ) label(2 "Post-Reform Recipients") size(`labsize'pt)) ///
xlab(-360(60)360, labsize(`labsize'pt)) /// 
ylab(, labsize(`labsize'pt)) ///
xtitle(, size(`titlesize'pt)) ytitle(, size(`titlesize'pt))
graph export $C_OUT_MANIPULATION/appendix_dist_app_ent_treat.png, replace
graph export $C_OUT_MANIPULATION/appendix_dist_app_ent_treat.eps, replace


********************************************************************************
* RDD retirement date on application
********************************************************************************
* Define application as running variable.
gen running_application = application_date_mdy_RTZN- mdy(07,01,2014) 
gen running_app_month = application_date_RTZN - ym(2014,07)

gen app_week = wofd(application_date_mdy_RTZN)
format app_week %tw
gen running_app_week = app_week -  wofd(mdy(07,01,2014) )

*-------------------------------------------------------------------------------
* RDD plots
*-------------------------------------------------------------------------------
cap gen all = 1
cap gen byte unbefristet = befristet != 1

* Write program  to plot rdd
cap program drop func_RDD_PLOT_app

* define program (function) for rdd plots.
program define func_RDD_PLOT_app
	
	preserve
	* Compute min/max for axis widths.
	*keep if abs(dist_app_ent) < 365
	drop if `2' > `4' -1
	drop if `2' < -`4'
	keep if `6' == 1

	rdbwselect `1' `2', p(1)  
	rdrobust `1' `2', p(1) vce(hc3)
	
	egen mean_all = mean(`1')
	egen sd_all =  sd(`1')
	
	gen minn = mean_all - 0.5* sd_all
	gen maxx = mean_all + 0.5* sd_all
		 
	cap drop means
	bys `2': egen means =mean(`1')
	local steps = `4'/30
	
	if `8' == 1 {
		twoway ///
		(scatter means `2', color(black%20) msymbol(O)) ///
		(line maxx running, sort color(white) lpattern(dot))  ///
		(line minn running, sort color(white) lpattern(dot)), ///
		legend(off) xlab(-`4'(4)`4', labsize(13pt)) ylab(`7', labsize(13pt)) ///
		xline(0, lcolor(red) lwidth(medthick) lpattern(dash_dot)) ///
		ylabel(645 "2013m10" 650 "2014m3" 655 "2014m8"  660 "2015m1" 665 "2015m6" 670 "2015m11") ///
		ytitle(`3', size(14pt)) xtitle("Application Date - Reform Date (in Weeks)", size(14pt))
		graph export $C_OUT_MANIPULATION/appendix_rdd_`2'_`1'_`6'.png, replace
		graph export $C_OUT_MANIPULATION/appendix_rdd_`2'_`1'_`6'.eps, replace
	}
	
	else {
		twoway ///
		(scatter means `2', color(black%20) msymbol(O)) ///
		(line maxx running, sort color(white) lpattern(dot))  ///
		(line minn running, sort color(white) lpattern(dot)), ///
		legend(off) xlab(-`4'(4)`4', labsize(13pt)) ylab(`7', labsize(13pt)) ///
		xline(0, lcolor(red) lwidth(medthick) lpattern(dash_dot)) ///
		ytitle(`3', size(14pt)) xtitle("Application Date - Reform Date (in weeks)", size(14pt))
		graph export $C_OUT_MANIPULATION/appendix_rdd_`2'_`1'_`6'.png, replace
		graph export $C_OUT_MANIPULATION/appendix_rdd_`2'_`1'_`6'.eps, replace
	}
	
	restore
	end
	
*gen dist_app_ent_absolute = abs(dist_app_ent)

func_RDD_PLOT_app dist_app_ent running_app_week `""Average Days Between" "Application & Entry Date""' 26 7 all 0(30)210 0

*-------------------------------------------------------------------------------
* Regression tables
*-------------------------------------------------------------------------------

cap program drop func_rdd_reg_table
program func_rdd_reg_table 
preserve
	keep if `1' == 1
	*keep if abs(dist_app_ent) < 365
	drop if abs(running_app_week) > 26
	foreach var in retirement_date_RTZN dist_app_ent {
		rdbwselect `var' running_app_week, p(`3')
		rdrobust `var' running_app_week, p(`3')
		eststo m_`var'
		
		estadd scalar bw_l =e(h_l)
		estadd scalar N_original = e(N_l) + e(N_r)
		estadd scalar N_effective = e(N_h_l) + e(N_h_r)
		
		qui sum `var' if running_app_week <0
		estadd scalar mean_control =r(mean)
		}
		esttab m_* using $C_OUT_MANIPULATION/appendix_rdd_tables_p`3'.tex, append ///
		obslast se scalars(mean_control bw_l N_original N_effective) starlevels(* 0.05 ** 0.01 *** 0.001) title(`2')
restore
end

eststo clear
func_rdd_reg_table all "all" 1
func_rdd_reg_table female "female" 1
func_rdd_reg_table male  "male" 1

