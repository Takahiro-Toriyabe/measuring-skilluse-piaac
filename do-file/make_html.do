local path_root "D:/GitHub/Kawaguchi-Toriyabe-PIAAC"
local path_html "`path_root'/html"

shell python "`path_html'/convert.py"
markstat using "`path_html'/justify_worklit/justify_worklit_converted"

shell pandoc "`path_html'/justify_worklit/justify_worklit_converted.html" ///
	-o "`path_html'/justify_worklit/justify_worklit_converted.md"

shell sed -i -r "s/\ \{\.stata\}/Stata/" "`path_html'/justify_worklit/justify_worklit_converted.md"
