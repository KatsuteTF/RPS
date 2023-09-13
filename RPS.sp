// Copyright (C) 2023 Katsute | Licensed under CC BY-NC-SA 4.0

#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>

float delay;

ConVar delayCV;

// plugin

public Plugin myinfo = {
    name        = "RPS Teammate",
    author      = "Katsute",
    description = "Kill teammate if they loose in RPS",
    version     = "2.0",
    url         = "https://github.com/KatsuteTF/RPS"
}

public OnPluginStart(){
    delayCV = CreateConVar("sm_rps_delay", "3", "Delay to kill loser in seconds");
    delayCV.AddChangeHook(OnConvarChanged);

    delay = delayCV.FloatValue;

    HookEvent("rps_taunt_event", OnRPS);

    for(int i = 1; i <= MaxClients; i++){
        if(!IsClientInGame(i))
            continue;
        SDKHook(i, SDKHook_OnTakeDamageAlive, OnTakeDamage);
    }
}

public void OnConvarChanged(const ConVar convar, const char[] oldValue, const char[] newValue){
    if(convar == delayCV)
        delay = StringToFloat(newValue);
}

public void OnClientPostAdminCheck(int client){
    SDKHook(client, SDKHook_OnTakeDamageAlive, OnTakeDamage);
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom){
    if(victim == attacker &&
       damageForce[0] == 0.0 && damageForce[1] == 0.0 && damageForce[2] == 0.0 &&
       damagePosition[0] == 0.0 && damagePosition[1] == 0.0 && damagePosition[2] == 0.0){
        attacker = weapon;
        weapon = -1;
    }
    return Plugin_Changed;
}

public void OnRPS(const Event event, const char[] name, const bool dontBroadcast){
    int winner = GetEventInt(event, "winner");
    int loser  = GetEventInt(event, "loser");

    if(GetClientTeam(winner) == GetClientTeam(loser)){
        DataPack pack;

        CreateDataTimer(delay, OnRPSLose, pack, TIMER_FLAG_NO_MAPCHANGE);

        pack.WriteCell(winner);
        pack.WriteCell(loser);
    }
}

public Action OnRPSLose(const Handle timer, const DataPack pack){
    pack.Reset();
    int winner = pack.ReadCell();
    int loser  = pack.ReadCell();

    if(IsClientInGame(loser))
        if(IsClientInGame(winner))
            SDKHooks_TakeDamage(loser, loser, loser, 9000.0, DMG_GENERIC, winner, NULL_VECTOR, NULL_VECTOR, false);
        else
            FakeClientCommand(loser, "explode");
    return Plugin_Continue;
}