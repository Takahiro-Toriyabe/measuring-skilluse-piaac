// Figure 5
use "${path_data}/piaac_main.dta", clear
do "${path_do}/common/InitialSetting.do"

levelsof cntryid, local(cntryid_list)
foreach score in lit num worklit worknum {
	qui gen b`score' = .
	qui gen se`score' = .
	local skill = subinstr("`score'", "work", "", .)
	Normalize `score', by(cntryid)
	foreach c in `cntryid_list' {
		qui reg `score' female if cntryid == `c' & flag_paper_`skill' == 0, robust
		qui replace b`score' = _b[female] if cntryid == `c'
		qui replace se`score' = _se[female] if cntryid == `c'
	}
}
	
do "${path_do}/common/GenLabeledCntryID.do"

qui duplicates drop cntryid3letter, force

local rownames ""
foreach j in `cntryid_list' {
	local cntry: label cntryid3letter `j'
	local rownames `rownames' `cntry'
}

foreach v of varlist lit num worklit worknum {
	mkmat b`v', matrix(B)
	matrix rownames B = `rownames'
	mkmat se`v', matrix(SE)

	coefplot matrix(B[.,1]), se(SE[.,1]) ///
		xtitle("Gender gap") ///
		xlabel(-0.7(0.1)0.3, glwidth(vthin)) ///
		xline(0, lpattern(solid) lcolor(gs10) lwidth(medthin)) ///
		xlabel(, glwidth(vthin) format(%02.1f)) ///
		xsize(3.8) ysize(4)
}

// Figure 6
use "${path_data}/piaac_main.dta", clear
do "${path_do}/common/InitialSetting.do"

levelsof cntryid, local(cntryid_list)
foreach v in lit num {
	Normalize work`v' if work == 1 & flag_paper_`v' == 0, by(cntryid)

	qui reg work`v' i.cntryid#c.workhour i.cntryid if work == 1 & flag_paper_`v' == 0
	tempvar uhat
	qui predict `uhat' if e(sample), residual
	qui replace work`v' = `uhat' if e(sample)
	qui replace work`v' = . if !e(sample)

	qui gen bwork`v' = .
	qui gen sework`v' = .
	
	foreach c in `cntryid_list' {
		qui count if cntryid == `c' & !missing(workhour) & work == 1
		if r(N) > 0 {
			qui reg work`v' female if cntryid == `c' & flag_paper_`v' == 0, robust
			qui replace bwork`v' = _b[female] if cntryid == `c'
			qui replace sework`v' = _se[female] if cntryid == `c'
		}
		else {
			qui replace bwork`v' = . if cntryid == `c'
			qui replace sework`v' = . if cntryid == `c'
		}
	}
}
	
do "${path_do}/common/GenLabeledCntryID.do"

qui duplicates drop cntryid3letter, force

local rownames ""
foreach j in `cntryid_list' {
	local cntry: label cntryid3letter `j'
	local rownames `rownames' `cntry'
}

foreach v in lit num {
	mkmat bwork`v', matrix(B)
	matrix rownames B = `rownames'
	mkmat sework`v', matrix(SE)

	coefplot matrix(B[.,1]), se(SE[.,1]) omit ///
		xtitle("Gender gap") ///
		xlabel(-0.7(0.1)0.3, glwidth(vthin)) ///
		xline(0, lpattern(solid) lcolor(gs10) lwidth(medthin)) ///
		xlabel(, glwidth(vthin) format(%02.1f)) ///
		xsize(3.8) ysize(4)
}

// Figure 7
use "${path_data}/piaac_main.dta", clear
do "${path_do}/common/InitialSetting.do"

replace d_q05a2 = d_q05A2 if !missing(d_q05A2)
replace d_q05b2 = d_q05B2 if !missing(d_q05B2)
replace tenure = 2012 - d_q05a2 + 3 * round2 if missing(tenure) & selfemp == 0
replace tenure = 2012 - d_q05b2 + 3 * round2 if missing(tenure) & selfemp==1

replace j_q04a = j_q04A if cntryid == 276
gen flag_immigrant = j_q04a == 2 if !missing(j_q04a)
replace flag_immigrant = . if cntryid == 616 // Very small immigrants in Poland data

keep if flag_paper_lit == 0

capture gen cons = 1
local x1 "female"
local x2 "age30_34 age35_39 age40_44 age45_49 age50_54 age55_59 flag_immigrant educ tenure lit worklit"
local K = wordcount("`x1' `x2'") + 1

levelsof cntryid if !missing(lwage) & !missing(tenure) & !missing(flag_immigrant), ///
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
	ytitle("Wage gap: Female vs Male") ylabel(-0.5(0.05)0, format("%03.2f")) ///
	legend(order(1 "Unadjusted" 2 "Adjusted"))

graph hbar DELTA0 DELTA1 DELTA2 DELTA3 DELTA4 DELTA5, ///
	stack over(tmp, label(nolabel) gap(*0.4)) over(cntryid3letter, label(labsize(*0.8)) gap(*0.5)) ///
	ytitle("Gelbach decomposition result") ylabel(-0.08(0.04)0.24, format("%03.2f")) ///
	legend(order(1 "Total: {&beta}{sup:full} - {&beta}{sup:base}" 2 "Demographics" 3 "Education" 4 "Tenure" ///
		5 "Literacy skill" 6 "Literacy use"))
