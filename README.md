# Kubernetes GitOps Web Project

A local DevOps lab that provisions virtual machines, installs a Kubernetes cluster, and
deploys a simple web application — all managed through Git using a GitOps approach.

**What you will see at the end:**
Open a browser and go to `http://web.local` — a web page served from inside a real
Kubernetes cluster running on your laptop.

---

## What is this project and why does it exist?

This project is a Senior DevOps interview task. The goal is to demonstrate how modern
infrastructure is built, deployed, and managed in a professional environment.

Every tool used here is industry-standard. You will find Vagrant, Ansible, Kubernetes,
and Argo CD in real companies every day.

---

## Requirements and deliverables

### 4 requirements (all met)

| # | Requirement | Implemented by |
|---|-------------|---------------|
| 1 | Deploy minimum 3 VMs using an IaC tool — fully automated, reproducible | `Vagrantfile` — `vagrant up` creates all 3 VMs from scratch |
| 2 | Install and configure a Kubernetes cluster on the VMs | `ansible/playbooks/` — K3s installed via Ansible across all nodes |
| 3 | Deploy a simple web application (single HTML page, Nginx) | `kubernetes/apps/web/` — Nginx + ConfigMap + Service + Ingress |
| 4 | Use a GitOps tool (Argo CD / Flux) — Git repo reflects cluster state | `kubernetes/argocd/web-application.yaml` — Argo CD auto-syncs on every merge |

### 5 deliverables (all present)

| Deliverable | File(s) |
|-------------|---------|
| IaC scripts | `Vagrantfile` |
| Ansible playbooks | `ansible/playbooks/` (prepare, k3s-server, k3s-agents, argocd) |
| Kubernetes manifests | `kubernetes/apps/web/` (namespace, configmap, deployment, service, ingress) |
| GitOps configuration | `kubernetes/argocd/web-application.yaml` |
| Documentation | `README.md` (this file) |

### 4 evaluation criteria

| Criterion | How this project meets it |
|-----------|--------------------------|
| **Correctness** | All components work together end-to-end: `make up && make setup && make bootstrap` → `http://web.local` shows the page |
| **Efficiency** | K3s (lightweight Kubernetes), resource limits on pods, non-root Nginx, idempotent Ansible tasks |
| **Clarity** | Every file has comments explaining what it does and why; README covers every step |
| **Scalability** | Adding a worker node = one new entry in `NODES` (Vagrantfile) and `inventory.ini`; see [Scaling the cluster](#scaling-the-cluster) |

---

## ELI5 — Explain it like I am 6 years old

This section explains every tool as simply as possible.
If you already know a tool, skip its section.

### What is VirtualBox?

Imagine you have a real computer (your MacBook or laptop).
VirtualBox lets you create **fake computers inside your real computer** — like running
a computer simulation. Each fake computer acts like a real one: it has its own operating
system, files, and network. You can start it, stop it, and delete it.

In this project we create **three fake computers** to simulate a real server environment.

### What is Vagrant?

Creating fake computers in VirtualBox by clicking buttons is slow and error-prone.
**Vagrant is a recipe book for VirtualBox.** You write a file called `Vagrantfile`
that says: *"create three computers with Ubuntu, each with 2GB RAM and a fixed IP address."*
Then you run `vagrant up` and Vagrant reads the recipe and does everything automatically.

This means anyone can recreate the exact same environment on any laptop just by running
one command.

### What is Ansible?

After Vagrant creates the fake computers, they are empty — just a fresh Ubuntu install.
**Ansible is a remote control for computers.** You write a list of tasks in a YAML file
(called a *playbook*) like: *"install curl, disable swap, install Kubernetes"*, and Ansible
connects to all three computers over SSH and runs those tasks automatically.

No need to log in to each computer and type commands manually.

### What is Kubernetes?

Imagine you have an app and you want to run it. You could just start it on one server — but
what if that server crashes? Your app is down. What if millions of people visit at once?
One server is not enough.

**Kubernetes is a manager for your apps.** It:
- Runs multiple copies of your app (so if one crashes, others keep working)
- Restarts crashed apps automatically
- Spreads traffic across copies
- Lets you update apps without downtime

Instead of telling Kubernetes *"do this"*, you tell it *"I want 2 copies of my app running"*.
Kubernetes figures out how to make that happen and keeps it that way.

### What is K3s?

The full version of Kubernetes is powerful but needs a lot of computer resources.
**K3s is a lightweight Kubernetes** — it does the same job but uses much less RAM and CPU.
It is made for local labs, small servers, and edge devices.

In this project we use K3s because our fake computers only have 2GB RAM each.
K3s is a certified Kubernetes distribution — everything you learn on K3s works on full Kubernetes.

### What is Argo CD?

You have Kubernetes running. How do you deploy your app?
One way: run `kubectl apply -f app.yaml` manually every time you change something.
This is error-prone — what if you forget? What if someone else changed the cluster directly?

**Argo CD is a robot that watches your Git repository.** When something in the
`kubernetes/apps/web/` folder changes on the `main` branch, Argo CD automatically
applies those changes to the cluster. The cluster always reflects what is in Git.

You never deploy manually. You push to Git, Argo CD does the rest.

### What is GitOps?

**GitOps is a way of working where Git is the only source of truth.**

Traditional approach:
- Developer runs `kubectl apply` → cluster changes
- Nobody knows what changed, or who did it, or when

GitOps approach:
- Developer commits to Git → Argo CD detects the change → cluster updates
- Full history in Git, code review before changes, automatic sync

The cluster should always look exactly like what is in the Git repository.
If someone changes the cluster directly (without Git), Argo CD resets it back.

### What is Traefik?

When a request comes to your cluster from a browser, something needs to decide:
*"which app should receive this request?"*

**Traefik is a reverse proxy and traffic router.** It reads the hostname of the request
(`web.local`) and forwards it to the correct Kubernetes Service.

K3s includes Traefik by default — you do not need to install it separately.

### What is an Ingress?

An **Ingress is a routing rule** that tells Traefik what to do with incoming requests.
In this project the Ingress says: *"requests with hostname `web.local` → send to Service `web`"*.

### What is a ConfigMap?

A **ConfigMap is a storage box for plain text** inside Kubernetes.
In this project it stores the `index.html` file content. The Nginx pods mount it as a file.

This means you can change the web page by editing the ConfigMap in Git —
no need to rebuild a Docker image.

### What is a Deployment?

A **Deployment is the instruction for running your app.** It says:
*"run 2 copies of this Nginx container, restart them if they crash, here is the Docker image to use."*

Kubernetes reads the Deployment and makes it happen.

### What is a Service?

Pods (containers) have temporary IP addresses — they can change when pods restart.
A **Service is a permanent, stable address** inside the cluster.
Other things inside the cluster can always reach your app via the Service name, even if pods restart.

### What is a Namespace?

A **Namespace is a folder inside Kubernetes** to keep things organized.
All web app resources live in the `web` namespace.
Argo CD lives in the `argocd` namespace.
System components live in `kube-system`.

### What is GitHub Actions?

**GitHub Actions are robots that wake up when you push code or open a Pull Request.**
You write a YAML file in `.github/workflows/` that says what to do.

In this project the robots:
- Validate your YAML, Ansible, and Kubernetes files before merge
- Check that commit messages follow the Conventional Commits format
- Write a deployment summary after merge

### What are Conventional Commits?

**Conventional Commits is a naming rule for your commit messages.**
Instead of writing `fixed stuff`, you write `fix(ingress): correct hostname typo`.

The format is: `type(optional-scope): short description`

This makes the Git history readable, searchable, and can be used to generate changelogs.

### What is CODEOWNERS?

**CODEOWNERS is a file that says who must approve Pull Requests.**
In this project `@viliwilli` must review and approve every change before it can be merged to `main`.

---

## Architecture overview

```text
Your laptop
│
├── VirtualBox (the virtualisation engine)
│   └── Vagrant (provisions the VMs from Vagrantfile)
│       ├── k8s-control-01   192.168.56.10   (Kubernetes control plane)
│       ├── k8s-worker-01    192.168.56.11   (runs your pods)
│       └── k8s-worker-02    192.168.56.12   (runs your pods)
│
├── Ansible (configures the VMs over SSH)
│   ├── installs system packages, disables swap
│   ├── installs K3s server on control-01
│   ├── joins worker-01 and worker-02 to the cluster
│   └── installs Argo CD into the cluster
│
├── K3s Kubernetes cluster
│   ├── Traefik Ingress Controller (routes web.local → web Service)
│   ├── argocd namespace (Argo CD pods)
│   └── web namespace (your Nginx web app)
│
└── Argo CD (GitOps engine)
    └── watches github.com/viliwilli/task-k8s-web-project
        └── syncs kubernetes/apps/web/ to the cluster automatically
```

Request flow when you open `http://web.local` in a browser:

```text
Browser (http://web.local)
  → /etc/hosts resolves web.local → 192.168.56.10
  → Traefik Ingress Controller on k8s-control-01:80
  → Ingress rule (host: web.local) → Service web
  → One of 2 Nginx pods
  → index.html from ConfigMap
  → Browser displays the page
```

---

## Repository structure

```text
.
├── .ansible-lint                    # ansible-lint configuration
├── .gitignore                       # files to exclude from Git
├── .yamllint.yml                    # yamllint configuration
├── CODEOWNERS                       # who must review Pull Requests
├── Makefile                         # shortcut commands (make up, make setup, …)
├── README.md                        # this file
├── Vagrantfile                      # VM definitions (3 Ubuntu VMs)
├── repo-config.json                 # conventional commit types
│
├── .github/
│   ├── pull_request_template.md     # checklist pre-filled when opening a PR on GitHub
│   └── workflows/
│       ├── pr-validate.yml          # validates changes on every PR (plan)
│       ├── post-merge.yml           # runs after merge to main (apply summary)
│       └── validate.yml             # reusable validation (called by the above two)
│
├── ansible/
│   ├── ansible.cfg                  # Ansible settings (inventory path, SSH options)
│   ├── inventory.ini                # list of VMs and their IPs
│   ├── group_vars/
│   │   └── all.yml                  # shared variables (K3s version, Argo CD version)
│   └── playbooks/
│       ├── site.yml                 # master playbook — runs all steps in order
│       ├── prepare.yml              # installs packages, disables swap, loads kernel modules
│       ├── k3s-server.yml           # installs K3s control-plane on k8s-control-01
│       ├── k3s-agents.yml           # installs K3s agents and joins worker nodes
│       └── argocd.yml               # installs Argo CD into the cluster
│
├── kubernetes/
│   ├── apps/
│   │   └── web/                     # all resources for the web application
│   │       ├── namespace.yaml       # creates the 'web' namespace
│   │       ├── configmap.yaml       # stores index.html content
│   │       ├── deployment.yaml      # runs 2 Nginx pods
│   │       ├── service.yaml         # stable internal address for the pods
│   │       └── ingress.yaml         # routes web.local → Service web via Traefik
│   └── argocd/
│       └── web-application.yaml     # Argo CD Application (GitOps bootstrap)
│
└── scripts/
    ├── check-commits.sh             # validates commit messages against repo-config.json
    └── kubeconfig.sh                # fetches kubeconfig from control node to .kube/config
```

---

## Prerequisites

### macOS (Intel or Apple Silicon)

```bash
# Install Homebrew if you do not have it
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install required tools
brew tap hashicorp/tap
brew install hashicorp/tap/hashicorp-vagrant
brew install ansible kubectl argocd
```

Install VirtualBox from: https://www.virtualbox.org/wiki/Downloads

On **Apple Silicon only** — run this VirtualBox workaround once before starting VMs:

```bash
VBoxManage setextradata global "VBoxInternal/Devices/pcbios/0/Config/DebugLevel"
```

### Linux (Ubuntu / Debian)

```bash
# Ansible
sudo apt update && sudo apt install -y ansible

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Argo CD CLI
VERSION=$(curl -Ls https://raw.githubusercontent.com/argoproj/argo-cd/stable/VERSION)
curl -sSL -o /tmp/argocd "https://github.com/argoproj/argo-cd/releases/download/v${VERSION}/argocd-linux-amd64"
sudo install -m 0755 /tmp/argocd /usr/local/bin/argocd

# Vagrant
wget -O /tmp/vagrant.deb https://releases.hashicorp.com/vagrant/2.4.3/vagrant_2.4.3-1_amd64.deb
sudo dpkg -i /tmp/vagrant.deb

# VirtualBox
sudo apt install -y virtualbox
```

### Windows (via WSL)

Ansible does not run natively on Windows. Use **WSL** (Windows Subsystem for Linux):

```powershell
# In PowerShell as Administrator
wsl --install
# Restart, then open the Ubuntu app
```

Inside WSL Ubuntu, follow the Linux instructions above.

Install VirtualBox for Windows from: https://www.virtualbox.org/wiki/Downloads

Add to `~/.bashrc` inside WSL so Vagrant can talk to Windows VirtualBox:

```bash
export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1"
export PATH="$PATH:/mnt/c/Program Files/Oracle/VirtualBox"
```

### Verify all tools are installed

```bash
vagrant --version
VBoxManage --version
ansible --version
kubectl version --client
argocd version --client
```

---

## Quick start (using Make)

If you want a single command flow, use `make`. All commands are one line:

```bash
# 1. Clone the repository
git clone https://github.com/viliwilli/task-k8s-web-project.git
cd task-k8s-web-project

# 2. Start VMs
make up

# 3. Test SSH connectivity
make ping

# 4. Install K3s + Argo CD on the VMs
make setup

# 5. Fetch kubeconfig to use kubectl from your laptop
make kubeconfig
export KUBECONFIG="$(pwd)/.kube/config"

# 6. Tell Argo CD to start watching this repository
make bootstrap

# 7. Verify everything is running
make status

# 8. Add web.local to /etc/hosts and open in browser
make hosts
# → open http://web.local in your browser
```

Run `make help` at any time to see all available targets.

---

## Step-by-step setup (detailed)

### Step 1: Clone the repository

```bash
git clone https://github.com/viliwilli/task-k8s-web-project.git
cd task-k8s-web-project
```

---

### Step 2: Start the virtual machines

```bash
make up
# same as: vagrant up
```

Vagrant reads `Vagrantfile` and creates three Ubuntu VMs in VirtualBox.
This takes a few minutes the first time.

Verify:

```bash
vagrant status
```

Expected:

```text
k8s-control-01   running
k8s-worker-01    running
k8s-worker-02    running
```

---

### Step 3: Test Ansible connectivity

```bash
make ping
# same as: cd ansible && ansible all -m ping
```

This verifies that Ansible can SSH into all three VMs.

Expected:

```text
k8s-control-01 | SUCCESS
k8s-worker-01  | SUCCESS
k8s-worker-02  | SUCCESS
```

---

### Step 4: Install K3s and Argo CD

```bash
make setup
# same as: cd ansible && ansible-playbook playbooks/site.yml
```

Ansible runs four playbooks in sequence:

1. `prepare.yml` — installs system packages, disables swap, loads kernel modules
2. `k3s-server.yml` — installs K3s control-plane on `k8s-control-01`
3. `k3s-agents.yml` — installs K3s agents on both worker nodes and joins them
4. `argocd.yml` — installs Argo CD into the cluster

This takes 5–10 minutes.

---

### Step 5: Configure kubectl access

```bash
make kubeconfig
# same as: ./scripts/kubeconfig.sh
```

This fetches the K3s kubeconfig file from the control node and saves it to `.kube/config`.

Then export it so `kubectl` knows which cluster to use:

```bash
export KUBECONFIG="$(pwd)/.kube/config"
```

> **Note:** This `export` only lasts for the current terminal session.
> Add it to your `~/.zshrc` or `~/.bashrc` to make it permanent.

Verify:

```bash
kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}'; echo
```

Expected: `https://192.168.56.10:6443`

---

### Step 6: Verify the cluster

```bash
make status
```

Expected output includes:

```text
=== Kubernetes Nodes ===
NAME             STATUS   ROLES
k8s-control-01   Ready    control-plane
k8s-worker-01    Ready    <none>
k8s-worker-02    Ready    <none>
```

---

### Step 7: Bootstrap Argo CD

```bash
make bootstrap
# same as: kubectl apply -f kubernetes/argocd/web-application.yaml
```

This applies one manifest that tells Argo CD:

```text
Watch: github.com/viliwilli/task-k8s-web-project
Branch: main
Path: kubernetes/apps/web
Sync to: the Kubernetes cluster
```

This is the **GitOps bootstrap** — a one-time step. After this, every change merged
to `main` is automatically synced to the cluster by Argo CD.

---

### Step 8: Verify Argo CD sync status

```bash
kubectl get application web-application -n argocd -o wide
```

Expected:

```text
NAME              SYNC STATUS   HEALTH STATUS
web-application   Synced        Healthy
```

`Synced` = cluster matches Git.
`Healthy` = all pods are running.

---

### Step 9: Verify the web application

```bash
make status
```

Check that the `web` namespace contains running pods and an Ingress:

```text
=== Web Namespace ===
pod/web-...       1/1 Running
service/web       ClusterIP
deployment/web    2/2 Ready

=== Ingress ===
NAME   CLASS     HOSTS       ADDRESS
web    traefik   web.local   192.168.56.10,...
```

Test with curl:

```bash
make web-test
# same as: curl -H "Host: web.local" http://192.168.56.10/
```

Expected: HTML page containing `<h1>Hello from Kubernetes!</h1>`

---

### Step 10: Open in a browser

Add `web.local` to your system's local DNS:

```bash
make hosts
# same as: echo "192.168.56.10 web.local" | sudo tee -a /etc/hosts
```

Open your browser and go to:

```
http://web.local
```

You will see a white card page:

```
Hello from Kubernetes!

This simple web application is deployed to a local K3s cluster.
The deployment is managed using Argo CD with a GitOps approach.
Repository path: kubernetes/apps/web
```

To remove the hosts entry later:

```bash
make hosts-remove
```

---

### Optional: Open Argo CD UI

```bash
make argocd-ui
# same as: kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Open: `https://localhost:8080`

Get the admin password:

```bash
argocd admin initial-password -n argocd
```

Login with username `admin` and the password above.
The browser will show a certificate warning — this is expected for a local self-signed cert, click "Proceed".

---

## Makefile reference

| Target | What it does |
|--------|-------------|
| `make help` | Show all available targets |
| `make up` | Start VMs (`vagrant up`) |
| `make ping` | Test Ansible SSH connectivity |
| `make setup` | Run full Ansible provisioning |
| `make kubeconfig` | Fetch kubeconfig from control node |
| `make bootstrap` | Apply Argo CD Application manifest |
| `make status` | Show nodes, Argo CD app, web namespace |
| `make web-test` | Test the app with curl |
| `make argocd-ui` | Port-forward Argo CD to localhost:8080 |
| `make hosts` | Add `web.local` to `/etc/hosts` |
| `make hosts-remove` | Remove `web.local` from `/etc/hosts` |
| `make down` | Stop VMs without deleting them |
| `make clean` | Destroy all VMs permanently |
| `make lint` | Run yamllint + ansible-lint locally |

---

## GitOps workflow — how changes reach the cluster

The web application is **never deployed manually**. The flow is always through Git:

```text
1. Create a branch
   git checkout -b Jira-ticket-011

2. Make a change (e.g. edit kubernetes/apps/web/configmap.yaml)

3. Commit with a conventional commit message
   git add .
   git commit -m "feat(web): update page title"

4. Push the branch
   git push -u origin Jira-ticket-011

5. Open GitHub → your repository → click "New pull request" → select your branch
   The PR description is pre-filled with the checklist from pull_request_template.md

6. PR validation runs automatically (yaml, ansible, kubernetes, commit checks)

7. Reviewer approves → merge to main

8. Argo CD detects the change on main (within ~3 minutes)
   Argo CD syncs: kubectl apply -f kubernetes/apps/web/
   Kubernetes updates the running pods

9. make status → web-application shows Synced + Healthy
```

---

## Pull Request template

The file `.github/pull_request_template.md` is a **GitHub feature** — not a workflow.

When you click "New pull request" on GitHub, the description text box is automatically
pre-filled with the template. You do not have to remember what to write — the checklist
is already there:

- What changed and why
- Type of change (feat / fix / docs / …) — must match your commit message type
- Which Kubernetes manifests were affected
- Which Ansible playbooks were affected
- Testing checklist (what you ran locally before opening the PR)

This makes it easy for a reviewer (and for yourself) to see exactly what was tested
before merging.

---

## GitHub Actions CI/CD workflows

The `.github/workflows/` directory contains three files.
They run automatically on GitHub — you do not start them manually.

### validate.yml — Reusable validation (not triggered directly)

This file contains the validation logic that is **shared** between `pr-validate.yml`
and `post-merge.yml`. It is defined once to avoid copy-pasting the same checks twice.

It runs three jobs in parallel:
- **YAML Syntax** — checks all `.yml` files in `ansible/` and `kubernetes/` with `yamllint`
- **Ansible Lint** — checks Ansible playbooks follow best practices with `ansible-lint`
- **Kubernetes Manifests** — validates K8s YAML against official schemas with `kubeconform`

### pr-validate.yml — PR validation ("plan")

**Triggered by:** opening or updating a Pull Request targeting `main`.

Calls `validate.yml` for file checks, plus:
- **Conventional Commits** — validates commit messages against `repo-config.json`
- **PR Comment** — posts a pass/fail table directly on the PR

```
## PR Validation Summary

| Check                          | Result     |
|--------------------------------|------------|
| YAML · Ansible · Kubernetes    | ✅ passed  |
| Conventional Commits           | ✅ passed  |

✅ All checks passed. Ready to merge.
```

If you push more commits, the comment **updates in place** — it does not create a new one.

### post-merge.yml — Post-merge summary ("apply")

**Triggered by:** any push to `main` (i.e. after a PR is merged).

Calls `validate.yml` again to confirm the merged state is clean, then writes a
**deployment summary** to the Actions UI (Actions tab → the run → Summary tab):

```
## Deployment Summary

Merged by viliwilli · abc1234

✅ All validations passed. Argo CD will sync the cluster within ~3 minutes.

| File                              | Kind        | Name            |
|-----------------------------------|-------------|-----------------|
| kubernetes/apps/web/configmap.yaml | ConfigMap  | web-content     |
| kubernetes/apps/web/deployment.yaml | Deployment | web            |
| ...                               | ...         | ...             |
```

---

## Conventional Commits

All commits must follow the format defined in `repo-config.json`:

```
type(optional-scope): short description
```

Examples:

```bash
feat: add Nginx deployment
fix(ingress): correct hostname from web to web.local
docs: update README prerequisites
refactor(ansible): split prepare into two playbooks
chore: bump Argo CD version to v3.5.0
ci: add kubeconform to PR validation
break: require 3 worker nodes instead of 2
```

| Type | Meaning | Version bump |
|------|---------|-------------|
| `feat` | New feature | minor |
| `fix` | Bug fix | patch |
| `break` | Breaking change | major |
| `refactor` | Reorganise, no behaviour change | none |
| `docs` | Documentation only | none |
| `chore` | Maintenance, dependency update | none |
| `ci` | CI/CD pipeline change | none |

**Check commit messages locally before pushing:**

```bash
git log origin/main..HEAD --no-merges --format="%s" | ./scripts/check-commits.sh
```

**Fix a bad commit message:**

```bash
# Fix only the last commit
git commit --amend -m "feat: add Argo CD application manifest"

# Fix an older commit
git rebase -i origin/main
# Change 'pick' to 'reword' on the commit you want to fix
```

---

## Branch protection and CODEOWNERS

### Branch protection

Branch protection prevents anyone from pushing directly to `main`.
Every change must go through a Pull Request with at least one approval.

**How to enable it:**

1. GitHub → Settings → Branches → Add branch protection rule
2. Branch name pattern: `main`
3. Enable:
   - ✅ Require a pull request before merging
   - ✅ Require approvals — set to 1
   - ✅ Require review from Code Owners
   - ✅ Require status checks to pass:
     - `YAML Syntax`
     - `Ansible Lint`
     - `Kubernetes Manifests`
     - `Conventional Commits`
   - ✅ Do not allow bypassing the above settings
4. Save changes

### CODEOWNERS

The `CODEOWNERS` file at the repository root contains:

```
* @viliwilli @vcillik
```

This means GitHub requests a review from `@viliwilli` or `@vcillik` for every
file change. The "Require review from Code Owners" protection rule enforces this.

---

## Important networking note

Vagrant creates **two network interfaces** inside each VM:

| Interface | Type | IP |
|-----------|------|----|
| `eth0` | NAT | `10.0.2.15` (same on all VMs) |
| `eth1` | Host-only | `192.168.56.10/11/12` (unique per VM) |

The `eth0` NAT IP is the same on all three VMs. Kubernetes pods on different nodes
would not be able to talk to each other if Flannel used it.

**K3s is configured to use `eth1`** via:

```yaml
# ansible/group_vars/all.yml
k3s_flannel_iface: "eth1"
```

This makes multi-node pod networking work correctly.

---

## Troubleshooting

### `kubectl` tries to connect to `localhost:8080`

```text
The connection to the server localhost:8080 was refused
```

`kubectl` does not know which cluster to use. Fix:

```bash
export KUBECONFIG="$(pwd)/.kube/config"
```

---

### Argo CD Application shows `Unknown` or `OutOfSync`

Argo CD components cannot communicate across nodes because the wrong network interface
is being used. Verify that `k3s_flannel_iface: "eth1"` is set in `ansible/group_vars/all.yml`,
then rebuild:

```bash
make clean
make up
make setup
make kubeconfig && export KUBECONFIG="$(pwd)/.kube/config"
make bootstrap
```

---

### `curl` returns `404`

Traefik is reachable but the Ingress rule is missing or not synced yet.

```bash
kubectl get ingress -n web -o wide
kubectl get application web-application -n argocd -o wide
```

Both should show the Ingress with `web.local` and the application as `Synced + Healthy`.
If the application is not synced, wait 3 minutes or force a sync:

```bash
kubectl annotate application web-application argocd.argoproj.io/refresh=normal -n argocd
```

---

### `make web-test` passes but browser shows nothing

You have not added `web.local` to `/etc/hosts`:

```bash
make hosts
```

---

## Validation — prove the solution works

Run all of these to demonstrate a working setup:

```bash
kubectl get nodes -o wide                              # all nodes Ready
kubectl get pods -A                                    # system + argocd pods Running
kubectl get application web-application -n argocd -o wide  # Synced + Healthy
kubectl get all -n web                                 # 2 web pods Running
kubectl get ingress -n web -o wide                     # web.local on 80
make web-test                                          # HTML response from curl
# open http://web.local in browser                    # page visible
```

---

## Scaling the cluster

The cluster is designed to scale by adding worker nodes. No code changes are needed in
Kubernetes manifests or Argo CD — only the VM and Ansible inventory need to be updated.

**Step 1** — Add the new node to `Vagrantfile`:

```ruby
NODES = [
  { name: "k8s-control-01", ip: "192.168.56.10", memory: 2048, cpus: 2 },
  { name: "k8s-worker-01",  ip: "192.168.56.11", memory: 2048, cpus: 2 },
  { name: "k8s-worker-02",  ip: "192.168.56.12", memory: 2048, cpus: 2 },
  { name: "k8s-worker-03",  ip: "192.168.56.13", memory: 2048, cpus: 2 },  # new
]
```

**Step 2** — Add it to `ansible/inventory.ini`:

```ini
[workers]
k8s-worker-01 ansible_host=192.168.56.11
k8s-worker-02 ansible_host=192.168.56.12
k8s-worker-03 ansible_host=192.168.56.13  # new
```

**Step 3** — Start and provision the new VM only:

```bash
vagrant up k8s-worker-03
cd ansible && ansible-playbook playbooks/k3s-agents.yml --limit k8s-worker-03
```

**Step 4** — Verify:

```bash
kubectl get nodes -o wide
# k8s-worker-03 should appear as Ready
```

Argo CD and the web application require no changes — Kubernetes automatically schedules
pods across all available nodes.

---

## Cleanup

```bash
make down        # stop VMs (keeps disks, fast to resume)
make up          # resume stopped VMs

make clean       # destroy all VMs permanently
# To recreate from scratch:
make up && make setup && make kubeconfig
export KUBECONFIG="$(pwd)/.kube/config"
make bootstrap && make status
```

Remove local files:

```bash
rm -rf .kube/      # remove kubeconfig
make hosts-remove  # remove web.local from /etc/hosts
```

---

## Summary

This project demonstrates a complete local DevOps pipeline:

```text
Vagrantfile          → describes the virtual machines
vagrant up           → creates them in VirtualBox
Ansible playbooks    → configures K3s + Argo CD on the VMs
Argo CD              → watches this Git repo and syncs Kubernetes automatically
kubernetes/apps/web/ → the desired state of the web application
http://web.local     → the running result in your browser
GitHub Actions       → validates every change before it reaches main
```

The key principle: **Git is the single source of truth.**
No manual `kubectl apply`. No manual deploys. Everything goes through a Pull Request.
