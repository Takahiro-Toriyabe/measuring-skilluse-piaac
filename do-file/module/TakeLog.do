capture program drop TakeLog
program define TakeLog
	syntax namelist(min=1 max=1) , path(string)
	
	capture log close `namelist'
	_GetTimeStamp
	
	capture mkdir "`path'/`r(Date)'"
	log using "`path'/`r(Date)'/`namelist'_`r(TimeStamp)'.smcl", ///
		replace name(`namelist')
end

capture program drop _GetTimeStamp
program define _GetTimeStamp, rclass
	tempname d t date time tstamp
	
	local `d' = td(`c(current_date)')
	local `t' = tc(`c(current_time)')
	
	local `date' = string(year(``d'')) + string(month(``d''), "%02.0f") ///
		+ string(day(``d''), "%02.0f")
	local `time' = string(hh(``t''), "%02.0f") + string(mm(``t''), "%02.0f") ///
		+ string(ss(``t''), "%02.0f")
	local `tstamp' = "``date''" + "_" + "``time''"

	
	return local Date ``date''
	return local Time ``time''
	return local TimeStamp ``tstamp''
end
