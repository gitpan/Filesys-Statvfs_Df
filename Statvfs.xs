#ifdef __cplusplus
extern "C" {
#endif
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "config.h"
#include<sys/statvfs.h>
#ifdef __cplusplus
}
#endif

typedef struct statvfs Statvfs;

MODULE = Filesys::Statvfs	PACKAGE = Filesys::Statvfs

void
statvfs(dir)
	char *dir
	PREINIT:
	Statvfs st;
	Statvfs *st_ptr;
	PPCODE:
	if(statvfs(dir, &st) == 0) {
		st_ptr=&st;
		EXTEND(sp, 15);
		PUSHs(sv_2mortal(newSViv(st_ptr->f_bsize)));
		PUSHs(sv_2mortal(newSViv(st_ptr->f_frsize)));
		PUSHs(sv_2mortal(newSViv(st_ptr->f_blocks)));
		PUSHs(sv_2mortal(newSViv(st_ptr->f_bfree)));
		PUSHs(sv_2mortal(newSViv(st_ptr->f_bavail)));
		PUSHs(sv_2mortal(newSViv(st_ptr->f_files)));
		PUSHs(sv_2mortal(newSViv(st_ptr->f_ffree)));
		PUSHs(sv_2mortal(newSViv(st_ptr->f_favail)));
#if defined(_AIX__) || defined(_LINUX__)
		PUSHs(sv_2mortal(newSViv(0)));
#else
		PUSHs(sv_2mortal(newSViv(st_ptr->f_fsid)));
#endif
#ifdef _LINUX__
		PUSHs(sv_2mortal(newSVpv(NULL, 1)));
#else
		PUSHs(sv_2mortal(newSVpv(st_ptr->f_basetype, 0)));
#endif
		PUSHs(sv_2mortal(newSViv(st_ptr->f_flag)));
		PUSHs(sv_2mortal(newSViv(st_ptr->f_namemax)));
#if defined(_DEC__) || defined(_LINUX__)
		PUSHs(sv_2mortal(newSVpv(NULL, 1)));
#else
		PUSHs(sv_2mortal(newSVpv(st_ptr->f_fstr, 0)));
#endif
#ifdef _HPUX__
		PUSHs(sv_2mortal(newSViv(st_ptr->f_size))); 
		PUSHs(sv_2mortal(newSViv(st_ptr->f_time)));
#endif
	}
