AC_PREREQ(2.53)
AC_INIT(sn-monitor, 0.1, http://www.pdaxrom.org/)
AM_INIT_AUTOMAKE
AM_MAINTAINER_MODE
AM_CONFIG_HEADER(config.h)

# Force to dynamic
AC_DISABLE_STATIC

# Checks for programs.
AC_PROG_CC
AC_PROG_INSTALL
AC_PROG_LN_S
AC_PROG_LIBTOOL

AC_PATH_XTRA

LIBS="-lXcursor"

# Checks for libraries.
pkg_modules="libstartup-notification-1.0"
PKG_CHECK_MODULES(PACKAGE, [$pkg_modules])
AC_SUBST(PACKAGE_CFLAGS)
AC_SUBST(PACKAGE_LIBS)

AC_OUTPUT([
  Makefile
])
