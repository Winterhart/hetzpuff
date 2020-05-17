# Setup SSH-Agent with Arch

SSH is a very powerfull tool, for example to pull/changes to remote git repositories w/o having to authorize each time.

- Ensure you don't have SSH key generated: `cat ~/.ssh/id_rsa.pub`. If this prints something skip to step 4 or 5.
- Ensure you have openssh installed: `yay -S openssh`.
- Create key, `ssh-keygen -t rsa -C "YOUR@EMAIL.com"` will prompt for location and passphrase.
- Now you need to enable SSH agent as a service. I found adding it as a systemd service is the most convinient.

- make dir with systemd unit `mkdir -p ~/.config/systemd/user/`
- write the service `vim ~/.config/systemd/user/ssh-agent.service`:

```bash

[Unit]
Description=SSH key agent

[Service]
Type=forking
Environment=SSH_AUTH_SOCK=%t/ssh-agent.socket
ExecStart=/usr/bin/ssh-agent -a $SSH_AUTH_SOCK

[Install]
WantedBy=default.target
```

Export the variable using your shell of use:

`vim ~/.zshrc`

and add:
`export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"`

Then:

- Reboot or reenter a shell to export new variable. `source ~/.zshrc`
- Enable service `systemctl --user enable --now ssh-agent`
- To add keys use `ssh-add`
