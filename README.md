# measuring-skilluse-piaac

This repository provides the codes to replicate [Daiji Kawaguchi and Takahiro Toriyabe (2022) "Measurements of Skill and Skill-use using PIAAC", Labour Economics](https://www.sciencedirect.com/science/article/pii/S0927537122000884).

## Before running the code...

### Dataset

To run our code, please prepare the following dataset under `measuring-skilluse-piaac/data/`

- PIAAC PUF (csv format): Avaiable [here](https://www.oecd.org/skills/piaac/data/)
- PIAAC German SUF data: Proprietary data but you can get access via GESIS
    (See [this page](https://search.gesis.org/research_data/ZA5845) for details about data application)
- O\*NET dataset release (2015): Available [here](https://ibs.org.pl/en/resources/occupation-classifications-crosswalks-from-onet-soc-to-isco/).
    To generate `isco08_2d.dta`, which is used in `measuring-skilluse-piaac/do-file/sec4.do`, please follow [Hardy, W., Keister, R. and Lewandowski, P. (2018). Educational upgrading, structural change and the task composition of jobs in Europe. Economics Of Transition 26](https://onlinelibrary.wiley.com/doi/full/10.1111/ecot.12145). We have modified some of the information obtained from O\*NET, and USDOL/ETA has not approved,
    endorsed, or tested these modifications.

### Supplementary data

In addition to the above data, we used the following data to derive country-level variables. You can find the derived variables in `measuring-skilluse-piaac/data/inst.dta`.

- World Values Survey Wave 6
- European Values Study 2008
- OECD family database
- Working Conditions Laws Database of the International Labour Organization

### Program depenency

Our graph scheme is partly based on Daniel Bischof, 2016. "BLINDSCHEMES: Stata module to provide graph schemes sensitive to color vision deficiency," Statistical Software Components S458251, Boston College Department of Economics, revised 07 Aug 2020. You can install this package by `ssc install blindschemes`. After installing it, please copy and paste `measuring-skilluse-piaac/scheme/scheme-tt_color.scheme` and `measuring-skilluse-piaac/scheme/scheme-tt_mono.scheme` under your ado-file folder. (You can find your ado-file folder by typing `adopath` on the Stata interactive window.)

## How to run the code

After preparing data and installing the program described above, you can run `measuring-skilluse-piaac/do-file/main.do` by specifying the following two global macro:

- `pwd`: Path to `measuring-skilluse-piaac`
- `path_german_suf`: Path to German PIAAC SUF

Then, `measuring-skilluse-piaac/do-file/main.do` automatically runs all subsequent codes to clean data and generate figures and tables shown in the paper.

## Contact

If you have any problems in running the code, please create a new issue from [this page](https://github.com/Takahiro-Toriyabe/measuring-skilluse-piaac/issues).