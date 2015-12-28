use std::io;

pub trait Day {
    fn new(String) -> Self;
    fn solve(self) -> io::Result<i32>;
}
