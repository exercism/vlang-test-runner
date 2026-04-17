module main

fn sorted_lower(s string) []rune {
	mut r := s.to_lower().runes()
	r.sort()
	return r
}

fn find_anagrams(subject string, candidates []string) []string {
	target := sorted_lower(subject)
	mut result := []string{}
	for c in candidates {
		if c.to_lower() != subject.to_lower() && sorted_lower(c) == target {
			result << c
		}
	}
	return result
}
