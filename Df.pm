package Filesys::Df;

use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

require 5.003;
use Filesys::Statvfs;
use Carp;
require Exporter;

@ISA = qw(Exporter);
@EXPORT = qw(df);
$VERSION = '0.46';

sub df {
my ($dir, $block_size)=@_;
my ($per, $user_used, $user_blocks);
my ($fper, $user_fused, $user_files);
my $h_ref={};
my $result=0;

	($dir) ||
		(croak "Usage: df\(\$dir\) or df\(\$dir\, \$block_size)");

	(-d $dir) ||
		(return());

	$block_size=1024 unless($block_size); 

        my ($bsize, $frsize, $blocks, $bfree,
        $bavail, $files, $ffree, $favail)=statvfs($dir);

	return if(! defined($blocks));

	####Return info in 1k blocks or specified size
        if($block_size > $frsize) {
                $result=$block_size/$frsize;
                $blocks=$blocks/$result;
                $bfree=$bfree/$result;
                $bavail=$bavail/$result;
        }

        elsif($block_size < $frsize) {
                $result=$frsize/$block_size;
                $blocks=$blocks*$result;
                $bfree=$bfree*$result;
                $bavail=$bavail*$result;
        }

        my $used=$blocks-$bfree;
	####There is a reserved amount for the su
        if($bfree != $bavail) {
                my $diff=$bfree-$bavail;
                $user_blocks=$blocks-$diff;
                $user_used=$user_blocks-$bavail;
		if($bavail >= 0) {
                	$per=$user_used/$user_blocks;
		}

		####over 100%
		else {
			my $tmp_bavail=$bavail;
			$tmp_bavail*=-1; 
                	$per=$tmp_bavail/$user_blocks;
		}
        }
	
	####su and user amount are the same
        else {
                $per=$used/$blocks;
		$user_blocks=$blocks;
		$user_used=$used;
        }

	#### round 
        $per*=100;
        $per+=.5;

	#### over 100%
	$per+=100 if($bfree != $bavail && $bavail < 0);

	#### Inodes
        my $fused=$files-$ffree;
	if($files >= 0) {	
	 	####There is a reserved amount for the su
        	if($ffree != $favail) {
                	my $diff=$ffree-$favail;
                	$user_files=$files-$diff;
                	$user_fused=$user_files-$favail;
			if($favail >= 0) {
               			$fper=$user_fused/$user_files;
			}

			## Over 100%
			else {
                		my $tmp_favail=$favail;
                		$tmp_favail*=-1;
                		$fper=$tmp_favail/$user_files;
			}
		}

        	####su and user amount are the same
		else {
                	$fper=$fused/$files;
			$user_files=$files;
			$user_fused=$fused;
		}

		#### round 
        	$fper*=100;
        	$fper+=.5;

		#### over 100%
		$fper+=100 if($ffree != $favail && $favail < 0);
        }

	####Probably an NFS mount no inode info
	else {
		$fper=-1;
		$fused=-1;
		$user_fused=-1;
		$user_files=-1;
	}

        ($h_ref->{per})=($per=~/(\d+)\./);
        $h_ref->{su_blocks}=$blocks;
        $h_ref->{su_bavail}=$bfree;
        $h_ref->{su_used}=$used;
        $h_ref->{user_blocks}=$user_blocks;
        $h_ref->{user_used}=$user_used;
        $h_ref->{user_bavail}=$bavail;
        $h_ref->{blocks}=$blocks;
        $h_ref->{bavail}=$bavail;
        $h_ref->{bfree}=$bfree;
        $h_ref->{used}=$used;

        ($h_ref->{fper})=($fper=~/(\d+)\./);
        $h_ref->{su_files}=$files;
        $h_ref->{su_favail}=$ffree;
        $h_ref->{su_fused}=$fused;
        $h_ref->{user_files}=$user_files;
        $h_ref->{user_favail}=$favail;
        $h_ref->{user_fused}=$user_fused;
        $h_ref->{files}=$files;
        $h_ref->{ffree}=$ffree;
        $h_ref->{favail}=$favail;
        $h_ref->{fused}=$fused;
        return($h_ref);
}

1;

__END__

=head1 NAME

Filesys::Df - Perl extension for obtaining file system stats.

=head1 SYNOPSIS


  use Filesys::Df;
  $ref=df("/tmp", 512); #Display output in 512k blocks
  print"Percent Full: $ref->{per}\n";
  print"Superuser Blocks: $ref->{blocks}\n";
  print"Superuser Blocks Available: $ref->{bfree}\n";
  print"User Blocks: $ref->{user_blocks}\n";
  print"User Blocks Available: $ref->{bavail}\n";
  print"Blocks Used: $ref->{used}\n";


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

=head1 SEE ALSO

statvfs(2), df(1M), bdf(1M)

perl(1).

=cut
