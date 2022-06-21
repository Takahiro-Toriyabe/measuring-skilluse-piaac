
clear all
set more off
capture log close _all

set matsize 11000
graph set window fontface "Times New Roman"
set scheme tt_mono

// Set directory

local rawdir "F:/PIAAC"
local outdir "C:/Users/takah/Dropbox/PIAAC/Data"

local pardir1 "D:/GitHub/Kawaguchi-Toriyabe-PIAAC"

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

local datadir "`pardir'/data"
local logdir "`pardir'/log"
local figdir "`pardir'/figure"
local tabdir "`pardir'/table"
local current_time = subinstr("`c(current_time)'", ":", "", 2)
local autname "Takahiro Toriyabe"

local dofile_name "make_indices"


// Open log file

capture mkdir "`logdir'/log_`c(current_date)'"
log using "`logdir'/log_`c(current_date)'/`dofile_name'_`c(current_date)'_`current_time'.smcl", replace


// Share of housework between spouses (ISSP)

use "`rawdir'/ISSP/issp.dta", clear

gen country = .
replace country = 1 if (V4==36)
replace country = 2 if (V4==56)
replace country = 3 if (V4==124)
replace country = 4 if (V4==152)
replace country = 5 if (V4==196)
replace country = 6 if (V4==203)
replace country = 7 if (V4==208)
replace country = 8 if (V4==233)
replace country = 9 if (V4==246)
replace country = 10 if (V4==250)
replace country = 11 if (V4==276)
replace country = 12 if (V4==300)
replace country = 13 if (V4==372)
replace country = 14 if (V4==376)
replace country = 15 if (V4==380)
replace country = 16 if (V4==392)
replace country = 17 if (V4==410)
replace country = 18 if (V4==440)
replace country = 19 if (V4==528)
replace country = 20 if (V4==554)
replace country = 21 if (V4==578)
replace country = 22 if (V4==616)
replace country = 23 if (V4==643)
replace country = 24 if (V4==702)
replace country = 25 if (V4==703)
replace country = 26 if (V4==705)
replace country = 27 if (V4==724)
replace country = 28 if (V4==752)
replace country = 29 if (V4==792)
replace country = 30 if (V4==826)
replace country = 31 if (V4==840)

drop if (country==.)

gen id_temp = _n

gen female = SEX - 1
replace female = . if (SEX==9)

gen marital = .
replace marital = 1 if (inlist(MARITAL, 1, 2)==1)
replace marital = 0 if (inlist(MARITAL, 3, 4, 5, 6)==1)

forvalues i = 42(1)47 {
	gen housework`i' = .
	replace housework`i' = 0*female + 1.0*(1-female) if (V`i'==1)&(marital==1)
	replace housework`i' = 0.25*female + 0.75*(1-female) if (V`i'==2)&(marital==1)
	replace housework`i' = 0.5 if (V`i'==3|V`i'==6)&(marital==1)
	replace housework`i' = 0.75*female + 0.25*(1-female) if (V`i'==4)&(marital==1)
	replace housework`i' = 1.0*female + 0.0*(1-female) if (V`i'==5)&(marital==1)
}

gen housework = housework42 + housework43 + housework44 + housework45 + housework46 + housework47
replace housework = housework/4
egen mhousework = mean(housework), by(country)

duplicates drop country, force

keep country mhousework

save "`outdir'/issp_index.dta", replace


// Indices from OECD database

import excel "`outdir'/index_institution.xlsx", sheet("Sheet1") firstrow clear

save "`outdir'/index_institution.dta", replace


// Gender norms (European Values Survey)

use "`outdir'/evs_wave4.dta", clear

gen country_temp = .
replace country_temp = 1 if (country==36)
replace country_temp = 2 if (country==56)
replace country_temp = 3 if (country==124)
replace country_temp = 4 if (country==203)
replace country_temp = 5 if (country==208)
replace country_temp = 6 if (country==233)
replace country_temp = 7 if (country==246)
replace country_temp = 8 if (country==250)
replace country_temp = 9 if (country==276)
replace country_temp = 10 if (country==372)
replace country_temp = 11 if (country==380)
replace country_temp = 12 if (country==392)
replace country_temp = 13 if (country==410)
replace country_temp = 14 if (country==528)
replace country_temp = 15 if (country==578)
replace country_temp = 16 if (country==616)
replace country_temp = 17 if (country==643)
replace country_temp = 18 if (country==703)
replace country_temp = 19 if (country==724)
replace country_temp = 20 if (country==752)
replace country_temp = 21 if (country==826)
replace country_temp = 22 if (country==840)
replace country_temp = 23 if (country==196)
replace country_temp = 24 if (country==152)
replace country_temp = 25 if (country==300)
replace country_temp = 26 if (country==376)
replace country_temp = 27 if (country==440)
replace country_temp = 28 if (country==554)
replace country_temp = 29 if (country==702)
replace country_temp = 30 if (country==705)
replace country_temp = 31 if (country==792)

drop if (country_temp==.)

gen gender_role_temp = .
replace gender_role_temp = 1 if (v103==1)
replace gender_role_temp = 0 if (v103==3)
replace gender_role_temp = -1 if (v103==2)
	// When jobs are scarce, men should have more right to work than women.
	// Agree -> 1
	// Neither -> 0
	// Disagree -> -1

egen gender_role = mean(gender_role_temp), by(country_temp)

gen fracgr_temp = .
replace fracgr_temp = 1 if (v103==1)
replace fracgr_temp = 0 if (v103==2|v103==3)
egen fracgr = mean(fracgr_temp), by(country_temp)

keep country_temp gender_role 

rename country_temp country

gen wvs_flag = 0

save "`outdir'/evs_temp.dta", replace


// Gender norms (World Values Survey)

use "`outdir'/wvs_wave6.dta", clear

gen country = .
replace country = 1 if (V2==36)
replace country = 2 if (V2==56)
replace country = 3 if (V2==124)
replace country = 4 if (V2==203)
replace country = 5 if (V2==208)
replace country = 6 if (V2==233)
replace country = 7 if (V2==246)
replace country = 8 if (V2==250)
replace country = 9 if (V2==276)
replace country = 10 if (V2==372)
replace country = 11 if (V2==380)
replace country = 12 if (V2==392)
replace country = 13 if (V2==410)
replace country = 14 if (V2==528)
replace country = 15 if (V2==578)
replace country = 16 if (V2==616)
replace country = 17 if (V2==643)
replace country = 18 if (V2==703)
replace country = 19 if (V2==724)
replace country = 20 if (V2==752)
replace country = 21 if (V2==826)
replace country = 22 if (V2==840)
replace country = 23 if (V2==196)
replace country = 24 if (V2==152)
replace country = 25 if (V2==300)
replace country = 26 if (V2==376)
replace country = 27 if (V2==440)
replace country = 28 if (V2==554)
replace country = 29 if (V2==702)
replace country = 30 if (V2==705)
replace country = 31 if (V2==792)

drop if (country==.)

gen gender_role_temp = 2 - V45
	// jobs are scarce; giving men priority
	// Agree -> 1
	// Neither -> 0
	// Disagree -> -1
	
egen gender_role = mean(gender_role_temp), by(country)

keep country gender_role 

gen wvs_flag = 1


// Append World Values Survey and European Values Survey

append using "`outdir'/evs_temp.dta"
egen doublecount = mean(wvs_flag), by(country)
drop if (doublecount<1)&(doublecount>0)&(wvs_flag==0)

duplicates drop country, force
drop wvs_flag doublecount


// Merge indices from the OECD database

capture drop _merge
merge 1:1 country using "`outdir'/index_institution.dta"
drop _merge

replace union_density = union_density/100
replace ntax133 = ntax133/100
replace ntax200 = ntax200/100
replace mlv_pymnt = mlv_pymnt/100
replace plv_pymnt = plv_pymnt/100

save "`outdir'/index.dta", replace








