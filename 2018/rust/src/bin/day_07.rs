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
    let mut assembly: Assembly = input.parse()?;
    let output = part_one(&mut assembly).iter().map(char::to_string).collect();
    Ok(output)
}

fn part_two<F: Fn(char) -> usize>(assembly: Assembly, worker_count: usize, step_time: F) {}

#[allow(dead_code)]
fn part_one(assembly: &mut Assembly) -> Vec<char> {
    let mut output = Vec::new();
    while !assembly.is_done() {
        let mut available = assembly.available_steps();
        available.sort();
        let done = *available[0];

        assembly.finish(&done);

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

    let mut assembly: Assembly = input.parse().unwrap();
    let output = part_one(&mut assembly);
    assert_eq!(output, vec!['C', 'A', 'B', 'D', 'F', 'E']);
}

struct Assembly {
    steps: HashMap<char, HashSet<char>>,
}

impl Assembly {
    fn is_done(&self) -> bool {
        self.steps.is_empty()
    }

    fn available_steps(&self) -> Vec<&char> {
        self.steps
            .iter()
            .filter(|(_, v)| v.is_empty())
            .map(|(k, _)| k)
            .collect()
    }

    fn finish(&mut self, step: &char) {
        self.steps.remove(step);
        for dependencies in self.steps.values_mut() {
            dependencies.remove(step);
        }
    }
}

impl FromStr for Assembly {
    type Err = Box<Error>;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let re = Regex::new(r"^Step (\w).*step (\w)").unwrap();

        let mut steps = HashMap::new();
        s.trim()
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

        Ok(Assembly { steps })
    }
}
