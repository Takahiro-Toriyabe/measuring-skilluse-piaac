capture program drop Normalize
program define Normalize
	syntax varlist(min=1 max=1 numeric) [if] [aw], [by(varlist)]

	marksample touse
	
	tempvar by_group
	if "`by'" == "" {
		qui gen `by_group' = 1 if `touse'
	}
	else {
		qui egen `by_group' = group(`by') if `touse'
	}
	
	tempname by_list
	qui levelsof `by_group', local(`by_list')
	foreach g in ``by_list'' {
		qui sum `varlist' [`weight'`exp'] if `touse' & `by_group' == `g'
		qui replace `varlist' = (`varlist' - `r(mean)') / `r(sd)' ///
			if `touse' & `by_group' == `g'
	}
end
