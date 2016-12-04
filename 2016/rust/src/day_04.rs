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
  let real_rooms = rooms.iter()
    .filter(|&&(ref room, ref checksum)| room.checksum() == *checksum);
  let sector_ids = real_rooms.map(|&(ref room, _)| room.sector_id);
  let sum: usize = sector_ids.sum();

  Ok(sum.to_string())
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
