use std::char;

use crypto::digest::Digest;
use crypto::md5::Md5;

use errors::*;

pub fn solve(input: &str) -> Result<String> {
  let pw = Password::new(input.trim());
  Ok(pw.take(8).collect())
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
  // we will be counting with usize
  type Item = char;

  // next() is the only required method
  fn next(&mut self) -> Option<char> {
    let mut result = None;
    let mut hash = [0; 16];

    while result.is_none() {
      let input = format!("{}{}", self.id, self.index);
      self.index += 1;

      self.md5.input_str(&input);
      self.md5.result(&mut hash);
      self.md5.reset();

      if self.index % 1000000 == 0 {
        println!("{}", self.index);
      }

      if hash[0] as u16 + hash[1] as u16 + (hash[2] >> 4) as u16 == 0 {
        result = Some(char::from_digit((hash[2] & 0b00001111) as u32, 16).unwrap());
        break
      }
    }
    result
  }
}

#[test]
fn test_password() {
  let mut pw = Password{id: "abc".into(), index: 3231928, md5: Md5::new()};
  assert_eq!(pw.next(), Some('1'.into()));
  assert_eq!(pw.index, 3231930);

  let mut pw = Password{id: "abc".into(), index: 5017308, md5: Md5::new()};
  assert_eq!(pw.next(), Some('8'.into()));
  assert_eq!(pw.next(), Some('f'.into()));
}
