//	26 Temmuz 2018 - sharax

#include 	<a_samp>
#include 	<a_mysql>
#include    <float>
#include    <dialogs>
#include 	<SKY>
#include    <weapon-config>
#include 	<sscanf2>
#include 	<Pawn.CMD>
#include 	<streamer>
#include 	<foreach>
#include 	<zones>
#include    <crashdetect>
#include    <progress2>
#include    <pause>

#if !defined IsValidVehicle
	native IsValidVehicle(vehicleid);
#endif

/////// MySQL ayarlar�
#define		MYSQL_HOST 				"localhost"
#define		MYSQL_HESAP 			"root"
#define		MYSQL_SIFRE 			""
#define		MYSQL_VERITABANI 		"copchase"
	new 	MySQL: CopSQL;

/////// Renkler
#define 	SUNUCU_RENK 			0x8B0000FF
#define 	SUNUCU_RENK2 			"{8B0000}"
#define     KIRMIZI             	0xD01717FF
#define     KIRMIZI2            	"{D01717}"
#define 	DONATOR_RENK			0xE15DC1FF
#define 	DONATOR_RENK2			"{E15DC1}"
#define     MAVI 	            	0x05B3FFFF
#define     MAVI2	            	"{05B3FF}"
#define     GRI             		0x8F8F8FFF
#define     GRI2             		"{8F8F8F}"
#define     BEYAZ              		0xFFFFFFFF
#define     BEYAZ2					"{FFFFFF}"
#define     BEYAZ3              	0xFFFFFF00
#define 	YESIL 					0x449C2DFF
#define     YESIL2					"{449C2D}"
#define     TURUNCU                 0xF96500FF
#define     TURUNCU2            	"{F96500}"
#define     YONETIM_RENK            0xD8AB3FFF
#define     YONETIM_RENK2           "{D8AB3F}"
#define     SUSPECT_RENK            0xEE1616FF
#define     SUSPECT_RENK2           0xEE161600
#define     POLIS_RENK          	0x767BA5FF
#define     POLIS_RENK2           	0x767BA500
#define     SARI                	0xF0D21DFF
#define     SARI2               	"{F0D21D}"
#define     SARI3               	0xF0D21D00
#define     KAPI_RENK             	0x647DA1FF
#define     KAPI_RENK2        		"{647DA1}"
#define		EMOTE_RENK          	0xC2A2DAFF
#define     CHAT_BELIRTME           0xAFAFAFFF
#define		EMOTE_RENK2          	"{C2A2DA}"
#define 	COLOR_ORANGE 			0xFF9500FF
#define 	COLOR_CLIENT      		(0xAAC4E5FF)
#define     DUEL_RENK               0x647DA1FF
#define     DUEL2               	"{647DA1}"
#define 	TELSIZ 					0xE28B2CFF
#define 	COLOR_GREY 				0xAFAFAFAA

/////// Pawno k�sayollar�
new 		fmesaj[400];
#define 	YollaIpucuMesaj(%0,%1) 			format(fmesaj, sizeof(fmesaj), %1) && 	IpucuMesajDefine(%0, fmesaj)
#define 	YollaDefaultMesaj(%0,%1) 		format(fmesaj, sizeof(fmesaj), %1) && 	DefaultMesajDefine(%0, fmesaj)
#define 	YollaKullanMesaj(%0,%1) 		format(fmesaj, sizeof(fmesaj), %1) && 	KullanMesajDefine(%0, fmesaj)
#define 	YollaHataMesaj(%0,%1)			format(fmesaj, sizeof(fmesaj), %1) && 	HataMesajDefine(%0, fmesaj)
#define 	YollaYoneticiMesaj(%0,%1,%2)	format(fmesaj, sizeof(fmesaj), %2) && 	YoneticiMesajDefine(%0, %1, fmesaj)
#define 	YollaHelperMesaj(%0,%1)			format(fmesaj, sizeof(fmesaj), %1) &&	HelperMesajDefine(%0, fmesaj)
#define 	YollaSoruMesaj(%0,%1)			format(fmesaj, sizeof(fmesaj), %1) &&	SoruMesajDefine(%0, fmesaj)
#define 	YollaFormatMesaj(%0,%1,%2) 		format(fmesaj, sizeof(fmesaj), %2) && 	SendClientMessage(%0, %1, fmesaj)
#define 	YollaHerkeseMesaj(%0,%1) 		format(fmesaj, sizeof(fmesaj), %1) && 	SendClientMessageToAll(%0, fmesaj)
#define 	PRESSED(%0) (((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))

/////// Timer S�releri
#define 	TIMER_SANIYE(%1)		(%1 * 1000)
#define 	TIMER_SANIYE_BUCUK(%1)	(%1 * 1500)
#define 	TIMER_DAKIKA(%1)		(%1 * 60000)

/////// Oyun modu ayarlar�
#define	 	SUNUCUKISALTMA			"SF-CC"
#define	 	SUNUCUADI				"[0.3-DL] - San Fierro Copchase"
#define	 	SUNUCUSIFRE    			""
#define	 	SUNUCUDIL	    		"Turkce"
#define	 	SUNUCUWEB	    		"www.sf-cc.ga"
#define	 	SUNUCUDISCORD	    	"discord.gg"
#define	 	MODADI	    			"SF:CC 1.0B2HF4"
#undef 		MAX_PLAYERS
#define 	MAX_PLAYERS 			50 // Maksimum 50 oyuncu, de�i�tirilemez
#define     BASLANGIC_POSX          246.375991
#define     BASLANGIC_POSY          109.245994
#define     BASLANGIC_POSZ          1003.218750
#define     BASLANGIC_POSA          0.0
#define 	MAX_ENGEL				100
#define 	OYUN_SANIYE				20 // oyunun ba�lamas� i�in max. saniye
#define 	OYUN_DAKIKA				8 // oyunun bitmesi i�in max. dakika

//// Hasar Sistemi
#define 	INVALID_WEAPON_ID		-1
#define 	MAX_DAMAGES				(MAX_PLAYERS * 20)

#define 	BODY_PART_CHEST			3
#define		BODY_PART_TORSO			4
#define		BODY_PART_LEFT_ARM		5
#define 	BODY_PART_RIGHT_ARM		6
#define		BODY_PART_LEFT_LEG		7
#define		BODY_PART_RIGHT_LEG		8
#define		BODY_PART_HEAD			9

//Tan�mlamalar
new Text:PublicTD[2];
new bool: Dmizin;

//Enumlar
enum Oyuncular
{
	SQLID,
    Cache: CacheID,
	OyuncuAdi[MAX_PLAYER_NAME],
	Yonetici,
	bool: Helper,
	Skor,
	Para,
	Medkit,
	Kiyafet[2],
	Sifre[65],
	IP[16],
	SSakla[17],
	PolisArac,
	bool: SuspectSari,
	bool: Suspect,
	bool: Polis,
	bool: PolisGPS,
	SusturDakika,
	SusturTimer,
	SuspectTimer,
	SuspectTimer2,
	SuspectTimer3,
	pKiyafet,
	sKiyafet,
	Olum,
	Oldurme,
	bool: DO_Yapiyor,
	DO_YaptigiID,
	DO_Timer,
	bool: Bisiklet,
	bool: AFK,
	bool: Oyunda,
	bool: Soru,
	bool: AracTamir,
	bool: RequestCar,
	bool: AracFlip,
	bool: AracNitro,
	Sorusu[120],
	bool: Rapor,
	Raporu[120],
	bool: Silah[7],
	bool: OyunSilah,
	SkorTimer,
	EngelHak,
	EngelSec,
	bool: TaserMermiDegis,
	bool: HedefKomut,
	bool: DM,
	bool: PMizin,
	bool: apm,
	bool: Taser,
	bool: Taserlendi,
	bool: Beanbag,
	bool: Beanbaglendi,
	DuzenleEngelID,
	bool: DuzenleEngel,
	bool: ElmDurum,
	bool: aduty,
	bool: aktifduel,
	bool: dueldavet,
	VW,
	Int,
	AracYanKoltuk,
	bool: Cbug,
	SWID,
	SWSeat,
	SWTimer,
	bool: pTopallama,
	TopallamaSure,
	DMArena,
	CbugSilah,
	CbugTimer,
	bool: Anim,
	HapisDakika,
	HapisTimer,
	SuspectKazanma,
	OyunModTimer,
	bool: Hud,
	bool: dmyetki,
	bool: dmizin,
	bool: OyunModu,
	bool: Donator,
	bool: ZirhHak,
	bool: FreezeDurumu,
	bool: IsimHak,
	Float: Pos[4],
	Text3D: ShotFired,
	bool: GirisYapti,
	GirisDenemeleri,
	SudaTimer,
	bool: SudanZatenAldi,
	PDLoadout1,
	PDLoadout2,
	PDLoadout3,
	FGLoadout1,
	FGLoadout2,
	FGLoadout3
};
new Oyuncu[MAX_PLAYERS][Oyuncular];

enum Yasaklar
{
	Yasaklanan[MAX_PLAYER_NAME],
	Yasaklayan[MAX_PLAYER_NAME],
	Sebep[MAX_PLAYER_NAME],
	Bitis,
	IslemTarih,
	YasakIP[16]
}
new Yasakla[MAX_PLAYERS][Yasaklar];

enum V_Arena
{
	ID,
	Kisi,
};
new Arena[3][V_Arena];

enum Engeller
{
	ID,
	AreaID,
	bool: Olusturuldu,
	SahipID,
	Tip,
	bool: Duzenleniyor,
	Model,
	Float: Pos[3],
	Text3D: Engel3D
}
new Engel[MAX_ENGEL][Engeller];
new MyPickup;
new MyPickup2;

// Dialog verileri
enum
{
	DIALOG_X,
	DIALOG_GIRIS,
	DIALOG_KAYIT,
	DIALOG_SUSPECTSKIN,
	DIALOG_PSKIN,
	DIALOG_PSKIN2,
	DIALOG_LOADOUT_COP,
	DIALOG_LOADOUT_FUGITIVE,
	DIALOG_LOADOUT_COP_PISTOL,
	DIALOG_LOADOUT_COP_RIFLE,
	DIALOG_LOADOUT_COP_HEAVYRIFLE,
	DIALOG_LOADOUT_FUGITIVE_PISTOL,
	DIALOG_LOADOUT_FUGITIVE_RIFLE,
	DIALOG_LOADOUT_FUGITIVE_HEAVYR,
	DIALOG_ARACDEGISTIR,
	DIALOG_DISIMDEGISTIR,
	DIALOG_DISIMDEGISTIR2,
	DIALOG_SWAPSEATS,
	DIALOG_BSILAHAL,
	DIALOG_OYUNMODU,
	DIALOG_MP3,
	RadioURL,
	ASILAHAL,
	TANITIM,
	TANITIM2,
	SKORYARDIM,
 	GIRIS2,
	DIALOG_HASARLAR
};

new Skinler[6][] =
{	// Suspect Skinleri
	{48, 109, 108, 110}, // El Corona 
	{276, 275, 274, 70}, // County General
	{117, 124, 125, 118}, // Mulholland
	{144, 72, 59, 7}, // Old Venturas
	{144, 72, 59, 7}, // Santa Flora
	{34, 59, 79, 128} // Tierra Robada
};

new engine, alarm, doors, lights, bonnet, boot, objective;
new engine2, alarm2, doors2, lights2, bonnet2, boot2, objective2;
new SuspectArac;
new CopArac[23];
new OyunArac[10];
new bool: Fdurum;
new FlasorTimer[MAX_VEHICLES];
new FlasorDurum[MAX_VEHICLES];
new Flasor[MAX_VEHICLES];
new AracKontrolTimer;
new AracSiren[MAX_VEHICLES];
new bool: AracSirenDurumu[MAX_VEHICLES];
new bool: AracHasar[MAX_VEHICLES];
new bool: AracYaratildi[MAX_VEHICLES];
new AracKilitSahip[MAX_VEHICLES];
new bool: EventModu;
new bool: EventModu2;
new OyunTimer;
new bool: OyunSayac;
new bool: SuspectAtes;
new bool: HerkesFreeze;
new OyunModuTip;
new OyunSebep[150];
new OyunKalanTimer;
new SuspectSaklaTimer;
new OyunDakika;
new bool: OyunBasladi;
new OyunSaniye;
new BankaOnKapi[2];
new BankaArkaKapi[2];
new PlayerText:Textdraw0[MAX_PLAYERS];
new PlayerText:Textdraw1[MAX_PLAYERS];
new g_MysqlRaceCheck[MAX_PLAYERS];

new PolisSkinler[13] =
{
	 280, 281, 282, 283, 284, 285, 288, 300, 301, 302, 306, 307, 311
};
new SupheliSkinler[263] =
{
	2, 3, 4, 5, 6, 7, 8, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29,
	30, 32, 33, 34, 35, 36, 37, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 57, 58, 59, 60,
	61, 62, 66, 68, 72, 73, 78, 79, 80, 81, 82, 83, 84, 94, 95, 96, 97, 98, 99, 100, 101, 102,
	103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120,
	121, 122, 123, 124, 125, 126, 127, 128, 132, 133, 134, 135, 136, 137, 142, 143, 144, 146,
	147, 153, 154, 155, 156, 158, 159, 160, 161, 162, 167, 168, 170, 171, 173, 174, 175, 176,
	177, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 200, 202, 203, 204, 206,
	208, 209, 210, 212, 213, 217, 220, 221, 222, 223, 228, 229, 230, 234, 235, 236, 239, 240,
	241, 242, 247, 248, 249, 250, 253, 254, 255, 258, 259, 260, 261, 262, 268, 272, 273, 289,
	290, 291, 292, 293, 294, 295, 296, 297, 299, 9, 10, 11, 12, 13, 31, 38, 39, 40, 41, 53, 54,
	55, 56, 63, 64, 65, 69, 75, 76, 77, 85, 88, 89, 90, 91, 92, 93, 129, 130, 131, 138, 140, 141,
    145, 148, 150, 151, 152, 157, 169, 178, 190, 191, 192, 193, 194, 195,
    196, 197, 198, 199, 201, 205, 207, 211, 214, 215, 216, 219, 224, 225,
    226, 231, 232, 233, 237, 238, 243, 244, 245, 246, 251, 256, 257, 263,
    298
};

#define 	MAX_DAMAGES				(MAX_PLAYERS * 20)
enum DAMAGE_DATA
{
	DamagePlayerID,
	DamageReason[25],
	DamageWeapon,
	DamageBodyPart,
	Float:DamageAmount
}
new DamageData[MAX_DAMAGES][DAMAGE_DATA], totalDamages = 0;

new RandomMSG[][] =
{
    ""YESIL2"["#SUNUCUKISALTMA"] "BEYAZ2"Oyun s�ras�nda �l�nce vakit ge�irmek i�in /dm veya /duel komutunu kullanabilirsin!",
    ""YESIL2"["#SUNUCUKISALTMA"] "BEYAZ2"/hesap komutu ile kullan�c� verilerini g�rebilirsin!",
    ""YESIL2"["#SUNUCUKISALTMA"] "BEYAZ2"/aksesuar komutu ile aksesuar takabilir ve d�zenleyebilirsin!",
    ""YESIL2"["#SUNUCUKISALTMA"] "BEYAZ2"/sorusor komutu ile bilmedi�in �eyleri ��renebilirsin!"
};


main()
{
	SendRconCommand("hostname "SUNUCUADI);
	SendRconCommand("password "SUNUCUSIFRE);
	SendRconCommand("language "SUNUCUDIL);
	SendRconCommand("weburl "SUNUCUWEB);
	printf("[S�STEM] Oyun modu '%s' ad�yla a��ld�.\n\n", SUNUCUADI);
}

forward YasakKontrol(playerid);
public YasakKontrol(playerid)
{
	new sorgu[150];
 	if(cache_num_rows())
  	{
    	new mesaj[500], mesajstr[500], yasaklanan[MAX_PLAYER_NAME], yasaklayan[MAX_PLAYER_NAME], sebep[25], bitis, islemtarih;
	    cache_get_value(0, "yasaklanan", yasaklanan, MAX_PLAYER_NAME);
		cache_get_value(0, "yasaklayan", yasaklayan, MAX_PLAYER_NAME);
	    cache_get_value(0, "sebep", sebep, MAX_PLAYER_NAME);
		cache_get_value_int(0, "bitis", bitis);
		cache_get_value_int(0, "islemtarih", islemtarih);
		if(bitis == 0)
	   	{
			format(mesaj, sizeof(mesaj), "\n"#SUNUCU_RENK2"S�resiz yasakland�n, yanl�� oldu�unu d���n�yorsan�z '"#BEYAZ2""#SUNUCUDISCORD""#SUNUCU_RENK2"' adresinde #probation kanal� �zerinden y�neticilere bildirin.");
			strcat(mesajstr, mesaj);
			format(mesaj, sizeof(mesaj), "\n\n"#SUNUCU_RENK2"Yasaklayan: "#BEYAZ2"%s\n"#SUNUCU_RENK2"Sebep: "#BEYAZ2"%s\n"#SUNUCU_RENK2"Tarih: "#BEYAZ2"%s", yasaklayan, sebep, Tarih(islemtarih));
			strcat(mesajstr, mesaj);
			ShowPlayerDialog(playerid, DIALOG_X, DIALOG_STYLE_MSGBOX, ""#SUNUCU_KISALTMA"", mesajstr, "Kapat", "");
			return Kickle(playerid);
		}
		if(bitis > gettime())
		{
			format(mesaj, sizeof(mesaj), "\n"#SUNUCU_RENK2"Yasakland�n, yanl�� oldu�unu d���n�yorsan�z '"#BEYAZ2""#SUNUCUDISCORD""#SUNUCU_RENK2"' adresinde #probation kanal� �zerinden y�neticilere bildirin.");
			strcat(mesajstr, mesaj);
			format(mesaj, sizeof(mesaj), "\n\n"#SUNUCU_RENK2"Yasaklayan: "#BEYAZ2"%s\n"#SUNUCU_RENK2"Sebep: "#BEYAZ2"%s\n"#SUNUCU_RENK2"Tarih: "#BEYAZ2"%s\n"#SUNUCU_RENK2"Biti� Tarihi: "#BEYAZ2"%s", yasaklayan, sebep, Tarih(islemtarih), Tarih(bitis));
			strcat(mesajstr, mesaj);
			ShowPlayerDialog(playerid, DIALOG_X, DIALOG_STYLE_MSGBOX, ""#SUNUCU_KISALTMA"", mesajstr, "Kapat", "");
			return Kickle(playerid);
		}
		else
		{
			mysql_format(CopSQL, sorgu, sizeof(sorgu), "DELETE FROM yasaklar WHERE yasaklanan = '%s'", yasaklanan);
			mysql_tquery(CopSQL, sorgu, "", "");
			mysql_format(CopSQL, sorgu, sizeof(sorgu), "SELECT * FROM hesaplar WHERE isim = '%s'", Oyuncuadi(playerid));
			mysql_tquery(CopSQL, sorgu, "OyuncuVeriYukle", "dd", playerid, g_MysqlRaceCheck[playerid]);
		}
	}
	else
	{
		mysql_format(CopSQL, sorgu, sizeof(sorgu), "SELECT * FROM hesaplar WHERE isim = '%s'", Oyuncuadi(playerid));
		mysql_tquery(CopSQL, sorgu, "OyuncuVeriYukle", "dd", playerid, g_MysqlRaceCheck[playerid]);
	}
	return 1;
}

forward OyuncuVeriYukle(playerid, race_check);
public OyuncuVeriYukle(playerid, race_check)
{
	if(race_check != g_MysqlRaceCheck[playerid]) return Kick(playerid);
	for(new i = 0; i < 50; i++) SendClientMessage(playerid, -1, " ");
	SetPlayerPos(playerid, 1525.2635, -1674.2241, 18.0518);
	SetPlayerVirtualWorld(playerid, 2);
	SetPlayerCameraPos(playerid, 1525.2635, -1674.2241, 18.8518);
	SetPlayerCameraLookAt(playerid, 1526.2628, -1674.2186, 18.8618);
	GetPlayerIp(playerid, Oyuncu[playerid][IP], 16);
	new string[115];
	if(cache_num_rows() > 0)
	{
     	OyuncuYukle(playerid);
		Oyuncu[playerid][CacheID] = cache_save();
		format(string, sizeof string, "%s adl� hesap kay�tl�, l�tfen �ifrenizi giriniz.", Oyuncu[playerid][OyuncuAdi]);
		ShowPlayerDialog(playerid, DIALOG_GIRIS, DIALOG_STYLE_PASSWORD, "Giri�", string, "Giri�", "��k��");
	}
	else
	{
		format(string, sizeof string, "%s adl� hesap kay�tl� de�il, �ifreni girerek kay�t olabilirsiniz.", Oyuncuadi(playerid));
		ShowPlayerDialog(playerid, DIALOG_KAYIT, DIALOG_STYLE_PASSWORD, "Kay�t", string, "Kay�t", "��k��");
	}
	return 1;
}

forward OyuncuYeniKayit(playerid);
public OyuncuYeniKayit(playerid)
{
	Oyuncu[playerid][SQLID] = cache_insert_id();
	ShowPlayerDialog(playerid, TANITIM, DIALOG_STYLE_MSGBOX, ""#SUNUCUKISALTMA" - TANITIM", "{FF0000}Oyun Modu\n{FFFFFF}Geri say�m�n bitmesinin ard�ndan oyuna kat�lan ki�i say�s�na g�re rastgele olacak �ekilde polisler ve ��pheliler olu�turulur. ��pheli arac�n s�r�c�s�ne [ROLEPLAY] - [NON-RP] �eklinde iki se�enek ��kar.\nSe�ti�iniz oyun tarz�na g�re oyun s�rd�r�l�r. Roleplay se�ti�inizde yine rastgele gelen b�l�me g�re olu�turulan senaryodan roleplay �eklinde devam ettirilir.\nSenaryolara alt b�l�mlerde g�z atabilirsiniz.\n NON-RP se�ti�iniz taktirde her �eyin serbest oldu�unu bilmeniz gerekli. Polislerin tek g�revi b�t�n ��phelileri etkisiz hale getirmektir.\n Bunu ��phelileri vurarak yada kelep�eleyerek yapabilirsiniz. ��phelilerin g�revi ise 8 dakika boyunca polislere yakalanmamakt�r. \nKendinize ve tak�m arkada�lar�n�za g�veniyorsan�z ister polislerle �at��abilir, isterseniz araban�z ile 8 dakika boyunca ka�abilirsiniz.", "�leri", "");
	YollaIpucuMesaj(playerid, "Tan�t�m� ge�erseniz oyundan at�l�rs�n�z.");
	Oyuncu[playerid][AFK] = true;
	YollaHerkeseMesaj(0x008000FF, "[B�LG�]"#BEYAZ2" %s sunucuya giri� yapt�.", Oyuncuadi(playerid));
	Oyuncu[playerid][SkorTimer] = SetTimerEx("OyuncuSkorVer", TIMER_DAKIKA(15), true, "d", playerid);
	Oyuncu[playerid][GirisYapti] = true;
	Oyuncu[playerid][AFK] = false;
	new sayi = random(22);
	sscanf(LobiKonum(sayi), "p<,>fff", Oyuncu[playerid][Pos][0], Oyuncu[playerid][Pos][1], Oyuncu[playerid][Pos][2]);
	Oyuncu[playerid][Kiyafet] = 280;
	SetSpawnInfo(playerid, 0, Oyuncu[playerid][Kiyafet], Oyuncu[playerid][Pos][0], Oyuncu[playerid][Pos][1], Oyuncu[playerid][Pos][2], Oyuncu[playerid][Pos][3], 0, 0, 0, 0, 0, 0);
	SpawnPlayer(playerid);
	SetPlayerSkin(playerid, Oyuncu[playerid][Kiyafet]);
	SetPlayerColor(playerid, BEYAZ3);
	SetPlayerVirtualWorld(playerid, 0);
	SetPlayerInterior(playerid, 10);
	SetCameraBehindPlayer(playerid);
	Oyuncu[playerid][Hud] = true;
	Baslat();
	PlayerTextDrawShow(playerid, Textdraw0[playerid]);
	PlayerTextDrawShow(playerid, Textdraw1[playerid]);
	return 1;
}

forward AracTamirEt(playerid, aracid);
public AracTamirEt(playerid, aracid)
{
	new Panels, Doors, Lights, Tires, Float: araccan;
	GetVehicleDamageStatus(aracid, Panels, Doors, Lights, Tires);
	GetVehicleHealth(aracid, araccan);
	if(araccan <= 850.0)
	{
		SetVehicleHealth(aracid, araccan+150.0);
	}
	AracHasar[aracid] = false;
	GetVehicleParamsEx(aracid, engine, lights, alarm, doors, bonnet, boot, objective);
	SetVehicleParamsEx(aracid, engine, lights, alarm, doors, VEHICLE_PARAMS_OFF, boot, objective);
	UpdateVehicleDamageStatus(aracid, Panels, Doors, Lights, 0);
	TogglePlayerControllable(playerid, 1);
	return 1;
}
/*
forward PingCheck(playerid);
public PingCheck(playerid)
{
    new string[256];
    new ping = GetPlayerPing(playerid);
    new playrname[MAX_PLAYER_NAME];
    GetPlayerName(playerid, playrname, sizeof(playrname));
    if(ping > 500)
    {
        format(string, sizeof(string), "\"%s\" sunucudan at�ld�. Sebep: (Y�ksek Ping) (Ping: %d  | Maximum: 500)", playrname, ping);
        SendClientMessageToAll(0xFFFF00FF, string);
        Kickle(playerid);
    }
}*/

forward SendMSG();
public SendMSG()
{
    new randMSG = random(sizeof(RandomMSG));
    SendClientMessageToAll(-1, RandomMSG[randMSG]);
}

forward AracSil(aracid);
public AracSil(aracid)
{
	return DestroyVehicle(aracid);
}

forward BugKontrol(playerid);
public BugKontrol(playerid)
{
	SetPlayerSkin(playerid, Oyuncu[playerid][Kiyafet]);
	TogglePlayerControllable(playerid, 1);
	return 1;
}

forward CBugFreeze(playerid);
public CBugFreeze(playerid)
{
	TogglePlayerControllable(playerid, 1);
	Oyuncu[playerid][Cbug] = false;
	return 1;
}

forward LobiyeDon(playerid);
public LobiyeDon(playerid)
{
	SetPlayerColor(playerid, BEYAZ3);
	new sayi = random(22);
	sscanf(LobiKonum(sayi), "p<,>fff", Oyuncu[playerid][Pos][0], Oyuncu[playerid][Pos][1], Oyuncu[playerid][Pos][2]);
	SetPlayerPos(playerid, Oyuncu[playerid][Pos][0], Oyuncu[playerid][Pos][1], Oyuncu[playerid][Pos][2]);
	SetPlayerFacingAngle(playerid, Oyuncu[playerid][Pos][3]);
	SetCameraBehindPlayer(playerid);
	SetPlayerHealth(playerid, 100.0);
	SetPlayerArmour(playerid, 0.0);
	SetPlayerVirtualWorld(playerid, 0);
	SetPlayerInterior(playerid, 10);
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
	ClearAnimations(playerid);
	ResetPlayerWeapons(playerid);
	Oyuncu[playerid][ZirhHak] = Oyuncu[playerid][Oyunda] = Oyuncu[playerid][DM] = Oyuncu[playerid][Suspect] = false;
	Oyuncu[playerid][Polis] = Oyuncu[playerid][aktifduel] = Oyuncu[playerid][SuspectSari] = false;
	SetTimerEx("BugKontrol", 500, false, "d", playerid);
}

forward PolisSilah(playerid);
public PolisSilah(playerid)
{
	if(OyunBasladi == true && Oyuncu[playerid][Oyunda] == true)
	{
		Oyuncu[playerid][OyunSilah] = false;
		GivePlayerWeapon(playerid, 24, 500);
		SetPlayerArmedWeapon(playerid, 0);
	}
	return 1;
}

forward Flas(aracid);
public Flas(aracid)
{
	if(Flasor[aracid] == 1)
	{
 		new panelsx, doorsx, lightsx, tiresx;
	    if(FlasorDurum[aracid] == 1)
	    {
	        GetVehicleDamageStatus(aracid, panelsx, doorsx, lightsx, tiresx);
	        UpdateVehicleDamageStatus(aracid, panelsx, doorsx, 4, tiresx);
	        FlasorDurum[aracid] = 0;
	    }
	    else
	    {
	        GetVehicleDamageStatus(aracid, panelsx, doorsx, lightsx, tiresx);
	        UpdateVehicleDamageStatus(aracid, panelsx, doorsx, 1, tiresx);
	        FlasorDurum[aracid] = 1;
	    }
	}
	return 1;
}

forward Baslat();
public Baslat()
{
	if(OyuncuSayisi() > 1 && OyunBasladi == false && OyunSayac == false)
	{
		OyunSayac = true;
		OyunSaniye = OYUN_SANIYE;
		if(EventModu == true)
		{
			OyunTimer = SetTimer("OyunEvent", TIMER_SANIYE(1), true);
			return 1;
		}
		if(EventModu2 == true)
		{
			OyunTimer = SetTimer("OyunEvent2", TIMER_SANIYE(1), true);
			return 1;
		}
		new tur = random(6);
		OyunTimer = SetTimerEx("OyunBasliyor", TIMER_SANIYE(1), true, "d", tur);
	}
	return 1;
}

forward OyunKalanSure(playerid);
public OyunKalanSure(playerid)
{
	OyunDakika--;
	OyunKontrol();
	return 1;
}

forward OyuncuSustur(playerid);
public OyuncuSustur(playerid)
{
	Oyuncu[playerid][SusturDakika]--;
	if(Oyuncu[playerid][SusturDakika] <= 0)
	{
		Oyuncu[playerid][SusturDakika] = 0;
		KillTimer(Oyuncu[playerid][SusturTimer]);
		YollaIpucuMesaj(playerid, "Susturman�n s�resi bitti art�k konu�abilirsin.");
	}
	return 1;
}

forward OyuncuHapis(playerid);
public OyuncuHapis(playerid)
{
	Oyuncu[playerid][HapisDakika]--;
	if(Oyuncu[playerid][HapisDakika] <= 0)
	{
		Oyuncu[playerid][HapisDakika] = 0;
		Oyuncu[playerid][AFK] = false;
		YollaIpucuMesaj(playerid, "Hapis s�resi bitti.");
		LobiyeDon(playerid);
		KillTimer(Oyuncu[playerid][HapisTimer]);
	}
	return 1;
}

forward OyunModuTimer(playerid);
public OyunModuTimer(playerid)
{
	if(OyunBasladi == true && Oyuncu[playerid][Oyunda] == true && Oyuncu[playerid][OyunModu] == true)
	{
		YollaHerkeseMesaj(0xD01717FF, "[B�LG�]"#BEYAZ2" %s adl� oyuncu 10 saniye boyunca mod se�imi yapmad��� i�in AFK sebebiyle at�ld�.", Oyuncuadi(playerid));
		Kickle(playerid);
		foreach(new i : Player)
		{
			if(Oyuncu[i][GirisYapti] == true && Oyuncu[i][Oyunda] == true)
			{
				SetPlayerPos(i, Oyuncu[i][Pos][0], Oyuncu[i][Pos][1], Oyuncu[i][Pos][2]);
				SetPlayerFacingAngle(i, Oyuncu[i][Pos][3]);
				SetCameraBehindPlayer(i);
				SetPlayerColor(i, BEYAZ3);
				SetPlayerVirtualWorld(i, 0);
				SetPlayerInterior(i, 10);
				Oyuncu[i][Oyunda] = Oyuncu[i][Suspect] = Oyuncu[i][SuspectSari] = Oyuncu[i][Polis] = false;
				ResetPlayerWeapons(i);
				TogglePlayerControllable(i, 1);
			}
		}
		for(new j = 1, i = GetVehiclePoolSize(); j <= i; j++)
		{
			DestroyVehicle(j);
		}
		OyunSaniye = OYUN_SANIYE;
		OyunBasladi = OyunSayac = false;
		OyunDakika = OYUN_DAKIKA;
		KillTimer(SuspectSaklaTimer);
		KillTimer(OyunKalanTimer);
		Baslat();
		YollaHerkeseMesaj(0x008000FF, "[B�LG�]"#BEYAZ2" Sistem taraf�ndan oyun yeniden ba�lat�l�yor.");
	}
	return 1;
}

TekSayiKontrol(sayi)
{
	return sayi % 2;
}

forward OyunEvent();
public OyunEvent()
{
	if(OyunSaniye <= 10)
	{
		foreach(new i : Player)
    	{
	        if(Oyuncu[i][Oyunda] == false && Oyuncu[i][GirisYapti] == true && Oyuncu[i][AFK] == false && Oyuncu[i][DM] == true)
	        {
	        	YollaIpucuMesaj(i, "Oyun birazdan ba�layaca�� i�in lobiye spawnland�n!");
	        	LobiyeDon(i);
	        }
	    }
	}
	new mesaj[50];
	format(mesaj, sizeof(mesaj), "~w~Oyun baslamasina %d", OyunSaniye);
	OyunSaniye--;
	GameTextForAll(mesaj, 1000, 4);
	if(OyuncuSayisi() < 2)
	{
		OyunSaniye = OYUN_SANIYE;
		OyunDakika = OYUN_DAKIKA;
		OyunBasladi = OyunSayac = false;
		KillTimer(OyunTimer);
		return 1;
	}

	if(OyunSaniye == 0)
	{
		OyunBasladi = true;
		OyunModuTip = 0;
		new oyuncusayi = OyuncuSayisi(), suspect[50], yukle = 0;
		SelectRandomPlayers(suspect, 25);
		if(TekSayiKontrol(oyuncusayi))
			oyuncusayi += random(2);

		new deneme = oyuncusayi / 2;
		foreach(new i : Player)
		{
			if(Oyuncu[i][GirisYapti] == true && Oyuncu[i][AFK] == false && Oyuncu[i][Suspect] == false)
			{
				if(deneme == yukle)
				{
					break;
				}
				foreach(new j : Player)
				{
					if(Oyuncu[j][GirisYapti] == true && Oyuncu[j][AFK] == false)
					{
						if(suspect[j] == i && Oyuncu[i][Suspect] == false)
						{
							Oyuncu[i][Suspect] = Oyuncu[i][Oyunda] = true;
							Oyuncu[i][Polis] = false;
							SetPlayerPos(i, -2809.8767, -1539.6384, 139.3850);
							SetPlayerFacingAngle(i, 32.0);
							if(Oyuncu[i][Donator] == true)
								GivePlayerWeapon(i, 35, 1);

							GivePlayerWeapon(i, 24, 500);
							GivePlayerWeapon(i, 30, 500);
							SetPlayerSkin(i, 25);
							SetPlayerInterior(i, 0);
							SetPlayerVirtualWorld(i, 0);
							SetCameraBehindPlayer(i);
							yukle++;
						}
					}
				}
			}
		}
		foreach(new i : Player)
		{
			if(Oyuncu[i][GirisYapti] == true && Oyuncu[i][AFK] == false && Oyuncu[i][Suspect] == false)
			{
				Oyuncu[i][Polis] = Oyuncu[i][Oyunda] = true;
				Oyuncu[i][Suspect] = false;
				SetPlayerPos(i, -2815.9026, -1695.2655, 141.5735);
				SetPlayerFacingAngle(i, 104.0);
				SetPlayerSkin(i, 285);
				SetPlayerInterior(i, 0);
				SetPlayerVirtualWorld(i, 0);
				if(Oyuncu[i][Donator] == true)
					GivePlayerWeapon(i, 34, 10);
				GivePlayerWeapon(i, 24, 500);
				GivePlayerWeapon(i, 31, 500);
				SetCameraBehindPlayer(i);
			}
		}
		SetTimer("OyunRenkleriDuzelt", TIMER_SANIYE(1), false);
		OyunDakika = OYUN_DAKIKA;
		KillTimer(OyunTimer);
		return 1;
	}
	return 1;
}

forward OyunEvent2();
public OyunEvent2()
{
	if(OyunSaniye <= 10)
	{
		foreach(new i : Player)
    	{
	        if(Oyuncu[i][Oyunda] == false && Oyuncu[i][GirisYapti] == true && Oyuncu[i][AFK] == false && Oyuncu[i][DM] == true)
	        {
	        	YollaIpucuMesaj(i, "Oyun birazdan ba�layaca�� i�in lobiye spawnland�n!");
	        	LobiyeDon(i);
	        }
	    }
	}
	new mesaj[50];
	format(mesaj, sizeof(mesaj), "~w~Oyun baslamasina %d", OyunSaniye);
	OyunSaniye--;
	GameTextForAll(mesaj, 1000, 4);
	if(OyuncuSayisi() < 2)
	{
		OyunSaniye = OYUN_SANIYE;
		OyunDakika = OYUN_DAKIKA;
		OyunBasladi = OyunSayac = false;
		KillTimer(OyunTimer);
		return 1;
	}

	if(OyunSaniye == 0)
	{
		OyunBasladi = true;
		OyunModuTip = 0;
		new oyuncusayi = OyuncuSayisi(), suspect[50], yukle = 0;
		SelectRandomPlayers(suspect, 25);
		if(TekSayiKontrol(oyuncusayi))
			oyuncusayi += random(2);

		new deneme = oyuncusayi / 2, Float: pos[3];
		foreach(new i : Player)
		{
			if(Oyuncu[i][GirisYapti] == true && Oyuncu[i][AFK] == false && Oyuncu[i][Suspect] == false)
			{
				if(deneme == yukle)
				{
					break;
				}
				foreach(new j : Player)
				{
					if(Oyuncu[j][GirisYapti] == true && Oyuncu[j][AFK] == false)
					{
						if(suspect[j] == i && Oyuncu[i][Suspect] == false)
						{
							Oyuncu[i][Suspect] = Oyuncu[i][Oyunda] = true;
							Oyuncu[i][Polis] = false;
							sscanf(Event2Konum(yukle, 1), "p<,>fff", pos[0], pos[1], pos[2]);
							SetPlayerPos(i, pos[0], pos[1], pos[2]);
							SetPlayerFacingAngle(i, 260.0);
							if(Oyuncu[i][Donator] == true)
								GivePlayerWeapon(i, 35, 1);

							GivePlayerWeapon(i, 24, 500);
							GivePlayerWeapon(i, 30, 500);
							SetPlayerSkin(i, 29);
							SetPlayerInterior(i, 0);
							SetPlayerVirtualWorld(i, 0);
							SetCameraBehindPlayer(i);
							yukle++;
						}
					}
				}
			}
		}
		foreach(new i : Player)
		{
			if(Oyuncu[i][GirisYapti] == true && Oyuncu[i][AFK] == false && Oyuncu[i][Suspect] == false)
			{
				Oyuncu[i][Polis] = Oyuncu[i][Oyunda] = true;
				Oyuncu[i][Suspect] = false;
				sscanf(Event2Konum(yukle, 0), "p<,>fff", pos[0], pos[1], pos[2]);
				SetPlayerPos(i, pos[0], pos[1], pos[2]);
				SetPlayerFacingAngle(i, 266.1480);
				SetPlayerSkin(i, 285);
				SetPlayerInterior(i, 0);
				SetPlayerVirtualWorld(i, 0);
				if(Oyuncu[i][Donator] == true)
					GivePlayerWeapon(i, 34, 10);
				GivePlayerWeapon(i, 24, 500);
				GivePlayerWeapon(i, 31, 500);
				SetCameraBehindPlayer(i);
			}
		}

		BankaOnKapi[0] = CreatePickup(1239, 1, 2303.5789, -68.7443, 26.4844); // giri�
		BankaOnKapi[1] = CreatePickup(1239, 1, 2316.6118, -70.3218, 26.4844); // ��k��
		BankaArkaKapi[0] = CreatePickup(1239, 1, 2305.5483, -16.0880, 26.7496); // giri�
		BankaArkaKapi[1] = CreatePickup(1239, 1, 2315.7178, 0.3387, 26.7422); // ��k��

		SetTimer("OyunRenkleriDuzelt", TIMER_SANIYE(1), false);
		OyunDakika = OYUN_DAKIKA;
		KillTimer(OyunTimer);
		return 1;
	}
	return 1;
}

forward AracKontrol();
public AracKontrol()
{
	if(OyunBasladi == false)
		KillTimer(AracKontrolTimer);
	for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
  	{
	    if(IsPlayerInAnyVehicle(i) && Oyuncu[i][GirisYapti] == true && Oyuncu[i][Oyunda] == true)
	    {
	        new Float: can;
	        new aracid = GetPlayerVehicleID(i);
		    GetVehicleParamsEx(aracid, engine, lights, alarm, doors, bonnet, boot, objective);
	        GetVehicleHealth(aracid, can);
	        if(can < 250.0)
	        {
	        	AracHasar[aracid] = true;
	        	SetVehicleHealth(aracid, 251.0);
				TogglePlayerControllable(i, false);
				GameTextForPlayer(i, "~r~ARAC HASARLI", 2000, 4);
		        RemovePlayerFromVehicle(i);
				SetVehicleParamsEx(aracid, 0, 0, alarm, doors, bonnet, boot, objective);
				TogglePlayerControllable(i, true);
	        }
	    }
	}
	return 1;
}

forward SuspectSilahVer(suspect);
public SuspectSilahVer(suspect)
{
	if(OyunBasladi == true && Oyuncu[suspect][Oyunda] == true)
	{
		GivePlayerWeapon(suspect, 24, 500);
		GivePlayerWeapon(suspect, 30, 500);
		if(GetPlayerState(suspect) == PLAYER_STATE_DRIVER)
			SetPlayerArmedWeapon(suspect, 0);
		if(GetPlayerState(suspect) == PLAYER_STATE_PASSENGER)
		{
		    if(GetPlayerWeapon(suspect) == 24)
				SetPlayerArmedWeapon(suspect, 0);
		}
	}
	return 1;
}

forward SuspectSakla(suspect);
public SuspectSakla(suspect)
{
	if(OyunBasladi == true && Oyuncu[suspect][Oyunda] == true)
	{
		if(Oyuncu[suspect][Suspect] == true)
			SetPlayerColor(suspect, SUSPECT_RENK2);
	}
	return 1;
}

forward SuspectCCTV();
public SuspectCCTV()
{
	new oyunpolissayi = OyunPolisSayi(), oyunsuspectsayi = OyunSuspectSayi();
	if((oyunsuspectsayi <= 0 && oyunpolissayi <= 0) || OyunDakika <= 1)
		return 1;
	if(OyunBasladi == true && oyunsuspectsayi >= 1)
	{
		new mesaj[160], bolge2[30], bolge[4][30], sayi = 0;

		for(new i; i < oyunsuspectsayi; i++)
		{
			if(Oyuncu[i][Suspect] == true)
			{
				if(Oyuncu[i][SuspectSari] == false)
				{
					SetPlayerColor(i, SUSPECT_RENK);
					SetTimerEx("SuspectSakla", TIMER_SANIYE(25), false, "d", i);
				}
				GetPlayer3DZone(i, bolge2, sizeof(bolge2));
				format(bolge[sayi], 30, "%s", bolge2);
				sayi++;
			}
		}

		if(sayi == 0)
			return 1;

		switch(sayi)
		{
			case 1: format(mesaj, sizeof(mesaj), "[CCTV] Aranan ��pheli %s b�lgesinde g�r�ld�!", bolge[0]);
			case 2:
			{
				if(strcmp(bolge[0], bolge[1], true) == 0)
					format(mesaj, sizeof(mesaj), "[CCTV] Aranan ��pheliler %s b�lgesinde g�r�ld�!", bolge[0]);
				else
					format(mesaj, sizeof(mesaj), "[CCTV] Aranan ��pheliler %s ve %s b�lgesinde g�r�ld�!", bolge[0], bolge[1]);
			}
			case 3:
			{
				if(strcmp(bolge[0], bolge[1], true) == 0 && strcmp(bolge[1], bolge[2], true) == 0)
					format(mesaj, sizeof(mesaj), "[CCTV] Aranan ��pheliler %s b�lgesinde g�r�ld�!", bolge[0]);
				else
					format(mesaj, sizeof(mesaj), "[CCTV] Aranan ��pheliler %s, %s ve %s b�lgesinde g�r�ld�!", bolge[0], bolge[1], bolge[2]);
			}
			case 4:
			{
				if(strcmp(bolge[0], bolge[1], true) == 0 && strcmp(bolge[1], bolge[2], true) == 0 && strcmp(bolge[2], bolge[3], true) == 0)
					format(mesaj, sizeof(mesaj), "[CCTV] Aranan ��pheliler %s b�lgesinde g�r�ld�!", bolge[0]);
				else
					format(mesaj, sizeof(mesaj), "[CCTV] Aranan ��pheliler %s, %s, %s ve %s b�lgesinde g�r�ld�!", bolge[0], bolge[1], bolge[2], bolge[3]);
			}
		}
		PolisTelsiz(mesaj);
	}
	return 1;
}

forward Float:GetDistancePlayerToVehicle(playerid, vehicleid);
public Float:GetDistancePlayerToVehicle(playerid, vehicleid)
{
	new Float:x1, Float:y1, Float:z1, Float:x2, Float:y2, Float:z2;
    GetPlayerPos(playerid, x1, y1, z1);
	GetVehiclePos(vehicleid, x2, y2, z2);
    return floatsqroot( ( ( x1 - x2 ) * ( x1 - x2 ) ) + ( ( y1 - y2 ) * ( y1 - y2 ) ) + ( ( z1 - z2 ) * ( z1 - z2 ) ) );
}

forward OyunKontrol();
public OyunKontrol()
{
	if(OyunBasladi == true)
	{
		new oyunpolissayi = OyunPolisSayi(), oyunsuspectsayi = OyunSuspectSayi();
		if(oyunsuspectsayi <= 0 && oyunpolissayi <= 0)
		{
			for(new i = 1; i < MAX_ENGEL; ++i)
			{
				if(Engel[i][Olusturuldu] == true)
				{
					DestroyDynamicObject(Engel[i][ID]);
					DestroyDynamic3DTextLabel(Engel[i][Engel3D]);
					if(IsValidDynamicArea(Engel[i][AreaID]))
						DestroyDynamicArea(Engel[i][AreaID]);
					Engel[i][Engel3D] = Text3D: INVALID_3DTEXT_ID;
					Engel[i][Pos][0] = Engel[i][Pos][1] = Engel[i][Pos][2] = 0.0;
					Engel[i][Duzenleniyor] = Engel[i][Olusturuldu] = false;
					Engel[i][SahipID] = -1;
				}
			}
			for(new j = 1, i = GetVehiclePoolSize(); j <= i; j++)
			{
				Flasor[j] = 0;
				KillTimer(FlasorTimer[j]);
				DestroyVehicle(j);
			}
			for(new i; i < 2; i++)
			{
				DestroyPickup(BankaOnKapi[i]);
				DestroyPickup(BankaArkaKapi[i]);
			}
			OyunSaniye = OYUN_SANIYE;
			OyunBasladi = EventModu = EventModu2 = OyunSayac = false;
			OyunDakika = OYUN_DAKIKA;
			KillTimer(SuspectSaklaTimer);
			KillTimer(OyunKalanTimer);
			SetTimer("Baslat", TIMER_SANIYE(5), false);
			return 1;
		}
		if(oyunsuspectsayi <= 0)
		{
			for(new i = 1; i < MAX_ENGEL; ++i)
			{
				if(Engel[i][Olusturuldu] == true)
				{
					DestroyDynamicObject(Engel[i][ID]);
					DestroyDynamic3DTextLabel(Engel[i][Engel3D]);
					if(IsValidDynamicArea(Engel[i][AreaID]))
						DestroyDynamicArea(Engel[i][AreaID]);
					Engel[i][Engel3D] = Text3D: INVALID_3DTEXT_ID;
					Engel[i][Pos][0] = Engel[i][Pos][1] = Engel[i][Pos][2] = 0.0;
					Engel[i][Duzenleniyor] = Engel[i][Olusturuldu] = false;
					Engel[i][SahipID] = -1;
				}
			}
			foreach(new i : Player)
			{
				if(GetPlayerState(i) == PLAYER_STATE_SPECTATING)
				{
					TogglePlayerSpectating(i, 0);
					LobiyeDon(i);
				}
				if(Oyuncu[i][GirisYapti] == true && Oyuncu[i][Oyunda] == true)
				{
					if(Oyuncu[i][Polis] == true)
					{
						if(Oyuncu[i][Donator] == true)
							SkorVer(i, 4);
						else
							SkorVer(i, 2);
					}
					SetTimerEx("LobiyeDon", TIMER_SANIYE(1), false, "d", i);
					KillTimer(Oyuncu[i][SuspectTimer2]);
					KillTimer(Oyuncu[i][SuspectTimer3]);
				}
			}
			for(new j = 1, i = GetVehiclePoolSize(); j <= i; j++)
			{
				Flasor[j] = 0;
				KillTimer(FlasorTimer[j]);
				DestroyVehicle(j);
			}
			for(new i; i < 2; i++)
			{
				DestroyPickup(BankaOnKapi[i]);
				DestroyPickup(BankaArkaKapi[i]);
			}
			OyunSaniye = OYUN_SANIYE;
			OyunBasladi = EventModu = EventModu2 = OyunSayac = false;
			OyunDakika = OYUN_DAKIKA;
			KillTimer(SuspectSaklaTimer);
			KillTimer(OyunKalanTimer);
			SetTimer("Baslat", TIMER_SANIYE(5), false);
			YollaHerkeseMesaj(0x008000FF, "[B�LG�]"#BEYAZ2" Oyunu polisler kazand�.");
			return 1;
		}
		if(oyunpolissayi <= 0)
		{
			for(new i = 1; i < MAX_ENGEL; ++i)
			{
				if(Engel[i][Olusturuldu] == true)
				{
					DestroyDynamicObject(Engel[i][ID]);
					DestroyDynamic3DTextLabel(Engel[i][Engel3D]);
					if(IsValidDynamicArea(Engel[i][AreaID]))
						DestroyDynamicArea(Engel[i][AreaID]);
					Engel[i][Engel3D] = Text3D: INVALID_3DTEXT_ID;
					Engel[i][Pos][0] = Engel[i][Pos][1] = Engel[i][Pos][2] = 0.0;
					Engel[i][Duzenleniyor] = Engel[i][Olusturuldu] = false;
					Engel[i][SahipID] = -1;
				}
			}
			foreach(new i : Player)
			{
				if(GetPlayerState(i) == PLAYER_STATE_SPECTATING)
				{
					TogglePlayerSpectating(i, 0);
					LobiyeDon(i);
				}
				if(Oyuncu[i][GirisYapti] == true && Oyuncu[i][Oyunda] == true)
				{
					if(Oyuncu[i][Suspect] == true)
					{
						if(Oyuncu[i][Donator] == true)
							SkorVer(i, 8);
						else
							SkorVer(i, 5);
						Oyuncu[i][SuspectKazanma]++;
					}
					SetTimerEx("LobiyeDon", TIMER_SANIYE(1), false, "d", i);
					KillTimer(Oyuncu[i][SuspectTimer2]);
					KillTimer(Oyuncu[i][SuspectTimer3]);
				}
			}
			for(new j = 1, i = GetVehiclePoolSize(); j <= i; j++)
			{
				Flasor[j] = 0;
				KillTimer(FlasorTimer[j]);
				DestroyVehicle(j);
			}
			for(new i; i < 2; i++)
			{
				DestroyPickup(BankaOnKapi[i]);
				DestroyPickup(BankaArkaKapi[i]);
			}
			OyunSaniye = OYUN_SANIYE;
			OyunBasladi = EventModu = EventModu2 = OyunSayac = false;
			OyunDakika = OYUN_DAKIKA;
			KillTimer(SuspectSaklaTimer);
			KillTimer(OyunKalanTimer);
			SetTimer("Baslat", TIMER_SANIYE(5), false);
			YollaHerkeseMesaj(0x008000FF, "[B�LG�]"#BEYAZ2" Oyunu suspectler kazand�.");
			return 1;
		}
		if(OyunDakika <= 0)
		{
			for(new i = 1; i < MAX_ENGEL; ++i)
			{
				if(Engel[i][Olusturuldu] == true)
				{
					DestroyDynamicObject(Engel[i][ID]);
					DestroyDynamic3DTextLabel(Engel[i][Engel3D]);
					if(IsValidDynamicArea(Engel[i][AreaID]))
						DestroyDynamicArea(Engel[i][AreaID]);
					Engel[i][Engel3D] = Text3D: INVALID_3DTEXT_ID;
					Engel[i][Pos][0] = Engel[i][Pos][1] = Engel[i][Pos][2] = 0.0;
					Engel[i][Duzenleniyor] = Engel[i][Olusturuldu] = false;
					Engel[i][SahipID] = -1;
				}
			}
			foreach(new i : Player)
			{
				if(GetPlayerState(i) == PLAYER_STATE_SPECTATING)
				{
					TogglePlayerSpectating(i, 0);
					LobiyeDon(i);
				}
				if(Oyuncu[i][GirisYapti] == true && Oyuncu[i][Oyunda] == true)
				{
					if(Oyuncu[i][Suspect] == true)
					{
						if(Oyuncu[i][Donator] == true)
							SkorVer(i, 8);
						else
							SkorVer(i, 5);
						Oyuncu[i][SuspectKazanma]++;
					}
					SetTimerEx("LobiyeDon", TIMER_SANIYE(1), false, "d", i);
					KillTimer(Oyuncu[i][SuspectTimer2]);
					KillTimer(Oyuncu[i][SuspectTimer3]);
				}
			}
			for(new j = 1, i = GetVehiclePoolSize(); j <= i; j++)
			{
				DestroyVehicle(j);
			}
			for(new i; i < 2; i++)
			{
				DestroyPickup(BankaOnKapi[i]);
				DestroyPickup(BankaArkaKapi[i]);
			}
			OyunSaniye = OYUN_SANIYE;
			OyunBasladi = OyunSayac = EventModu = EventModu2 = false;
			OyunDakika = OYUN_DAKIKA;
			KillTimer(SuspectSaklaTimer);
			KillTimer(OyunKalanTimer);
			SetTimer("Baslat", TIMER_SANIYE(5), false);
			YollaHerkeseMesaj(0x008000FF, "[B�LG�]"#BEYAZ2" Oyun s�resi doldu, ��pheliler kazand�.");
			return 1;			
		}
	}
	return 1;
}

forward FreezeCoz(playerid);
public FreezeCoz(playerid)
{
	if(Oyuncu[playerid][Suspect] == false)
		return 1;

	Oyuncu[playerid][Taserlendi] = false;
	Oyuncu[playerid][Beanbaglendi] = false;
	TogglePlayerControllable(playerid, 1);
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
	ClearAnimations(playerid);
	return 1;
}

forward OyuncuSkorVer(playerid);
public OyuncuSkorVer(playerid)
{
	new mesaj[30], miktar;
	miktar = 2;
	if(Oyuncu[playerid][Donator] == true)
		miktar = 5;
	format(mesaj, sizeof(mesaj), "~g~+%d", miktar);
	GameTextForPlayer(playerid, mesaj, 3000, 1);
	Oyuncu[playerid][Skor] += miktar;
	SetPlayerScore(playerid, Oyuncu[playerid][Skor]);
	YollaIpucuMesaj(playerid, "15 dakikad�r oyunda oldu�unuz i�in bir miktar skor kazand�n�z!");
	OyuncuGuncelle(playerid);
}

forward KickleSure(playerid);
public KickleSure(playerid)
{
	Kick(playerid);
	return 1;
}

Kickle(playerid, time = 500)
{
	SetTimerEx("KickleSure", time, false, "d", playerid);
	return 1;
}

ProxDetector(Float: mesafe, playerid, const mesaj[], renk)
{
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    foreach(new i : Player)
    {
        if(IsPlayerInRangeOfPoint(i, mesafe, x, y, z) && Oyuncu[i][GirisYapti] == true)
        {
            SendClientMessage(i, renk, mesaj);
        }
    }
}

ProxDetectorLobi(const mesaj[], renk)
{
    foreach(new i : Player)
    {
        if(Oyuncu[i][Oyunda] == false && Oyuncu[i][GirisYapti] == true)
        {
            SendClientMessage(i, renk, mesaj);
        }
    }
}

ProxDetectorOyun(const mesaj[], renk)
{
    foreach(new i : Player)
    {
        if(Oyuncu[i][Oyunda] == true && Oyuncu[i][GirisYapti] == true)
        {
            SendClientMessage(i, renk, mesaj);
        }
    }
}

EngelYakin(playerid)
{
	for(new engelid = 1; engelid < MAX_ENGEL; engelid++)
	{
	    if(Engel[engelid][Olusturuldu] == true && Engel[engelid][Tip] == 1 && IsPlayerInRangeOfPoint(playerid, 4.0, Engel[engelid][Pos][0], Engel[engelid][Pos][1], Engel[engelid][Pos][2]))
	    {
	        return engelid;
		}
	}
	return -1;
}

OyuncuSayisi()
{
	new oyuncusayi;
	foreach(new i : Player)
	{
		if(Oyuncu[i][GirisYapti] == true && Oyuncu[i][AFK] == false)
			oyuncusayi++;
	}
	return oyuncusayi;
}

SkorVer(playerid, miktar)
{
	new mesaj[30];
	if(miktar <= 0)
		format(mesaj, sizeof(mesaj), "~r~%d", miktar);
	else
		format(mesaj, sizeof(mesaj), "~g~+%d", miktar);
	GameTextForPlayer(playerid, mesaj, 3000, 1);
	Oyuncu[playerid][Skor] += miktar;
	SetPlayerScore(playerid, Oyuncu[playerid][Skor]);
	OyuncuGuncelle(playerid);
}

SkorVer2(playerid, miktar)
{
	new mesaj[30];
	if(miktar <= 0)
		format(mesaj, sizeof(mesaj), "~r~%d", miktar);
	else
		format(mesaj, sizeof(mesaj), "~g~+%d", miktar);
	Oyuncu[playerid][Skor] -= miktar;
	SetPlayerScore(playerid, Oyuncu[playerid][Skor]);
	OyuncuGuncelle(playerid);
}

SkorVerPolis(playerid, miktar)
{
	new mesaj[30];
	if(miktar <= 0)
		format(mesaj, sizeof(mesaj), "~r~%d", miktar);
	else
		format(mesaj, sizeof(mesaj), "~g~+%d", miktar);
	if(Oyuncu[playerid][Polis] == true)
	{
		Oyuncu[playerid][Skor] += miktar;
		SetPlayerScore(playerid, Oyuncu[playerid][Skor]);
		OyuncuGuncelle(playerid);
    }
}

LobiKonum(sayi)
{
	new konum[100];
	switch(sayi)
	{
		case 0: konum = "215.4709, 118.7441, 1003.2188";
		case 1: konum = "215.3861, 125.8334, 1003.2188"; 
		case 2: konum = "221.0941, 108.0906, 1003.2188"; 
		case 3: konum = "228.6524, 109.6527, 1003.2188"; 
		case 4: konum = "233.2130, 125.8823, 1003.2188";
		case 5: konum = "237.9346, 108.3780, 1003.2257";
		case 6: konum = "242.6455, 108.3418, 1003.2188";
		case 7: konum = "251.2015, 118.2985, 1003.2188";
		case 8: konum = "241.8130, 125.9939, 1003.2188";
		case 9: konum = "276.7540, 125.9373, 1004.6172";
		case 10: konum = "272.3663, 117.9959, 1004.6172";
		case 11: konum = "277.2069, 111.0254, 1004.6172";
		case 12: konum = "265.9143, 108.5897, 1004.6172";
		case 13: konum = "276.8078, 125.5859, 1008.8203";
		case 14: konum = "276.6935, 114.4686, 1008.8130";
		case 15: konum = "260.5240, 111.5504, 1008.8203";
		case 16: konum = "257.0615, 119.6802, 1008.8130";
		case 17: konum = "247.4724, 121.3852, 1010.2188";
		case 18: konum = "230.8337, 126.8253, 1010.2188";
		case 19: konum = "222.7090, 108.5362, 1010.2188";
		case 20: konum = "238.1862, 107.9779, 1010.2188";
		case 21: konum = "237.3039, 114.9812, 1010.2188";
	}
	return konum;
}

DMKonum(sayi)
{
	new konum[100];
	switch(sayi)
	{
		case 0: konum = "212.7434, 142.3439, 1003.0234";
		case 1: konum = "300.8310, 185.2354, 1007.1719"; 
		case 2: konum = "267.7838, 185.6091, 1008.1719";
		case 3: konum = "245.7049, 185.5751, 1008.1719";
		case 4: konum = "237.9269, 141.2811, 1003.0234";
		case 5: konum = "208.9285, 142.0022, 1003.0300";
		case 6: konum = "194.6322, 158.1613, 1003.0234";
		case 7: konum = "228.5259, 183.1147, 1003.0313";
	}
	return konum;
}

Event2Konum(sayi, tip)
{
	new konum[100];
	if(tip == 0) // cop
	{
		switch(sayi)
		{
			case 0: konum = "2303.3035, -78.9138, 26.4844, 2.0591";
			case 1: konum = "2303.3838, -81.3945, 26.4844, 1.3698";
			case 2: konum = "2303.3154, -84.4755, 26.4844, 1.3698";
			case 3: konum = "2316.6682, -60.5459, 26.4844, 181.7470";
			case 4: konum = "2316.6699, -58.3995, 26.4844, 181.7470";
			case 5: konum = "2316.6912, -56.7294, 26.4844, 184.7341";
			case 6: konum = "2303.3188, -57.9531, 26.4844, 178.6947";
			case 7: konum = "2303.2417, -54.3536, 26.4844, 178.6947";
			case 8: konum = "2302.6443, -52.2671, 26.4844, 178.6947";
			case 9: konum = "2325.1628, -77.1955, 26.4844, 90.2946";
			case 10: konum = "2328.5620, -77.1873, 26.4844, 90.2946";
			case 11: konum = "2332.5938, -77.2519, 26.4844, 90.2946";
			case 12: konum = "2282.1011, -48.3582, 27.0036, 270.8364";
			case 13: konum = "2281.7046, -51.0232, 27.0125, 269.4578";
			case 14: konum = "2282.4041, -54.1912, 26.9952, 269.4578";
			case 15: konum = "2335.4165, -50.9767, 26.4844, 180.2037";
			case 16: konum = "2335.0518, -48.5606, 26.4844, 180.2037";
			case 17: konum = "2335.1162, -45.9984, 26.4844, 180.2037";
			case 18: konum = "2272.3162, -74.3656, 31.6016, 272.3455";
			case 19: konum = "2302.0662, -103.6853, 26.4800, 357.8236";
			case 20: konum = "2332.3882, -103.4996, 26.4844, 359.2760";
			case 21: konum = "2334.1345, -23.5901, 26.3313, 178.4959";
			case 22: konum = "2306.1990, -22.4306, 26.4844, 181.9426";
			case 23: konum = "2281.0046, -22.0389, 26.4844, 269.7186";
			case 24: konum = "2280.7004, -34.7719, 26.4844, 269.7186";
		}
	}
	if(tip == 1) // suspect
	{
		switch(sayi)
		{
			case 0: konum = "2307.3877, -10.3876, 26.7422, 260.8682";
			case 1: konum = "2309.7332, -9.9624, 26.7422, 276.0752";
			case 2: konum = "2312.3452, -8.1502, 26.7422, 276.0752";
			case 3: konum = "2314.3645, -5.0189, 26.7422, 276.0752";
			case 4: konum = "2313.3684, -2.0012, 26.7422, 276.0752";
			case 5: konum = "2309.3789, -0.1238, 26.7422, 258.4669";
			case 6: konum = "2309.3079, -3.5107, 26.7422, 226.1945";
			case 7: konum = "2306.7678, -4.6379, 26.7422, 226.1945";
			case 8: konum = "2316.2710, -15.5631, 26.7422, 174.5983";
			case 9: konum = "2316.6213, -6.9123, 26.7422, 224.1791";
			case 10: konum = "2316.3154, -9.9366, 26.7422, 170.7965";
			case 11: konum = "2316.0862, -12.4669, 26.7422, 170.7965";
			case 12: konum = "2315.6069, -15.4171, 26.7422, 170.7965";
			case 13: konum = "2313.6628, -15.8956, 26.7422, 99.1052";
			case 14: konum = "2311.2473, -14.1210, 26.7422, 99.1052";
			case 15: konum = "2309.7004, -16.3241, 26.7496, 99.1052";
			case 16: konum = "2307.0969, -15.1422, 26.7496, 99.1052";
			case 17: konum = "2305.9189, -1.1908, 26.7422, 239.3155";
			case 18: konum = "2315.6865, -1.1800, 26.7422, 184.4607";
			case 19: konum = "2314.5981, -4.9446, 26.7422, 171.4259";
			case 20: konum = "2315.3909, -8.1139, 26.7422, 171.4259";
			case 21: konum = "2315.5073, -11.9049, 26.7422, 171.4259";
			case 22: konum = "2309.5010, -13.9066, 26.7422, 278.5062";
			case 23: konum = "2311.7268, -13.5737, 26.7422, 278.5062";
			case 24: konum = "2313.8679, -13.2533, 26.7422, 278.5062";
		}
	}
	return konum;
}

PolisTelsiz(const mesaj[])
{
    if(mesaj[0] == '\0') return;
	foreach(new i : Player)
	{
        if(Oyuncu[i][Oyunda] == true && Oyuncu[i][Polis] == true)
        {
			SendClientMessage(i, TELSIZ, mesaj);
        }
    }
}

bosYasakID()
{
	new temp[123], Cache: result, lastid, id, returnable = 1, maxid = 1, j;
 	result = mysql_query(CopSQL, "SELECT yasakID FROM yasaklar ORDER BY yasakID ASC");
 	j = cache_num_rows();
 	for(new i = 0; i < j; i++)
 	{
 	 	maxid++;
		cache_get_value_name(i, "yasakID", temp), id = strval(temp);
  		if(id - lastid > 1)
  		{
  	 		returnable = lastid+1;
  	 		cache_delete(result);
   			return returnable;
  		}
  		lastid = id;
 	}
 	cache_delete(result);
 	return maxid;
}

strreplace(string[], const search[], const replacement[], bool:ignorecase = false, pos = 0, limit = -1, maxlength = sizeof(string))
{// No need to do anything if the limit is 0.
    if(limit == 0) return 0;
    new sublen = strlen(search), replen = strlen(replacement), bool:packed = ispacked(string), maxlen = maxlength, len = strlen(string), count = 0;
    // "maxlen" holds the max string length (not to be confused with "maxlength", which holds the max. array size).
    // Since packed strings hold 4 characters per array slot, we multiply "maxlen" by 4.
    if (packed)
        maxlen *= 4;// If the length of the substring is 0, we have nothing to look for..
    if (!sublen)
        return 0;// In this line we both assign the return value from "strfind" to "pos" then check if it's -1.
    while (-1 != (pos = strfind(string, search, ignorecase, pos)))
	{// Delete the string we found
        strdel(string, pos, pos + sublen);
        len -= sublen;// If there's anything to put as replacement, insert it. Make sure there's enough room first.
        if (replen && len + replen < maxlen) {
            strins(string, replacement, pos, maxlength);

            pos += replen;
            len += replen;
        }// Is there a limit of number of replacements, if so, did we break it?
        if (limit != -1 && ++count >= limit)
            break;
    }
    return count;
}

TRcevir(trstring[])
{
    new trstr[100];
    format(trstr, 100, "%s", trstring);
	strreplace(trstr, "�","g");
	strreplace(trstr, "�","G");
	strreplace(trstr, "�","s");
	strreplace(trstr, "�","S");
	strreplace(trstr, "�","i");
	strreplace(trstr, "I","I");
	strreplace(trstr, "�","I");
	strreplace(trstr, "�","o");
	strreplace(trstr, "�","O");
	strreplace(trstr, "�","c");
	strreplace(trstr, "�","C");
	strreplace(trstr, "�","u");
	strreplace(trstr, "�","U");
	return trstr;
}

SelectRandomPlayers(dest[], how_many_players, s_size = sizeof(dest))
{
	new ids[MAX_PLAYERS], count = 0;
	for(new i = 50 - 1; i != -1; i--)
		if(Oyuncu[i][GirisYapti] == true && Oyuncu[i][AFK] == false)
			ids[count++] = i;

	if(how_many_players > s_size)
		how_many_players = s_size;

	if(count < how_many_players)
		how_many_players = count;

	while(how_many_players > 0)
	{
		new rand = random(count);
		if(ids[rand] != INVALID_PLAYER_ID)
		{
			dest[--how_many_players] = ids[rand];
			ids[rand] = INVALID_PLAYER_ID;
		}
	}
}

ReturnUser(const text[])
{
	new strPos, returnID = 0, bool: isnum = true;
	while(text[strPos]) 
	{
		if(isnum) 
		{
			if('0' <= text[strPos] <= '9') returnID = (returnID * 10) + (text[strPos] - '0');
			else isnum = false;
		}
		strPos++;
	}
	if(isnum) 
	{
		if(IsPlayerConnected(returnID)) return returnID;
	}
	else 
	{
		new sz_playerName[MAX_PLAYER_NAME];

		foreach(new i : Player) 
		{
			GetPlayerName(i, sz_playerName, MAX_PLAYER_NAME);
			if(!strcmp(sz_playerName, text, true, strPos)) return i;
		}
	}
	return INVALID_PLAYER_ID;
}

JailGonder(playerid)
{
	new sayi = random(4);
	switch(sayi)
	{
		case 0: SetPlayerPos(playerid, 215.3556, 110.7461, 999.0156);
		case 1: SetPlayerPos(playerid, 219.3807, 110.5989, 999.0156); 
		case 2: SetPlayerPos(playerid, 223.5638, 110.5576, 999.0156);
		case 3: SetPlayerPos(playerid, 227.2564, 110.4045, 999.0156);
	}
	Oyuncu[playerid][AFK] = true;
	SetCameraBehindPlayer(playerid);
	SetPlayerInterior(playerid, 10);
	SetPlayerVirtualWorld(playerid, 0);

	new mesaj[900];
	strcat(mesaj, "- Oyunda seni di�er oyunculardan �st�n k�lan mod kullanamazs�n.\n");
	strcat(mesaj, "- /f (OOC) chatte hakaret etmemelisin.\n");
	strcat(mesaj, "- Roleplay modunda roleplay kurallar�na uygun davranmal�s�n.\n");
	strcat(mesaj, "- Polis memurlar�, ��pheliler ate� a�maya ba�layana kadar ate� a�amaz buna tekerlekler dahil.\n");
	strcat(mesaj, "- Bulundu�un arac� roleplay kurallar� i�inde s�rmeye dikkat etmelisin.\n");
	strcat(mesaj, "- Arac�n� s�rerken polislere veya ��phelilere ramming yapmamal�s�n.\n");
	strcat(mesaj, "- ��pheli sudayken ki�iyi kelep�eleyemez, taserleyemez ya da beanbag ile ate� edemezsin.\n");
	strcat(mesaj, "- ��pheliler ate� a�mad��� s�rece Drive-BY (ara�tan sarkma) yapamazs�n.\n");
	strcat(mesaj, "- Objeleri amac� d���nda kullanmak yasakt�r.\n");
	strcat(mesaj, "- Polisler ara�lar�n� d�zg�n s�rmek zorunda, LINE (tek �izgi) kural�na dikkat edilmelidir.\n");
	strins(mesaj, ""#BEYAZ2"", 0);
	ShowPlayerDialog(playerid, DIALOG_X, DIALOG_STYLE_MSGBOX, ""#SUNUCU_KISALTMA" - Kurallar", mesaj, "Kapat", "");

}

OyundaDegilMesaj(playerid)
{
	return YollaHataMesaj(playerid, "Hedef oyunda de�il veya hatal� ID.");
}

Float:OyuncuYakinMesafe(playerid, hedefid)
{
	if(GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(hedefid) && GetPlayerInterior(playerid) == GetPlayerInterior(hedefid))
	{
		new Float:x1, Float:y1, Float:z1, Float:x2, Float:y2, Float:z2;
	    GetPlayerPos(playerid, x1, y1, z1);
		GetPlayerPos(hedefid, x2, y2, z2);
	    return floatsqroot( ( ( x1 - x2 ) * ( x1 - x2 ) ) + ( ( y1 - y2 ) * ( y1 - y2 ) ) + ( ( z1 - z2 ) * ( z1 - z2 ) ) );
    }
    else return 999999.9999;
}

OyuncuYukle(playerid)
{
	cache_get_value_int(0, "ID", Oyuncu[playerid][SQLID]);
    cache_get_value(0, "isim", Oyuncu[playerid][OyuncuAdi], MAX_PLAYER_NAME);
	cache_get_value(0, "sifre", Oyuncu[playerid][Sifre], 65);
	cache_get_value(0, "sifresakla", Oyuncu[playerid][SSakla], 17);
	cache_get_value_int(0, "kiyafet", Oyuncu[playerid][Kiyafet]);
	cache_get_value_int(0, "pkiyafet", Oyuncu[playerid][pKiyafet]);
	cache_get_value_int(0, "skiyafet", Oyuncu[playerid][sKiyafet]);
	cache_get_value_int(0, "skor", Oyuncu[playerid][Skor]);
	cache_get_value(0, "ipadresi", Oyuncu[playerid][IP], 16);
	cache_get_value_int(0, "yonetici", Oyuncu[playerid][Yonetici]);
	cache_get_value_int(0, "helper", Oyuncu[playerid][Helper]);
	cache_get_value_int(0, "polisarac", Oyuncu[playerid][PolisArac]);
	cache_get_value_int(0, "susturdakika", Oyuncu[playerid][SusturDakika]);
	cache_get_value_int(0, "hapisdakika", Oyuncu[playerid][HapisDakika]);
	cache_get_value_int(0, "suspectkazanma", Oyuncu[playerid][SuspectKazanma]);
	cache_get_value_int(0, "olum", Oyuncu[playerid][Olum]);
	cache_get_value_int(0, "oldurme", Oyuncu[playerid][Oldurme]);
	cache_get_value_int(0, "donator", Oyuncu[playerid][Donator]);
	cache_get_value_int(0, "isimhak", Oyuncu[playerid][IsimHak]);
	return 1;
}

OyuncuGuncelle(playerid)
{
	new sorgu[300];
	mysql_format(CopSQL, sorgu, sizeof(sorgu), "UPDATE `hesaplar` SET `kiyafet` = %d, `skiyafet` = %d, `skor` = %d, `para` = %d, `medkit` = %d, `ipadresi` = '%s',`yonetici` = %d WHERE `ID` = %d LIMIT 1", Oyuncu[playerid][pKiyafet], Oyuncu[playerid][sKiyafet], Oyuncu[playerid][Skor], Oyuncu[playerid][Para], Oyuncu[playerid][Medkit], Oyuncu[playerid][IP], Oyuncu[playerid][Yonetici], Oyuncu[playerid][SQLID]);
	mysql_tquery(CopSQL, sorgu);

	mysql_format(CopSQL, sorgu, sizeof(sorgu), "UPDATE `hesaplar` SET `helper` = %i, `polisarac` = '%d', `susturdakika` = '%d', `hapisdakika` = '%d' WHERE `ID` = %d LIMIT 1", Oyuncu[playerid][Helper], Oyuncu[playerid][PolisArac], Oyuncu[playerid][SusturDakika], Oyuncu[playerid][HapisDakika], Oyuncu[playerid][SQLID]);
	mysql_tquery(CopSQL, sorgu);

	mysql_format(CopSQL, sorgu, sizeof(sorgu), "UPDATE `hesaplar` SET `suspectkazanma` = %d, `olum` = %d, `oldurme` = %d, `donator` = %i, `isimhak` = %i, `PDLoadout1` = %d, `PDLoadout2` = %d, `PDLoadout3` = %d, `FGLoadout1` = %d, `FGLoadout2` = %d, `FGLoadout3` = %d WHERE `ID` = %d LIMIT 1", Oyuncu[playerid][SuspectKazanma], Oyuncu[playerid][Olum], Oyuncu[playerid][Oldurme], Oyuncu[playerid][Donator], Oyuncu[playerid][IsimHak], Oyuncu[playerid][PDLoadout1], Oyuncu[playerid][PDLoadout2], Oyuncu[playerid][PDLoadout3], Oyuncu[playerid][FGLoadout1], Oyuncu[playerid][FGLoadout2], Oyuncu[playerid][FGLoadout3],Oyuncu[playerid][SQLID]);
	mysql_tquery(CopSQL, sorgu);

	return 1;
}

OyuncuLobiGonder(playerid)
{
	new skin;
	if(Oyuncu[playerid][Polis] == true) skin = Oyuncu[playerid][pKiyafet];
	if(Oyuncu[playerid][Suspect] == true) skin = Oyuncu[playerid][sKiyafet];
	if(Oyuncu[playerid][YaraliDurum] == false)
	{
		GetPlayerPos(playerid, Oyuncu[playerid][Pos][0], Oyuncu[playerid][Pos][1], Oyuncu[playerid][Pos][2]);
		GetPlayerFacingAngle(playerid, Oyuncu[playerid][Pos][3]);
		SetTimerEx("OyuncuYaraliYap", 400, false, "d", playerid);
		SetSpawnInfo(playerid, 0, skin, Oyuncu[playerid][Pos][0], Oyuncu[playerid][Pos][1], Oyuncu[playerid][Pos][2], Oyuncu[playerid][Pos][3], 0, 0, 0, 0, 0, 0);
	}
	else
	{
		new sayi = random(22);
		sscanf(LobiKonum(sayi), "p<,>fff", Oyuncu[playerid][Pos][0], Oyuncu[playerid][Pos][1], Oyuncu[playerid][Pos][2]);
		SetSpawnInfo(playerid, 0, skin, Oyuncu[playerid][Pos][0], Oyuncu[playerid][Pos][1], Oyuncu[playerid][Pos][2], Oyuncu[playerid][Pos][3], 0, 0, 0, 0, 0, 0);
		Oyuncu[playerid][Oyunda] = Oyuncu[playerid][Suspect] = Oyuncu[playerid][Polis] = false;
		if(IsValidDynamic3DTextLabel(Oyuncu[playerid][ShotFired]) && Oyuncu[playerid][Oyunda] == false)
		{
			DestroyDynamic3DTextLabel(Oyuncu[playerid][ShotFired]);
			Oyuncu[playerid][ShotFired] = Text3D: INVALID_3DTEXT_ID;
		}
	}
	SpawnPlayer(playerid);
}

YoneticiYetkiAdi(yetki)
{
	new	yetkiadi[124];
	switch(yetki)
	{
	   	case 0: yetkiadi = "";
		case 1: yetkiadi = ""#MAVI2"Moderat�r"#BEYAZ2"";
		case 2: yetkiadi = ""#YESIL2"Oyun G�revlisi"#BEYAZ2"";
		case 3: yetkiadi = ""#TURUNCU2"Genel Yetkili"#BEYAZ2"";
		case 4: yetkiadi = ""#KIRMIZI2"Sunucu Y�neticisi"#BEYAZ2"";
		case 5: yetkiadi = "";
		case 6: yetkiadi = "";
		case 7: yetkiadi = "";
	}
 	return yetkiadi;
}

PolisRutbe(playerid)
{
	new	yetkiadi[124];
	switch(Oyuncu[playerid][Skor])
	{
	   	case -100..74: yetkiadi = "Recruit Officer";
		case 75..134: yetkiadi = "Police Officer I";
		case 135..164: yetkiadi = "Police Officer II";
		case 165..224: yetkiadi = "Police Officer III";
		case 225..299: yetkiadi = "Police Officer III+1";
		case 300..379: yetkiadi = "Police Detective I";
		case 380..559: yetkiadi = "Police Detective II";
		case 560..659: yetkiadi = "Police Sergeant I";
		case 660..859: yetkiadi = "Police Sergeant II";
		case 860..959: yetkiadi = "Police Lieutenant I";
		case 960..1059: yetkiadi = "Police Lieutenant II";
		case 1060..1159: yetkiadi = "Police Captain I";
		case 1160..1259: yetkiadi = "Police Captain II";
		case 1260..1459: yetkiadi = "Police Captain III";
		case 1460..1599: yetkiadi = "Police Commander";
		case 1600..1849: yetkiadi = "Police Deputy Chief";
		case 1850..2219: yetkiadi = "Police Assistant Chief";
	}
	if(Oyuncu[playerid][Skor] >= 2220) yetkiadi = "Chief of Police";
 	return yetkiadi;
}

GetClosestVehicle(playerid, Float:radius)
{
	new vehid = -1;
    new Float:distance = 999999.9;
	for(new v = 1, i = GetVehiclePoolSize(); v <= i; v++)
	{
		new Float:distance2 = GetDistancePlayerToVehicle(playerid, v);
		if(distance2 < radius && distance2 < distance) { distance = distance2; vehid = v; }
	}
	return vehid;
}

Tarih(timestamp, _form = 3) // date - Tarihi �ek
{
    /*~ convert a Timestamp to a Date. ~ 10.07.2009
    date( 1247182451 )  will print >> 09.07.2009-23:34:11 ____ date( 1247182451, 1) will print >> 09/07/2009, 23:34:11
    date( 1247182451, 2) will print >> July 09, 2009, 23:34:11 ____ date( 1247182451, 3) will print >> 9 Jul 2009, 23:34
    */
    new year = 1970, day = 0, month = 0, hour = 3, mins = 0, sec = 0, returnstring[32];
    new days_of_month[12] = {31,28,31,30,31,30,31,31,30,31,30,31};
    new names_of_month[12][10] = {"Ocak","�ubat","Mart","Nisan","May�s","Haziran","Temmuz","A�ustos","Eyl�l","Ekim","Kas�m","Aral�k"};
    while(timestamp>31622400)
	{
        timestamp -= 31536000;
        if(((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0)) timestamp -= 86400;
        year++;
    }
    if(((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0))
        days_of_month[1] = 29;
    else
        days_of_month[1] = 28;
    while(timestamp>86400)
	{
        timestamp -= 86400, day++;
        if(day==days_of_month[month]) day=0, month++;
    }
    while(timestamp>60)
	{
        timestamp -= 60, mins++;
        if( mins == 60) mins=0, hour++;
    }
    sec=timestamp;
    switch(_form)
	{
        case 1: format(returnstring, 31, "%02d/%02d/%d %02d:%02d:%02d", day+1, month+1, year, hour, mins, sec);
        case 2: format(returnstring, 31, "%s %02d, %d, %02d:%02d:%02d", names_of_month[month],day+1,year, hour, mins, sec);
        case 3: format(returnstring, 31, "%d %s %d - %02d:%02d", day+1,names_of_month[month],year,hour,mins);
        default: format(returnstring, 31, "%02d.%02d.%d-%02d:%02d:%02d", day+1, month+1, year, hour, mins, sec);
    }
    return returnstring;
}

PlaySoundEx(soundid, Float:x, Float:y, Float:z, mesafe)
{
	foreach(new i : Player)
	{
		if(Oyuncu[i][GirisYapti] == false && Oyuncu[i][Oyunda] == false) continue;
		if(!IsPlayerInRangeOfPoint(i, mesafe, x, y, z)) continue;
		PlayerPlaySound(i, soundid, 0, 0, 0);
	}
}

Oyuncuadi(playerid)
{
    new oyuncuisim[MAX_PLAYER_NAME];
    GetPlayerName(playerid, oyuncuisim, MAX_PLAYER_NAME);
    return oyuncuisim;
}

HataMesajDefine(playerid, const mesaj[])
{
	return YollaFormatMesaj(playerid, 0xD01717FF, "[HATA]"#BEYAZ2" %s", mesaj);
}
DefaultMesajDefine(playerid, const mesaj[])
{
	return YollaFormatMesaj(playerid, 0xFFFFFFFF, "%s", mesaj);
}
IpucuMesajDefine(playerid, const mesaj[])
{
	return YollaFormatMesaj(playerid, 0x008000FF, "[B�LG�]"#BEYAZ2" %s", mesaj);
}

KullanMesajDefine(playerid, const mesaj[])
{
	return YollaFormatMesaj(playerid, 0x008000FF, "[B�LG�]"#BEYAZ2" %s", mesaj);
}

YoneticiMesajDefine(yetki, renk, const mesaj[])
{
    if(mesaj[0] == '\0') return;
	foreach(new i : Player)
	{
        if(Oyuncu[i][Yonetici] >= yetki)
        {
			SendClientMessage(i, renk, mesaj);
        }
    }
}

HelperMesajDefine(renk, const mesaj[])
{
    if(mesaj[0] == '\0') return;
	foreach(new i : Player)
	{
        if(Oyuncu[i][Yonetici] >= 1 || Oyuncu[i][Helper] == true)
        {
			SendClientMessage(i, renk, mesaj);
        }
    }
}

SoruMesajDefine(renk, const mesaj[])
{
    if(mesaj[0] == '\0') return;
	foreach(new i : Player)
	{
        if(Oyuncu[i][Yonetici] >= 1 || Oyuncu[i][Helper] == true)
        {
			SendClientMessage(i, renk, mesaj);
        }
    }
}

public OnGameModeInit()
{
	Fdurum = true;
	OyunBasladi = EventModu = EventModu2 = false;
	OyunSaniye = OYUN_SANIYE;
	OyunDakika = OYUN_DAKIKA;
	new saat, dk, sn;
    gettime(saat, dk, sn);
	SetWorldTime(saat);
	new MySQLOpt: option_id = mysql_init_options();
	mysql_set_option(option_id, AUTO_RECONNECT, true);
	CopSQL = mysql_connect(MYSQL_HOST, MYSQL_HESAP, MYSQL_SIFRE, MYSQL_VERITABANI, option_id);
	if(CopSQL == MYSQL_INVALID_HANDLE || mysql_errno(CopSQL) != 0)
	{
		print("[S�STEM] Veritaban� ba�lant�s� ba�ar�s�z, sunucu kapan�yor..");
		SendRconCommand("exit");
		return 1;
	}
	mysql_tquery(CopSQL, "SET NAMES 'latin5'");
	print("[S�STEM] Veritaban� ba�lant�s� ba�ar�l�.");
	SetGameModeText(MODADI);
	DisableInteriorEnterExits();
	EnableStuntBonusForAll(0);
	ShowPlayerMarkers(1);
	ShowNameTags(1);
	ManualVehicleEngineAndLights();
	SetNameTagDrawDistance(20.0);
	SetTimer("SendMSG", 180000, true);
	Baslat();
	MyPickup = CreatePickup(1239, 23, 240.8472,115.2306,1003.2188, 0);
	MyPickup2 = CreatePickup(1239, 23, 252.5862,111.8131,1003.2188, 0);
	return 1;
}

public OnGameModeExit()
{
	OyunBasladi = EventModu = EventModu2 = false;
	OyunSaniye = OYUN_SANIYE;
	OyunDakika = OYUN_DAKIKA;
	KillTimer(SuspectSaklaTimer);
	KillTimer(OyunKalanTimer);
	for(new j = 1, i = GetVehiclePoolSize(); j <= i; j++)
	{
		DestroyVehicle(j);
	}
	foreach(new i : Player)
	{
		OnPlayerDisconnect(i, 1);
	}
	mysql_close(CopSQL);
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
    if(pickupid == MyPickup)
    {

    }
    if(pickupid == MyPickup2)
    {

    }
    if(EventModu2 == true)
    {
    	if(pickupid == BankaOnKapi[0])
	    	YollaIpucuMesaj(playerid, "Giri� i�in F tu�una bas�n.");
	    if(pickupid == BankaArkaKapi[0])
	    	YollaIpucuMesaj(playerid, "Giri� i�in F tu�una bas�n.");
	    if(pickupid == BankaOnKapi[1])
	    	YollaIpucuMesaj(playerid, "��k�� i�in F tu�una bas�n.");
	    if(pickupid == BankaArkaKapi[1])
	    	YollaIpucuMesaj(playerid, "��k�� i�in F tu�una bas�n.");
    }
    return 1;
}

public OnPlayerSelectDynamicObject(playerid, objectid, modelid, Float:x, Float:y, Float:z)
{
	if(Oyuncu[playerid][Oyunda] == false)
		return 1;
	if(Engel[objectid][Olusturuldu] == true)
	{
		if(Oyuncu[playerid][EngelSec] == 1)
		{
			if(Engel[objectid][Duzenleniyor] == true)
				return YollaHataMesaj(playerid, "Bu engel ba�kas� taraf�ndan d�zenleniyor.");
			Oyuncu[playerid][DuzenleEngelID] = objectid;
			Oyuncu[playerid][DuzenleEngel] = true;
			Engel[objectid][Duzenleniyor] = true;
			Oyuncu[playerid][EngelSec] = 0;
			EditDynamicObject(playerid, Engel[objectid][ID]);
			return 1;
		}
		if(Oyuncu[playerid][EngelSec] == 2)
		{
			DestroyDynamicObject(Engel[objectid][ID]);
			DestroyDynamic3DTextLabel(Engel[objectid][Engel3D]);
			DestroyDynamicArea(Engel[objectid][AreaID]);
			Engel[objectid][Engel3D] = Text3D: INVALID_3DTEXT_ID;
			Engel[objectid][Pos][0] = Engel[objectid][Pos][1] = Engel[objectid][Pos][2] = 0.0;
			Engel[objectid][Duzenleniyor] = false;
			Engel[objectid][Olusturuldu] = false;
			if(Oyuncu[Engel[objectid][SahipID]][Oyunda] == true && Oyuncu[Engel[objectid][SahipID]][Polis] == true)
			{
				Oyuncu[Engel[objectid][SahipID]][EngelHak]--;
			}
			Engel[objectid][SahipID] = -1;
			Oyuncu[playerid][DuzenleEngelID] = -1;
			Oyuncu[playerid][DuzenleEngel] = false;
			Engel[objectid][Duzenleniyor] = false;
			Oyuncu[playerid][EngelSec] = 0;
			YollaIpucuMesaj(playerid, "Engeli kald�rd�n. (Engel ID: %d)", objectid);
			CancelEdit(playerid);
			return 1;
		}
	}
	return 1;
}

public OnPlayerEditDynamicObject(playerid, STREAMER_TAG_OBJECT objectid, response, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz)
{
	if(Oyuncu[playerid][Oyunda] == false)
		return 1;
	if(response == EDIT_RESPONSE_FINAL)
	{
		if(Oyuncu[playerid][DuzenleEngel] == true)
		{
			SetDynamicObjectPos(objectid, x, y, z);
		    new engelid = Oyuncu[playerid][DuzenleEngelID], mesaj[130];
			DestroyDynamic3DTextLabel(Engel[engelid][Engel3D]);
			DestroyDynamicArea(Engel[engelid][AreaID]);
			format(mesaj, sizeof(mesaj), "Engel ID: %d - Olu�turan: %s", engelid, Oyuncuadi(Engel[engelid][SahipID]));
		    Engel[engelid][Pos][0] = x; Engel[engelid][Pos][1] = y; Engel[engelid][Pos][2] = z;
		    YollaIpucuMesaj(playerid, "Engeli d�zenledin. (Engel ID: %d)", engelid, Engel[engelid][Model]);
		    Engel[engelid][Engel3D] = CreateDynamic3DTextLabel(mesaj, MAVI, Engel[engelid][Pos][0], Engel[engelid][Pos][1], Engel[engelid][Pos][2], 20.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID);
		    Engel[engelid][AreaID] = CreateDynamicRectangle(Engel[engelid][Pos][0]+2, Engel[engelid][Pos][1]+2, Engel[engelid][Pos][0]-2, Engel[engelid][Pos][1]-2);
		    Oyuncu[playerid][DuzenleEngelID] = -1;
		    Oyuncu[playerid][DuzenleEngel] = false;
		    Engel[engelid][Duzenleniyor] = false;
		}
	}
	return 1;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	if(AracHasar[vehicleid] == true)
	{
		YollaIpucuMesaj(playerid, "Bu ara� hasarl� tamir etmeyi deneyin.");
	}
	if(Oyuncu[playerid][Suspect] == true && (GetVehicleModel(vehicleid) == 497 || GetVehicleModel(vehicleid) == 430))
	{
		new Float: x, FLoat: y, Float: z, Float: a;
		GetPlayerPos(playerid, Float: x, Float: y, Float: z);
		GetPlayerFacingAngle(playerid, a);
		SetPlayerPos(playerid, Float: x, Float: y, Float: z);
		SetPlayerFacingAngle(playerid, a);
	}
	return 1;
}

public OnPlayerEnterDynamicArea(playerid, areaid)
{
	new engelid = EngelYakin(playerid);
	if(Engel[engelid][Olusturuldu] == true)
	{
		if(IsPlayerInAnyVehicle(playerid))
		{
			new Panels, Doors, Lights, Tires;
			GetVehicleDamageStatus(GetPlayerVehicleID(playerid), Panels, Doors, Lights, Tires);
			UpdateVehicleDamageStatus(GetPlayerVehicleID(playerid), Panels, Doors, Lights, 15);
		}
		return 1;
	}
	return 1;
}

public OnPlayerConnect(playerid)
{
	
	PublicTD[0] = TextDrawCreate(545.000000, 391.000000, "San Fierro");
	TextDrawFont(PublicTD[0], 0);
	TextDrawLetterSize(PublicTD[0], 0.462500, 1.850000);
	TextDrawTextSize(PublicTD[0], 683.000000, 16.000000);
	TextDrawSetOutline(PublicTD[0], 1);
	TextDrawSetShadow(PublicTD[0], 0);
	TextDrawAlignment(PublicTD[0], 1);
	TextDrawColor(PublicTD[0], -1);
	TextDrawBackgroundColor(PublicTD[0], 255);
	TextDrawBoxColor(PublicTD[0], 50);
	TextDrawUseBox(PublicTD[0], 0);
	TextDrawSetProportional(PublicTD[0], 1);
	TextDrawSetSelectable(PublicTD[0], 0);

	PublicTD[1] = TextDrawCreate(555.000000, 409.000000, "  Copchase");
	TextDrawFont(PublicTD[1], 0);
	TextDrawLetterSize(PublicTD[1], 0.312500, 1.600000);
	TextDrawTextSize(PublicTD[1], 683.000000, 16.000000);
	TextDrawSetOutline(PublicTD[1], 1);
	TextDrawSetShadow(PublicTD[1], 0);
	TextDrawAlignment(PublicTD[1], 1);
	TextDrawColor(PublicTD[1], 1097458175);
	TextDrawBackgroundColor(PublicTD[1], 255);
	TextDrawBoxColor(PublicTD[1], 50);
	TextDrawUseBox(PublicTD[1], 0);
	TextDrawSetProportional(PublicTD[1], 1);
	TextDrawSetSelectable(PublicTD[1], 0);

	/*Textdraw1[playerid] = CreatePlayerTextDraw(playerid, 231.059005, 428.750122, "POLICE PURSUIT");
	PlayerTextDrawLetterSize(playerid, Textdraw1[playerid], 0.563412, 1.477501);
	PlayerTextDrawAlignment(playerid, Textdraw1[playerid], 1);
	PlayerTextDrawColor(playerid, Textdraw1[playerid], -1);
	PlayerTextDrawSetShadow(playerid, Textdraw1[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Textdraw1[playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, Textdraw1[playerid], 51);
	PlayerTextDrawFont(playerid, Textdraw1[playerid], 2);
	PlayerTextDrawSetProportional(playerid, Textdraw1[playerid], 1);*/
		
	SetPlayerColor(playerid, GRI);
	g_MysqlRaceCheck[playerid]++;
	static const empty_player[Oyuncular];
	Oyuncu[playerid] = empty_player;
	static const empty_player2[Yasaklar];
	Yasakla[playerid] = empty_player2;
	new sorgu[200], ipadresi[16];
	GetPlayerIp(playerid, ipadresi, 16);
	mysql_format(CopSQL, sorgu, sizeof(sorgu), "SELECT * FROM yasaklar WHERE yasaklanan = '%s' OR yasakip = '%s'", Oyuncuadi(playerid), ipadresi);
	mysql_tquery(CopSQL, sorgu, "YasakKontrol", "d", playerid);
	if(Oyuncu[playerid][Yonetici] >=  2)
	{
		Oyuncu[playerid][apm] = true;
	}
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	KillTimer(Oyuncu[playerid][CbugTimer]);
	g_MysqlRaceCheck[playerid]++;
	KillTimer(Oyuncu[playerid][SkorTimer]);
	if(Oyuncu[playerid][GirisYapti] == false) return 0;
	if(cache_is_valid(Oyuncu[playerid][CacheID]))
	{
		cache_delete(Oyuncu[playerid][CacheID]);
		Oyuncu[playerid][CacheID] = MYSQL_INVALID_CACHE;
	}
	Oyuncu[playerid][GirisYapti] = false;
	if(OyunBasladi == true && Oyuncu[playerid][Oyunda])
	{
		Oyuncu[playerid][Oyunda] = Oyuncu[playerid][Suspect] = Oyuncu[playerid][Polis] = false;
		OyunKontrol();
	}
	if(Oyuncu[playerid][HapisDakika] >= 1) KillTimer(Oyuncu[playerid][HapisTimer]);
	if(Oyuncu[playerid][SusturDakika] >= 1) KillTimer(Oyuncu[playerid][SusturTimer]);
	OyuncuGuncelle(playerid);
	return 1;
}
/*
public OnPlayerFakeConnect(playerid)
{
	printf("ID %d is fake connecting!", playerid);
	YollaHataMesaj(playerid, "Hile tespit edildi, sunucudan kicklendiniz.");
	Kickle(playerid);
	return 1;
}

public OnPlayerJetpackCheat(playerid)
{
	printf("ID %d is using jetpack cheats!", playerid);
	YollaHataMesaj(playerid, "Hile tespit edildi, sunucudan kicklendiniz.");
	Kickle(playerid);
	return 1;
}

public OnPlayerGunCheat(playerid, weaponid, ammo, hacktype)
{
	printf("ID %d just used weapon cheats weapon %d ammo %d type %d!", playerid, weaponid, ammo, hacktype);
	YollaHataMesaj(playerid, "Hile tespit edildi, sunucudan kicklendiniz.");
	YollaYoneticiMesaj(1, 0x008000FF, "%s, adl� oyuncu hile kullan�yor olabilir. [%d]", Oyuncuadi(playerid), hacktype);
	Kickle(playerid);
	return 1;
}

public OnPlayerSpeedCheat(playerid, speedtype)
{
	printf("ID %d just speed cheats type !", playerid, speedtype);
	YollaHataMesaj(playerid, "Hile tespit edildi, sunucudan kicklendiniz.");
	YollaYoneticiMesaj(1, 0x008000FF, "%s, adl� oyuncu hile kullan�yor olabilir. [%d]", Oyuncuadi(playerid), speedtype);
	Kickle(playerid);
	return 1;
}

public OnPlayerBreakAir(playerid, breaktype)
{
	printf("ID %d used airbreak/teleport cheats type %d !", playerid, breaktype);
	YollaHataMesaj(playerid, "Hile tespit edildi, sunucudan kicklendiniz.");
	YollaYoneticiMesaj(1, 0x008000FF, "%s, adl� oyuncu hile kullan�yor olabilir. [%d]", Oyuncuadi(playerid), breaktype);
	Kickle(playerid);
	return 1;
}

public OnPlayerSpamCars(playerid, number)
{
	printf("ID %d used car spammed %d vehicles !", playerid, number);
	YollaHataMesaj(playerid, "Hile tespit edildi, sunucudan kicklendiniz.");
	Kickle(playerid);
	return 1;
}

public OnPlayerCarTroll(playerid, vehicleid, trolledid, trolltype)
{
	if(trolledid == INVALID_PLAYER_ID)
		printf("ID %d used car troll cheats vehicle %d type %d !", playerid, vehicleid, trolltype);
	else
		printf("ID %d used car troll cheats on ID %d vehicle %d type %d !", playerid, trolledid, vehicleid, trolltype); 

	YollaHataMesaj(playerid, "Hile tespit edildi, sunucudan kicklendiniz.");
	Kickle(playerid);
	return 1;
}

public OnPlayerCashCheat(playerid, oldcash, newcash, amount)
{
	printf("ID %d used money cheats for %d !", playerid, amount);
	YollaHataMesaj(playerid, "Hile tespit edildi, sunucudan kicklendiniz.");
	Kickle(playerid);
	return 1;
}

public OnPlayerCarSwing(playerid, vehicleid)
{
	printf("ID %d used car swing cheats vehicle %d !", playerid, vehicleid);
	YollaHataMesaj(playerid, "Hile tespit edildi, sunucudan kicklendiniz.");
	Kickle(playerid);
	return 1;
}

public OnPlayerParticleSpam(playerid, vehicleid)
{
	printf("ID %d used car particle spam cheats vehicle %d !", playerid, vehicleid);
	YollaHataMesaj(playerid, "Hile tespit edildi, sunucudan kicklendiniz.");
	Kickle(playerid);
	return 1;
}

public OnVehicleModEx(playerid, vehicleid, componentid, illegal)
{
	if(illegal)
	{
		printf("ID %d used car mod cheats component %d vehicle %d !", playerid, componentid, vehicleid);
		YollaHataMesaj(playerid, "Hile tespit edildi, sunucudan kicklendiniz.");
		Kickle(playerid);
	}
	return 1;
}

public OnPlayerSlide(playerid, weaponid, Float:speed)
{
	printf("ID %d is slide bugging weapon %d !", playerid, weaponid);
	YollaHataMesaj(playerid, "Hile tespit edildi, sunucudan kicklendiniz.");
	Kickle(playerid);
	return 1;
}

public OnPlayerLagout(playerid, lagtype, ping)
{
	printf("ID %d is lagging type %d ping %d !", playerid, lagtype, ping);
	return 1;
}

public OnPlayerBugAttempt(playerid, bugcode)
{
	printf("ID %d is using bug cheats type %d!", playerid, bugcode);
	return 1;
}
*/
stock SetVehicleSpeed(vehicleid, Float:speed)
{
	new Float:x1, Float:y1, Float:z1, Float:x2, Float:y2, Float:z2, Float:a;
	GetVehicleVelocity(vehicleid, x1, y1, z1);
	GetVehiclePos(vehicleid, x2, y2, z2);
	GetVehicleZAngle(vehicleid, a); a = 360 - a;
	x1 = (floatsin(a, degrees) * (speed/100) + floatcos(a, degrees) * 0 + x2) - x2;
	y1 = (floatcos(a, degrees) * (speed/100) + floatsin(a, degrees) * 0 + y2) - y2;
	SetVehicleVelocity(vehicleid, x1, y1, z1);
}
public OnPlayerDamage(&playerid, &Float:amount, &issuerid, &weapon, &bodypart)
{
	if (issuerid == INVALID_PLAYER_ID) return 0;
	if (Oyuncu[playerid][Oyunda] == true && weapon == 51 || weapon == 54 || weapon == 50) return 0;
	if (Oyuncu[playerid][Oyunda] == true && Oyuncu[issuerid][Oyunda] == true && Oyuncu[issuerid][Polis] == true && Oyuncu[playerid][Polis] == true) return 0;
	if (Oyuncu[playerid][Oyunda] == true && Oyuncu[issuerid][Oyunda] == true && Oyuncu[issuerid][Suspect] == true && Oyuncu[playerid][Suspect] == true) return 0;
	if (Oyuncu[playerid][Oyunda] == true && Oyuncu[playerid][Suspect] == true && Oyuncu[playerid][SuspectAtes] == false) return 0;
	if (Oyuncu[playerid][Oyunda] == false && Oyuncu[playerid][DM] == false) return 0;
	//if (Oyuncu[playerid][Oyunda] == true && Oyuncu[playerid][Polis] == true && Oyuncu[issuerid][Polis] == true) return 0;
	if(issuerid != INVALID_PLAYER_ID)
		SaveDamageData(playerid, weapon, bodypart, amount);
	if(issuerid != INVALID_PLAYER_ID && Oyuncu[playerid][Oyunda] == false && Oyuncu[issuerid][Oyunda] == false && Oyuncu[playerid][aktifduel] == false && Oyuncu[playerid][DM] == false)
	{
		if(weapon == 0)
			SetTimerEx("OyuncuCanYenile", 150, false, "d", playerid);
	}
	if (Oyuncu[playerid][DM] == false && Oyuncu[playerid][pTopallama] == false && Oyuncu[playerid][Oyunda] == true && (bodypart == 7 || bodypart == 8))
	{
	    Oyuncu[playerid][pTopallama] = true;
	    Oyuncu[playerid][TopallamaSure] = 25;
	    YollaIpucuMesaj(playerid, "Aya��n�zdan vuruldunuz. 25 saniye boyunca y�r�yemezsiniz veya ko�amazs�n�z.");
	}
	if (Oyuncu[playerid][DM] == true && Oyuncu[playerid][DMArena] == 2)
	{
	    if (weapon == 24 && bodypart == 9) amount = 200.0;
	    else return 0;
	}
	else
	    if(weapon == 24) amount = 36.0;
	if(weapon == 34 && bodypart == 9) amount = 200.0;
	if (weapon == 33 && bodypart == 9) amount = 200.0;
	if(weapon == 31) amount = 12.0;
	if(weapon == 30) amount = 14.0;

	if(weapon == 33) amount = 33.0;
	if (weapon == WEAPON_VEHICLE)
	{
	    amount = 0;
	    ClearAnimations(playerid);
	    SetVehicleSpeed(GetPlayerVehicleID(issuerid), 0);
	    TogglePlayerControllable(issuerid, 0);
	    SetTimerEx("Cozz", TIMER_SANIYE(2), false, "d", issuerid);
		YollaHataMesaj(issuerid, "Car Ramming yasakt�r.");
		return 0;
	}
    return 1;
}

forward SaveDamageData(playerid, weaponid, bodypart, Float:amount);
public SaveDamageData(playerid, weaponid, bodypart, Float:amount)
{
	totalDamages ++;
	new i = totalDamages;
	if(i > MAX_DAMAGES - 1) return 1;
	DamageData[i][DamagePlayerID] = playerid;

	DamageData[i][DamageBodyPart] = bodypart;
	DamageData[i][DamageWeapon] = weaponid;
	DamageData[i][DamageAmount] = amount;
	return true;
}

public OnPlayerText(playerid, text[])
{
	if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING)
		return 0;
	if(Oyuncu[playerid][SusturDakika] >= 1)
	{
		YollaHataMesaj(playerid, "Susturuldu�un i�in konu�amazs�n, susturman�n bitmesine %d kald�.", Oyuncu[playerid][SusturDakika]);
		return 0;
	}
	new mesaj[150];
	if(Oyuncu[playerid][Yonetici] >= 1)
	{
		if(Oyuncu[playerid][Oyunda] == false)
		{
			format(mesaj, sizeof(mesaj), ""#BEYAZ2"[%s] %s(%d):"#BEYAZ2" %s", YoneticiYetkiAdi(Oyuncu[playerid][Yonetici]), Oyuncuadi(playerid), playerid, text);
			ProxDetectorLobi(mesaj, GetPlayerColor(playerid));
			return 0;
		}
		else
		{
			format(mesaj, sizeof(mesaj), "%s: %s", Oyuncuadi(playerid), text);
			ProxDetector(15.0, playerid, mesaj, BEYAZ);
			return 0;
		}
	}
	if(Oyuncu[playerid][Helper] == true)
	{
		if(Oyuncu[playerid][Oyunda] == false)
		{
			format(mesaj, sizeof(mesaj), ""#BEYAZ2"["#SARI2"Helper"#BEYAZ2"] %s(%d):"#BEYAZ2" %s", Oyuncuadi(playerid), playerid, text);
			ProxDetectorLobi(mesaj, GetPlayerColor(playerid));
			return 0;
		}
		else
		{
			format(mesaj, sizeof(mesaj), "%s: %s", Oyuncuadi(playerid), text);
			ProxDetector(15.0, playerid, mesaj, BEYAZ);
			return 0;
		}
	}
	if(Oyuncu[playerid][Donator] == true)
	{
		if(Oyuncu[playerid][Oyunda] == false)
		{
			format(mesaj, sizeof(mesaj), ""#BEYAZ2"["#DONATOR_RENK2"DONATOR"#BEYAZ2"] %s(%d):"#BEYAZ2" %s", Oyuncuadi(playerid), playerid, text);
			ProxDetectorLobi(mesaj, GetPlayerColor(playerid));
			return 0;
		}
		else
		{
			format(mesaj, sizeof(mesaj), "%s: %s", Oyuncuadi(playerid), text);
			ProxDetector(15.0, playerid, mesaj, BEYAZ);
			return 0;
		}
	}
	if(Oyuncu[playerid][Oyunda] == false)
	{
		format(mesaj, sizeof(mesaj), "%s(%d):"#BEYAZ2" %s", Oyuncuadi(playerid), playerid, text);
		ProxDetectorLobi(mesaj, GetPlayerColor(playerid));
		return 0;
	}
	else
	{
		format(mesaj, sizeof(mesaj), "%s: %s", Oyuncuadi(playerid), text);
		ProxDetector(15.0, playerid, mesaj, BEYAZ);
		return 0;
	}
}

public OnPlayerSpawn(playerid)
{
	ApplyAnimation(playerid, "COP_AMBIENT", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "DEALER", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "GRAVEYARD", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "INT_HOUSE", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "Attractors", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "MISC", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "FIGHT_E", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "CRIB", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "CRACK", "null", 0.0, 0, 0, 0, 0, 0);
	ApplyAnimation(playerid, "PED", "null", 0.0, 0, 0, 0, 0, 0);
	
	TextDrawShowForPlayer(playerid, PublicTD[0]);
	TextDrawShowForPlayer(playerid, PublicTD[1]);

	if(Oyuncu[playerid][HapisDakika] >= 1)
	{
		SetPlayerPos(playerid, 215.3556, 110.7461, 999.0156);
	}
	else
	{
		SetPlayerPos(playerid, Oyuncu[playerid][Pos][0], Oyuncu[playerid][Pos][1], Oyuncu[playerid][Pos][2]);
		SetPlayerFacingAngle(playerid, Oyuncu[playerid][Pos][3]);
		SetCameraBehindPlayer(playerid);
	}
	SetPlayerHealth(playerid, 100.0);
	SetPlayerArmour(playerid, 0.0);
	if(Oyuncu[playerid][DM] == true)
	{
		SetPlayerInterior(playerid, 3);
		SetPlayerVirtualWorld(playerid, 0);
		GivePlayerWeapon(playerid, 24, 500);
		GivePlayerWeapon(playerid, 25, 500);
	}
	else
	{
		Oyuncu[playerid][ZirhHak] = false;
		Oyuncu[playerid][Oyunda] = false;
		Oyuncu[playerid][Suspect] = false;
		Oyuncu[playerid][Polis] = false;
		SetPlayerVirtualWorld(playerid, 0);
		SetPlayerInterior(playerid, 10);
		ResetPlayerWeapons(playerid);
	}
	SetPlayerColor(playerid, BEYAZ3);
	SetTimerEx("BugKontrol", 500, false, "d", playerid);
	new name[MAX_PLAYER_NAME + 1];
	GetPlayerName(playerid, name, sizeof name);
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	KillTimer(FlasorTimer[vehicleid]);
	SetTimerEx("AracSil", TIMER_SANIYE(4), false, "d", vehicleid);
    return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(newstate == PLAYER_STATE_DRIVER)
		SetPlayerArmedWeapon(playerid, 0);
	if(newstate == PLAYER_STATE_PASSENGER)
	{
	    if(GetPlayerWeapon(playerid) == 24 || Oyuncu[playerid][Beanbag] == true)
			SetPlayerArmedWeapon(playerid, 0);
	}
 	return 1;
}

public OnPlayerUpdate(playerid)
{
	if(Oyuncu[playerid][Oyunda] == false && Oyuncu[playerid][GirisYapti] == true && Oyuncu[playerid][DM] == false)
	{
	    new animlib[32], animname[32];
	    GetAnimationName(GetPlayerAnimationIndex(playerid),animlib,32,animname,32);
	    if(strcmp(animlib, "PED") == 0)
	    {
	    	if(strcmp(animname, "FIGHTA_M") == 0 || strcmp(animname, "FIGHTA_1") == 0 || strcmp(animname, "FIGHTA_2") == 0 || strcmp(animname, "FIGHTA_3") == 0 || strcmp(animname, "FIGHTA_G") == 0)
	    	{

	    		SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
				ClearAnimations(playerid);
				TogglePlayerControllable(playerid, 0);
				SetTimerEx("CBugFreeze", 500, false, "d", playerid);
	    	}
	    }
	    if(strcmp(animlib, "FIGHT_E") == 0)
	    {
	    	if(strcmp(animname, "FIGHTKICK") == 0 || strcmp(animname, "FIGHTKICK_B") == 0)
	    	{
	    		SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
				ClearAnimations(playerid);
				TogglePlayerControllable(playerid, 0);
				SetTimerEx("CBugFreeze", 500, false, "d", playerid);
	    	}
	    }
	}
    return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	new Ntusu = KEY_NO, animtusu = KEY_FIRE, egilmetusu = KEY_CROUCH, Ytusu = KEY_YES;
	if((newkeys & animtusu) && !(oldkeys & animtusu))
	{
		if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_CUFFED)
			return 1;
		if(GetPlayerSpecialAction(playerid) != SPECIAL_ACTION_NONE && Oyuncu[playerid][Anim] == true && Oyuncu[playerid][Taserlendi] == false)
		{
			Oyuncu[playerid][Anim] = false;
			SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
			ClearAnimations(playerid);
		}
	}
	
	if(oldkeys == PLAYER_STATE_DRIVER && newkeys == PLAYER_STATE_DRIVER)
	{
    	SetPlayerArmedWeapon(playerid, 0);
	}
	
	if(oldkeys == PLAYER_STATE_ONFOOT && newkeys == PLAYER_STATE_PASSENGER)
    {
        if(GetPlayerWeapon(playerid) == 24)
        {
            SetPlayerArmedWeapon(playerid, 0);
            return 1;
        }
    }
	if((newkeys & Ntusu) && !(oldkeys & Ntusu))
	{
	    if(OyunBasladi == true && Oyuncu[playerid][Polis] == true && Oyuncu[playerid][Oyunda] == true)
	    {
	    	if(Oyuncu[playerid][PolisGPS] == true)
	    	{
	    		YollaIpucuMesaj(playerid, "Deste�i kapatt�n.");
		    	Oyuncu[playerid][PolisGPS] = false;
		    	SetPlayerColor(playerid, POLIS_RENK2);
		    	return 1;
	    	}
	    	if(Oyuncu[playerid][PolisGPS] == false)
	    	{
	    		new mesaj[150], bolge[30];
	    		GetPlayer3DZone(playerid, bolge, sizeof(bolge));
	    		format(mesaj, sizeof(mesaj), "[CH:911]%s adl� memurun deste�e ihtiyac� var. B�lge: %s", Oyuncuadi(playerid), bolge);
	    		PolisTelsiz(mesaj);
		    	Oyuncu[playerid][PolisGPS] = true;
		    	SetPlayerColor(playerid, POLIS_RENK);
		    	return 1;
	    	}
		}
	}
	if((newkeys & Ytusu) && !(oldkeys & Ytusu))
	{
	    if(OyunBasladi == true && Oyuncu[playerid][Polis] == true && Oyuncu[playerid][Oyunda] == true)
	    {
			if(IsPlayerInAnyVehicle(playerid))
				return 1;
			if(Oyuncu[playerid][OyunSilah] == true)
				return 1;
			if(Oyuncu[playerid][TaserMermiDegis] == true)
				return YollaHataMesaj(playerid, "Kartu� y�kleniyor!");
			new eylem[120];
			if(Oyuncu[playerid][Taser] == true)
			{
				Oyuncu[playerid][Taser] = false;
				SetPlayerAmmo(playerid, 23, 0);
				GivePlayerWeapon(playerid, 24, 300);
				format(eylem, sizeof(eylem), "* %s �ok tabancas�n� k�l�f�na koyar.", Oyuncuadi(playerid));
				ProxDetector(15.0, playerid, eylem, EMOTE_RENK);
				return 1;
			}
			if(Oyuncu[playerid][Taser] == false)
			{
				Oyuncu[playerid][Taser] = true;
				GivePlayerWeapon(playerid, 23, 1);
				format(eylem, sizeof(eylem), "* %s �ok tabancas�n� k�l�f�ndan ��kar�r.", Oyuncuadi(playerid));
				ProxDetector(15.0, playerid, eylem, EMOTE_RENK);
				return 1;
			}
		}
	}
	if(!Oyuncu[playerid][Cbug] && GetPlayerState(playerid) == PLAYER_STATE_ONFOOT)
	{
		if(PRESSED(animtusu))
		{
			switch(GetPlayerWeapon(playerid))
			{
				case WEAPON_DEAGLE, WEAPON_SHOTGUN, WEAPON_SNIPER:
				{
					Oyuncu[playerid][CbugSilah] = gettime();
				}
			}
		}
		else if(PRESSED(egilmetusu))
		{
			if((gettime() - Oyuncu[playerid][CbugSilah]) < 1)
			{
				TogglePlayerControllable(playerid, false);
				Oyuncu[playerid][Cbug] = true;
				GameTextForPlayer(playerid, "~r~C-BUG YASAK!", 3000, 4);
				KillTimer(Oyuncu[playerid][CbugTimer]);
				Oyuncu[playerid][CbugTimer] = SetTimerEx("CBugFreeze", TIMER_SANIYE_BUCUK(1), false, "d", playerid);
			}
		}
	}
	if((newkeys & KEY_SECONDARY_ATTACK) && !(oldkeys & KEY_SECONDARY_ATTACK))
	{
		if(EventModu2 == true)
		{
			if(IsPlayerInRangeOfPoint(playerid, 2.0, 2303.5789, -68.7443, 26.4844))
			{
				SetPlayerPos(playerid, 2305.3831, -16.1079, 26.7496);
				SetPlayerInterior(playerid, 0);
				SetPlayerVirtualWorld(playerid, 0);
			}
			if(IsPlayerInRangeOfPoint(playerid, 2.0, 2305.3831, -16.1079, 26.7496))
			{
				SetPlayerPos(playerid, 2303.5789, -68.7443, 26.4844);
				SetPlayerInterior(playerid, 0);
				SetPlayerVirtualWorld(playerid, 0);
			}
			if(IsPlayerInRangeOfPoint(playerid, 2.0, 2316.6118, -70.3218, 26.4844))
			{
				SetPlayerPos(playerid, 2315.7178, 0.3387, 26.7422);
				SetPlayerInterior(playerid, 0);
				SetPlayerVirtualWorld(playerid, 0);
			}
			if(IsPlayerInRangeOfPoint(playerid, 2.0, 2315.7178, 0.3387, 26.7422))
			{
				SetPlayerPos(playerid, 2316.6118, -70.3218, 26.4844);
				SetPlayerInterior(playerid, 0);
				SetPlayerVirtualWorld(playerid, 0);
			}
		}
	}
	return 1;
}

public OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
	if(Oyuncu[playerid][Taser] == true && Oyuncu[playerid][Polis] == true)
	{
		Oyuncu[playerid][TaserMermiDegis] = true;
		SetTimerEx("TaserVer", TIMER_SANIYE(3), false, "d", playerid);
	}
	if(Oyuncu[playerid][Taser] == true && Oyuncu[playerid][Polis] == true && Oyuncu[hitid][Polis] == false && Oyuncu[hitid][Taserlendi] == false && weaponid == 23)
	{
		if(OyuncuYakinMesafe(playerid, hitid) >= 13.0)
			return YollaHataMesaj(playerid, "Hedefe yeteri kadar yak�n de�ilsin.");

		new eylem[130];
		format(eylem, sizeof(eylem), "* �ok tabancas� ile vuruldu. (( %s ))", Oyuncuadi(hitid));
		ProxDetector(15.0, hitid, eylem, EMOTE_RENK);
		TogglePlayerControllable(hitid, 0);
		Oyuncu[hitid][Taserlendi] = true;
		ApplyAnimation(hitid, "CRACK", "crckdeth2", 4.1, 0, 1, 1, 1, 1, 1);
		SetTimerEx("FreezeCoz", TIMER_SANIYE(10), false, "d", hitid);
		return 1;
	}
	if(Oyuncu[playerid][Beanbag] == true && Oyuncu[playerid][Polis] == true && Oyuncu[hitid][Polis] == false && Oyuncu[hitid][Beanbaglendi] == false && weaponid == 25)
	{
		if(OyuncuYakinMesafe(playerid, hitid) >= 20.0)
			return YollaHataMesaj(playerid, "Hedefe yeteri kadar yak�n de�ilsin.");

		new eylem[130];
		format(eylem, sizeof(eylem), "* Plastik mermiler ile vuruldu. (( %s ))", Oyuncuadi(hitid));
		ProxDetector(15.0, hitid, eylem, EMOTE_RENK);
		TogglePlayerControllable(hitid, 0);
		Oyuncu[hitid][Beanbaglendi] = true;
		ApplyAnimation(hitid, "CRACK", "crckdeth2", 4.1, 0, 1, 1, 1, 1, 1);
		SetTimerEx("FreezeCoz", TIMER_SANIYE(10), false, "d", hitid);
		return 1;
	}
	if(EventModu == false && EventModu2 == false && Oyuncu[hitid][Oyunda] == true && Oyuncu[hitid][Polis] == true && Oyuncu[playerid][Suspect] == true && SuspectAtes == false && weaponid != 0)
	{
		SuspectAtes = Oyuncu[playerid][SuspectSari] = true;
		new mesaj[150], bolge[30];
		GetPlayer3DZone(hitid, bolge, sizeof(bolge));
		format(mesaj, sizeof(mesaj), "[BODY-ALARM] %s adl� memura ate� a��ld�, t�m birimler y�nelsin! [B�lge: %s]", Oyuncuadi(hitid), bolge);
		PolisTelsiz(mesaj);
		SetPlayerColor(playerid, SARI);
		SetTimerEx("SuspectSakla", TIMER_SANIYE(15), false, "d", playerid);
		return 1;
	}
	if(EventModu == false && EventModu2 == false && Oyuncu[hitid][Oyunda] == true && Oyuncu[hitid][Polis] == true && Oyuncu[playerid][Suspect] == true && SuspectAtes == false && weaponid != 0)
	{
		SuspectAtes = false;
	    SetPlayerHealth(hitid, 100.0);
	    YollaHataMesaj(playerid, "Ate� a�mayan ��pheliye ate� a�amazs�n�z.");
		return 1;
	}
	if(EventModu == true && EventModu2 == true && Oyuncu[hitid][Polis] == true && Oyuncu[playerid][Polis] == true && weaponid != 0)
	{
	    YollaHataMesaj(playerid, "Tak�m arkada��na ate� a�amazs�n.");
		return 1;
	}
	if(EventModu == true && EventModu2 == true && Oyuncu[hitid][Suspect] == true && Oyuncu[playerid][Suspect] == true && weaponid != 0)
	{
	    YollaHataMesaj(playerid, "Tak�m arkada��na ate� a�amazs�n.");
		return 1;
	}
	if(Oyuncu[playerid][Oyunda] == true && Oyuncu[playerid][Suspect] == true && weaponid != 0 && SuspectAtes == true && EventModu == false && EventModu2 == false)
	{
		if(Oyuncu[playerid][SuspectSari] == true)
			return 1;
		Oyuncu[playerid][SuspectSari] = true;
	    SetPlayerColor(playerid, SARI);
	    SetTimerEx("SuspectSakla", TIMER_SANIYE(15), false, "d", playerid);
		return 1;
	}
	return 1;
}

forward TaserVer(playerid);
public TaserVer(playerid)
{
	if(Oyuncu[playerid][Oyunda] == false)
		return 1;

	Oyuncu[playerid][TaserMermiDegis] = false;
	GivePlayerWeapon(playerid, 23, 1);
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	if(Oyuncu[playerid][DM] == true)
	{
		new sayi = random(8);
		sscanf(DMKonum(sayi), "p<,>fff", Oyuncu[playerid][Pos][0], Oyuncu[playerid][Pos][1], Oyuncu[playerid][Pos][2]);
		SetSpawnInfo(playerid, 0, Oyuncu[playerid][Kiyafet], Oyuncu[playerid][Pos][0], Oyuncu[playerid][Pos][1], Oyuncu[playerid][Pos][2], Oyuncu[playerid][Pos][3], 0, 0, 0, 0, 0, 0);
		if(killerid == INVALID_PLAYER_ID)
			YollaIpucuMesaj(playerid, "�e�itli nedenlerden dolay� �ld�n.");
		else
		{
			YollaIpucuMesaj(playerid, "%s taraf�ndan �ld�r�ld�n.", Oyuncuadi(killerid));
			Oyuncu[killerid][Oldurme]++;
			Oyuncu[playerid][Olum]++;
		}
		return 1;
	}
	if(Oyuncu[playerid][aktifduel] == true)
	{
		if(killerid == INVALID_PLAYER_ID)
			YollaIpucuMesaj(playerid, "�e�itli nedenlerden dolay� �ld�n.");
		else
		{
			YollaIpucuMesaj(playerid, "%s taraf�ndan �ld�r�ld�n.", Oyuncuadi(killerid));
			YollaHerkeseMesaj(-1, ""DUEL2"[DUEL]"DUEL2" %s adl� oyuncu %s adl� oyuncuya kar�� olan duelloyu kazand�.", Oyuncuadi(killerid), Oyuncuadi(playerid));
			LobiyeDon(killerid);
			Oyuncu[playerid][aktifduel] = false;
			Oyuncu[killerid][aktifduel] = false;
		}
		return 1;
	}
	if(OyunBasladi == true && Oyuncu[playerid][Oyunda] == true && Oyuncu[killerid][Oyunda] == true && Oyuncu[playerid][Polis] == true && Oyuncu[killerid][Polis])
    {
        SkorVer(killerid, -3);
    	return 1;
    }
	if(Oyuncu[killerid][Oyunda] == true)
		SendDeathMessage(killerid, playerid, reason);
	if(OyunBasladi == true)
		OyunKontrol();
	if(OyunBasladi == true && Oyuncu[playerid][Polis] == true)
	{
		new sayi = random(22);
		sscanf(LobiKonum(sayi), "p<,>fff", Oyuncu[playerid][Pos][0], Oyuncu[playerid][Pos][1], Oyuncu[playerid][Pos][2]);
		SetSpawnInfo(playerid, 0, Oyuncu[playerid][Kiyafet], Oyuncu[playerid][Pos][0], Oyuncu[playerid][Pos][1], Oyuncu[playerid][Pos][2], Oyuncu[playerid][Pos][3], 0, 0, 0, 0, 0, 0);

		Oyuncu[playerid][Oyunda] = Oyuncu[playerid][Suspect] = Oyuncu[playerid][Polis] = false;
		if(killerid == INVALID_PLAYER_ID)
			YollaIpucuMesaj(playerid, "�e�itli nedenlerden dolay� �ld�n.");
		else
		{
			YollaIpucuMesaj(playerid, "%s taraf�ndan �ld�r�ld�n.", Oyuncuadi(killerid));
		}
		OyunKontrol();
		return 1;
	}
	if(OyunBasladi == true && Oyuncu[playerid][Suspect] == true)
	{
		new sayi = random(22);
		sscanf(LobiKonum(sayi), "p<,>fff", Oyuncu[playerid][Pos][0], Oyuncu[playerid][Pos][1], Oyuncu[playerid][Pos][2]);
		SetSpawnInfo(playerid, 0, Oyuncu[playerid][Kiyafet], Oyuncu[playerid][Pos][0], Oyuncu[playerid][Pos][1], Oyuncu[playerid][Pos][2], Oyuncu[playerid][Pos][3], 0, 0, 0, 0, 0, 0);
		Oyuncu[playerid][Oyunda] = Oyuncu[playerid][Suspect] = Oyuncu[playerid][Polis] = false;
		if(killerid == INVALID_PLAYER_ID)
			YollaIpucuMesaj(playerid, "�e�itli nedenlerden dolay� �ld�n.");
		else
		{
			YollaIpucuMesaj(playerid, "%s taraf�ndan �ld�r�ld�n.", Oyuncuadi(killerid));
		}
		OyunKontrol();
		return 1;
	}
	new sayi = random(22);
	sscanf(LobiKonum(sayi), "p<,>fff", Oyuncu[playerid][Pos][0], Oyuncu[playerid][Pos][1], Oyuncu[playerid][Pos][2]);
	SetSpawnInfo(playerid, 0, Oyuncu[playerid][Kiyafet], Oyuncu[playerid][Pos][0], Oyuncu[playerid][Pos][1], Oyuncu[playerid][Pos][2], Oyuncu[playerid][Pos][3], 0, 0, 0, 0, 0, 0);
	return 1;
}
public OnPlayerCommandPerformed(playerid, cmd[], params[], result, flags)
{
	printf("%s: /%s", Oyuncuadi(playerid), cmd);
    if(result == -1)
    	return YollaHataMesaj(playerid, "Ge�ersiz komut, /yardim komutuna bak�n.");
    return 1;
}
stock SwapSeat(playerid, userid)
{
    if(!IsPlayerConnected(playerid) || !IsPlayerConnected(userid)) return 1;
    if(!IsPlayerInAnyVehicle(playerid) || !IsPlayerInAnyVehicle(userid)) return 1;
    new vehicleid = GetPlayerVehicleID(playerid);
    if(!IsPlayerInVehicle(userid, vehicleid)) return 1;
    new t_seat[2];
    t_seat[0] = GetPlayerVehicleSeat(playerid);
    t_seat[1] = GetPlayerVehicleSeat(userid);
    new Float:t_Pos[3];
    GetVehiclePos(vehicleid, t_Pos[0], t_Pos[1], t_Pos[2]);
    SetPlayerPos(playerid, t_Pos[0], t_Pos[1], t_Pos[2] + 3.0);
    SetPlayerPos(userid, t_Pos[0], t_Pos[1], t_Pos[2] + 3.0);
    SetTimerEx("timer_SwapSeat", 300, false, "ddd", playerid, vehicleid, t_seat[1]);
    SetTimerEx("timer_SwapSeat", 300, false, "ddd", userid, vehicleid, t_seat[0]);
    return 1;
}

stock IsPlayerInWater(playerid)
{
        new Float:Z;
        GetPlayerPos(playerid,Z,Z,Z);
        if (Z < 0.7) switch (GetPlayerAnimationIndex(playerid)) { case 1543,1538,1539: return 1; }
        if (GetPlayerDistanceFromPoint(playerid,-965,2438,42) <= 700 && Z < 45)return 1;
        new Float:water_places[][] =
        {
                {25.0,  2313.0, -1417.0,        23.0},
                {15.0,  1280.0, -773.0,         1082.0},
                {15.0,  1279.0, -804.0,         86.0},
                {20.0,  1094.0, -674.0,         111.0},
                {26.0,  194.0,  -1232.0,        76.0},
                {25.0,  2583.0, 2385.0,         15.0},
                {25.0,  225.0,  -1187.0,        73.0},
                {50.0,  1973.0, -1198.0,        17.0}
        };
        for (new t=0; t < sizeof water_places; t++)
                if (GetPlayerDistanceFromPoint(playerid,water_places[t][1],water_places[t][2],water_places[t][3]) <= water_places[t][0]) return 1;
        return 0;
}

forward timer_SwapSeat(playerid, vehicleid, seatid);
public timer_SwapSeat(playerid, vehicleid, seatid)
{
    if(!IsPlayerConnected(playerid)) return 1;
    if(!IsValidVehicle(vehicleid)) return 1;
    PutPlayerInVehicle(playerid, vehicleid, seatid);
    return 1;
}

public OnPlayerCommandReceived(playerid, cmd[], params[], flags)
{
	if(!Oyuncu[playerid][GirisYapti]) return 0;
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch (dialogid)
	{
		case DIALOG_SWAPSEATS:
        {
            if(!response) return YollaHataMesaj(Oyuncu[playerid][SWID], "Ki�i koltuk de�i�tirme iste�inizi reddetti.");
            if (response)
            {
                new vehicleid = GetPlayerVehicleID(playerid);
                new vehicleid2 = GetPlayerVehicleID(Oyuncu[playerid][SWID]);
                if (vehicleid != vehicleid2) return YollaHataMesaj(playerid, "Ayn� ara�ta de�ilsiniz.");
                SwapSeat(playerid, Oyuncu[playerid][SWID]);
            }
        }
		case DIALOG_X: return 1;
		case DIALOG_GIRIS:
		{
			if(!response) return Kick(playerid);
			new hashed_pass[65];
			SHA256_PassHash(inputtext, Oyuncu[playerid][SSakla], hashed_pass, 65);
			if(strcmp(hashed_pass, Oyuncu[playerid][Sifre]) == 0)
			{
				YollaHerkeseMesaj(0x008000FF, "[B�LG�]"#BEYAZ2" %s sunucuya giri� yapt�.", Oyuncuadi(playerid));
				TextDrawShowForPlayer(playerid, PublicTD[0]);
				TextDrawShowForPlayer(playerid, PublicTD[1]);
				cache_set_active(Oyuncu[playerid][CacheID]);
				cache_delete(Oyuncu[playerid][CacheID]);
				Oyuncu[playerid][CacheID] = MYSQL_INVALID_CACHE;
				Oyuncu[playerid][GirisYapti] = true;
				Oyuncu[playerid][AFK] = false;
				new sayi = random(22);
				sscanf(LobiKonum(sayi), "p<,>fff", Oyuncu[playerid][Pos][0], Oyuncu[playerid][Pos][1], Oyuncu[playerid][Pos][2]);
				SetSpawnInfo(playerid, 0, Oyuncu[playerid][Kiyafet], Oyuncu[playerid][Pos][0], Oyuncu[playerid][Pos][1], Oyuncu[playerid][Pos][2], Oyuncu[playerid][Pos][3], 0, 0, 0, 0, 0, 0);
				SpawnPlayer(playerid);
				SetTimerEx("BugKontrol", 500, false, "d", playerid);
				SetPlayerPos(playerid, Oyuncu[playerid][Pos][0], Oyuncu[playerid][Pos][1], Oyuncu[playerid][Pos][2]);
				SetPlayerFacingAngle(playerid, Oyuncu[playerid][Pos][3]);
				SetPlayerScore(playerid, Oyuncu[playerid][Skor]);
				SetCameraBehindPlayer(playerid);
				SetPlayerColor(playerid, BEYAZ3);
				SetPlayerVirtualWorld(playerid, 0);
				SetPlayerInterior(playerid, 10);
				SetPlayerSkin(playerid, Oyuncu[playerid][Kiyafet]);
				Oyuncu[playerid][Hud] = true;
				PlayerTextDrawShow(playerid, Textdraw0[playerid]);
				PlayerTextDrawShow(playerid, Textdraw1[playerid]);
				Baslat();
		     	if(Oyuncu[playerid][SusturDakika] >= 1)
		     		Oyuncu[playerid][SusturTimer] = SetTimerEx("OyuncuSustur", TIMER_DAKIKA(1), true, "d", playerid);
		     	if(Oyuncu[playerid][HapisDakika] >= 1)
		     	{
		     		Oyuncu[playerid][HapisTimer] = SetTimerEx("OyuncuHapis", TIMER_DAKIKA(1), true, "d", playerid);
		     		JailGonder(playerid);
		     	}
			}
			else
			{
				Oyuncu[playerid][GirisDenemeleri]++;
				if(Oyuncu[playerid][GirisDenemeleri] >= 3)
				{
					ShowPlayerDialog(playerid, DIALOG_X, DIALOG_STYLE_MSGBOX, "Giri�", "�ifrenizi bir�ok kez yanl�� girdiniz bu sebepten at�ld�n�z.", "Kapat", "");
					return Kickle(playerid);
				}
				else ShowPlayerDialog(playerid, DIALOG_GIRIS, DIALOG_STYLE_PASSWORD, "Giri�", "Yanl�� �ifre girdin!\nA�a��daki alana l�tfen �ifrenizi girin:", "Giri�", "��k��");
			}
		}
		case DIALOG_KAYIT:
		{
			if(!response) return Kick(playerid);
			if(strlen(inputtext) <= 4) return ShowPlayerDialog(playerid, DIALOG_KAYIT, DIALOG_STYLE_PASSWORD, "Kay�t", "�ifreniz 5 karakterden uzun olmal�.\nL�tfen �ifrenizi girin:", "Kay�t", "��k��");
			for(new i = 0; i < 16; i++) Oyuncu[playerid][SSakla][i] = random(94) + 33;
			SHA256_PassHash(inputtext, Oyuncu[playerid][SSakla], Oyuncu[playerid][Sifre], 65);
            Oyuncu[playerid][OyuncuAdi] = Oyuncuadi(playerid);
			new sorgu[250];
			mysql_format(CopSQL, sorgu, sizeof(sorgu), "INSERT INTO `hesaplar` (`isim`, `sifre`, `sifresakla`) VALUES ('%e', '%s', '%e')", Oyuncu[playerid][OyuncuAdi], Oyuncu[playerid][Sifre], Oyuncu[playerid][SSakla]);
			mysql_tquery(CopSQL, sorgu, "OyuncuYeniKayit", "d", playerid);
		}
		case TANITIM:
		{
			if(!response) return Kick(playerid);
			ShowPlayerDialog(playerid, TANITIM2, DIALOG_STYLE_MSGBOX, ""#SUNUCUKISALTMA" - TANITIM", "{FF0000}Oyun Modu\n{FFFFFF}Polisler kazand���nda b�t�n polisler +2 skor al�r.\n��pheliler kazand���nda b�t�n ��pheliler +4 skor al�r.\nE�er tak�m arkada��n�za zarar veriseniz skorunuz d��er.\nBunun yan�nda donator oldu�unuzda skorlarda art�� g�rebilirsiniz.\nBizden sana tam 5 skor! �yi oyunlar.","Kapat", "");
			SetPlayerScore(playerid, Oyuncu[playerid][Skor] +5);
			Oyuncu[playerid][AFK] = false;
			OyuncuGuncelle(playerid);
		}
		case DIALOG_MP3:
		{
		    if(!response) return 1;
			switch(listitem)
			{
  				case 0:
				{
					PlayAudioStreamForPlayer(playerid, "http://fenomen.listenfenomen.com/fenomen/128/icecast.audio");
				}
				case 1:
				{
					PlayAudioStreamForPlayer(playerid, "http://fenomen.listenfenomen.com/fenomenrap/128/icecast.audio");
				}
				case 2:
				{
					PlayAudioStreamForPlayer(playerid, "http://fenomen.listenfenomen.com/fenomenturk/128/icecast.audio");
					
				}
				case 3:
				{
					PlayAudioStreamForPlayer(playerid, "http://fenomen.listenfenomen.com/fenomenakustik/128/icecast.audio");
					
				}
				case 4:
				{
					PlayAudioStreamForPlayer(playerid, "http://fenomenoriental.listenfenomen.com/fenomenpop/128/icecast.audio");
					
				}
				case 5:
				{
					PlayAudioStreamForPlayer(playerid, "http://powerturkakustik.listenpowerapp.com/powerturkakustik/mpeg/icecast.audio");
					
				}
				case 6:
				{
					StopAudioStreamForPlayer(playerid);
					YollaIpucuMesaj(playerid, "MP3'� kapatt�n.");
				}
			}
			
		}
			    case DIALOG_LOADOUT_COP:
     	{
		    if(!response) return 1;
			switch(listitem)
			{
				case 0:
				{
					ShowPlayerDialog(playerid, DIALOG_LOADOUT_COP_PISTOL, DIALOG_STYLE_LIST ,"LV:PP Loadout", "{FFFFFF}Desert Eagle{97de5d}(0 Skor)\n{FFFFFF}Colt-45{97de5d}(120 Skor)\n{FFFFFF}TEC-9{97de5d}(200 Skor)", "Se�", "Kapat");
				}
				case 1:
				{
					ShowPlayerDialog(playerid, DIALOG_LOADOUT_COP_RIFLE, DIALOG_STYLE_LIST ,"LV:PP Loadout", "{FFFFFF}M4 Rifle{97de5d}(250 Skor)\n{FFFFFF}AK-47{97de5d}(300 Skor)\n{FFFFFF}Shotgun{97de5d}(25 Skor)\n{FFFFFF}MP5{97de5d}(0 Skor)", "Se�", "Kapat");
				}
				case 2:
				{
					ShowPlayerDialog(playerid, DIALOG_LOADOUT_COP_HEAVYRIFLE, DIALOG_STYLE_LIST ,"LV:PP Loadout", "{FFFFFF}Shotgun{97de5d}(600 Skor)\n{FFFFFF}Rifle{97de5d}(8000 Skor)", "Se�", "Kapat");
				}
			}
      	}
	    case DIALOG_LOADOUT_FUGITIVE:
     	{
		    if(!response) return 1;
			switch(listitem)
			{
				case 0:
				{
					ShowPlayerDialog(playerid, DIALOG_LOADOUT_FUGITIVE_PISTOL, DIALOG_STYLE_LIST ,"LV:PP Loadout", "{FFFFFF}Desert Eagle{97de5d}(0 Skor)\n{FFFFFF}Colt-45{97de5d}(120 Skor)\n{FFFFFF}TEC-9{97de5d}(200 Skor)", "Se�", "Kapat");
				}
				case 1:
				{
					ShowPlayerDialog(playerid, DIALOG_LOADOUT_FUGITIVE_RIFLE, DIALOG_STYLE_LIST ,"LV:PP Loadout", "{FFFFFF}M4 Rifle{97de5d}(500 Skor)\n{FFFFFF}AK-47{97de5d}(0 Skor)\n{FFFFFF}Shotgun{97de5d}(100 Skor)\n{FFFFFF}MP5{97de5d}(75 Skor)", "Se�", "Kapat");
				}
				case 2:
				{
					ShowPlayerDialog(playerid, DIALOG_LOADOUT_FUGITIVE_HEAVYR, DIALOG_STYLE_LIST ,"LV:PP Loadout", "{FFFFFF}Shotgun{97de5d}(600 Skor)\n{FFFFFF}Rifle{97de5d}(8000 Skor)", "Se�", "Kapat");
				}
			}
      	}
      	case DIALOG_LOADOUT_FUGITIVE_PISTOL:
      	{
		    if(!response) return 1;
			switch(listitem)
			{
			    case 0:
			    {
			        YollaIpucuMesaj(playerid, "Birincil silah�n�z Desert Eagle olarak ayarland�.");
			        Oyuncu[playerid][FGLoadout1] = 24;
			    }
			    case 1:
			    {
			        if (Oyuncu[playerid][Skor] < 120) return YollaHataMesaj(playerid, "Skorunuz yetersiz.");
			    	YollaIpucuMesaj(playerid, "Birincil silah�n�z Colt-45 olarak ayarland�.");
			    	Oyuncu[playerid][FGLoadout1] = 22;
			    }
			    case 2:
			    {
			        if (Oyuncu[playerid][Skor] < 200) return YollaHataMesaj(playerid, "Skorunuz yetersiz.");
			        YollaIpucuMesaj(playerid, "Birincil silah�n�z TEC-9 olarak ayarland�.");
			        Oyuncu[playerid][FGLoadout1] = 32;
			    }
			}
      	}
      	case DIALOG_LOADOUT_COP_PISTOL:
      	{
		    if(!response) return 1;
			switch(listitem)
			{
			    case 0:
			    {
			        YollaIpucuMesaj(playerid, "Birincil silah�n�z Desert Eagle olarak ayarland�.");
			        Oyuncu[playerid][PDLoadout1] = 24;
			    }
			    case 1:
			    {
			        if (Oyuncu[playerid][Skor] < 120) return YollaHataMesaj(playerid, "Skorunuz yetersiz.");
			    	YollaIpucuMesaj(playerid, "Birincil silah�n�z Colt-45 olarak ayarland�.");
			    	Oyuncu[playerid][PDLoadout1] = 22;
			    }
			    case 2:
			    {
			        if (Oyuncu[playerid][Skor] < 200) return YollaHataMesaj(playerid, "Skorunuz yetersiz.");
			        YollaIpucuMesaj(playerid, "Birincil silah�n�z TEC-9 olarak ayarland�.");
			        Oyuncu[playerid][PDLoadout1] = 32;
			    }
			}
      	}
      	case DIALOG_LOADOUT_FUGITIVE_RIFLE:
      	{
		    if(!response) return 1;
			switch(listitem)
			{
			    case 0:
			    {
			        if (Oyuncu[playerid][Skor] < 500) return YollaHataMesaj(playerid, "Skorunuz yetersiz.");
			        YollaIpucuMesaj(playerid, "�kincil silah�n�z M4 olarak ayarland�.");
			        Oyuncu[playerid][FGLoadout2] = 31;
			    }
			    case 1:
			    {
			    	YollaIpucuMesaj(playerid, "�kincil silah�n�z AK-47 olarak ayarland�.");
			    	Oyuncu[playerid][FGLoadout2] = 30;
			    }
			    case 2:
			    {
			        if (Oyuncu[playerid][FGLoadout3] == 25) return YollaHataMesaj(playerid, "���nc�l silah�n�zda zaten bu model var.");
			        if (Oyuncu[playerid][Skor] < 100) return YollaHataMesaj(playerid, "Skorunuz yetersiz.");
			    	YollaIpucuMesaj(playerid, "�kincil silah�n�z Shotgun olarak ayarland�.");
			    	Oyuncu[playerid][FGLoadout2] = 25;
			    }
			    case 3:
			    {
			        if (Oyuncu[playerid][Skor] < 75) return YollaHataMesaj(playerid, "Skorunuz yetersiz.");
			    	YollaIpucuMesaj(playerid, "�kincil silah�n�z MP5 olarak ayarland�.");
			    	Oyuncu[playerid][FGLoadout2] = 29;
			    }
			}
      	}
      	case DIALOG_LOADOUT_COP_RIFLE:
      	{
		    if(!response) return 1;
			switch(listitem)
			{
			    case 0:
			    {
			        if (Oyuncu[playerid][Skor] < 250) return YollaHataMesaj(playerid, "Skorunuz yetersiz.");
			        YollaIpucuMesaj(playerid, "�kincil silah�n�z M4 olarak ayarland�.");
			        Oyuncu[playerid][PDLoadout2] = 31;
			    }
			    case 1:
			    {
			    	if (Oyuncu[playerid][Skor] < 300) return YollaHataMesaj(playerid, "Skorunuz yetersiz.");
			    	YollaIpucuMesaj(playerid, "�kincil silah�n�z AK-47 olarak ayarland�.");
			    	Oyuncu[playerid][PDLoadout2] = 30;
			    }
			    case 2:
			    {
			        if (Oyuncu[playerid][PDLoadout3] == 25) return YollaHataMesaj(playerid, "���nc�l silah�n�zda zaten bu model var.");
			        if (Oyuncu[playerid][Skor] < 25) return YollaHataMesaj(playerid, "Skorunuz yetersiz.");
			    	YollaIpucuMesaj(playerid, "�kincil silah�n�z Shotgun olarak ayarland�.");
			    	Oyuncu[playerid][PDLoadout2] = 25;
			    }
			    case 3:
			    {
			    	YollaIpucuMesaj(playerid, "�kincil silah�n�z MP5 olarak ayarland�.");
			    	Oyuncu[playerid][PDLoadout2] = 29;
			    }
			}
      	}
      	case DIALOG_LOADOUT_FUGITIVE_HEAVYR:
      	{
		    if(!response) return 1;
			switch(listitem)
			{
			    case 0:
			    {
			    	if (Oyuncu[playerid][FGLoadout2] == 25) return YollaHataMesaj(playerid, "�kincil silah�n�zda zaten bu model var.");
			        if (Oyuncu[playerid][Skor] < 600) return YollaHataMesaj(playerid, "Skorunuz yetersiz.");
			        YollaIpucuMesaj(playerid, "���nc�l silah�n�z Shotgun olarak ayarland�.");
			        Oyuncu[playerid][FGLoadout3] = 25;
			    }
			    case 1:
			    {
			    	if (Oyuncu[playerid][Skor] < 8000) return YollaHataMesaj(playerid, "Skorunuz yetersiz.");
			    	YollaIpucuMesaj(playerid, "���nc�l silah�n�z Rifle olarak ayarland�.");
			    	Oyuncu[playerid][FGLoadout3] = 33;
			    }
			}
      	}
      	case DIALOG_LOADOUT_COP_HEAVYRIFLE:
      	{
		    if(!response) return 1;
			switch(listitem)
			{
			    case 0:
			    {
			    	if (Oyuncu[playerid][PDLoadout2] == 25) return YollaHataMesaj(playerid, "�kincil silah�n�zda zaten bu model var.");
			        if (Oyuncu[playerid][Skor] < 600) return YollaHataMesaj(playerid, "Skorunuz yetersiz.");
			        YollaIpucuMesaj(playerid, "���nc�l silah�n�z Shotgun olarak ayarland�.");
			        Oyuncu[playerid][PDLoadout3] = 25;
			    }
			    case 1:
			    {
			    	if (Oyuncu[playerid][Skor] < 8000) return YollaHataMesaj(playerid, "Skorunuz yetersiz.");
			    	YollaIpucuMesaj(playerid, "���nc�l silah�n�z Rifle olarak ayarland�.");
			    	Oyuncu[playerid][PDLoadout3] = 33;
			    }
			}
      	}
		
		case ASILAHAL:
		{
		    if(!response) return 1;
			switch(listitem)
			{
				case 0:
				{
				    new eylem[150];
					if(Oyuncu[playerid][Skor] < 350)
					    return YollaHataMesaj(playerid, "Skorun yeterli de�il.");
					GivePlayerWeapon(playerid, 31, 150);
					format(eylem, sizeof(eylem), "* %s arac�n panelinden M4A1 Carbine model silah�n� al�r.", Oyuncuadi(playerid));
					ProxDetector(15.0, playerid, eylem, EMOTE_RENK);
				}
			
			}

		}
		

		case DIALOG_SUSPECTSKIN:
		{
			if(!response) return 1;
			if (Oyuncu[playerid][Oyunda] == true) return YollaHataMesaj(playerid, "Oyun ba�lam��, bunu yapamazs�n.");
			Oyuncu[playerid][sKiyafet] = SupheliSkinler[listitem];
			SetPlayerSkin(playerid, SupheliSkinler[listitem]);
			YollaIpucuMesaj(playerid, "��pheli k�yafetini %d olarak de�i�tirdin.", SupheliSkinler[listitem]);
		}

		case DIALOG_PSKIN:
		{
			if(!response) return 1;
			if (Oyuncu[playerid][Oyunda] == true) return YollaHataMesaj(playerid, "Oyun ba�lam��, bunu yapamazs�n.");
			Oyuncu[playerid][pKiyafet] = PolisSkinler[listitem];
			SetPlayerSkin(playerid, PolisSkinler[listitem]);
			YollaIpucuMesaj(playerid, "Polis k�yafetini %d olarak de�i�tirdin.", PolisSkinler[listitem]);
		}

		case DIALOG_ARACDEGISTIR:
		{
			if(!response) return 1;
			switch(listitem)
			{
				case 0: Oyuncu[playerid][PolisArac] = 596;
				case 1: Oyuncu[playerid][PolisArac] = 597;
				case 2:	Oyuncu[playerid][PolisArac] = 598;
				case 3: Oyuncu[playerid][PolisArac] = 599;
				case 4: Oyuncu[playerid][PolisArac] = 523;
				case 5:
				{
					if(Oyuncu[playerid][Donator] == true || Oyuncu[playerid][Skor] >= 250)
					{
						Oyuncu[playerid][PolisArac] = 528;
					}
					else
					{
						YollaHataMesaj(playerid, "Donator de�ilsiniz yada 500 skorunuz bulunmuyor.");
						ShowPlayerDialog(playerid, DIALOG_ARACDEGISTIR, DIALOG_STYLE_LIST, ""#SUNUCU_KISALTMA" - Ara� De�i�tir", "Police Car (LSPD)\nPolice Car (SFPD)\nPolice Car (SASD)\nPolice Ranger\nHPV1000\nFBI Truck\nPremier\nBullet [DONATOR]\nBuffalo [DONATOR]\nSultan [DONATOR] / 500+ Skor", "De�i�tir", "Kapat");
						return 1;
					}
				}
				case 6: Oyuncu[playerid][PolisArac] = 426;
				case 7:
				{
					if(Oyuncu[playerid][Donator] == false)
					{
						YollaHataMesaj(playerid, "Donator de�ilsiniz.");
						ShowPlayerDialog(playerid, DIALOG_ARACDEGISTIR, DIALOG_STYLE_LIST, ""#SUNUCU_KISALTMA" - Ara� De�i�tir", "Police Car (LSPD)\nPolice Car (SFPD)\nPolice Car (SASD)\nPolice Ranger\nHPV1000\nFBI Truck\nPremier\nBullet [DONATOR]\nBuffalo [DONATOR]\nSultan [DONATOR] / 500+ Skor", "De�i�tir", "Kapat");
						return 1;
					}
					Oyuncu[playerid][PolisArac] = 541;
				}
				case 8:
				{
					if(Oyuncu[playerid][Donator] == false)
					{
						YollaHataMesaj(playerid, "Donator de�ilsiniz.");
						ShowPlayerDialog(playerid, DIALOG_ARACDEGISTIR, DIALOG_STYLE_LIST, ""#SUNUCU_KISALTMA" - Ara� De�i�tir", "Police Car (LSPD)\nPolice Car (SFPD)\nPolice Car (SASD)\nPolice Ranger\nHPV1000\nFBI Truck\nPremier\nBullet [DONATOR]\nBuffalo [DONATOR]\nSultan [DONATOR] / 500+ Skor", "De�i�tir", "Kapat");
						return 1;
					}
					Oyuncu[playerid][PolisArac] = 402;
				}
				case 9:
				{
					if(Oyuncu[playerid][Donator] == true || Oyuncu[playerid][Skor] >= 500)
					{
						Oyuncu[playerid][PolisArac] = 560;
					}
					else
					{
						YollaHataMesaj(playerid, "Donator de�ilsiniz yada 500 skorunuz bulunmuyor.");
						ShowPlayerDialog(playerid, DIALOG_ARACDEGISTIR, DIALOG_STYLE_LIST, ""#SUNUCU_KISALTMA" - Ara� De�i�tir", "Police Car (LSPD)\nPolice Car (SFPD)\nPolice Car (SASD)\nPolice Ranger\nHPV1000\nFBI Truck\nPremier\nBullet [DONATOR]\nBuffalo [DONATOR]\nSultan [DONATOR] / 500+ Skor", "De�i�tir", "Kapat");
						return 1;
					}
				}
			}
			YollaIpucuMesaj(playerid, "Ki�isel arac�n�z de�i�tirildi.");
		}
		case DIALOG_DISIMDEGISTIR:
		{
			if(!response) return 1;
			ShowPlayerDialog(playerid, DIALOG_DISIMDEGISTIR2, DIALOG_STYLE_INPUT, ""#SUNUCU_KISALTMA" - �sim De�i�tirme", ""#BEYAZ2"Yeni kullan�c� ad�n�z� a�a��daki bo�lu�a girin.", "Tamam", "�ptal");
		}
		case DIALOG_DISIMDEGISTIR2:
		{
			if(!response) return 1;
		    if(strlen(inputtext) > MAX_PLAYER_NAME)
		    	return YollaHataMesaj(playerid, "�sim aral��� 1-24 uzunlu�unda olmal�d�r.");
		    format(inputtext, MAX_PLAYER_NAME, "%s", TRcevir(inputtext));
	    	if(IsPlayerConnected(ReturnUser(inputtext)))
	    	{
				ShowPlayerDialog(playerid, DIALOG_DISIMDEGISTIR2, DIALOG_STYLE_INPUT, ""#SUNUCU_KISALTMA" - �sim De�i�tirme", ""#BEYAZ2"Yeni kullan�c� ad�n�z� a�a��daki bo�lu�a girin.", "Tamam", "�ptal");
				YollaHataMesaj(playerid, "Bu isim kullan�l�yor.");
				return 1;
	    	}
		    new sorgu[150], Cache: sorguj;
			mysql_format(CopSQL, sorgu, sizeof(sorgu), "SELECT * FROM hesaplar WHERE isim = '%s'", inputtext);
			sorguj = mysql_query(CopSQL, sorgu);
			if(cache_num_rows())
			{
				ShowPlayerDialog(playerid, DIALOG_DISIMDEGISTIR2, DIALOG_STYLE_INPUT, ""#SUNUCU_KISALTMA" - �sim De�i�tirme", ""#BEYAZ2"Yeni kullan�c� ad�n�z� a�a��daki bo�lu�a girin.", "Tamam", "�ptal");
				YollaHataMesaj(playerid, "Bu isim kullan�l�yor.");
				return 1;
			}
			cache_delete(sorguj);
		    YollaIpucuMesaj(playerid, "�sminiz %s olarak de�i�tirildi.", inputtext);
			Oyuncu[playerid][IsimHak] = true;
			SetPlayerName(playerid, inputtext);
			format(Oyuncu[playerid][OyuncuAdi], MAX_PLAYER_NAME, "%s", inputtext);
			mysql_format(CopSQL, sorgu, sizeof(sorgu), "UPDATE `hesaplar` SET `isim` = '%s', `isimhak` = '%i' WHERE `ID` = %d LIMIT 1", inputtext, Oyuncu[playerid][IsimHak], Oyuncu[playerid][SQLID]);
			mysql_tquery(CopSQL, sorgu);
		}
		case DIALOG_BSILAHAL:
		{
			if(!response)
			{
				new aracid = GetClosestVehicle(playerid, 4.0);
				GetVehicleParamsEx(aracid, engine, lights, alarm, doors, bonnet, boot, objective);
				SetVehicleParamsEx(aracid, engine, lights, alarm, doors, bonnet, VEHICLE_PARAMS_OFF, objective);
				return 1;
			}
			switch(listitem)
			{
				case 0:
				{
					if(Oyuncu[playerid][Skor] < 50)
						return YollaHataMesaj(playerid, "Yeterli skorunuz bulunmuyor.");
					if(Oyuncu[playerid][Silah][0] == true)
						return YollaHataMesaj(playerid, "Bu silaha zaten sahipsin.");
					if(Oyuncu[playerid][Beanbag] == true)
						return YollaHataMesaj(playerid, "Beanbag'e sahipken bu silah� alamazs�n!");
					new eylem[150];
					format(eylem, sizeof(eylem), "* %s bagaj� a�t� ve Shotgun model silah� ��kartt�.", Oyuncuadi(playerid));
					ProxDetector(15.0, playerid, eylem, EMOTE_RENK);
					GivePlayerWeapon(playerid, 25, 500);
					Oyuncu[playerid][Silah][0] = true;
					new aracid = GetClosestVehicle(playerid, 4.0);
					GetVehicleParamsEx(aracid, engine, lights, alarm, doors, bonnet, boot, objective);
					SetVehicleParamsEx(aracid, engine, lights, alarm, doors, bonnet, VEHICLE_PARAMS_OFF, objective);
				}
				case 1:
				{
					if(Oyuncu[playerid][Skor] < 140)
						return YollaHataMesaj(playerid, "Yeterli skorunuz bulunmuyor.");
					if(Oyuncu[playerid][Silah][1] == true)
						return YollaHataMesaj(playerid, "Bu silaha zaten sahipsin.");
					new eylem[150];
					format(eylem, sizeof(eylem), "* %s bagaj� a�t� ve MP5 model silah� ��kartt�.", Oyuncuadi(playerid));
					ProxDetector(15.0, playerid, eylem, EMOTE_RENK);
					GivePlayerWeapon(playerid, 29, 500);
					Oyuncu[playerid][Silah][1] = true;
					new aracid = GetClosestVehicle(playerid, 4.0);
					GetVehicleParamsEx(aracid, engine, lights, alarm, doors, bonnet, boot, objective);
					SetVehicleParamsEx(aracid, engine, lights, alarm, doors, bonnet, VEHICLE_PARAMS_OFF, objective);
				}
				case 2:
				{
					if(Oyuncu[playerid][Skor] < 210)
						return YollaHataMesaj(playerid, "Yeterli skorunuz bulunmuyor.");
					if(Oyuncu[playerid][Silah][2] == true)
						return YollaHataMesaj(playerid, "Bu silaha zaten sahipsin.");
					new eylem[150];
					format(eylem, sizeof(eylem), "* %s bagaj� a�t� ve Rifle model silah� ��kartt�.", Oyuncuadi(playerid));
					ProxDetector(15.0, playerid, eylem, EMOTE_RENK);
					GivePlayerWeapon(playerid, 33, 500);
					Oyuncu[playerid][Silah][2] = true;
					new aracid = GetClosestVehicle(playerid, 4.0);
					GetVehicleParamsEx(aracid, engine, lights, alarm, doors, bonnet, boot, objective);
					SetVehicleParamsEx(aracid, engine, lights, alarm, doors, bonnet, VEHICLE_PARAMS_OFF, objective);
				}
				case 3:
				{
					if(Oyuncu[playerid][Skor] < 360)
						return YollaHataMesaj(playerid, "Yeterli skorunuz bulunmuyor.");
					if(Oyuncu[playerid][Silah][3] == true)
						return YollaHataMesaj(playerid, "Bu silaha zaten sahipsin.");
					new eylem[150];
					format(eylem, sizeof(eylem), "* %s bagaj� a�t� ve M4 model silah� ��kartt�.", Oyuncuadi(playerid));
					ProxDetector(15.0, playerid, eylem, EMOTE_RENK);
					GivePlayerWeapon(playerid, 31, 500);
					Oyuncu[playerid][Silah][3] = true;
					new aracid = GetClosestVehicle(playerid, 4.0);
					GetVehicleParamsEx(aracid, engine, lights, alarm, doors, bonnet, boot, objective);
					SetVehicleParamsEx(aracid, engine, lights, alarm, doors, bonnet, VEHICLE_PARAMS_OFF, objective);
				}
				case 4:
				{
					if(Oyuncu[playerid][Donator] == false && Oyuncu[playerid][Skor] < 950)
						return YollaHataMesaj(playerid, "Donator de�ilsiniz yada yeterli skorunuz bulunmuyor.");
					if(Oyuncu[playerid][Silah][4] == true)
						return YollaHataMesaj(playerid, "Bu silaha zaten sahipsin.");
					new eylem[150];
					format(eylem, sizeof(eylem), "* %s bagaj� a�t� ve Sniper Rifle model silah� ��kartt�.", Oyuncuadi(playerid));
					ProxDetector(15.0, playerid, eylem, EMOTE_RENK);
					GivePlayerWeapon(playerid, 34, 500);
					Oyuncu[playerid][Silah][4] = true;
					new aracid = GetClosestVehicle(playerid, 4.0);
					GetVehicleParamsEx(aracid, engine, lights, alarm, doors, bonnet, boot, objective);
					SetVehicleParamsEx(aracid, engine, lights, alarm, doors, bonnet, VEHICLE_PARAMS_OFF, objective);
				}
				case 5:
				{
					if(Oyuncu[playerid][Donator] == false)
						return YollaHataMesaj(playerid, "Donator de�ilsin.");
					if(Oyuncu[playerid][Silah][5] == true)
						return YollaHataMesaj(playerid, "Bu silaha zaten sahipsin.");
					new eylem[150];
					format(eylem, sizeof(eylem), "* %s bagaj� a�t� ve Combat Shotgun model silah� ��kartt�.", Oyuncuadi(playerid));
					ProxDetector(15.0, playerid, eylem, EMOTE_RENK);
					GivePlayerWeapon(playerid, 27, 500);
					Oyuncu[playerid][Silah][5] = true;
					new aracid = GetClosestVehicle(playerid, 4.0);
					GetVehicleParamsEx(aracid, engine, lights, alarm, doors, bonnet, boot, objective);
					SetVehicleParamsEx(aracid, engine, lights, alarm, doors, bonnet, VEHICLE_PARAMS_OFF, objective);
				}
				case 6:
				{
					if(Oyuncu[playerid][Donator] == false)
						return YollaHataMesaj(playerid, "Donator de�ilsin.");
					if(Oyuncu[playerid][Silah][6] == true)
						return YollaHataMesaj(playerid, "Bu silaha zaten sahipsin.");
					new eylem[150];
					format(eylem, sizeof(eylem), "* %s bagaj� a�t� ve Sawn-Off Shotgun model silah� ��kartt�.", Oyuncuadi(playerid));
					ProxDetector(15.0, playerid, eylem, EMOTE_RENK);
					GivePlayerWeapon(playerid, 26, 500);
					Oyuncu[playerid][Silah][6] = true;
					new aracid = GetClosestVehicle(playerid, 4.0);
					GetVehicleParamsEx(aracid, engine, lights, alarm, doors, bonnet, boot, objective);
					SetVehicleParamsEx(aracid, engine, lights, alarm, doors, bonnet, VEHICLE_PARAMS_OFF, objective);
				}
			}
		}
		case DIALOG_OYUNMODU:
		{
			if(!response)
			{
				Oyuncu[playerid][OyunModu] = false;
				OyunModuTip = 1;
				KillTimer(Oyuncu[playerid][OyunModTimer]);
				YollaHerkeseMesaj(0x008000FF, "[B�LG�]"#BEYAZ2" Oyun modu "#KIRMIZI2"Non-RP"#BEYAZ2" olarak se�ildi, oyunu bu moda g�re devam ettirin!");
				foreach(new i : Player)
				{
					if(Oyuncu[i][GirisYapti] == true && Oyuncu[i][Oyunda] == true)
					{
						TogglePlayerControllable(i, 1);
					}
				}
				return 1;
			}
			OyunModuTip = 2;
			Oyuncu[playerid][OyunModu] = false;
			KillTimer(Oyuncu[playerid][OyunModTimer]);
			YollaHerkeseMesaj(0x008000FF, "[B�LG�]"#BEYAZ2" Oyun modu "#YESIL2"Roleplay"#BEYAZ2" olarak se�ildi, oyunu bu moda g�re devam ettirin!");
			foreach(new i : Player)
			{
				if(Oyuncu[i][GirisYapti] == true && Oyuncu[i][Oyunda] == true)
				{
					TogglePlayerControllable(i, 1);
				}
			}
		}
		default: return 0;
	}
	return 1;
}

CMD:afix(playerid, params[])
{
    if (Oyuncu[playerid][GirisYapti] == false) return 0;
	if (Oyuncu[playerid][Yonetici] < 1) return YollaHataMesaj(playerid, "Yetersiz yetki.");
	new aracid;
	if(sscanf(params, "u", aracid))
		return YollaKullanMesaj(playerid, "/afix [Ara� ID]");
	new Panels, Doors, Lights, Tires;
	GetVehicleDamageStatus(aracid, Panels, Doors, Lights, Tires);
	SetVehicleHealth(aracid, 1000);
	AracHasar[aracid] = false;
	RepairVehicle(aracid);
	Oyuncu[playerid][AracTamir] = true;
	YollaIpucuMesaj(playerid, "%d ID'ye sahip arac� tamir ettin.", aracid);
	return 1;
}

CMD:araccagir(playerid)
{
    if (Oyuncu[playerid][GirisYapti] == false) return 0;
	if (Oyuncu[playerid][Oyunda] == false) return YollaHataMesaj(playerid, "Oyunda de�ilsiniz.");
	if (IsPlayerInAnyVehicle(playerid)) return YollaHataMesaj(playerid, "Ara�tayken bunu yapamazs�n.");
	if (Oyuncu[playerid][Skor] < 2000) return YollaHataMesaj(playerid, "Minimum 1000 skor olmal�s�n�z.");
	if (Oyuncu[playerid][Polis] == false) return YollaHataMesaj(playerid, "Bunu sadece polis iken yapabilirsin.");
	if(Oyuncu[playerid][RequestCar] == true) return YollaHataMesaj(playerid, "Her el sadece bir kez yapabilirsin.");
	new Float:pos[3];
	GetPlayerPos(playerid, pos[0],pos[1],pos[2]);
	new aracid = AddStaticVehicleEx(Oyuncu[playerid][PolisArac], pos[0], pos[1], pos[2], 0, 0, 1, -1, 1);
	SetVehicleParamsEx(aracid, VEHICLE_PARAMS_ON, lights2, alarm2, doors2, bonnet2, boot2, objective2);
	Oyuncu[playerid][RequestCar] = true;
	Oyuncu[playerid][Para] -= 10000;
	foreach (new i : Player)
	{
		if (Oyuncu[i][Oyunda] == true)
		{
		    if (Oyuncu[i][Donator] == true)
				YollaDefaultMesaj(i, "{c44fbb}Donator {ffffff}%s yan�na ara� getirdi.", Oyuncuadi(playerid));
			else if (Oyuncu[i][Yonetici] >= 1)
			    YollaDefaultMesaj(i, "%s {ffffff}%s yan�na ara� getirdi.", YoneticiYetkiAdi(Oyuncu[playerid][Yonetici]), Oyuncuadi(playerid));
			else
				YollaDefaultMesaj(i, "Oyuncu {ffffff}%s yan�na ara� getirdi.", Oyuncuadi(playerid));
		}

	}
	return 1;
}

CMD:fix(playerid)
{
    if (Oyuncu[playerid][GirisYapti] == false) return 0;
	if (Oyuncu[playerid][Oyunda] == false) return YollaHataMesaj(playerid, "Oyunda de�ilsiniz.");
	if (Oyuncu[playerid][Donator] == false) return YollaHataMesaj(playerid, "Donator olmal�s�n�z.");
	if (!IsPlayerInAnyVehicle(playerid)) return YollaHataMesaj(playerid, "Ara�ta olmal�s�n�z.");
	if(Oyuncu[playerid][AracTamir] == true) return YollaHataMesaj(playerid, "Her el sadece bir kez yapabilirsin.");
	new aracid = GetPlayerVehicleID(playerid);
	new Panels, Doors, Lights, Tires;
	GetVehicleDamageStatus(aracid, Panels, Doors, Lights, Tires);
	SetVehicleHealth(aracid, 1000);
	AracHasar[aracid] = false;
	RepairVehicle(aracid);
	Oyuncu[playerid][AracTamir] = true;
	foreach (new i : Player)
	{
		if (Oyuncu[i][Oyunda] == true)
		    YollaHataMesaj(i, "{c44fbb}Donator {ffffff}%s arac�n� tamir etti.", Oyuncuadi(playerid));
	}
	return 1;
}

CMD:swapseats(playerid, params[])
{
    if (Oyuncu[playerid][GirisYapti] == false) return 0;
	new mesaj[200];
	new userid;
	if (Oyuncu[playerid][SWTimer] != 0) return YollaHataMesaj(playerid, "Tekrar koltuk de�i�tirme iste�i g�ndermek i�in biraz beklemelisiniz.");
	if (!IsPlayerInAnyVehicle(playerid)) return YollaHataMesaj(playerid, "Ara�ta olmal�s�n�z.");
	if (sscanf(params, "u", userid))
	    return YollaHataMesaj(playerid, "/swapseats [ID]");
	if (GetPlayerVehicleID(playerid) != GetPlayerVehicleID(userid)) return YollaHataMesaj(playerid, "Ayn� ara�ta de�ilsiniz.");
	Oyuncu[userid][SWID] = playerid;
	Oyuncu[userid][SWSeat] = GetPlayerVehicleSeat(playerid);
	Oyuncu[playerid][SWID] = userid;
	Oyuncu[playerid][SWSeat] = GetPlayerVehicleSeat(userid);
	Oyuncu[playerid][SWTimer] = 60;
	format(mesaj, sizeof(mesaj), "%s adl� oyuncu sizinle koltuklar� de�i�tirmek istiyor.", Oyuncuadi(playerid));
	ShowPlayerDialog(userid, DIALOG_SWAPSEATS, DIALOG_STYLE_MSGBOX, "{FF0000}Swapseats", mesaj, "{00FF00}Kabul Et", "{FF0000}Reddet");
	return 1;
}

CMD:wp(playerid)
{
    if (Oyuncu[playerid][GirisYapti] == false) return 0;
    if(!IsPlayerInAnyVehicle(playerid)) return YollaHataMesaj(playerid, "Bir ara�ta de�ilsin.");
    if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER) return YollaHataMesaj(playerid, "��f�rken bu komutu kullanamazs�n�z.");
    if(GetPlayerWeapon(playerid) == 0) return YollaHataMesaj(playerid, "Elinde silah yok.");
    new vehicleid = GetPlayerVehicleID(playerid), seat = GetPlayerVehicleSeat(playerid), Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z), TogglePlayerControllable(playerid, 0);
    SetPlayerPos(playerid, x, y, z + 3);
    SetTimerEx("timer_DriveBy", 250, false, "dddd", playerid, vehicleid, seat, GetPlayerWeapon(playerid));
    return 1;
}

CMD:flip(playerid)
{
    if (Oyuncu[playerid][GirisYapti] == false) return 0;
	if (Oyuncu[playerid][Oyunda] == false) return YollaHataMesaj(playerid, "Oyunda de�ilsiniz.");
	if (Oyuncu[playerid][Donator] == false) return YollaHataMesaj(playerid, "Donator olmal�s�n�z.");
	if (!IsPlayerInAnyVehicle(playerid)) return YollaHataMesaj(playerid, "Ara�ta olmal�s�n�z.");
	if(Oyuncu[playerid][AracFlip] == true) return YollaHataMesaj(playerid, "Her el sadece bir kez yapabilirsin.");
	new aracid = GetPlayerVehicleID(playerid);
	new Float:fAngle;
    GetVehicleZAngle(aracid, fAngle);
    SetVehicleZAngle(aracid, fAngle);
    SetVehicleVelocity(aracid, 0.0, 0.0, 0.0);
	Oyuncu[playerid][AracFlip] = true;
	foreach (new i : Player)
	{
		if (Oyuncu[i][Oyunda] == true)
		    YollaDefaultMesaj(i, "{c44fbb}Donator {ffffff}%s arac�n� �evirdi.", Oyuncuadi(playerid));
	}
	return 1;
}

CMD:nitrous(playerid)
{
	if (Oyuncu[playerid][GirisYapti] == false) return 0;
	if (Oyuncu[playerid][Oyunda] == false) return YollaHataMesaj(playerid, "Oyunda de�ilsin.");
	if (Oyuncu[playerid][Donator] == false) return YollaHataMesaj(playerid, "Minimum 1000 skora sahip olmal� veya donator olmal�s�n.");
	if (!IsPlayerInAnyVehicle(playerid)) return YollaHataMesaj(playerid, "Ara�ta olmal�s�n.");
	if (Oyuncu[playerid][Para] < 1500) return YollaHataMesaj(playerid, "Yetersiz para. ($1500)");
	if (Oyuncu[playerid][Suspect] == false) return YollaHataMesaj(playerid, "Bunu sadece ��pheli iken yapabilirsin.");
	if(Oyuncu[playerid][AracNitro] == true) return YollaHataMesaj(playerid, "Her el sadece bir kez yapabilirsin.");
 	new component = GetVehicleComponentInSlot(GetPlayerVehicleID(playerid), CARMODTYPE_NITRO);
 	if (component == 1010) return YollaHataMesaj(playerid, "Bu ara�ta zaten nitro var.");
	new aracid = GetPlayerVehicleID(playerid);
	Oyuncu[playerid][AracNitro] = true;
	AddVehicleComponent(aracid, 1010); // Nitro
	new eylem[150];
    format(eylem, sizeof(eylem), "* %s arac�na nitro ekler.", Oyuncuadi(playerid));
    SetPlayerChatBubble(playerid, eylem, EMOTE_RENK, 30.0, 2000);
    YollaIpucuMesaj(playerid, "$1500 kar��l���nda arac�na nitro ekledin.");
	return 1;
}

CMD:bicycle(playerid)
{
    if (Oyuncu[playerid][GirisYapti] == false) return 0;
	if (Oyuncu[playerid][Oyunda] == false) return YollaHataMesaj(playerid, "Oyunda de�ilsiniz.");
	if (Oyuncu[playerid][Donator] == false) return YollaHataMesaj(playerid, "Donator olmal�s�n�z.");
	if (IsPlayerInAnyVehicle(playerid)) return YollaHataMesaj(playerid, "Ara�tayken bunu yapamazs�n.");
	if(Oyuncu[playerid][Bisiklet] == true) return YollaHataMesaj(playerid, "Her el sadece bir kez yapabilirsin.");
	new Float:pos[3];
	GetPlayerPos(playerid, pos[0],pos[1],pos[2]);
	new aracid = CreateVehicle(510, pos[0], pos[1], pos[2], 0, -1, -1, 1);
	SetVehicleParamsEx(aracid, VEHICLE_PARAMS_ON, lights2, alarm2, doors2, bonnet2, boot2, objective2);
	Oyuncu[playerid][Bisiklet] = true;
	foreach (new i : Player)
	{
		if (Oyuncu[i][Oyunda] == true)
		    YollaDefaultMesaj(i, "{c44fbb}Donator {ffffff}%s yan�na bisiklet olu�turdu.", Oyuncuadi(playerid));
	}
	return 1;
}

CMD:ahelp(playerid, params[])
{
	if(Oyuncu[playerid][Yonetici] < 1)
		return 1;
    
	YollaFormatMesaj(playerid, -1, "MODERATOR: /mjail - /a - /baslat - /cc - /kick - /spawn - /slap - /uyari - /aspec - /aspecoff, - /aduty");
	YollaFormatMesaj(playerid, -1, "MODERATOR: /h - /raporkabul -/raporred - /restart - /sustur");
	if(Oyuncu[playerid][Yonetici] >= 2)
	{
		YollaFormatMesaj(playerid, -1, "GAME ADMIN: /ban - /setvw - /setint - /goto - /gethere - /sethp - /freeze - /sustur");
		YollaFormatMesaj(playerid, -1, "GAME ADMIN: /jail - /unjail - /engelsifirla - /dmkitle - /cezaver");
	}
	if(Oyuncu[playerid][Yonetici] >= 3)
	{
		YollaFormatMesaj(playerid, -1, "LEAD ADMIN: /offban - /unban - /makehelper - /gotopos - /getcar - /gotocar - /setweather - /settime");
		YollaFormatMesaj(playerid, -1, "LEAD ADMIN: /setskin - /setname - /setscore - /setarmor - /freeze2 - /fkapat - /muzik,");
	}
	if(Oyuncu[playerid][Yonetici] >= 4)
		YollaFormatMesaj(playerid, -1, "SERVER MANAGEMENT: /makeadmin - /donatoryap - /event - /bakim - /dox - /gmx");
	return 1;
}

CMD:baslat(playerid, params[])
{
	if(Oyuncu[playerid][Yonetici] < 1)
		return 1;

	Baslat();
	return 1;
}

CMD:a(playerid, params[])
{
	if(Oyuncu[playerid][Yonetici] < 1)
		return 1;
	new mesaj[150];
	if(sscanf(params, "s[150]", mesaj))
		return YollaKullanMesaj(playerid, "/a [mesaj]");
	YollaYoneticiMesaj(1, YONETIM_RENK, "[YONETIM] %s %s - (%d):"#BEYAZ2" %s", YoneticiYetkiAdi(Oyuncu[playerid][Yonetici]), Oyuncuadi(playerid), playerid, mesaj);
	return 1;
}

CMD:h(playerid, params[])
{
	if(Oyuncu[playerid][Yonetici] < 1 && Oyuncu[playerid][Helper] == false)
		return 1;
        
	new mesaj[150];
	if(sscanf(params, "s[150]", mesaj))
		return YollaKullanMesaj(playerid, "/h [mesaj]");
	YollaHelperMesaj(YONETIM_RENK, "[HELPER] %s :"#BEYAZ2" %s", Oyuncuadi(playerid), mesaj);
	return 1;
}

CMD:ban(playerid, params[])
{
	if(Oyuncu[playerid][Yonetici] <= 1)
		return 1;

	new hedefid, sebep[65], gun, ipadresi[16], sorgu[325], banmesaj[190], banstr[390];
    if(sscanf(params, "uds[65]", hedefid, gun, sebep))
 	{
		YollaKullanMesaj(playerid, "/ban [hedef ad�/ID] [g�n] [sebep]");
		YollaIpucuMesaj(playerid, "Hedefi s�resiz yasaklamak istiyorsan�z g�n k�sm�na 0 yaz�n.");
		return 1;
	}
	if(strlen(sebep) < 3 || strlen(sebep) > 24)
		return YollaHataMesaj(playerid, "Oyuncuyu yasaklama sebebiniz 3 ve 24 karakter aras�nda olmal�d�r.");
	if(gun < 0 || gun > 365)
		return YollaHataMesaj(playerid, "Oyuncuyu yasaklamak i�in belirtilen g�n 0 ve 365 g�n aras�nda olmal�d�r.");
	if(!IsPlayerConnected(hedefid))
		return OyundaDegilMesaj(playerid);

	if(Oyuncu[hedefid][Yonetici] >= 1)
	{
	    if(Oyuncu[playerid][Yonetici] <= 3)	return YollaHataMesaj(playerid, "Bu ki�i y�netici yasaklayamazs�n.");
	}
	GetPlayerIp(hedefid, ipadresi, 16);
	if(gun == 0)
	{
		mysql_format(CopSQL, sorgu, sizeof(sorgu), "INSERT INTO `yasaklar` (`yasakID`, `yasaklanan`, `yasaklayan`, `sebep`, `yasakip`, `bitis`, `islemtarih`, `bitistarih`) VALUES ('%d', '%s', '%s', '%s', '%s', '0', NOW(), 'Yok')", bosYasakID(), Oyuncuadi(hedefid), Oyuncuadi(playerid), sebep, ipadresi);
		mysql_tquery(CopSQL, sorgu);
		format(banmesaj, sizeof(banmesaj), "\n"#SUNUCU_RENK2"S�resiz yasakland�n, yanl�� oldu�unu d���n�yorsan�z '"#BEYAZ2"www.rpp.net"#SUNUCU_RENK2"' adresinden y�neticilere bildirin.");
		strcat(banstr, banmesaj);
		format(banmesaj, sizeof(banmesaj), "\n\n"#SUNUCU_RENK2"Yasaklayan: "#BEYAZ2"%s\n"#SUNUCU_RENK2"Sebep: "#BEYAZ2"%s\n"#SUNUCU_RENK2"Tarih: "#BEYAZ2"%s", Oyuncuadi(playerid), sebep, Tarih(gettime()));
		strcat(banstr, banmesaj);
		ShowPlayerDialog(hedefid, DIALOG_X, DIALOG_STYLE_MSGBOX, ""#BEYAZ2""#SUNUCU_KISALTMA"", banstr, ""#BEYAZ2"Kapat", "");
		YollaHerkeseMesaj(0xD01717FF, "[B�LG�]"#BEYAZ2" %s, %s adl� oyuncuyu sunucudan s�resiz yasaklad�. (Sebep: %s)", Oyuncuadi(playerid), Oyuncuadi(hedefid), sebep);
		Kickle(hedefid);
	}
	else
	{
		new bitistarih = gettime() + (gun * 86400);
		mysql_format(CopSQL, sorgu, sizeof(sorgu), "INSERT INTO `yasaklar` (`yasakID`, `yasaklanan`, `yasaklayan`, `sebep`, `yasakip`, `bitis`, `islemtarih`, `bitistarih`) VALUES ('%d', '%s', '%s', '%s', '%s', '%d', '%d', NOW())", bosYasakID(), Oyuncuadi(hedefid), Oyuncuadi(playerid), sebep, ipadresi, bitistarih, gettime());
		mysql_tquery(CopSQL, sorgu);
		format(banmesaj, sizeof(banmesaj), "\n"#SUNUCU_RENK2"Yasakland�n, yanl�� oldu�unu d���n�yorsan�z '"#BEYAZ2"www.rpp.net"#SUNUCU_RENK2"' adresinden y�neticilere bildirin.");
		strcat(banstr, banmesaj);
		format(banmesaj, sizeof(banmesaj), "\n\n"#SUNUCU_RENK2"Yasaklayan: "#BEYAZ2"%s\n"#SUNUCU_RENK2"Sebep: "#BEYAZ2"%s\n"#SUNUCU_RENK2"Tarih: "#BEYAZ2"%s\n"#SUNUCU_RENK2"Biti� Tarihi: "#BEYAZ2"%s", Oyuncuadi(playerid), sebep, Tarih(gettime()), Tarih(bitistarih));
		strcat(banstr, banmesaj);
		ShowPlayerDialog(hedefid, DIALOG_X, DIALOG_STYLE_MSGBOX, ""#BEYAZ2""#SUNUCU_KISALTMA"", banstr, ""#BEYAZ2"Kapat", "");
	    YollaHerkeseMesaj(0xD01717FF, "[B�LG�]"#BEYAZ2" %s, %s adl� oyuncuyu %d g�n sunucudan yasaklad�. (Sebep: %s)", Oyuncuadi(playerid), Oyuncuadi(hedefid), gun, sebep);
	    Kickle(hedefid);

	}
	return 1;
}

CMD:offban(playerid, params[])
{
	if(Oyuncu[playerid][Yonetici] <= 2)
		return 1;

	new sebep[65], gun, sorgu[325], isim[24], Cache: sorguj;
    if(sscanf(params, "s[24]ds[65]", isim, gun, sebep))
 	{
		YollaKullanMesaj(playerid, "/offban [isim] [g�n] [sebep]");
		YollaIpucuMesaj(playerid, "Hedefi s�resiz yasaklamak istiyorsan�z g�n k�sm�na 0 yaz�n.");
		return 1;
	}
	if(strlen(sebep) < 3 || strlen(sebep) > 24)
		return YollaIpucuMesaj(playerid, "Oyuncuyu yasaklama sebebiniz 3 ve 24 karakter aras�nda olmal�d�r.");
	if(gun < 0 || gun > 365)
		return YollaIpucuMesaj(playerid, "Oyuncuyu yasaklamak i�in belirtilen g�n 0 ve 365 g�n aras�nda olmal�d�r.");
	if(strlen(isim) < 5 || strlen(isim) > 24)
		return YollaIpucuMesaj(playerid, "Oyuncu ismi 5 ve 24 karakter aras�nda olmal�d�r.");
	if(IsPlayerConnected(ReturnUser(isim)))
		return YollaIpucuMesaj(playerid, "Oyuncu oyunda, /ban komutunu kullan�n.");

	mysql_format(CopSQL, sorgu, sizeof(sorgu), "SELECT * FROM yasaklar WHERE yasaklanan = '%s'", isim);
	sorguj = mysql_query(CopSQL, sorgu);
	new veriler = cache_num_rows(), ipadresi[30];
	if(veriler)
		return YollaHataMesaj(playerid, "%s adl� oyuncu zaten yasakl�.", isim);
    cache_get_value(0, "ipadresi", ipadresi, 30);
	if(gun == 0)
	{
		mysql_format(CopSQL, sorgu, sizeof(sorgu), "INSERT INTO `yasaklar` (`yasakID`, `yasaklanan`, `yasaklayan`, `sebep`, `yasakip`, `bitis`, `islemtarih`, `bitistarih`) VALUES ('%d', '%s', '%s', '%s', '%s', '0', NOW(), 'Yok')", bosYasakID(), isim, Oyuncuadi(playerid), sebep, ipadresi);
		mysql_tquery(CopSQL, sorgu);
		YollaIpucuMesaj(playerid, "%s adl� oyuncu yasakland�.", isim);
	}
	else
	{
		new bitistarih = gettime() + (gun * 86400);
		mysql_format(CopSQL, sorgu, sizeof(sorgu), "INSERT INTO `yasaklar` (`yasakID`, `yasaklanan`, `yasaklayan`, `sebep`, `yasakip`, `bitis`, `islemtarih`, `bitistarih`) VALUES ('%d', '%s', '%s', '%s', '%s', '%d', '%d', NOW())", bosYasakID(), isim, Oyuncuadi(playerid), sebep, ipadresi, bitistarih, gettime());
		mysql_tquery(CopSQL, sorgu);
		YollaIpucuMesaj(playerid, "%s adl� oyuncu %d g�n yasakland�.", isim, gun);
	}
	cache_delete(sorguj);
	return 1;
}

CMD:unban(playerid, params[])
{
	if(Oyuncu[playerid][Yonetici] <= 2)
		return 1;

	new isim[35], sorgu[125], Cache: sorguj;
    if(sscanf(params, "s[35]", isim))
		return YollaKullanMesaj(playerid, "/unban [isim]");
	if(strlen(isim) < 4 || strlen(isim) > 24)
		return YollaHataMesaj(playerid, "Oyuncu ismi 4 ve 24 karakter aras�nda olmal�d�r.");

	mysql_format(CopSQL, sorgu, sizeof(sorgu), "SELECT * FROM yasaklar WHERE yasaklanan = '%s'", isim);
	sorguj = mysql_query(CopSQL, sorgu);
	new veriler = cache_num_rows();
	if(veriler)
	{
		YollaIpucuMesaj(playerid, "%s adl� oyuncu yasaklamas�n� kald�rd�n.", isim);
		mysql_format(CopSQL, sorgu, sizeof(sorgu), "DELETE FROM yasaklar WHERE yasaklanan = '%s'", isim);
		mysql_tquery(CopSQL, sorgu);
	}
	else YollaHataMesaj(playerid, "%s adl� oyuncu yasakl� de�il.", isim);
	cache_delete(sorguj);
	return 1;
}

CMD:makeadmin(playerid, params[])
{
	if(Oyuncu[playerid][Yonetici] < 3)
		return 1;
	new hedefid, yetki;
    if(sscanf(params, "ui", hedefid, yetki))
    	return YollaKullanMesaj(playerid, "/makeadmin [hedef ad�/ID] [seviye]");
    if(!IsPlayerConnected(hedefid))
		return OyundaDegilMesaj(playerid);
	if(yetki < 0 || yetki > 4)
		return YollaHataMesaj(playerid, "Y�netici yetkileri 0 ve 4 aras�nda olmal�d�r.");

	if(yetki == 0)
	{
	    if(Oyuncu[hedefid][Yonetici] == 0)
	        return YollaHataMesaj(playerid, "Hedef y�netici de�il.");

		YollaYoneticiMesaj(1, 0x008000FF, "[B�LG�]"#BEYAZ2" %s, %s ki�isini y�neticilikten ��kard�.", Oyuncuadi(playerid), Oyuncuadi(hedefid));
	}
	new string[135];
	format(string, sizeof(string), "%s, %s ki�isini %d seviyesinde y�netici yapt�.", Oyuncuadi(playerid), Oyuncuadi(hedefid), yetki);
	Oyuncu[hedefid][Yonetici] = yetki;
	YollaYoneticiMesaj(1, 0x008000FF, "[B�LG�]"#BEYAZ2" %s, %s ki�isini %d seviyesinde y�netici yapt�.", Oyuncuadi(playerid), Oyuncuadi(hedefid), yetki);
	return 1;
}

CMD:makehelper(playerid, params[])
{
	if(Oyuncu[playerid][Yonetici] < 2)
		return 1;
	new hedefid;
    if(sscanf(params, "u", hedefid))
    	return YollaKullanMesaj(playerid, "/makehelper [hedef ad�/ID]");
    if(!IsPlayerConnected(hedefid))
		return OyundaDegilMesaj(playerid);
	if(Oyuncu[hedefid][Yonetici] >= 1)
		return YollaHataMesaj(playerid, "Y�netici olan birisini helper yapamazs�n.");

    if(Oyuncu[hedefid][Helper] == true)
    {
    	Oyuncu[hedefid][Helper] = false;
        return YollaYoneticiMesaj(1, 0x008000FF, "[B�LG�]"#BEYAZ2" %s, %s ki�isini helperl�ktan ��kard�.", Oyuncuadi(playerid), Oyuncuadi(hedefid));
    }
	Oyuncu[hedefid][Helper] = true;
	YollaYoneticiMesaj(1, 0x008000FF, "[B�LG�]"#BEYAZ2" %s, %s ki�isini helper yapt�.", Oyuncuadi(playerid), Oyuncuadi(hedefid));
	return 1;
}

CMD:setvw(playerid, params[])
{
	if(Oyuncu[playerid][Yonetici] <= 1)
		return 1;

	new hedefid, miktar;
    if(sscanf(params, "ud", hedefid, miktar))
    	return YollaKullanMesaj(playerid, "/setvw [hedef ad�/ID] [miktar]");
    if(!IsPlayerConnected(hedefid))
		return OyundaDegilMesaj(playerid);

	SetPlayerVirtualWorld(hedefid, miktar);
	YollaIpucuMesaj(hedefid, "%s VW'ni %d yapt�.", Oyuncuadi(playerid), miktar);
	YollaIpucuMesaj(playerid, "%s ki�isinin VW'sini %d yapt�n.", Oyuncuadi(hedefid), miktar);
	return 1;
}

CMD:setint(playerid, params[])
{
	if(Oyuncu[playerid][Yonetici] <= 1)
		return 1;

	new hedefid, miktar;
    if(sscanf(params, "ud", hedefid, miktar))
    	return YollaKullanMesaj(playerid, "/setint [hedef ad�/ID] [miktar]");
    if(!IsPlayerConnected(hedefid))
		return OyundaDegilMesaj(playerid);

	SetPlayerInterior(hedefid, miktar);
	YollaIpucuMesaj(hedefid, "%s interiorunu %d yapt�.", Oyuncuadi(playerid), miktar);
	YollaIpucuMesaj(playerid, "%s ki�isinin interiorunu %d yapt�n.", Oyuncuadi(hedefid), miktar);
	return 1;
}

CMD:gotopos(playerid, params[])
{
	if(Oyuncu[playerid][Yonetici] < 3)
		return 1;
	new Float: pos[3], int;
	if(sscanf(params, "fffd", pos[0], pos[1], pos[2], int)) 
		return YollaKullanMesaj(playerid, "/gotopos [X] [Y] [Z] [Interior]");

	YollaIpucuMesaj(playerid, "Girilen koordinatlara teleport oldun. (Interior: %d)", int);
	SetPlayerPos(playerid, pos[0], pos[1], pos[2]);
	SetPlayerInterior(playerid, int);
	return 1;
}

CMD:kick(playerid, params[])
{
	if(Oyuncu[playerid][Yonetici] < 1)
		return 1;

	new hedefid, sebep[30], kickmesaj[155], kickstr[255];
    if(sscanf(params, "us[30]", hedefid, sebep))
    	return YollaKullanMesaj(playerid, "/kick [hedef ad�/ID] [sebep]");
    if(!IsPlayerConnected(hedefid))
		return OyundaDegilMesaj(playerid);
	if(strlen(sebep) < 3 || strlen(sebep) > 24)
		return YollaHataMesaj(playerid, "Kick sebebi 3 ve en fazla 24 harfden olu�mal�d�r.");

	format(kickmesaj, sizeof(kickmesaj), "\n"#SUNUCU_RENK2"At�ld�n�z, yanl�� oldu�unu d���n�yorsan�z '"#BEYAZ2""#SUNUCU_WEB""#SUNUCU_RENK2"' adresinden y�neticilere bildirin.");
	strcat(kickstr, kickmesaj);
	format(kickmesaj, sizeof(kickmesaj), "\n\n"#SUNUCU_RENK2"Atan yetkili: "#BEYAZ2"%s\n"#SUNUCU_RENK2"Sebep: "#BEYAZ2"%s\n"#SUNUCU_RENK2"Tarih: "#BEYAZ2"%s", Oyuncuadi(playerid), sebep, Tarih(gettime()));
	strcat(kickstr, kickmesaj);
	ShowPlayerDialog(hedefid, DIALOG_X, DIALOG_STYLE_MSGBOX, ""#BEYAZ2""#SUNUCU_KISALTMA"", kickstr, ""#BEYAZ2"Kapat", "");

	YollaHerkeseMesaj(0xD01717FF, "[B�LG�]"#BEYAZ2" %s, %s adl� oyuncuyu sunucudan kickledi. (Sebep: %s)", Oyuncuadi(playerid), Oyuncuadi(hedefid), sebep);
	Kickle(hedefid);
	return 1;
}

CMD:admins(playerid, params[])
{
	new aktifyonetici = 0;
	foreach(new i : Player)
	{
		if(Oyuncu[i][Yonetici] >= 1)
		{
			YollaIpucuMesaj(playerid, "[%s] %s", YoneticiYetkiAdi(Oyuncu[i][Yonetici]), Oyuncuadi(i));
			aktifyonetici++;
        }
	}
	if(aktifyonetici == 0)
		return YollaHataMesaj(playerid, "�evrimi�i y�netici yok.");
	return 1;
}

CMD:helpers(playerid, params[])
{
	new aktifhelper = 0;
	foreach(new i : Player)
	{
		if(Oyuncu[i][Helper] == true)
		{
			YollaIpucuMesaj(playerid, "["#SARI2"Helper"#BEYAZ2"] - %s", Oyuncuadi(i));
			aktifhelper++;
        }
	}
	if(aktifhelper == 0)
		return YollaHataMesaj(playerid, "�evrimi�i helper yok.");
	return 1;
}

CMD:afk(playerid, params[])
{
	if(Oyuncu[playerid][HapisDakika] >= 1)
		return YollaHataMesaj(playerid, "Hapiste komut kullanamazs�n.");
	if(Oyuncu[playerid][AFK] == false)
	{
		YollaHerkeseMesaj(0x008000FF, "[B�LG�]"#BEYAZ2" %s, �uan AFK!", Oyuncuadi(playerid));
		Oyuncu[playerid][AFK] = true;
		return 1;
	}
	if(Oyuncu[playerid][AFK] == true)
	{
		YollaHerkeseMesaj(0x008000FF, "[B�LG�]"#BEYAZ2" %s, AFK'dan ayr�ld�!", Oyuncuadi(playerid));
		Oyuncu[playerid][AFK] = false;
		Baslat();
		return 1;
	}
	return 1;
}

CMD:goto(playerid, params[])
{
	if(Oyuncu[playerid][Yonetici] <= 1)
		return 1;
	new hedefid, Float: hedefPos[3];
    if(sscanf(params, "u", hedefid))
    	return YollaKullanMesaj(playerid, "/goto [hedef ad�/ID]");
    if(!IsPlayerConnected(hedefid))
		return OyundaDegilMesaj(playerid);

	GetPlayerPos(hedefid, hedefPos[0], hedefPos[1], hedefPos[2]);
	SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(hedefid));
	SetPlayerInterior(playerid, GetPlayerInterior(hedefid));
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
		new arac = GetPlayerVehicleID(playerid);
		SetVehiclePos(arac, hedefPos[0], hedefPos[1]+3, hedefPos[2]);
	}
	else
	{
		SetPlayerPos(playerid, hedefPos[0], hedefPos[1]+2, hedefPos[2]);
	}
	YollaIpucuMesaj(hedefid, "%s adl� y�netici yan�na ���nland�.", Oyuncuadi(playerid));
	YollaIpucuMesaj(playerid, "%s adl� oyuncunun yan�na ���nland�n.", Oyuncuadi(hedefid));
	return 1;
}

CMD:gethere(playerid, params[])
{
	if(Oyuncu[playerid][Yonetici] <= 1)
		return 1;

	new hedefid, Float: hedefPos[3];
	if(sscanf(params, "u", hedefid))
		return YollaKullanMesaj(playerid, "/gethere [hedef ad�/ID]");
	if(!IsPlayerConnected(hedefid))
		return OyundaDegilMesaj(playerid);

	GetPlayerPos(playerid, hedefPos[0], hedefPos[1], hedefPos[2]);
	SetPlayerInterior(hedefid, GetPlayerInterior(playerid));
	SetPlayerVirtualWorld(hedefid, GetPlayerVirtualWorld(playerid));
	if(GetPlayerState(hedefid) == PLAYER_STATE_DRIVER)
	{
		new arac = GetPlayerVehicleID(hedefid);
		SetVehiclePos(arac, hedefPos[0], hedefPos[1]+3, hedefPos[2]);
	}
	else
	{
		SetPlayerPos(hedefid, hedefPos[0], hedefPos[1]+2, hedefPos[2]);
	}
	YollaIpucuMesaj(hedefid, "%s adl� y�netici seni yan�na �ekti.", Oyuncuadi(playerid));
	YollaIpucuMesaj(playerid, "%s adl� oyuncuyu yan�na �ektin.", Oyuncuadi(hedefid));
	return 1;
}

CMD:sethp(playerid, params[])
{
	if(Oyuncu[playerid][Yonetici] <= 1)
		return 1;

	new hedefid, miktar;
    if(sscanf(params, "ui", hedefid, miktar))
    	return YollaKullanMesaj(playerid, "/sethp [hedef ad�/ID] [miktar]");
    if(!IsPlayerConnected(hedefid))
		return OyundaDegilMesaj(playerid);

	SetPlayerHealth(hedefid, miktar);
	YollaIpucuMesaj(hedefid, "%s adl� y�netici can�n� %d yapt�.", Oyuncuadi(playerid), miktar);
	YollaIpucuMesaj(playerid, "%s adl� oyuncunun can�n� %d yapt�n.", Oyuncuadi(hedefid), miktar);
	return 1;
}

CMD:spawn(playerid, params[])
{
	if(Oyuncu[playerid][Yonetici] >= 1 || Oyuncu[playerid][Helper] == true)
	{
	new hedefid;
    if(sscanf(params, "u", hedefid))
    	return YollaKullanMesaj(playerid, "/spawn [hedef ad�/ID]");
    if(!IsPlayerConnected(hedefid))
		return OyundaDegilMesaj(playerid);

	SetPlayerPos(hedefid, Oyuncu[hedefid][Pos][0], Oyuncu[hedefid][Pos][1], Oyuncu[hedefid][Pos][2]);
	SetPlayerFacingAngle(hedefid, Oyuncu[hedefid][Pos][3]);
	SetPlayerVirtualWorld(hedefid, 0);
	SetPlayerInterior(hedefid, 10);
	SetCameraBehindPlayer(hedefid);
	YollaIpucuMesaj(hedefid, "%s adl� y�netici taraf�ndan lobiye spawn oldun.", Oyuncuadi(playerid));
	YollaIpucuMesaj(playerid, "%s adl� oyuncuyu lobiye spawnlad�n.", Oyuncuadi(hedefid));
	}
	return 1;
}

CMD:setarmor(playerid, params[])
{
	if(Oyuncu[playerid][Yonetici] <= 2)
		return 1;

	new hedefid, miktar;
    if(sscanf(params, "ui", hedefid, miktar))
    	return YollaKullanMesaj(playerid, "/setarmor [hedef ad�/ID] [miktar]");
    if(!IsPlayerConnected(hedefid))
		return OyundaDegilMesaj(playerid);

	SetPlayerArmour(hedefid, miktar);
	YollaIpucuMesaj(hedefid, "%s adl� y�netici z�rh�n� %d yapt�.", Oyuncuadi(playerid), miktar);
	YollaIpucuMesaj(playerid, "%s adl� oyuncunun z�rh�n� %d yapt�n.", Oyuncuadi(hedefid), miktar);
	return 1;
}

CMD:slap(playerid, params[])
{
	if(Oyuncu[playerid][Yonetici] < 1)
		return 1;

	new hedefid, Float: hedefPos[3];
    if(sscanf(params, "u", hedefid))
    	return YollaKullanMesaj(playerid, "/slap [hedef ad�/ID]");
	if(!IsPlayerConnected(hedefid))
		return OyundaDegilMesaj(playerid);

	GetPlayerPos(hedefid, hedefPos[0], hedefPos[1], hedefPos[2]);
	SetPlayerPos(hedefid, hedefPos[0], hedefPos[1], hedefPos[2]+5);
	YollaIpucuMesaj(hedefid, "%s adl� y�netici seni tokatlad�.", Oyuncuadi(playerid));
	YollaIpucuMesaj(playerid, "%s adl� oyuncuyu tokatlad�n.", Oyuncuadi(hedefid));
	return 1;
}

CMD:freeze(playerid, params[])
{
	if(Oyuncu[playerid][Yonetici] <= 1)
		return 1;
	new hedefid;
	if(sscanf(params, "u", hedefid))
	    return YollaKullanMesaj(playerid, "/freeze [hedef ad�/ID]");
	if(!IsPlayerConnected(hedefid))
		return OyundaDegilMesaj(playerid);

	if(Oyuncu[hedefid][FreezeDurumu] == false)
	{
		TogglePlayerControllable(hedefid, 0);
		Oyuncu[hedefid][FreezeDurumu] = true;
		YollaIpucuMesaj(hedefid, "%s adl� y�netici seni freezeledi.", Oyuncuadi(playerid));
		YollaIpucuMesaj(playerid, "%s adl� oyuncuyu freezeledin.", Oyuncuadi(hedefid));
		return 1;
	}
	TogglePlayerControllable(hedefid, 1);
	Oyuncu[hedefid][FreezeDurumu] = false;
	YollaIpucuMesaj(hedefid, "%s adl� y�netici senin freeze'ini kald�rd�.", Oyuncuadi(playerid));
	YollaIpucuMesaj(playerid, "%s adl� oyuncunun freeze'ini kald�rd�n.", Oyuncuadi(hedefid));
	return 1;
}

CMD:freeze2(playerid, params[])
{
	if(Oyuncu[playerid][Yonetici] <= 2)
		return 1;

	if(HerkesFreeze == false)
	{
		foreach(new i : Player)
		{
			if(Oyuncu[i][GirisYapti] == true && Oyuncu[i][Oyunda] == true)
			{
				TogglePlayerControllable(i, 0);
			}
		}
		HerkesFreeze = true;
		new mesaj[150];
		format(mesaj, sizeof(mesaj), "[B�LG�]"#BEYAZ2" %s adl� y�netici herkesi dondurdu!", Oyuncuadi(playerid));
		ProxDetectorOyun(mesaj, 0x008000FF);
		return 1;
	}
	foreach(new i : Player)
	{
		if(Oyuncu[i][GirisYapti] == true && Oyuncu[i][Oyunda] == true)
		{
			TogglePlayerControllable(i, 1);
		}
	}
	HerkesFreeze = false;
	new mesaj[150];
	format(mesaj, sizeof(mesaj), "[B�LG�]"#BEYAZ2" %s adl� y�netici herkesin donmas�n� kald�rd�.", Oyuncuadi(playerid));
	ProxDetectorOyun(mesaj, 0x008000FF);
	return 1;
}

CMD:getcar(playerid, params[])
{
	if(Oyuncu[playerid][Yonetici] < 3)
		return 1;
	new aracid, Float:ax, Float:ay, Float:az;
	if(sscanf(params, "d", aracid))
		return YollaKullanMesaj(playerid, "/getcar [ara� ID]");

	GetPlayerPos(playerid, ax, ay, az);
	SetVehiclePos(aracid, ax+3, ay+1, az+1);

	SetVehicleVirtualWorld(aracid, GetPlayerVirtualWorld(playerid));
	LinkVehicleToInterior(aracid, GetPlayerInterior(playerid));
	YollaIpucuMesaj(playerid, "%d ID'li arac� yan�na �ektin.", aracid);
	return 1;
}

CMD:gotocar(playerid, params[])
{
	if(Oyuncu[playerid][Yonetici] < 3)
		return 1;
	new aracid, Float:ax, Float:ay, Float:az;
	if(sscanf(params, "d", aracid))
		return YollaKullanMesaj(playerid, "/gotocar [ara� ID]");
	if(!IsValidVehicle(aracid))
		return YollaHataMesaj(playerid, "Ara� ID ge�ersiz.");

	GetVehiclePos(aracid, ax, ay, az);
	if(GetPlayerState(playerid) != 2)
	{
		SetPlayerPos(playerid, ax, ay, az);
	}
	new aracix = GetPlayerVehicleID(playerid);
	SetVehiclePos(aracix, ax+3, ay+1, az+1);
	SetPlayerVirtualWorld(playerid, 0);
	SetPlayerInterior(playerid, 0);
	YollaIpucuMesaj(playerid, "%d ID'li arac�n yan�na ���nland�n.", aracid);
	return 1;
}

CMD:setskin(playerid, params[])
{
	if(Oyuncu[playerid][Yonetici] < 3)
		return 1;
	new hedefid, kiyafet;
	if(sscanf(params, "ud", hedefid, kiyafet))
		return YollaKullanMesaj(playerid, "/setskin [hedef ad�/ID] [skin ID]");
  	if(!IsPlayerConnected(hedefid))
		return OyundaDegilMesaj(playerid);
	Oyuncu[hedefid][Kiyafet] = kiyafet;
	SetPlayerSkin(hedefid, Oyuncu[hedefid][Kiyafet]);
	YollaIpucuMesaj(hedefid, "%s adl� y�netici k�yafetini %d yapt�.", Oyuncuadi(playerid), kiyafet);
	YollaIpucuMesaj(playerid, "%s adl� oyuncunun k�yafetini %d yapt�n.", Oyuncuadi(hedefid), kiyafet);
	return 1;
}

CMD:dskin(playerid, params[])
{
	if(Oyuncu[playerid][Donator] == false)
		return YollaHataMesaj(playerid, "Donator de�ilisiniz.");
	if(Oyuncu[playerid][Oyunda] == true)
		return YollaHataMesaj(playerid, "Lobide de�ilsin.");

	new kiyafet;
	if(sscanf(params, "d", kiyafet))
		return YollaKullanMesaj(playerid, "/dskin [skin ID]");
	Oyuncu[playerid][Kiyafet] = kiyafet;
	SetPlayerSkin(playerid, Oyuncu[playerid][Kiyafet]);
	YollaIpucuMesaj(playerid, "K�yafetini de�i�tirdin.");

	return 1;

}

CMD:setweather(playerid, params[])
{
	if(Oyuncu[playerid][Yonetici] < 3)
		return 1;
	new havaid;
	if(sscanf(params, "d", havaid))
		return YollaKullanMesaj(playerid, "/setweather [havadurumu ID]");

	SetWeather(havaid);
	YollaHerkeseMesaj(0x008000FF, "[B�LG�]"#BEYAZ2" Hava durumu y�neticiler taraf�ndan de�i�tirildi.");
	return 1;
}

CMD:settime(playerid, params[])
{
	if(Oyuncu[playerid][Yonetici] < 2)
		return 1;
	new saat;
	if(sscanf(params, "d", saat))
		return YollaKullanMesaj(playerid, "/settime [saat]");

	SetWorldTime(saat);
	YollaHerkeseMesaj(0x008000FF, "[B�LG�]"#BEYAZ2" Saat y�neticiler taraf�ndan de�i�tirildi.");
	return 1;
}

CMD:restart(playerid, params[])
{
	if(Oyuncu[playerid][Yonetici] < 1)
		return 1;
	if(OyunBasladi == false)
		return YollaHataMesaj(playerid, "Oyun zaten ba�lamam��.");
	foreach(new i : Player)
	{
		if(Oyuncu[i][GirisYapti] == true && Oyuncu[i][Oyunda] == true)
		{
			LobiyeDon(i);
			Oyuncu[i][Oyunda] = Oyuncu[i][Suspect] = Oyuncu[i][Polis] = false;
			ResetPlayerWeapons(i);
		}
	}
	for(new i = 1; i < MAX_ENGEL; ++i)
	{
		if(Engel[i][Olusturuldu] == true)
		{
			DestroyDynamicObject(Engel[i][ID]);
			DestroyDynamic3DTextLabel(Engel[i][Engel3D]);
			if(IsValidDynamicArea(Engel[i][AreaID]))
				DestroyDynamicArea(Engel[i][AreaID]);
			Engel[i][Engel3D] = Text3D: INVALID_3DTEXT_ID;
			Engel[i][Pos][0] = Engel[i][Pos][1] = Engel[i][Pos][2] = 0.0;
			Engel[i][Duzenleniyor] = Engel[i][Olusturuldu] = false;
			Engel[i][SahipID] = -1;
		}
	}
	for(new j = 1, i = GetVehiclePoolSize(); j <= i; j++)
	{
		Flasor[j] = 0;
		KillTimer(FlasorTimer[j]);
		DestroyVehicle(j);
	}
	OyunSaniye = OYUN_SANIYE;
	OyunBasladi = OyunSayac = false;
	OyunDakika = OYUN_DAKIKA;
	KillTimer(SuspectSaklaTimer);
	KillTimer(OyunKalanTimer);
	Baslat();
	YollaHerkeseMesaj(0x008000FF, "[B�LG�]"#BEYAZ2" %s taraf�ndan oyun yeniden ba�lat�l�yor.", Oyuncuadi(playerid));
	return 1;
}

CMD:uyari(playerid, params[])
{
	if(Oyuncu[playerid][Yonetici] >= 1 || Oyuncu[playerid][Helper] == true)
	{
	new hedefid, sebep[100], mesaj[900];
	if(sscanf(params, "us[100]", hedefid, sebep))
		return YollaKullanMesaj(playerid, "/uyari [hedef ad�/ID] [sebep]");
  	if(!IsPlayerConnected(hedefid))
		return OyundaDegilMesaj(playerid);

	format(mesaj, sizeof(mesaj), ""#BEYAZ2"%s adl� yetkili taraf�ndan %s sebebiyle uyar�ld�n, daha dikkatli ol!", Oyuncuadi(playerid), sebep);
	
	strcat(mesaj, "- Oyunda seni di�er oyunculardan �st�n k�lan mod kullanamazs�n.\n");
	strcat(mesaj, "- /f (OOC) chatte hakaret etmemelisin.\n");
	strcat(mesaj, "- Roleplay modunda roleplay kurallar�na uygun davranmal�s�n.\n");
	strcat(mesaj, "- Polis memurlar�, ��pheliler ate� a�maya ba�layana kadar ate� a�amaz buna tekerlekler dahil.\n");
	strcat(mesaj, "- Bulundu�un arac� roleplay kurallar� i�inde s�rmeye dikkat etmelisin.\n");
	strcat(mesaj, "- Arac�n� s�rerken polislere veya ��phelilere ramming yapmamal�s�n.\n");
	strcat(mesaj, "- ��pheli sudayken ki�iyi kelep�eleyemez, taserleyemez ya da beanbag ile ate� edemezsin.\n");
	strcat(mesaj, "- ��pheliler ate� a�mad��� s�rece Drive-BY (ara�tan sarkma) yapamazs�n.\n");
	strcat(mesaj, "- Objeleri amac� d���nda kullanmak yasakt�r.\n");
	strcat(mesaj, "- Polisler ara�lar�n� d�zg�n s�rmek zorunda, LINE (tek �izgi) kural�na dikkat edilmelidir.\n");
	strins(mesaj, ""#BEYAZ2"", 0);
	ShowPlayerDialog(hedefid, DIALOG_X, DIALOG_STYLE_MSGBOX, ""#SUNUCU_KISALTMA" - Kurallar", mesaj, "Kapat", "");
	ShowPlayerDialog(hedefid, DIALOG_X, DIALOG_STYLE_MSGBOX, ""#SUNUCU_KISALTMA"", mesaj, "Kapat", "");
	YollaYoneticiMesaj(1, YONETIM_RENK, "%s, %s ki�isini %s sebebiyle uyard�.", Oyuncuadi(playerid), Oyuncuadi(hedefid), sebep);
	}
	return 1;
}

CMD:muzik(playerid, params[])
{
	if(Oyuncu[playerid][Yonetici] < 1)
		return 1;
	new url[150];
	if(sscanf(params, "s[150]", url))
		return YollaKullanMesaj(playerid, "/muzik [url]");

	foreach(new i : Player)
	{
		if(Oyuncu[i][GirisYapti] == true)
		{
			PlayAudioStreamForPlayer(i, url);
		}
	}
	YollaHerkeseMesaj(0x008000FF, "[B�LG�]"#BEYAZ2" %s taraf�ndan m�zik de�i�tirildi. /muzikkapat ile kapatabilirsiniz.", Oyuncuadi(playerid));
	return 1;
}

CMD:muzikkapat(playerid, params[])
{
	StopAudioStreamForPlayer(playerid);
	YollaIpucuMesaj(playerid, "M�zi�i kapatt�n, tekrar m�zik a��lana kadar duymayacaks�n.");
	return 1;
}

CMD:sustur(playerid, params[])
{
	if(Oyuncu[playerid][Yonetici] < 1)
		return 1;
	new hedefid, dakika, sebep[100];
	if(sscanf(params, "udS(-1)[100]", hedefid, dakika, sebep))
		return YollaKullanMesaj(playerid, "/sustur [hedef ad�/ID] [dakika] [sebep]");
  	if(!IsPlayerConnected(hedefid))
		return OyundaDegilMesaj(playerid);
	if(dakika >= 4)
		return YollaHataMesaj(playerid, "Oyuncuyu sadece 1-3 dakika aras� susturabilirsin.");

	if(dakika == 0)
	{
		Oyuncu[hedefid][SusturDakika] = dakika;
		KillTimer(Oyuncu[hedefid][SusturTimer]);
		YollaHerkeseMesaj(0x008000FF, "[B�LG�]"#BEYAZ2" %s, %s adl� oyuncuyu susturmas�n� kald�rd�.", Oyuncuadi(playerid), Oyuncuadi(hedefid));
		return 1;
	}
	if(strval(sebep) == -1) 
		return YollaKullanMesaj(playerid, "/sustur [hedef ad�/ID] [dakika] [sebep]");
	Oyuncu[hedefid][SusturTimer] = SetTimerEx("OyuncuSustur", TIMER_DAKIKA(1), true, "d", hedefid);
	Oyuncu[hedefid][SusturDakika] = dakika;
	YollaHerkeseMesaj(0x008000FF, "[B�LG�]"#BEYAZ2" %s, %s adl� oyuncuyu %s sebebiyle %d dakika susturdu.", Oyuncuadi(playerid), Oyuncuadi(hedefid), sebep, dakika);
	return 1;
}

CMD:aspec(playerid, params[])
{
	if(Oyuncu[playerid][Yonetici] < 1)
		return 1;
	new hedefid;
	if(sscanf(params, "u", hedefid))
		return YollaKullanMesaj(playerid, "/aspec [hedef ad�/ID]");
  	if(!IsPlayerConnected(hedefid))
		return OyundaDegilMesaj(playerid);
	if(playerid == hedefid)
		return YollaHataMesaj(playerid, "Kendini izleyemezsin.");

	GetPlayerPos(playerid, Oyuncu[playerid][Pos][0], Oyuncu[playerid][Pos][1], Oyuncu[playerid][Pos][2]);
	Oyuncu[playerid][VW] = GetPlayerVirtualWorld(playerid);
	Oyuncu[playerid][Int] = GetPlayerInterior(playerid);
	SetPlayerInterior(playerid, GetPlayerInterior(hedefid));
	SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(hedefid));
	TogglePlayerSpectating(playerid, 1);
	if(IsPlayerInAnyVehicle(hedefid)) 
		PlayerSpectateVehicle(playerid, GetPlayerVehicleID(hedefid));
	else PlayerSpectatePlayer(playerid, hedefid);

	YollaIpucuMesaj(playerid, "%s adl� oyuncuyu izliyorsun.", Oyuncuadi(hedefid));
	return 1;
}

CMD:aspecoff(playerid, params[])
{
	if(Oyuncu[playerid][Yonetici] < 1)
		return 1;

	TogglePlayerSpectating(playerid, 0);
	SetPlayerInterior(playerid, Oyuncu[playerid][Int]);
	SetPlayerVirtualWorld(playerid, Oyuncu[playerid][VW]);
	SetPlayerPos(playerid, Oyuncu[playerid][Pos][0], Oyuncu[playerid][Pos][1], Oyuncu[playerid][Pos][2]);
	YollaIpucuMesaj(playerid, "�zlemeden ��kt�n.");
	return 1;
}

CMD:setname(playerid, params[])
{
	if(Oyuncu[playerid][Yonetici] < 3)
		return 1;
	new hedefid, isim[MAX_PLAYER_NAME], sorgu[120], Cache: sorguj;
	if(sscanf(params, "us[24]", hedefid, isim))
		return YollaKullanMesaj(playerid, "/setname [hedef ad�/ID] [isim]");
  	if(!IsPlayerConnected(hedefid))
		return OyundaDegilMesaj(playerid);
	if(strlen(isim) > MAX_PLAYER_NAME)
		return YollaHataMesaj(playerid, "�sim uzunlu�u 1-24 aras�nda olmal�d�r.");

	format(isim, MAX_PLAYER_NAME, "%s", TRcevir(isim));
	if(IsPlayerConnected(ReturnUser(isim)))
		return YollaHataMesaj(playerid, "Bu isim kullan�l�yor.");

	mysql_format(CopSQL, sorgu, sizeof(sorgu), "SELECT * FROM hesaplar WHERE isim = '%s'", isim);
	sorguj = mysql_query(CopSQL, sorgu);
	if(cache_num_rows())
		return YollaHataMesaj(playerid, "Bu isim kullan�l�yor.");
	cache_delete(sorguj);
	format(Oyuncu[hedefid][OyuncuAdi], MAX_PLAYER_NAME, "%s", isim);
	YollaYoneticiMesaj(1, 0x008000FF, "[B�LG�]"#BEYAZ2" %s taraf�ndan %s adl� oyuncunun ismi %s ile de�i�tirildi.", Oyuncuadi(playerid), Oyuncuadi(hedefid), Oyuncu[hedefid][OyuncuAdi]);
	SetPlayerName(hedefid, Oyuncu[hedefid][OyuncuAdi]);
	mysql_format(CopSQL, sorgu, sizeof(sorgu), "UPDATE `hesaplar` SET `isim` = '%s' WHERE `ID` = %d LIMIT 1", Oyuncu[hedefid][OyuncuAdi], Oyuncu[hedefid][SQLID]);
	mysql_tquery(CopSQL, sorgu);
	return 1;
}

CMD:setscore(playerid, params[])
{
	if(Oyuncu[playerid][Yonetici] < 3)
		return 1;
	new hedefid, miktar;
	if(sscanf(params, "ud", hedefid, miktar))
		return YollaKullanMesaj(playerid, "/setscore [hedef ad�/ID] [miktar]");
  	if(!IsPlayerConnected(hedefid))
		return OyundaDegilMesaj(playerid);

	SkorVer(hedefid, miktar);
	YollaYoneticiMesaj(1, 0x008000FF, "[B�LG�]"#BEYAZ2" %s taraf�ndan %s adl� oyuncuya %d miktar skor verildi.", Oyuncuadi(playerid), Oyuncuadi(hedefid), miktar);
	return 1;
}

CMD:setscoreall(playerid, params[])
{
	if(Oyuncu[playerid][Yonetici] < 3)
		return 1;
	new miktar;
	if(sscanf(params, "d", miktar))
		return YollaKullanMesaj(playerid, "/setscoreall [miktar]");

	for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
	SkorVer(i, miktar);
	YollaHerkeseMesaj(0x008000FF, "[B�LG�]"#BEYAZ2" %s adl� admin taraf�ndan %d miktar�nda skor verildi.", Oyuncuadi(playerid), miktar);
	return 1;
}

CMD:bakim(playerid, params[])
{
	if(Oyuncu[playerid][Yonetici] < 4)
		return 1;
	YollaHerkeseMesaj(0x008000FF, "[B�LG�]"#BEYAZ2" Sunucu bak�m nedeniyle kapat�lm��t�r.");
	for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
	{
		if(Oyuncu[i][Yonetici] >= 4)
			continue;
		Kickle(i);
	}
	return 1;
}

CMD:donatoryap(playerid, params[])
{
	if(Oyuncu[playerid][Yonetici] < 4)
		return 1;
	new hedefid;
    if(sscanf(params, "u", hedefid))
    	return YollaKullanMesaj(playerid, "/donatoryap [hedef ad�/ID]");
    if(!IsPlayerConnected(hedefid))
		return OyundaDegilMesaj(playerid);

    if(Oyuncu[hedefid][Donator] == true)
    {
    	Oyuncu[hedefid][Donator] = false;
    	YollaIpucuMesaj(hedefid, "%s adl� y�netici donatorl���n� ald�.", Oyuncuadi(playerid));
        return YollaYoneticiMesaj(1, 0x008000FF, "[B�LG�]"#BEYAZ2" %s, %s ki�isinin donatorl���n� ald�.", Oyuncuadi(playerid), Oyuncuadi(hedefid));
    }
	Oyuncu[hedefid][Donator] = true;
	YollaYoneticiMesaj(1, 0x008000FF, "[B�LG�]"#BEYAZ2" %s, %s ki�isini donator yapt�.", Oyuncuadi(playerid), Oyuncuadi(hedefid));
	return 1;
}

CMD:jail(playerid, params[])
{
	if(Oyuncu[playerid][Yonetici] < 2)
		return 1;
	new hedefid, dakika, sebep[100];
    if(sscanf(params, "uds[100]", hedefid, dakika, sebep))
    	return YollaKullanMesaj(playerid, "/jail [hedef ad�/ID] [dakika] [sebep]");
    if(!IsPlayerConnected(hedefid))
		return OyundaDegilMesaj(playerid);
	if(dakika <= 0)
		return YollaHataMesaj(playerid, "Jail dakikas� 0'dan b�y�k olmal�d�r.");
	if(Oyuncu[hedefid][HapisDakika] >= 1)
		return YollaHataMesaj(playerid, "Oyuncu zaten hapiste.");

	Oyuncu[hedefid][HapisDakika] = dakika;
	Oyuncu[hedefid][HapisTimer] = SetTimerEx("OyuncuHapis", TIMER_DAKIKA(1), true, "d", hedefid);
	JailGonder(hedefid);
	if(OyunBasladi == true && Oyuncu[hedefid][Oyunda] == true)
	{
		Oyuncu[hedefid][Oyunda] = Oyuncu[hedefid][Suspect] = Oyuncu[hedefid][Polis] = false;
		OyunKontrol();
	}
	SetPlayerColor(hedefid, BEYAZ3);
	ResetPlayerWeapons(hedefid);
	YollaHerkeseMesaj(0xD01717FF, "[B�LG�]"#BEYAZ2" %s, %s adl� oyuncuyu %s sebebiyle %d dakika cezaland�rd�.", Oyuncuadi(playerid), Oyuncuadi(hedefid), sebep, dakika);
	return 1;
}

CMD:mjail(playerid, params[])
{
	if(Oyuncu[playerid][Yonetici] < 1)
		return 1;
	new hedefid, dakika, sebep[100];
    if(sscanf(params, "uds[100]", hedefid, dakika, sebep))
    	return YollaKullanMesaj(playerid, "/mjail [hedef ad�/ID] [dakika(1-8)] [sebep]");
    if(!IsPlayerConnected(hedefid))
		return OyundaDegilMesaj(playerid);
	if(dakika <= 0)
		return YollaHataMesaj(playerid, "Jail dakikas� 0'dan b�y�k olmal�d�r.");
    if(dakika >= 8)
        return YollaHataMesaj(playerid, "8 dakikadan fazla atamazs�n�z.");
	if(Oyuncu[hedefid][HapisDakika] >= 1)
		return YollaHataMesaj(playerid, "Oyuncu zaten hapiste.");

	Oyuncu[hedefid][HapisDakika] = dakika;
	Oyuncu[hedefid][HapisTimer] = SetTimerEx("OyuncuHapis", TIMER_DAKIKA(1), true, "d", hedefid);
	JailGonder(hedefid);
	if(OyunBasladi == true && Oyuncu[hedefid][Oyunda] == true)
	{
		Oyuncu[hedefid][Oyunda] = Oyuncu[hedefid][Suspect] = Oyuncu[hedefid][Polis] = false;
		OyunKontrol();
	}
	SetPlayerColor(hedefid, BEYAZ3);
	ResetPlayerWeapons(hedefid);
	YollaHerkeseMesaj(0xD01717FF, "[B�LG�]"#BEYAZ2" %s, %s adl� oyuncuyu %s sebebiyle %d dakika cezaland�rd�.", Oyuncuadi(playerid), Oyuncuadi(hedefid), sebep, dakika);
	return 1;
}

CMD:unjail(playerid, params[])
{
	if(Oyuncu[playerid][Yonetici] < 2)
		return 1;
	new hedefid;
    if(sscanf(params, "u", hedefid))
    	return YollaKullanMesaj(playerid, "/unjail [hedef ad�/ID]");
    if(!IsPlayerConnected(hedefid))
		return OyundaDegilMesaj(playerid);
	if(Oyuncu[hedefid][HapisDakika] <= 0)
		return YollaHataMesaj(playerid, "Bu ki�i hapiste de�il.");

	Oyuncu[hedefid][HapisDakika] = 0;
	Oyuncu[hedefid][AFK] = false;
	KillTimer(Oyuncu[hedefid][HapisTimer]);
	LobiyeDon(hedefid);
	YollaYoneticiMesaj(1, 0xD01717FF, "[B�LG�]"#BEYAZ2" %s, %s adl� oyuncuyu hapisten ��kard�.", Oyuncuadi(playerid), Oyuncuadi(hedefid));
	return 1;
}

CMD:sorusor(playerid, params[])
{
	new soru[120];
    if(sscanf(params, "s[120]", soru))
    	return YollaKullanMesaj(playerid, "/sorusor [soru]");
    if(Oyuncu[playerid][Soru] == true)
    	return YollaHataMesaj(playerid, "Aktif bir sorunuz var, sorunuzu iptal etmek i�in /soruiptal yaz�n.");
    if(strlen(soru) > 120)
    	return YollaHataMesaj(playerid, "Sorunuz 120 karakterden fazla olamaz.");

    Oyuncu[playerid][Soru] = true;
    Oyuncu[playerid][Sorusu] = soru;
    YollaIpucuMesaj(playerid, "Sorun aktif y�netici ve helperlara g�nderildi.");
    YollaSoruMesaj(0x05B3FFFF, "[SORU] %s [%s(%d)]", soru, Oyuncuadi(playerid), playerid);
	return 1;
}

CMD:sorucevap(playerid, params[])
{
	if(Oyuncu[playerid][Yonetici] >= 1 || Oyuncu[playerid][Helper] == true)
	{
		new hedefid, cevap[120];
	    if(sscanf(params, "us[120]", hedefid, cevap))
	    	return YollaKullanMesaj(playerid, "/sorucevap [hedef ad�/ID] [cevap]");
	    if(!IsPlayerConnected(hedefid))
			return OyundaDegilMesaj(playerid);
	    if(Oyuncu[hedefid][Soru] == false)
	    	return YollaHataMesaj(playerid, "Bu oyuncunun aktif sorusu yok.");

	    YollaHerkeseMesaj(0x008000FF, "[SORU]"#BEYAZ2" %s [%s(%d)]", Oyuncu[hedefid][Sorusu], Oyuncuadi(hedefid), hedefid);
	    if(Oyuncu[playerid][Yonetici] >= 1)
	    	YollaHerkeseMesaj(0x008000FF, "[CEVAP]"#BEYAZ2" %s [%s - %s"#BEYAZ2"]", cevap, Oyuncuadi(playerid), YoneticiYetkiAdi(Oyuncu[playerid][Yonetici]));
	    if(Oyuncu[playerid][Helper] == true)
	    	YollaHerkeseMesaj(0x008000FF, "[CEVAP]"#BEYAZ2" %s [%s - Helper"#BEYAZ2"]", cevap, Oyuncuadi(playerid));
	    Oyuncu[hedefid][Soru] = false;
	    format(Oyuncu[hedefid][Sorusu], 100, "-");
	}
	return 1;
}

CMD:sorured(playerid, params[])
{
	if(Oyuncu[playerid][Yonetici] >= 1 || Oyuncu[playerid][Helper] == true)
	{
		new hedefid, sebep[120];
	    if(sscanf(params, "us[120]", hedefid, sebep))
	    	return YollaKullanMesaj(playerid, "/sorured [hedef ad�/ID] [sebep]");

	    if(Oyuncu[hedefid][Soru] == false)
	    	return YollaHataMesaj(playerid, "Bu oyuncunun aktif sorusu yok.");

	    YollaYoneticiMesaj(1, 0x008000FF, "%s adl� admin %s adl� oyuncunun sorusunu reddetti, sebep: %s", Oyuncuadi(playerid), Oyuncuadi(hedefid), sebep);
		YollaIpucuMesaj(hedefid, "Sorunuz %s adl� yetkili taraf�ndan red edildi, l�tfen kurallar� okuyup tekrar at�n. Sebep: %s", Oyuncuadi(playerid), sebep);
	    Oyuncu[hedefid][Soru] = false;
	    format(Oyuncu[hedefid][Sorusu], 100, "-");
	}
	return 1;
}

CMD:soruiptal(playerid, params[])
{
    if(Oyuncu[playerid][Soru] == false)
    	return YollaHataMesaj(playerid, "Aktif sorun yok.");
    Oyuncu[playerid][Soru] = false;
    format(Oyuncu[playerid][Sorusu], 100, "-");
    YollaIpucuMesaj(playerid, "G�ndermi� oldu�unuz soruyu iptal ettiniz.");	
	return 1;
}

CMD:event(playerid, params[])
{
	if(Oyuncu[playerid][Yonetici] < 3)
		return 1;

	if(EventModu == false)
	{
		YollaHerkeseMesaj(0x008000FF, "[B�LG�]"#BEYAZ2" Bir sonra ki tur i�in event modu aktif edildi.");
		EventModu = true;
		return 1;
	}
	if(EventModu == true)
	{
		YollaHerkeseMesaj(0x008000FF, "[B�LG�]"#BEYAZ2" Bir sonra ki tur i�in event modu kapat�ld�.");
		EventModu = false;
		return 1;
	}
	return 1;
}

CMD:event2(playerid, params[])
{
	if(Oyuncu[playerid][Yonetici] < 3)
		return 1;
	if(EventModu2 == false)
	{
		YollaHerkeseMesaj(0x008000FF, "[B�LG�]"#BEYAZ2" Bir sonra ki tur i�in event modu aktif edildi.");
		EventModu2 = true;
		return 1;
	}
	if(EventModu2 == true)
	{
		YollaHerkeseMesaj(0x008000FF, "[B�LG�]"#BEYAZ2" Bir sonra ki tur i�in event modu kapat�ld�.");
		EventModu2 = false;
		return 1;
	}
	return 1;
}

CMD:kurallar(playerid, params[])
{
	new mesaj[900];
	strcat(mesaj, "- Oyunda seni di�er oyunculardan �st�n k�lan mod kullanamazs�n.\n");
	strcat(mesaj, "- /f (OOC) chatte hakaret etmemelisin.\n");
	strcat(mesaj, "- Roleplay modunda roleplay kurallar�na uygun davranmal�s�n.\n");
	strcat(mesaj, "- Polis memurlar�, ��pheliler ate� a�maya ba�layana kadar ate� a�amaz buna tekerlekler dahil.\n");
	strcat(mesaj, "- Bulundu�un arac� roleplay kurallar� i�inde s�rmeye dikkat etmelisin.\n");
	strcat(mesaj, "- Arac�n� s�rerken polislere veya ��phelilere ramming yapmamal�s�n.\n");
	strcat(mesaj, "- ��pheli sudayken ki�iyi kelep�eleyemez, taserleyemez ya da beanbag ile ate� edemezsin.\n");
	strcat(mesaj, "- ��pheliler ate� a�mad��� s�rece Drive-BY (ara�tan sarkma) yapamazs�n.\n");
	strcat(mesaj, "- Objeleri amac� d���nda kullanmak yasakt�r.\n");
	strcat(mesaj, "- Polisler ara�lar�n� d�zg�n s�rmek zorunda, LINE (tek �izgi) kural�na dikkat edilmelidir.\n");
	strins(mesaj, ""#BEYAZ2"", 0);
	ShowPlayerDialog(playerid, DIALOG_X, DIALOG_STYLE_MSGBOX, ""#SUNUCU_KISALTMA" - Kurallar", mesaj, "Kapat", "");
	return 1;
}

CMD:skin(playerid, params[])
{
    if (Oyuncu[playerid][GirisYapti] == false) return 0;
	new islem[20];
	if(Oyuncu[playerid][HapisDakika] >= 1)
		return YollaHataMesaj(playerid, "Hapisteyken bu komutu kullanamazs�n.");
	if(Oyuncu[playerid][Oyunda] == true)
		return YollaHataMesaj(playerid, "Lobide de�ilsin.");
	if(Oyuncu[playerid][DM] == true)
		return YollaHataMesaj(playerid, "Lobide de�ilsin.");
	if(sscanf(params, "s[20]", islem))
		return YollaKullanMesaj(playerid, "/skin [polis/supheli]");
	if (!strcmp(islem, "polis"))
	{
	  	new yazi[500];
		for (new i; i<sizeof(PolisSkinler); i++)
		{
			format(yazi,sizeof(yazi), "%s%d\n",yazi,PolisSkinler[i]);
	 	}
	  	ShowPlayerDialog(playerid, DIALOG_PSKIN, DIALOG_STYLE_PREVMODEL, "KIYAFETLER",yazi, "Sec", "Iptal");
	}
	else if(!strcmp(islem, "supheli"))
	{
	  	new yazi[500];
		for (new i; i<sizeof(SupheliSkinler); i++)
		{
			format(yazi,sizeof(yazi), "%s%d\n",yazi,SupheliSkinler[i]);
	 	}
	  	ShowPlayerDialog(playerid, DIALOG_SUSPECTSKIN, DIALOG_STYLE_PREVMODEL, "KIYAFETLER",yazi, "Sec", "Iptal");
	}
	else
	    return YollaKullanMesaj(playerid, "/skin [polis/supheli]");
	return 1;
}

CMD:dskin2(playerid, params[])
{
	if(Oyuncu[playerid][HapisDakika] >= 1)
		return YollaHataMesaj(playerid, "Hapiste komut kullanamazs�n.");
	if(Oyuncu[playerid][Oyunda] == true)
		return YollaHataMesaj(playerid, "Lobide de�ilsin.");
   	if(Oyuncu[playerid][Skor] <= 250 && Oyuncu[playerid][Donator] == false)
		return YollaIpucuMesaj(playerid, "Yeterli skorun yok yada donator de�ilsin.");

	ShowPlayerDialog(playerid, DIALOG_PSKIN2, DIALOG_STYLE_LIST, ""#SUNUCU_KISALTMA" - �zel Skinler", "SWAT\nJacket Police\nSiyahi Dedektif\nDedektif 1\nDedektif 2\nSEB\nSheriff 1\nSheriff 2\nSheriff 3", "Se�", "Kapat");
	return 1;
}

CMD:cw(playerid, params[])
{
    if (Oyuncu[playerid][GirisYapti] == false) return 0;
	if (!IsPlayerInAnyVehicle(playerid)) return YollaHataMesaj(playerid, "Ara�ta olmal�s�n�z.");
    if(isnull(params) || strlen(params) > 256)return
        YollaIpucuMesaj(playerid, "/cw [yaz�]");

    new vehicleid = GetPlayerVehicleID(playerid);
    new string[256];
    format(string, sizeof(string), "[Ara� i�i] %s: %s", Oyuncuadi(playerid), params);
    foreach(new j : Player)
    {
        if(!IsPlayerConnected(j)) continue;
        if(GetPlayerVehicleID(j) != vehicleid) continue;

        SendClientMessage(j, SARI, string);
    }

    return 1;
}
CMD:medkit(playerid, params[])
{
    if (Oyuncu[playerid][GirisYapti] == false) return 0;
	new islem[20];
    if(sscanf(params, "s[20]", islem))
    	return YollaKullanMesaj(playerid, "/medkit [kullan/al/ver]");
    if (!strcmp(islem, "kullan"))
    {
		new Float: can;
		if(Oyuncu[playerid][Oyunda] == false) return YollaHataMesaj(playerid, "Bunu sadece oyunda iken yapabilirsiniz.");
		if (Oyuncu[playerid][Medkit] < 1) return YollaHataMesaj(playerid, "Medkitiniz yok.");
		GetPlayerHealth(playerid, can);
		if (can >= 90) return YollaHataMesaj(playerid, "Medkite ihtiyac�n�z yok.");
		Oyuncu[playerid][Medkit]--;
		YollaIpucuMesaj(playerid, "Medkit kullan�yorsun.");
		TogglePlayerControllable(playerid, false);
		ApplyAnimation(playerid, "CRACK", "crckdeth2", 4.1, 0, 1, 1, 1, 1, 1);
		SetTimerEx("MedkitKullan", TIMER_SANIYE(5), false, "d", playerid);
    }
	else if (!strcmp(islem, "al"))
	    MedkitAl(playerid);
	else if (!strcmp(islem, "ver"))
	{
		if (Oyuncu[playerid][Medkit] < 1) return YollaHataMesaj(playerid, "Medkitiniz yok.");
		foreach (new i : Player)
		{
		    if (playerid != i)
		    {
				if(Oyuncu[i][Oyunda] == true)
				{
					if (OyuncuYakinMesafe(playerid, i) <= 3.0)
					{
					    Oyuncu[i][Medkit]++;
					    Oyuncu[playerid][Medkit]--;
					    YollaIpucuMesaj(i, "%s adl� ki�i sana bir medkit verdi. (%d/5)", Oyuncuadi(i), Oyuncu[i][Medkit]);
					    YollaIpucuMesaj(playerid, "%s adl� ki�iye medkit verdin. (%d/5)", Oyuncuadi(i), Oyuncu[playerid][Medkit]);
					    break;
					}
				}
		    }

		}
	}
	else
		return YollaKullanMesaj(playerid, "/medkit [kullan/al/ver]");
	return 1;
}
stock MedkitAl(playerid)
{
	if(Oyuncu[playerid][Oyunda] == true) return YollaHataMesaj(playerid, "Oyunda iken bunu yapamazs�n.");
	if (Oyuncu[playerid][Para] < 250) return YollaHataMesaj(playerid, "Paran�z yetersiz. ($250)");
	if (Oyuncu[playerid][Medkit] >= 5) return YollaHataMesaj(playerid, "Maksimum 5 medkit ta��yabilirsiniz.");
	Oyuncu[playerid][Para] -= 250;
	Oyuncu[playerid][Medkit]++;
	YollaIpucuMesaj(playerid, "$250 kar��l���nda bir medkit sat�n ald�n. (%d/5)", Oyuncu[playerid][Medkit]);
	return 1;
}

CMD:hasarlar(playerid, params[])
{
    if (Oyuncu[playerid][GirisYapti] == false) return 0;
	new id;
	if(sscanf(params, "u", id)) return YollaFormatMesaj(playerid, -1, "Kullan�m: /hasarlar [playerid]");
	{
		if(!IsPlayerConnected(id)) return YollaFormatMesaj(playerid, -1, "Bu ki�i oyunda de�il.");

		if(!GetDistanceBetweenPlayers(playerid, id, 5.0)) return YollaFormatMesaj(playerid, -1, "Bu ki�i yak�n�n�zda de�il.");

		DisplayDamageData(id, playerid);
	}
	return 1;
}

CMD:animasyonlar(playerid, params[])
{
    if (Oyuncu[playerid][GirisYapti] == false) return 0;
    SendClientMessage(playerid, COLOR_CLIENT, "__________________________________[ANIMASYONLAR]___________________________________");
    SendClientMessage(playerid, COLOR_CLIENT, "ANIMASYON:{FFFFFF} /handsup /sarhos /bomb /rob /laugh /lookout /robman /crossarms /sit /siteat /hide /vomit /eat");
    SendClientMessage(playerid, COLOR_CLIENT, "ANIMASYON:{FFFFFF} /wave /slapass /deal /taichi /crack /smoke /chat /dance /fucku /drinkwater /pedmove /bat");
    SendClientMessage(playerid, COLOR_CLIENT, "ANIMASYON:{FFFFFF} /checktime /sleep /blob /opendoor /wavedown /shakehand /reload /cpr /dive /showoff /box /tag");
    SendClientMessage(playerid, COLOR_CLIENT, "ANIMASYON:{FFFFFF} /goggles /cry /dj /cheer /throw /robbed /hurt /nobreath /bar /getjiggy /fallover /rap /piss");
    SendClientMessage(playerid, COLOR_CLIENT, "ANIMASYON:{FFFFFF} /salute /crabs /washhands /signal /stop /gesture /jerkoff /idles /carchat");
    SendClientMessage(playerid, COLOR_CLIENT, "ANIMASYON:{FFFFFF} /blowjob /spank /sunbathe /kiss /snatch /sneak /copa /sexy /holdup /misc /bodypush");
    SendClientMessage(playerid, COLOR_CLIENT, "ANIMASYON:{FFFFFF} /lowbodypush /headbutt /airkick /doorkick /leftslap /elbow /coprun /lean /wank");
    SendClientMessage(playerid, COLOR_CLIENT, "__________________________________[ANIMASYONLAR]___________________________________");
    return 1;
}

CMD:handsup(playerid, params[])
{
	if(Oyuncu[playerid][HapisDakika] >= 1)
		return YollaHataMesaj(playerid, "Hapiste komut kullanamazs�n.");
	if(Oyuncu[playerid][Taserlendi] == true)
		return 1;
	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_CUFFED)
		return 1;

	Oyuncu[playerid][Anim] = true;
	YollaIpucuMesaj(playerid, "Mouse'�n sol tu�u ile animasyonu bozabilirsin.");
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_HANDSUP);
	return 1;
}

CMD:aim(playerid, params[])
{
	if(Oyuncu[playerid][HapisDakika] >= 1)
		return YollaHataMesaj(playerid, "Hapiste komut kullanamazs�n.");
	if(Oyuncu[playerid][Taserlendi] == true)
		return 1;
	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_CUFFED)
		return 1;

	Oyuncu[playerid][Anim] = true;
	YollaIpucuMesaj(playerid, "Mouse'�n sol tu�u ile animasyonu bozabilirsin.");
	ApplyAnimation(playerid, "ped", "ARRESTgun", 4.0, 0, 1, 1, 1, 1, 1);
	return 1;
}

CMD:sitonchair(playerid, params[])
{
	if(Oyuncu[playerid][HapisDakika] >= 1)
		return YollaHataMesaj(playerid, "Hapiste komut kullanamazs�n.");
	if(Oyuncu[playerid][Taserlendi] == true)
		return 1;
	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_CUFFED)
		return 1;

	new anim;
    if(sscanf(params, "d", anim))
    	return YollaKullanMesaj(playerid, "/sitonchair [1-7]");

	switch(anim)
	{
		case 1: ApplyAnimation(playerid, "Attractors", "Stepsit_in", 4.0, 0, 0, 0, 1, 0, 1);
		case 2: ApplyAnimation(playerid, "CRIB", "PED_Console_Loop", 4.0, 1, 0, 0, 0, 0, 1);
		case 3: ApplyAnimation(playerid, "INT_HOUSE", "LOU_In", 4.0, 0, 0, 0, 1, 1, 1);
		case 4: ApplyAnimation(playerid, "MISC", "SEAT_LR", 4.0, 1, 0, 0, 0, 0, 1);
		case 5: ApplyAnimation(playerid, "MISC", "Seat_talk_01", 4.0, 1, 0, 0, 0, 0, 1);
		case 6: ApplyAnimation(playerid, "MISC", "Seat_talk_02", 4.0, 1, 0, 0, 0, 0, 1);
		case 7: ApplyAnimation(playerid, "ped", "SEAT_down", 4.0, 0, 0, 0, 1, 1, 1);
		default: YollaKullanMesaj(playerid, "/sitonchair [1-7]");
	}
	Oyuncu[playerid][Anim] = true;
	YollaIpucuMesaj(playerid, "Mouse'�n sol tu�u ile animasyonu bozabilirsin.");
	return 1;
}

CMD:crossarms(playerid, params[])
{
	if(Oyuncu[playerid][HapisDakika] >= 1)
		return YollaHataMesaj(playerid, "Hapiste komut kullanamazs�n.");
	if(Oyuncu[playerid][Taserlendi] == true)
		return 1;
	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_CUFFED)
		return 1;


	new anim;
    if(sscanf(params, "d", anim))
    	return YollaKullanMesaj(playerid, "/crossarms [1-5]");

	switch(anim)
	{
		case 1: ApplyAnimation(playerid, "COP_AMBIENT", "Coplook_loop", 4.0, 0, 1, 1, 1, -1, 1);
		case 2: ApplyAnimation(playerid, "DEALER", "DEALER_IDLE", 4.0, 1, 0, 0, 0, 0, 1);
		case 3: ApplyAnimation(playerid, "GRAVEYARD", "mrnM_loop", 4.0, 1, 0, 0, 0, 0, 1);
		case 4: ApplyAnimation(playerid, "GRAVEYARD", "prst_loopa", 4.0, 1, 0, 0, 0, 0, 1);
		case 5: ApplyAnimation(playerid, "DEALER", "DEALER_IDLE_01", 4.0, 1, 0, 0, 0, 0, 1);
		default: YollaKullanMesaj(playerid, "/crossarms [1-5]");
	}
	Oyuncu[playerid][Anim] = true;
	YollaIpucuMesaj(playerid, "Mouse'�n sol tu�u ile animasyonu bozabilirsin.");
	return 1;
}

CMD:animlist(playerid, params[])
{
	YollaIpucuMesaj(playerid, "/handsup - /aim - /sitonchair - /crossarms");
	return 1;
}

CMD:spec(playerid, params[])
{
	if(OyunBasladi == false)
		return YollaHataMesaj(playerid, "Oyun ba�lamad� kimseyi izleyemezsin.");
	if(Oyuncu[playerid][Oyunda] == true)
		return YollaHataMesaj(playerid, "Lobide de�ilken birisini izleyemezsiniz.");
	if(Oyuncu[playerid][HapisDakika] >= 1)
		return YollaHataMesaj(playerid, "Hapiste komut kullanamazs�n.");
	new hedefid;
	if(sscanf(params, "u", hedefid))
		return YollaKullanMesaj(playerid, "/spec [hedef ad�/ID]");
	if(Oyuncu[hedefid][Suspect] == true)
		return YollaHataMesaj(playerid, "��phelileri izleyemezsiniz, sadece polisleri.");
	if(playerid == hedefid)
		return YollaHataMesaj(playerid, "Kendini izleyemezsin.");
    if(!IsPlayerConnected(hedefid))
		return OyundaDegilMesaj(playerid);

	Oyuncu[playerid][VW] = GetPlayerVirtualWorld(playerid);
	Oyuncu[playerid][Int] = GetPlayerInterior(playerid);
	SetPlayerInterior(playerid, GetPlayerInterior(hedefid));
	SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(hedefid));
	TogglePlayerSpectating(playerid, 1);
	if(IsPlayerInAnyVehicle(hedefid)) 
		PlayerSpectateVehicle(playerid, GetPlayerVehicleID(hedefid));
	else PlayerSpectatePlayer(playerid, hedefid);

	YollaIpucuMesaj(playerid, "%s adl� oyuncuyu izliyorsun.", Oyuncuadi(hedefid));
	return 1;
}

CMD:specoff(playerid, params[])
{
	if(Oyuncu[playerid][HapisDakika] >= 1)
		return YollaHataMesaj(playerid, "Hapiste komut kullanamazs�n.");
	if(OyunBasladi == false)
		return YollaHataMesaj(playerid, "Oyun ba�lamad� bu komutu kullanamazs�n.");
	if(Oyuncu[playerid][Oyunda] == true)
		return YollaHataMesaj(playerid, "Bu komut lobide kullan�labilir.");
	if(GetPlayerState(playerid) != PLAYER_STATE_SPECTATING)
		return YollaHataMesaj(playerid, "Kimseyi izlemiyorsun.");

	TogglePlayerSpectating(playerid, 0);
	LobiyeDon(playerid);
	YollaIpucuMesaj(playerid, "�zlemeden ��kt�n.");
	return 1;
}

CMD:kill(playerid, params[])
{
	if(Oyuncu[playerid][HapisDakika] >= 1)
		return YollaHataMesaj(playerid, "Hapiste komut kullanamazs�n.");
    if(Oyuncu[playerid][Suspect] == true)
		return YollaHataMesaj(playerid, "��pheliyken bu komutu kullanamazs�n.");
	if(Oyuncu[playerid][Oyunda] == false && Oyuncu[playerid][DM] == false && Oyuncu[playerid][aktifduel] == false)
		return YollaHataMesaj(playerid, "Oyunda de�ilsin.");

	if(Oyuncu[playerid][DM] == true)
	{
		Oyuncu[playerid][DM] = false;
		new sayi = random(22);
		sscanf(LobiKonum(sayi), "p<,>fff", Oyuncu[playerid][Pos][0], Oyuncu[playerid][Pos][1], Oyuncu[playerid][Pos][2]);
	}
	SetPlayerHealth(playerid, 0.0);
	return 1;
}

CMD:lobi(playerid, params[])
{
    if (Oyuncu[playerid][GirisYapti] == false) return 0;
	if(Oyuncu[playerid][HapisDakika] >= 1)
		return YollaHataMesaj(playerid, "Hapisteyken bu komutu kullanamazs�n.");
	if(Oyuncu[playerid][Oyunda] == true)
		return YollaHataMesaj(playerid, "Oyundayken bu komutu kullanamazs�n.");
	if(Oyuncu[playerid][DM] == false)
		return YollaHataMesaj(playerid, "DM lobisinde de�ilsin.");

	Oyuncu[playerid][DM] = false;
	Arena[Oyuncu[playerid][DMArena]][Kisi]--;
 	Oyuncu[playerid][DMArena] = -1;
	ResetPlayerWeapons(playerid);
	LobiyeDon(playerid);
	return 1;
}

CMD:discord(playerid, params[])
{
	YollaIpucuMesaj(playerid, "Discord adresimiz: "#SUNUCUDISCORD"");
	return 1;
}

CMD:jailtime(playerid, params[])
{
	if(Oyuncu[playerid][HapisDakika] <= 0)
		return YollaHataMesaj(playerid, "Hapiste de�ilsin.");
	YollaIpucuMesaj(playerid, "Kalan hapis s�resi: %d dakika", Oyuncu[playerid][HapisDakika]);
	return 1;
}

CMD:yardim(playerid, params[])
{
    if (Oyuncu[playerid][GirisYapti] == false) return 0;
	YollaFormatMesaj(playerid, TURUNCU, "KOMUTLAR:"#BEYAZ2" /lobi, /kurallar, /animasyonlar, /spec, /specoff, /kill, /dm, /discord, /bilgi1, /bilgi2 /topdm");
	YollaFormatMesaj(playerid, TURUNCU, "KOMUTLAR:"#BEYAZ2" /jailtime, /timeleft, /rapor, /raporiptal, /sorusor, /soruiptal, /skoryardim, /skin");
	YollaFormatMesaj(playerid, TURUNCU, "KOMUTLAR:"#BEYAZ2" /me, /do, /ame, /s (ba��rarak), /l (sessiz), /w (f�s�ldama), /ooc, /b (ooc), /pm, /mp3");
	YollaFormatMesaj(playerid, TURUNCU, "KOMUTLAR:"#BEYAZ2" /supheliler, /afk, /oyun, /pskin, /hud, /pmkapat /lisans, /hesap, /dyardim, /medkit, /revive, /drag, /scrollwep, /swapseats");
	YollaFormatMesaj(playerid, TURUNCU, "KOMUTLAR:"#BEYAZ2" /maske, /r, /robcar, /id, /nitrous");
	YollaFormatMesaj(playerid, TURUNCU, "ARA� KOMUTLARI:"#BEYAZ2" /kilit, /camac, /camkapat, /tamir, /bagaj, /polisler, /cw, /wp");
	YollaFormatMesaj(playerid, POLIS_RENK, "POL�S KOMUTLARI:"#BEYAZ2" /kelepce, /taser (Y'ye bas), /beanbag, /elm, /aracdegistir");
	YollaFormatMesaj(playerid, POLIS_RENK, "POL�S KOMUTLARI:"#BEYAZ2" [N] tu�u destek ister, /civi, /koni, /engelpos, /engelsil, /m, /m1, /m2, /gov, /op");
	YollaFormatMesaj(playerid, POLIS_RENK, "POL�S KOMUTLARI:"#BEYAZ2" /track, /dragout, /destekiste, /requestcar");
	YollaFormatMesaj(playerid, DONATOR_RENK, "DONATOR KOMUTLARI:"#BEYAZ2" /disimdegistir, /dskin, /fstyle, /fix, /flip, /bicycle");
	return 1;
}

CMD:aracdegistir(playerid, params[])
{
	if(Oyuncu[playerid][HapisDakika] >= 1)
		return YollaHataMesaj(playerid, "Hapiste komut kullanamazs�n.");
	if(Oyuncu[playerid][Oyunda] == true)
		return YollaHataMesaj(playerid, "Bu komut lobide kullan�labilir.");
	ShowPlayerDialog(playerid, DIALOG_ARACDEGISTIR, DIALOG_STYLE_LIST, ""#SUNUCU_KISALTMA" - Ara� De�i�tir", "Police Car (LSPD)\nPolice Car (SFPD)\nPolice Car (SASD)\nPolice Ranger\nHPV1000\nFBI Truck\nPremier\nBullet [DONATOR]\nBuffalo [DONATOR]\nSultan [DONATOR] / 500+ Skor", "De�i�tir", "Kapat");
	return 1;
}

CMD:supheliler(playerid, params[])
{
	if(OyunBasladi == false)
		return YollaHataMesaj(playerid, "Aktif oyun yok.");
	new supheli[4], sayi, mesaj[130];
	foreach(new i : Player)
	{
		if(Oyuncu[i][GirisYapti] == true && Oyuncu[i][Oyunda] == true && Oyuncu[i][Suspect] == true)
		{
			supheli[sayi] = i;
			sayi++;
		}
	}
	if(sayi == 1)
		format(mesaj, sizeof(mesaj), "%s", Oyuncuadi(supheli[0]));
	if(sayi == 2)
		format(mesaj, sizeof(mesaj), "%s, %s", Oyuncuadi(supheli[0]), Oyuncuadi(supheli[1]));
	if(sayi == 3)
		format(mesaj, sizeof(mesaj), "%s, %s, %s", Oyuncuadi(supheli[0]), Oyuncuadi(supheli[1]), Oyuncuadi(supheli[2]));
	if(sayi == 4)
		format(mesaj, sizeof(mesaj), "%s, %s, %s, %s", Oyuncuadi(supheli[0]), Oyuncuadi(supheli[1]), Oyuncuadi(supheli[2]), Oyuncuadi(supheli[3]));	
	strins(mesaj, "{EE1616}", 0);
	YollaIpucuMesaj(playerid, mesaj);
	return 1;
}

CMD:pm(playerid, params[])
{
	new hedefid, mesaj[150];
	if(sscanf(params, "us[150]", hedefid, mesaj))
		return YollaKullanMesaj(playerid, "/pm [hedef ad�/ID] [mesaj]");
    if(!IsPlayerConnected(hedefid))
		return OyundaDegilMesaj(playerid);
	if(playerid == hedefid)
		return YollaHataMesaj(playerid, "Kendine PM atamazs�n.");
	if(Oyuncu[hedefid][PMizin] == true)
		return YollaHataMesaj(playerid, "Ki�i �zel mesaj�n� kapatm��.");
	if(Oyuncu[playerid][PMizin] == true)
	    return YollaHataMesaj(playerid, "�zel mesaj�n kapal�.");

	YollaFormatMesaj(playerid, 0xB79400FF, "[PM] %s(%d) ki�isine: %s", Oyuncuadi(hedefid), hedefid, mesaj);
	YollaFormatMesaj(hedefid, 0xE5B900FF, "[PM] %s(%d) ki�isinden: %s", Oyuncuadi(playerid), playerid, mesaj);
	if(Oyuncu[playerid][apm] == true && Oyuncu[playerid][Yonetici] >= 2)
	{
	    YollaYoneticiMesaj(1, 0xB79400FF, "[APM] %s'dan %s'ya mesaj: %s", Oyuncuadi(playerid), Oyuncuadi(hedefid), mesaj);
		return 1;
	}

	return 1;
}

CMD:pmkapat(playerid, params[])
{
		
	if(Oyuncu[playerid][PMizin] == true)
	{
		Oyuncu[playerid][PMizin] = false;
		YollaIpucuMesaj(playerid, "�zel mesajlar�n� a�t�n art�k �zel mesaj alabilirsin.");
		return 1;
	}
	if(Oyuncu[playerid][PMizin] == false)
	{
		Oyuncu[playerid][PMizin] = true;
		YollaIpucuMesaj(playerid, "�zel mesajlar�n� kapatt�n art�k �zel mesaj almayacaks�n.");
		return 1;
	}
	return 1;

}

CMD:apm(playerid, params[])
{

    if(Oyuncu[playerid][Yonetici] < 1)
		return 1;

	if(Oyuncu[playerid][apm] == true)
	{
		Oyuncu[playerid][apm] = false;
		YollaIpucuMesaj(playerid, "Art�k �zel mesajlar� okumayacaks�n.");
		return 1;
	}
	if(Oyuncu[playerid][apm] == false)
	{
		Oyuncu[playerid][apm] = true;
		YollaIpucuMesaj(playerid, "�zel mesajlar� okuymay� a�t�n.");
		return 1;
	}
	return 1;

}

CMD:rapor(playerid, params[])
{
	new hedefid, rapor[120];
    if(sscanf(params, "ds[120]", hedefid, rapor))
    	return YollaKullanMesaj(playerid, "/rapor [hedef ad�/ID] [sebep]");
    if(Oyuncu[playerid][Rapor] == true)
    	return YollaHataMesaj(playerid, "Aktif bir raporunuz var, raporunuzu iptal etmek i�in /raporiptal yaz�n.");
    if(strlen(rapor) > 120)
    	return YollaHataMesaj(playerid, "Rapor sebebiniz 120 karakterden fazla olamaz.");

    Oyuncu[playerid][Rapor] = true;
    Oyuncu[playerid][Raporu] = rapor;
    YollaIpucuMesaj(playerid, "Bu ki�i hakk�nda y�neticilere bir rapor yollad�n�z.");
    YollaYoneticiMesaj(1, 0x05B3FFFF, "[%s(%d)], [%s(%d)] adl� oyuncuyu %s sebebiyle raporlad�.", Oyuncuadi(playerid), playerid, Oyuncuadi(hedefid), hedefid, rapor);
	return 1;
}

CMD:raporiptal(playerid, params[])
{
    if(Oyuncu[playerid][Rapor] == false)
    	return YollaHataMesaj(playerid, "Aktif raporun yok.");
    Oyuncu[playerid][Rapor] = false;
    format(Oyuncu[playerid][Raporu], 120, "-");
    YollaIpucuMesaj(playerid, "G�ndermi� oldu�unuz raporu iptal ettiniz.");	
	return 1;
}

CMD:raporkabul(playerid, params[])
{
	if(Oyuncu[playerid][Yonetici] >= 2)
	{
		new hedefid;
	    if(sscanf(params, "u", hedefid))
	    	return YollaKullanMesaj(playerid, "/raporkabul [hedef ad�/ID]");
	    if(!IsPlayerConnected(hedefid))
			return OyundaDegilMesaj(playerid);
	    if(Oyuncu[hedefid][Rapor] == false)
	    	return YollaHataMesaj(playerid, "Bu oyuncunun aktif raporu yok.");

	    YollaIpucuMesaj(hedefid, "Raporunuz kabul edildi, inceleniyor.");
	    YollaYoneticiMesaj(1, SUNUCU_RENK, "%s adl� yetkili %d ID'li raporu kabul etti.", Oyuncuadi(playerid), hedefid);
	    Oyuncu[hedefid][Rapor] = false;
	    format(Oyuncu[hedefid][Raporu], 100, "-");
	}
	return 1;
}

CMD:raporred(playerid, params[])
{
	if(Oyuncu[playerid][Yonetici] >= 2)
	{
		new hedefid, sebep[150];
	    if(sscanf(params, "us[150]", hedefid, sebep))
	    	return YollaKullanMesaj(playerid, "/raporred [hedef ad�/ID] [sebep]");

	    if(Oyuncu[hedefid][Rapor] == false)
	    	return YollaHataMesaj(playerid, "Bu oyuncunun aktif raporu yok.");

	    YollaIpucuMesaj(hedefid, "Raporunuz %s adl� yetkili taraf�ndan reddedildi, sebep: %s", Oyuncuadi(playerid), sebep);
	   	YollaYoneticiMesaj(1, SUNUCU_RENK, "%s adl� yetkili, %d ID'li raporu reddetti, sebep: %s", Oyuncuadi(playerid), hedefid, sebep);
	    Oyuncu[hedefid][Rapor] = false;
	    format(Oyuncu[hedefid][Raporu], 120, "-");
	}
	return 1;
}

CMD:dzirh(playerid, params[])
{
	if(Oyuncu[playerid][Donator] == false)
		return YollaHataMesaj(playerid, "Donator de�ilsin.");
	if(Oyuncu[playerid][Oyunda] == false)
		return YollaHataMesaj(playerid, "Oyunda de�ilsin.");
	if(Oyuncu[playerid][ZirhHak] == true)
		return YollaHataMesaj(playerid, "Z�rh hakk�n�z� kullanm��s�n�z.");
	SetPlayerArmour(playerid, 100.0);
	YollaIpucuMesaj(playerid, "Z�rh�n�z fullendi.");
	Oyuncu[playerid][ZirhHak] = true;
	return 1;
}

CMD:disimdegistir(playerid, params[])
{
	if(Oyuncu[playerid][HapisDakika] >= 1)
		return YollaHataMesaj(playerid, "Hapiste komut kullanamazs�n.");
	if(Oyuncu[playerid][Donator] == false)
		return YollaHataMesaj(playerid, "Donator de�ilsin.");
	if(Oyuncu[playerid][IsimHak] == true)
		return YollaHataMesaj(playerid, "�sim de�i�tirme hakk�n�z� kulland�n�z.");

    ShowPlayerDialog(playerid, DIALOG_DISIMDEGISTIR, DIALOG_STYLE_MSGBOX, ""#SUNUCU_KISALTMA" - �sim De�i�tirme", ""#BEYAZ2"Bu isim de�i�tirme hakk�n� sadece bir defa kullanabileceksiniz.", "Tamam", "�ptal");
	return 1;
}

CMD:me(playerid, params[])
{
	if(Oyuncu[playerid][Oyunda] == false)
		return YollaHataMesaj(playerid, "Oyunda de�ilsin.");
	new eylem[150];
    if(sscanf(params, "s[150]", eylem))
    	return YollaKullanMesaj(playerid, "/me [eylem]");

    format(eylem, sizeof(eylem), "* %s %s", Oyuncuadi(playerid), eylem);
    ProxDetector(15.0, playerid, eylem, EMOTE_RENK);
	return 1;
}

CMD:do(playerid, params[])
{
	if(Oyuncu[playerid][Oyunda] == false)
		return YollaHataMesaj(playerid, "Oyunda de�ilsin.");
	new eylem[150];
    if(sscanf(params, "s[150]", eylem))
    	return YollaKullanMesaj(playerid, "/do [eylem]");

    format(eylem, sizeof(eylem), "* %s (( %s ))", eylem, Oyuncuadi(playerid));
    ProxDetector(15.0, playerid, eylem, EMOTE_RENK);
	return 1;
}

CMD:s(playerid, params[])
{
	if(Oyuncu[playerid][Oyunda] == false)
		return YollaHataMesaj(playerid, "Oyunda de�ilsin.");
	new mesaj[150];
    if(sscanf(params, "s[150]", mesaj))
    	return YollaKullanMesaj(playerid, "/s [mesaj]");

    format(mesaj, sizeof(mesaj), "%s ba��rarak: %s!", Oyuncuadi(playerid), mesaj);
    ProxDetector(30.0, playerid, mesaj, BEYAZ);
	return 1;
}

CMD:l(playerid, params[])
{
	if(Oyuncu[playerid][Oyunda] == false)
		return YollaHataMesaj(playerid, "Oyunda de�ilsin.");
	new mesaj[150];
    if(sscanf(params, "s[150]", mesaj))
    	return YollaKullanMesaj(playerid, "/l [mesaj]");

    format(mesaj, sizeof(mesaj), "%s sessizce: %s", Oyuncuadi(playerid), mesaj);
    ProxDetector(10.0, playerid, mesaj, BEYAZ);
	return 1;
}

CMD:r(playerid, params[])
{
	if(Oyuncu[playerid][Oyunda] == false)
		return YollaHataMesaj(playerid, "Oyunda de�ilsin.");
	if(Oyuncu[playerid][Polis] == false)
		return YollaHataMesaj(playerid, "Polis de�ilsin.");

	new mesaj[150];
    if(sscanf(params, "s[150]", mesaj))
    	return YollaKullanMesaj(playerid, "/r [mesaj]");

	format(mesaj, sizeof(mesaj), "[CH:911] %s %s: %s", PolisRutbe(playerid), Oyuncuadi(playerid), mesaj);
	PolisTelsiz(mesaj);
	return 1;
}

CMD:elm(playerid, params)
{
	if(Oyuncu[playerid][Oyunda] == false)
		return YollaHataMesaj(playerid, "Oyunda de�ilsin.");
	if(Oyuncu[playerid][Polis] == false)
		return YollaHataMesaj(playerid, "Polis de�ilsin.");
	if(!IsPlayerInAnyVehicle(playerid))
		return YollaHataMesaj(playerid, "Ara�ta de�ilsin.");
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
		return YollaHataMesaj(playerid, "S�r�c� koltu�unda de�ilsin.");

	new aracid = GetPlayerVehicleID(playerid);
	if(Flasor[aracid] == 1)
	{
		Flasor[aracid] = 0;
		KillTimer(FlasorTimer[aracid]);
		GetVehicleParamsEx(aracid, engine, lights, alarm, doors, bonnet, boot, objective);
		SetVehicleParamsEx(aracid, engine, VEHICLE_PARAMS_OFF, alarm, doors, bonnet, boot, objective);
		YollaIpucuMesaj(playerid, "ELM'yi kapatt�n�z!");
		return 1;
	}
	if(Flasor[aracid] == 0)
	{
	    FlasorDurum[aracid] = 1;
		FlasorTimer[playerid] = SetTimerEx("Flas", 200, true, "d", aracid);
		GetVehicleParamsEx(aracid, engine, lights, alarm, doors, bonnet, boot, objective);
		SetVehicleParamsEx(aracid, engine, VEHICLE_PARAMS_ON, alarm, doors, bonnet, boot, objective);
		YollaIpucuMesaj(playerid, "ELM'yi aktif hale getirdiniz!");
		Flasor[aracid] = 1;
		return 1;
	}
	return 1;
}

CMD:b(playerid, params[])
{
	if(Oyuncu[playerid][Oyunda] == false)
		return YollaHataMesaj(playerid, "Oyunda de�ilsin.");
	new mesaj[150];
    if(sscanf(params, "s[150]", mesaj))
    	return YollaKullanMesaj(playerid, "/b [mesaj]");

    format(mesaj, sizeof(mesaj), "(( %s: %s ))", Oyuncuadi(playerid), mesaj);
    ProxDetector(15.0, playerid, mesaj, BEYAZ);
	return 1;
}

CMD:kilit(playerid, params[])
{
	if(Oyuncu[playerid][Oyunda] == false)
		return YollaHataMesaj(playerid, "Oyunda de�ilsin.");
	if(Oyuncu[playerid][Suspect] == true)
		return YollaHataMesaj(playerid, "Bu arac�n anahtar�na sahip de�ilsin!");

	new aracid = GetClosestVehicle(playerid, 4.0), doorsss;
	if(aracid == SuspectArac)
		return YollaHataMesaj(playerid, "Bu arac� kilitleyemezsin.");

	if(AracKilitSahip[aracid] != playerid)
	{
		if(!IsPlayerInAnyVehicle(playerid))
			return YollaHataMesaj(playerid, "Ara�ta de�ilsin.");
		if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
			return YollaHataMesaj(playerid, "S�r�c� koltu�unda de�ilsin.");

		GetVehicleParamsEx(aracid, engine, lights, alarm, doorsss, bonnet, boot, objective);
		if(doorsss == VEHICLE_PARAMS_OFF)
		{
			AracKilitSahip[aracid] = playerid;
			GameTextForPlayer(playerid, "~r~ARAC KILITLENDI!", 2000, 4);
			SetVehicleParamsEx(aracid, engine, lights, alarm, VEHICLE_PARAMS_ON, bonnet, boot, objective);
		}
		if(doorsss == VEHICLE_PARAMS_ON)
		{
			GameTextForPlayer(playerid, "~g~KILIT ACILDI!", 2000, 4);
			SetVehicleParamsEx(aracid, engine, lights, alarm, VEHICLE_PARAMS_OFF, bonnet, boot, objective);
		}
		return 1;
	}
	else if(AracKilitSahip[aracid] == playerid)
	{
		GetVehicleParamsEx(aracid, engine, lights, alarm, doorsss, bonnet, boot, objective);
		if(doorsss == VEHICLE_PARAMS_OFF)
		{
			AracKilitSahip[aracid] = playerid;
			GameTextForPlayer(playerid, "~r~ARAC KILITLENDI!", 2000, 4);
			SetVehicleParamsEx(aracid, engine, lights, alarm, VEHICLE_PARAMS_ON, bonnet, boot, objective);
		}
		if(doorsss == VEHICLE_PARAMS_ON)
		{
			GameTextForPlayer(playerid, "~g~KILIT ACILDI!", 2000, 4);
			SetVehicleParamsEx(aracid, engine, lights, alarm, VEHICLE_PARAMS_OFF, bonnet, boot, objective);
		}
	}
	return 1;
}

CMD:motor(playerid, params[])
{
	if(Oyuncu[playerid][Oyunda] == false)
		return YollaHataMesaj(playerid, "Oyunda de�ilsin.");
	if(!IsPlayerInAnyVehicle(playerid))
		return YollaHataMesaj(playerid, "Ara�ta de�ilsin.");
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
		return YollaHataMesaj(playerid, "S�r�c� koltu�unda de�ilsin.");

	new aracid = GetPlayerVehicleID(playerid);
	if(AracHasar[aracid] == true)
		return YollaHataMesaj(playerid, "Bu arac�n motoru hasarl�!");
	GetVehicleParamsEx(aracid, engine, lights, alarm, doors, bonnet, boot, objective);
	if(engine == VEHICLE_PARAMS_ON)
	{
	    new eylem[150];
		GameTextForPlayer(playerid, "~r~MOTOR DURDURULDU!", 2000, 4);
		SetVehicleParamsEx(aracid, VEHICLE_PARAMS_OFF, lights, alarm, doors, bonnet, boot, objective);
	 	format(eylem, sizeof(eylem), "* %s arac�n motorunu durdurur.", Oyuncuadi(playerid), eylem);
    	ProxDetector(15.0, playerid, eylem, EMOTE_RENK);
	}
	if(engine == VEHICLE_PARAMS_OFF)
	{
		new eylem[150];
		GameTextForPlayer(playerid, "~g~MOTOR CALISTIRILDI!", 2000, 4);
		SetVehicleParamsEx(aracid, VEHICLE_PARAMS_ON, lights, alarm, doors, bonnet, boot, objective);
		format(eylem, sizeof(eylem), "* %s arac�n motorunu �al��t�r�r.", Oyuncuadi(playerid), eylem);
    	ProxDetector(15.0, playerid, eylem, EMOTE_RENK);
	}
	return 1;
}

CMD:loadout(playerid, params[])
{
    if (Oyuncu[playerid][GirisYapti] == false) return 0;
	new tercih[32];
	if(sscanf(params, "s[32]", tercih))
		return YollaKullanMesaj(playerid, "/loadout [polis/supheli]");
	if (!strcmp(tercih, "polis"))
	{
	    ShowPlayerDialog(playerid, DIALOG_LOADOUT_COP, DIALOG_STYLE_LIST, "LV:PP Loadout - COP", "Tabanca\nT�fek\nA��r Silah", "Se�", "Kapat");
	}
	else if (!strcmp(tercih, "supheli"))
	{
		ShowPlayerDialog(playerid, DIALOG_LOADOUT_FUGITIVE, DIALOG_STYLE_LIST, "LV:PP Loadout - FUGITIVE", "Tabanca\nT�fek\nA��r Silah", "Se�", "Kapat");
	}
	else
	    return YollaKullanMesaj(playerid, "/loadout [polis/supheli]");
	return 1;
}

CMD:camac(playerid, params[])
{
	if(Oyuncu[playerid][Oyunda] == false)
		return YollaHataMesaj(playerid, "Oyunda de�ilsin.");
	if(!IsPlayerInAnyVehicle(playerid))
		return YollaHataMesaj(playerid, "Ara�ta de�ilsin.");
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
		return YollaHataMesaj(playerid, "S�r�c� koltu�unda de�ilsin.");

	new eylem[120];
	format(eylem, sizeof(eylem), "* %s, araban�n b�t�n camlar�n� a�ar.", Oyuncuadi(playerid));
	ProxDetector(15.0, playerid, eylem, EMOTE_RENK);
	SetVehicleParamsCarWindows(GetPlayerVehicleID(playerid), VEHICLE_PARAMS_OFF, VEHICLE_PARAMS_OFF, VEHICLE_PARAMS_OFF, VEHICLE_PARAMS_OFF);
	return 1;
}

CMD:camkapat(playerid, params[])
{
	if(Oyuncu[playerid][Oyunda] == false)
		return YollaHataMesaj(playerid, "Oyunda de�ilsin.");
	if(!IsPlayerInAnyVehicle(playerid))
		return YollaHataMesaj(playerid, "Ara�ta de�ilsin.");
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
		return YollaHataMesaj(playerid, "S�r�c� koltu�unda de�ilsin.");

	new eylem[120];
	format(eylem, sizeof(eylem), "* %s, araban�n b�t�n camlar�n� kapat�r.", Oyuncuadi(playerid));
	ProxDetector(15.0, playerid, eylem, EMOTE_RENK);
	SetVehicleParamsCarWindows(GetPlayerVehicleID(playerid), VEHICLE_PARAMS_ON, VEHICLE_PARAMS_ON, VEHICLE_PARAMS_ON, VEHICLE_PARAMS_ON);
	return 1;
}

CMD:m(playerid, params[])
{
	if(Oyuncu[playerid][Oyunda] == false)
		return YollaHataMesaj(playerid, "Oyunda de�ilsin.");
	if(Oyuncu[playerid][Polis] == false)
		return YollaHataMesaj(playerid, "Polis de�ilsin.");
	if(!IsPlayerInAnyVehicle(playerid))
		return YollaHataMesaj(playerid, "Ara�ta de�ilsin.");

	new mesaj[150];
    if(sscanf(params, "s[150]", mesaj))
    	return YollaKullanMesaj(playerid, "/m [mesaj]");

    format(mesaj, sizeof(mesaj), "[MEGAFON] %s: %s", Oyuncuadi(playerid), mesaj);
    ProxDetector(40.0, playerid, mesaj, SARI);
	return 1;
}

CMD:m1(playerid, params[])
{
	if(Oyuncu[playerid][Oyunda] == false)
		return YollaHataMesaj(playerid, "Oyunda de�ilsin.");
	if(Oyuncu[playerid][Polis] == false)
		return YollaHataMesaj(playerid, "Polis de�ilsin.");
	if(!IsPlayerInAnyVehicle(playerid))
		return YollaHataMesaj(playerid, "Ara�ta de�ilsin.");

	new mesaj[150], Float: mpos[3];
	GetPlayerPos(playerid, mpos[0], mpos[1], mpos[2]);
    format(mesaj, sizeof(mesaj), "[MEGAFON] %s: Los Santos Polis Departman�, oldu�un yerde kal!", Oyuncuadi(playerid));
    ProxDetector(40.0, playerid, mesaj, SARI);
    PlaySoundEx(15800, mpos[0], mpos[1], mpos[2], 35);
	return 1;
}

CMD:m2(playerid, params[])
{
	if(Oyuncu[playerid][Oyunda] == false)
		return YollaHataMesaj(playerid, "Oyunda de�ilsin.");
	if(Oyuncu[playerid][Polis] == false)
		return YollaHataMesaj(playerid, "Polis de�ilsin.");
	if(!IsPlayerInAnyVehicle(playerid))
		return YollaHataMesaj(playerid, "Ara�ta de�ilsin.");

	new mesaj[150], Float: mpos[3];
	GetPlayerPos(playerid, mpos[0], mpos[1], mpos[2]);
    format(mesaj, sizeof(mesaj), "[MEGAFON] %s: Teslim ol, etraf�n sar�ld�!", Oyuncuadi(playerid));
    ProxDetector(40.0, playerid, mesaj, SARI);
    PlaySoundEx(9605, mpos[0], mpos[1], mpos[2], 35);
	return 1;
}

CMD:f(playerid, params[])
{
	if(Oyuncu[playerid][HapisDakika] >= 1)
		return YollaHataMesaj(playerid, "Hapiste bu kanal� kullanamazs�n�z.");
	if(Oyuncu[playerid][SusturDakika] >= 1)
		YollaHataMesaj(playerid, "Susturuldu�un i�in konu�amazs�n, susturman�n bitmesine %d kald�.", Oyuncu[playerid][SusturDakika]);
	if(Fdurum == false)
		return YollaHataMesaj(playerid, "/f [OOC] kanal bir yetkili taraf�ndan devre d��� b�rak�lm��.");

	new mesaj[150];
    if(sscanf(params, "s[150]", mesaj))
    	return YollaKullanMesaj(playerid, "/f [ooc mesaj]");

    format(mesaj, sizeof(mesaj), "[OOC] %s(%d): %s", Oyuncuadi(playerid), playerid, mesaj);
    YollaHerkeseMesaj(0xF96500FF, mesaj);
	return 1;
}

CMD:fkapat(playerid, params[])
{
	if(Oyuncu[playerid][Yonetici] < 3)
		return 1;
	if(Fdurum == true)
	{
		Fdurum = false;
		YollaHerkeseMesaj(0x457790FF, "/f [OOC] kanal bir admin taraf�ndan devre d��� b�rak�ld�.");
		return 1;
	}
	else if(Fdurum == false)
	{
		Fdurum = true;
		YollaHerkeseMesaj(0x457790FF, "/f [OOC] kanal tekrardan bir yetkili taraf�ndan aktif hale getirildi.");
		return 1;
	}
	return 1;
}

CMD:w(playerid, params[])
{
	if(Oyuncu[playerid][HapisDakika] >= 1)
		return YollaHataMesaj(playerid, "Hapiste bu kanal� kullanamazs�n�z.");
	if(Oyuncu[playerid][Oyunda] == false)
		return YollaHataMesaj(playerid, "Oyunda de�ilsin.");

	new hedefid, mesaj[150];
    if(sscanf(params, "us[150]", hedefid, mesaj))
    	return YollaKullanMesaj(playerid, "/w [hedef ad�/ID] [mesaj]");
   	if(!IsPlayerConnected(hedefid))
   		return OyundaDegilMesaj(playerid);
	if(OyuncuYakinMesafe(playerid, hedefid) >= 3.5)
		return YollaHataMesaj(playerid, "Bu oyuncu yan�nda de�il.");
	if(playerid == hedefid)
		return YollaHataMesaj(playerid, "Kendine f�s�ldayamazs�n.");

    YollaFormatMesaj(hedefid, SARI, "%s adl� ki�i sana f�s�ldad�: %s", Oyuncuadi(playerid), mesaj);
    YollaFormatMesaj(playerid, SARI, "%s adl� ki�iye f�s�ldad�n: %s", Oyuncuadi(hedefid), mesaj);
	return 1;
}



CMD:tamir(playerid, params[])
{
	if(Oyuncu[playerid][Oyunda] == false)
		return YollaHataMesaj(playerid, "Oyunda de�ilsin.");
	if(IsPlayerInAnyVehicle(playerid))
		return YollaHataMesaj(playerid, "Ara�ta bu komutu kullanamazs�n.");
	if(Oyuncu[playerid][AracTamir] == true)
		return YollaHataMesaj(playerid, "Daha fazla tamir kitiniz bulunmuyor.");

	new aracid = GetClosestVehicle(playerid, 4.0);
	if(aracid <= 0)
		return YollaHataMesaj(playerid, "Ara� kaputuna yak�n de�ilsin.");

	new Panels, Doors, Lights, Tires, Float: araccan;
	GetVehicleDamageStatus(aracid, Panels, Doors, Lights, Tires);
	GetVehicleHealth(aracid, araccan);
	if(Tires == 0 && araccan >= 851.0)
		return YollaHataMesaj(playerid, "Bu ara� hasarl� de�il!");

	SetTimerEx("AracTamirEt", TIMER_SANIYE(13), false, "dd", playerid, aracid);
	Oyuncu[playerid][AracTamir] = true;
	GameTextForPlayer(playerid, "~w~ARACINIZI TAMIR EDIYORSUNUZ..", 13000, 4);
	GetVehicleParamsEx(aracid, engine, lights, alarm, doors, bonnet, boot, objective);
	SetVehicleParamsEx(aracid, engine, lights, alarm, doors, VEHICLE_PARAMS_ON, boot, objective);
	TogglePlayerControllable(playerid, 0);
	new eylem[120];
	format(eylem, sizeof(eylem), "* %s arac�n kaputunu a�ar ve tamir etmeye �al���r.", Oyuncuadi(playerid));
	ProxDetector(15.0, playerid, eylem, EMOTE_RENK);
	return 1;
}

CMD:koni(playerid, params[])
{
	if(Oyuncu[playerid][Oyunda] == false)
		return YollaHataMesaj(playerid, "Oyunda de�ilsin.");
	if(Oyuncu[playerid][Polis] == false)
		return YollaHataMesaj(playerid, "Polis de�ilsin.");
	if(IsPlayerInAnyVehicle(playerid))
		return YollaHataMesaj(playerid, "Ara�ta bu komutu kullanamazs�n.");
	if(Oyuncu[playerid][EngelHak] >= 5)
		return YollaHataMesaj(playerid, "Daha fazla engel yerle�tiremezsin.");
    if(Oyuncu[playerid][Skor] < 150)
	    return YollaHataMesaj (playerid, "Skorun yeterli de�il.");
	new engelid, mesaj[140];
	for(new i = 1; i < MAX_ENGEL; ++i)
	{
		if(Engel[i][Olusturuldu] == true)
			continue;
		engelid = i;
		break;
	}
	Oyuncu[playerid][EngelHak]++;
	format(mesaj, sizeof(mesaj), "Engel ID: %d - Olu�turan: %s", engelid, Oyuncuadi(playerid));
    GetPlayerPos(playerid, Engel[engelid][Pos][0], Engel[engelid][Pos][1], Engel[engelid][Pos][2]);
	Engel[engelid][Olusturuldu] = true;
	Engel[engelid][Duzenleniyor] = false;
    Engel[engelid][Model] = 1238;
    Engel[engelid][SahipID] = playerid;
    Engel[engelid][Tip] = 0;
    Engel[engelid][ID] = CreateDynamicObject(1238, Engel[engelid][Pos][0], Engel[engelid][Pos][1], Engel[engelid][Pos][2]-0.7, 0.0, 0.0, 0.0);
	Engel[engelid][Engel3D] = CreateDynamic3DTextLabel(mesaj, MAVI, Engel[engelid][Pos][0], Engel[engelid][Pos][1], Engel[engelid][Pos][2], 20.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID);
	YollaIpucuMesaj(playerid, "Koniyi yerle�tirdiniz.");
	return 1;
}

CMD:civi(playerid, params[])
{
	if(Oyuncu[playerid][Oyunda] == false)
		return YollaHataMesaj(playerid, "Oyunda de�ilsin.");
	if(Oyuncu[playerid][Polis] == false)
		return YollaHataMesaj(playerid, "Polis de�ilsin.");
	if(IsPlayerInAnyVehicle(playerid))
		return YollaHataMesaj(playerid, "Ara�ta bu komutu kullanamazs�n.");
	if(Oyuncu[playerid][EngelHak] >= 5)
		return YollaHataMesaj(playerid, "Daha fazla engel yerle�tiremezsin.");
	if(Oyuncu[playerid][Skor] < 150)
	    return YollaHataMesaj (playerid, "Skorun yeterli de�il.");
	new engelid, mesaj[140];
	for(new i = 1; i < MAX_ENGEL; ++i)
	{
		if(Engel[i][Olusturuldu] == true)
			continue;
		engelid = i;
		break;
	}
	Oyuncu[playerid][EngelHak]++;
	format(mesaj, sizeof(mesaj), "Engel ID: %d - Olu�turan: %s", engelid, Oyuncuadi(playerid));
    GetPlayerPos(playerid, Engel[engelid][Pos][0], Engel[engelid][Pos][1], Engel[engelid][Pos][2]);
	Engel[engelid][Olusturuldu] = true;
	Engel[engelid][Duzenleniyor] = false;
    Engel[engelid][Model] = 1238;
    Engel[engelid][SahipID] = playerid;
    Engel[engelid][Tip] = 1;
    Engel[engelid][AreaID] = CreateDynamicRectangle(Engel[engelid][Pos][0]+2, Engel[engelid][Pos][1]+2, Engel[engelid][Pos][0]-2, Engel[engelid][Pos][1]-2);
    Engel[engelid][ID] = CreateDynamicObject(2899, Engel[engelid][Pos][0], Engel[engelid][Pos][1], Engel[engelid][Pos][2]-0.9, 0.0, 0.0, 0.0);
	Engel[engelid][Engel3D] = CreateDynamic3DTextLabel(mesaj, MAVI, Engel[engelid][Pos][0], Engel[engelid][Pos][1], Engel[engelid][Pos][2], 20.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID);
	YollaIpucuMesaj(playerid, "�iviyi yerle�tirdiniz.");
	return 1;
}

CMD:engelpos(playerid, params[])
{
	if(Oyuncu[playerid][Oyunda] == false)
		return YollaHataMesaj(playerid, "Oyunda de�ilsin.");
	if(Oyuncu[playerid][Polis] == false)
		return YollaHataMesaj(playerid, "Polis de�ilsin.");
	if(IsPlayerInAnyVehicle(playerid))
		return YollaHataMesaj(playerid, "Ara�ta bu komutu kullanamazs�n.");
	if(Oyuncu[playerid][DuzenleEngel] == true)
		return YollaHataMesaj(playerid, "Engel d�zenlemeyi bitirin.");

	Oyuncu[playerid][EngelSec] = 1;
	YollaIpucuMesaj(playerid, "D�zenlemek istedi�iniz engeli se�in.");
	SelectObject(playerid);
	return 1;
}

CMD:engelsil(playerid, params[])
{
	if(Oyuncu[playerid][Oyunda] == false)
		return YollaHataMesaj(playerid, "Oyunda de�ilsin.");
	if(Oyuncu[playerid][Polis] == false)
		return YollaHataMesaj(playerid, "Polis de�ilsin.");
	if(IsPlayerInAnyVehicle(playerid))
		return YollaHataMesaj(playerid, "Ara�ta bu komutu kullanamazs�n.");
	if(Oyuncu[playerid][DuzenleEngel] == true)
		return YollaHataMesaj(playerid, "Engel d�zenlemeyi bitirin.");

	Oyuncu[playerid][EngelSec] = 2;
	YollaIpucuMesaj(playerid, "Kald�rmak istedi�iniz engeli se�in.");
	SelectObject(playerid);
	return 1;
}

CMD:engelsifirla(playerid, params[])
{
	if(Oyuncu[playerid][Yonetici] < 2)
		return 1;
	for(new i = 1; i < MAX_ENGEL; ++i)
	{
		if(Engel[i][Olusturuldu] == true)
		{
			DestroyDynamicObject(Engel[i][ID]);
			DestroyDynamic3DTextLabel(Engel[i][Engel3D]);
			if(IsValidDynamicArea(Engel[i][AreaID]))
				DestroyDynamicArea(Engel[i][AreaID]);
			Engel[i][Engel3D] = Text3D: INVALID_3DTEXT_ID;
			Engel[i][Pos][0] = Engel[i][Pos][1] = Engel[i][Pos][2] = 0.0;
			Engel[i][Duzenleniyor] = false;
			Engel[i][SahipID] = -1;
			Engel[i][Olusturuldu] = false;
		}
	}
	YollaHerkeseMesaj(0x008000FF, "[B�LG�]"#BEYAZ2" Bir yetkili taraf�ndan b�t�n engeller silindi.");
	return 1;
}

CMD:siren(playerid, params[])
{
	if(Oyuncu[playerid][Oyunda] == false)
		return YollaHataMesaj(playerid, "Oyunda de�ilsin.");
	if(Oyuncu[playerid][Polis] == false)
		return YollaHataMesaj(playerid, "Polis de�ilsin.");
	if(!IsPlayerInAnyVehicle(playerid))
		return YollaHataMesaj(playerid, "Ara�ta de�ilsin.");

	new aracid = GetPlayerVehicleID(playerid);
	if(aracid == 16)
		return YollaHataMesaj(playerid, "Polis arac�nda de�ilsin.");
	if(AracSirenDurumu[aracid] == false)
	{
		AracSirenDurumu[aracid] = true;
	    AracSiren[aracid] = CreateDynamicObject(18646, 10.0, 10.0, 10.0, 0.0, 0.0, 0.0);
		AttachDynamicObjectToVehicle(AracSiren[aracid], aracid, -0.43, 0.0, 0.785, 0.0, 0.1, 0.0);
		YollaIpucuMesaj(playerid, "Arac�n�za siren eklediniz!");
		return 1;
	}
	if(AracSirenDurumu[aracid] == true)
	{
		AracSirenDurumu[aracid] = false;
	  	DestroyDynamicObject(AracSiren[aracid]);
		YollaIpucuMesaj(playerid, "Arac�n�zdan sireni kald�rd�n�z!");
		return 1;
	}
	return 1;
}

CMD:taser(playerid, params[])
{	
	if(Oyuncu[playerid][Oyunda] == false)
		return YollaHataMesaj(playerid, "Oyunda de�ilsin.");
	if(Oyuncu[playerid][Polis] == false)
		return YollaHataMesaj(playerid, "Polis de�ilsin.");
	if(IsPlayerInAnyVehicle(playerid))
		return YollaHataMesaj(playerid, "Ara�ta bu komutu kullanamazs�n.");
	if(Oyuncu[playerid][OyunSilah] == true)
		return YollaHataMesaj(playerid, "Hen�z silahlar verilmedi!");
	if(Oyuncu[playerid][TaserMermiDegis] == true)
		return YollaHataMesaj(playerid, "Kartu� y�kleniyor!");

	new eylem[120];
	if(Oyuncu[playerid][Taser] == true)
	{
		Oyuncu[playerid][Taser] = false;
		SetPlayerAmmo(playerid, 23, 0);
		GivePlayerWeapon(playerid, 24, 300);
		format(eylem, sizeof(eylem), "* %s �ok tabancas�n� k�l�f�na koyar.", Oyuncuadi(playerid));
		ProxDetector(15.0, playerid, eylem, EMOTE_RENK);
		return 1;
	}
	if(Oyuncu[playerid][Taser] == false)
	{
		Oyuncu[playerid][Taser] = true;
		GivePlayerWeapon(playerid, 23, 1);
		format(eylem, sizeof(eylem), "* %s �ok tabancas�n� k�l�f�ndan ��kar�r.", Oyuncuadi(playerid));
		ProxDetector(15.0, playerid, eylem, EMOTE_RENK);
		return 1;
	}
	return 1;
}

CMD:beanbag(playerid, params[])
{
	if(Oyuncu[playerid][Oyunda] == false)
		return YollaHataMesaj(playerid, "Oyunda de�ilsin.");
	if(Oyuncu[playerid][Polis] == false)
		return YollaHataMesaj(playerid, "Polis de�ilsin.");
	if(!IsPlayerInAnyVehicle(playerid))
		return YollaHataMesaj(playerid, "Ara�ta de�ilsin.");
	if(Oyuncu[playerid][OyunSilah] == true)
		return YollaHataMesaj(playerid, "Hen�z silahlar verilmedi!");

	new eylem[120];
	if(Oyuncu[playerid][Beanbag] == true)
	{
		Oyuncu[playerid][Beanbag] = false;
		SetPlayerAmmo(playerid, 25, 0);
		format(eylem, sizeof(eylem), "* %s, elinde bulunan beanbag'i tekrardan orta panele yerle�tirir.", Oyuncuadi(playerid));
		ProxDetector(15.0, playerid, eylem, EMOTE_RENK);
		return 1;
	}
	if(Oyuncu[playerid][Beanbag] == false)
	{
		Oyuncu[playerid][Beanbag] = true;
		GivePlayerWeapon(playerid, 25, 50);
		if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
			SetPlayerArmedWeapon(playerid, 0);
		format(eylem, sizeof(eylem), "* %s, arac�n orta panelinden beanbag'i kavrar.", Oyuncuadi(playerid));
		ProxDetector(15.0, playerid, eylem, EMOTE_RENK);
		return 1;
	}
	return 1;
}

CMD:kelepce(playerid, params[])
{
	if(Oyuncu[playerid][Oyunda] == false)
		return YollaHataMesaj(playerid, "Oyunda de�ilsin.");
	if(Oyuncu[playerid][Polis] == false)
		return YollaHataMesaj(playerid, "Polis de�ilsin.");
	if(IsPlayerInAnyVehicle(playerid))
		return YollaHataMesaj(playerid, "Ara�ta bu komutu kullanamazs�n.");

	new hedefid;
    if(sscanf(params, "u", hedefid))
    	return YollaKullanMesaj(playerid, "/kelepce [hedef ad�/ID]");

    if(Oyuncu[hedefid][Polis] == true)
    	return 1;

    if(GetPlayerSpecialAction(hedefid) == SPECIAL_ACTION_HANDSUP || Oyuncu[hedefid][Taserlendi] == true || Oyuncu[hedefid][Beanbaglendi] == true)
    {
    	new eylem[140];
    	format(eylem, sizeof(eylem), "%s, te�hizat kemerinden kelep�esini kavrar ve ��phelinin bileklerine ge�irir.", Oyuncuadi(playerid));
    	TogglePlayerControllable(hedefid, 0);
    	Oyuncu[hedefid][Suspect] = false;
    	SetPlayerSpecialAction(hedefid, SPECIAL_ACTION_CUFFED);
    	ProxDetector(15.0, playerid, eylem, EMOTE_RENK);
    	SetTimer("OyunKontrol", TIMER_SANIYE(5), false);
    	return 1;
    }
	return 1;
}

CMD:dm(playerid, params[])
{
	if(Oyuncu[playerid][HapisDakika] >= 1)
		return YollaHataMesaj(playerid, "Hapiste bu komutu kullanamazs�n.");
	if(Oyuncu[playerid][Oyunda] == true)
		return YollaHataMesaj(playerid, "Oyunda bu komutu kullanamazs�n.");
	if(Oyuncu[playerid][DM] == true)
		return YollaHataMesaj(playerid, "Zaten DM lobisindesin.");
	if(Dmizin == true)
	    return YollaHataMesaj(playerid, "DM lobisi admin taraf�ndan kapat�lm��.");
	if(OyunSaniye <= 10 && OyunBasladi == false)
		return YollaIpucuMesaj(playerid, "Oyun birazdan ba�layacak.");
		

	new sayi = random(8);
	sscanf(DMKonum(sayi), "p<,>fff", Oyuncu[playerid][Pos][0], Oyuncu[playerid][Pos][1], Oyuncu[playerid][Pos][2]);
	SetPlayerPos(playerid, Oyuncu[playerid][Pos][0], Oyuncu[playerid][Pos][1], Oyuncu[playerid][Pos][2]);
	Oyuncu[playerid][DM] = true;
	SetPlayerInterior(playerid, 3);
	SetPlayerHealth(playerid, 100.0);
	SetPlayerVirtualWorld(playerid, 0);
	GivePlayerWeapon(playerid, 24, 500);
	GivePlayerWeapon(playerid, 25, 500);
	new mesaj[130];
	format(mesaj, sizeof(mesaj), "%s adl� oyuncu DM lobisine kat�ld�.", Oyuncuadi(playerid));
	ProxDetectorLobi(mesaj, SUNUCU_RENK);
	return 1;
}

CMD:oyun(playerid, params[])
{
	if(OyunBasladi == false)
		return YollaHataMesaj(playerid, "Aktif oyun yok.");
	if(Oyuncu[playerid][Oyunda] == false)
		return YollaHataMesaj(playerid, "Oyunda de�ilsin.");
	new tip[40];
	if(OyunModuTip == 0)
		format(tip, 40, "Event");
	if(OyunModuTip == 1)
		format(tip, 40, "Non-RP");
	if(OyunModuTip == 2)
		format(tip, 40, "Roleplay");
	YollaIpucuMesaj(playerid, "Oyun modu %s olarak se�ilmi�tir!", tip);
	if(OyunModuTip != 0)
		YollaIpucuMesaj(playerid, "%s", OyunSebep);
	return 1;
}

CMD:istatistik(playerid, params[])
{
	YollaIpucuMesaj(playerid, "�ld�rd��� ki�i say�s�: %d", Oyuncu[playerid][Oldurme]);
	YollaIpucuMesaj(playerid, "�ld�r�lme say�s�: %d", Oyuncu[playerid][Olum]);
	YollaIpucuMesaj(playerid, "Suspect kazan�m say�s�: %d", Oyuncu[playerid][SuspectKazanma]);
	return 1;
}

CMD:hesap(playerid, params[])
{
	if(Oyuncu[playerid][Donator] == true)
	{
		YollaFormatMesaj(playerid, -1, "HESAP: "DONATOR_RENK2"[Donator(Evet)]", Oyuncu[playerid][SuspectKazanma], Oyuncu[playerid][Skor]);
	}
	if(Oyuncu[playerid][Helper] == true)
	{
		YollaFormatMesaj(playerid, -1, "HESAP:"#SARI2" [Helper(Evet)]");
	}
	if(Oyuncu[playerid][Yonetici] >= 1)
	{
		YollaFormatMesaj(playerid, -1, "HESAP:"#BEYAZ2" [Y�netici(Evet] [Yetki(%s)]", YoneticiYetkiAdi(Oyuncu[playerid][Yonetici]));
	}
	YollaFormatMesaj(playerid, -1, "HESAP:"#BEYAZ2" [%s] [ID(%d)] [DM�ld�rme(%d)] [DM�l�m(%d)]", Oyuncuadi(playerid), playerid, Oyuncu[playerid][Oldurme], Oyuncu[playerid][Olum]);
	YollaFormatMesaj(playerid, -1, "HESAP:"#BEYAZ2" [��pheliKazanma(%d)]", Oyuncu[playerid][SuspectKazanma], Oyuncu[playerid][Skor]);
	return 1;
}

CMD:hud(playerid, params[])
{
	if(Oyuncu[playerid][Hud] == true)
	{
		Oyuncu[playerid][Hud] = false;
		PlayerTextDrawHide(playerid, Textdraw0[playerid]);
		PlayerTextDrawHide(playerid, Textdraw1[playerid]);
		YollaIpucuMesaj(playerid, "Hudu kapatt�n, a�mak i�in /hud.");
		return 1;
	}
	if(Oyuncu[playerid][Hud] == false)
	{
		Oyuncu[playerid][Hud] = true;
		PlayerTextDrawShow(playerid, Textdraw0[playerid]);
		PlayerTextDrawShow(playerid, Textdraw1[playerid]);
		YollaIpucuMesaj(playerid, "Hudu a�t�n, kapatmak i�in /hud.");
		return 1;
	}
	return 1;
}

CMD:aduty(playerid, params[])
{

	if(Oyuncu[playerid][Yonetici] <= 1)
		return 1;

	if(Oyuncu[playerid][aduty] == true)
	{
	    new Text3D:label;
		Oyuncu[playerid][aduty] = false;
		SetPlayerHealth(playerid, 100.0);
		YollaIpucuMesaj(playerid, "Admin i�ba�� durumundan ��kt�n, girmek i�in /aduty komutunu kullanabilirsin.");
		YollaHerkeseMesaj(-1, "{D8AB3F}%s {F96500}adl� admin i�ba��ndan ��kt�.", Oyuncuadi(playerid));
	 	Create3DTextLabel("", 0xD01717FF, 30.0, 40.0, 50.0, 40.0, 0);
	 	Delete3DTextLabel(label);
		return 1;
	}
	if(Oyuncu[playerid][aduty] == false)
	{
	    new Text3D:label;
        Oyuncu[playerid][aduty] = true;
		SetPlayerHealth(playerid, 1000.0);
		YollaIpucuMesaj(playerid, "Admin i�ba�� durumuna ge�tin, ��kmak i�in /aduty komutunu kullanabilirsin.");
		YollaHerkeseMesaj(-1, "{D8AB3F}%s{F96500} adl� admin i�ba��na ge�ti.", Oyuncuadi(playerid));
		Create3DTextLabel("Y�NET�C�", 0xD01717FF, 30.0, 40.0, 50.0, 40.0, 0);
	 	Attach3DTextLabelToPlayer(label, playerid, 0.0, 0.0, 0.3);
		return 1;
	}

	return 1;
	
}

CMD:o(playerid, params[])
{
	if(Oyuncu[playerid][Yonetici] < 1)
		return 1;
	new mesaj[150];
	if(sscanf(params, "s[150]", mesaj))
		return YollaKullanMesaj(playerid, "/o [mesaj]");
	YollaHerkeseMesaj(YONETIM_RENK, "[ADM�N] %s %s - (%d):"#BEYAZ2" %s", YoneticiYetkiAdi(Oyuncu[playerid][Yonetici]), Oyuncuadi(playerid), playerid, mesaj);
	return 1;
}

CMD:gmx(playerid, params[])
{
	if(Oyuncu[playerid][Yonetici] < 3)
		return 1;
	YollaHerkeseMesaj(KIRMIZI, "%s adl� admin taraf�ndan sunucu yeniden ba�lat�l�yor.", Oyuncuadi(playerid));
	SendRconCommand("gmx");

	return 1;
}

CMD:mp3(playerid, params[])
{
	if(Oyuncu[playerid][HapisDakika] >= 1)
		return YollaHataMesaj(playerid, "Hapiste bu komutu kullanamazs�n.");
	YollaIpucuMesaj(playerid, "Dinlemek istedi�iniz kanal� buradan se�ebilirsiniz.");
    ShowPlayerDialog(playerid, DIALOG_MP3, DIALOG_STYLE_LIST, "RS RADYO", "Radyo Fenomen\nFenomen RAP\nFenomen T�rk\nFenomen Akustik\nFenomen Pop\nPowert�rk FM\nYay�n� durdur.", "Se�", "Kapat");

	return 1;
}
	
CMD:op(playerid, params[])
{
	if(Oyuncu[playerid][Oyunda] == false)
		return YollaHataMesaj(playerid, "Oyunda de�ilsin.");
	if(Oyuncu[playerid][Polis] == false)
		return YollaHataMesaj(playerid, "Polis de�ilsin.");
	if(Oyuncu[playerid][Skor] < 450)
	    return YollaHataMesaj(playerid, "Skorun yeterli de�il.");

	new mesaj[150];
    if(sscanf(params, "s[150]", mesaj))
    	return YollaKullanMesaj(playerid, "/op(erator) [mesaj]");

	format(mesaj, sizeof(mesaj), "[OPERATOR] %s %s: %s", PolisRutbe(playerid), Oyuncuadi(playerid), mesaj);
	PolisTelsiz(mesaj);
	return 1;
}

CMD:gov(playerid, params[])
{
	if(Oyuncu[playerid][Oyunda] == false)
		return YollaHataMesaj(playerid, "Oyunda de�ilsin.");
	if(Oyuncu[playerid][Polis] == false)
		return YollaHataMesaj(playerid, "Polis de�ilsin.");
	if(Oyuncu[playerid][Skor] < 700)
	    return YollaHataMesaj(playerid, "Skorun yeterli de�il.");

	new mesaj[150];
    if(sscanf(params, "s[150]", mesaj))
    	return YollaKullanMesaj(playerid, "/gov(erment) [mesaj]");

	format(mesaj, sizeof(mesaj), ""#SARI2"[STATE]"#BEYAZ2" %s: %s", Oyuncuadi(playerid), mesaj);
	PolisTelsiz(mesaj);
	return 1;
}

CMD:dmkitle(playerid, params[])
{
    if(Oyuncu[playerid][Yonetici] < 2)
		return 1;

	if(Dmizin== true)
	{
		Dmizin = false;
		YollaIpucuMesaj(playerid, "DM lobisini a�t�n.");
		YollaHerkeseMesaj(-1, "{D8AB3F}%s{F96500} adl� admin DM lobisini a�t�.", Oyuncuadi(playerid));
		return 1;
	}
	if(Dmizin == false)
	{
		Dmizin = true;
		YollaIpucuMesaj(playerid, "DM lobisini kitledin.");
		YollaHerkeseMesaj(-1, "{D8AB3F}%s{F96500} adl� admin DM lobisini kitledi.", Oyuncuadi(playerid));
		return 1;
	}
	return 1;
}

CMD:lisans(playerid, params[])
{
	if(Oyuncu[playerid][Oyunda] == false)
	    return YollaHataMesaj(playerid, "Oyunda de�ilsin.");
    if(Oyuncu[playerid][Suspect] == false)
	    return YollaHataMesaj(playerid, "��pheli de�ilsin.");
	    
	new hedefid, eylem[150];
    if(sscanf(params, "u", hedefid))
    	return YollaKullanMesaj(playerid, "/lisans [OyuncuID]");
    	
    if(playerid == hedefid) return YollaHataMesaj(playerid, "Kendine g�steremezsin.");

	format(eylem, sizeof(eylem), "* %s lisans belgesini ��kart�r ve %s'a g�sterir.", Oyuncuadi(playerid), Oyuncuadi(hedefid));
	ProxDetector(15.0, playerid, eylem, EMOTE_RENK);
	YollaFormatMesaj(hedefid, -1, "[San Andreas Bakanl��� Motorlu Ta��tlar Departman�]");
	YollaFormatMesaj(hedefid, -1, "�sim: %s((%d)), Eyalet: Los Santos/San Andreas, Yenilenme Tarihi: "#KIRMIZI2"08.02.2022 "#BEYAZ2"Ge�erlilik:"#KIRMIZI2" Pasif.", Oyuncuadi(playerid), playerid);

	return 1;
}

CMD:polisler(playerid, params[])
{
	if(OyunBasladi == false)
		return YollaHataMesaj(playerid, "Aktif oyun yok.");

	new aktifpolis = 0;
	foreach(new i : Player)
	{
		if(Oyuncu[i][Polis] == true)
		{
			YollaIpucuMesaj(playerid, ""#MAVI2" - %s", Oyuncuadi(i));
			aktifpolis++;
        }
	}
	if(aktifpolis == 0)
		return YollaHataMesaj(playerid, "�evrimi�i polis yok.");
	return 1;
}

CMD:hyardim(playerid, params[])
{
	if(Oyuncu[playerid][Yonetici] >= 1 || Oyuncu[playerid][Helper] == true)
	{
	YollaFormatMesaj(playerid, -1, "HELPER: /h - /spawn - /uyari - /sorured - /hyardim - /sorucevap");
	}
	return 1;
}

CMD:ame(playerid, params[])
{
	if(Oyuncu[playerid][Oyunda] == false)
		return YollaHataMesaj(playerid, "Oyunda de�ilsin.");
	new eylem[150];
    if(sscanf(params, "s[150]", eylem))
    	return YollaKullanMesaj(playerid, "/ame [eylem]");

    format(eylem, sizeof(eylem), "* %s %s", Oyuncuadi(playerid), eylem);
    SetPlayerChatBubble(playerid, eylem, EMOTE_RENK, 30.0, 10000);
    YollaFormatMesaj(EMOTE_RENK, playerid, "* %s", eylem);
	return 1;
}

CMD:asilahal(playerid, params[])
{
	if(Oyuncu[playerid][Oyunda] == false)
		return YollaHataMesaj(playerid, "Oyunda de�ilsin.");
	if(Oyuncu[playerid][Polis] == false)
		return YollaHataMesaj(playerid, "Polis de�ilsin.");
	if(Oyuncu[playerid][OyunSilah] == true)
		return YollaHataMesaj(playerid, "Hen�z silahlar verilmedi!");
	if(!IsPlayerInAnyVehicle(playerid))
		return YollaHataMesaj(playerid, "Bu komutu ara�ta kullanabilirsin.");
    ShowPlayerDialog(playerid, ASILAHAL, DIALOG_STYLE_LIST, "Ara� Paneli", "M4A1 Carbine", "Al", "�ptal");

	return 1;
}

CMD:duel(playerid, params[])
{
	YollaHataMesaj(playerid, "Duel sistemi �uanl�k pasif.");
	return 1;
}

CMD:dkabul(playerid, params[])
{

	 YollaHataMesaj(playerid, "Duel sistemi �uanl�k pasif.");
 	 return 1;
}

CMD:dred(playerid, params[])
{

	 YollaHataMesaj(playerid, "Duel sistemi �uanl�k pasif.");
	 return 1;
}

CMD:dyardim(playerid, params[])
{
	YollaIpucuMesaj(playerid, "/duel komutuyla oyuncuya davet g�nderebilirsiniz.");
	YollaIpucuMesaj(playerid, "/dkabul komutu ile iste�i kabul edebilirsin, /dred ile red edebilirsiniz.");
	YollaHataMesaj(playerid, "Duel sistemi �uanl�k pasif.");
	return 1;
}

CMD:cezaver(playerid, params[])
{
	if(Oyuncu[playerid][Yonetici] < 2)
	    return 1;

	new hedefid, miktar;
	if(sscanf(params, "ud", hedefid, miktar))
		return YollaKullanMesaj(playerid, "/cezaver [OyuncuID] [Ceza(verilen miktarda skor oyuncudan kesilir)]");
  	if(!IsPlayerConnected(hedefid))
		return OyundaDegilMesaj(playerid);

	if(playerid == hedefid) return YollaHataMesaj(playerid, "Kendine ceza kesemezsin.");
    if(Oyuncu[hedefid][Yonetici] > 3)
        return YollaHataMesaj(playerid, "Bu oyuncuya kar�� bu komutu kullanmas�n.");

	YollaIpucuMesaj(hedefid, "%d miktar�nda skorun silindi, kurallar� dikkatlice oku!", miktar);
	SkorVer2(hedefid, miktar);
	YollaIpucuMesaj(playerid, "%s adl� oyuncuya %d miktar�ndanda ceza verdin.", Oyuncuadi(hedefid), miktar);
	YollaHerkeseMesaj(0xD01717FF, "[B�LG�]"#BEYAZ2" %s adl� y�netici %s adl� oyuncuya %d miktar�nda ceza kesti.", Oyuncuadi(playerid), Oyuncuadi(hedefid), miktar);
	return 1;
}

CMD:serverkilit(playerid, params[])
{
   if(Oyuncu[playerid][Yonetici] < 4)  return SendClientMessage(playerid, -1, "{C3C3C3}(BILGI) 4 level admin de�ilsiniz.");
   {
        new str[128];
        if(sscanf(params, "s[128]", str)) return SendClientMessage(playerid, -1, "{c3c3c3}(BILGI) /serverkilit [�ifre]");
        format(str, sizeof(str), "{c3c3c3}(BILGI) �ifre: %s", params);
        new pass[64];
        format(pass,sizeof(pass),"password %s",params);
        SendRconCommand(pass);
        format(str, sizeof(str), "{9d64d0}(BILGI) Bir admin sunucuyu kilitledi! (��FRE: %s)", params);
        YollaYoneticiMesaj(1, 0x008000FF, str);
   }
   return 1;
}

CMD:cc(playerid, params[])
{
   if(Oyuncu[playerid][Yonetici] < 1) return 0;
   for(new i = 0; i < 18; i++) SendClientMessageToAll(BEYAZ," ");
   YollaHerkeseMesaj(0x008000FF, "[B�LG�]"#BEYAZ2" %s adl� yetkili sohbet kanal�n� temizledi.", Oyuncuadi(playerid));
   return 1;
}

CMD:bilgi1(playerid, params[])
{
  	YollaFormatMesaj(playerid, TURUNCU, "B�LG�:"#BEYAZ2" Oyun modunu ��renmek i�in /kurallar komutuna g�z atmay� unutma!");
	YollaFormatMesaj(playerid, TURUNCU, "B�LG�:"#BEYAZ2" Akl�nda kalan bir soru olursa /sorusor komutunu kullanabilirsinin!");
	YollaFormatMesaj(playerid, TURUNCU, "B�LG�:"#BEYAZ2" /discord komutunu kullanarak discord adresemize kat�lmay� unutma!");
	return 1;
}

CMD:bilgi2(playerid, params[])
{
  	YollaFormatMesaj(playerid, TURUNCU, "B�LG�:"#BEYAZ2" ��phelilerin rengi sar� olmadan ate� a�arsan ceza alabilirsin!");
	YollaFormatMesaj(playerid, TURUNCU, "B�LG�:"#BEYAZ2" /mp3 komutuyla oyun esnas�nda radyo kanallar�na ula�abilirsin.");
	YollaFormatMesaj(playerid, TURUNCU, "B�LG�:"#BEYAZ2" Kafanda olan istek veya �nerilerini discord �zerinden bize bildirmeyi unutma!");
	YollaFormatMesaj(playerid, TURUNCU, "B�LG�:"#BEYAZ2" Bize zaman ay�rd���n i�in te�ekk�r ederiz.");
	if(Oyuncu[playerid][Skor] < 5)
	    return SetPlayerScore(playerid, Oyuncu[playerid][Skor] +5); 
	OyuncuGuncelle(playerid);
	return 1;
}

CMD:skoryardim(playerid, params[])
{
  		ShowPlayerDialog(playerid, SKORYARDIM, DIALOG_STYLE_TABLIST_HEADERS, "SKOR YARDIM",
		"SKOR\tR�TBE\tS�LAH\n\
		1\tRecruit Officer\tNormal\n\
		75\tPolice Officer\tShotgun\n\
		135\tPolice Officer I\tShotgun\n\
		165\tPolice Officer II\tMP5-Shotgun\n\
		225\tPolice Officer III\tRifle-MP5-Shotgun\n\
		300\tPolice Detective I\tRifle-MP5-Shotgun\n\
		380\tPolice Detective II\tRifle-MP5-Shotgun\n\
		560\tPolice Sergeant I\tM4-Rifle-MP5-Shotgun\n\
		660\tPolice Sergeant II\tB�t�n Silahlar\n\
		860\tPolice Lieutenant I\tB�t�n Silahlar\n\
		960\tPolice Lieutenant II\tB�t�n Silahlar\n\
		1060\tPolice Captain I\tB�t�n Silahlar\n\
		1160\tPolice Captain II\tB�t�n Silahlar\n\
		1260\tPolice Captain III\tB�t�n Silahlar\n\
		1460\tPolice Commander\tB�t�n Silahlar\n\
		1600\tDeputy Chief\tB�t�n Silahlar\n\
		1850\tPolice Assistant Chief\tB�t�n Silahlar\n\
		2200\tChief of Police\tB�t�n Silahlar",
		"Kapat", "");
		return 1;
}

CMD:track(playerid, params[])
{
    if (Oyuncu[playerid][GirisYapti] == false) return 0;
	if(Oyuncu[playerid][Oyunda] == false)
		return YollaHataMesaj(playerid, "Oyunda de�ilsin.");
	if(Oyuncu[playerid][Polis] == false)
		return YollaHataMesaj(playerid, "Polis de�ilsin.");
	if(Oyuncu[playerid][HedefKomut] == true)
		return YollaHataMesaj(playerid, "Tekrar kullanmak i�in biraz beklemelisin.");

	foreach(new i : Player)
		if(Oyuncu[i][GirisYapti] == true && Oyuncu[i][Oyunda] == true && Oyuncu[i][Suspect] == true)
			SetPlayerMarkerForPlayer(playerid, i, SUSPECT_RENK);
	Oyuncu[playerid][HedefKomut] = true;
	SetTimerEx("TekrarKullansin", TIMER_SANIYE(60), false, "d", playerid);
	SetTimerEx("HedefRenkSakla", TIMER_SANIYE(30), false, "d", playerid);
	YollaIpucuMesaj(playerid, "Hedefler haritada g�z�k�r hale geldi.");
	return 1;
}

CMD:oyunuhizlibaslat(playerid)
{
    if (Oyuncu[playerid][GirisYapti] == false) return 0;
	if (Oyuncu[playerid][Yonetici] < 4) return YollaHataMesaj(playerid, "Yetersiz yetki.");
	foreach(new i : Player)
	{
		YollaIpucuMesaj(i, "%s adl� yetkili oyunu h�zl� ba�latt�.", Oyuncuadi(playerid));
	}
	OyunSaniye = 1;
	return 1;
}

forward TekrarKullansin(playerid);
public TekrarKullansin(playerid)
{
	Oyuncu[playerid][HedefKomut] = false;
	return YollaIpucuMesaj(playerid, "/track komutunu tekrar kullanabilirsin.");
}

CMD:timeleft(playerid, params[])
{
	if(OyunBasladi == false)
		return YollaHataMesaj(playerid, "Aktif oyun yok.");
	YollaIpucuMesaj(playerid, "Kalan oyun s�resi: %d dakika", OyunDakika);
	return 1;
}

CMD:atamir(playerid, params[])
{
    new vehicleid = GetPlayerVehicleID(playerid);
	if(Oyuncu[playerid][Yonetici] < 2)
	    return 0;

	if(sscanf(params, "d", vehicleid))
	   	return YollaKullanMesaj(playerid, "/atamir [ara� ID]");

	if(!IsValidVehicle(vehicleid))
	 	return YollaHataMesaj(playerid, "Ge�ersiz bir ara� ID's� belirttiniz.");

	RepairVehicle(vehicleid);
	YollaIpucuMesaj(playerid, "%d ID'li ara� tamir edildi. ", vehicleid);
	engine = VEHICLE_PARAMS_ON;
	return 1;
}

CMD:pskor(playerid, params[])
{
	if(Oyuncu[playerid][Yonetici] < 2)
	    return 0;
    if(OyunBasladi == false)
	    return YollaHataMesaj(playerid, "Oyun ba�lamam��.");
	new skor;
	if(sscanf(params, "d", skor))
	   	return YollaKullanMesaj(playerid, "/pskor [skor]");
    foreach(new i : Player)
	SkorVerPolis(i, skor);
	YollaHerkeseMesaj(0x008000FF, "[B�LG�]"#BEYAZ2" %s adl� y�netici polislere %d miktar�nda skor verdi.", Oyuncuadi(playerid), skor);
	return 1;
}

CMD:aspawn(playerid, params[])
{
	if(Oyuncu[playerid][Yonetici] < 2) return 0;
    new vehicleid;
    if(sscanf( params, "i", vehicleid )) return YollaKullanMesaj(playerid, "/aspawn <aracid>" );
    DestroyVehicle(vehicleid);
    YollaIpucuMesaj(playerid, "%d ID'li arac� spawnlad�n.", vehicleid);
    return 1;
}

CMD:topdm(playerid, params[])
{
	new sorgu[100];
	mysql_format(CopSQL, sorgu, sizeof(sorgu), "SELECT isim, oldurme FROM hesaplar ORDER BY oldurme DESC LIMIT 5");
	mysql_tquery(CopSQL, sorgu, "TopListe", "d", playerid);
	return 1;
}

CMD:dmsifirla(playerid, params[])
{
	if(Oyuncu[playerid][Yonetici] < 4) return 0;
	foreach(new i : Player)
		if(Oyuncu[i][GirisYapti] == true)
			Oyuncu[i][Oldurme] = Oyuncu[i][Olum] = 0;

	mysql_tquery(CopSQL, "UPDATE hesaplar SET oldurme = 0, olum = 0");
	YollaYoneticiMesaj(1, YONETIM_RENK, "[YONETIM] %s adl� yetkili DM istatistiklerini s�f�rlad�", Oyuncuadi(playerid));
	return 1;
}

CMD:hedef(playerid, params[])
{
	if(Oyuncu[playerid][Oyunda] == false)
		return YollaHataMesaj(playerid, "Oyunda de�ilsin.");
	if(Oyuncu[playerid][Polis] == false)
		return YollaHataMesaj(playerid, "Polis de�ilsin.");
	if(Oyuncu[playerid][HedefKomut] == true)
		return YollaHataMesaj(playerid, "Bu komut bir defa kullan�labilir.");

	foreach(new i : Player)
		if(Oyuncu[i][GirisYapti] == true && Oyuncu[i][Oyunda] == true && Oyuncu[i][Suspect] == true)
			SetPlayerMarkerForPlayer(playerid, i, SUSPECT_RENK);

	Oyuncu[playerid][HedefKomut] = true;
	SetTimerEx("HedefRenkSakla", TIMER_SANIYE(30), false, "d", playerid);
	YollaIpucuMesaj(playerid, "Hedefler haritada g�z�k�r hale geldi.");
	return 1;
}

forward HedefRenkSakla(playerid);
public HedefRenkSakla(playerid)
{
	foreach(new i : Player)
		if(Oyuncu[i][GirisYapti] == true && Oyuncu[i][Oyunda] == true && Oyuncu[i][Suspect] == true)
			SetPlayerMarkerForPlayer(playerid, i, SUSPECT_RENK2);
	return 1;
}

forward TopListe(playerid);
public TopListe(playerid)
{
	new veriler = cache_num_rows();
 	if(veriler)
  	{
   		new yukle, isim[MAX_PLAYER_NAME], oldurme, liste[1000];
   		format(liste, sizeof(liste), "S�ralama\tOyuncu Ad�\t�ld�rme\n");
		while(yukle < veriler)
		{
			cache_get_value(yukle, "isim", isim, MAX_PLAYER_NAME);
			cache_get_value_int(yukle, "oldurme", oldurme);
			format(liste, sizeof(liste), "%s%d\t%s\t%d\n", liste, yukle+1, isim, oldurme);
			yukle++;
	    }
	    ShowPlayerDialog(playerid, DIALOG_X, DIALOG_STYLE_TABLIST_HEADERS, "Top 5 DM", liste, "Kapat", "");
	}
	return 1;
}

OyunAraclariYarat(oyunturu)
{
	switch(oyunturu)
	{
		case 0: // El Corona
		{
			CopArac[0] = AddStaticVehicleEx(596, 1820.062, -2044.193, 13.119, 180.0, 0, 1, -1, 1);
			CopArac[1] = AddStaticVehicleEx(596, 1758.785, -2115.574, 13.065, 270.0, 0, 1, -1, 1);
			CopArac[2] = AddStaticVehicleEx(596, 1708.844, -2197.107, 13.038, 280.0, 0, 1, -1, 1);
			CopArac[3] = AddStaticVehicleEx(596, 1512.068, -2360.651, 13.201, 0.0, 0, 1, -1, 1);
			CopArac[4] = AddStaticVehicleEx(596, 1497.761, -2361.047, 13.203, 0.0, 0, 1, -1, 1);
			CopArac[5] = AddStaticVehicleEx(596, 1959.352, -1987.203, 13.031, 180.0, 0, 1, -1, 1);
			CopArac[6] = AddStaticVehicleEx(596, 2049.927, -2164.705, 13.105, 85.0, 0, 1, -1, 1);
			CopArac[7] = AddStaticVehicleEx(596, 1853.592, -1934.950, 13.021, 280.0, 0, 1, -1, 1);
			CopArac[8] = AddStaticVehicleEx(596, 2135.875, -2210.781, 13.043, 40.0, 0, 1, -1, 1);
			CopArac[9] = AddStaticVehicleEx(596, 1793.948, -1857.551, 13.076, 270.0, 0, 1, -1, 1);
			CopArac[10] = AddStaticVehicleEx(596, 1818.986, -1818.510, 13.072, 180.0, 0, 1, -1, 1);
			CopArac[11] = AddStaticVehicleEx(596, 1958.924, -1834.223, 13.098, 180.0, 0, 1, -1, 1);
			CopArac[12] = AddStaticVehicleEx(596, 2079.129, -1866.278, 13.081, 180.0, 0, 1, -1, 1);
			CopArac[13] = AddStaticVehicleEx(596, 2102.548, -1779.288, 13.040, 270.0, 0, 1, -1, 1);
			CopArac[14] = AddStaticVehicleEx(596, 2120.683, -1782.690, 13.044, 0.0, 0, 1, -1, 1);
			CopArac[15] = AddStaticVehicleEx(596, 1426.976, -1645.409, 13.062, 0.0, 0, 1, -1, 1);
			CopArac[16] = AddStaticVehicleEx(596, 1386.827, -1755.797, 13.087, 0.0, 0, 1, -1, 1);
			CopArac[17] = AddStaticVehicleEx(596, 1386.905, -1811.897, 13.087, 0.0, 0, 1, -1, 1);
			CopArac[18] = AddStaticVehicleEx(596, 1309.308, -1854.972, 13.087, 0.0, 0, 1, -1, 1);
			CopArac[19] = AddStaticVehicleEx(596, 1267.036, -1854.965, 13.087, 0.0, 0, 1, -1, 1);
			CopArac[20] = AddStaticVehicleEx(596, 1216.377, -1854.519, 13.087, 0.0, 0, 1, -1, 1);
			CopArac[21] = AddStaticVehicleEx(596, 1239.465, -1813.193, 13.133, 0.0, 0, 1, -1, 1);
			CopArac[22] = AddStaticVehicleEx(596, 1264.760, -1796.042, 13.118, 0.0, 0, 1, -1, 1);
			SuspectArac = AddStaticVehicleEx(566, 1883.039, -2042.930, 13.173, 180.0, 3, 3, -1);
			format(OyunSebep, 150, "Darp su�undan aranan k�rm�z� renkli Tahoma, El Corona b�lgesinde g�r�ld�!");
		}
		case 1: // County General
		{	
			CopArac[0] = AddStaticVehicleEx(596, 2000.864, -1353.559, 23.651, 180.0, 0, 1, -1, 1);
			CopArac[1] = AddStaticVehicleEx(596, 1982.183, -1362.228, 23.557, 180.0, 0, 1, -1, 1);
			CopArac[2] = AddStaticVehicleEx(596, 1941.361, -1447.769, 13.205, 280.0, 0, 1, -1, 1);
			CopArac[3] = AddStaticVehicleEx(596, 2039.024, -1422.062, 16.789, 0.0, 0, 1, -1, 1);
			CopArac[4] = AddStaticVehicleEx(596, 2025.359, -1407.625, 16.803, 270.0, 0, 1, -1, 1);
			CopArac[5] = AddStaticVehicleEx(596, 2076.291, -1363.743, 23.619, 0.0, 0, 1, -1, 1);
			CopArac[6] = AddStaticVehicleEx(596, 2053.720, -1335.970, 23.611, 85.0, 0, 1, -1, 1);
			CopArac[7] = AddStaticVehicleEx(596, 2127.992, -1474.485, 23.594, 0.0, 0, 1, -1, 1);
			CopArac[8] = AddStaticVehicleEx(596, 1958.472, -1495.119, 3.065, 90.0, 0, 1, -1, 1);
			CopArac[9] = AddStaticVehicleEx(596, 1957.577, -1520.615, 3.063, 270.0, 0, 1, -1, 1);
			CopArac[10] = AddStaticVehicleEx(596, 2340.328, -1511.616, 23.547, 180.0, 0, 1, -1, 1);
			CopArac[11] = AddStaticVehicleEx(596, 2172.500, -1218.207, 23.536, 180.0, 0, 1, -1, 1);
			CopArac[12] = AddStaticVehicleEx(596, 2040.305, -1734.312, 13.254, 180.0, 0, 1, -1, 1);
			CopArac[13] = AddStaticVehicleEx(596, 1892.576, -1609.593, 13.098, 270.0, 0, 1, -1, 1);
			CopArac[14] = AddStaticVehicleEx(596, 1716.659, -1566.519, 13.260, 0.0, 0, 1, -1, 1);
			CopArac[15] = AddStaticVehicleEx(596, 2453.274, -1319.394, 23.540, 0.0, 0, 1, -1, 1);
			CopArac[16] = AddStaticVehicleEx(596, 2453.645, -1371.372, 23.540, 0.0, 0, 1, -1, 1);
			CopArac[17] = AddStaticVehicleEx(596, 2453.226, -1429.028, 23.533, 0.0, 0, 1, -1, 1);
			CopArac[18] = AddStaticVehicleEx(596, 2511.411, -1441.797, 28.065, 0.0, 0, 1, -1, 1);
			CopArac[19] = AddStaticVehicleEx(596, 2396.963, -1729.791, 13.087, 0.0, 0, 1, -1, 1);
			CopArac[20] = AddStaticVehicleEx(596, 2267.272, 1750.513, 13.087, 0.0, 0, 1, -1, 1);
			CopArac[21] = AddStaticVehicleEx(596, 2217.881, -1934.696, 13.042, 0.0, 0, 1, -1, 1);
			CopArac[22] = AddStaticVehicleEx(596, 2215.856, -1977.769, 13.095, 0.0, 0, 1, -1, 1);
			SuspectArac = AddStaticVehicleEx(490, 2000.107, -1447.887, 13.273, 180.0, 3, 3, -1);
			format(OyunSebep, 150, "County General hastanesinde rehine durumu mevcut. Ki�ilerin ambulans ile ka�t��� hakk�nda s�ylentiler var, durdurun �unlar�!");
		}
		case 2: // Mulholland
		{
			CopArac[0] = AddStaticVehicleEx(596, 1604.398, -1009.904, 23.618, 180.0, 0, 1, -1, 1);
			CopArac[1] = AddStaticVehicleEx(596, 1649.984, -1080.162, 23.617, 90.0, 0, 1, -1, 1);
			CopArac[2] = AddStaticVehicleEx(596, 1649.660, -1093.795, 23.620, 270.0, 0, 1, -1, 1);
			CopArac[3] = AddStaticVehicleEx(596, 1717.281, -1188.031, 23.380, 0.0, 0, 1, -1, 1);
			CopArac[4] = AddStaticVehicleEx(596, 1706.012, -1086.102, 23.619, 0.0, 0, 1, -1, 1);
			CopArac[5] = AddStaticVehicleEx(596, 1826.910, -1178.363, 23.344, 80.0, 0, 1, -1, 1);
			CopArac[6] = AddStaticVehicleEx(596, 1360.154, -1160.249, 23.382, 0.0, 0, 1, -1, 1);
			CopArac[7] = AddStaticVehicleEx(596, 1371.739, -1238.120, 13.094, 90.0, 0, 1, -1, 1);
			CopArac[8] = AddStaticVehicleEx(596, 1567.446, -905.510, 46.319, 120.0, 0, 1, -1, 1);
			CopArac[9] = AddStaticVehicleEx(596, 1658.206, -808.229, 56.719, 150.0, 0, 1, -1, 1);
			CopArac[10] = AddStaticVehicleEx(596, 1465.808, -860.850, 54.930, 70.0, 0, 1, -1, 1);
			CopArac[11] = AddStaticVehicleEx(596, 1431.193, -873.873, 50.831, 78.0, 0, 1, -1, 1);
			CopArac[12] = AddStaticVehicleEx(596, 1266.016, -1023.386, 32.296, 180.0, 0, 1, -1, 1);
			CopArac[13] = AddStaticVehicleEx(596, 1174.767, -954.382, 42.311, 270.0, 0, 1, -1, 1);
			CopArac[14] = AddStaticVehicleEx(596, 1210.887, -890.181, 42.636, 195.0, 0, 1, -1, 1);
			CopArac[15] = AddStaticVehicleEx(596, 1660.050, -1158.110, 23.466, 70.0, 0, 1, -1, 1);
			CopArac[16] = AddStaticVehicleEx(596, 1606.685, -1158.670, 23.643, 78.0, 0, 1, -1, 1);
			CopArac[17] = AddStaticVehicleEx(596, 1512.434, -1158.357, 23.647, 180.0, 0, 1, -1, 1);
			CopArac[18] = AddStaticVehicleEx(596, 1456.929, -1241.767, 13.130, 270.0, 0, 1, -1, 1);
			CopArac[19] = AddStaticVehicleEx(596, 1408.087, -1243.494, 13.125, 195.0, 0, 1, -1, 1);
			CopArac[20] = AddStaticVehicleEx(596, 1360.452, -1260.311, 13.125, 70.0, 0, 1, -1, 1);
			CopArac[21] = AddStaticVehicleEx(596, 1326.005, -1283.286, 13.124, 78.0, 0, 1, -1, 1);
			CopArac[22] = AddStaticVehicleEx(596, 1279.821, -1297.421, 13.086, 180.0, 0, 1, -1, 1);
			SuspectArac = AddStaticVehicleEx(482, 1453.665, -1028.426, 23.855, 90.0, 0, 0, -1);
			format(OyunSebep, 150, "Mulholland b�lgesinde siyah Burrito �zerinde banka soygunu ihbar� ald�k, durdurun �u adamlar�!");
		}
		case 3: // Old Venturas
		{
			CopArac[0] = AddStaticVehicleEx(596, 2370.125, 2235.476, 10.393, 90.0, 0, 1, -1, 1);
			CopArac[1] = AddStaticVehicleEx(596, 2326.904, 2230.701, 10.399, 270.0, 0, 1, -1, 1);
			CopArac[2] = AddStaticVehicleEx(596, 2367.982, 2055.382, 10.397, 90.0, 0, 1, -1, 1);
			CopArac[3] = AddStaticVehicleEx(596, 2149.896, 2033.795, 10.388, 0.0, 0, 1, -1, 1);
			CopArac[4] = AddStaticVehicleEx(596, 2424.345, 2251.765, 10.385, 180.0, 0, 1, -1, 1);
			CopArac[5] = AddStaticVehicleEx(596, 2258.472, 2230.639, 10.389, 270.0, 0, 1, -1, 1);
			CopArac[6] = AddStaticVehicleEx(596, 2378.130, 2019.034, 10.532, 90.0, 0, 1, -1, 1);
			CopArac[7] = AddStaticVehicleEx(596, 2185.970, 2004.173, 10.534, 270.0, 0, 1, -1, 1);
			CopArac[8] = AddStaticVehicleEx(596, 2102.706, 2036.354, 10.534, 180.0, 0, 1, -1, 1);
			CopArac[9] = AddStaticVehicleEx(596, 2032.762, 2147.281, 10.541, 0.0, 0, 1, -1, 1);
			CopArac[10] = AddStaticVehicleEx(596, 1891.269, 2116.209, 10.535, 90.0, 0, 1, -1, 1);
			CopArac[11] = AddStaticVehicleEx(596, 1912.863, 2156.399, 10.533, 78.0, 0, 1, -1, 1);
			CopArac[12] = AddStaticVehicleEx(596, 1880.449, 2258.548, 10.533, 180.0, 0, 1, -1, 1);
			CopArac[13] = AddStaticVehicleEx(596, 1987.517, 2467.376, 10.531, 270.0, 0, 1, -1, 1);
			CopArac[14] = AddStaticVehicleEx(596, 2223.065, 2467.810, 10.459, 180.0, 0, 1, -1, 1);
			CopArac[15] = AddStaticVehicleEx(596, 1940.364, 1710.710, 10.376, 90.0, 0, 1, -1, 1);
			CopArac[16] = AddStaticVehicleEx(596, 1890.426, 1710.482, 10.376, 78.0, 0, 1, -1, 1);
			CopArac[17] = AddStaticVehicleEx(596, 1809.128, 1635.590, 6.446, 180.0, 0, 1, -1, 1);
			CopArac[18] = AddStaticVehicleEx(596, 1809.680, 1558.835, 6.439, 270.0, 0, 1, -1, 1);
			CopArac[19] = AddStaticVehicleEx(596, 1810.159, 1502.495, 6.439, 180.0, 0, 1, -1, 1);
			CopArac[20] = AddStaticVehicleEx(596, 1989.314, 1405.921, 8.814, 90.0, 0, 1, -1, 1);
			CopArac[21] = AddStaticVehicleEx(596, 1968.575, 1389.779, 8.814, 78.0, 0, 1, -1, 1);
			CopArac[22] = AddStaticVehicleEx(596, 1949.648, 1360.003, 8.814, 180.0, 0, 1, -1, 1);
			SuspectArac = AddStaticVehicleEx(400, 2346.036, 2172.050, 10.407, 180.0, 2, 2, -1);
			format(OyunSebep, 150, "�nsan ka�ak��l��� su�undan aranan �ah�slar mavi renkli Landstalker i�erisinde Old Venturas Strip b�lgesinde g�r�ld�!");
		}
		case 4: // Santo Flora
		{
			CopArac[0] = AddStaticVehicleEx(596, -2491.801, 723.608, 34.734, 270.0, 0, 1, -1, 1);
			CopArac[1] = AddStaticVehicleEx(596, -2482.321, 705.312, 34.730, 270.0, 0, 1, -1, 1);
			CopArac[2] = AddStaticVehicleEx(596, -2383.217, 641.607, 34.730, 0.0, 0, 1, -1, 1);
			CopArac[3] = AddStaticVehicleEx(596, -2316.380, 673.009, 42.660, 90.0, 0, 1, -1, 1);
			CopArac[4] = AddStaticVehicleEx(596, -2404.955, 804.958, 34.743, 270.0, 0, 1, -1, 1);
			CopArac[5] = AddStaticVehicleEx(596, -2544.858, 659.574, 27.519, 90.0, 0, 1, -1, 1);
			CopArac[6] = AddStaticVehicleEx(596, -2379.554, 831.612, 36.938, 0.0, 0, 1, -1, 1);
			CopArac[7] = AddStaticVehicleEx(596, -2090.868, 717.516, 69.129, 180.0, 0, 1, -1, 1);
			CopArac[8] = AddStaticVehicleEx(596, -2399.348, 703.415, 34.805, 90.0, 0, 1, -1, 1);
			CopArac[9] = AddStaticVehicleEx(596, -2460.650, 794.855, 34.885, 90.0, 0, 1, -1, 1);
			CopArac[10] = AddStaticVehicleEx(596, -2494.729, 782.156, 34.885, 270.0, 0, 1, -1, 1);
			CopArac[11] = AddStaticVehicleEx(596, -2345.654, 505.560, 29.662, 90.0, 0, 1, -1, 1);
			CopArac[12] = AddStaticVehicleEx(596, -2268.979, 534.588, 34.729, 180.0, 0, 1, -1, 1);
			CopArac[13] = AddStaticVehicleEx(596, -1956.330, 584.945, 34.841, 180.0, 0, 1, -1, 1);
			CopArac[14] = AddStaticVehicleEx(596, -1707.022, 697.091, 24.521, 0.0, 0, 1, -1, 1);
			CopArac[15] = AddStaticVehicleEx(596, -2403.412, 905.853, 45.010, 270.0, 0, 1, -1, 1);
			CopArac[16] = AddStaticVehicleEx(596, -2402.605, 957.250, 45.044, 90.0, 0, 1, -1, 1);
			CopArac[17] = AddStaticVehicleEx(596, -2369.694, 967.065, 45.320, 180.0, 0, 1, -1, 1);
			CopArac[18] = AddStaticVehicleEx(596, -2360.341, 969.053, 45.467, 180.0, 0, 1, -1, 1);
			CopArac[19] = AddStaticVehicleEx(596, -2523.780, 693.302, 27.581, 0.0, 0, 1, -1, 1);
			CopArac[20] = AddStaticVehicleEx(596, -2528.712, 803.730, 49.569, 270.0, 0, 1, -1, 1);
			CopArac[21] = AddStaticVehicleEx(596, -2543.910, 806.448, 49.568, 90.0, 0, 1, -1, 1);
			CopArac[22] = AddStaticVehicleEx(596, -2478.448, 805.933, 34.833, 180.0, 0, 1, -1, 1);
			SuspectArac = AddStaticVehicleEx(445, -2417.382, 732.860, 34.804, 270.0, 0, 0, -1);
			format(OyunSebep, 150, "Santa Flora b�lgesinde silah sesleri y�kselmi�, siyah renkli Admiral ��pheli olabilir!");
		}
		case 5: // Tierra Robada
		{
			CopArac[0] = AddStaticVehicleEx(596, -1977.9967, 2532.6375, 55.1482, 213.4685, 0, 1, -1, 1);
			CopArac[1] = AddStaticVehicleEx(596, -1812.1467, 2275.0359, 26.1743, 53.1049, 0, 1, -1, 1);
			CopArac[2] = AddStaticVehicleEx(596, -2013.7227, 2630.7898, 50.5671, 68.5100, 0, 1, -1, 1);
			CopArac[3] = AddStaticVehicleEx(596, -2210.1797, 2634.7485, 54.9838, 268.0283, 0, 1, -1, 1);
			CopArac[4] = AddStaticVehicleEx(596, -1996.6832, 2275.9478, 17.7022, 179.3504, 0, 1, -1, 1);
			CopArac[5] = AddStaticVehicleEx(596, -1857.0243, 2184.5942, 5.5728, 217.2073, 0, 1, -1, 1);
			CopArac[6] = AddStaticVehicleEx(596, -1757.9906, 2184.1975, 2.6298, 325.3400, 0, 1, -1, 1);
			CopArac[7] = AddStaticVehicleEx(596, -1667.7766, 2038.4658, 18.0067, 176.2229, 0, 1, -1, 1);
			CopArac[8] = AddStaticVehicleEx(596, -1621.8799, 1828.5580, 25.4328, 278.4627, 0, 1, -1, 1);
			CopArac[9] = AddStaticVehicleEx(596, -1549.9117, 1894.0521, 25.8237, 34.4736, 0, 1, -1, 1);
			CopArac[10] = AddStaticVehicleEx(596, -2149.5942, 2675.3677, 53.0020, 81.5013, 0, 1, -1, 1);
			CopArac[11] = AddStaticVehicleEx(596, -2391.6155, 2676.0376, 59.2316, 92.5298, 0, 1, -1, 1);
			CopArac[12] = AddStaticVehicleEx(596, -2537.1458, 2672.6758, 67.7458, 87.8842, 0, 1, -1, 1);
			CopArac[13] = AddStaticVehicleEx(596, -2564.3154, 2607.8184, 62.0114, 279.3601, 0, 1, -1, 1);
			CopArac[14] = AddStaticVehicleEx(596, -2716.2483, 2509.7629, 76.5157, 331.0799, 0, 1, -1, 1);
			CopArac[15] = AddStaticVehicleEx(596, -2751.5476, 2346.6675, 72.6681, 281.1887, 0, 1, -1, 1);
			CopArac[16] = AddStaticVehicleEx(596, -2771.6768, 2485.8772, 95.0384, 177.0405, 0, 1, -1, 1);
			CopArac[17] = AddStaticVehicleEx(596, -1885.2776, 2514.6975, 47.0844, 302.8833, 0, 1, -1, 1);
			CopArac[18] = AddStaticVehicleEx(596, -1853.3893, 2677.6941, 53.9725, 142.2163, 0, 1, -1, 1);
			CopArac[19] = AddStaticVehicleEx(596, -1755.4658, 2695.9053, 58.9759, 48.0498, 0, 1, -1, 1);
			CopArac[20] = AddStaticVehicleEx(596, -1995.7299, 2457.5933, 36.5119, 144.5222, 0, 1, -1, 1);
			CopArac[21] = AddStaticVehicleEx(596, -1730.9485, 2303.2144, 32.6903, 137.8322, 0, 1, -1, 1);
			CopArac[22] = AddStaticVehicleEx(596, -1336.2861, 1863.1616, 37.3663, 92.2664, 0, 1, -1, 1);
			SuspectArac = AddStaticVehicleEx(579, -1922.0355, 2368.8713, 49.1344, 239.6615, 0, 0, -1);
			format(OyunSebep, 150, "Tierra Robada eyalet yolunda Jay's Diner adl� i�yeri soyulmu�, ��phelilerin siyah Huntley kulland���n� biliyoruz!");
		}
	}
	return 1;
}

OyuncuOyunDegerSifirla(playerid, oyunturu)
{
	if(Oyuncu[playerid][Oyunda] == true && Oyuncu[playerid][Suspect] == true && EventModu == false && EventModu2 == false)
		SetPlayerSkin(playerid, Skinler[oyunturu][random(4)]);

	SetPlayerColor(playerid, BEYAZ3);
	ResetPlayerWeapons(playerid);
	TogglePlayerControllable(playerid, 1);
	SetPlayerVirtualWorld(playerid, 0);
	SetPlayerInterior(playerid, 0);
	SetPlayerHealth(playerid, 100.0);
}

OyunPolisSayi()
{
	new sayi;
	foreach(new i : Player)
    {
        if(Oyuncu[i][Oyunda] == true && Oyuncu[i][Polis] == true)
        {
        	sayi++;
        }
    }
	return sayi;
}

OyunSuspectSayi()
{
	new sayi;
	foreach(new i : Player)
    {
        if(Oyuncu[i][Oyunda] == true && Oyuncu[i][Suspect] == true)
        {
        	sayi++;
        }
    }
	return sayi;
}

OyunSonPolisID()
{
	new oyuncuid = INVALID_PLAYER_ID;
	foreach(new i : Player)
    {
        if(Oyuncu[i][Oyunda] == true && Oyuncu[i][Polis] == true)
        {
        	oyuncuid = i;
        }
    }
	return oyuncuid;
}

forward OyunBasliyor(oyunturu);
public OyunBasliyor(oyunturu)
{
	if(OyunSaniye <= 10)
	{
		foreach(new i : Player)
    	{
	        if(Oyuncu[i][Oyunda] == false && Oyuncu[i][GirisYapti] == true && Oyuncu[i][AFK] == false && Oyuncu[i][DM] == true)
	        {
	        	YollaIpucuMesaj(i, "Oyun birazdan ba�layaca�� i�in lobiye spawnland�n!");
	        	LobiyeDon(i);
	        }
	    }
	}
	new mesaj[100];
	format(mesaj, sizeof(mesaj), "~w~Oyun baslamasina %d", OyunSaniye);
	OyunSaniye--;
	GameTextForAll(mesaj, 1000, 4);
	if(OyuncuSayisi() < 2)
	{
		OyunSaniye = OYUN_SANIYE;
		OyunDakika = OYUN_DAKIKA;
		OyunBasladi = OyunSayac = false;
		KillTimer(OyunTimer);
		return 1;
	}
	if(OyunSaniye == 0)
	{
		OyunBasladi = true;
		OyunModuTip = 0;
		HerkesFreeze = SuspectAtes = false;
		new oyuncusayi = OyuncuSayisi(), suspect[4];
		SelectRandomPlayers(suspect, 4);
		OyunAraclariYarat(oyunturu);
		new aracid = 0, Float: pos[4], koltuk = 1, bool: Arac_Koltuk[23], bool: Arac_Koltuk2[23];
		for(new aaracid; aaracid < 23; aaracid++)
			AracYaratildi[CopArac[aaracid]] = false;
		foreach(new i : Player)
		{
			if(Oyuncu[i][GirisYapti] == true && Oyuncu[i][AFK] == false)
			{
				if((i == suspect[0]) || (oyuncusayi >= 6 && i == suspect[1]) || (oyuncusayi >= 9 && i == suspect[2]) || (oyuncusayi >= 13 && i == suspect[3]))
				{
					Oyuncu[i][Oyunda] = Oyuncu[i][Suspect] = true;
					Oyuncu[i][Polis] = Oyuncu[i][DM] = Oyuncu[i][AracTamir] = Oyuncu[i][SuspectSari] = false;
					OyuncuOyunDegerSifirla(i, oyunturu);
					Oyuncu[i][SuspectTimer3] = SetTimerEx("SuspectSakla", TIMER_SANIYE(40), false, "d", i);
					Oyuncu[i][SuspectTimer2] = SetTimerEx("SuspectSilahVer", TIMER_SANIYE(25), false, "d", i);
					if(i == suspect[0])
						PutPlayerInVehicle(i, SuspectArac, 0);
					else
					{
						PutPlayerInVehicle(i, SuspectArac, koltuk);
						koltuk++;
					}
					continue;
				}
				if(Arac_Koltuk[CopArac[aracid]] == true && Arac_Koltuk2[CopArac[aracid]] == true) aracid++;
				if((random(2) == 0 && Arac_Koltuk[CopArac[aracid]] == false) || Arac_Koltuk2[CopArac[aracid]] == true)
				{
					if(Arac_Koltuk[CopArac[aracid]] == false)
					{
						if(Oyuncu[i][PolisArac] != 0 && Oyuncu[i][PolisArac] >= 400)
		    			{
		    				GetVehiclePos(CopArac[aracid], pos[0], pos[1], pos[2]);
		    				GetVehicleZAngle(CopArac[aracid], pos[3]);
		    				DestroyVehicle(CopArac[aracid]);
		    				CopArac[aracid] = AddStaticVehicleEx(Oyuncu[i][PolisArac], pos[0], pos[1], pos[2], pos[3], 0, 1, -1, 1);
		    			}
		    			AracHasar[CopArac[aracid]] = AracSirenDurumu[CopArac[aracid]] = false;
		    			AracKilitSahip[CopArac[aracid]] = -1;
		    			Arac_Koltuk[CopArac[aracid]] = AracYaratildi[CopArac[aracid]] = true;
		    			SetVehicleParamsEx(CopArac[aracid], VEHICLE_PARAMS_ON, VEHICLE_PARAMS_OFF, alarm, VEHICLE_PARAMS_OFF, VEHICLE_PARAMS_OFF, VEHICLE_PARAMS_OFF, objective);
						PutPlayerInVehicle(i, CopArac[aracid], 0);
						Oyuncu[i][AracYanKoltuk] = -1;
					}
				}
				else
				{
					if(Arac_Koltuk2[CopArac[aracid]] == false)
					{
						Arac_Koltuk2[CopArac[aracid]] = true;
						Oyuncu[i][AracYanKoltuk] = aracid;
					}
				}
				Oyuncu[i][Oyunda] = Oyuncu[i][Polis] = Oyuncu[i][OyunSilah] = true;
				Oyuncu[i][Suspect] = Oyuncu[i][AracTamir] = Oyuncu[i][PolisGPS] = Oyuncu[i][ElmDurum] = Oyuncu[i][DM] = false;
				Oyuncu[i][HedefKomut] = Oyuncu[i][TaserMermiDegis] = Oyuncu[i][SuspectSari] = false;
    			Oyuncu[i][EngelHak] = Oyuncu[i][EngelSec] = 0;
				for(new j; j < 7; j++) Oyuncu[i][Silah][j] = false;
				SetTimerEx("PolisSilah", TIMER_SANIYE(25), false, "d", i);
				OyuncuOyunDegerSifirla(i, oyunturu);
			}
		}
		AracHasar[SuspectArac] = false;
		AracKilitSahip[SuspectArac] = -1;
		SetVehicleParamsEx(SuspectArac, VEHICLE_PARAMS_ON, VEHICLE_PARAMS_OFF, alarm, VEHICLE_PARAMS_OFF, VEHICLE_PARAMS_OFF, VEHICLE_PARAMS_OFF, objective);
		OyunDakika = OYUN_DAKIKA;
		SuspectSaklaTimer = SetTimer("SuspectCCTV", TIMER_DAKIKA(1), true);
		OyunKalanTimer = SetTimer("OyunKalanSure", TIMER_DAKIKA(1), true);
		AracKontrolTimer = SetTimer("AracKontrol", TIMER_SANIYE(1), true);
		KillTimer(OyunTimer);
		new sonpolis = OyunSonPolisID();
		foreach(new i : Player)
		{
			if(Oyuncu[i][GirisYapti] == true && Oyuncu[i][Oyunda] == true)
			{
				if(Oyuncu[i][Polis] == true)
				{
					TogglePlayerControllable(i, 0);
					if(Oyuncu[i][AracYanKoltuk] != -1)
						PutPlayerInVehicle(i, CopArac[Oyuncu[i][AracYanKoltuk]], 1);
				}
			}
		}
		if(TekSayiKontrol(OyunPolisSayi()))
		{
			if(Oyuncu[sonpolis][PolisArac] != 0 && Oyuncu[sonpolis][PolisArac] >= 400)
			{
				GetVehiclePos(CopArac[aracid], pos[0], pos[1], pos[2]);
				GetVehicleZAngle(CopArac[aracid], pos[3]);
				DestroyVehicle(CopArac[aracid]);
				CopArac[aracid] = AddStaticVehicleEx(Oyuncu[sonpolis][PolisArac], pos[0], pos[1], pos[2], pos[3], 0, 1, -1, 1);
			}
			AracHasar[CopArac[aracid]] = AracSirenDurumu[CopArac[aracid]] = false;
			AracKilitSahip[CopArac[aracid]] = -1;
			AracYaratildi[CopArac[aracid]] = true;
			SetVehicleParamsEx(CopArac[aracid], VEHICLE_PARAMS_ON, VEHICLE_PARAMS_OFF, alarm, VEHICLE_PARAMS_OFF, VEHICLE_PARAMS_OFF, VEHICLE_PARAMS_OFF, objective);
			PutPlayerInVehicle(sonpolis, CopArac[aracid], 0);
		}
		SetTimer("OyunRenkleriDuzelt", TIMER_SANIYE(1), false);
		Oyuncu[suspect[0]][OyunModu] = true;
		Oyuncu[suspect[0]][OyunModTimer] = SetTimerEx("OyunModuTimer", TIMER_SANIYE(10), false, "d", suspect[0]);
		ShowPlayerDialog(suspect[0], DIALOG_OYUNMODU, DIALOG_STYLE_MSGBOX, ""#SUNUCU_KISALTMA" - Oyun Modu", ""#BEYAZ2"Oyun modunu se�iniz.", ""#YESIL2"Roleplay", ""#KIRMIZI2"Non-RP");
		YollaHerkeseMesaj(TURUNCU, OyunSebep);
		for(new aaracid; aaracid < 23; aaracid++)
			if(IsValidVehicle(CopArac[aaracid]) && AracYaratildi[CopArac[aaracid]] == false)
				DestroyVehicle(CopArac[aaracid]);

		OyunArac[0] = AddStaticVehicleEx(497, -2464.971, 2232.431, 5.002, 0.0, 0, 1, -1, 1);
		OyunArac[1] = AddStaticVehicleEx(430, -2235.382, 2392.731, -0.181, 0.0, 0, 1, -1, 1);
		OyunArac[2] = AddStaticVehicleEx(497, -2227.228, 2325.099, 7.724, 0.0, 0, 1, -1, 1);
		OyunArac[3] = AddStaticVehicleEx(430, -2232.117, 2430.063, -0.224, 0.0, 0, 1, -1, 1);
		OyunArac[4] = AddStaticVehicleEx(497, -1677.762, 707.221, 30.778, 0.0, 0, 1, -1, 1);
		OyunArac[5] = AddStaticVehicleEx(430, 2926.821, -2044.065, -0.345, 0.0, 0, 1, -1, 1);
		OyunArac[6] = AddStaticVehicleEx(497, 2314.149, 2449.964, 10.997, 0.0, 0, 1, -1, 1);
		OyunArac[7] = AddStaticVehicleEx(430, 201.571, -1909.995, -0.168, 0.0, 0, 1, -1, 1);
		OyunArac[8] = AddStaticVehicleEx(497, 1557.386, -1611.595, 13.559, 0.0, 0, 1, -1, 1);
		OyunArac[9] = AddStaticVehicleEx(430, -927.899, 2647.256, 40.387, 0.0, 0, 1, -1, 1);
		for(new aracidd; aracidd < 10; aracidd++)
		{
			AracHasar[OyunArac[aracidd]] = AracSirenDurumu[OyunArac[aracidd]] = false;
			AracKilitSahip[OyunArac[aracidd]] = -1;
			SetVehicleParamsEx(OyunArac[aracidd], VEHICLE_PARAMS_OFF, VEHICLE_PARAMS_OFF, alarm, VEHICLE_PARAMS_OFF, VEHICLE_PARAMS_OFF, VEHICLE_PARAMS_OFF, objective);
		}
		return 1;
	}
	return 1;
}

forward OyunRenkleriDuzelt();
public OyunRenkleriDuzelt()
{
	foreach(new i : Player)
	{
		if(Oyuncu[i][GirisYapti] == true && Oyuncu[i][Oyunda] == true)
		{
			if(Oyuncu[i][Polis] == true)
				SetPlayerColor(i, POLIS_RENK2);
			if(Oyuncu[i][Suspect] == true)
				SetPlayerColor(i, SUSPECT_RENK);
		}
		else SetPlayerColor(i, BEYAZ3);
	}
	return 1;
}

forward GetDistanceBetweenPlayers(playerid, id, Float:distance);
public GetDistanceBetweenPlayers(playerid, id, Float:distance)
{
	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);

	if(GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(id) && GetPlayerInterior(playerid) == GetPlayerInterior(id)) {
		if(IsPlayerInRangeOfPoint(id, distance, x, y, z)) {
			return true;
		}
	}
	return false;
}

forward DisplayDamageData(playerid, forplayerid);
public DisplayDamageData(playerid, forplayerid)
{
	new count = 0;
	for(new i = 0; i < MAX_DAMAGES; i++) {
		if(DamageData[i][DamagePlayerID] == playerid) {
			count++;
		}
	}

	new longstr[512] = EOS, weaponname[20] = EOS;
	for(new i = 0; i < MAX_DAMAGES; i++) {
		if(DamageData[i][DamagePlayerID] == playerid) {
			GetWeaponName(DamageData[i][DamageWeapon], weaponname, sizeof(weaponname));
			format(longstr, sizeof(longstr), "%s(%s - %s) %s\n", longstr, GetDamageType(DamageData[i][DamageWeapon]), GetBoneDamaged(DamageData[i][DamageBodyPart]), weaponname);
		}
	}

	ShowPlayerDialog(playerid, DIALOG_HASARLAR, DIALOG_STYLE_LIST, "Hasar Bilgileri", longstr, "Tamam", "");
	return true;
}

GetDamageType(weaponid)
{
	new damageType[32] = EOS;

	switch(weaponid)
	{
		case 0 .. 3, 5 .. 7, 10 .. 15: damageType = "Hafif Travma";
		case 4, 8, 9: damageType = "B��ak Yaras�";
		case 22 .. 34: damageType = "Kur�un Yaras�";
		case 18, 35, 36, 37, 16, 39, 40: damageType = "Yan�k/Patlay�c� Yaras�";
		default: damageType = "Bilinmeyen Yaralanma";
	}
	return damageType;
}

GetBoneDamaged(bodypart)
{
	new bodypartR[20] = EOS;
	switch(bodypart)
	{
		case BODY_PART_CHEST: bodypartR = "G���s";
		case BODY_PART_TORSO: bodypartR = "G�vde";
		case BODY_PART_LEFT_ARM: bodypartR = "Sol Kol";
		case BODY_PART_RIGHT_ARM: bodypartR = "Sol Kol";
		case BODY_PART_LEFT_LEG: bodypartR = "Sol Bacak";
		case BODY_PART_RIGHT_LEG: bodypartR = "Sa� Bacak";
		case BODY_PART_HEAD: bodypartR = "Kafa";
	}
	return bodypartR;
}

forward OyuncuAracCarpisma();
public OyuncuAracCarpisma()
{
	foreach(new i : Player) if(Oyuncu[i][GirisYapti] == true && Oyuncu[i][Oyunda] == true)
	{
		DisableRemoteVehicleCollisions(i, 0);
		YollaIpucuMesaj(i, "�arp��malar a��ld�, dikkatli olun!");
	}
	return 1;
}

//ALIAS
alias:swapseats("ss");
alias:scrollwep("sw");
alias:kelepce("cuff");
alias:revive("kaldir");
alias:nitrous("nitro");
alias:sustur("mute");
alias:bicycle("bc");
alias:r("t");
