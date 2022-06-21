// Take log
local dofile_name "sec2_4"
TakeLog `dofile_name', path("${path_log}")

// Figures 1, 2, Table 2
use "${path_data}/piaac_main.dta", clear
do "${path_do}/common/InitialSetting.do"

qui replace isco2c = . if isco2c > 9000
qui keep if !female & !inlist(cntryid, 40, 233, 246) & !missing(lwage)
	// No occupation data or wage data

qui egen meanlwage = mean(lwage), by(country)
qui replace lwage = lwage - meanlwage
qui egen nobs = count(lwage), by(country isco2c)

do "${path_do}/common/GenLabeledCntryID.do"
qui gen Skill = .
qui gen Use = .

eststo clear
foreach skill in lit num {
	// Figures 1, 2
	preserve
		keep if flag_paper_`skill' == 0 & !missing(`skill')
		qui collapse (mean) lwage `skill' work`skill' nobs, by (cntryid3letter isco2c)
		
		twoway (scatter lwage `skill' [aweight=nobs], msymbol(Oh) mlw(*0.5) msize(0.5)) ///
			(lfit lwage `skill' [aweight=nobs], lpattern(solid) lc(gs6) lw(*1.3)) ///
			if inrange(`skill', -2, 2), ///
			by(cntryid3letter, legend(off) note("") iyaxes ixaxes) ///
			subtitle(, nobox) ///
			xtitle("Average `desc_skill'' skill of each occupation", size(small)) ///
			ytitle("Average log wage of each occupation (demeaned)", size(small)) ///
			xlabel(-2(1)2, nogrid format(%02.1f)) ///
			ylabel(-2(1)2, nogrid angle(0) format(%02.1f))
			
		twoway (scatter lwage work`skill' [aweight=nobs], msymbol(Oh) mlw(*0.5) msize(0.5)) ///
			(lfit lwage work`skill' [aweight=nobs], lpattern(solid) lc(gs6) lw(*1.3)) ///
			if inrange(work`skill', -2, 2), ///
			by(cntryid3letter, legend(off) note("") iyaxes ixaxes) ///
			subtitle(, nobox) ///
			xtitle("Average `desc_skill'' skill use of each occupation", size(small)) ///
			ytitle("Average log wage of each occupation (demeaned)", size(small)) ///
			xlabel(-2(1)2, nogrid format(%02.1f)) ///
			ylabel(-2(1)2, nogrid angle(0) format(%02.1f))
	restore

	// Table 2
	qui replace Skill = `skill'
	qui replace Use = work`skill'
	qui eststo: reg lwage Skill Use i.country#c.${xvars} i.country ///
		if flag_paper_`skill' == 0 & !missing(isco2c), cluster(cluster_`skill')
		
	qui eststo: reg lwage Skill Use i.country#c.${xvars} i.country#i.isco2c ///
		if flag_paper_`skill' == 0, cluster(cluster_`skill')
}

# d;
	esttab,
	se nogap label obslast b(%9.3f) se(%9.3f) nonotes star(* 0.1 ** 0.05 *** 0.01)
	keep(Skill Use)	order(Skill Use) coeflabels(Skill "Skill" Use "Skill-use");
# d cr	

// Figure 3
use "${path_data}/piaac_main.dta", clear
do "${path_do}/common/InitialSetting.do"

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

recode isco1c (0 = 2) (2 = 0), gen(isco1c_tmp)
label define isco1c_tmp 0 "Professionals"
label define isco1c_tmp 1 "Managers", add
label define isco1c_tmp 2 "Armed forces", add
label define isco1c_tmp 3 "Technicians", add
label define isco1c_tmp 4 "Clerks", add
label define isco1c_tmp 5 "Service/Sales", add
label define isco1c_tmp 6 "Skilled agricultural/fishery", add
label define isco1c_tmp 7 "Craft and trades workers", add
label define isco1c_tmp 8 "Plant/Machine operators", add
label define isco1c_tmp 9 "Elementary occupations", add
label values isco1c_tmp isco1c_tmp

keep if female == 0 & work == 1

Normalize worklit if flag_paper_lit == 0 & !missing(isco1c), by(cntryid)
MyCumPlot worklit if flag_paper_lit == 0 & !missing(isco1c), by(isco1c_tmp) xtitle("Skill use") ///
	legend_pos("ring(0) pos(4) region(lw(*0.3) lc(gs13))")

// Figure 4
keep if !missing(lwage) & flag_paper_lit == 0
capture drop cum_*
qui bysort cntryid: cumul lwage, gen(cum_wage)
qui bysort cntryid: cumul worklit if !missing(lwage), gen(cum_worklit)
qui egen ycat = cut(cum_worklit), at(0(0.1)0.90 1.1)
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
	xtitle("Wage decile") xlabel(1(1)10, nogrid)

log close `dofile_name'
