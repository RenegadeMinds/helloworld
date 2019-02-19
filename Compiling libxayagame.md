# How to Compile libxayagame

In this tutorial, we'll compile libxayagame so that we can use it in other tutorials and even in our own games. Follow the instructions below exactly and do not deviate from them. 

Download MSYS2 x86_64 (https://www.msys2.org/) from this link: 

http://repo.msys2.org/distrib/x86_64/msys2-x86_64-20180531.exe

Install into default path `C:/msys64` then run MSYS2 (the 64-bit version and **NOT** the 32-bit version) from your Start menu.

You will need several files. 

- install_xaya_1.sh
- install_xaya_2.sh
- libglog.pc
- lmdb.pc
- stubgeneratorfactory.cpp
- stubgeneratorfactory.h

Download them [here](libxayagame-compiler-files.zip).

Copy all those files into C:\msys64\home\<username>\. Do not copy into a subfolder. The files must be in the "username" folder. These files:

- libglog.pc
- lmdb.pc
- stubgeneratorfactory.cpp
- stubgeneratorfactory.h

Are automatically deleted once they are no longer needed. If you need to start over, make certain to copy them to your username folder again. 

Copy the following code block to your clipboard **without the comment lines**. Make certain that you copy it exactly with no blank lines at the end. 

	/*******************************/
	./install_xaya_1.sh <<!
	y


	y
	y
	y
	!
	/********************************/

In MSYS2, press SHIFT+INSERT to paste and run that. The code block above will run the "install_xaya_1.sh" script and automatically answer all the prompts. 

If it doesn't work, copy the code block above into a text editor and ensure that there is no blank line at the bottom. Next, select all then copy it again and paste into MSYS2 as above. Here's a screenshot of it pasted into a text editor. Note the cursor position and the lack of whitespace at the end. 

![No whitespace](img/No-blank-lines-note-cursor.png)

When the code block runs, you will see the following message:

	warning: terminate MSYS2 without returning to shell and check for updates again
	warning: for example close your terminal window instead of calling exit

Sometimes life is messy and we must accept our fate. Click the X in the upper-right corner to close MSYS2 then click OK. 

![Click OK](img/click-ok.png)

Run MSYS2 again as you did above. 

Again, paste in the same code block from above using SHIFT+INSERT. 

Wait for everything to install, then close and reopen MSYS2.

Similar to how you copied the code block above exactly and without the comment lines and with no additional blank lines at the end, copy the following code block. 

	/***********************/
	./install_xaya_2.sh <<!
	Y
	!

	/************************/

Note that there is 1 blank line after "!" that should be copied, but not more than that. You can select from top to bottom and then press SHIFT+LEFT_RIGHT_ARROW to adjust the selection. Test it in a text editor. Here's a screenshot. Note the cursor position.

![Second copy paste](img/second-copy-paste.png)

Paste it into MSYS2 as you did above by pressing SHIFT+INSERT. Wait for the script to finish. 

Congratulations! You've just built your own GSP using libxayagame. You can now proceed on to the Hello World in C++ tutorial.

# Trouble Shooting

As mentioned above, copying and pasting must be done with the proper white space. You may need to copy into a text editor and delete a trailing space or line break. 

## Gnu32

Some GNU tools may cause the compilation to fail. You may need to uninstall these entirely, and then delete all references to "GnuWin32" in the Windows Registry. To do that:

1. Open up regedit.exe 
1. Click Edit > Find...
1. Type in GnuWin32
1. Check:
	1. Keys
	1. Values
	1. Data
1. Click Find Next
1. Verify that the registry entry should be deleted, then delete it
1. Press F3 to find the next "GnuWin32" entry
1. Repeat steps #6 and #7

Once you've cleaned all the GNU entries from the registry, open a new MSYS2 (64-bit) window and try again from where it failed above. You may need to entirely start over, but it shouldn't be necessary. 

