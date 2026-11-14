// A test print of one hinge: two cubes and the link between them.
// It prints in a fraction of the full cube's time, so the clearances can be tuned for a
// printer first. Print it bottom face down, then fold it: it should turn freely to 90 degrees.

include <../infinity-cube.scad>

/* [Test hinge] */
// Edge of each cube (mm); use the size the full cube will be
size = 20; // [12:1:30]
// Gap between the link and its channel (mm)
clearance = 0.4; // [0.2:0.05:0.8]
// Radial gap between each pin and its socket (mm)
pin_clearance = 0.5; // [0.2:0.05:0.8]

/* [Hidden] */
part = "none";

// The first bottom hinge, across the gap between the first two cubes of the front row.
difference() {
  for (i = [0, 1]) translate(cube_at(i, 0)) chamfered_cube();
  in_frame(hinges[0]) channel();
}
in_frame(hinges[0]) {
  pins();
  link();
}
