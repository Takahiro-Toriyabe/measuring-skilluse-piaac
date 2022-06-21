*Open log file
local dofile_name "summarize_country_level_var"
TakeLog `dofile_name', path("${path_log}")
capture mkdir "${path_table}/csv/`dofile_name'"

* Load data
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
		scheme(tt_mono) xsize(3.8) ysize(4)
	
	graph export "${path_figure}/pdf/diff`v'.pdf", as(pdf) replace
	graph export "${path_figure}/png/diff`v'.png", as(png) replace ///
		width(${fig_w_main}) height(${fig_h_main})
}

replace gdp_pc = gdp_pc / 10000

levelsof cntryid, local(cntryid_list)
foreach c in `cntryid_list' {
	local cntry: label cntryid3letter `c'
	display "`cntry'" _continue
	foreach var in ntax200 ccutil0_2 equal_right right_parttime gender_role ///
			pubsec ind3 emp_protect3 union_density {
		sum `var' if cntryid == `c', meanonly
		display " & " %04.3f r(mean) _continue
	}
	display " \\"
}


// Parental leave durations

foreach tag in _protect _paid _equiv {
	graph hbar tot`tag'_year, ///
		scheme(tt_mono) ///
		over(cntryid3letter, sort(tot`tag'_year) descending label(valuelabel)) nofill ///
		ytitle("Duration") ///
		ylabel(0(0.5)3.5, grid glcolor(gs13) glpattern(shortdash) glwidth(thin) angle(0)) ///
		yline(0 3.5, lcolor(gs13) lpattern(shortdash) lwidth(thin)) 

	graph export "${path_figure}/pdf/sum`tag'.pdf", as(pdf) replace
	graph export "${path_figure}/png/sum`tag'.pdf", as(png) replace ///
		width(${fig_w_main}) height(${fig_h_main})	
}

log close `dofile_name'
