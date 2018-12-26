use std::error::Error;
use std::str::FromStr;

use regex::Regex;

use advent_of_code::main;

main!();

fn solve(input: &str) -> Result<String, Box<Error>> {
    let mut program: Program = input.parse()?;
    program.registers[0] = 1;
    let registers = program.last().unwrap();
    let output = registers[0].to_string();
    Ok(output)
}

type Registers = [usize; 6];

struct Program {
    ip: usize,
    instructions: Vec<Instruction>,
    registers: Registers,
}

impl Program {
    fn execute(&mut self, i: &Instruction) {
        match i.opcode {
            Opcode::Addr => self.registers[i.c] = self.registers[i.a] + self.registers[i.b],
            Opcode::Addi => self.registers[i.c] = self.registers[i.a] + i.b,
            Opcode::Mulr => self.registers[i.c] = self.registers[i.a] * self.registers[i.b],
            Opcode::Muli => self.registers[i.c] = self.registers[i.a] * i.b,
            Opcode::Banr => self.registers[i.c] = self.registers[i.a] & self.registers[i.b],
            Opcode::Bani => self.registers[i.c] = self.registers[i.a] & i.b,
            Opcode::Borr => self.registers[i.c] = self.registers[i.a] | self.registers[i.b],
            Opcode::Bori => self.registers[i.c] = self.registers[i.a] | i.b,
            Opcode::Setr => self.registers[i.c] = self.registers[i.a],
            Opcode::Seti => self.registers[i.c] = i.a,
            Opcode::Gtir => self.registers[i.c] = if i.a > self.registers[i.b] { 1 } else { 0 },
            Opcode::Gtri => self.registers[i.c] = if self.registers[i.a] > i.b { 1 } else { 0 },
            Opcode::Gtrr => {
                self.registers[i.c] = if self.registers[i.a] > self.registers[i.b] {
                    1
                } else {
                    0
                }
            }
            Opcode::Eqir => self.registers[i.c] = if i.a == self.registers[i.b] { 1 } else { 0 },
            Opcode::Eqri => self.registers[i.c] = if self.registers[i.a] == i.b { 1 } else { 0 },
            Opcode::Eqrr => {
                self.registers[i.c] = if self.registers[i.a] == self.registers[i.b] {
                    1
                } else {
                    0
                }
            }
        }
    }
}

impl Iterator for Program {
    type Item = Registers;

    fn next(&mut self) -> Option<Self::Item> {
        let ins = *self.instructions.get(self.registers[self.ip])?;
        self.execute(&ins);
        self.registers[self.ip] += 1;
        Some(self.registers)
    }
}

#[test]
fn test_program() {
    let mut program: Program = r"
#ip 0
seti 5 0 1
seti 6 0 2
addi 0 1 0
addr 1 2 3
setr 1 0 0
seti 8 0 4
seti 9 0 5
    "
    .parse()
    .unwrap();

    assert_eq!(program.next().unwrap(), [1, 5, 0, 0, 0, 0]);
}

#[derive(Clone, Copy)]
struct Instruction {
    opcode: Opcode,
    a: usize,
    b: usize,
    c: usize,
}

#[derive(Clone, Copy)]
enum Opcode {
    Addr,
    Addi,
    Mulr,
    Muli,
    Banr,
    Bani,
    Borr,
    Bori,
    Setr,
    Seti,
    Gtir,
    Gtri,
    Gtrr,
    Eqir,
    Eqri,
    Eqrr,
}

impl FromStr for Program {
    type Err = Box<Error>;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let mut lines = s.trim().lines();
        let ip_re = Regex::new(r"^#ip (\d+)$").unwrap();
        let ip = lines
            .next()
            .and_then(|l| ip_re.captures(l))
            .and_then(|c| c.get(1))
            .unwrap()
            .as_str()
            .parse()?;

        let instructions = lines.map(|l| l.parse()).collect::<Result<_, _>>()?;

        let registers = [0; 6];

        Ok(Program {
            ip,
            instructions,
            registers,
        })
    }
}

impl FromStr for Instruction {
    type Err = Box<Error>;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let mut s = s.split_whitespace();
        let opcode = s.next().unwrap().parse()?;
        let a = s.next().unwrap().parse()?;
        let b = s.next().unwrap().parse()?;
        let c = s.next().unwrap().parse()?;
        Ok(Instruction { opcode, a, b, c })
    }
}

impl FromStr for Opcode {
    type Err = Box<Error>;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let opcode = match s {
            "addr" => Opcode::Addr,
            "addi" => Opcode::Addi,
            "mulr" => Opcode::Mulr,
            "muli" => Opcode::Muli,
            "banr" => Opcode::Banr,
            "bani" => Opcode::Bani,
            "borr" => Opcode::Borr,
            "bori" => Opcode::Bori,
            "setr" => Opcode::Setr,
            "seti" => Opcode::Seti,
            "gtir" => Opcode::Gtir,
            "gtri" => Opcode::Gtri,
            "gtrr" => Opcode::Gtrr,
            "eqir" => Opcode::Eqir,
            "eqri" => Opcode::Eqri,
            "eqrr" => Opcode::Eqrr,
            _ => unreachable!(),
        };
        Ok(opcode)
    }
}

// OPCODES = {
//   addr: ->(a, b, c) { ->(registers) { registers[c] = registers[a] + registers[b] } },
//   addi: ->(a, b, c) { ->(registers) { registers[c] = registers[a] + b } },
//   mulr: ->(a, b, c) { ->(registers) { registers[c] = registers[a] * registers[b] } },
//   muli: ->(a, b, c) { ->(registers) { registers[c] = registers[a] * b } },
//   banr: ->(a, b, c) { ->(registers) { registers[c] = registers[a] & registers[b] } },
//   bani: ->(a, b, c) { ->(registers) { registers[c] = registers[a] & b } },
//   borr: ->(a, b, c) { ->(registers) { registers[c] = registers[a] | registers[b] } },
//   bori: ->(a, b, c) { ->(registers) { registers[c] = registers[a] | b } },
//   setr: ->(a, b, c) { ->(registers) { registers[c] = registers[a] } },
//   seti: ->(a, b, c) { ->(registers) { registers[c] = a } },
//   gtir: ->(a, b, c) { ->(registers) { registers[c] = (a > registers[b]) ? 1 : 0 } },
//   gtri: ->(a, b, c) { ->(registers) { registers[c] = (registers[a] > b) ? 1 : 0 } },
//   gtrr: ->(a, b, c) { ->(registers) { registers[c] = (registers[a] > registers[b]) ? 1 : 0 } },
//   eqir: ->(a, b, c) { ->(registers) { registers[c] = (a == registers[b]) ? 1 : 0 } },
//   eqri: ->(a, b, c) { ->(registers) { registers[c] = (registers[a] == b) ? 1 : 0 } },
//   eqrr: ->(a, b, c) { ->(registers) { registers[c] = (registers[a] == registers[b]) ? 1 : 0 } },
// }
