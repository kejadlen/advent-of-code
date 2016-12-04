use std::io;
use std::io::Read;

extern crate advent_of_code_2016;
use advent_of_code_2016::*;

fn main() {
  let mut input = String::new();
  io::stdin().read_to_string(&mut input).ok();

  println!("{}", day_04::solve(&input).unwrap());
}
