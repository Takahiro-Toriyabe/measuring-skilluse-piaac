*Open log file
local dofile_name "referee_point3"
// TakeLog `dofile_name', path("${path_log}")
// capture mkdir "${path_table}/csv/`dofile_name'"

* Load data
use "${path_data}", clear 
do "${path_do}/common/InitialSetting.do"
do "${path_do}/common/GenLabeledCntryID.do"

// Immigrant
gen flag_immigrant = j_q04a == 2 if !missing(j_q04a)
replace flag_immigrant = . if cntryid == 616 // Very small immigrants in Poland data
levelsof cntryid, local(cntryid_list)
foreach score in lit num worklit worknum {
	qui gen b`score' = .
	qui gen se`score' = .
	local skill = subinstr("`score'", "work", "", .)
	Normalize `score', by(cntryid)
	foreach c in `cntryid_list' {
		qui count if cntryid == `c' & !missing(flag_immigrant)
		if r(N) > 0 {
			qui reg `score' flag_immigrant if cntryid == `c' & flag_paper_`skill' == 0, robust
			qui replace b`score' = _b[flag_immigrant] if cntryid == `c'
			qui replace se`score' = _se[flag_immigrant] if cntryid == `c'
		}
	}
}

qui duplicates drop cntryid3letter, force

local rownames ""
foreach j in `cntryid_list' {
	local cntry: label cntryid3letter `j'
	local rownames `rownames' `cntry'
}

foreach v of varlist lit num worklit worknum {
	mkmat b`v', matrix(B)
	matrix rownames B = `rownames'
	mkmat se`v', matrix(SE)

	coefplot matrix(B[.,1]), se(SE[.,1]) omitted ///
		xtitle("Immigrant vs Non-immigrant") ///
		xlabel(-3.2(0.4)1.6, glwidth(vthin)) ///
		xline(0, lpattern(solid) lcolor(gs10) lwidth(medthin)) ///
		xlabel(, glwidth(vthin) format(%02.1f)) ///
		scheme(tt_mono) xsize(3.8) ysize(4)
	
	graph export "${path_figure}/pdf/diff`v'_immigrant.pdf", as(pdf) replace
	graph export "${path_figure}/png/diff`v'_immigrant.png", as(png) replace ///
		width(${fig_w_main}) height(${fig_h_main})
}

// Regression analysis
use "${path_data}", clear 
do "${path_do}/common/InitialSetting.do"
do "${path_do}/common/GenLabeledCntryID.do"
gen flag_immigrant = j_q04a == 2 if !missing(j_q04a)
replace flag_immigrant = . if cntryid == 616 // Very small immigrants in Poland data

qui levelsof cntryid, local(clist)
local xlist female flag_immigrant
local I = wordcount("`clist'")
local J = wordcount("`xlist'")

foreach v in lit num {
	eststo clear
	foreach x in `xlist' {
		qui eststo: reg work`v' c.`v'#c.`x' `v' `x' ///
			i.cntryid if flag_paper_`v' == 0, cluster(cluster_`v')
		qui estadd local controls ""
		qui estadd local ncntry = strofreal(e(N_clust) / 4, "%2.0f")
		
		qui eststo: reg work`v' c.`v'#c.`x' `v' `x' ///
			i.cntryid#c.(educ age30_34 age35_39 age40_44 age45_49 age50_54 age55_59) ///
			i.cntryid if flag_paper_`v' == 0, cluster(cluster_`v')
		qui estadd local controls "X"
		qui estadd local ncntry = strofreal(e(N_clust) / 4, "%2.0f")
	}
	
	# d;
		esttab using "${path_table}/tex/sub/regdiff`v'_sub_refp3.tex",
		replace se nogap label obslast b(%9.3f) se(%9.3f) nonotes star(* 0.1 ** 0.05 *** 0.01)
		keep(`v' female c.`v'#c.female flag_immigrant c.`v'#c.flag_immigrant)
		order(`v' female c.`v'#c.female flag_immigrant c.`v'#c.flag_immigrant)
		coeflabels(`v' "Skill" female "Female" c.`v'#c.female "Female\$\times\$Skill"
			flag_immigrant "Immigrant" c.`v'#c.flag_immigrant "Immigrant\$\times\$Skill")
		stats(controls ncntry N, 
			labels("Controls" "Countries" "Observations")
			fmt(%1s %3.0f %5.0f));
	# d cr
}


// Regression analysis
matrix B = J(`I', `J' * 2, .)
matrix SE = J(`I', `J' * 2, .)
foreach v in lit num {
	forvalues i = 1(1)`I' {
		local c: word `i' of `clist'
		forvalues j = 1(1)`J' {
			local x: word `j' of `xlist'
			qui count if cntryid == `c' & !missing(`x')
			if r(N) > 0 {
				qui reg work`v' c.`v'#c.`x' `v' `x' educ ///
					age30_34 age35_39 age40_44 age45_49 age50_54 age55_59 ///
					if cntryid == `c' & flag_paper_`v' == 0, robust
				matrix B[`i', `j'] = _b[`x']
				matrix SE[`i', `j'] = _se[`x']
				matrix B[`i', `j' + `J'] = _b[c.`v'#c.`x']
				matrix SE[`i', `j' + `J'] = _se[c.`v'#c.`x']
			}
		}
	}

	local rownames ""
	foreach j in `clist' {
		local cntry: label cntryid3letter `j'
		local rownames `rownames' `cntry'
	}
	matrix rownames B = `rownames'

	coefplot matrix(B[.,1]), se(SE[.,1]) omitted ///
		xtitle("Female vs Male") ///
		xlabel(-1.2(0.4)1.6, glwidth(vthin)) ///
		xline(0, lpattern(solid) lcolor(gs10) lwidth(medthin)) ///
		xlabel(, glwidth(vthin) format(%02.1f)) ///
		scheme(tt_mono) xsize(3.8) ysize(4)
	graph export "${path_figure}/pdf/regdiff`v'_female.pdf", as(pdf) replace
	graph export "${path_figure}/png/regdiff`v'_female.png", as(png) replace ///
		width(${fig_w_main}) height(${fig_h_main})

	coefplot matrix(B[.,2]), se(SE[.,2]) omitted ///
		xtitle("Immigrant vs Non-immigrant") ///
		xlabel(-1.2(0.4)1.6, glwidth(vthin)) ///
		xline(0, lpattern(solid) lcolor(gs10) lwidth(medthin)) ///
		xlabel(, glwidth(vthin) format(%02.1f)) ///
		scheme(tt_mono) xsize(3.8) ysize(4)
	graph export "${path_figure}/pdf/regdiff`v'_immigrant.pdf", as(pdf) replace
	graph export "${path_figure}/png/regdiff`v'_immigrant.png", as(png) replace ///

		
	coefplot matrix(B[.,3]), se(SE[.,3]) omitted ///
		xtitle("Female vs Male") ///
		xlabel(-1.2(0.4)1.6, glwidth(vthin)) ///
		xline(0, lpattern(solid) lcolor(gs10) lwidth(medthin)) ///
		xlabel(, glwidth(vthin) format(%02.1f)) ///
		scheme(tt_mono) xsize(3.8) ysize(4)
	graph export "${path_figure}/pdf/regdiff`v'_slope_female.pdf", as(pdf) replace
	graph export "${path_figure}/png/regdiff`v'_slope_female.png", as(png) replace ///
		width(${fig_w_main}) height(${fig_h_main})


	coefplot matrix(B[.,4]), se(SE[.,4]) omitted ///
		xtitle("Immigrant vs Non-immigrant") ///
		xlabel(-1.2(0.4)1.6, glwidth(vthin)) ///
		xline(0, lpattern(solid) lcolor(gs10) lwidth(medthin)) ///
		xlabel(, glwidth(vthin) format(%02.1f)) ///
		scheme(tt_mono) xsize(3.8) ysize(4)
	graph export "${path_figure}/pdf/regdiff`v'_slope_immigrant.pdf", as(pdf) replace
	graph export "${path_figure}/png/regdiff`v'_slope_immigrant.png", as(png) replace ///
		width(${fig_w_main}) height(${fig_h_main})
}
