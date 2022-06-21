capture program drop ExportStat
program define ExportStat
	syntax varlist(max=1 numeric) [aweight fweight] [if] , ///
		saving(string) /// File name stored
		[stat(string)] /// Statistics (Default: mean)
		[format(string)] /// Format (Defalut: %12.0g)
	
	marksample touse
	
	* Statistics
	if ("`stat'"=="") {
		local stat "mean"
	}
	
	* Format
	if ("`format'"=="") {
		local format "%12.0g"
	}
	
	_ExportStatSub `varlist' if `touse', stat(`stat') format(`format') saving("`saving'_all.tex")
	
	_ExportStatSub `varlist' if `touse' & female, stat(`stat') format(`format') saving("`saving'_female.tex")
	
	_ExportStatSub `varlist' if `touse' & !female, stat(`stat') format(`format') saving("`saving'_male.tex")
			
end

capture program drop _ExportStatSub
program define _ExportStatSub
	syntax varlist(max=1 numeric) [aweight fweight] [if] , ///
		saving(string) /// File name stored
		[stat(string)] /// Statistics (Default: mean)
		[format(string)] /// Format (Defalut: %12.0g)
	
	marksample touse
	
	qui sum `varlist' ``wt'' if `touse' , detail
	
	tempname hh
	file open `hh' using "`saving'", write replace
	file write `hh' `format' (r(`stat')) "%"
	file close `hh'
end
