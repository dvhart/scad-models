/*
 * Group Collar Insert Gen 1
 *
 * An experimental model of an espresso machine group collar insert inspired by
 * the Breville (r) line of espresso machines.
 *
 * Copyright (c) 2018, Darren Hart <darren@dvhart.com>
 * All rights reserved.
 *
 * License: BSD-2-Clause
 */

//model_ver="v0.4";

// General geometry parameters
frag_a=1;           // affects number of sides on larger rotations
frag_s=1;           // affects number of sides on alignment pins
bbox_w=100;         // bounding box width (very generous) used for block and plane ops

// Model dimensions
cone_h=17;          // total height of cone
cone_b=3.3;         // bottom of the cone not counting the ramps
// FIXME: New measurement: 86.5
cone_od_max=86;     // top of inner cone
cone_od_min=83.5;   // bottom of inner cone
// FIXME: 2.5 at cone_h and 1.9 at cone_b
cone_wall=2.6;      // wall thickness of principle cone
cone_id_max=cone_od_max-2*cone_wall;
cone_id_min=cone_od_min-2*cone_wall;

ramp_w=6.3;
ramp_id=cone_od_min-ramp_w*2;
ramp_grade=4;       // ramp grade in degrees (steepness)
ramp_arc=109;       // ramp arc in degrees (length)
ramp_wall=3.0;
ramp_wall_a=5;
ramp_wall_arc=ramp_arc-ramp_wall_a+1;
ramp_wall_id_max=cone_od_max-2*ramp_wall;
ramp_wall_id_min=cone_od_min-2*ramp_wall;

pin_d=2.7;          // alignment pin diameter
pin_h=2;
pin1_a=35;
pin2_a=80;

stop_h=10.6;
stop_arc=11;
stop_relief_a=111;
stop_relief_arc=7.5;
stop_relief_h=10.6;

// Construction modules
module block(h1, h2=0) {
    translate([-bbox_w/2, -bbox_w/2, -h2]) cube(size=[bbox_w, bbox_w, h1+h2]);
}

// Model component modules
module pin(z=0) {
    // -x rotation counteracts ramp angle rotation (pins are vertical)
    rotate([-ramp_grade,0,z]) translate([38.5,0,-1.5]) {
        cylinder(h=pin_h, d=pin_d, $fa=frag_a, $fs=frag_s);
    }
}

module stop_relief(z=0) {
    rotate([0,0,z+stop_relief_a]) {
        rotate_extrude(angle=stop_relief_arc, $fa=frag_a) {
            // h is 10.6 here by chance, not because it should be stop_h
            translate([cone_od_min/2-ramp_w+2,0,0]) square(size=[ramp_w+3,stop_relief_h]);
        }
    }
}

module ramp(z=0) {
    rotate([0,0,z]) {
        // this is innacurate and ugly, we need a follow-path library
        // maybe: https://www.thingiverse.com/thing:186660
        // ref from: https://github.com/openscad/openscad/issues/114
        difference() {
            rotate([ramp_grade,0,0]) {
                // ramp
                rotate_extrude(angle=ramp_arc, $fa=frag_a) {
                    translate([ramp_id/2,0,0]) square(size=[ramp_w+1,4.5]);
                }
                // stop
                rotate([0,0,ramp_arc]) difference() {
                    rotate_extrude(angle=stop_arc, $fa=frag_a) {
                        translate([ramp_id/2,0,0]) square(size=[ramp_w+1,stop_h]);
                    }
                    // add the version
                    //translate([ramp_id/2+.25,2,1]) rotate([0,-90,0]) {
                    //    linear_extrude(1) text(model_ver, size=3);
                    //}
                    // bevel the top interior corner of the stop
                    translate([0,0,stop_h-1.5]) cylinder(3, d2=ramp_id+4,d1=ramp_id-2, $fa=frag_a);
                }

                // alignment pins
                pin(pin1_a);
                pin(pin2_a);
            }
            // bevel the start of the ramp
            translate([42,0,0]) rotate([0,0,67.5]) translate([-10,0,0]) cube(10);
            translate([42,0,0]) rotate([0,50,67.5]) translate([-12.3,3.1,0]) cube(10);
        }

        // Thicker walls above ramps
        difference() {
            union() {
                intersection() {
                    // outer cone
                    cylinder(h=cone_h, d2=cone_od_max, d1=cone_od_min, $fa=frag_a);
                    rotate([0,0,ramp_wall_a]) rotate_extrude(angle=ramp_wall_arc) square(50);
                }
                // fade into the outer wall
                rotate([0,0,ramp_wall_a]) translate([38.8,-15,0]) rotate([0,4.2,.25]) cube(15);
            }
            // remove the inner cone
            cylinder(cone_h, d2=ramp_wall_id_max, d1=ramp_wall_id_min, $fa=frag_a);
            // trim the top
            translate([-50,-50,13]) cube(100);
            // bevel the top of the ramp wall
            translate([0,0,13-1]) cylinder(1.4, d2=cone_id_max, d1=cone_id_max-2, $fa=frag_a);
            // trim the bottom
            block(cone_b, 1);
        }
    }
}

intersection() {
    union() {
        // Main block minus inner cone
        difference() {
            block(cone_h);
            cylinder(cone_h, d2=cone_id_max, d1=cone_id_min, $fa=frag_a);
            // eliminate the shared plane shearing effect in preview (no affect on final model)
            translate([0,0,cone_h-.5]) cylinder(1, d=cone_id_max-.1, $fa=frag_a);
            // Cut off the bottom before adding the ramps
            // FIXME: This should go from 3.2 at 120deg to 3.4 at 180deg
            block(cone_b, 1);
        }
        // Ramps
        ramp(0);
        ramp(180);
    }
    difference() {
        // Outer funnel
        cylinder(h=cone_h, d2=cone_od_max, d1=cone_od_min, $fa=frag_a);
        // Stop reliefs (alignment)
        stop_relief(0);
        stop_relief(180);
    }
}

echo(version=version());

