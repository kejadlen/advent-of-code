use std::collections::HashMap;
use std::fmt;

use regex::Regex;

use errors::*;

pub fn solve(input: &str) -> Result<String> {
  let rect_re = Regex::new(r"rect (\d+)x(\d+)").unwrap();
  let rotate_re = Regex::new(r"rotate (column x|row y)=(\d+) by (\d+)").unwrap();

  let mut screen = Screen::new(50, 6);
  for line in input.lines() {
    if let Some(caps) = rect_re.captures(line) {
      screen.rect(caps[1].parse().unwrap(), caps[2].parse().unwrap());
    } else if let Some(caps) = rotate_re.captures(line) {
      let index =  caps[2].parse().unwrap();
      let count = caps[3].parse().unwrap();
      if &caps[1] == "column x" {
        screen.rotate_col(index, count);
      } else if &caps[1] == "row y" {
        screen.rotate_row(index, count);
      }
    } else {
      return Err(format!("unexpected input: '{}'", line).into());
    }
  }

  Ok(format!("{}", screen.pixels.iter().filter(|&(_, &v)| v).count()))
  // Ok(format!("{}", screen))
}

#[derive(Eq,Hash,PartialEq)]
struct Point(usize, usize);

type Pixel = bool;

pub struct Screen {
  width: usize,
  height: usize,
  pixels: HashMap<Point, Pixel>,
}

impl Screen {
  fn new(width: usize, height: usize) -> Self {
    Screen {
      width: width,
      height: height,
      pixels: HashMap::new(),
    }
  }

  fn rect(&mut self, x: usize, y: usize) {
    for x in 0..x {
      for y in 0..y {
        self.pixels.insert(Point(x, y), true);
      }
    }
  }

  fn rotate_col(&mut self, index: usize, count: usize) {
    let count = count % self.height;

    let mut col = (0..self.height)
      .map(|y| self.pixels.get(&Point(index, y)).cloned().unwrap_or(false))
      .collect::<Vec<_>>();
    let col = Self::rotate(&mut col, count);

    for (y, &pixel) in col.iter().enumerate() {
      self.pixels.insert(Point(index, y), pixel);
    }
  }

  fn rotate_row(&mut self, index: usize, count: usize) {
    let count = count % self.width;

    let mut row = (0..self.width)
      .map(|x| self.pixels.get(&Point(x, index)).cloned().unwrap_or(false))
      .collect::<Vec<_>>();
    let row = Self::rotate(&mut row, count);

    for (x, &pixel) in row.iter().enumerate() {
      self.pixels.insert(Point(x, index), pixel);
    }
  }

  fn rotate<T: Clone>(v: &mut Vec<T>, count: usize) -> Vec<T> {
    let count = v.len() - count - 1;
    v[(count + 1)..].iter().chain(v[0...count].iter()).cloned().collect()
  }
}

impl fmt::Display for Screen {
  fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
    let s = (0..self.height)
      .map(|y| {
        (0..self.width)
          .map(|x| {
            if self.pixels.get(&Point(x, y)).cloned().unwrap_or(false) {
              '#'
            } else {
              '.'
            }
          })
          .collect::<String>()
      })
      .collect::<Vec<_>>()
      .join("\n");
    write!(f, "{}", s)
  }
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn test_screen() {
    let mut screen = Screen::new(7, 3);
    assert_eq!(format!("{}", screen),
               ".......
.......
.......");

    screen.rect(3, 2);
    assert_eq!(format!("{}", screen),
               "###....
###....
.......");

    screen.rotate_col(1, 1);
    assert_eq!(format!("{}", screen),
               "#.#....
###....
.#.....");

    screen.rotate_row(0, 4);
    assert_eq!(format!("{}", screen),
               "....#.#
###....
.#.....");

    screen.rotate_col(1, 1);
    assert_eq!(format!("{}", screen),
               ".#..#.#
#.#....
.#.....");
  }
}
