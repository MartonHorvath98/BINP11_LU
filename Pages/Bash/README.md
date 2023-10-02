# BASH cheatsheet
---
## Basic commands

### User operations
1. `whoami` - returns the name of the user
2. `passwd` - changes password for hte current user
3. `su [OPTIONS] [<users>]` - changes the effective user ID and/or group ID to that user; important option: `-m, --preserves-environment` whe set, the command does not reset environment variables
4. `sudo` - runs commands with admin privileges, requires admin password
5. `alias [NAME][COMMAND]` - can save a command with specific flags under a new alias; useful, if we rerun a specific command flag combination several times.

### File operations
1. `cd [PATH]` change directory - to path, "/" character means the root, ".." performs a backstep, "./dir" is used for subdirectories, but can be left out and "~" means the user directory (home/username).
2. `pwd` print working directory - prints the path to the directory the user is in currently to the standard output
3. `mv [SOURCE][DEST]` - moves a file from its old directory to the new, selected one
4. `cp [SOURCE][DEST]` - copies a file from its old directory to the new, selected one

---
## Most used commands

### ls - list directory contents

The bash function `ls [OPTION]... [FILE]...` lists information about the FILEs (the current directory by default).  Sort entries alphabetically if none of -cftuvSUX nor --sort is specified.
- `-a, --all` lists hidden entries as well, starting with . (e.g., current dir(.), backstep(..), etc.)
- `-A, --almost-all` do not list implied . and ..
- `-s, --size`  print the allocated size of each file, in blocks sorted by file size, largest first
- `-l` uses long listing format, including permissins, author, last editor, file size in bites, last modification time and the file names
- `-h, --human-readable` applied together with the long listing format (-l) or size (-s) converts the block sizes to appropriate bytes (e.g., kilobytes - 4.0K, megabytes - 124M, gigabites - 1.4G etc.) 
- `--author` with -l, print the author of each file

---

### chmod - change permissions

The function `chmod [OPTION]... MODE[,MODE]... FILE...`  changes the file mode bits of each given file according to mode, which can be either a symbolic representation of changes to make, or an octal number representing the bit pattern for the new mode bits. Permission mode bits use 10 character, that looks somethin like: `-rw-r--r--` and can be interpreted as:
- the first bit (-/d) denotes whether it is a regular file ("-") or a directory ("d")
- then three times the letter combination ("rwx") means if the current user, group members (other local users) or any user can read ("r"), write ("w") or execute the file ("x"). "-" in each case means the lack of that specific permission.

**SO IN CONCLUSION, WHEN USING 'chmod'**
First we select the users whose permissions we want to modify, then the operator and then the selected file mode bits like `chmod [uga][+-=][rwx]`, where ("u") is the own user, ("g") is the group users and ("a") is all users, ("+") adds permission, ("-") removes permission and ("=") adds a permission, while removes the ones not listed.

---


