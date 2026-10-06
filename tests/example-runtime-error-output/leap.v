module main

fn is_leap_year(year int) bool {
	if year < 0 {
		println('error: negative year')
	}
	return year % 4 == 0
}
