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

### Persistent data

**Sandy** *expression matrix*, *quality profile* and *structural variation* patterns are stored within docker container, that is, any database changes during runtime will last as long as the container is not removed.

A named Docker volume or a mounted host directory should be used in order to keep your changes to the database. If our container detects that the path `/sandy/db` is mounted, then the database `/sandy/db/db.sqlite3` will be used intead of the default database. In the same way, if there is no database `db.sqlite3` inside the mounted path `/sandy/db/`, then the default database will be copied to `/sandy/db/` and used consecutively.

#### Named volume:

- `sandy_db` volume will be created at first run and will persist after container deletion.

```
$ docker run \
	--rm \
	-v sandy_db:/sandy/db
	galantelab/sandy
```

You can verify the created volume with the commands:

```
$ docker volume ls

# and in more detail with the command:
$ docker volume inspect sandy_db
```

#### Mounted directory:

- `/path/to/DB` will receive the default database at first run and any further changes will be stored in it.

```
$ docker run \
	--rm \
	-v /path/to/DB:/sandy/db \
	galantelab/sandy
```

Now, verify the directory `/path/to/DB`. You should find the file `db.sqlite3`.

As you add your custom patterns to **Sandy**, the alterations will be kept safelly outside the container.

#### More examples:

- Add a new quality profile:

```
$ docker run \
	--rm \
	-v /path/to/quality_profile.txt:/quality_profile.txt \
	-v sandy_db:/sandy/db \
	galantelab/sandy quality add -q new_profile /quality_profile.txt
```

- Check the new quality profile at `sandy_db`:

`$ docker run --rm -v sandy_db:/sandy/db galantelab/sandy quality`

- Add a new expression matrix:

```
$ docker run \
	--rm \
	-v /path/to/tissue_counts.txt:/tissue_counts.txt \
	-v sandy_db:/sandy/db \
	galantelab/sandy expression add -f new_tissue /tissue_counts.txt
```

- Check the new expression matrix at `sandy_db`:

`$ docker run --rm -v sandy_db:/sandy/db galantelab/sandy expression`

- Add a new structural variation:

```
$ docker run \
	--rm \
	-v /path/to/sv.txt:/sv.txt \
	-v sandy_db:/sandy/db \
	galantelab/sandy variation add -a new_sv /sv.txt
```

- Check the new structural variation at `sandy_db`:

`$ docker run --rm -v sandy_db:/sandy/db galantelab/sandy variation`

### Thank You

So long, and thanks for all the fish!
