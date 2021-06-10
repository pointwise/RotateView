#############################################################################
#
# (C) 2021 Cadence Design Systems, Inc. All rights reserved worldwide.
#
# This sample script is not supported by Cadence Design Systems, Inc.
# It is provided freely for demonstration purposes only.
# SEE THE WARRANTY DISCLAIMER AT THE BOTTOM OF THIS FILE.
#
#############################################################################
#_____________________________________________________________#
#
# A Pointwise Glyph script which rotates current view by specified 
# rotation angles. 
# Operation:
#   - Specifiy rotation angles about each axis
#   - Enable/Disable animation with the "Animate Rotation" checkbox
#   - Click "Rotate" to execute
#   - Click "Done" to exit
# Additional notes:
#   - Click one of three isometric views to quickly rotate
#   - Click "Reset" to reset the view
#_____________________________________________________________#

# Load Glyph and TK modules
package require PWI_Glyph
pw::Script loadTK

# Save the current view
set currView [pw::Display getCurrentView]


############################################################################
# Rotate the View
############################################################################
proc RotateView {angles} {
    
    global sec infoMessage
    set infoMessage "Specify rotation angles or isometric view."

    set angleX [lindex $angles 0]
    set angleY [lindex $angles 1]
    set angleZ [lindex $angles 2]
   
    # Return x,y,z quaternions
    # For more information regarding quaternions visit
    # http://www.pointwise.com/glyph2/files/GgTclTools/cxx/GgQuaternionInterface-cxx.html 
    set xQuaternion [pwu::Quaternion set {1 0 0} $angleX]
    set yQuaternion [pwu::Quaternion set {0 1 0} $angleY]
    set zQuaternion [pwu::Quaternion set {0 0 1} $angleZ]
    
    set currView       [pw::Display getCurrentView]   
    set currQuaternion [pwu::Quaternion set [lindex $currView 2] [lindex $currView 3]]
        
    # Rotate current quaternion by 3 provided angles; x,y,z sequence
    set fullQuaternion [pwu::Quaternion rotate \
                       [pwu::Quaternion rotate \
                       [pwu::Quaternion rotate $zQuaternion $yQuaternion] $xQuaternion] $currQuaternion];
    
    # Specify the new view   
    set rotAxis  [pwu::Quaternion axis $fullQuaternion]
    set rotAngle [pwu::Quaternion angle $fullQuaternion]
    set view     [lreplace $currView 2 3 $rotAxis $rotAngle]
    pw::Display setCurrentView -animate $sec $view
    
}


############################################################################
# Isometric View Reset
############################################################################
proc IsoViewReset {direction} {

    global currView
    
    # Define quaternion for x,y,z axis
    if {$direction eq "X"} {
        set quaternion [pwu::Quaternion set {0 -1 0} 90]
    } elseif {$direction eq "Y"} {
        set quaternion [pwu::Quaternion set "0 [expr {1/sqrt(2.0)}] [expr {1/sqrt(2.0)}]" 180]
    } else {
        set quaternion [pwu::Quaternion set {0 0 0} 0]
    }
   
    # Set view prior to isometric rotation 
    set axis  [pwu::Quaternion axis $quaternion]
    set angle [pwu::Quaternion angle $quaternion]
    set view  [lreplace $currView 2 3 $axis $angle]   
    pw::Display setCurrentView $view

}

############################################################################
# Reset the View
############################################################################
proc ResetView {} {
    
    global sec infoMessage currView
    set infoMessage "Specify rotation angles or isometric view."

    # Reset the view to what it was before running the script
    pw::Display setCurrentView -animate $sec $currView
    
}


############################################################################
# TK GUI
############################################################################
wm title . "Rotate View"
grid [ttk::frame .f -padding "5 5 5 5"] -column 0 -row 0 -sticky nwes
grid columnconfigure . 0 -weight 1
grid rowconfigure    . 0 -weight 1

lappend infoMessages "Specify rotation angles or isometric view."
set infoMessage [join $infoMessages]

set r 1

grid [tk::message .f.m -textvariable infoMessage -background beige -bd 2 \
        -relief sunken -padx 5 -pady 5 -justify center -width 250] \
        -column 0 -row $r -columnspan 6 -sticky ew; incr r

grid [ttk::separator .f.s0 -orient horizontal] -column 0 -row $r -columnspan 6 -sticky ew; incr r

set labelWidth  2; set entryWidth 7
set butWidSmall 10; set butWidBig 40

set sec 0
set angleX  0; set angleY  0; set angleZ  0; 

grid [ttk::label .f.xAngl -text "X:" -width $labelWidth -anchor e] -column 0 -row $r -sticky e 
grid [tk::entry  .f.xAng -width $entryWidth -textvariable angleX] -column 1 -row $r -sticky e

grid [ttk::label .f.yAngl -text "Y:" -width $labelWidth -anchor e] -column 2 -row $r -sticky w
grid [tk::entry  .f.yAng -width $entryWidth -textvariable angleY] -column 3 -row $r -sticky e

grid [ttk::label .f.zAngl -text "Z:" -width $labelWidth -anchor e] -column 4 -row $r -sticky w
grid [tk::entry  .f.zAng -width $entryWidth -textvariable angleZ] -column 5 -row $r -sticky e; incr r

grid [ttk::separator .f.s1 -orient horizontal] -column 0 -row $r -columnspan 6 -sticky ew; incr r

# Isometric views
set xIsoCommand {IsoViewReset X; RotateView [list 0 45 35.264]}
set yIsoCommand {IsoViewReset Y; RotateView [list 35.264 0 45]}
set zIsoCommand {IsoViewReset Z; RotateView [list 35.264 45 0]}

grid [ttk::button .f.zy -text "X-Iso" -width $butWidSmall -command $xIsoCommand] -column 0 -row $r -columnspan 2 -sticky w
grid [ttk::button .f.xz -text "Y-Iso" -width $butWidSmall -command $yIsoCommand] -column 2 -row $r -columnspan 2 -sticky w
grid [ttk::button .f.xy -text "Z-Iso" -width $butWidSmall -command $zIsoCommand] -column 4 -row $r -columnspan 2 -sticky w; incr r

grid [ttk::separator .f.s2 -orient horizontal] -column 0 -row $r -columnspan 6 -sticky ew; incr r

grid [tk::checkbutton .f.chk1 -text "Animate Rotation" -command {set sec $chk1}] -column 0 -row $r -columnspan 4 -sticky w; incr r

grid [ttk::separator .f.s3 -orient horizontal] -column 0 -row $r -columnspan 6 -sticky ew; incr r

set rotateCommand {RotateView [list $angleX $angleY $angleZ]}

grid [ttk::button .f.ab -text "Rotate" -width $butWidSmall -command $rotateCommand] -column 0 -row $r -columnspan 2 -sticky w
grid [ttk::button .f.rb -text "Reset" -width $butWidSmall -command {ResetView} ] -column 2 -row $r -columnspan 2 
grid [ttk::button .f.db -text "Done" -width $butWidSmall -command {exit} ] -column 4 -row $r -columnspan 2 -sticky e

# Hotkeys
bind all <Control-x>       $xIsoCommand
bind all <Control-y>       $yIsoCommand
bind all <Control-z>       $zIsoCommand
bind all <KeyPress-Return> $rotateCommand
bind all <Control-r>       {ResetView}
bind all <KeyPress-Escape> {exit}

foreach w [winfo children .f] {grid configure $w -padx 5 -pady 5}

#::tk::PlaceWindow . widget to center window
# Place window off to the side
set height [winfo screenheight .]
set width  [winfo screenwidth  .]

set x [expr {$width/4}]
set y [expr {$height/3}]

wm geometry . +$x+$y
wm resizable . 0 0
focus -force .


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
            set infoMessage "Enter X-axis rotation angle."
        } else {
            $widget configure -background #EBAD99
            set infoMessage "Angle must be within \[-360, 360\]"
        }
    }

    # Y-axis Angle
    if {$widget == ".f.yAng"} {
        if {[llength $val] == 1 && [string is double -strict $val] && $val >= -360.0 && $val <= 360.0} {
            $widget configure -background white
            set infoMessage "Enter Y-axis rotation angle."
        } else {
            $widget configure -background #EBAD99
            set infoMessage "Angle must be within \[-360, 360\]"
        }
    }

    # Z-axis Angle
    if {$widget == ".f.zAng"} {
        if {[llength $val] == 1 && [string is double -strict $val] && $val >= -360.0 && $val <= 360.0} {
            $widget configure -background white
            set infoMessage "Enter Z-axis rotation angle."
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


# END_OF_SCRIPT

#############################################################################
#
# This file is licensed under the Cadence Public License Version 1.0 (the
# "License"), a copy of which is found in the included file named "LICENSE",
# and is distributed "AS IS." TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE
# LAW, CADENCE DISCLAIMS ALL WARRANTIES AND IN NO EVENT SHALL BE LIABLE TO
# ANY PARTY FOR ANY DAMAGES ARISING OUT OF OR RELATING TO USE OF THIS FILE.
# Please see the License for the full text of applicable terms.
#
#############################################################################
