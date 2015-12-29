use std::fs::File;
use std::io::prelude::*;
use std::io;
use std::path::PathBuf;

extern crate advent_of_code;
use advent_of_code::*;

fn read_input(filename: &str) -> Result<String, io::Error> {
    let mut path = PathBuf::from(".");
    path.push("input");
    path.push(filename);
    path.set_extension("txt");

    let mut f = try!(File::open(path));
    let mut s = String::new();
    try!(f.read_to_string(&mut s));
    Ok(s)
}

fn main() {
    let input = read_input("day_03").unwrap();
    let day = Day03::new(&input);
    println!("{}", day.solve().unwrap());
}
