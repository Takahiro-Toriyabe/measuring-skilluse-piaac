// Gender wage gap
use "${path_data}", clear
do "${path_do}/common/InitialSetting.do"
do "${path_do}/common/GenLabeledCntryID.do"
keep if work == 1 & !missing(lit)

qui levelsof cntryid, local(clist)
foreach c in `clist' {
	qui sum worklit if cntryid == `c'
	replace worklit = (worklit - r(mean)) / r(sd) if cntryid == `c'
}

bysort cntryid: cumul lit, gen(cdflit)
capture drop litcat10
gen litcat10 = .
forvalues i = 1(1)10 {
	local minv = 0 + 0.1 * (`i' - 1)
	local maxv = 0 + 0.1 * (`i' + 1)
	replace litcat10 = `i' if cdflit > `minv' & cdflit <= `maxv'
}
tab litcat10
assert !missing(litcat10)

preserve
collapse (p10) p10=worklit (p25) p25=worklit (p50) p50=worklit ///
	(p75) p75=worklit (p90) p90=worklit, by(litcat10)
	
twoway (connect p25 p50 p75 litcat10), scheme(tt_color)
restore

preserve
	collapse (p10) p10=worklit (p25) p25=worklit (p50) p50=worklit ///
		(p75) p75=worklit (p90) p90=worklit, by(litcat10 female)
		
	twoway (connect p90 litcat10 if female == 0, lp(l) ms(X) msize(*1.3) color(sky)) ///
		(connect p75 litcat10 if female == 0, lp(l) ms(Th) msize(*1.3) color(sky)) ///
		(connect p50 litcat10 if female == 0, lp(l) ms(Oh) msize(*1.3) color(sky)) ///
		(connect p25 litcat10 if female == 0, lp(l) ms(Dh) msize(*1.3) color(sky)) ///
		(connect p10 litcat10 if female == 0, lp(l) ms(+) msize(*1.3) color(sky)) ///
		(connect p90 litcat10 if female == 1, lp(shortdash) ms(X) msize(*1.3) color(reddish)) ///
		(connect p75 litcat10 if female == 1, lp(shortdash) ms(Th) msize(*1.3) color(reddish)) ///
		(connect p50 litcat10 if female == 1, lp(shortdash) ms(Oh) msize(*1.3) color(reddish)) ///
		(connect p25 litcat10 if female == 1, lp(shortdash) ms(Dh) msize(*1.3) color(reddish)) ///
		(connect p10 litcat10 if female == 1, lp(shortdash) ms(+) msize(*1.3) color(reddish)), ///
		ytitle("Literacy use (Mean=0, SD=1)") ylabel(-2.0(0.4)1.6, format(%02.1f)) ///
		xtitle("Literacy skill decile") xlabel(1(1)10.1, nogrid) ///
		legend(order(1 "Men: P90" 2 "Men: P75" 3 "Men: P50" 4 "Men: P25" 5 "Men: P10" ///
			6 "Women: P90" 7 "Women: P75" 8 "Women: P50" 9 "Women: P25" 10 "Women: P10")) ///
		scheme(tt_color)
	graph export "${path_figure}/pdf/lituse_dist_condon_lit_gender.pdf", as(pdf) replace
restore

preserve
	collapse (p10) p10=worklit (p25) p25=worklit (p50) p50=worklit ///
		(p75) p75=worklit (p90) p90=worklit, by(litcat10 female cntryid3letter)
	qui levelsof cntryid3letter, local(clist)
	capture graph drop _all
	foreach c in `clist' {
		local lbl: label cntryid3letter `c'
		twoway (connect p75 litcat10 if female == 0, lp(l) ms(Th) msize(*1.3) color(sky)) ///
			(connect p50 litcat10 if female == 0, lp(l) ms(Oh) msize(*1.3) color(sky)) ///
			(connect p25 litcat10 if female == 0, lp(l) ms(Dh) msize(*1.3) color(sky)) ///
			(connect p75 litcat10 if female == 1, lp(shortdash) ms(Th) msize(*1.3) color(reddish)) ///
			(connect p50 litcat10 if female == 1, lp(shortdash) ms(Oh) msize(*1.3) color(reddish)) ///
			(connect p25 litcat10 if female == 1, lp(shortdash) ms(Dh) msize(*1.3) color(reddish)) ///
			if cntryid3letter == `c', ///
			ytitle("Literacy use (Mean=0, SD=1)") ylabel(-2.0(0.4)1.6, format(%02.1f)) ///
			xtitle("Literacy skill decile") xlabel(1(1)10.1, nogrid) ///
			legend(order(1 "Men: P75" 2 "Men: P50" 3 "Men: P25" 4 "Women: P75" ///
				5 "Women: P50" 6 "Women: P25")) ///
			scheme(tt_color)
		graph export "${path_figure}/pdf/lituse_dist_condon_lit_gender_`lbl'.pdf", as(pdf) replace
	}
restore
