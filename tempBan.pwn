/*===============================================================
	=============TEMP BAN SYSTEM V 3.0=============================
	===============MADE BY BROZEUS=================================
	CREDITS------>
    Zeus [ thats me] -- For scripting
    YSI -- For sscanf2 and YSI/ini
    Zeex -- For Zcmd
    Jochemd -- For TimeStampToDate.inc
    Shacky  -- for fcreate and fdelete stocks
	
Do not remove creits or redistribute*/
#include <a_samp>
#include <fixes>
#include <YSI\y_ini>
#include <zcmd>
#include <sscanf2>
#include <TimeStampToDate>


#define BANPATH "/Bans/%s.ini"
#define IPPATH "/IP/%s.ini"

#define GMT_H 0  // Enter the value of the gmt hour u want otherwise keep it zero
#define GMT_M 0  // Enter the value of the gmt mintues u want otherwise keep it zero

new ln[MAX_PLAYERS]=0,revseen[][MAX_PLAYERS];

#if defined FILTERSCRIPT
	public OnFilterScriptInit()
	{
		if(!fexist("unban_log.txt"))
		{
			fcreate("unban_log.txt");
			print("unban_log.txt didnt existed so it was created.");
		}
		if(!fexist("BannedPlayers.txt"))
		{
			fcreate("BannedPlayers.txt");
			print("BannedPlayers.txt didnt existed so it was created.");
		}
		return 1;
	}
	#else
	public OnGameModeInit()
	{
		if(!fexist("unban_log.txt"))
		{
			fcreate("unban_log.txt");
			print("unban_log.txt didnt existed so it was created.");
		}
		if(!fexist("BannedPlayers.txt"))
		{
			fcreate("BannedPlayers.txt");
			print("BannedPlayers.txt didnt existed so it was created.");
		}
		
		return 1;
	}
#endif

enum pInfo
{
    pBanexp,
    pBanres[100],
    pBanPerm,
    pBanAdmin[20],
    pBanIPP[20]
}
new PlayerInfo[MAX_PLAYERS][pInfo];
new pp[50];

forward fcreate(filename[]);
public fcreate(filename[])
{
    if (fexist(filename)){return false;}
    new File:fhandle = fopen(filename,io_write);
    fclose(fhandle);
    return true;
}

forward LoadBanUser_data(playerid,name[],value[]);
public LoadBanUser_data(playerid,name[],value[])
{
	INI_Int("Banexp",PlayerInfo[playerid][pBanexp]);
	INI_Int("BanPerm",PlayerInfo[playerid][pBanPerm]);
	INI_String("BanAdmin", PlayerInfo[playerid][pBanAdmin], 20);
	INI_String("Reason",PlayerInfo[playerid][pBanres],100);
	return 1;
}

forward LoadIPUser_data(playerid,name[],value[]);
public LoadIPUser_data(playerid,name[],value[])
{INI_Int("Banexp",PlayerInfo[playerid][pBanexp]);
	INI_Int("BanPerm",PlayerInfo[playerid][pBanPerm]);
	INI_String("BanPlayer", PlayerInfo[playerid][pBanIPP], 20);
	INI_String("BanAdmin", PlayerInfo[playerid][pBanAdmin], 20);
	INI_String("Reason",PlayerInfo[playerid][pBanres],100);
	return 1;
}

forward LoadIP_data(playerid,name[],value[]);
public LoadIP_data(playerid,name[],value[])
{INI_String("IP",pp,50);
	return 1;
}

stock UserBanPath(playerid)
{
	new string[128],playername[MAX_PLAYER_NAME];
	GetPlayerName(playerid,playername,sizeof(playername));
	format(string,sizeof(string),BANPATH,playername);
	return string;
}
stock UserIPPath(playerid)
{
	new string[128],ip[50];
	GetPlayerIp(playerid,ip,sizeof(ip));
	format(string,sizeof(string),IPPATH,ip);
	return string;
}

stock Showinfo(playerid,targetname[])
{
    new path[150],ss[500];
	format(path,sizeof(path),"Bans/%s.ini",targetname);
    INI_ParseFile(path, "LoadBanUser_%s", .bExtra = true, .extra = playerid);
	if(PlayerInfo[playerid][pBanPerm]==1)
	format(ss,sizeof(ss),"{00FFFF}Banning Admin:\t\t{ff0000}%s\n{00FFFF}Ban Reason:\t\t{ff0000}%s\n{00FFFF}Ban Type:\t\t{ff0000}Permanent.\n\n{FFFF00}Click on Remove Ban button to un-ban the player.",PlayerInfo[playerid][pBanAdmin],PlayerInfo[playerid][pBanres]);
	else
	{
		new d,m,y,h,mi,s;
		TimestampToDate(PlayerInfo[playerid][pBanexp],y,m,d,h,mi,s,GMT_H,GMT_M);
		format(ss,sizeof(ss),"{00FFFF}Banning Admin:\t\t{ff0000}%s\n{00FFFF}Ban Reason:\t\t{ff0000}%s\n{00FFFF}Expire Time:\t\t{ff0000}%i-%i\n{00FFFF}Expire Date:\t\t{ff0000}%i-%i-%i\n\n{FFFF00}Time is according to %i GMT\nDate Format: dd-mm-yyyy\nClick on Remove Ban button to un-ban the player.",PlayerInfo[playerid][pBanAdmin],PlayerInfo[playerid][pBanres],h,mi,d,m,y,GMT_H);
	}
	format(revseen[playerid],MAX_PLAYER_NAME,"%s",targetname);
	ShowPlayerDialog(playerid, 113,  DIALOG_STYLE_MSGBOX,targetname,ss, "Remove Ban", "Cancel");
	return 1;
}

stock fdeleteline(filename[], line[])
{
	if(fexist(filename)){
		new temp[256];
		new File:fhandle = fopen(filename,io_read);
		fread(fhandle,temp,sizeof(temp),false);
		if(strfind(temp,line,true)==-1){return 0;}
		else{
			fclose(fhandle);
			fremove(filename);
			for(new i=0;i<strlen(temp);i++){
				new templine[256];
				strmid(templine,temp,i,i+strlen(line));
				if(strcmp(templine,line,true)){
					strdel(temp,i,i+strlen(line));
					fcreate(filename);
					fhandle = fopen(filename,io_write);
					fwrite(fhandle,temp);
					fclose(fhandle);
					return 1;
				}
			}
		}
	}
	return 0;
}


public OnPlayerConnect(playerid)
{
	
	if(fexist(UserBanPath(playerid)))
	{
		INI_ParseFile(UserBanPath(playerid), "LoadBanUser_%s", .bExtra = true, .extra = playerid);
		
		if(PlayerInfo[playerid][pBanPerm]==1)
		{new reso[256];
			SendClientMessage(playerid,-1,"{85BB65}You are permanently Banned from this server by Administration");
			format(reso,sizeof(reso),"{85BB65}Reason: {f0f000}%s",PlayerInfo[playerid][pBanres]);
			SendClientMessage(playerid,-1,reso);
			format(reso,sizeof(reso),"{85BB65}Banning Admin: {f0f000}%s",PlayerInfo[playerid][pBanAdmin]);
			SendClientMessage(playerid,-1,reso);
			SetTimerEx("KickPlayer",100,false,"i",playerid);
		}
		else
		{
			if(gettime() > PlayerInfo[playerid][pBanexp])
			{   fremove(UserBanPath(playerid));
				fremove(UserIPPath(playerid));
				SendClientMessage(playerid,-1,"{00cc00}You have been unbanned!!!!");
			}
			else
			{
				new d,m,y,h,mi,s;
				TimestampToDate(PlayerInfo[playerid][pBanexp],y,m,d,h,mi,s,GMT_H,GMT_M);
				new str[540];
				format(str,sizeof(str),"{85BB65}This Account Has Been Banned By The Adminstration Until {f0f000}%i-%i-%i[Date format : dd/mm/yyyy]",d,m,y);
				SendClientMessage(playerid,-1,str);
				format(str,sizeof(str),"{85BB65}Expires on[TIME] -- {f0f000}%i-%i[Time Format: 24 Hour Clock]",h,mi);
				SendClientMessage(playerid, -1, str);
				format(str,sizeof(str),"{85BB65}Reason -- {f0f000}%s",PlayerInfo[playerid][pBanres]);
				SendClientMessage(playerid, -1, str);
				format(str,sizeof(str),"{85BB65}Banning Admin -- {f0f000}%s",PlayerInfo[playerid][pBanAdmin]);
				SendClientMessage(playerid, -1, str);
				SetTimerEx("KickPlayer",100,false,"i",playerid);
			}}}
			
			else if(fexist(UserIPPath(playerid)))
			{
				INI_ParseFile(UserIPPath(playerid), "LoadIPUser_%s", .bExtra = true, .extra = playerid);
				if(PlayerInfo[playerid][pBanPerm]==1)
				{  new reso[256];
					SendClientMessage(playerid,-1,"{85BB65}This IP is permanently Banned from this server by Administration");
					format(reso,sizeof(reso),"{85BB65}Originally Banned Player: {f0f000}%s",PlayerInfo[playerid][pBanIPP]);
					SendClientMessage(playerid,-1,reso);
					format(reso,sizeof(reso),"{85BB65}Reason: {f0f000}%s",PlayerInfo[playerid][pBanres]);
					SendClientMessage(playerid,-1,reso);
					format(reso,sizeof(reso),"{85BB65}Banning Admin: {f0f000}%s",PlayerInfo[playerid][pBanAdmin]);
					SendClientMessage(playerid,-1,reso);
					SetTimerEx("KickPlayer",100,false,"i",playerid);
				}
				else {
					if(gettime() > PlayerInfo[playerid][pBanexp])
					{   new pat[100];
						fremove(UserIPPath(playerid));
						format(pat,sizeof(pat),"Bans/%s.ini",PlayerInfo[playerid][pBanIPP]);
						fremove(pat);
						SendClientMessage(playerid,-1,"{00cc00}This IP was banned but as now the expire time has passed this IP has been unbanned.");
					}
					else
					{
						new d,m,y,h,mi,s;
						TimestampToDate(PlayerInfo[playerid][pBanexp],y,m,d,h,mi,s,GMT_H,GMT_M);
						new str[540];
						format(str,sizeof(str),"{85BB65}This IP Has Been Banned By The Adminstration Until {f0f000}%i-%i-%i[Date format : dd/mm/yyyy]",d,m,y);
						SendClientMessage(playerid,-1,str);
						format(str,sizeof(str),"{85BB65}Expires on[TIME] -- {f0f000}%i-%i[Time Format: 24 Hour Clock]",h,mi);
						SendClientMessage(playerid, -1, str);
						format(str,sizeof(str),"{85BB65}Originally Banned Player -- {f0f000}%s",PlayerInfo[playerid][pBanIPP]);
						SendClientMessage(playerid, -1, str);
						format(str,sizeof(str),"{85BB65}Reason -- {f0f000}%s",PlayerInfo[playerid][pBanres]);
						SendClientMessage(playerid, -1, str);
						format(str,sizeof(str),"{85BB65}Banning Admin -- {f0f000}%s",PlayerInfo[playerid][pBanAdmin]);
						SendClientMessage(playerid, -1, str);
						SetTimerEx("KickPlayer",100,false,"i",playerid);
					}}}
					
return 1;}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid==110 && response)
	{
		
		Showinfo(playerid,inputtext);
		ln[playerid]=0;
	}
	if(dialogid==111)
	{
		if(response)Showinfo(playerid,inputtext);
		else
		{
			new read[200],ss[1008],op[1000];
			format(op,sizeof(op),"");
			new File:log=fopen("BannedPlayers.txt",io_read);
			fseek(log,ln[playerid],seek_start);
			while(fread(log,read))
			{
				strcat(read,"\n",200);
				strcat(op,read,1000);
			}
			fclose(log);
			format(ss,sizeof(ss),"{9ACD32}%s",op);
			ShowPlayerDialog(playerid, 112,  DIALOG_STYLE_LIST, "{00FFFF}Showing Currently Banned Players[Page 2]",ss, "Select", "Cancel");
			ln[playerid]=0;
		}}
		if(dialogid==112 && response)Showinfo(playerid,inputtext);
		if(dialogid==113 && response)
		{
			new pat[MAX_PLAYER_NAME+10],pati[MAX_PLAYER_NAME+10],ppf[100],adname[MAX_PLAYER_NAME];
			
			format(pat,sizeof(pat),"Bans/%s.ini",revseen[playerid]);
			
			INI_ParseFile(pat, "LoadIP_%s", .bExtra = true, .extra = playerid);
			format(pati,sizeof(pat),"IP/%s.ini",pp);
			fremove(pati);
			format(pat,sizeof(pat),"Bans/%s.ini",revseen[playerid]);
			fremove(pat);
			format(ppf,sizeof(ppf),"The player %s has been un-banned.",revseen[playerid]);
			SendClientMessage(playerid,0x00FF00FF,ppf);
			GetPlayerName(playerid,adname,sizeof(adname));
			format(pat,sizeof(pat),"%s has been unbanned by %s",revseen[playerid],adname);
			new File:log=fopen("unban_log.txt",io_append);
			fwrite(log, pat);
			fwrite(log,"\r\n");
			fclose(log);
			fdeleteline("BannedPlayers.txt", revseen[playerid]);
		}
		
		
		return 0;
}





forward KickPlayer(playerid);
public KickPlayer(playerid)
{
	Kick(playerid);
	return 1;
}

/*=====================================COMMANDS======================================*/
CMD:ban(playerid,parmas[])
{
    if(IsPlayerAdmin(playerid)){
		new tid,du,res[150],ppp[50];
		if(sscanf(parmas,"uis",tid,du,res) || isnull(parmas))return SendClientMessage(playerid,-1,"{ff0000}Wrong Usage || Correct Usage : /ban id duration(In Days) Reason");
		if(!IsPlayerConnected(tid))return SendClientMessage(playerid,-1,"{ff6666}The Player you requested is not connected.");
		new banmt[300],banma[300],adminname[MAX_PLAYER_NAME],targetn[MAX_PLAYER_NAME];
		GetPlayerName(playerid,adminname,sizeof(adminname));
		new exp=gettime()+(60*60*24*du);
		GetPlayerIp(tid,ppp,sizeof(ppp));
		new INI:File = INI_Open(UserBanPath(tid));
		INI_SetTag(File,"data");
		INI_WriteInt(File,"Banexp",exp);
		INI_WriteInt(File,"BanPerm",0);
		INI_WriteString(File,"BanAdmin",adminname);
		INI_WriteString(File,"Reason",res);
		INI_WriteString(File,"IP",ppp);
		INI_Close(File);
		GetPlayerName(tid,targetn,sizeof(targetn));
		new INI:iFile = INI_Open(UserIPPath(tid));
		INI_SetTag(iFile,"data");
		INI_WriteInt(iFile,"Banexp",exp);
		INI_WriteInt(iFile,"BanPerm",0);
		INI_WriteString(iFile,"BanPlayer",targetn);
		INI_WriteString(iFile,"BanAdmin",adminname);
		INI_WriteString(iFile,"Reason",res);
		INI_Close(iFile);
		new File:logg=fopen("BannedPlayers.txt",io_append);
		fwrite(logg, targetn);
		fwrite(logg,"\n");
		fclose(logg);
		format(banmt,sizeof(banmt),"{ff0000}Admin %s has banned you for %i days due to %s",adminname,du,res);
		format(banma,sizeof(banma),"{ff0000}Admin %s has banned %s for %i days due to %s",adminname,targetn,du,res);
		SendClientMessage(tid,-1,banmt);
		SendClientMessageToAll(-1,banma);
		SetTimerEx("KickPlayer",100,false,"i",tid);
	}else SendClientMessage(playerid,-1,"{ff0000}You are not authorized to use this command.");
return 1;}
/*===================================================================================================*/
CMD:removeban(playerid,parmas[]){
    if(IsPlayerAdmin(playerid)){
		new rename[MAX_PLAYER_NAME],pat[MAX_PLAYER_NAME+10],pati[MAX_PLAYER_NAME+10],ppf[100],adname[MAX_PLAYER_NAME];
		if(sscanf(parmas,"s",rename) || isnull(parmas))return SendClientMessage(playerid, -1, "{FF0000}Wrong Usage || Usage : /removeban PlayerName");
		format(pat,sizeof(pat),"Bans/%s.ini",rename);
		if(!fexist(pat))
		{
			format(ppf,sizeof(ppf),"The user cannot be unbanned because there is user named as %s banned.",rename);
			SendClientMessage(playerid,-1,ppf);
			return 1;
		}
		INI_ParseFile(pat, "LoadIP_%s", .bExtra = true, .extra = playerid);
		format(pati,sizeof(pat),"IP/%s.ini",pp);
		fremove(pati);
		format(pat,sizeof(pat),"Bans/%s.ini",rename);
		fremove(pat);
		format(ppf,sizeof(ppf),"The player %s has been un-banned.",rename);
		SendClientMessage(playerid,0x00FF00FF,ppf);
		GetPlayerName(playerid,adname,sizeof(adname));
		format(pat,sizeof(pat),"%s has been unbanned by %s",rename,adname);
		new File:log=fopen("unban_log.txt",io_append);
		fwrite(log, pat);
		fwrite(log,"\r\n");
		fclose(log);
		fdeleteline("BannedPlayers.txt", rename);
	}
    else SendClientMessage(playerid,-1,"{ff0000}You are not authorized to use this command");
return 1;}
/*====================================================================================================*/
CMD:banperm(playerid,parmas[])
{
    if(!IsPlayerAdmin(playerid))return SendClientMessage(playerid,-1,"{ff0000}You are not authorized to use this command.");
    new tid,res[90],ppp[50];
    if(sscanf(parmas,"us",tid,res) || isnull(parmas))return SendClientMessage(playerid,-1,"{ff0000}Wrong Usage || Correct Usage : /banperm PlayerID Reason");
    if(!IsPlayerConnected(tid))return SendClientMessage(playerid,-1,"{ff6666}The Player you requested is not connected.");
    new adminname[MAX_PLAYER_NAME];
    GetPlayerName(playerid,adminname,sizeof(adminname));
    GetPlayerIp(tid,ppp,sizeof(ppp));
    new INI:File = INI_Open(UserBanPath(tid));
    INI_SetTag(File,"data");
    INI_WriteInt(File,"Banexp",0);
    INI_WriteInt(File,"BanPerm",1);
    INI_WriteString(File,"BanAdmin",adminname);
    INI_WriteString(File,"Reason",res);
    INI_WriteString(File,"IP",ppp);
    INI_Close(File);
    new banmt[300],banma[300],targetn[MAX_PLAYER_NAME];
    GetPlayerName(tid,targetn,sizeof(targetn));
    new INI:iFile = INI_Open(UserIPPath(tid));
	INI_SetTag(iFile,"data");
	INI_WriteInt(iFile,"Banexp",0);
	INI_WriteInt(iFile,"BanPerm",1);
	INI_WriteString(iFile,"BanPlayer",targetn);
	INI_WriteString(iFile,"BanAdmin",adminname);
	INI_WriteString(iFile,"Reason",res);
	INI_Close(iFile);
	new File:logg=fopen("BannedPlayers.txt",io_append);
	fwrite(logg, targetn);
	fwrite(logg,"\n");
	fclose(logg);
    format(banmt,sizeof(banmt),"{ff0000}Admin %s has banned you for permanently due to %s",adminname,res);
    format(banma,sizeof(banma),"{ff0000}Admin %s has banned %s permanenetly due to %s",adminname,targetn,res);
    SendClientMessage(tid,-1,banmt);
    SendClientMessageToAll(-1,banma);
    SetTimerEx("KickPlayer",100,false,"i",tid);
return 1;}
/*=======================================================================================================*/
CMD:banm(playerid,parmas[])
{
    if(IsPlayerAdmin(playerid)){
		new tid,h,m,res[150],ppp[50];
		if(sscanf(parmas,"uiis",tid,h,m,res) || isnull(parmas))return SendClientMessage(playerid,-1,"{ff0000}Wrong Usage || Correct Usage : /banm ID Hours Minutes Reason");
		if(!IsPlayerConnected(tid))return SendClientMessage(playerid,-1,"{ff6666}The Player you requested is not connected.");
		new banmt[300],banma[300],adminname[MAX_PLAYER_NAME],targetn[MAX_PLAYER_NAME];
		GetPlayerName(playerid,adminname,sizeof(adminname));
		new exp=gettime()+(60*m)+(60*60*h);
		GetPlayerIp(tid,ppp,sizeof(ppp));
		new INI:File = INI_Open(UserBanPath(tid));
		INI_SetTag(File,"data");
		INI_WriteInt(File,"Banexp",exp);
		INI_WriteInt(File,"BanPerm",0);
		INI_WriteString(File,"BanAdmin",adminname);
		INI_WriteString(File,"Reason",res);
		INI_WriteString(File,"IP",ppp);
		INI_Close(File);
		GetPlayerName(tid,targetn,sizeof(targetn));
		new INI:iFile = INI_Open(UserIPPath(tid));
		INI_SetTag(iFile,"data");
		INI_WriteInt(iFile,"Banexp",exp);
		INI_WriteInt(iFile,"BanPerm",0);
		INI_WriteString(iFile,"BanPlayer",targetn);
		INI_WriteString(iFile,"BanAdmin",adminname);
		INI_WriteString(iFile,"Reason",res);
		INI_Close(iFile);
		new File:logg=fopen("BannedPlayers.txt",io_append);
		fwrite(logg, targetn);
		fwrite(logg,"\n");
		fclose(logg);
		format(banmt,sizeof(banmt),"{ff0000}Admin %s has banned you for %i hours %i minutes due to %s",adminname,h,m,res);
		format(banma,sizeof(banma),"{ff0000}Admin %s has banned %s for %i hours %i minutes due to %s",adminname,targetn,h,m,res);
		SendClientMessage(tid,-1,banmt);
		SendClientMessageToAll(-1,banma);
		SetTimerEx("KickPlayer",100,false,"i",tid);
	}else SendClientMessage(playerid,-1,"{ff0000}You are not authorized to use this command.");
return 1;}
/*=======================================================================================================*/
CMD:log(playerid,parmas[])
{
	if(!IsPlayerAdmin(playerid))return SendClientMessage(playerid,-1,"{ff0000}You are not authorized to use this command.");
	new read[500],ss[1008],op[1000];
	format(op,sizeof(op),"");
	new File:log=fopen("unban_log.txt",io_read);
	while(fread(log,read))
	{
		strcat(read,"\n",500);
		strcat(op,read,1000);
	}
	fclose(log);
	format(ss,sizeof(ss),"{9ACD32}%s",op);
	ShowPlayerDialog(playerid, 110, DIALOG_STYLE_MSGBOX, "{00BFFF}Showing Un-Ban Log",ss, "Cool", "");
	return 1;
}
/*=========================================================================================================*/
CMD:showbans(playerid,parmas[])
{
	if(!IsPlayerAdmin(playerid))return SendClientMessage(playerid,-1,"{ff0000}You are not authorized to use this command.");
	new read[200],ss[1008],op[1000],bool:NextDialog=false;
	format(op,sizeof(op),"");
	new File:log=fopen("BannedPlayers.txt",io_read);
	while(fread(log,read))
	{
		strcat(read,"\n",200);
		strcat(op,read,1000);
		ln[playerid]++;
		if(ln[playerid]==110)//this specifies the maximum no. of bans that are to be shown in 1 dialog box
		{
			NextDialog=true;
			break;
		}
	}
	fclose(log);
	if(strlen(op)<=3)return SendClientMessage(playerid,-1,"{ff0000}No players currently banned.");
	format(ss,sizeof(ss),"{9ACD32}%s",op);
	if(NextDialog==false)ShowPlayerDialog(playerid, 110,  DIALOG_STYLE_LIST, "{00FFFF}Showing Currently Banned Players",ss, "Select", "Cancel");
	else ShowPlayerDialog(playerid, 111,  DIALOG_STYLE_LIST, "{00FFFF}Showing Currently Banned Players",ss, "Select", "Next Page");
	return 1;
}
/*================================================================================================================*/
CMD:showbaninfo(playerid,parmas[])
{
	if(!IsPlayerAdmin(playerid))return SendClientMessage(playerid,-1,"{ff0000}You are not authorized to use this command.");
	new tid[MAX_PLAYER_NAME];
	if(sscanf(parmas,"s",tid))return SendClientMessage(playerid,-1,"{ff0000}Correct Usage: /showbaninfo PLAYERNAME\nNOTE:The PLAYERNAME should be exact name of player.");
	new path[150];
	format(path,sizeof(path),"Bans/%s.ini",tid);
	if(!fexist(path))return SendClientMessage(playerid,-1,"{ff0000}The player you requested is not in ban databse please use /showbans to view currently banned players.");
	Showinfo(playerid,tid);
	return 1;
}