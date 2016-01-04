use std::io;

use regex::Regex;

use day::Day;

pub struct Day05 {
    input: String,
}

#[allow(dead_code)]
impl Day05 {
    fn is_nice(string: &String) -> bool {
        Day05::has_pair_of_two_letters(string) &&
            Day05::has_letter_sandwich(string)
    }

    fn has_three_vowels(string: &String) -> bool {
        let three_vowels = Regex::new(r"[aeiou].*[aeiou].*[aeiou]").unwrap();
        three_vowels.is_match(string)
    }

    fn has_double_letters(string: &String) -> bool {
        string.as_bytes().windows(2).any(|win| win[0] == win[1])
    }

    fn has_no_substrings(string: &String) -> bool {
        !vec!["ab", "cd", "pq", "xy"].iter().any(|&s| string.contains(s))
    }

    fn has_pair_of_two_letters(string: &String) -> bool {
        string.as_bytes().windows(2).any(|win| {
            let s = String::from_utf8(win.to_vec()).unwrap();
            string.split(&s).count() > 2
        })
    }

    fn has_letter_sandwich(string: &String) -> bool {
        string.as_bytes().windows(3).any(|win| win[0] == win[2])
    }
}

impl Day for Day05 {
    fn new(input: String) -> Day05 {
        Day05 { input: input }
    }

    fn solve(&self) -> io::Result<i32> {
        Ok(self.input.lines().filter(|&s| Day05::is_nice(&s.to_string())).count() as i32)
    }
}

#[test]
fn test_nice() {
    assert!( Day05::is_nice(&"qjhvhtzxzqqjkmpb".to_string()));
    assert!( Day05::is_nice(&"xxyxx ".to_string()));
    assert!(!Day05::is_nice(&"uurcxstgmygtbstg ".to_string()));
    assert!(!Day05::is_nice(&"ieodomkazucvgmuy ".to_string()));
}
