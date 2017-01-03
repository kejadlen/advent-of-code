use errors::*;

pub fn solve(input: &str) -> Result<String> {
  Ok(input.lines()
    .map(|x| IP7::new(x))
    .filter(IP7::supports_ssl)
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

  pub fn supports_tls(&self) -> bool {
    self.supernets.iter().any(|x| Self::abba(x)) &&
    self.hypernets.iter().all(|x| !Self::abba(x))
  }

  fn supports_ssl(&self) -> bool {
    let abas: Vec<String> =
      self.supernets.iter().flat_map(|x| {
        Self::abas(x).iter().map(|aba| {
          let mut c = aba.chars();
          let a = c.next().unwrap();
          let b = c.next().unwrap();
          format!("{}{}{}", b, a, b)
        }).collect::<Vec<_>>()
      }).collect();
    self.hypernets.iter().any(|x| abas.iter().any(|y| x.contains(y)))
  }

  fn abba(s: &str) -> bool {
    let v: Vec<_> = s.chars().collect();
    v.windows(4).any(|w| (w[0] != w[1]) && (w[0] == w[3]) && (w[1] == w[2]))
  }

  fn abas(s: &str) -> Vec<String> {
    let v: Vec<_> = s.chars().collect();
    v.windows(3)
      .filter(|w| (w[0] != w[1]) && (w[0] == w[2]))
      .map(|w| w.iter().cloned().collect())
      .collect()
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

  #[test]
  fn test_abas() {
    assert_eq!(IP7::abas("zazbz"),
               vec!["zaz".to_string(), "zbz".to_string()]);
  }

  #[test]
  fn test_supports_ssl() {
    assert!(IP7::new("aba[bab]xyz").supports_ssl());
    assert!(!IP7::new("xyx[xyx]xyx").supports_ssl());
    assert!(IP7::new("aaa[kek]eke").supports_ssl());
    assert!(IP7::new("zazbz[bzb]cdb").supports_ssl());
  }
}
