use std::io;

use crypto::md5::Md5;
use crypto::digest::Digest;

use day::Day;

pub struct Day04 {
    secret: String,
}

impl Day for Day04 {
    fn new(input: String) -> Day04 {
        Day04 { secret: input }
    }

    fn solve(&self) -> io::Result<i32> {
        let mut md5 = Md5::new();
        let key = self.secret.as_bytes();
        let mut i = 0;
        let mut out = [0; 16];
        loop {
            i += 1;

            md5.input(key);
            md5.input(i.to_string().as_bytes());
            md5.result(&mut out);
            if out[0] == 0 && out[1] == 0 && out[2] >> 4 == 0 {
                break;
            }
            md5.reset();
        }
        Ok(i)
    }
}

#[test]
#[ignore]
fn test_day04() {
    let day = Day04::new("abcdef".to_string());
    assert_eq!(609043, day.solve().unwrap());
}
