* Open log file
local dofile_name "check_human_capital_depreciation"
TakeLog `dofile_name', path("${path_log}")
capture mkdir "${path_table}/csv/`dofile_name'"

* Load data
use "${path_data}", clear
do "${path_do}/common/InitialSetting.do"

gen leave_year = age - (5 + yrsqual + c_q09)

* Tenure
replace d_q05a2 = d_q05A2 if !missing(d_q05A2)
replace d_q05b2 = d_q05B2 if !missing(d_q05B2)
replace tenure = 2012 - d_q05a2 + 3 * round2 if missing(tenure) & selfemp == 0
replace tenure = 2012 - d_q05b2 + 3 * round2 if missing(tenure) & selfemp==1

levelsof cntryid, local(cntry_list)
foreach c in `cntry_list' {
	qui count if !missing(tenure) & cntryid == `c'
	if r(N) != 0 {
		replace tenure = 0 if work == 0 & cntryid == `c'
	}
}

* Main analysis

qui gen depvar1 = .
qui gen depvar2 = .
qui egen minworklit = min(worklit), by(country)
qui egen minworknum = min(worknum), by(country)

* Main analysis
local inst "${inst5}"

* Full sample
local cond1 "1 == 1"
local tag1 ""

* CBA
local cond2 "flag_paper_\`skill' == 0"
local tag2 "_cba"

local coeflabel_lit "Literacy"
local coeflabel_num "Numeracy"

foreach skill in lit num {
	foreach tag in _paid_year _protect_year {
		foreach i in 1 2 {
			qui replace depvar1 = work`skill' if work == 1
			qui replace depvar2 = work`skill' if work == 1
			qui replace depvar2 = minwork`skill' if work == 0

			eststo clear
			
			eststo: intreg depvar1 depvar2 ${indepvar} if !missing(leave_year) & `cond`i'', ///
				vce(cluster cluster_`skill') het(cfe*, nocons)
			qui estadd_spec, spec(5)
			qui estadd local ncntry = strofreal(e(N_clust) / 4, "%2.0f")
				
			eststo: intreg depvar1 depvar2 ${indepvar} ///
				c.(`skill'cat1 `skill'cat2 `skill'cat3 `skill'cat4)#c.female#c.leave_year ///
				c.(`skill'cat1 `skill'cat2 `skill'cat3 `skill'cat4)#c.leave_year if `cond`i'', ///
				vce(cluster cluster_`skill') het(cfe*, nocons)
			qui estadd_spec, spec(5)
			qui estadd local ncntry = strofreal(e(N_clust) / 4, "%2.0f")
				
			eststo: reg work`skill' ${indepvar} if !missing(leave_year) & work == 1 & `cond`i'', ///
				vce(cluster cluster_`skill')
			qui estadd_spec, spec(5)
			qui estadd local ncntry = strofreal(e(N_clust) / 4, "%2.0f")
				
			eststo: reg work`skill' ${indepvar} ///
				c.(`skill'cat1 `skill'cat2 `skill'cat3 `skill'cat4)#c.female#c.leave_year ///
				c.(`skill'cat1 `skill'cat2 `skill'cat3 `skill'cat4)#c.leave_year if work == 1 & `cond`i'', ///
				vce(cluster cluster_`skill')
			qui estadd_spec, spec(5)
			qui estadd local ncntry = strofreal(e(N_clust) / 4, "%2.0f")
			
			local texfile "${path_table}/tex/sub/estrobust_tenure_`skill'`tag'`tag`i''_sub.tex"
			# d;
				esttab using "`texfile'",
				replace se nogap nonotes nomtitles label obslast
				b(%9.3f) se(%9.3f) star(* 0.1 ** 0.05 *** 0.01)
				keep(
					c.`skill'cat1#c.female#c.tot`tag' c.`skill'cat2#c.female#c.tot`tag' c.`skill'cat3#c.female#c.tot`tag' c.`skill'cat4#c.female#c.tot`tag'
					c.`skill'cat1#c.leave_year c.`skill'cat2#c.leave_year c.`skill'cat3#c.leave_year c.`skill'cat4#c.leave_year
					c.`skill'cat1#c.female#c.leave_year c.`skill'cat2#c.female#c.leave_year c.`skill'cat3#c.female#c.leave_year c.`skill'cat4#c.female#c.leave_year
				)
				order(
					c.`skill'cat1#c.female#c.tot`tag' c.`skill'cat2#c.female#c.tot`tag' c.`skill'cat3#c.female#c.tot`tag' c.`skill'cat4#c.female#c.tot`tag'
					c.`skill'cat1#c.leave_year c.`skill'cat2#c.leave_year c.`skill'cat3#c.leave_year c.`skill'cat4#c.leave_year
					c.`skill'cat1#c.female#c.leave_year c.`skill'cat2#c.female#c.leave_year c.`skill'cat3#c.female#c.leave_year c.`skill'cat4#c.female#c.leave_year
					c.`skill'cat1#c.female#c.leave_year c.`skill'cat2#c.female#c.leave_year c.`skill'cat3#c.female#c.leave_year c.`skill'cat4#c.female#c.leave_year
				)
				coeflabels(
					c.`skill'cat1#c.female#c.tot`tag' "Female\$\times\$PL\$\times\$`coeflabel_`skill'' skill: Q1" 
					c.`skill'cat2#c.female#c.tot`tag' "Female\$\times\$PL\$\times\$`coeflabel_`skill'' skill: Q2"
					c.`skill'cat3#c.female#c.tot`tag' "Female\$\times\$PL\$\times\$`coeflabel_`skill'' skill: Q3" 
					c.`skill'cat4#c.female#c.tot`tag' "Female\$\times\$PL\$\times\$`coeflabel_`skill'' skill: Q4"
					c.`skill'cat1#c.leave_year "\hphantom{Female\$ \times \$}AL\$\times \$`coeflabel_`skill'' skill: Q1" 
					c.`skill'cat2#c.leave_year "\hphantom{Female\$ \times \$}AL\$\times \$`coeflabel_`skill'' skill: Q2"
					c.`skill'cat3#c.leave_year "\hphantom{Female\$ \times \$}AL\$\times \$`coeflabel_`skill'' skill: Q3" 
					c.`skill'cat4#c.leave_year "\hphantom{Female\$ \times \$}AL\$\times \$`coeflabel_`skill'' skill: Q4"
					c.`skill'cat1#c.female#c.leave_year "Female\$\times\$AL\$\times\$`coeflabel_`skill'' skill: Q1" 
					c.`skill'cat2#c.female#c.leave_year "Female\$\times\$AL\$\times\$`coeflabel_`skill'' skill: Q2"
					c.`skill'cat3#c.female#c.leave_year "Female\$\times\$AL\$\times\$`coeflabel_`skill'' skill: Q3" 
					c.`skill'cat4#c.female#c.leave_year "Female\$\times\$AL\$\times\$`coeflabel_`skill'' skill: Q4"
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
				mgroups("Full sample" "Employed",
					pattern(1 0 1 0) span prefix(\multicolumn{@span}{c}{) suffix(}))
				;
			# d cr
			clean_subtable "`texfile'", depvar("Dep.var. ${desc_`skill'} skill use") key("Full sample")
		}
	}
}

log close `dofile_name'

