use std::collections::HashMap;
use std::convert::TryFrom;
use failure::*;
use regex::Regex;

pub fn solve(input: &str) -> Result<String, Error> {
    // let input = "s1,x3/4,pe/b";
    let moves = input
        .split(',')
        .map(Move::try_from)
        .collect::<Result<_, _>>()?;
    let programs = (b'a'..=b'p').map(|c| c as char).collect();
    let dance = Dance { moves, programs };

    // dance.next();
    // Ok(dance.next().unwrap().iter().collect::<String>())

    let history = dance
        .enumerate()
        .scan(HashMap::new(), |state, (i, programs)| {
            if state.contains_key(&programs) {
                None
            } else {
                state.insert(programs, i);
                Some(state.clone())
            }
        })
        .last()
        .unwrap();
    let index = 1_000_000_000 % history.len();
    Ok(history
        .iter()
        .find(|(_, &v)| v == &index)
        .map(|(k, _)| k)
        .unwrap()
        .iter()
        .collect())
}

struct Dance {
    moves: Vec<Move>,
    programs: Vec<char>,
}

impl Iterator for Dance {
    type Item = Vec<char>;

    fn next(&mut self) -> Option<Self::Item> {
        let item = self.programs.clone();

        for m in &self.moves {
            match m {
                Move::Spin(size) => {
                    let len = self.programs.len();
                    self.programs.rotate(len - size);
                }
                Move::Exchange(a, b) => {
                    self.programs.swap(*a, *b);
                }
                Move::Partner(a, b) => {
                    let a = self.programs.iter().position(|x| x == a).unwrap();
                    let b = self.programs.iter().position(|x| x == b).unwrap();
                    self.programs.swap(a, b);
                }
            }
        }

        Some(item)
    }
}

#[test]
fn test_dance() {
    let moves = vec![Move::Spin(1), Move::Exchange(3, 4), Move::Partner('e', 'b')];
    let programs = (b'a'..=b'e').map(|c| c as char).collect();
    let mut dance = Dance { moves, programs };

    assert_eq!(dance.next().unwrap(), vec!['a', 'b', 'c', 'd', 'e']);
    assert_eq!(dance.next().unwrap(), vec!['b', 'a', 'e', 'd', 'c']);
}

#[derive(Debug, Eq, PartialEq)]
enum Move {
    Spin(usize),
    Exchange(usize, usize),
    Partner(char, char),
}

lazy_static! {
    static ref RE_S: Regex = { Regex::new(r"s(\d+)").unwrap() };
    static ref RE_X: Regex = { Regex::new(r"x(\d+)/(\d+)").unwrap() };
    static ref RE_P: Regex = { Regex::new(r"p(\w)/(\w)").unwrap() };
}

impl<'a> TryFrom<&'a str> for Move {
    type Error = Error;

    fn try_from(value: &str) -> Result<Self, Self::Error> {
        RE_S.captures(value)
            .and_then(|c| {
                let size = c.get(1).unwrap().as_str().parse().ok()?;
                Some(Move::Spin(size))
            })
            .or_else(|| {
                RE_X.captures(value).and_then(|c| {
                    let a = c.get(1).unwrap().as_str().parse().ok()?;
                    let b = c.get(2).unwrap().as_str().parse().ok()?;
                    Some(Move::Exchange(a, b))
                })
            })
            .or_else(|| {
                RE_P.captures(value).and_then(|c| {
                    let a = c.get(1).unwrap().as_str().chars().next()?;
                    let b = c.get(2).unwrap().as_str().chars().next()?;
                    Some(Move::Partner(a, b))
                })
            })
            .ok_or_else(|| format_err!("invalid move: {}", value))
    }
}

#[test]
fn test_move_try_from() {
    assert_eq!(Move::try_from("s1").unwrap(), Move::Spin(1));
    assert_eq!(Move::try_from("x3/4").unwrap(), Move::Exchange(3, 4));
    assert_eq!(Move::try_from("pe/b").unwrap(), Move::Partner('e', 'b'));
}
