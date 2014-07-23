#!/bin/bash bash-spec-runner
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function before_all {
    rm -rf /tmp/shcov

    UR_PACKAGES_FILE=$(mktemp)
    UR="shcov $DIR/../../bin/ur -p $UR_PACKAGES_FILE"

    private_project=$(mktemp -d --suffix=.git)

    make_git_server "$private_project"

    cat << EOF >> $UR_PACKAGES_FILE
requirejs-text https://github.com/requirejs/text.git
my-private-project file://$private_project
EOF
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
    local expected_result='HTTP/1.1 302 Found\r
Location: https://registry.npmjs.org/q\r
Connection: close\r
\r'

    assert diff <($UR -f npm_handler /q GET) <(echo -e "$expected_result");
}

function it_should_acquire_lock {
    local dir=`mktemp -d`

    pushd $dir > /dev/null

    $UR -f acquire_lock mylock

    assert [[ -f $dir/.locks/mylock ]]

    $UR -f release_lock mylock

    assert [[ ! -f $dir.locks//mylock ]]

    popd > /dev/null

    rm -rf $dir
}

function make_git_server {
    local path="$1"

    pushd "$path" > /dev/null
    git init > /dev/null

    make_package_json $path
    make_index_js $path

    git add . > /dev/null
    git commit -a -m "initial commit" > /dev/null
    git tag -a v0.0.0 -m "my version 0.0.0" > /dev/null
    popd > /dev/null
}

function make_package_json {
    cat << 'EOF' >> $1/package.json
{
    "name": "my-private-project", 
    "version": "0.0.0",
    "main": "index.js"
}
EOF
}

function make_index_js {
    cat << 'EOF' >> $1/index.js
exports.hello = function(who) {
    console.log('Hello', who);
}
EOF
}
