extern crate crypto;
extern crate regex;

macro_rules! import_day {
    ( $( $d:ident ),* ) => {
        $(
            pub use $d::*;
            mod $d;
        )*
    }
}

import_day! {
    day,
    day_01,
    day_02,
    day_03,
    day_04,
    day_05,
    day_06
}
