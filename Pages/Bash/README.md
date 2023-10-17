# BASH cheatsheet
---

## Keyboard shortcuts

|Key combination|Effect|
|---|:---:|
|Ctrl + A|Go to the beginning of the line|
|Ctrl + E|Go to the end of the line|
|Ctrl + D|Remove a character at the cursor position (or exit a shell or command)|
|Ctrl + K|Remove everything fro m the cursor to the end of the line|
|Ctrl + U|Remove everything before the cursor|
|Ctrl + L|Clear the terminal|
|Ctrl + C|Exit a running program|
|Alt + U|Make a word uppur-case (does not work on MAC)|
|ALt + L|Make a word lower-case (not on MAC)|

---

## Basic commands

### User operations
1. `whoami` - returns the name of the user
2. `passwd` - changes password for hte current user
3. `su [OPTIONS] [<users>]` - changes the effective user ID and/or group ID to that user; important option: `-m, --preserves-environment` whe set, the command does not reset environment variables
4. `sudo` - runs commands with admin privileges, requires admin password
5. `alias [NAME][COMMAND]` - can save a command with specific flags under a new alias; useful, if we rerun a specific command flag combination several times.

### File operations
1. `cd [PATH]` change directory - to path, "/" character means the root, ".." performs a backstep, "./dir" is used for subdirectories, but "./" can be left out. Finally, "~" means the user directory (home/username).
2. `pwd` print working directory - prints the path to the directory the user is in currently to the standard output
3. `mv [SOURCE][DEST]` - moves a file from its old directory to the new, selected one
4. `cp [SOURCE][DEST]` - copies a file from its old directory to the new, selected one

### Handling text file(s)
1. `cat [FILE]` - show the contents of a file, can be overwhelming if the file is big
2. `head -[num] [FILE]` or `tail -[num] [FILE]` - show the first or last n lines of the file
3. `touch [FILE]` - creates new files
4. `less [FILE]` - opens a file for reading bit by bit, the reader can be exited with q

### Setting the PATH variable
The directories that have accessible programs can be found in the PATH variable, which can be printed to the standard output (stdout) using `echo $PATH`, the '$' sign is used generally to access variables. The command will return a colon-separated list of the directories saved in the PATH. Bash will search each of these directories, when trying to run a program. If the program is in a different path, it can be added to the PATH variable using:
`export PATH=$PATH:/<list-of-colon-separated-paths>`
This change to the path variable is temporary and will not be remebered if the the user logs out or switches to another terminal window. For the changes to be remembered, the variable assignment should be added to the .bashrc file via:
`source ./bashrc # or ./bash_profile (on MAC) `  

---
## Frequently used commands

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



