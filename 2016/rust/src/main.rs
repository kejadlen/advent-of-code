use std::env;
use std::fs::File;
use std::io::prelude::*;

extern crate advent_of_code_2016;
use advent_of_code_2016::*;
use advent_of_code_2016::errors::*;

fn main() {
  run(|| {
    let filename = env::args().nth(1).ok_or("")?;
    let mut f = File::open(filename).chain_err(|| "")?;
    let mut input = String::new();
    f.read_to_string(&mut input).chain_err(|| "")?;

    let solution = day_23::solve(&input)?;
    println!("{}", solution);

    Ok(())
  });
}

fn run<F>(f: F)
  where F: Fn() -> Result<()>
{
  if let Err(error) = f() {
    for error in error.iter() {
      println!("{}", error);
    }
    std::process::exit(1);
  }
}
