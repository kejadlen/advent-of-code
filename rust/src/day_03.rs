use std::cmp::Eq;
use std::collections::HashMap;
use std::fmt;
use std::io;
use std::ops::Add;
use std::str::Chars;

use day::Day;

pub struct Day03 {
    directions: String,
}

impl Day for Day03 {
    fn new(input: &String) -> Day03 {
        Day03 { directions: input.clone() }
    }

    fn solve(&self) -> io::Result<i32> {
        let houses = Santa::houses_visited(&self.directions);
        Ok(houses.len() as i32)
    }
}

struct Santa<'a> {
    location: Point,
    directions: Chars<'a>,
}

impl<'a> Santa<'a> {
    fn new(directions: &str) -> Santa {
        Santa {
            location: Point::origin(),
            directions: directions.chars(),
        }
    }

    fn houses_visited(directions: &str) -> HashMap<Point, u32> {
        let santa = Santa::new(directions);
        let mut houses = HashMap::new();
        houses.insert(Point::origin(), 1);

        for point in santa {
            *houses.entry(point).or_insert(0) += 1;
        }

        houses
    }
}

impl<'a> Iterator for Santa<'a> {
    type Item = Point;

    fn next(&mut self) -> Option<Point> {
        let offset = match self.directions.next() {
            Some('^') => Point { x: 0, y: 1 },
            Some('v') => Point { x: 0, y: -1 },
            Some('>') => Point { x: 1, y: 0 },
            Some('<') => Point { x: -1, y: 0 },
            _ => return None,
        };
        self.location = self.location.clone() + offset;
        Some(self.location.clone())
    }
}

#[test]
fn test_one() {
    let directions = ">";
    let santa = Santa::new(directions);

    let points = santa.collect::<Vec<Point>>();
    let expected = vec![Point { x: 1, y: 0 }];
    assert_eq!(expected, points);

    let houses = Santa::houses_visited(directions);
    assert_eq!(2, houses.len());
    assert_eq!(&1, houses.get(&Point::origin()).unwrap());
    assert_eq!(&1, houses.get(&Point { x: 1, y: 0 }).unwrap());
}

#[test]
fn test_two() {
    let directions = "^>v<";
    let houses = Santa::houses_visited(directions);
    assert_eq!(4, houses.len());
    assert_eq!(&2, houses.get(&Point::origin()).unwrap());
    assert_eq!(&1, houses.get(&Point { x: 1, y: 0 }).unwrap());
}

#[test]
fn test_three() {
    let directions = "^v^v^v^v^v";
    let houses = Santa::houses_visited(directions);
    assert_eq!(2, houses.len());
    assert_eq!(&6, houses.get(&Point::origin()).unwrap());
    assert_eq!(&5, houses.get(&Point { x: 0, y: 1 }).unwrap());
}

#[derive(Clone,Debug,Eq,Hash)]
struct Point {
    x: i32,
    y: i32,
}

impl Point {
    fn origin() -> Point {
        Point { x: 0, y: 0 }
    }
}

impl Add for Point {
    type Output = Point;

    fn add(self, other: Point) -> Point {
        Point {
            x: self.x + other.x,
            y: self.y + other.y,
        }
    }
}

impl fmt::Display for Point {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "({}, {})", self.x, self.y)
    }
}

impl PartialEq for Point {
    fn eq(&self, other: &Self) -> bool {
        self.x == other.x && self.y == other.y
    }
}

#[test]
fn test_point() {
    let point = Point { x: 10, y: -10 };
    let offset = Point { x: -10, y: 10 };
    assert_eq!(Point::origin(), point + offset);
}
