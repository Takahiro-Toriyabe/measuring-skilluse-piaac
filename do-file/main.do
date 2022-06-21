/* README
   ==========================
   Author: Takahiro Toriyabe
   Date: 2022/06/22
   ==========================

   This is the code to replicate Daiji Kawaguchi and Takahiro Toriyabe (2022)
   "Measurements of Skill and Skill-use using PIAAC," Labour Economics.

   We used the following datasets:
       - PIAAC PUF: Avaiable from https://www.oecd.org/skills/piaac/data/
	   - PIAAC German SUF data: Proprietary data but one can get access via GESIS
	     (See https://www.gesis.org/en/piaac/rdc/data/national-scientific-use-files for details about application)
       - World Values Survey Wave 6
	   - European Values Study 2008
	   - OECD family database
	   - Working Conditions Laws Database of the International Labour Organization
	   - 20.1 O*NET dataset release (2015): Available from
	     https://ibs.org.pl/en/resources/occupation-classifications-crosswalks-from-onet-soc-to-isco/
		 To generate "isco08_2d.dta", which is used in measuring-skilluse-piaac/do-file/sec4.do,
		 Please follow Hardy, W., Keister, R. and Lewandowski, P. (2018). Educational upgrading,
		 structural change and the task composition of jobs in Europe. Economics Of Transition 26.
         (For details, you can find the paper here: https://onlinelibrary.wiley.com/doi/full/10.1111/ecot.12145)
		 We have modified some of the information obtained from O*NET, and USDOL/ETA has not approved,
		 endorsed, or tested these modifications.
   
   We used World Values Survey, European Values Study 2008, OECD family database
   and Working Conditions Laws Database to derive country-level variables as summrized
   in Table C1 in the paper, and also provided as dataset, "measuring-skilluse-piaac/data/inst.dta".
   
   
   ===========
   Dependency
   ===========
   
   Our graph scheme is partly based on Daniel Bischof, 2016. "BLINDSCHEMES: Stata module to
   provide graph schemes sensitive to color vision deficiency," Statistical Software Components S458251,
   Boston College Department of Economics, revised 07 Aug 2020. You can install this package by
   "ssc install blindschemes". After installing it, please copy and paste
   "measuring-skilluse-piaac/scheme/scheme-tt_color.scheme" and "measuring-skilluse-piaac/scheme/scheme-tt_mono.scheme"
   under your ado-file folder.
   
   
   ========
   Contact
   ========
   
   If you find any problem in running this program, please create a new issuse
   from https://github.com/Takahiro-Toriyabe/measuring-skilluse-piaac/issues
   
*/

clear all
log close _all

// Set the path of working directory
global pwd ""
do "${pwd}/do-file/config.do"

// Set the path to the German PIAAC SUF
global path_german_suf ""

// Data cleaning
do "${path_do}/clean_german_suf.do"
do "${path_do}/clean_piaac_puf.do"

// Analysis
do "${path_do}/sec2_4.do"
do "${path_do}/sec3_1.do"
do "${path_do}/sec3_2.do"
do "${path_do}/sec3_3.do"
do "${path_do}/sec4.do"
