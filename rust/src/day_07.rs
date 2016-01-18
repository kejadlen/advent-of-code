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
    assert_eq!(Some(&Signal::Value(123)), circuit.connections.get(&Wire("x".to_string())));
}

struct Circuit {
    connections: HashMap<Wire, Signal>,
}

impl Circuit {
    fn new(input: &str) -> Circuit{
        let mut connections = HashMap::new();
        for line in input.lines()
                         .map(|line| line.split(" -> ")
                                         .collect::<Vec<_>>()) {
            let wire = Wire(line.last().unwrap().to_string());
            let signal = Signal::new(line.first().unwrap().split(" ").collect());
            connections.insert(wire, signal);
        }

        Circuit { connections: connections }
    }
}

#[derive(Debug,Eq,Hash,PartialEq)]
struct Wire(String);

#[derive(Debug,PartialEq)]
enum Signal {
    Gate(Gate),
    Wire(Wire),
    Value(u16),
}

impl Signal {
    fn new(input: Vec<&str>) -> Signal {
        match &input[..] {
            [a, "AND", b] => Signal::Gate(Gate::And(Wire(a.to_string()), Wire(b.to_string()))),
            ["NOT", a] => Signal::Gate(Gate::Not(Wire(a.to_string()))),
            [a, "OR", b] => Signal::Gate(Gate::Or(Wire(a.to_string()), Wire(b.to_string()))),
            [a, "RSHIFT", b] => Signal::Gate(Gate::RightShift(Wire(a.to_string()), b.parse::<u16>().unwrap())),
            [a, "LSHIFT", b] => Signal::Gate(Gate::LeftShift(Wire(a.to_string()), b.parse::<u16>().unwrap())),
            [value] => {
                match value.parse::<u16>() {
                    Ok(value) => Signal::Value(value),
                    Err(_) => Signal::Wire(Wire(value.to_string())),
                }
            }
            _ => panic!("Unrecognized input: {:?}", input),
        }
    }
}

#[derive(Debug,PartialEq)]
enum Gate {
    And(Wire, Wire),
    LeftShift(Wire, u16),
    Not(Wire),
    Or(Wire, Wire),
    RightShift(Wire, u16),
}
