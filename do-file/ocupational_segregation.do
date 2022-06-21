
clear all
set more off
capture log close _all

set matsize 11000
graph set window fontface "Times New Roman"
set scheme tt_mono

// Set directory

local pardir1 "C:/Users/takah/Dropbox/PIAAC"
local pardir2 "D:/Dropbox/PIAAC"

local ndir = 1
local maxdir = 100
while 1 {
	if ("`pardir`ndir''"~="") {
		capture cd "`pardir`ndir''"
		if (_rc==0) {
			local pardir "`pardir`ndir''"
			continue, break
		}
		else {
			local ndir = `ndir' + 1
		}
	}
	else {
		local ndir = `ndir' + 1
	}
	if (`ndir'==`maxdir') {
		xxx
	}
}

local datadir "`pardir'/Data"
local tabdir "`pardir'/Tex"
local current_time = subinstr("`c(current_time)'", ":", "", 2)
local autname "Takahiro Toriyabe"


// Open log file

local dofile_name "occupational_segregation"
capture mkdir "`datadir'/log/log_`c(current_date)'"
log using "`datadir'/log/log_`c(current_date)'/`dofile_name'_`c(current_date)'_`current_time'.smcl", replace


// Read data

use "`datadir'/piaac_data_otheroutcomes.dta", clear

drop if (inlist(., child, work, educ, nativelang, impar)==1)
drop if (work==1)&(inlist(.,worklit,worknum,irt_taskdisc,irt_learning,irt_influence,irt_workwrite)==1)

qui gen imparent = .
qui replace imparent = 1 if (impar==1|impar==2)
qui replace imparent = 0 if (impar==3)

qui capture drop gdp_pc
qui gen gdp_pc = gdp_pc2011
qui replace gdp_pc = gdp_pc2012 if (round2==1)

// Convert leave durations into year

foreach tag in _protect _paid _equiv {
	gen tot`tag'_year = tot`tag' / 52
}

foreach v of varlist lit num {
	forvalues i = 1(1)30 {
		qui sum `v' if (cfe`i'==1)
		qui replace `v' = (`v' - r(mean))/r(sd) if (cfe`i'==1)
	}
}

foreach v of varlist worklit worknum {
	qui replace `v' = . if (work==0)
	forvalues i = 1(1)30 {
		qui sum `v' if (cfe`i'==1)
		qui replace `v' = (`v' - r(mean))/r(sd) if (cfe`i'==1)
	}
}

foreach v in lit num {
	foreach p in 25 50 75 {
		egen `v'`p' = pctile(`v'), p(`p') by(country)
	}
	
	gen `v'cat = 1 if (`v'<=`v'25)&(`v'~=.)
	replace `v'cat = 2 if (inrange(`v', `v'25, `v'50)==1)&(`v'~=.)
	replace `v'cat = 3 if (inrange(`v', `v'50, `v'75)==1)&(`v'~=.)
	replace `v'cat = 4 if (`v'>=`v'75)&(`v'~=.)
	
	tab `v'cat, gen(`v'cat)
}

egen cluster_lit = group(country litcat) 
egen cluster_num = group(country numcat) 


**** Full sample

qui gen depvar1 = .
qui gen depvar2 = .
qui gen Index = .
qui egen minworklit = min(worklit), by(country)
qui egen minworknum = min(worknum), by(country)

foreach tag in _protect _paid _equiv {
	gen tot`tag'_year_temp = tot`tag'_year
	sum tot`tag'_year, meanonly
	local tot`tag'_year_mean_main = r(mean)
}
qui gen ntax200_temp = ntax200
qui gen ccutil0_2_temp = ccutil0_2

replace isco2c = . if (inrange(isco2c,9995,9999)==1)
egen female_share = mean(female) if (work==1)&(isco2c~=.), by(country isco2c)
gen male_share = 1 - female_share if (work==1)&(isco2c~=.)

gen share_same_sex = female*female_share + (1-female)*male_share if (work==1)&(isco2c~=.)

gen plvar = .

local coeflabel_lit "Literacy"
local coeflabel_num "Numeracy"

foreach v of varlist lit num {
	eststo clear
	foreach tag in _paid_year _protect_year _equiv_year {
				
		qui replace depvar1 = work`v' if (work==1)
		qui replace depvar2 = work`v' if (work==1)
		qui replace depvar2 = minwork`v' if (work==0)
	
		foreach x of varlist gender_role mhousework tot`tag' ccutil0_2 ntax133 ntax200 emp_protect3 union_density ///
			pubsec ind3 ntax200_2001 childcare0_2_2006 tot`tag'_temp ccutil0_2_temp ntax200_temp gdp_pc {
			qui egen vartemp = mean(`x')
			qui replace `x' = `x' - vartemp
			qui drop vartemp
		}
		
		qui replace tot`tag' = tot`tag'_temp
		qui replace ntax200 = ntax200_temp
		qui replace ccutil0_2 = ccutil0_2_temp
	
		replace plvar = tot`tag'
			
		qui eststo: reg female_share ///
			c.(`v'cat1 `v'cat2 `v'cat3 `v'cat4)#c.female#c.plvar ///
			c.(`v'cat1 `v'cat2 `v'cat3 `v'cat4)#c.female ///
			c.(`v'cat1 `v'cat2 `v'cat3 `v'cat4)#c.female#c.( ///
				east ccutil0_2 ntax200 gender_role pubsec ind3 emp_protect3 union_density ///
			) ///
			c.(`v'cat1 `v'cat2 `v'cat3 `v'cat4)#c.( ///
				educ age30_34 age35_39 age40_44 age45_49 age50_54 age55_59 nativelang imparent ///
			) ///
			i.country#c.(`v'cat1 `v'cat2 `v'cat3 `v'cat4) ///				
			if (inlist(.,ccutil0_2,ntax200,gender_role,emp_protect3,union_density)==0)&(work==1), ///
			vce(cluster cluster_`v')
				
		test (c.`v'cat1#c.female#c.plvar==0) ///
			(c.`v'cat2#c.female#c.plvar==0) ///
			(c.`v'cat3#c.female#c.plvar==0) ///
			(c.`v'cat4#c.female#c.plvar==0)
						
	}
		
	# d;
		esttab using "`tabdir'/occupational_segregation_`v'.csv",
		replace se nogap label obslast b(%9.3f) se(%9.3f) nonotes star(* 0.1 ** 0.05 *** 0.01)
		keep(c.`v'cat1#c.female#c.plvar c.`v'cat2#c.female#c.plvar c.`v'cat3#c.female#c.plvar c.`v'cat4#c.female#c.plvar)
		order(c.`v'cat1#c.female#c.plvar c.`v'cat2#c.female#c.plvar c.`v'cat3#c.female#c.plvar c.`v'cat4#c.female#c.plvar)
		coeflabels(
			c.`v'cat1#c.female#c.plvar "\hphantom{Female} \$ \times \$ `coeflabel_`v'' skill: Q1" 
			c.`v'cat2#c.female#c.plvar "\hphantom{Female} \$ \times \$ `coeflabel_`v'' skill: Q2"
			c.`v'cat3#c.female#c.plvar "\hphantom{Female} \$ \times \$ `coeflabel_`v'' skill: Q3" 
			c.`v'cat4#c.female#c.plvar "\hphantom{Female} \$ \times \$ `coeflabel_`v'' skill: Q4"
		)
		mtitles("CB" "JP" "Equiv") ;
	# d cr
	
}

log close
