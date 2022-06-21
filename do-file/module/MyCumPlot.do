capture program drop MyCumPlot
program define MyCumPlot
	syntax varlist(min=1 max=1 numeric) [if], ///
		by(varlist min=1 max=1 numeric) ///
		xtitle(string) ///
		[legend_pos(string)]
	
	tempname line_opt1 line_opt2 line_opt3 line_opt4 line_opt5 line_opt6 ///
		line_opt7 line_opt8 line_opt9 line_opt10
		
	local `line_opt1' "lp(l) lc(gs3)"
	local `line_opt2' `"lp("-##") lc(gs3)"'
	local `line_opt3' "lp(l) lc(gs10)"
	local `line_opt4' `"lp("-##") lc(gs10)"'
	local `line_opt5' "lp(l) lc(sky)"
	local `line_opt6' `"lp("-##") lc(sky)"'
	local `line_opt7' "lp(l) lc(ananas)"
	local `line_opt8' `"lp("-##") lc(ananas)"'
	local `line_opt9' "lp(l) lc(reddish)"
	local `line_opt10' `"lp("-##") lc(reddish)"'
	
	marksample touse
	
	tempvar cum
	bysort `by': cumul `varlist', gen(`cum')
	
	tempname legend_list cnt val_list val_lab twoway_line
	local `legend_list' ""
	local `twoway_line' "twoway"
	local `cnt' = 0

	qui levelsof `by', local(`val_list')
	foreach val in ``val_list'' {
		local ``cnt'++'
		local `val_lab': label `by' `val'
		local `legend_list' `"``legend_list'' ``cnt'' "``val_lab''""'
		local `twoway_line' "``twoway_line'' (line `cum' `varlist' if `by' == `val', sort ``line_opt``cnt'''')"
	}

	``twoway_line'', ///
		ytitle("CDF") ylabel(0(0.1)1, nogrid format(%02.1f)) ///
		xtitle("`xtitle'") xlabel(-3(1)3, nogrid format(%01.0f)) ///
		legend(order(``legend_list'') `legend_pos') ///
		scheme(tt_color)
end
