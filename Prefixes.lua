local _, namespace = ...

local KNOWN_PREFIXES = {
	["<AFKTracker> Check Version"]		= "AFKTracker",
	["AAVLookupBroadcast"]			= "Atrox Arena Viewer",
	["AKAT2_"]				= "AKA",
	["AlgalonObserver"]			= "AlgalonObserver",
	["ArenaMaster"]				= "Arena Master",
	["Armory"]				= "Armory",
	["AthenesUpgradeEstimator DPS"]		= "Athene's Upgrade Estimator",
	["AthenesUpgradeEstimator dpsUpgrade"]	= "Athene's Upgrade Estimator",
	["AthenesUpgradeEstimator healUpgrade"]	= "Athene's Upgrade Estimator",
	["BeastTraining"]			= "BeastTraining",
	["BigWigs"]				= "BigWigs",
	["BWVB"]				= "BigWigs",	-- BigwWigs version query
	["BWVB2"]				= "BigWigs",	-- BigWigs version query v2
	["BWVQ"]				= "BigWigs",	-- BigWigs version query
	["BWVR"]				= "BigWigs",	-- BigWigs version response
	["BWOOD"]				= "BigWigs",	-- BigWigs version broadcast
	["BWOOD3"]				= "BigWigs3",
	["BWTIP"]				= "BigWigs3",
	["BWVQ3"]				= "BigWigs3",
	["BWVR3"]				= "BigWigs3",
	["BWVRA3"]				= "BigWigs3",
	["BOOTYCALL"]				= "BootyCall (Jaycyn)",
	["BTC"]					= "BootyCall (Rabbit)",
	["BossNotes"]				= "Boss Notes",
	["BOSSTACTICS"]				= "BossTactics",
	["CastCommLib"]				= "CastCommLib",
	["Crafts"]				= "Crafts",
	["DamageMeters"]			= "DamageMeters",
	["DataStore"]				= "DataStore",
	["DS_Cont"]				= "DataStore",
	["DS_Craft"]				= "DataStore",
	["DS_Inv"]				= "DataStore",
	["DS_Mails"]				= "DataStore",
	["Death_Tracker"]			= "Death_Tracker",
	["DoIKnowYou"]				= "DoIKnowYou",
	["EASYMOTHER"]				= "EasyMother",
	["EnsidiaFails"]			= "EnsidiaFails",
	["EnsidiaFailsWotLK"]		= "EnsidiaFailsWotLK",
	["eov_version_message"]			= "An eye on viper",
	["ForteWarlock"]			= "ForteXorcist",
	["Gatherer"]				= "Gatherer",
	["GUILDMAP"]				= "GuildMap",
	["LibGuildStorage-1.0"]			= "LibGuildStorage-1.0",
	["LibVersionCheck"]			= "LibVersionCheck-1.0",
	["Libzz"]				= "Libzz",
	["LootFilter"]				= "LootFilter",
	["lugMD"]				= "lugMD",
	["MageMajic"]				= "MageMajic",
	["MagicMarker"]				= "MagicMarker",
	["MalygosFlamer"]			= "MalygosFlamer",
	["MalygosFlamerVersion"]		= "MalygosFlamer",
	["MultiBoxer"]				= "MultiBoxer",
	["Ovale"]				= "Ovale",
	["PetEmote"]				= "PetEmote",
	["PreformAVEnabler"]			= "PreformAVEnabler",
	["PartyCastingBars"]			= "PartyCastingBars",
	["QuestAnnouncer"]			= "QuestAnnouncer",
	["RAB/BT"]				= "RABuffs",
	["RAB/BI"]				= "RABuffs", 
	["RAB/BS"]				= "RABuffs", 
	["RAB/RD"]				= "RABuffs", 
	["RAB/RN"]				= "RABuffs", 
	["RAB/RE"]				= "RABuffs", 
	["RAB/RO"]				= "RABuffs", 
	["RAB/RF"]				= "RABuffs", 
	["RAB/BR"]				= "RABuffs", 
	["RAB/V"] 				= "RABuffs", 
	["RAB/VC"]				= "RABuffs",  
	["RAIDMOBMARKER"]			= "RaidMobMarker",
	["RAIDVOICE"]				= "RaidVoice",
	["RankWatch"]				= "RankWatch",
	["RBS"]					= "RaidBuffStatus",
	["Recap"]				= "Recap",
	["Rupture"]				= "Rupture",
	["RW2"]					= "Raid Watch 2",
	["SimpleMD"]				= "SimpleMD",
	["Skadoosh"]				= "Skadoosh",
	["SmartRes"]				= "SmartRes",
	["SMN"]					= "SpamMeNot",
	["SorrenTimers"]			= "SorrenTimers",
	["SRTI"]				= "Simple Raid Target Icons",
	["SSPVP"]				= "SSPVP",
	["VisualHeal"]				= "VisualHeal",
	["X-Perl"]				= "X-Perl",
	["X-PerlHeal"]				= "X-Perl",
	["XChar"]				= "XChar-Profiler",
	["Yacl"]				= "YACL-DmgMeter",
	--AceComm Hashes
	
	["\198\137h"]				= "Violation",
	["\252\245G"]				= "QuestsFu",
	["2\224\237"]				= "Cartographer [Guild Positions]",
	["CGP"]					= "Cartographer [Guild Positions]",
	["8\206\194"]				= "VoiceFU",
	["\137\016"]				= "Cartographer [Notes]",
	["CaN"]					= "Cartographer [Notes]",
	["\1813T"]				= "Recount",
	["RECOUNT"]				= "Recount",
	["\1675B"]				= "Recap",
	["h\031Y"]				= "InventoryLib-2.0",
	[".\136="]				= "Proximo",
	["p\190\246"]				= "SimpleMD",
	["\1484\008"]				= "VanasKoS",
	["QQ6"]					= "TooltipExchange",  -- TooltipExchange protocol 6
	["\1613["]				= "BagPress",
	[")\252$"]				= "AceComm [VersionCheck]",	-- Hash of "Version". VersionChecker also uses
	["\234\218\230"]			= "Gladiator",
	["k\227D"]				= "GPSLib",
	["\229^\092"]				= "ZOMGBuffs",
	["\130\131\213"]			= "Boss Talk",
	["\143\019\007"]			= "SpamMeNot",
	["kEl"]					= "DalaranUniversity",
	["\198\232\192"]			= "Cooldown Timers 2",
	--[[
	["b\146F"]				= "UNKNOWN_2!!!_[b\146F]",
	["v`\153"]				= "UNKNOWN_3!!_[v'\153]",	-- warlock_raid"
	["\235\1742"]				= "UNKNOWN_4_ [235\1742]!!!",	-- looks like a typo!
	["LW\190"]				= "UNKNOWN_5!!_[LW\190]",	-- mage_raid",
	["\175\150\155"]			= "UNKNOWN_ 6[\175\150\155]",	-- Hunter_whisper", 
	["]\027L"]				= "UNKNOWN_7!!_[]\027L]",	-- paladin-bg
	["\016X{"]				= "UNKNOWN_8[\016X{]",	-- warrior-raid
	["KS2"]= "UNKNOWN_10!!!_KS2",
	["}\027L"] ="UNNOWN_12!!!_[}\027L",
	-- ]]--
	["[HA]"]				= "HealAssign",
	["D?"]					= "ControlArena",
	["BGGQ"]				= "Gladiator",
	["^RX^"]				= "Prescription_Pickup",
	["Absorbs_Scaling"]			= "LibAbsorbsMonitor-1.0",
	["Absorbs_UnitStats"]			= "LibAbsorbsMonitor-1.0",
	["AGC"]					= "AthenesGearCheck",
	["ALF_T"]				= "Arena Live Frames",
	["AltoGuild"]				= "Altoholic",
	["Altoholic"]				= "Altoholic",
	["AM_FU"]				= "AlphaMap",
	["ATF"]					= "AutoFIR",
	["ATf"]					= "AutoFIR",
	["ATm"]					= "AutoFIR",
	["ArenaUnitFrames"]			= "Arena Unit Frames",
	["ATR"]					= "Auctionator",
	["AucAdvAskPrice"]			= "Auctioneer",
	["Audio Effects"]			= "AFX",
	["AudioX"]				= "AudioX (Who)",
	["AVR"]					= "Augmented Virtual Reality",
	["AVRE-1.0"]				= "AVR Encounters",
	["BangCore_TPO"]			= "Bang!Core",
	["BangWG5"]				= "BangWintergrasp",
	["BDKP-REQ"]				= "BananaDKP",
	["BDKP-ATT-M"]				= "BananaDKP",
	["BDKP-ATT-S"]				= "BananaDKP",
	["BDKP-DKP-M"]				= "BananaDKP",
	["BDKP-DKP-S"]				= "BananaDKP",
	["BEJEWELED2"]				= "Bejeweled",
	["BEJ2a"]				= "Bejeweled",
	["BE2"]					= "BossEncounter2",
	["BFC"]					= "Battlefield Commander",
	["BGSAlertsVersion"]			= "BGSoundAlerts 2",
	["BG General*"]				= "Battleground General",
	["vG"]					= "Battleground General",	-- AlteracModule
	["BLSS"]				= "Blessed",
	["Broker_GuildMoney"]	= "Broker_GuildMoney",
	["BrokerEpicAvg"]			= "Broker:EpicAvg",
	["BST"]					= "Bonstar",
	["cap"]					= "Capping",
	["Cap"]					= "Capping_v3.2.002+",	-- new IoC siege sync
	["chatmod"]				= "ChatMOD",
	["CKICK_SYNC"]				= "Ckick", 
	["Crb"]					= "CarboniteQuest",
	["CRT"]					= "Curse Raid Tracker",
	["CRT_Att"]				= "Curse Raid Tracker (Attendance)",
	["CRT_Bid"]				= "Curse Raid Tracker (Bidding)",
	["CRT_Pts"]				= "Curse Raid Tracker (Points)",
	["CTRA"]				= "CTRaidAssist",
	["CFUVCQ"]				= "FuBar_ConvergeFU",
	["CFUVCR"]				= "FuBar_ConvergeFU",   
	["CT3"]					= "Cartographer 3",
	["DTMR"]				= "DoTimer",
	["DBM3Arathi"]				= "DeadlyBossMods_V3",
	["DBM3Alterac"]				= "DeadlyBossMods_V3",
	["DBMv4-CombatInfo"]			= "DeadlyBossMods_V4",
	["DBMv4-Kill"]				= "DeadlyBossMods_V4",
	["DBMv4-Mod"]				= "DeadlyBossMods_V4",
	["DBMv4-Pull"]				= "DeadlyBossMods_V4",
	["DBMv4-Pizza"]				= "DeadlyBossMods_V4",
	["DBMv4-RequestTimers"]			= "DeadlyBossMods_V4",
	["DBMv4-TimerInfo"]			= "DeadlyBossMods_V4",
	["DBMv4-Ver"]				= "DeadlyBossMods_V4",
	["DecursiveVersion"]			= "Decursive",
	["dgks_txt"]				= "dG Killshot Notifier",
	["dgks_ScrollingTextEvent"]		= "dG Killshot Notifier",
	["dgks_KillSoundEvent"]			= "dG Killshot Notifier",
	["dgks_BGVersionCheckRequest"]		= "dG Killshot Notifier",
	["dgks_RaidVersionCheckRequest"]	= "dG Killshot Notifier",
	["dgks_GuildVersionCheckRequest"]	= "dG Killshot Notifier",
	["dgks_VersionCheckResponse"]		= "dG Killshot Notifier",
	["DPD2"]				= "Doodlepad",
	["DPM"]					= "Deadly Pvp Mods",
	["DPMcheck"]				= "Deadly Pvp Mods",
	["DPMversion"]				= "Deadly Pvp Mods",
	["DPMtrue"]				= "Deadly Pvp Mods",
	["DQT"]					= "DaylieQuestViewer",
	["DTM"]					= "DiamondThreatMeter",
	["DRA2"]				= "DruidRaidAssist2",
	["DRA2_ASK"]				= "DruidRaidAssist2",
	["DXE"]					= "Deus Vox Encounters",
	["DXE_Dist8"]				= "Deus Vox Encounters",
	["ELITG"]				= "ElitistGroup",
	["EPGP"]				= "epgp (dkp reloaded)",
	["EPGPLMVChk"]				= "EPGPLootmaster",
	["EPGPLMVRsp"]				= "EPGPLootmaster",
	["EPGPLMVHdlr"]				= "EPGPLootmaster",
	["EPGPLootMasterC"]			= "EPGPLootmaster",
	["EPGPLootMasterML"]			= "EPGPLootmaster",
	["ExaminerGlyphs"]			= "Examiner",
	["eXtremeRaid"]				= "OnRaid",
	["FBAM"]				= "Fishing Buddy",
	["FX2"]					= "ForteXorcist",
	["G2G"]					= "Guild2Guild",
	["GathX"]				= "Gatherer",
	--		GSCR				= not GearScore :(
	["GHOSTRECON"]				= "Ghost: Recon",
	["GLDR"]				= "Guilder",
	["GMSD"]				= "GatherMate1",
	["GM2SD"]				= "GatherMate2",
	["GearScore"]				= "GearScore",
	["GearScoreRecount"]			= "GearScore",
	["GearScore_Request"]			= "GearScore",
	["GearScore_Send"]			= "GearScore",
	["GearScore_Version"]			= "GearScore",
	["GHI"]					= "Gryphonheart Items",
	["GoGoMountVER"]			= "GoGoMount",
	["GRoster"]				= "GuildRoster",
	["GSY"]					= "GearScore",
	["GSY_Request"]				= "GearScore",
	["GSY_Version"]				= "GearScore",
	["GSX"]					= "GearScore",
	["GTFO_u"]				= "GTFO",
	["GTFO_v"]				= "GTFO",
	["gqAccept"]				= "Guild Quests",
	["gqLogout"]				= "Guild Quests",
	["gqRemove"]				= "Guild Quests",
	["gqReply"]				= "Guild Quests",
	["GC3"]					= "GroupCalendar",
	["GC3/"]				= "GroupCalendar",  -- Does this one actually get sent?
	["GC4"]					= "GroupCalendar",
	["GC4/"]				= "GroupCalendar",  -- Does this one actually get sent?
	["GC5"]					= "GroupCalendar",
	["GDALootlist"]				= "GetDKP",
	["GLDG"]				= "GuildGreet",
	["GEM3"]				= "GuildEventManager",
	["GTH"]					= "Getting Things Healed",
	["GuildCraft3"]				= "Guild Craft",
	["GuildCraft35"]			= "Guild Craft",
	["GuildSpyVersion"]			= "GuildSpy",
	["GupPetVersion"]			= "GupPet",
	["HealBot"]				= "HealBot",
	["HealBot_GUID"]			= "HealBot",
	["hbComms"]				= "HealBot_Ultra_low_comms",
	["hbGUID"]				= "HealBot",
	["HealBot_Heals"]			= "HealBot",
	["HealComm"]				= "LibHealComm-3.0",	-- or version2, you cant tell them apart
	["Hermes_Receive_V1"]			= "Hermes",
	["Hermes_Send_V1"]			= "Hermes",
	["HIVE"]				= "HiveMind",
	["HUD"]					= "HudMap",
	["IHL"]					= "IncomingHealsLib-1.0",
	["JambaCommunicationsCommand"]		= "Jamba",	-- multiboxing tool
	["KALIFCMSG"]				= "Forecast",
	["KARMA"]				= "Karma",
	["KHP_dragon"]				= "Kalecgos Dual HP",
	["KHP_deamon"]				= "Kalecgos Dual HP",
	["KLHALG"]				= "KLHAlgalon",	-- check
	["KLHTM"]				= "KLHThreatMeter",
	["LGP"]					= "LibGuildPositions-1.0",
	["LHC40"]				= "LibHealComm-4.0",
	["LibGroupTalents-1.0"]			= "LibGroupTalents-1.0",
	["LockdownUpdate"]			= "Lockdown",
	["Lockdown0005Hello"]			= "Lockdown",
	["Lockdown0005NewLock"]			= "Lockdown",
	["Lockdown0005Wipe"]			= "Lockdown",
	["LOOT_OPENED"]				= "AceEvent-2.0 [Loot Opened]",
	["LPH10"]				= "LibPendingHeals-1.0",
	["LRW2"]				= "LiveRaidWatch_v2",
	["LVBM"]				= "Deadly Boss Mods",
	["LVBM NSP"]				= "Deadly Boss Mods",
	["LVFH MARK"]				= "Deadly Boss Mods",
	["LVGWF ENRAGE"]			= "Deadly Boss Mods",
	["LVFH VOID"]				= "Deadly Boss Mods",
	["LVBM NSP"]				= "Deadly Boss Mods",
	["LVNEF"]				= "Deadly Boss MOds",
	["MLRA"]				= "CT_RaidTracker",
	["MS1"]					= "MinnaStats",
	["MagicMarker"]				= "MagicMarker",
	["MagicMarkerRT"]			= "MagicMarker",
	["MARYSUE"]				= "MarySue",
	["MeBo"]				= "MessageBoard",	-- most likely
	["mmkocomm"]				= "MM Kill Order",	--check!	 
	["MorgDKP2MorgBid"]			= "MorgDKP2",
	["MorgDKP2Syncing"]			= "MorgDKP2",
	["MorgDKP2MorgBid"]			= "MorgDKP2",
	["MorgBid2"]				= "MorgBid2",
	["MVIT"]				= "MoveItMoveIt",
	["MYC"]					= "MakeYourChoice",
	["NECB"]				= "Natur EnemyCastBar",
	["NECBCHAT"]				= "Natur EnemyCastBar",
	["NECBCTRA"]				= "Natur EnemyCastBar",
	["Nurfed:Lyt"]				= "Nurfed Layout",
	["oRA"]					= "oRA2",
	["oRA3"]				= "oRA3",
	["<<PiraCore>>"]			= "PiraMod",
	["PABx39dkes8xj"]			= "Party Ability Bars",
	["PAB935ndd8xid"]			= "Party Ability Bars",
	["PABkd8cjnwuid"]			= "Party Ability Bars",
	["Piece of Justice"]			= "Piece of Justice",
	["Pit"]					= "PitBull",
	["PALB"]				= "Paladin Buffer",
	["PetShopSync"]				= "Pet Shop",
	["PLPWR"]				= "PallyPower",
	["PhoenixStyle"]			= "Phoenix Style",
	["PhoenixStyle_info"]			= "Phoenix Style",
	["PS-marksoff"]				= "Phoenix Style",
	["PS-myvers"]				= "Phoenix Style",
	["PSplag"]				= "Phoenix Style",
	["PSplag2"]				= "Phoenix Style",
	["QCOMPLETIST"]				= "Quest Completist",
	["Quecho"]				= "Quecho",
	["Quecho2"]				= "Quecho",	-- turned in
	["Quecho3"]				= "Quecho",	-- accepted
	["QHpr"]				= "QuestHelper",
	["QuGu"]				= "Quest Guru",
	["Quixote2"]				= "LibQuixote-2.0",
	["R\195\159"]				= "RecipeBook",
	["RaCD"]				= "RaidCooldowns",
	["RaidAchievement"]			= "RaidAchievement",
	["RaidAchievement_info"]		= "RaidAchievement",
	["RaidAchievement_info2"]		= "RaidAchievement",
	["RA-myvers"]				= "RaidAchievement",
	["RaidForge"]				= "RaidForge",
	["RAIDTOTEMS"]				= "TotemTimers",
	["RBM"]					= "RBM",
	["RCD2"]				= "RaidCooldowns",
	["RD"]					= "RogueDamage",
	["RDX"]					= "OpenRDX",
	["RID"]					= "Raid ID",
	["RRL"]					= "Raid Roll",
	["SRA"]					= "SRA",
	["RTM"]					= "RezzTextMonitor",
	["SGLC"]				= "SurgeonGeneral",
	["SRTi"]				= "Simple Raid Target Icons",
	["SSAF"]				= "SSArena Frames",
	["SSN"]					= "SpeakinSpell",
	["StinkyQ"]				= "StinkyQueue",
	["Super Duper Macro query"]		= "Super Duper Macro",
	["Super Duper Macro recFailed"]		= "Super Duper Macro",
	["Super Duper Macro receiving"]		= "Super Duper Macro",
	["Super Duper Macro sendFailed"]	= "Super Duper Macro",
	["Super Duper Macro recDone"]		= "Super Duper Macro",
	["Super Duper Macro response"]		= "Super Duper Macro",
	["Super Duper Macro send1"]		= "Super Duper Macro",
	["Super Duper Macro send2"]		= "Super Duper Macro",
	["SWSudX21"]				= "SW_Stats",
	["SWSHSX21"]				= "SW_Stats",
	["SWSudX22"]				= "SW_Stats",
	["SWSHSX22"]				= "SW_Stats",
	["SWSVC7w7"]				= "SW_Stats",
	["TAL"]					= "LibRockComm-1.0",
	["UnT"]					= "LibRockComm-1.0",
	["VER"]					= "LibRockComm-1.0",
	["Talented"]				= "Talented",
	["TGuide"]				= "Tourguide",
	["TGuideQID"]				= "Tourguide",
	["TGuideWP"]				= "Tourguide",
	["Thr"]					= "Threat-1.0",
	["TitanWG"]				= "Titan Panel [Wintergrasp]",
	["TL2"]					= "Threat-2.0",
	["tomQ2"]				= "tomQuest2",
	["TotemTracker"]			= "TotemTracker",
	["tradeDispenser"]			= "Trade Dispenser",
	["TLDB_-EndDrop"]			= "Trookat's Lootdb",
	["TLDB_-NewDrop"]			= "Trookat's Lootdb",
	["TLDB_-NewMob"]			= "Trookat's Lootdb",
	["TR_K"]				= "Totem Radius",
	["TR_L"]				= "Totem Radius",
	["TSK"]					= "TeamSqueak",
	["TypI"]				= "TypingNotifier",
	["Utopia"]				= "Utopia",
	["Utopia_UpTime"]			= "Utopia",
	["VisualHeal"]				= "VisualHeal",
	["VampArrow-1.0"]			= "Vamp/VampArrow",
	["VA"]					= "VoidReaverAlarm",	-- version check answer
	["VC"]					= "VoidReaverAlarm",	-- version check request
	["CB"]					= "VoidReaverAlarm",	-- 10sec normal mode
	["CT"]					= "VoidReaverAlarm",	-- 60sec test mode
	["VodkaHoldem"]				= "WoWTexasHoldem",
	["Warden-Banned"]			= "Guild Warden",
	["Warden-Left"]				= "Guild Warden",
	["Warden-Player"]			= "Guild Warden",
	["WGA"]					= "Wintergrasper Advanced",
	["WgFu"]				= "FuBar_WintergraspFu",
	["WGTime"]				= "Capping",	-- Wintergrasp-Sync
	["WIM"]					= "WoW Instant Messenger",
	["WIM_W2W"]				= "WoW Instant Messenger",
	["WintergraspT"]			= "WinterTime",
	["WL_LOOT_COOLDOWN"]			= "Wowhead Looter",  
	["WL_LOOTCOOLDOWN_NPC"]			= "Wowhead Looter",
	["WL_LOOTCOOLDOWN_OBJECT"]		= "Wowhead Looter",
	["WL_LOOTED_NPC"] 			= "Wowhead Looter",
	["WPNet"]				= "WoW Porty 2",
	["WQ2"]					= "WoWQuote2",
	["WRUGSAUTH"]				= "WRUGS Anti-Spam",
	["YRT2"]				= "YamRaidTracker2",
}

namespace.prefixes = KNOWN_PREFIXES