*Open log file
local dofile_name "market_outcomes"
TakeLog `dofile_name', path("${path_log}")
capture mkdir "${path_table}/csv/`dofile_name'"

* Load data
use "${path_data}", clear
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
local coeflabel_num "Numeracy"

local inst "${inst5}"

* Full sample
local cond1 "1 == 1"
local tag1 ""

* CBA
local cond2 "flag_paper_\`skill' == 0"
local tag2 "_cba"

* Employed
local cond3 "work == 1"
local tag3 "_emp"

* CBA and Employed
local cond4 "\`cond2' & `cond3'"
local tag4 "_cba_emp"


// Full sample

foreach skill in lit num {
	foreach tag in _paid_year _protect_year {
		foreach i in 1 2 {
			eststo clear

			* Labor force participation
			eststo: reg work ${indepvar} if `cond`i'', vce(cluster cluster_`skill')
			qui estadd_spec, spec(5)
			qui estadd local ncntry = strofreal(e(N_clust) / 4, "%2.0f")
			qui estadd local emodel = "OLS"
			qui sum `e(depvar)' if e(sample) & !female, meanonly
			qui estadd local meanval = strofreal(r(mean), "%04.2f")
			ExportStat `e(depvar)' if e(sample), stat(mean) format(%03.2f) ///
				saving("${path_draft}/MeanValue/`e(depvar)'_mean_`skill'`tag'`tag`i''")
						
			* Work hours
			eststo workhour: tobit workhour ${indepvar} if `cond`i'', vce(cluster cluster_`skill') ll(0)
			qui estadd_spec, spec(5)
			qui estadd local ncntry = strofreal(e(N_clust) / 4, "%2.0f")
			qui estadd local emodel = "Tobit"
			qui sum `e(depvar)' if e(sample) & !female, meanonly
			qui estadd local meanval = strofreal(r(mean), "%04.2f")
			ExportStat `e(depvar)' if e(sample), stat(mean) format(%3.1f) ///
				saving("${path_draft}/MeanValue/`e(depvar)'_mean_`skill'`tag'`tag`i''")
				
			* Hourly wages 
			eststo lwage: heckman lwage ${indepvar} if flag_heckit & `cond`i'', ///
				select(${indepvar}) vce(cluster cluster_`skill')
			qui estadd_spec, spec(5)
			qui estadd local ncntry = strofreal(e(N_clust) / 4, "%2.0f")
			qui estadd local emodel = "Heckit"
			qui sum `e(depvar)' if e(sample) & !female, meanonly
			qui estadd local meanval = strofreal(r(mean), "%04.2f")
			ExportStat `e(depvar)' if e(sample), stat(mean) format(%03.2f) ///
				saving("${path_draft}/MeanValue/`e(depvar)'_mean_all_`skill'`tag'`tag`i''")
			
			local texfile "${path_table}/tex/sub/marketoutcomes_`skill'`tag'`tag`i''_sub.tex"
			# d;
				esttab using "`texfile'",
				replace se nogap nonotes nomtitles label obslast
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
			
			clean_subtable "`texfile'", depvar("Dep.var.") key("Employment")
			shell "${sed}" -i -e "17,26d" "`texfile'"
		}
	}
}


// Labor market participants

foreach skill in lit num {
	foreach tag in _paid_year _protect_year {
		foreach i in 3 4 {
			eststo clear
			foreach depvar in workhour lwage {				
				eststo `depvar': reg `depvar' ${indepvar} if `cond`i'', vce(cluster cluster_`skill')
				qui estadd_spec, spec(5)
				qui estadd local ncntry = strofreal(e(N_clust) / 4, "%2.0f")
				qui estadd local emodel = "OLS"
				qui sum `e(depvar)' if e(sample) & !female, meanonly
				qui estadd local meanval = strofreal(r(mean), "%04.2f")
				
				ExportStat `depvar' if e(sample), stat(mean) format(%03.2f) ///
					saving("${path_draft}/MeanValue/`e(depvar)'_mean_`skill'`tag'_work`tag`i''")
			}	
			
			local texfile "${path_table}/tex/sub/marketoutcomes_`skill'`tag'`tag`i''_sub.tex"
			# d;
				esttab using "`texfile'",
				replace se nogap nonotes nomtitles label obslast
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
				mgroups("Work hours" "\$\ln(wage)\$",
					pattern(1 1) span prefix(\multicolumn{@span}{c}{) suffix(}))
				;
			# d cr
			
			clean_subtable "`texfile'", depvar("Dep.var.") key("Work hours")
		}
	}
}

log close `dofile_name'
