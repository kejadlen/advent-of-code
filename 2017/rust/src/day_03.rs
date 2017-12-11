use std::collections::HashMap;
use std::iter;
use failure::*;

#[allow(dead_code)]
pub fn solve(input: &str) -> Result<String, Error> {
    let input: usize = input.trim().parse()?;

    // 1
    // spiral()
    //     .zip(1..)
    //     .find(|&(_, i)| i == (square - 1))
    //     .map(|(coord, _)| (coord.0 + coord.1).to_string())
    //     .ok_or_else(|| format_err!(""))

    // 2
    let mut grid = HashMap::new();
    grid.insert(Coord(0, 0), 1);
    spiral()
        .map(|coord| {
            let sum = coord.neighbors().iter().filter_map(|x| grid.get(x)).sum();
            grid.insert(coord, sum);
            sum
        })
        .find(|value| value > &input)
        .map(|value| value.to_string())
        .ok_or_else(|| err_msg(""))
}

#[derive(Clone, Copy, Debug, Eq, Hash, PartialEq)]
struct Coord(isize, isize);

impl Coord {
    #[allow(dead_code)]
    fn neighbors(&self) -> Vec<Coord> {
        vec![
            [-1, 1],
            [0, 1],
            [1, 1],
            [-1, 0],
            [1, 0],
            [-1, -1],
            [0, -1],
            [1, -1],
        ].iter()
            .map(|delta| Coord(self.0 + delta[0], self.1 + delta[1]))
            .collect()
    }
}

#[derive(Clone, Copy, Debug, PartialEq)]
enum Dir {
    Right,
    Up,
    Left,
    Down,
}

#[allow(dead_code)]
lazy_static! {
    static ref DIRS: Vec<Dir> = vec![Dir::Right, Dir::Up, Dir::Left, Dir::Down];
}

#[allow(dead_code)]
fn spiral() -> impl Iterator<Item = Coord> {
    (1..)
        .flat_map(|x| iter::repeat(x).take(2))
        .zip(DIRS.iter().cycle())
        .flat_map(|(steps, dir)| iter::repeat(dir).take(steps))
        .scan(Coord(0, 0), |state, &dir| {
            *state = match dir {
                Dir::Right => Coord(state.0 + 1, state.1),
                Dir::Up => Coord(state.0, state.1 + 1),
                Dir::Left => Coord(state.0 - 1, state.1),
                Dir::Down => Coord(state.0, state.1 - 1),
            };
            Some(*state)
        })
}

#[test]
fn test_coords() {
    let mut spiral = spiral();
    assert_eq!(spiral.next(), Some(Coord(1, 0)));
    assert_eq!(spiral.next(), Some(Coord(1, 1)));
    assert_eq!(spiral.next(), Some(Coord(0, 1)));
    assert_eq!(spiral.next(), Some(Coord(-1, 1)));
    assert_eq!(spiral.next(), Some(Coord(-1, 0)));
    assert_eq!(spiral.next(), Some(Coord(-1, -1)));
}
