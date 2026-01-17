#2nd Sight Lab Mac Start Up Script to Disable Unneccessary Services
#Change the Username and network devices below to your own
#See related blog posts found here:

#remove any ssh sockets in tmp directory 
sudo rm -rf /tmp/com*

#diable ipv6 on a mac
#https://medium.com/cloud-security/disabling-ipv6-on-a-mac-fce45a19885a

#mac networking and related posts at the bottom
#https://medium.com/cloud-security/apple-macintosh-network-traffic-2b172d084fd

echo "Running  Mac OS Startup Script found at /Users/Shared/2sl-startup-config.sh"

echo "Disable netbios - somehow this got removed??"
sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.netbiosd.plist

echo "Disable SMB"
/usr/bin/sudo /bin/launchctl disable system/com.apple.smbd

echo "Disable IPv6"
networksetup -setv6off "Your device (see ipv6 post)"
networksetup -setv6off "Your device (see ipv6 post)"

echo "stop httpd (webserver)"
sudo launchctl unload -w /System/Library/LaunchDaemons/org.apache.httpd.plist

echo "Turn off sharing discoverability"
sudo defaults write com.apple.sharingd DiscoverableMode "Off"

echo "Disable  muticast DNSResponder advertisements"
sudo defaults write /Library/Preferences/com.apple.mDNSResponder.plist NoMulticastAdvertisements -bool true

echo "Disable air drop"
sudo defaults write com.apple.NetworkBrowser DisableAirDrop -bool true

echo "Disable AirplayReceiver"
sudo /usr/bin/defaults -currentHost write com.apple.controlcenter.plist AirplayRecieverEnabled -bool false

echo "Turn off ODS Agent"
sudo /bin/launchctl disable system/com.apple.ODSAgent

echo "Turn off Screensharing"
sudo /bin/launchctl disable system/com.apple.screensharing

echo "Turn off printer sharing"
sudo /usr/sbin/cupsctl --no-share-printers

echo "Legit or rogue open directory software?"
sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.odproxyd.plist

echo "Turn remote login off"
echo "yes" |  sudo /usr/sbin/systemsetup -setremotelogin off

echo "Turn remote management off"
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -deactivate -stop

echo "Turn off uucp- very old unix to unix protocol"
sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.uucp.plist

echo "Turn off remote apple events"
sudo /usr/sbin/systemsetup -setremoteappleevents off

echo "Disable Internet sharing (via a NAT apparently)"
sudo /usr/bin/defaults write /Library/Preferences/SystemConfiguration/com.apple.nat NAT -dict Enabled -int 0

echo "Disable asset cache manager"
sudo /usr/bin/AssetCacheManagerUtil deactivate

echo "Disable ftp proxy"
sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.ftp-proxy.plist

echo "Disable home sharing"
sudo /usr/bin/defaults write com.apple.amp.mediasharingd home-sharing-enabled -int 0

echo "Disable bluetooth"
sudo /usr/bin/defaults -currentHost write com.apple.Bluetooth PrefKeyServicesEnabled -bool false

echo "Disable assistant"
sudo /usr/bin/defaults write com.apple.assistant.support.plist 'Assistant Enabled' -bool false

echo "Disable Siri"
sudo /usr/bin/defaults write com.apple.Siri.plist LockscreenEnabled -bool false
sudo /usr/bin/defaults write com.apple.Siri.plist StatusMenuVisible -bool false
sudo /usr/bin/defaults write com.apple.Siri.plist TypeToSiriEnabled -bool false
sudo /usr/bin/defaults write com.apple.Siri.plist VoiceTriggerUserEnabled -bool false

echo "Disable diagnostic mesages history list for Apple support"
sudo /usr/bin/defaults write /Library/ApplicationSupport/CrashReporter/DiagnosticMessagesHistory.plist AutoSubmit -bool false
sudo /usr/bin/defaults write /Library/ApplicationSupport/CrashReporter/DiagnosticMessagesHistory.plist ThirdPartyDataSubmit -bool false
sudo /bin/chmod 644 /Library/ApplicationSupport/CrashReporter/DiagnosticMessagesHistory.plist
sudo /usr/bin/chgrp admin /Library/ApplicationSupport/CrashReporter/DiagnosticMessagesHistory.plist

echo "Opt out of Siri data sharing"
sudo /usr/bin/defaults write /Users/<username>/Library/Preferences/com.apple.assistant.support "Siri Data Sharing Opt-In Status" -int 2

echo "Limit ad tracking"
/usr/bin/sudo -u <username> /usr/bin/defaults write /Users/<username>/Library/Preferences/com.apple.Adlib.plist allowApplePersonalizedAdvertising -bool false
