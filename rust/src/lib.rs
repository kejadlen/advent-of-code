use std::io::Error;
use std::str::Chars;

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
        let elevator = Elevator::new(self.input);
        Ok(elevator.run().last().unwrap_or(0))
    }
}

struct Elevator {
    instructions: String,
}

impl<'a> Elevator {
    fn new(input: String) -> Self {
        Elevator { instructions: input }
    }

    fn run(self: &'a Self) -> ElevatorIterator<'a> {
        ElevatorIterator {
            chars: self.instructions.chars(),
            floor: 0,
        }
    }
}

struct ElevatorIterator<'a> {
    chars: Chars<'a>,
    floor: i32,
}

impl<'a> Iterator for ElevatorIterator<'a> {
    type Item = i32;

    fn next(&mut self) -> Option<i32> {
        match self.chars.next() {
            Some('(') => {
                self.floor += 1;
                Some(self.floor)
            },
            Some(')') => {
                self.floor -= 1;
                Some(self.floor)
            },
            _ => {
                None
            },
        }
    }
}
