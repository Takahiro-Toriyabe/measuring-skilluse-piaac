capture program drop estadd_spec
program define estadd_spec
	syntax , spec(integer)
	
	forvalues j = 1(1)`spec' {
		qui estadd local spec`j' = "X"
	}
end
