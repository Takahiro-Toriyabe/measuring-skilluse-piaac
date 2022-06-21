capture program drop clean_subtable
program define clean_subtable
	syntax anything, [sed(string)] [depvar(string)] [key(string)]
	
	if "`sed'" == "" & "${sed}" != "" {
		local sed "${sed}"
	}
	else if "`sed'" == "" & "${sed}" == "" {
		local sed "C:/Program Files/Git/usr/bin/sed.exe"
	}
	
	shell "`sed'" -i -r -e "/^main/d" -e "/^model/d" "`anything'"
	shell "`sed'" -i -r -e "1,6s/hline(.*)hline/toprule\1toprule/g" "`anything'"
	shell "`sed'" -i -r -e "7,100s/hline(.*)hline/bottomrule\1bottomrule/g" "`anything'"
	shell "`sed'" -i -r -e "s/^(.)hline$/\1midrule/g" -e "s/\s{0,}\&\s{0,}/ \& /g" "`anything'"
	shell "`sed'" -i -r -e "s/^\s{1,}//" "`anything'"
	if "`depvar'" != "" & "`key'" != "" {
		shell "`sed'" -i -r -e "s/^(.*`key')/`depvar' \1/" "`anything'"
	}
end
