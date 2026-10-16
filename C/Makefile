# GCCSDK cross build. Untested: adjust tool names to your install.
CC     = arm-unknown-riscos-gcc
CMUNGE = cmunge
# No stack checking: the blenders in blend.c run with an arbitrary R10.
CFLAGS = -O2 -std=gnu11 -Wall -Wextra -mmodule -mno-apcs-stack-check -Isrc -Ibuild

OBJS = build/DitherExtHdr.o build/main.o build/stubs.o build/colour.o build/select.o build/misc.o build/pattern.o build/screen.o build/setscreen.o build/blend.o build/antialias.o build/veneer.o build/tables_pattern.o build/tables.o

DitherExt,ffa: $(OBJS)
	$(CC) -mmodule -o $@ $(OBJS)

build/DitherExtHdr.o: cmhg/DitherExtHdr | build
	$(CMUNGE) -tgcc -32bit -o $@ -d build/DitherExtHdr.h cmhg/DitherExtHdr

build/%.o: src/%.c src/dither.h src/colour.h | build
	$(CC) $(CFLAGS) -c -o $@ $<

build/%.o: src/%.s | build
	$(CC) -mmodule -c -o $@ $<

build:
	mkdir -p build

clean:
	rm -rf build DitherExt,ffa

.PHONY: clean
