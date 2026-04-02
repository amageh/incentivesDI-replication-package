********************************************************************************
* Additional robustness check: donut manufacturing
********************************************************************************

do $PATH\syntax\do-rdd\_load_sample_rdd.do

*
rdrobust occ_manufact runn,  p(1)
gen donut = runn != 0.5 & runn != -0.5
rdrobust occ_manufact runn if donut==1,  p(1)

foreach b in 3.6 4.6 5.6 6.6 7.6 8.6 9.6 10.6 11.6 12.6 13.6 14.6 15.6 16.6 17.6 18.6{
	rdrobust occ_manufact runn if donut==1, h(`b') p(1)
	
}