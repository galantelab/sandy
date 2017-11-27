# Dockerfile for simulate_reads

### Building images yourself

Inside the docker folder:

`docker build -t simulate_reads .`

### Docker run options

By default simulate_reads runs in a container-private folder. You can change this using flags, like user (-u),
current directory, and volumes (-w and -v).  E.g. this behaves like an executable standalone and gives you
the power to process files outside the container.

`docker run --rm -u $(id -u):$(id -g) -v $(pwd):$(pwd) -w $(pwd) simulate_reads --help`

