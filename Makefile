all: build

build:
	mdbook build
	if [ -f .git2rss -a -x git2rss ] ; then ./git2rss > book/commits.xml ; fi

serve:
	mdbook serve --open --hostname 127.0.0.1

serve-all:
	mdbook serve --open --hostname 0.0.0.0

push:
	rsync -avz --delete book/ /keybase/team/jms1team.sites/jms1.info/
