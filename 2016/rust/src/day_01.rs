use std::collections::HashSet;
use std::f32::consts::PI;

pub fn solve(input: &str) -> String {
  let mut turtle = (-PI / 2.0, (0, 0));
  let mut visited: HashSet<(i32, i32)> = HashSet::new();

  for step in input.split(", ") {
    let mut chars = step.chars();
    let dir = chars.next().unwrap();
    let blocks = chars.collect::<String>().parse::<i32>().unwrap();

    turtle.0 += match dir {
      'R' => PI / 2.0,
      'L' => -PI / 2.0,
      _ => {
        unreachable!();
      }
    };

    for _ in 0..blocks {
      let movement = turtle.0.sin_cos();
      (turtle.1).0 += movement.1 as i32;
      (turtle.1).1 += movement.0 as i32;

      if visited.contains(&turtle.1) {
        return ((turtle.1).0.abs() + (turtle.1).1.abs()).to_string()
      } else {
        visited.insert(turtle.1);
      }
    }
  }

  ((turtle.1).0.abs() + (turtle.1).1.abs()).to_string()
}

#[test]
fn test_solve() {
  // assert_eq!(solve("R2, L3"), "5".to_string());
  // assert_eq!(solve("R2, R2, R2"), "2".to_string());
  // assert_eq!(solve("R5, L5, R5, R3"), "12".to_string());
  assert_eq!(solve("R8, R4, R4, R8"), "4".to_string());
}
