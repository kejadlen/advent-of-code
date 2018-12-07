use std::collections::{HashMap, HashSet};
use std::error::Error;
use std::io::{self, Read};
use std::str::FromStr;

use regex::Regex;

fn main() -> Result<(), Box<Error>> {
    let mut input = String::new();
    io::stdin().read_to_string(&mut input)?;

    let output = solve(&input)?;
    println!("{}", output);

    Ok(())
}

fn solve(input: &str) -> Result<String, Box<Error>> {
    let instructions: Instructions = input.parse()?;
    let output = part_one(instructions).iter().map(char::to_string).collect();
    Ok(output)
}

#[allow(dead_code)]
fn part_one(instructions: Instructions) -> Vec<char> {
    let mut steps = instructions.steps;

    let mut output = Vec::new();
    while !steps.is_empty() {
        let mut ready: Vec<_> = steps
            .iter()
            .filter(|(_, v)| v.is_empty())
            .map(|(k, _)| k)
            .collect();
        ready.sort();
        let done = *ready[0];

        steps.remove(&done);
        for dependencies in steps.values_mut() {
            dependencies.remove(&done);
        }

        output.push(done);
    }

    output
}

#[test]
fn test_part_one() {
    let input = r"
Step C must be finished before step A can begin.
Step C must be finished before step F can begin.
Step A must be finished before step B can begin.
Step A must be finished before step D can begin.
Step B must be finished before step E can begin.
Step D must be finished before step E can begin.
Step F must be finished before step E can begin.
    ";

    let instructions: Instructions = input.parse().unwrap();
    let output = part_one(instructions);
    assert_eq!(output, vec!['C', 'A', 'B', 'D', 'F', 'E']);
}

struct Instructions {
    steps: HashMap<char, HashSet<char>>,
}

impl FromStr for Instructions {
    type Err = Box<Error>;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let re = Regex::new(r"^Step (\w).*step (\w)").unwrap();

        let mut steps = HashMap::new();
        s
            .trim()
            .lines()
            .flat_map(|x| re.captures(x))
            .map(|x| {
                x.iter()
                    .flat_map(|x| x)
                    .map(|x| x.as_str().chars().next().unwrap())
                    .collect::<Vec<_>>()
            })
        .map(|x| (x[1], x[2]))
            .for_each(|(x, y)| {
                steps.entry(x).or_insert_with(HashSet::new);
                let entry = steps.entry(y).or_insert_with(HashSet::new);
                entry.insert(x);
            });

        Ok(Instructions{steps})
    }
}
