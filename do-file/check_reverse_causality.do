* Open log file
local dofile_name "check_reverse_causality"
TakeLog `dofile_name', path("${path_log}")
capture mkdir "${path_table}/csv/`dofile_name'"

* Load data
use "${path_data}", clear
do "${path_do}/common/InitialSetting.do"

qui gen depvar1 = .
qui gen depvar2 = .
qui gen Index = .
qui egen minworklit = min(worklit), by(country)
qui egen minworknum = min(worknum), by(country)

foreach t in 2011 2001 1991 1981 1971 {
	gen mlv_year`t' = mlv_week`t' / 52
}

local coeflabel_lit "Literacy"
local coeflabel_num "Numeracy"

tabstat tot_paid_year mlv_year2011 if !missing(mlv_year2011), by(country)

preserve
	keep if (inlist(.,ccutil0_2,ntax200,gender_role,pubsec,ind3,emp_protect3,union_density)==0)
	duplicates drop country, force
	corr tot_paid_year gender_role
	
	tempname hh
	file open `hh' using "${path_draft}/MeanValue/corr_plv_norm.tex", write replace
	file write `hh' %03.2f (r(rho)) "%"
	file close `hh'
restore

* Main analysis
local tag "_tmp"
local inst "${inst5}"

* Full sample
local model1 "intreg depvar1 depvar2"
local het1 "het(cfe*, nocons)"
local cond1 "1 == 1"
local tag1 ""

* CBA
local model2 "`model1'"
local het2 "`het1'"
local cond2 "flag_paper_\`skill' == 0"
local tag2 "_cba"

* Employed
local model3 "reg work\`skill'"
local het3 ""
local cond3 "work == 1"
local tag3 "_emp"

* CBA and Employed
local model4 "reg work\`skill'"
local het4 ""
local cond4 "\`cond2' & `cond3'"
local tag4 "_cba_emp"

* Finland and Norway
local cond_excl0 "1 == 1"
local tag_excl0 ""
local panel0 "Panel A: All available countries"

local cond_excl1 "!inlist(cntryid, 246, 578)"
local tag_excl1 "_exclFIN_NOR"
local panel1 "Panel B: Exclude Finland and Norway"
		
foreach skill in lit num {
	forvalues i = 1(1)4 {
		foreach j in 0 1 {
			qui replace depvar1 = work`skill' if work == 1
			qui replace depvar2 = work`skill' if work == 1
			qui replace depvar2 = minwork`skill' if work == 0

			capture drop tot_tmp
			gen tot_tmp = tot_paid_year
			
			eststo clear
			eststo: `model`i'' ${indepvar} if !missing(mlv_year2011) & `cond`i'' & `cond_excl`j'', ///
				vce(cluster cluster_`skill') `het`i''
			qui estadd local ply = "2011"
			qui estadd local src = "Original"
			qui estadd_spec, spec(5)
			qui estadd local ncntry = strofreal(e(N_clust) / 4, "%2.0f")

			foreach t in 2011 2001 1991 1981 1971 {
				replace tot_tmp = mlv_year`t'
				eststo: `model`i'' ${indepvar} if `cond`i'' & `cond_excl`j'', ///
					vce(cluster cluster_`skill') `het`i''
				qui estadd local ply = "`t'"
				qui estadd local src = "OECD"
				qui estadd_spec, spec(5)
				qui estadd local ncntry = strofreal(e(N_clust) / 4, "%2.0f")
			}
			
			local texfile "${path_table}/tex/sub/revcause_`skill'`tag_excl`j''`tag`i''_sub.tex"
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
				stats(ply src spec1 spec2 spec3 spec4 spec5 ncntry N,
					labels(
						"Parental leave policy year"
						"Source of parental leave policy"
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
				mgroups("`panel`j''", pattern(1 0 0 0 0 0)
					span prefix(\multicolumn{@span}{c}{) suffix(}))
				;
			# d cr

			clean_subtable "`texfile'", depvar("Dep.var. ${desc_`skill'} skill use") key("Panel")
			if `j' == 0 {
				shell "${sed}" -i -e "/^\}/d" -e "/bottomrule/d" -e "/end/d" "`texfile'"
			}
			else {
				shell "${sed}" -e "1,2d" -e "s/toprule/midrule/g" -e "/begin/d" "`texfile'" >> "${path_table}/tex/sub/revcause_`skill'`tag`i''_sub.tex"
			}
		}
	}
}

log close `dofile_name'
