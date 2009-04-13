AC_PREREQ(2.53)
AC_INIT([keyboard-tray], 0.1, [sash@pdaXrom.org])
AC_CONFIG_SRCDIR([keyboard-tray.c])

AM_INIT_AUTOMAKE()
AM_MAINTAINER_MODE
#AM_CONFIG_HEADER(config.h)

# Checks for programs.
AC_GNU_SOURCE
AC_PROG_CC
AC_HEADER_DIRENT
AC_HEADER_STDC

# Checks for typedefs, structures, and compiler characteristics.
AC_C_CONST
AC_TYPE_PID_T
AC_HEADER_TIME

PKG_CHECK_MODULES(GTK2, gtk+-2.0,, AC_MSG_ERROR([*** Required GTK2 not found ***]))

dnl ------ GCC flags --------------------------------------------------------

if test "x$GCC" = "xyes"; then
        GCC_WARNINGS="-g -Wall -fno-strict-aliasing"
        FAKEKEY_CFLAGS="$GCC_WARNINGS $FAKEKEY_CFLAGS"
fi


dnl ------ Substitute in found libs, clags to Makefiles etc -----------------

AC_OUTPUT([
Makefile
])
