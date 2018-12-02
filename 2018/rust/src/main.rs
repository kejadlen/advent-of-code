use std::io::{self, Read};

mod day_01;

fn main() {
    let mut input = String::new();
    io::stdin().read_to_string(&mut input).unwrap();

    let output = day_01::solve_1(&input, "\n");
    println!("{}", output);
}
