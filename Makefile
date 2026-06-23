# Makefile
#
# PURPOSE
# -------
# Replaces long sequences of manual commands with short `make <target>` calls.
# Works on macOS and Linux. Windows users should run these inside WSL.
#
# USAGE
#   make help       — list all available targets
#   make up         — start VMs
#   make setup      — run full Ansible provisioning
#   make status     — show cluster health
#   make down       — stop VMs
#   make clean      — destroy VMs completely
#
# QUICK START (first time)
#   make up
#   make ping
#   make setup
#   make kubeconfig
#   make bootstrap
#   make status
#
# PHONY targets are not files — Make always runs them even if a file
# with the same name exists.
.PHONY: help up ping setup kubeconfig bootstrap status argocd-ui \
        down clean lint web-test

# ---- paths -------------------------------------------------------------------

ANSIBLE_DIR := ansible
SCRIPTS_DIR := scripts

# Use the kubeconfig fetched from the control node.
# $(PWD) expands to the current working directory at the time make runs.
KUBECONFIG  := $(PWD)/.kube/config

# Prefix kubectl calls with KUBECONFIG so you do not need to export it manually.
# You can still run plain `kubectl` commands after: export KUBECONFIG=$(pwd)/.kube/config
KUBECTL     := KUBECONFIG=$(KUBECONFIG) kubectl

# ---- default target ----------------------------------------------------------

# Running `make` with no arguments shows the help text.
.DEFAULT_GOAL := help

# ---- targets -----------------------------------------------------------------

help: ## Show this help message
	@echo ""
	@echo "Kubernetes GitOps Lab — make targets"
	@echo "======================================"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	  awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo ""

up: ## Start the 3 Vagrant VMs (k8s-control-01, k8s-worker-01, k8s-worker-02)
	vagrant up

ping: ## Test that Ansible can SSH into all VMs
	cd $(ANSIBLE_DIR) && ansible all -m ping

setup: ## Run the full Ansible setup: prepare VMs, install K3s, install Argo CD
	cd $(ANSIBLE_DIR) && ansible-playbook playbooks/site.yml

kubeconfig: ## Fetch the kubeconfig from the control node into .kube/config
	./$(SCRIPTS_DIR)/kubeconfig.sh
	@echo ""
	@echo "Tip: to use kubectl directly in your shell, run:"
	@echo "  export KUBECONFIG=$(PWD)/.kube/config"

bootstrap: ## Apply the Argo CD Application manifest (one-time GitOps bootstrap)
	$(KUBECTL) apply -f kubernetes/argocd/web-application.yaml
	@echo ""
	@echo "Argo CD will now watch this repository and sync kubernetes/apps/web/ to the cluster."

status: ## Show nodes, Argo CD app status, and web namespace resources
	@echo "=== Kubernetes Nodes ==="
	$(KUBECTL) get nodes -o wide
	@echo ""
	@echo "=== Argo CD Application ==="
	$(KUBECTL) get application web-application -n argocd -o wide
	@echo ""
	@echo "=== Web Namespace ==="
	$(KUBECTL) get all -n web
	@echo ""
	@echo "=== Ingress ==="
	$(KUBECTL) get ingress -n web -o wide

argocd-ui: ## Port-forward the Argo CD UI to https://localhost:8080
	@echo "Argo CD UI → https://localhost:8080"
	@echo "Get password: argocd admin initial-password -n argocd"
	@echo "Press Ctrl+C to stop the port-forward."
	$(KUBECTL) port-forward svc/argocd-server -n argocd 8080:443

web-test: ## Test the web application with curl
	@echo "Testing web application..."
	curl -s -H "Host: web.local" http://192.168.56.10/ | grep -o '<h1>.*</h1>' || \
	  (echo "ERROR: Expected HTML not found. Is the cluster running?" && exit 1)
	@echo ""
	@echo "Web application is reachable."

down: ## Stop VMs without destroying them (preserves disk state)
	vagrant halt

clean: ## Destroy all VMs permanently (run 'make up && make setup' to recreate)
	vagrant destroy -f

lint: ## Run linting checks locally (requires yamllint and ansible-lint)
	@echo "=== YAML lint ==="
	@command -v yamllint > /dev/null || (echo "Install: pip install yamllint" && exit 1)
	yamllint ansible/ kubernetes/
	@echo ""
	@echo "=== Ansible lint ==="
	@command -v ansible-lint > /dev/null || (echo "Install: pip install ansible-lint" && exit 1)
	ansible-lint ansible/playbooks/
	@echo ""
	@echo "All lint checks passed."
