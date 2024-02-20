# Regex Cheat Sheet
The tables below are a reference to basic regex (the tables are non-exhaustive).

## Characters

|Regex|Legend|Example|Sample match|
|:-:|---|---|---|
|`\d`|one digit from 0 to 9<br>*python3: one unicode digit in any script*|\d\d|25|
|`\w`|"word character": ASCII letter, digit or underscore<br>*python3: unicode letter, ideogram or underscore*|\w-\w|A-1|
|`\s`|"whitespace character": space, tab, newline, carriage return, vertical tab<br>*python3: any unicode separator*|a\sb|a b|
|`\D`|one character the is **~~NOT~~** a digit|\\D\\D\\D|ABC|
|`\W`|one character the is **~~NOT~~** a word character|\\W\\W\\W|*+\)|
|`\S`|one character the is **~~NOT~~** a whitespace character|\\S\\S\\S|ABC|

## Quantifiers

|Regex|Legend|Example|Sample match|
|:-:|---|---|---|
|\+|one or more (greedy)|\\d+|12345|
|\{n\}|exactly n times|\\D\{3\}|ABC|
|\{2,4\}|between 2 t o4 times|\\d\{2,4\}|123|
|\{3,\}|3 or more times|\\w\{3,\}|many_letters|
|\*|0 or more times (greedy)|