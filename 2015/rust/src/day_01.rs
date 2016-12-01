use std::str::Chars;

pub fn solve(input: &str) -> i32 {
    let elevator = Elevator::new(input.to_string());
    1 + elevator.run().position(|f| f == -1).unwrap_or(0) as i32
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
