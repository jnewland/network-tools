Tools for researching networks.

### Network path analysis

Generates a graphviz graph (`graph.png`) representing routes taken by traffic to
a set of target domains. Alexa's top 25 sites in your current country are used
as targets if none are provided.

#### Usage

    docker run --rm -it -v $(pwd):/usr/src/app/out jnewland/network-tools rake graph
    open graph.png

Use a specific set of targets by setting the `TARGETS` environment variable:

    docker run --rm -it -e TARGETS=github.com,gitlab.com -v $(pwd):/usr/src/app/out jnewland/network-tools rake graph