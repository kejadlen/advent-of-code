use std::io;

use day::Day;

pub struct Day02 {
    presents: Vec<Present>,
}

impl Day for Day02 {
    fn new(input: String) -> Day02 {
        let presents = input.split("\n").map(|line| Present::new(line));
        Day02 { presents: presents.collect::<Vec<Present>>() }
    }

    fn solve(self) -> io::Result<i32> {
        Ok(self.presents.iter().fold(0u32, |acc, present| acc + present.ribbon()) as i32)
    }
}

struct Present {
    length: u32,
    width: u32,
    height: u32,
}

#[allow(dead_code)]
impl Present {
    fn new(input: &str) -> Self {
        let dimensions = input.split("x")
                              .map(|d| d.parse::<u32>().unwrap())
                              .collect::<Vec<u32>>();
        Present { length: dimensions[0], width: dimensions[1], height: dimensions[2] }
    }

    fn wrapping_paper(&self) -> u32 {
        self.surface_area() + self.slack()
    }

    fn ribbon(&self) -> u32 {
        *self.perimeters().iter().min().unwrap_or(&0) + self.volume()
    }

    fn surface_area(&self) -> u32 {
        self.side_areas().iter().fold(0, |acc, &area| acc + 2 * area)
    }

    fn slack(&self) -> u32 {
        *self.side_areas().iter().min().unwrap_or(&0)
    }

    fn perimeters(&self) -> Vec<u32> {
        vec![self.length + self.width,
             self.width + self.height,
             self.height + self.length ].iter().map(|&x| 2 * x).collect()
    }

    fn volume(&self) -> u32 {
        self.length * self.width * self.height
    }

    fn side_areas(&self) -> Vec<u32> {
        vec![self.length * self.width, self.width * self.height, self.height * self.length]
    }
}

#[test]
fn test_day02() {
    let mut present = Present::new("2x3x4");
    assert_eq!(52, present.surface_area());
    assert_eq!(6, present.slack());
    assert_eq!(58, present.wrapping_paper());
    assert_eq!(34, present.ribbon());

    present = Present::new("1x1x10");
    assert_eq!(42, present.surface_area());
    assert_eq!(1, present.slack());
    assert_eq!(43, present.wrapping_paper());
    assert_eq!(14, present.ribbon());
}
