#%Module1.0#####################################################################
##
##  MARIO pipeline modulefile
##
##  (generated from 'templates/modulefile' on 2019-01-30)
##

set name "mario_pipeline"
set proper "MARIO pipeline"
set version "3.9.1"
set descrip "Standard analysis pipeline for NGS data"
set homepage "https://tfwebdev.research.cchmc.org/gitlab/puj6ug/MARIO_pipeline"
set issues "https://tfwebdev.research.cchmc.org/gitlab/puj6ug/MARIO_pipeline/issues"
set moduledir  "/data/weirauchlab/local/modules/$name/$version"

# module dependencies
array set prereqs {
    perl        5.28.0
    fastqc      0.11.2
    hisat2      2.0.4
    MACS        2.1.0
    picard      1.89
    cutadapt    1.8.1
    trimgalore  0.4.2
    bowtie2     2.3.4.1
    samtools    1.8.0
}

proc ModulesHelp { } {
    global proper
    global descrip
    global version
    global homepage
    global issues
    puts stderr "\t$proper\n\t  - $descrip\n"
    puts stderr "\tVersion:   $version"
    puts stderr "\tHomepage:  $homepage"
    puts stderr "\tBugs:      $issues"
    puts stderr ""
}

# the output displayed by the 'module whatis' command
module-whatis "$proper $version - $descrip"

# Add PATH, MANPATH, LD_LIBRARY_PATH, and other environment modifications here.
# Although commonly seen in modulefiles, bear in mind that altering a user's
# LD_LIBRARY_PATH can be problematic; for a thorough discussion, see
# http://linuxmafia.com/faq/Admin/ld-lib-path.html
#prepend-path --delim " " LDFLAGS "-L$moduledir/lib -Wl,-rpath=$moduledir/lib"
#prepend-path --delim " " CFLAGS "-I$moduledir/include"
#prepend-path PKG_CONFIG_PATH "$moduledir/lib/pkgconfig"
#prepend-path MANPATH "$moduledir/share/man"
#prepend-path PATH "$moduledir/bin"

prepend-path PATH "$moduledir/bin"

foreach m [array names prereqs] {
    module load "$m/$prereqs($m)"
}

# vim: ft=tcl ts=4 sw=4 expandtab
