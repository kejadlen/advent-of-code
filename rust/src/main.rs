use std::env;
use std::io::prelude::*;
use std::io;

extern crate advent_of_code;
use advent_of_code::*;

fn main() {
  let mut input = String::new();
  io::stdin().read_to_string(&mut input).ok();

  let solution: String =
    match env::args().nth(1).as_ref().map(String::as_ref) {
      Some("1") => day_01::solve(&input).to_string(),
      Some("2") => day_02::solve(&input).to_string(),
      Some("3") => day_03::solve(&input).to_string(),
      Some("4") => day_04::solve(&input).to_string(),
      Some("5") => day_05::solve(&input).to_string(),
      Some("6") => day_06::solve(&input).to_string(),
      Some("7") => day_07::solve(&input, "a").to_string(),
      Some("8") => day_08::solve(&input).to_string(),
      Some("9") => day_09::solve(&input).to_string(),
      _ => day_10::solve(&input),
    };

  println!("{}", solution);
}
