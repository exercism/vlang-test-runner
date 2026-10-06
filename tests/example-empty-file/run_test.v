module main

fn test_not_divisible_by_4() {
	assert !is_leap_year(2015)
}

fn test_divisible_by_2_not_by_4() {
	assert !is_leap_year(1970)
}
