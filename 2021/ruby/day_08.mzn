include "globals.mzn";

enum Signals = { A, B, C, D, E, F, G };

set of Signals: Zero = { A, B, C, E, F, G };
set of Signals: One = { C, F };
set of Signals: Two = { A, C, D, E, G };
set of Signals: Three = { A, C, D, F, G };
set of Signals: Four = { B, C, D, F };
set of Signals: Five = { A, B, D, F, G };
set of Signals: Six = { A, B, D, E, F, G };
set of Signals: Seven = { A, C, F };
set of Signals: Eight = { A, B, C, D, E, F, G };
set of Signals: Nine = { A, B, C, D, F, G };
array[1..10] of set of Signals: AllSignals = [ Zero, One, Two, Three, Four, Five, Six, Seven, Eight, Nine ];

array[int] of set of Signals: Patterns;
% Patterns = [
%   { A, C, E, D, G, F, B },
%   { C, D, F, B, E },
%   { G, C, D, F, A },
%   { F, B, C, A, D },
%   { D, A, B },
%   { C, E, F, A, B, D },
%   { C, D, F, G, E, B },
%   { E, A, F, B },
%   { C, A, G, E, D, B },
%   { A, B },
% ];

array [Signals] of var Signals: Map;

constraint alldifferent(Map);
constraint forall(pattern in Patterns)(
  exists(digit in AllSignals)(
    { Map[x] | x in pattern } = digit
  )
);

output [show(Map)];