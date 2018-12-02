use std::io::{self, Read};

fn day_1(input: &str, delimiter: &str) -> String {
    let sum: i32 = input
        .split(delimiter)
        .flat_map(|change| change.parse::<i32>().ok())
        .sum();
    sum.to_string()
}

#[test]
fn test_day_1() {
    assert_eq!(day_1("+1, -2, +3, +1", ", "), "3");
}

fn main() {
    let mut input = String::new();
    io::stdin().read_to_string(&mut input).unwrap();

    let output = day_1(&input, "\n");
    println!("{}", output);
}
