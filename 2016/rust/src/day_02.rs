use std::char;

pub fn solve(input: &str) -> String {
  let arrangement = vec![
    vec!['1', '2', '3'],
    vec!['4', '5', '6'],
    vec!['7', '8', '9'],
  ];
  let mut keypad = Keypad {
    arrangement: arrangement,
    current: (1, 1),
  };

  let mut answer = String::new();
  for c in input.chars() {
    match c {
      'U' => { keypad.move_(Dir::Up); },
      'D' => { keypad.move_(Dir::Down); },
      'L' => { keypad.move_(Dir::Left); },
      'R' => { keypad.move_(Dir::Right); },
      '\n' => { answer.push(keypad.button()); },
      _ => { unreachable!(); },
    }
  }
  answer.push(keypad.button());
  answer
}

#[test]
fn test_solve() {
  let instructions = "ULL
RRDDD
LURDL
UUUUD";

  assert_eq!(solve(instructions), "1985".to_string());
}

struct Keypad {
  arrangement: Vec<Vec<char>>,
  current: (usize, usize),
}

impl Keypad {
  fn move_(&mut self, dir: Dir) {
    let (dx, dy): (isize, isize) = match dir {
      Dir::Up => (0, -1),
      Dir::Down => (0, 1),
      Dir::Left => (-1, 0),
      Dir::Right => (1, 0),
    };

    let x = (self.current.0 as isize + dx) as usize;
    let y = (self.current.1 as isize + dy) as usize;

    if self.button_at(x, y).is_some() {
      self.current = (x, y);
    }
  }

  fn button(&self) -> char {
    let (x, y) = self.current;
    self.arrangement[y][x].clone()
  }

  fn button_at(&self, x: usize, y: usize) -> Option<char> {
    self.arrangement.get(y).and_then(|row| row.get(x)).cloned()
  }
}

enum Dir {
  Up, Down, Left, Right
}

#[test]
fn test_keypad() {
  let arrangement = vec![
    vec!['1', '2', '3'],
    vec!['4', '5', '6'],
    vec!['7', '8', '9'],
  ];
  let mut keypad = Keypad {
    arrangement: arrangement,
    current: (1, 1),
  };

  assert_eq!(keypad.button_at(1, 1), Some('5'));
  assert_eq!(keypad.button(), '5');

  keypad.move_(Dir::Up);
  assert_eq!(keypad.button(), '2');

  keypad.move_(Dir::Up);
  assert_eq!(keypad.button(), '2');
}
