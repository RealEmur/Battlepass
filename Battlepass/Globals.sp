Handle sDatabase = null;
char KV_Gorevler[PLATFORM_MAX_PATH];
char KV_Oduller[PLATFORM_MAX_PATH];
char LogPath[PLATFORM_MAX_PATH];
char ModelPathFile[PLATFORM_MAX_PATH];

int MaxLevel = -1;
int GorevId[100] = {-1, ...};
int Gorev_GerekenIlerleme[100] = {-1, ...};
char Gorev_Mesaj[100][100];

int OdulTuru[100] = {-1, ...};
int Odul_KrediMiktari[100] = {-1, ...};
char Modeller_ModelIsmi[100][64];
char Modeller_DosyaYolu[100][PLATFORM_MAX_PATH];
int Modeller_Premium[100] = {0, ...};

char Bicaklar_BicakIsmi[100][64];
char Bicaklar_ViewDosyaYolu[100][PLATFORM_MAX_PATH];
char Bicaklar_WorldDosyaYolu[100][PLATFORM_MAX_PATH];

int Bicaklar_ViewModel[100] = {-1, ...};
int Bicaklar_WorldModel[100] = {-1, ...};
int Bicaklar_Premium[100] = {0, ...};

int Gorev_Takim[100] = {-1, ...};
char Gorev_Weapon[100][32];

bool Envanter_ModellerAktif = false, Envanter_BicaklarAktif = false;

//int ctInLr = -1, tInLr = -1;

/*Client Kısmı*/
int ClientLevel[MAXPLAYERS + 1] = {-1, ...},
ClientIlerleme[MAXPLAYERS + 1] = {-1, ...},
ClientPremium[MAXPLAYERS + 1] = {-1, ...},
ClientOyuncuModeli[MAXPLAYERS + 1] = {-1, ...};
ClientBicakModeli[MAXPLAYERS + 1] =  { -1, ... };

int ClientGorevmenuNum[MAXPLAYERS + 1] =  {1, ... };
int ClientOdulmenuNum[MAXPLAYERS + 1] =  {1, ... };

