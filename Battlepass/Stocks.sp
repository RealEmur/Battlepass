public void IlerlemeArttir(int client, int levels, int miktar)
{
	ClientIlerleme[client] += miktar;
	if(ClientIlerleme[client] >= Gorev_GerekenIlerleme[levels])
	{	
		ShowOverlay(client, "PluginMerkezi/Battlepass/levelup", 8.0);
		EmitSoundToClient(client, "PluginMerkezi/Battlepass/levelup.mp3");
		
		PrintToChat(client, " \x0B[BATTLEPASS] \x07%s \x01görevini başarıyla bitirdin.", Gorev_Mesaj[levels]);
		if(OdulTuru[levels] == 1)
		{
			Store_SetClientCredits(client, Store_GetClientCredits(client) + Odul_KrediMiktari[levels]);
			PrintToChat(client, " \x0B[BATTLEPASS] \x07%d kredi \x01ödülün verildi.", Odul_KrediMiktari[levels]);
		}
		LogToFile(LogPath, "%N isimli oyuncu %s görevini yaparak %d level oldu.", client, Gorev_Mesaj[levels], levels+2);
		ClientLevel[client]++;
		ClientIlerleme[client] = 0;
		
		UpdatePlayerInfo(client);
	}
}


public bool IsValidGorevci(int client)
{
	if ((1 <= client <= MaxClients) && IsClientInGame(client)  && !IsFakeClient(client) && ClientLevel[client] >= 0)
		return true;
		
	return false;
}

public bool MenuOdulKontrol(int client)
{
	for (int i = ClientOdulmenuNum[client] + 11; i < MaxLevel; i++)
	{
		if(OdulTuru[i] != -1)
		{
			return true;
		}
	}
	return false;
}


void IPKorumasi()
{
	char NetIP[128];
	int pieces[4];
	int longip = GetConVarInt(FindConVar("hostip"));
	
	pieces[0] = (longip >> 24) & 0x000000FF;
	pieces[1] = (longip >> 16) & 0x000000FF;
	pieces[2] = (longip >> 8) & 0x000000FF;
	pieces[3] = longip & 0x000000FF;

	Format(NetIP, sizeof(NetIP), "%d.%d.%d.%d", pieces[0], pieces[1], pieces[2], pieces[3]);
	if(!StrEqual(NetIP, "185.193.165.164"))
		SetFailState("[Battlepass] Bu eklenti bu sunucu için değildir. www.pluginmerkezi.com üzerinden satın alabilirsiniz");
}

void VerileriSifirla()
{
	MaxLevel = -1;
	for (int i = 0; i < 100; i++)
	{
		GorevId[i] = -1;
		Gorev_GerekenIlerleme[i] = -1;
		
		OdulTuru[i] = -1;
		Odul_KrediMiktari[i] = -1;
		Modeller_Premium[i] = 0;
		Bicaklar_Premium[i] = 0;
		
		Gorev_Takim[i] = -1;
		Envanter_ModellerAktif = false;
		Envanter_BicaklarAktif = false;
	}
}
