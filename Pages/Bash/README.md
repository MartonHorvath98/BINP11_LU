# BASH cheatsheet
---

## Keyboard shortcuts

|Key combination|Effect|
|---|---|
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
4. `less [FILE]` - opens a file for reading bit by bit, the reader can be exited with "q"

### Setting the PATH variable
The directories that have accessible programs can be found in the PATH variable, which can be printed to the standard output (stdout) using `echo $PATH`, the "$" sign is used generally to access variables. The command will return a colon-separated list of the directories saved in the PATH. Bash will search each of these directories, when trying to run a program. If the program is in a different path, it can be added to the PATH variable using: \n
> ```export PATH=$PATH:/<list-of-colon-separated-paths>```
This change to the path variable is temporary and will not be remebered if the the user logs out or switches to another terminal window. For the changes to be remembered, the variable assignment should be added to the .bashrc file via: \n
> ```source ./bashrc # or ./bash_profile (on MAC) ```

---
## Frequently used commands

### 'ls' - list directory contents

The bash function "ls" lists information about the FILEs (the current directory by default).  Sort entries alphabetically if --sort is not specified. Usage:
> ```ls [OPTION]... [FILE]...```
- `-a, --all` lists hidden entries as well, starting with . *(e.g., current dir(.), backstep(..), etc.)*
- `-A, --almost-all` do not list implied . and ..
- `-s, --size`  print the allocated size of each file, in blocks sorted by file size, largest first
- `-l` uses long listing format, including permissins, author, last editor, file size in bites, last modification time and the file names
- `-h, --human-readable` applied together with the long listing format (-l) or size (-s) converts the block sizes to appropriate bytes *(e.g., kilobytes - 4.0K, megabytes - 124M, gigabites - 1.4G etc.)* 
- `--author` with -l, print the author of each file

---

### 'chmod' - change permissions

The function "chmod"  changes the file mode bits of each given file according to mode, which can be either a symbolic representation of changes to make, or an octal number representing the bit pattern for the new mode bits. Usage:
> ```chmod [OPTION]... MODE[,MODE]... FILE...```
Permission mode bits use 10 character, that looks somethin like: `-rw-r--r--` and can be interpreted as:
- the first bit (-/d) denotes whether it is a regular file ("-") or a directory ("d")
- then three times the letter combination ("rwx") means if the current user, group members (other local users) or any user can read ("r"), write ("w") or execute the file ("x"). "-" in each case means the lack of that specific permission.

**SO IN CONCLUSION, WHEN USING 'chmod'**

First we select the users whose permissions we want to modify, then the operator and then the selected file mode bits like `chmod [uga][+-=][rwx]`, where ("u") is the own user, ("g") is the group users and ("a") is all users, ("+") adds permission, ("-") removes permission and ("=") adds a permission, while removes the ones not listed.

---

### 'tar' - (de)compression & archiving
 The GNU "tar" command saves (many) file(s) together into a singe disk archive, and can restore individual files from an archive. Usage:
 > ```tar [OPTIONS...] [FILE(s)]``` 
- `-x` - to extract files (from ".tar" archive format)
- `-z` - if the data is also compressed
- `-v` - to complete the process verbosely for every file in the archive or the input directories
- `-t, --list` - lists the content of an archive
- `-c` - to create a new archive directory
- `-f, --file=[FILE]` - uses archive file or device archive
Examples:
```
tar -cf archive.tar foo bar # creates archive.tar from files foo and bar
tar -tvf archive.tar # verbosely lists every file in archive.tar
tar -xvzf archive.tar.gz # extract all files from the compressed archive.tar.gz 
``` 

---

### 'wc'- new line, word and byte counts

The function "wc" prints the newline, word and character (byte) counts from each FILE. When no FILE is specified or when FILE is -, it reads the standard input. Usage:
> ```wc [OPTION...] [FILE]```
- `-c, --bytes` - prints the byte counts
- `-m, --chars` - prints the character counts (may differ for the byte count for complex characters)
- `-l, --lines` - print the new line counts, or the total lines if more than one FILE is specified
- `-L, --max-line-length` - prints the maximum display width
- `-w, --words` - print the word counts, where a word is a non-zero-length sequence of characters delimited by white space.

---

### 'tr' - translate

The function "tr" translates, squeezes and/or deletes characters from the standard input, writing to the standard output, which makes it useful for piped commands. Usage:
> ```tr [OPTIONS...] SET1 [SET2]```
- `-c, --complement` - use the complement of SET1
- `-d, --delete` - delete characters in SET1, do not translate
- `-s, --squeeze-repeats` - 
