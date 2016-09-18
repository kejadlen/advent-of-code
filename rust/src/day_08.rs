#[test]
fn test_day_08() {
  assert_eq!(4, solve(r#""""#));
  assert_eq!(4, solve(r#""abc""#));
  assert_eq!(6, solve(r#""aaa\"aaa""#));
  assert_eq!(5, solve(r#""\x27""#));
  assert_eq!(5, solve(r#""\xfa""#));
}

pub fn solve(input: &str) -> usize {
  input.lines().fold(0, |sum, s| sum + encode(s).chars().count() - s.len())
}

#[test]
fn test_decode() {
  assert_eq!("", decode(r#""""#));
  assert_eq!("abc", decode(r#""abc""#));
  assert_eq!("aaa\"aaa", decode(r#""aaa\"aaa""#));
  assert_eq!("'", decode(r#""\x27""#));
  assert_eq!(1, decode(r#""\xfa""#).chars().count());
}

#[allow(dead_code)]
fn decode(string: &str) -> String {
  let mut out = "".to_owned();

  let mut chars = string.chars().map(Some).collect::<Vec<_>>();
  chars.append(&mut vec![None, None, None]);
  let mut it = chars.windows(4);
  loop {
    match it.next() {
      Some(&[Some('"'), None, None, None]) => break,
      Some(&[Some('"'), _, _, _]) => {}
      Some(&[Some('\\'), Some('\\'), _, _]) => {
        it.next();
        out.push('\\');
      }
      Some(&[Some('\\'), Some('"'), _, _]) => {
        it.next();
        out.push('"');
      }
      Some(&[Some('\\'), Some('x'), Some(a), Some(b)]) => {
        it.next();
        it.next();
        it.next();
        let c = (a.to_digit(16).unwrap_or(0) << 4) +
                (b.to_digit(16).unwrap_or(0));
        out.push(c as u8 as char);
      }
      Some(&[Some(c), _, _, _]) => {
        out.push(c);
      }
      Some(x) => panic!("{:?}", x),
      None => panic!(""),
    };
  }
  out
}

#[test]
fn test_encode() {
  assert_eq!(r#""\"\"""#, encode(r#""""#));
  assert_eq!(r#""\"abc\"""#, encode(r#""abc""#));
  assert_eq!(r#""\"aaa\\\"aaa\"""#, encode(r#""aaa\"aaa""#));
  assert_eq!(r#""\"\\x27\"""#, encode(r#""\x27""#));
  assert_eq!(r#""\"\\xfa\"""#, encode(r#""\xfa""#));
}

fn encode(string: &str) -> String {
  format!(r#""{}""#,
          string.replace(r#"\"#, r#"\\"#).replace(r#"""#, r#"\""#))
}
