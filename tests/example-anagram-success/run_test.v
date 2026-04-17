module main

fn test_no_matches() {
	candidates := ['hello', 'world', 'zombies', 'pants']
	expected := []string{}
	assert find_anagrams('diaper', candidates) == expected
}

fn test_detects_three_anagrams() {
	candidates := ['gallery', 'ballerina', 'regally', 'clergy', 'largely', 'leading']
	expected := ['gallery', 'regally', 'largely']
	assert find_anagrams('allergy', candidates) == expected
}

fn test_detects_anagrams_case_insensitively() {
	candidates := ['cashregister', 'Carthorse', 'radishes']
	expected := ['Carthorse']
	assert find_anagrams('Orchestra', candidates) == expected
}

fn test_different_characters_may_have_the_same_bytes() {
	candidates := ['€a']
	expected := []string{}
	assert find_anagrams('a⬂', candidates) == expected
}
