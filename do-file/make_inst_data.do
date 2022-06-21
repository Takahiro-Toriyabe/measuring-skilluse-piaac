use "${path_data}", clear 
do "${path_do}/common/InitialSetting.do"
do "${path_do}/common/GenLabeledCntryID.do"

duplicates drop cntryid,force
keep cntryid pubsec ind3 ccutil0_2 ntax200 equal_right right_parttime gender_role emp_protect3 union_density
sort cntryid

save "D:/GitHub/Kawaguchi-Toriyabe-PIAAC/data/inst.dta", replace
