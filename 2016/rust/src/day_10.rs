use std::collections::HashMap;

use regex::Regex;

use errors::*;

pub fn solve(input: &str) -> Result<String> {
  Ok("".into())
}

struct Factory {
  bots: HashMap<usize, Bot>,
}

impl Factory {
  fn parse(input: &str) -> Result<Self> {
    let re =
      Regex::new(r"bot (\d+) gives low to bot (\d+) and high to bot (\d+)")
        .unwrap();

    let mut bots = HashMap::new();
    for line in input.lines() {
      if let Some(caps) = re.captures(line) {
        let id = caps[1].parse().unwrap();
        bots.insert(id,
                    Bot {
                      id: id,
                      values: Vec::new(),
                    });
      }
    }
    Ok(Factory { bots: bots })
  }
}

struct Bot {
  id: usize,
  values: Vec<usize>,
}

impl Bot {
  fn push(&mut self, value: usize) {
    self.values.push(value);
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
  let mut factory = Factory::parse(input).unwrap();

  assert_eq!(factory.bots.len(), 1);

  let mut bot = factory.bots.get_mut(&2).unwrap();
  bot.push(2);
  assert_eq!(bot.values, vec![2]);

  // After running, outputs are 5, 2, 3.
}
