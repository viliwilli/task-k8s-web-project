# task-k8s-web-project
Deploy and Manage a Kubernetes Cluster Using IaC Tools with GitOps Approach <br>

You are tasked with deploying a set of VMs, setting up a Kubernetes cluster on these VMs, and <br>
deploying a simple web application. The application should be accessible via a DNS record. You <br>
should use a GitOps approach to manage the configuration and deployment. <br>

# Kubernetes GitOps Web Project

This repository contains a local DevOps lab that deploys a multi-node Kubernetes cluster on virtual machines and manages a simple web application using a GitOps approach.

The solution is designed and tested on:

* macOS
* Apple Silicon MacBook Air M4
* VirtualBox
* Vagrant
* Ansible
* K3s Kubernetes
* Argo CD

The goal of this project is to demonstrate how to:

1. Provision multiple virtual machines using Infrastructure as Code.
2. Configure a Kubernetes cluster on those virtual machines.
3. Deploy a simple web application to Kubernetes.
4. Manage the application deployment using GitOps with Argo CD.

---

## High-level architecture

```text
Local laptop / MacBook
│
├── Vagrant + VirtualBox
│   ├── k8s-control-01   192.168.56.10
│   ├── k8s-worker-01    192.168.56.11
│   └── k8s-worker-02    192.168.56.12
│
├── Ansible
│   ├── prepares all VMs
│   ├── installs K3s server on the control node
│   ├── joins worker nodes to the cluster
│   └── installs Argo CD
│
├── K3s Kubernetes cluster
│   ├── control-plane node
│   ├── two worker nodes
│   ├── Traefik ingress controller
│   └── web application namespace
│
└── Argo CD
    └── watches this GitHub repository and syncs the web application from Git
```

---

## Basic tool explanation

### Vagrant

Vagrant is a tool for creating and managing virtual machines from code. In this project, the `Vagrantfile` describes three Ubuntu virtual machines, and `vagrant up` creates them automatically.

### Ansible

Ansible is an automation tool used to configure servers. In this project, Ansible connects to the Vagrant VMs over SSH and installs/configures K3s and Argo CD.

### Kubernetes

Kubernetes is a container orchestration platform. It runs containerized applications, manages replicas, services, networking, and keeps the desired state of applications.

### K3s

K3s is a lightweight Kubernetes distribution. It is useful for local labs, edge environments, and smaller clusters because it is easier to install and needs fewer resources than a full Kubernetes setup.

### Argo CD

Argo CD is a GitOps tool for Kubernetes. It watches a Git repository and keeps the Kubernetes cluster synchronized with the desired state stored in Git.

### GitOps

GitOps means that Git is the source of truth. Instead of manually deploying applications with `kubectl apply`, the desired state is stored in Git and Argo CD applies it to the Kubernetes cluster.

---

## Repository structure

```text
.
├── CODEOWNERS
├── README.md
├── Vagrantfile
├── ansible/
│   ├── ansible.cfg
│   ├── inventory.ini
│   ├── group_vars/
│   │   └── all.yml
│   └── playbooks/
│       ├── argocd.yml
│       ├── k3s-agents.yml
│       ├── k3s-server.yml
│       ├── prepare.yml
│       └── site.yml
├── kubernetes/
│   ├── apps/
│   │   └── web/
│   │       ├── configmap.yaml
│   │       ├── deployment.yaml
│   │       ├── ingress.yaml
│   │       ├── namespace.yaml
│   │       └── service.yaml
│   └── argocd/
│       └── web-application.yaml
├── scripts/
│   └── kubeconfig.sh
└── .gitignore
```

### `CODEOWNERS`

Defines the repository owner for code review purposes.

### `Vagrantfile`

Defines the local virtual machines.

This project creates:

```text
k8s-control-01   192.168.56.10
k8s-worker-01    192.168.56.11
k8s-worker-02    192.168.56.12
```

### `ansible/`

Contains Ansible configuration and playbooks.

Main files:

* `ansible.cfg`
  Tells Ansible which inventory file to use and disables SSH host key checking for the local lab.

* `inventory.ini`
  Defines the Vagrant VMs and groups them into `control`, `workers`, and `k3s_cluster`.

* `group_vars/all.yml`
  Contains shared variables such as K3s server IP, Argo CD version, and the Flannel network interface.

* `playbooks/prepare.yml`
  Prepares all VMs for Kubernetes by installing packages, disabling swap, loading kernel modules, and configuring sysctl values.

* `playbooks/k3s-server.yml`
  Installs K3s server on the control node.

* `playbooks/k3s-agents.yml`
  Installs K3s agents on worker nodes and joins them to the cluster.

* `playbooks/argocd.yml`
  Installs Argo CD into the Kubernetes cluster.

* `playbooks/site.yml`
  Main playbook that runs the full setup in the correct order.

### `kubernetes/apps/web/`

Contains Kubernetes manifests for the simple web application.

Files:

* `namespace.yaml`
  Creates the `web` namespace.

* `configmap.yaml`
  Stores a simple `index.html` page.

* `deployment.yaml`
  Runs two Nginx web server pods.

* `service.yaml`
  Exposes the web pods inside the cluster.

* `ingress.yaml`
  Exposes the web application through Traefik using the host `web.local`.

### `kubernetes/argocd/`

Contains the Argo CD Application manifest.

* `web-application.yaml`
  Tells Argo CD to watch this GitHub repository, read manifests from `kubernetes/apps/web`, and sync them into the Kubernetes cluster.

### `scripts/`

Contains helper scripts.

* `kubeconfig.sh`
  Fetches the K3s kubeconfig from the control node and stores it locally in `.kube/config`.

### `.gitignore`

Ignores local runtime files such as:

* `.vagrant/`
* `.kube/`
* Ansible retry/cache files
* macOS files
* editor files

These files are local only and should not be committed to Git.

---

## Prerequisites

This lab runs on macOS, Linux, and Windows (via WSL). Choose your platform below.

### macOS (Intel or Apple Silicon)

```bash
# Install Homebrew package manager if you do not have it
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Vagrant, Ansible, kubectl, and Argo CD CLI
brew tap hashicorp/tap
brew install hashicorp/tap/hashicorp-vagrant
brew install ansible kubectl argocd
```

Install VirtualBox from the official website: https://www.virtualbox.org/wiki/Downloads

On Apple Silicon Mac, run this VirtualBox workaround once before starting VMs:

```bash
VBoxManage setextradata global "VBoxInternal/Devices/pcbios/0/Config/DebugLevel"
```

### Linux (Ubuntu / Debian)

```bash
# Ansible
sudo apt update
sudo apt install -y ansible

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Argo CD CLI
VERSION=$(curl -Ls https://raw.githubusercontent.com/argoproj/argo-cd/stable/VERSION)
curl -sSL -o /usr/local/bin/argocd \
  "https://github.com/argoproj/argo-cd/releases/download/v${VERSION}/argocd-linux-amd64"
sudo chmod +x /usr/local/bin/argocd

# Vagrant — download the .deb from HashiCorp
wget -O /tmp/vagrant.deb https://releases.hashicorp.com/vagrant/2.4.3/vagrant_2.4.3-1_amd64.deb
sudo dpkg -i /tmp/vagrant.deb
```

Install VirtualBox: `sudo apt install -y virtualbox`

### Windows (via WSL)

Ansible does not run natively on Windows. The recommended approach is to use
**WSL (Windows Subsystem for Linux)** which gives you a full Linux environment.

```powershell
# In PowerShell (as Administrator)
wsl --install
# Then restart your computer and open the Ubuntu app from the Start menu
```

Inside the WSL Ubuntu terminal, follow the Linux instructions above.

Install VirtualBox for Windows from: https://www.virtualbox.org/wiki/Downloads

VirtualBox is installed on Windows (not inside WSL). Vagrant running inside WSL
can control the Windows VirtualBox via the environment variable:

```bash
# Add to ~/.bashrc inside WSL
export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1"
export PATH="$PATH:/mnt/c/Program Files/Oracle/VirtualBox"
```

### Verify installed tools (all platforms)

```bash
vagrant --version
VBoxManage --version
ansible --version
kubectl version --client
argocd version --client
```

---

## Step 1: Clone the repository

```bash
git clone https://github.com/viliwilli/task-k8s-web-project.git
cd task-k8s-web-project
```

This downloads the project to your local machine.

---

## Step 2: Start the virtual machines

```bash
vagrant up
```

This command reads the `Vagrantfile` and creates three Ubuntu VMs in VirtualBox.

Verify the VM status:

```bash
vagrant status
```

Expected result:

```text
k8s-control-01   running
k8s-worker-01    running
k8s-worker-02    running
```

---

## Step 3: Test Ansible connectivity

Go to the Ansible directory:

```bash
cd ansible
```

Test if Ansible can connect to all VMs:

```bash
ansible all -m ping
```

Expected result:

```text
k8s-control-01 | SUCCESS
k8s-worker-01  | SUCCESS
k8s-worker-02  | SUCCESS
```

This confirms that Ansible can connect to all VMs over SSH.

---

## Step 4: Install K3s and Argo CD

Run the main Ansible playbook:

```bash
ansible-playbook playbooks/site.yml
```

This playbook does the following:

1. Prepares all VMs for Kubernetes.
2. Installs K3s server on `k8s-control-01`.
3. Installs K3s agents on `k8s-worker-01` and `k8s-worker-02`.
4. Installs Argo CD into the cluster.

After the playbook finishes, go back to the repository root:

```bash
cd ..
```

---

## Step 5: Configure local kubectl access

Fetch the kubeconfig from the control node:

```bash
./scripts/kubeconfig.sh
```

Then export the kubeconfig path:

```bash
export KUBECONFIG="$(pwd)/.kube/config"
```

This tells `kubectl` which Kubernetes cluster to use.

Verify the Kubernetes API endpoint:

```bash
kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}'; echo
```

Expected result:

```text
https://192.168.56.10:6443
```

---

## Step 6: Verify the Kubernetes cluster

Check Kubernetes nodes:

```bash
kubectl get nodes -o wide
```

Expected result:

```text
NAME             STATUS   ROLES           INTERNAL-IP
k8s-control-01   Ready    control-plane   192.168.56.10
k8s-worker-01    Ready    <none>          192.168.56.11
k8s-worker-02    Ready    <none>          192.168.56.12
```

Check all pods:

```bash
kubectl get pods -A
```

You should see system pods in `kube-system` and Argo CD pods in `argocd`.

---

## Step 7: Bootstrap the Argo CD application

Apply the Argo CD Application manifest:

```bash
kubectl apply -f kubernetes/argocd/web-application.yaml
```

This does not manually deploy the web application.
It only tells Argo CD:

```text
Watch this GitHub repository.
Watch the main branch.
Use the path kubernetes/apps/web.
Sync the desired state into the Kubernetes cluster.
```

This is the GitOps bootstrap step.

---

## Step 8: Verify Argo CD sync status

Check the Argo CD Application:

```bash
kubectl get application web-application -n argocd -o wide
```

Expected result:

```text
NAME              SYNC STATUS   HEALTH STATUS
web-application   Synced        Healthy
```

This means Argo CD successfully synchronized the Kubernetes cluster with the Git repository.

---

## Step 9: Verify the web application

Check resources in the `web` namespace:

```bash
kubectl get all -n web
```

Expected result:

```text
pod/web-...       1/1 Running
service/web       ClusterIP
deployment/web    2/2 Ready
```

Check the Ingress:

```bash
kubectl get ingress -n web -o wide
```

Expected result:

```text
NAME   CLASS     HOSTS       ADDRESS                                     PORTS
web    traefik   web.local   192.168.56.10,192.168.56.11,192.168.56.12   80
```

Test the web application:

```bash
curl -H "Host: web.local" http://192.168.56.10/
```

Expected result contains:

```html
<h1>Hello from Kubernetes!</h1>
```

This confirms that the request path works:

```text
Local laptop
→ 192.168.56.10:80
→ Traefik Ingress Controller
→ Ingress rule for web.local
→ Kubernetes Service web
→ Nginx web pod
```

---

## Optional: Open Argo CD UI

Port-forward the Argo CD server:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Open in browser:

```text
https://localhost:8080
```

Get the initial admin password:

```bash
argocd admin initial-password -n argocd
```

Login:

```text
Username: admin
Password: output from the command above
```

The browser may show a certificate warning because Argo CD uses a self-signed certificate in this local setup.

---

## GitOps workflow explanation

The web application is not deployed manually with:

```bash
kubectl apply -f kubernetes/apps/web
```

Instead, Argo CD watches this repository:

```text
repoURL: https://github.com/viliwilli/task-k8s-web-project.git
targetRevision: main
path: kubernetes/apps/web
```

That means:

```text
Change in Git
→ merge to main
→ Argo CD detects the change
→ Argo CD syncs Kubernetes
→ cluster matches Git
```

In a team workflow, changes should be done through pull requests.

Example:

```bash
git checkout -b feature/update-web-page
# edit Kubernetes manifests
git add .
git commit -m "feat: update web page"
git push -u origin feature/update-web-page
```

Then open a Pull Request to `main`.

After merge, Argo CD syncs the new desired state to the cluster.

---

## Important networking note

Vagrant creates two network interfaces inside each VM:

```text
eth0 = NAT network
eth1 = host-only network
```

The NAT interface usually has the same IP on all VMs:

```text
10.0.2.15
```

This is not suitable for Kubernetes inter-node communication.

The host-only interface has unique IP addresses:

```text
k8s-control-01   192.168.56.10
k8s-worker-01    192.168.56.11
k8s-worker-02    192.168.56.12
```

For this reason, K3s/Flannel is configured to use:

```text
eth1
```

This is configured in:

```text
ansible/group_vars/all.yml
```

with:

```yaml
k3s_flannel_iface: "eth1"
```

And passed to K3s using:

```text
--flannel-iface eth1
```

This makes multi-node pod networking work correctly.

---

## Useful daily commands

### Start the lab

```bash
cd task-k8s-web-project
vagrant up
cd ansible
ansible all -m ping
cd ..
./scripts/kubeconfig.sh
export KUBECONFIG="$(pwd)/.kube/config"
kubectl get nodes -o wide
```

### Stop the lab without deleting it

```bash
vagrant halt
```

This powers off the VMs but keeps their disks and state.

### Delete the lab completely

```bash
vagrant destroy -f
```

This removes all VMs.
To recreate the environment, run:

```bash
vagrant up
cd ansible
ansible-playbook playbooks/site.yml
cd ..
./scripts/kubeconfig.sh
export KUBECONFIG="$(pwd)/.kube/config"
kubectl get nodes -o wide
```

---

## Troubleshooting

### Problem: kubectl tries to connect to localhost:8080

Error example:

```text
The connection to the server localhost:8080 was refused
```

Reason:

`kubectl` does not know which kubeconfig to use.

Fix:

```bash
export KUBECONFIG="$(pwd)/.kube/config"
```

Then test:

```bash
kubectl get nodes -o wide
```

---

### Problem: Argo CD Application is Unknown

Error example:

```text
SYNC STATUS: Unknown
```

Possible reason:

Argo CD components cannot communicate internally through the Kubernetes network.

In this project, this was solved by explicitly configuring K3s/Flannel to use the correct VirtualBox host-only network interface:

```yaml
k3s_flannel_iface: "eth1"
```

Then rebuild the lab:

```bash
vagrant destroy -f
vagrant up
cd ansible
ansible-playbook playbooks/site.yml
```

---

### Problem: curl returns 404 page not found

Command:

```bash
curl -H "Host: web.local" http://192.168.56.10/
```

Possible reason:

Traefik is reachable, but the Ingress rule is missing or not synced yet.

Check:

```bash
kubectl get ingress -n web -o wide
kubectl get application web-application -n argocd -o wide
```

Expected result:

```text
web-application   Synced   Healthy
```

and:

```text
web   traefik   web.local   192.168.56.10,192.168.56.11,192.168.56.12   80
```

---

## Validation commands

Use these commands to prove that the solution works:

```bash
kubectl get nodes -o wide
kubectl get pods -A
kubectl get application web-application -n argocd -o wide
kubectl get all -n web
kubectl get ingress -n web -o wide
curl -H "Host: web.local" http://192.168.56.10/
```

Expected highlights:

```text
All Kubernetes nodes are Ready.
Argo CD pods are Running.
web-application is Synced and Healthy.
The web namespace contains 2 running web pods.
Ingress exposes host web.local.
curl returns the HTML page.
```

---

## Cleanup

To stop the VMs:

```bash
vagrant halt
```

To delete all VMs:

```bash
vagrant destroy -f
```

To remove local kubeconfig:

```bash
rm -rf .kube/
```

---

## Makefile shortcuts

Instead of running individual commands manually, use `make`:

```bash
make help        # show all available targets
make up          # start VMs (vagrant up)
make ping        # test Ansible SSH connectivity
make setup       # run full Ansible provisioning (K3s + Argo CD)
make kubeconfig  # fetch kubeconfig from control node
make bootstrap   # apply the Argo CD Application manifest
make status      # show nodes, Argo CD status, web namespace
make web-test    # curl the web application and check the response
make argocd-ui   # port-forward Argo CD UI to https://localhost:8080
make down        # stop VMs without deleting them
make clean       # destroy all VMs
make lint        # run yamllint + ansible-lint locally
```

Quick start using only Make:

```bash
make up
make ping
make setup
make kubeconfig
make bootstrap
make status
make web-test
```

---

## GitHub Actions CI/CD workflows

This repository contains three automated workflows in `.github/workflows/`.
They run automatically on GitHub — you do not need to trigger them manually.

### What is a GitHub Actions workflow?

A workflow is a YAML file that describes a sequence of steps to run in the
cloud (on GitHub's servers). Every time you push code or open a Pull Request,
GitHub runs the relevant workflows automatically.

Think of them as a robot that checks your code before it reaches production.

---

### auto-pr.yml — Automatic Draft Pull Request

**When it runs:** When you push a new branch to GitHub.

**What it does:**
Automatically creates a Draft Pull Request for your branch. You no longer
need to go to GitHub and click "Compare & pull request" manually.

```
git push -u origin Jira-ticket-010
    ↓
auto-pr.yml triggers
    ↓
Draft PR created: "Jira Ticket 010"
    ↓
pr-validate.yml triggers automatically on the new PR
```

A Draft PR:
- Shows up in the PR list (visible to reviewers)
- Runs CI checks immediately
- Cannot be accidentally merged (must be marked "Ready for review" first)

---

### pr-validate.yml — Pull Request Validation (Plan)

**When it runs:** Every time a Pull Request to `main` is opened or updated.

**What it does:**
Runs 4 checks in parallel to verify the changes are correct BEFORE merge.
Think of it like `terraform plan` — it shows what would happen without
actually changing anything.

| Check | What it validates |
|-------|------------------|
| YAML Syntax | All `.yml`/`.yaml` files have valid YAML syntax |
| Ansible Lint | Ansible playbooks follow best practices |
| Kubernetes Manifests | K8s YAML matches the official Kubernetes schemas |
| Conventional Commits | Commit messages follow the format in `repo-config.json` |

After all checks finish, the workflow posts a summary comment on the PR:

```
## 🔍 PR Validation Summary (Plan)

| Check                | Status     |
|----------------------|------------|
| YAML Syntax          | ✅ passed  |
| Ansible Lint         | ✅ passed  |
| Kubernetes Manifests | ✅ passed  |
| Conventional Commits | ✅ passed  |
```

If any check fails, fix the issue and push again — the comment will update.

---

### post-merge.yml — Post-Merge Summary (Apply)

**When it runs:** Every time a commit lands on `main` (i.e. after PR merge).

**What it does:**
Runs the same validations again on the merged state, then generates a
deployment summary in the Actions UI. Think of it like `terraform apply` —
it confirms the new desired state is valid and shows what Argo CD will sync.

**Where to see the summary:**
GitHub → Actions tab → select the run → Summary tab

After this workflow passes, Argo CD detects the change on `main` (within ~3 minutes)
and synchronises the Kubernetes cluster automatically.

---

## Conventional Commits

All commit messages in this repository must follow the
[Conventional Commits](https://www.conventionalcommits.org/) format.

The allowed types are defined in `repo-config.json`:

```
type(optional-scope): short description
```

Examples:

```bash
feat: add nginx deployment manifest
fix(ingress): correct hostname from web to web.local
docs: update README with Linux prerequisites
refactor(ansible): split prepare playbook into separate tasks
chore: bump ArgoCD version to v3.4.4
ci: add yamllint to PR validation workflow
break: remove support for single-node cluster
```

### Why conventional commits?

- The Git history becomes machine-readable and easy to search
- Each commit type signals the kind of change (`feat` = new thing, `fix` = bug)
- Automated changelogs can be generated from the commit history
- Code reviewers immediately understand the scope and intent of a change

### How the type affects releases (from `repo-config.json`)

| Type | Meaning | Release impact |
|------|---------|----------------|
| `feat` | New feature | minor version bump |
| `fix` | Bug fix | patch version bump |
| `break` | Breaking change | major version bump |
| `refactor` | Code restructure | no release |
| `docs` | Documentation only | no release |
| `chore` | Maintenance | no release |
| `ci` | CI/CD pipeline | no release |

### Fixing a bad commit message

If you forgot the conventional format, fix it before pushing:

```bash
# Fix the last commit message
git commit --amend -m "feat: add Argo CD application manifest"

# Fix an older commit (interactive rebase)
git rebase -i origin/main
# Change 'pick' to 'reword' next to the commit you want to fix
```

### Checking commit messages locally

```bash
# Check all commits in your branch vs main
git log origin/main..HEAD --format="%s" | ./scripts/check-commits.sh
```

---

## Branch protection and CODEOWNERS

### What is branch protection?

Branch protection is a GitHub setting that prevents direct commits to `main`.
Every change must go through a Pull Request and receive an approval before
merging. This enforces code review and ensures CI checks always run.

### How to enable branch protection on your repository

1. Go to your repository on GitHub
2. Click **Settings** → **Branches**
3. Click **Add branch protection rule**
4. Set **Branch name pattern** to `main`
5. Enable these options:
   - ✅ **Require a pull request before merging**
   - ✅ **Require approvals** (set minimum to 1)
   - ✅ **Require review from Code Owners**
   - ✅ **Require status checks to pass before merging**
     - Add: `YAML Syntax Check`
     - Add: `Ansible Lint`
     - Add: `Kubernetes Manifest Validation`
     - Add: `Conventional Commits Check`
   - ✅ **Do not allow bypassing the above settings**
6. Click **Save changes**

After this is set up, nobody (not even the repository owner) can push directly
to `main`. Every change requires a PR.

### What is CODEOWNERS?

The `CODEOWNERS` file defines who must review changes before they can be merged.

This repository has:

```
* @viliwilli @vcillik
```

This means: for every file in the repository, GitHub will request a review from
`@viliwilli` or `@vcillik` before the PR can be merged.

The "Require review from Code Owners" branch protection rule (step 5 above)
is what actually enforces this requirement.

---

## Summary

This project demonstrates a complete local DevOps workflow:

```text
Vagrant provisions virtual machines.
Ansible configures the machines.
K3s runs Kubernetes.
Argo CD manages the application using GitOps.
Kubernetes runs and exposes the web application.
GitHub Actions validates every change before it reaches main.
```

The desired application state is stored in Git, and Argo CD keeps the Kubernetes cluster synchronized with that state.
