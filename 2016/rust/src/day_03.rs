pub fn solve(input: &str) -> String {
  let parsed = input.lines()
    .map(|line| {
      line.split_whitespace().map(str::parse).collect::<Result<Vec<usize>, _>>()
    })
    .collect::<Result<Vec<_>, _>>()
    .expect("couldn't parse input");
  let count = parsed.chunks(3)
    .flat_map(|chunk| {
      vec![
      Triangle(chunk[0][0], chunk[1][0], chunk[2][0]),
      Triangle(chunk[0][1], chunk[1][1], chunk[2][1]),
      Triangle(chunk[0][2], chunk[1][2], chunk[2][2]),
    ]
    })
    .filter(Triangle::is_valid)
    .count();

  count.to_string()
}

struct Triangle(usize, usize, usize);
impl Triangle {
  fn is_valid(&self) -> bool {
    self.0 + self.1 > self.2 && self.0 + self.2 > self.1 &&
    self.1 + self.2 > self.0
  }
}

#[test]
fn test_triangle() {
  assert!(!Triangle(5, 10, 25).is_valid());
}
