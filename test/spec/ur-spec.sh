#!/bin/bash bash-spec-runner
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
UR="shcov $DIR/../../bin/ur"

function before_all {
    rm -rf /tmp/shcov

    export UR_PACKAGES_FILE=$(mktemp)

    local private_project=$(mktemp -d --suffix=.git)

    make_git_server="$private_project"

    cat << EOF >> $UR_PACKAGES_FILE
requirejs-text https://github.com/requirejs/text.git
my-private-project file://$private_project
}

function after_all {
    rm $UR_PACKAGES_FILE
    rm -rf $private_project
}

function before_each {
    export UR_CACHE=$(mktemp -d)
}

function after_each {
    rm -rf $UR_CACHE
}

function it_should_redirect {
    local output=`$UR npm_handler /q GET`

    echo output
}

function make_git_server {
    local path="$1"

    pushd "$path"
    git init

    make_package_json
    make_index_js

    git add .
    git commit -a -m "initial commit"
    git tag -a v0.0.0 -m "my version 0.0.0"
    popd
}

function make_package_json {
    cat << 'EOF' >> $private_project/package.json
{
    "name": "my-private-project", 
    "version": "0.0.0",
    "main": "index.js"
}
EOF
}

function make_index_js {
    cat << 'EOF' >> $private_project/index.js
exports.hello = function(who) {
    console.log('Hello', who);
}
EOF
}