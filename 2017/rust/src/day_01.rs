use failure::*;

pub fn solve(input: &str) -> Result<String, Error> {
    let mut input: Vec<u32> = input
        .trim()
        .chars()
        .map(|x| x.to_digit(10).ok_or_else(|| format_err!("")))
        .collect::<Result<_, _>>()?;

    // 1
    let last = input[input.len() - 1];
    input.push(last);
    Ok(
        input
            .windows(2)
            .filter(|&a| a[0] == a[1])
            .map(|a| a[0])
            .sum::<u32>()
            .to_string(),
    )
}
