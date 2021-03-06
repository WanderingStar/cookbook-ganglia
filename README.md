# DESCRIPTION:

Installs and configures Ganglia.

http://ganglia.sourceforge.net/

# REQUIREMENTS:

*   SELinux must be disabled on CentOS
*   iptables must allow access to port 80


# USAGE:

A run list with "[recipe](http://ganglia)" enables monitoring.


A run list with "[recipe](ganglia::gmetad)" enables the gmetad collector.


A run list with "[recipe](ganglia::web)" enables the web interface.


A run list with "[recipe](ganglia::graphite)" enables graphite graphs.

# ATTRIBUTES:

Ganglia is installed on a host in one of the three modes, typically. They are:
*   Host to be monitored. The attributes file (-j option of chef-solo) for
    such a host will be something like:

        {
            "run_list": [
                "recipe[ganglia]"
            ],
            "ganglia": {
                "unicast": true,
                "server_addresses": [ "ec2-23-22-134-140.compute-1.amazonaws.com" ]
            }
        }


In case you use roles (instead of attributes file), please ensure that the
"run_list" includes:

    "recipe[ganglia]"

And "override_attrubutes" includes

    "ganglia": {
        "unicast": true,
        "server_addresses": [ <collector-host-name-or-address> ]
    }

Here `server_addresses` are the addresses or server names to which the current
host reports metrics periodically. Typically, it is a single host that
collects metrics (described next). Since this hosts only sends out UDP
messages to the collecting host, no port needs to be opened.

*   Host that collects metrics for a cluster. The attributes file (-j option
    of chef-solo) for such a host would be something like:

        {
            "run_list": [
                "recipe[ganglia]"
            ],
            "ganglia": {
                "unicast": true,
                "cluster_name": "test-cluster-1",
                "server_addresses": [ "ec2-23-22-134-140.compute-1.amazonaws.com" ]
            }
        }


In case you use roles (instead of attributes file), please ensure that the
"run_list" includes:

    "recipe[ganglia]"

And "override_attrubutes" includes

    "ganglia": {
        "unicast": true,
        "cluster_name": <name-of-the-cluster>,
        "server_addresses": [ <collector-host-name-or-address> ]
    }

Again, the `cluster_name` is the name of the cluster for which the current
host is collecting metrics. Since the hosts being monitored send UDP messages
to this host, this host should open UDP port 8649. Also since the web host
(see below) would be polling this host to retrieve metrics for the whole
cluster, the host should also open TCP port 8649.

The "server_addresses" field, again lists the hosts that this host should send
its mterics periodically. It is preferrable to use the full DNS name even if
that host happens to be the "localhost". Ganglia does reverse DNS lookup on
the source IP address to identify the host. With local hostname, that would
mean that source address would be 127.0.0.1 which in turn maps to "localhost"
on reverse lookup. That is not very user friendly.

*   Web host. The host that provides the web interface to the user to view the
    metrics. This host also runs gmetad, the program responsible to retireve
    cluster level metrics from the collector hosts (described above) and
    stores it in persistent store. The attributes file (-j option of
    chef-solo) for such a host would be something like:

        {
            "run_list": [
                "recipe[ganglia]",
                "recipe[ganglia::web]",
                "recipe[ganglia::gmetad]"
            ],
            "ganglia": {
                "server_auth_method": "openid",
                "openid": {
                    "profile_url": "https://www.google.com/accounts/o8/id",
                    "use_email_as_userid": true,
                    "email_pattern": "@verticloud.com$"
                },
                "unicast": true,
                "grid_name": "test-grid",
                "clusters": [
                    { "name": "test-cluster-1", "collector": "ec2-23-22-134-140.compute-1.amazonaws.com" },
                    { "name": "local-0", "collector": "localhost" }
                ],
                "server_addresses": [ "localhost" ]
            }
        }


In case you use roles (instead of attributes file), please ensure that the
"run_list" includes:

    "recipe[ganglia::web]",
    "recipe[ganglia::gmetad]"

And "override_attrubutes" includes

    "ganglia": {
        "server_auth_method": "openid",
        "openid": {
            "profile_url": "https://www.google.com/accounts/o8/id",
            "use_email_as_userid": true,
            "email_pattern": "@verticloud.com$"
        },
        "grid_name": <name-of-the-grid>",
        "clusters": [
            { "name": <name-of-cluster-1>, "collector": <collector-of-cluster-1> },
            { "name": <name-of-cluster-2>, "collector": <collector-of-cluster-2> },
            ...
        ],
    }

If openid based authentication is required on the host, the
`server_auth_method` and `open_id` fields must be specified. `grid_name` is
the name of the grid (the set of clusters, together is called a grid). The
`clusters` field provide information about the names of the clusters and their
corrsponding collection hosts.

# LWRP:

## gmetric

Installs a gmetric plugin.

The plugin is composed of two templates:
*   One for the script
*   One for the cron job that will call the script


The templates must be in the caller cookbook.

Example:

    ganglia_gmetric 'memcache' do
        options :port => 11211
    end

    templates:
    cookbooks/memcache/templates/default/memcache.gmetric.erb
    cookbooks/memcache/templates/default/memcache.cron.erb

The content of 'options' will be passed to the templates

## python

Installs a python plugin.

The plugin is composed of two templates:
*   One for the python module
*   One for the configuration of the module


The templates must be in the caller cookbook.

Example:

    ganglia_python 'memcache' do
        options :port => 11211
    end

    templates:
    cookbooks/memcache/templates/default/memcache.py.erb
    cookbooks/memcache/templates/default/memcache.pyconf.erb

The content of 'options' will be passed to the templates

# CAVEATS: 

This cookbook has been tested on Ubuntu 10.04 and Centos 5.5.

Search seems to takes a moment or two to index. You may need to converge again
to see recently added nodes.
