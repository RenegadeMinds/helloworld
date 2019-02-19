# Hello World C++

In this tutorial we're going to build a Hello World console application in C++. 

Our application will connect to libxayagame, which will return results for us. In another command prompt or terminal, we'll send moves to the game and retrieve the results. 

Download the code here. 

# Create helloworld.cpp and Add Includes

Open up your text editor and create a helloworld.cpp file. Next, add in these includes:

	#include <xayagame/defaultmain.hpp>

	#include <gflags/gflags.h>
	#include <glog/logging.h>

	#include <json/json.h>

	#include <cstdlib>
	#include <iostream>
	#include <sstream>

"xayagame/defaultmain.hpp" adds in libxayagame. This is the core daemon that processes game states for you. 

The "gflags/gflags.h" and "glog/logging.h" includes are for command line flag processing and the Google logging module. You can find them [here](https://github.com/gflags/gflags) and [here](https://github.com/google/glog), respectively. Don't get hung up on these though. They're just libraries that we'll be using.

We need to use JSON RPC, and "json/json.h" gives us that.

The other includes are simply standard libraries.

# Create an Anonymous Namespace

Much of our code will be in an anonymous namespace, so go ahead and create that.

	namespace { }

Now we can add code to our anonymous namespace. 

# Define Connection Variables

In order to connect to the daemon, we need several variables.

- xaya_rpc_url: URL at which Xaya Core's JSON-RPC interface is available
- game_rpc_port: The port at which the game daemon's JSON-RPC server will be start (if non-zero). 
- enable_pruning: If non-negative (including zero), enable pruning of old undo data and keep as many blocks as specified by the value
- storage_type: The type of storage to use for game data  (memory, sqlite or lmdb)
- datadir: base data directory for game data (will be extended by the game ID and chain); must be set if --storage_type is not memory

	DEFINE_string (xaya_rpc_url, "http://127.0.0.1", "");
	DEFINE_int32 (game_rpc_port, 8900, "");
	DEFINE_int32 (enable_pruning, -1, "");
	DEFINE_string (storage_type, "memory", "");
	DEFINE_string (datadir, "", "");

Change `xaya_rpc_url` and `game_rpc_port` according to your environment. Leave the others as they are. We aren't using a data directory in this example, so blank is fine. 

Our HelloWorld class inherits from `xaya::CachingGame`. Let's add it.




