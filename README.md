Tools for researching networks.

### Network path analysis

Generates a graphviz graph (`graph.png`) representing routes taken by traffic to
a set of target domains. Alexa's top 25 sites in your current country are used
as targets if none are provided.

#### Dependencies

System dependencies:

    geoip
    graphviz
    jq
    nmap
    ruby / bundler

A Brewfile is provided for those on OS X:

    brew tap homebrew/bundle
    brew bundle

Ruby dependencies can be installed with bundler:

    bundle install

#### Usage

    bundle exec rake graph
    open graph.png

Use a specific set of targets by setting the `TARGETS` environment variable:

    TARGETS=github.com,google.com bundle exec rake dot

Cleanup cached nmap output for another run:

    bundle exec rake clean

### Automatic smokeping config generation

Performs traceroutes using `nmap` to a handful of popular sites on the net and
generates a smokeping config containing all hops that appear in at least half of
the paths. Pair with the [smokeping docker container from
dockerhub](https://registry.hub.docker.com/u/dperson/smokeping/) for easy
monitoring of upstream ISP congestion.

    bundle exec rake smokeping
