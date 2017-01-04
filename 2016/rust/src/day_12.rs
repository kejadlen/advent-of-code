use std::collections::HashMap;

use errors::*;

pub fn solve(input: &str) -> Result<String> {
    Ok("".into())
}

// The assembunny code you've extracted operates on four registers (a, b, c, and d) that start at 0
// and can hold any integer. However, it seems to make use of only a few instructions:
#[derive(Clone, Copy, Debug, Hash, Eq, PartialEq)]
enum Register {
    A,
    B,
    C,
    D,
}

#[derive(Clone, Copy)]
enum Variable {
    Register(Register),
    Value(isize),
}

impl From<Register> for Variable {
    fn from(r: Register) -> Self {
        Variable::Register(r)
    }
}

impl From<isize> for Variable {
    fn from(i: isize) -> Self {
        Variable::Value(i)
    }
}

#[derive(Debug, PartialEq)]
struct State {
    pc: usize,
    registers: HashMap<Register, isize>,
}

impl State {
    fn value(&self, v: Variable) -> isize {
        match v {
            Variable::Register(ref r) => {
                self.registers.get(r).cloned().unwrap_or(0 as isize)
            }
            Variable::Value(value) => value,
        }
    }
}

// cpy x y copies x (either an integer or the value of a register) into register y.
struct Copy {
    variable: Variable,
    register: Register,
}

impl Copy {
    fn run(&self, state: &State) -> State {
        let pc = state.pc + 1;
        let mut registers = state.registers.clone();
        let value = state.value(self.variable);
        registers.insert(self.register, value);
        State {
            pc: pc,
            registers: registers,
        }
    }
}

// inc x increases the value of register x by one.
struct Increment {
    register: Register,
}

impl Increment {
    fn run(&self, state: &State) -> State {
        let pc = state.pc + 1;
        let mut registers = state.registers.clone();
        let value = state.value(self.register.into()) + 1;
        registers.insert(self.register, value);
        State {
            pc: pc,
            registers: registers,
        }
    }
}

// dec x decreases the value of register x by one.
struct Decrement {
    register: Register,
}

impl Decrement {
    fn run(&self, state: &State) -> State {
        let pc = state.pc + 1;
        let mut registers = state.registers.clone();
        let value = state.value(self.register.into()) - 1;
        registers.insert(self.register, value);
        State {
            pc: pc,
            registers: registers,
        }
    }
}

// jnz x y jumps to an instruction y away (positive means forward; negative means backward), but only if x is not zero.

#[cfg(test)]
mod tests {
    use super::{Variable, Register, State, Copy, Increment, Decrement};

    #[test]
    fn test_state_value() {
        let state = State {
            pc: 0,
            registers: vec![(Register::A, 41)].into_iter().collect(),
        };
        assert_eq!(state.value(Register::A.into()), 41);
        assert_eq!(state.value(Register::B.into()), 0);
        assert_eq!(state.value(23.into()), 23);
    }

    #[test]
    fn test_copy() {
        let variable = Variable::Value(41);
        let register = Register::A;
        let copy = Copy {
            variable: variable,
            register: register,
        };
        let state = State {
            pc: 0,
            registers: vec![].into_iter().collect(),
        };
        let expected = State {
            pc: 1,
            registers: vec![(Register::A, 41)].into_iter().collect(),
        };

        assert_eq!(copy.run(&state), expected);
    }

    #[test]
    fn test_increment() {
        let increment = Increment { register: Register::A };
        let state = State {
            pc: 0,
            registers: vec![(Register::A, 41)].into_iter().collect(),
        };
        let expected = State {
            pc: 1,
            registers: vec![(Register::A, 42)].into_iter().collect(),
        };

        assert_eq!(increment.run(&state), expected);
    }

    #[test]
    fn test_decrement() {
        let decrement = Decrement { register: Register::A };
        let state = State {
            pc: 0,
            registers: vec![(Register::A, 41)].into_iter().collect(),
        };
        let expected = State {
            pc: 1,
            registers: vec![(Register::A, 40)].into_iter().collect(),
        };

        assert_eq!(decrement.run(&state), expected);
    }
}
