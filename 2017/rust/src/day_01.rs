use failure::*;

pub fn solve(input: &str) -> Result<String, Error> {
    let input: Vec<u32> = input
        .trim()
        .chars()
        .map(|x| x.to_digit(10).ok_or_else(|| format_err!("")))
        .collect::<Result<_, _>>()?;

    // 1
    let offset = 1;
    let offset_iter = input.iter().skip(offset).cycle().take(input.len());
    Ok(
        input
            .iter()
            .zip(offset_iter)
            .filter(|&a| a.0 == a.1)
            .map(|a| a.0)
            .sum::<u32>()
            .to_string(),
    )
}
