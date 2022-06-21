*Open log file
local dofile_name "justify_skilluse_referee_point4"
TakeLog `dofile_name', path("${path_log}")
capture mkdir "${path_table}/csv/`dofile_name'"

* Load data
use "${path_data}", clear
do "${path_do}/common/InitialSetting.do"


// Occupation, skill-use and wages

qui replace isco2c = . if isco2c > 9000

qui keep if !female & !inlist(cntryid, 40, 233, 246) & !missing(lwage)
	// No occupation data or wage data

qui egen meanlwage = mean(lwage), by(country)
qui replace lwage = lwage - meanlwage
qui egen nobs = count(lwage), by(country isco2c)

* Full sample
local cond1 "1 == 1"
local tag1 ""

* CBA
local cond2 "flag_paper_\`skill' == 0"
local tag2 "_cba"

local desc_lit "literacy"
local desc_num "numeracy"

do "${path_do}/common/GenLabeledCntryID.do"
qui gen Skill = .
qui gen Use = .
	
forvalues j = 2(1)2 {
	eststo clear
	foreach skill in lit num {
		qui reg work`skill' i.cntryid#c.workhour i.cntryid if `cond`j'' 
		tempvar uhat
		qui predict `uhat', residual
		qui replace work`skill' = `uhat' if e(sample)
		qui replace work`skill' = . if !e(sample)

		
		*Graphical analysis
		preserve
			keep if `cond`j'' & !missing(`skill')
			qui collapse (mean) lwage `skill' work`skill' nobs, by (cntryid3letter isco2c)
			
			* By each country
			twoway (scatter lwage `skill' [aweight=nobs], msymbol(Oh) mlw(*0.5) msize(0.5)) ///
				(lfit lwage `skill' [aweight=nobs], lpattern(solid) lc(gs6) lw(*1.3)) ///
				if inrange(`skill', -2, 2), ///
				by(cntryid3letter, legend(off) note("") iyaxes ixaxes) ///
				subtitle(, nobox) ///
				xtitle("Average `desc_skill'' skill of each occupation", size(small)) ///
				ytitle("Average log wage of each occupation (demeaned)", size(small)) ///
				xlabel(-2(1)2, nogrid format(%02.1f)) ///
				ylabel(-2(1)2, nogrid angle(0) format(%02.1f)) ///
				scheme(tt_mono)
				
			graph export "${path_figure}/pdf/wage_`skill'`tag`j''_refp4.pdf", as(pdf) replace
			graph export "${path_figure}/png/wage_`skill'`tag`j''_refp4.png", as(png) replace ///
				width(${fig_w_main}) height(${fig_h_main})

			twoway (scatter lwage work`skill' [aweight=nobs], msymbol(Oh) mlw(*0.5) msize(0.5)) ///
				(lfit lwage work`skill' [aweight=nobs], lpattern(solid) lc(gs6) lw(*1.3)) ///
				if inrange(work`skill', -2, 2), ///
				by(cntryid3letter, legend(off) note("") iyaxes ixaxes) ///
				subtitle(, nobox) ///
				xtitle("Average `desc_skill'' skill use of each occupation", size(small)) ///
				ytitle("Average log wage of each occupation (demeaned)", size(small)) ///
				xlabel(-2(1)2, nogrid format(%02.1f)) ///
				ylabel(-2(1)2, nogrid angle(0) format(%02.1f)) ///
				scheme(tt_mono)

			graph export "${path_figure}/pdf/wage_`skill'use`tag`j''_refp4.pdf", as(pdf) replace
			graph export "${path_figure}/png/wage_`skill'use`tag`j''_refp4.png", as(png) replace ///
				width(${fig_w_main}) height(${fig_h_main})
			
			* Pool countries
			twoway (scatter lwage `skill' [aweight=nobs], msymbol(oh) mlw(*0.8)) ///
				(lfit lwage `skill' [aweight=nobs], lpattern(solid) lc(gs6) lw(*1.3)) ///
				if inrange(`skill', -2, 2), ///
				xtitle("Average `desc_skill'' skill of each occupation") ///
				ytitle("Average log wage of each occupation (demeaned)") ///
				xlabel(-2(1)2, nogrid format(%02.1f)) ///
				ylabel(-2(1)2, nogrid angle(0) format(%02.1f)) ///
				legend(off) ///
				scheme(tt_mono)
				
			graph export "${path_figure}/pdf/wage_`skill'_pool`tag`j''_refp4.pdf", as(pdf) replace
			graph export "${path_figure}/png/wage_`skill'_pool`tag`j''_refp4.png", as(png) replace ///
				width(${fig_w_main}) height(${fig_h_main})

			twoway (scatter lwage work`skill' [aweight=nobs], msymbol(oh) mlw(*0.8)) ///
				(lfit lwage work`skill' [aweight=nobs], lpattern(solid) lc(gs6) lw(*1.3)) ///
				if inrange(work`skill', -2, 2), ///
				xtitle("Average `desc_skill'' skill use of each occupation") ///
				ytitle("Average log wage of each occupation (demeaned)") ///
				xlabel(-2(1)2, nogrid format(%02.1f)) ///
				ylabel(-2(1)2, nogrid angle(0) format(%02.1f)) ///
				legend(off) ///
				scheme(tt_mono)

			graph export "${path_figure}/pdf/wage_`skill'use_pool`tag`j''_refp4.pdf", as(pdf) replace
			graph export "${path_figure}/png/wage_`skill'use_pool`tag`j''_refp4.png", as(png) replace ///
				width(${fig_w_main}) height(${fig_h_main})
		restore

		* Wage regression
		qui replace Skill = `skill'
		qui replace Use = work`skill'
		
		qui eststo: reg lwage Skill Use i.country#c.${xvars} i.country ///
			if `cond`j'' & !missing(isco2c), cluster(cluster_`skill')
			
		qui eststo: reg lwage Skill Use i.country#c.${xvars} i.country#i.isco2c ///
			if `cond`j'', cluster(cluster_`skill')
	}

	# d;
		esttab using  "${path_table}/csv/`dofile_name'/wage_skilluse`tag`j''_refp4.csv",
		replace se nogap label obslast b(%9.3f) se(%9.3f) nonotes star(* 0.1 ** 0.05 *** 0.01)
		keep(Skill Use)	order(Skill Use) coeflabels(Skill "Skill" Use "Skill-use");
	# d cr	
}


// More detailed analysis

use "${path_data}", clear
do "${path_do}/common/InitialSetting.do"
do "${path_do}/common/GenManageVar.do"

label define isco1c 0 "Armed forces"
label define isco1c 1 "Managers", add
label define isco1c 2 "Professionals", add
label define isco1c 3 "Technicians", add
label define isco1c 4 "Clerks", add
label define isco1c 5 "Service/Sales", add
label define isco1c 6 "Skilled agricultural/fishery", add
label define isco1c 7 "Craft and trades workers", add
label define isco1c 8 "Plant/Machine operators", add
label define isco1c 9 "Elementary occupations", add
label values isco1c isco1c

keep if female == 0 & work == 1

foreach skill in lit num {
	forvalues j = 2(1)2 {
		qui reg work`skill' i.cntryid#c.workhour i.cntryid if `cond`j''
		tempvar uhat
		qui predict `uhat' if e(sample), residual
		qui replace work`skill' = `uhat' if e(sample)
		qui replace work`skill' = . if !e(sample)

		capture drop cum_*
		qui bysort cntryid: cumul lwage if `cond`j'', gen(cum_wage)
		qui bysort cntryid: cumul work`skill' if `cond`j'' & !missing(lwage), gen(cum_work`skill')
		qui Normalize work`skill' if !missing(lwage), by(cntryid)

		* Relationship between literacy use and hourly wage
		twoway (lpoly cum_work`skill' cum_wage) if `cond`j'', ///
			ytitle("SKill use percentile") ylabel(0.3(0.1)0.7, format(%02.1f) nogrid) ///
			xtitle("Wage percentile") xlabel(0(0.1)1, format(%02.1f) nogrid) ///
			legend(off) ///
			scheme(tt_color)

		qui graph export "${path_figure}/pdf/lpoly_work`skill'_wage`tag`j''_refp4.pdf", as(pdf) replace
		qui graph export "${path_figure}/png/lpoly_work`skill'wage`tag`j''_refp4.png", ///
			as(png) replace width(${fig_w_main}) height(${fig_h_main})

		* Joint density of literacy use and wage
		preserve
			keep if !missing(lwage) & `cond`j''
			qui egen ycat = cut(cum_work`skill'), at(0(0.1)0.90 1.1)
			qui egen xcat = cut(cum_wage), at(0(0.1)0.90 1.1)
			qui gen nobs = 1

			collapse (sum) nobs, by(ycat xcat)
			
			qui replace ycat = (ycat + 0.1) * 10
			qui replace xcat = (xcat + 0.1) * 10
			
			qui egen tot = total(nobs)
			qui gen dens = nobs / tot
			
			twoway (contour dens ycat xcat, heatmap levels(10) minimax), ///
				ztitle("Density") zlabel(, format(%05.4f)) ///
				ytitle("Skill use decile") ylabel(1(1)10, nogrid) ///
				xtitle("Wage decile") xlabel(1(1)10, nogrid) ///
				scheme(tt_color)
				
			qui graph export "${path_figure}/pdf/contour_work`skill'_wage`tag`j''_refp4.pdf", ///
				as(pdf) replace
			qui graph export "${path_figure}/png/contour_work`skill'_wage`tag`j''_refp4.png", ///
				as(png) replace width(${fig_w_main}) height(${fig_h_main})
		restore

		* Relationship between literacy use and number of subordinates
		Normalize work`skill' if `cond`j'' & !missing(manage), by(cntryid)

		MyCumPlot work`skill' if `cond`j'', by(manage) xtitle("Skill use")
		qui graph export "${path_figure}/pdf/cum_work`Skill'_subordinate`tag`j''_refp4.pdf", as(pdf) replace
		qui graph export "${path_figure}/png/cum_work`Skill'_subordinate`tag`j''_refp4.png", ///
			as(png) replace width(${fig_w_main}) height(${fig_h_main})


		* Literacy use and occupation
		Normalize work`skill' if `cond`j'' & !missing(isco1c), by(cntryid)

		MyCumPlot work`skill', by(isco1c) xtitle("Skill use") ///
			legend_pos("ring(0) pos(4) region(lw(*0.3) lc(gs13))")
		qui graph export "${path_figure}/pdf/cum_work`skill'_occup`tag`j''_refp4.pdf", as(pdf) replace
		qui graph export "${path_figure}/png/cum_work`skill'_occup`tag`j''_refp4.png", ///
			as(png) replace width(${fig_w_main}) height(${fig_h_main})
	}
}

// Gender gap in skill use
use "${path_data}", clear 
do "${path_do}/common/InitialSetting.do"

levelsof cntryid, local(cntryid_list)
foreach v in lit num {
	Normalize work`v' if work == 1 & flag_paper_`v' == 0, by(cntryid)

	qui reg work`v' i.cntryid#c.workhour i.cntryid if work == 1 & flag_paper_`v' == 0
	tempvar uhat
	qui predict `uhat' if e(sample), residual
	qui replace work`v' = `uhat' if e(sample)
	qui replace work`v' = . if !e(sample)

	qui gen bwork`v' = .
	qui gen sework`v' = .
	
	foreach c in `cntryid_list' {
		qui count if cntryid == `c' & !missing(workhour) & work == 1
		if r(N) > 0 {
			qui reg work`v' female if cntryid == `c' & flag_paper_`v' == 0, robust
			qui replace bwork`v' = _b[female] if cntryid == `c'
			qui replace sework`v' = _se[female] if cntryid == `c'
		}
		else {
			qui replace bwork`v' = . if cntryid == `c'
			qui replace sework`v' = . if cntryid == `c'
		}
	}
}
	
do "${path_do}/common/GenLabeledCntryID.do"

qui duplicates drop cntryid3letter, force

local rownames ""
foreach j in `cntryid_list' {
	local cntry: label cntryid3letter `j'
	local rownames `rownames' `cntry'
}

foreach v in lit num {
	mkmat bwork`v', matrix(B)
	matrix rownames B = `rownames'
	mkmat sework`v', matrix(SE)

	coefplot matrix(B[.,1]), se(SE[.,1]) omit ///
		xtitle("Gender gap") ///
		xlabel(-0.7(0.1)0.3, glwidth(vthin)) ///
		xline(0, lpattern(solid) lcolor(gs10) lwidth(medthin)) ///
		xlabel(, glwidth(vthin) format(%02.1f)) ///
		scheme(tt_mono) xsize(3.8) ysize(4)
	
	graph export "${path_figure}/pdf/diffwork`v'_refp4.pdf", as(pdf) replace
	graph export "${path_figure}/png/diffwork`v'_refp4.png", as(png) replace ///
		width(${fig_w_main}) height(${fig_h_main})
}

// Immigrant
use "${path_data}", clear 
do "${path_do}/common/InitialSetting.do"
do "${path_do}/common/GenLabeledCntryID.do"

gen flag_immigrant = j_q04a == 2 if !missing(j_q04a)
replace flag_immigrant = . if cntryid == 616 // Very small immigrants in Poland data
levelsof cntryid, local(cntryid_list)

levelsof cntryid, local(cntryid_list)
foreach v in lit num {
	Normalize work`v' if work == 1 & flag_paper_`v' == 0, by(cntryid)

	qui reg work`v' i.cntryid#c.workhour i.cntryid if work == 1 & flag_paper_`v' == 0
	tempvar uhat
	qui predict `uhat' if e(sample), residual
	qui replace work`v' = `uhat' if e(sample)
	qui replace work`v' = . if !e(sample)

	qui gen bwork`v' = .
	qui gen sework`v' = .
	
	foreach c in `cntryid_list' {
		qui count if cntryid == `c' & !missing(flag_immigrant) & !missing(workhour) & work == 1
		if r(N) > 0 {
			qui reg work`v' flag_immigrant if cntryid == `c' & flag_paper_`v' == 0, robust
			qui replace bwork`v' = _b[flag_immigrant] if cntryid == `c'
			qui replace sework`v' = _se[flag_immigrant] if cntryid == `c'
		}
		else {
			qui replace bwork`v' = . if cntryid == `c'
			qui replace sework`v' = . if cntryid == `c'
		}
	}
}


qui duplicates drop cntryid3letter, force

local rownames ""
foreach j in `cntryid_list' {
	local cntry: label cntryid3letter `j'
	local rownames `rownames' `cntry'
}

foreach v of varlist lit num {
	mkmat bwork`v', matrix(B)
	matrix rownames B = `rownames'
	mkmat sework`v', matrix(SE)

	coefplot matrix(B[.,1]), se(SE[.,1]) omitted ///
		xtitle("Immigrant vs Non-immigrant") ///
		xlabel(-3.2(0.4)1.6, glwidth(vthin)) ///
		xline(0, lpattern(solid) lcolor(gs10) lwidth(medthin)) ///
		xlabel(, glwidth(vthin) format(%02.1f)) ///
		scheme(tt_mono) xsize(3.8) ysize(4)
	
	graph export "${path_figure}/pdf/diffwork`v'_immigrant_refp4.pdf", as(pdf) replace
	graph export "${path_figure}/png/diffwork`v'_immigrant_refp4.png", as(png) replace ///
		width(${fig_w_main}) height(${fig_h_main})
}

log close `dofile_name'
