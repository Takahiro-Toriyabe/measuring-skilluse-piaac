use "${path_data}", clear
do "${path_do}/common/InitialSetting.do"
keep if work == 1

// Literacy
eststo clear
eststo est0: reg worklit c.female#c.(litcat1 litcat2 litcat3 litcat4) ///
	litcat1 litcat2 litcat3 litcat4 if flag_paper_lit == 0, ///
	noconstant cluster(cluster_lit)

coefplot (est0, keep(c.female#c.litcat*) baselevels levels(95)), ///
	ytitle("Skill group") ///
	xtitle("Gender gap in skill use") xlabel(-0.40(0.05)0.01, format(%03.2f)) ///
	xline(0, lc(gs6) lp(l)) ///
	coeflabels(c.female#c.litcat1 = "Q1" c.female#c.litcat2 = "Q2" ///
		c.female#c.litcat3 = "Q3" c.female#c.litcat4 = "Q4")

graph export "${path_figure}/pdf/skilluse_gap_by_skill_lit.pdf", replace as(pdf)
		
//Numeracy
eststo est1: reg worknum c.female#c.(numcat1 numcat2 numcat3 numcat4) ///
	numcat1 numcat2 numcat3 numcat4 if flag_paper_num == 0, ///
	noconstant cluster(cluster_num)

coefplot (est1, keep(c.female#c.numcat*) baselevels levels(95)), ///
	ytitle("Skill group") ///
	xtitle("Gender gap in skill use") xlabel(-0.40(0.05)0.01, format(%03.2f)) ///
	xline(0, lc(gs6) lp(l)) ///
	coeflabels(c.female#c.numcat1 = "Q1" c.female#c.numcat2 = "Q2" ///
		c.female#c.numcat3 = "Q3" c.female#c.numcat4 = "Q4")
		
graph export "${path_figure}/pdf/skilluse_gap_by_skill_num.pdf", replace as(pdf)
