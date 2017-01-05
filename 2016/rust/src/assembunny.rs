use std::ops;
use std::str;

use errors::*;

pub struct Assembunny {
    pub registers: Registers,
    pub instructions: Instructions,
}

impl Assembunny {
    fn value<V: Into<Variable>>(&self, v: V) -> isize {
        let v: Variable = v.into();
        match v {
            Variable::Register(r) => self.registers[r],
            Variable::Value(i) => i,
        }
    }
}

impl Iterator for Assembunny {
    type Item = Registers;

    fn next(&mut self) -> Option<Registers> {
        let pc = self.value(Register::PC) as usize;
        let instruction = match self.instructions.0.get(pc) {
            Some(i) => i,
            None => {
                return None;
            }
        };

        match *instruction {
            Instruction::Cpy(v, r) => {
                let value = self.value(v);
                self.registers[r] = value;
                self.registers[Register::PC] += 1;
            }
            Instruction::Inc(r) => {
                self.registers[r] += 1;
                self.registers[Register::PC] += 1;
            }
            Instruction::Dec(r) => {
                self.registers[r] -= 1;
                self.registers[Register::PC] += 1;
            }
            Instruction::Jnz(v, i) => {
                let delta = if self.value(v) == 0 { 1 } else { i };
                let pc = self.value(Register::PC) + delta;
                self.registers[Register::PC] = pc;
            }
        }

        Some(self.registers.clone())
    }
}

#[derive(Clone)]
pub struct Registers(Vec<isize>);
pub struct Instructions(Vec<Instruction>);

impl Registers {
    pub fn new() -> Self {
        Registers(vec![0; 5])
    }

    fn index(r: Register) -> usize {
        match r {
            Register::PC => 0,
            Register::A => 1,
            Register::B => 2,
            Register::C => 3,
            Register::D => 4,
        }
    }
}

impl ops::Index<Register> for Registers {
    type Output = isize;

    fn index(&self, _index: Register) -> &isize {
        self.0.index(Self::index(_index))
    }
}
impl ops::IndexMut<Register> for Registers {
    fn index_mut(&mut self, _index: Register) -> &mut isize {
        self.0.index_mut(Self::index(_index))
    }
}

#[derive(Clone, Copy, Debug, Hash, Eq, PartialEq)]
pub enum Register {
    PC,
    A,
    B,
    C,
    D,
}

#[derive(Clone, Copy, Debug, PartialEq)]
enum Instruction {
    Cpy(Variable, Register),
    Inc(Register),
    Dec(Register),
    Jnz(Variable, isize),
}

#[derive(Clone, Copy, Debug, PartialEq)]
enum Variable {
    Register(Register),
    Value(isize),
}

impl From<Register> for Variable {
    fn from(r: Register) -> Self {
        Variable::Register(r)
    }
}

// Parsing

impl str::FromStr for Instructions {
    type Err = Error;
    fn from_str(s: &str) -> Result<Self> {
        s.lines()
            .map(|line| line.parse())
            .collect::<Result<Vec<_>>>()
            .map(Instructions)
    }
}

impl str::FromStr for Register {
    type Err = Error;
    fn from_str(s: &str) -> Result<Self> {
        match s {
            "a" => Ok(Register::A),
            "b" => Ok(Register::B),
            "c" => Ok(Register::C),
            "d" => Ok(Register::D),
            _ => Err(format!("invalid register '{}'", s).into()),
        }
    }
}

impl str::FromStr for Instruction {
    type Err = Error;
    fn from_str(s: &str) -> Result<Self> {
        let mut tokens = s.split_whitespace();
        match tokens.next() {
            Some("cpy") => {
                let v = tokens.read_variable()?;
                let r = tokens.read_register()?;
                Ok(Instruction::Cpy(v, r))
            }
            Some("inc") => {
                let r = tokens.read_register()?;
                Ok(Instruction::Inc(r))
            }
            Some("dec") => {
                let r = tokens.read_register()?;
                Ok(Instruction::Dec(r))
            }
            Some("jnz") => {
                let var = tokens.read_variable()?;
                let val = tokens.read_value()?;
                Ok(Instruction::Jnz(var, val))
            }
            Some(inst) => Err(format!("invalid instruction '{}'", inst).into()),
            None => Err("no instruction".into()),
        }
    }
}

impl str::FromStr for Variable {
    type Err = Error;
    fn from_str(s: &str) -> Result<Self> {
        s.parse::<Register>()
            .map(Variable::Register)
            .or_else(|_| s.parse::<isize>().map(Variable::Value))
            .map_err(|_| format!("invalid variable '{}'", s).into())
    }
}

trait SplitWhitespaceExt {
    fn read_variable(&mut self) -> Result<Variable>;
    fn read_register(&mut self) -> Result<Register>;
    fn read_value(&mut self) -> Result<isize>;
}

impl<'a> SplitWhitespaceExt for str::SplitWhitespace<'a> {
    fn read_variable(&mut self) -> Result<Variable> {
        self.next()
            .ok_or("missing variable".into())
            .and_then(|v| v.parse::<Variable>())
    }

    fn read_register(&mut self) -> Result<Register> {
        self.next()
            .ok_or("missing register".into())
            .and_then(|v| v.parse::<Register>())
    }

    fn read_value(&mut self) -> Result<isize> {
        self.next()
            .ok_or("missing value".into())
            .and_then(|v| v.parse::<isize>().chain_err(|| ""))
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use super::{Instruction, Variable};
    use std::str::FromStr;

    #[test]
    fn test_assembunny() {
        let instructions: Instructions = "cpy 41 a
inc a
inc a
dec a
jnz a 2
dec a"
            .parse()
            .unwrap();
        let mut assembunny = Assembunny {
            registers: Registers::new(),
            instructions: instructions,
        };

        let registers = assembunny.next().unwrap();
        assert_eq!(registers[Register::A], 41);
        assert_eq!(registers[Register::B], 0);

        let registers = assembunny.next().unwrap();
        assert_eq!(registers[Register::A], 42);
        assert_eq!(registers[Register::C], 0);

        let registers = assembunny.last().unwrap();
        assert_eq!(registers[Register::A], 42);
        assert_eq!(registers[Register::PC], 6);
    }

    #[test]
    fn test_instructions_from_str() {
        let i: Instructions = "cpy 41 a
inc a
inc a
dec a
jnz a 2
dec a"
            .parse()
            .unwrap();
        assert_eq!(i.0.len(), 6);
        assert_eq!(i.0[0], Instruction::from_str("cpy 41 a").unwrap());
    }

    #[test]
    fn test_instruction_from_str() {
        assert!(Instruction::from_str("").is_err());
        assert!(Instruction::from_str("omg").is_err());
        assert!(Instruction::from_str("inc 5").is_err());

        assert_eq!(Instruction::from_str("cpy 41 a").unwrap(),
                   Instruction::Cpy(Variable::Value(41), Register::A));
        assert_eq!(Instruction::from_str("inc a").unwrap(),
                   Instruction::Inc(Register::A));
        assert_eq!(Instruction::from_str("dec b").unwrap(),
                   Instruction::Dec(Register::B));
        assert_eq!(Instruction::from_str("jnz c 2").unwrap(),
                   Instruction::Jnz(Variable::Register(Register::C), 2));
    }
}
