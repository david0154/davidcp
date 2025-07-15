# Building packages

::: info
For building `david-nginx` or `david-php`, at least 2 GB of memory is required!
:::

Here is more detailed information about the build scripts that are run from `src`:

## Installing David from a branch

The following is useful for testing a Pull Request or a branch on a fork.

1. Install Node.js [Download](https://nodejs.org/en/download) or use [Node Source APT](https://github.com/nodesource/distributions)

```bash
# Replace with https://github.com/username/davidcp.git if you want to test a branch that you created yourself
git clone https://github.com/davidcp/davidcp.git
cd ./davidcp/

# Replace main with the branch you want to test
git checkout main

cd ./src/

# Compile packages
./dvp_autocompile.sh --all --noinstall --keepbuild '~localsrc'

cd ../install

bash dvp-install-{os}.sh --with-debs /tmp/davidcp-src/deb/
```

Any option can be appended to the installer command. [See the complete list](../introduction/getting-started#list-of-installation-options).

## Build packages only

```bash
# Only David
./dvp_autocompile.sh --david --noinstall --keepbuild '~localsrc'
```

```bash
# David + david-nginx and david-php
./dvp_autocompile.sh --all --noinstall --keepbuild '~localsrc'
```

## Build and install packages

::: info
Use if you have David already installed, for your changes to take effect.
:::

```bash
# Only David
./dvp_autocompile.sh --david --install '~localsrc'
```

```bash
# David + david-nginx and david-php
./dvp_autocompile.sh --all --install '~localsrc'
```

## Updating David from GitHub

The following is useful for pulling the latest staging/beta changes from GitHub and compiling the changes.

::: info
The following method only supports building the `david` package. If you need to build `david-nginx` or `david-php`, use one of the previous commands.
:::

1. Install Node.js [Download](https://nodejs.org/en/download) or use [Node Source APT](https://github.com/nodesource/distributions)

```bash
v-update-sys-david-git [USERNAME] [BRANCH]
```

**Note:** Sometimes dependencies will get added or removed when the packages are installed with `dpkg`. It is not possible to preload the dependencies. If this happens, you will see an error like this:

```bash
dpkg: error processing package david (–install):
dependency problems - leaving unconfigured
```

To solve this issue, run:

```bash
apt install -f
```
