use std::collections::HashSet;
use failure::*;

#[allow(dead_code)]
pub fn solve(input: &str) -> Result<String, Error> {
    let banks: Vec<_> = input
        .split_whitespace()
        .map(str::parse)
        .collect::<Result<_, _>>()?;

    let mut reallocation = Reallocation {
        banks: banks.clone(),
    };
    let cycles = unique_cycles(reallocation);

    reallocation = Reallocation { banks };
    Ok((unique_cycles(reallocation.skip(cycles - 1)) - 1).to_string())
}

#[allow(dead_code)]
fn unique_cycles<R: Iterator<Item = Vec<usize>>>(reallocation: R) -> usize {
    let mut seen = HashSet::new();
    for (i, banks) in reallocation.enumerate() {
        if seen.contains(&banks) {
            return i + 1;
        }

        seen.insert(banks.clone());
    }
    unreachable!();
}

#[test]
fn test_part_one() {
    let reallocation = Reallocation {
        banks: vec![0, 2, 7, 0],
    };
    assert_eq!(unique_cycles(reallocation), 5);
}

#[allow(dead_code)]
struct Reallocation {
    banks: Vec<usize>,
}

impl Iterator for Reallocation {
    type Item = Vec<usize>;

    fn next(&mut self) -> Option<Self::Item> {
        let banks = self.banks.clone();
        let mut banks: Vec<_> = banks.iter().enumerate().collect();
        banks.reverse();
        let (start, max) = banks
            .iter()
            .max_by_key(|&&(_, x)| x)
            .map(|&(i, x)| (i, *x))?;

        let len = self.banks.len();
        self.banks[start] = 0;
        for i in 1..=max {
            self.banks[(start + i) % len] += 1;
        }

        Some(self.banks.clone())
    }
}

#[test]
fn test_reallocation() {
    let mut r = Reallocation {
        banks: vec![0, 2, 7, 0],
    };
    assert_eq!(r.next(), Some(vec![2, 4, 1, 2]));
    assert_eq!(r.next(), Some(vec![3, 1, 2, 3]));
    assert_eq!(r.next(), Some(vec![0, 2, 3, 4]));
}
