#[macro_export]
macro_rules! main {
    () => {
        fn main() -> Result<(), Box<std::error::Error>> {
            use std::io::{self, Read};

            let mut input = String::new();
            io::stdin().read_to_string(&mut input)?;

            let output = solve(&input)?;
            println!("{}", output);

            Ok(())
        }
    };
}
