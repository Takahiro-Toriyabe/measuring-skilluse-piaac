* Open log file
local dofile_name "mismatch_robust"
TakeLog `dofile_name', path("${path_log}")

* Load data
use "${path_data}", clear
do "${path_do}/common/InitialSetting.do"

qui gen depvar1 = .
qui gen depvar2 = .
qui egen minworklit = min(worklit), by(cntryid)
qui egen minworknum = min(worknum), by(cntryid)

run "${path_do}/common/GenLabeledCntryID.do"

* Main analysis: Drop one country
local inst "${inst5}"
foreach skill in lit num {
	qui replace depvar1 = work`skill' if work == 1
	qui replace depvar2 = work`skill' if work == 1
	qui replace depvar2 = minwork`skill' if work == 0

	foreach tag in _paid_year _protect_year {
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
		
		forvalues i = 2(1)2 {
			display _newline "{bf:Skill=`skill' tag=`tag' cond=`cond`i''}"

			qui intreg depvar1 depvar2 ${indepvar} if `cond`i'', vce(cluster cluster_`skill') `het`i''
			forvalues s = 1(1)4 {
				foreach stat in b se {
					matrix `stat'`s' = [_`stat'[c.`skill'cat`s'#c.female#c.tot`tag']]
				}
			}
			local rownames `"Baseline"'
			
			qui levelsof cntryid3letter if e(sample), local(cntry_list)
			foreach c in `cntry_list' {
				qui intreg depvar1 depvar2 ${indepvar} ///
					if `cond`i'' & cntryid != `c', vce(cluster cluster_`skill') `het`i''
				forvalues s = 1(1)4 {
					foreach stat in b se {
						matrix `stat'`s' = `stat'`s' \ _`stat'[c.`skill'cat`s'#c.female#c.tot`tag']
					}
				}

				local rownames `rownames' `"`:label cntryid3letter `c''"'
				di "`:label cntryid3letter `c'': Done"
			}

			forvalues s = 1(1)4 {
				matrix rownames b`s' = `rownames'
				capture graph drop fig`s'
				coefplot matrix(b`s'[.,1]), se(se`s'[.,1]) ///
					grid(none) ///
					xtitle("Skill: Q`s'") ///
					xlabel(-0.7(0.1)0.3, glwidth(vthin) format(%02.1f)) ///
					xline(0, lpattern(solid) lcolor(gs10) lwidth(medthin)) ///
					xsize(3.8) ysize(4) scheme(tt_mono) ///
					name(fig`s')
			}

			graph combine fig1 fig2 fig3 fig4, iscale(*0.8) ycommon xcommon ///
				cols(2) scheme(tt_mono)

			local figfile "mismatch_robust_`skill'`tag'`tag`i''"
			qui graph export "${path_figure}/pdf/`figfile'.pdf", as(pdf) replace
			qui graph export "${path_figure}/png/`figfile'.png", as(png) replace width(3200) height(2400)
		}
	}
}

* Main analysis: Drop two countries
local inst "${inst5}"
foreach skill in lit num {
	qui replace depvar1 = work`skill' if work == 1
	qui replace depvar2 = work`skill' if work == 1
	qui replace depvar2 = minwork`skill' if work == 0

	foreach tag in _paid_year _protect_year {
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
		
		forvalues i = 2(1)2 {
			display _newline "{bf:Skill=`skill' tag=`tag' cond=`cond`i''}"
			
			qui intreg depvar1 depvar2 ${indepvar} if `cond`i'', vce(cluster cluster_`skill') `het`i''
			forvalues s = 1(1)4 {
				foreach stat in b se {
					matrix `stat'`s' = [_`stat'[c.`skill'cat`s'#c.female#c.tot`tag']]
				}
			}
			local rownames `"Baseline"'
			
			local cnt = 0
			qui levelsof cntryid3letter if e(sample), local(cntry_list)
			forvalues c1 = 1(1)`=wordcount("`cntry_list'")-1' {
				forvalues c2 = `=`c1'+1'(1)`=wordcount("`cntry_list'")' {
					local cntry1: word `c1' of `cntry_list'
					local cntry2: word `c2' of `cntry_list'

					qui intreg depvar1 depvar2 ${indepvar} ///
						if `cond`i'' & !inlist(cntryid, `cntry1', `cntry2'), ///
						vce(cluster cluster_`skill') `het`i''

					forvalues s = 1(1)4 {
						foreach stat in b se {
							matrix `stat'`s' = `stat'`s' \ _`stat'[c.`skill'cat`s'#c.female#c.tot`tag']
						}
					}

					di "(`++cnt'/276) `:label cntryid3letter `cntry1'' & `:label cntryid3letter `cntry2'': Done"
				}
			}
			
			preserve
				clear
				forvalues s = 1(1)4 {
					foreach stat in b se {
						svmat `stat'`s'
					}
					qui gen b`s'1_u = b`s'1 + 1.96 * se`s'1
					qui gen b`s'1_l = b`s'1 - 1.96 * se`s'1
					local base`s' = b`s'[1, 1]
				
					qui sum b`s'1
					local hs = round(r(min) - 0.05, 0.1)
					local hw = 0.01

					capture graph drop fig`s'
					twoway (histogram b`s'1, fraction start(`hs') width(`hw')) ///
						if _n != 1, ///
						ytitle("Fraction") ylabel(, format(%03.2f) nogrid) ///
						xtitle("Estimate: Skill Q`s'") xlabel(, format(%03.2f) nogrid) ///
						xline(`base`s'', lp(l) lc(gs10)) ///
						name(fig`s')
				}
				
				graph combine fig1 fig2 fig3 fig4, iscale(*0.8)	cols(2) ycommon scheme(tt_mono)
				local figfile "mismatch_robust2_`skill'`tag'`tag`i''"
				qui graph export "${path_figure}/pdf/`figfile'.pdf", as(pdf) replace
				qui graph export "${path_figure}/png/`figfile'.png", as(png) replace width(3200) height(2400)
				
				capture mkdir "${path_root}/data/mismatch_robust2"
				save "${path_root}/data/mismatch_robust2/mismatch_robust2_`skill'`tag'`tag`i''.dta", replace
			restore
		}
	}
}

log close `dofile_name'
