# recover-deleted-file.sh
Commands to recover a deleted file

Now ideally you would unmount the device. I'm going to try something simpler but the risk is that I overwrite data in my file while try to recoveer data. I can live with that because I also have another backup of the data.

Here's what I'm going to try.

# View device partitions
lsblk -p

# How do you know which partition the file is on? Example:

In your lsblk output:

```
NAME               MAJ:MIN RM SIZE RO TYPE MOUNTPOINTS
/dev/nvme0n1       259:0    0  80G  0 disk 
├─/dev/nvme0n1p1   259:1    0  80G  0 part /
└─/dev/nvme0n1p128 259:2    0  10M  0 part /boot/efi
```

The key to identifying which partition contains the deleted file is the MOUNTPOINTS column. Here's how to interpret it:

/dev/nvme0n1p1: This is a partition that's mounted at / (the root of your filesystem). If your file was in a location like /home/user/documents/report.txt, /var/log/messages, or 

/etc/config.conf, it was located on this partition.

/dev/nvme0n1p128: This partition is mounted at /boot/efi. This partition typically contains the files needed for the system's boot loader. If you deleted a file from /boot/efi or a subdirectory within it, then this is the partition to target for recovery. 

Now that I know what partition my file is on, I can use this to search for the deleted data:

#unique string in deleted data

searchstring="unique text in my deleted file"
partition="/dev/nvme0n1p1"
sudo grep -i -a -B10 -A10 $searchstring $partition

You'll see the text and if found in memory. If you only want to see matches to your search string you can try this:

sudo grep -i -a $searchstring $partition | $partition

Then if your string is found you can try adjusting the before and after parameters to grab the full file. Depending on the size of it and some other factors this might work:

#adjust B10 and A10 to the number of lines before and after your search string you want to retrieve.
sudo grep -i -a -B10 -A10 $searchstring $partition

But here's where I ran into a problem. Whatever I was searching from that was recovered somehow corrupted my data...so...I'm going to use my backup now. I did see some of my file there but it was a very large file so I'm going to go and just restore the backup and work off that.

