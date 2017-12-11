use std::collections::HashSet;
use failure::Error;

pub fn solve(input: &str) -> Result<String, Error> {
    Ok(input
        .trim()
        .lines()
        .map(|line| Passphrase { words: line.into() })
        .filter(Passphrase::is_valid)
        .count()
        .to_string())
}

struct Passphrase {
    words: String,
}

impl Passphrase {
    fn is_valid(&self) -> bool {
        let mut words = HashSet::new();
        !self.words
            .split_whitespace()
            .map(|word| {
                let mut chars: Vec<String> = word.chars().map(|x| x.to_string()).collect();
                chars.sort();
                chars.as_slice().join("")
            })
            .any(|word| {
                if words.contains(&word) {
                    return true;
                }
                words.insert(word);
                false
            })
    }
}
