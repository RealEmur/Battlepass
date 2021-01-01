void EventleriYukle()
{
	HookEvent("player_death", event_death);
	HookEvent("player_hurt", event_hurt);
	HookEvent("player_jump", event_jump);
	HookEvent("player_falldamage", event_falldamage);
	HookEvent("weapon_fire", event_fire);
	HookEvent("player_footstep", event_footstep);
	HookEvent("grenade_thrown", event_grenade);
	HookEvent("player_blind", event_blind);
	HookEvent("round_end", round_end);
	HookEvent("round_mvp", round_mvp);
	
	//Farklı olaylar ile alakalı
	HookEvent("player_spawn", event_spawn);
}

/*
1-  Oyuncu öldür. +
2-  Takımdaki oyuncuyu öldür. +
3-  Belli bir silah ile oyuncu öldür. (Bombalar dahil değil) +
4-  HS atarak oyuncu öldür. +
5-  Belli bir silah ile HS atarak oyuncu öldür. +
6-  No Scope atarak oyuncu öldür. +
7-  Kör iken oyuncu öldür. +
8-  Komutçuyu öldür. +
9-  Takım arkadaşını öldür. +
10- Bir Killde Asist al. +

11- Öl. (Başka bir oyuncu tarafından) +
12- İntihar Et. +

13- Round oyna. +
14- Belli bir takımda round oyna. +
15- Round kazan. +
16- Belli bir takımda round kazan. +

17- MVP Ol. +
18- Belli bir takımda MVP Ol. +

19- Hasar ver. +
20- Hasar al. +
21- Fall Damage al. +

22- Ateş et. +
23- Zıpla. +

26- Yürü. +

27- El bombası fırlat. +
28- Bir oyuncuyu kör et. (Takım arkadaşı sayılmaz) +
*/

public Action event_death(Event event, const char[] name, bool dontBroadcast)
{
	int victim = GetClientOfUserId(event.GetInt("userid"));
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	int assister = GetClientOfUserId(event.GetInt("assister"));
	if(attacker != victim)
	{
		if(IsValidGorevci(attacker))
		{
			//Oyuncu öldür.
			if(GorevId[ClientLevel[attacker]] == 1)
				IlerlemeArttir(attacker, ClientLevel[attacker], 1);
			//Takımdaki oyuncuyu öldür. 
			else if(GorevId[ClientLevel[attacker]] == 2 && GetClientTeam(victim) == Gorev_Takim[ClientLevel[attacker]])
				IlerlemeArttir(attacker, ClientLevel[attacker], 1);
			//Belli bir silah ile oyuncu öldür.
			else if(GorevId[ClientLevel[attacker]] == 3)
			{
				char weapon[32], sWeapon[32];
				event.GetString("weapon", sWeapon, sizeof(sWeapon), "null");
				Format(weapon, sizeof(weapon), "weapon_%s", sWeapon);
				if(StrContains(weapon, Gorev_Weapon[ClientLevel[attacker]]) != -1)
					IlerlemeArttir(attacker, ClientLevel[attacker], 1);
			}
			
			//HS ile öldür - Bir silah ile HS atarak öldür.
			else if(event.GetBool("headshot"))
			{
				if(GorevId[ClientLevel[attacker]] == 4)
					IlerlemeArttir(attacker, ClientLevel[attacker], 1);
					
				else if(GorevId[ClientLevel[attacker]] == 5)
				{
					char weapon[32], sWeapon[32];
					event.GetString("weapon", sWeapon, sizeof(sWeapon), "null");
					Format(weapon, sizeof(weapon), "weapon_%s", sWeapon);
					if(StrContains(weapon, Gorev_Weapon[ClientLevel[attacker]]) != -1)
						IlerlemeArttir(attacker, ClientLevel[attacker], 1);
				}
			}
			//NoScope atarak oyuncu öldür.
			else if(event.GetBool("noscope") && GorevId[ClientLevel[attacker]] == 6)
				IlerlemeArttir(attacker, ClientLevel[attacker], 1);
			//Körken oyuncu öldür.
			else if(event.GetBool("attackerblind") && GorevId[ClientLevel[attacker]] == 7)
				IlerlemeArttir(attacker, ClientLevel[attacker], 1);
			//Komutçuyu öldür.
			else if(warden_iswarden(victim) && GorevId[ClientLevel[attacker]] == 8)
				IlerlemeArttir(attacker, ClientLevel[attacker], 1);
			//Takım arkadaşı öldür
			else if(GetClientTeam(attacker) == GetClientTeam(victim) && GorevId[ClientLevel[attacker]] == 9)
				IlerlemeArttir(attacker, ClientLevel[attacker], 1);
		}
		if(IsValidGorevci(victim))
		{
			//Öl
			if(GorevId[ClientLevel[victim]] == 11)
				IlerlemeArttir(victim, ClientLevel[victim], 1);
		}
		if(IsValidGorevci(assister))
		{
			//Bir killde asist al
			if(GorevId[ClientLevel[assister]] == 10)
				IlerlemeArttir(assister, ClientLevel[assister], 1);
		}
			
	}
	//İntihar et
	else if(IsValidGorevci(victim))
	{
		if(GorevId[ClientLevel[victim]] == 12)
			IlerlemeArttir(victim, ClientLevel[victim], 1);
	}
	return Plugin_Continue;
}

public Action event_hurt(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	if(client != attacker)
	{
		//Hasar ver
		if(IsValidGorevci(attacker) && GorevId[ClientLevel[attacker]] == 19)
		{
			float damage = event.GetFloat("dmg_health");
			if(damage > 100)damage = 100.0
			IlerlemeArttir(attacker, ClientLevel[attacker], RoundToFloor(damage));
		}
		//Hasar al
		if(IsValidGorevci(client) && GorevId[ClientLevel[client]] == 20)
		{
			float damage = event.GetFloat("dmg_health");
			if(damage > 100)damage = 100.0
			IlerlemeArttir(client, ClientLevel[client], RoundToFloor(damage));
		}
	}
	return Plugin_Continue;
}

public Action event_falldamage(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	//Fall damage al.
	if(IsValidGorevci(client) && GorevId[ClientLevel[client]] == 21)
	{
		float damage = event.GetFloat("damage");
		if(damage > 100)damage = 100.0
		IlerlemeArttir(client, ClientLevel[client], RoundToFloor(damage));
	}
	return Plugin_Continue;
}

public Action event_fire(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	//Ateş et
	if(IsValidGorevci(client) && GorevId[ClientLevel[client]] == 22)
	{
		char weapon[32];
		event.GetString("weapon", weapon, sizeof(weapon));
		if(StrContains(weapon, "knife") == -1)
			IlerlemeArttir(client, ClientLevel[client], 1);
	}
	return Plugin_Continue;
}

public Action event_jump(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	//Zıpla
	if(IsValidGorevci(client) && GorevId[ClientLevel[client]] == 23)
		IlerlemeArttir(client, ClientLevel[client], 1);
	return Plugin_Continue;
}

public Action event_footstep(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	//Yürü
	if(IsValidGorevci(client) && GorevId[ClientLevel[client]] == 26)
		IlerlemeArttir(client, ClientLevel[client], 1);
	return Plugin_Continue;
}

public Action event_grenade(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	//Bomba fırlat
	if(IsValidGorevci(client) && GorevId[ClientLevel[client]] == 27)
		IlerlemeArttir(client, ClientLevel[client], 1);
	return Plugin_Continue;
}

public Action event_blind(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	//Kör et
	if(client != attacker && GetClientTeam(client) != GetClientTeam(attacker) && IsValidGorevci(attacker) && GorevId[ClientLevel[attacker]] == 28)
		IlerlemeArttir(attacker, ClientLevel[attacker], 1);
	return Plugin_Continue;
}

public Action round_end(Event event, const char[] name, bool dontBroadcast)
{
	int winner = event.GetInt("winner");
	for (int i = 1; i <= MaxClients; i++)
	{
		if(IsValidGorevci(i))
		{
			//Round oyna.
			if(GorevId[ClientLevel[i]] == 13)
				IlerlemeArttir(i, ClientLevel[i], 1);
			//Belli takımda round oyna.
			else if(GorevId[ClientLevel[i]] == 14 && GetClientTeam(i) == Gorev_Takim[ClientLevel[i]])
				IlerlemeArttir(i, ClientLevel[i], 1);
			if(GetClientTeam(i) == winner)
			{
				//Round kazan.
				if(GorevId[ClientLevel[i]] == 15)
					IlerlemeArttir(i, ClientLevel[i], 1);
				//Belli takımda round kazan.
				else if(GorevId[ClientLevel[i]] == 16 && GetClientTeam(i) == Gorev_Takim[ClientLevel[i]])
					IlerlemeArttir(i, ClientLevel[i], 1);	
			}
		}
	}
	return Plugin_Continue;
}

public Action round_mvp(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if(IsValidGorevci(client))
	{
		//MVP Ol
		if(GorevId[ClientLevel[client]] == 17)
			IlerlemeArttir(client, ClientLevel[client], 1);
		else if(GorevId[ClientLevel[client]] == 18 && GetClientTeam(client) == Gorev_Takim[ClientLevel[client]])
			IlerlemeArttir(client, ClientLevel[client], 1);
	}
	return Plugin_Continue;
}
