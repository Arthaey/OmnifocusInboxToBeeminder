OmnifocusInboxToBeeminder
=========================

Keep track of your Omnifocus inbox count with Beeminder

## About OmnifocusInboxToBeeminder
Keeping your OmniFocus inbox at zero is a challenge, but there's help. OmnifocusInboxToBeeminder lets you track your Omnifocus inbox with Beeminder. Using the Beeminder API, this script queries your OmniFocus inbox and reports the item count to Beeminder. This script is intended to be run once a day, at midnight, using cron.

## Usage
The basic syntax is:
```
main.rb -k KEY -g GOAL
```
For example:
```
main.rb -k MYSECRETBEEMINDERAPIKEY -g omnifocuszero
```
If your Omnifocus database is in a special location, you can specify it:
```
main.rb -k MYSECRETBEEMINDERAPIKEY -g omnifocuszero -p "/MyFiles/OmniFocusDatabase2" 
```
Here are the options for the script:
```
-k, --apikey KEY                 #Your Beeminder API key
-g, --beeminder_goal GOAL        #The slug of the goal you wish to log on Beeminder
-p, --database_path PATH         #Path to your omnifocus database
-h, --help                       #Show this message
```

## Setup instructions

1. Log into Beeminder. Create a new "Inbox less" goal. Give it a name like ```omnifocuszero```.
1. Get your Beeminder token here: https://www.beeminder.com/api/v1/auth_token.json
1. Run the script in your console, as described above. For example ```main.rb -k MYSECRETBEEMINDERAPIKEY -g omnifocuszero```.
