use std::collections::HashMap;

use errors::*;

pub fn solve(input: &str) -> Result<String> {
  let mut counters = HashMap::new();
  for line in input.lines() {
    for (i, c) in line.chars().enumerate() {
      let mut col = counters.entry(i).or_insert_with(HashMap::new);
      *col.entry(c).or_insert(0) += 1
    }
  }

  let mut counters: Vec<_> = counters.iter().collect();
  counters.sort_by_key(|&(idx, _)| idx);
  Ok(counters.iter()
    .map(|&(_, col)| {
      let mut v: Vec<_> = col.iter().collect();
      v.sort_by_key(|&(_, count)| count);
      v.iter().map(|&(chr, _)| *chr).last().unwrap()
    })
    .collect())
}

#[test]
fn test_solve() {
  let input = "eedadn
drvtee
eandsr
raavrd
atevrs
tsrnev
sdttsa
rasrtv
nssdts
ntnada
svetve
tesnvt
vntsnd
vrdear
dvrsen
enarar";
  assert_eq!(solve(input).unwrap(), "easter".to_string());
}
