* Open log file
local dofile_name "other_skilluse"
TakeLog `dofile_name', path("${path_log}")
capture mkdir "${path_table}/csv/`dofile_name'"

* Load data
use "${path_data}", clear
do "${path_do}/common/InitialSetting.do"

local depvars "irt_learning irt_influence irt_workwrite worknum worklit"
foreach depvar in `depvars' {
	drop if missing(`depvar') & work == 1
	replace `depvar' = . if work == 0
	Normalize `depvar', by(cntryid)
}

* Full sample
local model1 "intreg \`depvar1' \`depvar2' \${indepvar}"
local het1 "het(cfe*, nocons)"
local cond1 "1 == 1"
local tag1 ""

* CBA
local model2 "\`model1'"
local het2 "`het1'"
local cond2 "flag_paper_\`skill' == 0"
local tag2 "_cba"

local coef_lab_lit "Literacy"
local coef_lab_num "Numeracy"
local inst "${inst5}"

foreach skill in lit num {
	foreach tag in _paid_year _protect_year {
		forvalues i = 1(1)2 {
			eststo clear
			foreach depvar in `depvars' {
				if "`depvar'" != "work`skill'" {
					tempvar depvar1 depvar2 min
					qui gen `depvar1' = `depvar' if work == 1
					qui gen `depvar2' = `depvar' if work == 1
					qui egen `min' = min(`depvar'), by(cntryid)
					qui replace `depvar2' = `min' if work == 0

					eststo: `model`i'' if `cond`i'', vce(cluster cluster_`skill') `het`i''
					qui estadd_spec, spec(5)
					qui estadd local ncntry = strofreal(e(N_clust) / 4, "%2.0f")
				}
			}
		
			local desc_use = "Numeracy" * ("`skill'" == "lit") + "Literacy" * ("`skill'" == "num")
			local texfile "${path_table}/tex/sub/other_skilluse_`skill'`tag'`tag`i''_sub.tex"
			# d;
				esttab using "`texfile'",
				replace se nogap nonotes nomtitles label obslast
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
				mgroups("Learning" "Influence" "Writing" "`desc_use'", pattern(1 1 1 1)
					span prefix(\multicolumn{@span}{c}{) suffix(}))
				;
			# d cr
		
			clean_subtable "`texfile'", depvar("Dep.var.") key("Writing")
		}
	}
}

log close `dofile_name'
