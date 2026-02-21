PREFIX ?= /usr/local

install:
	install -m 755 specloop $(PREFIX)/bin/specloop

uninstall:
	rm -f $(PREFIX)/bin/specloop

.PHONY: install uninstall
