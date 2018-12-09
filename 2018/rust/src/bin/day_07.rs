#![feature(vec_remove_item)]

use std::cmp::{Ord, Ordering};
use std::collections::{HashMap, HashSet};
use std::error::Error;
use std::str::FromStr;

use regex::Regex;

use advent_of_code::main;

main!();

fn solve(input: &str) -> Result<String, Box<Error>> {
    let assembly: Assembly = input.parse()?;
    let output = part_two(assembly, 5, |x| (x as usize) - ('A' as usize) + 61);
    Ok(output.to_string())
}

fn part_two<F: Fn(char) -> usize>(assembly: Assembly, worker_count: usize, step_time: F) -> usize {
    let workers = Workers(vec![None; worker_count]);
    PartTwo {
        assembly,
        workers,
        step_time,
    }
    .count()
}

#[test]
fn test_part_two() {
    let input = r"
Step C must be finished before step A can begin.
Step C must be finished before step F can begin.
Step A must be finished before step B can begin.
Step A must be finished before step D can begin.
Step B must be finished before step E can begin.
Step D must be finished before step E can begin.
Step F must be finished before step E can begin.
    ";

    let assembly: Assembly = input.parse().unwrap();
    let output = part_two(assembly, 2, |x| (x as usize) - ('A' as usize) + 1);
    assert_eq!(output, 15);
}

struct PartTwo<F> {
    assembly: Assembly,
    workers: Workers,
    step_time: F,
}

impl<F: Fn(char) -> usize> Iterator for PartTwo<F> {
    type Item = Vec<Option<char>>;

    fn next(&mut self) -> Option<Self::Item> {
        if self.assembly.is_done() {
            return None;
        }

        for (worker, step_id) in self
            .workers
            .available()
            .iter_mut()
            .zip(self.assembly.available())
        {
            worker.replace((step_id, (self.step_time)(step_id)));
            self.assembly.start(step_id);
        }

        let done = self.workers.tick();
        for step_id in done {
            self.assembly.finish(step_id);
        }

        Some(self.workers.0.iter().map(|x| x.map(|x| x.0)).collect())
    }
}

#[derive(Debug)]
struct Workers(Vec<Option<(char, usize)>>);

impl Workers {
    fn available(&mut self) -> Vec<&mut Option<(char, usize)>> {
        self.0.iter_mut().filter(|x| x.is_none()).collect()
    }

    fn tick(&mut self) -> Vec<char> {
        let mut done = Vec::new();
        for maybe_work in self.0.iter_mut() {
            if let Some((step, mut time)) = maybe_work.take() {
                time -= 1;
                if time > 0 {
                    maybe_work.replace((step, time));
                } else {
                    done.push(step);
                }
            }
        }
        done
    }
}

#[test]
fn test_workers() {
    let mut workers = Workers(vec![None; 5]);

    let steps = workers.tick();
    assert!(steps.is_empty());

    let worker = &mut workers.available()[0];
    worker.replace(('a', 5));
    assert_eq!(workers.0[0], Some(('a', 5)));

    let worker = &mut workers.available()[0];
    worker.replace(('b', 1));
    assert_eq!(workers.0[1], Some(('b', 1)));

    let steps = workers.tick();
    assert_eq!(workers.0[0], Some(('a', 4)));
    assert_eq!(steps, vec!['b']);
}

#[allow(dead_code)]
fn part_one(assembly: &mut Assembly) -> Vec<char> {
    let mut output = Vec::new();
    while !assembly.is_done() {
        let done = assembly.available()[0];

        output.push(done);

        assembly.finish(done);
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

struct Assembly(Vec<Step>);

impl Assembly {
    fn is_done(&self) -> bool {
        self.0.iter().all(|x| x.state == State::Finished)
    }

    fn available(&self) -> Vec<char> {
        let finished = self.finished();
        let mut available: Vec<_> = self
            .0
            .iter()
            .filter(|x| x.state == State::Unstarted)
            .filter(|x| x.deps.iter().all(|x| finished.contains(x)))
            .map(|x| x.id)
            .collect();
        available.sort();
        available
    }

    fn finished(&self) -> Vec<char> {
        self.0
            .iter()
            .filter(|x| x.state == State::Finished)
            .map(|x| x.id)
            .collect()
    }

    fn start(&mut self, step_id: char) {
        if let Some(step) = self.0.iter_mut().find(|x| x.id == step_id) {
            step.state = State::InProgress;
        }
    }

    fn finish(&mut self, step_id: char) {
        if let Some(step) = self.0.iter_mut().find(|x| x.id == step_id) {
            step.state = State::Finished;
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
        let steps = steps
            .into_iter()
            .map(|(id, deps)| {
                let state = State::Unstarted;
                Step { id, deps, state }
            })
            .collect();

        Ok(Assembly(steps))
    }
}

#[derive(Eq, PartialEq)]
struct Step {
    id: char,
    deps: HashSet<char>,
    state: State,
}

impl PartialOrd for Step {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}

impl Ord for Step {
    fn cmp(&self, other: &Self) -> Ordering {
        self.id.cmp(&other.id)
    }
}

#[derive(Eq, PartialEq)]
enum State {
    Unstarted,
    InProgress,
    Finished,
}
