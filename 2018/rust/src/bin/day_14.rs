use std::error::Error;

use advent_of_code::main;

main!();

fn solve(_input: &str) -> Result<String, Box<Error>> {
    let elves = vec![0, 1];
    let recipes = vec![3, 7];
    let mut scoreboard = Scoreboard { elves, recipes };

    let n = 919_901;
    let recipes = scoreboard.find(|x| x.len() > n + 9).unwrap();
    let score: String = recipes[n..n + 10].iter().map(|&x| x.to_string()).collect();

    Ok(score)
}

#[derive(Debug)]
struct Scoreboard {
    elves: Vec<usize>,
    recipes: Vec<usize>,
}

impl Iterator for Scoreboard {
    type Item = Vec<usize>;

    fn next(&mut self) -> Option<Self::Item> {
        self.elves
            .iter()
            .map(|&x| self.recipes[x])
            .sum::<usize>()
            .to_string()
            .chars()
            .map(|x| x.to_digit(10).unwrap() as usize)
            .for_each(|x| self.recipes.push(x));
        self.elves = self
            .elves
            .iter()
            .map(|&x| (1 + self.recipes[x] + x) % self.recipes.len())
            .collect();

        Some(self.recipes.clone())
    }
}

#[test]
fn test_scoreboard() {
    let elves = vec![0, 1];
    let recipes = vec![3, 7];
    let mut scoreboard = Scoreboard { elves, recipes };

    let recipes = scoreboard.next().unwrap();
    assert_eq!(recipes, vec![3, 7, 1, 0]);
}
