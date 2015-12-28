macro_rules! import_day {
    ( $( $d:ident ),* ) => {
        $(
            pub use $d::*;
            mod $d;
        )*
    }
}

import_day!(day,
            day_01,
            day_02);
