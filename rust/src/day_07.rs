use std::collections::HashMap;
use std::ops::Index;

#[test]
#[ignore]
fn test_solve() {
    let input = "123 -> x
456 -> y
x AND y -> d
x OR y -> e
x LSHIFT 2 -> f
y RSHIFT 2 -> g
NOT x -> h
NOT y -> i";

    assert_eq!(123, solve(input, "x"));
}

pub fn solve(input: &str, wire: &str) -> u16 {
    let circuit = Circuit::new(input);
    0
}

#[test]
fn test_circuit() {
    let circuit = Circuit::new("123 -> x");
    assert_eq!(Some(&Signal::Value(123)), circuit.connections.get(&Wire("x")));
}

struct Circuit<'a> {
    connections: HashMap<Wire<'a>, Signal<'a>>,
}

impl<'a> Circuit<'a> {
    fn new(input: &str) -> Circuit {
        let mut connections = HashMap::new();
        for line in input.lines()
                         .map(|line| line.split(" -> ")
                                         .collect::<Vec<_>>()) {
            let wire = Wire(line.last().unwrap());
            let signal = Signal::new(line.first().unwrap().split(" ").collect());
            connections.insert(wire, signal);
        }

        Circuit { connections: connections }
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
