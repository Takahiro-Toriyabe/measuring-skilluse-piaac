* Open log file
local dofile_name "occupation_subordinates"
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

* Check the fraction in small cells (i.e., occup_#digit==10001)
tab occup2digit
tab occup4digit

* Check the occupational distribution by gender
tab isco1c female, col nofreq


// Analysis controlling for occupation

local coeflabel_lit "Literacy"
local coeflabel_num "Numeracy"

local inst "${inst5}"

local cond1 "1 == 1"
local tag1 "_emp"

local cond2 "flag_paper_\`skill' == 0"
local tag2 "_cba_emp"

foreach tag in _paid_year _protect_year {
	foreach skill in lit num {
		foreach i in 1 2 {
			eststo clear
			
			* Baseline
			qui eststo eq1_nr: reg work`skill' ${indepvar} if !`flag_missing' & `cond`i''
			qui eststo eq1: reg work`skill' ${indepvar} if !`flag_missing' & `cond`i'', vce(cluster cluster_`skill')
			qui estadd_spec, spec(5)
			qui estadd local ncntry = strofreal(e(N_clust) / 4, "%2.0f")
			
			* 2-digit occupation code
			qui eststo eq2_nr: reg work`skill' ${indepvar} i.occup2digit if !`flag_missing' & `cond`i''
			qui eststo eq2: reg work`skill' ${indepvar} i.occup2digit if !`flag_missing' & `cond`i'', vce(cluster cluster_`skill')
			qui estadd_spec, spec(5)
			qui estadd local ncntry = strofreal(e(N_clust) / 4, "%2.0f")
				
			* 4-digit occupation code
			qui eststo eq3_nr: reg work`skill' ${indepvar} i.occup4digit if !`flag_missing' & `cond`i''
			qui eststo eq3: reg work`skill' ${indepvar} i.occup4digit if !`flag_missing' & `cond`i'', vce(cluster cluster_`skill')
			qui estadd_spec, spec(5)
			qui estadd local ncntry = strofreal(e(N_clust) / 4, "%2.0f")

			qui eststo eq4: suest eq1_nr eq2_nr eq3_nr, vce(cluster cluster_`skill')
			foreach eq in eq2 eq3 {
				forvalues s = 1(1)4 {
					qui lincom [`eq'_nr_mean]c.`skill'cat`s'#c.female#c.tot`tag' - [eq1_nr_mean]c.`skill'cat`s'#c.female#c.tot`tag'
					local star = "*" * ((r(p) <= 0.01) + (r(p) <= 0.05) + (r(p) <= 0.1)) 
					qui estadd local diff`s' = strofreal(r(estimate), "%04.3f") + "`star'": `eq'
				}
			}
			eststo drop *_nr eq4
			
			local texfile "${path_table}/tex/sub/mismatch_occup_`skill'`tag'`tag`i''_sub.tex"
			# d;
				esttab using "`texfile'",
				replace se nogap nonotes nomtitles label obslast
				b(%9.3f) se(%9.3f) star(* 0.1 ** 0.05 *** 0.01)
				keep(c.`skill'cat1#c.female#c.tot`tag' c.`skill'cat2#c.female#c.tot`tag' c.`skill'cat3#c.female#c.tot`tag' c.`skill'cat4#c.female#c.tot`tag')
				order(c.`skill'cat1#c.female#c.tot`tag' c.`skill'cat2#c.female#c.tot`tag' c.`skill'cat3#c.female#c.tot`tag' c.`skill'cat4#c.female#c.tot`tag')
				coeflabels(
					c.`skill'cat1#c.female#c.tot`tag' "Female\$ \times \$PL\$\times\$`coeflabel_`skill'' skill: Q1" 
					c.`skill'cat2#c.female#c.tot`tag' "Female\$ \times \$PL\$\times\$`coeflabel_`skill'' skill: Q2"
					c.`skill'cat3#c.female#c.tot`tag' "Female\$ \times \$PL\$\times\$`coeflabel_`skill'' skill: Q3" 
					c.`skill'cat4#c.female#c.tot`tag' "Female\$ \times \$PL\$\times\$`coeflabel_`skill'' skill: Q4"
				)
				stats(diff1 diff2 diff3 diff4 spec1 spec2 spec3 spec4 spec5 ncntry N,
					labels(
						"Diffrence from baseline: Q1"
						"Diffrence from baseline: Q2"
						"Diffrence from baseline: Q3"
						"Diffrence from baseline: Q4"
						"Country\$\times\$Skill quartile FE"
						"Female\$\times\$Skill\$\times\$Industrial structure"
						"Female\$\times\$Skill\$\times\$Family policies"
						"Female\$\times\$Skill\$\times\$Gender norm"
						"Female\$\times\$Skill\$\times\$Market institutions"
						"Countries"
						"Observations"
					)
					fmt(%1s %1s %1s %1s %1s %1s %1s %1s %1s %3.0f %5.0f)
				)
				mgroups("Baseline" "2-digit code" "4-digit code",
					pattern(1 1 1) span prefix(\multicolumn{@span}{c}{) suffix(}))
				;
			# d cr

			clean_subtable "`texfile'", depvar("Dep.var. ${desc_`skill'} skill use") key("Baseline")
		}
	}
}


// Number of subordinates

do "${path_do}/common/GenManageVar.do"

table litcat female, contents(mean manage0 mean manage1 mean manage2) row col format(%04.3f)

foreach skill in lit num {
	foreach tag in _paid_year _protect_year {
		foreach i in 1 2 {
			eststo clear
			forvalues n = 0(1)2 {
				qui eststo: reg manage`n' ${indepvar} if `cond`i'', vce(cluster cluster_`skill')
				qui estadd_spec, spec(5)
				qui estadd local ncntry = strofreal(e(N_clust) / 4, "%2.0f")
				qui sum manage`n' if e(sample) & !female, meanonly
				qui estadd scalar meanval = r(mean)
				
				ExportStat `e(depvar)' if e(sample), stat(mean)	format(%04.3f) ///
					saving("${path_draft}/MeanValue/`e(depvar)'_mean_`skill'`tag'`tag`i''")
			}
			
			local texfile "${path_table}/tex/sub/estrobust_num_manage_`skill'`tag'`tag`i''_sub.tex"
			# d;
				esttab using "`texfile'",
				replace se nogap nonotes nomtitles label obslast
				b(%9.3f) se(%9.3f) star(* 0.1 ** 0.05 *** 0.01)
				keep(c.`skill'cat1#c.female#c.tot`tag' c.`skill'cat2#c.female#c.tot`tag' c.`skill'cat3#c.female#c.tot`tag' c.`skill'cat4#c.female#c.tot`tag')
				order(c.`skill'cat1#c.female#c.tot`tag' c.`skill'cat2#c.female#c.tot`tag' c.`skill'cat3#c.female#c.tot`tag' c.`skill'cat4#c.female#c.tot`tag')
				coeflabels(
					c.`skill'cat1#c.female#c.tot`tag' "Female\$ \times$PL\$\times\$`coeflabel_`skill'' skill: Q1" 
					c.`skill'cat2#c.female#c.tot`tag' "Female\$ \times$PL\$\times\$`coeflabel_`skill'' skill: Q2"
					c.`skill'cat3#c.female#c.tot`tag' "Female\$ \times$PL\$\times\$`coeflabel_`skill'' skill: Q3" 
					c.`skill'cat4#c.female#c.tot`tag' "Female\$ \times$PL\$\times\$`coeflabel_`skill'' skill: Q4"
				)
				stats(meanval spec1 spec2 spec3 spec4 spec5 ncntry N,
					labels(
						"Mean value among men"
						"Country\$\times\$Skill quartile FE"
						"Female\$\times\$Skill\$\times\$Industrial structure"
						"Female\$\times\$Skill\$\times\$Family policies"
						"Female\$\times\$Skill\$\times\$Gender norm"
						"Female\$\times\$Skill\$\times\$Market institutions"
						"Countries"
						"Observations"
					)
					fmt(%04.3f %1s %1s %1s %1s %1s %3.0f %5.0f)
				)
				mgroups("0" "1--10" "11 or more",
					pattern(1 1 1) span prefix(\multicolumn{@span}{c}{) suffix(}))
				;
			# d cr
			
			clean_subtable "`texfile'", depvar("Dep.var. number of subordinates") key("11 or more")
		}
	}
}

log close `dofile_name'
