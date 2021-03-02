# Wraps all atoms into one periodic image
# execute: vmd -dispdev text -e pbc.tcl -args PSF FILELIST TARGET_DCD> pbc_log.out 
# e.g: vmd  -dispdev text -e pbc.tcl -args $psf $filelist $traget_dcd > pbc_log.out
# PSF = '/9cis/dcdfiles/read_protein_membrane_8x.psf'
# FILELIST = {'/Volumes/back_up/new_dcd/9cis/dcdfiles/eq_jsr_9cis_wt_n20.dcd /Volumes/back_up/new_dcd/9cis/dcdfiles/eq_jsr_9cis_wt_n21.dcd'}
# TARGET_DCD = '/JSR1/9cis/dcd_wrap/' path to the folder where to save wrapped dcd

package require pbctools
set psf [lindex $argv 0]
set files [lindex $argv 1]
set filelist [split [lindex $files 0]]
set target_f [lindex $argv 2]

mol new $psf type psf
mol off top
set sel [atomselect top all]
set nf [llength $filelist]

for { set i 0 } { $i <= $nf } { incr i } {
    set current_file [lindex $filelist $i]
    puts current_file
    set out_file $target_f$i-pbc.dcd
    
    set fid [open $out_file w]

    animate read dcd $current_file beg 0 end -1 waitfor all
    pbc wrap -all -compound res -center com -centersel protein 

    animate write dcd $out_file
    close $fid
    animate delete all
}
puts 'DONE'
quit 
