# Clone an Existing Vault which uses obsidian-git

**2024-06-30**

Get URL of existing vault

* `git@github.com:USERNAME/REPONAME`
* `keybase://private/USERNAME/REPONAME`
* `keybase://team/TEAMNAME/REPONAME`
* etc.

Clone the repo

```
mkdir -p ~/Documents/Obsidian
cd ~/Documents/Obsidian
git clone keybase://team/TEAMNAME/REPONAME VAULTNAME
```

Open vault

* File &#x2192; Open Vault...
* Open folder as vault - click "Open"
* Navigate to `~/Documents/Obsidian/VAULTNAME`, click "Open"
* When asked about trusting plugins, say yes

Configure plugin

* Settings - (&#x2318;,) or (Obsidian &#x2192; Settings)
* On the left, under "Community Plugins" (bottom), select "Git"
* Under "Commit message"
    * {{hostname}} placeholder replacement &#x2192; identifier for *this* machine (not sync'ed in git repo)
* Under "Advanced"
    * Additional PATH environment variable paths (especially if you see popups about commands not being recognized, such as `gpg` or `keybase-remote`)
        ```
        /usr/local/bin
        /opt/homebrew/bin
        /opt/keybase/bin
        ```
    * Reload with new environment variables &#x2192; Reload
