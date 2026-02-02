.PHONY: build release install clean

build:
	swift build

release:
	swift build -c release

install: release
	cp .build/release/ClipboardHistory /usr/local/bin/

clean:
	swift package clean
	rm -rf .build
