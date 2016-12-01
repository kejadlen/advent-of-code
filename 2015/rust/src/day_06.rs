use std::ops::{Index,IndexMut};
use regex::Regex;

pub fn solve(input: &str) -> i32 {
    let mut lg = LightGrid::new();

    for line in input.lines() {
        let instruction = Instruction::new(line.to_string());

        match instruction.instruction.as_ref() {
            "turn on" => lg.turn_on(instruction.rect),
            "turn off" => lg.turn_off(instruction.rect),
            "toggle" => lg.toggle(instruction.rect),
            _ => { panic!("wtf"); },
        };
    }

    lg.iter().fold(0, |acc, brightness| acc + brightness) as i32
}

#[test]
fn test_solve() {
    let mut input = vec!["turn on 0,0 through 999,999"];
    assert_eq!(1_000_000, solve(&input.join("\n")));

    input.push("turn off 1,1 through 998,998");
    assert_eq!(3_996, solve(&input.join("\n")));

    input.push("toggle 2,2 through 997,997");
    assert_eq!(1_988_028, solve(&input.join("\n")));
}

struct LightGrid {
    grid: Box<[u32; 1_000 * 1_000]>,
}

impl LightGrid {
    fn new() -> LightGrid {
        LightGrid { grid: box [0; 1_000 * 1_000] }
    }

    fn turn_on(&mut self, rect: Rect) {
        let mut x = vec![(rect.0).0, (rect.1).0];
        let mut y = vec![(rect.0).1, (rect.1).1];

        x.sort();
        y.sort();

        for i in x[0]..x[1]+1 {
            for j in y[0]..y[1]+1 {
                self[Point(i, j)] += 1;
            }
        }
    }

    fn turn_off(&mut self, rect: Rect) {
        let mut x = vec![(rect.0).0, (rect.1).0];
        let mut y = vec![(rect.0).1, (rect.1).1];

        x.sort();
        y.sort();

        for i in x[0]..x[1]+1 {
            for j in y[0]..y[1]+1 {
                if self[Point(i, j)] > 0 {
                    self[Point(i, j)] -= 1;
                }
            }
        }
    }

    fn toggle(&mut self, rect: Rect) {
        let mut x = vec![(rect.0).0, (rect.1).0];
        let mut y = vec![(rect.0).1, (rect.1).1];

        x.sort();
        y.sort();

        for i in x[0]..x[1]+1 {
            for j in y[0]..y[1]+1 {
                self[Point(i, j)] += 2;
            }
        }
    }

    fn iter(&self) -> LightGridIterator {
        LightGridIterator::new(self)
    }
}

impl Index<Point> for LightGrid {
    type Output = u32;

    fn index(&self, _index: Point) -> &u32 {
        &self.grid[1_000 * _index.0 + _index.1]
    }
}

impl IndexMut<Point> for LightGrid {
    fn index_mut(&mut self, _index: Point) -> &mut u32 {
        &mut self.grid[1_000 * _index.0 + _index.1]
    }
}

#[test]
fn test_light_grid() {
    let mut lg = LightGrid::new();
    assert_eq!(0, lg[Point(0, 0)]);

    lg.turn_on(Rect(Point(0, 0), Point(1, 1)));
    assert_eq!(1, lg[Point(0, 0)]);
    assert_eq!(0, lg[Point(2, 0)]);

    lg.turn_off(Rect(Point(1, 1), Point(2, 2)));
    assert_eq!(1, lg[Point(0, 0)]);
    assert_eq!(0, lg[Point(1, 1)]);

    lg.toggle(Rect(Point(0, 0), Point(1, 1)));
    assert_eq!(3, lg[Point(0, 0)]);
    assert_eq!(2, lg[Point(1, 1)]);
}

struct LightGridIterator<'a> {
    lg: &'a LightGrid,
    pos: Point,
}

impl<'a> LightGridIterator<'a> {
    fn new(light_grid: &LightGrid) -> LightGridIterator {
        LightGridIterator { lg: light_grid, pos: Point(0, 0) }
    }
}

impl<'a> Iterator for LightGridIterator<'a> {
    type Item = u32;

    fn next(&mut self) -> Option<Self::Item> {
        if self.pos == Point(1_000, 0) {
            return None;
        }

        let result = self.lg[Point(self.pos.0, self.pos.1)];

        self.pos = match self.pos {
            Point(x, 999) => Point(x+1, 0),
            Point(x, y) => Point(x, y+1),
        };

        Some(result)
    }
}

#[derive(Debug)]
struct Instruction {
    instruction: String,
    rect: Rect,
}

impl Instruction {
    fn new(string: String) -> Instruction {
        let re = Regex::new(r"^([ \w]+) (\d+),(\d+) through (\d+),(\d+)$").unwrap();
        let caps = re.captures(&string).unwrap();

        let p1 = Point(caps.at(2).unwrap().parse().unwrap(),
                       caps.at(3).unwrap().parse().unwrap());
        let p2 = Point(caps.at(4).unwrap().parse().unwrap(),
                       caps.at(5).unwrap().parse().unwrap());

        Instruction {
            instruction: caps.at(1).unwrap().to_string(),
            rect: Rect(p1, p2),
        }
    }
}

#[test]
fn test_instruction() {
    let instruction = Instruction::new("turn on 0,0 through 999,999".to_string());
    assert_eq!("turn on", instruction.instruction);
    assert_eq!(Rect(Point(0, 0), Point(999, 999)), instruction.rect);

    let instruction = Instruction::new("toggle 0,0 through 999,0".to_string());
    assert_eq!("toggle", instruction.instruction);
    assert_eq!(Rect(Point(0, 0), Point(999, 0)), instruction.rect);
}

#[derive(Debug,PartialEq)]
struct Rect(Point, Point);

#[derive(Debug,PartialEq)]
struct Point(usize, usize);
