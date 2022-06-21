// Path
global path_do "${pwd}/do-file"
global path_log "${pwd}/log"
global path_data "${pwd}/data"

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
capture set scheme tt_color

// Control variables in main analysis
global inst1 "east pubsec ind3"
global inst2 "${inst1} ccutil0_2 ntax200 equal_right right_parttime"
global inst3 "${inst2} gender_role"
global inst4 "${inst3} emp_protect3 union_density"

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
