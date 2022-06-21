use "${path_data}", clear
do "${path_do}/common/InitialSetting.do"
do "${path_do}/common/GenLabeledCntryID.do"
do "${path_do}/common/PutOccupLabel2.do"

replace worklit = . if work != 1
replace worknum = . if work != 1
replace lit = . if flag_paper_lit == 1
replace num = . if flag_paper_num == 1

label variable lit "Literacy skill"
label variable worklit "Literacy use"
label variable num "Numeracy skill"
label variable worknum "Numeracy use"

replace isco2c = . if isco2c >= 9995 | isco2c == 47
levelsof cntryid3letter if !missing(isco2c), local(clist)
local K = wordcount("`clist'")

levelsof isco2c, local(olist)
local I = wordcount("`olist'")

local vlist lit worklit num worknum
local J = wordcount("`vlist'")

local nmin = 2
local footnote ""

forvalues k = 1(1)`K' {
	local c: word `k' of `clist'
	local clbl: label cntryid3letter `c'
	
	tempname hh
	file open `hh' using "${path_table}/tmp/task_table`k'_sub.tex", write replace

	forvalues i = 1(1)`I' {
		local o: word `i' of `olist'
		local olbl: label isco2c `o'
		forvalues j = 1(1)`J' {
			local v: word `j' of `vlist'
			local vlbl: variable label `v'
			
			qui count if cntryid3letter == `c' & isco2c == `o' & !missing(`v')
			if r(N) < `nmin' {
				local b`j' = "& "
				local se`j' = "& "
			}
			else {
				qui mean `v' if cntryid3letter == `c' & isco2c == `o' & !missing(`v')
				local b`j' = "& " + strofreal(_b[`v'], "%04.3f")
				local se`j' = "& (" + strofreal(_se[`v'], "%04.3f") + ")"
			}
		}
		foreach x in b se {
			forvalues j = 1(1)`J' {
				if "`x'" == "b" & `j' == 1 {
					file write `hh' "		\multirow[t]{2}{8cm}{`olbl'} "
				}
				else {
					file write `hh' "		"
				}
				file write `hh' "``x'`j''"
			}
			file write `hh' " \\" _newline
		}
	}
	file close `hh'
}

forvalues k = 1(1)`K' {
	local c: word `k' of `clist'
	local clbl: label cntryid3letter `c'
	
	tempname hh
	file open `hh' using "${path_table}/tmp/task_table`k'.tex", write replace

	file write `hh' "\begin{scriptsize}" _newline
	file write `hh' "	\begin{longtable}{p{8cm}*{4}{c}}" _newline
	file write `hh' "		%       \centering" _newline
	file write `hh' "		\caption{Skill and skill use score: `clbl'} \\" _newline
	file write `hh' "		\label{tab:task_table`k'} \\" _newline
	file write `hh' "		\toprule \toprule" _newline
	file write `hh' "		Occupation & Literacy skill & Literacy use & Numeracy skill & Numeracy use \\" _newline
	file write `hh' "		& (1) & (2) & (3) & (4) \\" _newline
	file write `hh' "		\midrule" _newline
	file write `hh' "		\endfirsthead" _newline
	file write `hh' "		\toprule \toprule" _newline
	file write `hh' "		Occupation & Literacy skill & Literacy use & Numeracy skill & Numeracy use \\" _newline
	file write `hh' "		& (1) & (2) & (3) & (4) \\" _newline
	file write `hh' "		\midrule" _newline
	file write `hh' "		\endhead" _newline
	file write `hh' "		\bottomrule \bottomrule" _newline
	file write `hh' "		\endfoot" _newline
	file write `hh' "		\bottomrule \bottomrule \\" _newline
	file write `hh' "		\multicolumn{5}{l}{Note: `footnote'} \\" _newline
	file write `hh' "		\endlastfoot" _newline
	file write `hh' "		\primitiveinput{../table/tmp/task_table`k'_sub.tex}" _newline
	file write `hh' "	\end{longtable}" _newline
	file write `hh' "\end{scriptsize}" _newline
	file close `hh'
}
