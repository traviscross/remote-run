.PHONY: all install clean

all:
clean:
install:
	install -d $(DESTDIR)/usr/bin
	install -m755 remote-run.sh $(DESTDIR)/usr/bin/remote-run
