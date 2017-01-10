#![feature(field_init_shorthand, inclusive_range_syntax, try_from)]
#![recursion_limit = "1024"]

#[macro_use]
extern crate error_chain;
extern crate regex;
extern crate crypto;

mod assembunny;
pub mod errors;
pub mod day_01;
pub mod day_02;
pub mod day_03;
pub mod day_04;
pub mod day_05;
pub mod day_06;
pub mod day_07;
pub mod day_08;
// pub mod day_09;
// pub mod day_10;
pub mod day_11;
pub mod day_12;
pub mod day_23;
