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

CFLAGS="$CFLAGS -export-dynamic"
LIBS="-lXcursor"

# Checks for libraries.
pkg_modules="glib-2.0 gtk+-2.0"
PKG_CHECK_MODULES(PACKAGE, [$pkg_modules])
AC_SUBST(PACKAGE_CFLAGS)
AC_SUBST(PACKAGE_LIBS)

AC_ARG_ENABLE(
    [hal],
    AS_HELP_STRING([--enable-hal],
                   [Build with Linux HAL support for shutdown/reboot/suspend (default: yes)]),
    use_hal=$enableval, use_hal="yes")

if test x"$use_hal" = x"yes"; then
dnl Check HAL support
    hal_modules="dbus-1"
    PKG_CHECK_MODULES(HAL, [$hal_modules], [have_hal=yes], [have_hal=no])

    if test x"$have_hal" = x"yes"; then
        AC_DEFINE([HAVE_HAL], [1], [Define to 1 if you have HAL.])
    else
        AC_MSG_ERROR([To use HAL support, you must have developing packages of dbus-glib-1 (>=0.31), or you can use --disable-hal to disable HAL support.])
    fi
fi
AM_CONDITIONAL(USE_HAL, test "$use_hal" = "yes")
AC_SUBST(HAL_CFLAGS)
AC_SUBST(HAL_LIBS)

AC_OUTPUT([
  Makefile
  netconfig/Makefile
  pppconfig/Makefile
  logout/Makefile
])
