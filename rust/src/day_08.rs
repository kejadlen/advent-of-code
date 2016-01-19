#[test]
fn test_day_08() {
    let mut input = r#""""#;
    assert_eq!("", decode(input));
    assert_eq!(2, solve(input));

    input = r#""abc""#;
    assert_eq!("abc", decode(input));
    assert_eq!(2, solve(input));

    input = r#""aaa\"aaa""#;
    assert_eq!("aaa\"aaa", decode(input));
    assert_eq!(3, solve(input));

    input = r#""\x27""#;
    assert_eq!("'", decode(input));
    assert_eq!(5, solve(input));

    input = r#""\xfa""#;
    assert_eq!(1, decode(input).chars().count());
    assert_eq!(5, solve(input));
}

pub fn solve(input: &str) -> usize {
    input.lines().fold(0, |sum, s| sum + s.len() - decode(s).chars().count())
}

fn decode(string: &str) -> String {
    let mut out = "".to_owned();
    let mut it = string[1..string.len()-1].chars();
    loop {
        let c = match it.next() {
            Some('\\') => {
                match it.next() {
                    Some('\\') => '\\',
                    Some('"') => '"',
                    Some('x') => {
                        let mut b = it.next().and_then(|c| c.to_digit(16)).unwrap() << 4;
                        b += it.next().and_then(|c| c.to_digit(16)).unwrap();
                        b as u8 as char
                    },
                    Some(c) => panic!("Unexpected escaped char: {}", c),
                    None => panic!("Unexpected end of string"),
                }
            }
            Some(c) => c,
            None => break,
        };
        out.push(c);
    }
    out
}
