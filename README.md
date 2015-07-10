Tools for researching networks.

### ISP congestion detection with smokeping config generation

Performs traceroutes using `nmap` to a handful of popular sites on the net and generates a smokeping config
containing all hops that appear in at least half of the paths. Pair with the [smokeping docker container from dockerhub](https://registry.hub.docker.com/u/dperson/smokeping/) for easy monitoring of upstream ISP congestion.

    bundle exec rake smokeping
