-------------------------------------------------------------------------------
-- Localized Lua globals.
-------------------------------------------------------------------------------
local _G = getfenv(0)

local math = _G.math
local string = _G.string
local table = _G.table

local pairs = _G.pairs
local ipairs = _G.ipairs

local tostring = _G.tostring
local tonumber = _G.tonumber

-------------------------------------------------------------------------------
-- Localized Blizzard UI globals.
-------------------------------------------------------------------------------
local GetTime = _G.GetTime

-------------------------------------------------------------------------------
-- Addon namespace.
-------------------------------------------------------------------------------
local ADDON_NAME, namespace	= ...

local KNOWN_PREFIXES		= namespace.prefixes

local LibStub		= _G.LibStub
local Spamalyzer	= LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME, "AceEvent-3.0", "AceHook-3.0", "AceTimer-3.0")
local LQT		= LibStub("LibQTip-1.0")
local LDB		= LibStub("LibDataBroker-1.1")
local LDBIcon		= LibStub("LibDBIcon-1.0")
local L			= LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

local debugger		= _G.tekDebug and _G.tekDebug:GetFrame(ADDON_NAME)

-------------------------------------------------------------------------------
-- Variables.
-------------------------------------------------------------------------------
local players		= {}	-- List of players and their data.
local sorted_players	= {}

local addons		= {}	-- List of AddOns and their data.
local sorted_addons	= {}

local channels		= {}	-- List of channels and their data.
local sorted_channels	= {}

local guild_classes	= {}	-- Guild cache, updated when GUILD_ROSTER_UPDATE fires.

local timers		= {}	-- Timers currently in use

local track_cache	= {}	-- Cached tracking types to avoid constant string.lower() calls.

-- Messages/bytes in/out
local activity = {
	["output"]	= 0,
	["input"]	= 0,
	["bytes"]	= 0,
	["sent"]	= 0,
	["received"]	= 0,
	["messages"]	= 0,
}

local db
local output_frame	-- ChatFrame to direct AddonMessages to.
local epoch		= GetTime()	-- Beginning time for AddonMessage tracking.

-------------------------------------------------------------------------------
-- Constants.
-------------------------------------------------------------------------------
local DISPLAY_NAMES = {
	[1]	= L["Output"],
	[2]	= L["Input"],
	[3]	= L["Bytes"],
	[4]	= L["Sent"],
	[5]	= L["Received"],
	[6]	= L["Messages"],
}

local DISPLAY_VALUES = {
	[1]	= "output",
	[2]	= "input",
	[3]	= "bytes",
	[4]	= "sent",
	[5]	= "received",
	[6]	= "messages",
}

local VIEW_MODES = {
	[1]	= _G.ADDONS,
	[2]	= _G.CHANNEL,
	[3]	= _G.PLAYER,
}

local SORT_VALUES = {
	[1]	= _G.NAME,
	[2]	= L["Bytes"],
	[3]	= L["Messages"],
}

local SORT_TABLES = {
	[1]	= sorted_addons,
	[2]	= sorted_channels,
	[3]	= sorted_players,
}

local CHAT_FRAME_MAP = {
	[1]	= nil,
	[2]	= _G.ChatFrame1,
	[3]	= _G.ChatFrame2,
	[4]	= _G.ChatFrame3,
	[5]	= _G.ChatFrame4,
	[6]	= _G.ChatFrame5,
	[7]	= _G.ChatFrame6,
	[8]	= _G.ChatFrame7,
}

local CHANNEL_TYPE_NAMES = {
	["BATTLEGROUND"]	= _G.BATTLEGROUND,
	["GUILD"]		= _G.GUILD,
	["PARTY"]		= _G.PARTY,
	["RAID"]		= _G.RAID,
	["WHISPER"]		= _G.WHISPER,
}

local MY_NAME		= UnitName("player")

local COLOR_GREEN	= "|cff00ff00"
local COLOR_PALE_GREEN	= "|cffa3feba"
local COLOR_PINK	= "|cffffbbbb"
local COLOR_RED		= "|cffff0000"

-- Populated in Spamalyzer:UPDATE_CHAT_COLOR()
local CHANNEL_COLORS

-------------------------------------------------------------------------------
-- Debugger.
-------------------------------------------------------------------------------
local function Debug(...)
	if debugger then
		debugger:AddMessage(string.join(", ", ...))
	end
end

-------------------------------------------------------------------------------
-- Tooltip and Databroker methods.
-------------------------------------------------------------------------------
local NUM_COLUMNS = 4

local data_obj
local LDB_anchor
local tooltip

local elapsed_line		-- Line in the tooltip where the elapsed time resides.

local ByteStr
do
	local MiB = 1024 * 1024

	function ByteStr(bytes)
		if bytes <= 0 then
			return "0"
		end

		if bytes >= MiB then
			return string.format("%.2f MiB", bytes / MiB)
		end

		if bytes >= 1024 then
			return string.format("%.2f KiB", bytes / 1024)
		end
		return bytes
	end
end

local function UpdateDataFeed()
	local value = db.datafeed.display
	local display = (value <= 3) and ByteStr(activity[DISPLAY_VALUES[value]]) or activity[DISPLAY_VALUES[value]]
	data_obj.text = DISPLAY_NAMES[value]..": "..(display or _G.NONE)
end

do
	local function TimeStr(val)
		local tm = tonumber(val)

		if tm <= 0 then
			return "0s"
		end
		local hours = math.floor(tm / 3600)
		local minutes = math.floor(tm / 60 - (hours * 60))
		local seconds = math.floor(tm - hours * 3600 - minutes * 60)

		hours = hours > 0 and (hours.."h") or ""
		minutes = minutes > 0 and (minutes.."m") or ""
		seconds = seconds > 0 and (seconds.."s") or ""
		return hours..minutes..seconds
	end
	local time_str = TimeStr(GetTime() - epoch)	-- Cached value used between updates.

	function Spamalyzer:UpdateElapsed(use_cache)
		if not elapsed_line or not tooltip then
			return
		end

		if use_cache then
			tooltip:SetCell(elapsed_line, NUM_COLUMNS, time_str)
			return
		end
		time_str = TimeStr(GetTime() - epoch)
		tooltip:SetCell(elapsed_line, NUM_COLUMNS, time_str)
	end
end	-- do

do
	local last_update = 0

	function Spamalyzer:UpdateTooltip()
		last_update = last_update + 1

		-- Check for tooltip visibility as well, since DockingStation 0.3.3 (and a few versions below)
		-- handles tooltip hiding _way_ too aggressively.
		if not tooltip or not tooltip:IsVisible() then
			self:CancelTimer(timers.tooltip_update)
			self:CancelTimer(timers.elapsed_update)

			timers.tooltip_update = nil
			timers.elapsed_update = nil
			LDB_anchor = nil
			elapsed_line = nil
			last_update = 0
			return
		end

		if tooltip:IsMouseOver() or (LDB_anchor and LDB_anchor:IsMouseOver()) then
			last_update = 0
		else
			local elapsed = last_update * 0.2

			if elapsed >= db.tooltip.timer then
				self:CancelTimer(timers.tooltip_update)
				self:CancelTimer(timers.elapsed_update)

				timers.tooltip_update = nil
				timers.elapsed_update = nil
				tooltip = LQT:Release(tooltip)
				LDB_anchor = nil
				elapsed_line = nil
				last_update = 0
			end
		end
	end
end	-- do

local DrawTooltip
do
	local function NameOnMouseUp(cell, index)
		local view_mode = db.tooltip.view_mode
		local entry

		if view_mode == 1 then
			entry = addons[sorted_addons[index]]
		elseif view_mode == 2 then
			entry = channels[sorted_channels[index]]
		elseif view_mode == 3 then
			entry = players[sorted_players[index]]
		end
		entry.toggled = not entry.toggled
		DrawTooltip(LDB_anchor)
	end

	local function SortOnMouseUp(cell, sort_func)
		db.tooltip.sorting = sort_func
		db.tooltip.sort_ascending = not db.tooltip.sort_ascending

		DrawTooltip(LDB_anchor)
	end

	-------------------------------------------------------------------------------
	-- Sorting
	-------------------------------------------------------------------------------

	-- Iterator states - when drawing the tooltip, we need to know which AddOn or channel we are currently on so
	-- we can accurately sort sub-entries. 
	local addon_iter
	local channel_iter

	local ADDON_SORT_FUNCS = {
		-------------------------------------------------------------------------------
		-- Name
		-------------------------------------------------------------------------------
		[1]	= function(a, b)
				  if db.tooltip.sort_ascending then
					  return a < b
				  end
				  return a > b
			  end,

		-------------------------------------------------------------------------------
		-- Bytes
		-------------------------------------------------------------------------------
		[2]	= function(a, b)
				  local addon_a, addon_b

				  if channel_iter then
					  local channel = channels[channel_iter]

					  addon_a, addon_b = channel.addons[a], channel.addons[b]
				  else
					  addon_a, addon_b = addons[a], addons[b]
				  end

				  if addon_a.output == addon_b.output then
					  if db.tooltip.sort_ascending then
						  return a < b
					  end
					  return a > b
				  end

				  if db.tooltip.sort_ascending then
					  return addon_a.output < addon_b.output
				  end
				  return addon_a.output > addon_b.output
			  end,

		-------------------------------------------------------------------------------
		-- Messages
		-------------------------------------------------------------------------------
		[3]	= function(a, b)
				  local addon_a, addon_b

				  if channel_iter then
					  local channel = channels[channel_iter]

					  addon_a, addon_b = channel.addons[a], channel.addons[b]
				  else
					  addon_a, addon_b = addons[a], addons[b]
				  end

				  if addon_a.messages == addon_b.messages then
					  if db.tooltip.sort_ascending then
						  return a < b
					  end
					  return a > b
				  end

				  if db.tooltip.sort_ascending then
					  return addon_a.messages < addon_b.messages
				  end
				  return addon_a.messages > addon_b.messages
			  end
	}

	local CHANNEL_SORT_FUNCS = {
		-------------------------------------------------------------------------------
		-- Name
		-------------------------------------------------------------------------------
		[1]	= function(a, b)
				  if db.tooltip.sort_ascending then
					  return a < b
				  end
				  return a > b
			  end,

		-------------------------------------------------------------------------------
		-- Bytes
		-------------------------------------------------------------------------------
		[2]	= function(a, b)
				  local channel_a, channel_b = channels[a], channels[b]

				  if channel_a.output == channel_b.output then
					  if db.tooltip.sort_ascending then
						  return a < b
					  end
					  return a > b
				  end

				  if db.tooltip.sort_ascending then
					  return channel_a.output < channel_b.output
				  end
				  return channel_a.output > channel_b.output
			  end,

		-------------------------------------------------------------------------------
		-- Messages
		-------------------------------------------------------------------------------
		[3]	= function(a, b)
				  local channel_a, channel_b = channels[a], channels[b]

				  if channel_a.messages == channel_b.messages then
					  if db.tooltip.sort_ascending then
						  return a < b
					  end
					  return a > b
				  end

				  if db.tooltip.sort_ascending then
					  return channel_a.messages < channel_b.messages
				  end
				  return channel_a.messages > channel_b.messages
			  end
	}

	local PLAYER_SORT_FUNCS = {
		-------------------------------------------------------------------------------
		-- Name
		-------------------------------------------------------------------------------
		[1]	= function(a, b)
				  if db.tooltip.sort_ascending then
					  return a < b
				  end
				  return a > b
			  end,

		-------------------------------------------------------------------------------
		-- Bytes
		-------------------------------------------------------------------------------
		[2]	= function(a, b)
				  local player_a, player_b = players[a], players[b]

				  if addon_iter then
					  if player_a.addons[addon_iter].output == player_b.addons[addon_iter].output then
						  if db.tooltip.sort_ascending then
							  return a < b
						  end
						  return a > b
					  end

					  if db.tooltip.sort_ascending then
						  return player_a.addons[addon_iter].output < player_b.addons[addon_iter].output
					  end
					  return player_a.addons[addon_iter].output > player_b.addons[addon_iter].output
				  end

				  if player_a.output == player_b.output then
					  if db.tooltip.sort_ascending then
						  return a < b
					  end
					  return a > b
				  end

				  if db.tooltip.sort_ascending then
					  return player_a.output < player_b.output
				  end
				  return player_a.output > player_b.output
			  end,

		-------------------------------------------------------------------------------
		-- Messages
		-------------------------------------------------------------------------------
		[3]	= function(a, b)
				  local player_a, player_b = players[a], players[b]

				  if addon_iter then
					  if player_a.addons[addon_iter].messages == player_b.addons[addon_iter].messages then
						  if db.tooltip.sort_ascending then
							  return a < b
						  end
						  return a > b
					  end

					  if db.tooltip.sort_ascending then
						  return player_a.addons[addon_iter].messages < player_b.addons[addon_iter].messages
					  end
					  return player_a.addons[addon_iter].messages > player_b.addons[addon_iter].messages
				  end

				  if player_a.messages == player_b.messages then
					  if db.tooltip.sort_ascending then
						  return a < b
					  end
					  return a > b
				  end

				  if db.tooltip.sort_ascending then
					  return player_a.messages < player_b.messages
				  end
				  return player_a.messages > player_b.messages
			  end,
	}

	local SORT_FUNC_TABLES = {
		[1]	= ADDON_SORT_FUNCS,
		[2]	= CHANNEL_SORT_FUNCS,
		[3]	= PLAYER_SORT_FUNCS,
	}

	local COLOR_TABLE = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS
	local CLASS_COLORS = {}

	for k, v in pairs(COLOR_TABLE) do
		CLASS_COLORS[k] = string.format("%2x%2x%2x", v.r * 255, v.g * 255, v.b * 255)
	end

	local function GetPlayerClass(player)
		local guildie = guild_classes[player]

		if guildie then
			return guildie
		end
		local _, class_english = _G.UnitClass(player)

		if class_english then
			return class_english
		end
	end

	function DrawTooltip(anchor)
		if not anchor then
			return
		end
		LDB_anchor = anchor

		if not tooltip then
			tooltip = LQT:Acquire(ADDON_NAME.."Tooltip", NUM_COLUMNS, "LEFT", "CENTER", "CENTER", "CENTER")
			tooltip:EnableMouse(true)

			if _G.TipTac and _G.TipTac.AddModifiedTip then
				-- Pass true as second parameter because hooking OnHide causes C stack overflows
				_G.TipTac:AddModifiedTip(tooltip, true)
			end
		end

		tooltip:Clear()
		tooltip:SmartAnchorTo(anchor)
		tooltip:SetScale(db.tooltip.scale)

		local view_mode = db.tooltip.view_mode
		local line, column = tooltip:AddHeader()

		tooltip:SetCell(line, 1, ADDON_NAME.." - "..VIEW_MODES[view_mode], "CENTER", NUM_COLUMNS)
		tooltip:AddSeparator()

		local sort_table = SORT_TABLES[view_mode]
		local sort_funcs = SORT_FUNC_TABLES[view_mode]

		if #sort_table == 0 then
			line = tooltip:AddLine()
			tooltip:SetCell(line, 1, _G.EMPTY, "CENTER", NUM_COLUMNS)
			tooltip:AddLine(" ")

			elapsed_line = tooltip:AddLine()
			tooltip:SetCell(elapsed_line, 1, _G.TIME_ELAPSED, "LEFT", 3)

			Spamalyzer:UpdateElapsed(timers.elapsed_update)
			
			tooltip:Show()
			return
		end
		line = tooltip:AddLine(" ", " ", L["Messages"], L["Bytes"])
		tooltip:SetCell(line, 1, _G.NAME, "LEFT", 2)

		tooltip:SetCellScript(line, 1, "OnMouseUp", SortOnMouseUp, 1)
		tooltip:SetCellScript(line, 3, "OnMouseUp", SortOnMouseUp, 3)
		tooltip:SetCellScript(line, 4, "OnMouseUp", SortOnMouseUp, 2)

		local ICON_PLUS		= [[|TInterface\BUTTONS\UI-PlusButton-Up:20:20|t]]
		local ICON_MINUS	= [[|TInterface\BUTTONS\UI-MinusButton-Up:20:20|t]]
		local sort_method	= db.tooltip.sorting

		if #sort_table > 1 then
			table.sort(sort_table, sort_funcs[sort_method])
		end

		-- Reset our iter state.
		addon_iter = nil
		channel_iter = nil

		if view_mode == 1 then
			-------------------------------------------------------------------------------
			-- AddOns view
			-------------------------------------------------------------------------------
			for index, addon_name in ipairs(sorted_addons) do
				local addon = addons[addon_name]
				local toggled = addon.toggled
				local color = addon.known and COLOR_GREEN or COLOR_RED

				addon_iter = addon_name

				line = tooltip:AddLine(toggled and ICON_MINUS or ICON_PLUS, " ", addon.messages, ByteStr(addon.output))
				tooltip:SetCell(line, 2, string.format("%s%s|r", color, addon_name), "LEFT")
				tooltip:SetLineScript(line, "OnMouseUp", NameOnMouseUp, index)

				if toggled then
					if #addon.sorted > 1 then
						table.sort(addon.sorted, PLAYER_SORT_FUNCS[sort_method])
					end

					for index, player_name in ipairs(addon.sorted) do
						local player = players[player_name]
						local class_color = CLASS_COLORS[player.class]

						if not class_color then
							player.class = GetPlayerClass(player_name)
							class_color = CLASS_COLORS[player.class]
						end
						line = tooltip:AddLine(" ", " ", player.addons[addon_name].messages, ByteStr(player.addons[addon_name].output))
						tooltip:SetCell(line, 2, string.format("|cff%s%s|r%s", class_color or "cccccc", player_name, player.realm or ""), "LEFT")
					end
				end
			end
		elseif view_mode == 2 then
			-------------------------------------------------------------------------------
			-- Channel view
			-------------------------------------------------------------------------------
			for index, channel_name in ipairs(sorted_channels) do
				local channel = channels[channel_name]
				local toggled = channel.toggled

				channel_iter = channel_name

				line = tooltip:AddLine(toggled and ICON_MINUS or ICON_PLUS, " ", channel.messages, ByteStr(channel.output))
				tooltip:SetCell(line, 2, channel.name, "LEFT")
				tooltip:SetLineScript(line, "OnMouseUp", NameOnMouseUp, index)

				if toggled then
					if #channel.sorted > 1 then
						table.sort(channel.sorted, ADDON_SORT_FUNCS[sort_method])
					end

					for index, addon_name in ipairs(channel.sorted) do
						local addon = channel.addons[addon_name]
						local color = addon.known and COLOR_GREEN or COLOR_RED

						line = tooltip:AddLine(" ", " ", addon.messages, ByteStr(addon.output))
						tooltip:SetCell(line, 2, string.format("%s%s|r", color, addon_name), "LEFT")
					end
				end
			end
		elseif view_mode == 3 then
			-------------------------------------------------------------------------------
			-- Player view
			-------------------------------------------------------------------------------
			for index, player_name in ipairs(sorted_players) do
				local player = players[player_name]
				local toggled = player.toggled
				local class_color = CLASS_COLORS[player.class]

				if not class_color then
					player.class = GetPlayerClass(player_name)
					class_color = CLASS_COLORS[player.class]
				end
				line = tooltip:AddLine(toggled and ICON_MINUS or ICON_PLUS, " ", player.messages, ByteStr(player.output))
				tooltip:SetCell(line, 2, string.format("|cff%s%s|r%s", class_color or "cccccc", player_name, player.realm or ""), "LEFT")
				tooltip:SetLineScript(line, "OnMouseUp", NameOnMouseUp, index)

				if toggled then
					if #player.sorted > 1 then
						table.sort(player.sorted, ADDON_SORT_FUNCS[sort_method])
					end

					for index, addon_name in ipairs(player.sorted) do
						local addon = player.addons[addon_name]
						local color = addon.known and COLOR_GREEN or COLOR_RED

						line = tooltip:AddLine(" ", " ", addon.messages, ByteStr(addon.output))
						tooltip:SetCell(line, 2, string.format("%s%s|r", color, addon_name), "LEFT")
					end
				end
			end
		end
		tooltip:AddLine(" ")

		elapsed_line = tooltip:AddLine()
		tooltip:SetCell(elapsed_line, 1, _G.TIME_ELAPSED, "LEFT", 3)

		Spamalyzer:UpdateElapsed(timers.elapsed_update)

		if db.tooltip.show_stats then
			tooltip:AddSeparator()

			for index, name in ipairs(DISPLAY_NAMES) do
				local value = activity[DISPLAY_VALUES[index]]

				line = tooltip:AddLine(" ", " ", " ", (index <= 3) and ByteStr(value) or value)
				tooltip:SetCell(line, 1, name, "LEFT", 2)
			end
		end

		if not db.tooltip.hide_hint then
			tooltip:AddSeparator()

			line = tooltip:AddLine()
			tooltip:SetCell(line, 1, L["Left-click to change datafeed type."], "LEFT", NUM_COLUMNS)

			line = tooltip:AddLine()
			tooltip:SetCell(line, 1, L["Shift+Left-click to clear data."], "LEFT", NUM_COLUMNS)

			line = tooltip:AddLine()
			tooltip:SetCell(line, 1, L["Right-click for options."], "LEFT", NUM_COLUMNS)

			line = tooltip:AddLine()
			tooltip:SetCell(line, 1, L["Middle-click to change tooltip mode."], "LEFT", NUM_COLUMNS)
		end
		tooltip:UpdateScrolling()
		tooltip:Show()
	end
end	-- do

-- Fired 1.5 seconds after a call to StoreMessage()
function Spamalyzer:OnMessageUpdate()
	UpdateDataFeed()

	if LDB_anchor and tooltip and tooltip:IsVisible() then
		DrawTooltip(LDB_anchor)
	end
	timers.message_update = nil
end

do
	local function EscapeChar(c)
		return ("\\%03d"):format(c:byte())
	end

	function Spamalyzer:StoreMessage(prefix, message, type, origin, target)
		local tracking = track_cache[type]

		if not tracking and not output_frame then
			return
		end
		local addon_name

		if KNOWN_PREFIXES[prefix] then
			addon_name = KNOWN_PREFIXES[prefix]
		elseif prefix:match("^$Tranq") then
			addon_name = "SimpleTranqShot"
		elseif prefix:match("^vgcomm") then
			addon_name = "VGComms"
		elseif prefix:match("^CC_") then
			addon_name = "ClassChannels"
		else
			-- Try escaping it and testing for AceComm-3.0 multi-part.
			local escaped_prefix = prefix:gsub("[%c\092\128-\255]", EscapeChar)

			if escaped_prefix:match(".-\\%d%d%d") then
				local matched_prefix = escaped_prefix:match("(.-)\\%d%d%d")

				if KNOWN_PREFIXES[matched_prefix] then
					addon_name = KNOWN_PREFIXES[matched_prefix]
				end
			end
			-- Cache this in the prefix table.
			KNOWN_PREFIXES[prefix] = addon_name
		end
		local known = addon_name and true or false	-- If addon_name is nil, we didn't find a match.
		local channel_color = CHANNEL_COLORS and CHANNEL_COLORS[type] or "cccccc"

		if output_frame and ((known and db.general.display_known) or (not known and db.general.display_unknown)) then
			local color = tracking and COLOR_PALE_GREEN or COLOR_PINK
			local display_name = addon_name or _G.UNKNOWN
			local display_color = known and COLOR_GREEN or COLOR_RED

			message = message or ""
			target = target and (" to "..target..", from ") or ""

			output_frame:AddMessage(string.format("%s%s|r (|cff%s%s|r): %s[%s] [%s]|r %s %s[%s]|r",
							      display_color, display_name, channel_color, CHANNEL_TYPE_NAMES[type], color, prefix, message, target, color, origin))
		end

		-- Not tracking data from this message type, so stop here.
		if not tracking then
			return
		end
		local bytes = string.len(prefix) + string.len(message)

		if bytes == 0 then
			return
		end
		addon_name = addon_name or prefix	-- Ensure that addon_name is not nil.

		local player_name, realm = string.split("-", origin, 2)

		-- If the player is on the current realm, player_name will be nil - set it as origin.
		player_name = player_name or origin

		local player = players[player_name]

		if not player then
			player = {
				["name"]	= player_name,
				["messages"]	= 1,
				["output"]	= bytes,
				["sorted"]	= {},
				["addons"]	= {
					[addon_name] = {
						["messages"]	= 1,
						["output"]	= bytes,
						["known"]	= known,
					}
				}
			}
			table.insert(player.sorted, addon_name)

			if realm then
				player.realm = "|cff"..channel_color.."-"..realm.."|r"
			end
			players[player_name] = player
			table.insert(sorted_players, player_name)
		else
			if realm then
				player.realm = "|cff"..channel_color.."-"..realm.."|r"
			end
			local source = player.addons[addon_name]

			if not source then
				source = {
					["known"]	= known,
					["messages"]	= 0,
					["output"]	= 0,
				}
				table.insert(player.sorted, addon_name)
				player.addons[addon_name] = source
			end
			source.output = source.output + bytes
			source.messages = source.messages + 1

			player.messages = player.messages + 1
			player.output = player.output + bytes
		end
		local addon = addons[addon_name]

		if not addon then
			addon = {
				["messages"]	= 1,
				["output"]	= bytes,
				["known"]	= known,
				["name"]	= addon_name,
				["sorted"]	= {},
				["players"]	= {
					[player_name] = true
				}
			}
			table.insert(addon.sorted, player_name)

			addons[addon_name] = addon
			table.insert(sorted_addons, addon_name)
		else
			local player = addon.players[player_name]

			if not player then
				addon.players[player_name] = true
				table.insert(addon.sorted, player_name)
			end
			addon.output = addon.output + bytes
			addon.messages = addon.messages + 1
		end
		local channel = channels[type]

		if not channel then
			channel = {
				["name"]	= "|cff"..channel_color..CHANNEL_TYPE_NAMES[type].."|r",
				["messages"]	= 1,
				["output"]	= bytes,
				["sorted"]	= {},
				["addons"]	= {
					[addon_name] = {
						["messages"]	= 1,
						["output"]	= bytes,
						["known"]	= known,
					}
				}
			}
			table.insert(channel.sorted, addon_name)
			channels[type] = channel
			table.insert(sorted_channels, type)
		else
			local source = channel.addons[addon_name]

			if not source then
				source = {
					["known"]	= known,
					["messages"]	= 0,
					["output"]	= 0,
				}
				table.insert(channel.sorted, addon_name)
				channel.addons[addon_name] = source
			end
			source.output = source.output + bytes
			source.messages = source.messages + 1

			channel.messages = channel.messages + 1
			channel.output = channel.output + bytes
		end

		if origin == MY_NAME then
			activity.output = activity.output + bytes
			activity.sent = activity.sent + 1
		else
			activity.input = activity.input + bytes
			activity.received = activity.received + 1
		end
		activity.bytes = activity.bytes + bytes
		activity.messages = activity.messages + 1

		if not timers.message_update then
			timers.message_update = self:ScheduleTimer("OnMessageUpdate", 1.5)
		end
	end
end	--do

-------------------------------------------------------------------------------
-- Hooked functions.
-------------------------------------------------------------------------------
function Spamalyzer:SendAddonMessage(prefix, message, type, target)
	-- Only gather messages we send to the whiper channel, because we'll catch everything else.
	if target and target ~= "" and type == "WHISPER" then
		self:StoreMessage(prefix, message, type, MY_NAME, target)
	end
end

-------------------------------------------------------------------------------
-- Event functions.
-------------------------------------------------------------------------------
function Spamalyzer:OnInitialize()
	local defaults = {
		global = {
			datafeed = {
				display		= 1,	-- Output (in bytes)
				minimap_icon	= {
					hide	= false,
				},
			},
			general = {
				display_frame	= 1,	-- None.
				display_known	= true,
				display_unknown	= true,
			},
			tracking = {
				battleground	= false,
				guild		= false,
				party		= true,
				raid		= true,
				whisper		= true,
			},
			tooltip = {
				hide_hint	= false,
				view_mode	= 3,	-- Player view.
				show_stats	= false,
				scale		= 1,
				sorting		= 1,	-- Name.
				sort_ascending	= true,
				timer		= 0.25,
			},
		}
	}

	local temp_db = LibStub("AceDB-3.0"):New(ADDON_NAME.."DB", defaults)
	db = temp_db.global

	output_frame = CHAT_FRAME_MAP[db.general.display_frame]

	-- Cache the tracking preferences.
	for track_type, val in pairs(db.tracking) do
		track_cache[track_type:upper()] = val
	end
	self:SetupOptions()
end

function Spamalyzer:OnEnable()
	data_obj = LDB:NewDataObject(ADDON_NAME, {
		type	= "data source",
		label	= ADDON_NAME,
		text	= " ",
		icon	= "Interface\\Icons\\INV_Letter_16",
		OnEnter	= function(display, motion)
				  if not timers.tooltip_update then
					  DrawTooltip(display)
					  timers.tooltip_update = self:ScheduleRepeatingTimer("UpdateTooltip", 0.2)
				  end

				  if not timers.elapsed_update then
					  timers.elapsed_update = self:ScheduleRepeatingTimer("UpdateElapsed", 1)
				  end
			  end,
		-- OnLeave is an empty function because some LDB displays refuse to display a plugin that has an OnEnter but no OnLeave.
		OnLeave	= function()
			  end,
		OnClick = function(display, button)
				  if button == "RightButton" then
					  local options_frame = InterfaceOptionsFrame

					  if options_frame:IsVisible() then
						  options_frame:Hide()
					  else
						  InterfaceOptionsFrame_OpenToCategory(Spamalyzer.options_frame)
					  end
				  elseif button == "LeftButton" then
					  if IsShiftKeyDown() then
						  table.wipe(sorted_players)
						  table.wipe(players)

						  table.wipe(sorted_addons)
						  table.wipe(addons)

						  table.wipe(sorted_channels)
						  table.wipe(channels)

						  activity.output = 0
						  activity.input = 0
						  activity.bytes = 0
						  activity.sent = 0
						  activity.received = 0
						  activity.messages = 0

						  epoch = GetTime()
						  elapsed_line = nil
						  DrawTooltip(display)
						  UpdateDataFeed()
					  else
						  local cur_val = db.datafeed.display
						  db.datafeed.display = (cur_val == 6) and 1 or cur_val + 1
						  UpdateDataFeed()
					  end
				  elseif button == "MiddleButton" then
					  local cur_val = db.tooltip.view_mode

					  db.tooltip.view_mode = (cur_val == 3) and 1 or cur_val + 1
					  elapsed_line = nil
					  DrawTooltip(display)
				  end
			  end,
	})
	UpdateDataFeed()

	self:RegisterEvent("CHAT_MSG_ADDON")
	self:RegisterEvent("GUILD_ROSTER_UPDATE")
	self:RegisterEvent("UPDATE_CHAT_COLOR")

	self:SecureHook("SendAddonMessage")

	-- Wait a few seconds to be sure everything is loaded, then request guild and channel information to cache for later use.
	self:ScheduleTimer(_G.GuildRoster, 5)
	self:ScheduleTimer("UPDATE_CHAT_COLOR", 5)

	if LDBIcon then
		LDBIcon:Register(ADDON_NAME, data_obj, db.datafeed.minimap_icon)
	end
end

function Spamalyzer:OnDisable()
	for k, v in pairs(timers) do
		self:CancelTimer(v, true)
		timers[k] = nil
	end
end

-- Channel names may have been set before this event fired, and must be colorized.
-- This is also fired when the user changes channel colors in the default UI.
function Spamalyzer:UPDATE_CHAT_COLOR()
	CHANNEL_COLORS = CHANNEL_COLORS or {}

	for track_type, val in pairs(db.tracking) do
		local upper_type = track_type:upper()
		local chat_info = _G.ChatTypeInfo[upper_type]

		CHANNEL_COLORS[upper_type] = string.format("%2x%2x%2x", chat_info.r * 255, chat_info.g * 255, chat_info.b * 255)

		if channels[upper_type] then
			channels[upper_type].name = "|cff"..CHANNEL_COLORS[upper_type]..CHANNEL_TYPE_NAMES[upper_type].."|r"
		end
	end
end

function Spamalyzer:GUILD_ROSTER_UPDATE()
	if not _G.IsInGuild() then
		return
	end
	table.wipe(guild_classes)

	for count = 1, _G.GetNumGuildMembers(true), 1 do
		local name, _, _, _, _, _, _, _, _, _, class = _G.GetGuildRosterInfo(count)

		if name and class then
			guild_classes[name] = class
		end
	end
end


function Spamalyzer:CHAT_MSG_ADDON(event, prefix, message, channel, sender)
	self:StoreMessage(prefix, message, channel, sender)
end

-------------------------------------------------------------------------------
-- Configuration.
-------------------------------------------------------------------------------
local options

local function GetOptions()
	if not options then
		options = {
			name = ADDON_NAME,
			childGroups = "tab",
			type = "group",
			args = {
				-------------------------------------------------------------------------------
				-- General options.
				-------------------------------------------------------------------------------
				general = {
					name	= _G.GENERAL_LABEL,
					order	= 10,
					type	= "group",
					args	= {
						minimap_icon = {
							order	= 10,
							type	= "toggle",
							width	= "full",
							name	= L["Minimap Icon"],
							desc	= L["Draws the icon on the minimap."],
							get	= function()
									  return not db.datafeed.minimap_icon.hide
								  end,
							set	= function(info, value)
									  db.datafeed.minimap_icon.hide = not value

									  LDBIcon[value and "Show" or "Hide"](LDBIcon, ADDON_NAME)
								  end,
						},
						spacer1 = {
							order	= 11,
							type	= "description",
							name	= "\n",
						},
						display_frame = {
							order	= 20,
							type	= "select",
							name	= _G.DISPLAY_OPTIONS,
							desc	= L["Secondary location to display AddOn messages."],
							get	= function()
									  return db.general.display_frame
								  end,
							set	= function(info, value)
									  db.general.display_frame = value
									  output_frame = CHAT_FRAME_MAP[value]
								  end,
							values	= {
								[1]	= _G.NONE,
								[2]	= L["ChatFrame1"],
								[3]	= L["ChatFrame2"],
								[4]	= L["ChatFrame3"],
								[5]	= L["ChatFrame4"],
								[6]	= L["ChatFrame5"],
								[7]	= L["ChatFrame6"],
								[8]	= L["ChatFrame7"],
							},
						},
						display_known = {
							order	= 30,
							type	= "toggle",
							width	= "full",
							name	= L["Display Known"],
							desc	= L["Display messages from known AddOns in the ChatFrame."],
							get	= function()
									  return db.general.display_known
								  end,
							set	= function(info, value)
									  db.general.display_known = value
								  end,
						},
						display_unknown = {
							order	= 40,
							type	= "toggle",
							width	= "full",
							name	= L["Display Unknown"],
							desc	= L["Display messages from unknown AddOns in the ChatFrame."],
							get	= function()
									  return db.general.display_unknown
								  end,
							set	= function(info, value)
									  db.general.display_unknown = value
								  end,
						},
					},
				},
				-------------------------------------------------------------------------------
				-- Tracking options.
				-------------------------------------------------------------------------------
				tracking = {
					name	= L["Tracking"],
					order	= 30,
					type	= "group",
					args	= {
						battleground = {
							order	= 10,
							type	= "toggle",
							name	= _G.BATTLEGROUND,
							desc	= string.format(L["Toggle recording of %s AddOn messages."], _G.BATTLEGROUND),
							get	= function() return db.tracking.battleground end,
							set	= function()
									  db.tracking.battleground = not db.tracking.battleground
									  track_cache["BATTLEGROUND"] = db.tracking.battleground
								  end,
						},
						guild = {
							order	= 20,
							type	= "toggle",
							name	= _G.GUILD,
							desc	= string.format(L["Toggle recording of %s AddOn messages."], _G.GUILD),
							get	= function() return db.tracking.guild end,
							set	= function()
									  db.tracking.guild = not db.tracking.guild
									  track_cache["GUILD"] = db.tracking.guild
								  end,
						},
						party = {
							order	= 30,
							type	= "toggle",
							name	= _G.PARTY,
							desc	= string.format(L["Toggle recording of %s AddOn messages."], _G.PARTY),
							get	= function() return db.tracking.party end,
							set	= function()
									  db.tracking.party = not db.tracking.party
									  track_cache["PARTY"] = db.tracking.party
								  end,
						},
						raid = {
							order	= 40,
							type	= "toggle",
							name	= _G.RAID,
							desc	= string.format(L["Toggle recording of %s AddOn messages."], _G.RAID),
							get	= function() return db.tracking.raid end,
							set	= function()
									  db.tracking.raid = not db.tracking.raid
									  track_cache["RAID"] = db.tracking.raid
								  end,
						},
						whisper	= {
							order	= 50,
							type	= "toggle",
							name	= _G.WHISPER,
							desc	= string.format(L["Toggle recording of %s AddOn messages."], _G.WHISPER),
							get	= function() return db.tracking.whisper end,
							set	= function()
									  db.tracking.whisper = not db.tracking.whisper
									  track_cache["WHISPER"] = db.tracking.whisper
								  end,
						},
					},
				},
				-------------------------------------------------------------------------------
				-- Tooltip options.
				-------------------------------------------------------------------------------
				tooltip = {
					name	= L["Tooltip"],
					order	= 40,
					type	= "group",
					args	= {
						scale = {
							order	= 10,
							type	= "range",
							width	= "full",
							name	= L["Scale"],
							desc	= L["Move the slider to adjust the scale of the tooltip."],
							min	= 0.5,
							max	= 1.5,
							step	= 0.01,
							get	= function()
									  return db.tooltip.scale
								  end,
							set	= function(info, value)
									  db.tooltip.scale = math.max(0.5, math.min(1.5, value))
								  end,
						},
						timer = {
							order	= 20,
							type	= "range",
							width	= "full",
							name	= L["Timer"],
							desc	= L["Move the slider to adjust the tooltip fade time."],
							min	= 0.2,
							max	= 2,
							step	= 0.1,
							get	= function()
									  return db.tooltip.timer
								  end,
							set	= function(info, value)
									  db.tooltip.timer = math.max(0.2, math.min(2, value))
								  end,
						},
						hide_hint = {
							order	= 30,
							type	= "toggle",
							width	= "full",
							name	= L["Hide Hint Text"],
							desc	= L["Hides the hint text at the bottom of the tooltip."],
							get	= function()
									  return db.tooltip.hide_hint
								  end,
							set	= function(info, value)
									  db.tooltip.hide_hint = value
								  end,
						},
						show_stats = {
							order	= 40,
							type	= "toggle",
							width	= "full",
							name	= _G.STATISTICS,
							desc	= L["Show traffic statistics at the bottom of the tooltip."],
							get	= function()
									  return db.tooltip.show_stats
								  end,
							set	= function(info, value)
									  db.tooltip.show_stats = value
								  end,
						},
					},
				},
			},
		}
	end
	return options
end

function Spamalyzer:SetupOptions()
	LibStub("AceConfig-3.0"):RegisterOptionsTable(ADDON_NAME, GetOptions())
	self.options_frame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(ADDON_NAME)
end
