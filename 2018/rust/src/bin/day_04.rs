use std::error::Error;
use std::io::{self, Read};
use std::ops::Range;

use pest::iterators::Pair;
use pest::Parser;
use pest_derive::Parser;

fn main() -> Result<(), Box<Error>> {
    let mut input = String::new();
    io::stdin().read_to_string(&mut input)?;

    let output = solve(&input)?;
    println!("{}", output);

    Ok(())
}

fn solve(input: &str) -> Result<String, Box<Error>> {
    Ok("".into())
}

#[derive(Debug)]
struct Record {
    guard_id: String,
    sleep_ranges: Vec<Range<usize>>,
}

impl Record {
    fn parse(s: &str) -> Result<Vec<Record>, Box<Error>> {
        let mut records: Vec<_> = s.lines().collect();
        records.sort();
        let input = records.join("\n");

        let mut parsed = RecordsParser::parse(Rule::records, &input)?;
        let records: Vec<Record> = parsed
            .next()
            .unwrap()
            .into_inner()
            .flat_map(|record| match record.as_rule() {
                Rule::record => Some(record.into()),
                Rule::EOI => None,
                _ => unreachable!(),
            })
            .collect();

        Ok(records)
    }

    fn parse_sleep_range(pair: Pair<Rule>) -> Range<usize> {
        let mut sleep_range = pair.into_inner();
        let falls_asleep: usize = Self::parse_minute(sleep_range.next().unwrap());
        let wakes_up: usize = Self::parse_minute(sleep_range.next().unwrap());
        (falls_asleep..wakes_up)
    }

    fn parse_minute(pair: Pair<Rule>) -> usize {
        pair.into_inner().next().unwrap().as_str().parse().unwrap()
    }
}

#[test]
fn test_parsing() {
    let input = r"
[1518-11-01 00:00] Guard #10 begins shift
[1518-11-01 00:05] falls asleep
[1518-11-01 00:25] wakes up
[1518-11-01 00:30] falls asleep
[1518-11-01 00:55] wakes up
[1518-11-01 23:58] Guard #99 begins shift
[1518-11-02 00:40] falls asleep
[1518-11-02 00:50] wakes up
[1518-11-03 00:05] Guard #10 begins shift
[1518-11-03 00:24] falls asleep
[1518-11-03 00:29] wakes up
[1518-11-04 00:02] Guard #99 begins shift
[1518-11-04 00:36] falls asleep
[1518-11-04 00:46] wakes up
[1518-11-05 00:03] Guard #99 begins shift
[1518-11-05 00:45] falls asleep
[1518-11-05 00:55] wakes up
    "
    .trim();

    let records = Record::parse(input).unwrap();
    assert_eq!(records.len(), 5);
    let record = &records[0];
    assert_eq!(record.guard_id, "10");
    assert_eq!(record.sleep_ranges, vec![(5..25), (30..55)]);
}

impl<'a> From<Pair<'a, Rule>> for Record {
    fn from(pair: Pair<Rule>) -> Self {
        let mut record = pair.into_inner();
        let guard_id = record
            .next()
            .unwrap()
            .into_inner()
            .nth(1) // skip the minute
            .unwrap()
            .as_str()
            .into();
        let sleep_ranges: Vec<_> = record
            .next()
            .unwrap()
            .into_inner()
            .map(Self::parse_sleep_range)
            .collect();

        Record {
            guard_id,
            sleep_ranges,
        }
    }
}

#[derive(Parser)]
#[grammar = "day_04.pest"]
#[allow(dead_code)]
struct RecordsParser;
