if status is-interactive
    # Commands to run in interactive sessions can go here
end

function mkcd
    mkdir -p $argv[1] && cd $argv[1]
end
function cdr
    cd $(git rev-parse --path-format=relative --show-toplevel)
end

abbr --add l less
abbr --add s sudo
abbr --add se sudoedit

abbr --add gad git add
abbr --add gbi git bisect
abbr --add gbr git branch
abbr --add gcm git commit
abbr --add gcp git cherry-pick
abbr --add gdf git diff
abbr --add gdfs git diff --stat
abbr --add gdfc git diff --cached
abbr --add gdfo git diff ORIG_HEAD
abbr --add gdfu git diff @{u}
abbr --add glo git log
abbr --add glos git log --stat
abbr --add glop git log -p --format=fuller --stat
abbr --add glopo git log -p --format=fuller --stat --reverse ORIG_HEAD..
abbr --add glopu git log -p --format=fuller --stat --reverse ..@{u}
abbr --add gmr git merge
abbr --add gpl git pull --stat
abbr --add gps git push
abbr --add gpsf git push --force-with-lease
abbr --add grb git rebase
abbr --add grs git reset
abbr --add grsh git reset --hard
abbr --add grt git remote
abbr --add grv git revert
abbr --add gsh git show
abbr --add gsm git submodule
abbr --add gst git stash
abbr --add gw git switch
abbr --add gwt git worktree
abbr --add gr git restore

abbr --add gca git commit -a
abbr --add gcam git commit -a --amend
abbr --add gcle git clean -f
abbr --add gclef git clean -dffx
abbr --add gfe git fetch -v -p
abbr --add gfea git fetch -v -p --all
abbr --add grbi git rebase -i
abbr --add grmc git rm --cached
abbr --add gs git status -sb
abbr --add gso git status -sbuno
abbr --add gss git status -sb --ignored
abbr --add gsmf gsm foreach --recursive
abbr --add gsmu gsm update --init --recursive

function gwm
    git switch $argv $(git-default-branch)
end
function gdfm
    git diff $argv $(git-default-branch)
end
function grbm
    git rebase $argv $(git-default-branch)
end
# glot() { GIT_EXTERNAL_DIFF=difft glop --ext-diff; }
# gdft() { GIT_EXTERNAL_DIFF=difft git diff; }

complete -c gbrd -f -a '(git for-each-ref --format=%\(refname:strip=2\) --sort=-committerdate refs/heads/)'
abbr --add gclo git clone
abbr --add grbc git rebase --continue
abbr --add ggc git gc --prune=all
abbr --add ggr git grep -InE

abbr --add sc systemctl
abbr --add scu systemctl --user
abbr --add jc journalctl
abbr --add jcu journalctl --user

abbr --add ls ls -F
abbr --add ll ls -lhiF
abbr --add la ls -alhiF
abbr --add lt ls -Alhrt

abbr --add zs sudo -E $SHELL
abbr --add rr rm -rf

abbr --add gg go get
abbr --add ggn go generate
abbr --add gb go build
abbr --add gi go install
abbr --add gt go test
abbr --add gts go test -vet=off -short -timeout 10s
abbr --add gf go test -run=- -vet=off -fuzz

# gomajor is still useful for bumping major versions,
# but "go list" and "go get" are enough and less buggy for others.
function go-updates
    go list -u -m -f '{{if and (not .Indirect) .Update}}{{.}}{{end}}' all
end
function go-updates-do
    go get $(go list -u -m -f '{{if not .Indirect}}{{with .Update}}{{.Path}}@{{.Version}}{{end}}{{end}}' all)
    go mod tidy
end

function wbin
    fish_add_path --path --move /usr/bin
end

function gstr
    if ! set -q argv[1]
        echo "gstr [stress flags] ./test [test flags]"
        return
    end
    echo "go test -c -vet=off -o test && stress $argv"
    go test -c -vet=off -o test && stress $argv
end

function gcov
    go test -coverpkg=./... -coverprofile=/tmp/c $argv
    go tool cover -html=/tmp/c
end

# abbr --add gtoolcmp 'go build -toolexec "toolstash -cmp" -a std cmd'

# gim() { goimports -l -w ${@:-*.go}; }
# gfm() { gofumpt -l -w ${@:-*.go}; }
# sfm() { shfmt -s -l -w ${@:-.}; }

function syu
    echo " -- rpm-ostree --"
    rpm-ostree upgrade || return 1

    echo " -- flatpak --"
    flatpak update || return 1

    echo " -- fwupdmgr --"
    fwupdmgr refresh || return 1
    fwupdmgr get-updates || true # no updates is code 1
end

abbr --add gsmfc "gsmf 'git clean -dffx && git reset --hard' && gcle && grsh"

function git-default-branch-fix
    git remote set-head origin -a
end
function git-default-branch
    git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'
end
function git-file-sizes
    git ls-files -z | xargs -0 du -b | sort -n
end

# gfork() { gh repo fork --remote --remote-name mvdan; }
# gprf() { gh pr checkout --branch=pr-$1 $1; }
# gmrc() { git push origin -o merge_request.create "$@"; }
abbr --add gml git-codereview mail

abbr --add ssh TERM=xterm ssh
abbr --add rsv rsync -avh --info=progress2

abbr --add tb nc termbin.com 9999
abbr --add procs procs --color=disable
abbr --add unr arc unarchive
abbr --add kc kubectl
abbr --add kcl kubectl logs
abbr --add kcg kubectl get
abbr --add kcd kubectl describe

# podman-prune-all-old() { podman system prune --all --filter until=730h; }
