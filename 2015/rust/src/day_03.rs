use std::collections::HashMap;
use std::fmt;
use std::ops::Add;
use std::str::Chars;

pub fn solve(input: &str) -> i32 {
  let mut santa = String::new();
  let mut robo_santa = String::new();
  let mut iter = input.chars();

  loop {
    match iter.next() {
      Some(c) => santa.push(c),
      None => break,
    }
    match iter.next() {
      Some(c) => robo_santa.push(c),
      None => break,
    }
  }

  let mut houses: HashMap<Point, u32> = HashMap::new();
  Santa::houses_visited(&santa, &mut houses);
  Santa::houses_visited(&robo_santa, &mut houses);
  houses.len() as i32
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

  fn houses_visited(directions: &str, houses: &mut HashMap<Point, u32>) {
    let santa = Santa::new(directions);
    houses.insert(santa.location, 1);

    for point in santa {
      *houses.entry(point).or_insert(0) += 1;
    }
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
    self.location = self.location + offset;
    Some(self.location)
  }
}

#[test]
fn test_one() {
  let directions = ">";
  let santa = Santa::new(directions);

  let points = santa.collect::<Vec<Point>>();
  let expected = vec![Point { x: 1, y: 0 }];
  assert_eq!(expected, points);

  let mut houses: HashMap<Point, u32> = HashMap::new();
  Santa::houses_visited(directions, &mut houses);
  assert_eq!(2, houses.len());
  assert_eq!(&1, houses.get(&Point::origin()).unwrap());
  assert_eq!(&1, houses.get(&Point { x: 1, y: 0 }).unwrap());
}

#[test]
fn test_two() {
  let directions = "^>v<";

  let mut houses: HashMap<Point, u32> = HashMap::new();
  Santa::houses_visited(directions, &mut houses);
  assert_eq!(4, houses.len());
  assert_eq!(&2, houses.get(&Point::origin()).unwrap());
  assert_eq!(&1, houses.get(&Point { x: 1, y: 0 }).unwrap());
}

#[test]
fn test_three() {
  let directions = "^v^v^v^v^v";

  let mut houses: HashMap<Point, u32> = HashMap::new();
  Santa::houses_visited(directions, &mut houses);
  assert_eq!(2, houses.len());
  assert_eq!(&6, houses.get(&Point::origin()).unwrap());
  assert_eq!(&5, houses.get(&Point { x: 0, y: 1 }).unwrap());
}

#[derive(Clone,Copy,Debug,Eq,Hash,PartialEq)]
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

#[test]
fn test_point() {
  let point = Point { x: 10, y: -10 };
  let offset = Point { x: -10, y: 10 };
  assert_eq!(Point::origin(), point + offset);
}
