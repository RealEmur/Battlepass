public int SQLConnect(Handle owner, Handle hdnl, char[] error, any data)
{
	if(hdnl == null)
	{
		LogToFile(LogPath, "Veritabanı ile bağlantı sağlanamadı: %s", error);
		SetFailState("Veritabanı ile bağlantı sağlanamadı: %s", error);
	}
	sDatabase = hdnl;
	char query[255];
	Format(query, sizeof(query), "CREATE TABLE IF NOT EXISTS battlepass (steamid varchar(64), name varchar(32), level INTEGER, ilerleme INTEGER, premium INTEGER, oyuncumodeli INTEGER, bicakmodeli INTEGER)");
	SQL_TQuery(sDatabase, SQL_ConnectCallback, query);
}

void SorgulaClient(int client)
{
	char sId[32];
	GetClientAuthId(client, AuthId_Steam2, sId, sizeof(sId));
	
	char query[255];
	Format(query, sizeof(query), "SELECT level, ilerleme, premium, oyuncumodeli, bicakmodeli FROM battlepass WHERE steamid = '%s'", sId);
	SQL_TQuery(sDatabase, SQL_SorgulaCallback, query, GetClientUserId(client));
}

public int SQL_SorgulaCallback(Handle owner, Handle hdnl, char[] error, any data)
{
	int client;
	if((client = GetClientOfUserId(data)) == 0)
		return;
	if(hdnl == null)
	{
		LogToFile(LogPath, "Veritabanı Hatası: %s", error);
		return;
	}
	if(!SQL_GetRowCount(hdnl) || !SQL_FetchRow(hdnl))
	{
		AddNewPlayer(client);
		ClientLevel[client] = 0;
		ClientIlerleme[client] = 0;
		ClientPremium[client] = 0;
		ClientOyuncuModeli[client] = -1;
		ClientBicakModeli[client] = -1;
		return;
	}
	ClientLevel[client] = SQL_FetchInt(hdnl, 0);
	ClientIlerleme[client] = SQL_FetchInt(hdnl, 1);
	ClientPremium[client] = SQL_FetchInt(hdnl, 2);
	ClientOyuncuModeli[client] = SQL_FetchInt(hdnl, 3);
	ClientBicakModeli[client] = SQL_FetchInt(hdnl, 4);
	SetKnifeModel(client);
	if(ClientLevel[client] < 0)
	{
		ClientLevel[client] = 0;
	}
}

public void AddNewPlayer(int client)
{
	char sId[32];
	GetClientAuthId(client, AuthId_Steam2, sId, sizeof(sId));
	
	char Name[MAX_NAME_LENGTH+1];
	char SafeName[(sizeof(Name)*2)+1];
	if(!GetClientName(client, Name, sizeof(Name)))
		Format(SafeName, sizeof(SafeName), "<noname>");
	else
	{
		TrimString(Name);
		SQL_EscapeString(sDatabase, Name, SafeName, sizeof(SafeName));
	}
	
	char query[255];
	Format(query, sizeof(query), "INSERT INTO battlepass(steamid, name, level, ilerleme, premium, oyuncumodeli, bicakmodeli) VALUES('%s', '%s', '0', '0','0','-1','-1')", sId, SafeName);
	SQL_TQuery(sDatabase, SQL_ErrorCheck, query);
	SetKnifeModel(client);
}

public void UpdatePlayerInfo(int client)
{
	char sId[32];
	GetClientAuthId(client, AuthId_Steam2, sId, sizeof(sId));
	
	char Name[MAX_NAME_LENGTH+1];
	char SafeName[(sizeof(Name)*2)+1];
	if(!GetClientName(client, Name, sizeof(Name)))
		Format(SafeName, sizeof(SafeName), "<noname>");
	else
	{
		TrimString(Name);
		SQL_EscapeString(sDatabase, Name, SafeName, sizeof(SafeName));
	}
	
	char query[255];
	Format(query, sizeof(query), "UPDATE battlepass SET name = '%s', level = '%d', ilerleme = '%d', premium = '%d' , oyuncumodeli = '%d', bicakmodeli = '%d' WHERE steamid = '%s'",SafeName, ClientLevel[client], ClientIlerleme[client], ClientPremium[client], ClientOyuncuModeli[client],ClientBicakModeli[client], sId);
	SQL_TQuery(sDatabase, SQL_ErrorCheck, query);
}

public int SQL_ErrorCheck(Handle owner, Handle hdnl, char[] error, any data)
{
	if(hdnl == null)
		LogToFile(LogPath, "Veritabanı Hatası: %s", error);
}

public int SQL_ConnectCallback(Handle owner, Handle hdnl, char[] error, any data)
{
	if(hdnl == null)
	{
		LogToFile(LogPath, "Veritabanı Hatası: %s", error);
		SetFailState("Veritabanı Hatası: %s", error);
	}
	for(int i = 1; i<= MaxClients; i++)
	{
		if(IsClientInGame(i) && !IsFakeClient(i))
			SorgulaClient(i);
	}
}

public Action ShowTotal(int client, int args)
{
	if (sDatabase != INVALID_HANDLE)
	{
		char buffer[200];
		Format(buffer, sizeof(buffer), "SELECT name, level FROM battlepass ORDER BY level DESC LIMIT 999");
		SQL_TQuery(sDatabase, ShowTotalCallback, buffer, client);
	}
	else
	{
		PrintToChat(client, " \x07[BATTLEPASS] \x01Rank sistemi şuanlık aktif değil.");
	}
}

public int ShowTotalCallback(Handle owner, Handle hndl, char[] error, any client)
{
	if (hndl == INVALID_HANDLE)
	{
		LogToFile(LogPath, error);
		return;
	}
	
	Menu menu = new Menu(topmenu);
	menu.SetTitle("Battlepass - En İyiler\n▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬");
	
	int order = 0;
	char name[64];
	char textbuffer[128];
	char steamid[128];
	
	if (SQL_HasResultSet(hndl))
	{
		while (SQL_FetchRow(hndl))
		{
			order++;
			SQL_FetchString(hndl, 0, name, sizeof(name));
			SQL_FetchString(hndl, 0, name, sizeof(name));
			Format(textbuffer, 128, "[%d.] %s [level %d]", order, name, SQL_FetchInt(hndl, 1) + 1);
			menu.AddItem(steamid, textbuffer, ITEMDRAW_DISABLED);
		}
	}
	if (order < 1)
	{
		menu.AddItem("empty", "TOP Bomboş!");
	}
	
	menu.ExitButton = true;
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int topmenu(Menu menu, MenuAction action, int client, int item)
{
	if(action == MenuAction_Select)
	{
	}
	else if(action == MenuAction_Cancel)
	{
		if(item == MenuCancel_ExitBack)
		{
			Menu_AnaMenu(client);
		}
	}
	else if(action == MenuAction_End)
	{
		delete menu;
	}
}

public void SQLPremiumVer(const char[] sId, int number)
{
	char query[255];
	Format(query, sizeof(query), "UPDATE battlepass SET premium = '%d' WHERE steamid = '%s'",number ,sId);
	SQL_TQuery(sDatabase, SQL_ErrorCheck, query);
}

public Action bpgoster(int client, int args)
{
	if(args >= 1)
	{
		char arg1[64];
		GetCmdArg(1, arg1, sizeof(arg1));
		if(StrContains(arg1, "STEAM_", false) != -1)
		{
			char query[255];
			Format(query, sizeof(query), "SELECT name, level, ilerleme, bicakmodeli FROM battlepass WHERE steamid = '%s'", arg1);
			SQL_TQuery(sDatabase, SQLVeriAl, query, GetClientUserId(client));
		}
		else
			ReplyToCommand(client, " \x07[Battlepass] \x01Bir steamid girmelisin.");
	}
	else
		ReplyToCommand(client," \x07[Battlepass] \x01Kullanım: !bpgoster <Steam Id>");
}


public int SQLVeriAl(Handle owner, Handle hndl, char[] error, any data)
{
	int client;
	if((client = GetClientOfUserId(data)) == 0)
		return;
	if(hndl == null)
	{
		return;
	}
	if(!SQL_GetRowCount(hndl) || !SQL_FetchRow(hndl))
	{
		PrintToChat(client, " \x07[Battlepass] \x01Oyuncuya ait veri bulunamadı.");
		return;
	}
	
	char name[64];
	SQL_FetchString(hndl, 0, name, sizeof(name));
	
	char sLevel[32], sIlerleme[32], sBicakModeli[32], sTitle[64];
	Format(sTitle, sizeof(sTitle), "Oyuncu: %s", name);
	Format(sLevel, sizeof(sLevel), "Level: %d", SQL_FetchInt(hndl, 1) + 1);
	Format(sIlerleme, sizeof(sIlerleme), "Ilerleme: %d", SQL_FetchInt(hndl, 2));
	Format(sBicakModeli, sizeof(sBicakModeli), "Bıçak Modeli: %d", SQL_FetchInt(hndl, 3));
	
	Panel panel = new Panel();
	panel.SetTitle(sTitle);
	panel.DrawText(sLevel);
	panel.DrawText(sIlerleme);
	panel.DrawText(sBicakModeli);
	panel.DrawItem("Kapat");
	panel.Send(client, panelcallback, MENU_TIME_FOREVER);
	delete panel;
}

public int panelcallback(Menu menu, MenuAction action, int client, int item)
{
	if(action == MenuAction_Select)
	{
		
	}
	else if(action == MenuAction_End)
	{
		
	}
	
}

