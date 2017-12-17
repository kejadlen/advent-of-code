#![feature(conservative_impl_trait, inclusive_range_syntax, match_default_bindings, slice_rotate,
           try_from)]

extern crate failure;
#[macro_use]
extern crate lazy_static;
extern crate regex;
extern crate time;

use std::io::{self, Read};

use failure::Error;

mod day_01;
mod day_02;
mod day_03;
mod day_04;
mod day_05;
mod day_06;
mod day_15;
mod day_16;

fn main() {
    if let Err(e) = run() {
        eprintln!("{}", e);
    }
}

fn run() -> Result<(), Error> {
    let mut input = String::new();
    io::stdin().read_to_string(&mut input)?;

    let solution = day_16::solve(&input)?;
    println!("{}", solution);

    Ok(())
}
