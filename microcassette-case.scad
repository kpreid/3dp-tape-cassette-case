interior_dimensions = [51, 35, 8.5];
pocket_depth = 12;
wall_thickness = 1;
cover_gap = 0.4;

epsilon = 0.1;
outsideplus = interior_dimensions + [1, 1, 1] * ((wall_thickness + epsilon) * 2);
outsideplushalf = outsideplus / 2;

preview();


module preview() {
    base_half();
    cover_half();
}

module base_half() {
    difference() {
        shell();
        cut(false);
        
        hinge_axis() cylinder(d=3, h=interior_dimensions.x, $fn=30);
    }
}

module cover_half() {
    intersection() {
        shell();
        cut(true);
    }
}

module cut(is_for_cover) {
    slant = interior_dimensions.z / 2;  // TODO not accounting for thicknesses
    translate(is_for_cover ? [0, -cover_gap / sqrt(2), cover_gap] : [0, 0, 0])
    rotate([0, 90, 0])
    mirror([1, 0, 0])
    linear_extrude(outsideplus.x, center=true)
    polygon([
        [-interior_dimensions.z/2, -outsideplushalf.y],
        [-interior_dimensions.z/2, outsideplushalf.y - pocket_depth - slant],
        [outsideplushalf.z, outsideplushalf.y - pocket_depth + slant],
        [outsideplushalf.z, -outsideplushalf.y],
    ]);
}

module shell() {
    difference() {
        minkowski() {
            octahedron(wall_thickness / 2);
            cube([1, 1, 1] * wall_thickness, center=true);
            
            cube(interior_dimensions, center=true);
        }
        cube(interior_dimensions, center=true);
    }
}

module hinge_axis() {
    translate([0, interior_dimensions.y / 2 - interior_dimensions.z / 2])
    rotate([0, 90, 0])
    children();
}

module octahedron(r) {
    scale([r, r, r])
    polyhedron(
        points=[
            [1, 0, 0],
            [-1, 0, 0],
            [0, 1, 0], 
            [0, -1, 0],
            [0, 0, 1],
            [0, 0, -1],
        ],
        faces=[
            [0, 4, 2],
            [0, 2, 5],
            [0, 3, 4],
            [0, 5, 3],
            [1, 2, 4],
            [1, 5, 2],
            [1, 4, 3],
            [1, 3, 5],
        ], convexity=1);
}