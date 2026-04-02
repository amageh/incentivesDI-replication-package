********************************************************************************
* DO FILE TO GET AKVS DATASET FROM RAW DATA FILES W/ REDUCED SIZE
********************************************************************************
clear all
set max_memory .
set matsize 5000

* Path to master data files
global DATA =  "XXX\AKVS" // Hier muss der Pfad zu den Rohdateien der AKVS delegt werden

* Data paths for user
global DATA_OUT = "XXX\Data\AKVS"

********************************************************************************
* 1. Define label for variable covering insurance status
********************************************************************************
label define VSTATUS ///
	-2 "-2 Im Vorjahr versichert" ///
	-1 "-1 Verstorben" ///
	0 "0 Kindererziehungszeit o. Wehrdienst o. Pflegeperson" ///
	1 "1 Anrechnungszeit (§§ 58, 252, 252a SGB VI ohne § 58 Abs. 1 Nr. 6 SGB VI) (VSAZJA)" ///
	2 "2 Anrechnungszeit wegen Arbeitslosengeld II-Bezug (§ 58 Abs. 1 Nr. 6 SGB VI) (VSAZJA)" ///
	3 "3 Freiwillig Versicherter (§ 7 SGB VI) (VSFWJA)" ///
	4 "4 Pflichtversicherter Selbständiger (VSSSJA)" ///
	5 "5 Sonstiger Leistungsbezug (VSLEJA)" ///
	6 "6 Geringfügig Beschäftigt (VSGIPHJA) (VSGIJA)" ///
	7 "7 Leistungsempfänger SGB III (VSALJA)" ///
	8 "8 Versicherter mit Entgelt in der Gleitzone (VSBHGZJA)" ///
	9 "9 Vorruhestandsgeldbezieher (VSVORUJA)" ///
	10 "10 Altersteilzeit (VSAETLJA)" ///
	11 "11 Berufsausbildung (VSBAJA)" ///
	12 "12 Versicherungspflichtig Beschäftigt (VSBHJA)" ///
	13 "13 Rentner (VSRTJA)"

* Program to generate variable for insurance status
*-----------
* Note: For AKVS 2021 this still leaves around 4% w/o status (this is mainly people
* w/o a status on Dec 31st but who were insured in some way during the year or
* previous year)
*-----------
cap program drop code_insurance_status
program define code_insurance_status 

gen VSTATUS = .
	replace VSTATUS = -2 if inlist(VSBHVOJA,1,2,3) | inlist(VSRTVOJA,1,2,3,4,5,6,7) ///
	| inlist(VSAZVOJA,1,2) | inlist(VSGIPHVOJA, 1, 2) | inlist(VSGIVOJA, 1, 2) ///
	| inlist(VSSSVOJA,2,3,4,5) | inlist(VSKIEZVOJA,1) | inlist(VSDNVOJA,1) | inlist(VSPEVOJA,1) ///
	| inlist(VSFWVOJA,1) | inlist(VSALVOJA,1,2) | inlist(VSBHGZVOJA,1) | inlist(VSBAVOJA,1,2) ///
	| inlist(VSAETLVOJA,1,2,3) | inlist(VSVORUVOJA,1,2,3) | inlist(VSALVOJA,1,2) ///
	| inlist(VSLEVOJA,1,2)
	replace VSTATUS = -2 if ((BHTGVOJA1 > 0 & BHTGVOJA1!=.) ///
	| (BHTGVOJA2 > 0 & BHTGVOJA2!=.)) & VSTATUS ==.
	replace VSTATUS = -1 if TD !=0 
	replace VSTATUS = 0 if inlist(VSKIEZJA,1) | inlist(VSDNJA,1) | inlist(VSPEJA,1)
	replace VSTATUS = 0 if (PETGJA > 0 & PETGJA!=.) & VSTATUS ==.
	replace VSTATUS = 1 if VSAZJA==1
	replace VSTATUS = 2 if VSAZJA==2
	replace VSTATUS = 2 if (ALHITGJA1 > 0 & ALHITGJA1!=.) & VSTATUS ==.
	replace VSTATUS = 3 if VSFWJA==1
	replace VSTATUS = 4 if inlist(VSSSJA,2,3,4,5)
	replace VSTATUS = 5 if inlist(VSLEJA,1,2)
	replace VSTATUS = 6 if inlist(VSGIPHJA, 1, 2) | inlist(VSGIJA, 1, 2)
	replace VSTATUS = 7 if inlist(VSALJA,1,2)
	replace VSTATUS = 7 if (AFGTGJA1 > 0 & AFGTGJA1!=.) & VSTATUS ==.
	replace VSTATUS = 8 if inlist(VSBHGZJA,1)
	replace VSTATUS = 8 if (BHGZTGJA > 0 & BHGZTGJA!=.) & VSTATUS ==.
	replace VSTATUS = 9 if inlist(VSVORUJA,1,2,3)
	replace VSTATUS = 10 if inlist(VSAETLJA,1,2,3)
	replace VSTATUS = 11 if inlist(VSBAJA,1,2)
	replace VSTATUS = 11 if (BATGJA > 0 & BATGJA!=.) & VSTATUS ==.
	replace VSTATUS = 12 if inlist(VSBHJA,1,2,3)
	replace VSTATUS = 12 if ((BHTGJA1 > 0 & BHTGJA1!=.) | (BHTGJA2 > 0 & BHTGJA2!=.)) & VSTATUS ==.
	replace VSTATUS = 13 if inlist(VSRTJA,1,2,3,4,5,6,7)
	
	
	label values VSTATUS VSTATUS
	label variable VSTATUS "Verischerungsstatus im Berichtsjahr"
	
end 


********************************************************************************	
* 2. Call datasets and select variables ********************************************************************************

* 2.2. Years w/o RIEMR variables
foreach i in 2012 2013 2014 2015 2016 2017 {
	 
	use "$DATA\OSV.AKVS.`i'.dta", clear
	
	* get insurance status 
	code_insurance_status
	
	* keep relevant variable selection
	keep FDZ_ID JA GBJA GBMO GEVS SAVS WHOT RTBE TD VSKN RTJA ///
	 VSRTJA BHTGJA1 BHEGJA1 BHTGJA2 BHEGJA2 TGSUJA TGSUVOJA TTSC* ///
	 BY1 VSTATUS VSSSJA ///
	 BHTGJA1 BHTGJA1 BHTGJA2 BHTGJA2 VSLEJA VSGIPHJA VSGIJA VSBHGZJA VSALJA ///
	 VSAZJA VSAZJA
	
	*drop duplicates
	sort FDZ_ID
	qui by FDZ_ID: gen dup = cond(_N==1,0,_n)
	drop if dup > 1
	
	* drop some voja occupations
	drop TTSCVOJA TTSCJA TTSCVOJA2 TTSCVOJA3 TTSCVOJA4 TTSCVOJA5 dup
	
	compress
	* Save full akvs with all workers and subset of variables
	save using "$DATA_OUT\AKVS.`i'.subset.dta"
}
