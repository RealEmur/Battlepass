#include <sourcemod>
#include <store>
#include <sdktools>
#include <zephstocks>
#include <warden>
#include <overlays>
#include <fpvm_interface>

#include "battlepass/Globals.sp"
#include "battlepass/Menuler.sp"
#include "battlepass/Eventler.sp"
#include "battlepass/VerileriYukle.sp"
#include "battlepass/Sql.sp"
#include "battlepass/OyuncuModelleri.sp"
#include "battlepass/Stocks.sp"

public Plugin myinfo=
{
	name = "Battlepass",
	author = "Emur",
	description = "CS:GO Battlepass",
	version = "5.0",
	url = "www.pluginmerkezi.com"
};

public void OnPluginStart()
{
	CreateDirectory("addons/sourcemod/configs/PluginMerkezi/Battlepass", 3);
	CreateDirectory("addons/sourcemod/logs/PluginMerkezi", 3);
	BuildPath(Path_SM, LogPath, sizeof(LogPath), "logs/PluginMerkezi/Battlepass/battlepass.txt");
	BuildPath(Path_SM, KV_Gorevler, sizeof(KV_Gorevler), "configs/PluginMerkezi/Battlepass/gorevler.txt");
	BuildPath(Path_SM, KV_Oduller, sizeof(KV_Oduller), "configs/PluginMerkezi/Battlepass/oduller.txt");
	
	EventleriYukle();
	GorevleriYukle();
	
	RegConsoleCmd("sm_battlepass", command_battlepass);
	RegConsoleCmd("sm_pass", command_battlepass);
	RegConsoleCmd("sm_toppass", ShowTotal);
	
	RegAdminCmd("sm_passlevel", command_passlevel, ADMFLAG_ROOT);
	RegAdminCmd("sm_passilerleme", command_passilerleme, ADMFLAG_ROOT);
	RegAdminCmd("sm_passpremium", command_passpremium, ADMFLAG_ROOT);
	RegAdminCmd("sm_passpremiumsil", command_passpremiumsil, ADMFLAG_ROOT);
	RegAdminCmd("sm_bpgoster", bpgoster, ADMFLAG_ROOT);
	
	SQL_TConnect(SQLConnect, "battlepass");
	
	LoadTranslations("common.phrases.txt");
}

public void OnMapStart()
{
	VerileriSifirla();
	IPKorumasi();
	GorevleriYukle();
	OdulleriYukle();
	
	PrecacheKontrol();
	
	AddFileToDownloadsTable("sound/PluginMerkezi/Battlepass/levelup.mp3");
	PrecacheSound("PluginMerkezi/Battlepass/levelup.mp3");
	PrecacheDecalAnyDownload("PluginMerkezi/Battlepass/levelup");
}

public void OnPluginEnd()
{
	for(int i = 1; i<= MaxClients; i++)
	{
		if(IsClientInGame(i) && !IsFakeClient(i))
			UpdatePlayerInfo(i);
	}
}

public void OnClientPostAdminCheck(int client)
{
	ClientPremium[client] = 0;
	ClientOyuncuModeli[client] = -1;
	ClientBicakModeli[client] = -1;
	SorgulaClient(client);
}

public void OnClientDisconnect(int client)
{
	UpdatePlayerInfo(client);
}

public Action command_battlepass(int client, int args)
{
	Menu_AnaMenu(client);
	return Plugin_Handled;
}


public Action command_passlevel(int client, int args)
{
	if(args >= 2)
	{
		char arg1[32], arg2[32];
		GetCmdArg(1, arg1, sizeof(arg1));
		GetCmdArg(2, arg2, sizeof(arg2));
		
		int Target = FindTarget(client, arg1, true, false);
		if(Target == -1)
		{
		}
		else
		{
			if(!(1 <= StringToInt(arg2) < MaxLevel + 1))
			{
				ReplyToCommand(client, " \x07[Battlepass] \x01Girilecek değer 1 ile %d arasında olmalıdır.", MaxLevel);
				return Plugin_Handled;
			}
			ClientLevel[Target] = StringToInt(arg2) - 1;
			PrintToChat(client, " \x07[Battlepass] \x0B%N \x01isimli oyuncunun leveli başarıyla \x04%d \x01olarak değiştirildi.", Target, StringToInt(arg2));
			PrintToChat(client, " \x07[Battlepass] \x0B%N \x01isimli yetkili tarafından levelin \x04%d \x01olarak değiştirildi.", client, StringToInt(arg2));
		}
	}
	else
	{
		ReplyToCommand(client, "[SM] Kullanım: !passlevel <oyuncu> <yeni level>");
	}
	
	return Plugin_Handled;
}

public Action command_passilerleme(int client, int args)
{
	if(args >= 2)
	{
		char arg1[32], arg2[32];
		GetCmdArg(1, arg1, sizeof(arg1));
		GetCmdArg(2, arg2, sizeof(arg2));
		
		int Target = FindTarget(client, arg1, true, false);
		if(Target == -1)
		{
		}
		else
		{
			if(0 > StringToInt(arg2))
			{
				ReplyToCommand(client, " \x07[Battlepass] \x01Girilecek değer 0'dan büyük olmalıdır", MaxLevel);
				return Plugin_Handled;
			}
			
			ClientIlerleme[Target] = StringToInt(arg2);
			PrintToChat(client, " \x07[Battlepass] \x0B%N \x01isimli oyuncunun ilerlemesi başarıyla \x04%d \x01olarak değiştirildi.", Target, StringToInt(arg2));
			PrintToChat(client, " \x07[Battlepass] \x0B%N \x01isimli yetkili tarafından ilerlemen \x04%d \x01olarak değiştirildi.", client, StringToInt(arg2));
		}
	}
	else
	{
		ReplyToCommand(client, "[SM] Kullanım: !passilerleme <oyuncu> <yeni ilerleme>");
	}
	
	return Plugin_Handled;
}

public Action command_passpremium(int client, int args)
{
	if(args >= 1)
	{
		char arg1[32];
		GetCmdArg(1, arg1, sizeof(arg1));
		
		if(StrContains(arg1, "STEAM") == -1)
		{
			int Target = FindTarget(client, arg1, true, false);
			if(Target == -1)
			{
			}
			else
			{
				ClientPremium[Target] = 1;
				PrintToChat(client, " \x07[Battlepass] \x0B%N \x01isimli oyuncuya \x10Premium Battlepass \x01verildi.", Target);
				PrintToChat(client, " \x07[Battlepass] \x0B%N \x01isimli yetkili tarafından \x10Premium Battlepass \x01elde ettin!", client);
			}
		}
		else
			SQLPremiumVer(arg1, 1);
	}
	else
	{
		ReplyToCommand(client, "[SM] Kullanım: !passpremium <oyuncu>");
	}
	return Plugin_Handled;
}

public Action command_passpremiumsil(int client, int args)
{
	if(args >= 1)
	{
		char arg1[32];
		GetCmdArg(1, arg1, sizeof(arg1));
		
		if(StrContains(arg1, "STEAM") == -1)
		{
			int Target = FindTarget(client, arg1, true, false);
			if(Target == -1)
			{
			}
			else
			{
				ClientPremium[Target] = 0;
				PrintToChat(client, " \x07[Battlepass] \x0B%N \x01isimli oyuncunun \x10Premium Battlepassi \x01alındı.", Target);
				PrintToChat(client, " \x07[Battlepass] \x0B%N \x01isimli yetkili tarafından \x10Premium Battlepassin \x01alındı!", client);
			}
		}
		else
			SQLPremiumVer(arg1, 0);
	}
	else
	{
		ReplyToCommand(client, "[SM] Kullanım: !passpremium <oyuncu>");
	}
	return Plugin_Handled;
}

