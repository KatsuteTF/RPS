// Copyright (C) 2023 Katsute | Licensed under CC BY-NC-SA 4.0

#pragma semicolon 1

#include <sourcemod>

static float delay;

ConVar delayCV;

// plugin

public Plugin myinfo = {
    name        = "RPS Teammate",
    author      = "Katsute",
    description = "Kill teammate if they loose in RPS",
    version     = "1.0",
    url         = "https://github.com/KatsuteTF/RPS"
}

public OnPluginStart(){
    delayCV = CreateConVar("sm_rps_delay", "3", "Delay to kill loser in seconds");
    delayCV.AddChangeHook(OnConvarChanged);

    delay = delayCV.FloatValue;

    HookEvent("rps_taunt_event", OnRPS);
}

public void OnConvarChanged(const Handle convar, const char[] oldValue, const char[] newValue){
	if(convar == delayCV)
        delay = StringToFloat(newValue);
}

public void OnRPS(const Event event, const char[] name, const bool dontBroadcast){
    int winner = GetEventInt(event, "winner");
    int loser  = GetEventInt(event, "loser");

    if(GetClientTeam(winner) == GetClientTeam(loser))
        CreateTimer(delay, OnRPSLose, loser, TIMER_FLAG_NO_MAPCHANGE);
}

public Action OnRPSLose(const Handle timer, const int client){
    if(IsClientInGame(client))
        FakeClientCommand(client, "explode");
    return Plugin_Continue;
}