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

frags=100;
wall=2.6;
rwall=3.0;
ramp=6.3;
ramp_a=4;
pin=2.7;

// Modules
module ramp(z=0) {
    rotate([0,0,z]) {
        // this is innacurate and ugly, we need a follow-path library
        // maybe: https://www.thingiverse.com/thing:186660
        // ref from: https://github.com/openscad/openscad/issues/114
        difference() {
            rotate([ramp_a,0,0]) {
                // ramp
                rotate_extrude(angle=106, $fn=frags) {
                    translate([83.5/2-6.3,0,0]) square(size=[ramp+1,4.5]);
                }
                // stop
                rotate([0,0,106]) {
                    rotate_extrude(angle=14, $fn=frags) {
                        translate([83.5/2-ramp,0,0]) square(size=[ramp+1,10.6]);
                    }
                }
                // alignment pins
                // x rotation counteracts ramp angle rotation (pins are vertical)
                rotate([-ramp_a,0,35]) translate([38.5,0,-1.5]) cylinder(h=2, d=pin, $fn=10);
                rotate([-ramp_a,0,80]) translate([38.5,0,-1.5]) cylinder(h=2, d=pin, $fn=10);
            }
            // trim the beginning to be vertical (after the rotation)
            translate([0,-50,0]) cube(50);
        }

        // Thicker walls above ramps
        // FIXME: These should smooth into the wall from where they start through 7deg back 
        intersection() {
            difference() {
                cylinder(h=17, d2=86.00, d1=83.5, $fn=frags);
                cylinder(h=40, d2=86.00-2*rwall, d1=83.5-2*rwall, $fn=frags, center=true);
                translate([0,0,13]) cylinder(h=5, d=90);
                cube(size=[100, 100, 3.3*2], center=true);
            }
            union() {
                rotate_extrude(angle=106) square(50);
            }
        }

    }
}


intersection() {
    union() {
        // Main block minus inner cone
        difference() {
            translate([-50,-50,0]) cube(size=[100, 100, 17]);
            cylinder(h=40, d2=86.00-2*wall, d1=83.5-2*wall, $fn=frags, center=true);
            // Cut off the bottom before adding the ramps
            // This should go from 3.2 at 120deg to 3.4 at 180deg
            // FIXME: also needs follow-path library
            cube(size=[100, 100, 3.3*2], center=true);
        }
        // Ramps
        ramp(0);
        ramp(180);
    }
    // Outer funnel
    cylinder(h=17, d2=86.00, d1=83.5, $fn=frags);
}

echo(version=version());

