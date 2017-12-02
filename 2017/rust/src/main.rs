extern crate failure;

use std::io::{self, Read};

use failure::Error;

mod day_01;
mod day_02;

fn main() {
    if let Err(e) = run() {
        eprintln!("{}", e);
    }
}

fn run() -> Result<(), Error> {
    let mut input = String::new();
    io::stdin().read_to_string(&mut input)?;

    let solution = day_02::solve(&input)?;
    println!("{}", solution);

    Ok(())
}
