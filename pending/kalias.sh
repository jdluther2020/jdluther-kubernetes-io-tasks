# Setup Aliases and Env Vars
# Copy/paste the whole thing in any terminal 
# cat kalias.sh | pbcopy
# Use them regularly, so that you'll be forced to set them.

# Begin
## Env vars

sudo chown -LR cloud_user:cloud_user ~/.kube
alias kacg='kubectl config use-context acgk8s'

export KC=~/.kube/config
export do='--dry-run=client -o yaml'
export dos='--dry-run=server -o yaml'
export now='--force --grace-period 0'
export dd='describe deploy'
export dn='describe node'
export dp='describe pod'
export ds='describe service'

## Aliases

# Most frequently used command
alias k=kubectl

# Context and namespace related
alias kcc='egrep "(current-context|namespace)" $KC'
alias kn='kubectl config set-context --current --namespace'
alias knd='kubectl config set-context --current --namespace default'
alias kcg='kubectl config get-contexts'
alias kgns='kubectl get namespaces'

# Dealing with kube-system namespace
alias kk='kubectl -n kube-system'
alias kgpk='kubectl -n kube-system get pods'
alias kgpkw='kubectl -n kube-system get pods -o wide'

# Frequently used operational commands
alias ka='kubectl apply -f'
alias kad='kubectl apply --dry-run=client -f'
alias kads='kubectl apply --dry-run=server -f'
alias kd='kubectl delete -f'
alias kdelp='kubectl delete pod' # this has the risk async delete, thus needing secondary validation
alias kg='kubectl get -f'
alias kr='kubectl replace -f'

# Get commands
alias kgd='kubectl get deploy'
alias kgp='kubectl get pods'
alias kgpw='kubectl get pods -o wide'
alias kgpf='kubectl get pods -w'
alias kgn='kubectl get nodes'
alias kgnw='kubectl get nodes -o wide'
alias kgs='kubectl get svc'
alias kgsw='kubectl get svc -o wide'

# Edit commands
alias kep='kubectl edit pod'
alias ked='kubectl edit deploy'
alias kes='kubectl edit svc'

# Describe commands
alias kde='kubectl describe'
alias kdp='kubectl describe pod'
alias kdn='kubectl describe node'
alias kds='kubectl describe service'
alias kdd='kubectl describe deployment'

# Cluster commands
alias ke='kubectl exec -it'
alias kge="kubectl get events --sort-by='.lastTimestamp'"
alias kl='kubectl logs'

# End
