--[[
	MODERN EVENT TO 335 EVENT: EventHandler_AddClassicEvent
	----
	arg1: Modern Event
	arg2: 335 Client Event (Table or String)
	arg3: Return ClassicEvent back to registered frame(s) OnEvent func (*If required)

	Misc events that are pending dedicated files go here.

]]

local _, Private = ...

local EventHandler = Private.EventHandler
local _ = Private.EventHandler_AddClassicEvent

local GetNumRaidMembers = GetNumRaidMembers

_("INSPECT_READY", "INSPECT_TALENT_READY")
_("SPELL_DATA_LOAD_RESULT")
_("ITEM_DATA_LOAD_RESULT")
-- UNIT_CONNECTION : Unit.lua
-- UNIT_HEAL_PREDICTION : HealPrediction.lua

-- GROUP_ROSTER_UPDATE
function EventHandler:GROUP_ROSTER_UPDATE_TRIGGER(_, Event)
	if ( Event == "PARTY_MEMBERS_CHANGED" and GetNumRaidMembers() > 0 ) then
		return false -- Halt party updates if raid.
	end
end
_("GROUP_ROSTER_UPDATE", {"PARTY_MEMBERS_CHANGED", "RAID_ROSTER_UPDATE"})