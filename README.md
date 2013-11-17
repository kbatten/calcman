Calculator Manager
==================

TI-86 assembly app that allows renaming of variables, security and updates the Snd85 menu for programs.
Released January 12, 1999 on ticalc.org

------------
What it does
------------
Calculator Manager is an update to some of the features already on the
TI86. This program integrates seamlessly with the OS making it quite
user friendly. Calculator Manager actaully combines three different
things into one convenient package. The first part of the program adds
two new menu items to the Snd85 link menu. These are PRGM and ALL,
this adds the ability to transfer all types of variables to the 85.
Note that some programs may transfer incorrectly if functions not
available on the 85 are used. The second part of the program is located
in the Delete menu. It allows you to rename a variable. It wont let you
name two variables the same thing. The third part of the program is a
security program. It lets you password protect certain parts of your
calculator. You can protect the Link menu, the Mem|Reset/SelfTest
functions, and the delete and rename functions. You can also lock
individual variables from being renamed or deleted. 

------------
Instructions
------------
To run Calculator Manager simply run the program CalcMan to set it up.

Here is a list of keys in the CalcMan program.

[1] -> Install CalcMan (removes any other (sqrt)KEY program)
       * This must be done before any other function is enabled
[2] -> Uninstall CalcMan (or any other (sqrt)KEY program)
       * You must enter the password to uninstall it
       * This will reset the password back to [NTER] if you reinstall
[3] -> Change Password (default password is [ENTER])
       * You must enter the old password to change
[4 or EXIT] -> Quit and save changes
[F1] -> Lock or unlock the Link menu with a password
       * You must enter the password to toggle this
[F3] -> Lock or unlock the Reset menu with a password
       * You must enter the password to toggle this
[F5] -> Lock or unlock the Delete menu with a password
       * You must enter the password to toggle this

Here is the list keys in the Delete menu

[F3] -> Change the name of the current variable
 Del    -> Delete the last character (backspace)
 Alpha  -> Toggle between Upper and Lower Case
 Second -> Switch to numbers
 Exit   -> Quit renaming without saving
 Enter  -> Save name


[F4] -> Protect or unprotect individual variables from renaming and
        deleting (NOTE: this is disabled if you have AShell 1.3)

--------------
Known Problems
--------------
The individual protecting of variables will interfere with AShell 1.3's
 organizing function. Thus the program will disable the protection of
 individual variables if it finds you have ASE 1.3 installed on your
 calculator.
Do not start the name of a variable with a number because you will not
 be able to access it.

If you find any more bugs, have any ideas for improvements or just want
to send a comment, please contact me at:
kbatten@gmail.com

Special Thanks:
        Randy Gluvna for the TI-8x emulator
        Dux Gregis for his work on the (sqrt)KEY variable
        Jeremy Goetsch for the awesome Assembly Studio 86
	Anyone who reported bugs to me
        And Anyone who gave input on VManage (the precursor of CalcMan)

