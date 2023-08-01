---
layout: page
title: Installation
permalink: /install/
---

There are three ways to obtain **Sandy**: pulling the official [Docker](https://www.docker.com/)
image, installing through [CPAN](https://metacpan.org/) and installing manually.

## Contents
{:.no_toc}

1. This will become a table of contents.
{:toc}

## Docker

Once [Docker](https://www.docker.com/) is installed, simply run the command:

{% highlight shell_session %}
$ docker pull galantelab/sandy
{% endhighlight %}

This way the latest stable version of **Sandy** will be installed. You can see the complete list of
available versions at [![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=flat&logo=docker&logoColor=white)](https://hub.docker.com/r/galantelab/sandy/tags).

For more details about `docker` usage and examples, see
[docker/README.md](https://github.com/galantelab/sandy/blob/master/docker/README.md) file.

## CPAN

### Prerequisites

Along with `perl`, you must have `zlib`, `gcc`, `make` and `cpanm` packages installed:

- Debian/Ubuntu

{% highlight shell_session %}
# apt-get install perl zlib1g-dev gcc make cpanminus
{% endhighlight %}

- CentOS/Fedora

{% highlight shell_session %}
# yum install perl zlib gcc make perl-App-cpanminus
{% endhighlight %}

- Archlinux

{% highlight shell_session %}
# pacman -S perl zlib gcc make cpanminus
{% endhighlight %}

### Installing with `cpanm`

Install **Sandy** with the following command:

{% highlight shell_session %}
# cpanm App::Sandy
{% endhighlight %}

If you concern about speed, you can avoid testing with the flag `--notest`:

{% highlight shell_session %}
# cpanm --notest App::Sandy
{% endhighlight %}

## Manual installation

This is not the recommended way to install **Sandy**, but for conscience sake,
here is the manual way to obtain and install it.

First of all, install the [prerequisites](#prerequisites).

Then, clone the source-code:

{% highlight shell_session %}
$ git clone https://github.com/galantelab/sandy.git
{% endhighlight %}

if you already have all the perl packages Sandy depends on (you probably don't),
then skip this step. Inside **Sandy** directory, install all perl dependencies
with `cpanm`:

{% highlight shell_session %}
# cpanm --installdeps .
{% endhighlight %}

Now compile the code with:

{% highlight shell_session %}
$ perl Makefile.PL
$ make
{% endhighlight %}

And install:

{% highlight shell_session %}
# make install
{% endhighlight %}

For more details, see
[INSTALL](https://github.com/galantelab/sandy/blob/master/INSTALL) file.
