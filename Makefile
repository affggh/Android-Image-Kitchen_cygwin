CC = gcc
CXX = g++
STRIP = strip

override CFLAGS := -O2 -Wall $(CFLAGS)
override CXXFLAGS := -O2 -Wall $(CXXFLAGS)
override LDFLAGS := -static -L/usr/local/lib

SHELL = bash

# sony_dump
SONY_DUMP_INCLUDES = \
    -Iexternal/anyxperia_dumper/include
SONY_DUMP_SRC = \
    external/anyxperia_dumper/lz4.c \
    external/anyxperia_dumper/untar.c \
    external/anyxperia_dumper/unpackbootimg.c \
    external/anyxperia_dumper/sony_dump.c
SONY_DUMP_OBJ = $(patsubst %.c,obj/sony_dump/%.o,$(SONY_DUMP_SRC))

# BlobTools blobunpack blobpack
BLOBTOOL_INCLUDES = \
    -Iexternal/BlobTools/shared
BLOBPACK_SRC = external/BlobTools/src/blobpack.cpp
BLOBUNPACK_SRC = external/BlobTools/src/blobunpack.cpp
BLOBPACK_OBJ = $(patsubst %.cpp, obj/BlobTools/%.o, $(BLOBPACK_SRC))
BLOBUNPACK_OBJ = $(patsubst %.cpp, obj/BlobTools/%.o, $(BLOBUNPACK_SRC))

# loki_tool
LOKI_TOOL_SRC = \
    external/loki/loki_flash.c \
    external/loki/loki_patch.c \
    external/loki/loki_find.c \
    external/loki/loki_unlok.c \
    external/loki/main.c
LOKI_TOOL_OBJ = $(patsubst %.c,obj/loki/%.o,$(LOKI_TOOL_SRC))

RKCRC_SRC = external/rkflashtool/rkcrc.c
RKCRC_OBJ = $(patsubst %.c,obj/%.o,$(RKCRC_SRC))


.PHONY: all

all: out/sony_dump out/blobpack out/blobunpack \
        out/dhtbsign out/elftool out/futility \
        out/loki_tool out/lz4 out/mboot out/mkbootimg out/unpackbootimg \
        out/mkmtkhdr out/pxa-mkbootimg out/pxa-unpackbootimg \
        out/rkcrc out/unpackelf

obj/%.o: %.c
	@mkdir -p `dirname $@`
	@echo -e "\t    CC\t    $@"
	@$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

obj/%.o: %.cc
	@mkdir -p `dirname $@`
	@echo -e "\t    CPP\t    $@"
	@$(CXX) $(CXXFLAGS) $(INCLUDES) -fno-exceptions -c $< -o $@

obj/%.o: %.cpp
	@mkdir -p `dirname $@`
	@echo -e "\t    CPP\t    $@"
	@$(CXX) $(CXXFLAGS) $(INCLUDES) -c $< -o $@

obj/loki/%.o: %.c
	@mkdir -p `dirname $@`
	@echo -e "\t    CC\t    $@"
	@$(CC) $(CFLAGS) $(INCLUDES) -Iexternal/loki -c $< -o $@

obj/BlobTools/%.o: %.cpp
	@mkdir -p `dirname $@`
	@echo -e "\t    CPP\t    $@"
	@$(CXX) $(CXXFLAGS) $(INCLUDES) $(BLOBTOOL_INCLUDES) -c $< -o $@

obj/sony_dump/%.o: %.c
	@mkdir -p `dirname $@`
	@echo -e "\t    CC\t    $@"
	@$(CC) $(CFLAGS) -DUSE_FILE32API -D_FILE_OFFSET_BITS=64 -D_LARGEFILE64_SOURCE=1 $(SONY_DUMP_INCLUDES) -c $< -o $@

out/sony_dump: $(SONY_DUMP_OBJ)
	@mkdir -p `dirname $@`
	@echo -e "\t    LD\t    $@"
	@$(CC) $(CFLAGS) -o $@ $^ -lz $(LDFLAGS)
	@echo -e "\t    STRIP\t$@"
	@$(STRIP) $@

out/blobpack: $(BLOBPACK_OBJ)
	@mkdir -p `dirname $@`
	@echo -e "\t    LD\t    $@"
	@$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)
	@echo -e "\t    STRIP\t$@"
	@$(STRIP) $@

out/blobunpack: $(BLOBUNPACK_OBJ)
	@mkdir -p `dirname $@`
	@echo -e "\t    LD\t    $@"
	@$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)
	@echo -e "\t    STRIP\t$@"
	@$(STRIP) $@

out/dhtbsign:
	@mkdir -p `dirname $@`
	@$(MAKE) -C external/dhtbsign static
	@cp -f external/dhtbsign/dhtbsign `dirname $@`/

out/elftool:
	@mkdir -p `dirname $@`
	@$(MAKE) -C external/elftool static
	@cp -f external/elftool/elftool `dirname $@`/

out/futility: external/openssl/libcrypto.a
	@mkdir -p `dirname $@`
	@$(MAKE) -C external/futility static LDFLAGS="-L../openssl -lcrypto"
	@cp -f external/futility/futility `dirname $@`/

out/loki_tool: $(LOKI_TOOL_OBJ)
	@mkdir -p `dirname $@`
	@echo -e "\t    LD\t    $@"
	@$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)
	@echo -e "\t    STRIP\t$@"
	@$(STRIP) $@

out/lz4:
	@mkdir -p `dirname $@`
	@$(MAKE) -C external/lz4 LDFLAGS="-static"
	@cp -f external/lz4/lz4 `dirname $@`/

out/mboot:
	@mkdir -p `dirname $@`
	@$(MAKE) -C external/mboot static
	@cp -f external/mboot/mboot `dirname $@`/

out/mkbootimg:
	@mkdir -p `dirname $@`
	@$(MAKE) -C external/mkbootimg static
	@cp -f external/mkbootimg/mkbootimg `dirname $@`/

out/unpackbootimg: out/mkbootimg
	@mkdir -p `dirname $@`
	@cp -f external/mkbootimg/unpackbootimg `dirname $@`/

out/mkmtkhdr:
	@mkdir -p `dirname $@`
	@$(MAKE) -C external/mkmtkhdr static
	@cp -f external/mkmtkhdr/mkmtkhdr `dirname $@`

out/pxa-mkbootimg:
	@mkdir -p `dirname $@`
	@$(MAKE) -C external/pxa-mkbootimg static
	@cp -f external/pxa-mkbootimg/pxa-mkbootimg `dirname $@`/

out/pxa-unpackbootimg: out/pxa-mkbootimg
	@mkdir -p `dirname $@`
	@cp -f external/pxa-mkbootimg/pxa-unpackbootimg `dirname $@`/

out/rkcrc: $(RKCRC_OBJ)
	@mkdir -p `dirname $@`
	@echo -e "\t    LD\t    $@"
	@$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)
	@echo -e "\t    STRIP\t$@"
	@$(STRIP) $@

out/unpackelf:
	@mkdir -p `dirname $@`
	@$(MAKE) -C external/unpackelf static
	@cp -f external/unpackelf/unpackelf `dirname $@`/

external/openssl/libcrypto.a:
	cd external/openssl && ./config
	cd external/openssl && $(MAKE)

clean:
	@echo -e "\t    RM\t    obj"
	@rm -rf obj
	@echo -e "\t    RM\t    out"
	@rm -rf out
	@$(MAKE) -C external/dhtbsign clean
	@$(MAKE) -C external/elftool clean
	@$(MAKE) -C external/futility clean
	@$(MAKE) -C external/lz4 clean
	@$(MAKE) -C external/mboot clean
	@$(MAKE) -C external/mkbootimg clean
	@$(MAKE) -C external/mkmtkhdr clean
	@$(MAKE) -C external/pxa-mkbootimg clean
	@$(MAKE) -C external/unpackelf clean
	@$(MAKE) -C external/openssl clean