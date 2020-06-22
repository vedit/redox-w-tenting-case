$fa=1;
$fs=5;
$fs=2;    // Uncomment for final render

base_height = 10;
base_chamfer = 2.5;
wall_thickness = 2.0004;


tent_positions = [
    // [X, Y, Angle]
    [96.5, 45.0, 0],
    [96.5, -16.5, 0],
    [-55.8, 45.5, 175],
    [-68, -46, -150],
    ];

// M5 bolt tenting
boltRad = 5 / 2;
nutRad = 9.4 / 2;
nutHeight = 3.5;
module tent_support(position) {
    off = apothem(nutRad, 6)+0.5;
    lift = 0;
    height = base_height - lift;
    translate([position[0], position[1], lift]) rotate([0, 0, position[2]]) {
        difference() {
            chamfer_extrude(height=height, chamfer=base_chamfer, faces = [true, false]) {
                hull() {
                    translate([-5,0]) square([0.1, 35], center=true);
                    translate([off, 0]) circle(r=boltRad+base_chamfer+1.5);
                }
            }
            translate([-10,-20, -0.1]) cube([10-base_chamfer, 40, base_chamfer+1], center=false);
            translate([-10,-20, base_chamfer]) cube([10-wall_thickness+0.1, 40, base_height+1], center=false);
            translate([off, 0, -0.1]) polyhole(r=boltRad, h=height+1);
            // Nut hole
            translate([off, 0, height-nutHeight]) rotate([0, 0, 60/2]) cylinder(r=nutRad, h=nutHeight+0.1, $fn=6);
        }
    }
}


// Make a mold for making an oogoo foot around the M5 nut heads.
module foot_negative() {
    rotate([0, 90, 0]) {
        // Nut trap to stop the bolt from being pushed out. Two half height nuts.
        translate([0, 0, -1]) cylinder(r = nutRad + 0.75, h = 5.5, center = true, $fn=16);
        // actual bolt shaft
        polyhole(r = boltRad, h = 20, center = true);
        // show actual bolt head shape
        translate([0, 0, 10]) cylinder(r1 = 5, r2 = 2.5, h = 2.7, center = false);
        // This is the rubber around the head
        translate([0, 0, 11]) {
            scale([1, 1, 0.5])  sphere(r = 6.5);
        } 
    }
}

module foot_mold() {
    height = 8;
    for (m = [0, 1])
        mirror([m, 0, 0])
            translate([5, 0, 0])
            difference() {
            translate([0, -10, 0])  cube([25, 65, height], center = false);
            for (i = [0:3]) {
          #      translate([7, i*15, height]) foot_negative();
            }
    }
}

module modified_base() {
    difference() {
        union() {
            rotate([0,0,180]) import("orig/BottomR.stl");
            for(i = [0:len(tent_positions)-1]) {
                tent_support(tent_positions[i]);
            }
        }
        // Hole to access reset microswitch
        #translate([40, 55.38, wall_thickness]) {
            cube([14, 6, 6], center = false);
            translate([8, 0, 1])  cube([2, 10, 4], center = false);
        }
    }
}

//mirror([1, 0, 0])
modified_base();

//micro_usb_bracket();

//foot_mold();

// Requires my utility functions in your OpenSCAD lib or as local submodule
// https://github.com/Lenbok/scad-lenbok-utils.git
use<utils.scad>