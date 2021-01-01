void GorevleriYukle()
{
	KeyValues kv = CreateKeyValues("Levellar");
	kv.ImportFromFile(KV_Gorevler);
	
	char iBuffer[16];
	for (int i = 0; i < 100; i++)
	{
		IntToString(i + 1, iBuffer, sizeof(iBuffer));
		if (kv.JumpToKey(iBuffer, false))
		{
			GorevId[i] = kv.GetNum("Gorev ID");
			Gorev_GerekenIlerleme[i] = kv.GetNum("Gereken İlerleme");
			kv.GetString("Görev Mesajı", Gorev_Mesaj[i], sizeof(Gorev_Mesaj[]));
			
			if (GorevId[i] == 2 || GorevId[i] == 14 || GorevId[i] == 16 || GorevId[i] == 18)
				Gorev_Takim[i] = kv.GetNum("Takım")
			if (GorevId[i] == 3 || GorevId[i] == 5)
				kv.GetString("Silah", Gorev_Weapon[i], sizeof(Gorev_Weapon[]));
			kv.GoBack();
		}
		else
		{
			MaxLevel = i;
			break;
		}
	}
	kv.Rewind();
	kv.ExportToFile(KV_Gorevler);
	delete kv;
}

void OdulleriYukle()
{
	Envanter_ModellerAktif = false;
	
	KeyValues kv = CreateKeyValues("Ödüller");
	kv.ImportFromFile(KV_Oduller);

	char iBuffer[16];
	for (int i = 0; i < 100; i++)
	{
		IntToString(i + 1, iBuffer, sizeof(iBuffer));
		if (kv.JumpToKey(iBuffer, false))
		{
			OdulTuru[i] = kv.GetNum("Ödül Türü");
			if (OdulTuru[i] == 1)
				Odul_KrediMiktari[i] = kv.GetNum("Kredi Miktarı");
			else if(OdulTuru[i] == 2)
			{
				kv.GetString("Model İsmi", Modeller_ModelIsmi[i], sizeof(Modeller_ModelIsmi[]));
				kv.GetString("Dosya Yolu", Modeller_DosyaYolu[i], sizeof(Modeller_DosyaYolu[]));
				Modeller_Premium[i] = kv.GetNum("Premium", 0);
				PrecacheModel(Modeller_DosyaYolu[i], true);
				Downloader_AddFileToDownloadsTable(Modeller_DosyaYolu[i]);
				if (!Envanter_ModellerAktif)Envanter_ModellerAktif = true;
			}
			else if(OdulTuru[i] == 3)
			{
				kv.GetString("Model İsmi", Bicaklar_BicakIsmi[i], sizeof(Bicaklar_BicakIsmi[]));
				kv.GetString("View Model", Bicaklar_ViewDosyaYolu[i], sizeof(Bicaklar_ViewDosyaYolu[]), "null");
				kv.GetString("World Model", Bicaklar_WorldDosyaYolu[i], sizeof(Bicaklar_WorldDosyaYolu[]), "null");
				Bicaklar_ViewModel[i] = PrecacheModel(Bicaklar_ViewDosyaYolu[i], true);
				Downloader_AddFileToDownloadsTable(Bicaklar_ViewDosyaYolu[i]);
				if(!StrEqual(Bicaklar_WorldDosyaYolu[i], "null"))
				{
					Bicaklar_WorldModel[i] = PrecacheModel(Bicaklar_WorldDosyaYolu[i] , true);
					Downloader_AddFileToDownloadsTable(Bicaklar_WorldDosyaYolu[i]);
				}
				Bicaklar_Premium[i] = kv.GetNum("Premium", 0);
				if (!Envanter_BicaklarAktif)Envanter_BicaklarAktif = true;
			}
			kv.GoBack();
		}
	}
	kv.Rewind();
	kv.ExportToFile(KV_Oduller);
	delete kv;
} 


void PrecacheKontrol()
{
	KeyValues kv = CreateKeyValues("Ödüller");
	kv.ImportFromFile(KV_Oduller);

	char iBuffer[16];
	for (int i = 0; i < 100; i++)
	{
		IntToString(i + 1, iBuffer, sizeof(iBuffer));
		if (kv.JumpToKey(iBuffer, false))
		{
			int sOdul = kv.GetNum("Ödül Türü");
			if(sOdul == 2)
			{
				kv.GetString("Dosya Yolu", Modeller_DosyaYolu[i], sizeof(Modeller_DosyaYolu[]), "null");
				if(!IsModelPrecached(Modeller_DosyaYolu[i]))
				{
					PrecacheModel(Modeller_DosyaYolu[i], true);
					Downloader_AddFileToDownloadsTable(Modeller_DosyaYolu[i]);
				}
			}
			else if(sOdul == 3)
			{
				kv.GetString("View Model", Bicaklar_ViewDosyaYolu[i], sizeof(Bicaklar_ViewDosyaYolu[]), "null");
				kv.GetString("World Model", Bicaklar_WorldDosyaYolu[i], sizeof(Bicaklar_WorldDosyaYolu[]), "null");
				
				if(!IsModelPrecached(Bicaklar_ViewDosyaYolu[i]))
				{
					Bicaklar_ViewModel[i] = PrecacheModel(Bicaklar_ViewDosyaYolu[i], true);
					Downloader_AddFileToDownloadsTable(Bicaklar_ViewDosyaYolu[i]);
				}
				if(!StrEqual(Bicaklar_WorldDosyaYolu[i], "null"))
				{
					if(!IsModelPrecached(Bicaklar_WorldDosyaYolu[i]))
					{
						Bicaklar_WorldModel[i] = PrecacheModel(Bicaklar_WorldDosyaYolu[i], true);
						Downloader_AddFileToDownloadsTable(Bicaklar_WorldDosyaYolu[i]);
					}
				}
			}
			kv.GoBack();
		}
	}
	kv.Rewind();
	kv.ExportToFile(KV_Oduller);
	delete kv;
}