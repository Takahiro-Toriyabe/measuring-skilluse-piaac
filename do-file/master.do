clear all
log close _all

// Set the path of working directory
local pwd "D:/GitHub/Kawaguchi-Toriyabe-PIAAC/do-file"
do "`pwd'/SetParam.do"
do "${path_do}/var_germany.do"
do "${path_do}/cross_country_variable.do"

* Estimation
do "${path_do}/justify_skilluse.do"
do "${path_do}/scatter_plot_quantile.do"

do "${path_do}/mismatch.do"
do "${path_do}/mismatch_robust.do"
do "${path_do}/check_reverse_causality.do"
do "${path_do}/other_skilluse.do"
do "${path_do}/market_outcomes.do"
do "${path_do}/check_human_capital_depreciation.do"
do "${path_do}/occupation_subordinates.do"

* Other
do "${path_do}/summarize_country_level_var.do"
do "${path_do}/fig_lfp_ssu_skill.do"
