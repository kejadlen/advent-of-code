use std::error::Error;

use regex::Regex;

use advent_of_code::main;

main!();

fn solve(input: &str) -> Result<String, Box<Error>> {
    let re = Regex::new(r"(?P<players>\d+) players; last marble is worth (?P<points>\d+) points")
        .unwrap();
    let caps = re.captures(input).unwrap();
    let player_count = caps.name("players").unwrap().as_str().parse()?;
    let marble_count: usize = caps.name("points").unwrap().as_str().parse()?;
    let high_score = play(player_count, marble_count * 100);
    Ok(high_score.to_string())
}

fn play(player_count: usize, marble_count: usize) -> usize {
    let mut scores = vec![0; player_count];
    let mut circle = vec![Marble {
        value: 0,
        next: 0,
        prev: 0,
    }];

    let mut current_player = 0;
    let mut current_index: usize = 0;

    for value in 1..=marble_count {
        if value % 23 == 0 {
            scores[current_player] += value;
            for _ in 0..7 {
                current_index = circle[current_index].prev;
            }
            let marble = &circle[current_index];
            scores[current_player] += marble.value;
            let prev = marble.prev;
            let next = marble.next;
            circle[prev].next = next;
            circle[next].prev = prev;
            current_index = next;
        } else {
            current_index = circle[current_index].next;
            let current_marble = &circle[current_index];
            let next = current_marble.next;
            let prev = current_index;
            let marble = Marble { value, next, prev };
            circle.push(marble);
            current_index = circle.len() - 1;
            circle[prev].next = current_index;
            circle[next].prev = current_index;
        }

        // if current_index % 100000 == 0 {
        //     println!("{}", current_index);
        // }
        // println!("[{}] {:?}", current_player + 1, circle_to_string(&circle));

        current_player += 1;
        current_player %= player_count;
    }

    *scores.iter().max().unwrap()
}

#[test]
fn test_play() {
    assert_eq!(play(9, 25), 32);
    assert_eq!(play(10, 1618), 8317);
    assert_eq!(play(13, 7999), 146373);
    assert_eq!(play(17, 1104), 2764);
    assert_eq!(play(21, 6111), 54718);
    assert_eq!(play(30, 5807), 37305);
}

// fn circle_to_string(circle: &Vec<Marble>) -> String {
//     let mut i = 0;
//     let mut v = Vec::new();
//     loop {
//         v.push(circle[i].value);
//         i = circle[i].next;
//         if i == 0 {
//             break;
//         }
//     }
//     format!("{:?}", v)
// }

#[derive(Debug)]
struct Marble {
    value: usize,
    next: usize,
    prev: usize,
}
