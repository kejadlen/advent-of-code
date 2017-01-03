use std::str;

use errors::*;

pub fn solve(_: &str) -> Result<String> {
    Ok("".into())
}

struct Decompress<'a> {
    chars: str::Chars<'a>,
}

impl<'a> Decompress<'a> {
    fn new(input: &'a str) -> Self {
        Decompress{chars: input.chars()}
    }
}

impl<'a> Iterator for Decompress<'a> {
    type Item = char;

    fn next(&mut self) -> Option<char> {
        self.chars.next()
    }
}

#[cfg(test)]
mod tests {
    use super::Decompress;

    #[test]
    fn test_no_markers() {
        let mut decompress = Decompress::new("ADVENT");
        let output: String = decompress.collect();
        assert_eq!(output, "ADVENT");
    }
}
