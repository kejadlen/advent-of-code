use std::cmp::Ordering;
use std::collections::{BinaryHeap, HashMap, HashSet};
use std::error::Error;
use std::str::FromStr;

use advent_of_code::main;

main!();

fn solve(input: &str) -> Result<String, Box<Error>> {
    unimplemented!();
}

struct Combat {
    map: Map,
}

impl Combat {}

struct Map {
    walls: HashSet<Square>,
    units: HashMap<Square, Unit>,
}

impl Map {
    fn is_open(&self, square: &Square) -> bool {
        !self.walls.contains(&square) && !self.units.contains_key(&square)
    }

    fn open_neighbors(&self, square: &Square) -> HashSet<Square> {
        square
            .neighbors()
            .into_iter()
            .filter(|x| self.is_open(x))
            .collect()
    }

    fn distances(&self, from: &Square) -> HashMap<Square, usize> {
        #[derive(Eq, PartialEq)]
        struct State {
            distance: usize,
            square: Square,
        }

        impl Ord for State {
            fn cmp(&self, other: &Self) -> Ordering {
                other.distance.cmp(&self.distance)
            }
        }

        impl PartialOrd for State {
            fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
                Some(self.cmp(other))
            }
        }

        let mut distances = HashMap::new();
        let mut queue = BinaryHeap::new();
        queue.push(State {
            distance: 0,
            square: *from,
        });

        while let Some(State { distance, square }) = queue.pop() {
            distances.entry(square).or_insert(distance);

            self.open_neighbors(&square)
                .iter()
                .filter(|x| !distances.contains_key(x))
                .map(|&x| State {
                    distance: distance + 1,
                    square: x,
                })
                .for_each(|x| queue.push(x));
        }

        distances
    }
}

impl FromStr for Map {
    type Err = Box<Error>;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let mut walls = HashSet::new();
        let mut units = HashMap::new();
        s.trim()
            .lines()
            .enumerate()
            .flat_map(|(y, line)| {
                line.chars()
                    .enumerate()
                    .map(move |(x, c)| (Square((y, x)), c))
            })
            .for_each(|(square, c)| {
                match c {
                    '#' => {
                        walls.insert(square);
                    }
                    'G' => {
                        units.insert(square, Unit::new(Race::Goblin));
                    }
                    'E' => {
                        units.insert(square, Unit::new(Race::Elf));
                    }
                    '.' => {}
                    _ => panic!(),
                };
            });

        Ok(Self { walls, units })
    }
}

#[test]
fn test_map_distances() {
    let map: Map = r"
#######
#E..G.#
#...#.#
#.G.#G#
#######
    "
    .parse()
    .unwrap();

    let distances = map.distances(&Square((1, 1)));
    assert!(!distances.contains_key(&Square((0, 0))));
    assert!(!distances.contains_key(&Square((1, 4))));
    assert!(!distances.contains_key(&Square((1, 5))));
    assert_eq!(distances.get(&Square((2, 2))).unwrap(), &2);
    assert_eq!(distances.get(&Square((1, 3))).unwrap(), &2);
    assert_eq!(distances.get(&Square((3, 3))).unwrap(), &4);
}

#[test]
fn test_map_from_str() {
    let input = r"
#######
#.G.E.#
#E.G.E#
#.G.E.#
#######
    ";

    let map: Map = input.parse().unwrap();

    assert!(map.walls.contains(&Square((0, 0))));
    assert!(!map.walls.contains(&Square((1, 1))));

    assert_eq!(map.units.get(&Square((1, 2))).unwrap().race, Race::Goblin);
    assert_eq!(map.units.get(&Square((1, 4))).unwrap().race, Race::Elf);
}

#[derive(Clone, Copy, Debug, Eq, Hash, PartialEq)]
struct Square((usize, usize));

impl Square {
    fn neighbors(&self) -> HashSet<Self> {
        let (y, x) = self.0;
        let mut set = HashSet::new();
        set.insert(Square((y - 1, x)));
        set.insert(Square((y + 1, x)));
        set.insert(Square((y, x - 1)));
        set.insert(Square((y, x + 1)));
        set
    }
}

impl Ord for Square {
    fn cmp(&self, other: &Self) -> Ordering {
        self.0.cmp(&other.0)
    }
}

impl PartialOrd for Square {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}
#[test]
fn test_square_ord() {
    let mut squares: Vec<Square> = vec![(1, 2), (1, 4), (2, 1), (2, 3), (2, 5), (3, 2), (3, 4)]
        .iter()
        .map(|&x| Square(x))
        .collect();
    squares.sort();
    assert_eq!(
        squares.iter().map(|x| x.0).collect::<Vec<_>>(),
        vec![(1, 2), (1, 4), (2, 1), (2, 3), (2, 5), (3, 2), (3, 4)]
    );
}

struct Unit {
    race: Race,
    hp: usize,
}

impl Unit {
    fn new(race: Race) -> Self {
        let hp = 200;
        Unit { race, hp }
    }

    fn targets(&self, map: &Map) -> HashSet<Square> {
        map.units
            .iter()
            .filter(|(_, x)| x.race == self.race.enemy())
            .map(|(&x, _)| x)
            .collect()
    }

    fn in_range(&self, map: &Map) -> HashSet<Square> {
        self.targets(&map)
            .iter()
            .flat_map(|x| map.open_neighbors(x))
            .collect()
    }

    fn reachable(&self, square: &Square, map: &Map) -> HashMap<Square, usize> {
        let in_range = self.in_range(&map);
        map.distances(square)
            .into_iter()
            .filter(|(x, _)| in_range.contains(x))
            .collect()
    }

    fn next_step(&self, square: &Square, map: &Map) -> Option<Square> {
        self.reachable(&square, &map)
            .into_iter()
            .fold(HashMap::new(), |mut m, (s, d)| {
                let v = m.entry(d).or_insert_with(Vec::new);
                v.push(s);
                m
            })
            .iter()
            .min_by_key(|(&x, _)| x)
            .and_then(|(_, x)| x.iter().min().cloned()) // Is there a way to avoid this clone?
    }
}

#[test]
fn test_unit_targets() {
    let map: Map = r"
#######
#E..G.#
#...#.#
#.G.#G#
#######
    "
    .parse()
    .unwrap();

    let square = Square((1, 1));
    let unit = map.units.get(&square).unwrap();

    let targets = unit.targets(&map);
    assert_eq!(targets.len(), 3);
    assert!(vec![(1, 4), (3, 2), (3, 5)]
        .iter()
        .map(|&x| Square(x))
        .all(|x| targets.contains(&x)));

    let in_range = unit.in_range(&map);
    assert_eq!(in_range.len(), 6);
    assert!(vec![(1, 3), (1, 5), (2, 2), (2, 5), (3, 1), (3, 3)]
        .iter()
        .map(|&x| Square(x))
        .all(|x| in_range.contains(&x)));

    let reachable = unit.reachable(&square, &map);
    assert_eq!(reachable.len(), 4);
    assert!(vec![(1, 3), (2, 2), (3, 1), (3, 3)]
        .iter()
        .map(|&x| Square(x))
        .all(|x| reachable.contains_key(&x)));

    let next_step = unit.next_step(&square, &map);
    assert_eq!(next_step.unwrap().0, (1, 3));
}

#[derive(Debug, Eq, PartialEq)]
enum Race {
    Elf,
    Goblin,
}

impl Race {
    fn enemy(&self) -> Race {
        match self {
            Race::Elf => Race::Goblin,
            Race::Goblin => Race::Elf,
        }
    }
}
