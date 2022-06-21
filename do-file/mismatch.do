* Open log file
local dofile_name "mismatch"
TakeLog `dofile_name', path("${path_log}")
capture mkdir "${path_table}/csv/`dofile_name'"

* Load data
use "${path_data}", clear
do "${path_do}/common/InitialSetting.do"

qui gen depvar1 = .
qui gen depvar2 = .
qui egen minworklit = min(worklit), by(cntryid)
qui egen minworknum = min(worknum), by(cntryid)

* Main analysis
foreach skill in lit num {
	foreach tag in _paid_year _protect_year {
				
		qui replace depvar1 = work`skill' if work == 1
		qui replace depvar2 = work`skill' if work == 1
		qui replace depvar2 = minwork`skill' if work == 0

		* Full sample
		local model1 "intreg depvar1 depvar2"
		local het1 "het(cfe*, nocons)"
		local cond1 "1 == 1"
		local tag1 ""
		
		* CBA
		local model2 "`model1'"
		local het2 "`het1'"
		local cond2 "flag_paper_`skill' == 0"
		local tag2 "_cba"
		
		forvalues i = 1(1)2 {
			eststo clear
			forvalues j = 1(1)5 {
				local inst "${inst`j'}"
				eststo: `model`i'' ${indepvar} if `cond`i'', vce(cluster cluster_`skill') `het`i''
				qui estadd_spec, spec(`j')
				qui estadd local ncntry = strofreal(e(N_clust) / 4, "%2.0f")
			}
			eststo: reg work`skill' ${indepvar} if `cond`i'' & work == 1, vce(cluster cluster_`skill')
			qui estadd_spec, spec(5)
			qui estadd local ncntry = strofreal(e(N_clust) / 4, "%2.0f")
			
			local coef_lab_lit "Literacy"
			local coef_lab_num "Numeracy"
			local texfile "${path_table}/tex/sub/mismatch_`skill'`tag'`tag`i''_sub.tex"
		
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
					fmt(%1s %1s %1s %1s %1s %3.0f %5.0f)
				)
				mgroups("Full sample" "Employed", pattern(1 0 0 0 0 1)
					span prefix(\multicolumn{@span}{c}{) suffix(}))
				;
			# d cr
			
			clean_subtable "`texfile'", depvar("Dep.var. ${desc_`skill'} skill use") key("Full sample")
		}
	}
}

log close `dofile_name'
