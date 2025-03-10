// Sturdy Infinity Cube reference

$fn = 100;

difference()
{
    size = 20;   // Size of each cube.  Below 16, the links interfere with each other.
    spacing = 1; // Space between cubes.
    cut = 2;     // Size of the edge cut.

    union()
    {
        difference()
        {
            union()
            {
                for (i = [0:3])
                {
                    translate([ size * i + spacing * i, 0, 0 ]) rcube(size, cut);
                    translate([ size * i + spacing * i, size + spacing, 0 ]) rcube(size, cut);
                }
            }
            // bottom
            translate([ size - 8.5, size / 4, 0 ]) linkcut(size, spacing);
            translate([ size - 8.5, size / 4 + size + spacing, 0 ]) linkcut(size, spacing);
            translate([ size * 3 - 8.5 + 2 * spacing, size / 4, 0 ]) linkcut(size, spacing);
            translate([ size * 3 - 8.5 + 2 * spacing, size / 4 + size + spacing, 0 ]) linkcut(size, spacing);

            // sides
            translate([ size * 2 - 8.5 + spacing, size * 2 + spacing, size / 4 ]) rotate([ 90, 0, 0 ])
                linkcut(size, spacing);
            translate([ size * 2 - 8.5 + spacing, 0, size - size / 4 ]) rotate([ -90, 0, 0 ]) linkcut(size, spacing);

            // top
            translate([ size / 4, size - 8.5, size ]) rotate([ 180, 0, 90 ]) linkcut(size, spacing);
            translate([ size * 3 + spacing * 3 + size / 4, size - 8.5, size ]) rotate([ 180, 0, 90 ])
                linkcut(size, spacing);
        }

        translate([ size - 8.5, size / 4, 0 ]) link(size, spacing);
        translate([ size - 8.5, size / 4 + size + spacing, 0 ]) link(size, spacing);
        translate([ size * 3 - 8.5 + spacing * 2, size / 4, 0 ]) link(size, spacing);
        translate([ size * 3 - 8.5 + spacing * 2, size / 4 + size + spacing, 0 ]) link(size, spacing);

        // sides
        translate([ size * 2 - 8.5 + spacing, size * 2 + spacing, size / 4 ]) rotate([ 90, 0, 0 ]) link(size, spacing);
        translate([ size * 2 - 8.5 + spacing - 1, size * 2 + spacing - 4, size / 4 + 0.4 ])
            cube([ 20 + spacing, 0.2, 0.2 ]); // support

        translate([ size * 2 - 8.5 + spacing, 0, size - size / 4 ]) rotate([ -90, 0, 0 ]) link(size, spacing);
        translate([ size * 2 - 8.5 + spacing - 1, 4, size / 4 + 0.4 ]) cube([ 20 + spacing, 0.2, 0.2 ]); // support

        // top
        translate([ size / 4, size - 8.5, size ]) rotate([ 180, 0, 90 ]) link(size, spacing);
        translate([ size / 2 - 2, size - 1, size - 9 ]) cube([ 4, 0.2, 2 ]);           // support
        translate([ size / 2 - 2, size + spacing + 1, size - 9 ]) cube([ 4, 0.2, 2 ]); // support

        translate([ size * 3 + spacing * 3 + size / 4, size - 8.5, size ]) rotate([ 180, 0, 90 ]) link(size, spacing);
        translate([ size * 3.5 + spacing * 3 - 2, size - 1, size - 9 ]) cube([ 4, 0.2, 2 ]);           // support
        translate([ size * 3.5 + spacing * 3 - 2, size + spacing + 1, size - 9 ]) cube([ 4, 0.2, 2 ]); // support
    }
}

module rcube(size, cut)
{
    translate([ size / 2, size / 2, size / 2 ]) for (i = [0:4]) rotate([ 90 * i, 0, 0 ])
    {
        union()
        {
            subcube(size, cut);
            rotate([ 0, 0, 90 ]) subcube(size, cut);
        }
    }
}

module subcube(size, cut)
{
    translate([ -size / 2, -size / 2, -size / 2 ]) difference()
    {
        cube(size / 2);
        translate([ -0.5, cut, 0 ]) rotate([ 135, 0, 0 ]) cube(size);
        translate([ cut, size, 0 ]) rotate([ 135, 0, -90 ]) cube(size + 1);
        translate([ cut, 0, 0 ]) rotate([ 0, 0, 135 ]) cube(size);
    }
}

module link(size, spacing)
{
    s2 = size / 2;
    union()
    {
        difference()
        {
            union()
            {
                translate([ 4.5, 0.4, 0 ]) cube([ 8 + spacing, s2 - 0.8, 8 ]);
                translate([ 4.5, 0.4, 4 ]) rotate([ -90, 0, 0 ]) cylinder(h = s2 - 0.8, r = 4);
                translate([ 12.5 + spacing, 0.4, 4 ]) rotate([ -90, 0, 0 ]) cylinder(h = s2 - 0.8, r = 4);
            }
            translate([ 4.5, s2, 4 ]) rotate([ 90, 0, 0 ]) cylinder(4.3, 2.5, 1.5);
            translate([ 12.5 + spacing, s2, 4 ]) rotate([ 90, 0, 0 ]) cylinder(4.3, 2.5, 1.5);

            translate([ 4.5, 0, 4 ]) rotate([ -90, 0, 0 ]) cylinder(4.3, 2.5, 1.5);
            translate([ 12.5 + spacing, 0, 4 ]) rotate([ -90, 0, 0 ]) cylinder(4.3, 2.5, 1.5);
        }
        translate([ 4.5, s2, 4 ]) rotate([ 90, 0, 0 ]) cylinder(3.9, 2, 1);
        translate([ 12.5 + spacing, s2, 4 ]) rotate([ 90, 0, 0 ]) cylinder(3.9, 2, 1);

        translate([ 4.5, 0, 4 ]) rotate([ -90, 0, 0 ]) cylinder(3.9, 2, 1);
        translate([ 12.5 + spacing, 0, 4 ]) rotate([ -90, 0, 0 ]) cylinder(3.9, 2, 1);
    }
}

module linkcut(size, spacing)
{
    s2 = size / 2;
    union()
    {
        translate([ 4.5, 0, -1 ]) cube([ 8 + spacing, s2, 9.4 ]);
        translate([ 0.1, 0, -1 ]) cube([ 16.8 + spacing, s2, 5 ]);
        translate([ 4.5, 0, 4 ]) rotate([ -90, 0, 0 ]) cylinder(h = s2, r = 4.4);
        translate([ 12.5 + spacing, 0, 4 ]) rotate([ -90, 0, 0 ]) cylinder(h = s2, r = 4.4);
    }
}