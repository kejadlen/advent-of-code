use std::collections::{HashMap, HashSet};
use std::hash::{Hash, Hasher};

use permutohedron::Heap;

#[test]
fn test_day_09() {
  let input = "London to Dublin = 464
London to Belfast = 518
Dublin to \
               Belfast = 141";
  let day = Day09::new(input);

  assert_eq!(464,
             day.distances[&LocationPair(Location("Dublin"),
                                         Location("London"))]);
  assert_eq!(464,
             day.distances[&LocationPair(Location("London"),
                                         Location("Dublin"))]);

  let route = day.route(vec![Location("Dublin"),
                               Location("London"),
                               Location("Belfast")]);
  assert_eq!(982, route.distance);

  assert_eq!(6, day.routes().len());

  assert_eq!(982, solve(input));
}

pub fn solve(input: &str) -> usize {
  let day = Day09::new(input);
  day.routes().iter().map(|r| r.distance).max().unwrap()
}

struct Day09<'a> {
  locations: HashSet<Location<'a>>,
  distances: HashMap<LocationPair<'a>, usize>,
}

impl<'a> Day09<'a> {
  fn new(input: &str) -> Day09 {
    let mut locations = HashSet::new();
    let mut distances = HashMap::new();

    for line in input.lines() {
      let mut split_eq = line.split(" = ");
      let mut split_to = split_eq.next().unwrap().split(" to ");
      let a = Location(split_to.next().unwrap());
      let b = Location(split_to.last().unwrap());
      let distance = split_eq.last().unwrap().parse::<usize>().unwrap();

      locations.insert(a);
      locations.insert(b);
      distances.insert(LocationPair(a, b), distance);
    }

    Day09 {
      locations: locations,
      distances: distances,
    }
  }

  fn routes(&self) -> Vec<Route> {
    let mut locations = self.locations
      .iter()
      .cloned()
      .collect::<Vec<Location>>();
    let heap = Heap::new(&mut locations);
    heap.map(|p| self.route(p)).collect()
  }

  fn route(&self, locations: Vec<Location<'a>>) -> Route {
    let distance = locations.windows(2)
      .map(|w| self.distances[&LocationPair(w[0], w[1])])
      .fold(0, |sum, dist| sum + dist);
    Route {
      locations: locations,
      distance: distance,
    }
  }
}

#[derive(Debug)]
struct Route<'a> {
  locations: Vec<Location<'a>>,
  distance: usize,
}

#[derive(Clone,Copy,Debug,Eq,Hash,PartialEq,PartialOrd,Ord)]
struct Location<'a>(&'a str);

#[derive(Debug,Eq)]
struct LocationPair<'a>(Location<'a>, Location<'a>);

impl<'a> PartialEq for LocationPair<'a> {
  fn eq(&self, other: &LocationPair) -> bool {
    let mut a = vec![&self.0, &self.1];
    a.sort();

    let mut b = vec![&other.0, &other.1];
    b.sort();

    a == b
  }
}

impl<'a> Hash for LocationPair<'a> {
  fn hash<H: Hasher>(&self, state: &mut H) {
    let mut locations = vec![&self.0, &self.1];
    locations.sort();
    locations.hash(state);
  }
}
