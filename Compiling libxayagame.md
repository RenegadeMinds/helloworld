# How to Compile libxayagame. 

In this tutorial, we'll compile libxayagame so that we can use it in other tutorials and even in our own games. 

Download MSYS2 x86_64 (https://www.msys2.org/) from this link: 

http://repo.msys2.org/distrib/x86_64/msys2-x86_64-20180531.exe

Install into default path C:/msys64, and run using
 
![]()

You will need several files. Download them [here]().

Copy all those files into C:\msys64\home\username\libxayagame.

Run MSYS2 from your Start menu or here:

	C:\msys64\msys2.exe

Copy the following code block to your clipboard. Make certain that you copy it exactly with no blank lines at the end. 

	/*******************************/
	./install_xaya_1.sh <<!
	y


	y
	y
	y
	! 
	/********************************/

In MSYS2, press SHIFT+INSERT to paste and run that. The code block above will run the "install_xaya_1.sh" script and automatically answer all the prompts. 

You will see the following message:

	warning: terminate MSYS2 without returning to shell and check for updates again
	warning: for example close your terminal window instead of calling exit

Close MSYS2 and run it again as you did above.

![]()

Again, paste in the code block from above using SHIFT+INSERT. 

Wait for everything to install, then close and reopen MSYS2.  

Similar to how you copied the code block above exactly and with no blank lines at the end, copy the following code block.

/***********************/
./install_xaya_2.sh <<!
Y
!

/************************/

Paste it into MSYS2 as you did above by pressing SHIFT+INSERT. Wait for the script to finish. 

Congratulations! You've just built your own GSP using libxayagame. You can now proceed on to the Hello World in C++ tutorial.



