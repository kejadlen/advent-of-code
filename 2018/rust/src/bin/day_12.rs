use std::collections::HashMap;
use std::error::Error;
use std::fmt;
use std::str::FromStr;

use regex::Regex;

use advent_of_code::main;

main!();

fn solve(input: &str) -> Result<String, Box<Error>> {
    let mut generation: Generation = input.parse()?;
    for _ in 0..19 {
        generation.next();
    }

    let pots = generation.next().unwrap();
    let indices: Vec<_> = pots.iter().filter(|(_, &v)| v).map(|(&k, _)| k).collect();
    let output: isize = indices.iter().sum();

    Ok(output.to_string())
}

#[test]
fn test_solve() {
    let input = r"
initial state: #..#.#..##......###...###

...## => #
..#.. => #
.#... => #
.#.#. => #
.#.## => #
.##.. => #
.#### => #
#.#.# => #
#.### => #
##.#. => #
##.## => #
###.. => #
###.# => #
####. => #
    ";

    assert_eq!(solve(&input).unwrap(), 325.to_string());
}

struct Generation {
    pots: HashMap<isize, bool>,
    notes: HashMap<String, bool>,
}

impl fmt::Display for Generation {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        let plants: Vec<_> = self
            .pots
            .iter()
            .filter(|(_, &v)| v)
            .map(|(&k, _)| k)
            .collect();
        let min = *plants.iter().min().unwrap();
        let max = *plants.iter().max().unwrap();
        let s: String = (min..=max)
            .map(|x| self.pots.get(&x).unwrap_or_else(|| &false))
            .map(|&x| if x { '#' } else { '.' })
            .collect();
        write!(f, "{}", s)
    }
}

impl Iterator for Generation {
    type Item = HashMap<isize, bool>;

    fn next(&mut self) -> Option<Self::Item> {
        let plants: Vec<_> = self
            .pots
            .iter()
            .filter(|(_, &v)| v)
            .map(|(&k, _)| k)
            .collect();
        let min = *plants.iter().min().unwrap() - 2;
        let max = *plants.iter().max().unwrap() + 2;
        self.pots = (min..=max)
            .map(|i| {
                let key: String = ((i - 2)..=(i + 2))
                    .map(|x| self.pots.get(&x).unwrap_or_else(|| &false))
                    .map(|&x| if x { '#' } else { '.' })
                    .collect();
                let value = *self.notes.get(&key).unwrap_or_else(|| &false);
                (i, value)
            })
            .collect();

        Some(self.pots.clone())
    }
}

#[test]
fn test_generation() {
    let input = r"
initial state: #..#.#..##......###...###

...## => #
..#.. => #
.#... => #
.#.#. => #
.#.## => #
.##.. => #
.#### => #
#.#.# => #
#.### => #
##.#. => #
##.## => #
###.. => #
###.# => #
####. => #
    ";
    let mut generation: Generation = input.parse().unwrap();
    let pots = generation.pots.clone();
    assert!(pots.get(&0).unwrap());
    assert!(pots.get(&3).unwrap());
    assert!(!pots.get(&4).unwrap());

    let pots = generation.next().unwrap();
    assert!(pots.get(&0).unwrap());
    assert!(!pots.get(&3).unwrap());
    assert!(pots.get(&4).unwrap());
}

impl FromStr for Generation {
    type Err = Box<Error>;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let mut lines = s.trim().lines();

        let initial_state = lines.next().unwrap();
        let pots = Regex::new(r"[.#]+")
            .ok()
            .and_then(|re| re.find(initial_state))
            .unwrap()
            .as_str()
            .chars()
            .enumerate()
            .map(|(i, c)| (i as isize, c == '#'))
            .collect();

        lines.next(); // skip blank line

        let notes = lines
            .map(|line| {
                let mut note = line.split(" => ");
                let key = note.next().unwrap();
                let value = note.next().unwrap() == "#";
                (key.into(), value)
            })
            .collect();

        Ok(Generation { pots, notes })
    }
}
