*Open log file
local dofile_name "scatter_plot_quantile"
TakeLog `dofile_name', path("${path_log}")
capture mkdir "${path_table}/csv/`dofile_name'"

* Load data
use "${path_data}", clear
do "${path_do}/common/InitialSetting.do"

keep if work == 1


// Main analysis

local list_exp_raw female
local list_exp_cond female ${xvars}

* Full sample
local cond1 "1 == 1"
local tag1 ""

* CBA
local cond2 "flag_paper_\`skill' == 0"
local tag2 "_cba"

* Non ex-communist
local cond3 "!east"
local tag3 "_nonEast"

* CBA & Non ex-communist
local cond4 "flag_paper_\`skill' == 0 & !east"
local tag4 "_cba_nonEast"

* Estimate country-skillQtile parameters

foreach skill in lit num {
	forvalues j = 1(1)4 {
		foreach prm in beta se n {
			qui gen `prm'`skill'_raw`tag`j'' = .
			qui gen `prm'`skill'_cond`tag`j'' = .
		}
	
		qui levelsof cntryid if `cond`j'', local(cntryid_list)
		foreach c in `cntryid_list' {
			forvalues s = 1(1)4 {
				foreach tag in _raw`tag`j'' _cond`tag`j'' {
					if substr("`tag'", 1, 5) == "_cond" { 
						local indepvar "female ${xvars}"
					}
					else {
						local indepvar "female"
					}

					qui reg work`skill' `indepvar' ///
						if cntryid == `c' & `skill'cat == `s' & `cond`j'', robust

					qui replace beta`skill'`tag' = _b[female] if e(sample)
					qui replace se`skill'`tag' = _se[female] if e(sample)
					qui replace n`skill'`tag' = e(N) if e(sample)
				}
			}
		}
	}
}

* Visualize the estimates
local wt "n\`skill'"
foreach skill in lit num {
	forvalues j = 1(1)4 {
		preserve
			keep if `cond`j'' & !missing(`skill')
			duplicates drop country `skill'cat, force
			
			foreach pl in _paid_year _protect_year {
				foreach tag in _raw`tag`j'' _cond`tag`j'' {
					eststo clear
					forvalues s = 1(1)4 {
						qui eststo: reg beta`skill'`tag' tot`pl' [aw=`wt'`tag'] ///
							if `skill'cat == `s', robust
						
						capture graph drop cat`s'
						qui twoway (scatter beta`skill'`tag' tot`pl' [aw=`wt'`tag'], ms(Oh) mc(gs3)) ///
							(lfit beta`skill'`tag' tot`pl' [aw=`wt'`tag'], lp(l) lc(gs3)) ///
							if `skill'cat==`s', ///
							title("Skill level: Q`s'") ///
							ytitle("Gender gap in skill use (SD)") ylabel(, format(%02.1f)) ///
							xtitle("Parental leaves (year)") xlabel(, format(%02.1f)) ///
							legend(off) ///
							scheme(tt_color) ///
							name("cat`s'")
					}

					qui graph combine cat1 cat2 cat3 cat4, col(2) ycommon xcommon iscale(*0.75) scheme(tt_color)
					qui graph export "${path_figure}/pdf/tot`pl'_`skill'`tag'.pdf", as(pdf) replace
					qui graph export "${path_figure}/png/tot`pl'_`skill'`tag'.png", as(png) replace ///
						width(`w_main') height(`h_main')
					
					capture graph drop _all
					
					# d;
						esttab,
						se nogap label obslast b(%9.3f) se(%9.3f) nonotes star(* 0.1 ** 0.05 *** 0.01)
						keep(tot`pl') coeflabels(tot`pl' "PL") 
						title("tot`pl'_`skill'`tag'") mtitles(Q1 Q2 Q3 Q4);
					# d cr
				}
			}
		restore
	}
}

log close `dofile_name'
