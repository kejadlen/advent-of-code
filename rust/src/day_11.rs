use std::collections::HashSet;

#[derive(Debug, Eq, PartialEq)]
pub struct Password(String);
impl Password {
  pub fn new(s: &str) -> Self {
    Password(s.into())
  }

  pub fn is_valid(&self) -> bool {
    self.has_increasing_straight() && !self.has_confusing_chars() &&
    self.has_different_nonoverlapping_pairs()
  }

  pub fn next(&self) -> Self {
    StringIncrementor::new(&self.0).map(|x| Self::new(&x)).find(|ref x| {
      x.is_valid()
    }).unwrap()
  }

  fn has_increasing_straight(&self) -> bool {
    self.0
      .chars()
      .collect::<Vec<_>>()
      .windows(3)
      .any(|w| w.windows(2).all(|x| (x[1] as i8) - (x[0] as i8) == 1))
  }

  fn has_confusing_chars(&self) -> bool {
    self.0.chars().any(|c| ['i', 'l', 'o'].contains(&c))
  }

  fn has_different_nonoverlapping_pairs(&self) -> bool {
    let slice = self.0.chars().collect::<Vec<_>>();
    slice.windows(2).filter_map(|x| {
      if x[0] == x[1] { Some(x[0]) } else { None }
    }).collect::<HashSet<_>>().len() > 1
  }
}

impl From<Password> for String {
  fn from(p: Password) -> String {
    p.0
  }
}

struct StringIncrementor {
  s: String,
}

impl StringIncrementor {
  fn new(s: &str) -> Self {
    StringIncrementor{s: s.into()}
  }
}

impl Iterator for StringIncrementor {
  type Item = String;

  fn next(&mut self) -> Option<String> {
    self.s = self.s.chars()
        .rev()
        .scan(true, |carry, x| {
            if !*carry {
                return Some(x);
            }

            if x == 'z' {
                Some('a')
            } else {
                *carry = false;
                Some((x as u8 + 1) as char)
            }
        })
        .collect::<Vec<_>>()
        .iter()
        .map(|&x| x)
        .rev()
        .collect();
      Some(self.s.clone())
  }
}

#[test]
fn test_string_incrementor() {
  assert_eq!(StringIncrementor::new("abcdefgh").next(), Some("abcdefgi".into()));
  assert_eq!(StringIncrementor::new("az").next(), Some("ba".into()));
}

#[cfg(test)]
mod test {
  use super::*;

  #[test]
  fn test_password() {
    assert!(!Password::new("hijklmmn").is_valid());
    assert!(!Password::new("abbceffg").is_valid());
    assert!(!Password::new("abbcegjk").is_valid());
    assert!(!Password::new("ghjaaaaa").is_valid());

    assert_eq!(Password::new("abcdefgh").next(), Password::new("abcdffaa"));
    assert_eq!(Password::new("ghijklmn").next(), Password::new("ghjaabcc"));
  }
}
