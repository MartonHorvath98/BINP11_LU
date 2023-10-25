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
4. `less [FILE]` - opens a file for reading bit by bit, the reader can be exited with "q". Typing "g" moves to the top of the document, "G" goes to the end, typing "/" the user can searc for a string in the document and then typing "n" will move to the subsequent match.

### Setting the PATH variable
The directories that have accessible programs can be found in the PATH variable, which can be printed to the standard output (stdout) using `echo $PATH`, the "$" sign is used generally to access variables. The command will return a colon-separated list of the directories saved in the PATH. Bash will search each of these directories, when trying to run a program. If the program is in a different path, it can be added to the PATH variable using: \n
```
export PATH=$PATH:/<list-of-colon-separated-paths>
```
\nThis change to the path variable is temporary and will not be remebered if the the user logs out or switches to another terminal window. For the changes to be remembered, the variable assignment should be added to the .bashrc file via: \n
```
source ./bashrc # or ./bash_profile (on MAC)
```

### Remote login
1. `ssh [DEST]` - with "ssh" (secure shell) you can access any distant machine, where you have permission to log in. You can leave the last stage of the network, you logged into with ssh using `exit`
2. `scp [user@host:port][DEST]` - with "scp" (secure copy) you can copy files between hosts on a network using ssh for data transfer.
3. `rsync -a [user@host:port][DEST]` -  while "scp" works on individual files, "rsync" synchronizes a complete folder between hosts on the network. Both "scp" and "rsync" work both ways, one process is called a push operation because it “pushes” a directory from the local system to a remote system. The opposite operation is pull, and is used to sync a remote directory to the local system. 

---
## Frequently used commands

### 'ls' - list directory contents

The bash function "ls" lists information about the FILEs (the current directory by default).  Sort entries alphabetically if --sort is not specified. 
Syntax:
```
ls [OPTION]... [FILE]...
```
- `-a, --all` lists hidden entries as well, starting with . *(e.g., current dir(.), backstep(..), etc.)*
- `-A, --almost-all` do not list implied . and ..
- `-s, --size`  print the allocated size of each file, in blocks sorted by file size, largest first
- `-l` uses long listing format, including permissins, author, last editor, file size in bites, last modification time and the file names
- `-h, --human-readable` applied together with the long listing format (-l) or size (-s) converts the block sizes to appropriate bytes *(e.g., kilobytes - 4.0K, megabytes - 124M, gigabites - 1.4G etc.)* 
- `--author` with -l, print the author of each file

---

### 'chmod' - change permissions

The function "chmod"  changes the file mode bits of each given file according to mode, which can be either a symbolic representation of changes to make, or an octal number representing the bit pattern for the new mode bits. 
Syntax:
```
chmod [OPTION]... MODE[,MODE]... FILE...
```
\nPermission mode bits use 10 character, that looks somethin like: `-rw-r--r--` and can be interpreted as:
- the first bit (-/d) denotes whether it is a regular file ("-") or a directory ("d")
- then three times the letter combination ("rwx") means if the current user, group members (other local users) or any user can read ("r"), write ("w") or execute the file ("x"). "-" in each case means the lack of that specific permission.

*SO IN CONCLUSION, WHEN USING 'chmod'* First we select the users whose permissions we want to modify, then the operator and then the selected file mode bits like `chmod [uga][+-=][rwx]`, where ("u") is the own user, ("g") is the group users and ("a") is all users, ("+") adds permission, ("-") removes permission and ("=") adds a permission, while removes the ones not listed.

---

### 'tar' - (de)compression & archiving
 The GNU "tar" command saves (many) file(s) together into a singe disk archive, and can restore individual files from an archive. 
 Syntax:
 ```
tar [OPTIONS...] [FILE(s)]
``` 
- `-x` - to extract files (from ".tar" archive format)
- `-z` - if the data is also compressed
- `-v` - to complete the process verbosely for every file in the archive or the input directories
- `-t, --list` - lists the content of an archive
- `-c` - to create a new archive directory
- `-f, --file=[FILE]` - uses archive file or device archive

*Examples:*
```
tar -cf archive.tar foo bar # creates archive.tar from files foo and bar
tar -tvf archive.tar # verbosely lists every file in archive.tar
tar -xvzf archive.tar.gz # extract all files from the compressed archive.tar.gz 
``` 

---

### 'wc'- new line, word and byte counts

The function "wc" prints the newline, word and character (byte) counts from each FILE. When no FILE is specified or when FILE is -, it reads the standard input. 
Syntax:
```
wc [OPTION...] [FILE]
```
- `-c, --bytes` - prints the byte counts
- `-m, --chars` - prints the character counts (may differ for the byte count for complex characters)
- `-l, --lines` - print the new line counts, or the total lines if more than one FILE is specified
- `-L, --max-line-length` - prints the maximum display width
- `-w, --words` - print the word counts, where a word is a non-zero-length sequence of characters delimited by white space.

---

### 'tr' - translate

The function "tr" translates, squeezes and/or deletes characters from the standard input, writing to the standard output, which makes it useful for piped commands. 
Syntax:
```
tr [OPTIONS...] SET1 [SET2]
```
- `-c, --complement` - use the complement of SET1
- `-d, --delete` - delete characters in SET1, do not translate
- `-s, --squeeze-repeats` - 

---

### 'paste' - paste sequential

The function "paste" writes lines consisting of the sequentially corresponding lines from each FILE, separated by TABs, to standard output. With no FILE, or when FILE is -, read standard input. It is best use as part of a pipe and can be powerful to parse lines into columns, where functions like "grep" can work better. 
Syntax:
```
paste [OPTION]... [FILE]... # example: paste - - (pastes every other lines in a second column) 
```
- `-d, --delimiter=[LIST]` instead of the deault TAB delimiter it reuse characters from LIST

---

### 'cut' - select 

The function "cut" prints selected parts of lines from each FILE to the standard output. With no FILE or when FILE is -, it reads the standard input instead. 
Syntax:
```
cut OPTION... [FILE]...
```
- `-b, --bytes=LIST` select bytes defined by the LIST
- `-c, --character=LIST` select these characters
- `-f, --fields=LIST` select these fields
Use only one of "-b","-c" or "-f" at the same time, while the LIST can be made up of one range or many ranges separated by commas, where the format of the range is set as follows: **M** - the M'th byte/char/field (starting from 1), **M-** - everything starting from the M'th, **-N** everything up to N'th, **M-N, (O-P), ...** everything between the N'th and M'th and then O'th and P'th...

- `-d, --delimiter=DELIM` when selecting field, the delimiter can be defined, unless the search defaults back to TABs
- `-s, --only-delimited` unless "-s" is set, "-f" also prints any line that does not contain the delimiter character
- `--complement` complement the set of selected bytes/characters/fields

*Example:*
```
cut -b 50-100 input.txt # takes out character 50 to 100 from the file

cat list.txt | cut -d : -f 5-7 | tr : "\t" # from a : delimited file prints and tab delimits the fifth to seventh columns.
```

---

### 'grep' - pattern search

The function "grep" searches in PATTERN(S) in FILE(S). Patterns can contain multiple patterns separated by newlines. 
Syntax:
```
grep [OPTION] ... PATTERN [FILE] ... 
```
*Pattern selection*
- `-e, --regexp=PATTERN` use PATTERN for matching 
- `-G, --basic-regexp` defines basic regular expressions, `-P, --perl-regexp` Perl type regular expressions, `-F, --fixed-strings` strings
- `-i, --ignore-case` ignores case distinction in the pattern and the data, which are accounted for by default

*Output control*

- `-v, --invert-match` selects the non-matching lines
- `-c, --count` returns the number of counts instead of the lines with matches (limitation! "grep" can only find one match per line and the count will disregard any further matches)
- `-m, --max-count=INT` stop after INT selected lines
- `-d, --directories=ACTION` how to handle directories, optional actions are "read", "recourse" or "skip"
- `-B, --before-context=INT` print INT lines from before the line that matches
- `-A, --after-context=INT` prints INT lines after the match
- `-C, --context=INT` print INT line of output context, where the middle line is the one with the match

*Examples:*
```
cat fasta.fna | grep \> 
# prints the header lines, starting with ">" (the escape character "\" is needed otherwise > only channels the outputto a file)

cat fasta.fna | grep -c \> # instead of returning the headers counts them

cat fasta.fna |grep -v \> | grep -c "^ATGAA" 
# -v removes headers and -c counts sequences that start with the string "ATGAA"
```

---

### sed - stream editor

The "sed" function in Linux stands for stream editor and can perform a wide range of functions, although most common uses are for substituion, for find or for remove. Using "sed" we can change files without opening them which is much quicker way to find and replace something in file, than first opening that file in an editor (like VIM) and then changing it.
Syntax:
```
sed OPTIONS... [SCRIPT] [FILE]... 
```
*Replacing or substituting string*
- `s/old/new/` using "s//" sed replaces the old string with the new string (by default: for the first occurence in every new line)
- `s/old/new/2` substitutes the nth occurence in the line, "/1" "/2" replaces the first or the second 
- `s/old/new/g` replaces every occurence of the pattern, can be combined with a number like "/2g" will replace from the second occurrence to all occurrences in a line
- `3 s/old/new/` or `1,3 s/old/new/` the line or a range of lines can be specified where to do the substitution (in a range the "$" character symbolizes the last line)
- `s/old/new/p` the flag "/p" duplicates the line where a substitution was done. When used together with the `-n, --silent` flag, only the duplicated lines are printed
- `s/old/new/I or i` matches in a case-insensitive manner

*Deleting lines*
SED command can also be used for deleting lines from a particular file. SED command is used for performing deletion operation without even opening the file:

|Expression|Range & Description|
|---|---|
|'nd'|deletes a particular line (n<sup>th</sup>) *e.g. '5d' deletes the 5<sup>th</sup>*|
|'$d'|deletes the last line|
|'4,10d'|deletes lines starting from the 4<sup>th</sup> to the 10<sup>th</sup>, *does not work in revers, in that case only deletes the last!*|
|'4,+5d'|starting from the 4<sup>th</sup> deletes the following 5 lines|
|'2,5!d'|deletes everything except from 2<sup>nd</sup> till 5<sup>th</sup> lines|
|'1\~2d' OR '1\~2!d'|prints only the even or odd lines, respectively|
|'n;d' OR -n 'n;p' |can achieve the same, even or odd lines|
|'/PATTERN/d'|deletes the pattern matching line|