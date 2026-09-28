module main

fn test_divisible_by_4__and_5() {
	assert is_leap_year(1960)
}

fn test_divisible_by_2__not__by_4() {
	assert !is_leap_year(1970)
}

fn test_divisible_by_4__not_by_100() {
	assert is_leap_year(1996)
}

fn test_divisible_by_100__not_by_125() {
	assert is_leap_year(2400)
}
