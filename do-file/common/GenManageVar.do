replace d_q08a = d_q08A if cntryid == 276
replace d_q08b = d_q08B if cntryid == 276

gen manage = 0 if d_q08a == 2 | d_q07a == 2
replace manage = 1 if inlist(d_q08b, 1, 2) | d_q07b == 1
replace manage = 2 if inrange(d_q08b, 3, 5) | inrange(d_q07b, 2, 5)

label define manage 0 "None" 1 "1-10" 2 "11 or more"
label values manage manage
		
forvalues n = 0(1)2 {
	gen manage`n' = manage == `n' if !missing(manage)
}
