require "matrix"
require "set"

scanners = ARGF.read.strip.split("\n\n").to_h {|scanner|
  id, *rest = scanner.split("\n")
  id = id.scan(/\d+/)[0].to_i
  coords = rest.map { _1.split(?,).map(&:to_i) }
  [id, coords.map { Matrix.column_vector(_1) }]
}

first_scanner = scanners.shift
origin_beacon = first_scanner[1].first
origin_beacon = Matrix.column_vector([-618,-824,-621])

known_scanners = {
  first_scanner[0] => [ origin_beacon.map { -_1 }, Matrix.identity(3) ],
}
known_beacons = Set.new(first_scanner[1].map {|beacon| beacon - origin_beacon })

rot_x = Matrix[ [1, 0,  0], [0, 0, -1], [0, 1,  0] ]
rot_y = Matrix[ [0,  0, 1], [0,  1, 0], [-1, 0, 0] ]
rot_z = Matrix[ [0, -1, 0], [1,  0, 0], [0,  0, 1] ]
id = Matrix.identity(3)

ROTATIONS = Set.new(
  Array.new(4) { rot_x ** _1 }.flat_map {|x|
    Array.new(4) { rot_y ** _1 }.flat_map {|y|
      Array.new(4) { rot_z ** _1 }.map {|z| x * y * z }}}
)

def find_overlapping_scanner(known_beacons, scanners)
  scanners.filter_map {|id, beacons|
    haystack = ROTATIONS.flat_map {|r| beacons.map {|b| [ r*b, r ] }}
    # haystack.select { _2 == Matrix.identity(3) }.map(&:first).each { p _1 }
    haystack.find {|position, rotation|
      translated_beacons = beacons.map { (rotation * _1) - position }
      (known_beacons & translated_beacons).size >= 12
    }&.then {|p,o| [id, p, o] }
  }.first
end

until scanners.empty?
  id, position, orientation = find_overlapping_scanner(known_beacons, scanners)

  p [id, position, orientation]

  known_scanners[id] = [position, orientation]
  translated_beacons = scanners[id].map {|b| b.zip(position).map { _2 - _1 }.zip(orientation).map { _1 * _2 }}
  known_beacons.merge(translated_beacons)
  scanners.delete(id)
end

