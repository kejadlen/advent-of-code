#![allow(dead_code)]

use regex::Regex;

pub fn solve(input: &str) -> i32 {
  input.lines().filter(|&s| is_nice(&s.to_string())).count() as i32
}

fn is_nice(string: &str) -> bool {
  has_pair_of_two_letters(string) && has_letter_sandwich(string)
}

fn has_three_vowels(string: &str) -> bool {
  let three_vowels = Regex::new(r"[aeiou].*[aeiou].*[aeiou]").unwrap();
  three_vowels.is_match(string)
}

fn has_double_letters(string: &str) -> bool {
  string.as_bytes().windows(2).any(|win| win[0] == win[1])
}

fn has_no_substrings(string: &str) -> bool {
  !vec!["ab", "cd", "pq", "xy"].iter().any(|&s| string.contains(s))
}

fn has_pair_of_two_letters(string: &str) -> bool {
  string.as_bytes().windows(2).any(|win| {
    let s = String::from_utf8(win.to_vec()).unwrap();
    string.split(&s).count() > 2
  })
}

fn has_letter_sandwich(string: &str) -> bool {
  string.as_bytes().windows(3).any(|win| win[0] == win[2])
}

#[test]
fn test_nice() {
  assert!(is_nice(&"qjhvhtzxzqqjkmpb".to_string()));
  assert!(is_nice(&"xxyxx ".to_string()));
  assert!(!is_nice(&"uurcxstgmygtbstg ".to_string()));
  assert!(!is_nice(&"ieodomkazucvgmuy ".to_string()));
}
