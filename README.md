ur
===

Standalone registry for npm and bower. This script act as a proxy in front of a public npm/bower registry. It allows you to serve repositories hosted on private git servers and let npm/bower handle the version numbers correctly. You don't need to clone the public registries.

This script is a bash script, not a javascript. The reason why it's a bash script is because most operations are file operations and bash is more appropriate to perform this kind of job than javascript.

Usage
---
```bash
# Creates the package list
cat << EOF >> some/packages
my-package ssh://git@my.private.repo/user/my-package.git
my-other-package ssh://git@my.private.repo/user/my-other-package.git
EOF

# Runs the standalone server
ur some/packages

# npm installs using this registry as a proxy
npm install --registry http://127.0.0.1:8080/npm

# bower installs using this registry as a proxy
bower install --registry http://127.0.0.1:8080/bower

# Download a tar.gz archive for a specific version
curl -o http://127.0.0.1:8080/archives/my-package/0.0.0/archive.tar.gz

# Prints the full package definition, with all the available versions
curl http://127.0.0.1:8080/npm/my-package

# Prints the package definition for a specific version
curl http://127.0.0.1:8080/npm/my-package/0.0.0

# Execute the unit tests
cd path/to/ur
npm install && npm test
```
