# Hello World C++

In this tutorial we're going to build a Hello World console application in C++ from scratch. Once we're finished, we'll run it, check its game state, then make a move and say hello to everyone. This all involves several major steps. 

1. Write our Hello World code
2. Compile libxayagame so that we can include it in our executable
3. Compile our Hello World game with libxayagame
4. Sort out the extra dependency files that we need
5. Check the game state
6. Make a move and say hello!

Our application will incorporate libxayagame and will run as a daemon. In another command prompt or terminal, we'll send moves to the game and retrieve the results, which mimics a "front end" as it were. 

Download the code and ancillary files [here](helloworld.zip). There are some extra files to help with compilation and running for people that need them. 

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


```c++
namespace { }
```


Now we can add code to our anonymous namespace. 

# Define Connection Variables

In order to connect to the daemon, we need several flags.

- xaya_rpc_url: URL at which Xaya Core's JSON-RPC interface is available
- game_rpc_port: The port at which the game daemon's JSON-RPC server will be start (if non-zero). 
- enable_pruning: If non-negative (including zero), enable pruning of old undo data and keep as many blocks as specified by the value
- storage_type: The type of storage to use for game data  (memory, sqlite or lmdb)
- datadir: base data directory for game data (will be extended by the game ID and chain); must be set if --storage_type is not memory


```c++
DEFINE_string (xaya_rpc_url, "http://127.0.0.1", "");
DEFINE_int32 (game_rpc_port, 8900, "");
DEFINE_int32 (enable_pruning, -1, "");
DEFINE_string (storage_type, "memory", "");
DEFINE_string (datadir, "", "");
```

Copy and paste that into your helloworld.cpp file under the includes.

Next, change `xaya_rpc_url` and `game_rpc_port` according to your environment. Leave the others as they are. We aren't using a data directory in this example, so blank is fine. 

# Create the HelloWorld Class

Our `HelloWorld` class inherits from `xaya::CachingGame`. Let's add it.


```c++
class HelloWorld : public xaya::CachingGame
{
	protected:
}
```


We're going to add 3 methods to this class.

1. GetInitialStateInternal
1. UpdateState
1. GameStateToJson

# Write the GameStateToJson Method

`GameStateToJson` is the simplest, so let's add it to our `HelloWorld` class first. 

While we may not strictly need this method in our Hello World game, it's nice to have. Copy and paste it into our `HelloWorld` class.


```c++
GameStateToJson (const xaya::GameStateData& state) override
{
	std::istringstream in(state);
	Json::Value jsonState;
	in >> jsonState;
	return jsonState;
}
```


In there we get our GameStateData into a string buffer, then store it in a JSON value and return the JSON. This makes dealing with our GameStateData easier to handle because it's now just a big bunch of key/value pairs stored in JSON. 

# Write the GetInitialStateInternal Method

Next, our `GetInitialStateInternal` is similarly quite easy. It decides which chain to run on and which block to start at. It's only ever used once, but it's critical to get it right. 

Start writing that method as shown below.


```c++
xaya::GameStateData
GetInitialStateInternal (unsigned& height, std::string& hashHex) override
{ }
```


## Choose Which Chain to Run On

In `GetInitialStateInternal` we'll decide which chain our Hello World game will run on, i.e. mainnet, testnet, or regtest. We'll use the xaya::Chain enumeration to choose. Add in a switch case block as shown below. 


```c++
switch (GetChain ())
{
	case xaya::Chain::MAIN:
	break;

	case xaya::Chain::TEST:
	break;

	case xaya::Chain::REGTEST:
	break;

	default:
	LOG (FATAL) << "Invalid chain: " << static_cast<int> (GetChain ());
}
```

The `GetChain` method detects which chain we're on, i.e. mainnet, testnet, or regtest. We'll actually decide what chain we want to run on at runtime when we pass in a command line argument for `xaya_rpc_url`. Here are some possibilities for mainnet, testnet, and regtest, respectively:

- --xaya_rpc_url="http://user:password@localhost:8396"
- --xaya_rpc_url="http://user:password@localhost:18396"
- --xaya_rpc_url="http://user:password@localhost:18493"

With that decided, we set the height and hashHex values. The height is the block height that we want our game to start at. This should be the highest possible block height that is prior to any moves being made in our game. The hashHex is the block hash for that block. You can look up the block hash at https://explorer.xaya.io/. We're going to start our game at [block 555,555](https://explorer.xaya.io/block/555555). 

Go ahead and add that to the mainnet case as shown below.

```c++
case xaya::Chain::MAIN:
	height = 555555;
	hashHex
	  = "ce6a6ae43103db943a74294b90906de9bb873d602f2881ddb3eb7a9f0e626312";
	break;
```

Fill in the values for testnet and regtest. You can leave them blank if you wish as we won't be using them. In a real game, you would have to fill in those values because you would need to use testnet and regtest during development. 

Since the initial state is only run once, and we need to have a valid value for our GameStateData, return a simple, valid JSON string as shown below. 

```c++
return "{}";
```

That's the end of GetInitialStateInternal. We now turn our attention to the meaty goodness of processing "moves" in the game. 

# Write the UpdateState Method

The `UpdateState` method iterates over the various players in our game and creates a game state. Game states are representations of what the game world looks like at a particular block height. 

Wire up your `UpdateState` method as shown below.

```c++
xaya::GameStateData
UpdateState (const xaya::GameStateData& oldState,
    const Json::Value& blockData) override
{ }
```

## Get the Previous Game State

We need to have the game state from the previous block and the new moves in order to process our game logic and come up with a new game state. So, first we get the old game state (`oldState`), store it in a string buffer and then put it into a JSON value so that we can use it easily. Type or copy and paste the following into your `UpdateState` method.

```c++
std::istringstream in(oldState);
Json::Value state;
in >> state;
```

We now have our previous game state stored in `state`.

## Iterate Over the Moves

We need to look at all the new moves in the new block data. Our `blockData` will contain JSON similar to the following.

```json
{
  "block": {
	"hash": "dda7eccde4857742e5000bd66cf72154ce26c22876582654bc8b8d78dadbce8c",
	"height": 558369,
	"parent": "18f72c91c7b9223e9c7d0525216277e4016d748a2c81be4ba9d4a2b30eaed92d",
	"rngseed": "b36747498ce183b9da32b3ab6e0d72f2a17aa06859c08cf1d1e91907cb09dddc",
	"timestamp": 1549056526
  },
  "moves": [
	{
	  "move": {
		"m": "Hello world!"
	  },
	  "name": "ALICE",
	  "out": {
		"CMBPmRos5QADg2T8kvkQhMaMV5WzpzfedR": 3443.7832612
	  },
	  "txid": "edd0d7a7662a1b5f8ded16e333f114eb5bea343a432e6c72dfdbdcfef6bf4d44"
	}
  ],
  "reqtoken": "1fba0f4f9e76a65b1f09f3ea40a59af8"
}
```

The "moves" node is an array. We are only interested in the "move" and the "name". 

Go ahead and wire up a for statement to iterate over all the "moves" in our `blockData`.

```c++
for (const auto& entry : blockData["moves"])
{

}
```
As mentioned above, we're really only interested in "name" and "move". Let's get them from our blockData into a string and an auto&.


```c++
const std::string name = entry["name"].asString ();
const auto& mvData = entry["move"];
```

The "name" is simple enough, but we don't know anything about the "move" is. We know what a valid move should look like, but we don't know what **THIS** move is, so we must do some error checking. Check to see if we have a valid string. If it's not valid, then we send ourselves a message and go back to the top of our for loop. Go ahead and add some code to do that or copy and paste the following into your `UpdateState` method.

```c++
if (mvData.empty ())
{
	LOG (WARNING)
		<< "Move data for " << name << " is not a string: " << mvData;
	continue;
}
```

The inferred data type is `Json::Value`. Above we only check for whether or not it is empty, but more thorough error checking is certainly recommended.

## Update the Game State

At this point, we know that we have a valid string, so we use the players name as a key for our game state (`state`) and we assign its value as our move. 

If you remember from above, "m" stores our Hello World message. Get "m" out of mvData and store it in our game state with the player's name as the key. 

```c++
const auto& message = mvData["m"].asString ();
state[name] = message;
```

You've just updated the game state. Time to return it. 

## Return the Game State

With our game state updated, we can return it. Create an output string buffer to store our game state in, and then return it as a string. Write that code on your own or copy and paste the following.

```c++
std::ostringstream out;
out << state;
return out.str ();
```

Congratulations! We're finished our `HelloWorld` class and can move on to `main` method!

# Write the main Method

Our main method will be written outside of the anonymous namespace. Wire it up as usual.


```c++
int main (int argc, char** argv)
{ }
```

## Set Logging

If you remember the glog include way up above, we're going to start using that now. Add logging as shown below. 

```c++
google::InitGoogleLogging (argv[0]);
```

`argv[0]` is the FLAGS_xaya_rpc_url URL, so glog will send output to libxayagame, which in turn will feed our console the logging output. 

## Set Flags

We must also set our flags. If you remember from above, we included gflags. We'll use that to parse command line arguments into our flags, i.e.:

- FLAGS_xaya_rpc_url
- FLAGS_game_rpc_port
- FLAGS_enable_pruning
- FLAGS_storage_type
- FLAGS_datadir

You can do that manually, or you can use gflags. Go ahead and write code to parse command line arguments for our flags, or copy and paste in the following code.

	  gflags::SetUsageMessage ("Run HelloWorld game daemon");
	  gflags::SetVersionString ("1.0");
	  gflags::ParseCommandLineFlags (&argc, &argv, true);

The flags we listed above are now populated with the appropriate values. 

## Check for Errors

We must check for some errors. 

We must have a correct RPC URL. You can write code to do thorough error checking or copy and paste the basic check here.

```c++
if (FLAGS_xaya_rpc_url.empty ())
{
  std::cerr << "Error: --xaya_rpc_url must be set" << std::endl;
  return EXIT_FAILURE;
}
```

libxayagame can use 3 different types of storage:

- Memory
- SQLite
- lmdb

Memory doesn't require a data directory, but the other 2 do. Let's check for an error there. The strings for each are as above, but lower case. 

```c++
if (FLAGS_datadir.empty () && FLAGS_storage_type != "memory")
{
  std::cerr << "Error: --datadir must be specified for non-memory storage"
			<< std::endl;
  return EXIT_FAILURE;
}
```

## Wire Up and Set a Daemon Configuration

libxayagame expects a configuration. Copy and paste the following.

	xaya::GameDaemonConfiguration config;

We'll fill the configuration with data from our flags. Write code to fill the flags or copy and paste the following into your main method. 

```c++
	  config.XayaRpcUrl = FLAGS_xaya_rpc_url;
	  if (FLAGS_game_rpc_port != 0)
		{
		  config.GameRpcServer = xaya::RpcServerType::HTTP;
		  config.GameRpcPort = FLAGS_game_rpc_port;
		}
	  config.EnablePruning = FLAGS_enable_pruning;
	  config.StorageType = FLAGS_storage_type;
	  config.DataDirectory = FLAGS_datadir;
```

**NOTE:** The configuration requires an RPC server type. It is set as follows. 
	
```c++
	config.GameRpcServer = xaya::RpcServerType::HTTP;
```

## Instantiate an Instance of Your HelloWorld Class

It's time to put our HelloWorld class to work. Instantiate an instance of it now. 
	  
```c++
	  HelloWorld logic;
```	  

## libxayagame Startup Checklist	  

We need 3 things to start libxayagame:

1. A daemon configuration
1. A game name
1. Game logic

We created the **daemon configuration** through the command line arguments that we parsed into flags. 

Our game name is **"helloworld"**.

Our game logic is our **`HelloWorld` class**.

## Start libxayagame

Copy and paste the following at the end of your main method.
	  
```c++
	  const int res = xaya::DefaultMain (config, "helloworld", logic);
	  return res;
```

Connecting to libxayagame is a blocking operation, so `return res;` will never be reached<!-- unless the user presses CTRL+C -->. 

CONGRATULATIONS! You can now compile and run your Hello World application. It will run like a daemon now. 

# Compile Hello World

Compiling Hello World has quite a few requirements, and for some people this is probably the most difficult part. 

Our Hello World needs libxayagame to work. For that, we must compile libxayagame. 

Once that's done we have to compile Hello World.

In this tutorial we are using MSYS2 (64-bit) and g++ to compile both libxayagame and Hello World. You can use other compilers if you wish. 

## Compiling libxayagame

There is a separate tutorial to show you how to compile libxayagame. It has all the scripts and instructions needed. Finish the [How to Compile libxayagame](Compiling%20libxayagame%20-%202.md) tutorial then return back here. If all goes well, you can complete that tutorial in a few minutes. 

## Compiling Hello World

Now you have libxayagame built and available. 

1. Open up MSYS2
1. Create a new folder for Hello World and copy in all the files for it, i.e.:
	* helloworld.cpp
	* build.sh
	* hellotest.py
	* run-regtest.sh
	* run-mainnet.sh
1. Run build.sh as follows:
	
	./build.sh

1. Done.

However, hello won't run quite yet. libxayagame is built into it, but libxayagame has some dependencies. In a file explorer, navigate to this folder:

	C:\msys64\mingw64\bin

In there we must copy the following files into the same folder as the new Hello World executable. 

1. libbrotlicommon.dll
1. libbrotlidec.dll
1. libcrypto-1_1-x64.dll
1. libcurl-4.dll
1. libffi-6.dll
1. libgcc_s_seh-1.dll
1. libgflags.dll
1. libgflags_nothreads.dll
1. libglog.dll
1. libgmp-10.dll
1. libgnutls-30.dll
1. libgtest.dll
1. libgtest_main.dll
1. libhogweed-4.dll
1. libiconv-2.dll
1. libidn2-0.dll
1. libintl-8.dll
1. libjsoncpp-20.dll
1. libjsonrpccpp-client.dll
1. libjsonrpccpp-common.dll
1. libjsonrpccpp-server.dll
1. libjsonrpccpp-stub.dll
1. liblmdb.dll
1. libmicrohttpd-12.dll
1. libnettle-6.dll
1. libnghttp2-14.dll
1. libp11-kit-0.dll
1. libprotobuf-lite.dll
1. libprotobuf.dll
1. libprotoc.dll
1. libpsl-5.dll
1. libsodium-23.dll
1. libsqlite3-0.dll
1. libssh2-1.dll
1. libssl-1_1-x64.dll
1. libstdc++-6.dll
1. libtasn1-6.dll
1. libunistring-2.dll
1. libwinpthread-1.dll
1. libzmq.dll
1. zlib1.dll

With those files copied, all our dependencies are covered, and we can run Hello World.

# Run Hello World

Our Hello World application needs several parameters to be set. Recall from [Set Flags](#set-flags) above that we have 5 flags that we set:

- FLAGS_xaya_rpc_url
- FLAGS_game_rpc_port
- FLAGS_enable_pruning
- FLAGS_storage_type
- FLAGS_datadir

# Run Hello World

## Run with Electron Wallet

hello --xaya_rpc_url="http://__cookie__:62c7a564a2eea4b0e56b4ee9d0abdbb12c1a859139af4f3b045534bf5445c59d@127.0.0.1:8396" --game_rpc_port=29050 --storage_type=memory --datadir=/tmp/xayagame

## Run with xayad




We set the `FLAGS_enable_pruning` flag independently of any command line arguments. So, we must pass in the other 4 when we run Hello World. Running on the regtest chain will look something like this:

	./hello --xaya_rpc_url="http://user:password@localhost:18493" --game_rpc_port=29050  --storage_type=memory --datadir=/tmp/xayagame

Or on Windows like this:

	hello.exe --xaya_rpc_url="http://user:password@localhost:18493" --game_rpc_port=29050 --storage_type=memory --datadir=/tmp/xayagame

Running on mainnet will look something like this:

	./hello --xaya_rpc_url="http://user:password@localhost:8396" --game_rpc_port=29050  --storage_type=memory --datadir=/tmp/xayagame

Or on Windows like this:

	hello.exe --xaya_rpc_url="http://user:password@localhost:8396" --game_rpc_port=29050 --storage_type=memory --datadir=/tmp/xayagame

Run one of those now. 

![Screenshot of Hello World]()

It will scroll quickly until it reaches the current block height.

CONGRATULATIONS! IT WORKS! 

Our next tasks are to check the state of the game and make a move.

## Trouble Shooting

If you're not getting any results, it is likely that you do not have xayad running. 

See the [First Steps tutorial](https://github.com/xaya/xaya_tutorials/wiki/First-steps) and [Startup Flags in Prerequisites](https://github.com/xaya/xaya_tutorials/wiki/Prerequisites#Startup-Flags) for information on how to run xayad properly. 

Alternatively, you can run the XAYA Electron wallet as it is preconfigured to run with all the proper flags set for games, such as our Hello World example. 

# See What People Are Saying with GetCurrentState

To get the game state and see what people are saying, we must issue an RPC command to the Hello World daemon. We can use curl for that. Note that we must use JSON 2.0. 

	curl --data-binary '{"jsonrpc": "2.0", "id":"curltest", "method": "getcurrentstate"}" -H 'content-type: text/plain;' http://127.0.0.1:29050/

Or on Windows:

	curl --data-binary "{\"jsonrpc\": \"2.0\", \"id\":\"curltest\", \"method\": \"getcurrentstate\"}" -H "content-type: text/plain;" http://127.0.0.1:29050/

Open up a new command window and try that now.  

Our result is JSON.

	{"id":"curltest","jsonrpc":"2.0","result":{"blockhash":"cd8235ac63697d20732d65bd9d49bcf8107f24d4a4bc32f83e93786dd8276c6a","chain":"main","gameid":"helloworld","gamestate":{"ALICE":"","BOB":"HELLO WORLD!","Crawling Chaos":"...Hello, ALICE!","Wile E. Coyote":"Hello Road Runner!"},"height":610662,"state":"up-to-date"}}

Or prettified:


```json
{
  "id" : "curltest",
  "jsonrpc" : "2.0",
  "result" : {
    "blockhash" : "cd8235ac63697d20732d65bd9d49bcf8107f24d4a4bc32f83e93786dd8276c6a",
    "chain" : "main",
    "gameid" : "helloworld",
    "gamestate" : {
      "ALICE" : "",
      "BOB" : "HELLO WORLD!",
      "Crawling Chaos" : "...Hello, ALICE!",
      "Wile E. Coyote" : "Hello Road Runner!"
      },
    "height" : 610662,
    "state" : "up-to-date"
    }
}
```

The chain is "main", as discussed in [Choose Which Chain to Run On](#Choose-Which-Chain-to-Run-On). 

You can also see our gameid is "helloworld", just as we set it above in [Start libxayagame](#start-libxayagame).

```c++
	  const int res = xaya::DefaultMain (config, "helloworld", logic);
```

However, of most interest is our game state.


```json
"gamestate" : {
      "ALICE" : "",
      "BOB" : "HELLO WORLD!",
      "Crawling Chaos" : "...Hello, ALICE!",
      "Wile E. Coyote" : "Hello Road Runner!"
      }
```

If you recall from above in [Update the Game State](#Update-the-Game-State), we added players to our game state with their name as the key and their message as the value.

```c++
const auto& message = mvData["m"].asString ();
state[name] = message;
```

Now we have those back in a nice neat list.

If we were to have a front end for our Hello World game, we would take that game state and process it. That might mean displaying all players in a list with their messages like this:

	<name> said "<message>"

Now that we know how to get the game state, let's make a move!

# Making Moves in Hello World

With our Hello World game now running as a daemon with libxayagame embedded inside it, we must use another command line or terminal to send moves to the XAYA blockchain. Go ahead and open one now. 

Moves are made through JSON RPC to the XAYA daemon, i.e. to xayad. There are many ways to do that, but we'll limit our methods to xaya-cli and curl. 

If you're not already familiar with xaya-cli, see the [Getting Started with xaya-cli](https://github.com/xaya/xaya_tutorials/wiki/xaya-cli) tutorial. 

Each game has it's own format for sending moves. For Hello World, it's trivial.

	"m":"<hello message>"

However, there's a general format for all games. Here you can see the above embedded in it:

	{"g":{"helloworld":{"m":"<hello message>"}}}

The "g" means the game namespace and "helloworld" is the name of the game. 

## Time to Make Your Move!

Let's find out if you have a name in your XAYA wallet. In your command prompt/terminal, navigate to the folder with the XAYA QT wallet because xaya-cli is in there. 

Type or copy and paste this command:

	xaya-cli name_list

If you have any names, they'll be listed. If you don't have any, go back and [complete that portion of the First Steps tutorial](First-steps#create-a-xaya-name).

Moves are made through the name_update RPC method. The following is an example that updates your name to have no value.

	xaya-cli name_update "p/<my name>" "{}"

Combining that with our move structure from above yields the following.

	xaya-cli name_update "p/<my name>" "{\"g\":{\"helloworld\":{\"m\":\"Hello World!\"}}}"

Replace your name in that command and run it to make a move in our Hello World game. 

You will receive an error code if you made a mistake, or if all went well you'll receive a transaction ID (or txid as is more commonly used). 

CONGRATULATIONS! You made a move in Hello World! Now, check the game state as you did above. You may need to wait a minute until it's mined into the blockchain. (Miners provide an invaluable service.) 

# Summary





















