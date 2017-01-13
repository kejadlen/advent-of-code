use std::io;
use std::io::Read;

extern crate advent_of_code_2016;
use advent_of_code_2016::*;
use advent_of_code_2016::errors::*;

fn main() {
  run(|| {
    let mut input = String::new();
    io::stdin().read_to_string(&mut input).ok();

    let solution = day_11::solve(&input)?;
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
