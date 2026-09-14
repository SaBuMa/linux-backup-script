# Build walkthrough

`backup.sh` was built incrementally, one concept at a time, before being
assembled into the final script. This doc summarizes that process.

## 1. Reading input

The script takes two positional arguments: the directory to back up
(`targetDirectory`) and where to put the resulting archive
(`destinationDirectory`). Before doing anything else, it checks that exactly
two arguments were given and that both point to real directories — failing
fast with a clear usage message otherwise.

## 2. Naming the backup file

A timestamp (`date +%s`, seconds since the epoch) is captured once at the
start and reused throughout, so every part of the script refers to the same
moment in time. It's used to name the archive: `backup-<timestamp>.tar.gz`.

## 3. Resolving paths before moving around

Because the script needs to `cd` into both the target and destination
directories, it first resolves their **absolute** paths (`pwd` after `cd`-ing
into each one). That way, no matter which directory the script is currently
sitting in when it needs to move the finished archive, it always knows
exactly where to put it.

## 4. Finding files modified in the last 24 hours

The cutoff is computed once: `yesterdayTS = currentTS - 24*60*60`. The script
then loops over every entry in the target directory (`for file in *`),
checks each file's last-modified timestamp with `date -r "$file" +%s`, and
appends it to a `toBackup` array if it's newer than the cutoff.

## 5. Archiving and moving

Once the list of qualifying files is built, `tar -czvf` compresses them into
the named archive, which is then moved into the destination directory.

## Hardening decisions

A few things were tightened up compared to a minimal version of the script:

- **Quoting.** Every variable and array expansion (`"$var"`, `"${arr[@]}"`)
  is quoted so filenames containing spaces don't get split into multiple
  arguments.
- **Empty-result handling.** If no files were modified in the last 24 hours,
  the script exits cleanly with a message instead of calling `tar` with an
  empty argument list (which would otherwise error or produce a useless
  archive).
- **Non-regular files.** The loop skips anything that isn't a regular file
  (e.g., subdirectories), since `date -r` and `tar` should only be applied to
  actual files here.
- **Exit codes.** Invalid usage exits `1`; a successful run — including a
  "nothing to back up" run — exits `0`, so the script behaves predictably if
  it's ever wired into cron or another automated pipeline.
