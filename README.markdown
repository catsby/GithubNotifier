#GithubNotifier

GithubNotifier is a menu-bar app for Mac OS 10.6+ that polls Github for network activity on any of your repositories.  

#Release History

- **[1.2]** [GithubNotifier-1.2.zip][8]
  - Better notifications
  - Updates on watcher count

- **[1.1]**  GithubNotifier-1.1.zip
	- Receive notifications when someone starts watching any of your repositories.  

- **[1.0]**  GithubNotifier-1.0.zip

#Development

Patches / bugs welcome.
To get setup for development, be sure to run 
`git submodule init` && `git submodule update` to pull down the latest `CocoaREST` and `EMKeychain` files

#Building

Releases are done by myself, so "release" configuration requires my
private key for code-signing.  If you'd like to compile and run your own
release build go to project settings and under "release"
configuration, remove `scary-robot-development` and either leave blank
or use your own key

#Future

- Sparkle integration (or Mac App store... debating)
- New notifications:
 	- New forks of your repositories 
	- New issues added to your repositories

#Credits:
[Steven Degutis][2] for [CocoaREST][3]

[ExtendMac][4] for [EMKeychain][5]

[Shaun Harrison and or Enormego][6] for [NSWorkspaceHelper][7]


[2]: http://degutis.org/
[3]: http://github.com/sdegutis/CocoaREST
[4]: http://extendmac.com
[5]: http://extendmac.com/EMKeychain
[6]: http://www.enormego.com
[7]: http://github.com/enormego/cocoa-helpers
[8]: https://github.com/downloads/ctshryock/GithubNotifier/GithubNotifier-1.2.zip
