use errors::*;

pub fn solve(input: &str) -> Result<String> {
  Ok(input.lines()
    .map(|x| IP7::new(x))
    .filter(IP7::supports_tls)
    .count()
    .to_string())
}

pub struct IP7 {
  supernets: Vec<String>,
  hypernets: Vec<String>,
}

impl IP7 {
  fn new(s: &str) -> Self {
    let mut current = String::new();
    let mut supernets = Vec::new();
    let mut hypernets = Vec::new();

    for c in s.chars() {
      match c {
        '[' => {
          supernets.push(current);
          current = String::new();
        }
        ']' => {
          hypernets.push(current);
          current = String::new();
        }
        c => current.push(c),
      }
    }
    supernets.push(current);

    IP7 {
      supernets: supernets,
      hypernets: hypernets,
    }
  }

  fn supports_tls(&self) -> bool {
    self.supernets.iter().any(|x| Self::abba(x)) &&
    self.hypernets.iter().all(|x| !Self::abba(x))
  }

  fn abba(s: &str) -> bool {
    let v: Vec<_> = s.chars().collect();
    v.windows(4).any(|w| (w[0] != w[1]) && (w[0] == w[3]) && (w[1] == w[2]))
  }
}

#[cfg(test)]
mod tests {
  use super::*;

  #[test]
  fn test_new() {
    let ip = IP7::new("abba[mnop]qrst");
    assert_eq!(ip.supernets, vec!["abba".to_string(), "qrst".to_string()]);
    assert_eq!(ip.hypernets, vec!["mnop".to_string()]);
  }

  #[test]
  fn test_abba() {
    assert!(IP7::abba("abba"));
    assert!(!IP7::abba("abcd"));
  }

  #[test]
  fn test_supports_tls() {
    assert_eq!(IP7::new("abba[mnop]qrst").supports_tls(), true);
    assert_eq!(IP7::new("abcd[bddb]xyyx").supports_tls(), false);
    assert_eq!(IP7::new("aaaa[qwer]tyui").supports_tls(), false);
    assert_eq!(IP7::new("ioxxoj[asdfgh]zxcvbn").supports_tls(), true);
  }
}
