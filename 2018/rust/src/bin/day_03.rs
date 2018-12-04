use std::collections::HashMap;
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
    let claims: Vec<_> = input
        .lines()
        .map(str::trim)
        .map(Claim::from_str)
        .collect::<Result<_, _>>()?;
    let fabric = claims.iter().fold(
        HashMap::new(),
        |mut fabric: HashMap<(usize, usize), Vec<usize>>, claim| {
            for square_inch in claim.square_inches() {
                fabric
                    .entry(square_inch)
                    .and_modify(|ids| ids.push(claim.id))
                    .or_insert_with(|| vec![claim.id]);
            }
            fabric
        },
    );
    let values: Vec<_> = fabric.values().collect();
    let output = values
        .iter()
        .map(|ids| ids[0])
        .find(|id| !values.iter().any(|ids| ids.len() > 1 && ids.contains(id)))
        .unwrap()
        .to_string();
    Ok(output)
}

#[test]
fn test_solve() {
    let input = r"
        #1 @ 1,3: 4x4
        #2 @ 3,1: 4x4
        #3 @ 5,5: 2x2
    "
    .trim();

    assert_eq!(&solve(input).unwrap(), "3");
}

#[derive(Debug, PartialEq, Eq)]
struct Claim {
    id: usize,
    x: usize,
    y: usize,
    width: usize,
    height: usize,
}

impl Claim {
    fn square_inches(&self) -> impl Iterator<Item = (usize, usize)> + '_ {
        (self.x..self.x + self.width)
            .flat_map(move |x| (self.y..self.y + self.height).map(move |y| (x, y)))
    }
}

#[test]
fn test_claim_square_inches() {
    let claim = Claim {
        id: 1,
        x: 2,
        y: 3,
        width: 4,
        height: 4,
    };
    let square_inches: Vec<_> = claim.square_inches().collect();
    assert_eq!(square_inches.len(), 16);
    assert!(square_inches.contains(&(2, 3)));
    assert!(square_inches.contains(&(5, 3)));
    assert!(square_inches.contains(&(5, 6)));
    assert!(square_inches.contains(&(2, 6)));
}

impl FromStr for Claim {
    type Err = Box<Error>;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let re =
            Regex::new(r"^#(?P<id>\d+) @ (?P<x>\d+),(?P<y>\d+): (?P<width>\d+)x(?P<height>\d+)$")
                .unwrap();

        let captures = re.captures(s).unwrap();
        let id = captures.name("id").unwrap().as_str().parse()?;
        let x = captures.name("x").unwrap().as_str().parse()?;
        let y = captures.name("y").unwrap().as_str().parse()?;
        let width = captures.name("width").unwrap().as_str().parse()?;
        let height = captures.name("height").unwrap().as_str().parse()?;

        Ok(Claim {
            id,
            x,
            y,
            width,
            height,
        })
    }
}

#[test]
fn test_claim_from_str() {
    let claim = Claim::from_str("#1 @ 1,3: 4x4").unwrap();
    assert_eq!(
        claim,
        Claim {
            id: 1,
            x: 1,
            y: 3,
            width: 4,
            height: 4
        }
    );
}
