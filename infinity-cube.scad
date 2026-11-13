// infinity-cube.scad: a print-in-place infinity cube.
//
// Eight cubes in a 4 x 2 block, joined by eight hinges, fold through each
// other endlessly. Each hinge is a stadium-shaped link sunk into a channel
// across two neighbouring cubes, turning on cone pins that stand out from the
// channel's ends into cone sockets in the link. The hinge scales with the
// cube; the clearances that let it turn stay fixed.

/* [Size] */
// Edge of each cube (mm)
size = 20;
// Gap between neighbouring cubes (mm)
spacing = 1;
// Chamfer on the cubes' edges (mm)
chamfer = 2;

/* [Hinges] */
// Hinge radius (mm); 0 uses size / 5
hinge_radius = 0;
// Gap between each link and its channel (mm)
clearance = 0.4;
// Radial gap between each pin and its socket (mm)
pin_clearance = 0.5;
// Break-away supports under the side and top links, for printing
supports = true;
// Leave the links out, to check the channels and pins on their own
show_links = true;
// "cube" renders the infinity cube; "none" renders nothing, for including this file
part = "cube"; // [cube, none]

$fn = $preview ? 32 : 64;

r = hinge_radius > 0 ? hinge_radius : size / 5;
// Each hinge sits on a cube face across the gap. In its own frame the gap is
// centred on x = 0, the hinge axes run along y, and the cubes lie at z >= 0.
axis_x = r + spacing / 2;     // the two axes, at x = -axis_x and +axis_x
channel_len = size / 2;       // channel length along the axes
link_len = channel_len - 2 * clearance;
pin_h = r - 0.1;              // cone pin: length and end radii
pin_r1 = r / 2;
pin_r2 = r / 4;

assert(chamfer < r, str("chamfer must be less than the hinge radius (", r, " mm) so the channels clear it"));
assert(spacing >= 0.4, "spacing must be at least 0.4 mm for the cubes to turn");

// ---------------- One hinge, in its own frame ----------------
// The channel cut into the two cubes: the link's stadium plus clearance, open
// to the face at z = 0.
module channel() {
  translate([-axis_x, -channel_len / 2, -1]) cube([2 * axis_x, channel_len, 2 * r + clearance + 1]);
  translate([-(axis_x + r + clearance), -channel_len / 2, -1])
    cube([2 * (axis_x + r + clearance), channel_len, r + 1]);
  for (s = [-1, 1])
    translate([s * axis_x, -channel_len / 2, r]) rotate([-90, 0, 0]) cylinder(r = r + clearance, h = channel_len);
}

// A cone along the axis at x, from the channel end at y = end * channel_len / 2
// pointing back into the channel.
module cone_at(x, end, h, r1, r2) {
  translate([x, end * channel_len / 2, r]) rotate([end * 90, 0, 0]) cylinder(h = h, r1 = r1, r2 = r2);
}

// The four pins, standing from the channel's ends into the link's sockets.
module pins() {
  for (s = [-1, 1], end = [-1, 1]) cone_at(s * axis_x, end, pin_h, pin_r1, pin_r2);
}

// The link: a stadium spanning both axes, with a cone socket at each pin.
module link() {
  difference() {
    union() {
      translate([-axis_x, -link_len / 2, 0]) cube([2 * axis_x, link_len, 2 * r]);
      for (s = [-1, 1])
        translate([s * axis_x, -link_len / 2, r]) rotate([-90, 0, 0]) cylinder(r = r, h = link_len);
    }
    for (s = [-1, 1], end = [-1, 1])
      cone_at(s * axis_x, end, pin_h + clearance, pin_r1 + pin_clearance, pin_r2 + pin_clearance);
  }
}

// A thin rib across the link's lower end and into both cubes, for a hinge
// whose axes stand vertical; `end` is the end of the link that faces down.
module side_rib(end) {
  y = end < 0 ? -link_len / 2 : link_len / 2 - 0.2;
  w = axis_x + r + clearance + 1.5;
  translate([-w, y, r - 0.2]) cube([2 * w, 0.2, 0.2]);
}

// Two thin pads from the link's far side to the channel floor, for a hinge
// printed upside down on the top face.
module top_pads() {
  for (s = [-1, 1])
    translate([s * (1 + spacing / 2) - (s < 0 ? 0.2 : 0), -2, 2 * r - 1]) cube([0.2, 4, 2]);
}

// ---------------- The cube ----------------
function cube_at(i, j) = [(size + spacing) * i, (size + spacing) * j, 0];

// A cube with chamfered edges and corners.
module chamfered_cube() {
  c = chamfer;
  hull() {
    translate([0, c, c]) cube([size, size - 2 * c, size - 2 * c]);
    translate([c, 0, c]) cube([size - 2 * c, size, size - 2 * c]);
    translate([c, c, 0]) cube([size - 2 * c, size - 2 * c, size]);
  }
}

// Each hinge: where its frame sits, how it is turned, and its support.
//   bottom: across the gaps between columns 0-1 and 2-3, on the bottom face
//   side:   across the gap between columns 1-2, on the back and front faces
//   top:    across the gap between the rows, on the top face of columns 0 and 3
gap = size + spacing / 2;
TOP = [[0, 1, 0, 0], [1, 0, 0, 0], [0, 0, -1, 0], [0, 0, 0, 1]];
hinges = [
  for (i = [0, 2], j = [0, 1])
    ["bottom", [(size + spacing) * i + gap, (size + spacing) * j + size / 2, 0], [0, 0, 0]],
  ["side_back", [(size + spacing) + gap, 2 * size + spacing, size / 2], [90, 0, 0]],
  ["side_front", [(size + spacing) + gap, 0, size / 2], [-90, 0, 0]],
  for (i = [0, 3]) ["top", [(size + spacing) * i + size / 2, gap, size], TOP],
];

module in_frame(h) {
  translate(h[1])
    if (h[0] == "top") multmatrix(h[2]) children();
    else rotate(h[2]) children();
}

module infinity_cube() {
  difference() {
    for (i = [0:3], j = [0:1]) translate(cube_at(i, j)) chamfered_cube();
    for (h = hinges) in_frame(h) channel();
  }
  for (h = hinges) in_frame(h) {
    pins();
    if (show_links) link();
    if (supports && show_links) {
      if (h[0] == "side_back") side_rib(-1);
      if (h[0] == "side_front") side_rib(1);
      if (h[0] == "top") top_pads();
    }
  }
}

if (part == "cube") infinity_cube();
else assert(part == "none", str("part must be cube or none, not ", part));
