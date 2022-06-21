capture program drop estadd_spec
program define estadd_spec
	syntax , spec(integer)
	local J = `spec' + 1
	forvalues j = 1(1)`J' {
		qui estadd local spec`j' = "X"
	}
end
