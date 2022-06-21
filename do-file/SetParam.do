// Path
global path_root "D:/GitHub/Kawaguchi-Toriyabe-PIAAC"
global path_do "${path_root}/do-file"
globa path_figure "${path_root}/figure"
global path_table "${path_root}/table"
global path_log "${path_root}/log"
global path_draft "${path_root}/draft"

global path_data "D:/Dropbox/PIAAC/Data/piaac_data_otheroutcomes.dta"

// Specify the path to the German PIAAC SUF
global path_german_suf ""

global sed "C:/Program Files/Git/usr/bin/sed.exe"

// Module
local file_list: dir "${path_do}/module" files "*.do", respectcase
foreach file in `file_list' {
	do "${path_do}/module/`file'"
}

// Graph parameters
global fig_w_main 3200
global fig_h_main 2400
global fig_w_html 600
global fig_h_html 450

graph set window fontface "Times New Roman"
set scheme tt_color

// Control variables in main analysis
global inst1 "east"
global inst2 "${inst1} pubsec ind3"
global inst3 "${inst2} ccutil0_2 ntax200 equal_right right_parttime"
global inst4 "${inst3} gender_role"
global inst5 "${inst4} emp_protect3 union_density"

global xvars "educ age30_34 age35_39 age40_44 age45_49 age50_54 age55_59 nativelang imparent"

global indepvar = "c.(\`skill'cat1 \`skill'cat2 \`skill'cat3 \`skill'cat4)#c.female#c.tot\`tag'" ///
	+ " c.(\`skill'cat1 \`skill'cat2 \`skill'cat3 \`skill'cat4)#c.female" ///
	+ " c.(\`skill'cat1 \`skill'cat2 \`skill'cat3 \`skill'cat4)#c.female#c.(\`inst')" ///
	+ " c.(\`skill'cat1 \`skill'cat2 \`skill'cat3 \`skill'cat4)#c.(${xvars})" ///
	+ " i.flag_paper_\`skill'#i.country#c.(\`skill'cat1 \`skill'cat2 \`skill'cat3 \`skill'cat4)"
	
global desc_lit "literacy"
global desc_num "numeracy"

// Other parameters
set more off
set matsize 11000
