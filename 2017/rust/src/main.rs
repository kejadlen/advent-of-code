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
mod day_15;

fn main() {
    if let Err(e) = run() {
        eprintln!("{}", e);
    }
}

fn run() -> Result<(), Error> {
    let mut input = String::new();
    io::stdin().read_to_string(&mut input)?;

    let solution = day_15::solve(&input)?;
    println!("{}", solution);

    Ok(())
}
