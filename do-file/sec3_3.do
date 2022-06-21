// Figure 10
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
local x1 "flag_immigrant"
local x2 "age30_34 age35_39 age40_44 age45_49 age50_54 age55_59 female educ tenure lit worklit"
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
	ytitle("Wage gap: Immigrants vs Non-immigrants") ylabel(-0.5(0.1)0.4, format("%03.2f")) ///
	legend(order(1 "Unadjusted" 2 "Adjusted"))

graph hbar DELTA0 DELTA1 DELTA2 DELTA3 DELTA4 DELTA5, ///
	stack over(tmp, label(nolabel) gap(*0.4)) over(cntryid3letter, label(labsize(*0.8)) gap(*0.5)) ///
	ytitle("Gelbach decomposition result") ylabel(-0.15(0.05)0.35, format("%03.2f")) ///
	legend(order(1 "Total: {&beta}{sup:full} - {&beta}{sup:base}" 2 "Demographics" 3 "Education" 4 "Tenure" ///
		5 "Literacy skill" 6 "Literacy use"))

// Figure 11
use "${path_data}/piaac_main.dta", clear
do "${path_do}/common/InitialSetting.do"

replace d_q05a2 = d_q05A2 if !missing(d_q05A2)
replace d_q05b2 = d_q05B2 if !missing(d_q05B2)
replace tenure = 2012 - d_q05a2 + 3 * round2 if missing(tenure) & selfemp == 0
replace tenure = 2012 - d_q05b2 + 3 * round2 if missing(tenure) & selfemp==1

replace j_q04a = j_q04A if cntryid == 276
gen flag_immigrant = j_q04a == 2 if !missing(j_q04a)
replace flag_immigrant = . if cntryid == 616 // Very small immigrants in Poland data

gen svy_year = 2012 + round2 * 3
replace j_q04c2  = j_q04c2_t if cntryid == 233
replace j_q04c2  = j_q04C2 if cntryid == 276
gen yrs_immigrate = svy_year - j_q04c2 if flag_immigrant == 1
replace yrs_immigrate = . if yrs_immigrate < 0
replace yrs_immigrate = min(yrs_immigrate, 40) if !missing(yrs_immigrate)
egen cat_yrs_immigrate = cut(yrs_immigrate), at(0(5)45)
tab cat_yrs_immigrate
replace cat_yrs_immigrate = 100 if flag_immigrant == 0
tab cat_yrs_immigrate, gen(x1_)

keep if flag_paper_lit == 0 & !missing(lit) & !missing(worklit) & !missing(lwage) ///
	& !missing(tenure) & !missing(cat_yrs_immigrate)

tab cntryid, gen(c_)
qui levelsof cntryid, local(clist)
local nc = wordcount("`clist'")

capture gen cons = 1
local x1 "x1_1 x1_2 x1_3 x1_4 x1_5 x1_6 x1_7 x1_8 x1_9"
local x2_1 "age30_34 age35_39 age40_44 age45_49 age50_54 age55_59 female"
local x2_2 "educ"
local x2_3 "tenure"
local x2_4 "lit"
local x2_5 "worklit"
local x2_base "`x2_1' `x2_2' `x2_3' `x2_4' `x2_5'"

forvalues c = 1(1)`nc' {
	local x1 "`x1' c_`c'"
}

local x2 ""
forvalues k = 1(1)5 {
	local cnt = 1
	foreach var in `x2_`k'' {
		forvalues c = 1(1)`nc' {
			capture gen x2_`k'_`cnt'_`c' = `var' * c_`c'
			local x2 "`x2' x2_`k'_`cnt'_`c'"
		}
		local cnt = `cnt' + 1
	}
}

keep lwage x1_? c_1-c_`nc' x2_?_?_* cluster_lit `x2_base'
order lwage x1_? c_1-c_`nc' x2_?_?_* cluster_lit `x2_base'

qui reg lwage `x1' `x2', nocons cluster(cluster_lit)
matrix BFULL = e(b)
forvalues j = 1(1)5 {
	local nv = wordcount("`x2_`j''")
	matrix BX2_`j' = BFULL["y1", "x2_`j'_1_1".."x2_`j'_`nv'_`nc'"]
}
matrix BX1FULL = BFULL["y1", "x1_1".."c_`nc'"]

matrix VX1FULL = e(V)
matrix VX1FULL = vecdiag(VX1FULL["x1_1".."x1_9", "x1_1".."x1_9"])'

qui reg lwage `x1', nocons cluster(cluster_lit)
matrix BX1SUB = e(b)
matrix VX1SUB = e(V)
matrix VX1SUB = vecdiag(VX1SUB["x1_1".."x1_9", "x1_1".."x1_9"])'

mata
	BX1FULL = st_matrix("BX1FULL")
	BX1SUB = st_matrix("BX1SUB")

	BX2_1 = st_matrix("BX2_1")
	BX2_2 = st_matrix("BX2_2")
	BX2_3 = st_matrix("BX2_3")
	BX2_4 = st_matrix("BX2_4")
	BX2_5 = st_matrix("BX2_5")

	X1 = st_data(., (2..30))
	X2_1 = st_data(., (31..170))
	X2_2 = st_data(., (171..190))
	X2_3 = st_data(., (191..210))
	X2_4 = st_data(., (211..230))
	X2_5 = st_data(., (231..250))
	
	invX1X1 = -1 * invsym(cross(X1, X1))
	DELTA1 = invX1X1 * cross(X1, X2_1) * BX2_1'
	DELTA2 = invX1X1 * cross(X1, X2_2) * BX2_2'
	DELTA3 = invX1X1 * cross(X1, X2_3) * BX2_3'
	DELTA4 = invX1X1 * cross(X1, X2_4) * BX2_4'
	DELTA5 = invX1X1 * cross(X1, X2_5) * BX2_5'
	DELTA = DELTA1, DELTA2, DELTA3, DELTA4, DELTA5
	DELTA
	CHECK = DELTA1 + DELTA2 + DELTA3 + DELTA4 + DELTA5 - (BX1FULL - BX1SUB)'
	CHECK
	
	st_matrix("DELTA", DELTA)
end mata

matrix BX1FULL = BX1FULL[1, 1..9]'
matrix BX1SUB = BX1SUB[1, 1..9]'
matrix DELTA = DELTA[1..9,.]

clear
svmat BX1FULL
svmat VX1FULL

svmat BX1SUB
svmat VX1SUB

foreach spec in FULL SUB {
	gen b_u`spec' = BX1`spec' + invnormal(0.975) * sqrt(VX1`spec')
	gen b_l`spec' = BX1`spec' - invnormal(0.975) * sqrt(VX1`spec')
}

svmat DELTA
gen x = _n
gen x1 = x + 0.2
gen x2 = x - 0.2

capture label drop x
label define x 1 "0-4" 2 "5-9" 3 "10-14" 4 "15-19" 5 "20-24" 6 "25-29" 7 "30-34" 8 "35-39" 9 "40+"
label values x x

expand 2, gen(tmp)
gen DELTA0 = BX1FULL - BX1SUB if tmp == 0
forvalues j = 1(1)5 {
	replace DELTA`j' = . if tmp == 0
}

twoway (scatter BX1SUB x2, sort color(sky)) ///
	(rcap b_uSUB b_lSUB x2, sort color(sky) msize(*0)) ///
	(scatter BX1FULL x1, sort color(reddish)) ///
	(rcap b_uFULL b_lFULL x1, sort color(reddish) msize(*0)) ///
	if tmp == 0, ///
	ytitle("Wage gap") ylabel(-0.3(0.05)0.15, format("%04.3f")) yline(0, lp(l) lc(gs10)) ///
	xtitle("Years since immigration") xlabel(1 "0-4" 2 "5-9" 3 "10-14" 4 "15-19" ///
		5 "20-24" 6 "25-29" 7 "30-34" 8 "35-39" 9 "40+") ///
	legend(order(1 "Unadjusted" 3 "Adjusted"))

graph bar DELTA0 DELTA1 DELTA2 DELTA3 DELTA4 DELTA5, ///
	stack over(tmp, label(nolabel) gap(*0.4)) over(x, label(labsize(*0.8)) gap(*0.5)) ///
	ytitle("Gelbach decomposition result") ylabel(-0.1(0.025)0.15, format("%04.3f")) ///
	b1title("Number of years since immigration") ///
	legend(order(1 "Total: {&beta}{sup:full} - {&beta}{sup:base}" 2 "Demographics" ///
		3 "Education" 4 "Tenure" 5 "Literacy skill" 6 "Literacy use"))
