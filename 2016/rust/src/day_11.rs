use regex;
use std::convert::TryFrom;
use std::str;
use errors::*;

// You come upon a column of four floors that have been entirely sealed off from the rest of the
// building except for a small dedicated lobby. There are some radiation warnings and a big sign
// which reads "Radioisotope Testing Facility".

struct Facility {
    floors: Vec<Floor>,
}

#[derive(Debug, PartialEq)]
struct Floor {
    items: Vec<Item>,
}

impl Floor {
    fn generators(&self) -> Vec<String> {
        self.items.iter().map(|item| {
            match *item {
                Item::Generator(ref s) => Some(s),
                _ => None,
            }
        }).flat_map(|x| x).cloned().collect()
    }

    fn microchips(&self) -> Vec<String> {
        self.items.iter().map(|item| {
            match *item {
                Item::Microchip(ref s) => Some(s),
                _ => None,
            }
        }).flat_map(|x| x).cloned().collect()
    }
}

#[test]
fn test_generators_and_microchips() {
    let items = vec![
        Item::Generator("a".into()),
        Item::Microchip("b".into()),
    ];
    let floor = Floor{items};
    assert_eq!(floor.generators(), vec!["a".to_string()]);
    assert_eq!(floor.microchips(), vec!["b".to_string()]);
}

#[derive(Clone, Debug, PartialEq)]
enum Item {
    Generator(String),
    Microchip(String),
}

impl<'a> TryFrom<regex::Captures<'a>> for Item {
    type Err = Error;
    fn try_from(c: regex::Captures) -> Result<Item> {
        let element = c.name("element").ok_or("missing element name")?;
        let itemtype = c.name("itemtype").ok_or("missing item type")?;
        match itemtype {
            "generator" => { Ok(Item::Generator(element.into())) },
            "microchip" => { Ok(Item::Microchip(element.into())) },
            _ => { Err(format!("invalid item type: '{}", itemtype).into()) },
        }
    }
}

// According to the project status board, this facility is currently being used to experiment with
// Radioisotope Thermoelectric Generators (RTGs, or simply "generators") that are designed to be
// paired with specially-constructed microchips. Basically, an RTG is a highly radioactive rock
// that generates electricity through heat.
//
// The experimental RTGs have poor radiation containment, so they're dangerously radioactive. The
// chips are prototypes and don't have normal radiation shielding, but they do have the ability to
// generate an electromagnetic radiation shield when powered. Unfortunately, they can only be
// powered by their corresponding RTG. An RTG powering a microchip is still dangerous to other
// microchips.
//
// In other words, if a chip is ever left in the same area as another RTG, and it's not connected
// to its own RTG, the chip will be fried. Therefore, it is assumed that you will follow procedure
// and keep chips connected to their corresponding RTG when they're in the same room, and away from
// other RTGs otherwise.

impl Floor {
    fn is_safe(&self) -> bool {
        if self.generators().is_empty() {
            return true;
        }

        let generators = self.generators();
        let microchips = self.microchips();
        let unpaired_chips = microchips.iter().filter(|microchip| {
            !generators.contains(&microchip)
        });
        unpaired_chips.count() == 0
    }
}

#[test]
fn test_is_safe() {
    assert!(Floor{items: Vec::new()}.is_safe());
    assert!(Floor{items: vec![Item::Generator("".into())]}.is_safe());
    assert!(Floor{items: vec![Item::Microchip("a".into())]}.is_safe());

    let items = vec![Item::Generator("a".into()), Item::Microchip("b".into())];
    assert!(!Floor{items}.is_safe());

    let items = vec![
        Item::Generator("a".into()),
        Item::Microchip("a".into()),
        Item::Generator("b".into()),
    ];
    assert!(Floor{items}.is_safe());
}

// These microchips sound very interesting and useful to your current activities, and you'd like to
// try to retrieve them. The fourth floor of the facility has an assembling machine which can make
// a self-contained, shielded computer for you to take with you - that is, if you can bring it all
// of the RTGs and microchips.
//
// Within the radiation-shielded part of the facility (in which it's safe to have these
// pre-assembly RTGs), there is an elevator that can move between the four floors. Its capacity
// rating means it can carry at most yourself and two RTGs or microchips in any combination.
// (They're rigged to some heavy diagnostic equipment - the assembling machine will detach it for
// you.) As a security measure, the elevator will only function if it contains at least one RTG or
// microchip. The elevator always stops on each floor to recharge, and this takes long enough that
// the items within it and the items on that floor can irradiate each other. (You can prevent this
// if a Microchip and its Generator end up on the same floor in this way, as they can be connected
// while the elevator is recharging.)
//
// You make some notes of the locations of each component of interest (your puzzle input). Before
// you don a hazmat suit and start moving things around, you'd like to have an idea of what you
// need to do.
//
// When you enter the containment area, you and the elevator will start on the first floor.
//
// For example, suppose the isolated area has the following arrangement:
//
// The first floor contains a hydrogen-compatible microchip and a lithium-compatible microchip.
// The second floor contains a hydrogen generator.
// The third floor contains a lithium generator.
// The fourth floor contains nothing relevant.
// As a diagram (F# for a Floor number, E for Elevator, H for Hydrogen, L for Lithium, M for Microchip, and G for Generator), the initial state looks like this:

impl str::FromStr for Facility {
    type Err = Error;

    fn from_str(input: &str) -> Result<Self> {
        let floors = input.lines()
            .map(|line| line.parse::<Floor>())
            .collect::<Result<Vec<_>>>()?;
        Ok(Facility{floors})
    }
}

#[test]
fn test_facility_from_str() {
    let input = "The first floor contains a hydrogen-compatible microchip and a lithium-compatible microchip.
The second floor contains a hydrogen generator.
The third floor contains a lithium generator.
The fourth floor contains nothing relevant.";
    let facility: Facility = input.parse().unwrap();
    assert_eq!(facility.floors.len(), 4);
    assert_eq!(facility.floors[1], Floor{items: vec![Item::Generator("hydrogen".into())]});
}

impl str::FromStr for Floor {
    type Err = Error;

    fn from_str(input: &str) -> Result<Self> {
        // Ok(Floor{items: Vec::new()})
        let re = regex::Regex::new(r"(?P<element>\w+)(-compatible)? (?P<itemtype>generator|microchip)").unwrap();
        re.captures_iter(input)
            .map(|captures| Item::try_from(captures))
            .collect::<Result<Vec<_>>>()
            .map(|items| Floor{items} )
    }
}

#[test]
fn test_floor_from_str() {
    let input = "The first floor contains a hydrogen-compatible microchip and \
                 a lithium-compatible microchip.";
    let floor: Floor = input.parse().unwrap();
    assert_eq!(floor.items.len(), 2);
    assert!(floor.items.contains(&Item::Microchip("hydrogen".into())));
    assert!(floor.items.contains(&Item::Microchip("lithium".into())));

    let input = "The first floor contains a hydrogen-compatible microchip and \
                 a lithium generator.";
    let floor: Floor = input.parse().unwrap();
    assert_eq!(floor.items.len(), 2);
    assert!(floor.items.contains(&Item::Microchip("hydrogen".into())));
    assert!(floor.items.contains(&Item::Generator("lithium".into())));
}

// F4 .  .  .  .  .
// F3 .  .  .  LG .
// F2 .  HG .  .  .
// F1 E  .  HM .  LM
// Then, to get everything up to the assembling machine on the fourth floor, the following steps could be taken:
//
// Bring the Hydrogen-compatible Microchip to the second floor, which is safe because it can get power from the Hydrogen Generator:
//
// F4 .  .  .  .  .
// F3 .  .  .  LG .
// F2 E  HG HM .  .
// F1 .  .  .  .  LM
// Bring both Hydrogen-related items to the third floor, which is safe because the Hydrogen-compatible microchip is getting power from its generator:
//
// F4 .  .  .  .  .
// F3 E  HG HM LG .
// F2 .  .  .  .  .
// F1 .  .  .  .  LM
// Leave the Hydrogen Generator on floor three, but bring the Hydrogen-compatible Microchip back down with you so you can still use the elevator:
//
// F4 .  .  .  .  .
// F3 .  HG .  LG .
// F2 E  .  HM .  .
// F1 .  .  .  .  LM
// At the first floor, grab the Lithium-compatible Microchip, which is safe because Microchips don't affect each other:
//
// F4 .  .  .  .  .
// F3 .  HG .  LG .
// F2 .  .  .  .  .
// F1 E  .  HM .  LM
// Bring both Microchips up one floor, where there is nothing to fry them:
//
// F4 .  .  .  .  .
// F3 .  HG .  LG .
// F2 E  .  HM .  LM
// F1 .  .  .  .  .
// Bring both Microchips up again to floor three, where they can be temporarily connected to their corresponding generators while the elevator recharges, preventing either of them from being fried:
//
// F4 .  .  .  .  .
// F3 E  HG HM LG LM
// F2 .  .  .  .  .
// F1 .  .  .  .  .
// Bring both Microchips to the fourth floor:
//
// F4 E  .  HM .  LM
// F3 .  HG .  LG .
// F2 .  .  .  .  .
// F1 .  .  .  .  .
// Leave the Lithium-compatible microchip on the fourth floor, but bring the Hydrogen-compatible one so you can still use the elevator; this is safe because although the Lithium Generator is on the destination floor, you can connect Hydrogen-compatible microchip to the Hydrogen Generator there:
//
// F4 .  .  .  .  LM
// F3 E  HG HM LG .
// F2 .  .  .  .  .
// F1 .  .  .  .  .
// Bring both Generators up to the fourth floor, which is safe because you can connect the Lithium-compatible Microchip to the Lithium Generator upon arrival:
//
// F4 E  HG .  LG LM
// F3 .  .  HM .  .
// F2 .  .  .  .  .
// F1 .  .  .  .  .
// Bring the Lithium Microchip with you to the third floor so you can use the elevator:
//
// F4 .  HG .  LG .
// F3 E  .  HM .  LM
// F2 .  .  .  .  .
// F1 .  .  .  .  .
// Bring both Microchips to the fourth floor:
//
// F4 E  HG HM LG LM
// F3 .  .  .  .  .
// F2 .  .  .  .  .
// F1 .  .  .  .  .
// In this arrangement, it takes 11 steps to collect all of the objects at the fourth floor for assembly. (Each elevator stop counts as one step, even if nothing is added to or removed from it.)
//
// In your situation, what is the minimum number of steps required to bring all of the objects to the fourth floor?

pub fn solve(input: &str) -> Result<String> {
    return Ok("".into())
}

#[test]
fn test_solve() {
    let input = "The first floor contains a hydrogen-compatible microchip and a lithium-compatible microchip.
The second floor contains a hydrogen generator.
The third floor contains a lithium generator.
The fourth floor contains nothing relevant.";
}
