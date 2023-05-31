# About

[![](https://github.com/BaptisteBdn/docker-selfhosted-apps/raw/main/_utilities/borg.svg)](https://github.com/BaptisteBdn/docker-selfhosted-apps/blob/main/_utilities/borg.svg)

BorgBackup is a deduplicating backup program, it supports compression and authenticated encryption.

* [Github](https://github.com/borgbackup/borg)
* [Documentation](https://borgbackup.readthedocs.io/en/stable/)

Borg is a key element for this selfhosted infrastructure as it will back up all your valuable data, the scripts alongside borg provides the following features :

- Local backup of your docker repository
    - docker-compose, env files, etc.
    - **volumes** containing important data for your containers 
- External cloud backup on AWS (S3)
- Backup notifications with [Gotify](../gotify)

The scripts are configured for use with [Gotify](../gotify) and Cloudflare R2 storage buckets.

# Table of Contents

<!-- TOC -->

- [About](#about)
- [Table of Contents](#table-of-contents)
- [Files structure](#files-structure)
- [Information](#information)
    - [env](#env)
        - [borg](#borg)
        - [R2](#R2)
        - [Gotify](#gotify)
    - [Backup scripts](#backup-scripts)
- [Usage](#usage)
    - [Requirements](#requirements)
    - [Configuration](#configuration)
    - [Download and extract backups](#download-and-extract-backups)
- [Security](#security)

<!-- /TOC -->

# Files structure 

```bash
.
|-- backup-borg-s3.sh*
|-- download-backup-s3.sh*
`-- excludes.txt
```
- `backup-borg-r2.sh`- a script to back up your data : locally and in the cloud (AWS S3)
- `download-backup-r2.sh`- a script to download your data from the cloud
- `excludes.txt` - an exclude file, default will back up all your docker infrastructure 

Please make sure that all the files and directories are present.

# Information

Borg requires user's specific configuration. 


### borg

```bash
# Directory to back up
DOCKER_DIR=/path/to/docker_directory
```
The directory containing all the configuration of the docker containers, usually the directory you cloned this guide into.


```bash
# Borg repository
BORG_REPO=/path/to/borg_repository
BORG_PASSPHRASE=borg_passphrase
```
The borg repository where the backups will be located, and the corresponding passphrase used to encrypt the datas.

To create the repository and set your passphrase :

```bash
borg init --encryption=repokey /path/to/repo
```

> You can use [vaultwarden](../vaultwarden) to store your passphrase securly.

### R2

> Keep in mind that Cloudflare R2 is not free. The amount of storage used and sent to the storage bucket will cost the user.

```bash
# R2 configuration
CLOUDFLARE_R2_ACCOUNT_ID="your_account_id"
CLOUDFLARE_R2_ZONE_ID="your_zone_id"
CLOUDFLARE_R2_BUCKET_NAME="your_bucket_name"
```

Cloudflare provides a lot of services, we are gonna use R2 which is an object storage service, based on AWS S3, where you can store and protect any amount of data for virtually any use case.
It is a great, reliable and cheap way to store your already encrypted backups.

In order to use R2, you will need a Cloudflare account. Luckily, if you have followed the guide you will already have one.


Create your R2 bucket, keep in mind that the name of the bucket must be unique between all users using R2, you can choose something like `cf-docker-selfhost-backups-1069`. Please be careful not to put your bucket publicly visible, by default it should not be.

> NOTE: Content inside docker volumes can be sometimes owned by root as they are created by docker, as a result, to avoid conflict I run the backups and R2 upload as root. If you want to do the same, the R2 profile will have to be configured inside root's home.

The R2 configuration is finished, add the bucket name and the ids from your cloudflare profile to the files.


### Gotify

You need to have a selfhosted [gotify](../gotify) available, check the guide if you want to know how to generate a token.

## Backup scripts

The backup script works in 5 steps :

- Stops all running docker container to ensure uncorrupted files
- Create local borg backup 
- Prune old backups
    - Keep the most up to date daily, weekly and monthly backup
- Synchronise the local backup to the R2 bucket (kind of like rsync would do)
- Starts all docker containers
- Notify using Gotify


The download script works in 2 steps :

- Check that you have enough space on your host
- Download the remote encrypted backup


# Usage

## Requirements

Please ensure that the env variables are correctly configure.

## Configuration

While you want to keep most of the data, you may also want to exclude heavy files from backups (media files, logs, etc.).
Add any **full path** to any directory or file that you want to exclude to `exclude.txt`.

Now that everything is set up, you can run the backup script.

```bash
sudo /bin/bash /path/to/backup-borg-r2.sh
```

You can also use cron to automate the backup.

```bash
1 3 * * 1 root /bin/bash /path/to/backup-borg-r2.sh >> /var/log/backup.log
```
This will run the backup script as root every monday at 3.

## Download and extract backups

If you ever need your backup, borg makes it pretty easy.

First, download the backup using the download backup script.

```bash
/bin/bash /download-backup-r2.sh
```

List the backups available (you will need your passphrase).

```bash
borg list /tmp/cf-backup
```

Then create and move to the folder you want to extract your backup in.

```bash
mkdir /tmp/extracted-backup && cd /tmp/extracted-backup
```

Finally, extract the backup you need (it will extract in the directory you are located in).

```bash
borg extract /tmp/cf-backup::backup-2021-12-06T03.01
```


# Security

A few security points : 
- Please be careful not to put your bucket publicly visible, by default it should not be.
- You can store your passphrase in [vaultwarden](../vaultwarden).
- Test your backup recovery process, try to download, extract and run your backup to check if everything runs correctly.
- Check the backup scripts and try to understand them, you will have more trust in your backup, that's the beauty of opensource.


