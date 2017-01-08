use std::fmt;
use std::ops;
use std::str;

use errors::*;

pub struct Assembunny {
    pub registers: Registers,
    pub instructions: Instructions,
}

impl Assembunny {
    fn instruction(&self, i: usize) -> Option<Instruction> {
        self.instructions.get(i).cloned()
    }

    fn value<V: Into<Variable>>(&self, v: V) -> isize {
        let v: Variable = v.into();
        match v {
            Variable::Register(r) => self.registers[r],
            Variable::Value(i) => i,
        }
    }

    fn toggle(&mut self, i: usize) {
        let instruction = match self.instruction(i) {
            Some(x) => x,
            None => return,
        };

        let replacement = match instruction {
            Instruction::Cpy(a, b) => Instruction::Jnz(a, b),
            Instruction::Inc(x) => Instruction::Dec(x),
            Instruction::Dec(x) |
            Instruction::Tgl(x) => Instruction::Inc(x),
            Instruction::Jnz(a, b) => Instruction::Cpy(a, b),
        };
        self.instructions[i] = replacement;
    }
}

impl Iterator for Assembunny {
    type Item = Registers;

    fn next(&mut self) -> Option<Registers> {
        let pc = self.value(Register::PC) as usize;
        let instruction = match self.instruction(pc) {
            Some(i) => i,
            None => {
                return None;
            }
        };

        self.registers[Register::PC] += 1;
        match instruction {
            Instruction::Cpy(v, Variable::Register(r)) => {
                self.registers[r] = self.value(v);
            }
            Instruction::Inc(Variable::Register(r)) => {
                self.registers[r] += 1;
            }
            Instruction::Dec(Variable::Register(r)) => {
                self.registers[r] -= 1;
            }
            Instruction::Jnz(v, delta) if self.value(v) != 0 => {
                self.registers[Register::PC] -= 1;
                self.registers[Register::PC] += self.value(delta);
            }
            Instruction::Tgl(v) => {
                let index = (pc as isize) + self.value(v);
                self.toggle(index as usize);
            }
            _ => {}
        }

        Some(self.registers.clone())
    }
}

#[derive(Clone, Debug)]
pub struct Registers([isize; 5]);

impl Registers {
    pub fn new() -> Self {
        Registers([0; 5])
    }
}

impl ops::Index<Register> for Registers {
    type Output = isize;

    fn index(&self, _index: Register) -> &isize {
        self.0.index(usize::from(_index))
    }
}
impl ops::IndexMut<Register> for Registers {
    fn index_mut(&mut self, _index: Register) -> &mut isize {
        self.0.index_mut(usize::from(_index))
    }
}

pub struct Instructions(Vec<Instruction>);

impl Instructions {
    fn get(&self, i: usize) -> Option<&Instruction> {
        self.0.get(i)
    }
}

impl ops::Index<usize> for Instructions {
    type Output = Instruction;

    fn index(&self, _index: usize) -> &Instruction {
        self.0.index(_index)
    }
}

impl ops::IndexMut<usize> for Instructions {
    fn index_mut(&mut self, _index: usize) -> &mut Instruction {
        self.0.index_mut(_index)
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

impl From<Register> for usize {
    fn from(r: Register) -> usize {
        match r {
            Register::PC => 0,
            Register::A => 1,
            Register::B => 2,
            Register::C => 3,
            Register::D => 4,
        }
    }
}

#[derive(Clone, Copy, Debug, PartialEq)]
pub enum Instruction {
    Cpy(Variable, Variable),
    Inc(Variable),
    Dec(Variable),
    Jnz(Variable, Variable),
    Tgl(Variable),
}

#[derive(Clone, Copy, Debug, PartialEq)]
pub enum Variable {
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

// Display

impl fmt::Display for Instructions {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f,
               "{}",
               self.0
                   .iter()
                   .map(Instruction::to_string)
                   .collect::<Vec<_>>()
                   .join("\n"))
    }
}

impl fmt::Display for Instruction {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match *self {
            Instruction::Cpy(a, b) => write!(f, "cpy {} {}", a, b),
            Instruction::Inc(a) => write!(f, "inc {}", a),
            Instruction::Dec(a) => write!(f, "dec {}", a),
            Instruction::Jnz(a, b) => write!(f, "jnz {} {}", a, b),
            Instruction::Tgl(a) => write!(f, "tgl {}", a),
        }
    }
}

impl fmt::Display for Variable {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match *self {
            Variable::Register(r) => {
                write!(f, "{}", format!("{:?}", r).to_lowercase())
            }
            Variable::Value(v) => write!(f, "{:?}", v),
        }
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
                let r = tokens.read_variable()?;
                Ok(Instruction::Cpy(v, r))
            }
            Some("inc") => {
                let r = tokens.read_register()?;
                Ok(Instruction::Inc(Variable::Register(r)))
            }
            Some("dec") => {
                let r = tokens.read_register()?;
                Ok(Instruction::Dec(Variable::Register(r)))
            }
            Some("jnz") => {
                let var = tokens.read_variable()?;
                let val = tokens.read_variable()?;
                Ok(Instruction::Jnz(var, val))
            }
            Some("tgl") => {
                let var = tokens.read_variable()?;
                Ok(Instruction::Tgl(var))
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
    fn test_toggle_integration() {
        let instructions: Instructions = "cpy 2 a
tgl a
tgl a
tgl a
cpy 1 a
dec a
dec a"
            .parse()
            .unwrap();

        let assembunny = Assembunny {
            registers: Registers::new(),
            instructions: instructions,
        };

        let registers = assembunny.last().unwrap();
        assert_eq!(registers[Register::A], 3);
        assert_eq!(registers[Register::PC], 7);
    }

    #[test]
    fn test_toggle() {
        let instructions: Instructions = "tgl a"
            .parse()
            .unwrap();

        let mut assembunny = Assembunny {
            registers: Registers::new(),
            instructions: instructions,
        };

        assembunny.toggle(0);
        assert_eq!(assembunny.instruction(0),
                   Some(Instruction::Inc(Variable::Register(Register::A))));

        assembunny.toggle(0);
        assert_eq!(assembunny.instruction(0),
                   Some(Instruction::Dec(Variable::Register(Register::A))));

        assembunny.toggle(0);
        assert_eq!(assembunny.instruction(0),
                   Some(Instruction::Inc(Variable::Register(Register::A))));
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
                   Instruction::Cpy(Variable::Value(41),
                                    Variable::Register(Register::A)));
        assert_eq!(Instruction::from_str("inc a").unwrap(),
                   Instruction::Inc(Variable::Register(Register::A)));
        assert_eq!(Instruction::from_str("dec b").unwrap(),
                   Instruction::Dec(Variable::Register(Register::B)));
        assert_eq!(Instruction::from_str("jnz c 2").unwrap(),
                   Instruction::Jnz(Variable::Register(Register::C),
                                    Variable::Value(2)));
        assert_eq!(Instruction::from_str("tgl a").unwrap(),
                   Instruction::Tgl(Variable::Register(Register::A)));
    }
}
