// Checks on the hinges, chosen by CHECK:
//   "links_vs_body": every link against the cubes and pins; empty if each
//                    link is free in its channel
//   "links":         the links alone; one piece each unless two touch
//   "pins_in_links": the pins against the links with their sockets filled;
//                    how far the pins reach into the links
//   "fold":          the first bottom hinge folded by ANGLE degrees: each of
//                    its two cubes turned about its own axis, against the
//                    link; empty if the hinge turns that far freely
//   "folded":        the same two cubes folded by ANGLE degrees, against each
//                    other; empty if they fold face to face without meeting
include <../infinity-cube.scad>

part = "none";
CHECK = "links_vs_body";
ANGLE = 90;

module body() {
  difference() {
    for (i = [0:3], j = [0:1]) translate(cube_at(i, j)) chamfered_cube();
    for (h = hinges) in_frame(h) channel();
  }
  for (h = hinges) in_frame(h) pins();
}

module solid_link() {
  translate([-axis_x, -link_len / 2, 0]) cube([2 * axis_x, link_len, 2 * r]);
  for (s = [-1, 1])
    translate([s * axis_x, -link_len / 2, r]) rotate([-90, 0, 0]) cylinder(r = r, h = link_len);
}

if (CHECK == "links_vs_body")
  intersection() { body(); for (h = hinges) in_frame(h) link(); }
else if (CHECK == "links")
  for (h = hinges) in_frame(h) link();
else if (CHECK == "pins_in_links")
  intersection() {
    for (h = hinges) in_frame(h) pins();
    for (h = hinges) in_frame(h) solid_link();
  }
else if (CHECK == "fold")
  intersection() {
    union() { folded_cube(0, -1); folded_cube(1, 1); }
    in_frame(hinges[0]) link();
  }
else if (CHECK == "folded")
  intersection() { folded_cube(0, -1); folded_cube(1, 1); }

// Cube i of the first bottom hinge, turned by ANGLE about its own axis.
module folded_cube(i, s) {
  ax = hinges[0][1].x + s * axis_x;
  translate([ax, 0, r]) rotate([0, s * ANGLE, 0]) translate([-ax, 0, -r])
    intersection() { body(); translate(cube_at(i, 0)) cube(size); }
}
