package Filesys::Df;

use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

require 5.003;
use Filesys::Statvfs;
use Carp;
require Exporter;

@ISA = qw(Exporter);
@EXPORT = qw(df);
$VERSION = '0.68';

sub df {
my ($dir, $block_size) = @_;
my ($bsize, $frsize);
my $result = 0;
my %fs;

	($dir) ||
		(croak "Usage: df\(\$dir\) or df\(\$dir\, \$block_size)");

	(-d $dir) ||
		(return());

	($block_size) ||
		($block_size = 1024);

	($bsize, $frsize, $fs{blocks}, $fs{bfree},
	 $fs{bavail}, $fs{files}, $fs{ffree},
	 $fs{favail}) = statvfs($dir);

	(defined($fs{blocks})) ||
			(return());

	## If blocks is 0 then we cant return percentage and
	## other useful info. (/proc etc)
	($fs{blocks} == 0)  && 
			(return());

	####Return info in 1k blocks or specified size

	## Added for GNU lib bug 
	if($frsize != 0) {
		if($block_size > $frsize) {
			$result = $block_size / $frsize;
			$fs{blocks} /= $result;
			$fs{bfree} /= $result;
			####Keep bavail -
			($fs{bavail} < 0) &&
				($result *= -1);
			$fs{bavail} /= $result;
		}

		elsif($block_size < $frsize) {
			$result = $frsize / $block_size;
			$fs{blocks} *= $result;
			$fs{bfree} *= $result;
			####Keep bavail -
			($fs{bavail} < 0) &&
				($result *= -1);
			$fs{bavail} *= $result;
		}
	}

	$fs{used} = $fs{blocks} - $fs{bfree};
	####There is a reserved amount for the su
	if($fs{bfree} != $fs{bavail}) {
		$fs{user_blocks} = $fs{blocks} - ($fs{bfree} - $fs{bavail});
		$fs{user_used} = $fs{user_blocks} - $fs{bavail};
		if($fs{bavail} < 0) {
			#### over 100%
			my $tmp_bavail = $fs{bavail};
			$fs{per} = ($tmp_bavail *= -1) / $fs{user_blocks};
		}
	
		else {
			$fs{per} = $fs{user_used} / $fs{user_blocks};
		}
	}
	
	####su and user amount are the same
	else {
		$fs{per} = $fs{used} / $fs{blocks};
		$fs{user_blocks} = $fs{blocks};
		$fs{user_used} = $fs{used};
	}

	#### round 
	$fs{per} *= 100;
	$fs{per} += .5;

	#### over 100%
	($fs{bavail} < 0) &&
		($fs{per} += 100);

	$fs{per} = int($fs{per});

	#### Inodes
	$fs{fused} = $fs{files} - $fs{ffree};

	if($fs{files} > 0) {	
		####There is a reserved amount for the su
		if($fs{ffree} != $fs{favail}) {
			$fs{user_files} = $fs{files} - ($fs{ffree} - $fs{favail});
			$fs{user_fused} = $fs{user_files} - $fs{favail};
			if($fs{favail} < 0)  {
				#### over 100%
				my $tmp_favail = $fs{favail};
				$fs{fper} = ($tmp_favail *= -1) / $fs{user_files};
			}

			else {
				$fs{fper} = $fs{user_fused} / $fs{user_files};
			}
		}

		####su and user amount are the same
		else {
			$fs{fper} = $fs{fused}/$fs{files};
			$fs{user_files} = $fs{files};
			$fs{user_fused} = $fs{fused};
		}

		#### round 
		$fs{fper} *= 100;
		$fs{fper} += .5;

		#### over 100%
		($fs{favail} < 0) &&
			($fs{fper} += 100);
	}

	####Probably an NFS mount no inode info
	else {
		$fs{fper}       = -1;
		$fs{fused}      = -1;
		$fs{user_fused} = -1;
		$fs{user_files} = -1;
	}

	$fs{fper} = int($fs{fper});
	return(\%fs);
}

1;

__END__

=head1 NAME

Filesys::Df - Perl extension for obtaining file system stats.

=head1 SYNOPSIS


  use Filesys::Df;
  $ref = df("/tmp", 512); #Display output in 512 byte blocks
                          #Default is 1024 byte blocks.
  print"Percent Full:               $ref->{per}\n";
  print"Superuser Blocks:           $ref->{blocks}\n";
  print"Superuser Blocks Available: $ref->{bfree}\n";
  print"User Blocks:                $ref->{user_blocks}\n";
  print"User Blocks Available:      $ref->{bavail}\n";
  print"Blocks Used:                $ref->{used}\n";


=head1 DESCRIPTION

This module will produce information on the amount
disk space available to the normal user and the superuser
for any given filesystem.

It contains one function df(), which takes a directory
as the first argument and an optional second argument
which will let you specify the block size for the output.
Note that the inode values are not changed by the block size
argument. 

The return value of df() is a refrence to a hash.
The main keys of intrest in this hash are:

{per}
Percent used. This is based on what the non-superuser will have used.
(In other words, if the filesystem has 10% of its space reserved for
the superuser, then the percent used can go up to 110%.)

{blocks}
Total number of blocks on the file system.

{used}
Total number of blocks used.

{bavail}
Total number of blocks available.

{fper}
Percent of inodes used. This is based on what 
the non-superuser will have used.

{files}
Total inodes on the file system.

{fused}
Total number of inodes used.

{favail}
Inodes available.


Most filesystems have a certain amount of space
reserved that only the superuser can access.

If you wish to differentiate between the amount
of space that the normal user can access, and the
amount of space the superuser can access, you can
use these keys:

{su_blocks} or {blocks}
Total number of blocks on the file system.

{user_blocks}
Total number of blocks on the filesystem for the
non-superuser.

{su_bavail} or {bfree}
Total number of blocks available to the superuser.

{user_bavail} or {bavail}
Total number of blocks available to the non-superuser.

{su_files} or {files}
Total inodes on the file system.

{user_files}
Total number of inodes on the filesystem for the
non-superuser.

{su_favail} or {ffree}
Inodes available in file system.

{user_favail} or {favail}
Inodes available to non-superuser.

Most 'df' applications will print out the 'blocks' or 'user_blocks',
'bavail', 'used', and the percent full values. So you will probably
end up using these values the most.

If the file system does not contain a diffrential in space for
the superuser then the user_ keys will contain the same
values as the su_ keys.

If there was an error df() will return undef 
and $! will have been set.

If the blocks field returned from statvfs() is 0
then df() returns undef. This may occur if you
stat a directory such as /proc.

Requirements:
Your system must contain statvfs(). 
You must be running perl.5003 or higher.

Note:
The way the percent full is measured is based on what the
HP-UX application 'bdf' returns.  The 'bdf' application 
seems to round a bit different than 'df' does but I like
'bdf' so that is what I based the percentages on.

=head1 AUTHOR

Ian Guthrie
IGuthrie@aol.com

Copyright (c) 1998 Ian Guthrie. All rights reserved.
               This program is free software; you can redistribute it and/or
               modify it under the same terms as Perl itself.

=head1 SEE ALSO

statvfs(2), df(1M), bdf(1M)

perl(1).

=cut
