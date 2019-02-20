# How to Compile libxayagame

In this tutorial, we'll compile libxayagame so that we can use it in other tutorials and even in our own games. Follow the instructions below exactly and do not deviate from them. 

# Get Downloads

Download MSYS2 x86_64 (https://www.msys2.org/) from this link: 

http://repo.msys2.org/distrib/x86_64/msys2-x86_64-20180531.exe

Install into default path `C:/msys64` then run MSYS2 (the 64-bit version and **NOT** the 32-bit version) from your Start menu.

You will need several files. 

- input1.txt
- input2.txt
- install_xaya_1.sh
- install_xaya_2.sh
- libglog.pc
- lmdb.pc
- stubgeneratorfactory.cpp
- stubgeneratorfactory.h

Download them [here](libxayagame-compiler-files2.zip).

# Copy Required Files

Copy all those files into `C:\msys64\home\<username>\`. Do not copy into a subfolder. The files must be in the "username" folder. 

Some files will be deleted when they are no longer needed.

- libglog.pc
- lmdb.pc
- stubgeneratorfactory.cpp
- stubgeneratorfactory.h

If you need to start over, make certain to copy them to your username folder again. 

# Command 1

Run the following command.

	cat "input1.txt" | ./install_xaya_1.sh

Wait for it to finish.

# Command 2

Run the following command.

	cat "input2.txt" | ./install_xaya_2.sh

Wait for it to finish.

# CONGRATULATIONS! 

Congratulations! You've just built your own GSP using libxayagame. You can now proceed on to the Hello World in C++ tutorial where we'll put libxayagame to good use! 


