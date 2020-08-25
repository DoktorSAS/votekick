#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\gametypes\_hud_message;
/*
	Developer: DoktorSAS
	Discord: Discord.io/Sorex
	Mod: Votekick
	Website: sorexproject.webflow.io
	Discord:  https://discord.io/Sorex or https://discord.com/invite/nCP2y4J
	Description: This script is votekick bad users, the players can start a vote kick 
	
	If you like my servers and scripts I invite you to donate something to support my work 
	Donate: https://www.paypal.com/paypalme/SorexProject
	
	Copyright: The script was created by DoktorSAS and no one else can 
			   say they created it. The script is free and accessible to 
			   everyone, it is not possible to sell the script.
*/

init(){
	/*---------Don't tuch this---------*/
    if ( level.createfx_enabled ){
		return;
	}
	if ( sessionmodeiszombiesgame() ){
		setdvar( "g_TeamIcon_Axis", "faction_cia" );
		setdvar( "g_TeamIcon_Allies", "faction_cdc" );
	}else{
		setdvar( "g_TeamIcon_Axis", game[ "icons" ][ "axis" ] );
		setdvar( "g_TeamIcon_Allies", game[ "icons" ][ "allies" ] );
	}
	level.votekick = [];
	level.votekick["status"] = false;
	level.votekick["votes"] = 0;
	level.votekick["target"] = "Target";
	level.votekick["players"] = 0;
	/*-------------------------------*/
	
	/*---------Configurable Variables---------*/
	level.votekick["long_command_name"] = true; // This is to enable long version of the command( \votekick yes, \votekick no, \votekick list and \votekick id)
	level.votekick["enble_bot_kick"] = true; // This is to enable users to kick bots
	level.votekick["enble_debug"] = true; //This is to enable debug print
	level.votekick["wait_time"] = 15; //This is the during of the votekick, don't put a value higher then 60
	/*---------------------------------------*/
	/*Add the // in front of level thread OverflowFix(); if you have other overflow fix functions and ediy yours overflow adding my */
	level thread OverflowFix();
	
	level thread onPlayerConnect();
}

onPlayerConnect(){
    for(;;){
        level waittill("connected", player);
        if(isDefined(player.pers["isBot"]) && player.pers["isBot"]){	
  		}else{
  			level.votekick["players"]++;
        	player thread onPlayerSpawned();
        	player thread onPlayerDisconnect();
        }
    }
}

onPlayerSpawned(){
    self endon("disconnect");
	level endon("game_ended");
	self thread list(); // Command votekick list or vk list
	self thread votekick_no();  // Command votekick no or vk no
	self thread votekick_yes();  // Command votekick yes or vk yes
	self.votekick = self createFontString("objective", 1.2);
	self.votekick setPoint("TOP", "TOP", 0, "TOP");
	/*--------This is the timer--------*/
	self.votekick_time = self createFontString("onbjective", 1.2);
    self.votekick_time setPoint("TOP", "TOP", 0, -20);
    self.votekick_time.alpha = 0;
    if(level.votekick["wait_time"] <= 60)
    	self.votekick_time.label = &"^7Time: 00:";
    /*--------------------------------*/
	self.voted = false;
	self.list_status = false;
	for(i = 0; i < 19;i++){ //This is to generate the commands to votekick for each id
		self thread votekick_command_generator("votekick_"+i, "votekick " + i, "vk " + i, i);
	}
}
 
onPlayerDisconnect(){
	self waittill("disconnect");
	level.votekick["players"]--;
}
votekick_yes(){ //This is to manage the command vk yes and votekick yes
	if(level.votekick["long_command_name"])
		self notifyOnPlayerCommand( "votekick_yes", "votekick yes" );
	self notifyOnPlayerCommand( "votekick_yes", "vk yes" );
	for(;;){
        self waittill( "votekick_yes" );
        if(level.votekick["enble_debug"])
        	self iprintln("<<^5Sorex^7>>  Command for ^6vote yes ^1Executed");
        if(!self.voted && level.votekick["status"]){
        	self.voted = true;
        	self iprintln("Voted ^2YES");
        	level notify("update_votekick_votes"); 
        }else if(self.voted)
        	self iprintln("You already voted");
    }
}
votekick_no(){ //This is to manage the command vk no and votekick no
	if(level.votekick["long_command_name"])
		self notifyOnPlayerCommand( "votekick_no", "votekick no" );
	self notifyOnPlayerCommand( "votekick_no", "vk no" );
	for(;;){
        self waittill( "votekick_no" );
        if(level.votekick["enble_debug"])
        	self iprintln("<<^5Sorex^7>>  Command for ^6vote no ^1Executed");
        if(!self.voted && level.votekick["status"]){
        	self.voted = true;
        	self iprintln("Vote ^1NO");
        }else if(self.voted)
        	self iprintln("You already voted");
    }
}
votekick_command_generator( command_id , command, shortcommand, index){
	if(level.votekick["long_command_name"])
		self notifyOnPlayerCommand( command_id, command );
	self notifyOnPlayerCommand( command_id, shortcommand );
	for(;;){
        self waittill( command_id );
        self iprintln(index);
        if(level.votekick["enble_debug"])
        	self iprintln("<<^5Sorex^7>>  Command for ^6votekicking ^1Executed");
        if( !level.votekick["status"] ){
        	p = getPlayer( index );
        	if(isDefined(p)){
        		if(isPlayerABot( p ) && level.votekick["enble_bot_kick"]){
        			self.isPlayerABot = false;
        			self iprintln("Votekick for ^6"+ p.name + " ^2Started");
        			level thread votekick_manager( p );
        			if(self.list_status){
        				for(i = 1; i <= 5; i++){
							self.list[i] SetElementText(&"");
						}
        				self.list_status = false;
        			}	
        		}else{
        			if(isPlayerABot( p ) && !level.votekick["enble_bot_kick"]){
        				self iprintln("You ^1can't ^7kick bot");
        				self.isPlayerABot = false;
        			}else{
        				self iprintln("Votekick for ^6"+ p.name + " ^2Started");
        				self.isPlayerABot = false;
        				level thread votekick_manager( p );
        				if(self.list_status){
        					for(i = 1; i <= 5; i++){
								self.list[i] SetElementText(&"");
							}
        				self.list_status = false;
        				}	
        			}
        		}
        	}else self iprintln("There ^1no ^7players with this id");
        }else{
        	self iprintln("There a ^5Votekick ^2Active ^7, wait the end of the other votekick ");
        }
    }
}
isPlayerABot( player ){ //Check if player is a bot
	self.isPlayerABot = false;
	if(isDefined(player.pers["isBot"]) && player.pers["isBot"] && player getentitynumber() == id && !self.isPlayerABot){
		self iprintln(player.name + " ID: " + player getentitynumber() + "ID  :" +id);
		self.isPlayerABot = true;
	}
	return self.isPlayerABot;	
}
getPlayer( id ){ //
 	P = undefined;
	foreach(player in level.players){
		if(player getentitynumber() == id){
			p = player;
			break;
		}
	}
	return p;
}
votekick_time_manager(){ //This is to manage the time and the timer
	foreach(player in level.players){
        if(isDefined(player.pers["isBot"]) && player.pers["isBot"]){
        }else{
        	player.votekick_time.alpha = 1;
        	player.votekick_time setValue(level.votekick["wait_time"]);
        }
    }   	
	i = level.votekick["wait_time"];
	time = 0;
	while(i > 0 && time == 0){
		i--;
		wait 1;
		votekick_timer(i);
		if(level.votekick["votes"] >= ((int(level.votekick["players"]/2))+1))
			time = i;	
	}
	return i;
}
votekick_timer( time ){ //This is to check every secconds if the necessary votes have been reached to kick the player
	foreach(player in level.players){
        if(isDefined(player.pers["isBot"]) && player.pers["isBot"]){	
  		}else
  			player.votekick_time setValue(time);
  	}
}
votekick_manager( p ){ //This is to manage when votekick start
	level.votekick["status"] = true;
	level.votekick["target"] = "";
	level thread votekick_update( p.name );
	time = votekick_time_manager();
	foreach(player in level.players){
        if(isDefined(player.pers["isBot"]) && player.pers["isBot"]){	
  		}else if(time > 0){
  			player.votekick SetElementText( "^6" +level.votekick["target"] + "^7 has been ^1kicked" );
  			player.votekick_time.alpha = 0;
  		}else if(time == 0){
  			player.votekick SetElementText( "Time ^1Over" );
  			player.votekick_time.alpha = 0;
  		}
	}
	wait 2;
	level notify("votekick_ended");
	foreach(player in level.players){
        if(isDefined(player.pers["isBot"]) && player.pers["isBot"]){	
  		}else{
  			player.voted = false;
  			player.votekick SetElementText( "" );
  		}
	}
	if(level.votekick["votes"] >= ((int(level.votekick["players"]/2))+1)){
		kick(p getentitynumber(), "EXE_PLAYERKICKED");
		foreach(player in level.players){
        	if(isDefined(player.pers["isBot"]) && player.pers["isBot"]){	
		}else{
			if(player.list_status)
				for(i = 1; i <= 5; i++){ player.list[i] SetElementText(&"");}player.list_status = false;}		
		}
	}
	level.votekick["votes"] = 0;
	level.votekick["status"] = false;	
}
votekick_update( target ){ //This is to update the votes
	level endon("votekick_ended");
	level.votekick["target"] = target;
	foreach(player in level.players)
  		player.votekick SetElementText( "Votekick for ^6" + target + " ^7Votes: ^5" + level.votekick["votes"] + "^7/" + "^1" + ((int(level.votekick["players"]/2))+1) );
	while(true){
		level waittill("update_votekick_votes");
		level.votekick["votes"]++;
		foreach(player in level.players)
  			player.votekick SetElementText( "Votekick for ^6" + target + " ^7Votes: ^5" + level.votekick["votes"] + "^7/" + "^1" + ((int(level.votekick["players"]/2))+1)  );
	}
}
list(){ //This is to manage the votekick list or vk list command
	self.list = [];
	start_pos = -200;
	for(i = 1; i <= 5; i++){
		self.list[i] = self createFontString("objective", 1);
		self.list[i] setPoint("RIGHT", "RIGHT", 0, start_pos);
		self.list[i] SetElementText(&"");
		if(start_pos < 0)
			start_pos = start_pos + (15*3);
		else
			start_pos = start_pos - (15*3);
	}
	if(level.votekick["long_command_name"])
		self notifyOnPlayerCommand( "list", "votekick list" );
	self notifyOnPlayerCommand( "list", "vk list" );
	self.list_status = false;
    for(;;){
        self waittill( "list");
        if(level.votekick["enble_debug"])
        	self iprintln("<<^5Sorex^7>>  Command ^6list ^1Executed");
        if( self.list_status ){
        	for(i = 0; i <= 5; i++){
				self.list[i] SetElementText(&"");
			}
        	self.list_status = false;
        }else{
        	self.list_status = true;
        	index = 1;
        	player_index = 0;
        	players_in_list = 1;
       	 	players_list = "";
       	 	index_while = 0;
       	 	if(level.votekick["enble_bot_kick"]){
				while(index_while < level.players.size){
					if(player_index == 3){
						self.list[index] SetElementText(players_list);
						player_index = 0;
						index++;
						players_list = "[ID: ^1"+  level.players[index_while] getentitynumber() + "^7 ][ Name: ^6" + level.players[index_while].name + "^7]\n";
					}else
						players_list = players_list + "[ID: ^1"+  level.players[index_while] getentitynumber() + "^7 ][ Name: ^6" + level.players[index_while].name + "^7]\n";
       	 			index_while++;
       	 			player_index++;
       	 		}
       	 		if(player_index > 0){
       	 			self.list[index] SetElementText(players_list);
       	 		}
       	 		
        	}else{
        		index = 1;
        		player_index = 0;
        		players_in_list = 1;
       	 		players_list = "";
       	 		index_while = 0;
       	 		foreach(player in level.players){
       	 			if(isDefined( player.pers["isBot"] ) && player.pers["isBot"]){	
  					}else{
						if(player_index == 3){
							self.list[index] SetElementText(players_list);
							player_index = 0;
							index++;
							players_list = "[ID: ^1"+  lplayer getentitynumber() + "^7 ][ Name: ^6" + player.name + "^7]\n";
						}else
							players_list = players_list + "[ID: ^1"+  player getentitynumber() + "^7 ][ Name: ^6" + player.name + "^7]\n";
       	 				player_index++;
       	 			}
       	 		}
       	 		if(player_index > 0){
       	 			self.list[index] SetElementText(players_list);
       	 		}
        	}
        }
    }
}
SetElementText(text){
	level notify("textset");
    self SetText(text);
    if (self.text != text)
        self.text = text;
    if (!IsInArray(level.stringtable, text))
        level.stringtable[level.stringtable.size] = text;
    if (!IsInArray(level.textelementtable, self))
        level.textelementtable[level.textelementtable.size] = self;
}
OverflowFix(){
	level endon("game_ended");
	level endon("host_migration_begin");
	level waittill("connected", player); 
    level.stringtable = [];
    level.textelementtable = [];
    textanchor = CreateServerFontString("default", 1);
    textanchor SetElementText("Anchor");
    textanchor.alpha = 0; 
    gmtype = GetDvar("g_gametype");
    if (GetDvar("g_gametype") == "tdm" || GetDvar("g_gametype") == "hctdm")
        limit = 54;
    else if (GetDvar("g_gametype") == "dm" || GetDvar("g_gametype") == "hcdm")
        limit = 54;
    else if (GetDvar("g_gametype") == "dom" || GetDvar("g_gametype") == "hcdom")
        limit = 38;
    else if (GetDvar("g_gametype") == "dem" || GetDvar("g_gametype") == "hcdem")
        limit = 41;
    else if (GetDvar("g_gametype") == "conf" || GetDvar("g_gametype") == "hcconf")
        limit = 53;
    else if (GetDvar("g_gametype") == "koth" || GetDvar("g_gametype") == "hckoth")
        limit = 41;
    else if (GetDvar("g_gametype") == "hq" || GetDvar("g_gametype") == "hchq")
        limit = 43;
    else if (GetDvar("g_gametype") == "ctf" || GetDvar("g_gametype") == "hcctf")
        limit = 32;
    else if (GetDvar("g_gametype") == "sd" || GetDvar("g_gametype") == "hcsd")
        limit = 38;
    else if (GetDvar("g_gametype") == "oneflag" || GetDvar("g_gametype") == "hconeflag")
        limit = 25;
    else if (GetDvar("g_gametype") == "gun")
        limit = 48;
    else if (GetDvar("g_gametype") == "oic")
        limit = 51;
    else if (GetDvar("g_gametype") == "shrp")
        limit = 48;
    else if (GetDvar("g_gametype") == "sas")
        limit = 50;
    if (IsDefined(level.stringoptimization))
        limit += 172;
    while (!level.gameended){
        if (IsDefined(level.stringoptimization) && level.stringtable.size >= 100 && !IsDefined(textanchor2)){
            textanchor2 = CreateServerFontString("default", 1);
            textanchor2 SetElementText("Anchor2");                
            textanchor2.alpha = 0; 
        }
        
        if (level.stringtable.size >= limit){
       		foreach(player in level.players){
        	 	if(isDefined(player.pers["isBot"]) && player.pers["isBot"]){	
  				}else{
  					if(level.votekick["status"])
  						player.votekick SetElementText( "Votekick for ^6" + level.votekick["target"] + " ^7Votes: ^5" + level.votekick["votes"] + "/" + "^1" + ((int(level.votekick["players"]/2))+1) );
  					else
						player.votekick SetElementText("");
					wait 0.01;
			  	}
			}
            if (IsDefined(textanchor2)){
                textanchor2 ClearAllTextAfterHudElem();
                textanchor2 DestroyElement();
            }           
			textanchor ClearAllTextAfterHudElem();
            level.stringtable = [];
            foreach (textelement in level.textelementtable){
                if (!IsDefined(self.label))
                    textelement SetElementText(textelement.text);
                else
                    textelement SetElementValueText(textelement.text);
            }
        }            
        wait 0.005;
    }
}
SetElementText(text){
	level notify("textset");
    self SetText(text);
    if (self.text != text)
        self.text = text;
    if (!IsInArray(level.stringtable, text))
        level.stringtable[level.stringtable.size] = text;
    if (!IsInArray(level.textelementtable, self))
        level.textelementtable[level.textelementtable.size] = self;
}
SetElementValueText(text){
    self.label = &"" + text;  
    if (self.text != text)
        self.text = text;
    if (!IsInArray(level.stringtable, text))
        level.stringtable[level.stringtable.size] = text;
    if (!IsInArray(level.textelementtable, self))
        level.textelementtable[level.textelementtable.size] = self;
}
DestroyElement(){
    if (IsInArray(level.textelementtable, self))
        ArrayRemoveValue(level.textelementtable, self);
    if (IsDefined(self.elemtype)){
        self.frame Destroy();
        self.bar Destroy();
        self.barframe Destroy();
    }       
    self Destroy();
}
setSafeText(text){
	self SetElementText(text);
}

