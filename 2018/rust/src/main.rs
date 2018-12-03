use std::io::{self, Read};

mod day_01;
mod day_02;

fn main() {
    let mut input = String::new();
    io::stdin().read_to_string(&mut input).unwrap();

    let output = day_02::solve(&input);
    println!("{}", output);
}
