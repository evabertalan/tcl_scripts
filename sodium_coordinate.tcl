# Measures the distance between the starting coordinate of the sodium ion and the middle point of the binding pocket along its trajectory
#execute: vmd -dispdev text -e water_near_residue.tcl -args CODE FILELIST SOD_RESID sod_x sod_y sod_z > sodium_coordinate_log.out
# e.g: CODE = 6b73B
# e.g: FILELIST = 
# e.g: SOD_RESID = 50
# coordinates of the sodium binding atoms
# e.g: ser = -4.959457 SER OG
# e.g: asp = -6.712894 ASP OD2
# e.g: asn = -3.926964 ASN 0

set code [lindex $argv 0]
set files [lindex $argv 1]
set filelist [split [lindex $files 0]]
set resid [lindex $argv 2]
set ser [lindex $argv 3]
set asp [lindex $argv 4]
set asn [lindex $argv 5]

set nf [llength $filelist]
set selection "resname SOD and resid $resid"

mol new ../../$code/results/step5_assembly.xplor_ext.psf type psf
mol off top
set first_frame 0
set last_frame -1

for { set i 0 } { $i <= $nf } { incr i } {
    puts [lindex $filelist $i]
    set file_name [lindex $filelist $i]
    set crnt_file [glob $file_name-pbc.dcd]

    animate read dcd $crnt_file beg 0 end -1 waitfor all

    set num_steps [molinfo top get numframes]
        
    #set out_file $crnt_file-warter_count.txt
    set out_file $file_name-sodium_coord.txt
    
    set fid [open $out_file w]

    for {set frame 0} {$frame < $num_steps} {incr frame} {
        puts "Frame: $frame"
        set a [atomselect top $selection frame $frame]
        set sod_center [measure center $a]

        set pocket [atomselect top "(resname ASN and resid $asn and name O) or (resname ASP and resid $asp and name OD2) or (resname SER and resid $ser and name OG)" frame $frame]
        set pocket_center [measure center $pocket]
        
        puts $sod_center
        puts $pocket_center
        
        set dist [vecdist $sod_center $pocket_center]
        
        puts $fid "$frame $sod_center $dist"
        $a delete
    }
    #Close written files
    close $fid

    #set first_frame [expr {$first_frame + $num_steps}]
    animate delete all
}


puts "Done"
quit