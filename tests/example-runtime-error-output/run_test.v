module main

fn test_negative_year_prints_error() {
	assert !is_leap_year(-1)
}

fn test_divisible_by_100_not_by_400() {
	assert !is_leap_year(1900)
}
