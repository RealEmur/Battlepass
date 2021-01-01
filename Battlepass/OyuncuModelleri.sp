public Action event_spawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	int sModel = ClientOyuncuModeli[client];
	if(sModel != -1 && FileExists(Modeller_DosyaYolu[sModel]))
		CreateTimer(0.25, DodgeStoreAndSetTheModel, client, TIMER_FLAG_NO_MAPCHANGE);

	return Plugin_Continue;
}

public Action DodgeStoreAndSetTheModel(Handle timer, int client)
{
	//0.25 saniye içinde belki modeli değiştirir yarraklar diye bidaha kontrol ediyoruz.
	if(IsClientInGame(client) && !IsFakeClient(client) && IsPlayerAlive(client))
	{
		int sModel = ClientOyuncuModeli[client];
		if(sModel != -1 && FileExists(Modeller_DosyaYolu[sModel]))
			SetEntityModel(client, Modeller_DosyaYolu[sModel]);
	}
	return Plugin_Stop;
}

public void SetKnifeModel(int client)
{
	int sModel = ClientBicakModeli[client];
	if(sModel != -1 && !StrEqual(Bicaklar_ViewDosyaYolu[sModel], "null") && (FileExists(Bicaklar_ViewDosyaYolu[sModel]) || FileExists(Bicaklar_ViewDosyaYolu[sModel], true)) && IsModelPrecached(Bicaklar_ViewDosyaYolu[sModel]))
	{
		FPVMI_AddViewModelToClient(client, "weapon_knife", Bicaklar_ViewModel[sModel]);
	}
	if(sModel != -1 && !StrEqual(Bicaklar_WorldDosyaYolu[sModel], "null") && (FileExists(Bicaklar_WorldDosyaYolu[sModel]) || FileExists(Bicaklar_WorldDosyaYolu[sModel], true))&& IsModelPrecached(Bicaklar_WorldDosyaYolu[sModel]))
	{
		FPVMI_AddWorldModelToClient(client, "weapon_knife", Bicaklar_WorldModel[sModel]);
	}
	if(sModel == -1 || ClientLevel[client] <= sModel)
	{
		FPVMI_RemoveViewModelToClient(client, "weapon_knife");
		FPVMI_RemoveWorldModelToClient(client, "weapon_knife");
	}
}