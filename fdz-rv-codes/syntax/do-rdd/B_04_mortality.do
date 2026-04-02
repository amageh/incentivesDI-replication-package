********************************************************************************
* Projekt:Incentive Effects of disability benefits
* Author: Annica Gehlen & Sebastian Becker
* Purpose: Descriptive information on mortality
********************************************************************************


do $PATH\syntax\do-rdd\_load_sample_rdd.do
xtile RTBT_pct = RTBT_2014, nquantiles(10)
drop dist_entry


keep if abs(bandwidth) < 13

gen start_month = ym(2014,1)
gen end_month = ym(2020,12)

expand end_month - start_month + 1
by fdz_id_num, sort: gen date = start_month + _n -1
format date %tm
gen year = year(dofm(date))

gen dist_entry = date - start_date_RTZN
gen counter = 1

* Plot data
gen dead=0
replace dead = 1 if death_date <= date

* Reduce amount of data.
replace dist_entry = dist_entry +1
*replace dist_entry = 0 if dist_entry ==1
replace dist_entry = dist_entry/ 12 if dist_entry > 0
drop if dist_entry > 6

gen dead_female =.
replace dead_female = dead if female ==1
gen dead_male =.
replace dead_male = dead if male ==1



preserve
gen age_all =1 

collapse (mean) dead*, by(dist_entry)

drop if dist_entry < 0
drop if dist_entry > 6

replace dead = dead*100
replace dead_female = dead_female*100
replace dead_male= dead_male*100

twoway (line dead dist_entry, color(black) lwidth(0.5)) ///
(line dead_female dist_entry, color(black) lpattern(shortdash) lwidth(0.5)) ///
(line dead_male dist_entry, color(black) lpattern(dash) lwidth(0.5)), ///
legend(pos(6) col(4) label(1 "All") label(2 "Female") label(3 "Male")size(11pt)) ///
ylab(, labsize(13pt)) xlab(0(1)6, labsize(13pt)) ///
ytitle("Share Deceased (%)", size(13pt)) xtitle("Years from Start Date of Benefits", size(13pt))
graph export $B_OUT\appendix_mortality_by_gender.png, replace
graph export $B_OUT\appendix_mortality_by_gender.eps, replace

restore

