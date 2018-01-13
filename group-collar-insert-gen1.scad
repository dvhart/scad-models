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

frag_a=1; // affects number of sides on larger rotations
frag_s=1; // affects number of sides on alignment pins
wall=2.6;
rwall=3.0;
ramp=6.3;
ramp_a=4;
pin=2.7;

// Modules
module stop_relief(z=0) {
    rotate([0,0,z+111]) {
        rotate_extrude(angle=7.5, $fa=frag_a) {
            translate([83.5/2-ramp+2,0,0]) square(size=[ramp+3,10.6]);
        }
    }
}

module ramp(z=0) {
    rotate([0,0,z]) {
        // this is innacurate and ugly, we need a follow-path library
        // maybe: https://www.thingiverse.com/thing:186660
        // ref from: https://github.com/openscad/openscad/issues/114
        difference() {
            rotate([ramp_a,0,0]) {
                // ramp
                rotate_extrude(angle=109, $fa=frag_a) {
                    translate([83.5/2-6.3,0,0]) square(size=[ramp+1,4.5]);
                }
                // stop
                rotate([0,0,109]) {
                    rotate_extrude(angle=11, $fa=frag_a) {
                        translate([83.5/2-ramp,0,0]) square(size=[ramp+1,10.6]);
                    }
                }                
                // alignment pins
                // x rotation counteracts ramp angle rotation (pins are vertical)
                rotate([-ramp_a,0,35]) translate([38.5,0,-1.5]) cylinder(h=2, d=pin, $fa=frag_a, $fs=frag_s);
                rotate([-ramp_a,0,80]) translate([38.5,0,-1.5]) cylinder(h=2, d=pin, $fa=frag_a, $fs=frag_s);
            }
            // trim the beginning to be vertical (after the rotation)
            translate([0,-50,0]) cube(50);
        }

        // Thicker walls above ramps
        // FIXME: These should smooth into the wall from where they start through 7deg back 
        intersection() {
            difference() {
                cylinder(h=17, d2=86.00, d1=83.5, $fa=frag_a);
                cylinder(h=40, d2=86.00-2*rwall, d1=83.5-2*rwall, $fa=frag_a, center=true);
                translate([0,0,13]) cylinder(h=5, d=90);
                cube(size=[100, 100, 3.3*2], center=true);
            }
            union() {
                rotate_extrude(angle=110) square(50);
            }
        }
    }
}


intersection() {
    union() {
        // Main block minus inner cone
        difference() {
            translate([-50,-50,0]) cube(size=[100, 100, 17]);
            cylinder(h=40, d2=86.00-2*wall, d1=83.5-2*wall, $fa=frag_a, center=true);
            // Cut off the bottom before adding the ramps
            // This should go from 3.2 at 120deg to 3.4 at 180deg
            // FIXME: also needs follow-path library
            cube(size=[100, 100, 3.3*2], center=true);
        }
        // Ramps
        ramp(0);
        ramp(180);
    }
    difference() {
        // Outer funnel
        cylinder(h=17, d2=86.00, d1=83.5, $fa=frag_a);
        // Stop reliefs (alignment)
        stop_relief(0);
        stop_relief(180);
    }
}

echo(version=version());

