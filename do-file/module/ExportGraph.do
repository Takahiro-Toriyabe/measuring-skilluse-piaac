capture program drop ExportGraph
program define ExportGraph
	syntax namelist(min=1 max=1), path(string) [path_html(string)]
	foreach fmt in png pdf {
		graph export "`path'/`fmt'/`namelist'.`fmt'", replace
	}
	
	if "`path_html'" != "" {
		graph export "`path_html'/`namelist'.png", replace
	}
end
