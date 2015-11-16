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

```
# Start Vagrant VM with OpenShift, log in and select your project
# Update `hosts` file on the host by running:
$ vagrant route
Updating hosts file with new hostnames:
pyapp-python.router.default.svc.cluster.local
```
