use "${path_data}", clear 
do "${path_do}/common/InitialSetting.do"

levelsof cntryid, local(cntryid_list)
foreach score in lit num worklit worknum {
	qui gen b`score' = .
	qui gen se`score' = .
	local skill = subinstr("`score'", "work", "", .)
	Normalize `score', by(cntryid)
	foreach c in `cntryid_list' {
		qui reg `score' female if cntryid == `c' & flag_paper_`skill' == 0, robust
		qui replace b`score' = _b[female] if cntryid == `c'
		qui replace se`score' = _se[female] if cntryid == `c'
	}
}
	
do "${path_do}/common/GenLabeledCntryID.do"

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

	coefplot matrix(B[.,1]), se(SE[.,1]) ///
		xtitle("Gender gap") ///
		xlabel(-0.7(0.1)0.3, glwidth(vthin)) ///
		xline(0, lpattern(solid) lcolor(gs10) lwidth(medthin)) ///
		xlabel(, glwidth(vthin) format(%02.1f)) ///
		scheme(tt_mono) xsize(3.8) ysize(4) sort(.)
	
	graph export "${path_figure}/pdf/diff`v'_sort.pdf", as(pdf) replace
	graph export "${path_figure}/png/diff`v'_sort.png", as(png) replace ///
		width(${fig_w_main}) height(${fig_h_main})
}
