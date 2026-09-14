# linux-backup-script

![Bash](https://img.shields.io/badge/Bash-4EAA25?style=flat&logo=gnubash&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=flat&logo=linux&logoColor=black)
![Shell Scripting](https://img.shields.io/badge/Shell_Scripting-121011?style=flat&logo=gnu-bash&logoColor=white)
![Automation](https://img.shields.io/badge/Automation-0A66C2?style=flat)
![Cron](https://img.shields.io/badge/Cron-2C3E50?style=flat)
![tar/gzip](https://img.shields.io/badge/tar%2Fgzip-CC3534?style=flat)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat)

A Bash script that automatically finds and archives files modified within
the last 24 hours, then moves the compressed backup to a chosen destination
directory. Built as a hands-on project for learning core Linux shell
scripting concepts: argument handling, path resolution, timestamp math,
arrays, loops, and `tar` archiving.

## Repository structure

```
linux-backup-script/
├── backup.sh              # the executable backup script
├── README.md               # you are here
├── LICENSE                 # MIT license
├── .gitignore               # ignores generated backup archives and test data
└── docs/
    └── walkthrough.md      # task-by-task explanation of how the script was built
```

## What it does

Given a target directory and a destination directory, `backup.sh`:

1. Validates that exactly two arguments were passed and that both are real directories.
2. Scans the target directory for files whose last-modified timestamp is within the past 24 hours.
3. Archives and compresses those files into `backup-<unix-timestamp>.tar.gz`.
4. Moves the archive into the destination directory.
5. Exits cleanly (with a message, not an error) if there is nothing to back up.

## Usage

```bash
./backup.sh <target_directory> <destination_directory>
```

**Example:**

```bash
./backup.sh important-documents backups/
```

```
Target Directory= important-documents
Destination Directory= backups/
important-documents/notes.txt
important-documents/report.pdf
Backup complete: /home/user/backups/backup-1734000000.tar.gz
```

## Requirements

- Bash
- GNU coreutils (`date`, `tar`) — this script relies on GNU `date -r <file>`
  to read a file's last-modified timestamp, so it targets Linux environments
  rather than macOS/BSD, where `date` behaves differently.

## Installation

Clone the repo and make the script executable:

```bash
git clone https://github.com/<your-username>/linux-backup-script.git
cd linux-backup-script
chmod +x backup.sh
```

Optionally install it system-wide so it can be run from anywhere:

```bash
sudo cp backup.sh /usr/local/bin/backup.sh
```

## Automating it with cron

To run the backup daily at 2 AM, add a line like this to your crontab
(`crontab -e`):

```
0 2 * * * /usr/local/bin/backup.sh /path/to/target /path/to/destination
```

## How it's built

The script was developed incrementally, task by task — each step tackled
one piece of the problem before being assembled into the final solution
below. A full write-up of that process, including the reasoning behind
each step, is in [`docs/walkthrough.md`](docs/walkthrough.md).

| Concept | Where it's used |
|---|---|
| Argument validation (`$#`, `-d`) | Usage checks at the top of the script |
| Command substitution (`$( )`) | Capturing `pwd` and `date` output |
| Timestamp arithmetic (`$(( ))`) | Computing the 24-hour cutoff |
| Arrays (`declare -a`, `+=`) | Collecting the list of files to back up |
| Looping over files (`for file in *`) | Scanning the target directory |
| Safe quoting (`"$var"`, `"${arr[@]}"`) | Preventing word-splitting on filenames with spaces |
| Archiving (`tar -czvf`) | Building the compressed backup |

## Notes on the improvements made over the original draft

This version includes a few small hardening changes beyond the base
assignment:

- All variable expansions are quoted to avoid breaking on filenames with spaces.
- The script exits with a clear error and correct exit code (`1`) on invalid input.
- It exits gracefully (exit code `0`, informative message) if no files qualify for backup, rather than calling `tar` with an empty file list.
- Loop iteration skips non-regular files (e.g. subdirectories) so `date -r` isn't run on something it can't read a mtime for the same way.

## License

Released under the [MIT License](LICENSE).

## Acknowledgments

Built as the final project for *Introduction to Linux Commands and Shell
Scripting*, then reorganized and hardened for standalone use.
