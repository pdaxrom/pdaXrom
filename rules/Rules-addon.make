#
# install_target
#
# Recursive installation in directory in an ipkg packet.
#
# $1: packet label
# $2: source directory
# $3: destination directory
#
install_target =								\
	XPACKET=$(strip $(1));                                                  \
	XSRC=$(strip $(2));                                                     \
	XDST=$(strip $(3));                                                     \
	for f in `find $$XSRC -printf "%P\n"`; do				\
	    if [ -L "$$XSRC/$$f" ]; then					\
		L=`readlink "$$XSRC/$$f"`;					\
		$(call install_link, $$XPACKET, "$$L", "$$XDST/$$f");		\
	    elif [ -d "$$XSRC/$$f" ]; then					\
		XMOD=`stat -c "%a" "$$XSRC/$$f"`;				\
		$(call install_copy, $$XPACKET, 0, 0, $$XMOD, "$$XDST/$$f");	\
	    else								\
		XMOD=`stat -c "%a" "$$XSRC/$$f"`;				\
		$(call install_copy, $$XPACKET, 0, 0, $$XMOD, "$$XSRC/$$f", "$$XDST/$$f"); \
	    fi;									\
	done
