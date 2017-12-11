use failure::*;

#[allow(dead_code)]
pub fn solve(input: &str) -> Result<String, Error> {
    let input: Vec<u32> = input
        .trim()
        .chars()
        .map(|x| x.to_digit(10).ok_or_else(|| err_msg("")))
        .collect::<Result<_, _>>()?;

    // 1
    // let offset = 1;
    let offset = input.len() / 2;

    let offset_iter = input.iter().cycle().skip(offset);
    Ok(input
        .iter()
        .zip(offset_iter)
        .filter(|&a| a.0 == a.1)
        .map(|a| a.0)
        .sum::<u32>()
        .to_string())
}

#[test]
fn part_two() {
    assert_eq!(solve("1212").unwrap(), "6".to_string());
    assert_eq!(solve("1221").unwrap(), "0".to_string());
    assert_eq!(solve("123425").unwrap(), "4".to_string());
    assert_eq!(solve("123123").unwrap(), "12".to_string());
    assert_eq!(solve("12131415").unwrap(), "4".to_string());
}
