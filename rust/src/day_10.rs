#[test]
fn test_day_10() {
    let mut foo = LookAndSay { seq: vec![2, 1, 1] };
    assert_eq!(vec![1, 2, 2, 1], foo.next().unwrap());

    foo = LookAndSay { seq: vec![1] };
    assert_eq!(vec![1, 1], foo.next().unwrap());
    assert_eq!(vec![2, 1], foo.next().unwrap());
    assert_eq!(vec![1, 2, 1, 1], foo.next().unwrap());
    assert_eq!(vec![1, 1, 1, 2, 2, 1], foo.next().unwrap());
    assert_eq!(vec![3, 1, 2, 2, 1, 1], foo.next().unwrap());
}

pub fn solve(input: &str) -> usize {
    let seq = input
        .chars()
        .map(|c| c.to_digit(10).unwrap() as usize)
        .collect::<Vec<usize>>();
    let mut look_and_say = LookAndSay { seq: seq };

    for _ in 0..50  {
        look_and_say.next();
    }

    look_and_say.seq.len()
}

struct LookAndSay {
    seq: Vec<usize>,
}

impl Iterator for LookAndSay {
    type Item = Vec<usize>;

    fn next(&mut self) -> Option<Vec<usize>> {
        let mut s = Vec::new();

        let mut digit = self.seq[0];
        let mut count = 0;

        for &i in &self.seq {
            if i != digit {
                s.push(count);
                s.push(digit);

                digit = i;
                count = 1;
            } else {
                count += 1;
            }
        }
        s.push(count);
        s.push(digit);

        self.seq = s.clone();

        Some(s)
    }
}
