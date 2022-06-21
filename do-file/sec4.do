// Take log
local dofile_name "sec4"
TakeLog `dofile_name', path("${path_log}")

/* Import O*NET data
   For the crosswalk between O*NET occupation code and ISCO08 occupation code,
   I used the code provided by Hardy, W., Keister, R. and Lewandowski, P. (2018). Educational upgrading, structural change and the task composition of jobs in Europe. Economics Of Transition 26.
   For details, you can find the paper here: https://onlinelibrary.wiley.com/doi/full/10.1111/ecot.12145
   
   This code uses information from the O*NET 26.1
   Database (https://www.onetcenter.org/database.html) by the U.S. Department of Labor,
   Employment and Training Administration (USDOL/ETA). Used under the CC BY 4.0 license
   (https://creativecommons.org/licenses/by/4.0/). O*NETR is a trademark of USDOL/ETA. We
   have modified all or some of this information. USDOL/ETA has not approved, endorsed, or
   tested these modifications.
*/
use "${path_data}/isco08_2d.dta", clear

rename t_1A2a2 onet_ability_num
rename t_1A1a2 onet_ability_lit
rename t_2A1e onet_skill_num
rename t_2A1a onet_skill_lit

keep isco2c onet_*

tempfile tmp
save `tmp', replace

use "${path_data}/piaac_main.dta", clear
do "${path_do}/common/InitialSetting.do"

keep if cntryid == 840 & isco2c < 100
replace lit = . if flag_paper_lit == 1
replace num = . if flag_paper_num == 1
replace worklit = . if work != 1
replace worknum = . if work != 1

collapse (mean) lit num worklit worknum (count) nworklit=worklit nworknum=worknum, by(isco2c)
merge 1:1 isco2c using `tmp', keep(3) nogen

// Figure 12 (a)
gsort - worklit
gen piaac_skill_lit_rank = _n
gsort - onet_skill_lit
gen onet_skill_lit_rank = _n

twoway (scatter piaac_skill_lit_rank onet_skill_lit_rank [aw=nworklit], color(gs3) msize(*0.8)) ///
	(function y = x, range(0 40) lp(l) lc(gs10)), ///
	ytitle("Rank in PIAAC") ylabel(0(5)40) ///
	xtitle("Rank in O*NET") xlabel(0(5)40.2) ///
	legend(off) 

// Figure 12 (b)
gsort - worknum
gen piaac_skill_num_rank = _n
gsort - onet_skill_num
gen onet_skill_num_rank = _n

twoway (scatter piaac_skill_num_rank onet_skill_num_rank [aw=nworknum], color(gs3) msize(*0.8)) ///
	(function y = x, range(0 40) lp(l) lc(gs10)), ///
	ytitle("Rank in PIAAC") ylabel(0(5)40) ///
	xtitle("Rank in O*NET") xlabel(0(5)40.2) ///
	legend(off) 

log close `dofile_name'
