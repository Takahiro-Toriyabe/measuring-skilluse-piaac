* Open log file
local dofile_name "support_stat_dscrmnt"
TakeLog `dofile_name', path("${path_log}")
capture mkdir "${path_table}/csv/`dofile_name'"

* Load data
use "${path_data}", clear
do "${path_do}/common/InitialSetting.do"

keep if work == 1

qui gen depvar1 = .
qui gen depvar2 = .
qui egen minworklit = min(worklit), by(cntryid)
qui egen minworknum = min(worknum), by(cntryid)

gen manager = isco1c == 1 if !missing(isco1c)
gen prof = isco1c == 2 if !missing(isco1c)

tempvar flag_missing flag_small2 flag_small4

gen occup2digit = isco2c if isco2c < 9996
egen `flag_small2' = sum(1), by(occup2digit)
replace occup2digit = 10001 if `flag_small2' < 50

egen `flag_missing' = mean(isco08_c), by(cntryid)
replace `flag_missing' = inrange(`flag_missing', 9996, 9999)

replace occup2digit = 10000 ///
	if inlist(occup2digit, 9996, 9997, 9998, 9999, .) & !`flag_missing'
replace occup2digit = . if `flag_missing'

gen occup4digit = isco08_c if isco08_c < 9996
egen `flag_small4' = sum(1), by(occup4digit)
replace occup4digit = 10001 if `flag_small4' < 50

replace occup4digit = 10000 ///
	if inlist(occup4digit, 9996, 9997, 9998, 9999, .) & !`flag_missing'
replace occup4digit = . if `flag_missing'


// Analysis controlling for occupation

local coeflabel_lit "Literacy"
local coeflabel_num "Numeracy"

local inst "${inst5}"

local cond1 "1 == 1"
local tag1 "_emp"

local cond2 "flag_paper_\`skill' == 0"
local tag2 "_cba_emp"


// Number of subordinates

do "${path_do}/common/GenManageVar.do"

capture drop flag_manage
gen flag_manage = 1 - manage0

capture drop num_manage?
local ceil = 4
forvalues j = 1(1)`ceil' {
	qui gen num_manage`j' = d_q08b == `j' if !missing(d_q08b)
	qui replace num_manage`j' = 0 if flag_manage == 0
}
qui replace num_manage`ceil' = 1 if inrange(d_q08b, `ceil', 5)
gen num_manage0 = flag_manage == 0 if !missing(flag_manage)

// gen num_manage0_cum = 1 - flag_manage
// forvalues j = 1(1)`ceil' {
// 	gen num_manage`j'_cum = num_manage`=`j'-1'_cum + num_manage`j'
// }

local coef_lab_lit "Literacy"
local coef_lab_num "Numeracy"
foreach skill in lit num {
	foreach tag in _paid_year _protect_year {
		forvalues j = 1(1)4 {
			capture drop d`j'
			qui gen d`j' = `skill'cat`j' * female * tot`tag'
		}

		foreach var of varlist d1 d2 d3 d4 num_manage0 num_manage1 ///
				num_manage2 num_manage3 num_manage4 {
			qui reg `var' ///
				c.(`skill'cat?)#c.(${xvars} female c.female#c.(${inst5})) ///
				i.country#c.(`skill'cat?) ///
				if work & !flag_paper_`skill' & !selfemp, ///
				vce(cluster cluster_`skill')

			capture drop u_`var'
			qui predict u_`var' if e(sample), residual
		}
		
		forvalues s = 1(1)4 {
			label variable u_d`s' "Female\$\times\$PL\$ \times \$`coef_lab_`skill'' skill: Q`s'"
		}
	
		eststo clear
		qui eststo: gmm (eq0: u_num_manage0 - {xb0: u_d1 u_d2 u_d3 u_d4}) ///
			(eq1: u_num_manage1 - {xb1: u_d1 u_d2 u_d3 u_d4}) ///
			(eq2: u_num_manage2 - {xb2: u_d1 u_d2 u_d3 u_d4}) ///
			(eq3: u_num_manage3 - {xb3: u_d1 u_d2 u_d3 u_d4}) ///
			(eq4: u_num_manage4 - {xb4: u_d1 u_d2 u_d3 u_d4}), ///
			vce(cluster cluster_`skill') variables(u_d?) ///
			instruments(eq0: u_d1 u_d2 u_d3 u_d4, noconstant) ///
			instruments(eq1: u_d1 u_d2 u_d3 u_d4, noconstant) ///
			instruments(eq2: u_d1 u_d2 u_d3 u_d4, noconstant) ///
			instruments(eq3: u_d1 u_d2 u_d3 u_d4, noconstant) ///
			instruments(eq4: u_d1 u_d2 u_d3 u_d4, noconstant) ///
			derivative(eq0/xb0 = -1) ///
			derivative(eq1/xb1 = -1) ///
			derivative(eq2/xb2 = -1) ///
			derivative(eq3/xb3 = -1) ///
			derivative(eq4/xb4 = -1) ///
			winitial(identity) onestep

		esttab using "${path_table}/tex/sub/justify_statdiscr_`skill'`tag'_sub.tex", ///
			replace se nogap nonotes nomtitles label obslast ///
			b(%9.3f) se(%9.3f) star(* 0.1 ** 0.05 *** 0.01) ///
			keep(u_d?) ///
			unstack
	}
}

preserve
	keep if work == 1
	drop if missing(num_manage0) | missing(num_manage1) | missing(num_manage2) ///
		| missing(num_manage3) | missing(num_manage4)

	do "${path_do}/common/GenLabeledCntryID.do"
	collapse (mean) num_manage? tot_paid_year if !female, by(cntryid3letter)
	
	reshape long num_manage@, i(cntryid3letter) j(x)
	
	graph hbar (mean) num_manage, ///
		over(x, relabel(1 "0" 2 "1-5" 3 "6-10" 4 "11-24" 5 "25+")) ///
		over(cntryid3letter) stack asyvar ///
		ytitle("Fraction") ylabel(0(0.1)1, format(%02.1f))

	graph export "${path_figure}/pdf/num_manage_desc.pdf", replace
	
	graph hbar (mean) num_manage, ///
		over(x, relabel(1 "0" 2 "1-5" 3 "6-10" 4 "11-24" 5 "25+")) ///
		over(cntryid3letter, sort(tot_paid_year)) stack asyvar ///
		ytitle("Fraction") ylabel(0(0.1)1, format(%02.1f))

	graph export "${path_figure}/pdf/num_manage_desc_sortPL.pdf", replace
restore
/*
// Training
forvalues j = 1(1)5 {
	capture drop nfe12jr`j'
	gen nfe12jr`j' = 0 if nfe12jr == 0
	replace nfe12jr`j' = b_q16 == `j' if nfe12jr == 1 & !missing(b_q16)
}

capture drop nfe12jr_cost
gen nfe12jr_cost = 0 if nfe12jr == 0
replace nfe12jr_cost = inlist(b_q16, 1, 2) if nfe12jr == 1

capture drop nfe12jr_nocost
gen nfe12jr_nocost = nfe12jr & (1 - nfe12jr_cost)

capture drop flag_ojt
gen flag_ojt = 0 if nfe12 == 0
replace flag_ojt = inlist(1, b_q12c, b_q12C) if missing(flag_ojt) & (!missing(b_q12c) | !missing(b_q12c))
replace flag_ojt = b_q13 == 2 if missing(flag_ojt) & !missing(b_q13)

local inst ${inst5}
foreach skill in lit num {
	foreach tag in _paid_year _protect_year {
		eststo clear

		foreach depvar of varlist faet12jr nfe12jr nfe12jr1-nfe12jr4 flag_ojt {
			qui eststo: reg `depvar' ${indepvar} ///
				if work & !selfemp & !flag_paper_lit & !nfe12jr5 ///
				& !missing(faet12jr) & !missing(nfe12jr1) & !missing(flag_ojt), ///
				cluster(cluster_lit)
		}
		esttab , ${esttab_opt} se star(* 0.1 ** 0.05 *** 0.001) ///
			keep(c.`skill'cat?#c.female#c.tot`tag') title("`skill' & tot`tag'")

	}
}
*/

log close `dofile_name'
