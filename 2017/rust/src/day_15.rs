use failure::*;

pub fn solve(_: &str) -> Result<String, Error> {
    let a = Generator {
        value: 679,
        factor: 16807,
    };
    let b = Generator {
        value: 771,
        factor: 48271,
    };

    let answer = a.filter(|a| a % 4 == 0)
        .zip(b.filter(|b| b % 8 == 0))
        .take(5_000_000)
        .filter(|&(a, b)| a & 0b1111111111111111 == b & 0b1111111111111111)
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
        self.value %= 2147483647;
        Some(self.value)
    }
}
