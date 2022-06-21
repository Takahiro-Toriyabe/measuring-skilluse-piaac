* Sample restriction
drop if missing(child) | missing(work) | missing(educ) | missing(nativelang) | missing(impar)
drop if work == 1 & (missing(worklit) | missing(worknum))

foreach var in $inst5 {
	drop if missing(`var')
}

qui gen flag_paper_lit = paper == 1
qui gen flag_paper_num = paper == 2

qui gen imparent = .
qui replace imparent = 1 if impar == 1 | impar == 2
qui replace imparent = 0 if impar == 3

qui capture drop gdp_pc
qui gen gdp_pc = gdp_pc2011
qui replace gdp_pc = gdp_pc2012 if round2 == 1

* Convert leave durations into year
foreach tag in _protect _paid _equiv {
	gen tot`tag'_year = tot`tag' / 52
}

* Normalize skill and skill use
foreach var of varlist lit num {
	Normalize `var', by(cntryid)
}

foreach var of varlist worklit worknum {
	qui replace `var' = . if work == 0
	Normalize `var', by(cntryid)
}

* Skill-quantile variable

foreach var in lit num {
	foreach p in 25 50 75 {
		egen `var'`p' = pctile(`var'), p(`p') by(flag_paper_`var' country)
	}
	
	gen `var'cat = 1 if `var' <= `var'25 & !missing(`var')
	replace `var'cat = 2 if inrange(`var', `var'25, `var'50) & !missing(`var')
	replace `var'cat = 3 if inrange(`var', `var'50, `var'75) & !missing(`var')
	replace `var'cat = 4 if `var' >= `var'75 & !missing(`var')
	
	tab `var'cat, gen(`var'cat)
}

* Clustering group
egen cluster_lit = group(country litcat) 
egen cluster_num = group(country numcat) 
