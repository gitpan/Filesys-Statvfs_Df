use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	=> 'Filesys::Statvfs',
    'VERSION_FROM' => 'Filesys/Statvfs.pm', # finds $VERSION
    'LIBS'	=> [''],   # e.g., '-lm' 
    'DEFINE'	=> '',     # e.g., '-DHAVE_SOMETHING' 
    'INC'	=> '',     # e.g., '-I/usr/include/other'
    'PMLIBDIRS' => [qw(Filesys)],
    'dist'      => {COMPRESS => 'gzip --best',
	            SUFFIX   => '.gz',
	            DIST_DEFAULT =>  'tardist',
	           },
);
