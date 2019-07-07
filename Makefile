SOURCES := $(shell find src -type f)

tetris.nes: $(SOURCES) tetris.chr
	cd src && nesasm tetris.s
	mv src/tetris.nes .
	mv src/tetris.fns .

tetris.chr: src/res/tetris.bmp
	bmp2chr $< $@

clean:
	rm -f tetris.nes tetris.chr tetris.fns