use std::char;
use std::collections::HashMap;

use crypto::digest::Digest;
use crypto::md5::Md5;

use errors::*;

pub fn solve(input: &str) -> Result<String> {
  let mut pw = Password::new(input.trim());
  let mut solution = HashMap::new();
  while solution.len() < 8 {
    let candidate = pw.next().unwrap();
    if candidate.0 < 8 {
      solution.entry(candidate.0).or_insert(candidate.1);
    }
  }
  let mut v = solution.iter().collect::<Vec<_>>();
  v.sort();
  Ok(v.iter().map(|x| *x.1).collect::<String>())
}

struct Password {
  id: String,
  index: usize,
  md5: Md5,
}

impl Password {
  fn new(id: &str) -> Self {
    Password{id: id.into(), index: 0, md5: Md5::new()}
  }
}

impl Iterator for Password {
  type Item = (usize, char);

  fn next(&mut self) -> Option<(usize, char)> {
    let mut result = None;
    let mut hash = [0; 16];

    while result.is_none() {
      let input = format!("{}{}", self.id, self.index);
      self.index += 1;

      self.md5.input_str(&input);
      self.md5.result(&mut hash);
      self.md5.reset();

      if hash[0] as u16 + hash[1] as u16 + (hash[2] >> 4) as u16 == 0 {
        let pos = (hash[2] & 0b00001111) as usize;
        let c = char::from_digit((hash[3] >> 4) as u32, 16).unwrap();
        result = Some((pos, c));
        break
      }
    }
    result
  }
}

#[test]
fn test_password() {
  let mut pw = Password{id: "abc".into(), index: 3231928, md5: Md5::new()};
  assert_eq!(pw.next(), Some((1, '5'.into())));
  assert_eq!(pw.index, 3231930);

  let mut pw = Password{id: "abc".into(), index: 5017308, md5: Md5::new()};
  assert_eq!(pw.next(), Some((8, 'f'.into())));
  // assert_eq!(pw.next(), Some((4, 'e'.into())));
}
