interior_dimensions = [51, 35, 8.5];
pocket_depth = 12;
wall_thickness = 1;
cover_gap = 0.4;
hinge_plate_gap = 0.2;
hinge_diameter = 3;
hinge_nub_thickness = 1.0;
latch_diameter = 2;
latch_nub_thickness = 0.4;
outer_chamfer = 0.4;

epsilon = 0.1;
outsideplusexact = interior_dimensions + [1, 1, 1] * (wall_thickness * 2);
outsideplus = interior_dimensions + [1, 1, 1] * ((wall_thickness + epsilon) * 2);
outsideplushalf = outsideplus / 2;
hinge_plate_thickness = wall_thickness;
full_outside_dimensions = interior_dimensions + [
    wall_thickness + hinge_plate_thickness + hinge_plate_gap,
    wall_thickness, 
    wall_thickness] * 2;


printable();


module printable() {
    separation = full_outside_dimensions.x + 1;
    
    translate([-separation / 2, 0, 0])
    base_half();

    translate([separation / 2, 0, 0])
    rotate([180, 0, 0])
    cover_half();
}

module preview() {
    color("pink") base_half();
    %cover_half();
}

module hinge_preview() {
    difference() {
        union() {
            color("pink") base_half();
            cover_half();
        }
        
        translate(interior_dimensions * -0.45)
        cube(outsideplus);
    }
}

module base_half() {
    intersection() {
        difference() {
            shell(false);
            
            cut(false);
            
            hinge_axis() cylinder(d=hinge_diameter, h=outsideplus.x, center=true, $fn=30);
            latch_axis() cylinder(d=latch_diameter, h=outsideplus.x, center=true, $fn=30);
        }

        outside_chamfer_shape();
    }
}

module cover_half() {
    render(convexity=4) {  // cheap and improves glitches in preview
        intersection() {
            union() {
                intersection() {
                    shell(true);
                    cut(true);
                }
                
                mirrored([1, 0, 0])
                cover_end_plate();
            }
            
            outside_chamfer_shape();
        }
    }
}

module cover_end_plate() {
    translate([interior_dimensions.x / 2 + wall_thickness + hinge_plate_gap, 0, 0]) {
        translate([hinge_plate_thickness / 2, 0, 0])
        cube([hinge_plate_thickness, outsideplusexact.y, outsideplusexact.z], center=true);
    
        hinge_axis() inward_nub(hinge_diameter + hinge_plate_gap, hinge_nub_thickness, 2);
        latch_axis() inward_nub(latch_diameter, latch_nub_thickness, 0.5);
    }
}

module inward_nub(d, h, bevel_slope) {
    mirror([0, 0, 1])  // sticks out towards center
    cylinder(d1=d, d2=max(0, d - 2 * h / bevel_slope), h=h, $fn=30);
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
        minkowski() {  // TODO this can be just a sized cube
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

module outside_chamfer_shape() {
    octabox(d=full_outside_dimensions, r=outer_chamfer);
}

module hinge_axis() {
    translate([0, interior_dimensions.y / 2 - interior_dimensions.z / 2, 0])
    rotate([0, 90, 0])
    children();
}

module latch_axis() {
    // TODO: y position is fudged
    translate([0, interior_dimensions.y / 2 - interior_dimensions.z * 1.2, -interior_dimensions.z * 0.25])
    rotate([0, 90, 0])
    children();
}

module octabox(d, r, center=true) {
    minkowski() {
        cube(d - [1, 1, 1] * r * 2, center=center);
        octahedron(r);
    }
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
