extern crate crypto;
extern crate regex;

macro_rules! pub_mod {
    ( $( $d:ident ),* ) => {
        $(
            pub mod $d;
        )*
    }
}

pub_mod! {
    day_01,
    day_02,
    day_03,
    day_04,
    day_05,
    day_06
}
