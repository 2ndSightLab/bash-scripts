# random

Random commands that might come in handy.

# Tip: Use AI for sed commands, etc.

I had some posts on useful sed commands and such but you're better off just using AI to formulate those commands. You have to get the prompt just right but generally you can get what you're seeking. Want to know how?

https://medium.com/cloud-security/artificial-intelligence-2e97415216c0

I got many of these commands using AI but the results are not consistent so adding here for future reference.

# Get all the subdomains for a domain

```
domain='2ndsightlab.com'
curl -s "https://crt.sh/?q=%.$domain&output=json" | \
  jq -r '.[].common_name' | \
  sed 's/\*\.//g' | \
  sort | \
  uniq > domains.txt
```

# Get all the IP addresses for a list of domains in a text file

```
xargs -a domains.txt dig +short A
```

# Install dig in AWS CloudShell

```
sudo yum install bind-utils
```

# Wipe out git history (dangerous)
```
git checkout --orphan new_master
git add -A
git commit -m "Initial commit"
git branch -D main
git branch -m main
git push -f origin main
```

# Test if xrdp has access to certificate you want to use
```
sudo -u xrdp cat /etc/xrdp/ssl/certificate.pem > /dev/null && echo "Certificate readable" || echo "Certificate NOT readable"
sudo -u xrdp cat /etc/xrdp/ssl/private-nopass.pem > /dev/null && echo "Key readable" || echo "Key NOT readable"
```

# Securely delete a file on linux
```
sudo shred -u /file.txt
```

# Look at the top 4 rows of hex in a file
```
hexdump -C file.txt | head -n 5
```

# View a live stream of ALL commits to ANY public git repo. Yes really.
```
curl https://api.github.com/events
```
# Create an Open API spec

```
create a valid 3.0 open api spec with correct syntax and formatting, no other errors, and no missing or extra elements. Use [ ] for the base URL. Use [value] as the example for the [field]. Do not add content node to 200. Do not use any prior prompts only base it on this description:
```

# xrdp install - add repo (except I don't think I actually used this. The AWS repo worked fine.)
```
sudo add-apt-repository ppa:xrdp/xrdp
sudo apt update
sudo apt install xrdp
```

# Loop through lines of file in bash
```
while read p; do
  echo "$p"
done <file.txt
```

# netcat listener one port
```
nc -l <port>
```

# netcat listender on port 80 and 443
```
for p in 80 443; do sudo nc -lvnp $p & done
```

# tcpdump listen to port 443 and 80
```
sudo tcpdump 'port 80 or port 443' -nvt
```

#install yq on Amazon Linux ARM
```
sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_arm64
chmod a+x /usr/local/bin/yq
```
# yq to parse a yaml file and show errors
```
yq . file.yaml
```

# ran an AWS command that returns a lot of records or less and type ctrl-c instead of q and now nothing you print shows on screen
```
reset
```

# search in vi
```
<esc>:/search phrase <enter>
```
# clear a search
```
<esc>:noh
```
# go to end of line in vi
```
<esc><shift>$
```

# disable and remove AWS SSM
```
sudo systemctl stop amazon-ssm-agent
sudo systemctl disable amazon-ssm-agent
```
# stop and remove chrony if you happen to see multiple instances and not clear why
```
sudo yum remove amazon-ssm-agent  # For Amazon Linux/RHEL
sudo apt-get remove amazon-ssm-agent # For Ubuntu/Debian
```
# burp browser won't open - permissions and ownership
https://medium.com/bugs-that-bite/cant-open-burp-browser-12577802c839
```
chromedir=ls ~/BurpSuitePro/burpbrowser/139.0.7258.127/
cd $chromedir
sudo chown root chrome-sandbox
sudo chmod 4755 chrome-sandbox
```
# burp browser won't open - Missing xserver or $Display
https://medium.com/bugs-that-bite/missing-xserver-or-display-d784ea3c2d36
```
xhost si:localuser:<username>
```
# can't open default browser on ubuntu ~ reinstall browsers and update icons to point to them 
https://medium.com/bugs-that-bite/failed-to-execute-the-default-web-browser-on-aws-ubuntu-instance-running-xfce4-as-described-in-this-ef9dc43399a6
https://medium.com/bugs-that-bite/cant-run-chromium-on-ubuntu-4db4f804543d

```
sudo apt install chromium-browser
sudo apt install firefox
```
# login failed for display 0 on Ubuntu with xrdp 
https://medium.com/bugs-that-bite/login-failed-for-display-0-675504a306a9
https://medium.com/bugs-that-bite/connecting-to-sesman-ip-127-0-0-1-port-3350-login-failed-a4650d388fc0
```
# use the correct password - you had a typo
# took me way too long to figure that out
```
#disable ipv6 on ubuntu when it's blocked and ubuntu won't update
```
vi /etc/default/grub
#edit file to add this:
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash ipv6.disable=1"
GRUB_CMDLINE_LINUX="ipv6.disable=1"
#save file
sudo update-grub
sudo reboot
```
# remove conflicting chromium profile on Ubuntu
```
rm -f ~/snap/chromium/common/chromium/Singleton*
rm -f ~/.config/chromium/Singleton*
```
#what branch you're on in git repo
#replace <branch> in the commands below with local branch and remote branch (origin/<branch>)
```
git branch
```
#view changes not in your local dir
```
git log <branch>..origin/<branch>
```
#diff changes not in your local dir
```
git diff <branch>..origin/<branch>
```
#see commit status
```
git status
```
#diff what is loccal not in remote
```
git log -p <branch>..origin/<branch>
```
#view commit log
```
git log origin/<branch>..<branch>
```
#view commit log  
```
git log --graph --oneline --decorate origin/<branch>..<branch>
```
#compare your branch with remote branch \
#look for indented line followed by |/ on next line like: \
#* 1a0d944 (HEAD -> main) comment1 \
#| * 1824d2a (origin/main, origin/HEAD) comment2 \
#|/ \
#* 1a0d999 comment 3 \
#branches share a common history up to comment3 \
#the indented commit comment2 is not in local directory \
#if you have a divergent commit it can show unexpected diff output
```
git log --graph --onellog --graph --oneline --decorate --all
```
#show what's in a specific commit
#for examlpe from command above
#git show1824d2a
```
git show <commit>
```
#compare two specific commits
```
git diff <commit> <commit>
```
#trying to figure out why can't commit when appears be no differences in local and remote
# run this and look for any commit (amend), rebase, reset
#If you find a rebase or amend in the recent history, it confirms that your commit history diverged from the remote, even if the final file contents are the same. For example, amending a commit changes its hash, making it a completely new commit from Git's perspective.
```
git reflog
```
#do a dry run of a merge before changes\
#note that you'll get this error after asking you to commit changes before merging\
#fatal: You have not concluded your merge (MERGE_HEAD exists).\
#Please, commit your changes before you merge.\
#git status will show somethign like:\
#On branch main\
#Your branch and 'origin/main' have diverged,\
#and have 1 and 1 different commits each, respectively.\
#(use "git pull" if you want to integrate the remote branch with yours)\
#\
#All conflicts fixed but you are still merging.\
#(use "git commit" to conclude merge)\
#Or abort...\
#(use "git merge --abort" to abort the merge)
```
git merge --no-commit --no-ff origin/main
```
#abort a merge
```
git merge --abort
```
#to fix this error:\
#git pull\
#error: You have not concluded your merge (MERGE_HEAD exists).\
#hint: Please, commit your changes before merging.\
#fatal: Exiting because of unfinished merge.
```
git merge --abort
```
#then one of the following:
#merge local and remote changes:
```
git config pull.rebase false
```
#replace your local changes with remote changes
```
git config pull.rebase true
```
#
#git config pull.ff only is a safety setting that changes the default git pull from "merge everything" to "only merge if it's simple, otherwise stop and ask."
#if divergent branches exist will stop and user will have to do a rebase to fix. This may keep logs cleaner but can be more confusing when there are no diffs only divergent branches.
```
git config pull.ff only
```
#unset pull ff
```
git config --unset pull.ff
```
