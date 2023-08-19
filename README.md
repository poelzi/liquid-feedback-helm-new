# Liquid-Feedback-Helm

[Liquid Feedback](http://liquidfeedback.org) is an [open-source application](https://www.public-software-group.org/liquid_feedback) that enables internet platforms for proposition development and decision making.

This helm chart provides a full automatic installation/upgrade and scaleable version of liquid feedback.

***Features:***

  * [x] [Zalandao Postegres Operator](https://github.com/zalando/postgres-operator) support
  * [x] auto sql upgrade
  * [x] admin user managment
  * [x] horizontal scaleable
  * [x] LDAP support (WIP)
  * [ ] OAUTH2 support

## Usage

Add the helm registry to your installation

`helm repo add liquid-feedback https://b1-systems.github.io/liquid-feedback-helm/`

Then use:

`helm install lf liquid-feedback/liquid-feedback`

Please note that the default settings use the Zalandao Postegres Operator.


## Creating admin users

Fill the `adminUsers` array. In case the `liquid-feedback-update` pod did not restart,
delete the pod. Example:

`kubectl delete pod $(kubectl get pods --namespace default -l "app.kubernetes.io/name=liquid-feedback-update,app.kubernetes.io/instance=lf" -o jsonpath="{.items[0].metadata.name}")`

Assuming your helm name is `lf`.

## LDAP configuration

Since ldap mapping is quite complex, it needs to me configured with a lua snippet.
Enable `ldap.enable` and adjust the `ldap.config` to match your organization.

*warning*: Any misstake in the ldap configuration will result in denied login with no hint in log files or login error messages. The units given in the privilege_map must exist.

## OAuth2 configuration

Using the oauth2 client requires special dynamic configuration and environment variables to pin SSL certificates. Since oauth is undocumented, no successful oauth2 client was archived.

## Development

Install the [nix](https://nixos.org/download#download-nix) package manager. This does not require NixOS, but can be installed on any linux os.

run `nix develop` to enter development shell.
Run `help` for commands.

It uses [minikube](https://github.com/kubernetes/minikube) to provide a dev environment.

## Dockerfile for Liquid Feedback

You can use the Docker file to build a fully self contained version for testing etc.

The project's source code has a lot of dependencies and requires a lot of tedious steps to build. This Dockerfile simplifies this process and allows interested developers and organizations to quickly build and run a Liquid Feedback server using a [Docker](http://docker.io) container.

## How to use

To build an image go to the Dockerfile dir and do:

    `docker build -t liquid-feedback .`
The kubernetes version with:

    `docker build -t liquid-feedback-k8s .  --build-arg K8S=1`
    
To run the server do:

    `docker run -p 127.0.0.1:8080:8080 liquid-feedback`
    
And connect a browser to http://localhost:8080 and login with user admin and empty password
