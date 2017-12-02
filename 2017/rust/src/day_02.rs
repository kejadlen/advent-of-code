use failure::*;

pub fn solve(input: &str) -> Result<String, Error> {
    Ok(
        input
            .trim()
            .split('\n')
            .map(|row| {
                row.split('\t')
                    .map(|x| x.parse::<usize>().unwrap())
                    .collect::<Vec<_>>()
            })
            .map(|row| checksum(&row))
            .sum::<usize>()
            .to_string(),
    )
}

fn checksum(row: &[usize]) -> usize {
    let min = row.iter().min().unwrap();
    let max = row.iter().max().unwrap();
    max - min
}
