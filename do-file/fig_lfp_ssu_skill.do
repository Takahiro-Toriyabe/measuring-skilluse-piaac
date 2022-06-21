*Open log file
local dofile_name "fig_lfp_ssu_skill"
TakeLog `dofile_name', path("${path_log}")
capture mkdir "${path_table}/csv/`dofile_name'"

* Load data
use "${path_data}", clear 
do "${path_do}/common/InitialSetting.do"
	
do "${path_do}/common/GenLabeledCntryID.do"

* Descending order in terms of paid leave duration
capture drop group
label define group 0 ""
gen tot_paid_year_d = - tot_paid_year

egen group = group(tot_paid_year_d cntryid3letter)
levelsof group, local(group_list)

foreach g in `group_list' {
	sum cntryid3letter if group == `g', meanonly
	local cntry_lbl: label cntryid3letter `r(mean)'
	sum tot_paid_year if group == `g', meanonly
	local ply = round(r(mean), 0.01)

	if `ply' < 1 & `ply' != 0 {
		local ply = "0" + "`ply'"
	}
	if strlen("`ply'") == 1 {
		local ply = "`ply'" + "."
	}
	if strlen("`ply'") < 4 {
		local ply = "`ply'" + "0" * (4 - strlen("`ply'"))
	}

	local ply = substr("`ply'", 1, 4)
	label define group `g' "`cntry_lbl' (`ply')", add
}
label values group group

foreach skill in lit num {
	twoway (lowess work `skill' if !female, lpattern(solid) lwidth(medthick) lcolor(gs3)) ///
		(lowess work `skill' if female, lpattern("-##") lwidth(medthick) lcolor(gs3)) ///
		if flag_paper_`skill' == 0, ///
		by(group, note("") iyaxes ixaxes cols(6) ///
			legend(cols(1) pos(4) ring(0) size(*0.9))) ///
		legend(order(1 "Male" 2 "Female")) ///
		subtitle(, nobox) ///
		ytitle("Employment rates", size(vsmall)) xtitle("Skill", size(vsmall)) ///
		ylabel(0(0.25)1, nogrid angle(0)) ///
		ymticks(0(0.25)1, nogrid) ///
		xlabel(-4(2)4, nogrid angle(0)) ///
		xmticks(-4(1)4, nogrid) ///
		xsize(6) ysize(4) ///
		scheme(tt_mono) 
		
	graph export "${path_figure}/pdf/emprate`skill'.pdf", as(pdf) replace
	graph export "${path_figure}/png/emprate`skill'.png", as(png) replace ///
		width(${fig_w_main}) height(${fig_h_main})

	twoway (lowess work`skill' `skill' if !female, lpattern(solid) lwidth(medthick) lcolor(gs3)) ///
		(lowess work`skill' `skill' if female, lpattern("-##") lwidth(medthick) lcolor(gs3)) ///
		if flag_paper_`skill' == 0, ///
		by(group, note("") iyaxes ixaxes cols(6) ///
			legend(cols(1) pos(4) ring(0) size(*0.9))) ///
		legend(order(1 "Male" 2 "Female")) ///
		subtitle(, nobox) ///
		ytitle("Skill use", size(vsmall)) xtitle("Skill", size(vsmall)) ///
		ylabel(-1(1)2, nogrid angle(0)) ///
		ymticks(-1(0.5)2, nogrid) ///
		xlabel(-4(2)4, nogrid angle(0)) ///
		xmticks(-4(1)4, nogrid) ///
		xsize(6) ysize(4) ///
		scheme(tt_mono)
		
	graph export "${path_figure}/pdf/ssu`skill'.pdf", as(pdf) replace
	graph export "${path_figure}/png/ssu`skill'.png", as(png) replace ///
		width(${fig_w_main}) height(${fig_h_main})
}

log close `dofile_name'
