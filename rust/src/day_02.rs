use std::io;

use day::Day;

pub struct Day02 {
    input: String,
}

impl Day for Day02 {
    fn new(input: String) -> Day02 {
        Day02 { input: input }
    }

    fn solve(self) -> io::Result<i32> {
        Ok(1)
    }
}

struct Present {
    length: u32,
    width: u32,
    height: u32,
}

impl Present {
    fn new(input: String) -> Self {
        let dimensions = input.split("x")
                              .map(|d| d.parse::<u32>().unwrap())
                              .collect::<Vec<u32>>();
        Present { length: dimensions[0], width: dimensions[1], height: dimensions[2] }
    }

    fn wrapping_paper(&self) -> u32 {
        self.surface_area() + self.slack()
    }

    fn surface_area(&self) -> u32 {
        self.side_areas().iter().fold(0, |acc, &area| acc + 2 * area)
    }

    fn slack(&self) -> u32 {
        *self.side_areas().iter().min().unwrap_or(&0)
    }

    fn side_areas(&self) -> Vec<u32> {
        vec![self.length * self.width, self.width * self.height, self.height * self.length]
    }
}

#[test]
fn test_day02() {
    let mut present = Present::new("2x3x4".to_string());
    assert_eq!(52, present.surface_area());
    assert_eq!(6, present.slack());
    assert_eq!(58, present.wrapping_paper());

    present = Present::new("1x1x10".to_string());
    assert_eq!(42, present.surface_area());
    assert_eq!(1, present.slack());
    assert_eq!(43, present.wrapping_paper());
}
