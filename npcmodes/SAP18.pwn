#include <a_npc>
#define NPC "SAP18"

NextPlayBack()
{
	StartRecordingPlayback(PLAYER_RECORDING_TYPE_DRIVER,NPC);
}

public OnRecordingPlaybackEnd()
{
	NextPlayBack();
}
public OnNPCSpawn()
{
	NextPlayBack();
}
public OnNPCExitVehicle()
{
	StopRecordingPlayback();
}
