pub fn solve(input: &str) -> String {
  let parsed = input.split_whitespace()
    .map(str::parse)
    .collect::<Result<Vec<usize>, _>>()
    .expect("unable to parse input");
  let count = parsed.chunks(3)
    .map(|w| Triangle(w[0], w[1], w[2]))
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
