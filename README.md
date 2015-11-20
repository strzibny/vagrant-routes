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

- First start Vagrant VM with OpenShift, log in and select your project within the guest
- Then run `vagrant route`

```
$ vagrant route
Updating hosts file with new hostnames:
pyapp-python.router.default.svc.cluster.local
```

Use `--help` to see all options:

```
$ vagrant route --help
Usage: vagrant route [options]

Options:

        --all                        Expose all routes (you need to be cluster admin)
    -h, --help                       Print this help
```
