use assembunny::*;
use errors::*;

pub fn solve(input: &str) -> Result<String> {
    let instructions: Instructions = input.parse()?;
    let mut registers = Registers::new();
    registers[Register::C] = 1;
    let assembunny = Assembunny{registers: registers, instructions: instructions};

    let registers = assembunny.last().ok_or("")?;
    let a = registers[Register::A];
    Ok(a.to_string())
}
