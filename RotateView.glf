#
# Copyright 2016 (c) Pointwise, Inc.
# All rights reserved.
# 
# 
# This sample script is not supported by Pointwise, Inc.
# It is provided freely for demonstration purposes only.  
# SEE THE WARRANTY DISCLAIMER AT THE BOTTOM OF THIS FILE.
#_____________________________________________________________#
#
#************************ Brief Description ************************* #
# A Pointwise Glyph script which rotates current view by specified 
# rotation angles. 
# Operation:
#   - Specifiy rotation angles about each axis
#   - Enable/Disable rotation animation with the "Animate" checkbox
#   - Click "Rotate" to execute
#   - Click "Done" to exit
#_____________________________________________________________#

# Load Glyph and TK modules
package require PWI_Glyph
pw::Script loadTK

############################################################################
# TK GUI
############################################################################
wm title . "Rotate View"
grid [ttk::frame .f -padding "5 5 5 5"] -column 0 -row 0 -sticky nwes
grid columnconfigure . 0 -weight 1
grid rowconfigure    . 0 -weight 1

lappend infoMessages "Specify Rotation Angles"
set infoMessage [join $infoMessages]

set r 1; # row count

grid [tk::message .f.m -textvariable infoMessage -background beige -bd 2 \
        -relief sunken -padx 5 -pady 5 -anchor w -justify left -width 250] \
        -column 0 -row $r -columnspan 2 -sticky ew; incr r

grid [ttk::separator .f.s -orient horizontal] -column 0 -row $r -columnspan 2 -sticky ew; incr r

set labelWidth  20; set entryWidth  10
set butWidSmall 10; set butWidBig   40

set sec 0
set angleX  0.00; set angleY  0.00; set angleZ  0.00; 

grid [ttk::label .f.xAng1 -text "X-axis angle" -width $labelWidth] -column 0 -row $r -sticky w
grid [tk::entry  .f.xAng -width $entryWidth -textvariable angleX] -column 1 -row $r -sticky e; incr r

grid [ttk::label .f.yAng1 -text "Y-axis angle" -width $labelWidth] -column 0 -row $r -sticky w
grid [tk::entry  .f.yAng -width $entryWidth -textvariable angleY] -column 1 -row $r -sticky e; incr r

grid [ttk::label .f.zAng1 -text "Z-axis angle" -width $labelWidth] -column 0 -row $r -sticky w
grid [tk::entry  .f.zAng -width $entryWidth -textvariable angleZ] -column 1 -row $r -sticky e; incr r

grid [tk::checkbutton .f.chk1 -text "Animate" -command {set sec $chk1}] -column 0 -row $r -sticky w; incr r

grid [ttk::button .f.ab -text "Rotate" -width $butWidSmall -command {RotateView} ] -column 0 -row $r -sticky e

grid [ttk::button .f.db -text "Done"   -width $butWidSmall -command {exit} ] -column 1 -row $r -sticky e

bind all <KeyPress-Return> {RotateView}; bind all <KeyPress-Escape> {exit};

foreach w [winfo children .f] {grid configure $w -padx 5 -pady 5}

::tk::PlaceWindow . widget
wm resizable . 0 0


############################################################################
# Update Button and Entry States
############################################################################
proc UpdateStates {} {

    if [ColorCheck] {
        .f.ab   configure -state enabled
    } else {
        .f.ab   configure -state disabled
    }
    
}


############################################################################
# Check Entry Color
############################################################################
proc ColorCheck {} {

    set test 0

    if {![string equal [.f.xAng cget -background] #EBAD99]} {incr test}
    if {![string equal [.f.yAng cget -background] #EBAD99]} {incr test}
    if {![string equal [.f.zAng cget -background] #EBAD99]} {incr test}
    
    # Only passes if all entry boxes are not red
    if {$test == 3} {
        return true
    } else {
        return false
    }

}


############################################################################
# Real Time Parameter Validation
############################################################################
proc ValidateParams {val widget} {

    global infoMessage
    
    # X-axis Angle
    if {$widget == ".f.xAng"} {
        if {[llength $val] == 1 && [string is double -strict $val] && $val >= -360.0 && $val <= 360.0} {
            $widget configure -background white
            set infoMessage "Enter X-axis rotation angle"
        } else {
            $widget configure -background #EBAD99
            set infoMessage "Angle must be within \[-360, 360\]"
        }
    }

    # Y-axis Angle
    if {$widget == ".f.yAng"} {
        if {[llength $val] == 1 && [string is double -strict $val] && $val >= -360.0 && $val <= 360.0} {
            $widget configure -background white
            set infoMessage "Enter Y-axis rotation angle"
        } else {
            $widget configure -background #EBAD99
            set infoMessage "Angle must be within \[-360, 360\]"
        }
    }

    # Z-axis Angle
    if {$widget == ".f.zAng"} {
        if {[llength $val] == 1 && [string is double -strict $val] && $val >= -360.0 && $val <= 360.0} {
            $widget configure -background white
            set infoMessage "Enter Z-axis rotation angle"
        } else {
            $widget configure -background #EBAD99
            set infoMessage "Angle must be within \[-360, 360\]"
        }
    }

    UpdateStates
    return true

} 


############################################################################
# Startup GUI Configuration
############################################################################
# Label/Button states
.f.xAng configure -state normal
.f.yAng configure -state normal
.f.zAng configure -state normal
.f.db   configure -state enabled    
.f.chk1 invoke
    
# Validate entry field values
.f.xAng configure -validate all -vcmd {ValidateParams %P %W}
.f.yAng configure -validate all -vcmd {ValidateParams %P %W}
.f.zAng configure -validate all -vcmd {ValidateParams %P %W}


############################################################################
# Rotate the View
############################################################################
proc RotateView {} {
    
    global sec angleX angleY angleZ
    
    set xQuaternion [pwu::Quaternion set {1 0 0} $angleX]
    set yQuaternion [pwu::Quaternion set {0 1 0} $angleY]
    set zQuaternion [pwu::Quaternion set {0 0 1} $angleZ]
    
    set currView [pw::Display getCurrentView]   
    set currQuaternion [pwu::Quaternion set [lindex $currView 2]  [lindex $currView 3]]
        
    # Rotate current quaternions by 3 provided angles; Quaternion: Y-X-Z_CurrentView_Quaternion
    set fullQuaternion [pwu::Quaternion rotate \
                       [pwu::Quaternion rotate \
                       [pwu::Quaternion rotate $yQuaternion $xQuaternion] $zQuaternion]  $currQuaternion];
       
    set rotAxis [pwu::Quaternion axis $fullQuaternion]
    set rotAngle [pwu::Quaternion angle $fullQuaternion]
    set view [lreplace $currView 2 3 $rotAxis $rotAngle]
    pw::Display setCurrentView -animate $sec $view
    
    unset xQuaternion yQuaternion zQuaternion currView currQuaternion fullQuaternion rotAngle rotAxis view    
    
    # Update display and script GUI
    pw::Display update
    wm state . normal
    raise .
    
}

# END_OF_SCRIPT

# DISCLAIMER:
# TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, POINTWISE DISCLAIMS
# ALL WARRANTIES, EITHER EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED
# TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE, WITH REGARD TO THIS SCRIPT.  TO THE MAXIMUM EXTENT PERMITTED 
# BY APPLICABLE LAW, IN NO EVENT SHALL POINTWISE BE LIABLE TO ANY PARTY 
# FOR ANY SPECIAL, INCIDENTAL, INDIRECT, OR CONSEQUENTIAL DAMAGES 
# WHATSOEVER (INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF 
# BUSINESS INFORMATION, OR ANY OTHER PECUNIARY LOSS) ARISING OUT OF THE 
# USE OF OR INABILITY TO USE THIS SCRIPT EVEN IF POINTWISE HAS BEEN 
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGES AND REGARDLESS OF THE 
# FAULT OR NEGLIGENCE OF POINTWISE.
#
