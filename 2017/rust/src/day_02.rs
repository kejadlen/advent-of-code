use failure::*;

pub fn solve(input: &str) -> Result<String, Error> {
    Ok(
        input
            .trim()
            .split("\n")
            .map(|row| {
                let row: Vec<_> = row.split("\t")
                    .map(|x| x.parse::<usize>().unwrap())
                    .collect();
                let min = row.iter().min().unwrap();
                let max = row.iter().max().unwrap();
                max - min
            })
            .sum::<usize>()
            .to_string(),
    )
}
