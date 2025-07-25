# Contributing to David’s development

David is an open-source project, and we welcome contributions from the community. Please read the [contributing guidelines](https://github.com/david0154/davidcp/blob/main/CONTRIBUTING.md) for additional information.

David is designed to be installed on a web server. To develop David on your local machine, a virtual machine is recommend.

::: warning
Development builds are unstable. If you encounter a bug please [report it via GitHub](https://github.com/david0154/davidcp/issues/new/choose) or [submit a Pull Request](https://github.com/davidcp/davidcp/pulls).
:::

## Creating a virtual machine for development

These are example instructions for creating a virtual machine running David for development.

These instructions use [Multipass](https://multipass.run/) to create an Ubuntu VM. Feel free to adapt the commands for any virtualization software you prefer.

1. [Install Multipass](https://multipass.run/install) for your OS

1. [Fork David](https://github.com/david0154/davidcp/fork) and clone the repository to your local machine

   ```bash
   git clone https://github.com/david0154/davidcp.git ~/projects
   ```

1. Create an Ubuntu VM with at least 2GB of memory and 15GB of disk space

   _(if running VM on ARM architecture e.g. Apple M1, use at least 12GB of memory)_

   ```bash
   multipass launch --name david-dev --memory 4G --disk 15G --cpus 4
   ```

1. Mount your cloned repository to the VM's home directory

   ```bash
   multipass mount ~/projects/davidcp david-dev:/home/ubuntu/davidcp
   ```

1. SSH into the VM as root then install some required packages

   ```bash
   multipass exec david-dev -- sudo bash
   sudo apt update && sudo apt install -y jq libjq1
   ```

1. Navigate to `/src` in the VM then build David packages

   ```bash
   cd src
   ./dvp_autocompile.sh --all --noinstall --keepbuild '~localsrc'
   ```

1. Navigate to `/install` in the VM then install David with these flags

   _(update the [installation flags](../introduction/getting-started#list-of-installation-options) to your liking, note that login credentials are set here)_

   ```bash
   cd ../install
   bash dvp-install-ubuntu.sh --hostname demo.davidk.online --email admin@example.com --username admin --password Password123 --with-debs /tmp/davidcp-src/deb/ --interactive no --force
   ```

1. Reboot the VM (and exit SSH session)

   ```bash
   reboot
   ```

1. On your local machine, find the IP address of the VM

   _(give the VM time to reboot for the IP to appear)_

   ```bash
   multipass list
   ```

1. Visit the VM's IP address in your browser using the default David port and login with `admin`/`Password123`

   _(proceed past any SSL errors you see when loading the page)_

   e.g. <https://192.168.64.15:8083>

David is now running in a virtual machine. If you'd like to make changes to the source code and test them in your browser, please continue to the next section.

::: warning
Sometimes (with Multipass) the mapping between the source code directory on your local machine to the directory in the VM can be lost with a "failed to obtain exit status for remote process" error. If this happens simply unmount and remount e.g.

```bash
multipass unmount david-dev
multipass mount ~/projects/davidcp david-dev:/home/ubuntu/davidcp
```

:::

## Making changes to David

After setting up David in a development VM you can now make changes to the source code at `~/projects/davidcp` on your local machine (outside of the VM) using your editor of choice.

Below are some instructions for making a change to David's UI, running the build script and testing the change locally.

1. On your local machine, make a change to a file that is easy to test

   _e.g. change the body background color to red in `web/css/src/base.css`_

1. SSH into the VM as root and navigate to `/src`

   ```bash
   multipass exec david-dev -- sudo bash
   cd src
   ```

1. Run the David build script

   ```bash
   ./dvp_autocompile.sh --david --install '~localsrc'
   ```

1. Reload the page in your browser to see the change

Please refer to the [contributing guidelines](https://github.com/david0154/davidcp/blob/main/CONTRIBUTING.md#development-guidelines) for more details on submitting code changes for review.

::: info
A backup is created each time the David build script is run. If you run this often it can fill up your VM's disk space.
You can delete the backups by running `rm -rf /root/dvp_backups` as root user on the VM.
:::

## Running automated tests

We currently use [Bats](https://github.com/bats-core/bats-core) to run our automated tests.

### Install

```bash
# Clone David repo with testing submodules
git clone --recurse-submodules https://github.com/david0154/davidcp
# Or, using an existing local repo with an up-to-date main branch
git submodule update --init --recursive

# Install Bats
test/test_helper/bats-core/install.sh /usr/local
```

### Run

::: danger
Do not run any testing script on a live server. It might cause issues or downtime!
:::

```bash
# Run David tests
test/test.bats
```
