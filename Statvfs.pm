package Filesys::Statvfs;

use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

require Exporter;
require DynaLoader;

@ISA = qw(Exporter DynaLoader);
@EXPORT = qw(statvfs);
$VERSION = '0.68';
bootstrap Filesys::Statvfs $VERSION;

1;
__END__

=head1 NAME

Filesys::Statvfs - Perl extension for statvfs().

=head1 SYNOPSIS

  use Filesys::Statvfs;

	my($bsize, $frsize, $blocks, $bfree, $bavail,
	$files, $ffree, $favail, $fsid, $basetype, $flag,
	$namemax, $fstr) = statvfs("/tmp");

	##### On HP-UX 10x systems f_time and f_size are avaliable

	($bsize, $frsize, $blocks, $bfree, $bavail,
	$files, $ffree, $favail, $fsid, $basetype, $flag,
	$namemax, $fstr, $size, $time) = statvfs("/tmp");



=head1 DESCRIPTION

Interface for statvfs();

The statvfs() function will return a list
of values or will return undef and 
set $! if there was an error.

The values returned are described in the statvfs header or
the statvfs() man page.

Note:
On Digital Unix $fstr will be NULL.

$size and $time are only returned on HP-UX systems.

=head1 AUTHOR

Ian Guthrie
IGuthrie@aol.com

Copyright (c) 1998 Ian Guthrie. All rights reserved.
               This program is free software; you can redistribute it and/or
               modify it under the same terms as Perl itself.

=head1 SEE ALSO

statvfs(2), df(1M)

=cut
