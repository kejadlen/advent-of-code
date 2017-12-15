use std::collections::HashMap;
use std::collections::hash_map::Entry;
use failure::*;

#[allow(dead_code)]
pub fn solve(input: &str) -> Result<String, Error> {
    let mut jumps: HashMap<isize, isize> = input
        .trim()
        .lines()
        .enumerate()
        .map(|(i, x)| x.parse().map(|x| (i as isize, x)))
        .collect::<Result<_, _>>()?;
    let mut pc = 0;
    let mut steps = 0;
    while let Entry::Occupied(mut entry) = jumps.entry(pc) {
        let offset = entry.get_mut();
        pc += *offset;
        if *offset >= 3 {
            *offset -= 1;
        } else {
            *offset += 1;
        }
        steps += 1;
    }
    Ok(steps.to_string())
}
