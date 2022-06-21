// Take log
local dofile_name "clean_german_suf"
TakeLog `dofile_name', path("${path_log}")

// Clean German SUF
use "${path_german_suf}", clear

qui varcase _all

replace isic1c = "1" if (isic1c=="A")
replace isic1c = "2" if (isic1c=="B")
replace isic1c = "3" if (isic1c=="C")
replace isic1c = "4" if (isic1c=="D")
replace isic1c = "5" if (isic1c=="E")
replace isic1c = "6" if (isic1c=="F")
replace isic1c = "7" if (isic1c=="G")
replace isic1c = "8" if (isic1c=="H")
replace isic1c = "9" if (isic1c=="I")
replace isic1c = "10" if (isic1c=="J")
replace isic1c = "11" if (isic1c=="K")
replace isic1c = "12" if (isic1c=="L")
replace isic1c = "13" if (isic1c=="M")
replace isic1c = "14" if (isic1c=="N")
replace isic1c = "15" if (isic1c=="O")
replace isic1c = "16" if (isic1c=="P")
replace isic1c = "17" if (isic1c=="Q")
replace isic1c = "18" if (isic1c=="R")
replace isic1c = "19" if (isic1c=="S")
replace isic1c = "20" if (isic1c=="T")
replace isic1c = "21" if (isic1c=="U")

qui destring _all, replace force
foreach v of varlist _all {
	qui replace `v' = . if (inlist(`v', .a, .b, .c, .d, .e, .f, .g, .h, .i, .j, ///
		.k, .l, .m, .n, .o, .p, .q, .r, .s, .t, .u, .v, .w, .x, .y, .z)==1)
}

qui gen country = 9

qui rename h_q04A h_q04a
qui rename h_q04B h_q04b

rename u01A000s u01a000s
rename u01B000s u01b000s
rename u02X000s u02x000s
rename u03A000s u03a000s
rename u04A000s u04a000s
rename u06A000s u06a000s
rename u06B000s u06b000s
rename u07X000s u07x000s
rename u11B000s u11b000s
rename u16X000s u16x000s
rename u19A000s u19a000s
rename u19B000s u19b000s
rename u21X000s u21x000s
rename u23X000s u23x000s

rename f_q05A f_q05a
rename f_q05B f_q05b

rename g_q01A g_q01a
rename g_q01B g_q01b
rename g_q01C g_q01c
rename g_q01D g_q01d
rename g_q01E g_q01e
rename g_q01F g_q01f
rename g_q01G g_q01g
rename g_q01H g_q01h

rename g_q03B g_q03b
rename g_q03C g_q03c
rename g_q03D g_q03d
rename g_q03F g_q03f
rename g_q03G g_q03g
rename g_q03H g_q03h

rename g_q05A g_q05a
rename g_q05C g_q05c
rename g_q05D g_q05d
rename g_q05E g_q05e
rename g_q05F g_q05f
rename g_q05G g_q05g
rename g_q05H g_q05h

rename h_q01A h_q01a
rename h_q01B h_q01b
rename h_q01C h_q01c
rename h_q01D h_q01d
rename h_q01E h_q01e
rename h_q01F h_q01f
rename h_q01G h_q01g
rename h_q01H h_q01h

rename h_q03B h_q03b
rename h_q03C h_q03c
rename h_q03D h_q03d
rename h_q03F h_q03f
rename h_q03G h_q03g
rename h_q03H h_q03h

rename h_q05A h_q05a
rename h_q05C h_q05c
rename h_q05D h_q05d
rename h_q05E h_q05e
rename h_q05F h_q05f
rename h_q05G h_q05g
rename h_q05H h_q05h

rename d_q05A1 d_q05a1
rename d_q05B1 d_q05b1

rename c_q01A c_q01a
rename c_q01B c_q01b
rename c_q01C c_q01c
rename c_q02A c_q02a
rename c_q08A c_q08a
rename c_q08B c_q08b

rename j_q02A j_q02a

rename j_q03A j_q03a
rename j_q03B j_q03b

rename j_q06B j_q06b
rename j_q06B_t j_q06b_t
rename j_q07B j_q07b
rename j_q07B_t j_q07b_t
rename j_q02C j_q02c

rename d_q12A d_q12a
rename d_q12B d_q12b
rename f_q07A f_q07a

save "${path_data}/data9.dta", replace

log close
