# Generic workshop cluster setup

![Travis CI build status](https://travis-ci.org/observabilitystack/workshop-cluster.svg?branch=master)

This repository holds resources to set up a general workshop 
cluster. Use powerful cloud servers for your workshop. Remove
the software installment hassle on local laptops. Upon setup, 
participants ...

* work on their own server in _Hetzner_ cloud
* edit the workshop files in the browser
* install, configure and launch workshop related software

![alt](docs/workshop-login.png)

## TL;DR

```bash
cd infrastructure && tf apply
tf output ansible_inventory > ../inventory/all.yaml
cd .. && ansible-playbook site.yaml
```

## Documentation

* [Technical foundatations](docs/technical_foundations.md)
* [Customizing the Cluster for your workshop](docs/customizing_for_your_workshop.md)
* [Setting up the Cluster](docs/setting_up_the_cluster.md)

## Connecting to a server using VSCode

To connect to your Kubernetes training cluster, we recommend using Visual 
Studio Code and the remote SSH plugin. Hit `F1` and start typing 
`Remote SSH`. Select `Remote SSH: Connect to Host ...`

![alt](docs/vscode_remote_ssh.png)

During the workshop, you connect as the SSH user `workshop`. Connect
to your assigned server, e.g. `workshop@opawaited-asp.k8s.o12stack.org`. 

![alt](docs/vscode_remote_ssh_server.png)

VSCode opens a remote SSH shell for your convenience. Click `Open a folder`
and select `/home/workshop/observability-workshop` to gain access to the
workshops resources.

![alt](docs/vscode_open_remote_folder.png)

## Questions?

Do not hesitate to contact us by E-Mail, Twitter or [Slack](https://o12stack.slack.com/) if you have any questions:

👨‍💻 | Torsten Köster | Nikolaus Winter
---|------------ | -------------
🌐 | [thiswayup.de](https://www.thiswayup.de) | [nikolauswinter.de](https://www.nikolauswinter.de)
📧 | [tbk@thiswayup.de](mailto:tbk@thiswayup.de) | [training@nikolauswinter.de](mailto:training@nikolauswinter.de)
🐦 | [@tboeghk](https://twitter.com/tboeghk) | [@backstreetkiwi](https://twitter.com/backstreetkiwi)