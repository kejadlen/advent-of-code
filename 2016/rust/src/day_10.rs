use regex::Regex;

use errors::*;

pub fn solve(input: &str) -> Result<String> {
  Ok("".into())
}

struct Factory {
  bots: Vec<usize>,
}

impl Factory {
  fn parse(input: &str) -> Result<Self> {
    let re = Regex::new(r"bot (\d+) gives low to (bot|output) (\d+) and high to (bot|output) (\d+)").unwrap();

    let mut bots = Vec::new();
    for line in input.lines() {
      if let Some(caps) = re.captures(line) {
        bots.push(0);
      }
    }
    Ok(Factory { bots: bots })
  }
}

#[test]
fn test_factory() {
  let input = "value 5 goes to bot 2
bot 2 gives low to bot 1 and high to bot 0
value 3 goes to bot 1
bot 1 gives low to output 1 and high to bot 0
bot 0 gives low to output 2 and high to output 0
value 2 goes to bot 2";
  let factory = Factory::parse(input).unwrap();

  assert_eq!(factory.bots.len(), 3);

  // After running, outputs are 5, 2, 3.
}
