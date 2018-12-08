use std::error::Error;
use std::io::{self, Read};

use lazy_static::lazy_static;
use regex::Regex;

fn main() -> Result<(), Box<Error>> {
    let mut input = String::new();
    io::stdin().read_to_string(&mut input)?;

    let output = solve(&input)?;
    println!("{}", output);

    Ok(())
}

fn solve(input: &str) -> Result<String, Box<Error>> {
    let polymer = input.trim();

    // Part One
    // let reaction = Reaction {
    //     polymer: polymer.into()
    // };
    // Ok(reaction.last().map(|x| x.len().to_string()).unwrap())

    // Part Two
    let output = (b'a'..=b'z')
        .map(|x| x as char)
        .map(|x| {
            polymer
                .replace(x, "")
                .replace(&x.to_uppercase().to_string(), "")
        })
        .map(|polymer| Reaction { polymer })
        .flat_map(|reaction| reaction.last())
        .map(|polymer| polymer.len())
        .min();
    Ok(output.unwrap().to_string())
}

#[test]
fn test_solve() {
    let input = "dabAcCaCBAcCcaDA";

    let output = solve(input).unwrap();

    // Part One
    // assert_eq!(output, "10".to_string());

    // Part Two
    assert_eq!(output, "4".to_string());
}

struct Reaction {
    polymer: String,
}

impl Iterator for Reaction {
    type Item = String;

    fn next(&mut self) -> Option<Self::Item> {
        lazy_static! {
            static ref RE: Regex = {
                let re: String = (b'a'..=b'z')
                    .map(|x| x as char)
                    .flat_map(|x| {
                        vec![
                            format!("{}{}", x, x.to_uppercase()),
                            format!("{}{}", x.to_uppercase(), x),
                        ]
                    })
                    .collect::<Vec<_>>()
                    .join("|");
                Regex::new(&re).unwrap()
            };
        }

        let current = self.polymer.clone();
        self.polymer = RE.replace(&self.polymer, "").into();
        if self.polymer == current {
            None
        } else {
            Some(self.polymer.to_string())
        }
    }
}

#[test]
fn test_reaction() {
    let polymer = "dabAcCaCBAcCcaDA".into();
    let mut reaction = Reaction { polymer };

    let polymer = reaction.next().unwrap();
    assert_eq!(polymer, "dabAaCBAcCcaDA".to_string());

    let polymer = reaction.next().unwrap();
    assert_eq!(polymer, "dabCBAcCcaDA".to_string());

    let polymer = reaction.next().unwrap();
    assert_eq!(polymer, "dabCBAcaDA".to_string());

    assert_eq!(reaction.next(), Option::None);
}
