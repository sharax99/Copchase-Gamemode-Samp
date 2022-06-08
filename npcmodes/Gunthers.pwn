#include <a_npc>

NextPlayBack()
{
	StartRecordingPlayback(PLAYER_RECORDING_TYPE_DRIVER, "SAPTexi2");
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