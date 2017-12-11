use failure::*;

#[allow(dead_code)]
pub fn solve(input: &str) -> Result<String, Error> {
    Ok(input
        .trim()
        .split('\n')
        .map(|row| {
            row.split('\t')
                .map(|x| x.parse::<usize>().unwrap())
                .collect::<Vec<_>>()
        })
        .map(|row| checksum(&row))
        .sum::<usize>()
        .to_string())
}

fn checksum(row: &[usize]) -> usize {
    // 1
    // let min = row.iter().min().unwrap();
    // let max = row.iter().max().unwrap();
    // max - min

    row.iter()
        .flat_map(|x| row.iter().map(|y| (x, y)).collect::<Vec<_>>())
        .filter(|&(a, b)| a != b)
        .filter(|&(&a, &b)| (a as f64) % (b as f64) == 0.0)
        .map(|(&a, &b)| a / b)
        .next()
        .unwrap()
}
