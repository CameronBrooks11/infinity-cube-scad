# Render and check the cube at several sizes
test:
    python3 tests/test_cube.py

# Render the README pictures into assets/
images:
    mkdir -p assets
    openscad --imgsize 1200,700 --viewall --autocenter --colorscheme Tomorrow --camera 0,0,0,55,0,25,0 -o assets/cube.png infinity-cube.scad
    openscad --imgsize 1200,700 --viewall --autocenter --colorscheme Tomorrow --camera 0,0,0,235,0,205,0 -o assets/underside.png infinity-cube.scad
    openscad --imgsize 1200,700 --viewall --autocenter --colorscheme Tomorrow --camera 0,0,0,55,0,25,0 -D show_links=false -o assets/channels.png infinity-cube.scad
