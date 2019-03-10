# Dockerfile for Sandy

A straightforward and complete next-generation sequencing read simulator

## Getting Started

These instructions will cover installation and usage information for the docker container.

### Prerequisities

In order to run this container you'll need docker installed.

* [Windows](https://docs.docker.com/windows/started)
* [OS X](https://docs.docker.com/mac/started/)
* [Linux](https://docs.docker.com/linux/started/)

### Acquiring Sandy Image

#### Manual Installation

Clone **Sandy** repository:

`$ git clone https://github.com/galantelab/sandy.git`

Inside `sandy/` folder:

`$ docker build -t sandy -f docker/Dockerfile .`

#### Pulling Image

Pull **Sandy** image from [dockerhub](https://hub.docker.com) registry:

`$ docker pull galantelab/sandy`

It's possible to pull a specific image version by appending a colon with the required tag.
For example:

`$ docker pull galantelab/sandy:release-v0.22`

For a complete list of **Sandy** versions, please access the dockerhub tag page: <https://hub.docker.com/r/galantelab/sandy/tags/>

### Setting

Mac users may need to change the default settings in order to make use
of all CPUs and memory. For a complete tutorial, see: [Get started with Docker Desktop for Mac](https://docs.docker.com/docker-for-mac/#preferences-menu)

### Usage

#### Container Examples

`$ docker run galantelab/sandy`

By default **Sandy** runs in a container-private folder. You can change this using flags, like user (-u),
current directory, and volumes (-w and -v). E.g. this behaves like an executable standalone and gives you
the power to process files outside the container:

```
$ docker run \
	--rm \
	-u $(id -u):$(id -g) \
	-v $(pwd):$(pwd) \
	-w $(pwd) \
	galantelab/sandy genome example.fa
```

How to get a shell started in your container:

`$ docker run -ti --entrypoint bash galantelab/sandy`

### Thank You

So long, and thanks for all the fish!
