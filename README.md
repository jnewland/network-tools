Tools for researching networks.

### Network path analysis

Performs traceroutes and generates a graphviz file (`graph.dot`) representing
the routes taken by your traffic.

    bundle exec rake dot
    dot -Tpng graph.dot > graph.png
    open graph.png
    TARGETS=github.com bundle exec rake dot

### Automatic smokeping config generation

Performs traceroutes using `nmap` to a handful of popular sites on the net and
generates a smokeping config containing all hops that appear in at least half of
the paths. Pair with the [smokeping docker container from
dockerhub](https://registry.hub.docker.com/u/dperson/smokeping/) for easy
monitoring of upstream ISP congestion.

    bundle exec rake smokeping
