<p align="center">
  <a href="https://nxtsrv.de/">
    <img src="https://raw.githubusercontent.com/shoujii/NeXt-Server-Lite/master/includes/NeXt-logo.jpg">
  </a>

  <h3 align="center">NeXt-Server-Lite</h3>

  <p align="center">
    Debian Lite Version of NeXt-Server Script.
    <br>
    <a href="https://github.com/shoujii/NeXt-Server-Lite/wiki"><strong>NeXt-Server Wiki »</strong></a>
    <br>
    <br>
    <a href="https://github.com/shoujii/NeXt-Server-Lite/issues/new">Report bug</a>
    ·
  </p>
</p>

<br>

## Table of contents

- [What you need](#what-you-need)
- [Quick start](#quick-start)
- [What's included](#whats-included)
- [Bugs and feature requests](#bugs-and-feature-requests)
- [Documentation](#documentation)
- [Contributing](#contributing)
- [Creators](#creators)
- [Thanks](#thanks)
- [Used software](#used-software)
- [Copyright and license](#copyright-and-license)

## What you need:

A vServer with at least:
```
- 1 CPU Core
- 1 GB RAM
- KVM virtualized server (Openvz [...] will not work!)
- The latest "clean" Debian 12.x minimal installed on the server (with all updates!)
- rDNS set to the desired Domain
- root user access
- 9 GB free disk space

- IPv4 Adress
- A Domain and the ability to change the DNS Settings
- DNS Settings described in the dns_settings.txt
- Time... the DNS system may need 24 to 48 hours to recognize the changes you made!

- The will to learn something about Linux ;)
```

## Quick start

Several quick start options are available:

Important!:
Login with:
- `su -`
otherwise the script will throw multiple errors!

Install with [git]:
- `cd /root/; apt update; apt install git -y; git clone https://github.com/shoujii/NeXt-Server-Lite; cd NeXt-Server-Lite; bash nxt.sh
`

Install dev mode [git]:

DO NOT USE FOR PRODUCTION!

The Mailserver and other features won't work!
(This will create a fake Let's Encrypt Cert, you won't run into the limition of weekly cert's)
- `cd /root/; apt update; apt install git -y; git clone https://github.com/shoujii/NeXt-Server-Lite; cd NeXt-Server-Lite; touch dev.conf; bash nxt.sh
`

Read the [NeXt-Server Wiki](https://github.com/shoujii/NeXt-Server-Lite/wiki) for advanced information!

## What's included

Within the cloned repository you'll find the following directories and files, grouping the different installation files and configs in a logic structure. You'll see something like this:

```
NeXt-Server-Lite/
    ├── .github/
    │   ├── issue_template.md
    │
    ├── addons/
    │
    │   ├── vhosts/
    │      ├── [Various Vhost .conf files]
    │   ├── [Various Addon .sh files]
    │
    ├── checks/
    │   ├── [Various check .sh files]
    │
    ├── configs/
    │   ├── arno-iptables-firewall/
    │   ├── fail2ban/
    │   ├── nginx/
    │   ├── pma/
    │   ├── [Various interfaces, blocked ports and upgrade files] 
    │   ├── sources.cfg
    │   ├── sshd_config  
    │   ├── userconfig.cfg
    │   ├── versions.cfg
    │
    ├── cronjobs/
    │   ├── free_disk_space    
    │   ├── le_cert_alert    
    │   ├── webserver_backup
    │
    ├── includes/
    │   ├── issue   
    │   ├── issue.net     
    │   ├── NeXt-logo.jpg
    │
    ├── logs/
    │   ├── [Various .log files]
    │
    ├── menus/
    │   ├── [Various menu .sh files]
    │
    ├── script/
    │   ├── [Various script .sh files (main part of the script)]
    │
    ├── updates/
    │   ├── [Various service update .sh files]
    │
    ├── confighelper.sh   
    ├── install.sh     
    ├── LICENSE
    ├── login_information.txt    
    ├── nxt.sh    
    ├── README.md
    ├── update_script.sh
```

## Bugs and feature requests

Have a bug or a feature request? Please first read the [issue guidelines]() and search for existing and closed issues. If your problem or idea is not addressed yet, [please open a new issue](https://github.com/shoujii/NeXt-Server-Lite/issues/new).


## Documentation

The NeXt-Server documentation, included in this repository in the docs directory, is also available on the [NeXt-Server Wiki](https://github.com/shoujii/NeXt-Server-Lite/wiki).

## Contributing

Please read through our [contributing guidelines](https://github.com/twbs/bootstrap/blob/master/CONTRIBUTING.md). Included are directions for opening issues, coding standards, and notes on development.

## Creators

**Marcel Eichlohn**

- <https://github.com/shoujii>

**René Wurch**

- <https://github.com/BoBBer446>

** Flo**

- <https://github.com/flo-ku>

## Thanks

A big thanks to [George Liu], for some great lines of code!.
(https://github.com/centminmod)

## Used software
- Nginx                      <https://github.com/nginx/nginx>
- Openssh                    <https://github.com/openssh/openssh-portable>
- Libressl                   <https://github.com/libressl/portable>
- fail2ban                   <https://github.com/fail2ban/fail2ban>
- Arno's iptables firewall   <https://github.com/arno-iptables-firewall/aif>
- MariaDB                    <https://github.com/MariaDB/server>
- acme.sh                    <https://github.com/Neilpang/acme.sh>

## Copyright and license

Code and documentation copyright 2017-2022 the [NeXt-Server-Lite Authors](https://github.com/shoujii/NeXt-Server-Lite/graphs/contributors)
Code released under the [GNU General Public License v3.0](https://github.com/shoujii/NeXt-Server-Lite/blob/master/LICENSE).
