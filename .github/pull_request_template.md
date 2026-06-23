## What changed

<!-- Describe what this PR changes and why. Be specific. -->

## Type of change

<!-- Check the one that applies. The commit message type must match. -->

- [ ] `feat` — new feature or capability
- [ ] `fix` — bug fix
- [ ] `docs` — documentation update only
- [ ] `refactor` — code reorganisation, no behaviour change
- [ ] `chore` — maintenance, dependency update, config tweak
- [ ] `ci` — CI/CD pipeline change
- [ ] `break` — breaking change (incompatible with previous setup)

## Kubernetes resources affected

<!-- List which manifests this PR adds, changes, or removes -->

- [ ] None
- [ ] `kubernetes/apps/web/deployment.yaml`
- [ ] `kubernetes/apps/web/configmap.yaml`
- [ ] `kubernetes/apps/web/service.yaml`
- [ ] `kubernetes/apps/web/ingress.yaml`
- [ ] `kubernetes/apps/web/namespace.yaml`
- [ ] `kubernetes/argocd/web-application.yaml`
- [ ] Other: <!-- describe -->

## Ansible changes

<!-- List which Ansible playbooks or variables this PR changes -->

- [ ] None
- [ ] `ansible/playbooks/prepare.yml`
- [ ] `ansible/playbooks/k3s-server.yml`
- [ ] `ansible/playbooks/k3s-agents.yml`
- [ ] `ansible/playbooks/argocd.yml`
- [ ] `ansible/group_vars/all.yml`
- [ ] Other: <!-- describe -->

## Testing checklist

<!-- Check the items you have tested locally. CI checks run automatically. -->

- [ ] `vagrant up` — VMs started without errors
- [ ] `ansible all -m ping` — Ansible can connect to all VMs
- [ ] `ansible-playbook playbooks/site.yml` — full setup completed
- [ ] `kubectl get nodes -o wide` — all nodes are Ready
- [ ] Argo CD shows `Synced` + `Healthy` for `web-application`
- [ ] `curl -H "Host: web.local" http://192.168.56.10/` — returns expected HTML

## Notes for reviewer

<!-- Any additional context, trade-offs, or things to watch out for -->
