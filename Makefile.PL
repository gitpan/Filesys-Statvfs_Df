use ExtUtils::MakeMaker;
use Config(%Config);

open(CONFIG, ">config.h") or die "$! config.h";

($Config{osname} eq "hpux") &&
        (print CONFIG "#define _HPUX__\n");

($Config{osname} eq "dec_osf") &&
        (print CONFIG "#define _DEC__\n");

close(CONFIG);

WriteMakefile(
    'NAME'	=> 'Filesys::Statvfs',
    'VERSION_FROM' => 'Statvfs.pm', # finds $VERSION
    'LIBS'	=> [''],   # e.g., '-lm' 
    'DEFINE'	=> '',     # e.g., '-DHAVE_SOMETHING' 
    'INC'	=> '',     # e.g., '-I/usr/include/other' 
);
