use std::collections::HashMap;
use std::io::{self, Read};

fn day_1_0(input: &str, delimiter: &str) -> String {
    let sum: i32 = input
        .split(delimiter)
        .flat_map(|change| change.parse::<i32>().ok())
        .sum();
    sum.to_string()
}

#[test]
fn test_day_1_0() {
    assert_eq!(day_1_0("+1, -2, +3, +1", ", "), "3");
}

fn day_1_1(input: &str, delimiter: &str) -> String {
    let mut seen = HashMap::new();
    seen.insert(0, 1);

    input
        .split(delimiter)
        .flat_map(|change| change.parse::<i32>().ok())
        .cycle()
        .scan((seen, 0), |(seen, freq), change| {
            *freq += change;

            let count = seen.entry(freq.clone()).or_insert(0);
            *count += 1;

            Some((freq.clone(), count.clone()))
        })
        .filter(|(_, count)| *count > 1)
        .map(|(freq, _)| freq)
        .next()
        .unwrap()
        .to_string()
}

#[test]
fn test_day_1_1() {
    assert_eq!(day_1_1("+1, -2, +3, +1", ", "), "2");
    assert_eq!(day_1_1("+1, -1", ", "), "0");
    assert_eq!(day_1_1("+3, +3, +4, -2, -4", ", "), "10");
    assert_eq!(day_1_1("-6, +3, +8, +5, -6", ", "), "5");
    assert_eq!(day_1_1("+7, +7, -2, -7, -4", ", "), "14");
}

fn main() {
    let mut input = String::new();
    io::stdin().read_to_string(&mut input).unwrap();

    let output = day_1_1(&input, "\n");
    println!("{}", output);
}
