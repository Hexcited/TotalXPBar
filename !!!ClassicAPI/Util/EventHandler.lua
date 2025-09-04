local _, Private = ...

local BitBand = bit.band
local GetMetaTable = getmetatable
local HookSecureFunc = hooksecurefunc

local EventHandler = CreateFrame("Frame")
local ___RegisterEvent = EventHandler.RegisterEvent
local ___UnregisterEvent = EventHandler.UnregisterEvent

local EVENT_STORAGE = {}
local CLASSIC_EVENT = {}
local HANDLER_EVENT = {}

--[[

	CALLBACK SYSTEM

]]

local function EventHandler_Unregister(Self, Function, Event, Event2)
	local EventData = EVENT_STORAGE[Event]

	if ( EventData ) then
		local EventDataTotal, Index = 0

		for i=1,#EventData do
			local Callback = EventData[i]

			if ( Callback ) then
				EventDataTotal = EventDataTotal + 1

				if ( Callback.Func == Function ) then
					Index = i
					if ( EventDataTotal > 1 ) then break end
				end
			end
		end

		if ( Index ) then
			if ( EventDataTotal == 1 ) then
				EVENT_STORAGE[Event] = nil
				___UnregisterEvent(EventHandler, Event2)

				local UnregisterFunc = EventHandler[Event.."_UNREGISTER"]
				if ( UnregisterFunc ) then
					UnregisterFunc(nil, Self)
				end
			else
				EventData[Index] = false
			end
		end
	end
end

local function EventHandler_Register(Self, Function, Event, Event2)
	local EventData = EVENT_STORAGE[Event]
	local EventDataTotal = 0

	if ( not EventData ) then
		local _ = {}
		EVENT_STORAGE[Event] = _
		EventData = _
	else
		EventDataTotal = #EventData

		for i=1,EventDataTotal do
			if ( EventData[i].Func == Function ) then
				return
			end
		end
	end

	EventData[EventDataTotal + 1] = {Func = Function, Self = Self}
	___RegisterEvent(EventHandler, Event2)
end

local function EventHandler_Fire(Self, Event, ...)
	Event = HANDLER_EVENT[Event] or Event
	local EventData = EVENT_STORAGE[Event]

	if ( EventData ) then
		local TriggerFunc = EventHandler[Event.."_TRIGGER"]
		if ( TriggerFunc and TriggerFunc(nil, Self, Event, ...) == false ) then
			return
		end

		local Shuffle = 1
		for i=1,#EventData do
			local Callback = EventData[i]

			if ( Callback ) then
				Callback.Func(Callback.Self, Event, ...)

				if ( i ~= Shuffle ) then
					EventData[Shuffle] = Callback
					EventData[i] = nil
				end

				Shuffle = Shuffle + 1
			else
				EventData[i] = nil
			end
		end
	end
end
EventHandler:SetScript("OnEvent", EventHandler_Fire)

--[[

	METHOD HOOK(S)

]]

local function Method_RegisterEvent(Self, Event)
	local ClassicEvent = CLASSIC_EVENT[Event]

	if ( ClassicEvent ) then
		local OnEvent = Self:GetScript("OnEvent")

		if ( OnEvent ) then
			local RegisterFunc = EventHandler[Event.."_REGISTER"]
			if ( RegisterFunc and RegisterFunc(nil, Self) == false ) then
				return
			end

			if ( ClassicEvent[1] ) then
				for i=1,#ClassicEvent do
					EventHandler_Register(Self, OnEvent, Event, ClassicEvent[i])
				end
			else
				EventHandler_Register(Self, OnEvent, Event, ClassicEvent)
			end
		end
	end
end

local function Method_UnregisterEvent(Self, Event)
	local ClassicEvent = CLASSIC_EVENT[Event]

	if ( ClassicEvent ) then
		local OnEvent = Self:GetScript("OnEvent")

		if ( OnEvent ) then
			if ( ClassicEvent[1] ) then
				for i=1,#ClassicEvent do
					EventHandler_Unregister(Self, OnEvent, Event, ClassicEvent[i])
				end
			else
				EventHandler_Unregister(Self, OnEvent, Event, ClassicEvent)
			end
		end
	end
end

local function Method_RegisterUnitEvent(Self, Event, Unit1, Unit2)
	local UnitEvent = Self.___UnitEvent

	if ( not UnitEvent ) then
		UnitEvent = CreateFrame("Frame")
		Self.___UnitEvent = UnitEvent

		UnitEvent:SetScript("OnEvent", function(_, Event, ...)
			local Units = UnitEvent[Event]
			if ( Units ) then
				local Unit = ...
				if ( Units[1] == Unit or Units[2] == Unit ) then
					local OnEvent = Self:GetScript("OnEvent")
					if ( OnEvent ) then
						OnEvent(Self, Event, ...)
					end
				end
			end
		end)

		HookSecureFunc(Self, "UnregisterEvent", function(_, Event)
			if ( UnitEvent[Event] ) then
				UnitEvent[Event] = nil
				___UnregisterEvent(UnitEvent, Event) -- Stop extra method call.
			end
		end)
	end

	local Units = UnitEvent[Event]
	if ( not Units ) then
		Units = {}
		UnitEvent[Event] = Units
		UnitEvent:RegisterEvent(Event)
	end

	Units[1] = Unit1
	if ( Unit2 ) then
		Units[2] = Unit2
	end
end

--[[
	MODERN EVENT TO 335 EVENT: EventHandler_AddClassicEvent
	----
	arg1: Modern Event
	arg2: 335 Client Event (Table or String)
	arg3: Return ClassicEvent back to registered frame(s) OnEvent func (*If required)

]]

local function EventHandler_AddClassicEvent(ClassicEvent, Event)
	CLASSIC_EVENT[ClassicEvent] = (Event) and Event or ClassicEvent

	if ( Event ) then
		if ( Event[1] ) then
			for i=1,#Event do
				HANDLER_EVENT[Event[i]] = ClassicEvent
			end
		else
			HANDLER_EVENT[Event] = ClassicEvent
		end
	end
end

local FrameMeta = GetMetaTable(EventHandler).__index
local ButtonMeta = GetMetaTable(CreateFrame("Button")).__index
FrameMeta.RegisterUnitEvent = Method_RegisterUnitEvent
ButtonMeta.RegisterUnitEvent = Method_RegisterUnitEvent
HookSecureFunc(FrameMeta, "RegisterEvent", Method_RegisterEvent)
HookSecureFunc(FrameMeta, "UnregisterEvent", Method_UnregisterEvent)
HookSecureFunc(ButtonMeta, "RegisterEvent", Method_RegisterEvent)
HookSecureFunc(ButtonMeta, "UnregisterEvent", Method_UnregisterEvent)

-- Private Namespace
Private.EventHandler = EventHandler
Private.EventHandler_Fire = EventHandler_Fire
Private.EventHandler_Register = EventHandler_Register
Private.EventHandler_Unregister = EventHandler_Unregister
Private.EventHandler_AddClassicEvent = EventHandler_AddClassicEvent