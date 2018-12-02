use std::collections::HashMap;

pub fn solve_0(input: &str, delimiter: &str) -> String {
    let sum: i32 = input
        .trim()
        .split(delimiter)
        .map(|change| change.parse::<i32>().unwrap())
        .sum();
    sum.to_string()
}

#[test]
fn test_solve_0() {
    assert_eq!(solve_0("+1, -2, +3, +1", ", "), "3");
}

pub fn solve_1(input: &str, delimiter: &str) -> String {
    vec![0 as i32] // Start with 0 frequency
        .into_iter()
        .chain(
            input
                .trim()
                .split(delimiter)
                .map(|change| change.parse::<i32>().unwrap())
                .cycle(),
        )
        .scan(0, |freq, change| {
            *freq += change;
            Some(*freq)
        })
        .scan(HashMap::new(), |history, freq| {
            let count = history.entry(freq).or_insert(0);
            *count += 1;

            Some((freq, *count))
        })
        .filter(|(_, count)| *count > 1)
        .map(|(freq, _)| freq)
        .next()
        .unwrap()
        .to_string()
}

#[test]
fn test_solve_1() {
    assert_eq!(solve_1("+1, -2, +3, +1", ", "), "2");
    assert_eq!(solve_1("+1, -1", ", "), "0");
    assert_eq!(solve_1("+3, +3, +4, -2, -4", ", "), "10");
    assert_eq!(solve_1("-6, +3, +8, +5, -6", ", "), "5");
    assert_eq!(solve_1("+7, +7, -2, -7, -4", ", "), "14");
}
