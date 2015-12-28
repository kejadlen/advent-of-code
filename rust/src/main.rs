extern crate advent_of_code;
use advent_of_code::*;

fn main() {
    let day = Day01::new("".to_string());
    match day.solve() {
        Ok(n) => println!("{}", n),
        Err(e) => println!("{}", e),
    }
}
