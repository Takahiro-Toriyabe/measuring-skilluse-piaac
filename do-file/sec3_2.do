// Take log
local dofile_name "sec3_2"
TakeLog `dofile_name', path("${path_log}")

// Figures 9, C1
use "${path_data}/piaac_main.dta", clear
do "${path_do}/common/InitialSetting.do"

keep if work == 1
local ymin_lit = -0.6
local ymax_lit = 0.3
local ymin_num = -0.7
local ymax_num = 0.2

foreach skill in lit num {
	gen b_`skill' = .
	gen n_`skill' = .

	qui levelsof cntryid if flag_paper_`skill' == 0 & !east, local(cntryid_list)
	foreach c in `cntryid_list' {
		forvalues s = 1(1)4 {
			qui reg work`skill' female if cntryid == `c' & `skill'cat == `s' & flag_paper_`skill' == 0 & !east, robust

			qui replace b_`skill' = _b[female] if e(sample)
			qui replace n_`skill' = e(N) if e(sample)
		}
	}
	preserve
		keep if flag_paper_`skill' == 0 & !east
		collapse (mean) b_`skill' n_`skill' tot_paid_year, by(cntryid `skill'cat)

		capture graph drop _all
		forvalues s = 1(1)4 {
			qui twoway (scatter b_`skill' tot_paid_year [aw=n_`skill'], ms(Oh) mc(gs3)) ///
				(lfit b_`skill' tot_paid_year [aw=n_`skill'], lp(l) lc(gs3)) ///
				if `skill'cat == `s', ///
				title("Skill level: Q`s'") ///
				ytitle("Gender gap in skill use (SD)") ylabel(`ymin_`skill''(0.1)`ymax_`skill'', format(%02.1f)) ///
				xtitle("Parental leaves (year)") xlabel(0(0.2)1.4, format(%02.1f)) ///
				legend(off) ///
				name("cat`s'")
		}
		graph combine cat1 cat2 cat3 cat4, col(2) ycommon xcommon iscale(*0.75)
	restore
}

// Tables 3, 4, C2
use "${path_data}/piaac_main.dta", clear
do "${path_do}/common/InitialSetting.do"

qui gen depvar1 = .
qui gen depvar2 = .
qui egen minworklit = min(worklit), by(cntryid)
qui egen minworknum = min(worknum), by(cntryid)

foreach skill in lit num {
	foreach tag in _paid_year _protect_year {
				
		qui replace depvar1 = work`skill' if work == 1
		qui replace depvar2 = work`skill' if work == 1
		qui replace depvar2 = minwork`skill' if work == 0
		
		eststo clear
		forvalues j = 1(1)4 {
			local inst "${inst`j'}"
			eststo: intreg depvar1 depvar2 ${indepvar} if flag_paper_`skill' == 0, vce(cluster cluster_`skill') het(cfe*, nocons)
			qui estadd_spec, spec(`j')
			qui estadd local ncntry = strofreal(e(N_clust) / 4, "%2.0f")
		}
		eststo: reg work`skill' ${indepvar} if flag_paper_`skill' == 0 & work == 1, vce(cluster cluster_`skill')
		qui estadd_spec, spec(4)
		qui estadd local ncntry = strofreal(e(N_clust) / 4, "%2.0f")
		
		local coef_lab_lit "Literacy"
		local coef_lab_num "Numeracy"
	
		# d;
			esttab,
			se nogap nonotes nomtitles label obslast
			b(%9.3f) se(%9.3f) star(* 0.1 ** 0.05 *** 0.01)
			keep(c.`skill'cat1#c.female#c.tot`tag' c.`skill'cat2#c.female#c.tot`tag' c.`skill'cat3#c.female#c.tot`tag' c.`skill'cat4#c.female#c.tot`tag')
			order(c.`skill'cat1#c.female#c.tot`tag' c.`skill'cat2#c.female#c.tot`tag' c.`skill'cat3#c.female#c.tot`tag' c.`skill'cat4#c.female#c.tot`tag')
			coeflabels(
				c.`skill'cat1#c.female#c.tot`tag' "Female\$\times\$PL\$ \times \$`coef_lab_`skill'' skill: Q1"
				c.`skill'cat2#c.female#c.tot`tag' "Female\$\times\$PL\$ \times \$`coef_lab_`skill'' skill: Q2"
				c.`skill'cat3#c.female#c.tot`tag' "Female\$\times\$PL\$ \times \$`coef_lab_`skill'' skill: Q3"
				c.`skill'cat4#c.female#c.tot`tag' "Female\$\times\$PL\$ \times \$`coef_lab_`skill'' skill: Q4"
			)
			stats(spec1 spec2 spec3 spec4 spec5 ncntry N,
				labels(
					"Country\$\times\$Skill quartile FE"
					"Female\$\times\$Skill\$\times\$Industrial structure"
					"Female\$\times\$Skill\$\times\$Family policies"
					"Female\$\times\$Skill\$\times\$Gender norm"
					"Female\$\times\$Skill\$\times\$Market institutions"
					"Countries"
					"Observations"
				)
				fmt(%1s %1s %1s %1s %1s %3.0f %5.0f)
			)
			mgroups("Full sample" "Employed", pattern(1 0 0 0 0 1)
				span prefix(\multicolumn{@span}{c}{) suffix(}))
			;
		# d cr
	}
}

// Table 5
use "${path_data}/piaac_main.dta", clear
do "${path_do}/common/InitialSetting.do"

* Subjective skill-use measure
gen subeduc = yrsget
	// Unit of measure is years

gen subexp1 = .
gen subexp2 = .
gen subexp0 = d_q12c

replace subexp1 = 0 if d_q12c == 1
replace subexp2 = 0 if d_q12c == 1

replace subexp1 = 0 if d_q12c == 2
replace subexp2 = 1 / 12 if d_q12c == 2

replace subexp1 = 1 / 12 if d_q12c == 3
replace subexp2 = 6 / 12 if d_q12c == 3

replace subexp1 = 7 / 12 if d_q12c == 4
replace subexp2 = 11 / 12 if d_q12c == 4

replace subexp1 = 1 if d_q12c == 5
replace subexp2 = 2 if d_q12c == 5

replace subexp1 = 3 if d_q12c == 6
replace subexp2 = . if d_q12c == 6

tabstat subeduc subexp1 subexp2, by(country)
	
foreach c in `cntry_list' {
	qui count if !missing(subeduc) & cntryid == `c'
	if r(N) != 0 {
		replace subeduc = 0 if work == 0 & cntryid == `c'
	}
	qui count if !missing(d_q12c) & cntryid == `c'
	if r(N) != 0 {
		replace subexp0 = 1 if work == 0 & cntryid == `c'
		replace subexp1 = 0 if work == 0 & cntryid == `c'
		replace subexp2 = 0 if work == 0 & cntryid == `c'
	}
}

drop if missing(subexp1) | missing(subeduc)

qui gen depvar1 = .
qui gen depvar2 = .
qui gen Index = .
foreach var in `deplist_lit' {
	qui egen min`var' = min(`var'), by(country)
}
egen minworklit = min(worklit), by(country)

qui egen flag_heckit = mean(lwage), by(country)
qui replace flag_heckit = !missing(flag_heckit)

local coeflabel_lit "Literacy"
local inst "${inst4}"
local skill "lit"
local tag "_paid_year"

eststo clear

// Labor force participation
eststo: reg work ${indepvar} if flag_paper_`skill' == 0, vce(cluster cluster_`skill')
qui estadd_spec, spec(4)
qui estadd local ncntry = strofreal(e(N_clust) / 4, "%2.0f")
qui estadd local emodel = "OLS"
qui sum `e(depvar)' if e(sample) & !female, meanonly
qui estadd local meanval = strofreal(r(mean), "%04.2f")
			
// Work hours
eststo workhour: tobit workhour ${indepvar} if flag_paper_`skill' == 0, vce(cluster cluster_`skill') ll(0)
qui estadd_spec, spec(4)
qui estadd local ncntry = strofreal(e(N_clust) / 4, "%2.0f")
qui estadd local emodel = "Tobit"
qui sum `e(depvar)' if e(sample) & !female, meanonly
qui estadd local meanval = strofreal(r(mean), "%04.2f")
	
// Hourly wages 
eststo lwage: heckman lwage ${indepvar} if flag_heckit & flag_paper_`skill' == 0, ///
	select(${indepvar}) vce(cluster cluster_`skill')
qui estadd_spec, spec(5)
qui estadd local ncntry = strofreal(e(N_clust) / 4, "%2.0f")
qui estadd local emodel = "Heckit"
qui sum `e(depvar)' if e(sample) & !female, meanonly
qui estadd local meanval = strofreal(r(mean), "%04.2f")

# d;
	esttab,
	se nogap nonotes nomtitles label obslast
	b(%9.3f) se(%9.3f) star(* 0.1 ** 0.05 *** 0.01)
	keep(c.`skill'cat1#c.female#c.tot`tag' c.`skill'cat2#c.female#c.tot`tag' c.`skill'cat3#c.female#c.tot`tag' c.`skill'cat4#c.female#c.tot`tag')
	order(c.`skill'cat1#c.female#c.tot`tag' c.`skill'cat2#c.female#c.tot`tag' c.`skill'cat3#c.female#c.tot`tag' c.`skill'cat4#c.female#c.tot`tag')
	coeflabels(
		c.`skill'cat1#c.female#c.tot`tag' "Female\$\times\$PL\$ \times \$`coeflabel_`skill'' skill: Q1"
		c.`skill'cat2#c.female#c.tot`tag' "Female\$\times\$PL\$ \times \$`coeflabel_`skill'' skill: Q2"
		c.`skill'cat3#c.female#c.tot`tag' "Female\$\times\$PL\$ \times \$`coeflabel_`skill'' skill: Q3"
		c.`skill'cat4#c.female#c.tot`tag' "Female\$\times\$PL\$ \times \$`coeflabel_`skill'' skill: Q4"
	)
	stats(meanval emodel spec1 spec2 spec3 spec4 spec5 ncntry N,
		labels(
			"Mean value among men"
			"Method"
			"Country\$\times\$Skill quartile FE"
			"Female\$\times\$Skill\$\times\$Industrial structure"
			"Female\$\times\$Skill\$\times\$Family policies"
			"Female\$\times\$Skill\$\times\$Gender norm"
			"Female\$\times\$Skill\$\times\$Market institutions"
			"Countries"
			"Observations"
		)
		fmt(%1s %1s %1s %1s %1s %1s %1s %3.0f %5.0f)
	)
	mgroups("Employment" "Work hours" "\$\ln(wage)\$",
		pattern(1 1 1) span prefix(\multicolumn{@span}{c}{) suffix(}))
	;
# d cr

// Table C1
duplicates drop cntryid, force
do "${path_do}/common/GenLabeledCntryID.do"
tabstat ntax200 ccutil0_2 equal_right right_parttime gender_role pubsec ind3 emp_protect3 union_density, by(cntryid3letter) format(%04.3f)

// Figure 8
graph hbar tot_paid_year, over(cntryid3letter, sort(tot_paid_year) reverse) ylabel(0(0.5)3.5) ytitle("Duration")
graph hbar tot_protect_year, over(cntryid3letter, sort(tot_protect_year) reverse) ylabel(0(0.5)3.5) ytitle("Duration")

// Table C3
use "${path_data}/piaac_main.dta", clear
do "${path_do}/common/InitialSetting.do"

local depvars "irt_learning irt_influence irt_workwrite worknum"
foreach depvar in `depvars' {
	drop if missing(`depvar') & work == 1
	replace `depvar' = . if work == 0
	Normalize `depvar', by(cntryid)
}

local skill "lit"
local tag "_paid_year"
local inst "${inst4}"

eststo clear
foreach depvar in `depvars' {
	tempvar depvar1 depvar2 min
	qui gen `depvar1' = `depvar' if work == 1
	qui gen `depvar2' = `depvar' if work == 1
	qui egen `min' = min(`depvar'), by(cntryid)
	qui replace `depvar2' = `min' if work == 0

	eststo: intreg `depvar1' `depvar2' ${indepvar} if flag_paper_`skill' == 0, vce(cluster cluster_`skill') het(cfe*, nocons)
	qui estadd_spec, spec(4)
	qui estadd local ncntry = strofreal(e(N_clust) / 4, "%2.0f")
}

# d;
	esttab,
	se nogap nonotes nomtitles label obslast
	b(%9.3f) se(%9.3f) star(* 0.1 ** 0.05 *** 0.01)
	keep(c.`skill'cat1#c.female#c.tot`tag' c.`skill'cat2#c.female#c.tot`tag' c.`skill'cat3#c.female#c.tot`tag' c.`skill'cat4#c.female#c.tot`tag')
	order(c.`skill'cat1#c.female#c.tot`tag' c.`skill'cat2#c.female#c.tot`tag' c.`skill'cat3#c.female#c.tot`tag' c.`skill'cat4#c.female#c.tot`tag')
	coeflabels(
		c.`skill'cat1#c.female#c.tot`tag' "Female\$\times\$PL\$ \times \$`coef_lab_`skill'' skill: Q1"
		c.`skill'cat2#c.female#c.tot`tag' "Female\$\times\$PL\$ \times \$`coef_lab_`skill'' skill: Q2"
		c.`skill'cat3#c.female#c.tot`tag' "Female\$\times\$PL\$ \times \$`coef_lab_`skill'' skill: Q3"
		c.`skill'cat4#c.female#c.tot`tag' "Female\$\times\$PL\$ \times \$`coef_lab_`skill'' skill: Q4"
	)
	stats(spec1 spec2 spec3 spec4 spec5 ncntry N,
		labels(
			"Country\$\times\$Skill quartile FE"
			"Female\$\times\$Skill\$\times\$Industrial structure"
			"Female\$\times\$Skill\$\times\$Family policies"
			"Female\$\times\$Skill\$\times\$Gender norm"
			"Female\$\times\$Skill\$\times\$Market institutions"
			"Countries"
			"Observations"
		)
		fmt(%1s %1s %1s %1s %3.0f %5.0f)
	)
	mgroups("Learning" "Influence" "Writing" "Numeracy", pattern(1 1 1 1)
		span prefix(\multicolumn{@span}{c}{) suffix(}))
	;
# d cr

// Table C4
use "${path_data}/piaac_main.dta", clear
do "${path_do}/common/InitialSetting.do"

qui gen depvar1 = .
qui gen depvar2 = .
qui egen minworklit = min(worklit), by(cntryid)
qui egen minworknum = min(worknum), by(cntryid)

foreach var in lit num {
	foreach p in 20 40 60 80 {
		egen `var'`p' = pctile(`var'), p(`p') by(flag_paper_`var' country)
	}
	
	capture drop `var'cat
	gen `var'cat = 1 if `var' <= `var'20 & !missing(`var')
	replace `var'cat = 2 if inrange(`var', `var'20, `var'40) & !missing(`var')
	replace `var'cat = 3 if inrange(`var', `var'40, `var'60) & !missing(`var')
	replace `var'cat = 4 if inrange(`var', `var'60, `var'80) & !missing(`var')
	replace `var'cat = 5 if `var' >= `var'80 & !missing(`var')
	
	capture drop `var'cat?
	tab `var'cat, gen(`var'cat)
}
capture drop cluster_lit cluster_num
egen cluster_lit = group(country litcat) 
egen cluster_num = group(country numcat) 

local indepvar = "c.(\`skill'cat1 \`skill'cat2 \`skill'cat3 \`skill'cat4 \`skill'cat5)#c.female#c.tot\`tag'" ///
	+ " c.(\`skill'cat1 \`skill'cat2 \`skill'cat3 \`skill'cat4 \`skill'cat5)#c.female" ///
	+ " c.(\`skill'cat1 \`skill'cat2 \`skill'cat3 \`skill'cat4 \`skill'cat5)#c.female#c.(\`inst')" ///
	+ " c.(\`skill'cat1 \`skill'cat2 \`skill'cat3 \`skill'cat4 \`skill'cat5)#c.(${xvars})" ///
	+ " i.flag_paper_\`skill'#i.country#c.(\`skill'cat1 \`skill'cat2 \`skill'cat3 \`skill'cat4 \`skill'cat5)"

local skill "lit"
local tag "_paid_year"
				
qui replace depvar1 = work`skill' if work == 1
qui replace depvar2 = work`skill' if work == 1
qui replace depvar2 = minwork`skill' if work == 0

eststo clear
forvalues j = 1(1)4 {
	local inst "${inst`j'}"
	eststo: intreg depvar1 depvar2 `indepvar' if flag_paper_`skill' == 0, vce(cluster cluster_`skill') het(cfe*, nocons)
	qui estadd_spec, spec(`j')
	qui estadd local ncntry = strofreal(e(N_clust) / 4, "%2.0f")
}
eststo: reg work`skill' `indepvar' if flag_paper_`skill' == 0 & work == 1, vce(cluster cluster_`skill')
qui estadd_spec, spec(4)
qui estadd local ncntry = strofreal(e(N_clust) / 5, "%2.0f")

local coef_lab_lit "Literacy"
# d;
	esttab,
	se nogap nonotes nomtitles label obslast
	b(%9.3f) se(%9.3f) star(* 0.1 ** 0.05 *** 0.01)
	keep(c.`skill'cat1#c.female#c.tot`tag' c.`skill'cat2#c.female#c.tot`tag' c.`skill'cat3#c.female#c.tot`tag' c.`skill'cat4#c.female#c.tot`tag' c.`skill'cat5#c.female#c.tot`tag')
	order(c.`skill'cat1#c.female#c.tot`tag' c.`skill'cat2#c.female#c.tot`tag' c.`skill'cat3#c.female#c.tot`tag' c.`skill'cat4#c.female#c.tot`tag' c.`skill'cat5#c.female#c.tot`tag')
	coeflabels(
		c.`skill'cat1#c.female#c.tot`tag' "Female\$\times\$PL\$ \times \$`coef_lab_`skill'' skill: Q1"
		c.`skill'cat2#c.female#c.tot`tag' "Female\$\times\$PL\$ \times \$`coef_lab_`skill'' skill: Q2"
		c.`skill'cat3#c.female#c.tot`tag' "Female\$\times\$PL\$ \times \$`coef_lab_`skill'' skill: Q3"
		c.`skill'cat4#c.female#c.tot`tag' "Female\$\times\$PL\$ \times \$`coef_lab_`skill'' skill: Q4"
		c.`skill'cat5#c.female#c.tot`tag' "Female\$\times\$PL\$ \times \$`coef_lab_`skill'' skill: Q5"
	)
	stats(spec1 spec2 spec3 spec4 spec5 ncntry N,
		labels(
			"Country\$\times\$Skill quartile FE"
			"Female\$\times\$Skill\$\times\$Industrial structure"
			"Female\$\times\$Skill\$\times\$Family policies"
			"Female\$\times\$Skill\$\times\$Gender norm"
			"Female\$\times\$Skill\$\times\$Market institutions"
			"Countries"
			"Observations"
		)
		fmt(%1s %1s %1s %1s %1s %3.0f %5.0f)
	)
	mgroups("Full sample" "Employed", pattern(1 0 0 0 0 1)
		span prefix(\multicolumn{@span}{c}{) suffix(}))
	;
# d cr


log close `dofile_name'
