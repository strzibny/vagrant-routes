# vagrant-routes

**This is a proof-of-concept.**

Access OpenShift routes from the host.

This plugin updates the hosts file on your host with hostname entries of your
OpenShift applications. Windows support implementation is taken from the
`vagrant-hostmanager` plugin, thanks guys!

## Installation

```
$ vagrant plugin install vagrant-routes
```

## Usage

Export all routes as cluster admin:

```
$ vagrant route --all
Updating hosts file with new hostnames:
pyapp-python.router.default.svc.cluster.local
```

Otherwise you need to log in and select your project within the OpenShift guest and then run `vagrant route` on host.


Use `--help` to see all options:

```
$ vagrant route --help
Usage: vagrant route [options]

Options:

        --all                        Expose all routes
    -h, --help                       Print this help
```
