## Introduction
This is temporary ban system including ip bans for sa-mp servers. It uses [y_ini](http://forum.sa-mp.com/showthread.php?t=570957) to write/read from ini files.

## Features
* Players can be banned for days, hours or minutes!
* IP of player is also banned when a player is banned preventing Multi-acconting.
* It has ban/unban logs storing feature which can be viewed ingame by commands listed below.
* Has the command to show detailed ban info of a paticular ban!

## Things you need or need to do
* You need TimeStampToDate.inc to use it which can be found [here](http://forum.sa-mp.com/showthread.php?t=347605).
* You also need fixes.inc which can be found [here](https://raw.githubusercontent.com/Open-GTO/sa-mp-fixes/master/fixes.inc)
* Create folder named as **"Bans"** and **"IP"** in scriptfiles folder.

## Commands
Command | Description
--- | ---
/ban id [duration in days] [Reason] | Bans a player for specified number of days.
/banm [id] [hours] [minutes] [reason] | Bans a player for specified number of hours and minutes.
/log | Shows unban log.
/banperm [id] [Reason] | Permanently bans a player.
/removeban [playername] | Removes a ban. *
/showbans | Shows currently banned players.
/showbaninfo [playername] | Shows the ban info of a specific player specified. You need exact name of player.
 
* _An alternative way to remove ban is remove player ini file directly from Bans folder._
