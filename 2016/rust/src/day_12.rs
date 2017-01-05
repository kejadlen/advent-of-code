use assembunny::*;
use errors::*;

pub fn solve(input: &str) -> Result<String> {
    let instructions: Instructions = input.parse()?;
    let registers = vec![(Register::C, 1)].into_iter().collect();
    let assembunny = Assembunny{registers: registers, instructions: instructions};

    let registers = assembunny.last().ok_or("")?;
    let a = registers.get(&Register::A).ok_or("")?;
    Ok(a.to_string())
}
