clear all
set more off
set obs 38

gen cntryid = .
replace cntryid = 36 if _n == 1
replace cntryid = 40 if _n == 2
replace cntryid = 56 if _n == 3
replace cntryid = 124 if _n == 4
replace cntryid = 152 if _n == 5
replace cntryid = 203 if _n == 6
replace cntryid = 208 if _n == 7
replace cntryid = 233 if _n == 8
replace cntryid = 246 if _n == 9
replace cntryid = 250 if _n == 10
replace cntryid = 276 if _n == 11
replace cntryid = 300 if _n == 12
replace cntryid = 348 if _n == 13
replace cntryid = 352 if _n == 14
replace cntryid = 372 if _n == 15
replace cntryid = 376 if _n == 16
replace cntryid = 380 if _n == 17
replace cntryid = 392 if _n == 18
replace cntryid = 410 if _n == 19
replace cntryid = 442 if _n == 20
replace cntryid = 484 if _n == 21
replace cntryid = 528 if _n == 22
replace cntryid = 554 if _n == 23
replace cntryid = 578 if _n == 24
replace cntryid = 616 if _n == 25
replace cntryid = 620 if _n == 26
replace cntryid = 643 if _n == 27
replace cntryid = 703 if _n == 28
replace cntryid = 705 if _n == 29
replace cntryid = 724 if _n == 30
replace cntryid = 752 if _n == 31
replace cntryid = 756 if _n == 32
replace cntryid = 792 if _n == 33
replace cntryid = 826 if _n == 34
replace cntryid = 840 if _n == 35

* Countries in PIAAC but not in OECD Employment Outlook
replace cntryid = 196 if _n == 36
replace cntryid = 440 if _n == 37
replace cntryid = 702 if _n == 38

* Flag to compare with Blau and Kahn (2013, AER)
gen flag_us = cntryid == 35
gen flag_non_us = inlist(_n, 3, 4, 7, 9, 10, 11, 12, 15, 17, 20, 22, 23, 24, 26, 30, 34)

* Main variables
gen equal_right = inlist(_n, 2, 3, 4, 5, 8, 9, 10, 11, 12, 13, 15, 17, 18, ///
	19, 20 22, 24, 25, 26, 28, 29, 30, 31, 33, 34) ///
	if !inlist(_n, 14, 16, 27, 36, 37, 38)

gen right_parttime = inlist(_n, 3, 10, 12, 13, 18, 22, 25, 29, 30) ///
	if !inlist(_n, 36, 37, 38)
	// I use "Parents" and "N" for the right to work part-time to be ///
	/// consistent with Blau and Kahn (2013) 

// Validity check
/*
	According to Blau and Kahn (2013)
	
	1. US does not have "equal right" or "right to part-time"
	2. Twelve non-US countries have "equal right"
	3. Five non-US countries have "right to part-time"
*/

assert equal_right == 0 & right_parttime == 0 if flag_us

count if flag_non_us & equal_right == 1
assert r(N) == 12

count if flag_non_us & right_parttime == 1
assert r(N) == 5

keep cntryid equal_right right_parttime

save "D:/GitHub/Kawaguchi-Toriyabe-PIAAC/data/parttime_right.dta", replace
