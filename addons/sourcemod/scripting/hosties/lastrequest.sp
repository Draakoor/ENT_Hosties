/*
 * SourceMod Hosties Project
 * by: SourceMod Hosties Dev Team
 *
 * This file is part of the SM Hosties project.
 *
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) 
 * any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#define FlashbangOffset         12    // (12 * 4)
#define MAX_BUTTONS				25
#define IN_ATTACK2				(1 << 11)
 
// Include files
#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <sdkhooks>
#include <sdktools>
#include <hosties>
#include <lastrequest>
#include <smlib>
#include <multicolors>
#include <hosties-restore>

// Compiler options
#pragma semicolon 1

// Global variables
int g_LastButtons[MAXPLAYERS+1];
bool g_TriedToStab[MAXPLAYERS+1] = false;

ConVar g_hRoundTime;
int g_RoundTime;
Handle RoundTimeTicker;
Handle TickerState = INVALID_HANDLE;
float After_Jump_pos[MAXPLAYERS+1][3];
float Before_Jump_pos[MAXPLAYERS+1][3];
bool LR_Player_Jumped[MAXPLAYERS+1] = false;
bool LR_Player_Landed[MAXPLAYERS+1] = false;
float f_DoneDistance[MAXPLAYERS+1];

bool g_bIsLRAvailable = true;
bool g_bRoundInProgress = true;
bool g_bListenersAdded = false;
bool g_bAnnouncedThisRound = false;
bool g_bInLastRequest[MAXPLAYERS+1];
bool g_bIsARebel[MAXPLAYERS+1];
Handle gH_BuildLR[MAXPLAYERS+1];
LastRequest g_LRLookup[MAXPLAYERS+1];
int g_LR_PermissionLookup[MAXPLAYERS+1];
Handle g_GunTossTimer = null;
Handle g_ChickenFightTimer = null;
Handle g_DodgeballTimer = null;
Handle g_BeaconTimer = null;
Handle g_RaceTimer = null;
Handle g_DelayLREnableTimer = null;
Handle g_BeerGogglesTimer = null;
Handle g_CountdownTimer = null;
Handle g_FarthestJumpTimer = null;

Handle gH_Frwd_LR_CleanUp = null;
Handle gH_Frwd_LR_Start = null;
Handle gH_Frwd_LR_Process = null;
Handle gH_Frwd_LR_StartGlobal = null;
Handle gH_Frwd_LR_Available = null;

int BeamSprite = -1;
int HaloSprite = -1;
int LaserSprite = -1;
int LaserHalo = -1;
int greenColor[] = {15, 255, 15, 255};
int redColor[] = {255, 25, 15, 255};
int blueColor[] = {50, 75, 255, 255};
int greyColor[] = {128, 128, 128, 255};
int yellowColor[] = {255, 255, 0, 255};

int g_Offset_Armor = -1;
int g_Offset_Clip1 = -1;
int g_Offset_Ammo = -1;
int g_Offset_FOV = -1;
int g_Offset_ActiveWeapon = -1;
int g_Offset_GroundEnt = -1;
int g_Offset_DefFOV = -1;
int g_Offset_PunchAngle = -1; 
int g_Offset_SecAttack = -1;

Handle gH_DArray_LastRequests = null;
Handle gH_DArray_LR_Partners = null;
Handle gH_DArray_Beacons = null;
Handle gH_DArray_LR_CustomNames = null;

ConVar gH_Cvar_LR_KnifeFight_On;
ConVar gH_Cvar_LR_Shot4Shot_On;
ConVar gH_Cvar_LR_GunToss_On;
ConVar gH_Cvar_LR_ChickenFight_On;
ConVar gH_Cvar_LR_HotPotato_On;
ConVar gH_Cvar_LR_Dodgeball_On;
ConVar gH_Cvar_LR_NoScope_On;
ConVar gH_Cvar_LR_RockPaperScissors_On;
ConVar gH_Cvar_LR_Rebel_On;
ConVar gH_Cvar_LR_Mag4Mag_On;
ConVar gH_Cvar_LR_Race_On;
ConVar gH_Cvar_LR_RussianRoulette_On;
ConVar gH_Cvar_LR_JumpContest_On;
ConVar gH_Cvar_Announce_Delay_Enable;
ConVar gH_Cvar_LR_HotPotato_Mode;
ConVar gH_Cvar_MaxPrisonersToLR;
ConVar gH_Cvar_RebelAction;
ConVar gH_Cvar_RebelHandling;
ConVar gH_Cvar_SendGlobalMsgs;
ConVar gH_Cvar_ColorRebels;
ConVar gH_Cvar_LR_Enable;
ConVar gH_Cvar_LR_MenuTime;
ConVar gH_Cvar_LR_KillTimeouts;
ConVar gH_Cvar_ColorRebels_Red;
ConVar gH_Cvar_ColorRebels_Blue;
ConVar gH_Cvar_ColorRebels_Green;
ConVar gH_Cvar_LR_Beacons;
ConVar gH_Cvar_LR_HelpBeams;
ConVar gH_Cvar_LR_HelpBeams_Distance;
ConVar gH_Cvar_LR_Beacon_Interval;
ConVar gH_Cvar_RebelOnImpact;
ConVar gH_Cvar_LR_ChickenFight_Slay;
ConVar gH_Cvar_LR_ChickenFight_C_Blue;
ConVar gH_Cvar_LR_ChickenFight_C_Red;
ConVar gH_Cvar_LR_ChickenFight_C_Green;
ConVar gH_Cvar_LR_Dodgeball_CheatCheck;
ConVar gH_Cvar_LR_Dodgeball_SpawnTime;
ConVar gH_Cvar_LR_Dodgeball_Gravity;
ConVar gH_Cvar_LR_HotPotato_MaxTime;
ConVar gH_Cvar_LR_HotPotato_MinTime;
ConVar gH_Cvar_LR_HotPotato_Speed;
ConVar gH_Cvar_LR_NoScope_Sound;
ConVar gH_Cvar_LR_Sound;
ConVar gH_Cvar_LR_NoScope_Weapon;
ConVar gH_Cvar_LR_S4S_DoubleShot;
ConVar gH_Cvar_LR_GunToss_MarkerMode;
ConVar gH_Cvar_LR_GunToss_ShowMeter;
ConVar gH_Cvar_LR_Race_AirPoints;
ConVar gH_Cvar_LR_Race_NotifyCTs;
ConVar gH_Cvar_Announce_CT_FreeHit;
ConVar gH_Cvar_Announce_LR;
ConVar gH_Cvar_Announce_Rebel;
ConVar gH_Cvar_Announce_RebelDown;
ConVar gH_Cvar_Announce_Weapon_Attack;
ConVar gH_Cvar_Announce_HotPotato_Eqp;
ConVar gH_Cvar_Announce_Shot4Shot;
ConVar gH_Cvar_LR_NonContKiller_Action;
ConVar gH_Cvar_LR_Delay_Enable_Time;
ConVar gH_Cvar_LR_Damage;
ConVar gH_Cvar_LR_NoScope_Delay;
ConVar gH_Cvar_LR_ChickenFight_Rebel;
ConVar gH_Cvar_LR_HotPotato_Rebel;
ConVar gH_Cvar_LR_KnifeFight_Rebel;
ConVar gH_Cvar_LR_Rebel_MaxTs;
ConVar gH_Cvar_LR_Rebel_MinCTs;
ConVar gH_Cvar_LR_M4M_MagCapacity;
ConVar gH_Cvar_LR_KnifeFight_LowGrav;
ConVar gH_Cvar_LR_KnifeFight_HiSpeed;
ConVar gH_Cvar_LR_KnifeFight_Drunk;
ConVar gH_Cvar_LR_Beacon_Sound;
ConVar gH_Cvar_LR_AutoDisplay;
ConVar gH_Cvar_LR_BlockSuicide;
ConVar gH_Cvar_LR_VictorPoints;
ConVar gH_Cvar_LR_RestoreWeapon_T;
ConVar gH_Cvar_LR_RestoreWeapon_CT;
ConVar gH_Cvar_LR_Rebel_HP_per_CT;

int g_iLastCT_FreeAttacker = -1;
bool g_bPushedToMenu = false;

// Autostart
LastRequest g_selection[MAXPLAYERS + 1];
int g_LR_Player_Guard[MAXPLAYERS + 1] = 0;

// Custom types local to the plugin
enum NoScopeWeapon
{
	NSW_AWP = 0,
	NSW_Scout,
	NSW_SG550,
	NSW_G3SG1
};

enum PistolWeapon
{
	Pistol_Deagle = 0,
	Pistol_P228,
	Pistol_Glock,
	Pistol_FiveSeven,
	Pistol_Dualies,
	Pistol_USP,
	Pistol_Tec9,
	Pistol_Revolver
};

enum KnifeType
{
	Knife_Vintage = 0,
	Knife_Drunk,
	Knife_LowGrav,
	Knife_HiSpeed,
	Knife_Drugs,
	Knife_ThirdPerson,
	Knife_Throwing,
	Knife_Flying
};

enum JumpContest
{
	Jump_TheMost = 0,
	Jump_Farthest,
	Jump_BrinkOfDeath
};

char g_sLastRequestPhrase[LastRequest][MAX_DISPLAYNAME_SIZE];

void LastRequest_OnPluginStart()
{
	// Populate translation entries
	// no longer pulling LANG_SERVER
	g_sLastRequestPhrase[LR_KnifeFight] = "Knife Fight";
	g_sLastRequestPhrase[LR_Shot4Shot] = "Shot4Shot";
	g_sLastRequestPhrase[LR_GunToss] = "Gun Toss";
	g_sLastRequestPhrase[LR_ChickenFight] = "Chicken Fight";
	g_sLastRequestPhrase[LR_HotPotato] = "Hot Potato";
	g_sLastRequestPhrase[LR_Dodgeball] = "Dodgeball";
	g_sLastRequestPhrase[LR_NoScope] = "No Scope Battle";
	g_sLastRequestPhrase[LR_RockPaperScissors] = "Rock Paper Scissors";
	g_sLastRequestPhrase[LR_Rebel] = "Rebel!";
	g_sLastRequestPhrase[LR_Mag4Mag] = "Mag4Mag";
	g_sLastRequestPhrase[LR_Race] = "Race";
	g_sLastRequestPhrase[LR_RussianRoulette] = "Russian Roulette";
	g_sLastRequestPhrase[LR_JumpContest] = "Jumping Contest";

	// Gather all offsets
	g_Offset_Health = FindSendPropInfo("CBasePlayer", "m_iHealth");
	if (g_Offset_Health == -1)
	{
		SetFailState("Unable to find offset for health.");
	}
	g_Offset_Armor = FindSendPropInfo("CCSPlayer", "m_ArmorValue");
	if (g_Offset_Armor == -1)
	{
		SetFailState("Unable to find offset for armor.");
	}
	g_Offset_Clip1 = FindSendPropInfo("CBaseCombatWeapon", "m_iClip1");
	if (g_Offset_Clip1 == -1)
	{
		SetFailState("Unable to find offset for clip.");
	}
	if (g_Game != Game_CSGO)
	{
		g_Offset_Ammo = FindSendPropInfo("CCSPlayer", "m_iAmmo");
		if (g_Offset_Ammo == -1)
		{
			SetFailState("Unable to find offset for ammo.");
		}
	}
	g_Offset_FOV = FindSendPropInfo("CBasePlayer", "m_iFOV");
	if (g_Offset_FOV == -1)
	{
		SetFailState("Unable to find offset for FOV.");
	}
	g_Offset_ActiveWeapon = FindSendPropInfo("CCSPlayer", "m_hActiveWeapon");
	if (g_Offset_ActiveWeapon == -1)
	{
		SetFailState("Unable to find offset for active weapon.");
	}
	g_Offset_GroundEnt = FindSendPropInfo("CBasePlayer", "m_hGroundEntity");
	if (g_Offset_GroundEnt == -1)
	{
		SetFailState("Unable to find offset for ground entity.");
	}
	g_Offset_DefFOV = FindSendPropInfo("CBasePlayer", "m_iDefaultFOV");
	if (g_Offset_DefFOV == -1)
	{
		SetFailState("Unable to find offset for default FOV.");
	}
	if (g_Game == Game_CSS)
	{
		g_Offset_PunchAngle = FindSendPropInfo("CBasePlayer", "m_vecPunchAngle");
	}
	else if (g_Game == Game_CSGO)
	{
		g_Offset_PunchAngle = FindSendPropInfo("CBasePlayer", "m_aimPunchAngle");
	}
	if (g_Offset_PunchAngle == -1)
	{
		SetFailState("Unable to find offset for punch angle.");
	}
	g_Offset_SecAttack = FindSendPropInfo("CBaseCombatWeapon", "m_flNextSecondaryAttack");
	if (g_Offset_SecAttack == -1)
	{
		SetFailState("Unable to find offset for next secondary attack.");
	}
	g_Offset_CollisionGroup = FindSendPropInfo("CBaseEntity", "m_CollisionGroup");
	if (g_Offset_CollisionGroup == -1)
	{
		SetFailState("Unable to find offset for collision groups.");
	}
	
	// Console commands
	RegConsoleCmd("sm_lr", Command_LastRequest);
	RegConsoleCmd("sm_lastrequest", Command_LastRequest);
	
	// Admin commands
	RegAdminCmd("sm_stoplr", Command_CancelLR, ADMFLAG_SLAY);
	RegAdminCmd("sm_cancellr", Command_CancelLR, ADMFLAG_SLAY);
	RegAdminCmd("sm_abortlr", Command_CancelLR, ADMFLAG_SLAY);
	
	// Events hooks
	HookEvent("round_start", LastRequest_RoundStart);
	HookEvent("round_end", LastRequest_RoundEnd);
	HookEvent("player_hurt", LastRequest_PlayerHurt);
	HookEvent("player_death", LastRequest_PlayerDeath);
	HookEvent("bullet_impact", LastRequest_BulletImpact);
	HookEvent("player_disconnect", LastRequest_PlayerDisconnect);
	HookEvent("weapon_zoom", LastRequest_WeaponZoom, EventHookMode_Pre);
	HookEvent("weapon_fire", LastRequest_WeaponFire);
	HookEvent("player_jump", LastRequest_PlayerJump);
	HookEvent("player_spawn", LastRequest_PlayerSpawn);
	
	// Make global arrays
	gH_DArray_LastRequests = CreateArray(2);
	gH_DArray_Beacons = CreateArray();
	gH_DArray_LR_CustomNames = CreateArray(MAX_DISPLAYNAME_SIZE);
	gH_DArray_LR_Partners = CreateArray(10);
	// array structure:
	// -- block 0 -> LastRequest type
	// -- block 1 -> Prisoner client index
	// -- block 2 -> Guard client index
	// -- block 3 -> LR Data (Prisoner)
	// -- block 4 -> LR Data (Guard)
	// -- block 5 -> LR Data (Global 1)
	// -- block 6 -> LR Data (Global 2)
	// -- block 7 -> LR Data (Global 3)
	// -- block 8 -> LR Data (Global 4)
	// -- block 9 -> Handle to Additional Data
	
	// Create forwards for custom LR plugins
	gH_Frwd_LR_Available = CreateGlobalForward("OnAvailableLR", ET_Ignore, Param_Cell);
	gH_Frwd_LR_CleanUp = CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
	gH_Frwd_LR_Start = CreateForward(ET_Ignore, Param_Cell, Param_Cell);
	gH_Frwd_LR_Process = CreateForward(ET_Event, Param_Cell, Param_Cell);
	gH_Frwd_LR_StartGlobal = CreateGlobalForward("OnStartLR", ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
	
	// Register cvars
	gH_Cvar_LR_Enable = CreateConVar("sm_hosties_lr", "1", "Enable or disable Last Requests (the !lr command): 0 - disable, 1 - enable", 0, true, 0.0, true, 1.0);
	gH_Cvar_LR_MenuTime = CreateConVar("sm_hosties_lr_menutime", "0", "Sets the time the LR menu is displayed (in seconds)", 0, true, 0.0);
	gH_Cvar_LR_KillTimeouts = CreateConVar("sm_hosties_lr_killtimeouts", "0", "Kills Ts who timeout the LR menu and controls whether the exit button is displayed: 0 - disable, 1 - enable", 0, true, 0.0, true, 1.0);
	gH_Cvar_LR_KnifeFight_On = CreateConVar("sm_hosties_lr_kf_enable", "1", "Enable LR Knife Fight: 0 - disable, 1 - enable", 0, true, 0.0, true, 1.0);
	gH_Cvar_LR_Shot4Shot_On = CreateConVar("sm_hosties_lr_s4s_enable", "1", "Enable LR Shot4Shot: 0 - disable, 1 - enable", 0, true, 0.0, true, 1.0);
	gH_Cvar_LR_GunToss_On = CreateConVar("sm_hosties_lr_gt_enable", "1", "Enable LR Gun Toss: 0 - disable, 1 - enable", 0, true, 0.0, true, 1.0);
	gH_Cvar_LR_ChickenFight_On = CreateConVar("sm_hosties_lr_cf_enable", "1", "Enable LR Chicken Fight: 0 - disable, 1 - enable", 0, true, 0.0, true, 1.0);
	gH_Cvar_LR_HotPotato_On = CreateConVar("sm_hosties_lr_hp_enable", "1", "Enable LR Hot Potato: 0 - disable, 1 - enable", 0, true, 0.0, true, 1.0);
	gH_Cvar_LR_Dodgeball_On = CreateConVar("sm_hosties_lr_db_enable", "1", "Enable LR Dodgeball: 0 - disable, 1 - enable", 0, true, 0.0, true, 1.0);
	gH_Cvar_LR_NoScope_On = CreateConVar("sm_hosties_lr_ns_enable", "1", "Enable LR No Scope Battle: 0 - disable, 1 - enable", 0, true, 0.0, true, 1.0);
	gH_Cvar_LR_RockPaperScissors_On = CreateConVar("sm_hosties_lr_rps_enable", "1", "Enable LR Rock Paper Scissors: 0 - disable, 1 - enable", 0, true, 0.0, true, 1.0);
	gH_Cvar_LR_Rebel_On = CreateConVar("sm_hosties_lr_rebel_on", "1", "Enables the LR Rebel: 0 - disable, 1 - enable", 0, true, 0.0, true, 1.0);
	gH_Cvar_LR_Mag4Mag_On = CreateConVar("sm_hosties_lr_mag4mag_on", "1", "Enables the LR Magazine4Magazine: 0 - disable, 1 - enable", 0, true, 0.0, true, 1.0);
	gH_Cvar_LR_Race_On = CreateConVar("sm_hosties_lr_race_on", "1", "Enables the LR Race: 0 - disable, 1 - enable", 0, true, 0.0, true, 1.0);
	gH_Cvar_LR_RussianRoulette_On = CreateConVar("sm_hosties_lr_russianroulette_on", "1", "Enables the LR Russian Roulette: 0 - disable, 1 - enable", 0, true, 0.0, true, 1.0);
	gH_Cvar_LR_JumpContest_On = CreateConVar("sm_hosties_lr_jumpcontest_on", "1", "Enables the LR Jumping Contest: 0 - disable, 1 - enable", 0, true, 0.0, true, 1.0);	

	gH_Cvar_LR_HotPotato_Mode = CreateConVar("sm_hosties_lr_hp_teleport", "2", "Teleport CT to T on hot potato contest start: 0 - disable, 1 - enable, 2 - enable and freeze", 0, true, 0.0, true, 2.0);
	gH_Cvar_SendGlobalMsgs = CreateConVar("sm_hosties_lr_send_global_msgs", "0", "Specifies if non-death related LR messages are sent to everyone or just the active participants in that LR. 0: participants, 1: everyone", 0, true, 0.0, true, 1.0);
	gH_Cvar_MaxPrisonersToLR = CreateConVar("sm_hosties_lr_ts_max", "2", "The maximum number of terrorists left to enable LR: 0 - LR is always enabled, >0 - maximum number of Ts", 0, true, 0.0, true, 63.0);
	gH_Cvar_RebelAction = CreateConVar("sm_hosties_lr_rebel_action", "2", "Decides what to do with those who rebel/interfere during an LR. 1 - Abort, 2 - Slay.", 0, true, 1.0, true, 2.0);
	gH_Cvar_RebelHandling = CreateConVar("sm_hosties_lr_rebel_mode", "1", "LR-mode for rebelling terrorists: 0 - Rebelling Ts can never have a LR, 1 - Rebelling Ts must let the CT decide if a LR is OK, 2 - Rebelling Ts can have a LR just like other Ts", 0, true, 0.0);
	gH_Cvar_RebelOnImpact = CreateConVar("sm_hosties_lr_rebel_impact", "0", "Sets terrorists to rebels for firing a bullet. 0 - Disabled, 1 - Enabled.", 0, true, 0.0, true, 1.0);
	gH_Cvar_ColorRebels = CreateConVar("sm_hosties_rebel_color", "0", "Turns on coloring rebels", 0, true, 0.0, true, 1.0);
	gH_Cvar_ColorRebels_Red = CreateConVar("sm_hosties_rebel_red", "255", "What color to turn a rebel into (set R, G and B values to 255 to disable) (Rgb): x - red value", 0, true, 0.0, true, 255.0);
	gH_Cvar_ColorRebels_Green = CreateConVar("sm_hosties_rebel_green", "0", "What color to turn a rebel into (rGb): x - green value", 0, true, 0.0, true, 255.0);
	gH_Cvar_ColorRebels_Blue = CreateConVar("sm_hosties_rebel_blue", "0", "What color to turn a rebel into (rgB): x - blue value", 0, true, 0.0, true, 255.0);
	gH_Cvar_LR_Beacons = CreateConVar("sm_hosties_lr_beacon", "1", "Beacon players on LR or not: 0 - disable, 1 - enable", 0, true, 0.0, true, 1.0);
	gH_Cvar_LR_HelpBeams = CreateConVar("sm_hosties_lr_beams", "1", "Displays connecting beams between LR contestants: 0 - disable, 1 - enable", 0, true, 0.0, true, 1.0);
	gH_Cvar_LR_HelpBeams_Distance = CreateConVar("sm_hosties_lr_beams_distance", "0.0", "Controls how close LR partners must be before the connecting beams will disappear: 0 - always on, >0 the distance in game units", 0, true, 0.0);
	gH_Cvar_LR_Beacon_Interval = CreateConVar("sm_hosties_lr_beacon_interval", "1.0", "The interval in seconds of which the beacon 'beeps' on LR", 0, true, 0.1);
	gH_Cvar_LR_ChickenFight_Slay = CreateConVar("sm_hosties_lr_cf_slay", "1", "Slay the loser of a Chicken Fight instantly? 0 - disable, 1 - enable", 0, true, 0.0, true, 1.0);
	gH_Cvar_LR_ChickenFight_C_Blue = CreateConVar("sm_hosties_lr_cf_loser_blue", "0", "What color to turn the loser of a chicken fight into (rgB): x - blue value", 0, true, 0.0, true, 255.0);
	gH_Cvar_LR_ChickenFight_C_Green = CreateConVar("sm_hosties_lr_cf_loser_green", "255", "What color to turn the loser of a chicken fight into (rGb): x - green value", 0, true, 0.0, true, 255.0);
	gH_Cvar_LR_ChickenFight_C_Red = CreateConVar("sm_hosties_lr_cf_loser_red", "255", "What color to turn the loser of a chicken fight into (only if sm_hosties_lr_cf_slay == 0, set R, G and B values to 255 to disable) (Rgb): x - red value", 0, true, 0.0, true, 255.0);
	gH_Cvar_LR_Dodgeball_CheatCheck = CreateConVar("sm_hosties_lr_db_cheatcheck", "1", "Enable health-checker in LR Dodgeball to prevent contestant cheating (healing themselves): 0 - disable, 1 - enable", 0, true, 0.0, true, 1.0);
	gH_Cvar_LR_Dodgeball_SpawnTime = CreateConVar("sm_hosties_lr_db_flash_duration", "1.4", "The amount of time after a thrown flash before a new flash is given to a contestant: float value - delay in seconds", 0, true, 0.7, true, 6.0);
	gH_Cvar_LR_Dodgeball_Gravity = CreateConVar("sm_hosties_lr_db_gravity", "0.6", "What gravity multiplier the dodgeball contestants will get: <1.0 - less/lower, >1.0 - more/higher", 0, true, 0.1, true, 2.0);
	gH_Cvar_LR_HotPotato_MaxTime = CreateConVar("sm_hosties_lr_hp_maxtime", "20.0", "Maximum time in seconds the Hot Potato contest will last for (time is randomized): float value - time", 0, true, 8.0, true, 120.0);
	gH_Cvar_LR_HotPotato_MinTime = CreateConVar("sm_hosties_lr_hp_mintime", "10.0", "Minimum time in seconds the Hot Potato contest will last for (time is randomized): float value - time", 0, true, 0.0, true, 45.0);
	gH_Cvar_LR_HotPotato_Speed = CreateConVar("sm_hosties_lr_hp_speed_multipl", "1.5", "What speed multiplier a hot potato contestant who has the deagle is gonna get: <1.0 - slower, >1.0 - faster", 0, true, 0.8, true, 3.0);
	gH_Cvar_LR_S4S_DoubleShot = CreateConVar("sm_hosties_lr_s4s_dblsht_action", "1", "What to do with someone who fires 2 shots in a row in Shot4Shot: 0 - nothing (ignore completely), 1 - Follow rebel punishment cvars", 0, true, 0.0, true, 1.0);
	gH_Cvar_LR_NoScope_Sound = CreateConVar("sm_hosties_noscope_sound", "sm_hosties/noscopestart1.mp3", "What sound to play when a No Scope Battle starts, relative to the sound-folder: -1 - disable, path - path to sound file", 0);
	gH_Cvar_LR_Sound = CreateConVar("sm_hosties_lr_sound", "sm_hosties/lr1.mp3", "What sound to play when LR gets available, relative to the sound-folder (also requires sm_hosties_announce_lr to be 1): -1 - disable, path - path to sound file", 0);
	gH_Cvar_LR_Beacon_Sound = CreateConVar("sm_hosties_beacon_sound", "buttons/blip1.wav", "What sound to play each second a beacon is 'ping'ed.", 0);
	gH_Cvar_LR_NoScope_Weapon = CreateConVar("sm_hosties_lr_ns_weapon", "2", "Weapon to use in a No Scope Battle: 0 - AWP, 1 - scout, 2 - let the terrorist choose, 3 - SG550, 4 - G3SG1", 0, true, 0.0, true, 2.0);
	gH_Cvar_LR_NonContKiller_Action = CreateConVar("sm_hosties_lr_p_killed_action", "1", "What to do when a LR-player gets killed by a player not in LR during LR: 0 - just abort LR, 1 - abort LR and slay the attacker", 0, true, 0.0, true, 1.0);
	gH_Cvar_LR_GunToss_MarkerMode = CreateConVar("sm_hosties_lr_gt_markers", "0", "Deagle marking (requires sm_hosties_lr_gt_mode 1): 0 - markers straight up where the deagles land, 1 - markers starting where the deagle was dropped ending at the deagle landing point", 0);
	gH_Cvar_LR_GunToss_ShowMeter = CreateConVar("sm_hosties_lr_gt_meter", "1", "Displays a distance meter: 0 - do not display, 1 - display", 0, true, 0.0, true, 1.0);
	gH_Cvar_LR_Delay_Enable_Time = CreateConVar("sm_hosties_lr_enable_delay", "0.0", "Delay in seconds before a last request can be started: 0.0 - instantly, >0.0 - (float value) delay in seconds", 0, true, 0.0);
	gH_Cvar_LR_Damage = CreateConVar("sm_hosties_lr_damage", "0", "Enables that players can not attack players in LR and players in LR can not attack players outside LR: 0 - disable, 1 - enable", 0, true, 0.0, true, 1.0);
	gH_Cvar_LR_NoScope_Delay = CreateConVar("sm_hosties_lr_ns_delay", "3", "Delay in seconds before a No Scope Battle begins (to prepare the contestants...)", 0, true, 0.0);
	gH_Cvar_LR_ChickenFight_Rebel = CreateConVar("sm_hosties_lr_cf_cheat_action", "1", "What to do with a chicken fighter who attacks the other player with another weapon than knife: 0 - abort LR, 1 - slay player", 0, true, 0.0, true, 1.0);
	gH_Cvar_LR_HotPotato_Rebel = CreateConVar("sm_hosties_lr_hp_cheat_action", "1", "What to do with a hot potato contestant who attacks the other player: 0 - abort LR, 1 - slay player", 0, true, 0.0, true, 1.0);
	gH_Cvar_LR_KnifeFight_Rebel = CreateConVar("sm_hosties_lr_kf_cheat_action", "1", "What to do with a knife fighter who attacks the other player with another weapon than knife: 0 - abort LR, 1 - slay player", 0, true, 0.0, true, 1.0);
	gH_Cvar_LR_Race_AirPoints = CreateConVar("sm_hosties_lr_race_airpoints", "0", "Allow prisoners to set race points in the air.", 0, true, 0.0, true, 1.0);
	gH_Cvar_LR_Debug_Enabled = CreateConVar("sm_hosties_debug_enabled", "0", "Allow prisoners to set race points in the air.", 0, true, 0.0, true, 1.0);
	gH_Cvar_LR_Race_NotifyCTs = CreateConVar("sm_hosties_lr_race_tell_cts", "1", "Tells all CTs when a T has selected the race option from the LR menu", 0, true, 0.0, true, 1.0);
	gH_Cvar_LR_Rebel_MaxTs = CreateConVar("sm_hosties_lr_rebel_ts", "1", "If the Rebel LR option is enabled, specifies the maximum number of alive terrorists needed for the option to appear in the LR menu.", 0, true, 1.0);
	gH_Cvar_LR_Rebel_MinCTs = CreateConVar("sm_hosties_lr_rebel_cts", "1", "If the Rebel LR option is enabled, specifies how minimum number of alive counter-terrorists needed for the option to appear in the LR menu.", 0, true, 1.0);
	gH_Cvar_LR_M4M_MagCapacity = CreateConVar("sm_hosties_lr_m4m_capacity", "7", "The number of bullets in each magazine given to Mag4Mag LR contestants", 0, true, 2.0);
	gH_Cvar_LR_KnifeFight_LowGrav = CreateConVar("sm_hosties_lr_kf_gravity", "0.6", "The multiplier used for the low-gravity knife fight.", 0, true, 0.0, true, 1.0);
	gH_Cvar_LR_KnifeFight_HiSpeed = CreateConVar("sm_hosties_lr_kf_speed", "2.2", "The multiplier used for the high-speed knife fight.", 0, true, 1.1);
	gH_Cvar_LR_KnifeFight_Drunk = CreateConVar("sm_hosties_lr_kf_drunk", "4", "The multiplier used for how drunk the player will be during the drunken boxing knife fight.", 0, true, 0.0);
	gH_Cvar_Announce_CT_FreeHit = CreateConVar("sm_hosties_announce_attack", "1", "Enable or disable announcements when a CT attacks a non-rebelling T: 0 - disable, 1 - console, 2 - chat, 3 - both", 0, true, 0.0, true, 3.0);
	gH_Cvar_Announce_LR = CreateConVar("sm_hosties_announce_lr", "1", "Enable or disable chat announcements when Last Requests starts to be available: 0 - disable, 1 - enable", 0, true, 0.0, true, 1.0);
	gH_Cvar_Announce_Rebel = CreateConVar("sm_hosties_announce_rebel", "0", "Enable or disable chat announcements when a terrorist becomes a rebel: 0 - disable, 1 - enable", 0, true, 0.0, true, 1.0);
	gH_Cvar_Announce_RebelDown = CreateConVar("sm_hosties_announce_rebel_down", "0", "Enable or disable chat announcements when a rebel is killed: 0 - disable, 1 - enable", 0, true, 0.0, true, 1.0);
	gH_Cvar_Announce_Weapon_Attack = CreateConVar("sm_hosties_announce_wpn_attack", "0", "Enable or disable an announcement telling that a non-rebelling T has a weapon when he gets attacked by a CT (also requires sm_hosties_announce_attack 1): 0 - disable, 1 - enable", 0, true, 0.0, true, 1.0);
	gH_Cvar_Announce_Shot4Shot = CreateConVar("sm_hosties_lr_s4s_shot_taken", "1", "Enable announcements in Shot4Shot or Mag4Mag when a contestant empties their gun: 0 - disable, 1 - enable", 0, true, 0.0, true, 1.0);
	gH_Cvar_Announce_Delay_Enable = CreateConVar("sm_hosties_announce_lr_delay", "1", "Enable or disable chat announcements to tell that last request delaying is activated and how long the delay is: 0 - disable, 1 - enable", 0, true, 0.0, true, 1.0);
	gH_Cvar_Announce_HotPotato_Eqp = CreateConVar("sm_hosties_lr_hp_pickupannounce", "0", "Enable announcement when a Hot Potato contestant picks up the hot potato: 0 - disable, 1 - enable", 0, true, 0.0, true, 1.0);
	gH_Cvar_LR_AutoDisplay = CreateConVar("sm_hosties_lr_autodisplay", "0", "Automatically display the LR menu to non-rebelers when they become elgible for LR: 0 - disable, 1 - enable", 0, true, 0.0, true, 1.0);
	gH_Cvar_LR_BlockSuicide = CreateConVar("sm_hosties_lr_blocksuicide", "0", "Blocks LR participants from commiting suicide to avoid deaths: 0 - disable, 1 - enable", 0, true, 0.0, true, 1.0);
	gH_Cvar_LR_VictorPoints = CreateConVar("sm_hosties_lr_victorpoints", "1", "Amount of frags to reward victor in an LR where other player automatically dies", 0, true, 0.0);
	gH_Cvar_LR_RestoreWeapon_T = CreateConVar("sm_hosties_lr_restoreweapon_t", "1", "Restore weapons after LR for T players: 0 - disable, 1 - enable", 0, true, 0.0, true, 1.0);
	gH_Cvar_LR_RestoreWeapon_CT = CreateConVar("sm_hosties_lr_restoreweapon_ct", "1", "Restore weapons after LR for CT players: 0 - disable, 1 - enable", 0, true, 0.0, true, 1.0);
	gH_Cvar_LR_Rebel_HP_per_CT = CreateConVar("sm_hosties_rebel_hp_for_ct", "50", "Customize HPs per CT in Rebel as a Terrorist.", 0, true, 0.0);
	
	HookConVarChange(gH_Cvar_LR_KnifeFight_On, ConVarChanged_LastRequest);
	HookConVarChange(gH_Cvar_LR_Shot4Shot_On, ConVarChanged_LastRequest);
	HookConVarChange(gH_Cvar_LR_ChickenFight_On, ConVarChanged_LastRequest);
	HookConVarChange(gH_Cvar_LR_GunToss_On, ConVarChanged_LastRequest);
	HookConVarChange(gH_Cvar_LR_HotPotato_On, ConVarChanged_LastRequest);
	HookConVarChange(gH_Cvar_LR_Dodgeball_On, ConVarChanged_LastRequest);
	HookConVarChange(gH_Cvar_LR_NoScope_On, ConVarChanged_LastRequest);
	HookConVarChange(gH_Cvar_LR_RockPaperScissors_On, ConVarChanged_LastRequest);
	HookConVarChange(gH_Cvar_LR_Rebel_On, ConVarChanged_LastRequest);
	HookConVarChange(gH_Cvar_LR_Mag4Mag_On, ConVarChanged_LastRequest);
	HookConVarChange(gH_Cvar_LR_Race_On, ConVarChanged_LastRequest);
	HookConVarChange(gH_Cvar_LR_RussianRoulette_On, ConVarChanged_LastRequest);
	HookConVarChange(gH_Cvar_LR_JumpContest_On, ConVarChanged_LastRequest);
	
	// Account for late loading
	for (int idx = 1; idx <= MaxClients ; idx++)
	{
		if (IsClientInGame(idx))
		{
			SDKHook(idx, SDKHook_WeaponDrop, OnWeaponDrop);
			SDKHook(idx, SDKHook_WeaponEquip, OnWeaponEquip);
			SDKHook(idx, SDKHook_WeaponCanUse, OnWeaponDecideUse);
			SDKHook(idx, SDKHook_OnTakeDamage, OnTakeDamage);
		}
		g_bIsARebel[idx] = false;
		g_bInLastRequest[idx] = false;
		gH_BuildLR[idx] = null;
	}
}

void LastRequest_Menus(Handle h_TopMenu, TopMenuObject obj_Hosties)
{
	AddToTopMenu(h_TopMenu, "sm_stoplr", TopMenuObject_Item, AdminMenu_StopLR, obj_Hosties, "sm_stoplr", ADMFLAG_SLAY);
}

public void AdminMenu_StopLR(Handle h_TopMenu, TopMenuAction action, TopMenuObject item, int client, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "Stop All LastRequests");
	}
	else if (action == TopMenuAction_SelectOption)
	{
		StopActiveLRs(client);
	}
}

void LastRequest_APL()
{
	CreateNative("AddLastRequestToList", Native_LR_AddToList);
	CreateNative("RemoveLastRequestFromList", Native_LR_RemoveFromList);
	CreateNative("IsClientRebel", Native_IsClientRebel);
	CreateNative("IsClientInLastRequest", Native_IsClientInLR);
	CreateNative("ProcessAllLastRequests", Native_ProcessLRs);
	CreateNative("ChangeRebelStatus", Native_ChangeRebelStatus);
	CreateNative("InitializeLR", Native_LR_Initialize);
	CreateNative("CleanupLR", Native_LR_Cleanup);
	
	RegPluginLibrary("lastrequest");
}

public int Native_ProcessLRs(Handle h_Plugin, int iNumParameters)
{
	Function LoopCallback = GetNativeCell(1);
	AddToForward(gH_Frwd_LR_Process, h_Plugin, LoopCallback);
	LastRequest thisType = GetNativeCell(2);
		
	int theLRArraySize = GetArraySize(gH_DArray_LR_Partners);
	for (int idx = 0; idx < GetArraySize(gH_DArray_LR_Partners); idx++)
	{
		LastRequest type = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_LRType));
		if (type == thisType)
		{
			Call_StartForward(gH_Frwd_LR_Process);
			Call_PushCell(gH_DArray_LR_Partners);
			Call_PushCell(idx);
			Call_Finish();
		}
	}
	
	RemoveFromForward(gH_Frwd_LR_Process, h_Plugin, LoopCallback);
	return theLRArraySize;
}

public int Native_LR_AddToList(Handle h_Plugin, int iNumParameters)
{
	Function StartCall = GetNativeCell(1);
	Function CleanUpCall = GetNativeCell(2);
	AddToForward(gH_Frwd_LR_Start, h_Plugin, StartCall);
	AddToForward(gH_Frwd_LR_CleanUp, h_Plugin, CleanUpCall);
	char sLR_Name[MAX_DISPLAYNAME_SIZE];
	GetNativeString(3, sLR_Name, MAX_DISPLAYNAME_SIZE);
	bool AutoStart;
	if (iNumParameters > 3)
	{
		AutoStart = GetNativeCell(4);
	}
	else
	{
		AutoStart = true;
	}
	int iPosition = PushArrayString(gH_DArray_LR_CustomNames, sLR_Name);
	// take the maximum number of LRs + the custom LR index to get int value to push
	iPosition += view_as<int>(LastRequest);
	int iIndex = PushArrayCell(gH_DArray_LastRequests, iPosition);
	SetArrayCell(gH_DArray_LastRequests, iIndex, AutoStart, 1);
	return iPosition;
}

public int Native_LR_RemoveFromList(Handle h_Plugin, int iNumParameters)
{
	Function StartCall = GetNativeCell(1);
	Function CleanUpCall = GetNativeCell(2);
	RemoveFromForward(gH_Frwd_LR_Start, h_Plugin, StartCall);
	RemoveFromForward(gH_Frwd_LR_CleanUp, h_Plugin, CleanUpCall);
	char sLR_Name[MAX_DISPLAYNAME_SIZE];
	GetNativeString(3, sLR_Name, MAX_DISPLAYNAME_SIZE);
	int iPosition = FindStringInArray(gH_DArray_LR_CustomNames, sLR_Name);
	if (iPosition == -1)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "LR Name (%s) Not Found", sLR_Name);
	}
	else
	{
		RemoveFromArray(gH_DArray_LR_CustomNames, iPosition);
		iPosition += view_as<int>(LastRequest);
		RemoveFromArray(gH_DArray_LastRequests, iPosition);
	}
	return 1;
}

public int Native_LR_Initialize(Handle h_Plugin, int iNumParameters)
{
	if(iNumParameters == 1)
	{
		int LR_Player_Prisoner = 0;
		if(GetNativeCell(1) != 0)
		{
			if(GetClientTeam(GetNativeCell(1)) == 2)
			{
				LR_Player_Prisoner = GetNativeCell(1);
			}
		}
		if(LR_Player_Prisoner != 0 && g_LR_Player_Guard[LR_Player_Prisoner] != 0)
		{
			if(!IsLastRequestAutoStart(g_selection[LR_Player_Prisoner]))
			{
				int iArrayIndex = PushArrayCell(gH_DArray_LR_Partners, g_selection[LR_Player_Prisoner]);
				SetArrayCell(gH_DArray_LR_Partners, iArrayIndex, LR_Player_Prisoner, view_as<int>(Block_Prisoner));
				SetArrayCell(gH_DArray_LR_Partners, iArrayIndex, g_LR_Player_Guard[LR_Player_Prisoner], view_as<int>(Block_Guard));

				g_bInLastRequest[LR_Player_Prisoner] = true;
				g_bInLastRequest[g_LR_Player_Guard[LR_Player_Prisoner]] = true;

				// Fire global
				Call_StartForward(gH_Frwd_LR_StartGlobal);
				Call_PushCell(LR_Player_Prisoner);
				Call_PushCell(g_LR_Player_Guard[LR_Player_Prisoner]);
				// LR type
				Call_PushCell(g_selection[LR_Player_Prisoner]);
				int ignore;
				Call_Finish(view_as<int>(ignore));
				
				// Close datapack
				if (gH_BuildLR[LR_Player_Prisoner] != null)
				{
					CloseHandle(gH_BuildLR[LR_Player_Prisoner]);		
				}
				gH_BuildLR[LR_Player_Prisoner] = null;
				
				// Beacon players
				if (gH_Cvar_LR_Beacons.BoolValue)
				{
					AddBeacon(LR_Player_Prisoner);
					AddBeacon(g_LR_Player_Guard[LR_Player_Prisoner]);
				}
			}
		}
		else
		{
			ThrowNativeError(SP_ERROR_NATIVE, "InitializeLR Failure (Invalid client(s) index).");
		}
	}
	else
	{
		ThrowNativeError(SP_ERROR_NATIVE, "InitializeLR Failure (Wrong number of parameters).");
	}
}

public int Native_LR_Cleanup(Handle h_Plugin, int iNumParameters)
{
	if(iNumParameters == 1)
	{
		int LR_Player_Prisoner = 0;
		if(GetNativeCell(1) != 0)
		{
			if(GetClientTeam(GetNativeCell(1)) == 2 && !g_bInLastRequest[GetNativeCell(1)])
			{
				LR_Player_Prisoner = GetNativeCell(1);
			}
		}
		if(LR_Player_Prisoner != 0)
		{
			if(!IsLastRequestAutoStart(g_selection[LR_Player_Prisoner]))
			{
				g_LR_Player_Guard[LR_Player_Prisoner] = 0;
			}
		}
		else
		{
			ThrowNativeError(SP_ERROR_NATIVE, "CleanupLR Failure (Invalid client index or player is already in LR).");
		}
	}
	else
	{
		ThrowNativeError(SP_ERROR_NATIVE, "CleanupLR Failure (Wrong number of parameters).");
	}
}

public int Native_LR_Available(Handle h_Plugin, int iNumParameters)
{
	return g_bIsLRAvailable;
}

public int Native_IsClientRebel(Handle h_Plugin, int iNumParameters)
{
	int client = GetNativeCell(1);
	if (client > MaxClients || client < 0)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d)", client);
	}
	return view_as<bool>(g_bIsARebel[client]);
}

public int Native_ChangeRebelStatus(Handle h_Plugin, int iNumParameters)
{
	int client = GetNativeCell(1);
	if (client > MaxClients || client < 0)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d)", client);
	}
	int status = GetNativeCell(2);
	if (status < 0 || status > 1)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid rebel status (%d)", status);
	}
	g_bIsARebel[client] = view_as<bool>(status);
	if(g_bIsARebel[client])
	{
		MarkRebel(client, 0);
	}
	return 1;
}

public int Native_IsClientInLR(Handle h_Plugin, int iNumParameters)
{
	int client = GetNativeCell(1);
	if (!IsClientInGame(client))
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Given client index (%d) not in game", client);
	}
	return Local_IsClientInLR(client);
}

void MarkRebel(int client, int victim)
{
	if (gH_Cvar_Announce_Rebel.BoolValue && IsClientInGame(client))
	{
		if (gH_Cvar_SendGlobalMsgs.BoolValue)
		{
			CPrintToChatAll("%s %t", ChatBanner, "New Rebel", client);
		}
		else
		{
			CPrintToChat(client, "%s %t", ChatBanner, "New Rebel", client);
			if (victim && IsClientInGame(victim))
			{
				CPrintToChat(victim, "%s %t", ChatBanner, "New Rebel", client);
			}
		}
	}
	if (gH_Cvar_ColorRebels.BoolValue)
	{
		SetEntityRenderColor(client, gH_Cvar_ColorRebels_Red.IntValue, gH_Cvar_ColorRebels_Green.IntValue, gH_Cvar_ColorRebels_Blue.IntValue, 255);
	}
}

int Local_IsClientInLR(int client)
{
	int iArraySize = GetArraySize(gH_DArray_LR_Partners);
	for (int idx = 0; idx < iArraySize; idx++)
	{
		int LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Prisoner));
		int LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Guard));
		if ((LR_Player_Prisoner == client) || (LR_Player_Guard == client))
		{
			// check if a partner exists
			if ((LR_Player_Prisoner == 0) || (LR_Player_Guard == 0))
			{
				return -1;
			}
			else
			{
				return (LR_Player_Prisoner == client ? LR_Player_Guard : LR_Player_Prisoner);
			}
		}
	}
	return 0;
}

public Action LastRequest_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	g_hRoundTime = FindConVar("mp_roundtime");
	g_RoundTime = GetConVarInt(g_hRoundTime) * 60;
	if (TickerState == INVALID_HANDLE)
	{
		RoundTimeTicker = CreateTimer(1.0, Timer_RoundTimeLeft, g_RoundTime, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		KillTimer(RoundTimeTicker);
		RoundTimeTicker = CreateTimer(1.0, Timer_RoundTimeLeft, g_RoundTime, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}

	g_bAnnouncedThisRound = false;
	
	// Set variable to know that the round has started
	g_bRoundInProgress = true;
	
	// roundstart done, enable LR if there should be no LR delay (credits to Caza for this :p)
	if (gH_Cvar_LR_Delay_Enable_Time.FloatValue > 0.0)
	{
		g_bIsLRAvailable = false;	
		g_DelayLREnableTimer = CreateTimer(gH_Cvar_LR_Delay_Enable_Time.FloatValue, Timer_EnableLR, _, TIMER_FLAG_NO_MAPCHANGE);

		if (gH_Cvar_Announce_Delay_Enable.BoolValue)
		{
			CPrintToChatAll("%s %t", ChatBanner, "LR Delay Announcement", RoundToNearest(gH_Cvar_LR_Delay_Enable_Time.FloatValue));
		}
	}
	else
	{
		g_bIsLRAvailable = true;
	}
	
	for (int idx = 1; idx <= MaxClients; idx++)
	{
		g_bIsARebel[idx] = false;
		g_bInLastRequest[idx] = false;
		g_LR_Player_Guard[idx] = 0;
		SetCorrectPlayerColor(idx);
	}
}

public Action Timer_EnableLR(Handle timer)
{
	if (g_DelayLREnableTimer == timer)
	{
		g_bIsLRAvailable = true;
		g_DelayLREnableTimer = null;
		
		int Ts, CTs, NumCTsAvailable;
		UpdatePlayerCounts(Ts, CTs, NumCTsAvailable);	
	
		// Check if we should send OnAvailableLR forward now
		if (Ts <= gH_Cvar_MaxPrisonersToLR.IntValue && (NumCTsAvailable > 0) && (Ts > 0))
		{
			// do not announce later
			g_bAnnouncedThisRound = true;
			
			Call_StartForward(gH_Frwd_LR_Available);
			// announced = no
			Call_PushCell(false);
			int ignore;
			Call_Finish(view_as<int>(ignore));
		}
	}
	return Plugin_Stop;
}

public Action Command_CancelLR(int client, int args)
{
	StopActiveLRs(client);
	return Plugin_Handled;
}

void StopActiveLRs(int client)
{
	int iArraySize = GetArraySize(gH_DArray_LR_Partners);
	while (iArraySize > 0)
	{
		CleanupLastRequest(client, iArraySize-1);
		RemoveFromArray(gH_DArray_LR_Partners, iArraySize-1);
		iArraySize--;
	}
	CShowActivity(client, "%s %t", ChatBanner, "LR Aborted");
}

public Action LastRequest_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	if (TickerState != INVALID_HANDLE)
	{
		KillTimer(RoundTimeTicker);
	}

	// Block LRs and reset
	g_bIsLRAvailable = false;
	
	// Set variable to know that the round has ended
	g_bRoundInProgress = false;
	
	// Remove all the LR data
	ClearArray(gH_DArray_LR_Partners);
	ClearArray(gH_DArray_Beacons);
	
	// Stop timers for short rounds
	if (g_DelayLREnableTimer != null)
	{
		g_DelayLREnableTimer = null;
	}
	
	// Cancel menus of all alive prisoners	
	ClosePotentialLRMenus();
}

public Action LastRequest_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	int victim = GetClientOfUserId(GetEventInt(event, "userid"));

	int iArraySize = GetArraySize(gH_DArray_LR_Partners);
	if (iArraySize > 0)
	{
		for (int idx = 0; idx < GetArraySize(gH_DArray_LR_Partners); idx++)
		{	
			LastRequest type = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_LRType));
			int LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Prisoner));
			int LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Guard));
			
			if (victim == LR_Player_Prisoner || victim == LR_Player_Guard) 
			{
				if (attacker != LR_Player_Prisoner && attacker != LR_Player_Guard \
					&& attacker && (type != LR_Rebel))
				{
					if (!gH_Cvar_LR_NonContKiller_Action)
					{
						CPrintToChatAll("%s %t", ChatBanner, "Non LR Kill LR Abort", attacker, victim);
					}
					else
					{
						// follow rebel action
						DecideRebelsFate(attacker, idx);
						return;
					}
				}
            
				CleanupLastRequest(victim, idx);            
				RemoveFromArray(gH_DArray_LR_Partners, idx);            
			}
		}
	}

	int Ts, CTs, NumCTsAvailable;
	UpdatePlayerCounts(Ts, CTs, NumCTsAvailable);
	
	if ((Ts > 0) && gH_Cvar_Announce_RebelDown && g_bIsARebel[victim] && attacker && (attacker != victim))
	{
		if (gH_Cvar_SendGlobalMsgs.BoolValue)
		{
			CPrintToChatAll("%s %t", ChatBanner, "Rebel Kill", attacker, victim);
		}
		else
		{
			CPrintToChat(attacker, "%s %t", ChatBanner, "Rebel Kill", attacker, victim);
			CPrintToChat(victim, "%s %t", ChatBanner, "Rebel Kill", attacker, victim);
		}
	}
	
	if (gH_Cvar_LR_AutoDisplay.BoolValue && gH_Cvar_LR_Enable.BoolValue && (Ts > 0) && (NumCTsAvailable > 0) && (Ts <= gH_Cvar_MaxPrisonersToLR.IntValue))
	{
		for (int idx = 1; idx <= MaxClients; idx++)
		{
			if (IsClientInGame(idx) && IsPlayerAlive(idx) && GetClientTeam(idx) == CS_TEAM_T && !g_bIsARebel[idx])
			{
				FakeClientCommand(idx, "sm_lastrequest");
			}
		}
	}
	
	if (!g_bAnnouncedThisRound && gH_Cvar_LR_Enable.BoolValue)
	{
		if ((Ts == gH_Cvar_MaxPrisonersToLR.IntValue) && (NumCTsAvailable > 0) && (Ts > 0))
		{
			Call_StartForward(gH_Frwd_LR_Available);
			// announced = yes
			Call_PushCell(gH_Cvar_Announce_LR.BoolValue);
			int ignore;
			Call_Finish(view_as<int>(ignore));
		
			if (gH_Cvar_Announce_LR.BoolValue)
			{
				CPrintToChatAll("%s %t", ChatBanner, "LR Available");
				char buffer[PLATFORM_MAX_PATH];
				gH_Cvar_LR_Sound.GetString(buffer, sizeof(buffer));
				
				if ((strlen(buffer) > 0) && !StrEqual(buffer, "-1"))
				{
					EmitSoundToAllAny(buffer);
				}
			}
			
			g_bAnnouncedThisRound = true;
		}
	}
}

public Action LastRequest_PlayerHurt(Event event, const char[] name, bool dontBroadcast)
{
	int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	int target = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (Local_IsClientInLR(attacker) || Local_IsClientInLR(target))
	{
		for (int idx = 0; idx < GetArraySize(gH_DArray_LR_Partners); idx++)
		{
			LastRequest type = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_LRType));
			
			if ((type == LR_Rebel) || !attacker || (attacker == target))
			{
				continue;
			}
			
			int LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Prisoner));
			int LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Guard));
			
			// someone outside the group interfered inside this LR
			if ((target == LR_Player_Prisoner || target == LR_Player_Guard) && \
            attacker != LR_Player_Prisoner && attacker != LR_Player_Guard)
			{
				// take action for rebelers
				if (!g_bIsARebel[attacker] && (GetClientTeam(attacker) == CS_TEAM_T))
				{
					g_bIsARebel[attacker] = true;
					if (gH_Cvar_Announce_Rebel.IntValue && IsClientInGame(attacker))
					{
						if (gH_Cvar_SendGlobalMsgs.BoolValue)
						{
							CPrintToChatAll("%s %t", ChatBanner, "New Rebel", attacker);
						}
						else
						{
							CPrintToChat(attacker, "%s %t", ChatBanner, "New Rebel", attacker);
							CPrintToChat(target, "%s %t", ChatBanner, "New Rebel", attacker);
						}
					}
				}
			}
			// someone inside this LR interfered with someone else
			else if (target != LR_Player_Prisoner && target != LR_Player_Guard && \
				(attacker == LR_Player_Prisoner || attacker == LR_Player_Guard))
			{
				if (gH_Cvar_LR_Debug_Enabled.BoolValue) LogToFileEx(gShadow_Hosties_LogFile, "%L has been killed for attacking someone outside of the LR.", attacker);
				DecideRebelsFate(attacker, idx, target);
			}
			
			// if the current LR partner is being attacked
			if ((attacker == LR_Player_Prisoner || attacker == LR_Player_Guard) && \
            (target == LR_Player_Prisoner || target == LR_Player_Guard))
			{
				char weapon[32];
				GetEventString(event, "weapon", weapon, 32);
				bool bIsItAKnife = (StrContains(weapon, "knife") == -1 ? false : true);
				
				if (g_Game == Game_CSGO) RightKnifeAntiCheat(attacker, idx);
				
				switch (type)
				{
					case LR_KnifeFight, LR_ChickenFight:
					{
						if (!bIsItAKnife)
						{
							if (gH_Cvar_LR_Debug_Enabled.BoolValue) LogToFileEx(gShadow_Hosties_LogFile, "%L has been killed for using other weapon in KnifeFight.", attacker);
							DecideRebelsFate(attacker, idx, target);
						}
					}
					case LR_NoScope:
					{
						if (bIsItAKnife)
						{
							if (gH_Cvar_LR_Debug_Enabled.BoolValue) LogToFileEx(gShadow_Hosties_LogFile, "%L has been killed for using Knife in NoScope. - 1239", attacker);
							DecideRebelsFate(attacker, idx, target);
						}
					}
					case LR_HotPotato:
					{
						if (gH_Cvar_LR_Debug_Enabled.BoolValue) LogToFileEx(gShadow_Hosties_LogFile, "%L has been killed for attacking the enemy in HotPotato.", attacker);
						DecideRebelsFate(attacker, idx, target);
					}
				}		
			}
		}
	}
	// if a T attacks a CT and there's no last requests active
	else if (attacker && target && (GetClientTeam(attacker) == CS_TEAM_T) && (GetClientTeam(target) == CS_TEAM_CT) \
		&& !g_bIsARebel[attacker] && g_bRoundInProgress)
	{
		g_bIsARebel[attacker] = true;
		if (IsClientInGame(attacker))
		{
			MarkRebel(attacker, target);
		}
	}
	else if (attacker && target && (GetClientTeam(attacker) == CS_TEAM_CT) && (GetClientTeam(target) == CS_TEAM_T) \
		&& !g_bIsARebel[target] && g_bRoundInProgress)
	{
		bool bPrisonerHasGun = PlayerHasGun(target);
		
		if (gH_Cvar_Announce_CT_FreeHit.IntValue && target != g_iLastCT_FreeAttacker)
		{
			g_iLastCT_FreeAttacker = target;
			
			if (gH_Cvar_Announce_Weapon_Attack.BoolValue && bPrisonerHasGun)
			{
				if (IsClientInGame(target) && IsPlayerAlive(target))
				{
					for (int idx = 1; idx <= MaxClients; idx++)
					{
						if (IsClientInGame(idx))
						{
							if(gH_Cvar_Announce_CT_FreeHit.IntValue != 2)
							{
								PrintToConsole(idx, "[Hosties] %t", "CT Attack T Gun", attacker, target);
							}
							if(gH_Cvar_Announce_CT_FreeHit.IntValue >= 2)
							{
								CPrintToChat(idx, "%s %t", ChatBanner, "CT Attack T Gun", attacker, target);
							}
						}
					}
				}
			}
			else
			{
				for (int idx = 1; idx <= MaxClients; idx++)
				{
					if (IsClientInGame(idx))
					{
						if(gH_Cvar_Announce_CT_FreeHit.IntValue != 2)
						{
							PrintToConsole(idx, "[Hosties] %t", "Freeattack", attacker, target);
						}
						if(gH_Cvar_Announce_CT_FreeHit.IntValue >= 2)
						{
							CPrintToChat(idx, "%s %t", ChatBanner, "Freeattack", attacker, target);
						}
					}
				}
			}
		}
	}
}

public Action LastRequest_PlayerDisconnect(Event event, const char[] name, bool dontBroadcast)
{
	int iArraySize = GetArraySize(gH_DArray_LR_Partners);
	if (iArraySize > 0)
	{
		int client = GetClientOfUserId(GetEventInt(event, "userid"));
		for (int idx = 0; idx < GetArraySize(gH_DArray_LR_Partners); idx++)
		{	
			int LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Prisoner));
			int LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Guard));
			
			if (client == LR_Player_Prisoner || client == LR_Player_Guard)
			{
				CleanupLastRequest(client, idx);
				RemoveFromArray(gH_DArray_LR_Partners, idx);
				CPrintToChatAll("%s %s", ChatBanner, "LR Player Disconnect", client);
				if (gH_Cvar_LR_Debug_Enabled.BoolValue) LogToFileEx(gShadow_Hosties_LogFile, "%L has disconnected in LR. LR aborted.", client);
			}
		}
	}
}

void CleanupLastRequest(int loser, int arrayIndex)
{
	LastRequest type = GetArrayCell(gH_DArray_LR_Partners, arrayIndex, view_as<int>(Block_LRType));
	int LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, arrayIndex, view_as<int>(Block_Prisoner));
	int LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, arrayIndex, view_as<int>(Block_Guard));
	
	g_bInLastRequest[LR_Player_Prisoner] = false;
	g_bInLastRequest[LR_Player_Guard] = false;
	
	RemoveBeacon(LR_Player_Prisoner);
	RemoveBeacon(LR_Player_Guard);
	
	int winner = (loser == LR_Player_Prisoner) ? LR_Player_Guard : LR_Player_Prisoner;
	
	switch (type)
	{
		case LR_KnifeFight:
		{
			KnifeType KnifeChoice = GetArrayCell(gH_DArray_LR_Partners, arrayIndex, view_as<int>(Block_Global1));
			switch (KnifeChoice)
			{
				case Knife_Drunk, Knife_Drugs:
				{
					if (IsClientInGame(LR_Player_Prisoner))
					{
						SetEntData(LR_Player_Prisoner, g_Offset_FOV, NORMAL_VISION, 4, true);
						SetEntData(LR_Player_Prisoner, g_Offset_DefFOV, NORMAL_VISION, 4, true);
						ShowOverlayToClient(LR_Player_Prisoner, "");
					}	
					if (IsClientInGame(LR_Player_Guard))
					{
						SetEntData(LR_Player_Guard, g_Offset_FOV, NORMAL_VISION, 4, true);
						SetEntData(LR_Player_Guard, g_Offset_DefFOV, NORMAL_VISION, 4, true);
						ShowOverlayToClient(LR_Player_Guard, "");
					}
					
					if (g_Game == Game_CSGO)
					{
						ServerCommand("sm_drug #%i 0", GetClientUserId(LR_Player_Prisoner));
						ServerCommand("sm_drug #%i 0", GetClientUserId(LR_Player_Guard));
					}
				}
				case Knife_LowGrav:
				{
					if  (IsClientInGame(LR_Player_Prisoner))
					{
						SetEntityGravity(LR_Player_Prisoner, 1.0);
					}
					if (IsClientInGame(LR_Player_Guard))
					{
						SetEntityGravity(LR_Player_Guard, 1.0);
					}
				}
				case Knife_HiSpeed:
				{
					if (IsClientInGame(winner) && IsPlayerAlive(winner))
					{
						SetEntPropFloat(winner, Prop_Data, "m_flLaggedMovementValue", 1.0);
					}
					if (IsClientInGame(loser))
					{
						SetEntPropFloat(winner, Prop_Data, "m_flLaggedMovementValue", 1.0);
					}
				}
				case Knife_ThirdPerson:
				{
					if (IsClientInGame(LR_Player_Prisoner))
					{
						SetFirstPerson(LR_Player_Prisoner);
					}
					if (IsClientInGame(LR_Player_Guard))
					{
						SetFirstPerson(LR_Player_Guard);
					}
				}
			}
			
			if (gH_Cvar_LR_Debug_Enabled.BoolValue) LogToFileEx(gShadow_Hosties_LogFile, "Successfull cleanup after LR - Knife Fight.");
		}
		case LR_GunToss:
		{
			int GTdeagle1 = EntRefToEntIndex(GetArrayCell(gH_DArray_LR_Partners, arrayIndex, view_as<int>(Block_PrisonerData)));
			int GTdeagle2 = EntRefToEntIndex(GetArrayCell(gH_DArray_LR_Partners, arrayIndex, view_as<int>(Block_GuardData)));
			if (IsValidEntity(GTdeagle1))
			{
				SetEntityRenderColor(GTdeagle1, 255, 255, 255);
				SetEntityRenderMode(GTdeagle1, RENDER_NORMAL);
			}
			if (IsValidEntity(GTdeagle2))
			{
				SetEntityRenderColor(GTdeagle2, 255, 255, 255);
				SetEntityRenderMode(GTdeagle2, RENDER_NORMAL);
			}
			
			if (gH_Cvar_LR_Debug_Enabled.BoolValue) LogToFileEx(gShadow_Hosties_LogFile, "Successfull cleanup after LR - Gun Toss.");
		}
		case LR_HotPotato:
		{
			if (IsClientInGame(winner) && IsPlayerAlive(winner))
			{
				SetEntPropFloat(winner, Prop_Data, "m_flLaggedMovementValue", 1.0);
				SetEntityMoveType(winner, MOVETYPE_WALK);
			}
			
			int HPdeagle = GetArrayCell(gH_DArray_LR_Partners, arrayIndex, view_as<int>(Block_Global4));
			RemoveBeacon(HPdeagle);
			if (IsValidEntity(HPdeagle))
			{
				SetEntityRenderColor(HPdeagle, 255, 255, 255);
				SetEntityRenderMode(HPdeagle, RENDER_NORMAL);
			}
			
			if (gH_Cvar_LR_Debug_Enabled.BoolValue) LogToFileEx(gShadow_Hosties_LogFile, "Successfull cleanup after LR - Hot Potato.");
		}
		case LR_RussianRoulette:
		{
			if (IsClientInGame(winner) && IsPlayerAlive(winner))
			{
				SetEntityMoveType(winner, MOVETYPE_WALK);
			}
			
			if (gH_Cvar_LR_Debug_Enabled.BoolValue) LogToFileEx(gShadow_Hosties_LogFile, "Successfull cleanup after LR - Russian Roulette.");
		}
		case LR_Dodgeball:
		{
			if  (IsClientInGame(LR_Player_Prisoner))
			{
				SetEntityGravity(LR_Player_Prisoner, 1.0);
			}
			if (IsClientInGame(LR_Player_Guard))
			{
				SetEntityGravity(LR_Player_Guard, 1.0);
			}
			
			if (IsClientInGame(winner) && IsPlayerAlive(winner))
			{
				StripAllWeapons(winner);
				if(g_Game != Game_CSGO)
				{
					SetEntData(winner, g_Offset_Ammo+(view_as<int>(12)*4), 0, _, true);
				}
			}
			
			if (gH_Cvar_LR_Debug_Enabled.BoolValue) LogToFileEx(gShadow_Hosties_LogFile, "Successfull cleanup after LR - Dodgeball.");
		}
		case LR_Race:
		{
			CloseHandle(GetArrayCell(gH_DArray_LR_Partners, arrayIndex, 9));
			
			if (gH_Cvar_LR_Debug_Enabled.BoolValue) LogToFileEx(gShadow_Hosties_LogFile, "Successfull cleanup after LR - Race.");
		}
		case LR_JumpContest:
		{
			JumpContest JumpType = GetArrayCell(gH_DArray_LR_Partners, arrayIndex, view_as<int>(Block_Global2));

			switch (JumpType)
			{
				case Jump_Farthest:
				{
					if (IsClientInGame(winner) && IsPlayerAlive(winner))
					{
						SetEntityMoveType(winner, MOVETYPE_WALK);
					}               
				}
			}
			
			if (gH_Cvar_LR_Debug_Enabled.BoolValue) LogToFileEx(gShadow_Hosties_LogFile, "Successfull cleanup after LR - Jump Contest.");
		}
		default:
		{
			Call_StartForward(gH_Frwd_LR_CleanUp);
			Call_PushCell(type);
			Call_PushCell(LR_Player_Prisoner);
			Call_PushCell(LR_Player_Guard);
			int ignore;
			Call_Finish(view_as<int>(ignore));
			
			if(!IsLastRequestAutoStart(type))
			{
				g_LR_Player_Guard[LR_Player_Prisoner] = 0;
			}
			
			if (gH_Cvar_LR_Debug_Enabled.BoolValue) LogToFileEx(gShadow_Hosties_LogFile, "Successfull cleanup after LR - Default.");
		}
	}
	
	if (IsClientInGame(LR_Player_Prisoner) && IsPlayerAlive(LR_Player_Prisoner))
	{
		if (g_Game == Game_CSGO)
		{
			ConVar Cvar_TeamBlock = FindConVar("mp_solid_teammates");
			int TeamBlock = GetConVarInt(Cvar_TeamBlock);
		
			if (TeamBlock == 1 || TeamBlock == 2)
				BlockEntity(LR_Player_Prisoner, g_Offset_CollisionGroup);
			else
				UnblockEntity(LR_Player_Prisoner, g_Offset_CollisionGroup);
		}
		else if (g_Game == Game_CSS)
		{
			BlockEntity(LR_Player_Prisoner, g_Offset_CollisionGroup);
		}
		
		SetEntPropFloat(LR_Player_Prisoner, Prop_Data, "m_flLaggedMovementValue", 1.0);
		
		SetEntityMoveType(LR_Player_Prisoner, MOVETYPE_WALK);
		
		StripAllWeapons(LR_Player_Prisoner);
		
		if (gH_Cvar_LR_RestoreWeapon_T.BoolValue && g_Game == Game_CSGO)
		{
			RestoreWeapons(LR_Player_Prisoner);
			
			int malee = GetPlayerWeaponSlot(LR_Player_Prisoner, CS_SLOT_KNIFE);
			if (malee == -1)
			{
				malee = GivePlayerItem(LR_Player_Prisoner, "weapon_fists");
				EquipPlayerWeapon(LR_Player_Prisoner, malee);
			}
		}
		else
		{
			int weapon;
			while((weapon = GetPlayerWeaponSlot(LR_Player_Prisoner, CS_SLOT_KNIFE)) != -1)
			{
				RemovePlayerItem(LR_Player_Prisoner, weapon);
				AcceptEntityInput(weapon, "Kill");
			}
		
			int iMelee = GivePlayerItem(LR_Player_Prisoner, "weapon_knife");
			EquipPlayerWeapon(LR_Player_Prisoner, iMelee);
		}

		SetEntityHealth(LR_Player_Prisoner, 100);
		
		if (gH_Cvar_LR_Debug_Enabled.BoolValue) LogToFileEx(gShadow_Hosties_LogFile, "%L (Prisoner) attribute reset after LR.", LR_Player_Prisoner);
	}
	
	if (IsClientInGame(LR_Player_Guard) && IsPlayerAlive(LR_Player_Guard))
	{
		SetEntPropFloat(LR_Player_Guard, Prop_Data, "m_flLaggedMovementValue", 1.0);
		
		if (g_Game == Game_CSGO)
		{
			ConVar Cvar_TeamBlock = FindConVar("mp_solid_teammates");
			int TeamBlock = GetConVarInt(Cvar_TeamBlock);
		
			if (TeamBlock == 1 || TeamBlock == 2)
				BlockEntity(LR_Player_Guard, g_Offset_CollisionGroup);
			else
				UnblockEntity(LR_Player_Guard, g_Offset_CollisionGroup);
		}
		else if (g_Game == Game_CSS)
		{
			BlockEntity(LR_Player_Guard, g_Offset_CollisionGroup);
		}
		
		SetEntityMoveType(LR_Player_Guard, MOVETYPE_WALK);
		
		StripAllWeapons(LR_Player_Guard);
		
		if (gH_Cvar_LR_RestoreWeapon_CT.BoolValue && g_Game == Game_CSGO)
		{
			RestoreWeapons(LR_Player_Guard);
			
			int malee = GetPlayerWeaponSlot(LR_Player_Guard, CS_SLOT_KNIFE);
			if (malee == -1)
			{
				malee = GivePlayerItem(LR_Player_Guard, "weapon_fists");
				EquipPlayerWeapon(LR_Player_Guard, malee);
			}
		}
		else
		{
			int weapon;
			while((weapon = GetPlayerWeaponSlot(LR_Player_Guard, CS_SLOT_KNIFE)) != -1)
			{
				RemovePlayerItem(LR_Player_Guard, weapon);
				AcceptEntityInput(weapon, "Kill");
			}
		
			int iMelee = GivePlayerItem(LR_Player_Guard, "weapon_knife");
			EquipPlayerWeapon(LR_Player_Guard, iMelee);
		}
		
		SetEntityHealth(LR_Player_Guard, 100);
		
		if (gH_Cvar_LR_Debug_Enabled.BoolValue) LogToFileEx(gShadow_Hosties_LogFile, "%L (Guard) attribute reset after LR.", LR_Player_Guard);
	}
}

public Action LastRequest_BulletImpact(Event event, const char[] name, bool dontBroadcast)
{
	int attacker = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!g_bIsARebel[attacker] && gH_Cvar_RebelOnImpact.BoolValue && (GetClientTeam(attacker) == CS_TEAM_T) && !Local_IsClientInLR(attacker))
	{
		g_bIsARebel[attacker] = true;
		MarkRebel(attacker, 0);
	}
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
	for (int idx = 0; idx < GetArraySize(gH_DArray_LR_Partners); idx++)
	{
		LastRequest type = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_LRType));
		if (type == LR_NoScope || type == LR_Mag4Mag)
		{
			int LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Prisoner));
			int LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Guard));
			if (client == LR_Player_Prisoner || client == LR_Player_Guard)
			{
				buttons &= ~IN_ATTACK2;
			}
		}
		
		GetLastButton(client, buttons, idx);
	}
	return Plugin_Continue;
}

public Action LastRequest_WeaponZoom(Event event, const char[] name, bool dontBroadcast)
{
	int iArraySize = GetArraySize(gH_DArray_LR_Partners);
	if (iArraySize > 0)
	{
		int client = GetClientOfUserId(GetEventInt(event, "userid"));
		for (int idx = 0; idx < GetArraySize(gH_DArray_LR_Partners); idx++)
		{	
			LastRequest type = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_LRType));
			if (type == LR_NoScope)
			{
				int LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Prisoner));
				int LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Guard));
				if (client == LR_Player_Prisoner || client == LR_Player_Guard)
				{
					SetEntData(client, g_Offset_FOV, 0, 4, true);
					return Plugin_Handled;
				}
			}
		}
	}
	
	return Plugin_Continue;
}

public Action LastRequest_PlayerJump(Event event, const char[] name, bool dontBroadcast)
{
	int iArraySize = GetArraySize(gH_DArray_LR_Partners);
	if (iArraySize > 0)
	{
		int client = GetClientOfUserId(GetEventInt(event, "userid"));
		for (int idx = 0; idx < GetArraySize(gH_DArray_LR_Partners); idx++)
		{	
			LastRequest type = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_LRType));
			if (type == LR_JumpContest)
			{
				int LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Prisoner));
				int LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Guard));
				JumpContest JumpType = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Global2));
				
				switch (JumpType)
				{
					case Jump_TheMost:
					{
						int iJumpCount = 0;
						if (client == LR_Player_Prisoner)
						{
							iJumpCount = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_PrisonerData));
							SetArrayCell(gH_DArray_LR_Partners, idx, ++iJumpCount, view_as<int>(Block_PrisonerData));
						}
						else if (client == LR_Player_Guard)
						{
							iJumpCount = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_GuardData));
							SetArrayCell(gH_DArray_LR_Partners, idx, ++iJumpCount, view_as<int>(Block_GuardData));
						}					
					}
					case Jump_Farthest:
					{
						if ((client == LR_Player_Prisoner) && !LR_Player_Jumped[LR_Player_Prisoner])
						{
							GetClientAbsOrigin(LR_Player_Prisoner, Before_Jump_pos[LR_Player_Prisoner]);
							LR_Player_Jumped[LR_Player_Prisoner] = true;
						}
						else if ((client == LR_Player_Guard) && !LR_Player_Jumped[LR_Player_Guard])
						{
							GetClientAbsOrigin(LR_Player_Guard, Before_Jump_pos[LR_Player_Guard]);
							LR_Player_Jumped[LR_Player_Guard] = true;
						}
					}
				}
			}
			else if (type == LR_GunToss)
			{
				int LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Prisoner));
				int LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Guard));
				int GTp1dropped = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Global1));
				int GTp2dropped = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Global2));

				// we want to grab the last jump position *before* they throw their gun
				if (client == LR_Player_Prisoner && !GTp1dropped)
				{
					// record position
					float Prisoner_Position[3];
					GetClientAbsOrigin(LR_Player_Prisoner, Prisoner_Position);
					Handle JumpPackPosition = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_DataPackHandle));
					#if SOURCEMOD_V_MAJOR >= 1 && SOURCEMOD_V_MINOR >= 8
						SetPackPosition(JumpPackPosition, view_as<DataPackPos>(6));
					#else
						SetPackPosition(JumpPackPosition, 6);
					#endif
					WritePackFloat(JumpPackPosition, Prisoner_Position[0]);
					WritePackFloat(JumpPackPosition, Prisoner_Position[1]);
					WritePackFloat(JumpPackPosition, Prisoner_Position[2]);
				}
				else if (client == LR_Player_Guard && !GTp2dropped)
				{
					// record position
					float Guard_Position[3];
					GetClientAbsOrigin(LR_Player_Guard, Guard_Position);
					Handle JumpPackPosition = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_DataPackHandle));
					#if SOURCEMOD_V_MAJOR >= 1 && SOURCEMOD_V_MINOR >= 8
						SetPackPosition(JumpPackPosition, view_as<DataPackPos>(9));
					#else
						SetPackPosition(JumpPackPosition, 9);
					#endif
					WritePackFloat(JumpPackPosition, Guard_Position[0]);
					WritePackFloat(JumpPackPosition, Guard_Position[1]);
					WritePackFloat(JumpPackPosition, Guard_Position[2]);
				}
			}
		}
	}
}

public Action LastRequest_WeaponFire(Event event, const char[] name, bool dontBroadcast)
{
	int iArraySize = GetArraySize(gH_DArray_LR_Partners);
	if (iArraySize > 0)
	{
		int client = GetClientOfUserId(GetEventInt(event, "userid"));
		for (int idx = 0; idx < GetArraySize(gH_DArray_LR_Partners); idx++)
		{
			LastRequest type = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_LRType));
			if (type == LR_Mag4Mag)
			{
				int LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Prisoner));
				int LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Guard));
				
				if ((client == LR_Player_Prisoner) || (client == LR_Player_Guard))
				{
					int M4M_Prisoner_Weapon = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_PrisonerData));
					int M4M_Guard_Weapon = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_GuardData));
					int M4M_RoundsFired = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Global2));
					int M4M_Ammo = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Global3));
					
					char FiredWeapon[32];
					GetEventString(event, "weapon", FiredWeapon, sizeof(FiredWeapon));
					int iClientWeapon = GetEntDataEnt2(client, g_Offset_ActiveWeapon);	
					
					// set the time to enable burst value to a high value
					SetEntDataFloat(iClientWeapon, g_Offset_SecAttack, 5000.0);
					
					if (iClientWeapon != M4M_Prisoner_Weapon && iClientWeapon != M4M_Guard_Weapon && StrContains(FiredWeapon, "knife") == -1)
					{
						DecideRebelsFate(client, idx, -1);
					}
					else if (!StrEqual(FiredWeapon, "knife"))
					{
						int currentAmmo = GetEntData(iClientWeapon, g_Offset_Clip1);
						// check if a shot was actually fired
						if (currentAmmo != M4M_Ammo)
						{
							SetArrayCell(gH_DArray_LR_Partners, idx, currentAmmo, view_as<int>(Block_Global3));
							SetArrayCell(gH_DArray_LR_Partners, idx, ++M4M_RoundsFired, view_as<int>(Block_Global2));
							
							if (M4M_RoundsFired >= gH_Cvar_LR_M4M_MagCapacity.IntValue)
							{
								M4M_RoundsFired = 0;
								SetArrayCell(gH_DArray_LR_Partners, idx, M4M_RoundsFired, view_as<int>(Block_Global2));
								if (gH_Cvar_Announce_Shot4Shot.BoolValue)
								{
									if (gH_Cvar_SendGlobalMsgs.BoolValue)
									{
										CPrintToChatAll("%s %t", ChatBanner, "M4M Mag Used", client);
									}
									else
									{
										CPrintToChat(LR_Player_Guard, "%s %t", ChatBanner, "M4M Mag Used", client);
										CPrintToChat(LR_Player_Prisoner, "%s %t", ChatBanner, "M4M Mag Used", client);
									}
								}

								// send it to the next player
								if (LR_Player_Prisoner == client)
								{
									SetEntData(M4M_Guard_Weapon, g_Offset_Clip1, gH_Cvar_LR_M4M_MagCapacity.IntValue);
									SetArrayCell(gH_DArray_LR_Partners, idx, LR_Player_Guard, view_as<int>(Block_Global1));
								}
								else if (LR_Player_Guard == client)
								{
									SetEntData(M4M_Prisoner_Weapon, g_Offset_Clip1, gH_Cvar_LR_M4M_MagCapacity.IntValue);
									SetArrayCell(gH_DArray_LR_Partners, idx, LR_Player_Prisoner, view_as<int>(Block_Global1));
								}
								
								if(g_Game == Game_CSGO)
								{
									SetEntProp(M4M_Guard_Weapon, Prop_Send, "m_iPrimaryReserveAmmoCount", 0);
									SetEntProp(M4M_Prisoner_Weapon, Prop_Send, "m_iPrimaryReserveAmmoCount", 0);
								}
								else
								{
									int iAmmoType = GetEntProp(M4M_Prisoner_Weapon, Prop_Send, "m_iPrimaryAmmoType");
									SetEntData(LR_Player_Guard, g_Offset_Ammo+(iAmmoType*4), 0, _, true);
									SetEntData(LR_Player_Prisoner, g_Offset_Ammo+(iAmmoType*4), 0, _, true);
								}
							}
						}
					}
				}			
			}
			else if (type == LR_RussianRoulette)
			{
				int LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Prisoner));
				int LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Guard));
				if ((client == LR_Player_Prisoner) || (client == LR_Player_Guard))
				{							
					int Prisoner_Weapon = EntRefToEntIndex(GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_PrisonerData)));
					int Guard_Weapon = EntRefToEntIndex(GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_GuardData)));

					if (gH_Cvar_Announce_Shot4Shot.BoolValue)
					{
						if (gH_Cvar_SendGlobalMsgs.BoolValue)
						{
							CPrintToChatAll("%s %t", ChatBanner, "S4S Shot Taken", client);
						}
						else
						{
							CPrintToChat(LR_Player_Guard, "%s %t", ChatBanner, "S4S Shot Taken", client);
							CPrintToChat(LR_Player_Prisoner, "%s %t", ChatBanner, "S4S Shot Taken", client);
						}
					}
					
					// give the opposite LR player 1 bullet in their deagle
					if (client == LR_Player_Prisoner)
					{
						// modify deagle 2s ammo
						SetEntData(Guard_Weapon, g_Offset_Clip1, 1);
					}
					else if (client == LR_Player_Guard)
					{
						// modify deagle 1s ammo
						SetEntData(Prisoner_Weapon, g_Offset_Clip1, 1);
					}
					
					if(g_Game == Game_CSGO)
					{
						SetEntProp(Guard_Weapon, Prop_Send, "m_iPrimaryReserveAmmoCount", 0);
						SetEntProp(Prisoner_Weapon, Prop_Send, "m_iPrimaryReserveAmmoCount", 0);
					}
					else
					{
						int iAmmoType = GetEntProp(Prisoner_Weapon, Prop_Send, "m_iPrimaryAmmoType");
						SetEntData(LR_Player_Guard, g_Offset_Ammo+(iAmmoType*4), 0, _, true);
						SetEntData(LR_Player_Prisoner, g_Offset_Ammo+(iAmmoType*4), 0, _, true);
					}
					
					ChangeEdictState(Prisoner_Weapon, g_Offset_Clip1);
					ChangeEdictState(Guard_Weapon, g_Offset_Clip1);
				}
			}
			else if (type == LR_Shot4Shot)
			{
				int LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Prisoner));
				int LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Guard));
				if ((client == LR_Player_Prisoner) || (client == LR_Player_Guard))
				{
					int Prisoner_S4S_Pistol = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_PrisonerData));
					int Guard_S4S_Pistol = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_GuardData));
					int S4Slastshot = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Global1));
					
					char FiredWeapon[48];
					GetEventString(event, "weapon", FiredWeapon, sizeof(FiredWeapon));
					
					int iClientWeapon = GetEntDataEnt2(client, g_Offset_ActiveWeapon);
					
					if (iClientWeapon != Prisoner_S4S_Pistol && iClientWeapon != Guard_S4S_Pistol && StrContains(FiredWeapon, "knife") == -1)
					{
						if (g_Game == Game_CSGO) RightKnifeAntiCheat(client, idx);
						DecideRebelsFate(client, idx, -1);
					}
					else if (StrContains(FiredWeapon, "knife") == -1)
					{
						// update who took the last shot
						SetArrayCell(gH_DArray_LR_Partners, idx, client, view_as<int>(Block_Global1));
						
						// check for double shot situation (if they picked up another deagle with more ammo between shots)
						if (gH_Cvar_LR_S4S_DoubleShot.BoolValue && (S4Slastshot == client))
						{
							// this should no longer be possible to do without extra manipulation	
							if (g_Game == Game_CSGO) RightKnifeAntiCheat(client, idx);
							DecideRebelsFate(client, idx, -1);
						}
						else // if we didn't repeat
						{		
							if (gH_Cvar_Announce_Shot4Shot.BoolValue)
							{
								if (gH_Cvar_SendGlobalMsgs.BoolValue)
								{
									CPrintToChatAll("%s %t", ChatBanner, "S4S Shot Taken", client);
								}
								else
								{
									CPrintToChat(LR_Player_Guard, "%s %t", ChatBanner, "S4S Shot Taken", client);
									CPrintToChat(LR_Player_Prisoner, "%s %t", ChatBanner, "S4S Shot Taken", client);
								}
							}
							
							// give the opposite LR player 1 bullet in their deagle
							if (client == LR_Player_Prisoner)
							{
								// modify deagle 2s ammo
								SetEntData(Guard_S4S_Pistol, g_Offset_Clip1, 1);
							}
							else if (client == LR_Player_Guard)
							{
								// modify deagle 1s ammo
								SetEntData(Prisoner_S4S_Pistol, g_Offset_Clip1, 1);
							}
							
							if(g_Game == Game_CSGO)
							{
								SetEntProp(Guard_S4S_Pistol, Prop_Send, "m_iPrimaryReserveAmmoCount", 0);
								SetEntProp(Prisoner_S4S_Pistol, Prop_Send, "m_iPrimaryReserveAmmoCount", 0);
							}
							else
							{
								int iAmmoType = GetEntProp(Prisoner_S4S_Pistol, Prop_Send, "m_iPrimaryAmmoType");
								SetEntData(LR_Player_Guard, g_Offset_Ammo+(iAmmoType*4), 0, _, true);
								SetEntData(LR_Player_Prisoner, g_Offset_Ammo+(iAmmoType*4), 0, _, true);
							}
							
							// propogate the ammo immediately! (thanks psychonic)
							ChangeEdictState(Prisoner_S4S_Pistol, g_Offset_Clip1);
							ChangeEdictState(Guard_S4S_Pistol, g_Offset_Clip1);
						}
					}
				}	
			}	
			else if (type == LR_NoScope)
			{
				int LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Prisoner));
				int LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Guard));
				if (client == LR_Player_Prisoner || client == LR_Player_Guard)
				{
					// place delay on zoom
					int iClientWeapon = GetEntDataEnt2(client, g_Offset_ActiveWeapon);
					SetEntDataFloat(iClientWeapon, g_Offset_SecAttack, 5000.0);
					
					// grab weapon choice
					NoScopeWeapon NS_Selection;
					NS_Selection = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Global2));					
					switch (NS_Selection)
					{
						case NSW_AWP:
						{
							CreateTimer(1.8, Timer_ResetZoom, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
						}
						case NSW_Scout:
						{
							CreateTimer(1.3, Timer_ResetZoom, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
						}
						default:
						{
							CreateTimer(0.5, Timer_ResetZoom, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
						}
					}
				}
			}
		}
	}
} // end LastRequest_WeaponFire

public Action Timer_ResetZoom(Handle timer, any UserId)
{
	int client = GetClientOfUserId(UserId);
	if (client)
	{
		SetEntData(client, g_Offset_FOV, 0, 4, true);
	}
	return Plugin_Handled;
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{
	if ((victim != attacker) && (victim > 0) && (victim <= MaxClients) && (attacker > 0) && (attacker <= MaxClients))
	{
		int iArraySize = GetArraySize(gH_DArray_LR_Partners);
		if (iArraySize > 0)
		{
			for (int idx = 0; idx < GetArraySize(gH_DArray_LR_Partners); idx++)
			{
				int LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Prisoner));
				int LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Guard));
				LastRequest Type = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_LRType));
				
				char UsedWeapon[64];
				if (Weapon_IsValid(weapon))
				{
					GetEntityClassname(weapon, UsedWeapon, sizeof(UsedWeapon));
				}
				ReplaceString(UsedWeapon, sizeof(UsedWeapon), "weapon_", "", false); 
				
				// if a roulette player is hurting the other contestant
				if ((Type == LR_RussianRoulette) && (attacker == LR_Player_Guard || attacker == LR_Player_Prisoner) && \
					(victim == LR_Player_Guard || victim == LR_Player_Prisoner))
				{
					// determine if LR weapon is being used
					int Pistol_Prisoner = EntRefToEntIndex(GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_PrisonerData)));
					int Pistol_Guard = EntRefToEntIndex(GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_GuardData)));
					
					if ((weapon != Pistol_Prisoner) && (weapon != Pistol_Guard))
					{
						DecideRebelsFate(attacker, idx, victim);
						if (g_Game == Game_CSGO) RightKnifeAntiCheat(attacker, idx);
					}
					
					// null any damage
					damage = 0.0;
					
					// decide if there's a winner
					int bullet = GetRandomInt(1,6);
					switch (bullet)
					{
						case 1:
						{
							KillAndReward(victim, attacker);
							CPrintToChatAll("%s %t", ChatBanner, "Russian Roulette - Hit", victim);

						}
						default:
						{
							if (gH_Cvar_SendGlobalMsgs.BoolValue)
							{						
								CPrintToChatAll("%s %t", ChatBanner, "Russian Roulette - Miss");
							}
							else
							{
								CPrintToChat(LR_Player_Prisoner, "%s %t", ChatBanner, "Russian Roulette - Miss");
								CPrintToChat(LR_Player_Guard, "%s %t", ChatBanner, "Russian Roulette - Miss");
							}
						}
					}
					return Plugin_Handled;
				}
				else if (Type == LR_RockPaperScissors || Type == LR_Race || Type == LR_JumpContest && \
					(attacker == LR_Player_Guard || attacker == LR_Player_Prisoner) && \
					(victim == LR_Player_Guard || victim == LR_Player_Prisoner))
				{
					if (gH_Cvar_LR_Debug_Enabled.BoolValue) LogToFileEx(gShadow_Hosties_LogFile, "%L has been killed for using %s in RPS/R/JC", attacker, UsedWeapon);
					DecideRebelsFate(attacker, idx, -1);
					if (g_Game == Game_CSGO) RightKnifeAntiCheat(attacker, idx);
					
					damage = 0.0;
					return Plugin_Changed;
				}
				else if (Type == LR_Dodgeball && \
					((attacker == LR_Player_Guard || attacker == LR_Player_Prisoner) && \
					(victim == LR_Player_Guard || victim == LR_Player_Prisoner)))
				{
					char ActiveWeapon[64];
					Client_GetActiveWeaponName(attacker, ActiveWeapon, sizeof(ActiveWeapon));
					ReplaceString(ActiveWeapon, sizeof(ActiveWeapon), "weapon_", "", false); 		
					
					if (!StrEqual(ActiveWeapon, "flashbang"))
					{
						if (gH_Cvar_LR_Debug_Enabled.BoolValue) LogToFileEx(gShadow_Hosties_LogFile, "%L has been killed for using %s in Dodgeball", attacker, ActiveWeapon);
						DecideRebelsFate(attacker, idx, -1);
						if (g_Game == Game_CSGO) RightKnifeAntiCheat(attacker, idx);
						
						damage = 0.0;
						return Plugin_Changed;
					}
				}
				else if ((Type == LR_Shot4Shot || Type == LR_Mag4Mag || Type == LR_NoScope) && \
					((attacker == LR_Player_Guard && victim == LR_Player_Prisoner) || \
					(attacker == LR_Player_Prisoner && victim == LR_Player_Guard)))
				{
					int Prisoner_Weapon = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_PrisonerData));
					int Guard_Weapon = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_GuardData));
					
					if (!Weapon_IsValid(weapon))
					{
						weapon = Client_GetActiveWeapon(attacker);
					}
					
					if ((weapon != Prisoner_Weapon) && (weapon != Guard_Weapon) && ((StrContains(UsedWeapon, "knife", false) == -1) && (StrContains(UsedWeapon, "bayonet", false) == -1)))
					{
						damage = 0.0;
						if (g_Game == Game_CSGO) RightKnifeAntiCheat(attacker, idx);
						DecideRebelsFate(attacker, idx);
						if (gH_Cvar_LR_Debug_Enabled.BoolValue) LogToFileEx(gShadow_Hosties_LogFile, "%L has been killed for using %s in Shot4Shot", attacker, UsedWeapon);
						return Plugin_Changed;
					}
				}
				else if (((attacker == LR_Player_Guard && victim != LR_Player_Prisoner) || \
					(attacker == LR_Player_Prisoner && victim != LR_Player_Guard)) && Type != LR_Rebel &&
					(GetClientTeam(attacker) != GetClientTeam(victim)) && Type != LR_Dodgeball)
				{
					damage = 0.0;
					return Plugin_Changed;
				}
				else if (Type == LR_Rebel)
				{
					return Plugin_Continue;
				}
				// Allow LR contestants to attack each other
				else if ((victim == LR_Player_Prisoner && attacker == LR_Player_Guard) || (victim == LR_Player_Guard && attacker == LR_Player_Prisoner))
				{
					return Plugin_Continue;
				}
				// Don't allow attacks outside or inside the Last Request
				else if (victim == LR_Player_Prisoner || victim == LR_Player_Guard || attacker == LR_Player_Prisoner || attacker == LR_Player_Guard)
				{
					damage = 0.0;
					return Plugin_Changed;
				}
				else if (!gH_Cvar_LR_Damage.BoolValue)
				{
					return Plugin_Continue;
				}
			}
		}
	}
	return Plugin_Continue;
}  

public Action OnWeaponDecideUse(int client, int weapon)
{
	int iArraySize = GetArraySize(gH_DArray_LR_Partners);
	if (iArraySize > 0)
	{
		for (int idx = 0; idx < GetArraySize(gH_DArray_LR_Partners); idx++)
		{
			LastRequest type = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_LRType));
			int LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Prisoner));
			int LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Guard));
			
			if (type == LR_HotPotato)
			{
				int HPdeagle = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Global4));
				
				// check if someone else picked up the hot potato
				if (client != LR_Player_Guard && client != LR_Player_Prisoner && weapon == HPdeagle)
				{
					return Plugin_Handled;
				}
				// prevent them from picking up any other pistol
				else if ((client == LR_Player_Guard || client == LR_Player_Prisoner) && weapon != HPdeagle)
				{
					return Plugin_Handled;			
				}
			}
			else if (type == LR_GunToss)
			{
				int GTp1done = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Global3));
				int GTp2done = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Global4));
				int GTp1dropped = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Global1));
				int GTp2dropped = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Global2));
				int GTdeagle1 = EntRefToEntIndex(GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_PrisonerData)));
				int GTdeagle2 = EntRefToEntIndex(GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_GuardData)));
				
				if ((weapon == GTdeagle1 && !GTp1dropped) || (weapon == GTdeagle2 && !GTp2dropped))
				{
					return Plugin_Continue;
				}
				else if ((weapon == GTdeagle1 || weapon == GTdeagle2) && (GTp1done && GTp2done))
				{
					if ((f_DoneDistance[LR_Player_Guard] > f_DoneDistance[LR_Player_Prisoner]) && (client  == LR_Player_Guard) && (weapon == GTdeagle2))
					{
						return Plugin_Continue;
					}
					else if ((f_DoneDistance[LR_Player_Guard] < f_DoneDistance[LR_Player_Prisoner]) && (client  == LR_Player_Prisoner) && (weapon == GTdeagle1))
					{
						return Plugin_Continue;
					}
					else
					{
						return Plugin_Handled;
					}
				}
				else if ((client  == LR_Player_Prisoner) || (client  == LR_Player_Guard))
				{
					return Plugin_Handled;
				}
			}
			// block crashing situations on CS:GO
			else if (type == LR_KnifeFight && g_Game == Game_CSGO)
			{
				char weapon_name[32];
				GetEntityClassname(weapon, weapon_name, sizeof(weapon_name));
				
				// block any weapon pickup during the LR except knife
				if ((client == LR_Player_Guard || client == LR_Player_Prisoner) && !StrEqual(weapon_name, "weapon_knife"))
				{
					return Plugin_Handled;
				}
			}
			else if (type == LR_ChickenFight && g_Game == Game_CSGO)
			{
				if (client == LR_Player_Guard || client == LR_Player_Prisoner)
				{
					return Plugin_Handled;
				}
			}
			else if (type == LR_NoScope && g_Game == Game_CSGO)
			{
				char weapon_name[32];
				GetEntityClassname(weapon, weapon_name, sizeof(weapon_name));
				
				// block switching to knife for NoScope
				if ((client == LR_Player_Guard || client == LR_Player_Prisoner) && StrEqual(weapon_name, "weapon_knife"))
				{
					return Plugin_Handled;
				}
			}
		}
	}
	return Plugin_Continue;
}

public Action OnWeaponEquip(int client, int weapon)
{
	int iArraySize = GetArraySize(gH_DArray_LR_Partners);
	if (iArraySize > 0)
	{
		for (int idx = 0; idx < GetArraySize(gH_DArray_LR_Partners); idx++)
		{	
			LastRequest type = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_LRType));
			int LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Prisoner));
			int LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Guard));

			if (client == LR_Player_Prisoner || client == LR_Player_Guard)
			{
				if (type == LR_GunToss)
				{
					int GTp1dropped = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Global1));
					int GTp2dropped = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Global2));
					int GTp1done = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Global3));
					int GTp2done = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Global4));
					
					if (client == LR_Player_Prisoner && GTp1dropped && !GTp1done)
					{
						char weapon_name[32];
						GetEntityClassname(weapon, weapon_name, sizeof(weapon_name));
						if (StrEqual(weapon_name, "weapon_deagle"))
						{
							SetArrayCell(gH_DArray_LR_Partners, idx, true, view_as<int>(Block_Global3));
							return Plugin_Continue;
						}		
					}
					else if (client == LR_Player_Guard && GTp2dropped && !GTp2done)
					{
						char weapon_name[32];
						GetEntityClassname(weapon, weapon_name, sizeof(weapon_name));
						if (StrEqual(weapon_name, "weapon_deagle"))
						{
							SetArrayCell(gH_DArray_LR_Partners, idx, true, view_as<int>(Block_Global4));
							return Plugin_Continue;
						}
					}
					
					char weapon_name[32];
					GetEntityClassname(weapon, weapon_name, sizeof(weapon_name));
					if (StrEqual(weapon_name, "weapon_deagle"))
					{
						if ((GTp1done && GTp2done) && (GTp1dropped && GTp2dropped))
						{
							if ((f_DoneDistance[LR_Player_Guard] > f_DoneDistance[LR_Player_Prisoner]) && (client == LR_Player_Guard))
							{
								return Plugin_Continue;
							}
							else if ((f_DoneDistance[LR_Player_Guard] < f_DoneDistance[LR_Player_Prisoner]) && (client == LR_Player_Prisoner))
							{
								return Plugin_Continue;
							}
							else
							{
								return Plugin_Handled;
							}
						}
					}
					else
					{
						return Plugin_Handled;
					}
				}
				else if (type == LR_HotPotato)
				{
					int HPdeagle = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Global4));
					if (weapon == HPdeagle)
					{
						SetArrayCell(gH_DArray_LR_Partners, idx, client, view_as<int>(Block_Global1)); // HPloser
						if (gH_Cvar_LR_HotPotato_Mode.IntValue != 2)
						{
							SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", gH_Cvar_LR_HotPotato_Speed.FloatValue);
							// reset other player's speed
							SetEntPropFloat((client == LR_Player_Prisoner ? LR_Player_Guard : LR_Player_Prisoner), 
								Prop_Data, "m_flLaggedMovementValue", 1.0);
						}
						
						if (gH_Cvar_Announce_HotPotato_Eqp.BoolValue)
						{
							if (gH_Cvar_SendGlobalMsgs.BoolValue)
							{
								CPrintToChatAll("%s %t", ChatBanner, "Hot Potato PickUp", client);
							}
							else
							{
								CPrintToChat(LR_Player_Prisoner, "%s %t", ChatBanner, "Hot Potato Pickup", client);
								CPrintToChat(LR_Player_Guard, "%s %t", ChatBanner, "Hot Potato Pickup", client);
							}
						}
					}
				}
			}
		}
	}

	return Plugin_Continue;
}

public Action OnWeaponDrop(int client, int weapon)
{
	int iArraySize = GetArraySize(gH_DArray_LR_Partners);
	if (iArraySize > 0)
	{
		for (int idx = 0; idx < GetArraySize(gH_DArray_LR_Partners); idx++)
		{	
			LastRequest type = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_LRType));
			if (type == LR_RussianRoulette)
			{
				int LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Prisoner));
				int LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Guard));
				
				if (client == LR_Player_Prisoner || client == LR_Player_Guard)
				{
					return Plugin_Handled;
				}
			}
			else if (type == LR_GunToss)
			{
				int LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Prisoner));
				int LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Guard));
				int GTp1dropped = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Global1));
				int GTp2dropped = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Global2));
				
				if (client == LR_Player_Prisoner || client == LR_Player_Guard)
				{
					int GTdeagle1 = EntRefToEntIndex(GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_PrisonerData)));
					int GTdeagle2 = EntRefToEntIndex(GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_GuardData)));
					
					if (((client == LR_Player_Prisoner && GTp1dropped) || 
						(client == LR_Player_Guard && GTp2dropped)))
					{
						if (IsValidEntity(weapon))
						{
							char weapon_name[32];
							GetEntityClassname(weapon, weapon_name, sizeof(weapon_name));
							if (StrEqual(weapon_name, "weapon_deagle"))
							{
								CPrintToChat(client, "%s %t", ChatBanner, "Already Dropped Deagle");
								return Plugin_Handled;
							}
						}
					}
					else
					{
						Handle PositionDataPack = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_DataPackHandle));
						if (client == LR_Player_Prisoner)
						{
							if (IsValidEntity(GTdeagle1))
							{
								SetEntData(GTdeagle1, g_Offset_Clip1, 250);
								GivePlayerItem(LR_Player_Prisoner, "weapon_knife");
							}
							
							if (weapon == GTdeagle1)
							{
								float GTp1droppos[3];
								GetClientAbsOrigin(LR_Player_Prisoner, GTp1droppos);
								#if SOURCEMOD_V_MAJOR >= 1 && SOURCEMOD_V_MINOR >= 8
									SetPackPosition(PositionDataPack, view_as<DataPackPos>(12));
								#else
									SetPackPosition(PositionDataPack, 12);
								#endif
								WritePackFloat(PositionDataPack, GTp1droppos[0]);
								WritePackFloat(PositionDataPack, GTp1droppos[1]);
								WritePackFloat(PositionDataPack, GTp1droppos[2]);
								
								SetArrayCell(gH_DArray_LR_Partners, idx, true, view_as<int>(Block_Global1));
								CreateTimer(10.0, Timer_EnemyMustThrow, TIMER_FLAG_NO_MAPCHANGE);
								CPrintToChat(LR_Player_Guard, "%s %t", ChatBanner, "GT Throw Warning");
							}
						}
						else if (client == LR_Player_Guard)
						{
							if (IsValidEntity(GTdeagle2))
							{
								SetEntData(GTdeagle2, g_Offset_Clip1, 250);
								GivePlayerItem(LR_Player_Guard, "weapon_knife");
							}

							if (weapon == GTdeagle2)
							{
								float GTp2droppos[3];
								GetClientAbsOrigin(LR_Player_Guard, GTp2droppos);
								#if SOURCEMOD_V_MAJOR >= 1 && SOURCEMOD_V_MINOR >= 8
									SetPackPosition(PositionDataPack, view_as<DataPackPos>(15));
								#else
									SetPackPosition(PositionDataPack, 15);
								#endif
								WritePackFloat(PositionDataPack, GTp2droppos[0]);
								WritePackFloat(PositionDataPack, GTp2droppos[1]);
								WritePackFloat(PositionDataPack, GTp2droppos[2]);
								
								SetArrayCell(gH_DArray_LR_Partners, idx, true, view_as<int>(Block_Global2));
								CreateTimer(10.0, Timer_EnemyMustThrow, TIMER_FLAG_NO_MAPCHANGE);
								CPrintToChat(LR_Player_Prisoner, "%s %t", ChatBanner, "GT Throw Warning");
							}
						}	
						
						if (g_GunTossTimer == null && (weapon == GTdeagle1 || weapon == GTdeagle2))
						{
							if (g_Game == Game_CSS)
							{
								g_GunTossTimer = CreateTimer(0.1, Timer_GunToss, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
							}
							else if (g_Game == Game_CSGO)
							{
								g_GunTossTimer = CreateTimer(1.0, Timer_GunToss, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
						}	}
					}
				}
			}
		}
	}
	return Plugin_Continue;
}

public Action Timer_EnemyMustThrow(Handle timer)
{
	int iArraySize = GetArraySize(gH_DArray_LR_Partners);
	if (iArraySize > 0)
	{
		for (int idx = 0; idx < GetArraySize(gH_DArray_LR_Partners); idx++)
		{
			LastRequest type = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_LRType));
			if (type == LR_GunToss)
			{
				int LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Prisoner));
				int LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Guard));
				int GTp1dropped = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Global1));
				int GTp2dropped = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Global2));
				
				if (GTp1dropped && !GTp2dropped)
				{
					KillAndReward(LR_Player_Guard, LR_Player_Prisoner);
					CPrintToChatAll("%s %t", ChatBanner, "GT No Throw", LR_Player_Prisoner, LR_Player_Guard);
				}
				else if (!GTp1dropped && GTp2dropped)
				{
					KillAndReward(LR_Player_Prisoner, LR_Player_Guard);
					CPrintToChatAll("%s %t", ChatBanner, "GT No Throw", LR_Player_Guard, LR_Player_Prisoner);
				}
			}
		}
	}
	return Plugin_Stop;
}

public Action OnPreThink(int client)
{
	int iArraySize = GetArraySize(gH_DArray_LR_Partners);
	if (iArraySize > 0)
	{
		for (int idx = 0; idx < GetArraySize(gH_DArray_LR_Partners); idx++)
		{
			LastRequest type = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_LRType));
			if (type == LR_KnifeFight)
			{
				KnifeType KnifeChoice = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Global1));
				if(KnifeChoice == Knife_ThirdPerson)
				{
					int LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Prisoner));
					int LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Guard));
					if (client == LR_Player_Prisoner || client == LR_Player_Guard)
					{
						SetThirdPerson(client);
					}
				}
			}
		}
	}
}

void LastRequest_OnMapStart()
{
	// Precache any materials needed
	if (g_Game == Game_CSS)
	{
		BeamSprite = PrecacheModel("materials/sprites/laser.vmt");
		HaloSprite = PrecacheModel("materials/sprites/halo01.vmt");
		LaserSprite = PrecacheModel("materials/sprites/lgtning.vmt");
		LaserHalo = PrecacheModel("materials/sprites/plasmahalo.vmt");
	}
	else if (g_Game == Game_CSGO)
	{
		BeamSprite = PrecacheModel("materials/sprites/laserbeam.vmt");
		HaloSprite = PrecacheModel("materials/sprites/glow01.vmt");
		LaserSprite = PrecacheModel("materials/sprites/laserbeam.vmt");
		LaserHalo = PrecacheModel("materials/sprites/light_glow02.vmt");
	}
	
	// Fix for problems with g_BeaconTimer not being set to null on timer terminating (TIMER_FLAG_NO_MAPCHANGE)
	if (g_BeaconTimer != null)
	{
		g_BeaconTimer = null;
	}
	// Fix for the same problem with g_CountdownTimer
	if (g_CountdownTimer != null)
	{
		g_CountdownTimer = null;
	}
}

void LastRequest_OnConfigsExecuted()
{
	if (!g_bPushedToMenu)
	{
		int iIndex = 0;
		// Check LRs
		if (gH_Cvar_LR_KnifeFight_On.BoolValue)
		{
			iIndex = PushArrayCell(gH_DArray_LastRequests, LR_KnifeFight);
			SetArrayCell(gH_DArray_LastRequests, iIndex, true, 1);
		}
		if (gH_Cvar_LR_Shot4Shot_On.BoolValue)
		{
			iIndex = PushArrayCell(gH_DArray_LastRequests, LR_Shot4Shot);
			SetArrayCell(gH_DArray_LastRequests, iIndex, true, 1);
		}
		if (gH_Cvar_LR_GunToss_On.BoolValue)
		{
			iIndex = PushArrayCell(gH_DArray_LastRequests, LR_GunToss);
			SetArrayCell(gH_DArray_LastRequests, iIndex, true, 1);
		}
		if (gH_Cvar_LR_ChickenFight_On.IntValue)
		{
			iIndex = PushArrayCell(gH_DArray_LastRequests, LR_ChickenFight);
			SetArrayCell(gH_DArray_LastRequests, iIndex, true, 1);
		}
		if (gH_Cvar_LR_HotPotato_On.BoolValue)
		{
			iIndex = PushArrayCell(gH_DArray_LastRequests, LR_HotPotato);
			SetArrayCell(gH_DArray_LastRequests, iIndex, true, 1);
		}
		if (gH_Cvar_LR_Dodgeball_On.BoolValue)
		{
			iIndex = PushArrayCell(gH_DArray_LastRequests, LR_Dodgeball);
			SetArrayCell(gH_DArray_LastRequests, iIndex, true, 1);
		}
		if (gH_Cvar_LR_NoScope_On.BoolValue)
		{
			iIndex = PushArrayCell(gH_DArray_LastRequests, LR_NoScope);
			SetArrayCell(gH_DArray_LastRequests, iIndex, true, 1);
		}
		if (gH_Cvar_LR_RockPaperScissors_On.BoolValue)
		{
			iIndex = PushArrayCell(gH_DArray_LastRequests, LR_RockPaperScissors);
			SetArrayCell(gH_DArray_LastRequests, iIndex, true, 1);
		}
		if (gH_Cvar_LR_Rebel_On.BoolValue)
		{
			iIndex = PushArrayCell(gH_DArray_LastRequests, LR_Rebel);
			SetArrayCell(gH_DArray_LastRequests, iIndex, true, 1);
		}
		if (gH_Cvar_LR_Mag4Mag_On.BoolValue)
		{
			iIndex = PushArrayCell(gH_DArray_LastRequests, LR_Mag4Mag);
			SetArrayCell(gH_DArray_LastRequests, iIndex, true, 1);
		}
		if (gH_Cvar_LR_Race_On.BoolValue)
		{
			iIndex = PushArrayCell(gH_DArray_LastRequests, LR_Race);
			SetArrayCell(gH_DArray_LastRequests, iIndex, true, 1);
		}
		if (gH_Cvar_LR_RussianRoulette_On.BoolValue)
		{
			iIndex = PushArrayCell(gH_DArray_LastRequests, LR_RussianRoulette);
			SetArrayCell(gH_DArray_LastRequests, iIndex, true, 1);
		}
		if (gH_Cvar_LR_JumpContest_On.BoolValue)
		{
			iIndex = PushArrayCell(gH_DArray_LastRequests, LR_JumpContest);
			SetArrayCell(gH_DArray_LastRequests, iIndex, true, 1);
		}
	}
	g_bPushedToMenu = true;
	
	// check for -1 for backward compatibility
	MediaType soundfile = type_Sound;
	char buffer[PLATFORM_MAX_PATH];
	gH_Cvar_LR_NoScope_Sound.GetString(buffer, sizeof(buffer));
	if ((strlen(buffer) > 0) && !StrEqual(buffer, "-1"))
	{		
		CacheTheFile(buffer, soundfile);
	}
	gH_Cvar_LR_Sound.GetString(buffer, sizeof(buffer));
	if ((strlen(buffer) > 0) && !StrEqual(buffer, "-1"))
	{
		CacheTheFile(buffer, soundfile);
	}
	gH_Cvar_LR_Beacon_Sound.GetString(buffer, sizeof(buffer));
	if ((strlen(buffer) > 0) && !StrEqual(buffer, "-1"))
	{
		CacheTheFile(buffer, soundfile);
	}

	if (gH_Cvar_LR_BlockSuicide.BoolValue && !g_bListenersAdded)
	{
		AddCommandListener(Suicide_Check, "kill");
		AddCommandListener(Suicide_Check, "explode");
		AddCommandListener(Suicide_Check, "jointeam");
		AddCommandListener(Suicide_Check, "spectate");
		g_bListenersAdded = true;
	}
	else if (!gH_Cvar_LR_BlockSuicide.BoolValue && g_bListenersAdded)
	{
		RemoveCommandListener(Suicide_Check, "kill");
		RemoveCommandListener(Suicide_Check, "explode");
		RemoveCommandListener(Suicide_Check, "jointeam");
		RemoveCommandListener(Suicide_Check, "spectate");
		g_bListenersAdded = false;
	}
}

public void ConVarChanged_Setting(Handle cvar, const char[] oldValue, const char[] newValue)
{
	if (cvar == gH_Cvar_LR_BlockSuicide)
	{
		if (gH_Cvar_LR_BlockSuicide.BoolValue && !g_bListenersAdded)
		{
			AddCommandListener(Suicide_Check, "kill");
			AddCommandListener(Suicide_Check, "explode");
			AddCommandListener(Suicide_Check, "jointeam");
			AddCommandListener(Suicide_Check, "spectate");
			g_bListenersAdded = true;
		}
		else if (!gH_Cvar_LR_BlockSuicide.BoolValue && g_bListenersAdded)
		{
			RemoveCommandListener(Suicide_Check, "kill");
			RemoveCommandListener(Suicide_Check, "explode");
			RemoveCommandListener(Suicide_Check, "jointeam");
			RemoveCommandListener(Suicide_Check, "spectate");
			g_bListenersAdded = false;
		}
		
	}
}

public Action Suicide_Check(int client, const char[] command, int args)
{
	if (client && IsClientInGame(client) && Local_IsClientInLR(client))
	{
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

void UpdateLastRequestArray(LastRequest entry)
{
	int iArrayIndex = FindValueInArray(gH_DArray_LastRequests, entry);
	if (iArrayIndex == -1)
	{
		int iIndex = PushArrayCell(gH_DArray_LastRequests, entry);
		SetArrayCell(gH_DArray_LastRequests, iIndex, true, 1);
	}
	else
	{
		RemoveFromArray(gH_DArray_LastRequests, iArrayIndex);
	}
}

public void ConVarChanged_LastRequest(Handle cvar, const char[] oldValue, const char[] newValue)
{
	// Perform boolean checking
	int iNewValue = StringToInt(newValue);
	int iOldValue = StringToInt(oldValue);
	if (iNewValue == iOldValue || !g_bPushedToMenu)
	{
		return;
	}
	
	if (cvar == gH_Cvar_LR_KnifeFight_On)
	{
		UpdateLastRequestArray(LR_KnifeFight);
	}
	else if (cvar == gH_Cvar_LR_Shot4Shot_On)
	{
		UpdateLastRequestArray(LR_Shot4Shot);
	}
	else if (cvar == gH_Cvar_LR_GunToss_On)
	{
		UpdateLastRequestArray(LR_GunToss);
	}
	else if (cvar == gH_Cvar_LR_ChickenFight_On)
	{
		UpdateLastRequestArray(LR_ChickenFight);
	}
	else if (cvar == gH_Cvar_LR_HotPotato_On)
	{
		UpdateLastRequestArray(LR_HotPotato);
	}
	else if (cvar == gH_Cvar_LR_Dodgeball_On)
	{
		UpdateLastRequestArray(LR_Dodgeball);
	}
	else if (cvar == gH_Cvar_LR_NoScope_On)
	{
		UpdateLastRequestArray(LR_NoScope);
	}
	else if (cvar == gH_Cvar_LR_RockPaperScissors_On)
	{
		UpdateLastRequestArray(LR_RockPaperScissors);
	}
	else if (cvar == gH_Cvar_LR_Rebel_On)
	{
		UpdateLastRequestArray(LR_Rebel);
	}
	else if (cvar == gH_Cvar_LR_Mag4Mag_On)
	{
		UpdateLastRequestArray(LR_Mag4Mag);
	}
	else if (cvar == gH_Cvar_LR_Race_On)
	{
		UpdateLastRequestArray(LR_Race);
	}
	else if (cvar == gH_Cvar_LR_RussianRoulette_On)
	{
		UpdateLastRequestArray(LR_RussianRoulette);
	}
	else if (cvar == gH_Cvar_LR_JumpContest_On)
	{
		UpdateLastRequestArray(LR_JumpContest);
	}
}

bool IsLastRequestAutoStart(LastRequest game)
{
	int iArrayIndex = FindValueInArray(gH_DArray_LastRequests, game);
	if (iArrayIndex == -1)
	{
		return false;
	}
	else
	{
		return view_as<bool>(GetArrayCell(gH_DArray_LastRequests, iArrayIndex, 1));
	}
}

void LastRequest_ClientPutInServer(int client)
{
	SDKHook(client, SDKHook_WeaponDrop, OnWeaponDrop);
	SDKHook(client, SDKHook_WeaponEquip, OnWeaponEquip);
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponDecideUse);
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage); 
	if (g_Game == Game_CSGO)
	{
		SDKHook(client, SDKHook_PreThink, OnPreThink);
	}
}

public Action Command_LastRequest(int client, int args)
{
	if (gH_Cvar_LR_Enable.BoolValue)
	{
		if (g_bIsLRAvailable)
		{
			if (!g_bInLastRequest[client])
			{
				if (IsPlayerAlive(client) && (GetClientTeam(client) == CS_TEAM_T))
				{
					if (g_bIsARebel[client] && !gH_Cvar_RebelHandling.IntValue)
					{
						CPrintToChat(client, "%s %t", ChatBanner, "LR Rebel Not Allowed");
					}
					else
					{
						if ((g_Game == Game_CSGO && GameRules_GetProp("m_bWarmupPeriod") == 0) || g_Game == Game_CSS)
						{
							// check the number of terrorists still alive
							int Ts, CTs, NumCTsAvailable;
							UpdatePlayerCounts(Ts, CTs, NumCTsAvailable);

							if (Ts <= gH_Cvar_MaxPrisonersToLR.IntValue || gH_Cvar_MaxPrisonersToLR.IntValue == 0)
							{
								if (CTs > 0)
								{
									if (NumCTsAvailable > 0)
									{
										if (g_Game == Game_CSGO)
										{
											ConVar g_cvGraceTime = FindConVar("mp_join_grace_time");
											ConVar g_cvFreezeTime = FindConVar("mp_freezetime");
											
											int RoundTime = GameRules_GetProp("m_iRoundTime");
											int GraceTime = GetConVarInt(g_cvGraceTime);
											int FreezeTime = GetConVarInt(g_cvFreezeTime);
											
											int ToCheckTime = (RoundTime - GraceTime - FreezeTime);
										
											if (g_RoundTime < ToCheckTime)
											{
												DisplayLastRequestMenu(client, Ts, CTs);
											}
											else
											{
												CPrintToChat(client, "%s %t", ChatBanner, "LR Grace TimeBlock");
											}
										}
										else if (g_Game == Game_CSS)
										{
											DisplayLastRequestMenu(client, Ts, CTs);
										}
									}
									else
									{
										CPrintToChat(client, "%s %t", ChatBanner, "LR No CTs Available");
									}
								}
								else
								{
									CPrintToChat(client, "%s %t", ChatBanner, "No CTs Alive");
								}
							}
							else
							{
								CPrintToChat(client, "%s %t", ChatBanner, "Too Many Ts");
							}
						}
						else
						{
							CPrintToChat(client, "%s %t", ChatBanner, "Blocked Warmup");
						}
					}
				}
				else
				{
					CPrintToChat(client, "%s %t", ChatBanner, "Not Alive Or In Wrong Team");
				}
			}
			else
			{
				CPrintToChat(client, "%s %t", ChatBanner, "Another LR In Progress");
			}
		}
		else
		{
			CPrintToChat(client, "%s %t", ChatBanner, "LR Not Available");
		}
	}
	else
	{
		CPrintToChat(client, "%s %t", ChatBanner, "LR Not Available");
	}

	return Plugin_Handled;
}

public Action Timer_RoundTimeLeft(Handle timer, int RoundTime)
{
	if (g_RoundTime != 0)
	{
		g_RoundTime = g_RoundTime - 1;
	}
	else
		return Plugin_Stop;
	return Plugin_Continue;
}

void DisplayLastRequestMenu(int client, int Ts, int CTs)
{
	gH_BuildLR[client] = CreateDataPack();
	Handle menu = CreateMenu(LR_Selection_Handler);
	SetMenuTitle(menu, "%T", "LR Choose", client);
	
	char sDataField[MAX_DATAENTRY_SIZE];
	char sTitleField[MAX_DISPLAYNAME_SIZE];
	LastRequest entry;	
	int iLR_ArraySize = GetArraySize(gH_DArray_LastRequests);
	int iCustomCount = 0;
	int iCustomLR_Size = GetArraySize(gH_DArray_LR_CustomNames);
	for (int iLR_Index = 0; iLR_Index < iLR_ArraySize; iLR_Index++)
	{
		entry = GetArrayCell(gH_DArray_LastRequests, iLR_Index);
		if (entry < LastRequest)
		{
			if (entry != LR_Rebel || (entry == LR_Rebel && Ts <= gH_Cvar_LR_Rebel_MaxTs.IntValue && CTs >= gH_Cvar_LR_Rebel_MinCTs.IntValue))
			{
				Format(sDataField, sizeof(sDataField), "%d", entry);
				Format(sTitleField, sizeof(sTitleField), "%T", g_sLastRequestPhrase[entry], client);
				AddMenuItem(menu, sDataField, sTitleField);
			}
		}
		else
		{
			if (iCustomCount < iCustomLR_Size)
			{
				Format(sDataField, sizeof(sDataField), "%d", entry);
				GetArrayString(gH_DArray_LR_CustomNames, iCustomCount, sTitleField, MAX_DISPLAYNAME_SIZE);
				AddMenuItem(menu, sDataField, sTitleField);
				iCustomCount++;
			}
		}
	}
	
	SetMenuExitButton(menu, gH_Cvar_LR_KillTimeouts.BoolValue ? false : true);
	DisplayMenu(menu, client, gH_Cvar_LR_MenuTime.IntValue);
}

public int LR_Selection_Handler(Handle menu, MenuAction action, int client, int iButtonChoice)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (g_bIsLRAvailable)
			{
				if (!g_bInLastRequest[client])
				{
					if (IsPlayerAlive(client) && (GetClientTeam(client) == CS_TEAM_T))
					{
						char sData[MAX_DATAENTRY_SIZE];
						GetMenuItem(menu, iButtonChoice, sData, sizeof(sData));
						LastRequest choice = view_as<LastRequest>(StringToInt(sData));
						g_LRLookup[client] = choice;
						
						switch (choice)
						{
							case LR_KnifeFight:
							{
								Handle KnifeFightMenu = CreateMenu(SubLRType_MenuHandler);								
								SetMenuTitle(KnifeFightMenu, "%T", "Knife Fight Selection Menu", client);
								
								char sSubTypeName[MAX_DISPLAYNAME_SIZE];
								char sDataField[MAX_DATAENTRY_SIZE];
								Format(sDataField, sizeof(sDataField), "%d", Knife_Vintage);
								Format(sSubTypeName, sizeof(sSubTypeName), "%T", "Knife_Vintage", client);
								AddMenuItem(KnifeFightMenu, sDataField, sSubTypeName);
								Format(sDataField, sizeof(sDataField), "%d", Knife_Drunk);
								Format(sSubTypeName, sizeof(sSubTypeName), "%T", "Knife_Drunk", client);
								AddMenuItem(KnifeFightMenu, sDataField, sSubTypeName);
								Format(sDataField, sizeof(sDataField), "%d", Knife_Drugs);
								Format(sSubTypeName, sizeof(sSubTypeName), "%T", "Knife_Drugs", client);
								AddMenuItem(KnifeFightMenu, sDataField, sSubTypeName);
								Format(sDataField, sizeof(sDataField), "%d", Knife_LowGrav);
								Format(sSubTypeName, sizeof(sSubTypeName), "%T", "Knife_LowGrav", client);
								AddMenuItem(KnifeFightMenu, sDataField, sSubTypeName);
								Format(sDataField, sizeof(sDataField), "%d", Knife_HiSpeed);
								Format(sSubTypeName, sizeof(sSubTypeName), "%T", "Knife_HiSpeed", client);
								AddMenuItem(KnifeFightMenu, sDataField, sSubTypeName);
								Format(sDataField, sizeof(sDataField), "%d", Knife_ThirdPerson);
								Format(sSubTypeName, sizeof(sSubTypeName), "%T", "Knife_ThirdPerson", client);
								AddMenuItem(KnifeFightMenu, sDataField, sSubTypeName);
								
								SetMenuExitBackButton(KnifeFightMenu, true);
								DisplayMenu(KnifeFightMenu, client, 10);
							}
							case LR_Shot4Shot, LR_Mag4Mag:
							{
								Handle SubWeaponMenu = CreateMenu(SubLRType_MenuHandler);
								SetMenuTitle(SubWeaponMenu, "%T", "Pistol Selection Menu", client);
								
								char sSubTypeName[MAX_DISPLAYNAME_SIZE];
								char sDataField[MAX_DATAENTRY_SIZE];
								Format(sDataField, sizeof(sDataField), "%d", Pistol_Deagle);
								Format(sSubTypeName, sizeof(sSubTypeName), "%T", "Pistol_Deagle", client);
								AddMenuItem(SubWeaponMenu, sDataField, sSubTypeName);
								Format(sDataField, sizeof(sDataField), "%d", Pistol_P228);
								if (g_Game == Game_CSS)
								{
									Format(sSubTypeName, sizeof(sSubTypeName), "%T", "Pistol_P228", client);
								}
								else if (g_Game == Game_CSGO)
								{
									Format(sSubTypeName, sizeof(sSubTypeName), "%T", "Pistol_P250", client);
								}
								AddMenuItem(SubWeaponMenu, sDataField, sSubTypeName);								
								Format(sDataField, sizeof(sDataField), "%d", Pistol_Glock);
								Format(sSubTypeName, sizeof(sSubTypeName), "%T", "Pistol_Glock", client);
								AddMenuItem(SubWeaponMenu, sDataField, sSubTypeName);		
								Format(sDataField, sizeof(sDataField), "%d", Pistol_FiveSeven);
								Format(sSubTypeName, sizeof(sSubTypeName), "%T", "Pistol_FiveSeven", client);
								AddMenuItem(SubWeaponMenu, sDataField, sSubTypeName);		
								Format(sDataField, sizeof(sDataField), "%d", Pistol_Dualies);
								Format(sSubTypeName, sizeof(sSubTypeName), "%T", "Pistol_Dualies", client);
								AddMenuItem(SubWeaponMenu, sDataField, sSubTypeName);		
								Format(sDataField, sizeof(sDataField), "%d", Pistol_USP);
								if (g_Game == Game_CSS)
								{
									Format(sSubTypeName, sizeof(sSubTypeName), "%T", "Pistol_USP", client);
								}
								else if (g_Game == Game_CSGO)
								{
									Format(sSubTypeName, sizeof(sSubTypeName), "%T", "Pistol_P2000", client);
								}
								AddMenuItem(SubWeaponMenu, sDataField, sSubTypeName);
								if (g_Game == Game_CSGO)
								{
									Format(sDataField, sizeof(sDataField), "%d", Pistol_Tec9);
									Format(sSubTypeName, sizeof(sSubTypeName), "%T", "Pistol_Tec9", client);
									AddMenuItem(SubWeaponMenu, sDataField, sSubTypeName);
									Format(sDataField, sizeof(sDataField), "%d", Pistol_Revolver);
									Format(sSubTypeName, sizeof(sSubTypeName), "%T", "Pistol_Revolver", client);
									AddMenuItem(SubWeaponMenu, sDataField, sSubTypeName);
								}
								
								SetMenuExitBackButton(SubWeaponMenu, true);
								DisplayMenu(SubWeaponMenu, client, 10);
							}					
							case LR_NoScope:
							{
								if (gH_Cvar_LR_NoScope_Weapon.IntValue == 2)
								{
									Handle NSweaponMenu = CreateMenu(SubLRType_MenuHandler);
									SetMenuTitle(NSweaponMenu, "%T", "NS Weapon Chooser Menu", client);

									char sSubTypeName[MAX_DISPLAYNAME_SIZE];
									char sDataField[MAX_DATAENTRY_SIZE];
									Format(sDataField, sizeof(sDataField), "%d", NSW_AWP);
									Format(sSubTypeName, sizeof(sSubTypeName), "%T", "NSW_AWP", client);	
									AddMenuItem(NSweaponMenu, sDataField, sSubTypeName);
									Format(sDataField, sizeof(sDataField), "%d", NSW_Scout);
									if (g_Game == Game_CSS)
									{
										Format(sSubTypeName, sizeof(sSubTypeName), "%T", "NSW_Scout", client);
									}
									else if (g_Game == Game_CSGO)
									{
										Format(sSubTypeName, sizeof(sSubTypeName), "%T", "NSW_SSG08", client);
									}
									AddMenuItem(NSweaponMenu, sDataField, sSubTypeName);
									Format(sDataField, sizeof(sDataField), "%d", NSW_SG550);
									if (g_Game == Game_CSS)
									{
										Format(sSubTypeName, sizeof(sSubTypeName), "%T", "NSW_SG550", client);
									}
									else if (g_Game == Game_CSGO)
									{
										Format(sSubTypeName, sizeof(sSubTypeName), "%T", "NSW_SCAR20", client);
									}
									AddMenuItem(NSweaponMenu, sDataField, sSubTypeName);
									Format(sDataField, sizeof(sDataField), "%d", NSW_G3SG1);
									Format(sSubTypeName, sizeof(sSubTypeName), "%T", "NSW_G3SG1", client);	
									AddMenuItem(NSweaponMenu, sDataField, sSubTypeName);
			
									SetMenuExitButton(NSweaponMenu, true);
									DisplayMenu(NSweaponMenu, client, 10);						
								}
								else
								{
									CreateMainPlayerHandler(client);
								}
							}
							case LR_Race:
							{								
								// create menu for T to choose start point
								Handle racemenu1 = CreateMenu(RaceStartPointHandler);
								SetMenuTitle(racemenu1, "%T", "Find a Starting Location", client);
								char sMenuText[MAX_DISPLAYNAME_SIZE];
								Format(sMenuText, sizeof(sMenuText), "%T", "Use Current Position", client);
								AddMenuItem(racemenu1, "startloc", sMenuText);
								SetMenuExitButton(racemenu1, true);
								DisplayMenu(racemenu1, client, MENU_TIME_FOREVER);						
								
								if (gH_Cvar_LR_Race_NotifyCTs.BoolValue)
								{
									for (int idx = 1; idx <= MaxClients; idx++)
									{
										if (IsClientInGame(idx) && IsPlayerAlive(idx) && (GetClientTeam(idx) == CS_TEAM_CT))
										{
											CPrintToChat(idx, "%s %t", ChatBanner, "Race Could Start Soon", client);
										}
									}
								}
							}
							case LR_Rebel:
							{
								LastRequest gametype = g_LRLookup[client];
								int iArrayIndex = PushArrayCell(gH_DArray_LR_Partners, gametype);
								SetArrayCell(gH_DArray_LR_Partners, iArrayIndex, client, view_as<int>(Block_Prisoner));
								SetArrayCell(gH_DArray_LR_Partners, iArrayIndex, client, view_as<int>(Block_Guard));
								g_bInLastRequest[client] = true;
								g_bIsARebel[client] = true;
								InitializeGame(iArrayIndex);			
							}
							case LR_JumpContest:
							{
								Handle SubJumpMenu = CreateMenu(SubLRType_MenuHandler);
								SetMenuTitle(SubJumpMenu, "%T", "Jump Contest Menu", client);
								
								char sSubTypeName[MAX_DISPLAYNAME_SIZE];
								char sDataField[MAX_DATAENTRY_SIZE];
								
								Format(sDataField, sizeof(sDataField), "%d", Jump_TheMost);
								Format(sSubTypeName, sizeof(sSubTypeName), "%T", "Jump_TheMost", client);
								AddMenuItem(SubJumpMenu, sDataField, sSubTypeName);
								Format(sDataField, sizeof(sDataField), "%d", Jump_Farthest);
								Format(sSubTypeName, sizeof(sSubTypeName), "%T", "Jump_Farthest", client);
								AddMenuItem(SubJumpMenu, sDataField, sSubTypeName);								
								Format(sDataField, sizeof(sDataField), "%d", Jump_BrinkOfDeath);
								Format(sSubTypeName, sizeof(sSubTypeName), "%T", "Jump_BrinkOfDeath", client);
								AddMenuItem(SubJumpMenu, sDataField, sSubTypeName);		
								
								SetMenuExitBackButton(SubJumpMenu, true);
								DisplayMenu(SubJumpMenu, client, 10);							
							}
							default:
							{
								CreateMainPlayerHandler(client);
							}
						}
					}
					else
					{
						CPrintToChat(client, "%s %t", ChatBanner, "Not Alive Or In Wrong Team");
					}
				}
				else
				{
					CPrintToChat(client, "%s %t", ChatBanner, "Another LR In Progress");
				}
			}
			else
			{
				CPrintToChat(client, "%s %t", ChatBanner, "LR Not Available");
			}
		}
		case MenuAction_End:
		{
			if (client > 0 && client < MAXPLAYERS+1)
			{
				if (gH_BuildLR[client] != null)
				{
					CloseHandle(gH_BuildLR[client]);
					gH_BuildLR[client] = null;
				}
			}
			CloseHandle(menu);
		}
		case MenuAction_Cancel:
		{
			if (gH_Cvar_LR_KillTimeouts.BoolValue)
			{
				if (g_Game == Game_CSGO)
				{
					CreateTimer(0.1, Timer_SafeSlay, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
				}
				else
				{
					ForcePlayerSuicide(client);
				}
			}
		}
	}
}

void CreateMainPlayerHandler(int client)
{
	Handle playermenu = CreateMenu(MainPlayerHandler);
	SetMenuTitle(playermenu, "%T", "Choose A Player", client);

	int iNumCTsAvailable = 0;
	int iUserId = 0;
	char sClientName[MAX_DISPLAYNAME_SIZE];
	char sDataField[MAX_DATAENTRY_SIZE];
	for(int i = 1; i <= MaxClients; i++)
	{
		// if player is alive and CT and not in another LR
		if (IsClientInGame(i) && IsPlayerAlive(i) && (GetClientTeam(i) == CS_TEAM_CT) && !g_bInLastRequest[i])
		{
			Format(sClientName, sizeof(sClientName), "%N", i);
			iUserId = GetClientUserId(i);
			Format(sDataField, sizeof(sDataField), "%d", iUserId);
			AddMenuItem(playermenu, sDataField, sClientName);
			iNumCTsAvailable++;
		}
	}

	if (iNumCTsAvailable == 0)
	{
		CPrintToChat(client,"%s %t", ChatBanner, "LR No CTs Available");
		if (client > 0 && client < MAXPLAYERS+1)
		{
			if (gH_BuildLR[client] != null)
			{
				CloseHandle(gH_BuildLR[client]);
				gH_BuildLR[client] = null;
			}
		}
		CloseHandle(playermenu);
	}
	else
	{
		SetMenuExitButton(playermenu, true);
		DisplayMenu(playermenu, client, gH_Cvar_LR_MenuTime.IntValue);
	}
}

public int SubLRType_MenuHandler(Handle SelectionMenu, MenuAction action, int client, int iMenuChoice)
{
	if (action == MenuAction_Select)
	{
		if (g_bIsLRAvailable)
		{
			if (!g_bInLastRequest[client])
			{
				if (IsPlayerAlive(client) && (GetClientTeam(client) == CS_TEAM_T))
				{
					char sDataField[MAX_DATAENTRY_SIZE];	
					GetMenuItem(SelectionMenu, iMenuChoice, sDataField, sizeof(sDataField));
					int iSelection = StringToInt(sDataField);
					WritePackCell(gH_BuildLR[client], iSelection);
					CreateMainPlayerHandler(client);
				}
				else
				{
					CPrintToChat(client,"%s %t", ChatBanner, "Not Alive Or In Wrong Team");
				}
			}
			else
			{
				CPrintToChat(client,"%s %t", ChatBanner, "Too Slow Another LR In Progress");
			}
		}
		else
		{
			CPrintToChat(client,"%s %t", ChatBanner, "LR Not Available");
		}
	}
	else if (action == MenuAction_End)
	{
		if (client > 0 && client < MAXPLAYERS+1)
		{
			if (gH_BuildLR[client] != null)
			{
				CloseHandle(gH_BuildLR[client]);
				gH_BuildLR[client] = null;
			}
		}
		CloseHandle(SelectionMenu);
	}
}

public int RaceEndPointHandler(Handle menu, MenuAction action, int client, int param2)
{
	if (action == MenuAction_Select)
	{
		if (g_bIsLRAvailable)
		{
			if (!g_bInLastRequest[client])
			{
				if (IsPlayerAlive(client) && (GetClientTeam(client) == CS_TEAM_T))
				{
					if (gH_Cvar_LR_Race_AirPoints.BoolValue || (GetEntityFlags(client) & FL_ONGROUND))
					{
						// use this location
						float f_EndLocation[3];
						GetClientAbsOrigin(client, f_EndLocation);
						f_EndLocation[2] += 10;
						
						WritePackFloat(gH_BuildLR[client], f_EndLocation[0]);
						WritePackFloat(gH_BuildLR[client], f_EndLocation[1]);
						WritePackFloat(gH_BuildLR[client], f_EndLocation[2]);
						
						// get start location
						float f_StartLocation[3];
						ResetPack(gH_BuildLR[client]);
						f_StartLocation[0] = ReadPackFloat(gH_BuildLR[client]);
						f_StartLocation[1] = ReadPackFloat(gH_BuildLR[client]);
						f_StartLocation[2] = ReadPackFloat(gH_BuildLR[client]);
						
						// check how far the requested end is from the start
						float distanceBetweenPoints = GetVectorDistance(f_StartLocation, f_EndLocation, false);
						
						if (distanceBetweenPoints > 300.0)
						{
							TE_SetupBeamRingPoint(f_EndLocation, 100.0, 130.0, BeamSprite, HaloSprite, 0, 15, 20.0, 7.0, 0.0, greenColor, 1, 0);
							TE_SendToAll();						
							// allow them to choose a player finally
							CreateMainPlayerHandler(client);
						}
						else
						{
							CPrintToChat(client, "%s %t", ChatBanner, "Race Points too Close");
						}
					}
					else
					{
						CPrintToChat(client, "%s %t", ChatBanner, "Must Be On Ground");
					}
				}
				else
				{
					CPrintToChat(client, "%s %t", ChatBanner, "Not Alive Or In Wrong Team");
				}
			}
			else
			{
				CPrintToChat(client, "%s %t", ChatBanner, "Too Slow Another LR In Progress");
			}
		}
		else
		{
			CPrintToChat(client, "%s %t", ChatBanner, "LR Not Available");
		}
	}
	else if (action == MenuAction_End)
	{
		if (client > 0 && client < MAXPLAYERS+1)
		{
			if (gH_BuildLR[client] != INVALID_HANDLE)
			{
				CloseHandle(gH_BuildLR[client]);
				gH_BuildLR[client] = INVALID_HANDLE;
			}
		}
		CloseHandle(menu);
	}
}

public int RaceStartPointHandler(Handle menu, MenuAction action, int client, int param2)
{
	if (action == MenuAction_Select)
	{
		if (g_bIsLRAvailable)
		{
			if (!g_bInLastRequest[client])
			{
				if (IsPlayerAlive(client) && (GetClientTeam(client) == CS_TEAM_T))
				{
					if (gH_Cvar_LR_Race_AirPoints.BoolValue || (GetEntityFlags(client) & FL_ONGROUND))
					{
						// use this location
						float f_StartPoint[3];
						GetClientAbsOrigin(client, f_StartPoint);
						f_StartPoint[2] += 10;

						TE_SetupBeamRingPoint(f_StartPoint, 100.0, 130.0, BeamSprite, HaloSprite, 0, 15, 30.0, 7.0, 0.0, yellowColor, 1, 0);
						TE_SendToAll();
						
						// write start point
						WritePackFloat(gH_BuildLR[client], f_StartPoint[0]);
						WritePackFloat(gH_BuildLR[client], f_StartPoint[1]);
						WritePackFloat(gH_BuildLR[client], f_StartPoint[2]);
						
						CreateRaceEndPointMenu(client);
					}
					else
					{
						CPrintToChat(client, "%s %t", ChatBanner, "Must Be On Ground");
					}
				}
				else
				{
					CPrintToChat(client, "%s %t", ChatBanner, "Not Alive Or In Wrong Team");
				}
			}
			else
			{
				CPrintToChat(client, "%s %t", ChatBanner, "Too Slow Another LR In Progress");
			}
		}
		else
		{
			CPrintToChat(client, "%s %t", ChatBanner, "LR Not Available");
		}
	}
	else if (action == MenuAction_End)
	{
		if (client > 0 && client < MAXPLAYERS+1)
		{
			if (gH_BuildLR[client] != INVALID_HANDLE)
			{
				CloseHandle(gH_BuildLR[client]);
				gH_BuildLR[client] = INVALID_HANDLE;
			}
		}
		CloseHandle(menu);
	}
}

void CreateRaceEndPointMenu(int client)
{
	Handle EndPointMenu = CreateMenu(RaceEndPointHandler);
	SetMenuTitle(EndPointMenu, "%T", "Choose an End Point", client);
	char sMenuText[MAX_DISPLAYNAME_SIZE];
	Format (sMenuText, sizeof(sMenuText), "%T", "Use Current Position", client);
	AddMenuItem(EndPointMenu, "endpoint", sMenuText);
	SetMenuExitButton(EndPointMenu, true);
	DisplayMenu(EndPointMenu, client, MENU_TIME_FOREVER);
}

public int MainPlayerHandler(Handle playermenu, MenuAction action, int client, int iButtonChoice)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (g_bIsLRAvailable)
			{
				if (!g_bInLastRequest[client])
				{
					if (IsPlayerAlive(client) && (GetClientTeam(client) == CS_TEAM_T))
					{
						char sData[MAX_DATAENTRY_SIZE];
						GetMenuItem(playermenu, iButtonChoice, sData, sizeof(sData));
						int ClientIdxOfCT = GetClientOfUserId(StringToInt(sData));
						
						if (ClientIdxOfCT && IsClientInGame(ClientIdxOfCT) && IsPlayerAlive(ClientIdxOfCT) && (GetClientTeam(ClientIdxOfCT) == CS_TEAM_CT))
						{
							// check the number of terrorists still alive
							int Ts, CTs, iNumCTsAvailable;
							UpdatePlayerCounts(Ts, CTs, iNumCTsAvailable);
							
							if (Ts <= gH_Cvar_MaxPrisonersToLR.IntValue || gH_Cvar_MaxPrisonersToLR.IntValue == 0)
							{
								if (CTs > 0)
								{
									if (iNumCTsAvailable > 0)
									{
										if (!IsFakeClient(ClientIdxOfCT))
										{
											if (!g_bIsARebel[client] || (gH_Cvar_RebelHandling.IntValue == 2))
											{
												if (!g_bInLastRequest[ClientIdxOfCT])
												{
													LastRequest game = g_LRLookup[client];
													if ((game == LR_HotPotato || game == LR_RussianRoulette) && IsClientTooNearObstacle(client))
													{
														CPrintToChat(client, "%s %t", ChatBanner, "Too Near Obstruction");
													}
													// player isn't on ground
													else if ((game == LR_JumpContest) && !(GetEntityFlags(client) & FL_ONGROUND|FL_INWATER))
													{
														CPrintToChat(client, "%s %t", ChatBanner, "Must Be On Ground");
													}
													// make sure they're not ducked
													else if ((game == LR_JumpContest) && (GetEntityFlags(client) & FL_DUCKING))
													{
														CPrintToChat(client, "%s %t", ChatBanner, "Too Near Obstruction");
													}
													else if (IsLastRequestAutoStart(game))
													{
														// lock in this LR pair
														int iArrayIndex = PushArrayCell(gH_DArray_LR_Partners, game);
														SetArrayCell(gH_DArray_LR_Partners, iArrayIndex, client, view_as<int>(Block_Prisoner));
														SetArrayCell(gH_DArray_LR_Partners, iArrayIndex, ClientIdxOfCT, view_as<int>(Block_Guard));
														g_bInLastRequest[client] = true;
														g_bInLastRequest[ClientIdxOfCT] = true;
														InitializeGame(iArrayIndex);
													}
													else
													{
														int iArrayIndex = PushArrayCell(gH_DArray_LR_Partners, game);
														SetArrayCell(gH_DArray_LR_Partners, iArrayIndex, client, view_as<int>(Block_Prisoner));
														SetArrayCell(gH_DArray_LR_Partners, iArrayIndex, ClientIdxOfCT, view_as<int>(Block_Guard));
														InitializeGame(iArrayIndex);
													}
												}
												else
												{
													CPrintToChat(client, "%s %t", ChatBanner, "Another LR In Progress");
												}
											}
											else
											{
												// if rebel, send a menu to the CT asking for permission
												Handle askmenu = CreateMenu(MainAskHandler);
												char lrname[MAX_DISPLAYNAME_SIZE];
												if (g_LRLookup[client] < LastRequest)
												{
													Format(lrname, sizeof(lrname), "%T", g_sLastRequestPhrase[g_LRLookup[client]], ClientIdxOfCT);		
												}
												else
												{
													GetArrayString(gH_DArray_LR_CustomNames, view_as<int>(g_LRLookup[client] - LastRequest), lrname, MAX_DISPLAYNAME_SIZE);
												}
												SetMenuTitle(askmenu, "%T", "Rebel Ask CT For LR", ClientIdxOfCT, client, lrname);
		
												char yes[8];
												char no[8];
												Format(yes, sizeof(yes), "%T", "Yes", ClientIdxOfCT);
												Format(no, sizeof(no), "%T", "No", ClientIdxOfCT);
												AddMenuItem(askmenu, "yes", yes);
												AddMenuItem(askmenu, "no", no);
		
												g_LR_PermissionLookup[ClientIdxOfCT] = client;
												SetMenuExitButton(askmenu, true);
												DisplayMenu(askmenu, ClientIdxOfCT, 6);
		
												CPrintToChat(client, "%s %t", ChatBanner, "Asking For Permission", ClientIdxOfCT);
											}
										}
										else
										{
											CPrintToChat(client, "%s %t", ChatBanner, "LR Not With Bot");
										}
									}
									else
									{
										CPrintToChat(client, "%s %t", ChatBanner, "LR No CTs Available");
									}
								}
								else
								{
									CPrintToChat(client, "%s %t", ChatBanner, "No CTs Alive");
								}
							}
							else
							{
								CPrintToChat(client, "%s %t", ChatBanner, "Too Many Ts");
							}
						}
						else
						{
							CPrintToChat(client, "%s %t", ChatBanner, "Target Is Not Alive Or In Wrong Team");
						}
					}
					else
					{
						CPrintToChat(client, "%s %t", ChatBanner, "Not Alive Or In Wrong Team");
					}
				}
				else
				{
					CPrintToChat(client, "%s %t", ChatBanner, "Another LR In Progress");
				}
			}
			else
			{
				CPrintToChat(client, "%s %t", ChatBanner, "LR Not Available");
			}	
		}
		case MenuAction_End:
		{
			if (client > 0 && client < MAXPLAYERS+1)
			{
				if (gH_BuildLR[client] != INVALID_HANDLE)
				{
					CloseHandle(gH_BuildLR[client]);
					gH_BuildLR[client] = INVALID_HANDLE;
				}
			}
			CloseHandle(playermenu);
		}
	}
}

public int MainAskHandler(Handle askmenu, MenuAction action, int client, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (g_bIsLRAvailable)
			{
				// client here is the guard
				if (!g_bInLastRequest[g_LR_PermissionLookup[client]])
				{
					if ((IsClientInGame(g_LR_PermissionLookup[client])) && (IsPlayerAlive(g_LR_PermissionLookup[client])))
					{
						if (IsPlayerAlive(client) && (GetClientTeam(client) == CS_TEAM_CT))
						{
							// param2, 0 -> yes
							if (param2 == 0 || (client != 0 && !IsFakeClient(client)))
							{
								if (!g_bInLastRequest[client])
								{
									int T_Count = 0;
									for(int idx = 1; idx <= MaxClients; idx++)
									{
										if (IsValidClient(idx) &&IsPlayerAlive(idx) && !IsFakeClient(idx))
										if(GetClientTeam(idx) == CS_TEAM_T)
										{
											T_Count++;
										}
									}

									if (T_Count <= gH_Cvar_MaxPrisonersToLR.IntValue || gH_Cvar_MaxPrisonersToLR.IntValue == 0)
									{								
										LastRequest game = g_LRLookup[g_LR_PermissionLookup[client]];
										
										// lock in this LR pair
										int iArrayIndex = PushArrayCell(gH_DArray_LR_Partners, game);
										SetArrayCell(gH_DArray_LR_Partners, iArrayIndex, g_LR_PermissionLookup[client], view_as<int>(Block_Prisoner));
										SetArrayCell(gH_DArray_LR_Partners, iArrayIndex, client, view_as<int>(Block_Guard));
										InitializeGame(iArrayIndex);
										
										if(IsLastRequestAutoStart(game))
										{
											g_bInLastRequest[client] = true;
											g_bInLastRequest[g_LR_PermissionLookup[client]] = true;
										}
									}
									else
									{
										CPrintToChat(client, "%s %t", ChatBanner, "Too Many Ts");
									}
								}
								else
								{
									CPrintToChat(client, "%s %t", ChatBanner, "Too Slow Another LR In Progress");
								}
							}
							else
							{
								CPrintToChat(g_LR_PermissionLookup[client], "%s %t", ChatBanner, "Declined LR Request", client);
							}
						}
						else
						{
							CPrintToChat(client, "%s %t", ChatBanner, "Not Alive Or In Wrong Team");
						}
					}
					else
					{
						CPrintToChat(client, "%s %t", ChatBanner, "LR Partner Died");
					}
				}
				else
				{
					CPrintToChat(client, "%s %t", ChatBanner, "Too Slow Another LR In Progress");
				}
			}
			else
			{
				CPrintToChat(client, "%s %t", ChatBanner, "LR Not Available");
			}
		}
		case MenuAction_Cancel:
		{
			if (IsClientInGame(g_LR_PermissionLookup[client]))
			{
				CPrintToChat(g_LR_PermissionLookup[client], "%s %t", ChatBanner, "LR Request Decline Or Too Long", client);
			}
		}
		case MenuAction_End:
		{
			if (client > 0 && client < MAXPLAYERS+1)
			{
				if (gH_BuildLR[g_LR_PermissionLookup[client]] != INVALID_HANDLE)
				{
					CloseHandle(gH_BuildLR[g_LR_PermissionLookup[client]]);
					gH_BuildLR[g_LR_PermissionLookup[client]] = INVALID_HANDLE;
				}
			}
			CloseHandle(askmenu);
		}
	}
}

void InitializeGame(int iPartnersIndex)
{
	// grab the info
	LastRequest selection = GetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, view_as<int>(Block_LRType));
	int LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, view_as<int>(Block_Prisoner));
	int LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, view_as<int>(Block_Guard));
	
	// Beacon players
	if (gH_Cvar_LR_Beacons.BoolValue && selection != LR_Rebel && selection != LR_RussianRoulette)
	{
		AddBeacon(LR_Player_Prisoner);
		AddBeacon(LR_Player_Guard);
	}
	
	// log the event for stats engines
	if (selection < LastRequest)
	{
		LogToGame("\"%L\" started a LR game (\"%s\") with \"%L\"", LR_Player_Prisoner, g_sLastRequestPhrase[selection], LR_Player_Guard);
	}
	else
	{
		char LR_Name[MAX_DISPLAYNAME_SIZE];
		GetArrayString(gH_DArray_LR_CustomNames, view_as<int>(selection - LastRequest), LR_Name, MAX_DISPLAYNAME_SIZE);
		LogToGame("\"%L\" started a LR game (\"%s\") with \"%L\"", LR_Player_Prisoner, LR_Name, LR_Player_Guard);
	}
	
	if (IsValidClient(LR_Player_Prisoner))
	{
		SetEntPropFloat(LR_Player_Prisoner, Prop_Data, "m_flLaggedMovementValue", 1.0);
		SetEntityGravity(LR_Player_Prisoner, 1.0);
		
		if (g_Game == Game_CSGO)
		{
			SetEntProp(LR_Player_Prisoner, Prop_Send, "m_passiveItems", 0, 1, 1);
		}
	}
	
	if (IsValidClient(LR_Player_Guard))
	{
		SetEntPropFloat(LR_Player_Guard, Prop_Data, "m_flLaggedMovementValue", 1.0);
		SetEntityGravity(LR_Player_Guard, 1.0);
		
		if (g_Game == Game_CSGO)
		{
			SetEntProp(LR_Player_Guard, Prop_Send, "m_passiveItems", 0, 1, 1);
		}
	}
	
	switch (selection)
	{
		case LR_KnifeFight:
		{
			if (gH_Cvar_LR_RestoreWeapon_T.BoolValue)
				SaveWeapons(LR_Player_Prisoner);
			else
				StripAllWeapons(LR_Player_Prisoner);
				
			if (gH_Cvar_LR_RestoreWeapon_CT.BoolValue)
				SaveWeapons(LR_Player_Guard);
			else
				StripAllWeapons(LR_Player_Guard);

			KnifeType KnifeChoice;
			ResetPack(gH_BuildLR[LR_Player_Prisoner]);
			KnifeChoice = ReadPackCell(gH_BuildLR[LR_Player_Prisoner]);
			
			SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, KnifeChoice, view_as<int>(Block_Global1));
			
			switch (KnifeChoice)
			{
				case Knife_Drunk:
				{
					SetEntData(LR_Player_Prisoner, g_Offset_FOV, 105, 4, true);
					SetEntData(LR_Player_Prisoner, g_Offset_DefFOV, 105, 4, true);	
					ShowOverlayToClient(LR_Player_Prisoner, "effects/strider_pinch_dudv");
					SetEntData(LR_Player_Guard, g_Offset_FOV, 105, 4, true);
					SetEntData(LR_Player_Guard, g_Offset_DefFOV, 105, 4, true);	
					ShowOverlayToClient(LR_Player_Guard, "effects/strider_pinch_dudv");
					if (g_BeerGogglesTimer == INVALID_HANDLE)
					{
						g_BeerGogglesTimer = CreateTimer(1.0, Timer_BeerGoggles, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
					}
				}
				case Knife_LowGrav:
				{
					SetEntityGravity(LR_Player_Prisoner, gH_Cvar_LR_KnifeFight_LowGrav.FloatValue);
					SetEntityGravity(LR_Player_Guard, gH_Cvar_LR_KnifeFight_LowGrav.FloatValue);
				}
				case Knife_HiSpeed:
				{
					SetEntPropFloat(LR_Player_Prisoner, Prop_Data, "m_flLaggedMovementValue", gH_Cvar_LR_KnifeFight_HiSpeed.FloatValue);
					SetEntPropFloat(LR_Player_Guard, Prop_Data, "m_flLaggedMovementValue", gH_Cvar_LR_KnifeFight_HiSpeed.FloatValue);
				}
				case Knife_ThirdPerson:
				{
					SetThirdPerson(LR_Player_Prisoner);
					SetThirdPerson(LR_Player_Guard);
				}
				case Knife_Drugs:
				{
					ShowOverlayToClient(LR_Player_Prisoner, "models/effects/portalfunnel_sheet");
					ShowOverlayToClient(LR_Player_Guard, "models/effects/portalfunnel_sheet");
					
					if (g_Game == Game_CSGO)
					{
						ServerCommand("sm_drug #%i 1", GetClientUserId(LR_Player_Prisoner));
						ServerCommand("sm_drug #%i 1", GetClientUserId(LR_Player_Guard));
					}
				}
			}

			// give knives
			GivePlayerItem(LR_Player_Prisoner, "weapon_knife");
			GivePlayerItem(LR_Player_Guard, "weapon_knife");

			// announce LR
			CPrintToChatAll("%s %t", ChatBanner, "LR KF Start", LR_Player_Prisoner, LR_Player_Guard);		
		}
		case LR_Shot4Shot:
		{
			if (gH_Cvar_LR_RestoreWeapon_T.BoolValue)
				SaveWeapons(LR_Player_Prisoner);
			else
				StripAllWeapons(LR_Player_Prisoner);
				
			if (gH_Cvar_LR_RestoreWeapon_CT.BoolValue)
				SaveWeapons(LR_Player_Guard);
			else
				StripAllWeapons(LR_Player_Guard);

			// grab weapon choice
			PistolWeapon PistolChoice;
			ResetPack(gH_BuildLR[LR_Player_Prisoner]);
			PistolChoice = ReadPackCell(gH_BuildLR[LR_Player_Prisoner]);
	
			int Pistol_Prisoner, Pistol_Guard, Prisoner_Weapon, Guard_Weapon;
			switch (PistolChoice)
			{
				case Pistol_Deagle:
				{
					Pistol_Prisoner = GivePlayerItem(LR_Player_Prisoner, "weapon_deagle");
					Pistol_Guard = GivePlayerItem(LR_Player_Guard, "weapon_deagle");
				}
				case Pistol_P228:
				{
					if (g_Game == Game_CSS)
					{
						Pistol_Prisoner = GivePlayerItem(LR_Player_Prisoner, "weapon_p228");
						Pistol_Guard = GivePlayerItem(LR_Player_Guard, "weapon_p228");
					}
					else if (g_Game == Game_CSGO)
					{
						Pistol_Prisoner = GivePlayerItem(LR_Player_Prisoner, "weapon_p250");
						Pistol_Guard = GivePlayerItem(LR_Player_Guard, "weapon_p250");
					}
				}
				case Pistol_Glock:
				{
					Pistol_Prisoner = GivePlayerItem(LR_Player_Prisoner, "weapon_glock");
					Pistol_Guard = GivePlayerItem(LR_Player_Guard, "weapon_glock");
				}
				case Pistol_FiveSeven:
				{
					Pistol_Prisoner = GivePlayerItem(LR_Player_Prisoner, "weapon_fiveseven");
					Pistol_Guard = GivePlayerItem(LR_Player_Guard, "weapon_fiveseven");
				}
				case Pistol_Dualies:
				{
					Pistol_Prisoner = GivePlayerItem(LR_Player_Prisoner, "weapon_elite");
					Pistol_Guard = GivePlayerItem(LR_Player_Guard, "weapon_elite");
				}
				case Pistol_USP:
				{
					if(g_Game == Game_CSS)
					{
						Pistol_Prisoner = GivePlayerItem(LR_Player_Prisoner, "weapon_usp");
						Pistol_Guard = GivePlayerItem(LR_Player_Guard, "weapon_usp");
					}
					else if(g_Game == Game_CSGO)
					{
						Pistol_Prisoner = GivePlayerItem(LR_Player_Prisoner, "weapon_usp_silencer");
						Pistol_Guard = GivePlayerItem(LR_Player_Guard, "weapon_usp_silencer");
					}
				}
				case Pistol_Tec9:
				{
					Pistol_Prisoner = GivePlayerItem(LR_Player_Prisoner, "weapon_tec9");
					Pistol_Guard = GivePlayerItem(LR_Player_Guard, "weapon_tec9");
				}
				case Pistol_Revolver:
				{
					Pistol_Prisoner = GivePlayerItem(LR_Player_Prisoner, "weapon_revolver");
					Pistol_Guard = GivePlayerItem(LR_Player_Guard, "weapon_revolver");
				}
				default:
				{
					LogError("hit default S4S");
					Pistol_Prisoner = GivePlayerItem(LR_Player_Prisoner, "weapon_deagle");
					Pistol_Guard = GivePlayerItem(LR_Player_Guard, "weapon_deagle");
				}
			}
			
			Prisoner_Weapon = GetEntPropEnt(LR_Player_Prisoner, Prop_Data, "m_hActiveWeapon");
			Guard_Weapon = GetEntPropEnt(LR_Player_Guard, Prop_Data, "m_hActiveWeapon");
			
			GivePlayerItem(LR_Player_Prisoner, "weapon_knife");
			GivePlayerItem(LR_Player_Guard, "weapon_knife");
			SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, Pistol_Prisoner, view_as<int>(Block_PrisonerData));
			SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, Pistol_Guard, view_as<int>(Block_GuardData));
			
			if(g_Game == Game_CSGO)
			{
				SetZeroAmmo(LR_Player_Guard, Guard_Weapon);
				SetZeroAmmo(LR_Player_Prisoner, Prisoner_Weapon);
			}
			
			CPrintToChatAll("%s %t", ChatBanner, "LR S4S Start", LR_Player_Prisoner, LR_Player_Guard);
			// randomize who starts first
			int s4sPlayerFirst = GetRandomInt(0, 1);
			if (s4sPlayerFirst == 0)
			{
				SetEntData(Pistol_Prisoner, g_Offset_Clip1, 0);
				SetEntData(Pistol_Guard, g_Offset_Clip1, 1);
				SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, LR_Player_Prisoner, view_as<int>(Block_Global1));
				if (gH_Cvar_SendGlobalMsgs.BoolValue)
				{
					CPrintToChatAll("%s %t", ChatBanner, "Randomly Chose First Player", LR_Player_Guard);
				}
				else
				{
					CPrintToChat(LR_Player_Prisoner, "%s %t", ChatBanner, "Randomly Chose First Player", LR_Player_Guard);
					CPrintToChat(LR_Player_Guard, "%s %t", ChatBanner, "Randomly Chose First Player", LR_Player_Guard);
				}
			}
			else
			{
				SetEntData(Pistol_Prisoner, g_Offset_Clip1, 1);
				SetEntData(Pistol_Guard, g_Offset_Clip1, 0);			
				SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, LR_Player_Guard, view_as<int>(Block_Global1));
				if (gH_Cvar_SendGlobalMsgs.BoolValue)
				{
					CPrintToChatAll("%s %t", ChatBanner, "Randomly Chose First Player", LR_Player_Prisoner);
				}
				else
				{
					CPrintToChat(LR_Player_Prisoner, "%s %t", ChatBanner, "Randomly Chose First Player", LR_Player_Prisoner);
					CPrintToChat(LR_Player_Guard, "%s %t", ChatBanner, "Randomly Chose First Player", LR_Player_Prisoner);				
				}
			}

			// set secondary ammo to 0
			if(g_Game == Game_CSGO)
			{
				SetEntProp(Pistol_Guard, Prop_Send, "m_iPrimaryReserveAmmoCount", 0);
				SetEntProp(Pistol_Prisoner, Prop_Send, "m_iPrimaryReserveAmmoCount", 0);
			}
			else
			{
				int iAmmoType = GetEntProp(Pistol_Prisoner, Prop_Send, "m_iPrimaryAmmoType");
				SetEntData(LR_Player_Guard, g_Offset_Ammo+(iAmmoType*4), 0, _, true);
				SetEntData(LR_Player_Prisoner, g_Offset_Ammo+(iAmmoType*4), 0, _, true);
			}
		}
		case LR_GunToss:
		{
			if (gH_Cvar_LR_RestoreWeapon_T.BoolValue)
				SaveWeapons(LR_Player_Prisoner);
			else
				StripAllWeapons(LR_Player_Prisoner);
				
			if (gH_Cvar_LR_RestoreWeapon_CT.BoolValue)
				SaveWeapons(LR_Player_Guard);
			else
				StripAllWeapons(LR_Player_Guard);
			
			SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, false, view_as<int>(Block_Global1)); // GTp1dropped
			SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, false, view_as<int>(Block_Global2)); // GTp2dropped
			SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, false, view_as<int>(Block_Global3)); // GTp1done
			SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, false, view_as<int>(Block_Global4)); // GTp2done
			
			Handle DataPackPosition = CreateDataPack();
			SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, DataPackPosition, view_as<int>(Block_DataPackHandle)); // position handle
			WritePackFloat(DataPackPosition, 0.0);
			WritePackFloat(DataPackPosition, 0.0);
			WritePackFloat(DataPackPosition, 0.0); // GTdeagle1lastpos
			WritePackFloat(DataPackPosition, 0.0);
			WritePackFloat(DataPackPosition, 0.0);
			WritePackFloat(DataPackPosition, 0.0); // GTdeagle2lastpos
			WritePackFloat(DataPackPosition, 0.0);
			WritePackFloat(DataPackPosition, 0.0);
			WritePackFloat(DataPackPosition, 0.0); // 
			WritePackFloat(DataPackPosition, 0.0);
			WritePackFloat(DataPackPosition, 0.0);
			WritePackFloat(DataPackPosition, 0.0); // 
			WritePackFloat(DataPackPosition, 0.0);
			WritePackFloat(DataPackPosition, 0.0);
			WritePackFloat(DataPackPosition, 0.0); // player 1 last jump position
			WritePackFloat(DataPackPosition, 0.0);
			WritePackFloat(DataPackPosition, 0.0);
			WritePackFloat(DataPackPosition, 0.0); // player 2 last jump position

			int GTdeagle1 = GivePlayerItem(LR_Player_Prisoner, "weapon_deagle");
			int GTdeagle2 = GivePlayerItem(LR_Player_Guard, "weapon_deagle");
			int Prisoner_GunEntRef = EntIndexToEntRef(GTdeagle1);
			int Guard_GunEntRef = EntIndexToEntRef(GTdeagle2);
			SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, Prisoner_GunEntRef, view_as<int>(Block_PrisonerData));
			SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, Guard_GunEntRef, view_as<int>(Block_GuardData));

			SetEntityRenderMode(GTdeagle1, RENDER_TRANSCOLOR);
			SetEntityRenderColor(GTdeagle1, 255, 0, 0);
			SetEntityRenderMode(GTdeagle2, RENDER_TRANSCOLOR);
			SetEntityRenderColor(GTdeagle2, 0, 0, 255);
			
			EquipPlayerWeapon(LR_Player_Prisoner, GTdeagle1);
			EquipPlayerWeapon(LR_Player_Guard, GTdeagle2);
			
			SetEntPropEnt(LR_Player_Prisoner, Prop_Send, "m_hActiveWeapon", GTdeagle1);
			SetEntPropEnt(LR_Player_Guard, Prop_Send, "m_hActiveWeapon", GTdeagle2);

			// set secondary ammo to 0
			if(g_Game == Game_CSGO)
			{
				SetZeroAmmo(LR_Player_Prisoner, GTdeagle1);
				SetZeroAmmo(LR_Player_Guard, GTdeagle2);
			}
			else
			{
				int iAmmoType = GetEntProp(GTdeagle1, Prop_Send, "m_iPrimaryAmmoType");
				SetEntData(LR_Player_Guard, g_Offset_Ammo+(iAmmoType*4), 0, _, true);
				SetEntData(LR_Player_Prisoner, g_Offset_Ammo+(iAmmoType*4), 0, _, true);
			}
			
			// announce LR
			CPrintToChatAll("%s %t", ChatBanner, "LR GT Start", LR_Player_Prisoner, LR_Player_Guard);
		}
		case LR_ChickenFight:
		{
			if (gH_Cvar_LR_RestoreWeapon_T.BoolValue)
				SaveWeapons(LR_Player_Prisoner);
			else
				StripAllWeapons(LR_Player_Prisoner);
				
			if (gH_Cvar_LR_RestoreWeapon_CT.BoolValue)
				SaveWeapons(LR_Player_Guard);
			else
				StripAllWeapons(LR_Player_Guard);

			if (g_ChickenFightTimer == INVALID_HANDLE)
			{
				g_ChickenFightTimer = CreateTimer(0.2, Timer_ChickenFight, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			}

			BlockEntity(LR_Player_Prisoner, g_Offset_CollisionGroup);
			BlockEntity(LR_Player_Guard, g_Offset_CollisionGroup);

			// announce LR
			CPrintToChatAll("%s %t", ChatBanner, "LR CF Start", LR_Player_Prisoner, LR_Player_Guard);
		}
		case LR_HotPotato:
		{
			if (gH_Cvar_LR_RestoreWeapon_T.BoolValue)
				SaveWeapons(LR_Player_Prisoner);
			else
				StripAllWeapons(LR_Player_Prisoner);
				
			if (gH_Cvar_LR_RestoreWeapon_CT.BoolValue)
				SaveWeapons(LR_Player_Guard);
			else
				StripAllWeapons(LR_Player_Guard);

			// always give potato to the prisoner
			int potatoClient = LR_Player_Prisoner;
			SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, potatoClient, view_as<int>(Block_Global1)); // HPloser

			// create the potato deagle
			int HPdeagle = GivePlayerItem(potatoClient, "weapon_deagle");
			SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, HPdeagle, view_as<int>(Block_Global4));
			DispatchSpawn(HPdeagle);
			EquipPlayerWeapon(potatoClient, HPdeagle);
			SetEntPropEnt(potatoClient, Prop_Send, "m_hActiveWeapon", HPdeagle);

			// set ammo (Clip2) 0
			if(g_Game == Game_CSGO)
			{
				SetEntProp(HPdeagle, Prop_Send, "m_iPrimaryReserveAmmoCount", 0);
			}
			else
			{
				SetEntData(potatoClient, g_Offset_Ammo+(1*4), 0);
			}
			// set ammo (Clip1) 0
			SetEntData(HPdeagle, g_Offset_Clip1, 0);

			SetEntityRenderMode(HPdeagle, RENDER_TRANSCOLOR);
			SetEntityRenderColor(HPdeagle, 255, 255, 0);

			float p1pos[3], p2pos[3];
			GetClientAbsOrigin(LR_Player_Prisoner, p1pos);
			
			float f_PrisonerAngles[3], f_SubtractFromPrisoner[3];
			GetClientEyeAngles(LR_Player_Prisoner, f_PrisonerAngles);			
			// zero out pitch/yaw
			f_PrisonerAngles[0] = 0.0;			
			GetAngleVectors(f_PrisonerAngles, f_SubtractFromPrisoner, NULL_VECTOR, NULL_VECTOR);
			float f_GuardDirection[3];
			f_GuardDirection = f_SubtractFromPrisoner;
			if (g_Game == Game_CSS)
			{
				ScaleVector(f_SubtractFromPrisoner, -70.0);
			}
			else if (g_Game == Game_CSGO)
			{
				ScaleVector(f_SubtractFromPrisoner, -115.0);
			}
			MakeVectorFromPoints(f_SubtractFromPrisoner, p1pos, p2pos);

			if (g_Game == Game_CSGO)
			{
				p1pos[2] -= 20.0;
			}
			
			// create 'unique' ID for this hot potato
			int uniqueID = GetRandomInt(1, 31337);
			SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, uniqueID, view_as<int>(Block_Global3));
			
			// create timer to end hot potato
			float rndEnd = GetRandomFloat(gH_Cvar_LR_HotPotato_MinTime.FloatValue, gH_Cvar_LR_HotPotato_MaxTime.FloatValue);
			CreateTimer(rndEnd, Timer_HotPotatoDone, uniqueID, TIMER_FLAG_NO_MAPCHANGE);

			if (gH_Cvar_LR_HotPotato_Mode.IntValue == 2)
			{
				SetEntityMoveType(LR_Player_Prisoner, MOVETYPE_NONE);
				SetEntityMoveType(LR_Player_Guard, MOVETYPE_NONE);
				ScaleVector(f_GuardDirection, -1.0);
				TeleportEntity(LR_Player_Guard, p2pos, f_GuardDirection, view_as<float>({0.0, 0.0, 0.0}));
				TeleportEntity(LR_Player_Prisoner, NULL_VECTOR, NULL_VECTOR, view_as<float>({0.0, 0.0, 0.0}));
			}
			else
			{
				if (gH_Cvar_LR_HotPotato_Mode.IntValue == 1)
				{
					if (gH_Cvar_NoBlock.BoolValue)
					{
						UnblockEntity(LR_Player_Prisoner, g_Offset_CollisionGroup);
						UnblockEntity(LR_Player_Guard, g_Offset_CollisionGroup);
					}
					TeleportEntity(LR_Player_Guard, p2pos, f_GuardDirection, NULL_VECTOR);
				}
				
				SetEntPropFloat(LR_Player_Prisoner, Prop_Data, "m_flLaggedMovementValue", gH_Cvar_LR_HotPotato_Speed.FloatValue);				
			}
			TeleportEntity(HPdeagle, p1pos, NULL_VECTOR, NULL_VECTOR);
			
			if (gH_Cvar_LR_Beacons.BoolValue)
			{
				AddBeacon(HPdeagle);
			}
			
			// announce LR
			CPrintToChatAll("%s %t", ChatBanner, "LR HP Start", LR_Player_Prisoner, LR_Player_Guard);
		}
		case LR_Dodgeball:
		{
			if (gH_Cvar_LR_RestoreWeapon_T.BoolValue)
				SaveWeapons(LR_Player_Prisoner);
			else
				StripAllWeapons(LR_Player_Prisoner);
				
			if (gH_Cvar_LR_RestoreWeapon_CT.BoolValue)
				SaveWeapons(LR_Player_Guard);
			else
				StripAllWeapons(LR_Player_Guard);

			// bug fix...
			if(g_Game != Game_CSGO)
			{
				SetEntData(LR_Player_Prisoner, g_Offset_Ammo + (12 * 4), 0, _, true);
				SetEntData(LR_Player_Guard, g_Offset_Ammo + (12 * 4), 0, _, true);
			}

			BlockEntity(LR_Player_Guard, g_Offset_CollisionGroup);
			BlockEntity(LR_Player_Prisoner, g_Offset_CollisionGroup);

			// set HP
			SetEntData(LR_Player_Prisoner, g_Offset_Health, 1);
			SetEntData(LR_Player_Guard, g_Offset_Health, 1);
			SetEntData(LR_Player_Prisoner, g_Offset_Armor, 0);
			SetEntData(LR_Player_Guard, g_Offset_Armor, 0);

			// give flashbangs
			GivePlayerItem(LR_Player_Guard, "weapon_flashbang");
			GivePlayerItem(LR_Player_Prisoner, "weapon_flashbang");

			SetEntityGravity(LR_Player_Prisoner, gH_Cvar_LR_Dodgeball_Gravity.FloatValue);
			SetEntityGravity(LR_Player_Guard, gH_Cvar_LR_Dodgeball_Gravity.FloatValue);
			
			// timer making sure DB contestants stay @ 1 HP (if enabled by cvar)
			if ((g_DodgeballTimer == INVALID_HANDLE) && gH_Cvar_LR_Dodgeball_CheatCheck.BoolValue)
			{
				g_DodgeballTimer = CreateTimer(1.0, Timer_DodgeballCheckCheaters, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			}

			// announce LR
			CPrintToChatAll("%s %t", ChatBanner, "LR DB Start", LR_Player_Prisoner, LR_Player_Guard);
		}
		case LR_NoScope:
		{
			if (gH_Cvar_LR_RestoreWeapon_T.BoolValue)
				SaveWeapons(LR_Player_Prisoner);
			else
				StripAllWeapons(LR_Player_Prisoner);
				
			if (gH_Cvar_LR_RestoreWeapon_CT.BoolValue)
				SaveWeapons(LR_Player_Guard);
			else
				StripAllWeapons(LR_Player_Guard);

			GivePlayerItem(LR_Player_Prisoner, "weapon_knife");
			GivePlayerItem(LR_Player_Guard, "weapon_knife");

			NoScopeWeapon WeaponChoice;
			switch (gH_Cvar_LR_NoScope_Weapon.IntValue)
			{
				case 0:
				{
					WeaponChoice = NSW_AWP;
				}
				case 1:
				{
					WeaponChoice = NSW_Scout;
				}
				case 2:
				{
					ResetPack(gH_BuildLR[LR_Player_Prisoner]);
					WeaponChoice = ReadPackCell(gH_BuildLR[LR_Player_Prisoner]);			
				}
				case 3:
				{
					WeaponChoice = NSW_SG550;
				}
				case 4:
				{
					WeaponChoice = NSW_G3SG1;
				}
			}
			
			SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, WeaponChoice, view_as<int>(Block_Global2));
			
			CPrintToChatAll("%s %t", ChatBanner, "LR NS Start", LR_Player_Prisoner, LR_Player_Guard);
			if (gH_Cvar_LR_NoScope_Delay.IntValue > 0)
			{
				SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, gH_Cvar_LR_NoScope_Delay.IntValue, view_as<int>(Block_Global1));
				if (g_CountdownTimer == INVALID_HANDLE)
				{
					g_CountdownTimer = CreateTimer(1.0, Timer_Countdown, iPartnersIndex, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				}
			}
			// launch now if there's no countdown requested
			else
			{				
				int NSW_Prisoner, NSW_Guard;
				switch (WeaponChoice)
				{
					case NSW_AWP:
					{
						NSW_Prisoner = GivePlayerItem(LR_Player_Prisoner, "weapon_awp");
						NSW_Guard = GivePlayerItem(LR_Player_Guard, "weapon_awp");
					}
					case NSW_Scout:
					{
						if (g_Game == Game_CSS)
						{
							NSW_Prisoner = GivePlayerItem(LR_Player_Prisoner, "weapon_scout");
							NSW_Guard = GivePlayerItem(LR_Player_Guard, "weapon_scout");
						}
						else if (g_Game == Game_CSGO)
						{
							NSW_Prisoner = GivePlayerItem(LR_Player_Prisoner, "weapon_ssg08");
							NSW_Guard = GivePlayerItem(LR_Player_Guard, "weapon_ssg08");
						}
					}
					case NSW_SG550:
					{
						if (g_Game == Game_CSS)
						{
							NSW_Prisoner = GivePlayerItem(LR_Player_Prisoner, "weapon_sg550");
							NSW_Guard = GivePlayerItem(LR_Player_Guard, "weapon_sg550");
						}
						else if (g_Game == Game_CSGO)
						{
							NSW_Prisoner = GivePlayerItem(LR_Player_Prisoner, "weapon_scar20");
							NSW_Guard = GivePlayerItem(LR_Player_Guard, "weapon_scar20");
						}
					}
					case NSW_G3SG1:
					{
						NSW_Prisoner = GivePlayerItem(LR_Player_Prisoner, "weapon_g3sg1");
						NSW_Guard = GivePlayerItem(LR_Player_Guard, "weapon_g3sg1");
					}
					default:
					{
						LogError("hit default NS");
						NSW_Prisoner = GivePlayerItem(LR_Player_Prisoner, "weapon_awp");
						NSW_Guard = GivePlayerItem(LR_Player_Guard, "weapon_awp");
					}
				}
				
				SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, NSW_Prisoner, view_as<int>(Block_PrisonerData));
				SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, NSW_Guard, view_as<int>(Block_GuardData));
				
				if (gH_Cvar_LR_Debug_Enabled.BoolValue)
				{
					char sWeaponName[32], sWeaponNameB[32];
				
					GetEntityClassname(NSW_Guard, sWeaponName, sizeof(sWeaponName));
					ReplaceString(sWeaponName, sizeof(sWeaponName), "weapon_", "");
					
					GetEntityClassname(NSW_Prisoner, sWeaponNameB, sizeof(sWeaponNameB));
					ReplaceString(sWeaponNameB, sizeof(sWeaponNameB), "weapon_", "");
					
					LogToFileEx(gShadow_Hosties_LogFile, "NoScope choosen weapon is T:'%s' | CT:'%s'", sWeaponName, sWeaponNameB);
				}
				
				SetEntPropEnt(LR_Player_Prisoner, Prop_Send, "m_hActiveWeapon", NSW_Prisoner);
				SetEntPropEnt(LR_Player_Guard, Prop_Send, "m_hActiveWeapon", NSW_Guard);
				SetEntData(NSW_Prisoner, g_Offset_Clip1, 99);
				SetEntData(NSW_Guard, g_Offset_Clip1, 99);
				
				// place delay on zoom
				SetEntDataFloat(NSW_Prisoner, g_Offset_SecAttack, 5000.0);
				SetEntDataFloat(NSW_Guard, g_Offset_SecAttack, 5000.0);
				
				char buffer[PLATFORM_MAX_PATH];
				gH_Cvar_LR_NoScope_Sound.GetString(buffer, sizeof(buffer));
				if ((strlen(buffer) > 0) && !StrEqual(buffer, "-1"))
				{
					EmitSoundToAllAny(buffer);
				}			
			}
		}
		case LR_RockPaperScissors:
		{
			SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, -1, view_as<int>(Block_Global1));
			SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, -1, view_as<int>(Block_Global2));
			Handle rpsmenu1 = CreateMenu(RPSmenuHandler);
			SetMenuTitle(rpsmenu1, "%T", "Rock Paper Scissors", LR_Player_Prisoner);
			SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, rpsmenu1, view_as<int>(Block_PrisonerData));

			char r1[32], p1[64], s1[64];
			Format(r1, sizeof(r1), "%T", "Rock", LR_Player_Prisoner);
			Format(p1, sizeof(p1), "%T", "Paper", LR_Player_Prisoner);
			Format(s1, sizeof(s1), "%T", "Scissors", LR_Player_Prisoner);
			AddMenuItem(rpsmenu1, "0", r1);
			AddMenuItem(rpsmenu1, "1", p1);
			AddMenuItem(rpsmenu1, "2", s1);

			SetMenuExitButton(rpsmenu1, true);
			DisplayMenu(rpsmenu1, LR_Player_Prisoner, 15);

			Handle rpsmenu2 = CreateMenu(RPSmenuHandler);
			SetMenuTitle(rpsmenu2, "%T", "Rock Paper Scissors", LR_Player_Guard);
			SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, rpsmenu2, view_as<int>(Block_GuardData));

			char r2[32], p2[64], s2[64];
			Format(r2, sizeof(r2), "%T", "Rock", LR_Player_Guard);
			Format(p2, sizeof(p2), "%T", "Paper", LR_Player_Guard);
			Format(s2, sizeof(s2), "%T", "Scissors", LR_Player_Guard);
			AddMenuItem(rpsmenu2, "0", r2);
			AddMenuItem(rpsmenu2, "1", p2);
			AddMenuItem(rpsmenu2, "2", s2);

			SetMenuExitButton(rpsmenu2, true);
			DisplayMenu(rpsmenu2, LR_Player_Guard, 15);

			// announce LR
			CPrintToChatAll("%s %t", ChatBanner, "LR RPS Start", LR_Player_Prisoner, LR_Player_Guard);
		}
		case LR_Rebel:
		{
			// strip weapons from T rebelling
			StripAllWeapons(LR_Player_Prisoner);

			// give knife
			GivePlayerItem(LR_Player_Prisoner, "weapon_knife");
			
			// give deagle with ammo
			int RebelDeagle = GivePlayerItem(LR_Player_Prisoner, "weapon_deagle");
			SetEntData(RebelDeagle, g_Offset_Clip1, 7);

			// set primary and secondary ammo
			SetEntData(RebelDeagle, g_Offset_Clip1, 7);
			if(g_Game == Game_CSGO)
			{
				SetEntProp(RebelDeagle, Prop_Send, "m_iPrimaryReserveAmmoCount", 42);
			}
			else
			{
				SetEntData(LR_Player_Prisoner, g_Offset_Ammo+(1*4), 42);
			}
			
			if (g_Game == Game_CSGO)
			{
				GivePlayerItem(LR_Player_Prisoner, "weapon_negev");
			}
			else
			{
				GivePlayerItem(LR_Player_Prisoner, "weapon_m249");
			}

			// find number of alive CTs
			int numCTsAlive = 0;
			for(int i = 1; i <= MaxClients; i++)
			{
				if (IsClientInGame(i) && IsPlayerAlive(i))
				{
					if (GetClientTeam(i) == CS_TEAM_CT)
					{
						numCTsAlive++;
					}
				}
			}
			
			// set HP
			SetEntData(LR_Player_Prisoner, g_Offset_Health, numCTsAlive*gH_Cvar_LR_Rebel_HP_per_CT.IntValue);
			
			// announce LR
			CPrintToChatAll("%s %t", ChatBanner, "LR Has Chosen to Rebel!", LR_Player_Prisoner);
		}
		case LR_Mag4Mag:
		{
			if (gH_Cvar_LR_RestoreWeapon_T.BoolValue)
				SaveWeapons(LR_Player_Prisoner);
			else
				StripAllWeapons(LR_Player_Prisoner);
				
			if (gH_Cvar_LR_RestoreWeapon_CT.BoolValue)
				SaveWeapons(LR_Player_Guard);
			else
				StripAllWeapons(LR_Player_Guard);
			
			SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, 0, view_as<int>(Block_Global2)); // M4MroundsFired
			SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, 0, view_as<int>(Block_Global3)); // M4Mammo
			
			// grab weapon choice
			int PistolChoice;
			ResetPack(gH_BuildLR[LR_Player_Prisoner]);
			PistolChoice = ReadPackCell(gH_BuildLR[LR_Player_Prisoner]);
	
			int Pistol_Prisoner, Pistol_Guard, Prisoner_Weapon, Guard_Weapon;
			switch (PistolChoice)
			{
				case Pistol_Deagle:
				{
					Pistol_Prisoner = GivePlayerItem(LR_Player_Prisoner, "weapon_deagle");
					Pistol_Guard = GivePlayerItem(LR_Player_Guard, "weapon_deagle");
				}
				case Pistol_P228:
				{
					if (g_Game == Game_CSS)
					{
						Pistol_Prisoner = GivePlayerItem(LR_Player_Prisoner, "weapon_p228");
						Pistol_Guard = GivePlayerItem(LR_Player_Guard, "weapon_p228");
					}
					else if (g_Game == Game_CSGO)
					{
						Pistol_Prisoner = GivePlayerItem(LR_Player_Prisoner, "weapon_p250");
						Pistol_Guard = GivePlayerItem(LR_Player_Guard, "weapon_p250");
					}
				}
				case Pistol_Glock:
				{
					Pistol_Prisoner = GivePlayerItem(LR_Player_Prisoner, "weapon_glock");
					Pistol_Guard = GivePlayerItem(LR_Player_Guard, "weapon_glock");
				}
				case Pistol_FiveSeven:
				{
					Pistol_Prisoner = GivePlayerItem(LR_Player_Prisoner, "weapon_fiveseven");
					Pistol_Guard = GivePlayerItem(LR_Player_Guard, "weapon_fiveseven");
				}
				case Pistol_Dualies:
				{
					Pistol_Prisoner = GivePlayerItem(LR_Player_Prisoner, "weapon_elite");
					Pistol_Guard = GivePlayerItem(LR_Player_Guard, "weapon_elite");
				}
				case Pistol_USP:
				{
					if (g_Game == Game_CSS)
					{
						Pistol_Prisoner = GivePlayerItem(LR_Player_Prisoner, "weapon_usp");
						Pistol_Guard = GivePlayerItem(LR_Player_Guard, "weapon_usp");
					}
					else if (g_Game == Game_CSGO)
					{
						Pistol_Prisoner = GivePlayerItem(LR_Player_Prisoner, "weapon_usp_silencer");
						Pistol_Guard = GivePlayerItem(LR_Player_Guard, "weapon_usp_silencer");
					}
				}
				case Pistol_Tec9:
				{
					Pistol_Prisoner = GivePlayerItem(LR_Player_Prisoner, "weapon_tec9");
					Pistol_Guard = GivePlayerItem(LR_Player_Guard, "weapon_tec9");
				}
				case Pistol_Revolver:
				{
					Pistol_Prisoner = GivePlayerItem(LR_Player_Prisoner, "weapon_revolver");
					Pistol_Guard = GivePlayerItem(LR_Player_Guard, "weapon_revolver");
				}
				default:
				{
					LogError("hit default S4S");
					Pistol_Prisoner = GivePlayerItem(LR_Player_Prisoner, "weapon_deagle");
					Pistol_Guard = GivePlayerItem(LR_Player_Guard, "weapon_deagle");
				}
			}
			
			Prisoner_Weapon = GetEntPropEnt(LR_Player_Prisoner, Prop_Data, "m_hActiveWeapon");
			Guard_Weapon = GetEntPropEnt(LR_Player_Guard, Prop_Data, "m_hActiveWeapon");
			
			// give knives and deagles
			GivePlayerItem(LR_Player_Prisoner, "weapon_knife");
			GivePlayerItem(LR_Player_Guard, "weapon_knife");

			if(g_Game == Game_CSGO)
			{
				SetZeroAmmo(LR_Player_Guard, Guard_Weapon);
				SetZeroAmmo(LR_Player_Prisoner, Prisoner_Weapon);
			}
			
			SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, Pistol_Prisoner, view_as<int>(Block_PrisonerData));
			SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, Pistol_Guard, view_as<int>(Block_GuardData));
			
			CPrintToChatAll("%s %t", ChatBanner, "LR Mag4Mag Start", LR_Player_Prisoner, LR_Player_Guard);
			
			SetEntDataFloat(Pistol_Prisoner, g_Offset_SecAttack, 5000.0);
			SetEntDataFloat(Pistol_Guard, g_Offset_SecAttack, 5000.0);
			
			int m4mPlayerFirst = GetRandomInt(0, 1);
			if (m4mPlayerFirst == 0)
			{
				SetEntData(Pistol_Prisoner, g_Offset_Clip1, 0);
				SetEntData(Pistol_Guard, g_Offset_Clip1, gH_Cvar_LR_M4M_MagCapacity.IntValue);
				if (gH_Cvar_SendGlobalMsgs.BoolValue)
				{
					CPrintToChatAll("%s %t", ChatBanner, "Randomly Chose First Player", LR_Player_Guard);
				}
				else
				{
					CPrintToChat(LR_Player_Prisoner, "%s %t", ChatBanner, "Randomly Chose First Player", LR_Player_Guard);
					CPrintToChat(LR_Player_Guard, "%s %t", ChatBanner, "Randomly Chose First Player", LR_Player_Guard);
				}
				SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, LR_Player_Guard, view_as<int>(Block_Global1)); // S4Slastshot
			}
			else
			{
				SetEntData(Pistol_Prisoner, g_Offset_Clip1, gH_Cvar_LR_M4M_MagCapacity.IntValue);
				SetEntData(Pistol_Guard, g_Offset_Clip1, 0);			
				if (gH_Cvar_SendGlobalMsgs.BoolValue)
				{
					CPrintToChatAll("%s %t", ChatBanner, "Randomly Chose First Player", LR_Player_Prisoner);
				}
				else
				{
					CPrintToChat(LR_Player_Prisoner, "%s %t", ChatBanner, "Randomly Chose First Player", LR_Player_Prisoner);
					CPrintToChat(LR_Player_Guard, "%s %t", ChatBanner, "Randomly Chose First Player", LR_Player_Prisoner);
				}
				SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, LR_Player_Prisoner, view_as<int>(Block_Global1));
			}

			if(g_Game == Game_CSGO)
			{
				SetEntProp(Pistol_Guard, Prop_Send, "m_iPrimaryReserveAmmoCount", 0);
				SetEntProp(Pistol_Prisoner, Prop_Send, "m_iPrimaryReserveAmmoCount", 0);
			}
			else
			{
				int iAmmoType = GetEntProp(Pistol_Prisoner, Prop_Send, "m_iPrimaryAmmoType");
				SetEntData(LR_Player_Guard, g_Offset_Ammo+(iAmmoType*4), 0, _, true);
				SetEntData(LR_Player_Prisoner, g_Offset_Ammo+(iAmmoType*4), 0, _, true);
			}
		}
		case LR_Race:
		{
			if (gH_Cvar_LR_RestoreWeapon_T.BoolValue)
				SaveWeapons(LR_Player_Prisoner);
			else
				StripAllWeapons(LR_Player_Prisoner);
				
			if (gH_Cvar_LR_RestoreWeapon_CT.BoolValue)
				SaveWeapons(LR_Player_Guard);
			else
				StripAllWeapons(LR_Player_Guard);
			
			if (!gH_Cvar_NoBlock.BoolValue)
			{
				UnblockEntity(LR_Player_Prisoner, g_Offset_CollisionGroup);
				UnblockEntity(LR_Player_Guard, g_Offset_CollisionGroup);
			}
			
			SetEntityMoveType(LR_Player_Prisoner, MOVETYPE_NONE);
			SetEntityMoveType(LR_Player_Guard, MOVETYPE_NONE);
			
			//  teleport both players to the start of the race
			float f_StartLocation[3], f_EndLocation[3];
			ResetPack(gH_BuildLR[LR_Player_Prisoner]);
			f_StartLocation[0] = ReadPackFloat(gH_BuildLR[LR_Player_Prisoner]);
			f_StartLocation[1] = ReadPackFloat(gH_BuildLR[LR_Player_Prisoner]);
			f_StartLocation[2] = ReadPackFloat(gH_BuildLR[LR_Player_Prisoner]);
			f_EndLocation[0] = ReadPackFloat(gH_BuildLR[LR_Player_Prisoner]);
			f_EndLocation[1] = ReadPackFloat(gH_BuildLR[LR_Player_Prisoner]);
			f_EndLocation[2] = ReadPackFloat(gH_BuildLR[LR_Player_Prisoner]);
			Handle ThisDataPack = CreateDataPack();
			SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, ThisDataPack, 9);
			WritePackFloat(ThisDataPack, f_EndLocation[0]);
			WritePackFloat(ThisDataPack, f_EndLocation[1]);
			WritePackFloat(ThisDataPack, f_EndLocation[2]);
			
			TeleportEntity(LR_Player_Prisoner, f_StartLocation, NULL_VECTOR, view_as<float>({0.0, 0.0, 0.0}));
			TeleportEntity(LR_Player_Guard, f_StartLocation, NULL_VECTOR, view_as<float>({0.0, 0.0, 0.0}));
			
			SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, 3, view_as<int>(Block_Global1));
			// fire timer for race begin countdown
			if (g_CountdownTimer == INVALID_HANDLE)
			{
				g_CountdownTimer = CreateTimer(1.0, Timer_Countdown, iPartnersIndex, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			}
		}
		case LR_RussianRoulette:
		{
			if (gH_Cvar_LR_RestoreWeapon_T.BoolValue)
				SaveWeapons(LR_Player_Prisoner);
			else
				StripAllWeapons(LR_Player_Prisoner);
				
			if (gH_Cvar_LR_RestoreWeapon_CT.BoolValue)
				SaveWeapons(LR_Player_Guard);
			else
				StripAllWeapons(LR_Player_Guard);
			
			float p1pos[3], p2pos[3];
			GetClientAbsOrigin(LR_Player_Prisoner, p1pos);
			
			float f_PrisonerAngles[3], f_SubtractFromPrisoner[3];
			GetClientEyeAngles(LR_Player_Prisoner, f_PrisonerAngles);
			// zero out pitch/yaw
			f_PrisonerAngles[0] = 0.0;			
			GetAngleVectors(f_PrisonerAngles, f_SubtractFromPrisoner, NULL_VECTOR, NULL_VECTOR);
			float f_GuardDirection[3];
			f_GuardDirection = f_SubtractFromPrisoner;
			ScaleVector(f_SubtractFromPrisoner, -70.0);			
			MakeVectorFromPoints(f_SubtractFromPrisoner, p1pos, p2pos);

			SetEntityMoveType(LR_Player_Prisoner, MOVETYPE_NONE);
			SetEntityMoveType(LR_Player_Guard, MOVETYPE_NONE);			
			ScaleVector(f_GuardDirection, -1.0);			
			TeleportEntity(LR_Player_Guard, p2pos, f_GuardDirection, view_as<float>({0.0, 0.0, 0.0}));
			TeleportEntity(LR_Player_Prisoner, NULL_VECTOR, NULL_VECTOR, view_as<float>({0.0, 0.0, 0.0}));

			int Pistol_Prisoner = GivePlayerItem(LR_Player_Prisoner, "weapon_deagle");
			int Pistol_Guard = GivePlayerItem(LR_Player_Guard, "weapon_deagle");
			int Pistol_PrisonerEntRef = EntIndexToEntRef(Pistol_Prisoner);
			int Pistol_GuardEntRef = EntIndexToEntRef(Pistol_Guard);
			SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, Pistol_PrisonerEntRef, view_as<int>(Block_PrisonerData));
			SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, Pistol_GuardEntRef, view_as<int>(Block_GuardData));	
				
			CPrintToChatAll("%s %t", ChatBanner, "LR RR Start", LR_Player_Prisoner, LR_Player_Guard);
			
			// randomize who starts first
			if (GetRandomInt(0, 1) == 0)
			{
				SetEntData(Pistol_Prisoner, g_Offset_Clip1, 0);
				SetEntData(Pistol_Guard, g_Offset_Clip1, 1);
				if (gH_Cvar_SendGlobalMsgs.BoolValue)
				{
					CPrintToChatAll("%s %t", ChatBanner, "Randomly Chose First Player", LR_Player_Guard);
				}
				else
				{
					CPrintToChat(LR_Player_Prisoner, "%s %t", ChatBanner, "Randomly Chose First Player", LR_Player_Guard);
					CPrintToChat(LR_Player_Guard, "%s %t", ChatBanner, "Randomly Chose First Player", LR_Player_Guard);
				}
			}
			else
			{
				SetEntData(Pistol_Prisoner, g_Offset_Clip1, 1);
				SetEntData(Pistol_Guard, g_Offset_Clip1, 0);
				if (gH_Cvar_SendGlobalMsgs.BoolValue)
				{
					CPrintToChatAll("%s %t", ChatBanner, "Randomly Chose First Player", LR_Player_Prisoner);
				}
				else
				{
					CPrintToChat(LR_Player_Prisoner, "%s %t", ChatBanner, "Randomly Chose First Player", LR_Player_Prisoner);
					CPrintToChat(LR_Player_Guard, "%s %t", ChatBanner, "Randomly Chose First Player", LR_Player_Prisoner);				
				}
			}

			// set secondary ammo to 0
			if(g_Game == Game_CSGO)
			{
				SetEntProp(Pistol_Guard, Prop_Send, "m_iPrimaryReserveAmmoCount", 0);
				SetEntProp(Pistol_Prisoner, Prop_Send, "m_iPrimaryReserveAmmoCount", 0);
			}
			else
			{
				int iAmmoType = GetEntProp(Pistol_Prisoner, Prop_Send, "m_iPrimaryAmmoType");
				SetEntData(LR_Player_Guard, g_Offset_Ammo+(iAmmoType*4), 0, _, true);
				SetEntData(LR_Player_Prisoner, g_Offset_Ammo+(iAmmoType*4), 0, _, true);
			}	
		}
		case LR_JumpContest:
		{
			if (gH_Cvar_LR_RestoreWeapon_T.BoolValue)
				SaveWeapons(LR_Player_Prisoner);
			else
				StripAllWeapons(LR_Player_Prisoner);
				
			if (gH_Cvar_LR_RestoreWeapon_CT.BoolValue)
				SaveWeapons(LR_Player_Guard);
			else
				StripAllWeapons(LR_Player_Guard);
			
			int JumpChoice;
			ResetPack(gH_BuildLR[LR_Player_Prisoner]);
			JumpChoice = ReadPackCell(gH_BuildLR[LR_Player_Prisoner]);
			SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, JumpChoice, view_as<int>(Block_Global2));

			UnblockEntity(LR_Player_Prisoner, g_Offset_CollisionGroup);
			UnblockEntity(LR_Player_Guard, g_Offset_CollisionGroup);

			switch (JumpChoice)
			{
				case Jump_TheMost:
				{
					// reset jump counts
					SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, 0, view_as<int>(Block_PrisonerData));
					SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, 0, view_as<int>(Block_GuardData));
					// set countdown timer
					SetArrayCell(gH_DArray_LR_Partners, iPartnersIndex, 3, view_as<int>(Block_Global1));
					
					if (g_CountdownTimer == INVALID_HANDLE)
					{
						g_CountdownTimer = CreateTimer(1.0, Timer_Countdown, iPartnersIndex, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
					}
					
					CPrintToChatAll("%s %t", ChatBanner, "Start Jump Contest", LR_Player_Prisoner, LR_Player_Guard);
					
					float Prisoner_Position[3];
					GetClientAbsOrigin(LR_Player_Prisoner, Prisoner_Position);
					TeleportEntity(LR_Player_Guard, Prisoner_Position, NULL_VECTOR, NULL_VECTOR);
				}
				case Jump_Farthest:
				{
					Before_Jump_pos[LR_Player_Guard][0] = 0.0;
					Before_Jump_pos[LR_Player_Guard][1] = 0.0;
					Before_Jump_pos[LR_Player_Guard][2] = 0.0;
					Before_Jump_pos[LR_Player_Prisoner][0] = 0.0;
					Before_Jump_pos[LR_Player_Prisoner][1] = 0.0;
					Before_Jump_pos[LR_Player_Prisoner][2] = 0.0;
					
					After_Jump_pos[LR_Player_Guard][0] = 0.0;
					After_Jump_pos[LR_Player_Guard][1] = 0.0;
					After_Jump_pos[LR_Player_Guard][2] = 0.0;
					After_Jump_pos[LR_Player_Prisoner][0] = 0.0;
					After_Jump_pos[LR_Player_Prisoner][1] = 0.0;
					After_Jump_pos[LR_Player_Prisoner][2] = 0.0;
					
					LR_Player_Jumped[LR_Player_Guard] = false;
					LR_Player_Jumped[LR_Player_Prisoner] = false;
					
					LR_Player_Landed[LR_Player_Guard] = false;
					LR_Player_Landed[LR_Player_Prisoner] = false;			
					
					CPrintToChatAll("%s %t", ChatBanner, "Start Farthest Jump", LR_Player_Prisoner, LR_Player_Guard);
					
					// start detection timer
					if (g_FarthestJumpTimer == INVALID_HANDLE)
					{
						g_FarthestJumpTimer = CreateTimer(0.1, Timer_FarthestJumpDetector, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
					}		
				}
				case Jump_BrinkOfDeath:
				{
					float Prisoner_Position[3];
					GetClientAbsOrigin(LR_Player_Prisoner, Prisoner_Position);
					TeleportEntity(LR_Player_Guard, Prisoner_Position, NULL_VECTOR, NULL_VECTOR);
					
					UnblockEntity(LR_Player_Guard, g_Offset_CollisionGroup);
					UnblockEntity(LR_Player_Prisoner, g_Offset_CollisionGroup);
					
					CPrintToChatAll("%s %t", ChatBanner, "Start Brink of Death", LR_Player_Prisoner, LR_Player_Guard);
					
					// timer to quit the LR
					CreateTimer(22.0, Timer_JumpContestOver, _, TIMER_FLAG_NO_MAPCHANGE);
				}
			}
		}
		default:
		{
			Call_StartForward(gH_Frwd_LR_Start);
			Call_PushCell(gH_DArray_LR_Partners);
			Call_PushCell(iPartnersIndex);
			int ignore;
			Call_Finish(view_as<int>(ignore));
			
			if(!IsLastRequestAutoStart(selection))
			{
				g_LR_Player_Guard[LR_Player_Prisoner] = LR_Player_Guard;
				g_selection[LR_Player_Prisoner] = selection;
				
				RemoveFromArray(gH_DArray_LR_Partners, iPartnersIndex);
			}
		}
	}
	
	CreateTimer(0.3, Timer_StripZeus, LR_Player_Prisoner, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer(0.3, Timer_StripZeus, LR_Player_Guard, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	
	if(IsLastRequestAutoStart(selection))
	{
		// Fire global
		Call_StartForward(gH_Frwd_LR_StartGlobal);
		Call_PushCell(LR_Player_Prisoner);
		Call_PushCell(LR_Player_Guard);
		// LR type
		Call_PushCell(selection);
		int ignore;
		Call_Finish(view_as<int>(ignore));
		
		// Close datapack
		if (gH_BuildLR[LR_Player_Prisoner] != null)
		{
			CloseHandle(gH_BuildLR[LR_Player_Prisoner]);		
		}
		gH_BuildLR[LR_Player_Prisoner] = null;
		
		
		if (IsClientInGame(LR_Player_Prisoner) && IsPlayerAlive(LR_Player_Prisoner))
		{
			if (selection != LR_Rebel && (selection == LR_ChickenFight || selection == LR_Dodgeball || selection == LR_GunToss ||
				selection == LR_HotPotato || selection == LR_JumpContest || selection == LR_KnifeFight || selection == LR_Mag4Mag ||
				selection == LR_NoScope || selection == LR_Race || selection == LR_Shot4Shot))
			{
				SetEntityHealth(LR_Player_Prisoner, 100);
			
				SetEntProp(LR_Player_Prisoner, Prop_Send, "m_bHasHelmet", 0);
				SetEntProp(LR_Player_Prisoner, Prop_Send, "m_ArmorValue", 0, 0);
				
				if(g_Game == Game_CSGO)
				{
					RemoveDangerZone(LR_Player_Prisoner);
				
					SetEntProp(LR_Player_Prisoner, Prop_Send, "m_bHasHeavyArmor", 0);
					SetEntProp(LR_Player_Prisoner, Prop_Send, "m_bWearingSuit", 0);
				}
			}
		}
		
		if (IsClientInGame(LR_Player_Guard) && IsPlayerAlive(LR_Player_Guard))
		{
			if (selection != LR_Rebel && (selection == LR_ChickenFight || selection == LR_Dodgeball || selection == LR_GunToss ||
				selection == LR_HotPotato || selection == LR_JumpContest || selection == LR_KnifeFight || selection == LR_Mag4Mag ||
				selection == LR_NoScope || selection == LR_Race || selection == LR_Shot4Shot))
			{
				SetEntityHealth(LR_Player_Guard, 100);
			
				SetEntProp(LR_Player_Guard, Prop_Send, "m_bHasHelmet", 0);
				SetEntProp(LR_Player_Guard, Prop_Send, "m_ArmorValue", 0, 0);
				
				if(g_Game == Game_CSGO)
				{
					RemoveDangerZone(LR_Player_Guard);
				
					SetEntProp(LR_Player_Guard, Prop_Send, "m_bHasHeavyArmor", 0);
					SetEntProp(LR_Player_Guard, Prop_Send, "m_bWearingSuit", 0);
				}
			}
		}
	}
}

public Action Timer_FarthestJumpDetector(Handle timer)
{
	int iArraySize = GetArraySize(gH_DArray_LR_Partners);
	if (iArraySize > 0)
	{
		for (int idx = 0; idx < GetArraySize(gH_DArray_LR_Partners); idx++)
		{
			LastRequest type = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_LRType));
			if (type == LR_JumpContest)
			{
				JumpContest subType = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Global2));
				if (subType == Jump_Farthest)
				{								
					int LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Prisoner));
					int LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Guard));					

					if (LR_Player_Jumped[LR_Player_Prisoner] && (GetEntityFlags(LR_Player_Prisoner) & FL_ONGROUND) && !LR_Player_Landed[LR_Player_Prisoner])
					{
						SetEntityMoveType(LR_Player_Prisoner, MOVETYPE_NONE);
						LR_Player_Landed[LR_Player_Prisoner] = true;
						
						GetClientAbsOrigin(LR_Player_Prisoner, After_Jump_pos[LR_Player_Prisoner]);
						
						CreateTimer(10.0, Timer_EnemyMustJump, TIMER_FLAG_NO_MAPCHANGE);
						CPrintToChat(LR_Player_Guard, "%s %t", ChatBanner, "JF Jump Warning");
					}
					
					if (LR_Player_Jumped[LR_Player_Guard] && (GetEntityFlags(LR_Player_Guard) & FL_ONGROUND) && !LR_Player_Landed[LR_Player_Guard])
					{
						SetEntityMoveType(LR_Player_Guard, MOVETYPE_NONE);
						LR_Player_Landed[LR_Player_Guard] = true;
						
						GetClientAbsOrigin(LR_Player_Guard, After_Jump_pos[LR_Player_Guard]);
						
						CreateTimer(10.0, Timer_EnemyMustJump, TIMER_FLAG_NO_MAPCHANGE);
						CPrintToChat(LR_Player_Prisoner, "%s %t", ChatBanner, "JF Jump Warning");
					}
					
					if (LR_Player_Landed[LR_Player_Prisoner] && LR_Player_Landed[LR_Player_Guard])
					{
						float Prisoner_Distance = GetVectorDistance(Before_Jump_pos[LR_Player_Prisoner], After_Jump_pos[LR_Player_Prisoner]);
						float Guard_Distance = GetVectorDistance(Before_Jump_pos[LR_Player_Guard], After_Jump_pos[LR_Player_Guard]);
						
						if (Prisoner_Distance > Guard_Distance)
						{
							CPrintToChatAll("%s %t", ChatBanner, "Farthest Jump Won", LR_Player_Prisoner, LR_Player_Guard, Prisoner_Distance, Guard_Distance);
							KillAndReward(LR_Player_Guard, LR_Player_Prisoner);
						}
						
						else if (Guard_Distance >= Prisoner_Distance)
						{
							CPrintToChatAll("%s %t", ChatBanner, "Farthest Jump Won", LR_Player_Guard, LR_Player_Prisoner, Guard_Distance, Prisoner_Distance);
							KillAndReward(LR_Player_Prisoner, LR_Player_Guard);
						}	
					}
				}
			}
		}
	}
	else
	{
		g_FarthestJumpTimer = INVALID_HANDLE;
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public Action Timer_EnemyMustJump(Handle timer)
{
	int iArraySize = GetArraySize(gH_DArray_LR_Partners);
	if (iArraySize > 0)
	{
		for (int idx = 0; idx < GetArraySize(gH_DArray_LR_Partners); idx++)
		{		
			LastRequest type = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_LRType));
			if (type == LR_JumpContest)
			{
				int jumptype = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Global2));
				int LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Prisoner));
				int LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Guard));					
				switch (jumptype)
				{
					case Jump_Farthest:
					{
						if (LR_Player_Jumped[LR_Player_Prisoner] && !LR_Player_Jumped[LR_Player_Guard])
						{
							KillAndReward(LR_Player_Guard, LR_Player_Prisoner);
							CPrintToChatAll("%s %t", ChatBanner, "JF No Jump", LR_Player_Prisoner, LR_Player_Guard);
						}
						else if (!LR_Player_Jumped[LR_Player_Prisoner] && LR_Player_Jumped[LR_Player_Guard])
						{
							KillAndReward(LR_Player_Prisoner, LR_Player_Guard);
							CPrintToChatAll("%s %t", ChatBanner, "JF No Jump", LR_Player_Guard, LR_Player_Prisoner);
						}
					}
				}
			}
		}
	}
	return Plugin_Stop;
}

public Action Timer_JumpContestOver(Handle timer)
{
	int iArraySize = GetArraySize(gH_DArray_LR_Partners);
	if (iArraySize > 0)
	{
		for (int idx = 0; idx < GetArraySize(gH_DArray_LR_Partners); idx++)
		{		
			LastRequest type = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_LRType));
			if (type == LR_JumpContest)
			{
				int jumptype = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Global2));
				int LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Prisoner));
				int LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Guard));					
				switch (jumptype)
				{
					case Jump_TheMost:
					{						
						int Guard_JumpCount = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_GuardData));
						int Prisoner_JumpCount = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_PrisonerData));
						
						if (Prisoner_JumpCount > Guard_JumpCount)
						{
							CPrintToChatAll("%s %t", ChatBanner, "Won Jump Contest", LR_Player_Prisoner);
							KillAndReward(LR_Player_Guard, LR_Player_Prisoner);
						}
						else
						{
							CPrintToChatAll("%s %t", ChatBanner, "Won Jump Contest", LR_Player_Guard);
							KillAndReward(LR_Player_Prisoner, LR_Player_Guard);
						}
					}
					case Jump_BrinkOfDeath:
					{
						int Prisoner_Health = GetClientHealth(LR_Player_Prisoner);
						int Guard_Health = GetClientHealth(LR_Player_Guard);
						
						int loser = (Prisoner_Health > Guard_Health) ? LR_Player_Prisoner : LR_Player_Guard;
						int winner = (Prisoner_Health > Guard_Health) ? LR_Player_Guard : LR_Player_Prisoner;
						
						// TODO *** consider adding this as an option (random or abort)
						if (Prisoner_Health == Guard_Health)
						{
							int random = GetRandomInt(0,1);
							winner = (random) ? LR_Player_Prisoner : LR_Player_Guard;
							loser = (random) ? LR_Player_Guard : LR_Player_Prisoner;
						}
						
						KillAndReward(loser, winner);
						
						if (IsPlayerAlive(winner))
						{
							SetEntityHealth(winner, 100);
							if (!gH_Cvar_NoBlock.BoolValue)
							{
								BlockEntity(winner, g_Offset_CollisionGroup);
							}
						}						
						
						CPrintToChatAll("%s %t", ChatBanner, "Won Jump Contest", winner);
					}
				}
			}
		}
	}	
}

public Action Timer_Beacon(Handle timer)
{
	int iNumOfBeacons = GetArraySize(gH_DArray_Beacons);
	if (iNumOfBeacons <= 0)
	{
		g_BeaconTimer = null; // TODO: Remove this because it doesn't make sense?
		return Plugin_Stop;
	}
	static int iTimerCount = 1;
	if (iTimerCount > 99999)
	{
		iTimerCount = 1;
	}
	iTimerCount++;
	
	if (gH_Cvar_LR_HelpBeams.BoolValue)
	{
		for (int LRindex = 0; LRindex < GetArraySize(gH_DArray_LR_Partners); LRindex++)
		{
			LastRequest type = GetArrayCell(gH_DArray_LR_Partners, LRindex, view_as<int>(Block_LRType));
			
			if (type != LR_Rebel)
			{
				int LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, LRindex, view_as<int>(Block_Prisoner));
				int LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, LRindex, view_as<int>(Block_Guard));
				
				int clients[2];
				clients[0] = LR_Player_Prisoner;
				clients[1] = LR_Player_Guard;
				
				// setup beam
				float Prisoner_Pos[3], Guard_Pos[3], distance;
				GetClientEyePosition(LR_Player_Prisoner, Prisoner_Pos);
				Prisoner_Pos[2] -= 40.0;
				GetClientEyePosition(LR_Player_Guard, Guard_Pos);
				Guard_Pos[2] -= 40.0;
				distance = GetVectorDistance(Prisoner_Pos, Guard_Pos);
				
				if (distance > gH_Cvar_LR_HelpBeams_Distance.FloatValue)
				{
					TE_SetupBeamPoints(Prisoner_Pos, Guard_Pos, LaserSprite, LaserHalo, 1, 1, 0.1, 5.0, 5.0, 0, 10.0, greyColor, 255);			
					TE_Send(clients, 2);
					TE_SetupBeamPoints(Guard_Pos, Prisoner_Pos, LaserSprite, LaserHalo, 1, 1, 0.1, 5.0, 5.0, 0, 10.0, greyColor, 255);			
					TE_Send(clients, 2);
				}
			}
		}
	}
	int modTime = RoundToCeil(10.0 * gH_Cvar_LR_Beacon_Interval.FloatValue);
	if ((iTimerCount % modTime) == 0)
	{
		int iEntityIndex;
		for (int idx = 0; idx < iNumOfBeacons; idx++)
		{
			iEntityIndex = GetArrayCell(gH_DArray_Beacons, idx);
			if (IsValidEntity(iEntityIndex))
			{
				float f_Origin[3];
				GetEntPropVector(iEntityIndex, Prop_Data, "m_vecOrigin", f_Origin);
				f_Origin[2] += 10.0;
				TE_SetupBeamRingPoint(f_Origin, 10.0, 375.0, BeamSprite, HaloSprite, 0, 15, 0.5, 5.0, 0.0, greyColor, 10, 0);
				TE_SendToAll();
				// check if it's a weapon or player
				if (iEntityIndex < MaxClients+1)
				{
					int team = GetClientTeam(iEntityIndex);
					if (team == CS_TEAM_T)
					{
						TE_SetupBeamRingPoint(f_Origin, 10.0, 375.0, BeamSprite, HaloSprite, 0, 10, 0.6, 10.0, 0.5, redColor, 10, 0);
						TE_SendToAll();
					}
					else if (team == CS_TEAM_CT)
					{
						TE_SetupBeamRingPoint(f_Origin, 10.0, 375.0, BeamSprite, HaloSprite, 0, 10, 0.6, 10.0, 0.5, blueColor, 10, 0);
						TE_SendToAll();
					}
				}
				else
				{
					TE_SetupBeamRingPoint(f_Origin, 10.0, 375.0, BeamSprite, HaloSprite, 0, 10, 0.6, 10.0, 0.5, yellowColor, 10, 0);
					TE_SendToAll();
				}
				char buffer[PLATFORM_MAX_PATH];
				gH_Cvar_LR_Beacon_Sound.GetString(buffer, sizeof(buffer));
				EmitAmbientSoundAny(buffer, f_Origin, iEntityIndex, SNDLEVEL_RAIDSIREN);	
			}
			else
			{
				RemoveFromArray(gH_DArray_Beacons, idx);
			}
		}
	}
	
	return Plugin_Continue;
}

void AddBeacon(int entityIndex)
{
	if (IsValidEntity(entityIndex))
	{
		PushArrayCell(gH_DArray_Beacons, entityIndex);
	}
	if (g_BeaconTimer == null)
	{
		g_BeaconTimer = CreateTimer(0.1, Timer_Beacon, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}
}

void RemoveBeacon(int entityIndex)
{
	int iBeaconIndex = FindValueInArray(gH_DArray_Beacons, entityIndex);
	if (iBeaconIndex != -1)
	{
		RemoveFromArray(gH_DArray_Beacons, iBeaconIndex);
	}
}

public void OnEntityCreated(int entity, const char[] classname)
{
	int iArraySize = GetArraySize(gH_DArray_LR_Partners);
	bool bIsDodgeball = false;
	if (iArraySize > 0)
	{
		for (int idx = 0; idx < GetArraySize(gH_DArray_LR_Partners); idx++)
		{
			LastRequest type = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_LRType));
			if (type == LR_Dodgeball)
			{
				bIsDodgeball = true;
			}
		}
	}
	if (bIsDodgeball && StrEqual(classname, "flashbang_projectile"))
	{
		SDKHook(entity, SDKHook_Spawn, OnEntitySpawned);
	}
}

public void OnEntitySpawned(int entity)
{
	int client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	int iArraySize = GetArraySize(gH_DArray_LR_Partners);
	if (iArraySize > 0)
	{
		for (int idx = 0; idx < GetArraySize(gH_DArray_LR_Partners); idx++)
		{
			int LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Prisoner));
			int LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Guard));
			
			if (client == LR_Player_Prisoner || client == LR_Player_Guard)
			{
				CreateTimer(0.0, Timer_RemoveThinkTick, entity, TIMER_FLAG_NO_MAPCHANGE);
			}
		}
	}
}

public Action Timer_RemoveThinkTick(Handle timer, any entity)
{
	SetEntProp(entity, Prop_Data, "m_nNextThinkTick", -1);
	CreateTimer(gH_Cvar_LR_Dodgeball_SpawnTime.FloatValue, Timer_RemoveFlashbang, entity, TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_RemoveFlashbang(Handle timer, any entity)
{
	if (IsValidEntity(entity))
	{
		int client = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity");
		AcceptEntityInput(entity, "Kill");
		
		if ((client != -1) && IsClientInGame(client) && IsPlayerAlive(client) && Local_IsClientInLR(client))
		{
			GivePlayerItem(client, "weapon_flashbang");
		}
	}
}

public Action Timer_Countdown(Handle timer)
{
	int iArraySize = GetArraySize(gH_DArray_LR_Partners);
	if (iArraySize == 0)
	{
		g_CountdownTimer = null; // TODO: Remove this because it doesn't make sense?
		return Plugin_Stop;
	}
	
	bool bCountdownUsed = false;
	
	for (int idx = 0; idx < GetArraySize(gH_DArray_LR_Partners); idx++)
	{
		LastRequest type = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_LRType));
		
		if (type != LR_Race && type != LR_NoScope && type != LR_JumpContest)
		{
			continue;
		}
		
		int LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Prisoner));
		int LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Guard));
		int countdown = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Global1));
		if (countdown > 0)
		{
			bCountdownUsed = true;
			PrintCenterText(LR_Player_Prisoner, "LR begins in %i...", countdown);
			PrintCenterText(LR_Player_Guard, "LR begins in %i...", countdown);
			SetArrayCell(gH_DArray_LR_Partners, idx, --countdown, view_as<int>(Block_Global1));
			
			// set up laser beams for race points
			if (type == LR_Race && gH_Cvar_LR_Race_NotifyCTs.BoolValue)
			{
				float LR_Prisoner_Position[3], f_EndLocation[3];
				Handle PositionPack = GetArrayCell(gH_DArray_LR_Partners, idx, 9);
				ResetPack(PositionPack);
				f_EndLocation[0] = ReadPackFloat(PositionPack);
				f_EndLocation[1] = ReadPackFloat(PositionPack);
				f_EndLocation[2] = ReadPackFloat(PositionPack);
				GetClientAbsOrigin(LR_Player_Prisoner, LR_Prisoner_Position);
				
				int clients[2];
				clients[0] = LR_Player_Prisoner;
				clients[1] = LR_Player_Guard;
				
				TE_SetupBeamPoints(f_EndLocation, LR_Prisoner_Position, LaserSprite, LaserHalo, 1, 1, 1.1, 5.0, 5.0, 0, 10.0, redColor, 200);			
				TE_Send(clients, 2);
				TE_SetupBeamPoints(LR_Prisoner_Position, f_EndLocation, LaserSprite, LaserHalo, 1, 1, 1.1, 5.0, 5.0, 0, 10.0, redColor, 200);			
				TE_Send(clients, 2);
			}
		}
		else if (countdown == 0)
		{
			bCountdownUsed = true;
			SetArrayCell(gH_DArray_LR_Partners, idx, --countdown, view_as<int>(Block_Global1));	
			switch (type)
			{
				case LR_Race:
				{
					SetEntityMoveType(LR_Player_Prisoner, MOVETYPE_WALK);
					SetEntityMoveType(LR_Player_Guard, MOVETYPE_WALK);
					
					UnblockEntity(LR_Player_Guard, g_Offset_CollisionGroup);
					UnblockEntity(LR_Player_Prisoner, g_Offset_CollisionGroup);
					
					// make timer to check the race winner
					if (g_RaceTimer == null)
					{
						g_RaceTimer = CreateTimer(0.1, Timer_Race, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
					}			
				}
				case LR_NoScope:
				{
					StripAllWeapons(LR_Player_Prisoner);
					StripAllWeapons(LR_Player_Guard);
					
					if (g_Game == Game_CSGO)
					{
						RemoveDangerZone(LR_Player_Prisoner);
						RemoveDangerZone(LR_Player_Guard);
					}
					
					// grab weapon choice
					NoScopeWeapon NS_Selection;
					NS_Selection = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Global2));					
					int NSW_Prisoner, NSW_Guard;
					switch (NS_Selection)
					{
						case NSW_AWP:
						{
							NSW_Prisoner = GivePlayerItem(LR_Player_Prisoner, "weapon_awp");
							NSW_Guard = GivePlayerItem(LR_Player_Guard, "weapon_awp");
						}
						case NSW_Scout:
						{
							if(g_Game == Game_CSS)
							{
								NSW_Prisoner = GivePlayerItem(LR_Player_Prisoner, "weapon_scout");
								NSW_Guard = GivePlayerItem(LR_Player_Guard, "weapon_scout");
							}
							else if(g_Game == Game_CSGO)
							{
								NSW_Prisoner = GivePlayerItem(LR_Player_Prisoner, "weapon_ssg08");
								NSW_Guard = GivePlayerItem(LR_Player_Guard, "weapon_ssg08");
							}
						}
						case NSW_SG550:
						{
							if(g_Game == Game_CSS)
							{
								NSW_Prisoner = GivePlayerItem(LR_Player_Prisoner, "weapon_sg550");
								NSW_Guard = GivePlayerItem(LR_Player_Guard, "weapon_sg550");
							}
							else if(g_Game == Game_CSGO)
							{
								NSW_Prisoner = GivePlayerItem(LR_Player_Prisoner, "weapon_scar20");
								NSW_Guard = GivePlayerItem(LR_Player_Guard, "weapon_scar20");
							}
						}
						case NSW_G3SG1:
						{
							NSW_Prisoner = GivePlayerItem(LR_Player_Prisoner, "weapon_g3sg1");
							NSW_Guard = GivePlayerItem(LR_Player_Guard, "weapon_g3sg1");
						}
						default:
						{
							LogError("hit default NS");
							NSW_Prisoner = GivePlayerItem(LR_Player_Prisoner, "weapon_awp");
							NSW_Guard = GivePlayerItem(LR_Player_Guard, "weapon_awp");
						}
					}

					SetEntPropEnt(LR_Player_Prisoner, Prop_Send, "m_hActiveWeapon", NSW_Prisoner);
					SetEntPropEnt(LR_Player_Guard, Prop_Send, "m_hActiveWeapon", NSW_Guard);
					SetEntData(NSW_Prisoner, g_Offset_Clip1, 99);
					SetEntData(NSW_Guard, g_Offset_Clip1, 99);
					
					// place delay on zoom
					SetEntDataFloat(NSW_Prisoner, g_Offset_SecAttack, 5000.0);
					SetEntDataFloat(NSW_Guard, g_Offset_SecAttack, 5000.0);
					
					char buffer[PLATFORM_MAX_PATH];
					gH_Cvar_LR_NoScope_Sound.GetString(buffer, sizeof(buffer));
					if ((strlen(buffer) > 0) && !StrEqual(buffer, "-1"))
					{
						if (g_Game == Game_CSS)
						{
							EmitSoundToAll(buffer);
						}
						else
						{
							char sCommand[PLATFORM_MAX_PATH];
							for (int idx2 = 1; idx2 <= MaxClients; idx2++)
							{
								if (IsClientInGame(idx2))
								{
									Format(sCommand, sizeof(sCommand), "play *%s", buffer);
									ClientCommand(idx2, sCommand);
								}
							}
						}
					}
				}
				case LR_JumpContest:
				{
					CreateTimer(13.0, Timer_JumpContestOver, _, TIMER_FLAG_NO_MAPCHANGE);			
				}
			}
		}
	}
	if (bCountdownUsed == false)
	{
		g_CountdownTimer = null;
		return Plugin_Stop;
	}

	return Plugin_Continue;
}

public Action Timer_Race(Handle timer)
{
	int iArraySize = GetArraySize(gH_DArray_LR_Partners);
	bool bIsRace = false;
	if (iArraySize > 0)
	{
		for (int idx = 0; idx < GetArraySize(gH_DArray_LR_Partners); idx++)
		{	
			LastRequest type = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_LRType));
			if (type == LR_Race)
			{
				bIsRace = true;
				int LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Prisoner));
				int LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Guard));
				
				float LR_Prisoner_Position[3], LR_Guard_Position[3], f_EndLocation[3];
				Handle PositionPack = GetArrayCell(gH_DArray_LR_Partners, idx, 9);
				ResetPack(PositionPack);
				f_EndLocation[0] = ReadPackFloat(PositionPack);
				f_EndLocation[1] = ReadPackFloat(PositionPack);
				f_EndLocation[2] = ReadPackFloat(PositionPack);
				GetClientAbsOrigin(LR_Player_Prisoner, LR_Prisoner_Position);
				GetClientAbsOrigin(LR_Player_Guard, LR_Guard_Position);
				// check how close they are to the end point
				f_DoneDistance[LR_Player_Prisoner] = GetVectorDistance(LR_Prisoner_Position, f_EndLocation, false);
				f_DoneDistance[LR_Player_Guard] = GetVectorDistance(LR_Guard_Position, f_EndLocation, false);
				
				if (f_DoneDistance[LR_Player_Prisoner] < 75.0 || f_DoneDistance[LR_Player_Guard] < 75.0)
				{
					if (f_DoneDistance[LR_Player_Prisoner] < f_DoneDistance[LR_Player_Guard])
					{
						KillAndReward(LR_Player_Guard, LR_Player_Prisoner);
						CPrintToChatAll("%s %t", ChatBanner, "Race Won", LR_Player_Prisoner);
					}
					else
					{
						KillAndReward(LR_Player_Prisoner, LR_Player_Guard);
						CPrintToChatAll("%s %t", ChatBanner, "Race Won", LR_Player_Guard);
					}
				}
				
				// update end location beam
				TE_SetupBeamRingPoint(f_EndLocation, 100.0, 110.0, BeamSprite, HaloSprite, 0, 15, 0.2, 7.0, 1.0, greenColor, 1, 0);
				TE_SendToAll();					
			}
		}
	}
	if (!bIsRace)
	{
		g_RaceTimer = INVALID_HANDLE;
		return Plugin_Stop;
	}

	return Plugin_Continue;
}

public int RPSmenuHandler(Handle menu, MenuAction action, int client, int param2)
{
	if (action == MenuAction_Select)
	{
		// find out which LR this is for
		for (int idx = 0; idx < GetArraySize(gH_DArray_LR_Partners); idx++)
		{
			LastRequest type = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_LRType));
			if (type == LR_RockPaperScissors)
			{
				int LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Prisoner));
				int LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Guard));	
				if (client == LR_Player_Prisoner || client == LR_Player_Guard)
				{
					int RPS_Prisoner_Choice = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Global1));
					int RPS_Guard_Choice = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Global2));
					
					if (client == LR_Player_Prisoner)
					{
						RPS_Prisoner_Choice = param2;
						SetArrayCell(gH_DArray_LR_Partners, idx, RPS_Prisoner_Choice, 5);
					}
					else if (client == LR_Player_Guard)
					{
						RPS_Guard_Choice = param2;
						SetArrayCell(gH_DArray_LR_Partners, idx, RPS_Guard_Choice, view_as<int>(Block_Global2));
					}
					
					if ((RPS_Guard_Choice != -1) && (RPS_Prisoner_Choice != -1))
					{
						// decide who wins -- rock 0 paper 1 scissors 2
						char RPSr[64], RPSp[64], RPSs[64], RPSc1[64], RPSc2[64];
						Format(RPSr, sizeof(RPSr), "%T", "Rock", LR_Player_Prisoner);
						Format(RPSp, sizeof(RPSp), "%T", "Paper", LR_Player_Prisoner);
						Format(RPSs, sizeof(RPSs), "%T", "Scissors", LR_Player_Prisoner);
		
						switch (RPS_Prisoner_Choice)
						{
							case 0:
							{
								strcopy(RPSc1, sizeof(RPSc1), RPSr);
							}
							case 1:
							{
								strcopy(RPSc1, sizeof(RPSc1), RPSp);
							}
							case 2:
							{
								strcopy(RPSc1, sizeof(RPSc1), RPSs);
							}
						}
						switch (RPS_Guard_Choice)
						{
							case 0:
							{
								strcopy(RPSc2, sizeof(RPSc2), RPSr);
							}
							case 1:
							{
								strcopy(RPSc2, sizeof(RPSc2), RPSp);
							}
							case 2:
							{
								strcopy(RPSc2, sizeof(RPSc2), RPSs);
							}
						}
		
						if (RPS_Prisoner_Choice == RPS_Guard_Choice) // tie
						{
							if (client == LR_Player_Prisoner)
							{
								if (gH_Cvar_SendGlobalMsgs.BoolValue)
								{
									CPrintToChatAll("%s %t", ChatBanner, "LR RPS Tie", LR_Player_Prisoner, RPSc2, LR_Player_Guard, RPSc1);
								}
								else
								{
									CPrintToChat(LR_Player_Prisoner, "%s %t", ChatBanner, "LR RPS Tie", LR_Player_Prisoner, RPSc2, LR_Player_Guard, RPSc1);
									CPrintToChat(LR_Player_Guard, "%s %t", ChatBanner, "LR RPS Tie", LR_Player_Prisoner, RPSc2, LR_Player_Guard, RPSc1);
								}
							}
							else
							{
								if (gH_Cvar_SendGlobalMsgs.BoolValue)
								{
									CPrintToChatAll("%s %t", ChatBanner, "LR RPS Tie", LR_Player_Guard, RPSc1, LR_Player_Prisoner, RPSc2);
								}
								else
								{
									CPrintToChat(LR_Player_Guard, "%s %t", ChatBanner, "LR RPS Tie", LR_Player_Guard, RPSc1, LR_Player_Prisoner, RPSc2);
									CPrintToChat(LR_Player_Prisoner, "%s %t", ChatBanner, "LR RPS Tie", LR_Player_Guard, RPSc1, LR_Player_Prisoner, RPSc2);
								}
							}
							
							// redo menu
							SetArrayCell(gH_DArray_LR_Partners, idx, -1, view_as<int>(Block_Global1));
							SetArrayCell(gH_DArray_LR_Partners, idx, -1, view_as<int>(Block_Global2));
							Handle rpsmenu1 = CreateMenu(RPSmenuHandler);
							SetMenuTitle(rpsmenu1, "%T", "Rock Paper Scissors", LR_Player_Prisoner);
							SetArrayCell(gH_DArray_LR_Partners, idx, rpsmenu1, view_as<int>(Block_PrisonerData));
				
							char r1[32], p1[64], s1[64];
							Format(r1, sizeof(r1), "%T", "Rock", LR_Player_Prisoner);
							Format(p1, sizeof(p1), "%T", "Paper", LR_Player_Prisoner);
							Format(s1, sizeof(s1), "%T", "Scissors", LR_Player_Prisoner);
							AddMenuItem(rpsmenu1, "0", r1);
							AddMenuItem(rpsmenu1, "1", p1);
							AddMenuItem(rpsmenu1, "2", s1);
				
							SetMenuExitButton(rpsmenu1, true);
							DisplayMenu(rpsmenu1, LR_Player_Prisoner, 15);
				
							Handle rpsmenu2 = CreateMenu(RPSmenuHandler);
							SetMenuTitle(rpsmenu2, "%T", "Rock Paper Scissors", LR_Player_Guard);
							SetArrayCell(gH_DArray_LR_Partners, idx, rpsmenu2, view_as<int>(Block_GuardData));
				
							char r2[32], p2[64], s2[64];
							Format(r2, sizeof(r2), "%T", "Rock", LR_Player_Guard);
							Format(p2, sizeof(p2), "%T", "Paper", LR_Player_Guard);
							Format(s2, sizeof(s2), "%T", "Scissors", LR_Player_Guard);
							AddMenuItem(rpsmenu2, "0", r2);
							AddMenuItem(rpsmenu2, "1", p2);
							AddMenuItem(rpsmenu2, "2", s2);
				
							SetMenuExitButton(rpsmenu2, true);
							DisplayMenu(rpsmenu2, LR_Player_Guard, 15);
						}
						// if THIS player has won
						else if ((RPS_Guard_Choice == 0 && RPS_Prisoner_Choice == 2) || (RPS_Guard_Choice == 1 && RPS_Prisoner_Choice == 0) || (RPS_Guard_Choice == 2 && RPS_Prisoner_Choice == 1))
						{
							KillAndReward(LR_Player_Prisoner, LR_Player_Guard);
							CPrintToChatAll("%s %t", ChatBanner, "LR RPS Done", LR_Player_Prisoner, RPSc1, LR_Player_Guard, RPSc2, LR_Player_Guard);
						}
						// otherwise THIS player has lost
						else
						{
							KillAndReward(LR_Player_Guard, LR_Player_Prisoner);
							CPrintToChatAll("%s %t", ChatBanner, "LR RPS Done", LR_Player_Prisoner, RPSc1, LR_Player_Guard, RPSc2, LR_Player_Prisoner);
						}				
					}				
				}		
			}			
		}

	}
	else if (action == MenuAction_Cancel)
	{
		for (int idx = 0; idx < GetArraySize(gH_DArray_LR_Partners); idx++)
		{
			LastRequest type = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_LRType));
			if (type == LR_RockPaperScissors)
			{
				int LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Prisoner));
				int LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Guard));	
				if (client == LR_Player_Prisoner || client == LR_Player_Guard)
				{
					if (IsClientInGame(client) && IsPlayerAlive(client))
					{
						if (g_Game == Game_CSGO)
						{
							CreateTimer(0.1, Timer_SafeSlay, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
						}
						else
						{
							ForcePlayerSuicide(client);
						}
						CPrintToChatAll("%s %t", ChatBanner, "LR RPS No Answer", client);
					}
				}	
			}
		}
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public Action Timer_DodgeballCheckCheaters(Handle timer)
{
	// is there still a gun toss LR going on?
	bool bDodgeball = false;
	int iArraySize = GetArraySize(gH_DArray_LR_Partners);
	if (iArraySize > 0)
	{
		for (int idx = 0; idx < GetArraySize(gH_DArray_LR_Partners); idx++)
		{	
			LastRequest type = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_LRType));
			if (type == LR_Dodgeball)
			{
				bDodgeball = true;
				
				int LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Prisoner));
				int LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Guard));
				
				if (IsValidEntity(LR_Player_Prisoner) && (GetClientHealth(LR_Player_Prisoner) > 1))
				{
					SetEntityHealth(LR_Player_Prisoner, 1);
				}
				if (IsValidEntity(LR_Player_Guard) && (GetClientHealth(LR_Player_Guard) > 1))
				{
					SetEntityHealth(LR_Player_Guard, 1);
				}
			}
		}
	}
	
	if (!bDodgeball)
	{
		g_DodgeballTimer = null;
		return Plugin_Stop;
	}

	return Plugin_Continue;
}

public Action Timer_HotPotatoDone(Handle timer, any HotPotato_ID)
{
	int iArraySize = GetArraySize(gH_DArray_LR_Partners);
	if (iArraySize > 0)
	{
		for (int idx = 0; idx < GetArraySize(gH_DArray_LR_Partners); idx++)
		{	
			LastRequest type = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_LRType));
			int thisHotPotato_ID = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Global3));			
			if ((type == LR_HotPotato) && (HotPotato_ID == thisHotPotato_ID))
			{
				int LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Prisoner));
				int LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Guard));
				
				int HPloser = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Global1));
				int HPwinner = ((HPloser == LR_Player_Prisoner) ? LR_Player_Guard : LR_Player_Prisoner);
				
				KillAndReward(HPloser, HPwinner);
				CPrintToChatAll("%s %t", ChatBanner, "HP Win", HPwinner, HPloser);
				
				if (gH_Cvar_LR_HotPotato_Mode.IntValue != 2)
				{
					SetEntPropFloat(HPwinner, Prop_Data, "m_flLaggedMovementValue", 1.0);
				}
			}
		}
	}
	return Plugin_Stop;
}

// Gun Toss distance meter and BeamSprite application
public Action Timer_GunToss(Handle timer)
{
	// is there still a gun toss LR going on?
	int iNumGunTosses = 0;
	int iArraySize = GetArraySize(gH_DArray_LR_Partners);
	
	char sHintTextGlobal[200];
	
	if (iArraySize > 0)
	{
		for (int idx = 0; idx < GetArraySize(gH_DArray_LR_Partners); idx++)
		{	
			LastRequest type = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_LRType));
			if (type == LR_GunToss)
			{
				iNumGunTosses++;
				
				int GTp1done, GTp2done, GTp1dropped, GTp2dropped, GTdeagle1, GTdeagle2;
				GTp1done = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Global3));
				GTp2done = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Global4));
				GTp1dropped = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Global1));
				GTp2dropped = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Global2));
				GTdeagle1 = EntRefToEntIndex(GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_PrisonerData)));
				GTdeagle2 = EntRefToEntIndex(GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_GuardData)));
				float GTdeagle1pos[3], GTdeagle2pos[3];
				float GTdeagle1lastpos[3], GTdeagle2lastpos[3];
				Handle PositionDataPack = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_DataPackHandle));
				ResetPack(PositionDataPack);
				GTdeagle1lastpos[0] = ReadPackFloat(PositionDataPack);
				GTdeagle1lastpos[1] = ReadPackFloat(PositionDataPack);
				GTdeagle1lastpos[2] = ReadPackFloat(PositionDataPack);
				GTdeagle2lastpos[0] = ReadPackFloat(PositionDataPack);
				GTdeagle2lastpos[1] = ReadPackFloat(PositionDataPack);
				GTdeagle2lastpos[2] = ReadPackFloat(PositionDataPack);
				float GTp1droppos[3], GTp2droppos[3];
				GTp1droppos[0] = ReadPackFloat(PositionDataPack);
				GTp1droppos[1] = ReadPackFloat(PositionDataPack);
				GTp1droppos[2] = ReadPackFloat(PositionDataPack);
				GTp2droppos[0] = ReadPackFloat(PositionDataPack);
				GTp2droppos[1] = ReadPackFloat(PositionDataPack);
				GTp2droppos[2] = ReadPackFloat(PositionDataPack);
				float GTp1jumppos[3], GTp2jumppos[3];
				GTp1jumppos[0] = ReadPackFloat(PositionDataPack);
				GTp1jumppos[1] = ReadPackFloat(PositionDataPack);
				GTp1jumppos[2] = ReadPackFloat(PositionDataPack);
				GTp2jumppos[0] = ReadPackFloat(PositionDataPack);
				GTp2jumppos[1] = ReadPackFloat(PositionDataPack);
				GTp2jumppos[2] = ReadPackFloat(PositionDataPack);
				
				if(IsValidEntity(GTdeagle1))
				{
					GetEntPropVector(GTdeagle1, Prop_Data, "m_vecOrigin", GTdeagle1pos);
					if (GTp1dropped && !GTp1done)
					{
						if (GetVectorDistance(GTdeagle1lastpos, GTdeagle1pos) < 3.00)
						{
							GTp1done = true;
							SetArrayCell(gH_DArray_LR_Partners, idx, GTp1done, view_as<int>(Block_Global3));
						}
						else
						{
							GTdeagle1lastpos[0] = GTdeagle1pos[0];
							GTdeagle1lastpos[1] = GTdeagle1pos[1];
							GTdeagle1lastpos[2] = GTdeagle1pos[2];
							#if SOURCEMOD_V_MAJOR >= 1 && SOURCEMOD_V_MINOR >= 8
								SetPackPosition(PositionDataPack, view_as<DataPackPos>(0));
							#else
								SetPackPosition(PositionDataPack, 0);
							#endif
							WritePackFloat(PositionDataPack, GTdeagle1lastpos[0]);
							WritePackFloat(PositionDataPack, GTdeagle1lastpos[1]);
							WritePackFloat(PositionDataPack, GTdeagle1lastpos[2]);
						}
					}
					else if (GTp1dropped && GTp1done)
					{
						float fBeamWidth = (g_Game == Game_CSS ? 10.0 : 2.0);
						float fRefreshRate = (g_Game == Game_CSS ? 0.1 : 1.0);
						switch (gH_Cvar_LR_GunToss_MarkerMode.IntValue)
						{
							case 0:
							{
								float beamStartP1[3];		
								float f_SubtractVec[3] = {0.0, 0.0, -30.0};
								MakeVectorFromPoints(f_SubtractVec, GTdeagle1lastpos, beamStartP1);
								TE_SetupBeamPoints(beamStartP1, GTdeagle1lastpos, BeamSprite, 0, 0, 0, fRefreshRate, fBeamWidth, fBeamWidth, 7, 0.0, redColor, 0);
							}
							case 1:
							{
								TE_SetupBeamPoints(GTp1droppos, GTdeagle1lastpos, BeamSprite, 0, 0, 0, fRefreshRate, fBeamWidth, fBeamWidth, 7, 0.0, redColor, 0);
							}
						}
	
						TE_SendToAll();				
					}
				}
				
				if(IsValidEntity(GTdeagle2))
				{
					GetEntPropVector(GTdeagle2, Prop_Data, "m_vecOrigin", GTdeagle2pos);
					if (GTp2dropped && !GTp2done)
					{					
						if (GetVectorDistance(GTdeagle2lastpos, GTdeagle2pos) < 3.00)
						{
							GTp2done = true;
							SetArrayCell(gH_DArray_LR_Partners, idx, GTp2done, view_as<int>(Block_Global4));						
						}
						else
						{
							GTdeagle2lastpos[0] = GTdeagle2pos[0];
							GTdeagle2lastpos[1] = GTdeagle2pos[1];
							GTdeagle2lastpos[2] = GTdeagle2pos[2];
	
							#if SOURCEMOD_V_MAJOR >= 1 && SOURCEMOD_V_MINOR >= 8
								SetPackPosition(PositionDataPack, view_as<DataPackPos>(3));
							#else
								SetPackPosition(PositionDataPack, 3);
							#endif
							WritePackFloat(PositionDataPack, GTdeagle2lastpos[0]);
							WritePackFloat(PositionDataPack, GTdeagle2lastpos[1]);
							WritePackFloat(PositionDataPack, GTdeagle2lastpos[2]);
						}
					}
					else if (GTp2dropped && GTp2done)
					{
						float fBeamWidth = (g_Game == Game_CSS ? 10.0 : 2.0);
						float fRefreshRate = (g_Game == Game_CSS ? 0.1 : 1.0);
						switch (gH_Cvar_LR_GunToss_MarkerMode.IntValue)
						{
							case 0:
							{
								float beamStartP2[3];
								float f_SubtractVec[3] = {0.0, 0.0, -30.0};
								MakeVectorFromPoints(f_SubtractVec, GTdeagle2lastpos, beamStartP2);
								TE_SetupBeamPoints(beamStartP2, GTdeagle2lastpos, BeamSprite, 0, 0, 0, fRefreshRate, fBeamWidth, fBeamWidth, 7, 0.0, blueColor, 0);
							}
							case 1:
							{
								TE_SetupBeamPoints(GTp2droppos, GTdeagle2lastpos, BeamSprite, 0, 0, 0, fRefreshRate, fBeamWidth, fBeamWidth, 7, 0.0, blueColor, 0);
							}
						}
						
						TE_SendToAll();				
					}
				}
				
				int LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Prisoner));
				int LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Guard));
				
				// broadcast distance
				if (gH_Cvar_LR_GunToss_ShowMeter.IntValue)
				{
					if (GTp2dropped)
					{
						f_DoneDistance[LR_Player_Guard] = GetVectorDistance(GTp2jumppos, GTdeagle2lastpos);
					}
					else
					{
						f_DoneDistance[LR_Player_Guard] = 0.0;
					}
					
					if (GTp1dropped)
					{
						f_DoneDistance[LR_Player_Prisoner] = GetVectorDistance(GTp1jumppos, GTdeagle1lastpos);
					}
					else
					{
						f_DoneDistance[LR_Player_Prisoner] = 0.0;
					}

					if (!gH_Cvar_SendGlobalMsgs.BoolValue)
					{
						if (g_Game == Game_CSS)
						{
							PrintHintText(LR_Player_Prisoner, "%t\n \n%N: %3.1f \n%N: %3.1f", "Distance Meter", LR_Player_Prisoner, f_DoneDistance[LR_Player_Prisoner], LR_Player_Guard, f_DoneDistance[LR_Player_Guard]);
							PrintHintText(LR_Player_Guard, "%t\n \n%N: %3.1f \n%N: %3.1f", "Distance Meter", LR_Player_Prisoner, f_DoneDistance[LR_Player_Prisoner], LR_Player_Guard, f_DoneDistance[LR_Player_Guard]);
						}
						else if (g_Game == Game_CSGO)
						{
							PrintHintText(LR_Player_Prisoner, "%t\n%N: %3.1f \n%N: %3.1f", "Distance Meter", LR_Player_Prisoner, f_DoneDistance[LR_Player_Prisoner], LR_Player_Guard, f_DoneDistance[LR_Player_Guard]);
							PrintHintText(LR_Player_Guard, "%t\n%N: %3.1f \n%N: %3.1f", "Distance Meter", LR_Player_Prisoner, f_DoneDistance[LR_Player_Prisoner], LR_Player_Guard, f_DoneDistance[LR_Player_Guard]);
						}
					}
					else
					{
						if (g_Game == Game_CSS)
						{
							Format(sHintTextGlobal, sizeof(sHintTextGlobal), "%s \n \n %N: %3.1f \n %N: %3.1f", sHintTextGlobal, LR_Player_Prisoner, f_DoneDistance[LR_Player_Prisoner], LR_Player_Guard, f_DoneDistance[LR_Player_Guard]);
						}
						else if (g_Game == Game_CSGO)
						{
							Format(sHintTextGlobal, sizeof(sHintTextGlobal), "%s \n %N: %3.1f \n %N: %3.1f", sHintTextGlobal, LR_Player_Prisoner, f_DoneDistance[LR_Player_Prisoner], LR_Player_Guard, f_DoneDistance[LR_Player_Guard]);
						}
					}
				}
			}
		}
	}
	
	if (gH_Cvar_LR_GunToss_ShowMeter.IntValue && gH_Cvar_SendGlobalMsgs.BoolValue && (iNumGunTosses > 0))
	{
		PrintHintTextToAll("%t %s", "Distance Meter", sHintTextGlobal);
	}
	
	if (iNumGunTosses <= 0)
	{
		g_GunTossTimer = null;
		return Plugin_Stop;
	}
	
	return Plugin_Continue;
}

public Action Timer_ChickenFight(Handle timer)
{
	int iArraySize = GetArraySize(gH_DArray_LR_Partners);
	bool bIsChickenFight = false;
	if (iArraySize > 0)
	{
		for (int idx = 0; idx < GetArraySize(gH_DArray_LR_Partners); idx++)
		{	
			LastRequest type = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_LRType));
			if (type == LR_ChickenFight)
			{
				bIsChickenFight = true;
				int LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Prisoner));
				int LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Guard));
				int p1EntityBelow = GetEntDataEnt2(LR_Player_Prisoner, g_Offset_GroundEnt);
				int p2EntityBelow = GetEntDataEnt2(LR_Player_Guard, g_Offset_GroundEnt);
				
				if (p1EntityBelow == LR_Player_Guard)
				{
					if (gH_Cvar_LR_ChickenFight_Slay.BoolValue)
					{
						CPrintToChatAll("%s %t", ChatBanner, "Chicken Fight Win And Slay", LR_Player_Prisoner, LR_Player_Guard);
						KillAndReward(LR_Player_Guard, LR_Player_Prisoner);
					}
					else
					{
						CPrintToChatAll("%s %t", ChatBanner, "Chicken Fight Win", LR_Player_Prisoner);
						CPrintToChat(LR_Player_Prisoner, "Chicken Fight Kill Loser", LR_Player_Guard);
						
						GivePlayerItem(LR_Player_Prisoner, "weapon_knife");
						
						SetEntityRenderColor(LR_Player_Guard, gH_Cvar_LR_ChickenFight_C_Red.IntValue, gH_Cvar_LR_ChickenFight_C_Green.IntValue,
							gH_Cvar_LR_ChickenFight_C_Blue.IntValue, 255);
							
						bIsChickenFight = false;
					}
				}
				else if (p2EntityBelow == LR_Player_Prisoner)
				{
					if (gH_Cvar_LR_ChickenFight_Slay.BoolValue)
					{
						CPrintToChatAll("%s %t", ChatBanner, "Chicken Fight Win And Slay", LR_Player_Guard, LR_Player_Prisoner);
						KillAndReward(LR_Player_Prisoner, LR_Player_Guard);
					}
					else
					{
						CPrintToChatAll("%s %t", ChatBanner, "Chicken Fight Win", LR_Player_Guard);
						CPrintToChat(LR_Player_Guard, "Chicken Fight Kill Loser", LR_Player_Prisoner);
						
						GivePlayerItem(LR_Player_Guard, "weapon_knife");
						
						SetEntityRenderColor(LR_Player_Prisoner, gH_Cvar_LR_ChickenFight_C_Red.IntValue, gH_Cvar_LR_ChickenFight_C_Green.IntValue,
							gH_Cvar_LR_ChickenFight_C_Blue.IntValue, 255);
							
						bIsChickenFight = false;
					}
				}
			}
		}
	}
	if (!bIsChickenFight)
	{
		g_ChickenFightTimer = INVALID_HANDLE;
		return Plugin_Stop;	
	}
	
	return Plugin_Continue;
}

void DecideRebelsFate(int rebeller, int LRIndex, int victim = 0)
{
	char sWeaponName[32];
	int iClientWeapon = GetEntDataEnt2(rebeller, g_Offset_ActiveWeapon);
	if (IsValidEdict(iClientWeapon))
	{
		GetEntityClassname(iClientWeapon, sWeaponName, sizeof(sWeaponName));
		ReplaceString(sWeaponName, sizeof(sWeaponName), "weapon_", "");
	}
	else
	{
		Format(sWeaponName, sizeof(sWeaponName), "unknown");
	}
	
	// grab the current LR and override default rebel action if requested (backward compatibility)
	int rebelAction;	
	LastRequest type = GetArrayCell(gH_DArray_LR_Partners, LRIndex, view_as<int>(Block_LRType));
	switch (type)
	{
		case LR_KnifeFight:
		{
			rebelAction = gH_Cvar_LR_KnifeFight_Rebel.IntValue+1;
		}
		case LR_ChickenFight:
		{
			rebelAction = gH_Cvar_LR_ChickenFight_Rebel.IntValue+1;
		}
		case LR_HotPotato:
		{
			rebelAction = gH_Cvar_LR_HotPotato_Rebel.IntValue+1;
		}		
		default:
		{
			rebelAction = gH_Cvar_RebelAction.IntValue;
		}
	}
	
	switch (rebelAction)
	{
		case 0:
		{
			// take no action here (for now)
		}
		case 1:
		{
			if (IsPlayerAlive(rebeller))
			{
				StripAllWeapons(rebeller);
			}
			CleanupLastRequest(rebeller, LRIndex);
			RemoveFromArray(gH_DArray_LR_Partners, LRIndex);
			if (victim == 0)
			{
				CPrintToChatAll("%s %t", ChatBanner, "LR Interference Abort - No Victim", rebeller, sWeaponName);
			}
			else if (victim == -1)
			{
				CPrintToChatAll("%s %t", ChatBanner, "LR Cheating Abort", rebeller);
			}
			else
			{
				CPrintToChatAll("%s %t", ChatBanner, "LR Interference Abort", rebeller, victim, sWeaponName);	
			}	
		}
		case 2:
		{
			if (IsPlayerAlive(rebeller))
			{
				if (g_Game == Game_CSGO)
				{
					CreateTimer(0.1, Timer_SafeSlay, GetClientUserId(rebeller), TIMER_FLAG_NO_MAPCHANGE);
				}
				else
				{
					ForcePlayerSuicide(rebeller);
				}
			}
			if (victim == 0)
			{
				CPrintToChatAll("%s %t", ChatBanner, "LR Interference Slay - No Victim", rebeller, sWeaponName);
			}
			else if (victim == -1)
			{
				CPrintToChatAll("%s %t", ChatBanner, "LR Cheating Slay", rebeller);
			}
			else
			{
				CPrintToChatAll("%s %t", ChatBanner, "LR Interference Slay", rebeller, victim, sWeaponName);	
			}		
		}
	}
}

public Action Timer_SafeSlay(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client)
	{
		ForcePlayerSuicide(client);
	}
}

public Action Timer_BeerGoggles(Handle timer)
{
	int timerCount = 1;
	timerCount++;
	if (timerCount > 160)
	{
		timerCount = 1;
	}
	
	float vecPunch[3];
	float drunkMultiplier = float(gH_Cvar_LR_KnifeFight_Drunk.IntValue);
	
	int iArraySize = GetArraySize(gH_DArray_LR_Partners);
	if (iArraySize == 0)
	{
		g_BeerGogglesTimer = null;
		return Plugin_Stop;
	}
	for (int idx = 0; idx < GetArraySize(gH_DArray_LR_Partners); idx++)
	{
		LastRequest type = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_LRType));
		if (type == LR_KnifeFight)
		{
			KnifeType KnifeChoice = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Global1));
			if (KnifeChoice == Knife_Drunk)
			{
				int LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Prisoner));
				int LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Guard));
				
				switch (timerCount % 4)
				{
					case 0:
					{
						vecPunch[0] = drunkMultiplier*5.0;
						vecPunch[1] = drunkMultiplier*5.0;
						vecPunch[2] = drunkMultiplier*-5.0;
					}
					case 1:
					{
						vecPunch[0] = drunkMultiplier*-5.0;
						vecPunch[1] = drunkMultiplier*-5.0;
						vecPunch[2] = drunkMultiplier*5.0;
					}
					case 2:
					{
						vecPunch[0] = drunkMultiplier*5.0;
						vecPunch[1] = drunkMultiplier*-5.0;
						vecPunch[2] = drunkMultiplier*5.0;
					}
					case 3:
					{
						vecPunch[0] = drunkMultiplier*-5.0;
						vecPunch[1] = drunkMultiplier*5.0;
						vecPunch[2] = drunkMultiplier*-5.0;
					}					
				}
				SetEntDataVector(LR_Player_Prisoner, g_Offset_PunchAngle, vecPunch, true);	
				SetEntDataVector(LR_Player_Guard, g_Offset_PunchAngle, vecPunch, true);
			}
		}
	}
	return Plugin_Continue;
}

void KillAndReward(int loser, int victor)
{
	StripAllWeapons(loser);
	
	if (g_Game == Game_CSGO)
	{
		RemoveDangerZone(loser);
		CreateTimer(0.1, Timer_SafeSlay, GetClientUserId(loser), TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		ForcePlayerSuicide(loser);
	}
	
	if (IsClientInGame(victor))
	{
		if (g_Game == Game_CSS)
		{
			int iFrags = GetEntProp(victor, Prop_Data, "m_iFrags");
			iFrags += gH_Cvar_LR_VictorPoints.IntValue;
			SetEntProp(victor, Prop_Data, "m_iFrags", iFrags);
		}
		else if (g_Game == Game_CSGO)
		{
			int iResourceEntity = GetPlayerResourceEntity();
			if (iResourceEntity != -1)
			{
				int iScore = GetEntProp(iResourceEntity, Prop_Send, "m_iScore", _, victor);
				iScore += gH_Cvar_LR_VictorPoints.IntValue*2;
				SetEntProp(iResourceEntity, Prop_Send, "m_iScore", iScore, _, victor);
			}
		}
	}
}

public Action SetZeroAmmo(int client, int weapon)
{ 
	if (IsValidEntity(weapon)) {
	//Primary ammo
	SetReserveAmmo(client, weapon, 0);

	//Clip
	SetClipAmmo(weapon, 0);
	}
}

void SetReserveAmmo(int client, int weapon, int ammo)
{
	SetEntProp(weapon, Prop_Send, "m_iPrimaryReserveAmmoCount", ammo); //set reserve to 0
    
	int ammotype = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType");
	if(ammotype == -1) return;
  
	SetEntProp(client, Prop_Send, "m_iAmmo", ammo, _, ammotype);
}

void SetClipAmmo(int weapon, int ammo)
{
	SetEntProp(weapon, Prop_Send, "m_iClip1", ammo);
	SetEntProp(weapon, Prop_Send, "m_iClip2", ammo);
}

void GetLastButton(int client, int &buttons, int idx)
{
	int LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Prisoner));
	int LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Guard));
	if (IsClientInGame(client) && IsPlayerAlive(client))
	{
		if (client == LR_Player_Prisoner || client == LR_Player_Guard)
		{
			for (int i = 0; i < MAX_BUTTONS; i++)
			{
				int button = (1 << i);
				if ((buttons & button))
				{
					if (!(g_LastButtons[client] & button))
					{
						if (button == IN_ATTACK2 || button == IN_ATTACK)
						{
							char classname[32];
							Client_GetActiveWeaponName(client, classname, 32);
							if ((StrContains(classname, "knife", false) != -1) || (StrContains(classname, "bayonet", false) != -1))
							{
								g_TriedToStab[client] = true;
							}
							else
							{
								g_TriedToStab[client] = false;
							}
						}
					}
				}
			}
		}
	}
	
	g_LastButtons[client] = buttons;
}

public Action Timer_StripZeus(Handle timer, int client)
{
	if (!IsValidClient(client) || !IsClientInLastRequest(client)) return Plugin_Stop;
	
	int TaserAmmo = Client_GetWeaponPlayerAmmo(client, "weapon_taser");
	if (TaserAmmo != 0)
	{
		Client_RemoveWeapon(client, "weapon_taser", false);
		
		if (gH_Cvar_LR_Debug_Enabled.BoolValue)
		{
			LogToFileEx(gShadow_Hosties_LogFile, "%L stripped from a Zeus - [lastrequest.sp - Timer_StripZeus]", client);
		}
	}
	
	return Plugin_Continue;
}

void RemoveDangerZone(int client)
{
	int Healthshot = Client_GetWeaponPlayerAmmo(client, "weapon_healthshot");
	int Snowball = Client_GetWeaponPlayerAmmo(client, "weapon_snowball");
	int Breachcharge = Client_GetWeaponPlayerAmmo(client, "weapon_breachcharge");
	int Tagrenade = Client_GetWeaponPlayerAmmo(client, "weapon_tagrenade");
	int Shield = Client_GetWeaponPlayerAmmo(client, "weapon_shield");
	int Bumpmine = Client_GetWeaponPlayerAmmo(client, "weapon_bumpmine");
	int Fists = Client_GetWeaponPlayerAmmo(client, "weapon_fists");
	
	if (Healthshot != 0)
		Client_RemoveWeapon(client, "weapon_healthshot", false);
		
	if (Snowball != 0)
		Client_RemoveWeapon(client, "weapon_snowball", false);
		
	if (Breachcharge != 0)
		Client_RemoveWeapon(client, "weapon_breachcharge", false);
		
	if (Tagrenade != 0)
		Client_RemoveWeapon(client, "weapon_tagrenade", false);
		
	if (Shield != 0)
		Client_RemoveWeapon(client, "weapon_shield", false);
		
	if (Bumpmine != 0)
		Client_RemoveWeapon(client, "weapon_bumpmine", false);
		
	if (Fists != 0)
		Client_RemoveWeapon(client, "weapon_fists", false);
}

void RightKnifeAntiCheat(int client, int idx)
{
	LastRequest type = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_LRType));
	int LR_Player_Prisoner = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Prisoner));
	int LR_Player_Guard = GetArrayCell(gH_DArray_LR_Partners, idx, view_as<int>(Block_Guard));
	
	if (client == LR_Player_Prisoner || client == LR_Player_Guard && IsValidClient(client))
	{		
		if (!((type == LR_KnifeFight) && !(type == LR_Rebel)) && ((type == LR_JumpContest) || (type == LR_Race) || (type == LR_ChickenFight) || (type == LR_Dodgeball) || \
			(type == LR_HotPotato) || (type == LR_Shot4Shot) || (type == LR_Mag4Mag) || (type == LR_NoScope) || (type == LR_RockPaperScissors) ||\
			(type == LR_RussianRoulette)))
		{
			if (IsClientInGame(client) && IsPlayerAlive(client))
			{
				if (g_TriedToStab[client] == true)
				{					
					DecideRebelsFate(client, idx);
					g_TriedToStab[client] = false;
				}
			}
		}		
	}
}

void UpdatePlayerCounts(int &Prisoners, int &Guards, int &iNumGuardsAvailable)
{
	for(int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && IsPlayerAlive(i))
		{
			if (GetClientTeam(i) == CS_TEAM_T)
			{
				Prisoners++;
			}
			else if (GetClientTeam(i) == CS_TEAM_CT)
			{
				Guards++;
				if (!g_bInLastRequest[i])
				{
					for(int idx = 1; idx <= MaxClients; idx++) // TODO: Less dum way?
					{
						if(g_LR_Player_Guard[idx] == i)
						{
							iNumGuardsAvailable--;
						}
					}
					iNumGuardsAvailable++;
				}
			}
		}
	}
}

public Action LastRequest_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	SetCorrectPlayerColor(client);
	
	if (g_Game == Game_CSGO)
	{
		ConVar Cvar_TeamBlock = FindConVar("mp_solid_teammates");
		int TeamBlock = GetConVarInt(Cvar_TeamBlock);
		
		if (TeamBlock == 1 || TeamBlock == 2)
			BlockEntity(client, g_Offset_CollisionGroup);
		else
			UnblockEntity(client, g_Offset_CollisionGroup);
	}
}

void SetCorrectPlayerColor(int client)
{
	if (!IsClientInGame(client) || !IsPlayerAlive(client))
	{
		return;
	}

	if (g_bIsARebel[client] && gH_Cvar_ColorRebels.IntValue)
	{
		SetEntityRenderColor(client, gH_Cvar_ColorRebels_Red.IntValue, gH_Cvar_ColorRebels_Green.IntValue, gH_Cvar_ColorRebels_Blue.IntValue, 255);
	}
	else
	{
		SetEntityRenderColor(client, 255, 255, 255, 255);
	}
}