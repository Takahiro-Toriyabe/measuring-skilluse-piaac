// Take log
local dofile_name "clean_piaac"
TakeLog `dofile_name', path("${path_log}")

// Import data
local cnt = 1
foreach cntry in aut bel can cze dnk est fin fra irl ita jpn kor nld nor pol rus ///
		svk esp swe gbr usa cyp chl grc isr ltu nzl sgp svn tur {
	if (`cnt'==9) {
		local `cnt++'
	}
	
	import delimited "${path_data}/Prg`cntry'p1.csv", clear

	replace isic1c = "1" if (isic1c=="A")
	replace isic1c = "2" if (isic1c=="B")
	replace isic1c = "3" if (isic1c=="C")
	replace isic1c = "4" if (isic1c=="D")
	replace isic1c = "5" if (isic1c=="E")
	replace isic1c = "6" if (isic1c=="F")
	replace isic1c = "7" if (isic1c=="G")
	replace isic1c = "8" if (isic1c=="H")
	replace isic1c = "9" if (isic1c=="I")
	replace isic1c = "10" if (isic1c=="J")
	replace isic1c = "11" if (isic1c=="K")
	replace isic1c = "12" if (isic1c=="L")
	replace isic1c = "13" if (isic1c=="M")
	replace isic1c = "14" if (isic1c=="N")
	replace isic1c = "15" if (isic1c=="O")
	replace isic1c = "16" if (isic1c=="P")
	replace isic1c = "17" if (isic1c=="Q")
	replace isic1c = "18" if (isic1c=="R")
	replace isic1c = "19" if (isic1c=="S")
	replace isic1c = "20" if (isic1c=="T")
	replace isic1c = "21" if (isic1c=="U")

	for varlist _all: destring X, force replace

	replace isic1c = . if (inlist(isic1c, 9995, 9996, 9997, 9998, 9999)==1)
	replace isco1c = . if (inlist(isco1c, 9995, 9996, 9997, 9998, 9999)==1)

	gen country = `cnt'
		
	save "${path_data}/data`cnt'.dta", replace
	
	local `cnt++'
}

clear
forvalues j = 1(1)31 {
	append using "${path_data}/data`j'.dta"
}

gen id = _n

replace isic1c = . if (inlist(isic1c, 9995, 9996, 9997, 9998, 9999)==1)
replace isco1c = . if (inlist(isco1c, 9995, 9996, 9997, 9998, 9999)==1)

/*  Country ID
	
	1  -> Austria
	2  -> Belgium
	3  -> Canada
	4  -> Czech   
	5  -> Denmark
	6  -> Estonia
	7  -> Finland
	8  -> France
	9  -> Germany
	10 -> Ireland
	11 -> Italy
	12 -> Japan
	13 -> Korea
	14 -> Netherlands
	15 -> Norway
	16 -> Poland
	17 -> Russian Federation
	18 -> Slovak Republic
	19 -> Spain
	20 -> Sweden
	21 -> United Kingdom
	22 -> United States
	23 -> Cyprus
	24 -> Chile
	25 -> Greece
	26 -> Israel
	27 -> Lithuania
	28 -> New Zealand
	29 -> Singapore
	30 -> Slovenia
	31 -> Turkey
*/


// Core test results
gen core1_fail = 0
replace core1_fail = 1 if (corestage1_pass==29)
// core1_fail = 1 if one failed to pass the first core stage

gen core2_fail = 0
replace core2_fail = 1 if (corestage2_pass==29)
// core2_fail = 1 if one failed to pass the second core stage

gen papercore_fail = 0
replace papercore_fail = 1 if (paper==3)
// paper = 3 -> one fails paper core 

rename h_q04a cmp_exp
replace cmp_exp = 2 - cmp_exp
replace cmp_exp = 1 if (g_q04==1)
// cmp_exp = 1 if the respondent has experience to use a computer


// Variables indicating whether one gave correct answer or not
rename d311701s cl1
rename c308120s cl2
rename e321001s cl3
rename e321002s cl4
rename c305215s cl5
rename c305218s cl6
rename c308117s cl7
rename c308119s cl8
rename c308121s cl9
rename c308118s cl10
rename d304710s cl11
rename d304711s cl12
rename d315512s cl13
rename e327001s cl14
rename e327002s cl15
rename e327003s cl16
rename e327004s cl17
rename c308116s cl18
rename c309320s cl19
rename c309321s cl20
rename d307401s cl21
rename d307402s cl22
rename c313412s cl23
rename c313414s cl24
rename c309319s cl25
rename c309322s cl26
rename e322001s cl27
rename e322002s cl28
rename e322005s cl29
rename e320001s cl30
rename e320003s cl31
rename e320004s cl32
rename c310406s cl33
rename c310407s cl34
rename e322003s cl35
rename e323003s cl36
rename e323004s cl37
rename e322004s cl38
rename d306110s cl39
rename d306111s cl40
rename c313410s cl41
rename c313411s cl42
rename c313413s cl43
rename e318001s cl44
rename e318003s cl45
rename e323002s cl46
rename e323005s cl47
rename e329002s cl48
rename e329003s cl49
rename c615602s cn1
rename c615603s cn2
rename c624619s cn3
rename c624620s cn4
rename c604505s cn5
rename c605506s cn6
rename c605507s cn7
rename c605508s cn8
rename e650001s cn9
rename c623616s cn10
rename c623617s cn11
rename c619609s cn12
rename e657001s cn13
rename e646002s cn14
rename c620610s cn15
rename c620612s cn16
rename e632001s cn17
rename e632002s cn18
rename c607510s cn19
rename c614601s cn20
rename c618607s cn21
rename c618608s cn22
rename e635001s cn23
rename c613520s cn24
rename c608513s cn25
rename e655001s cn26
rename c602501s cn27
rename c602502s cn28
rename c602503s cn29
rename c611516s cn30
rename c611517s cn31
rename c606509s cn32
rename e665001s cn33
rename e665002s cn34
rename c622615s cn35
rename e636001s cn36
rename c617605s cn37
rename c617606s cn38
rename e641001s cn39
rename e661001s cn40
rename e661002s cn41
rename e660003s cn42
rename e660004s cn43
rename e634001s cn44
rename e634002s cn45
rename e651002s cn46
rename e664001s cn47
rename e644002s cn48
rename c612518s cn49
rename u01a000s ps1
rename u01b000s ps2
rename u02x000s ps3
rename u03a000s ps4
rename u04a000s ps5
rename u06a000s ps6
rename u06b000s ps7
rename u07x000s ps8
rename u11b000s ps9
rename u16x000s ps10
rename u19a000s ps11
rename u19b000s ps12
rename u21x000s ps13
rename u23x000s ps14
rename n306110s pl1
rename n306111s pl2
rename m313410s pl3
rename m313411s pl4
rename m313412s pl5
rename m313413s pl6
rename m313414s pl7
rename p324002s pl8
rename p324003s pl9
rename m305215s pl10
rename m305218s pl11
rename p317001s pl12
rename p317002s pl13
rename p317003s pl14
rename m310406s pl15
rename m310407s pl16
rename m309319s pl17
rename m309320s pl18
rename m309321s pl19
rename m309322s pl20
rename m615602s pn1
rename m615603s pn2
rename p640001s pn3
rename m620610s pn4
rename m620612s pn5
rename p666001s pn6
rename m623616s pn7
rename m623617s pn8
rename m623618s pn9
rename m624619s pn10
rename m624620s pn11
rename m618607s pn12
rename m618608s pn13
rename m604505s pn14
rename m610515s pn15
rename p664001s pn16
rename m602501s pn17
rename m602502s pn18
rename m602503s pn19
rename p655001s pn20

/*
	cl -> computer literacy
	cn -> computer numeracy
	ps -> problem solution
	pl -> paper literacy
	pn -> paper numeracy
*/

for num 1/49: replace clX = 0 if (clX==7)
	// = 1 if correct, = 0 if incorrect
for num 1/49: replace cnX = 0 if (cnX==7)
	// = 1 if correct, = 0 if incorrect
for num 1/20: replace plX = 0 if (plX==7)
	// = 1 if correct, = 0 if incorrect
for num 1/20: replace pnX = 0 if (pnX==7)
	// = 1 if correct, = 0 if incorrect

replace ps2 = 0 if (ps2==7)
replace ps4 = 0 if (ps4==7)
replace ps6 = 0 if (ps6==7)
replace ps7 = 0 if (ps7==7)
replace ps8 = 0 if (ps8==7)
replace ps10 = 0 if (ps10==7)
replace ps11 = 0 if (ps11==7)
replace ps13 = 0 if (ps13==7)


/*
	Using the information of the testlet assigned to each respondent,
	we identify the items which he/she was supposed to solve.
*/

forvalues i = 1(1)9 {
	replace cl`i' = 0 if (cl`i'==.)&(cbamod2alt==12|cbamod2alt==13)&(cbamod1stg1==1)
	replace cn`i' = 0 if (cn`i'==.)&(cbamod2alt==21|cbamod2alt==23)&(cbamod1stg1==1)
	replace cl`i' = 0 if (cl`i'==.)&(cbamod2alt==21|cbamod2alt==31)&(cbamod2stg1==1)
	replace cn`i' = 0 if (cn`i'==.)&(cbamod2alt==12|cbamod2alt==32)&(cbamod2stg1==1)
}

forvalues i = 5(1)13 {
	replace cl`i' = 0 if (cl`i'==.)& (cbamod2alt==12|cbamod2alt==13)&(cbamod1stg1==2)
	replace cn`i' = 0 if (cn`i'==.)&(cbamod2alt==21|cbamod2alt==23)&(cbamod1stg1==2)
	replace cl`i' = 0 if (cl`i'==.)&(cbamod2alt==21|cbamod2alt==31)&(cbamod2stg1==2)
	replace cn`i' = 0 if (cn`i'==.)&(cbamod2alt==12|cbamod2alt==32)&(cbamod2stg1==2)
}

forvalues i = 10(1)18 {
	replace cl`i' = 0 if (cl`i'==.)&(cbamod2alt==12|cbamod2alt==13)&(cbamod1stg1==3)
	replace cn`i' = 0 if (cn`i'==.)&(cbamod2alt==21|cbamod2alt==23)&(cbamod1stg1==3)
	replace cl`i' = 0 if (cl`i'==.)&(cbamod2alt==21|cbamod2alt==31)&(cbamod2stg1==3)
	replace cn`i' = 0 if (cn`i'==.)&(cbamod2alt==12|cbamod2alt==32)&(cbamod2stg1==3)
}

forvalues i = 19(1)29 {
	replace cl`i' = 0 if (cl`i'==.)&(cbamod2alt==12|cbamod2alt==13)&(cbamod1stg2==1)
	replace cn`i' = 0 if (cn`i'==.)&(cbamod2alt==21|cbamod2alt==23)&(cbamod1stg2==1)
	replace cl`i' = 0 if (cl`i'==.)&(cbamod2alt==21|cbamod2alt==31)&(cbamod2stg2==1)
	replace cn`i' = 0 if (cn`i'==.)&(cbamod2alt==12|cbamod2alt==32)&(cbamod2stg2==1)
}

forvalues i = 25(1)35 {
	replace cl`i' = 0 if (cl`i'==.)&(cbamod2alt==12|cbamod2alt==13)&(cbamod1stg2==2)
	replace cn`i' = 0 if (cn`i'==.)&(cbamod2alt==21|cbamod2alt==23)&(cbamod1stg2==2)
	replace cl`i' = 0 if (cl`i'==.)&(cbamod2alt==21|cbamod2alt==31)&(cbamod2stg2==2)
	replace cn`i' = 0 if (cn`i'==.)&(cbamod2alt==12|cbamod2alt==32)&(cbamod2stg2==2)
}

forvalues i = 33(1)43 {
	replace cl`i' = 0 if (cl`i'==.)&(cbamod2alt==12|cbamod2alt==13)&(cbamod1stg2==3)
	replace cn`i' = 0 if (cn`i'==.)&(cbamod2alt==21|cbamod2alt==23)&(cbamod1stg2==3)
	replace cl`i' = 0 if (cl`i'==.)&(cbamod2alt==21|cbamod2alt==31)&(cbamod2stg2==3)
	replace cn`i' = 0 if (cn`i'==.)&(cbamod2alt==12|cbamod2alt==32)&(cbamod2stg2==3)
}

forvalues i = 39(1)49 {
	replace cl`i' = 0 if (cl`i'==.)&(cbamod2alt==12|cbamod2alt==13)&(cbamod1stg2==4)
	replace cn`i' = 0 if (cn`i'==.)&(cbamod2alt==21|cbamod2alt==23)&(cbamod1stg2==4)
	replace cl`i' = 0 if (cl`i'==.)&(cbamod2alt==21|cbamod2alt==31)&(cbamod2stg2==4)
	replace cn`i' = 0 if (cn`i'==.)&(cbamod2alt==12|cbamod2alt==32)&(cbamod2stg2==4)
}


// Those who did not have basic computer skill skipped computer-based test
		
forvalues i = 1(1)14 {
	replace ps`i' = . if (cmp_exp==0|core1_fail==1|core2_fail==1)
}

forvalues i = 1(1)49 {
	replace cn`i' = . if (cmp_exp==0|core1_fail==1|core2_fail==1)
	replace cl`i' = . if (cmp_exp==0|core1_fail==1|core2_fail==1)
}

forvalues i = 1(1)20 {
	replace pl`i' = 0 if (pl`i'==.)&(paper==1)
	replace pl`i' = . if (paper==2)
	replace pl`i' = . if (papercore_fail==1|core2_fail==1)	
}
replace pl14 = 1 if (pl14==2)

forvalues i = 1(1)20 {
	replace pn`i' = 0 if (pn`i'==.)&(paper==2)
	replace pn`i' = . if (paper==1)
	replace pn`i' = . if (papercore_fail==1|core2_fail==1)	
}


// Skill-Use Items
rename f_q05a pswork1
rename f_q05b pswork2

rename g_q01a readwork1
rename g_q01b readwork2
rename g_q01c readwork3
rename g_q01d readwork4
rename g_q01e readwork5
rename g_q01f readwork6
rename g_q01g readwork7
rename g_q01h readwork8

rename g_q03b numwork1
rename g_q03c numwork2
rename g_q03d numwork3
rename g_q03f numwork4
rename g_q03g numwork5
rename g_q03h numwork6

gen cmp_work = 2 - g_q04
// cmp_work = 1 if one uses computer to work.

rename g_q05a ictwork1
rename g_q05c ictwork2
rename g_q05d ictwork3
rename g_q05e ictwork4
rename g_q05f ictwork5
rename g_q05g ictwork6
rename g_q05h ictwork7

forvalues i = 1(1)7 {
	replace ictwork`i' = 1 if(cmp_work==0)
}

// Daily Skiil-Use 
rename h_q01a readdaily1
rename h_q01b readdaily2
rename h_q01c readdaily3
rename h_q01d readdaily4
rename h_q01e readdaily5
rename h_q01f readdaily6
rename h_q01g readdaily7
rename h_q01h readdaily8

rename h_q03b numdaily1
rename h_q03c numdaily2
rename h_q03d numdaily3
rename h_q03f numdaily4
rename h_q03g numdaily5
rename h_q03h numdaily6

rename h_q05a ictdaily1
rename h_q05c ictdaily2
rename h_q05d ictdaily3
rename h_q05e ictdaily4
rename h_q05f ictdaily5
rename h_q05g ictdaily6
rename h_q05h ictdaily7

forvalues i = 1(1)7 {
	replace ictdaily`i' = 1 if (cmp_exp==0) | (h_q04b==2)
}

// Background Variables
label define cntry 1 "Austria"
label define cntry 2 "Belgium", add
label define cntry 3 "Canada", add
label define cntry 4 "Czech", add
label define cntry 5 "Denmark", add
label define cntry 6 "Estonia", add
label define cntry 7 "Finland", add
label define cntry 8 "France", add
label define cntry 9 "Germany", add
label define cntry 10 "Ireland", add
label define cntry 11 "Italy", add
label define cntry 12 "Japan", add
label define cntry 13 "Korea", add
label define cntry 14 "Netherlands", add
label define cntry 15 "Norway", add
label define cntry 16 "Poland", add
label define cntry 17 "Russian Federation", add
label define cntry 18 "Slovak Republic", add
label define cntry 19 "Spain", add
label define cntry 20 "Sweden", add
label define cntry 21 "United Kingdom", add
label define cntry 22 "United States", add
label define cntry 23 "Cyprus", add
label define cntry 24 "Chile", add
label define cntry 25 "Greece", add
label define cntry 26 "Israel", add
label define cntry 27 "Lithuania", add
label define cntry 28 "New Zealand", add
label define cntry 29 "Singapore", add
label define cntry 30 "Slovenia", add
label define cntry 31 "Turkey", add
label value country cntry

gen female = gender_r - 1
	// female = 1 -> female; female = 0 -> male
label define sex 0 "male" 1 "female"
label value female sex

rename age_r age
gen age2 = age * age
* age2 represents age squared
gen age3 = age*age*age
* age3 represents age cubed

gen agegroup = ageg5lfs
label define agegroup 1 "16-19"
label define agegroup 2 "20-24", add
label define agegroup 3 "25-29", add
label define agegroup 4 "30-34", add
label define agegroup 5 "35-39", add
label define agegroup 6 "40-44", add
label define agegroup 7 "45-49", add
label define agegroup 8 "50-54", add
label define agegroup 9 "54-59", add
label define agegroup 10 "60-65", add
label value agegroup agegroup

gen age16_19 = 0
replace age16_19 = 1 if (ageg5lfs==1)
gen age20_24 = 0
replace age20_24 = 1 if (ageg5lfs==2)
gen age25_29 = 0
replace age25_29 = 1 if (ageg5lfs==3)
gen age30_34 = 0
replace age30_34 = 1 if (ageg5lfs==4)
gen age35_39 = 0
replace age35_39 = 1 if (ageg5lfs==5)
gen age40_44 = 0
replace age40_44 = 1 if (ageg5lfs==6)
gen age45_49 = 0
replace age45_49 = 1 if (ageg5lfs==7)
gen age50_54 = 0
replace age50_54 = 1 if (ageg5lfs==8)
gen age55_59 = 0
replace age55_59 = 1 if (ageg5lfs==9)
gen age60_65 = 0
replace age60_65 = 1 if (ageg5lfs==10)

gen educ = yrsqual
	// educ represents years of education (imputed)

gen selfemp = d_q04 - 1
	// = 1 if one is self-employed

rename d_q05a1 tenure_age
replace tenure_age = d_q05b1 if (selfemp==1)
	// tenure_age represents the age when the respondent starts to work for the current firm

gen tenure = age - tenure_age
replace tenure = 0 if (tenure<0)
gen tenure2 = tenure * tenure
	// tenure2 represents tenure squared
gen tenure3 = tenure * tenure * tenure
	// tenure3 represents tenure cubed

gen worklastmonth = .
replace worklastmonth = 1 if (inlist(1, c_q01a, c_q01b, c_q01c, c_q02a)==1)
replace worklastmonth = 0 if (c_q01a==2 & c_q01b==2 & c_q01c==2 & c_q02a==2)
replace worklastmonth = 0 if (c_q08a==2 & c_q01c~=1)
replace worklastmonth = 0 if (c_q08b==2 & c_q01c~=1)

rename d_q10 workhour
	// workhour represents hours worked per week, including overtime
replace workhour = 0 if (worklastmonth==0)
gen fulltime = .
replace fulltime = 1 if (workhour>=30 & workhour<.)
replace fulltime = 0 if (workhour<30 & workhour>=0)

rename j_q01 famsize
	// famsize represents family size

rename j_q02a spouse
replace spouse = 0 if (spouse==2)
replace spouse = 0 if (famsize==1)
	// spouse = 1 if one lives with his/her spouse or partner.

gen child = 2 - j_q03a
label define child 1 "A respondent has children"
label define child 0 "A respondent does not have children", add
label value child child

rename j_q03b num_chldrn
	// num_chldrn represents the number of children, including those who do not live with the respondent
replace num_chldrn = 0 if (j_q03a==2)

gen educ_mother = j_q06b
	// educ_mother = 1 -> ISCED123cshort; = 2 -> ISCED3excl3c4; = 3 -> ISCED56

gen educ_father = j_q07b
	// educ_father = 1 -> ISCED123cshort; = 2 -> ISCED3excl3c4; = 3 -> ISCED56


// IRT

**** flag to insert missing value

* Skill

gen cl_flag = 0
gen cl_flag_temp = 0
forvalues i = 1(1)49 {
	replace cl_flag_temp = cl_flag_temp + 1 if (cl`i'==.)
}
replace cl_flag = 1 if (cl_flag_temp==49)
drop cl_flag_temp

gen cn_flag = 0
gen cn_flag_temp = 0
forvalues i = 1(1)49 {
	replace cn_flag_temp = cn_flag_temp + 1 if (cn`i'==.)
}
replace cn_flag = 1 if (cn_flag_temp==49)
drop cn_flag_temp

gen ps_flag = 0
gen ps_flag_temp = 0
forvalues i = 1(1)14 {
	replace ps_flag_temp = ps_flag_temp + 1 if (ps`i'==.)
}
replace ps_flag = 1 if (ps_flag_temp==14)
drop ps_flag_temp

gen pl_flag = 0
gen pl_flag_temp = 0
forvalues i = 1(1)20 {
	replace pl_flag_temp = pl_flag_temp + 1 if (pl`i'==.)
}
replace pl_flag = 1 if (pl_flag_temp==20)
drop pl_flag_temp

gen pn_flag = 0
gen pn_flag_temp = 0
forvalues i = 1(1)20 {
	replace pn_flag_temp = pn_flag_temp + 1 if (pn`i'==.)
}
replace pn_flag = 1 if (pn_flag_temp==20)
drop pn_flag_temp

// Skill-Use at Work
gen readwork_flag = 0
gen readwork_flag_temp = 0
forvalues i = 1(1)8 {
	replace readwork_flag_temp = readwork_flag_temp + 1 if (readwork`i'==.)
}
replace readwork_flag = 1 if (readwork_flag_temp==8)
drop readwork_flag_temp

gen numwork_flag = 0
gen numwork_flag_temp = 0
forvalues i = 1(1)6 {
	replace numwork_flag_temp = numwork_flag_temp + 1 if (numwork`i'==.)
}
replace numwork_flag = 1 if (numwork_flag_temp==6)
drop numwork_flag_temp

gen ictwork_flag = 0
gen ictwork_flag_temp = 0
forvalues i = 1(1)7 {
	replace ictwork_flag_temp = ictwork_flag_temp + 1 if (ictwork`i'==.)
}
replace ictwork_flag = 1 if (ictwork_flag_temp==7)
drop ictwork_flag_temp

// Skill-Use at Daily Life
gen readdaily_flag = 0
gen readdaily_flag_temp = 0
forvalues i = 1(1)8 {
	replace readdaily_flag_temp = readdaily_flag_temp + 1 if (readdaily`i'==.)
}
replace readdaily_flag = 1 if (readdaily_flag_temp==8)
drop readdaily_flag_temp

gen numdaily_flag = 0
gen numdaily_flag_temp = 0
forvalues i = 1(1)6 {
	replace numdaily_flag_temp = numdaily_flag_temp + 1 if (numdaily`i'==.)
}
replace numdaily_flag = 1 if (numdaily_flag_temp==6)
drop numdaily_flag_temp

gen ictdaily_flag = 0
gen ictdaily_flag_temp = 0
forvalues i = 1(1)7 {
	replace ictdaily_flag_temp = ictdaily_flag_temp + 1 if (ictdaily`i'==.)
}
replace ictdaily_flag = 1 if (ictdaily_flag_temp==7)
drop ictdaily_flag_temp


**** IRT (Estimation of skill indices)
aorder

foreach est in theta se {
	foreach tag in _cl _cn _ps_pl _pn {
		gen `est'`tag' = .
	}
}

foreach i of numlist 1(1)16 18(1)30 {

	irt 2pl cl1-cl49 if (country==`i')
	predict theta_cl_`i', latent se(se_cl_`i')
	replace theta_cl_`i' = . if (cl_flag==1)
	replace se_cl_`i' = . if (cl_flag==1)

	irt 2pl cn1-cn49 if (country==`i')
	predict theta_cn_`i', latent se(se_cn_`i')
	replace theta_cn_`i' = . if (cn_flag==1)
	replace se_cn_`i' = . if (cn_flag==1)

	if (inlist(`i',8,13,19,23)==0) {
		irt gpcm ps1-ps14 if (country==`i') 
		predict theta_ps_`i', latent se(se_ps_`i')
		replace theta_ps_`i' = . if (ps_flag==1)
		replace se_ps_`i' = . if (ps_flag==1)
	}
	else {
		gen theta_ps_`i' = .
		gen se_ps_`i' = .
	}

	irt 2pl pl1-pl20 if (country==`i')
	predict theta_pl_`i', latent se(se_pl_`i')
	replace theta_pl_`i' = . if (pl_flag==1)
	replace se_pl_`i' = . if (pl_flag==1)

	irt 2pl pn1-pn20 if (country==`i')
	predict theta_pn_`i', latent se(se_pn_`i')
	replace theta_pn_`i' = . if (pn_flag==1)
	replace se_pn_`i' = . if (pn_flag==1)

	foreach v of varlist theta_cl theta_cn theta_ps theta_pl theta_pn se_cl se_cn se_ps se_pl se_pn {
		replace `v' = `v'_`i' if (country==`i')
	}
}

forvalues i = 17(1)17 {

	irt 2pl cl1-cl48 if (country==`i')
	predict theta_cl_`i', latent se(se_cl_`i')
	replace theta_cl_`i' = . if (cl_flag==1)
	replace se_cl_`i' = . if (cl_flag==1)

	irt 2pl cn1-cn49 if (country==`i')
	predict theta_cn_`i', latent se(se_cn_`i')
	replace theta_cn_`i' = . if (cn_flag==1)
	replace se_cn_`i' = . if (cn_flag==1)

	irt gpcm ps1-ps14 if (country==`i')
	predict theta_ps_`i', latent se(se_ps_`i')
	replace theta_ps_`i' = . if (ps_flag==1)
	replace se_ps_`i' = . if (ps_flag==1)

	irt 2pl pl1-pl20 if (country==`i')
	predict theta_pl_`i', latent se(se_pl_`i')
	replace theta_pl_`i' = . if (pl_flag==1)
	replace se_pl_`i' = . if (pl_flag==1)

	irt 2pl pn1-pn20 if (country==`i')
	predict theta_pn_`i', latent se(se_pn_`i')
	replace theta_pn_`i' = . if (pn_flag==1)
	replace se_pn_`i' = . if (pn_flag==1)

	foreach v of varlist theta_cl theta_cn theta_ps theta_pl theta_pn se_cl se_cn se_ps se_pl se_pn {
		replace `v' = `v'_`i' if (country==`i')
	}
}

forvalues i = 31(1)31 {

	irt 2pl cl1-cl21 cl23-cl25 cl27-cl32 cl35-cl49 if (country==`i')
	predict theta_cl_`i', latent se(se_cl_`i')
	replace theta_cl_`i' = . if (cl_flag==1)
	replace se_cl_`i' = . if (cl_flag==1)
	* cl22, cl26, cl33 and cl35 have no variation

	irt 2pl cn1-cn49 if (country==`i')
	predict theta_cn_`i', latent se(se_cn_`i')
	replace theta_cn_`i' = . if (cn_flag==1)
	replace se_cn_`i' = . if (cn_flag==1)

	irt gpcm ps1-ps14 if (country==`i')
	predict theta_ps_`i', latent se(se_ps_`i')
	replace theta_ps_`i' = . if (ps_flag==1)
	replace se_ps_`i' = . if (ps_flag==1)

	irt 2pl pl1-pl20 if (country==`i')
	predict theta_pl_`i', latent se(se_pl_`i')
	replace theta_pl_`i' = . if (pl_flag==1)
	replace se_pl_`i' = . if (pl_flag==1)

	irt 2pl pn1-pn20 if (country==`i')
	predict theta_pn_`i', latent se(se_pn_`i')
	replace theta_pn_`i' = . if (pn_flag==1)
	replace se_pn_`i' = . if (pn_flag==1)

	foreach v of varlist theta_cl theta_cn theta_ps theta_pl theta_pn se_cl se_cn se_ps se_pl se_pn {
		replace `v' = `v'_`i' if (country==`i')
	}
}

gen skill_lit = theta_cl if (theta_cl~=.) 
replace skill_lit = theta_pl if (theta_pl~=.)

gen se_lit = se_cl if (se_cl~=.)
replace se_lit = se_pl if (se_pl~=.)

gen skill_num = theta_cn if (theta_cn~=.) 
replace skill_num = theta_pn if (theta_pn~=.) 

gen se_num = se_cn if (se_cn~=.)
replace se_num = se_pn if (se_pn~=.)

gen skill_ps = theta_ps if (theta_ps~=.)
replace se_ps = . if (skill_ps==.)


// IRT (Estimation of skill-use indices)
aorder

foreach var in skilluse se_skilluse skillusedaily se_skillusedaily {
	foreach tag in _lit _num _ict {
		gen `var'`tag' = .
		gen p`var'`tag' = .
	}
}
		

foreach i of numlist 1(1)26 28 29 31 {
	irt gpcm readwork1-readwork8 if (country==`i')
	predict skilluse_lit_`i' if (country==`i'), latent se(se_skilluse_lit_`i')
	replace skilluse_lit_`i' = . if (readwork_flag==1)
	sum skilluse_lit_`i' if (country==`i')
	replace pskilluse_lit = (skilluse_lit_`i' - r(min))/(r(max) - r(min)) if (country==`i')

	irt gpcm numwork1-numwork6 if (country==`i')
	predict skilluse_num_`i' if (country==`i'), latent se(se_skilluse_num_`i')
	replace skilluse_num_`i' = . if (numwork_flag==1)
	sum skilluse_num_`i' if (country==`i')
	replace pskilluse_num = (skilluse_num_`i' - r(min))/(r(max) - r(min)) if (country==`i')

	irt gpcm ictwork1-ictwork7 if (country==`i')
	predict skilluse_ict_`i' if (country==`i'), latent se(se_skilluse_ict_`i')
	replace skilluse_ict_`i' = . if (ictwork_flag==1)
	sum skilluse_ict_`i' if (country==`i')
	replace pskilluse_ict = (skilluse_ict_`i' - r(min))/(r(max) - r(min)) if (country==`i')
	
	irt gpcm readdaily1-readdaily8 if (country==`i')
	predict skillusedaily_lit_`i' if (country==`i'), latent se(se_skillusedaily_lit_`i')
	replace skillusedaily_lit_`i' = . if (readdaily_flag==1)
	sum skillusedaily_lit_`i' if (country==`i')
	replace pskillusedaily_lit = (skillusedaily_lit_`i' - r(min))/(r(max) - r(min)) if (country==`i')
	
	irt gpcm numdaily1-numdaily6 if (country==`i')
	predict skillusedaily_num_`i' if (country==`i'), latent se(se_skillusedaily_num_`i')
	replace skillusedaily_num_`i' = . if (numdaily_flag==1)
	sum skillusedaily_num_`i' if (country==`i')
	replace pskillusedaily_num = (skillusedaily_num_`i' - r(min))/(r(max) - r(min)) if (country==`i')

	irt gpcm ictdaily1-ictdaily7 if (country==`i')
	predict skillusedaily_ict_`i' if (country==`i'), latent se(se_skillusedaily_ict_`i')
	replace skillusedaily_ict_`i' = . if (ictdaily_flag==1)
	sum skillusedaily_ict_`i' if (country==`i')
	replace pskillusedaily_ict = (skillusedaily_ict_`i' - r(min))/(r(max) - r(min)) if (country==`i')
	
	foreach var in skilluse se_skilluse {
		foreach tag in _lit _num _ict {
			replace `var'`tag' = `var'`tag'_`i' if (country==`i')
			replace `var'daily`tag' = `var'daily`tag'_`i' if (country==`i')
		}
	}
}

foreach i in 27 30 {
	irt gpcm readwork1-readwork8 if (country==`i')
	predict skilluse_lit_`i' if (country==`i'), latent se(se_skilluse_lit_`i')
	replace skilluse_lit_`i' = . if (readwork_flag==1)
	sum skilluse_lit_`i' if (country==`i')
	replace pskilluse_lit = (skilluse_lit_`i' - r(min))/(r(max) - r(min)) if (country==`i')

	irt gpcm numwork1-numwork6 if (country==`i')
	predict skilluse_num_`i' if (country==`i'), latent se(se_skilluse_num_`i')
	replace skilluse_num_`i' = . if (numwork_flag==1)
	sum skilluse_num_`i' if (country==`i')
	replace pskilluse_num = (skilluse_num_`i' - r(min))/(r(max) - r(min)) if (country==`i')

	irt gpcm ictwork1-ictwork7 if (country==`i')
	predict skilluse_ict_`i' if (country==`i'), latent se(se_skilluse_ict_`i') intpoints(9)
	replace skilluse_ict_`i' = . if (ictwork_flag==1)
	sum skilluse_ict_`i' if (country==`i')
	replace pskilluse_ict = (skilluse_ict_`i' - r(min))/(r(max) - r(min)) if (country==`i')
	
	irt gpcm readdaily1-readdaily8 if (country==`i')
	predict skillusedaily_lit_`i' if (country==`i'), latent se(se_skillusedaily_lit_`i')
	replace skillusedaily_lit_`i' = . if (readdaily_flag==1)
	sum skillusedaily_lit_`i' if (country==`i')
	replace pskillusedaily_lit = (skillusedaily_lit_`i' - r(min))/(r(max) - r(min)) if (country==`i')
	
	irt gpcm numdaily1-numdaily6 if (country==`i')
	predict skillusedaily_num_`i' if (country==`i'), latent se(se_skillusedaily_num_`i')
	replace skillusedaily_num_`i' = . if (numdaily_flag==1)
	sum skillusedaily_num_`i' if (country==`i')
	replace pskillusedaily_num = (skillusedaily_num_`i' - r(min))/(r(max) - r(min)) if (country==`i')

	irt gpcm ictdaily1-ictdaily7 if (country==`i')
	predict skillusedaily_ict_`i' if (country==`i'), latent se(se_skillusedaily_ict_`i')
	replace skillusedaily_ict_`i' = . if (ictdaily_flag==1)
	sum skillusedaily_ict_`i' if (country==`i')
	replace pskillusedaily_ict = (skillusedaily_ict_`i' - r(min))/(r(max) - r(min)) if (country==`i')
	
	foreach var in skilluse se_skilluse {
		foreach tag in _lit _num _ict {
			replace `var'`tag' = `var'`tag'_`i' if (country==`i')
			replace `var'daily`tag' = `var'daily`tag'_`i' if (country==`i')
		}
	}
}


// Normalization
qui gen lit = .
qui gen num = .
qui gen ict = .
foreach v of varlist lit num ict {
	qui gen work`v' = .
	qui gen home`v' = .
}

forvalues i = 1(1)31 {
	foreach v of varlist lit num {
		qui sum skill_`v' if (country==`i')
		qui replace `v' = (skill_`v' - r(mean))/r(sd) if (country==`i')
		qui sum skilluse_`v' if (country==`i')
		qui replace work`v' = (skilluse_`v' - r(mean))/r(sd) if (country==`i')
		qui sum skillusedaily_`v' if (country==`i')
		qui replace home`v' = (skillusedaily_`v' - r(mean))/r(sd) if (country==`i')
	}
}

forvalues i = 1(1)31 {
	qui sum skill_ps if (country==`i')
	qui replace ict = (skill_ps - r(mean))/r(sd) if (country==`i')
	qui sum skilluse_ict if (country==`i')
	qui replace workict = (skilluse_ict - r(mean))/r(sd) if (country==`i')
	qui sum skillusedaily_ict if (country==`i')
	qui replace homeict = (skillusedaily_ict - r(mean))/r(sd) if (country==`i')
}


// Wage: Continuous Value
gen wage = earnhr

forvalues i = 1(1)31 {
	_pctile wage if(country==`i'), nq(100)
	replace wage = . if(country==`i') & (wage<=r(r1) | wage>=r(r99))
}

gen lwage = ln(wage)

// Other Variables
gen age60 = 0
replace age60 = 1 if (age>=60 & age<1000)

gen agegroup0 = 0
gen agegroup1 = 0
gen agegroup2 = 0
gen agegroup3 = 0
gen agegroup4 = 0

replace agegroup0 = 1 if (inlist(1, age16_19, age20_24)==1) 
replace agegroup1 = 1 if (inlist(1, age25_29, age30_34)==1) 
replace agegroup2 = 1 if (inlist(1, age35_39, age40_44, age45_49)==1) 
replace agegroup3 = 1 if (inlist(1, age50_54, age55_59)==1) 
replace agegroup4 = 1 if (age60_65==1)

gen female_chldrn = female * num_chldrn
gen female_spouse = female * spouse

gen spouse_regular = (j_q02c==1) if (j_q02c~=.)

gen female_spreg = female * spouse_regular

gen work_flag = .
replace work_flag = 1 if (c_q01a==1|c_q01b==1)|(c_q01c==1)
replace work_flag = 2 if (c_q08a==1&c_q08b==1)
replace work_flag = 3 if (c_q08a==1&c_q08b==2)
replace work_flag = 4 if (c_q08a==2)
/*
	1 <- currently work
	2 <- currently not work, but worked during last 12 months
	3 <- currently not work and not work during last 12 months, but has work experience
	4 <- no work experience
	"work_flag" corresponds to C_D09 in questionare.
*/

gen work = work_flag
replace work = 0 if (inlist(work_flag, 2, 3, 4)==1)

gen drop_flag = 0
replace drop_flag = 1 if (c_q07==4|c_q07==7)
* We will exclude students and permanently disabled people from sample. 

drop country
egen country = group(cntryid)
label define country 1 "Austria"
label define country 2 "Belgium", add
label define country 3 "Canada", add
label define country 4 "Chile", add
label define country 5 "Cyprus", add
label define country 6 "Czech", add
label define country 7 "Denmark", add
label define country 8 "Estonia", add
label define country 9 "Finland", add
label define country 10 "France", add
label define country 11 "Germany", add
label define country 12 "Greece", add
label define country 13 "Ireland", add
label define country 14 "Israel", add
label define country 15 "Italy", add
label define country 16 "Japan", add
label define country 17 "Korea", add
label define country 18 "Lithuania", add
label define country 19 "Netherlands", add
label define country 20 "New Zealand", add
label define country 21 "Norway", add
label define country 22 "Poland", add
label define country 23 "Russian Federation", add
label define country 24 "Singapore", add
label define country 25 "Slovak Republic", add
label define country 26 "Slovenia", add
label define country 27 "Spain", add
label define country 28 "Sweden", add
label define country 29 "Turkey", add
label define country 30 "United Kingdom", add
label define country 31 "United States", add
label value country country
	
// Sample restriction
qui drop if (inlist(1,age16_19,age20_24,age60_65)==1)
qui drop if (country==23)
qui drop if (drop_flag==1)
capture qui tab country, gen(cfe)

// Other outcomes regarding  skill use at work place

// Clean Germany data
foreach i in 11 12 13 {
	foreach j in A B C D E F G {
		local k = strlower("`j'")
		capture replace d_q`i'`k' = d_q`i'`j' if (country==11)
	}
}

forvalues i = 1(1)9 {
	foreach j in A B C D E F G {
		local k = strlower("`j'")
		capture replace f_q0`i'`k' = f_q0`i'`j' if (country==11)
	}
}

foreach i in 2 {
	foreach j in A B C D E F G {
		local k = strlower("`j'")
		capture replace g_q0`i'`k' = g_q0`i'`j' if (country==11)
	}
}

sum d_q1?? f_q0?? g_q02? if (country==11)

// Make variables to use IRT

// Task discretion at work
local num = 1
foreach j in a b c d {
	gen q_taskdisc`num' = d_q11`j'
	local num = `num' + 1
}

gen taskdisc_flag = 0
gen taskdisc_flag_temp = 0
forvalues i = 1(1)4 {
	replace taskdisc_flag_temp = taskdisc_flag_temp + 1 if (q_taskdisc`i'==.)
}
replace taskdisc_flag = 1 if (taskdisc_flag_temp==4)
drop taskdisc_flag_temp

// Learning at work
local num = 1
foreach j in a b c {
	gen q_learning`num' = d_q13`j'
	local num = `num' + 1
}

gen learning_flag = 0
gen learning_flag_temp = 0
forvalues i = 1(1)3 {
	replace learning_flag_temp = learning_flag_temp + 1 if (q_learning`i'==.)
}
replace learning_flag = 1 if (learning_flag_temp==3)
drop learning_flag_temp

// Influence at work
gen q_influence1 = f_q02b
gen q_influence2 = f_q02c
gen q_influence3 = f_q02e
gen q_influence4 = f_q03b
gen q_influence5 = f_q04a
gen q_influence6 = f_q04b

gen influence_flag = 0
gen influence_flag_temp = 0
forvalues i = 1(1)6 {
	replace influence_flag_temp = influence_flag_temp + 1 if (q_influence`i'==.)
}
replace influence_flag = 1 if (influence_flag_temp==6)
drop influence_flag_temp

// Writing skill at work
local num = 1
foreach j in a b c d {
	gen q_workwrite`num' = g_q02`j'
	local num = `num' + 1
}

gen workwrite_flag = 0
gen workwrite_flag_temp = 0
forvalues i = 1(1)4 {
	replace workwrite_flag_temp = workwrite_flag_temp + 1 if (q_workwrite`i'==.)
}
replace workwrite_flag = 1 if (workwrite_flag_temp==4)
drop workwrite_flag_temp

// Subjective skill-use measure
local num = 1
foreach j in a b c {
	gen q_sbjctv_skilluse`num' = d_q12`j'
	local num = `num' + 1
}

// Make IRT scores
local ntaskdisc = 4
local nlearning = 3
local ninfluence = 6
local nworkwrite = 4

foreach var in irt_taskdisc irt_learning irt_influence irt_workwrite {
	gen `var' = .
}

forvalues i = 1(1)31 {
	display "**** Country `i' ****"
	if (`i'~=23) {
		foreach var in taskdisc learning influence workwrite {
			qui irt gpcm q_`var'1-q_`var'`n`var'' if (country==`i')
			qui predict `var'_`i' if (country==`i'), latent
			qui replace `var'_`i' = . if (`var'_flag==1)
			qui replace irt_`var' = `var'_`i' if (country==`i')
			qui drop `var'_`i'
			
			display "IRT `var' was done"
		}
	}
	else {
		display "Skipped"
	}
	display ""
}

// Check the correlation with the imputed variables in PIAAC
corr taskdisc irt_taskdisc
corr learnatwork irt_learning
corr influence irt_influence
corr writwork irt_workwrite

// 4-digit occupation label
do "${path_do}/common/label_occup4digit.do"

// Occupation of the low skilled by gender
tab isco08_c if (work==1)&(female==0)&(lit<-1), sort
tab isco08_c if (work==1)&(female==1)&(lit<-1), sort


// Merge country-level data
merge m:1 cntryid using "${path_data}/inst.dta", keep(3) nogen
save "${path_data}/piaac_main.dta", replace

log close
