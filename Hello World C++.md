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

Copy and paste that into your helloworld.cpp file under the includes.

Next, change `xaya_rpc_url` and `game_rpc_port` according to your environment. Leave the others as they are. We aren't using a data directory in this example, so blank is fine. 

# Create the HelloWorld Class

Our `HelloWorld` class inherits from `xaya::CachingGame`. Let's add it.

	class HelloWorld : public xaya::CachingGame
	{
		protected:

We're going to add 3 methods to this class.

1. GetInitialStateInternal
1. UpdateState
1. GameStateToJson

# Write the GameStateToJson Method

`GameStateToJson` is the simplest, so let's add it to our `HelloWorld` class first. 

While we may not strictly need this method in our Hello World game, it's nice to have. Copy and paste it into our `HelloWorld` class.

	  GameStateToJson (const xaya::GameStateData& state) override
	  {
		std::istringstream in(state);
		Json::Value jsonState;
		in >> jsonState;
		return jsonState;
	  }

In there we get our GameStateData into a string buffer, then store it in a JSON value and return the JSON. This makes dealing with our GameStateData easier to handle because it's now just a big bunch of key/value pairs stored in JSON. 

# Write the GetInitialStateInternal Method

Next, our `GetInitialStateInternal` is similarly quite easy. Start writing that method as shown below.

	  xaya::GameStateData
	  GetInitialStateInternal (unsigned& height, std::string& hashHex) override
	  { }

## Choose Which Network to Run On

In `GetInitialStateInternal` we'll decide which chain our Hello World game will run on, i.e. mainnet, testnet, or regtest. We'll use the xaya::Chain enumeration to choose. Add in a switch case block as shown below. 

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

Once we've decided, we'll set the height and hashHex values. The height is the block height that we want our game to start at. This should be the highest possible block height that is prior to any moves being made in our game. The hashHex is the block hash for that block. You can look up the block hash at https://explorer.xaya.io/. We're going to start our game at [block 555,555](https://explorer.xaya.io/block/555555). 

Go ahead and add that to the mainnet case as shown below.

      case xaya::Chain::MAIN:
        height = 555555;
        hashHex
          = "ce6a6ae43103db943a74294b90906de9bb873d602f2881ddb3eb7a9f0e626312";
        break;

Fill in the values for testnet and regtest. You can leave them blank if you wish as we won't be using them. In a real game, you would have to fill in those values because you would need to use testnet and regtest during development. 

Since the initial state is only run once, and we need to have a valid value for our GameStateData, return a simple, valid JSON string as shown below. 

	return "{}";

That's the end of GetInitialStateInternal. We now turn our attention to the meaty goodness of processing "moves" in the game. 

# Write the UpdateState Method

The `UpdateState` method iterates over the various players in our game and creates a game state. Game states are representations of what the game world looks like at a particular block height. 

Wire up your `UpdateState` method as shown below.

	  xaya::GameStateData
	  UpdateState (const xaya::GameStateData& oldState,
				   const Json::Value& blockData) override
	  { }

## Get the Previous Game State

We need to have the game state from the previous block and the new moves in order to process our game logic and come up with a new game state. So, first we get the old game state (`oldState`), store it in a string buffer and then put it into a JSON value so that we can use it easily. Type or copy and paste the following into your `UpdateState` method.

		std::istringstream in(oldState);
		Json::Value state;
		in >> state;

We now have our previous game state stored in `state`.

## Iterate Over the Moves

We need to look at all the new moves in the new block data. Our `blockData` will contain JSON similar to the following.

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

The "moves" node is an array. We are only interested in the "move" and the "name". 

Go ahead and wire up a for statement to iterate over all the "moves" in our `blockData`.


    for (const auto& entry : blockData["moves"])
    {

    }

As mentioned above, we're really only interested in "name" and "move". Let's get them from our blockData into a string and an auto&.

        const std::string name = entry["name"].asString ();
        const auto& mvData = entry["move"];

The "name" is simple enough, but we don't know anything about the "move" is. We know what a valid move should look like, but we don't know what **THIS** move is, so we must do some error checking. Check to see if we have a valid string. If it's not valid, then we send ourselves a message and go back to the top of our for loop. Go ahead and add some code to do that or copy and paste the following into your `UpdateState` method.

        if (!mvData.isString ())
        {
            LOG (WARNING)
                << "Move data for " << name << " is not a string: " << mvData;
            continue;
        }

## Update the Game State

At this point, we know that we have a valid string, so we use the players name as a key for our game state (`state`) and we assign its value as our move. 

        state[name] = mvData.asString ();

## Return the Game State

With our game state updated, we can return it. Create an output string buffer to store our game state in, and then return it as a string. Write that code on your own or copy and paste the following.

    std::ostringstream out;
    out << state;
    return out.str ();

Congratulations! We're finished our `HelloWorld` class and can move on to `main` method!

# Write the main Method











