# cran2crux Makefile

PREFIX ?= /usr
LIBDIR ?= $(PREFIX)/lib/cran2crux
BINDIR ?= $(PREFIX)/bin
ETCDIR ?= /etc
MANDIR ?= $(PREFIX)/share/man

# DESTDIR is used by packaging systems
DESTDIR ?=

.PHONY: all install uninstall clean

all:
	@echo "Nothing to build. Run 'make install'."

install:
	install -Dm644 cran2crux.conf "$(DESTDIR)$(ETCDIR)/cran2crux.conf"
	install -Dm755 cran2crux      "$(DESTDIR)$(BINDIR)/cran2crux"
	install -Dm644 cran2pkgfile.R "$(DESTDIR)$(LIBDIR)/cran2pkgfile.R"
	install -Dm644 old2new.R      "$(DESTDIR)$(LIBDIR)/old2new.R"
	install -Dm644 repos2db.R     "$(DESTDIR)$(LIBDIR)/repos2db.R"
	install -Dm644 cran2crux.1    "$(DESTDIR)$(MANDIR)/man1/cran2crux.1"
	gzip -9 -f "$(DESTDIR)$(MANDIR)/man1/cran2crux.1"

uninstall:
	rm -f "$(DESTDIR)$(ETCDIR)/cran2crux.conf"
	rm -f "$(DESTDIR)$(BINDIR)/cran2crux"
	rm -f "$(DESTDIR)$(LIBDIR)/cran2pkgfile.R"
	rm -f "$(DESTDIR)$(LIBDIR)/old2new.R"
	rm -f "$(DESTDIR)$(LIBDIR)/repos2db.R"
	rm -f "$(DESTDIR)$(MANDIR)/man1/cran2crux.1.gz"

clean:
	@echo "Nothing to clean."
