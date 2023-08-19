{
description = "minikube development environment for macOS";

inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05-small";
  flake-utils.url = "github:numtide/flake-utils";
};

outputs = { self, nixpkgs, flake-utils }:
  flake-utils.lib.eachDefaultSystem
    (system:
    let pkgs = import nixpkgs {
      inherit system;
    };
    in let
    shell-prepare = pkgs.writeShellScriptBin "prepare-k8s-cluster"
        ''
        set -e
        set -x
        if ! minikube status; then
          MINIKUBE_DRIVER=$\{MINIKUBE_DRIVER:-docker\};
          echo "using MINIKUBE_DRIVER=$MINIKUBE_DRIVER"
          minikube start --driver=docker --mount=true --mount-string=$(pwd):/minikube-host --wait=apiserver,system_pods --addons=registry
        fi
        minikube -p minikube docker-env
        helm repo add postgres-operator-charts https://opensource.zalando.com/postgres-operator/charts/postgres-operator

        # install the postgres-operator
        helm install postgres-operator postgres-operator-charts/postgres-operator

        # add repo for postgres-operator-ui
        helm repo add postgres-operator-ui-charts https://opensource.zalando.com/postgres-operator/charts/postgres-operator-ui

        # install the postgres-operator-ui
        # helm install postgres-operator-ui postgres-operator-ui-charts/postgres-operator-ui

        # minikube addons enable ingress
        # minikube addons enable registry

        # helm repo add twuni https://helm.twun.io
        # helm install docker-registry twuni/docker-registry --set service.type=NodePort

        helm repo add helm-openldap https://jp-gouin.github.io/helm-openldap/
        helm install ldap helm-openldap/openldap-stack-ha --values tests/ldap_config.yaml || true
      '';

    shell-build-k8s-docker = pkgs.writeShellScriptBin "build-k8s-docker" ''
      eval $(minikube -p minikube docker-env)
      docker build -t liquid-feedback-k8s .  --build-arg K8S=1
    '';

    shell-lf-up = pkgs.writeShellScriptBin "lf-up" ''
      set -x

      helm upgrade lf ./liquid-feedback --install --values tests/default.yaml $@
      # if [[ $(helm status lf --output json | jq '.info.status') = '"deployed"' ]]; then
      #   echo "start upgrade";
      #   set -x;
      #   
      # else
      #   echo "start install";
      #   set -x;
      #   helm install lf ./liquid-feedback --values tests/default.yaml $@
      # fi
    '';

    shell-lf-down = pkgs.writeShellScriptBin "lf-down" ''
      helm delete lf
    '';

    shell-template = pkgs.writeShellScriptBin "lf-template" ''
      set -x
      helm template ./liquid-feedback --values tests/default.yaml $@ | bat -l yaml
    '';
    shell-active-config = pkgs.writeShellScriptBin "lf-get-config" ''
      kubectl get cm lf-liquid-feedback -o jsonpath='{.data.frontend\.lua}' | bat -l lua
    '';

    in
      {
        devShell = pkgs.mkShell { 
          buildInputs = with pkgs; [
            bat
            mercurial
            minikube
            kubernetes-helm
            kubectl
            k9s
            jq
            docker
            podman
            shell-prepare
            shell-build-k8s-docker
            shell-lf-up
            shell-lf-down
            shell-template
            shell-active-config
          ];
          shellHook = ''
            . <(minikube completion bash)
            . <(helm completion bash)

            # kubectk and docker completion require the control plane to be running
            if [[ $(minikube status -o json | jq -r .Host) == "Running" ]]; then
              . <(kubectl completion bash)
              . <(minikube -p minikube docker-env)
            fi

            # export DOCKER_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services docker-registry)
            # export DOCKER_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")
            # echo "Docker registry: http://$NODE_IP:$NODE_PORT"

            function help() {
              echo "Dev commands: "
              echo "  prepare-k8s-cluster  - start minikube cluster for testing"
              echo "  minikube delete      - cleanup minikube cluster"
              echo "  build-k8s-docker     - builds the kubernetes image"
              echo "  lf-up                - install/upgrades the lf installation"
              echo "  lf-down              - deinstall liquid-feedback"
              echo "  lf-template          - template the lf installation"
              echo "  lf-get-config        - get the active configuration"
            }
            help
          '';
        };
      }
    );
}
