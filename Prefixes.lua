local _, namespace = ...

-- These are partial-match prefixes.
local MATCHED_PREFIXES = {
	["^$Tranq"]	 = "SimpleTranqShot",
	["^vgcomm"]	 = "VGComms",
	["^CC_"]	 = "ClassChannels",
}

namespace.matched_prefixes = MATCHED_PREFIXES


-- These prefixes are full matches.
local KNOWN_PREFIXES = {
	["_AMR"]					= "AskMrRobot",
	[")\252$"]					= "AceComm [VersionCheck]",	-- Hash of "Version". VersionChecker also uses
	[".\136="]					= "Proximo",
	["2\224\237"]					= "Cartographer [Guild Positions]",
	["8\206\194"]					= "VoiceFU",
	["<<PiraCore>>"]				= "PiraMod",
	["<AFKTracker> Check Version"]			= "AFKTracker",
	["AAVLookupBroadcast"]				= "Atrox Arena Viewer",
	["AGC"]						= "AthenesGearCheck",
	["AKAT2_"]					= "AKA",
	["ALF_T"]					= "Arena Live Frames",
	["AM_FU"]					= "AlphaMap",
	["ATF"]						= "AutoFIR",
	["ATR"]						= "Auctionator",
	["ATf"]						= "AutoFIR",
	["ATm"]						= "AutoFIR",
	["AVR"]						= "Augmented Virtual Reality",
	["AVRE-1.0"]					= "AVR Encounters",
	["Absorbs_Scaling"]				= "LibAbsorbsMonitor-1.0",
	["Absorbs_UnitStats"]				= "LibAbsorbsMonitor-1.0",
	["AlgalonObserver"]				= "AlgalonObserver",
	["AltoGuild"]					= "Altoholic",
	["Altoholic"]					= "Altoholic",
	["ArenaMaster"]					= "Arena Master",
	["ArenaUnitFrames"]				= "Arena Unit Frames",
	["Armory"]					= "Armory",
	["AthenesUpgradeEstimator DPS"]			= "Athene's Upgrade Estimator",
	["AthenesUpgradeEstimator dpsUpgrade"]		= "Athene's Upgrade Estimator",
	["AthenesUpgradeEstimator healUpgrade"]		= "Athene's Upgrade Estimator",
	["AucAdvAskPrice"]				= "Auctioneer",
	["Audio Effects"]				= "AFX",
	["AudioX"]					= "AudioX (Who)",
	["BBReady"]					= "BigBrother_Ready",
	["BDKP-ATT-M"]					= "BananaDKP",
	["BDKP-ATT-S"]					= "BananaDKP",
	["BDKP-DKP-M"]					= "BananaDKP",
	["BDKP-DKP-S"]					= "BananaDKP",
	["BDKP-REQ"]					= "BananaDKP",
	["BE2"]						= "BossEncounter2",
	["BEJ2a"]					= "Bejeweled",
	["BEJEWELED2"]					= "Bejeweled",
	["BFC"]						= "Battlefield Commander",
	["BG General*"]					= "Battleground General",
	["BGGQ"]					= "Gladiator",
	["BGSAlertsVersion"]				= "BGSoundAlerts 2",
	["BLSS"]					= "Blessed",
	["BMT"]						= "Black Market Tracker",
	["BOOTYCALL"]					= "BootyCall (Jaycyn)",
	["BOSSTACTICS"]					= "BossTactics",
	["BST"]						= "Bonstar",
	["BTC"]						= "BootyCall (Rabbit)",
	["BWOOD"]					= "BigWigs",	-- BigWigs version broadcast
	["BWOOD3"]					= "BigWigs3",
	["BWTIP"]					= "BigWigs3",
	["BWVB"]					= "BigWigs",	-- BigwWigs version query
	["BWVB2"]					= "BigWigs",	-- BigWigs version query v2
	["BWVQ"]					= "BigWigs",	-- BigWigs version query
	["BWVQ3"]					= "BigWigs3",
	["BWVR"]					= "BigWigs",	-- BigWigs version response
	["BWVR3"]					= "BigWigs3",
	["BWVRA3"]					= "BigWigs3",
	["BangCore_TPO"]				= "Bang!Core",
	["BangWG5"]					= "BangWintergrasp",
	["BeastTraining"]				= "BeastTraining",
	["BigBrother"]					= "Big Brother",
	["BigWigs"]					= "BigWigs",
	["BossNotes"]					= "Boss Notes",
	["BrokerEpicAvg"]				= "Broker:EpicAvg",
	["BrokerCPUREV"]				= "Broker:CPU",
	["Broker_GuildMoney"]				= "Broker_GuildMoney",
	["Broker_TBTime"]				= "Broker TBTime (Tol Barad)",
	["CB"]						= "VoidReaverAlarm",	-- 10sec normal mode
	["CFUVCQ"]					= "FuBar_ConvergeFU",
	["CFUVCR"]					= "FuBar_ConvergeFU",
	["CGP"]						= "Cartographer [Guild Positions]",
	["CKICK_SYNC"]					= "Ckick",
	["CRT"]						= "Curse Raid Tracker",
	["CRT_Att"]					= "Curse Raid Tracker (Attendance)",
	["CRT_Bid"]					= "Curse Raid Tracker (Bidding)",
	["CRT_Pts"]					= "Curse Raid Tracker (Points)",
	["CT"]						= "VoidReaverAlarm",	-- 60sec test mode
	["CT3"]						= "Cartographer 3",
	["CTRA"]					= "CTRaidAssist",
	["CaN"]						= "Cartographer [Notes]",
	["Cap"]						= "Capping_v3.2.002+",	-- new IoC siege sync
	["CastCommLib"]					= "CastCommLib",
	["Crafts"]					= "Crafts",
	["Crb"]						= "CarboniteQuest",
	["D4"]						= "DeadlyBossMods_V4.1(r5415+)", --used for the wow 4.1 compatible Version since 4.75-r5415
	["D?"]						= "ControlArena",
	["DBM3Alterac"]					= "DeadlyBossMods_V3",
	["DBM3Arathi"]					= "DeadlyBossMods_V3",
	["DBMv4-CombatInfo"]				= "DeadlyBossMods_V4",
	["DBMv4-Kill"]					= "DeadlyBossMods_V4",
	["DBMv4-Mod"]					= "DeadlyBossMods_V4",
	["DBMv4-Pizza"]					= "DeadlyBossMods_V4",
	["DBMv4-Pull"]					= "DeadlyBossMods_V4",
	["DBMv4-RequestTimers"]				= "DeadlyBossMods_V4",
	["DBMv4-TimerInfo"]				= "DeadlyBossMods_V4",
	["DBMv4-Ver"]					= "DeadlyBossMods_V4",
	["DPD2"]					= "Doodlepad",
	["DPM"]						= "Deadly Pvp Mods",
	["DPMcheck"]					= "Deadly Pvp Mods",
	["DPMtrue"]					= "Deadly Pvp Mods",
	["DPMversion"]					= "Deadly Pvp Mods",
	["DQT"]						= "DaylieQuestViewer",
	["DRA2"]					= "DruidRaidAssist2",
	["DRA2_ASK"]					= "DruidRaidAssist2",
	["DS_Cont"]					= "DataStore",
	["DS_Craft"]					= "DataStore",
	["DS_Inv"]					= "DataStore",
	["DS_Mails"]					= "DataStore",
	["DTM"]						= "DiamondThreatMeter",
	["DTMR"]					= "DoTimer",
	["DXE"]						= "Deus Vox Encounters",
	["DXE_Dist8"]					= "Deus Vox Encounters",
	["DamageMeters"]				= "DamageMeters",
	["DataStore"]					= "DataStore",
	["Death_Tracker"]				= "Death_Tracker",
	["DecursiveVersion"]				= "Decursive",
	["DoIKnowYou"]					= "DoIKnowYou",
	["EAILT"]					= "Equipped Average Item Level",
	["EASYMOTHER"]					= "EasyMother",
	["EFailsWotLK"]					= "EnsidiaFailsWotLK",
	["ElvUIPluginVC"]				= "ElvUI",
	["ElvUIVC"]					= "ElvUI",
	["ELVUI_VERSIONCHK"]		= "ElvUI",
	["ElvSays"]					= "ElvUI", --developer joke?
	["ELITG"]					= "ElitistGroup",
	["EPGP"]					= "epgp (dkp reloaded)",
	["EPGPLMVChk"]					= "EPGPLootmaster",
	["EPGPLMVHdlr"]					= "EPGPLootmaster",
	["EPGPLMVRsp"]					= "EPGPLootmaster",
	["EPGPLootMasterC"]				= "EPGPLootmaster",
	["EPGPLootMasterML"]				= "EPGPLootmaster",
	["EnsidiaFails"]				= "EnsidiaFails",
	["EnsidiaFailsWotLK"]				= "EnsidiaFailsWotLK",
	["ExaminerGlyphs"]				= "Examiner",
	["FBAM"]					= "Fishing Buddy",
	["FX2"]						= "ForteXorcist",
	["ForteWarlock"]				= "ForteXorcist",
	["G2G"]						= "Guild2Guild",
	["GC3"]						= "GroupCalendar",
	["GC3/"]					= "GroupCalendar",  -- Does this one actually get sent?
	["GC4"]						= "GroupCalendar",
	["GC4/"]					= "GroupCalendar",  -- Does this one actually get sent?
	["GC5"]						= "GroupCalendar",
	["GDALootlist"]					= "GetDKP",
	["GEM3"]					= "GuildEventManager",
	["GHI"]						= "Gryphonheart Items",
	["GHI2"]					= "Gryphonheart Items",
	["GHOSTRECON"]					= "Ghost: Recon",
	["GLDG"]					= "GuildGreet",
	["GLDR"]					= "Guilder",
	["GM2SD"]					= "GatherMate2",
	["GMSD"]					= "GatherMate1",
	["GRoster"]					= "GuildRoster",
	["GS4x_Data"]					= "GearScore",
	["GS4y_Data"]					= "GearScore",
	["GSY_Version"]					= "GearScore",
	["GSX"]						= "GearScore",
	["GSY"]						= "GearScore",
	["GSY_Request"]					= "GearScore",
	["GSY_Version"]					= "GearScore",
	["GTFO"]					= "GTFO",
	["GTH"]						= "Getting Things Healed",
	["GUILDMAP"]					= "GuildMap",
	["GathX"]					= "Gatherer",
	["Gatherer"]					= "Gatherer",
	["GearScore"]					= "GearScore",
	["GearScoreRecount"]				= "GearScore",
	["GearScore_Request"]				= "GearScore",
	["GearScore_Send"]				= "GearScore",
	["GearScore_Version"]				= "GearScore",
	["GoGoMountVER"]				= "GoGoMount",
	["GuildCraft3"]					= "Guild Craft",
	["GuildCraft35"]				= "Guild Craft",
	["GUILD_SHIELD"]				= "GuildShield",
	["GuildSpyVersion"]				= "GuildSpy",
	["GupPetVersion"]				= "GupPet",
	["H"]						= "DeadlyBossMods_V4.1(r5415+)", --used for the wow 4.1 compatible Version since 4.75-r5415 (PvP Module)
	["HIVE"]					= "HiveMind",
	["HUD"]						= "HudMap",
	["HealBot"]					= "HealBot",
	["HealBot_GUID"]				= "HealBot",
	["HealBot_Heals"]				= "HealBot",
	["HealComm"]					= "LibHealComm-3.0",	-- or version2, you cant tell them apart
	["HermesR1"]					= "Hermes",
	["HermesS1"]					= "Hermes",
	["I_HAVE_SHIELD"]				= "GuildShield",
	["IHL"]						= "IncomingHealsLib-1.0",
	["JambaCommunicationsCommand"]			= "Jamba",	-- multiboxing tool
	["KALIFCMSG"]					= "Forecast",
	["KARMA"]					= "Karma",
	["KHP_deamon"]					= "Kalecgos Dual HP",
	["KHP_dragon"]					= "Kalecgos Dual HP",
	["KLHALG"]					= "KLHAlgalon",
	["KLHTM"]					= "KLHThreatMeter",
	["LGIST1"]					= "LibGroupInspecT",
	["LGP"]						= "LibGuildPositions-1.0",
	["LGT-1.0"]					= "LibGroupTalents-1.0",
	["LHC40"]					= "LibHealComm-4.0",
	["LOOT_OPENED"]					= "AceEvent-2.0 [Loot Opened]",
	["LPH10"]					= "LibPendingHeals-1.0",
	["LRW2"]					= "LiveRaidWatch_v2",
	["LVBM NSP"]					= "Deadly Boss Mods",
	["LVBM"]					= "Deadly Boss Mods",
	["LVFH MARK"]					= "Deadly Boss Mods",
	["LVFH VOID"]					= "Deadly Boss Mods",
	["LVGWF ENRAGE"]				= "Deadly Boss Mods",
	["LVNEF"]					= "Deadly Boss MOds",
	["LibGroupTalents-1.0"]				= "LibGroupTalents-1.0",
	["LibGuildStorage-1.0"]				= "LibGuildStorage-1.0",
	["LibSyncTimeSC"]				= "LibSyncTime-1.0",
	["LibSyncTimeRQ"]				= "LibSyncTime-1.0",
	["LibVersionCheck"]				= "LibVersionCheck-1.0",
	["Libzz"]					= "Libzz",
	["Lockdown0005Hello"]				= "Lockdown",
	["Lockdown0005NewLock"]				= "Lockdown",
	["Lockdown0005Wipe"]				= "Lockdown",
	["LockdownUpdate"]				= "Lockdown",
	["LootFilter"]					= "LootFilter",
	["LUI_Version"]					= "LUI",
	["MARYSUE"]					= "MarySue",
	["MLRA"]					= "CT_RaidTracker",
	["MS1"]						= "MinnaStats",
	["MSP"]						= "MyRolePlay",
	["MVIT"]					= "MoveItMoveIt",
	["MYC"]						= "MakeYourChoice",
	["MageMajic"]					= "MageMajic",
	["MagicMarker"]					= "MagicMarker",
	["MagicMarkerRT"]				= "MagicMarker",
	["MalygosFlamer"]				= "MalygosFlamer",
	["MalygosFlamerVersion"]			= "MalygosFlamer",
	["MeBo"]					= "MessageBoard",	-- most likely
	["MorgBid2"]					= "MorgBid2",
	["MorgDKP2MorgBid"]				= "MorgDKP2",
	["MorgDKP2Syncing"]				= "MorgDKP2",
	["MultiBoxer"]					= "MultiBoxer",
	["NECB"]					= "Natur EnemyCastBar",
	["NECBCHAT"]					= "Natur EnemyCastBar",
	["NECBCTRA"]					= "Natur EnemyCastBar",
	["Nurfed:Lyt"]					= "Nurfed Layout",
	["OpenRaid"]					= "OpenRaid",
	["Ovale"]					= "Ovale",
	["OQ"]						= "oQueue",
	["PAB935ndd8xid"]				= "Party Ability Bars",
	["PABkd8cjnwuid"]				= "Party Ability Bars",
	["PABx39dkes8xj"]				= "Party Ability Bars",
	["PALB"]					= "Paladin Buffer",
	["PLPWR"]					= "PallyPower",
	["PS-marksoff"]					= "Phoenix Style",
	["PS-myvers"]					= "Phoenix Style",
	["PSaddmod"]					= "Phoenix Style",
	["PSaddon"]					= "Phoenix Style",-- since v1.5302
	["PSplag"]					= "Phoenix Style",
	["PSplag2"]					= "Phoenix Style",
	["PartyCastingBars"]				= "PartyCastingBars",
	["PetEmote"]					= "PetEmote",
	["PetShopSync"]					= "Pet Shop",
	["PhoenixStyle"]				= "Phoenix Style",
	["PhoenixStyle_info"]				= "Phoenix Style",
	["Piece of Justice"]				= "Piece of Justice",
	["Pit"]						= "PitBull",
	["PreformAVEnabler"]				= "PreformAVEnabler",
	["QCOMPLETIST"]					= "Quest Completist",
	["QHpr"]					= "QuestHelper",
	["QQ6"]						= "TooltipExchange",  -- TooltipExchange protocol 6
	["QuGu"]					= "Quest Guru",
	["Quecho"]					= "Quecho",
	["Quecho2"]					= "Quecho",	-- turned in
	["Quecho3"]					= "Quecho",	-- accepted
	["QuestAnnouncer"]				= "QuestAnnouncer",
	["Quixote2"]					= "LibQuixote-2.0",
	["RA-myvers"]					= "RaidAchievement",
	["RAB/BI"]					= "RABuffs",
	["RAB/BR"]					= "RABuffs",
	["RAB/BS"]					= "RABuffs",
	["RAB/BT"]					= "RABuffs",
	["RAB/RD"]					= "RABuffs",
	["RAB/RE"]					= "RABuffs",
	["RAB/RF"]					= "RABuffs",
	["RAB/RN"]					= "RABuffs",
	["RAB/RO"]					= "RABuffs",
	["RAB/V"] 					= "RABuffs",
	["RAB/VC"]					= "RABuffs",
	["RAIDMOBMARKER"]				= "RaidMobMarker",
	["RAIDTOTEMS"]					= "TotemTimers",
	["RAIDVOICE"]					= "RaidVoice",
	["RAother"]					= "RaidAchievement",
	["RBA"]						= "RatedBattlegroundAssist",
	["RBM"]						= "RBM",
	["RBMPing"]					= "RobBossMods",
	["RBMPong"]					= "RobBossMods",
	["RBMVersion"]					= "RobBossMods",
	["RBS"]						= "RaidBuffStatus",
	["RCD2"]					= "RaidCooldowns",
	["RD"]						= "RogueDamage",
	["RDX"]						= "OpenRDX",
	["RECOUNT"]					= "Recount",
	["REFlex"]					= "REFlex - Arena/Battleground Historian",
	["RID"]						= "Raid ID",
	["RRL"]						= "Raid Roll",
	["RSCaddon"]				= "RaidSlackCheck",
	["RSCb"]					= "RaidSlackCheck",
	["RSCf"]					= "RaidSlackCheck",
	["RSCfs1"]					= "RaidSlackCheck",
	["RSCfs2"]					= "RaidSlackCheck",
	["RTM"]						= "RezzTextMonitor",
	["RW2"]						= "Raid Watch 2",
	["R\195\159"]				= "RecipeBook",
	["RaCD"]					= "RaidCooldowns",
	["RaidAc"]					= "RaidAchievement",
	["RaidAchievement"]			= "RaidAchievement",
	["RaidAchievement_info"]	= "RaidAchievement",
	["RaidAchievement_info2"]	= "RaidAchievement",
	["RaidForge"]				= "RaidForge",
	["RankWatch"]				= "RankWatch",
	["Recap"]					= "Recap",
	["Rupture"]					= "Rupture",
	["SAYell"]					= "Say Announcer",
	["SGI_LIVE_SYNC"]			= "SuperGuildInvite",
	["SGI_LOCK"]				= "SuperGuildInvite",
	["SGI_MASS"]				= "SuperGuildInvite",
	["SGI_PING"]				= "SuperGuildInvite",
	["SGI_PONG"]				= "SuperGuildInvite",
	["SGI_REQ"]					= "SuperGuildInvite",
	["SGI_STOP"]				= "SuperGuildInvite",
	["SGI_VERSION"]				= "SuperGuildInvite",
	["SGLC"]					= "SurgeonGeneral",
	["ShestakUIVersion"]		= "ShestakUI",
	["SMN"]						= "SpamMeNot",
	["SPOONERROLE"]				= "Spooner",
	["SRA"]						= "SRA",
	["SRTI"]					= "Simple Raid Target Icons",
	["SRTi"]					= "Simple Raid Target Icons",
	["SSAF"]					= "SSArena Frames",
	["SSN"]						= "SpeakinSpell",
	["SSPVP"]					= "SSPVP",
	["SWSHSX21"]					= "SW_Stats",
	["SWSHSX22"]					= "SW_Stats",
	["SWSVC7w7"]					= "SW_Stats",
	["SWSudX21"]					= "SW_Stats",
	["SWSudX22"]					= "SW_Stats",
	["SimpleMD"]					= "SimpleMD",
	["Skadoosh"]					= "Skadoosh",
	["SmartRes"]					= "SmartRes",
	["SorrenTimers"]				= "SorrenTimers",
	["SquidFrame"]					= "SquidFrame",
	["StinkyQ"]					= "StinkyQueue",
	["Super Duper Macro query"]			= "Super Duper Macro",
	["Super Duper Macro recDone"]			= "Super Duper Macro",
	["Super Duper Macro recFailed"]			= "Super Duper Macro",
	["Super Duper Macro receiving"]			= "Super Duper Macro",
	["Super Duper Macro response"]			= "Super Duper Macro",
	["Super Duper Macro send1"]			= "Super Duper Macro",
	["Super Duper Macro send2"]			= "Super Duper Macro",
	["Super Duper Macro sendFailed"]		= "Super Duper Macro",
	["TAL"]						= "LibRockComm-1.0",
	["TGuide"]					= "Tourguide",
	["TGuideQID"]					= "Tourguide",
	["TGuideWP"]					= "Tourguide",
	["TL2"]						= "Threat-2.0",
	["TLDB_-EndDrop"]				= "Trookat's Lootdb",
	["TLDB_-NewDrop"]				= "Trookat's Lootdb",
	["TLDB_-NewMob"]				= "Trookat's Lootdb",
	["TMW"]						= "TellMeWhen",
	["TMWSUG"]					= "TellMeWhen",
	["TMWV"]					= "TellMeWhen",
	["TMW_CSC_25"]				= "TellMeWhen",
	["TR_K"]					= "Totem Radius",
	["TR_L"]					= "Totem Radius",
	["TSK"]						= "TeamSqueak",
	["Talented"]					= "Talented",
	["Thr"]						= "Threat-1.0",
	["TitanWG"]					= "Titan Panel [Wintergrasp]",
	["TotemTracker"]				= "TotemTracker",
	["TukuiVersion"]				= "Tukui",
	["TypI"]					= "TypingNotifier",
	["UnT"]						= "LibRockComm-1.0",
	["Utopia"]					= "Utopia",
	["Utopia_UpTime"]				= "Utopia",
	["VA"]						= "VoidReaverAlarm",	-- version check answer
	["VC"]						= "VoidReaverAlarm",	-- version check request
	["VER"]						= "LibRockComm-1.0",
	["VampArrow-1.0"]				= "Vamp/VampArrow",
	["VisualHeal"]					= "VisualHeal",
	["VodkaHoldem"]					= "WoWTexasHoldem",
	["WGA"]						= "Wintergrasper Advanced",
	["WGTime"]					= "Capping",	-- Wintergrasp-Sync
	["WIM"]						= "WoW Instant Messenger",
	["WIM_W2W"]					= "WoW Instant Messenger",
	["WL_LOOTCOOLDOWN_NPC"]				= "Wowhead Looter",
	["WL_LOOTCOOLDOWN_OBJECT"]			= "Wowhead Looter",
	["WL_LOOTED_NPC"] 				= "Wowhead Looter",
	["WL_LOOT_COOLDOWN"]				= "Wowhead Looter",
	["WPNet"]					= "WoW Porty 2",
	["WQ2"]						= "WoWQuote2",
	["WRUGSAUTH"]					= "WRUGS Anti-Spam",
	["Warden-Banned"]				= "Guild Warden",
	["Warden-Left"]					= "Guild Warden",
	["Warden-Player"]				= "Guild Warden",
	["WgFu"]					= "FuBar_WintergraspFu",
	["WintergraspT"]				= "WinterTime",
	["X-Perl"]					= "X-Perl",
	["X-PerlHeal"]					= "X-Perl",
	["XChar"]					= "XChar-Profiler",
	["YRT2"]					= "YamRaidTracker2",
	["Yacl"]					= "YACL-DmgMeter",
	["[HA]"]					= "HealAssign",
	["[Spy]"]					= "Spy",
	["\130\131\213"]				= "Boss Talk",
	["\143\019\007"]				= "SpamMeNot",
	["\1484\008"]					= "VanasKoS",
	["\1613["]					= "BagPress",
	["\1675B"]					= "Recap",
	["\1813T"]					= "Recount",
	["\198\137h"]					= "Violation",
	["\198\232\192"]				= "Cooldown Timers 2",
	["\229^\092"]					= "ZOMGBuffs",
	["\234\218\230"]				= "Gladiator",
	["\252\245G"]					= "QuestsFu",
	["^RX^"]					= "Prescription_Pickup",
	["cap"]						= "Capping",
	["chatmod"]					= "ChatMOD",
	["dgks_BGVersionCheckRequest"]			= "dG Killshot Notifier",
	["dgks_GuildVersionCheckRequest"]		= "dG Killshot Notifier",
	["dgks_KillSoundEvent"]				= "dG Killshot Notifier",
	["dgks_RaidVersionCheckRequest"]		= "dG Killshot Notifier",
	["dgks_ScrollingTextEvent"]			= "dG Killshot Notifier",
	["dgks_VersionCheckResponse"]			= "dG Killshot Notifier",
	["dgks_txt"]					= "dG Killshot Notifier",
	["eXtremeRaid"]					= "OnRaid",
	["eov_version_message"]				= "An eye on viper",
	["gqAccept"]					= "Guild Quests",
	["gqLogout"]					= "Guild Quests",
	["gqRemove"]					= "Guild Quests",
	["gqReply"]					= "Guild Quests",
	["h\031Y"]					= "InventoryLib-2.0",
	["hbComms"]					= "HealBot_Ultra_low_comms",
	["hbGUID"]					= "HealBot",
	["kEl"]						= "DalaranUniversity",
	["k\227D"]					= "GPSLib",
	["kshot_BG_Death_ScrollingTextEvent"]		= "Killshot",
	["kshot_BG_Death_SoundEvent"]			= "Killshot",
	["kshot_BG_Kill_ScrollingTextEvent"]		= "Killshot",
	["kshot_BG_Kill_SoundEvent"]			= "Killshot",
	["kshot_BG_MultiKill_ScrollingTextEvent"]	= "Killshot",
	["kshot_BG_MultiKill_SoundEvent"]		= "Killshot",
	["kshot_GuildVersionCheckRequest"]		= "Killshot",
	["kshot_Guild_Death_ScrollingTextEvent"]	= "Killshot",
	["kshot_Guild_Death_SoundEvent"]		= "Killshot",
	["kshot_Guild_KillSoundEvent"]			= "Killshot",
	["kshot_Guild_Kill_ScrollingTextEvent"]		= "Killshot",
	["kshot_Guild_Kill_SoundEvent"]			= "Killshot",
	["kshot_Guild_MultiKill_ScrollingTextEvent"]	= "Killshot",
	["kshot_Guild_MultiKill_SoundEvent"]		= "Killshot",
	["kshot_Guild_ScrollingTextEvent"]		= "Killshot",
	["kshot_Guild_VersionCheckRequest"]		= "Killshot",
	["kshot_RaidVersionCheckRequest"]		= "Killshot",
	["kshot_Raid_Death_ScrollingTextEvent"]		= "Killshot",
	["kshot_Raid_Death_SoundEvent"]			= "Killshot",
	["kshot_Raid_KillSoundEvent"]			= "Killshot",
	["kshot_Raid_Kill_ScrollingTextEvent"]		= "Killshot",
	["kshot_Raid_Kill_SoundEvent"]			= "Killshot",
	["kshot_Raid_MultiKill_ScrollingTextEvent"]	= "Killshot",
	["kshot_Raid_MultiKill_SoundEvent"]		= "Killshot",
	["kshot_Raid_ScrollingTextEvent"]		= "Killshot",
	["kshot_Raid_VersionCheckRequest"]		= "Killshot",
	["kshot_StreakAnnounceEvent"]			= "Killshot",
	["kshot_VersionCheckResponse"]			= "Killshot",
	["lugMD"]					= "lugMD",
	["mmkocomm"]					= "MM Kill Order",	--check!
	["oRA"]						= "oRA2",
	["oRA3"]					= "oRA3",
	["p\190\246"]					= "SimpleMD",
	["tomQ2"]					= "tomQuest2",
	["tradeDispenser"]				= "Trade Dispenser",
	["vG"]						= "Battleground General",	-- AlteracModule
	["\137\016"]					= "Cartographer [Notes]",
}

namespace.known_prefixes = KNOWN_PREFIXES
