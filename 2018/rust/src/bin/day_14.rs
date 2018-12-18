use std::error::Error;

use advent_of_code::main;

main!();

fn solve(input: &str) -> Result<String, Box<Error>> {
    let elves = vec![0, 1];
    let recipes = "37".into();
    let scoreboard = Scoreboard { elves, recipes };

    let needle = input;
    // let recipes = scoreboard.find(|x| x.len() > n + 9).unwrap();
    // let score: String = recipes[n..n + 10].iter().map(|&x| x.to_string()).collect();

    let n = scoreboard
        .scan(0, |n, recipes| {
            let seen = *n;
            *n = recipes
                .len()
                .checked_sub(needle.len() - 1)
                .unwrap_or_else(|| 0);
            Some((seen, recipes[seen..recipes.len()].to_string()))
        })
        // .inspect(|x| println!("{:?}", x))
        .flat_map(|(n, x)| x.find(needle).map(|i| n + i))
        .next()
        .unwrap();

    Ok(n.to_string())
}

#[test]
fn test_solve() {
    // Part Two
    assert_eq!(&solve("51589").unwrap(), "9");
    assert_eq!(&solve("01245").unwrap(), "5");
    assert_eq!(&solve("92510").unwrap(), "18");
    assert_eq!(&solve("59414").unwrap(), "2018");
}

#[derive(Debug)]
struct Scoreboard {
    elves: Vec<usize>,
    recipes: String,
}

impl Iterator for Scoreboard {
    type Item = String;

    fn next(&mut self) -> Option<Self::Item> {
        self.recipes.push_str(
            &self
                .elves
                .iter()
                .map(|&x| self.recipes[x..=x].parse::<usize>().unwrap())
                .sum::<usize>()
                .to_string(),
        );
        self.elves = self
            .elves
            .iter()
            .map(|&x| (1 + self.recipes[x..=x].parse::<usize>().unwrap() + x) % self.recipes.len())
            .collect();

        Some(self.recipes.clone())
    }
}

#[test]
fn test_scoreboard() {
    let elves = vec![0, 1];
    let recipes = "37".into();
    let mut scoreboard = Scoreboard { elves, recipes };

    let recipes = scoreboard.next().unwrap();
    assert_eq!(recipes, "3710");
}
