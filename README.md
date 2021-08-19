# esx-racing
Racing mod designed for esx 1.2, FiveM mod. Initial dev build will be static race tracks with commands to access. Ui interface designed to be streamlined to show all information pertinent to the race scene. Built under the assumption PD will not be able to use. Feature in plans to disable PD from viewing app at all.
No Plans to support Cash trasnsactions, players using the app should handle that on RP side.

Features:
Race History
Track Best times
Crypto payouts (configurable)
Position calculated based on checkpoints
Easily update tracks, and add new ones
Sprints/Circuits
Circuits configurable in UI for number of Laps
App shows All tracks, Tracks Pending, as well as races run this session
Notification system for pending races
Did Not Finish system 

Configurable:
Enable disable Crypto
Payout from Cypto
Minimum racers for Crypto to Pay
Crypto Name
Allow /Commands
Force Item to access racing app


Set up
SQL scripts will need to be run on first install, located within sql folder. file 0.1.0.sql is for item compatibility and will need to be adjusted on a per server basis. 0.0.1 can be run immediately. After SQL is run, install into resources folder and activate via cfg file. If using item compatibility a default thumbnail is located within the /img folder, just needs to be dropped into the appropriate location. 

Advanced Set Up
This uses a vue boiler plate so if you need to modify the UI, navigate the the html folder and run `npm run install` then you can modify your files and when your ready run `npm run build`. This will compile the vue project into the correct folders to be used on the server.

FAQ: How to add a new track
Answer: Tracks are built using the  x y z position on the map for each checkpoint. First create a new file within the tracks folder ex. XTestTrack. 'X' should be replaced with the chronological next id 1,2,3,4 etc. Inside your file you will need to follow the correct format, please copy from a previous track. The number inside the brackets should match the 'X' you used in your naming convention. Do not skip numbers or the system will break. If you repeat a number you will be overwriting the previous track. Removing tracks should be done by replacing with a new one to preserve the number sequence. If you replace a track make sure to wipe out the leaderboards for that track or your new one will have incorrect stats.

Future Features - Check Projects on Github
Bug Reports - Check Projects on Github

License:
Free to use and modify.
