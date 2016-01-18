use std::collections::HashMap;
use std::ops::Index;

#[test]
fn test_solve() {
    let input = "123 -> x
456 -> y
x AND y -> d
x OR y -> e
x LSHIFT 2 -> f
y RSHIFT 2 -> g
NOT x -> h
NOT y -> i";

    assert_eq!(72, solve(input, "d"));
    assert_eq!(507, solve(input, "e"));
    assert_eq!(492, solve(input, "f"));
    assert_eq!(114, solve(input, "g"));
    assert_eq!(65412, solve(input, "h"));
    assert_eq!(65079, solve(input, "i"));
    assert_eq!(123, solve(input, "x"));
    assert_eq!(456, solve(input, "y"));
}

pub fn solve(input: &str, wire_id: &str) -> u16 {
    let mut circuit = Circuit::new(input);
    circuit.signal_on(wire_id)
}

#[test]
fn test_circuit() {
    let mut circuit = Circuit::new("123 -> x\nx -> y\nNOT x -> h\nx AND y -> i");

    assert_eq!(Signal::Value(123), circuit.connections[&Wire("x")]);
    assert_eq!(Signal::Wire(Wire("x")), circuit.connections[&Wire("y")]);
    assert_eq!(Signal::Gate(Gate::Not(Wire("x"))), circuit.connections[&Wire("h")]);

    assert_eq!(123, circuit.signal_on("x"));
    assert_eq!(123, circuit.signal_on("y"));
    assert_eq!(65412, circuit.signal_on("h"));
    assert_eq!(123, circuit.signal_on("i"));
}

struct Circuit<'a> {
    connections: HashMap<Wire<'a>, Signal<'a>>,
}

impl<'a> Circuit<'a> {
    fn new(input: &str) -> Circuit {
        let mut connections = HashMap::new();
        for line in input.lines()
                         .map(|line| line.split(" -> ").collect::<Vec<_>>()) {
            let wire = Wire(line.last().unwrap());
            let signal = Signal::new(line.first().unwrap().split(" ").collect());
            connections.insert(wire, signal);
        }

        Circuit { connections: connections }
    }

    // TODO This should probably return a Result...
    // TODO Is there a way for this to not be mutable?
    fn signal_on(&mut self, wire_id: &'a str) -> u16 {
        let value = match self.connections.get(&Wire(wire_id)).unwrap() {
            &Signal::Value(value) => value,
            &Signal::Wire(Wire(input_wire_id)) => self.signal_on(input_wire_id),
            &Signal::Gate(Gate::And(Wire(a), Wire(b))) => self.signal_on(a) & self.signal_on(b),
            &Signal::Gate(Gate::LeftShift(Wire(a), i)) => self.signal_on(a) << i,
            &Signal::Gate(Gate::Not(Wire(a))) => !self.signal_on(a),
            &Signal::Gate(Gate::Or(Wire(a), Wire(b))) => self.signal_on(a) | self.signal_on(b),
            &Signal::Gate(Gate::RightShift(Wire(a), i)) => self.signal_on(a) >> i,
        };
        value
    }
}

#[derive(Debug,Eq,Hash,PartialEq)]
struct Wire<'a>(&'a str);

#[derive(Debug,PartialEq)]
enum Signal<'a> {
    Gate(Gate<'a>),
    Wire(Wire<'a>),
    Value(u16),
}

impl<'a> Signal<'a> {
    fn new(input: Vec<&str>) -> Signal {
        match &input[..] {
            [a, "AND", b] => Signal::Gate(Gate::And(Wire(a), Wire(b))),
            ["NOT", a] => Signal::Gate(Gate::Not(Wire(a))),
            [a, "OR", b] => Signal::Gate(Gate::Or(Wire(a), Wire(b))),
            [a, "RSHIFT", b] => Signal::Gate(Gate::RightShift(Wire(a), b.parse::<u16>().unwrap())),
            [a, "LSHIFT", b] => Signal::Gate(Gate::LeftShift(Wire(a), b.parse::<u16>().unwrap())),
            [value] => {
                match value.parse::<u16>() {
                    Ok(value) => Signal::Value(value),
                    Err(_) => Signal::Wire(Wire(value)),
                }
            }
            _ => panic!("Unrecognized input: {:?}", input),
        }
    }
}

#[derive(Debug,PartialEq)]
enum Gate<'a> {
    And(Wire<'a>, Wire<'a>),
    LeftShift(Wire<'a>, u16),
    Not(Wire<'a>),
    Or(Wire<'a>, Wire<'a>),
    RightShift(Wire<'a>, u16),
}
