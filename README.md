

## **Welcome!**

David Control Panel is designed to provide administrators an easy to use web and command line interface, enabling them to quickly deploy and manage web domains, mail accounts, DNS zones, and databases from one central dashboard without the hassle of manually deploying and configuring individual components or services.



## Features and Services

- Apache2 and NGINX with PHP-FPM
- Multiple PHP versions (5.6 - 8.4, 8.3 as default)
- DNS Server (Bind) with clustering capabilities
- POP/IMAP/SMTP mail services with Anti-Virus, Anti-Spam, and Webmail (ClamAV, SpamAssassin, Sieve, Roundcube)
- MariaDB/MySQL and/or PostgreSQL databases
- Let's Encrypt SSL support with wildcard certificates
- Firewall with brute-force attack detection and IP lists (iptables, fail2ban, and ipset).
- Leech protection,Hot link protection
- WordPress maneger
- also come with pre build ai for security check and error handling,code scan, virus scan 

## Supported platforms and operating systems

- **Debian:** 12, 11
- **Ubuntu:** 24.04 LTS, 22.04 LTS, 20.04 LTS

**NOTES:**

- David Control Panel does not support 32 bit operating systems!
- David Control Panel in combination with OpenVZ 7 or lower might have issues with DNS and/or firewall. If you use a Virtual Private Server we strongly advice you to use something based on KVM or LXC!

## Installing David Control Panel

- **NOTE:** You must install David Control Panel on top of a fresh operating system installation to ensure proper functionality.

While we have taken every effort to make the installation process and the control panel interface as friendly as possible (even for new users), it is assumed that you will have some prior knowledge and understanding in the basics how to set up a Linux server before continuing.

### Step 1: Log in

To start the installation, you will need to be logged in as **root** or a user with super-user privileges. You can perform the installation either directly from the command line console or remotely via SSH:

```bash
ssh root@your.server
```

### Step 2: Download

Download the installation script for the latest release:

```bash
wget https://raw.githubusercontent.com/david0154/davidcp/release/install/dvp-install.sh
```

If the download fails due to an SSL validation error, please be sure you've installed the ca-certificate package on your system - you can do this with the following command:

```bash
apt-get update && apt-get install ca-certificates
```

### Step 3: Run

To begin the installation process, simply run the script and follow the on-screen prompts:

```bash
bash dvp-install.sh
```

You will receive a welcome email at the address specified during installation (if applicable) and on-screen instructions after the installation is completed to log in and access your server.

### Custom installation

You may specify a number of various flags during installation to only install the features in which you need. To view a list of available options, run:

```bash
bash dvp-install.sh -h
```



## How to upgrade an existing installation

Automatic Updates are enabled by default on new installations of David Control Panel and can be managed from **Server Settings > Updates**. To manually check for and install available updates, use the apt package manager:

```bash
apt-get update
apt-get upgrade
```

## Issues & Support Requests

- If you encounter a general problem while using David Control Panel and need help, please  to search for potential solutions or post a new thread where community members can assist.
- Bugs and other reproducible issues should be filed via GitHub by [creating a new issue report](https://github.com/david0154/davidcp/issues) so that our developers can investigate further. Please note that requests for support will be redirected to our forum.

**IMPORTANT: We _cannot_ provide support for requests that do not describe the troubleshooting steps that have already been performed, or for third-party applications not related to David Control Panel (such as WordPress). Please make sure that you include as much information as possible in your forum posts or issue reports!**

## Contributions

If you would like to contribute to the project, please [read our Contribution Guidelines](https://github.com/david0154/davidcp/blob/main/CONTRIBUTING.md) for a brief overview of our development process and standards.

## Copyright

"David Control Panel", "davidcp", and the David logo are original copyright of davidk.online and the following restrictions apply:

**You are allowed to:**

- use the names "David Control Panel", "davidcp", or the David logo in any context directly related to the application or the project. This includes the application itself, local communities and news or blog posts.

**You are not allowed to:**

- sell or redistribute the application under the name "David Control Panel", "davidcp", or similar derivatives, including the use of the David logo in any brand or marketing materials related to revenue generating activities,
- use the names "David Control Panel", "davidcp", or the David logo in any context that is not related to the project,
- alter the name "David Control Panel", "davidcp", or the David logo in any way.

## License

David Control Panel is licensed under [GPL v3](https://github.com/david0154/davidcp/blob/release/LICENSE) license.<br>
