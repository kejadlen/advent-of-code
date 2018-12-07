use std::collections::{HashMap, HashSet};
use std::error::Error;
use std::io::{self, Read};

use regex::Regex;

fn main() -> Result<(), Box<Error>> {
    let mut input = String::new();
    io::stdin().read_to_string(&mut input)?;

    let output = solve(&input)?;
    println!("{}", output);

    Ok(())
}

fn solve(input: &str) -> Result<String, Box<Error>> {
    let re = Regex::new(r"^Step (\w).*step (\w)").unwrap();

    let mut steps = HashMap::new();
    input
        .trim()
        .lines()
        .flat_map(|x| re.captures(x))
        .map(|x| {
            x.iter()
                .flat_map(|x| x)
                .map(|x| x.as_str())
                .collect::<Vec<_>>()
        })
        .map(|x| (x[1], x[2]))
        .for_each(|(x, y)| {
            steps.entry(x).or_insert_with(HashSet::new);
            let entry = steps.entry(y).or_insert_with(HashSet::new);
            entry.insert(x);
        });

    let mut output = String::new();
    while !steps.is_empty() {
        let mut ready: Vec<_> = steps
            .iter()
            .filter(|(_, v)| v.is_empty())
            .map(|(k, _)| k)
            .collect();
        ready.sort();
        let done = ready[0].clone();

        steps.remove(done);
        for dependencies in steps.values_mut() {
            dependencies.remove(done);
        }

        output.push_str(done);
    }

    Ok(output)
}

#[test]
fn test_solve() {
    let input = r"
Step C must be finished before step A can begin.
Step C must be finished before step F can begin.
Step A must be finished before step B can begin.
Step A must be finished before step D can begin.
Step B must be finished before step E can begin.
Step D must be finished before step E can begin.
Step F must be finished before step E can begin.
    ";

    let output = solve(input).unwrap();
    assert_eq!(output, "CABDFE".to_string());
}
