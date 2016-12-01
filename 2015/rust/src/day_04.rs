use crypto::md5::Md5;
use crypto::digest::Digest;

pub fn solve(input: &str) -> i32 {
    let mut md5 = Md5::new();
    let key = input.as_bytes();
    let mut i = 0;
    let mut out = [0; 16];
    loop {
        i += 1;

        md5.input(key);
        md5.input(i.to_string().as_bytes());
        md5.result(&mut out);
        if out[0] == 0 && out[1] == 0 && out[2] == 0 {
            break;
        }
        md5.reset();
    }
    i
}

#[test]
#[ignore]
fn test_day04() {
    assert_eq!(609043, solve("abcdef"));
}
