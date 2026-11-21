# Render and check the cube at several sizes
test:
    python3 tests/test_cube.py

# Everything CI runs, bar the tests
check: fmt-check

# Format the .scad sources with topiary (.topiary/languages.ncl)
fmt:
    git ls-files -z '*.scad' | xargs -0 -r topiary format

# Check the .scad sources are formatted, without changing them
fmt-check:
    git ls-files -z '*.scad' | xargs -0 -r -n1 topiary format --check

# Render the README pictures into assets/
images:
    mkdir -p assets
    openscad --imgsize 1200,700 --viewall --autocenter --colorscheme Tomorrow --camera 0,0,0,55,0,25,0 -o assets/cube.png infinity-cube.scad
    openscad --imgsize 1200,700 --viewall --autocenter --colorscheme Tomorrow --camera 0,0,0,235,0,205,0 -o assets/underside.png infinity-cube.scad
    openscad --imgsize 1200,700 --viewall --autocenter --colorscheme Tomorrow --camera 0,0,0,55,0,25,0 -D show_links=false -o assets/channels.png infinity-cube.scad
