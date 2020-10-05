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

#include <sourcemod>
#include <cstrike>
#include <sdkhooks>
#include <multicolors>
#undef REQUIRE_PLUGIN
#include <basecomm>
#define REQUIRE_PLUGIN
#include <hosties>

ConVar gH_Cvar_MuteStatus;
ConVar gH_Cvar_MuteLength;
ConVar gH_Cvar_MuteImmune;
ConVar gH_Cvar_MuteCT;
Handle gH_Timer_Unmuter = INVALID_HANDLE;

int gAdmFlags_MuteImmunity = 0;

void MutePrisoners_OnPluginStart()
{
	gH_Cvar_MuteStatus = CreateConVar("sm_hosties_mute", "1", "Setting for muting terrorists automatically: 0 - disable, 1 - terrorists are muted the first few seconds of a round, 2 - terrorists are muted when they die, 3 - both", 0, true, 0.0, true, 3.0);	
	gH_Cvar_MuteLength = CreateConVar("sm_hosties_roundstart_mute", "30.0", "The length of time the Terrorist team is muted for after the round begins", 0, true, 3.0, true, 90.0);	
	gH_Cvar_MuteImmune = CreateConVar("sm_hosties_mute_immune", "z", "Admin flags which are immune from getting muted: 0 - nobody, 1 - all admins, flag values: abcdefghijklmnopqrst");	
	gH_Cvar_MuteCT = CreateConVar("sm_hosties_mute_ct", "0", "Setting for muting counter-terrorists automatically when they die (requires sm_hosties_mute 2 or 3): 0 - disable, 1 - enable", 0, true, 0.0, true, 1.0);
	
	g_Offset_CollisionGroup = FindSendPropInfo("CBaseEntity", "m_CollisionGroup");
	if (g_Offset_CollisionGroup == -1)
	{
		SetFailState("Unable to find offset for collision groups.");
	}
}

void MutePrisoners_AllPluginsLoaded()
{
	if (DoesContainBaseCommNatives())
	{
		HookEvent("round_start", MutePrisoners_RoundStart);
		HookEvent("round_end", MutePrisoners_RoundEnd);
		HookEvent("player_death", MutePrisoners_PlayerDeath);
		HookEvent("player_spawn", MutePrisoners_PlayerSpawn);
	}
	else
	{
		CPrintToServer("Hosties Mute System Disabled. Upgrade to SM >= 1.4.0");
		LogMessage("Hosties Mute System Disabled. Upgrade to SM >= 1.4.0");
	}
}

void MutePrisoners_OnConfigsExecuted()
{
	MutePrisoners_CalcImmunity();
}

stock void MuteTs()
{
	for(int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && IsPlayerAlive(i)) // if player is in game and alive
		{
			if (!BaseComm_IsClientMuted(i))
			{
				MutePlayer(i);
			}
		}
	}
}

stock void UnmuteAlive()
{
	for(int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && IsPlayerAlive(i)) // if player is in game and alive
		{
			if (!BaseComm_IsClientMuted(i))
			{
				UnmutePlayer(i);
			}
		}
	}
}

stock bool DoesContainBaseCommNatives()
{
	// 1.3.9 will have Native_IsClientMuted in basecomm.inc 
	if (GetFeatureStatus(FeatureType_Native, "BaseComm_IsClientMuted") == FeatureStatus_Available)
	{
		return true;
	}
	return false;
}

stock void UnmuteAll()
{
	for(int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i)) // if player is in game
		{
			if (!BaseComm_IsClientMuted(i))
			{
				UnmutePlayer(i);
			}
		}
	}
}

void MutePrisoners_CalcImmunity()
{
	char buffer[128];
	gH_Cvar_MuteImmune.GetString(buffer, sizeof(buffer));
	if (StrEqual(buffer, "0"))
	{
		gAdmFlags_MuteImmunity = 0;
	}
	else
	{
		if(StrEqual(buffer, "1"))
		{
			// include everything but 'a': reservation slot
			Format(buffer, sizeof(buffer), "bcdefghijklmnopqrstz");
		}
		
		gAdmFlags_MuteImmunity = ReadFlagString(buffer);
	}
}

public Action MutePrisoners_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	if (gH_Cvar_MuteStatus.IntValue == 1 || gH_Cvar_MuteStatus.IntValue == 3)
	{
		// if the timer is anything but invalid, we should mute these new spawners
		if (gH_Timer_Unmuter != null)
		{
			int client = GetClientOfUserId(GetEventInt(event, "userid"));
			if (GetClientTeam(client) == CS_TEAM_T)
			{
				if (gAdmFlags_MuteImmunity == 0)
				{
					CreateTimer(0.1, Timer_Mute, client, TIMER_FLAG_NO_MAPCHANGE);
				}
				else
				{
					if (!(GetUserFlagBits(client) & gAdmFlags_MuteImmunity))
					{
						CreateTimer(0.1, Timer_Mute, client, TIMER_FLAG_NO_MAPCHANGE);
					}
				}
			}
		}
	}
}

public Action MutePrisoners_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	if (gH_Cvar_MuteStatus.IntValue <= 1)
	{
		return;
	}

	int victim = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (gAdmFlags_MuteImmunity == 0 || !(GetUserFlagBits(victim) & gAdmFlags_MuteImmunity))
	{
		int team = GetClientTeam(victim);
		switch (team)
		{
			case CS_TEAM_T:
			{
				CreateTimer(0.1, Timer_Mute, victim, TIMER_FLAG_NO_MAPCHANGE);
			}
			case CS_TEAM_CT:
			{
				if (gH_Cvar_MuteCT.BoolValue)
				{			
					CreateTimer(0.1, Timer_Mute, victim, TIMER_FLAG_NO_MAPCHANGE);
				}
			}
		}
	}
}

public Action Timer_Mute(Handle timer, any client)
{
	if (IsClientInGame(client))
	{
		MutePlayer(client);
		CPrintToChat(client, "%s %t", ChatBanner, "Now Muted");
	}
	
	return Plugin_Stop;
}

public Action MutePrisoners_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	if (gH_Cvar_MuteStatus.IntValue)
	{
		// Unmute Timer
		CreateTimer(0.2, Timer_UnmuteAll, _, TIMER_FLAG_NO_MAPCHANGE);
	}
	
	if (gH_Timer_Unmuter != null)
	{
		gH_Timer_Unmuter = null;
	}
}

public Action MutePrisoners_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if (gH_Cvar_MuteStatus.IntValue == 1 || gH_Cvar_MuteStatus.IntValue == 3)
	{
		if (gAdmFlags_MuteImmunity == 0)
		{
			// Mute All Ts
			MuteTs();
		}
		else
		{
			// Mute non-flagged Ts
			for (int idx = 1; idx <= MaxClients; idx++)
			{
				if (IsClientInGame(idx) && (GetClientTeam(idx) == CS_TEAM_T) && !(GetUserFlagBits(idx) & gAdmFlags_MuteImmunity))
				{
					MutePlayer(idx);
				}
			}
		}
		
		CreateTimer(gH_Cvar_MuteLength.FloatValue, Timer_UnmutePrisoners, _, TIMER_FLAG_NO_MAPCHANGE);
		
		CPrintToChatAll("%s %t", ChatBanner, "Ts Muted", RoundToNearest(gH_Cvar_MuteLength.FloatValue));
	}
}

public Action Timer_UnmutePrisoners(Handle timer)
{
	UnmuteAlive();
	CPrintToChatAll("%s %t", ChatBanner, "Ts Can Speak Again");
	
	return Plugin_Stop;
}

public Action Timer_UnmuteAll(Handle timer)
{
	UnmuteAll();
	
	return Plugin_Stop;
}