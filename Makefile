# Makefile for the Z80 assembler by shevek
# Copyright 2002-2007  Bas Wijnen
#
# This file is part of gbz80asm.
#
# Z80asm is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Z80asm is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

CC = gcc
CFLAGS = -O0 -Wall -Wwrite-strings -Wcast-qual -Wcast-align -Wstrict-prototypes -Wmissing-prototypes -Wmissing-declarations -Wredundant-decls -Wnested-externs -Winline -pedantic -ansi -Wshadow -ggdb3 -W
SHELL = /bin/bash
VERSION ?= $(shell echo -n `cat VERSION | cut -d. -f1`. ; echo $$[`cat VERSION | cut -d. -f2` + 1])

all: gbz80asm

gbz80asm: gbz80asm.o expressions.o Makefile
	$(CC) $(LDFLAGS) $(filter %.o,$^) -o $@
	$(MAKE) -C tests || rm $@

%.o:%.c gbz80asm.h Makefile
	$(CC) $(CFLAGS) -c $< -o $@ -DVERSION=\"$(shell cat VERSION)\"

clean:
	for i in . gnulib examples headers ; do \
		rm -f $$i/core $$i/*~ $$i/\#* $$i/*.o $$i/*.rom ; \
	done
	rm -f gbz80asm gbz80asm.exe

dist: clean
	! git status | grep modified
	echo $(VERSION) > VERSION
	git add VERSION
	-git commit -m "Release version $(VERSION)"
	rm -rf /tmp/gbz80asm-$(VERSION)
	git archive --format=tar --prefix=gbz80asm-$(VERSION)/ HEAD | tar xf - -C /tmp
	tar cvzf ../gbz80asm-$(VERSION).tar.gz -C /tmp gbz80asm-$(VERSION)
	rm -r /tmp/gbz80asm-$(VERSION)
	cd .. && gpg -b gbz80asm-$(VERSION).tar.gz
	scp ../gbz80asm-$(VERSION).tar.gz* dl.sv.nongnu.org:/releases/gbz80asm/
	git push
