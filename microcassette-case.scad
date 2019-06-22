interior_dimensions = [51, 35, 8.5];
pocket_depth = 12;
wall_thickness = 1;
cover_gap = 0.4;
hinge_plate_gap = 0.4;

epsilon = 0.1;
outsideplusexact = interior_dimensions + [1, 1, 1] * (wall_thickness * 2);
outsideplus = interior_dimensions + [1, 1, 1] * ((wall_thickness + epsilon) * 2);
outsideplushalf = outsideplus / 2;
hinge_plate_thickness = wall_thickness;

preview();


module preview() {
    base_half();
    %cover_half();
}

module base_half() {
    difference() {
        shell(false);
        cut(false);
        
        hinge_axis() cylinder(d=3, h=interior_dimensions.x, $fn=30);
    }
}

module cover_half() {
    intersection() {
        shell(true);
        cut(true);
    }
    
    mirrored([1, 0, 0])
    cover_end_plate();
}

module cover_end_plate() {
    translate([interior_dimensions.x / 2 + wall_thickness + hinge_plate_gap, 0, 0]) {
        translate([hinge_plate_thickness / 2, 0, 0])
        cube([hinge_plate_thickness, outsideplusexact.y, outsideplusexact.z], center=true);
    }
}

module cut(is_for_cover) {
    slant = interior_dimensions.z / 2;  // TODO not accounting for thicknesses
    translate(is_for_cover ? [0, -cover_gap / sqrt(2), cover_gap] : [0, 0, 0])
    rotate([0, 90, 0])
    mirror([1, 0, 0])
    linear_extrude(interior_dimensions.x + 2 * (wall_thickness + hinge_plate_gap + epsilon), center=true)
    polygon([
        [-interior_dimensions.z/2, -outsideplushalf.y],
        [-interior_dimensions.z/2, outsideplushalf.y - pocket_depth - slant],
        [outsideplushalf.z, outsideplushalf.y - pocket_depth + slant],
        [outsideplushalf.z, -outsideplushalf.y],
    ]);
}

module shell(is_for_cover) {
    difference() {
        minkowski() {
            cube([
                (wall_thickness + (is_for_cover ? hinge_plate_gap + hinge_plate_thickness : 0)) * 2,
                wall_thickness * 2,
                wall_thickness * 2,
            ], center=true);
            
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

module mirrored(axis) {
    children();
    mirror(axis) children();
}
