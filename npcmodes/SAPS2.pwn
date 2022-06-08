#include <a_npc>
#define NPC "[LV]Ship[02]"

NextPlayBack()
{
	StartRecordingPlayback(PLAYER_RECORDING_TYPE_ONFOOT ,NPC);
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
