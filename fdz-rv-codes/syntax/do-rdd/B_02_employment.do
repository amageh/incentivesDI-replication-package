
********************************************************************************
* Projekt: Incentive Effects of Disability Benefits
* Author: Annica Gehlen & Sebastian Becker
* Purpose: Descriptives employment : plots and tables
********************************************************************************
*-------------------------------------------------------------------------------
* A. PLOTS
*-------------------------------------------------------------------------------
do $PATH\syntax\do-rdd\_load_sample_panel.do

* restrict to 2014 sample
drop if Y_ALIVE != 1
*drop if retirement_year != 2014
keep if abs(bandwidth) <30
gen byte Y_no_pension = Y_STATUS ==4



preserve
keep if Y_no_pension==1
keep if bandwidth < 0
keep if bandwidth > -7

keep if Y_ALIVE

collapse (mean) Y_UEMP Y_OBENFIT Y_MEMP Y_REGEMP, by(dist_entry)

drop if dist_entry < 1
drop if dist_entry > 5

replace Y_UEMP = Y_UEMP*100
replace Y_OBENFIT = Y_OBENFIT*100
replace Y_REGEMP = Y_REGEMP*100
replace Y_MEMP = Y_MEMP*100

twoway (scatter Y_UEMP dist_entry, c(1) msymbol(o) msize(large) lwidth(0.5) color(orange%90) lpattern(dash_dot)) ///
(scatter Y_OBENFIT dist_entry, c(1) msymbol(d) msize(large) lwidth(0.5) color(green%90) lpattern(dash)) ///
(scatter Y_REGEMP dist_entry, c(1)  msymbol(s) msize(large) lwidth(0.5) color(navy%90) lpattern(shortdash)) ///
(scatter Y_MEMP dist_entry, c(1) msymbol(t) msize(large) lwidth(0.5) color(ebblue%90)), ///
legend(pos(3) col(1) ring(0)  bmargin(small) size(11pt) ///
label(1 "Unemployment") label(2 "Sickness/Other") label(3 "Insured Employment") ///
label(4 "Marginal Employment")) ///
ytitle("Share of DI exits (%)", size(12pt)) ///
xtitle("Years after Benefit Start", size(12pt))  ///
xlab(1(1)5, labsize(12pt)) ///
ylab(0(20)60, labsize(12pt))
graph export $B_OUT/appendix_share_employed_no_benefits.png, replace
graph export $B_OUT/appendix_share_employed_no_benefits.eps, replace

restore


preserve
keep if Y_ALIVE
keep if Y_no_pension==0
keep if bandwidth < 0
keep if bandwidth > -7

collapse (mean) Y_UEMP Y_OBENFIT Y_MEMP Y_REGEMP, by(dist_entry)

drop if dist_entry < 1
drop if dist_entry > 5

replace Y_UEMP = Y_UEMP*100
replace Y_OBENFIT = Y_OBENFIT*100
replace Y_REGEMP = Y_REGEMP*100
replace Y_MEMP = Y_MEMP*100

twoway (scatter Y_UEMP dist_entry, c(1) msymbol(o) msize(large) lwidth(0.5) color(orange%90) lpattern(dash_dot)) ///
(scatter Y_OBENFIT dist_entry, c(1) msymbol(d) msize(large) lwidth(0.5) color(green%90) lpattern(dash)) ///
(scatter Y_REGEMP dist_entry, c(1)  msymbol(s) msize(large) lwidth(0.5) color(navy%90) lpattern(shortdash)) ///
(scatter Y_MEMP dist_entry, c(1) msymbol(t) msize(large) lwidth(0.5) color(ebblue%90)), ///
legend(pos(3) col(1) ring(0)  bmargin(small) size(11pt) ///
label(1 "Unemployment") label(2 "Sickness/Other") label(3 "Insured Employment") ///
label(4 "Marginal Employment")) ///
ytitle("Share of DI Recipients (%)", size(12pt)) ///
xtitle("Years after Benefit Start", size(12pt))  ///
xlab(1(1)5, labsize(12pt)) ///
ylab(0(20)60, labsize(12pt))
graph export $B_OUT/appendix_share_employed_benefits.png, replace
graph export $B_OUT/appendix_share_employed_benefits.eps, replace
restore


preserve
keep if Y_ALIVE
*keep if Y_no_pension==0
keep if bandwidth < 0
keep if bandwidth > -7

collapse (mean) Y_UEMP Y_OBENFIT Y_MEMP Y_REGEMP, by(dist_entry)

drop if dist_entry > 0
drop if dist_entry < -2

replace Y_UEMP = Y_UEMP*100
replace Y_OBENFIT = Y_OBENFIT*100
replace Y_REGEMP = Y_REGEMP*100
replace Y_MEMP = Y_MEMP*100

twoway (scatter Y_UEMP dist_entry, c(1) msymbol(o) msize(large) lwidth(0.5) color(orange%90) lpattern(dash_dot)) ///
(scatter Y_OBENFIT dist_entry, c(1) msymbol(d) msize(large) lwidth(0.5) color(green%90) lpattern(dash)) ///
(scatter Y_REGEMP dist_entry, c(1)  msymbol(s) msize(large) lwidth(0.5) color(navy%90) lpattern(shortdash)) ///
(scatter Y_MEMP dist_entry, c(1) msymbol(t) msize(large) lwidth(0.5) color(ebblue%90)), ///
legend(pos(3) col(1) ring(0)  bmargin(small) size(11pt) ///
label(1 "Unemployment") label(2 "Sickness/Other") label(3 "Insured Employment") ///
label(4 "Marginal Employment")) ///
ytitle("Share of DI Recipients (%)", size(12pt)) ///
xtitle("Years before Benefit Start", size(12pt))  ///
xlab(-2(1)0, labsize(12pt)) ///
ylab(0(20)60, labsize(12pt))
graph export $B_OUT/appendix_share_employed_prebenefits.png, replace
graph export $B_OUT/appendix_share_employed_prebenefits.eps, replace

restore




preserve
keep if Y_ALIVE
*keep if Y_no_pension==0
keep if bandwidth < 0
keep if bandwidth > -7

collapse (mean) Y_UEMP Y_OBENFIT Y_MEMP Y_REGEMP, by(dist_entry)

drop if dist_entry > 5
drop if dist_entry < -2

replace Y_UEMP = Y_UEMP*100
replace Y_OBENFIT = Y_OBENFIT*100
replace Y_REGEMP = Y_REGEMP*100
replace Y_MEMP = Y_MEMP*100

twoway (scatter Y_UEMP dist_entry, c(1) msymbol(o) msize(large) lwidth(0.5) color(orange%90) lpattern(dash_dot)) ///
(scatter Y_OBENFIT dist_entry, c(1) msymbol(d) msize(large) lwidth(0.5) color(green%90) lpattern(dash)) ///
(scatter Y_REGEMP dist_entry, c(1)  msymbol(s) msize(large) lwidth(0.5) color(navy%90) lpattern(shortdash)) ///
(scatter Y_MEMP dist_entry, c(1) msymbol(t) msize(large) lwidth(0.5) color(ebblue%90)), ///
legend(pos(3) col(1) ring(0)  bmargin(small) size(11pt) ///
label(1 "Unemployment") label(2 "Sickness/Other") label(3 "Insured Employment") ///
label(4 "Marginal Employment")) ///
ytitle("Share of DI Recipients (%)", size(12pt)) ///
xtitle("Years from Benefit Start", size(12pt))  ///
xlab(-2(1)5, labsize(12pt)) ///
ylab(0(20)60, labsize(12pt))
graph export $B_OUT/appendix_share_employed_fulltimeline.png, replace
graph export $B_OUT/appendix_share_employed_fulltimeline.eps, replace

restore

************************************************************
* WAGE DISTRIBUTIONS FROM RDD SAMPLE
************************************************************

do $PATH\syntax\do-rdd\_load_sample_rdd.do

* MARGINAL EMPLOYMENT
hist MEMP_earnings_post1 if MEMP_earnings_post1>0 , width(200) percent xline(6300) xline(5400) xtitle("Annual Earnings from Marginal Employment (in Euros)", size(13pt)) ytitle("Percent", size(13pt)) ///
ylab(0(5)20, labsize(14pt)) xlab(0(2000)7000, labsize(14pt))
graph export $B_OUT/appendix_hist_MEMP_earnings_post1.png, replace
graph export $B_OUT/appendix_hist_MEMP_earnings_post1.eps, replace

hist MEMP_earnings_post2 if MEMP_earnings_post2>0 , width(200) percent xline(6300) xline(5400) xtitle("Annual Earnings from Marginal Employment (in Euros)", size(13pt)) ytitle("Percent", size(13pt)) ///
ylab(0(5)20, labsize(14pt)) xlab(0(2000)7000, labsize(14pt))
graph export $B_OUT/appendix_hist_MEMP_earnings_post2.png, replace
graph export $B_OUT/appendix_hist_MEMP_earnings_post2.eps, replace

hist MEMP_earnings_post3 if MEMP_earnings_post3>0 , width(200) percent xline(6300) xline(5400) xtitle("Annual Earnings from Marginal Employment (in Euros)", size(13pt)) ytitle("Percent", size(13pt)) ///
ylab(0(5)20, labsize(14pt)) xlab(0(2000)7000, labsize(14pt))
 graph export $B_OUT/appendix_hist_MEMP_earnings_post3.png, replace
 graph export $B_OUT/appendix_hist_MEMP_earnings_post3.eps, replace

hist MEMP_earnings_post4 if MEMP_earnings_post4>0 , width(200) percent xline(6300) xline(5400)  xtitle("Annual Earnings from Marginal Employment (in Euros)", size(13pt)) ytitle("Percent", size(13pt)) ///
ylab(0(5)20, labsize(11pt)) xlab(0(2000)7000, labsize(11pt))
graph export $B_OUT/appendix_hist_MEMP_earnings_post4.png, replace
graph export $B_OUT/appendix_hist_MEMP_earnings_post4.eps, replace


hist MEMP_avg_rec if MEMP_avg_rec>0 & MEMP_avg_rec<13000, width(200) percent xline(6300) xline(5400) ytitle("Percent", size(13pt)) xtitle("Avg. Annual Earnings from Marginal Employment (in Euros)", size(13pt)) ///
ylab(0(5)20, labsize(14pt)) xlab(0(2000)7000, labsize(14pt))
graph export $B_OUT/appendix_hist_MEMP_avg_rec.png, replace
graph export $B_OUT/appendix_hist_MEMP_avg_rec.eps, replace


*REGULAR EMPLOYMENT
hist REGEMP_earnings_post1 if REGEMP_earnings_post1>0 & Y_STATUS==1, width(1000) percent xline(6300) xtitle("Annual Earnings from Insured Employment (in Euros)", size(13pt)) ytitle("Percent", size(13pt)) ///
ylab(0(5)20, labsize(14pt)) xlab(0(20000)65000, labsize(14pt))
graph export $B_OUT/appendix_hist_REGEMP_earnings_post1.png, replace
graph export $B_OUT/appendix_hist_REGEMP_earnings_post1.eps, replace

hist REGEMP_earnings_post2 if REGEMP_earnings_post2>0 & Y_STATUS==1, width(1000) percent xline(6300) xtitle("Annual Earnings from Insured Employment (in Euros)", size(13pt)) ytitle("Percent", size(13pt)) ///
ylab(0(5)20, labsize(14pt)) xlab(0(20000)65000, labsize(14pt))
graph export $B_OUT/appendix_hist_REGEMP_earnings_post2.png, replace
graph export $B_OUT/appendix_hist_REGEMP_earnings_post2.eps, replace

hist REGEMP_earnings_post3 if REGEMP_earnings_post3>0 & Y_STATUS==1, width(1000) percent xline(6300) xtitle("Annual Earnings from Insured Employment (in Euros)", size(13pt)) ytitle("Percent", size(13pt)) ///
ylab(0(5)20, labsize(14pt)) xlab(0(20000)65000, labsize(14pt))
 graph export $B_OUT/appendix_hist_REGEMP_earnings_post3.png, replace
 graph export $B_OUT/appendix_hist_REGEMP_earnings_post3.eps, replace

hist REGEMP_earnings_post4 if REGEMP_earnings_post4>0 & Y_STATUS==1, width(1000) percent xline(6300)  xtitle("Annual Earnings from Insured Employment (in Euros)", size(13pt)) ytitle("Percent", size(13pt)) ///
ylab(0(5)20, labsize(14pt)) xlab(0(20000)65000, labsize(14pt))
graph export $B_OUT/appendix_hist_REGEMP_earnings_post4.png, replace
graph export $B_OUT/appendix_hist_REGEMP_earnings_post4.eps, replace




