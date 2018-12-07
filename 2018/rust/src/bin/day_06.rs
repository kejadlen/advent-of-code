use std::collections::{HashMap, HashSet};
use std::error::Error;
use std::hash::Hash;
use std::io::{self, Read};
use std::str::FromStr;

fn main() -> Result<(), Box<Error>> {
    let mut input = String::new();
    io::stdin().read_to_string(&mut input)?;

    let output = part_two(&input, 10_000)?;
    println!("{}", output);

    Ok(())
}

fn part_two(input: &str, max_distance: usize) -> Result<String, Box<Error>> {
    let coords = Coords::from_str(input)?;

    let min_x = coords.0.iter().map(|c| c.x).min().unwrap();
    let max_x = coords.0.iter().map(|c| c.x).max().unwrap();
    let min_y = coords.0.iter().map(|c| c.y).min().unwrap();
    let max_y = coords.0.iter().map(|c| c.y).max().unwrap();
    let top_left = Coord { x: min_x, y: min_y };
    let bottom_right = Coord { x: max_x, y: max_y };

    let grid = Grid::new(top_left, bottom_right, |coord| {
        coords.total_distance(*coord)
    });

    let area = grid
        .locations
        .values()
        .filter(|&&x| x < max_distance)
        .count();
    Ok(area.to_string())
}

#[test]
fn test_part_two() {
    let input = r"
1, 1
1, 6
8, 3
3, 4
5, 5
8, 9
    ";

    let output = part_two(&input, 32).unwrap();
    assert_eq!(output, "16".to_string());
}

#[allow(dead_code)]
fn part_one(input: &str) -> Result<String, Box<Error>> {
    let coords = Coords::from_str(input)?;

    let min_x = coords.0.iter().map(|c| c.x).min().unwrap();
    let max_x = coords.0.iter().map(|c| c.x).max().unwrap();
    let min_y = coords.0.iter().map(|c| c.y).min().unwrap();
    let max_y = coords.0.iter().map(|c| c.y).max().unwrap();
    let top_left = Coord { x: min_x, y: min_y };
    let bottom_right = Coord { x: max_x, y: max_y };

    let coord_names: HashMap<_, _> = coords
        .0
        .iter()
        .enumerate()
        .map(|(i, c)| (c, (i + 65) as u8 as char))
        .collect();

    let grid = Grid::new(top_left, bottom_right, |coord| {
        coords
            .closest(*coord)
            .and_then(|closest| coord_names.get(&closest))
    });
    let edges: HashSet<_> = grid.edges().iter().flat_map(|&x| x).collect();

    let mut area_sizes = HashMap::new();
    grid.locations
        .values()
        .flat_map(|x| x)
        .filter(|x| !edges.contains(x))
        .for_each(|x| {
            let count = area_sizes.entry(x).or_insert(0);
            *count += 1;
        });

    let max_area = area_sizes.iter().map(|(_, v)| v).max().unwrap();
    Ok(max_area.to_string())
}

#[test]
fn test_part_one() {
    let input = r"
1, 1
1, 6
8, 3
3, 4
5, 5
8, 9
    ";

    let output = part_one(&input).unwrap();
    assert_eq!(output, "17".to_string());
}

#[derive(Debug)]
struct Grid<T> {
    top_left: Coord,
    bottom_right: Coord,
    locations: HashMap<Coord, T>,
}

impl<T> Grid<T> {
    fn new<C: Into<Coord>, F: Fn(&Coord) -> T>(top_left: C, bottom_right: C, f: F) -> Self {
        let top_left = top_left.into();
        let bottom_right = bottom_right.into();
        let mut locations = HashMap::new();

        for coord in top_left.grid(&bottom_right) {
            locations.insert(coord, f(&coord));
        }

        Grid {
            top_left,
            bottom_right,
            locations,
        }
    }
}

impl<T: Eq + Hash> Grid<T> {
    fn edges(&self) -> HashSet<&T> {
        let mut edges = HashSet::new();

        for x in self.top_left.x..=self.bottom_right.x {
            for &y in &[self.top_left.y, self.bottom_right.y] {
                if let Some(t) = self.locations.get(&Coord { x, y }) {
                    edges.insert(t);
                }
            }
        }

        for y in self.top_left.y..=self.bottom_right.y {
            for &x in &[self.top_left.x, self.bottom_right.x] {
                if let Some(t) = self.locations.get(&Coord { x, y }) {
                    edges.insert(t);
                }
            }
        }

        edges
    }
}

#[test]
fn test_edges() {
    let top_left = Coord { x: 0, y: 0 };
    let bottom_right = Coord { x: 2, y: 2 };
    let grid = Grid::new(top_left, bottom_right, |coord| coord.y * 3 + coord.x);
    let expected: HashSet<_> = vec![0, 1, 2, 3, 5, 6, 7, 8]
        .iter()
        .map(|&x| x as isize)
        .collect();
    assert_eq!(grid.edges(), expected.iter().collect());
}

#[derive(Debug)]
struct Coords(Vec<Coord>);

impl Coords {
    fn closest<C: Into<Coord>>(&self, c: C) -> Option<Coord> {
        let c = c.into();

        let mut distances = HashMap::new();
        for coord in &self.0 {
            let distance = coord.distance(c);
            let v = distances.entry(distance).or_insert_with(Vec::new);
            v.push(coord);
        }

        let (_, closest_coords) = distances.iter().min_by_key(|(&k, _)| k)?;
        if closest_coords.len() == 1 {
            Some(*closest_coords[0])
        } else {
            None
        }
    }

    fn total_distance<C: Into<Coord>>(&self, c: C) -> usize {
        let c = c.into();
        self.0.iter().map(|x| x.distance(c) as usize).sum()
    }
}

#[test]
fn test_closest() {
    let coords = Coords::from_str(
        r"
1, 1
1, 6
8, 3
3, 4
5, 5
8, 9
    ",
    )
    .unwrap();

    assert_eq!(coords.closest((0, 0)), Some(Coord::from((1, 1))));
    assert_eq!(coords.closest((3, 2)), Some(Coord::from((3, 4))));
    assert_eq!(coords.closest((5, 0)), None);
    assert_eq!(coords.closest((0, 4)), None);
}

#[test]
fn test_total_distance() {
    let coords = Coords::from_str(
        r"
1, 1
1, 6
8, 3
3, 4
5, 5
8, 9
    ",
    )
    .unwrap();

    assert_eq!(coords.total_distance((4, 3)), 30);
}

impl FromStr for Coords {
    type Err = Box<Error>;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let coords = s
            .trim()
            .lines()
            .map(Coord::from_str)
            .collect::<Result<_, _>>()?;
        Ok(Coords(coords))
    }
}

#[derive(Clone, Copy, Debug, Eq, Hash, PartialEq)]
struct Coord {
    x: isize,
    y: isize,
}

impl Coord {
    fn distance<C: Into<Self>>(&self, other: C) -> isize {
        let other = other.into();
        (self.x - other.x).abs() + (self.y - other.y).abs()
    }

    fn grid(&self, to: &Self) -> impl Iterator<Item = Coord> + '_ {
        let to = *to;
        (self.x..=to.x).flat_map(move |x| (self.y..=to.y).map(move |y| (x, y).into()))
    }
}

#[test]
fn test_distance() {
    let coord = Coord { x: 4, y: 3 };
    assert_eq!(coord.distance((1, 1)), 5);
    assert_eq!(coord.distance((8, 9)), 10);
}

impl From<(isize, isize)> for Coord {
    fn from((x, y): (isize, isize)) -> Self {
        Coord { x, y }
    }
}

impl FromStr for Coord {
    type Err = Box<Error>;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let mut xy = s.split(", ");
        let x = xy.next().unwrap().parse()?;
        let y = xy.next().unwrap().parse()?;
        Ok(Coord { x, y })
    }
}
