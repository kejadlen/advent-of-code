#![feature(conservative_impl_trait)]

extern crate failure;
#[macro_use]
extern crate lazy_static;

use std::io::{self, Read};

use failure::Error;

mod day_01;
mod day_02;
mod day_03;
mod day_04;
mod day_05;

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

fn main() {
    let mut a = Generator{value: 679, factor: 16807};
    let mut b = Generator{value: 771, factor: 48271};

    let answer = a.filter(|a| a % 4 == 0).zip(b.filter(|b| b % 8 == 0))
        .take(5_000_000)
        .filter(|&(a,b)| a & 0b1111111111111111 == b & 0b1111111111111111)
        .count();
    println!("{}", answer);

// p a.zip(b).take(40_000_000).with_index.count {|(a,b),i|
  // p i if i % 1_000_000 == 0
  // a.to_s(2)[-16,16] == b.to_s(2)[-16,16]
// }

    // if let Err(e) = run() {
    //     eprintln!("{}", e);
    // }
}

fn run() -> Result<(), Error> {
    let mut input = String::new();
    io::stdin().read_to_string(&mut input)?;

    let solution = day_05::solve(&input)?;
    println!("{}", solution);

    Ok(())
}
