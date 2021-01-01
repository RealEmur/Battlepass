public void Menu_AnaMenu(int client)
{
	if(IsValidGorevci(client))
	{
		char levelBuffer[128], ilerlemeBuffer[32];
		if(ClientLevel[client] >= MaxLevel)
		{
			Format(levelBuffer, sizeof(levelBuffer), "Level %d: MAXLEVEL", ClientLevel[client] + 1, Gorev_Mesaj[ClientLevel[client]]);
			Format(ilerlemeBuffer, sizeof(ilerlemeBuffer), "Mevcut İlerleme: %d/∞", ClientIlerleme[client]);
		}
		else
		{
			Format(levelBuffer, sizeof(levelBuffer), "Level %d: %s", ClientLevel[client] + 1, Gorev_Mesaj[ClientLevel[client]]);
			Format(ilerlemeBuffer, sizeof(ilerlemeBuffer), "Mevcut İlerleme: %d/%d", ClientIlerleme[client], Gorev_GerekenIlerleme[ClientLevel[client]]);
		}
		Panel menu = new Panel();
		menu.SetTitle("Battlepass");
		menu.DrawText("▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬");
		menu.DrawText(levelBuffer);
		menu.DrawText(ilerlemeBuffer);
		menu.DrawText("▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬");
		menu.CurrentKey = 5;
		menu.DrawItem("Tüm Görevler");
		menu.CurrentKey = 6;
		menu.DrawItem("Tüm Ödüller");
		menu.DrawText("▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬");
		menu.CurrentKey = 7;
		if(Envanter_ModellerAktif || Envanter_BicaklarAktif)
		{
			menu.CurrentKey = 7;
			menu.DrawItem("Envanter");
		}
		menu.CurrentKey = 8;
		menu.DrawItem("En İyiler!");
		menu.DrawText("▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬");
		menu.CurrentKey = 9;
		menu.DrawItem("Kapat");
		menu.Send(client,AnaMenu, MENU_TIME_FOREVER);
		delete menu;
	}
}

public int AnaMenu(Menu menu, MenuAction action, int client, int item)
{
	if(action == MenuAction_Select)
	{
		if(item == 5)
		{
			ClientGorevmenuNum[client] = 1;
			GorevMenusu(client);
		}
		else if(item == 6)
		{
			ClientOdulmenuNum[client] = 1;
			OdulMenusu(client);
		}
		else if(item == 7)
			Menu_Envanter(client);
		else if(item == 8)
			ShowTotal(client, 0);
	}
	else if(action == MenuAction_End)
	{
	}
}

public void Menu_Envanter(int client)
{
	Menu menu = new Menu(Envanter)
	menu.SetTitle("Envanter\n▬▬▬▬▬▬▬▬▬▬▬▬▬▬");
	if(Envanter_ModellerAktif)
		menu.AddItem("1", "Oyuncu Modelleri");
	if(Envanter_BicaklarAktif)
		menu.AddItem("2", "Bıçak Modelleri");
	
	menu.AddItem("", "", ITEMDRAW_NOTEXT);
	menu.ExitButton = true;
	menu.ExitBackButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Envanter(Menu menu, MenuAction action, int client, int item)
{
	if(action == MenuAction_Select)
	{
		char secilen[32];
		menu.GetItem(item, secilen, sizeof(secilen));
		if(StringToInt(secilen) == 1)
			Menu_EnvanterOyuncuModelleri(client);
		else if(StringToInt(secilen) == 2)
			Menu_EnvanterBicakModelleri(client);
	}
	else if(action == MenuAction_Cancel)
	{
		if(item == MenuCancel_ExitBack)
			Menu_AnaMenu(client);
	}
	else if(action == MenuAction_End)
	{
		delete menu;
	}
}

public void Menu_EnvanterOyuncuModelleri(int client)
{
	Menu menu = new Menu(Envanter_OyuncuModelleri)
	menu.SetTitle("Oyuncu Modelleri\n▬▬▬▬▬▬▬▬▬▬▬▬▬▬");
	for(int i = 0; i< 100;i++)
	{
		if(OdulTuru[i] == 2)
		{
			char modelismi[258], iBuffer[16];
			IntToString(i, iBuffer, sizeof(iBuffer));
			if(Modeller_Premium[i] == 0)
				Format(modelismi, sizeof(modelismi), "[LEVEL %d] %s",i+1, Modeller_ModelIsmi[i]);
			else
				Format(modelismi, sizeof(modelismi), "[LEVEL %d] %s ♛",i+1, Modeller_ModelIsmi[i]);
			if(ClientLevel[client] > i)
				menu.AddItem(iBuffer, modelismi, ITEMDRAW_DEFAULT);
			else
				menu.AddItem(iBuffer, modelismi, ITEMDRAW_DISABLED);
		}
	}
	menu.AddItem("", "", ITEMDRAW_NOTEXT);
	menu.ExitBackButton = true;
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Envanter_OyuncuModelleri(Menu menu, MenuAction action, int client, int item)
{
	if(action == MenuAction_Select)
	{
		char secilen[32];
		menu.GetItem(item, secilen, sizeof(secilen));
		if(Modeller_Premium[StringToInt(secilen)] == 0 || (Modeller_Premium[StringToInt(secilen)] == 1 && ClientPremium[client] == 1))
			OnayMenusu(client, 1, StringToInt(secilen));
		else
		{
			PrintToChat(client, " \x07[BATTLEPASS] \x01Bu modeli kullanabilmek için \x10Premium Battlepass \x01sahibi olmalısın.");
			Menu_EnvanterOyuncuModelleri(client);
		}
	}
	else if(action == MenuAction_Cancel)
	{
		if(item == MenuCancel_ExitBack)
				Menu_Envanter(client);
	}
	else if(action == MenuAction_End)
	{
		delete menu;
	}
}

public void Menu_EnvanterBicakModelleri(int client)
{
	Menu menu = new Menu(Envanter_BicakModelleri)
	menu.SetTitle("Bıçak Modelleri\n▬▬▬▬▬▬▬▬▬▬▬▬▬▬");
	for(int i = 0; i< 100;i++)
	{
		if(OdulTuru[i] == 3)
		{
			char modelismi[258], iBuffer[16];
			IntToString(i, iBuffer, sizeof(iBuffer));
			if(Bicaklar_Premium[i] == 0)
				Format(modelismi, sizeof(modelismi), "[LEVEL %d] %s",i+1, Bicaklar_BicakIsmi[i]);
			else
				Format(modelismi, sizeof(modelismi), "[LEVEL %d] %s ♛",i+1, Bicaklar_BicakIsmi[i]);
			if(ClientLevel[client] > i)
				menu.AddItem(iBuffer, modelismi, ITEMDRAW_DEFAULT);
			else
				menu.AddItem(iBuffer, modelismi, ITEMDRAW_DISABLED);
		}
	}
	menu.AddItem("", "", ITEMDRAW_NOTEXT);
	menu.ExitBackButton = true;
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Envanter_BicakModelleri(Menu menu, MenuAction action, int client, int item)
{
	if(action == MenuAction_Select)
	{
		char secilen[32];
		menu.GetItem(item, secilen, sizeof(secilen));
		if(Bicaklar_Premium[StringToInt(secilen)] == 0 || (Bicaklar_Premium[StringToInt(secilen)] == 1 && ClientPremium[client] == 1))
			OnayMenusu(client, 2, StringToInt(secilen));
		else
		{
			PrintToChat(client, " \x07[BATTLEPASS] \x01Bu modeli kullanabilmek için \x10Premium Battlepass \x01sahibi olmalısın.");
			Menu_EnvanterBicakModelleri(client);
		}
	}
	else if(action == MenuAction_Cancel)
	{
		if(item == MenuCancel_ExitBack)
				Menu_Envanter(client);
	}
	else if(action == MenuAction_End)
	{
		delete menu;
	}
}

public void OnayMenusu(int client, int menuType, int sId)
{
	Menu menu = new Menu(onaymenucallback);
	if(menuType == 1)
	{
		menu.SetTitle("Model: %s", Modeller_ModelIsmi[sId]);
		if(ClientOyuncuModeli[client] == sId)
			menu.AddItem("1", "Modeli Çıkar");
		else
		{
			char idFormat[64];
			Format(idFormat, sizeof(idFormat), "%dmodel", sId)
			menu.AddItem(idFormat, "Modeli Giy");
		}
	}
	else if(menuType == 2)
	{
		menu.SetTitle("Bıçak: %s", Bicaklar_BicakIsmi[sId]);
		if(ClientBicakModeli[client] == sId)
			menu.AddItem("2", "Modeli Çıkar");
		else
		{
			char idFormat[64];
			Format(idFormat, sizeof(idFormat), "%dbicak", sId)
			menu.AddItem(idFormat, "Modeli Giy");
		}
	}
	menu.ExitBackButton = true;
	menu.ExitButton = false;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int onaymenucallback(Menu menu, MenuAction action, int client, int item)
{
	if(action == MenuAction_Select)
	{
		char sItem[32];
		menu.GetItem(item, sItem, sizeof(sItem));
		if(StrContains(sItem, "model") != -1)
		{
			if(IsClientInGame(client) && !IsFakeClient(client) && IsPlayerAlive(client))
				SetEntityModel(client, Modeller_DosyaYolu[StringToInt(sItem)]);
			ClientOyuncuModeli[client] = StringToInt(sItem);
		}
		else if(StrContains(sItem, "bicak") != -1)
		{
			ClientBicakModeli[client] = StringToInt(sItem);
			SetKnifeModel(client);
		}
		else if(StringToInt(sItem) == 1)
			ClientOyuncuModeli[client] = -1;
		else if(StringToInt(sItem) == 2)
		{
			ClientBicakModeli[client] = -1;
			SetKnifeModel(client);
		}
	}
	else if(action == MenuAction_Cancel)
	{
		if(item == MenuCancel_ExitBack)
				Menu_Envanter(client);
	}
	else if(action == MenuAction_End)
	{
		delete menu;
	}
}


public void GorevMenusu(int client)
{
	int sayi = ClientGorevmenuNum[client];
	
	Panel menu = new Panel();
	menu.SetTitle("Görevler\n▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬")
	while(sayi < ClientGorevmenuNum[client] + 10 && sayi <= MaxLevel)
	{
		char gorev[128];
		Format(gorev, sizeof(gorev), "%d - %s", sayi, Gorev_Mesaj[sayi - 1]);
		menu.DrawText(gorev);
		sayi++;
	}
	menu.DrawText("▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬");
	menu.CurrentKey = 7;
	menu.DrawItem("Geri");
	if(ClientGorevmenuNum[client] + 10 < MaxLevel)
	{
		menu.CurrentKey = 8;
		menu.DrawItem("İleri");
	}
	menu.DrawText(" ");
	menu.CurrentKey = 9;
	menu.DrawItem("Kapat");
	menu.Send(client, gorevmenucallback, MENU_TIME_FOREVER);
	delete menu;
}

public int gorevmenucallback(Menu menu, MenuAction action, int client, int item)
{
	if(action == MenuAction_Select)
	{
		if(item == 7)
		{
			if(ClientGorevmenuNum[client] == 1)
			{
				Menu_AnaMenu(client);
				return;
			}
			ClientGorevmenuNum[client] -= 10;
			GorevMenusu(client);
		}
		else if(item == 8)
		{
			ClientGorevmenuNum[client] += 10;
			GorevMenusu(client);
		}
		else if(item == 9)
			ClientGorevmenuNum[client] = 1;
	}
	else if(action == MenuAction_End)
	{
	}
}

public void OdulMenusu(int client)
{
	int sayi = ClientOdulmenuNum[client];
	
	Panel menu = new Panel();
	menu.SetTitle("Ödüller\n▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬")
	while(sayi < ClientOdulmenuNum[client] + 10 && sayi <= MaxLevel)
	{
		char gorev[128];
		if(OdulTuru[sayi - 1] == 1)
			Format(gorev, sizeof(gorev), "%d - %d Kredi", sayi, Odul_KrediMiktari[sayi - 1]);
		else if(OdulTuru[sayi - 1] == 2)
			Format(gorev, sizeof(gorev), "%d - %s Oyuncu Modeli", sayi, Modeller_ModelIsmi[sayi - 1]);
		else if(OdulTuru[sayi - 1] == 3)
			Format(gorev, sizeof(gorev), "%d - %s Bıçak Modeli", sayi, Bicaklar_BicakIsmi[sayi - 1]);
		else
		{
			sayi++;
			continue;
		}
		menu.DrawText(gorev);
		sayi++;
	}
	menu.DrawText("▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬");
	menu.CurrentKey = 7;
	menu.DrawItem("Geri");
	if(ClientOdulmenuNum[client] + 10 < MaxLevel && MenuOdulKontrol(client))
	{
		menu.CurrentKey = 8;
		menu.DrawItem("İleri");
	}
	menu.DrawText(" ");
	menu.CurrentKey = 9;
	menu.DrawItem("Kapat");
	menu.Send(client, odulmenusucallback, MENU_TIME_FOREVER);
	delete menu;
}

public int odulmenusucallback(Menu menu, MenuAction action, int client, int item)
{
	if(action == MenuAction_Select)
	{
		if(item == 7)
		{
			if(ClientOdulmenuNum[client] == 1)
			{
				Menu_AnaMenu(client);
				return;
			}
			ClientOdulmenuNum[client] -= 10;
			OdulMenusu(client);
		}
		else if(item == 8)
		{
			ClientOdulmenuNum[client] += 10;
			OdulMenusu(client);
		}
		else if(item == 9)
			ClientOdulmenuNum[client] = 1;
	}
	else if(action == MenuAction_End)
	{
	}
}
