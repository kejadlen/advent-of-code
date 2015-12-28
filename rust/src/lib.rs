use std::io::Error;

pub trait Day {
    fn new(String) -> Self;
    fn solve(self) -> Result<i32, Error>;
}

pub struct Day01 {
    input: String,
}

impl Day for Day01 {
    fn new(input: String) -> Day01 {
        Day01 { input: input }
    }

    fn solve(self) -> Result<i32, Error> {
        Ok(1)
    }
}
