use std::error::Error;
use std::io::{self, Read};

fn main() -> Result<(), Box<Error>> {
    let mut input = String::new();
    io::stdin().read_to_string(&mut input)?;

    let output = solve(&input);
    println!("{}", output);

    Ok(())
}

fn solve(input: &str) -> String {
    let box_ids: Vec<_> = input.lines().map(BoxId::new).collect();

    let two_count = box_ids.iter().filter(|&x| x.is_two()).count();
    let three_count = box_ids.iter().filter(|&x| x.is_three()).count();

    (two_count * three_count).to_string()
}

struct BoxId(String);

impl BoxId {
    fn new(s: &str) -> Self {
        BoxId(s.into())
    }

    fn is_two(&self) -> bool {
        self.is_n(2)
    }

    fn is_three(&self) -> bool {
        self.is_n(3)
    }

    fn is_n(&self, n: usize) -> bool {
        self.0
            .chars()
            .any(|x| self.0.chars().filter(|&y| x == y).count() == n)
    }
}

#[test]
fn test_is_two() {
    assert_eq!(BoxId::new("abcdef").is_two(), false);
    assert_eq!(BoxId::new("bababc").is_two(), true);
    assert_eq!(BoxId::new("abbcde").is_two(), true);
    assert_eq!(BoxId::new("abcccd").is_two(), false);
    assert_eq!(BoxId::new("aabcdd").is_two(), true);
    assert_eq!(BoxId::new("abcdee").is_two(), true);
    assert_eq!(BoxId::new("ababab").is_two(), false);
}

#[test]
fn test_is_three() {
    assert_eq!(BoxId::new("abcdef").is_three(), false);
    assert_eq!(BoxId::new("bababc").is_three(), true);
    assert_eq!(BoxId::new("abbcde").is_three(), false);
    assert_eq!(BoxId::new("abcccd").is_three(), true);
    assert_eq!(BoxId::new("aabcdd").is_three(), false);
    assert_eq!(BoxId::new("abcdee").is_three(), false);
    assert_eq!(BoxId::new("ababab").is_three(), true);
}
