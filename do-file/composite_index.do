clear all
set more off
set matsize 11000

use "D:/GitHub/PIAAC-Cleaning/data/dta/piaac_skill.dta" , clear

keep if inlist(cntryid, 40, 56, 152, 203, 208, 233, 246, 250, 276, 300, 372, ///
	380, 392, 410, 528, 554, 578, 616, 703, 705, 724, 752, 826, 840)

rename g_q01a readwork1
rename g_q01b readwork2
rename g_q01c readwork3
rename g_q01d readwork4
rename g_q01e readwork5
rename g_q01f readwork6
rename g_q01g readwork7
rename g_q01h readwork8

rename g_q03b numwork1
rename g_q03c numwork2
rename g_q03d numwork3
rename g_q03f numwork4
rename g_q03g numwork5
rename g_q03h numwork6

order readwork* numwork* cl1-cl49 cn1-cn49

gen cogabil = .
gen coguse = .

gen work_flag = .
replace work_flag = 1 if (c_q01a==1|c_q01b==1)|(c_q01c==1)
replace work_flag = 2 if (c_q08a==1&c_q08b==1)
replace work_flag = 3 if (c_q08a==1&c_q08b==2)
replace work_flag = 4 if (c_q08a==2)

gen work = work_flag
replace work = 0 if (inlist(work_flag, 2, 3, 4)==1)

levelsof cntryid, local(cntry_list)
foreach c in `cntry_list' {
	display "{bf:cntryid = `c'}"
	tempvar abil use
	
	irt 2pl cl1-cl49 cn1-cn49 if cntryid == `c'
	predict `abil', latent
	replace cogabil = `abil' if e(sample)
	
	irt gpcm readwork1-readwork8 numwork1-numwork6 if cntryid == `c' & work == 1
	predict `use', latent
	replace coguse = `use' if e(sample)
}

gen flag_cl = !missing(abil_cl) & missing(abil_cn)
gen flag_cn = missing(abil_cl) & !missing(abil_cn)
gen flag_cl_cn = !missing(abil_cl) & !missing(abil_cn)
gen flag_pl = !missing(abil_pl)
gen flag_pn = !missing(abil_pn)

foreach tag in _pl _pn {
	foreach c in `cntry_list' {
		qui sum abil`tag' if flag`tag' & cntryid == `c'
		replace abil`tag' = (abil`tag' - r(mean)) / r(sd) ///
			if flag`tag' & cntryid == `c'
	}
	replace cogabil = abil`tag' if flag`tag'
}

save "D:/Dropbox/PIAAC/Data/piaac_cog_tmp.dta", replace

use "D:/Dropbox/PIAAC/Data/piaac_cog_tmp.dta", clear
keep cntryid seqid cogabil coguse flag_cl flag_cn flag_cl_cn flag_pl flag_pn

merge 1:1 cntryid seqid using "D:/Dropbox/PIAAC/Data/piaac_data_otheroutcomes.dta"
keep if _merge == 3

levelsof cntryid, local(cntry_list)
foreach c in `cntry_list' {
	foreach var in cogabil coguse {
		qui sum `var' if cntryid == `c'
		qui replace `var' = (`var' - r(mean)) / r(sd) if cntryid == `c'
	}
}

foreach v in cogabil {
	foreach p in 25 50 75 {
		egen `v'`p' = pctile(`v'), p(`p') by(cntryid)
	}
	
	gen `v'cat = 1 if (`v'<=`v'25)&(`v'~=.)
	replace `v'cat = 2 if (inrange(`v', `v'25, `v'50)==1)&(`v'~=.)
	replace `v'cat = 3 if (inrange(`v', `v'50, `v'75)==1)&(`v'~=.)
	replace `v'cat = 4 if (`v'>=`v'75)&(`v'~=.)
	
	tab `v'cat, gen(`v'cat)
	egen cluster_`v' = group(cntryid `v'cat) 
}

qui egen min_score = min(coguse), by(cntryid)
qui gen depvar1 = .
qui gen depvar2 = .

foreach tag in _protect _paid _equiv {
	gen tot`tag'_year = tot`tag' / 52
}
foreach tag in _protect _paid _equiv {
	gen tot`tag'_year_temp = tot`tag'_year
	sum tot`tag'_year, meanonly
	local tot`tag'_year_mean_main = r(mean)
}
qui gen ntax200_temp = ntax200
qui gen ccutil0_2_temp = ccutil0_2
qui gen gdp_pc = gdp_pc2011
qui replace gdp_pc = gdp_pc2012 if (round2==1)

qui gen imparent = .
qui replace imparent = 1 if (impar==1|impar==2)
qui replace imparent = 0 if (impar==3)

foreach v of varlist cogabil {
	foreach tag in _paid_year {
				
		qui replace depvar1 = coguse if (work==1)
		qui replace depvar2 = coguse if (work==1)
		qui replace depvar2 = min_score if (work==0)

		eststo clear
	
		foreach x of varlist gender_role mhousework tot`tag' ccutil0_2 ntax133 ntax200 emp_protect3 union_density ///
			pubsec ind3 ntax200_2001 childcare0_2_2006 tot`tag'_temp ccutil0_2_temp ntax200_temp gdp_pc {
			qui egen vartemp = mean(`x')
			qui replace `x' = `x' - vartemp
			qui drop vartemp
		}
		
		qui replace tot`tag' = tot`tag'_temp
		qui replace ntax200 = ntax200_temp
		qui replace ccutil0_2 = ccutil0_2_temp

		local xvars "educ age30_34 age35_39 age40_44 age45_49 age50_54 age55_59 nativelang imparent flag_cl flag_cn flag_cl_cn flag_pl flag_pn"

		// Specification 5: Specification 4 + Labor market institutions 2
		
		eststo: intreg depvar1 depvar2 ///
			c.(`v'cat1 `v'cat2 `v'cat3 `v'cat4)#c.female#c.tot`tag' ///
			c.(`v'cat1 `v'cat2 `v'cat3 `v'cat4)#c.female ///
			c.(`v'cat1 `v'cat2 `v'cat3 `v'cat4)#c.female#c.( ///
				east ccutil0_2 ntax200 gender_role pubsec ind3 emp_protect3 union_density ///
			) ///
			c.(`v'cat1 `v'cat2 `v'cat3 `v'cat4)#c.(`xvars') ///
			i.country#c.(`v'cat1 `v'cat2 `v'cat3 `v'cat4) ///
			if (inlist(.,ccutil0_2,ntax200,gender_role,emp_protect3,union_density)==0), ///
			vce(cluster cluster_`v') het(cfe*, nocons)
			
		eststo: reg coguse ///
			c.(`v'cat1 `v'cat2 `v'cat3 `v'cat4)#c.female#c.tot`tag' ///
			c.(`v'cat1 `v'cat2 `v'cat3 `v'cat4)#c.female ///
			c.(`v'cat1 `v'cat2 `v'cat3 `v'cat4)#c.female#c.( ///
				east ccutil0_2 ntax200 gender_role pubsec ind3 emp_protect3 union_density ///
			) ///
			c.(`v'cat1 `v'cat2 `v'cat3 `v'cat4)#c.(`xvars') ///
			i.country#c.(`v'cat1 `v'cat2 `v'cat3 `v'cat4) ///
			if (inlist(.,ccutil0_2,ntax200,gender_role,emp_protect3,union_density)==0)&(work==1), ///
			vce(cluster cluster_`v') 
								

		# d;
			esttab,
			replace se nogap label obslast b(%9.3f) se(%9.3f) nonotes star(* 0.1 ** 0.05 *** 0.01)
			keep(c.`v'cat1#c.female#c.tot`tag' c.`v'cat2#c.female#c.tot`tag' c.`v'cat3#c.female#c.tot`tag' c.`v'cat4#c.female#c.tot`tag')
			order(c.`v'cat1#c.female#c.tot`tag' c.`v'cat2#c.female#c.tot`tag' c.`v'cat3#c.female#c.tot`tag' c.`v'cat4#c.female#c.tot`tag')
			coeflabels(
				c.`v'cat1#c.female#c.tot`tag' "Skill: Q1" 
				c.`v'cat2#c.female#c.tot`tag' "Skill: Q2"
				c.`v'cat3#c.female#c.tot`tag' "Skill: Q3" 
				c.`v'cat4#c.female#c.tot`tag' "Skill: Q4"
			)
			mtitle("All" "Employed")
			;
		# d cr
	}
}

