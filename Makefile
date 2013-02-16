# $Id: Makefile,v 1.3 2011/05/15 02:51:43 rok Exp rok $
#DEBUG = -g
FRAMEWORK = -framework Cocoa -framework QuartzCore
#ARCH = -arch i386 -arch ppc -arch x86_64
ARCH = -arch i386 -arch x86_64
CFALGS = $(DEBUG) $(FRAMEWORK) $(ARCH)
CC = cc $(CFLAGS) 
LDFLAGS = $(FRAMEWORK) $(ARCH) $(DEBUG)
LD = cc $(LDFLAGS)

TARGZ = unquadify.tar.gz
EXCLUDE = --exclude $(TARGZ) --exclude RCS --exclude Trush --exclude Misc

DESTDIR = /usr/local
BINDIR = $(DESTDIR)/bin
OBJ = 
PROGS = unquadify

all: $(PROGS)

install:
	mkdir -p $(BINDIR)
	install -s $(PROGS) $(BINDIR)

tar: archive
archive:        clean
	tar $(EXCLUDE) -C .. -c -v -z -f $(TARGZ) unquadify

clean:
	rm -rf $(OBJ) $(PROGS) *.bak *~ *.~
