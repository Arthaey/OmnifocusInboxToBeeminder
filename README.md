OmnifocusInboxToBeeminder
=========================

Keep track of your Omnifocus inbox count with Beeminder

## About OmnifocusInboxToBeeminder
Keeping your OmniFocus inbox at zero is a challenge, but there's help. OmnifocusInboxToBeeminder lets you track your Omnifocus inbox with Beeminder. Using the Beeminder API, this script queries your OmniFocus inbox and reports the item count to Beeminder. This script is intended to be run four times a day, at midnight, 6am, noon, and 6pm, using ```cron```.

## Usage
The basic syntax is:
```
ruby main.rb -k KEY -g GOAL
```
For example:
```
ruby main.rb -k MYSECRETBEEMINDERAPIKEY -g omnifocuszero
```
If your Omnifocus database is in a special location, you can specify it:
```
ruby main.rb -k MYSECRETBEEMINDERAPIKEY -g omnifocuszero -p "/MyFiles/OmniFocusDatabase2" 
```
Here are the options for the script:
```
-k, --apikey KEY                 #Your Beeminder API key
-g, --beeminder_goal GOAL        #The slug of the goal you wish to log on Beeminder
-p, --database_path PATH         #Path to your omnifocus database
-h, --help                       #Show this message
```

## Setup instructions

1. Log into Beeminder. Create a new "Inbox less" goal. When prompted, give it a shortname like ```omnifocuszero```
1. Get your Beeminder token here: https://www.beeminder.com/api/v1/auth_token.json
1. Run the script in your console, as described above: ```ruby main.rb -k MYSECRETBEEMINDERAPIKEY -g omnifocuszero```. The -k option should be the auth token you got in the previous step.
1. On the Beeminder website, check to see if the new datapoint was registered. Below the chart for your goal, there is a section called Add Data. It should say something like, ```28 14 "Automated Omnifocus count as of 10/28/2013 at 7:04 AM"```. If you see the datapoint, the script is working. If you don't see the datapoint, you have a problem. In that case, stop here until you fix it.
1. Schedule the script to run at midnight, 6am, noon, and 6pm. You can schedule it to run whenever you want, those are just the times that work for me. The reason I run it 4x/day is that my Mac will inevitably be off (airplane, battery died, etc.) and I want to make sure I get a datapoint every day. I'd rather get a few extra datapoints than none. If you don't know how to schedule a ```cron``` job, google it. On OS X, it might be better to use ```launchctl``` instead of ```cron```.

## Help & contributions
Email me at ```jerzygangi@gmail.com``` with questions, or submit a bug and I'll do my best to fix it. If you want to contribute code, join in.