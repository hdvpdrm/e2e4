# e2e4
This is the essoteric programming language.<br>
It is interpeted and implemented in ```Perl```,<br>
'cause ```Perl``` is kinda good choice for text processing tasks.<br>


https://github.com/hdvpdrm/e2e4/blob/main/chess.gif - hello world program execution.

# Syntax
Program in e2e4 is represented as a sequence of commands splitted by new line character ```\n```.<br>
There are 2 patterns for commands:<br>
1) you place a figure.
2) you move a figure.

## Example
```a1K``` - place King at a1.<br>
```a1b1``` - move King from a1 to b1.

That's almost all you need to know, folks!.


## Figures
1) ```K``` - king.
2) ```k``` - knight.
3) ```P``` - pawn.
4) ```R``` - rook.
5) ```Q``` - queen.
6) ```B``` - bishop.

# Concept
You have a matrix 8x8. Simple, isn't it?<br>
So each cell equals 0 if no figure is placed.<br>
Each line of matrix is binary number.<br>
It converts to decimal and its associated ascii character.<br>


