// Copyright (C) 2023 Katsute | Licensed under CC BY-NC-SA 4.0

#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>

float delay;

ConVar delayCV;
static ConVar mp_friendlyfire;
ArrayStack RPSStack;

// plugin

public Plugin myinfo = {
    name        = "RPS Teammate",
    author      = "Katsute, Peanut       ",
    description = "Kill teammate if they loose in RPS",
    version     = "1.1",
    url         = "https://github.com/KatsuteTF/RPS"
}

public OnPluginStart(){
    delayCV = CreateConVar("sm_rps_delay", "3", "Delay to kill loser in seconds");
    delayCV.AddChangeHook(OnConvarChanged);

    delay = delayCV.FloatValue;
    
    mp_friendlyfire = FindConVar("mp_friendlyfire");

    HookEvent("rps_taunt_event", OnRPS);
}

public void OnConvarChanged(const ConVar convar, const char[] oldValue, const char[] newValue){
	if(convar == delayCV)
        delay = StringToFloat(newValue);
}

public void OnRPS(const Event event, const char[] name, const bool dontBroadcast){
    int winner = GetEventInt(event, "winner");
    int loser  = GetEventInt(event, "loser");

    if(GetClientTeam(winner) == GetClientTeam(loser)) {
        RPSStack.Push(winner);
        CreateTimer(delay, OnRPSLose, loser, TIMER_FLAG_NO_MAPCHANGE);
    }
}

public Action OnRPSLose(const Handle timer, const int loser){
    float damageForce[3] = { 0.0, 0.0, 1024.0 };
    int winner = RPSStack.Pop();
    
    if(IsClientInGame(loser) & IsClientInGame(winner)) {
        mp_friendlyfire.IntValue = 1;
        SDKHooks_TakeDamage(loser, 0, winner, 999.0, DMG_GENERIC, -1, damageForce, .bypassHooks = false);
        mp_friendlyfire.IntValue = 0;
    }
    return Plugin_Continue;
}