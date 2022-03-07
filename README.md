FreeBSD Service cluster tool
======

This is a tool to build a freebsd service cluster

== Basic Idea

1. Use consul as service discovery

2. Use nomad to schedule services

3. Use traefik as service redirect

4. Use CARP to handle service fail over

5. Use FreeBSD jail management tool(pot) to manage service jail

== Usage

1. get help
```sh
./bin/sc usage
```

2. build a service cluster

2.1 create configuration of cluster

See examples at examples/conf/cluster.conf

2.2 build service cluster

for each hosts in the cluster, run:

```sh
./bin/sc apply -c examples/conf/cluster.conf -i em0
```

- em0 is the netif used by consul/nomad/traefik

3. build jail image of service

3.1 create jail with required packages installed

3.2 export the jail image

3.3 upload the jail image to repository which can be accessed
by service cluster


4. create nomad job for jail service 

See examples/jobs for detail

5. submit job to make service online

6. configure DNS service to resolve service domain to CARP address

*.<data center>.<your domain>

== Others

create pull request if you found any issue.

