---
layout: page
title: Installation
permalink: /install/
---

## Contents

1. [Prerequisites](#prerequisites)
2. [Installing Sandy properly](#installing-sandy-properly)
3. [Or get Sandy in a Docker image](#or-get-sandy-in-a-docker-image)

## Prerequisites

Along with **Perl**, the user must have **zlib**, **gcc**, **make** and
**perldoc** packages installed. To install them according to your distro, use:

* Debian/Ubuntu
```bash
	$ apt-get install perl zlib1g-dev gcc make perl-doc
```

* CentOS/Fedora
```bash
	$ yum install perl zlib gcc make perl-doc
```

* Archlinux
```bash
	$ pacman -S perl zlib gcc make perl-doc
```

**Sandy** uses the *Comprehensive Perl Archive Network*, CPAN, as its package
manager, which allows a good control over all dependencies needed. If you have
Perl installed, then you may have the cpan command utility. At the first run,
cpan will interactively configure your environment and mirror.

If you are not sure, confirm the prerequisites presented and, after this,
install *cpanminus* package manager:
```bash
	$ cpan -i App::cpanminus
```

`App::cpanminus` will provide the `cpanm` utility, which has the capability of
install not only Sandy, but also all its dependencies, recursively.

## Installing **Sandy** properly

Finally install **Sandy** with:
```bash
	$ cpanm App::Sandy
```

**Important:** MacOS users must add an extra option to the command above, like
this:
```bash
	$ cpanm --force App::Sandy
```

## Or get Sandy in a Docker image

If the user prefer to avoid any intallation process and have Docker, you can just
pull *Sandy*'s* [image](https://hub.docker.com/r/galantelab/sandy) from Docker
Hub with:
```bash
	$ docker pull galantelab/sandy
```

And will take the latest version of **Sandy**, ready to rock!

So, to view some instructions about how to use **Sandy** from a docker image, see
the manual or consult the web [tutorial about Sandy usage from docker](https://galantelab.github.io/sandy/v0.22/main.html#docker-usage).

**Important:** Docker has some strict default configurations for memory and CPU
usage on MacOS. Users of this system can change these configurations on their
behalf by accessing the [Preferences menu](https://docs.docker.com/docker-for-mac/#preferences-menu)
on the Docker icon at top right corner of their desktops.

For many more details, see the [INSTALL](https://github.com/galantelab/sandy/blob/master/INSTALL)
file on *Sandy*'s* GitHub [repository](https://github.com/galantelab/sandy).
