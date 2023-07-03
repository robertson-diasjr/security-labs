# Network & Security Health-Check Tool
Stepping back some years ago (when Ansible was still crawling) and due the lack of open-source options to manage network & security configurations upon routers, switches, wlan-controllers, firewalls and almost all the appliances driven by a "cli - command line interface", I decided to create a tool named as <b>"Network & Security Health-Check Tool"</b>.

This tool essentially performs:
- connect via ssh upon target devices, issue commands and track the output on separate files;
- compare the downloaded configuration against "source of truth templates/best practices" to say if that device is compliance or not;
- follow the same logic, you can:
    - use the tool for routine backups
    - scale the infrastructure changes, such as: 1) shutdown the gi0/1 interface on all the network switches 2) add the IP 192.168.0.1/32 on Cisco ASA firewall rule and so on.

## How it Works

- The software run at Linux (Red Hat, Debian, Ubuntu, Slackware, CentOS, Fedora, etc) OS.

- A “template” must be created with a set of minimum configuration terms to be evaluated by tool. This terms should be based at customer’s security policy agreed.

- All the configuration files (from network devices) must be saved as extension type text (txt, conf or cfg).

- During the tool execution, all requirements within the “template” will be matched against device’s configuration file.

- At the end, an html output individual file is generated with all terms evaluated for that network device and each term reported as “Pass” or “Failed”.

## Details
1. What's Health-Check Tools ?
- A: Is a tool to perform security health-check at network devices based on pre-defined templates.

2. What's the kind of program language to develop new or current modules ?
- A: Any language that could be supported by Linux Posix. Examples: Perl, Expect, Java, Pyton, AWK, C,
C++, Ruby, Shell Script and so on

3. What's the type of program language used currently ?
- A: Shell Script, Perl Regex, Awk and Sed

4. What's the operational system requirement ?
- A: Can run successfully on all Linux and Unix operational system. By best practice, we recommend to
use on IBM Linux OpenClient.

5. Can I execute multiple evaluations simultaneously for the same technology (such as Cisco router) ?
- A: Yes. To do this, just put all device's configuration under directory "hc-configs"

6. Can I execute multiple evaluations simultaneoulsy for different technologies (such as Cisco router
and Juniper router)
- A: No. For each technology you should adjust a different template to meet each type of command. For
Cisco router, an username field under configuration is "username xxxx password". For Juniper, the same
username is: set system login user xxxx". Therefore, it's not possible use the same template to meet Cisco
and Juniper once a time.

7. What is needed to run a HC ?
- A: Follow the next 4 steps, where:
    1. get all device's configuration and save extension as "cfg", "txt" or "conf"
    2. move all collected configuration to directory "hc-configs"
    3. within directory "hc-templates", adjust the template model to be used
    4. within the main directory, execute "./hc" and choose option
    5. after finish, go to directory "hc-output" to see all outputs

## How to install
- First, open a linux terminal
    1. sudo yum install perl-HTML-FromText.noarch
    2. mkdir -p ~/tools
    3. cd ~/tools
    4. clone this repo ;-)

## What's the purpose of each directory ?
- changelog: description about features inserted on tool
- hc = executable to run the software
- hc-configs = retain device's configuration
- hc-output = retain output after run the tool
- hc-scripts = retain all algorithms written to perform health check
- hc-templates = retain security policies templates

## How to run
# Examples to run HC
Executing Cisco's device (router or switch)

1. Enter on directory "health-check"
- `[user@localhost ~]$ cd /home/user/tools/health-check`

2. Enter on directory "hc-configs" and remove all contents
- `[user@localhost health-check]$ cd hc-configs/`
- `[user@localhost hc-configs]$ rm *`

3. Copy current Cisco's device configuration to here: "hc-configs"
- `[user@localhost hc-configs]$ cp /tmp/router.txt .`
- `[user@localhost hc-configs]$ ls -l`
- `total 8`
- `-rw-rw-r--. 1 user user 7327 May 14 14:26 router.txt`

4. Return to base directory (healt-check)
- `[user@localhost hc-configs]$ cd ..`

5. Enter on directory "hc-templates"
- `[user@localhost health-check]$ cd hc-templates/`

6. If file "template.txt" exist, remove it
- `[user@localhost hc-configs]$ rm template.txt`

7. Now, we're using the default template known as "template-hc-cisco-sw-ios.txt"
- `[user@localhost hc-templates]$ cp -s default/template-hc-cisco-sw-ios.txt template.txt`
- `[user@localhost hc-templates]$ ls -la`
- `lrwxrwxrwx. 1 user user 36 May 14 14:27 template.txt -> default/template-hc-cisco-sw-ios.txt`

8. Return to base directory (healt-check)
- `[user@localhost hc-templates]$ cd ..`

9. Run the script "hc"
- `[user@localhost health-check]$ ./hc cisco switch`
- `HC de Cisco SW IOS`
- `Health-checking device: router.txt ...`
- `Output Result: ../hc-output/HC-router.txt`

10. Enter on directory "hc-output" and evaluate results
- `[user@localhost health-check]$ cd hc-output/`
- `[user@localhost hc-output]$ ls -la`
- `total 44`
- `-rw-rw-r--. 1 user user 3708 May 14 14:27 HC-router.html`
- `-rw-rw-r--. 1 user user 300 May 14 14:27 HC-summary.html`

We recommend use default browser to open both above files.
 
## Contributing

"Let me know and I'll be glad to invite you !!!, then ..."

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D

## License
- GNU Public License

## Screenshots
![HC-Tool](https://github.com/robertson-diasjr/security-labs/blob/main/HealthCheck/hc-diagram.jpg)
