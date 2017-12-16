use failure::*;
use regex::Regex;

#[allow(dead_code)]
pub fn solve(input: &str) -> Result<String, Error> {
    let re: Regex = Regex::new(r"\d+")?;
    let matches: Vec<_> = re.find_iter(input)
        .map(|x| x.as_str())
        .map(str::parse)
        .collect::<Result<_, _>>()?;
    let a_start = matches[0];
    let b_start = matches[1];
    // let a_start = 679;
    // let b_start = 771;

    let a = Generator {
        value: a_start,
        factor: 16_807,
    };
    let b = Generator {
        value: b_start,
        factor: 48_271,
    };

    let answer = a.filter(|a| a % 4 == 0)
        .zip(b.filter(|b| b % 8 == 0))
        .take(5_000_000)
        .filter(|&(a, b)| a & 0b1111_1111_1111_1111 == b & 0b1111_1111_1111_1111)
        .count();
    Ok(answer.to_string())
}

struct Generator {
    value: usize,
    factor: usize,
}

impl Iterator for Generator {
    type Item = usize;

    fn next(&mut self) -> Option<Self::Item> {
        self.value *= self.factor;
        self.value %= 2_147_483_647;
        Some(self.value)
    }
}
