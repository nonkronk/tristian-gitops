# it-k8s-gitops

## Push-based GitOps-Kubernetes (fluxcd/flux2-managed) on top of Proxmox VE cluster + Unraid VMs [@Home](https://github.com/nonkronk/rumah-assistant)

Highly opinionated setup on deploying HA [k3s](https://k3s.io) cluster with [Ansible](https://www.ansible.com) and [Terraform](https://www.terraform.io) backed by [Flux](https://toolkit.fluxcd.io/) and [SOPS](https://toolkit.fluxcd.io/guides/mozilla-sops/).

![Proxmox VE + Unraid](![it-k8s-gitops](https://user-images.githubusercontent.com/29120359/170990291-c6962a7d-67df-493b-898c-041254268979.jpeg)
)

## Overview

Stacks:

- [cert-manager](https://cert-manager.io/) - SSL certificates - with Cloudflare DNS challenge
- [calico](https://www.tigera.io/project-calico/) - CNI (container network interface)
- [echo-server](https://github.com/Ealenn/Echo-Server) - REST Server Tests (Echo-Server) API (useful for debugging HTTP issues)
- [flux](https://toolkit.fluxcd.io/) - GitOps tool for deploying manifests from the `cluster` directory
- [hajimari](https://github.com/toboshii/hajimari) - start page with ingress discovery
- [kube-vip](https://kube-vip.io/) - layer 2 load balancer for the Kubernetes control plane
- [local-path-provisioner](https://github.com/rancher/local-path-provisioner) - default storage class provided by k3s
- [metallb](https://metallb.universe.tf/) - bare metal load balancer
- [reloader](https://github.com/stakater/Reloader) - restart pods when Kubernetes `configmap` or `secret` changes
- [reflector](https://github.com/emberstack/kubernetes-reflector) - mirror `configmap`s or `secret`s to other Kubernetes namespaces
- [system-upgrade-controller](https://github.com/rancher/system-upgrade-controller) - automate upgrading k3s
- [traefik](https://traefik.io) - ingress controller

For provisioning:

- [Ubuntu](https://ubuntu.com/download/server) - this is a pretty universal operating system that supports running all kinds of home related workloads in Kubernetes
- [Ansible](https://www.ansible.com) - this will be used to provision the Ubuntu operating system to be ready for Kubernetes and also to install k3s
- [Terraform](https://www.terraform.io) - in order to help with the DNS settings this will be used to provision an already existing Cloudflare domain and DNS settings

## 📝 Prerequisites 

### 🔧 Tools

| Tool                                               | Purpose                                                                                                                                 |
|----------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------|
| [ansible](https://www.ansible.com)                 | Preparing Ubuntu for Kubernetes and installing k3s                                                                                      |
| [direnv](https://github.com/direnv/direnv)         | Exports env vars based on present working directory                                                                                     |
| [flux](https://toolkit.fluxcd.io/)                 | Operator that manages your k8s cluster based on your Git repository                                                                     |
| [age](https://github.com/FiloSottile/age)          | A simple, modern and secure encryption tool (and Go library) with small explicit keys, no config options, and UNIX-style composability. |
| [go-task](https://github.com/go-task/task)         | A task runner / simpler Make alternative written in Go                                                                                  |
| [ipcalc](http://jodies.de/ipcalc)                  | Used to verify settings in the configure script                                                                                         |
| [jq](https://stedolan.github.io/jq/)               | Used to verify settings in the configure script                                                                                         |
| [kubectl](https://kubernetes.io/docs/tasks/tools/) | Allows you to run commands against Kubernetes clusters                                                                                  |
| [sops](https://github.com/mozilla/sops)            | Encrypts k8s secrets with Age                                                                                                           |
| [terraform](https://www.terraform.io)              | Prepare a Cloudflare domain to be used with the cluster                                                                                 |

#### Complement

| Tool                                                   | Purpose                                                  |
|--------------------------------------------------------|----------------------------------------------------------|
| [helm](https://helm.sh/)                               | Manage Kubernetes applications                           |
| [kustomize](https://kustomize.io/)                     | Template-free way to customize application configuration |
| [pre-commit](https://github.com/pre-commit/pre-commit) | Runs checks pre `git commit`                             |
| [gitleaks](https://github.com/zricethezav/gitleaks)    | Scan git repos (or files) for secrets                    |
| [prettier](https://github.com/prettier/prettier)       | Prettier is an opinionated code formatter.               |

## 📂 Repository structure

The Git repository contains the following directories under `cluster` and are ordered below by how Flux will apply them.

- **base** directory is the entrypoint to Flux
- **crds** directory contains custom resource definitions (CRDs) that need to exist globally in your cluster before anything else exists
- **core** directory (depends on **crds**) are important infrastructure applications (grouped by namespace) that should never be pruned by Flux
- **apps** directory (depends on **core**) is where your common applications (grouped by namespace) could be placed, Flux will prune resources here if they are not tracked by Git anymore

```
cluster
├── apps
│   ├── default
│   ├── networking
│   └── system-upgrade
├── base
│   └── flux-system
├── core
│   ├── cert-manager
│   ├── metallb-system
│   ├── namespaces
│   └── system-upgrade
└── crds
    └── cert-manager
```

## 🤝 Thanks

Big shout out to all the authors and contributors to the projects [awesome-home-kubernetes](https://github.com/k8s-at-home/awesome-home-kubernetes)
