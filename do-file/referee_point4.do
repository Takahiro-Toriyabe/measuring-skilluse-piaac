*Open log file
local dofile_name "referee_point4"
// TakeLog `dofile_name', path("${path_log}")
// capture mkdir "${path_table}/csv/`dofile_name'"

* Load data
use "${path_data}", clear 
do "${path_do}/common/InitialSetting.do"
do "${path_do}/common/GenLabeledCntryID.do"

keep if !missing(worklit) & !missing(homelit) & work == 1

// Full sample
qui levelsof cntryid3letter, local(clist)
local I = wordcount("`clist'")
local rownames ""
matrix B = J(`I', 1, .)
matrix SE = J(`I', 1, .)

forvalues i = 1(1)`I' {
	local c: word `i' of `clist'
	local cntry: label cntryid3letter `c'
	local rownames `rownames' `cntry'
	foreach v in worklit homelit {
		qui reg `v' lit female $xvars if cntryid3letter == `c', robust
		tempvar uhat`v'
		qui predict `uhat`v'' if cntryid3letter == `c', residual
		qui sum `uhat`v'' if cntryid3letter == `c'
		local sd`v' = r(sd)
	}
	qui reg `uhathomelit' `uhatworklit' if cntryid3letter == `c', nocons robust
	matrix B[`i', 1] = _b[`uhatworklit'] * `sdworklit' / `sdhomelit'
	matrix SE[`i', 1] = _se[`uhatworklit'] * `sdworklit' / `sdhomelit'
}

matrix rownames B = `rownames'

coefplot matrix(B[.,1]), se(SE[.,1]) ///
	xtitle("Partial correlation between literacy use at home and at work") ///
	xlabel(0(0.1)0.72, glwidth(vthin) format(%03.2f)) ///
	xline(0, lpattern(solid) lcolor(gs10) lwidth(medthin)) ///
	scheme(tt_mono) xsize(3.8) ysize(4)

graph export "${path_figure}/pdf/corr_homelit_worklit.pdf", as(pdf) replace
graph export "${path_figure}/png/corr_homelit_worklit.png", as(png) replace ///
	width(${fig_w_main}) height(${fig_h_main})

// By gender
foreach g in 0 1 {
	qui levelsof cntryid3letter, local(clist)
	local I = wordcount("`clist'")
	local rownames ""
	matrix B = J(`I', 1, .)
	matrix SE = J(`I', 1, .)

	forvalues i = 1(1)`I' {
		local c: word `i' of `clist'
		local cntry: label cntryid3letter `c'
		local rownames `rownames' `cntry'
		foreach v in worklit homelit {
			qui reg `v' lit $xvars if cntryid3letter == `c' & female == `g', robust
			tempvar uhat`v'
			qui predict `uhat`v'' if cntryid3letter == `c' & female == `g', residual
			qui sum `uhat`v'' if cntryid3letter == `c' & female == `g'
			local sd`v' = r(sd)
		}
		qui reg `uhathomelit' `uhatworklit' if cntryid3letter == `c' & female == `g', nocons robust
		matrix B[`i', 1] = _b[`uhatworklit'] * `sdworklit' / `sdhomelit'
		matrix SE[`i', 1] = _se[`uhatworklit'] * `sdworklit' / `sdhomelit'
	}

	matrix rownames B = `rownames'

	coefplot matrix(B[.,1]), se(SE[.,1]) ///
		xtitle("Partial correlation between literacy use at home and at work") ///
		xlabel(0(0.1)0.72, glwidth(vthin) format(%03.2f)) ///
		xline(0, lpattern(solid) lcolor(gs10) lwidth(medthin)) ///
		scheme(tt_mono) xsize(3.8) ysize(4)

	graph export "${path_figure}/pdf/corr_homelit_worklit_g`g'.pdf", as(pdf) replace
	graph export "${path_figure}/png/corr_homelit_worklit_g`g'.png", as(png) replace ///
		width(${fig_w_main}) height(${fig_h_main})
}

* Load data
use "${path_data}", clear 
do "${path_do}/common/InitialSetting.do"
do "${path_do}/common/GenLabeledCntryID.do"

keep if !missing(worknum) & !missing(homenum) & work == 1

// Full sample
qui levelsof cntryid3letter, local(clist)
local I = wordcount("`clist'")
local rownames ""
matrix B = J(`I', 1, .)
matrix SE = J(`I', 1, .)

forvalues i = 1(1)`I' {
	local c: word `i' of `clist'
	local cntry: label cntryid3letter `c'
	local rownames `rownames' `cntry'
	foreach v in worknum homenum {
		qui reg `v' num female $xvars if cntryid3letter == `c', robust
		tempvar uhat`v'
		qui predict `uhat`v'' if cntryid3letter == `c', residual
		qui sum `uhat`v'' if cntryid3letter == `c'
		local sd`v' = r(sd)
	}
	qui reg `uhathomenum' `uhatworknum' if cntryid3letter == `c', nocons robust
	matrix B[`i', 1] = _b[`uhatworknum'] * `sdworknum' / `sdhomenum'
	matrix SE[`i', 1] = _se[`uhatworknum'] * `sdworknum' / `sdhomenum'
}

matrix rownames B = `rownames'

coefplot matrix(B[.,1]), se(SE[.,1]) ///
	xtitle("Partial correlation between numeracy use at home and at work") ///
	xlabel(0(0.1)0.72, glwidth(vthin) format(%03.2f)) ///
	xline(0, lpattern(solid) lcolor(gs10) lwidth(medthin)) ///
	scheme(tt_mono) xsize(3.8) ysize(4)

graph export "${path_figure}/pdf/corr_homenum_worknum.pdf", as(pdf) replace
graph export "${path_figure}/png/corr_homenum_worknum.png", as(png) replace ///
	width(${fig_w_main}) height(${fig_h_main})

// By gender
foreach g in 0 1 {
	qui levelsof cntryid3letter, local(clist)
	local I = wordcount("`clist'")
	local rownames ""
	matrix B = J(`I', 1, .)
	matrix SE = J(`I', 1, .)

	forvalues i = 1(1)`I' {
		local c: word `i' of `clist'
		local cntry: label cntryid3letter `c'
		local rownames `rownames' `cntry'
		foreach v in worknum homenum {
			qui reg `v' num $xvars if cntryid3letter == `c' & female == `g', robust
			tempvar uhat`v'
			qui predict `uhat`v'' if cntryid3letter == `c' & female == `g', residual
			qui sum `uhat`v'' if cntryid3letter == `c' & female == `g'
			local sd`v' = r(sd)
		}
		qui reg `uhathomenum' `uhatworknum' if cntryid3letter == `c' & female == `g', nocons robust
		matrix B[`i', 1] = _b[`uhatworknum'] * `sdworknum' / `sdhomenum'
		matrix SE[`i', 1] = _se[`uhatworknum'] * `sdworknum' / `sdhomenum'
	}

	matrix rownames B = `rownames'

	coefplot matrix(B[.,1]), se(SE[.,1]) ///
		xtitle("Partial correlation between numeracy use at home and at work") ///
		xlabel(0(0.1)0.72, glwidth(vthin) format(%03.2f)) ///
		xline(0, lpattern(solid) lcolor(gs10) lwidth(medthin)) ///
		scheme(tt_mono) xsize(3.8) ysize(4)

	graph export "${path_figure}/pdf/corr_homenum_worknum_g`g'.pdf", as(pdf) replace
	graph export "${path_figure}/png/corr_homenum_worknum_g`g'.png", as(png) replace ///
		width(${fig_w_main}) height(${fig_h_main})
}

// Wage regression with work hours
// Gender wage gap
use "${path_data}", clear
do "${path_do}/common/InitialSetting.do"

// Tenure
replace d_q05a2 = d_q05A2 if !missing(d_q05A2)
replace d_q05b2 = d_q05B2 if !missing(d_q05B2)
replace tenure = 2012 - d_q05a2 + 3 * round2 if missing(tenure) & selfemp == 0
replace tenure = 2012 - d_q05b2 + 3 * round2 if missing(tenure) & selfemp==1

// Immigration status
gen flag_immigrant = j_q04a == 2 if !missing(j_q04a)
replace flag_immigrant = . if cntryid == 616 // Very small immigrants in Poland data


keep if flag_paper_lit == 0

capture gen cons = 1
local x1 "female"
local x2 "age30_34 age35_39 age40_44 age45_49 age50_54 age55_59 flag_immigrant educ tenure workhour lit worklit"
local K = wordcount("`x1' `x2'") + 1

levelsof cntryid if !missing(lwage) & !missing(tenure) & !missing(flag_immigrant) & !missing(workhour), ///
	local(clist)
local I = wordcount("`clist'")
matrix DELTA = J(`I', 6, .)
matrix B = J(`I', 2, .)
matrix ID = J(`I', 1, .)

forvalues i = 1(1)`I' {
	local c: word `i' of `clist'
	matrix ID[`i', 1] = `c'

	tempvar flag_sample
	qui reg lwage `x1' `x2' if cntryid == `c', robust
	matrix B[`i', 1] = _b[`x1']
	gen `flag_sample' = e(sample)

	matrix BFULL = e(b)
	matrix BX2 = BFULL[1, 2..`=`K'-1']

	qui reg lwage `x1' if `flag_sample', robust
	matrix B[`i', 2] = _b[`x1']

	mkmat cons `x1' if `flag_sample', matrix(X1)
	mkmat `x2' if `flag_sample', matrix(X2)

	matrix GAMMA = inv(X1' * X1) * X1' * X2
	matrix DELTA[`i', 1] = -1 * GAMMA[2, 1..7] * BX2[1, 1..7]'
	matrix DELTA[`i', 2] = -1 * GAMMA[2, 8] * BX2[1, 8]'
	matrix DELTA[`i', 3] = -1 * GAMMA[2, 9] * BX2[1, 9]'
	matrix DELTA[`i', 4] = -1 * GAMMA[2, 10] * BX2[1, 10]'
	matrix DELTA[`i', 5] = -1 * GAMMA[2, 11] * BX2[1, 11]'
	matrix DELTA[`i', 6] = -1 * GAMMA[2, 12] * BX2[1, 12]'
}

clear
svmat DELTA
svmat B
svmat ID
rename ID1 cntryid
do "${path_do}/common/GenLabeledCntryID.do"

gen diff = B1 - B2
forvalues i = 1(1)6 {
	gen pdiff`i' = DELTA`i' / abs(diff)
}

expand 2
bysort cntryid: gen tmp = _n

forvalues i = 1(1)6 {
	replace DELTA`i' = . if tmp == 1
}
gen DELTA0 = diff if tmp == 1

graph hbar B2 B1 if tmp == 2, over(cntryid3letter) ///
	ytitle("Wage gap: Female vs Male") ylabel(-0.5(0.05)0, format("%03.2f")) ///
	legend(order(1 "Unconditional" 2 "Conditional"))
graph export "${path_figure}/pdf/wagegaplit_gender_refp4.pdf", as(pdf) replace
graph export "${path_figure}/png/wagegaplit_gender_refp4.png", as(png) replace ///
	width(${fig_w_main}) height(${fig_h_main})

graph hbar DELTA0 DELTA1 DELTA2 DELTA3 DELTA4 DELTA5 DELTA6, ///
	stack over(tmp, label(nolabel) gap(*0.4)) over(cntryid3letter, label(labsize(*0.8)) gap(*0.5)) ///
	ytitle("Gelbach decomposition result") ylabel(-0.20(0.04)0.24, format("%03.2f")) ///
	legend(order(1 "Total: {&beta}{sub:full} - {&beta}{sub:base}" 2 "Demographics" 3 "Education" 4 "Tenure" ///
		5 "Work hours" 6 "Literacy skill" 7 "Literacy use"))
graph export "${path_figure}/pdf/gelbachlit_gender_refp4.pdf", as(pdf) replace
graph export "${path_figure}/png/gelbachlit_gender_refp4.png", as(png) replace ///
	width(${fig_w_main}) height(${fig_h_main})

// Immigrant
use "${path_data}", clear
do "${path_do}/common/InitialSetting.do"

// Tenure
replace d_q05a2 = d_q05A2 if !missing(d_q05A2)
replace d_q05b2 = d_q05B2 if !missing(d_q05B2)
replace tenure = 2012 - d_q05a2 + 3 * round2 if missing(tenure) & selfemp == 0
replace tenure = 2012 - d_q05b2 + 3 * round2 if missing(tenure) & selfemp==1

// Immigration status
gen flag_immigrant = j_q04a == 2 if !missing(j_q04a)
replace flag_immigrant = . if cntryid == 616 // Very small immigrants in Poland data


keep if flag_paper_lit == 0

capture gen cons = 1
local x1 "flag_immigrant"
local x2 "age30_34 age35_39 age40_44 age45_49 age50_54 age55_59 female educ tenure workhour lit worklit"
local K = wordcount("`x1' `x2'") + 1

levelsof cntryid if !missing(lwage) & !missing(tenure) & !missing(flag_immigrant) & !missing(workhour), ///
	local(clist)
local I = wordcount("`clist'")
matrix DELTA = J(`I', 6, .)
matrix B = J(`I', 2, .)
matrix ID = J(`I', 1, .)

reg lwage `x1' `x2' if cntryid == 392
reg lwage `x1' if e(sample)


forvalues i = 1(1)`I' {
	local c: word `i' of `clist'
	matrix ID[`i', 1] = `c'

	tempvar flag_sample
	qui reg lwage `x1' `x2' if cntryid == `c', robust
	matrix B[`i', 1] = _b[`x1']
	gen `flag_sample' = e(sample)

	matrix BFULL = e(b)
	matrix BX2 = BFULL[1, 2..`=`K'-1']

	qui reg lwage `x1' if `flag_sample', robust
	matrix B[`i', 2] = _b[`x1']

	mkmat cons `x1' if `flag_sample', matrix(X1)
	mkmat `x2' if `flag_sample', matrix(X2)

	matrix GAMMA = inv(X1' * X1) * X1' * X2
	matrix DELTA[`i', 1] = -1 * GAMMA[2, 1..7] * BX2[1, 1..7]'
	matrix DELTA[`i', 2] = -1 * GAMMA[2, 8] * BX2[1, 8]'
	matrix DELTA[`i', 3] = -1 * GAMMA[2, 9] * BX2[1, 9]'
	matrix DELTA[`i', 4] = -1 * GAMMA[2, 10] * BX2[1, 10]'
	matrix DELTA[`i', 5] = -1 * GAMMA[2, 11] * BX2[1, 11]'
	matrix DELTA[`i', 6] = -1 * GAMMA[2, 12] * BX2[1, 12]'
}

clear
svmat DELTA
svmat B
svmat ID
rename ID1 cntryid
do "${path_do}/common/GenLabeledCntryID.do"

gen diff = B1 - B2
forvalues i = 1(1)5 {
	gen pdiff`i' = DELTA`i' / abs(diff)
}

expand 2
bysort cntryid: gen tmp = _n

forvalues i = 1(1)5 {
	replace DELTA`i' = . if tmp == 1
}
gen DELTA0 = diff if tmp == 1

graph hbar B2 B1 if tmp == 2, over(cntryid3letter) ///
	ytitle("Wage gap: Immigrants vs Non-immigrants") ylabel(-0.5(0.1)0.4, format("%03.2f")) ///
	legend(order(1 "Unconditional" 2 "Conditional"))
graph export "${path_figure}/pdf/wagegaplit_immigrant_refp4.pdf", as(pdf) replace
graph export "${path_figure}/png/wagegaplit_immigrant_refp4.png", as(png) replace ///
	width(${fig_w_main}) height(${fig_h_main})

graph hbar DELTA0 DELTA1 DELTA2 DELTA3 DELTA4 DELTA5 DELTA6, ///
	stack over(tmp, label(nolabel) gap(*0.4)) over(cntryid3letter, label(labsize(*0.8)) gap(*0.5)) ///
	ytitle("Gelbach decomposition result") ylabel(-0.15(0.05)0.4, format("%03.2f")) ///
	legend(order(1 "Total: {&beta}{sub:full} - {&beta}{sub:base}" 2 "Demographics" 3 "Education" 4 "Tenure" ///
		5 "Work hours" 6 "Literacy skill" 7 "Literacy use"))
graph export "${path_figure}/pdf/gelbachlit_immigrant_refp4.pdf", as(pdf) replace
graph export "${path_figure}/png/gelbachlit_immigrant_refp4.png", as(png) replace ///
	width(${fig_w_main}) height(${fig_h_main})
