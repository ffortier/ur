describe('ur', function() {
    'use strict';

    var cacheDir;
    var extend = require('extend');
    var path = require('path');
    var execFile = require('child_process').execFile;
    var proxyquire = require('proxyquire');
    var shasum = require('shasum');
    var temp = require('temp');

    temp.track();

    var ur = proxyquire('../../lib', {
        child_process: {
            execFile: execFileWithCoverage
        }
    });

    beforeEach(function() {
        cacheDir = temp.mkdirSync();
    });

    afterEach(function() {
        temp.cleanupSync();
    });

    describe('npmHandler', function() {

        beforeEach(function() {
            this.addMatchers({
                toHaveHead: function(status, headers) {
                    var stdout = this.actual.mostRecentCall && this.actual.mostRecentCall.args[0] && this.actual.mostRecentCall.args[0][0];

                    this.message = function() {
                        return ['Expected status ' + status + ', but found ' + stdout, 'Not expected status ' + status + ', but found ' + stdout];
                    };

                    if (!stdout) {
                        return false;
                    }

                    var lines = stdout.split('\r\n');

                    return lines[0].indexOf('HTTP/1.1 ' + status) === 0;
                }
            })
        });

        it('should redirect for unknown packages', function(done) {
            var success = jasmine.createSpy('success');
            var error = jasmine.createSpy('error');
            var expected = 'HTTP/1.1 302 Found\r\nLocation: https://registry.npmjs.org/q\r\n\r\n';

            ur.npmHandler(['GET', '/q']).then(success, error).fin(function() {
                expect(success).toHaveBeenCalledWith([expected, '']);
                expect(success).toHaveHead(302);
                expect(error).wasNotCalled();
                done();
            });
        });

        it('should mirror new packages using the git url provided', function(done) {
            var success = jasmine.createSpy('success');
            var error = jasmine.createSpy('error');

            ur.mirrorPackage(['https://github.com/requirejs/text.git']).then(success, error).fin(function() {
                expect(success).toHaveBeenCalledWith([path.join(cacheDir, 'packages', shasum('https://github.com/requirejs/text.git')), '']);
                expect(error).wasNotCalled();
                done();
            });
        });

    });

    function execFileWithCoverage(filename, args, options, callback) {
        var env = options.env || process.env;

        args.unshift(filename);

        filename = 'shcov';

        options.env = extend({}, env, {
            PATH: env.PATH + ':' + path.resolve(__dirname, '../support/shcov-5/scripts'),
            UR_PACKAGES_FILE: path.resolve(__dirname, '../data/packages'),
            UR_CACHE: cacheDir
        });

        return execFile(filename, args, options, callback);
    }

});