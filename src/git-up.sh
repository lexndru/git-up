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

export CWD=$(pwd)
export ERROR='\033[0;31m'
export RESET='\033[0m'
export HOMEPAGE=http://github.com/lexndru/git-up

# check if git is installed
if ! command -v git > /dev/null 2>&1; then
    echo "Cannot find git on system. Please install it."
    exit 1
fi

# print cwd and user
location () {
    echo "You $(whoami) are here $CWD"
    echo ""
}

# initialize repo wrapper
init_repo () {
    local username="$(git config --get user.name)"
    local usermail="$(git config --get user.email)"

    location

    # check if cwd is a git repo
    if [ -d .git ]; then
        repo="$(git config --get remote.origin.url)"

        if [ -z "$repo" ]; then
            echo "Current directory is a ${ERROR}misconfigured${RESET} repository:"
            echo " (${ERROR}\"remote.origin.url\" is missing${RESET})"
        else
            echo "Current directory is a repository:"
            echo " $repo"
        fi

        echo ""

        if [ -z "$username" ] && [ -z "$usermail" ]; then
            echo "Committer identity is NOT set:"
            echo " (${ERROR}\"user.name\" and \"user.email\" are missing${RESET})"
        elif [ -z "$username" ] && [ ! -z "$usermail" ]; then
            echo "Committer identity NAME is NOT set:"
            echo " (${ERROR}\"user.name\" is missing${RESET})"
            echo " n/a <${usermail}>"
        elif [ ! -z "$username" ] && [ -z "$usermail" ]; then
            echo "Committer identity EMAIL is NOT set:"
            echo " (${ERROR}\"user.email\" is missing${RESET})"
            echo " $username <n/a>"
        else
            echo "Committer identity:"
            echo " $username <${usermail}>"
        fi

        echo ""

        if ! git status; then
            echo "Cannot get git status"
            exit 1
        fi
    else
        echo "Current directory is not a repository..."
        read -p "Create now? [Yn] " create

        if [ -z "$create" ]; then
            create=Y
        fi

        case $create in
            y|Y) {
                if ! git init; then
                    echo "Cannot initialize git repository here"
                    echo "Please check permissions and try agian"
                    exit 1
                else
                    echo "Successfully initialized"
                fi

                # create .gitignore file
                if ! echo "/tmp" > .gitignore; then
                    echo "Cannot create .gitignore file"
                fi

                # create readme file
                if ! echo "# $(basename $CWD)" > README.md; then
                    echo "Cannot create README.md file"
                fi

                # update user name
                read -p "Committer name [${username}]: " name
                if [ ! -z "$name" ]; then
                    git config --local user.name "$name"
                fi

                # update user mail
                read -p "Committer email [${usermail}]: " mail
                if [ ! -z "$mail" ]; then
                    git config --local user.email "$mail"
                fi

                # set remote repo origin
                read -p "Repository: " repo
                if [ ! -z "$repo" ]; then
                    git remote add origin "$repo"
                fi

                # create optional license file
                # read -p "License (leave blank to skip): " license
            } ;;

            n|N) {
                echo "Okay, bye!"
                exit 0
            } ;;

            *) {
                echo "Cannot understand answer"
                echo "Try again"
                exit 1
            } ;;
        esac
    fi
}

# remove git directory and gitignore
drop_repo () {
    if [ -d "$CWD/.git" ]; then
        location
        echo "Deleting .git directory is permanent!"
        read -p "Type \"YES\" to continue... " drop
        if [ "x$drop" = "xyes" ] || [ "x$drop" = "xYES" ]; then
            if rm -rf "$CWD/.git" "$CWD/.gitignore"; then
                echo "Deleted repo from directory"
            else
                echo "Cannot delete directory..."
                exit 1
            fi
        else
            echo "Doing nothing"
        fi
    else
        echo "This is not a git repository"
        echo "Doing nothing"
    fi
}

# print help message
help_message () {
    echo "Git Up is an utility tool for Git"
    echo ""
    echo "It's purpose is to extend the initialization procedure by adding a few"
    echo "more steps such as setting user name/email and repository remote origin"
    echo "as well as creating a .gitignore file, a README file and a LICENSE file"
    echo ""
    echo "Please report bugs at: $HOMEPAGE"
    echo ""
    echo "Usage:"
    echo "  help   - prints this message"
    echo "  init   - same as \"git init\", followed by some steps"
    echo "  drop   - delete git directory and gitignore file"
    echo ""
}

# load script
if [ $# -gt 0 ]; then
    if [ "x$1" = "xhelp" ]; then
        help_message
    elif [ "x$1" = "xinit" ]; then
        init_repo
    elif [ "x$1" = "xdrop" ]; then
        drop_repo
    else
        echo "Unsupported action \"$@\" (try help)"
    fi
else
    init_repo
fi
