#!/bin/sh
#
# Copyright (c) 2019 Alexandru Catrina <alex@codeissues.net>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

export HOMEPAGE=http://github.com/lexndru/git-up
export USER_BIN=$HOME/bin
export GIT=$(command -v git)
export GIT2=$USER_BIN/git
export GITUP_NOTICE="Git Up rich features installed"

# scan for git repositories
gitup_scan () {
    local dir="$1"

    if [ "x$dir" = "x" ] || [ ! -d "$dir" ]; then
        echo "Please provide a valid directory path to start scan"
        exit 1
    fi

    if [ "x$dir" = "x." ]; then
        dir=$(pwd)
    fi

    echo "Scanning for git repositories..."
    echo "Top-level directory: $dir"

    find $dir -name .git | while read line; do
        local repo="$(realpath "$line")"

        echo "[#] Found git directory"
        echo "    dir: $repo"

        if [ -f "$repo/config" ]; then
            echo "    url: $(grep url "$repo/config" | cut -d '=' -f 2)"
        else
            echo "    err: repository is not configured (ignore it?)"
        fi

    done
}


# enable git up
gitup_enable () {
    if [ -z "$HOME" ]; then
        echo "User's home directory is not set in \$PATH"
        exit 1
    fi

    if ! mkdir -p "$USER_BIN"; then
        echo "Cannot create user's private bin directory in $HOME"
        echo "Please check permissions and try again"
        exit 1
    fi

    if [ -f "$USER_BIN/git" ]; then
        if ! tail "$USER_BIN/git" -n 1 | grep "$GITUP_NOTICE" > /dev/null 2>&1; then
            echo "Aborting because cannot resolve conflict!"
            echo "A script with the name \"git\" already exists in $USER_BIN"
            echo "Please remove this script and try again"
            exit 1
        else
            if ! cp "$USER_BIN/git" /tmp/git.bkp; then
                echo "Aborting because cannot create backup!"
                echo "A script with the name \"git\" already exists in $USER_BIN"
                echo "Please remove this script and try again"
                exit 1
            else
                echo "Updated script to latest version."
                echo "A backup copy of the previous one has been stored in /tmp/git.bkp"
            fi
        fi
    fi

    cat > $GIT2 2> /dev/null <<EOF
#!/bin/sh
#
# Copyright (c) 2019 Alexandru Catrina <alex@codeissues.net>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

export ERROR='\033[0;31m'
export RESET='\033[0m'

if [ ! -f $GIT ]; then
    echo "Cannot find git on system. Please install it."
    exit 1
fi

_status () {
    if [ -d .git ] && [ -f .git/config ]; then
        local username="\$($GIT config --get user.name)"
        local usermail="\$($GIT config --get user.email)"
        local repo="\$($GIT config --get remote.origin.url)"

        echo "You (\$(whoami)) are here \$(pwd)"
        echo ""

        if [ -z "\$repo" ]; then
            echo "Current directory is a \${ERROR}misconfigured\${RESET} repository:"
            echo " (\${ERROR}\"remote.origin.url\" is missing\${RESET})"
        else
            echo "Current directory is a repository:"
            echo " \$repo"
        fi

        echo ""

        if [ -z "\$username" ] && [ -z "\$usermail" ]; then
            echo "Committer identity is NOT set:"
            echo " (\${ERROR}\"user.name\" and \"user.email\" are missing\${RESET})"
        elif [ -z "\$username" ] && [ ! -z "\$usermail" ]; then
            echo "Committer identity NAME is NOT set:"
            echo " (\${ERROR}\"user.name\" is missing\${RESET})"
            echo " n/a <\${usermail}>"
        elif [ ! -z "\$username" ] && [ -z "\$usermail" ]; then
            echo "Committer identity EMAIL is NOT set:"
            echo " (\${ERROR}\"user.email\" is missing\${RESET})"
            echo " \$username <n/a>"
        else
            echo "Committer identity:"
            echo " \$username <\${usermail}>"
        fi

        echo ""
    fi

    shift && $GIT status \$@
}

_init () {
    shift && $GIT init \$@

    if ! [ \$? -eq 0 ]; then
        exit 1
    fi

    if [ ! -z "\$1" ]; then
        cd "\$1"
    fi

    local username="\$($GIT config --get user.name)"
    local usermail="\$($GIT config --get user.email)"

    if ! echo "/tmp" > .gitignore; then
        echo "Cannot create .gitignore file"
    fi

    if ! echo "# \$(basename \$(pwd))" > README.md; then
        echo "Cannot create README.md file"
    fi

    read -p "Committer name [\${username}]: " name
    if [ ! -z "\$name" ]; then
        $GIT config --local user.name "\$name"
    fi

    read -p "Committer email [\${usermail}]: " mail
    if [ ! -z "\$mail" ]; then
        $GIT config --local user.email "\$mail"
    fi

    read -p "Repository: " repo
    if [ ! -z "\$repo" ]; then
        $GIT remote add origin "\$repo"
    fi
}

_push () {
    shift
    $GIT push \$@
}

case "\$1" in
    init) {
        _init \$@
    } ;;
    status) {
        _status \$@
    } ;;
    push) {
        _push \$@
    } ;;
    *) {
        $GIT \$@
    }
esac

# $GITUP_NOTICE on $(date)
EOF

    if [ $? -eq 0 ] && chmod +x "$GIT2"; then
        echo "Git Up features are now enabled!"
    else
        rm -rf "$GIT2" > /dev/null 2>&1
        echo "Cannot enable Git Up features"
        echo "Please check permissions and try again"
        exit 1
    fi
}

# disable git up
gitup_disable () {
    if [ -f "$USER_BIN/git" ]; then
        if ! tail "$USER_BIN/git" -n 1 | grep "$GITUP_NOTICE" > /dev/null 2>&1; then
            echo "Aborting because cannot detect Git Up wrapper!"
            echo "A script with the name \"git\" already exists in $USER_BIN"
            echo "but cannot determine if it's a Git Up feature wrapper."
            echo "Please manually remove this script on your own risk."
            exit 1
        else
            if rm -f "$USER_BIN/git"; then
                echo "Git Up features are now disabled!"
            else
                echo "Cannot disable Git Up features"
                echo "Please check permissions and try again"
            fi
        fi
    else
        echo "Git Up features are not enabled. Nothing changed."
    fi
}

# print help message
help_message () {
    echo "Git Up is an utility tool for Git"
    echo ""
    echo "The purpose of Git Up is to extend Git's procedures with helpful rich features."
    echo "The utility creates a wrapper over git upon activating. The state of the binary"
    echo "remains unchanged."
    echo ""
    echo "Please report bugs at: $HOMEPAGE"
    echo ""
    echo "Usage:"
    echo "  help        - prints this message"
    echo "  status      - checks if git-up features are enabled or not"
    echo "  enable      - activate git-up features"
    echo "  disable     - deactivate git-up features"
    echo "  scan [dir]  - scan for git repositories starting"
    echo ""
}

# load git up script
if [ $# -gt 0 ]; then
    if [ "x$1" = "xhelp" ]; then
        help_message
    elif [ "x$1" = "xstatus" ]; then
        gitup_status
    elif [ "x$1" = "xenable" ]; then
        gitup_enable
    elif [ "x$1" = "xdisable" ]; then
        gitup_disable
    elif [ "x$1" = "xscan" ]; then
        gitup_scan "$2"
    else
        echo "Unsupported action \"$@\" (try help)"
    fi
else
    help_message
fi
