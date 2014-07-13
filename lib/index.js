'use strict';

var fs = require('fs');
var q = require('q');
var inflect = require('i')();
var path = require('path');
var execFile = q.denodeify(require('child_process').execFile);
var filename = path.resolve(__dirname, '../bin/ur');
var bashScript = fs.readFileSync(filename, 'utf8');
var re = /^\s*function\s+([a-zA-Z0-9_]+)/gm;
var urProxy = {};
var m = re.exec(bashScript);

while (m) {
    defineMethod(urProxy, m[1], filename);
    m = re.exec(bashScript);
}

module.exports = exports = urProxy;

function defineMethod(obj, name, filename) {
    obj[inflect.camelize(name, false)] = function(args, options) {
        return execFile(filename, [name].concat(args), options || {});
    };
}
