use std::io;
use std::io::Read;
use std::f32::consts::PI;

fn solve(input: &str) -> String {
  let mut turtle = (-PI / 2.0, (0, 0));

  for step in input.split(", ") {
    let mut chars = step.chars();
    let dir = chars.next().unwrap();
    let blocks = chars.collect::<String>().parse::<f32>().unwrap();

    turtle.0 += match dir {
      'R' => PI / 2.0,
      'L' => -PI / 2.0,
      _ => {
        unreachable!();
      }
    };

    let movement = turtle.0.sin_cos();
    (turtle.1).0 += (blocks*movement.1) as i32;
    (turtle.1).1 += (blocks*movement.0) as i32;
  }

  ((turtle.1).0.abs() + (turtle.1).1.abs()).to_string()
}

#[test]
fn test_solve() {
  assert_eq!(solve("R2, L3"), "5".to_string());
  assert_eq!(solve("R2, R2, R2"), "2".to_string());
  assert_eq!(solve("R5, L5, R5, R3"), "12".to_string());
}

fn main() {
  let mut input = String::new();
  io::stdin().read_to_string(&mut input).ok();

  println!("{}", solve(&input));
}
