pub fn solve(input: &str) -> i32 {
  input.lines().map(|line| Present::new(line).ribbon()).sum::<u32>() as i32
}

struct Present {
  length: u32,
  width: u32,
  height: u32,
}

#[allow(dead_code)]
impl Present {
  fn new(input: &str) -> Self {
    let dimensions = input.split('x')
      .map(|d| d.parse::<u32>().unwrap())
      .collect::<Vec<_>>();
    Present {
      length: dimensions[0],
      width: dimensions[1],
      height: dimensions[2],
    }
  }

  fn wrapping_paper(&self) -> u32 {
    self.surface_area() + self.slack()
  }

  fn ribbon(&self) -> u32 {
    *self.perimeters().iter().min().unwrap_or(&0) + self.volume()
  }

  fn surface_area(&self) -> u32 {
    self.side_areas().iter().map(|area| 2 * area).sum()
  }

  fn slack(&self) -> u32 {
    *self.side_areas().iter().min().unwrap_or(&0)
  }

  fn perimeters(&self) -> Vec<u32> {
    vec![self.length + self.width,
         self.width + self.height,
         self.height + self.length]
      .iter()
      .map(|&x| 2 * x)
      .collect()
  }

  fn volume(&self) -> u32 {
    self.length * self.width * self.height
  }

  fn side_areas(&self) -> Vec<u32> {
    vec![self.length * self.width,
         self.width * self.height,
         self.height * self.length]
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
