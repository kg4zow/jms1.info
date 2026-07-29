all: clean build

build:
	rm -rf theme/ && mkdir theme
	mdbook build
	if [ -f .git2rss -a -x git2rss ] ; then ./git2rss > book/commits.xml ; fi

clean:
	mdbook clean

serve:
	rm -rf theme/ && mkdir theme
	mdbook serve --open --hostname 127.0.0.1

serve-all:
	rm -rf theme/ && mkdir theme
	mdbook serve --open --hostname 0.0.0.0

push: build
	rsync -avz --delete book/ /keybase/team/jms1team.sites/jms1.info/
	rsync -avz --delete book/ vps2.jms1.net:/var/www/jms1.info/
