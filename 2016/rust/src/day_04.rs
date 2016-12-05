use std::char;
use std::cmp::Ordering;
use std::collections::HashMap;

use errors::*;
use regex::Regex;

pub fn solve(input: &str) -> Result<String> {
  let rooms: Vec<(Room, String)> = input.lines()
    .map(|line| {
      let re = Regex::new(r"(?P<room>.+)\[(?P<checksum>.+)\]").unwrap();
      let caps = re.captures(line).ok_or("")?;
      let room = caps.name("room").unwrap();
      let checksum = caps.name("checksum").unwrap();

      Room::new(room).map(|room| (room, checksum.into()))
    })
    .collect::<Result<_>>()?;
  let mut real_rooms = rooms.iter()
    .filter(|&&(ref room, ref checksum)| room.checksum() == *checksum)
    .map(|&(ref room, _)| room);
  let room = real_rooms.find(|room| room.name().contains("north")).ok_or("")?;

  Ok(room.sector_id.to_string())
}

#[test]
fn test_solve() {}

struct Room {
  encrypted_name: String,
  sector_id: usize,
}

impl Room {
  fn new(s: &str) -> Result<Self> {
    let re = Regex::new(r"(?P<name>.+)-(?P<id>\d+)").unwrap();
    let caps = re.captures(s).ok_or("")?;
    let name = caps.name("name").unwrap();
    let id = caps.name("id").unwrap().parse().chain_err(|| "")?;
    Ok(Room {
      encrypted_name: name.into(),
      sector_id: id,
    })
  }

  fn checksum(&self) -> String {
    let mut counts = HashMap::new();
    for c in self.encrypted_name.chars().filter(|c| c.is_alphabetic()) {
      *counts.entry(c).or_insert(0) += 1;
    }

    let mut counts: Vec<_> = counts.iter().collect();
    counts.sort_by(|a, b| {
      match b.1.cmp(a.1) {
        Ordering::Equal => a.0.cmp(b.0),
        x => x,
      }
    });

    counts.iter().take(5).map(|x| *x.0).collect()
  }

  fn name(&self) -> String {
    self.encrypted_name.chars().map(|c| {
      match c {
        '-' => ' ',
        c => {
          let digit = c.to_digit(36).unwrap() - 10;
          let shifted = (digit + self.sector_id as u32) % 26;
          char::from_digit(shifted + 10, 36).unwrap()
        },
      }
    }).collect()
  }
}

#[test]
fn test_new() {
  let room = Room::new("aaaaa-bbb-z-y-x-123").unwrap();
  assert_eq!(room.encrypted_name, "aaaaa-bbb-z-y-x".to_string());
  assert_eq!(room.sector_id, 123);
}

#[test]
fn test_checksum() {
  let room = Room::new("aaaaa-bbb-z-y-x-123").unwrap();
  assert_eq!(room.checksum(), "abxyz".to_string());

  let room = Room::new("a-b-c-d-e-f-g-h-987").unwrap();
  assert_eq!(room.checksum(), "abcde".to_string());

  let room = Room::new("not-a-real-room-404").unwrap();
  assert_eq!(room.checksum(), "oarel".to_string());

  let room = Room::new("totally-real-room-200").unwrap();
  assert_ne!(room.checksum(), "decoy".to_string());
}

#[test]
fn test_name() {
  let room = Room::new("qzmt-zixmtkozy-ivhz-343").unwrap();
  assert_eq!(room.name(), "very encrypted name");
}
