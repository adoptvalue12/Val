local k={Farm={Enabled=false;BabyMode=false;AutoNeeds={Enabled=false;Skip=
{}},KeepPetEquipped=false,PreferNeon=true;PetOrder="youngest",FarmPetKinds=
{},BuyEgg=false,EggToBuy="cracked_egg",Focus="";AutoPotions={Enabled=false,Skip={}};AutoNeon=
{Enabled=false,Mega=false},CollectCashback=false,AutoOpen=
{Enabled=false};AutoAcceptMenu=false,AntiAfk=true,CameraGuard=true,AutoRejoin=false,SpotTravel="tel
eport";GameTravel=true;HomeByRespawn=true;FoodBowlTrip=false,StuckRecovery=
{Enabled=true,Seconds=240},DisableMinutes=15,Event=
{GhostGallery=false,Hauntlet=false;HauntletMove="tween";HauntletMoveSeconds=.5;HauntletFirst=true;U
sePrompt=true,GhostJoinByZone=true;StrayCat=false,Crypt=false;MummySpider=true,CryptOpen=
{"ladder"};PigeonNest=false,AutoNest=false,AutoSkelicorn=false;CandyPets={Enabled=false;Pick=
{};MaxBuy=false;KeepCandy=0,KeepBucks=0;Buy={{id="halloween_2026_jump_scare";price=40000;max=1},
{id="halloween_2026_jacobean_pigeon";price=4000,max=4};
{id="halloween_2026_skelicorn",price=120000;max=0,machine=true}}};Quests=false;HouseVisits=false;Pe
tPen=false;PetPenMinutes=15;PetPenSlots=4,PetPenStock=false,PetPenStockMinBucks=750}};Interface=
{Enabled=true,Keybind="RightShift";Toasts=true;RememberSettings=true,Theme="Halloween";Descriptions
=false,StartHidden=false,Language="Auto"};Logging=
{ConsoleLevel="OFF",FileEnabled=false,SessionFile=false};Telemetry=
{Enabled=false,IncludeInventory=false},Notifications={Enabled=true;Webhooks=
{Summary="",Alerts=""};SummaryIntervalMinutes=30;SendOnTaskComplete=false;SendOnError=true;SendOnKi
ck=true,SendOnStartStop=true,SendTestMessageOnStart=false,PingDiscordUserId="";PingOn=
{Kick=true,Error=true,Summary=true;TaskCompleted=true;SessionStopped=true,PreviousSession=true};Inc
ludeUsername=true}}local P={}local l={}local B={}local function U(k)local Z=l[k]if Z==B then
error("Circular import: "..k,2)end if Z~=nil then return Z end local m=P[k]if not m then
error("Unknown module: "..k,2)end l[k]=B local H=m(U)l[k]=H return H end
P["Core/Enums"]=function(...)local function k(k,P)local l={}for k,P in ipairs(P)do l[P]=P end
return setmetatable(l,{__index=function(P,l)error(string.format("%s.%s is not a valid enum
item",k,tostring(l)),2)end;__newindex=function()error(k.." is read-only",2)end})end local P=
{}P.LogLevel=k("LogLevel",{"DEBUG","INFO";"SUCCESS","WARN","ERROR"})P.LogLevelRank=
{DEBUG=1,INFO=2;SUCCESS=3,WARN=4,ERROR=5;OFF=99}P.NotifyEvent=k("NotifyEvent",
{"SessionStarted","SessionStopped";"Summary";"TaskCompleted";"Error","Kicked","PreviousSessionEnded
","Test"})return P end P["Core/Util"]=function(...)local k=game:GetService("HttpService")local P=
{}function P.now()return os.clock()end function P.getSharedEnvironment()if
type(getgenv)=="function"then return getgenv()end return _G end function P.getRequestFunction()if
type(request)=="function"then return request end if type(http_request)=="function"then return
http_request end if type(syn)=="table"and type(syn.request)=="function"then return syn.request end
if type(http)=="table"and type(http.request)=="function"then return http.request end return nil end
function
P.fileApi()return{canWrite=type(writefile)=="function",canAppend=type(appendfile)=="function";canMa
keFolder=type(makefolder)=="function"and type(isfolder)=="function"}end function
P.ensureFolder(k)local l=P.fileApi()if not l.canMakeFolder then return false end local B=""for k in
string.gmatch(k,"[^/]+")do B=(B=="")and k or(B..("/"..k))local P=pcall(function()if not
isfolder(B)then makefolder(B)end end)if not P then return false end end return true end function
P.jsonEncode(P)local l,B=pcall(function()return k:JSONEncode(P)end)if l then return B end return
nil,tostring(B)end function P.jsonDecode(P)local l,B=pcall(function()return k:JSONDecode(P)end)if l
then return B end return nil,tostring(B)end function P.formatDuration(k)k=math.max(0,math.floor(k
or 0))local P=math.floor(k/3600)local l=math.floor(((k%3600))/60)local B=k%60 return
string.format("%02d:%02d:%02d",P,l,B)end function P.truncate(k,P)k=tostring(k)if#k<=P then return k
end local l=math.max(0,P-3)while l>0 do local P=string.byte(k,l+1)if not P or P<128 or P>=192 then
break end l=l-(1)end return string.sub(k,1,l).."..."end function P.shallowCopy(k)local P={}for k,l
in pairs(k)do P[k]=l end return P end return P end P["Core/Signal"]=function(...)local k=
{}k.__index=k function k.new(P)return setmetatable({_name=P or"Signal";_listeners={}},k)end
function k.Connect(P,k)assert(type(k)=="function","Signal:Connect expects a function")local l=
{handler=k;connected=true}table.insert(P._listeners,l)local B={Connected=true}function
B.Disconnect()if not l.connected then return end l.connected=false B.Connected=false for k,B in
ipairs(P._listeners)do if B==l then table.remove(P._listeners,k)break end end end return B end
function k.Fire(k,...)local P=table.clone(k._listeners)for P,l in ipairs(P)do if l.connected then
local P,B=pcall(l.handler,...)if not P then warn("["..(k._name..("] handler error:
"..tostring(B))))end end end end function k.DisconnectAll(k)for k,P in ipairs(k._listeners)do
P.connected=false end table.clear(k._listeners)end k.Destroy=k.DisconnectAll return k end
P["Core/Maid"]=function(...)local k={}k.__index=k function k.new()return setmetatable({_jobs=
{}},k)end local function P(k)if typeof(k)=="RBXScriptConnection"then return true end return
type(k)=="table"and type(k.Disconnect)=="function"end local function l(k)if type(k)=="function"then
k()elseif type(k)=="thread"then if coroutine.running()~=k then pcall(task.cancel,k)end elseif
P(k)then k:Disconnect()elseif type(k)=="table"and type(k.Destroy)=="function"then k:Destroy()elseif
typeof(k)=="Instance"then k:Destroy()end end function k.Give(P,k)assert(k~=nil,"Maid:Give received
nil")table.insert(P._jobs,k)return k end function k.Clean(k)local B=k._jobs k._jobs={}for k,B in
ipairs(B)do if P(B)then pcall(l,B)end end for k,B in ipairs(B)do if not P(B)then local
k,P=pcall(l,B)if not k then warn("[Maid] cleanup error: "..tostring(P))end end end end
k.Destroy=k.Clean return k end P["Core/Config"]=function(...)local k=...local
P=k("Core/Enums")local l={}l.Defaults={General={ScriptName="Adopt Victims";TickSeconds=.5};Farm=
{Enabled=true,BabyMode=true,FastTravel=true;Tasks=
{pet_me=true,salon=true;bored=true;cat_cafe=true;sleepy=true,dirty=true;toilet=true,hungry=true,thi
rsty=true,play=true;pizza_party=true;school=true,sick=true;camping=true,beach_party=true;mystery=tr
ue;walk=true,ride=true},AutoNeeds={Enabled=false;Skip={}};MultiNeed={Enabled=true;Kinds=

{"pet_me";"hungry";"thirsty";"play"},GapSeconds=1};SmartPriority=true,Priority=
{mystery=51,pet_me=50;hungry=49,thirsty=48;dirty=46,toilet=45;sleepy=44,play=42,sick=47,salon=40;sc
hool=39,pizza_party=38;camping=34;beach_party=33;walk=32,ride=31;cat_cafe=35;bored=30};AutoAcceptMe
nu=false,AntiAfk=true,CameraGuard=true,CollectCashback=false,CashbackMinutes=10,SpotTravel="telepor
t",KeepPetEquipped=false;GameTravel=true;HomeByRespawn=true,HouseDoorExit=false;FoodBowlTrip=false;
SkipFullGrown=true,PetOrder="youngest",BuyEgg=false;EggToBuy="cracked_egg",Focus="",MaxEggBuysPerSe
ssion=0;BuyWater=true;BuyFood=true,MaxBuysPerSession=0;AutoPotions={Enabled=false;Potions=
{"pet_age_potion","tiny_pet_age_potion","pet_bonus_bucks_potion"};Skip={};PetKinds={}};AutoNeon=
{Enabled=false,Mega=false,Exclude=
{}},PreferNeon=true;AutoRejoin=false;StuckRejoinSeconds=180,StuckRecovery=
{Enabled=true,Seconds=240},FarmPetKinds={},AutoOpen={Enabled=false;Exclude={}};Event=
{Enabled=true,GhostGallery=false;Hauntlet=false,HauntletMove="tween";HauntletMoveSeconds=.5,Hauntle
tFirst=true;HauntletSquad=true,HauntletSquadKey="",GhostJoinByZone=true,Crypt=false;MummySpider=tru
e;CryptOpen=
{"ladder"},Quests=false,HouseVisits=false,PigeonNest=false;AutoNest=false;AutoSkelicorn=false;Stray
Cat=false,PetPen=false;PetPenMinutes=15,CandyPets={Enabled=false,Pick={};KeepCandy=0;Buy=
{{id="halloween_2026_jump_scare";price=40000,max=1},
{id="halloween_2026_jacobean_pigeon";price=4000;max=4}}};PetPenSlots=4,PetPenStock=false,PetPenStoc
kMinBucks=750};PetMeFocusSeconds=7,FailureCooldownSeconds=30,MaxConsecutiveFailures=3;DisableMinute
s=15};Interface=
{Enabled=true,Keybind="RightShift";Toasts=true,RememberSettings=true,Theme="Halloween";Descriptions
=false,Autoload="";StartHidden=false;UIScale="Auto";Language="Auto"},Logging=
{ConsoleLevel="INFO",FileLevel="DEBUG",FileEnabled=true;SessionFile=true;Folder="AdoptMeFarm/logs",
FlushSeconds=5;DuplicateWindowSeconds=10,MaxLinesPerSession=20000};Telemetry=
{Enabled=false;Url="",Owner="",SummaryMinutes=30;IncludeInventory=false};Notifications=
{Enabled=false,Webhooks=
{Summary="";Alerts=""},SummaryIntervalMinutes=15,SendOnTaskComplete=false;SendOnError=true;SendOnKi
ck=true;SendOnStartStop=true;SendTestMessageOnStart=false;PingDiscordUserId="";Ping=true;SendSummar
y=true;PingOn=
{Kick=true;Error=false;Summary=false;TaskCompleted=false;SessionStopped=false,PreviousSession=false
};IncludeUsername=true,AlertCooldownSeconds=60,MinSecondsBetweenMessages=2.5,MaxQueueSize=50;MaxRet
ries=3}}local function B()local k={}for P in pairs(l.Defaults.Farm.Tasks)do table.insert(k,P)end
table.sort(k)local P={}for k,l in ipairs(k)do table.insert(P,{"Farm";"Tasks",l})end return P end
l.FEATURE_PATHS={{"Farm";"AutoNeeds";"Enabled"},{"Farm","BabyMode"},{"Farm";"KeepPetEquipped"},
{"Farm";"BuyEgg"};{"Farm";"CollectCashback"},{"Farm";"AutoPotions","Enabled"};
{"Farm";"AutoNeon";"Enabled"};{"Farm";"AutoNeon";"Mega"},{"Farm";"AutoOpen";"Enabled"};
{"Farm","Event";"GhostGallery"};{"Farm";"Event";"Hauntlet"};{"Farm";"Event","Crypt"};
{"Farm","Event","Quests"};{"Farm";"Event";"HouseVisits"},{"Farm","Event","PigeonNest"},
{"Farm";"Event","StrayCat"},{"Farm","Event";"PetPen"};{"Farm";"Event";"PetPenStock"},
{"Farm";"Event";"CandyPets";"Enabled"}}l.PRESET_EXTRA_PATHS={{"Farm","Focus"},
{"Farm";"Event","AutoSkelicorn"},{"Farm";"Event","MummySpider"};{"Farm";"FarmPetKinds"};
{"Farm","AutoPotions","PetKinds"},{"Farm","PetOrder"},{"Farm";"AutoNeeds";"Skip"},
{"Farm","AutoPotions";"Skip"};{"Farm";"Event","CryptOpen"},{"Farm";"Event";"CandyPets";"Pick"}}for
k,P in ipairs(B())do table.insert(l.PRESET_EXTRA_PATHS,P)end local
U="halloween_2026_tomb_spider"local Z={{{"Farm","AutoNeeds";"Enabled"},true}}local function
m(...)local k={}for P,l in ipairs({...})do for P,l in ipairs(l)do table.insert(k,l)end end return k
end local H=m(Z,{{{"Farm","BabyMode"},true},{{"Farm";"KeepPetEquipped"};true};
{{"Farm","BuyEgg"};true}})local Q={{{"Farm";"CollectCashback"};true},
{{"Farm","AutoPotions";"Enabled"};true},{{"Farm","AutoNeon","Enabled"};true};
{{"Farm";"AutoNeon","Mega"};true};{{"Farm";"AutoOpen";"Enabled"};true}}local A=
{{{"Farm";"Event";"GhostGallery"},true};{{"Farm";"Event","Hauntlet"},true},
{{"Farm","Event";"Crypt"},true},{{"Farm","Event";"Quests"};true};
{{"Farm","Event";"HouseVisits"};true},{{"Farm";"Event";"PetPen"},true}}local f=
{{{"Farm";"Event","PigeonNest"};true},{{"Farm";"Event";"StrayCat"},true},
{{"Farm";"Event";"PetPenStock"},true},{{"Farm","Event";"CandyPets","Enabled"};true};
{{"Farm","Event";"CandyPets","Pick"};
{"halloween_2026_jacobean_pigeon";"halloween_2026_jump_scare"}}}l.SPEEDRUN_CHANGES=
{{{"Farm","BuyEgg"};false},{{"Farm","AutoPotions","PetKinds"},{U}};{{"Farm";"FarmPetKinds"};{U}},
{{"Farm";"AutoNeon";"Enabled"};true},{{"Farm";"PreferNeon"};true},{{"Farm","PetOrder"},"oldest"};
{{"Farm";"Event";"GhostGallery"},true};{{"Farm","Event","Crypt"},true},
{{"Farm","Event";"MummySpider"};true},{{"Farm";"Event","Quests"},true},
{{"Farm";"Event";"Hauntlet"};false},{{"Farm";"Event","PigeonNest"};false};
{{"Farm";"Event","StrayCat"};false};{{"Farm";"Event";"CandyPets","Enabled"},false};
{{"Farm","Event";"PetPenStock"},false};{{"Farm","Focus"};U}}local Y="halloween_2026_skelicorn"local
function n(k)return{{{"Farm";"Focus"},k},{{"Farm","AutoNeon";"Enabled"};true},
{{"Farm";"AutoNeon";"Mega"},true},{{"Farm","AutoPotions","Enabled"},true},
{{"Farm","PreferNeon"},true};{{"Farm";"PetOrder"},"oldest"},{{"Farm","Event","PetPen"},true},
{{"Farm";"Event","PetPenStock"},true},{{"Farm","Event";"CandyPets";"Enabled"},false};
{{"Farm","Event","PigeonNest"};false},{{"Farm","Event";"StrayCat"};false}}end l.focusChanges=n
l.SKELICORN_CHANGES=m(n(Y),{{{"Farm";"BuyEgg"};false},{{"Farm";"FarmPetKinds"};{Y}},
{{"Farm";"AutoPotions","PetKinds"};{Y}};{{"Farm","Event";"Crypt"};true},
{{"Farm";"Event";"AutoSkelicorn"},true};{{"Farm";"Event","Hauntlet"};true};
{{"Farm";"Event","GhostGallery"};true}})l.Presets={{id="Off";name="Everything
Off",icon="power";about="Every feature off (the defaults). Anti-AFK and the Play button stay

on.",set={{{"Farm";"Enabled"};false}}};{id="Balanced",name="Full AutoFarm",icon="circlegauge",about="Everything: every need, eggs, potions, neon + mega neon, gifts, cashback, quests and
the whole event.",set=m(H,Q,A,f)};{id="Speedrun";name="Mega Mummy
Spider\'s",icon="rocket";about="Mummy Spiders only: keys straight down the Crypt, every spider
grown (needs, potions, Pet Pen), then neon + mega neon. No eggs, no candy pets, no nest / Stray
Cat.",set=m(H,Q,A,f,l.SPEEDRUN_CHANGES)};{id="Skelicorn",name="Mega
Skelicorn",icon="sparkles",about="Skelicorns only: candy from the whole event, Lightning Lever from
the Crypt, a Skelicorn every 120k candy (up to 5 growing), grown + neon + mega
neon.";set=m(H,Q,A,l.SKELICORN_CHANGES)};{id="Focus",name="Mega a
Pet",icon="crosshair";pick=true;about="Pick one pet or egg below. Egg: bought and hatched on
repeat. Candy pet: 5 bought (1 raised, 4 in the Pet Pen). Any pet: grown, neon, mega neon on
repeat, its copies in the Pet Pen.",set=m(H,Q,A,n(""))};{id="EventOnly";name="Event
Only";icon="ghost",about="Only Halloween: Ghost Gallery, Crypt + Mummy Spider, quests, Pet Pen. No
pet / baby needs.",set=A};{id="NeedsOnly";name="Needs Only",icon="list-checks";about="Only pet +
baby needs (with eggs when nothing grows). The event stays off.",set=H}}function l.findPreset(k)if
type(k)~="string"then return nil end local P=string.lower((string.gsub(k,"[%s_%-]","")))for k,l in
ipairs(l.Presets)do if string.lower(l.id)==P or string.lower((string.gsub(l.name,"[%s_%-]","")))==P
then return l end end return nil end local function L(k)if type(k)~="table"then return k end local
P={}for k,l in pairs(k)do P[k]=L(l)end return P end local function b(k,P)local l=k for k=1,#P,1 do
if type(l)~="table"then return nil end l=l[P[k]]end return l end l.valueAt=b function
l.presetValues(k,P)local B=l.findPreset(k)if not B then return nil end local Z={}for k,P in
ipairs({l.FEATURE_PATHS,l.PRESET_EXTRA_PATHS})do for k,P in ipairs(P)do table.insert(Z,
{P,L(b(l.Defaults,P))})end end for k,P in ipairs(B.set)do table.insert(Z,{P[1],L(P[2])})end if
B.pick then local k=type(P)=="string"and P or""table.insert(Z,{{"Farm";"Focus"};k})local
l=string.match(k,"_egg$")~=nil if k~=""and not l then table.insert(Z,{{"Farm","FarmPetKinds"},
{k}})table.insert(Z,{{"Farm";"AutoPotions";"PetKinds"},{k}})table.insert(Z,
{{"Farm";"BuyEgg"};false})elseif k~=""then table.insert(Z,{{"Farm";"BuyEgg"},true})table.insert(Z,
{{"Farm","EggToBuy"},k})table.insert(Z,{{"Farm","PetOrder"};"youngest"})end if k==U or k==Y then
table.insert(Z,{{"Farm","Event","Crypt"},true})table.insert(Z,
{{"Farm";"Event";"MummySpider"},true})end if k==Y then table.insert(Z,
{{"Farm","Event";"AutoSkelicorn"},true})end end return Z,B end function l.countFeatures(k)local P=0
for l,B in ipairs(l.FEATURE_PATHS)do if b(k,B)==true then P=P+(1)end end return P,#l.FEATURE_PATHS
end local M=P.LogLevelRank local function O(k)if k==""then return true end return
string.match(k,"^https://discord%.com/api/webhooks/%d+/[%w%-_]+$")~=nil or
string.match(k,"^https://discordapp%.com/api/webhooks/%d+/[%w%-_]+$")~=nil or
string.match(k,"^https://canary%.discord%.com/api/webhooks/%d+/[%w%-_]+$")~=nil or
string.match(k,"^https://ptb%.discord%.com/api/webhooks/%d+/[%w%-_]+$")~=nil end
l.isValidWebhookUrl=O local function C(k)if type(k)~="table"then return false end local P=0 for k
in pairs(k)do P=P+(1)end return P==#k end local function G(k,P,l,B)local U={}for k,Z in pairs(k)do
local m=P and P[k]local H=l==""and k or(l..("."..k))if C(Z)and C(m)then U[k]=table.clone(m)continue
end if type(Z)=="table"then if m~=nil and type(m)~="table"then table.insert(B,H.." must be a table;
default used")m=nil end U[k]=G(Z,m,H,B)elseif m==nil then U[k]=Z elseif type(m)~=type(Z)then
table.insert(B,string.format("%s must be a %s (got %s); default used",H,type(Z),type(m)))U[k]=Z
else U[k]=m end end if type(P)=="table"then for P in pairs(P)do if k[P]==nil then local k=l==""and
tostring(P)or(l..("."..tostring(P)))table.insert(B,"Unknown setting ignored: "..k)end end end
return U end function l.build(k)local P={}local B=l.Defaults local U=k or{}local Z if
type(U)=="table"and U.Preset~=nil then local k,m=l.presetValues(U.Preset,type(U.Farm)=="table"and
U.Farm.Focus or nil)if k then Z=m.id B=L(l.Defaults)for k,P in ipairs(k)do local l=b(B,
{table.unpack(P[1],1,#P[1]-1)})if type(l)=="table"then l[P[1][#P[1]]]=P[2]end end elseif
U.Preset~=""then table.insert(P,"Preset \'"..(tostring(U.Preset).."\' is not a preset (Off,
Balanced, Speedrun, Skelicorn, Focus, EventOnly, NeedsOnly); none used"))end
U=table.clone(U)U.Preset=nil end local m=G(B,U,"",P)m.Preset=Z for k,l in
ipairs({"ConsoleLevel";"FileLevel"})do local B=string.upper(m.Logging[l])if M[B]==nil then
table.insert(P,"Logging."..(l.." is not a valid level; INFO used"))B="INFO"end m.Logging[l]=B end
local H=m.Notifications for k,l in pairs(H.Webhooks)do if not O(l)then
table.insert(P,"Notifications.Webhooks."..(k.." is not a Discord webhook URL;
disabled"))H.Webhooks[k]=""end end if H.PingDiscordUserId~=""and not
string.match(H.PingDiscordUserId,"^%d+$")then table.insert(P,"Notifications.PingDiscordUserId must
contain digits only; pings disabled")H.PingDiscordUserId=""end if H.SummaryIntervalMinutes<0 then
H.SummaryIntervalMinutes=0 end
H.MinSecondsBetweenMessages=math.max(1,H.MinSecondsBetweenMessages)m.General.TickSeconds=math.clamp
(m.General.TickSeconds,.1,5)m.Logging.FlushSeconds=math.clamp(m.Logging.FlushSeconds,1,60)return
m,P end return l end P["Core/Logger"]=function(...)local k=...local P=k("Core/Enums")local
l=k("Core/Signal")local B=k("Core/Util")local U={}U.__index=U function U.new(k)local
Z=setmetatable({},U)Z._config=k
Z._consoleRank=P.LogLevelRank[k.ConsoleLevel]Z._fileRank=P.LogLevelRank[k.FileLevel]Z._pendingFileL
ines={}Z._fileContent={}Z._bytesWritten=0 Z._appendChecksLeft=3 Z._appendBroken=false
Z._linesWritten=0 Z._fileDisabledReason=nil Z._lastKey=nil Z._lastTime=0 Z._repeatCount=0
Z._lastLevel=nil Z._lastCategory=nil Z.Counts=
{DEBUG=0,INFO=0;SUCCESS=0;WARN=0;ERROR=0}Z.OnEntry=l.new("Logger.OnEntry")Z._fileApi=B.fileApi()Z._
filePath=nil if k.FileEnabled then if not Z._fileApi.canWrite then Z._fileDisabledReason="writefile
unavailable"elseif not B.ensureFolder(k.Folder)then Z._fileDisabledReason="could not create folder
"..k.Folder else local P,l=pcall(function()return(game:GetService("Players")).LocalPlayer.Name
end)local B=((P and type(l)=="string"))and(string.gsub(l,"

[^%w_]","").."_")or""Z._filePath=k.Folder..("/session_"..(B..
(os.date("%Y%m%d_%H%M%S")..".log")))end else Z._fileDisabledReason="disabled in config"end return Z
end function U.getFilePath(k)return k._filePath,k._fileDisabledReason end local function
Z(k,P,l)return string.format("[%s][%s][%s] %s",os.date("%H:%M:%S"),k,P,l)end function
U._output(U,k,l,B)local m=Z(k,l,B)local H=P.LogLevelRank[k]local
Q=P.LogLevelRank[string.upper(tostring(U._config.ConsoleLevel))]or U._consoleRank if U._reporting
then Q=math.min(Q,P.LogLevelRank.INFO)end if H>=Q then if H>=P.LogLevelRank.WARN then warn(m)else
print(m)end end if U._filePath and H>=U._fileRank then if
U._linesWritten<U._config.MaxLinesPerSession then
table.insert(U._pendingFileLines,m)U._linesWritten=U._linesWritten+(1)elseif
U._linesWritten==U._config.MaxLinesPerSession then
table.insert(U._pendingFileLines,Z("WARN","Logger","Line limit reached; file logging stopped for
this session"))U._linesWritten=U._linesWritten+(1)end end end function U._flushRepeats(k)if
k._repeatCount>0 then k:_output(k._lastLevel,k._lastCategory,string.format("(previous message
repeated %d more times)",k._repeatCount))k._repeatCount=0 end end function
U.log(m,k,l,U,Z)assert(P.LogLevelRank[k],"Unknown log level: "..tostring(k))l=tostring(l
or"General")U=tostring(U)m.Counts[k]=m.Counts[k]+(1)local H=k..("|"..(l..("|"..U)))local
Q=B.now()if H==m._lastKey and(Q-m._lastTime)<m._config.DuplicateWindowSeconds then
m._repeatCount=m._repeatCount+(1)return end m:_flushRepeats()m._lastKey,m._lastTime=H,Q
m._lastLevel,m._lastCategory=k,l m:_output(k,l,U)if k~="DEBUG"then m.Recent=m.Recent
or{}table.insert(m.Recent,string.format("%s %s [%s]
%s",os.date("%H:%M:%S"),k,l,B.truncate(U,300)))if#m.Recent>120 then table.remove(m.Recent,1)end end
m.OnEntry:Fire(k,l,U,Z)end function U.problemReport(k)local P=""if
type(k.reportHeader)=="function"then local l,B=pcall(k.reportHeader)P=l
and(type(B)=="string"and(B.."\n"))or""end return P..(string.format("Warnings %d, errors
%d\n",k.Counts.WARN,k.Counts.ERROR)..table.concat(k.Recent or{},"\n"))end
U.PROBLEM_FILE="AdoptMeFarm/problem_report.txt"function U.saveProblemReport(k)if
type(writefile)~="function"then return false end pcall(function()if
type(makefolder)=="function"and(type(isfolder)=="function"and not isfolder("AdoptMeFarm"))then
makefolder("AdoptMeFarm")end end)return pcall(writefile,U.PROBLEM_FILE,k:problemReport())end
function U.report(B,k,l)local U=B._consoleRank
B._consoleRank=math.min(U,P.LogLevelRank.INFO)B._reporting=true B:info(k,l)B._reporting=false
B._consoleRank=U end function U.debug(U,k,l,B)U:log(P.LogLevel.DEBUG,k,l,B)end function
U.info(U,k,l,B)U:log(P.LogLevel.INFO,k,l,B)end function
U.success(U,k,l,B)U:log(P.LogLevel.SUCCESS,k,l,B)end function
U.warn(U,k,l,B)U:log(P.LogLevel.WARN,k,l,B)end function
U.error(U,k,l,B)U:log(P.LogLevel.ERROR,k,l,B)end function U.flush(k)if not k._filePath
or#k._pendingFileLines==0 then return end local P=k._pendingFileLines k._pendingFileLines={}local
l=table.concat(P,"\n").."\n"if k._partBytes and k._partBytes+#l>400000 then k._part=((k._part or
1))+1 k._fileContent={}k._partBytes=0 k._filePath=string.gsub(k._basePath or
k._filePath,"%.log$","")..("_part"..(k._part..".log"))end k._basePath=k._basePath or k._filePath
table.insert(k._fileContent,l)k._partBytes=((k._partBytes or 0))+#l
k._bytesWritten=k._bytesWritten+(#l)local
B,U=pcall(writefile,k._filePath,table.concat(k._fileContent))k._fileCreated=k._fileCreated or B if
not B then k._fileDisabledReason="write failed: "..tostring(U)k._filePath=nil warn("[Logger] File
logging disabled: "..tostring(U))end end function
U.close(k)k:_flushRepeats()k:flush()k.OnEntry:DisconnectAll()end return U end
P["Core/State"]=function(...)local k=...local P=k("Core/Signal")local l=k("Core/Util")local B=
{}B.__index=B function B.new()local k=setmetatable({},B)k._values={}k._meta=
{}k.Changed=P.new("State.Changed")return k end local function U(k,P)if k==P then return true end if
type(k)~="table"or type(P)~="table"then return false end for k,l in pairs(k)do if P[k]~=l then
return false end end for P in pairs(P)do if k[P]==nil then return false end end return true end
function B.set(Z,k,P,B)assert(type(k)=="string"and k~="","State:set needs a
key")assert(type(B)=="string"and B~="","State:set("..(k..") needs a source"))local
m=Z._values[k]Z._meta[k]={source=B,updatedAt=l.now()}if U(m,P)then return false end Z._values[k]=P
Z.Changed:Fire(k,P,m)return true end function B.get(l,k,P)local B=l._values[k]if B==nil then return
P end return B end function B.getMeta(P,k)return P._meta[k]end function B.increment(B,k,P,l)local
U=B._values[k]or 0 B:set(k,U+((P or 1)),l)return B._values[k]end function B.age(P,k)local
B=P._meta[k]return B and(l.now()-B.updatedAt)or nil end function B.snapshot(k)return
l.shallowCopy(k._values)end function B.destroy(k)k.Changed:DisconnectAll()end return B end
P["Core/Scheduler"]=function(...)local k=...local P=k("Core/Util")local l={}l.__index=l local B=2
local U=5 function l.new(k,P)local B=setmetatable({},l)B._logger=k B._tickSeconds=P B._jobs=
{}B._order={}B._running=false B._paused=false B._thread=nil B.TickCount=0 return B end function
l.addJob(Z,k,l,B,U)assert(type(k)=="string","job name must be a
string")assert(type(B)=="function","job callback must be a function")assert(Z._jobs[k]==nil,"job
already exists: "..k)U=U or{}Z._jobs[k]=
{name=k;interval=math.max(0,l),callback=B,nextRun=U.runImmediately and 0
or(P.now()+l),failures=0;enabled=true;runs=0}table.insert(Z._order,k)end function
l.removeJob(P,k)P._jobs[k]=nil for l,B in ipairs(P._order)do if B==k then
table.remove(P._order,l)break end end end function l.getJob(P,k)return P._jobs[k]end function
l._runJob(Z,k,l)k.nextRun=l+k.interval local m=P.now()local H,Q=pcall(k.callback,l)local A=P.now()m k.runs=k.runs+(1)if A>B then Z._logger:warn("Scheduler",string.format("Job \'%s\' took %.2f s
(blocks other jobs)",k.name,A))end if H then k.failures=0 return end k.failures=k.failures+
(1)Z._logger:error("Scheduler",string.format("Job \'%s\' failed (%d in a row):

%s",k.name,k.failures,tostring(Q)))if k.failures>=U then k.enabled=false
Z._logger:error("Scheduler","Job \'"..(k.name.."\' disabled after repeated failures"))end end
function l._tick(k)k.TickCount=k.TickCount+(1)local l=P.now()for P,B in
ipairs(table.clone(k._order))do if not k._running or k._paused then return end local U=k._jobs[B]if
U and(U.enabled and l>=U.nextRun)then k:_runJob(U,l)end end end function l.start(k)if k._running
then return end k._running=true k._paused=false k._thread=task.spawn(function()while k._running do
if not k._paused then k:_tick()end task.wait(k._tickSeconds)end
end)k._logger:info("Scheduler",string.format("Started (tick %.2f s, %d
jobs)",k._tickSeconds,#k._order))end function l.pause(k)k._paused=true
k._logger:info("Scheduler","Paused")end function l.resume(k)k._paused=false
k._logger:info("Scheduler","Resumed")end function l.isRunning(k)return k._running and not k._paused
end function l.stop(k)if not k._running then return end k._running=false local P=k._thread
k._thread=nil if P and coroutine.running()~=P then pcall(task.cancel,P)end
k._logger:info("Scheduler","Stopped")end return l end P["Services/Disclosure"]=function(...)local
k=...local P=k("Core/Config")local l={}l.VERSION="2.1.4 (Adopt Victims - UI Remastered Edition,
Hauntlet squad)"l.WEBHOOK_FIELDS={Player="your Roblox username (only if
Notifications.IncludeUsername = true)",["Session time"]="how long the script has been
running",Bucks="your current Bucks";["Bucks earned"]="Bucks earned this session",Candy="your
current Halloween candy";["Candy earned"]="candy earned this session",["Needs completed"]="number
of completed pet/baby needs this session",["Last task"]="name of the last completed need";Pet="name
and age of the pet being farmed",Error="short error text from this script";Reason="the
disconnect/kick message Roblox showed";["Log counts"]="number of warnings/errors this
session",Version="this script\'s version";["Previous session"]="when the previous run ended without
Stop() and the last Roblox message it saw"}l.BEHAVIOUR={reads={"your own Roblox username","your own
game data that Adopt Me already sends to your device: needs (ailments), Bucks, team, equipped pets,
the furniture list of the room you are in, your backpack (inventory: which food / drink / toy you
own), whether your character is sitting","the game\'s ClientData.get_data() is called ONCE at
start, only to read that same data","Halloween 2026 data (candy, Crypt graves, nest, Stray Cat,
round times) and the Ghost Gallery messages the server sends to you (join, score, reward); the
Hauntlet messages sent to you (rooms, doors, your hearts and run items, reward) and your Hauntlet
stats; your Pet Pen";"other players\' data arrives on the same channel: it is dropped immediately
and never stored, except the hearts of the players in YOUR Hauntlet run, kept in memory for that
run only (to agree on whose turn it is to use a shared item)";"which pet model in the world is
yours (to find it later)","Roblox disconnect/kick messages (to report them)";"for the window\'s
icons: the game\'s item list (pictures of pets / items) and the picture next to your Bucks / candy
on the game\'s own screen (read only)"},behaviour={"starts with EVERY farm feature off: nothing is
farmed until you switch features on (window or preset)";"works while the farm is paused, and sends
no game remote: Anti-AFK (a virtual click on Roblox\'s idle warning) and clicking Play on the main
menu (Farm.AntiAfk, Farm.AutoAcceptMenu)","only while the farm runs: cashback, every need, event
job, purchase and the quick actions","needs that can be done where you are come first
(Farm.SmartPriority); no teleport when you already stand at the spot; home only when a need needs
home (Farm.FoodBowlTrip = false: food from the backpack away from home)";"stuck in one place (not
moving, tasks failing) for Farm.StuckRecovery.Seconds: goes home by respawn","a task that failed 3
times in a row rests Farm.DisableMinutes, then is tried again","window quick actions (only when you
press them): pause / resume, go home, skip the running task, claim the Pet Pen now, retry tasks
that rest";"the window changes the farm live; your webhook URL and Discord id may be typed there
too (kept on this device in the window settings file, never in a shared config)";"Hauntlet
(Farm.Event.Hauntlet, off by default): joins a run from the Hotel, picks one door per room by
standing in its circle (never the door a phone revealed as the ghost), uses only the run\'s own
items (keys, phone, potions, wand), unlocks the journal page once after a run; a run comes before a
Ghost Gallery round (Farm.Event.HauntletFirst; off: never while a Ghost Gallery round is near);
several of your accounts in one run take turns with the shared items
(Farm.Event.HauntletSquad)","Auto Skelicorn (Farm.Event.AutoSkelicorn, off by default): Rusty Keys
look for the Lightning Lever in the Crypt, the lever goes into the machine by the Manor ONCE and is
pulled, then 1 Skelicorn is bought with candy; idle once you own one";"camera guard
(Farm.CameraGuard, works paused): when the camera is inside your character it is pushed back out
through your own zoom limit for a moment (a local setting, no remote)";"configs (Config tab): the
settings you save go to AdoptMeFarm/configs/ on this device; one may load at start";"Autoclose GUI
on execute (Interface.StartHidden): the window starts hidden by pressing its own minimize button
(the hide / show key or the round paw button opens it)","the Dashboard (PC) shows this server\'s
players, FPS / ping, region and uptime, read on your device (nothing sent); its Join script button
copies a script that joins this server to your clipboard"},never={"downloads or runs any other code
(only YOUR loader downloads this program, from the URL shown above)";"sends data anywhere except
your own Discord webhook (if you set one) and, when Telemetry is on, the developer\'s relay (see
NETWORK)";"trades, gifts or drops items";"clicks any buy / purchase / Robux button (on popups it
only clicks the close X)";"uses items other than: sandwich / cheese / hotdog (hungry), water /
chocolate milk (thirsty), squeaky bone (play); buys nothing except 1 water or 1 hotdog when a need
has nothing to use (limit: Farm.MaxBuysPerSession, 0 = none), and 1 egg (Farm.EggToBuy, Bucks only)
when you have no pet that still grows (Farm.BuyEgg, limit Farm.MaxEggBuysPerSession); Halloween
(Farm.Event): 1 water a day for the Stray Cat, your Rusty Keys, Crypt Twigs and the loaned Ghost
Vacuum; spends candy only on the Halloween pets you pick (Farm.Event.CandyPets), 1 Skelicorn
(Farm.Event.AutoSkelicorn) and, with Mega a Pet (Farm.Focus), copies of the picked candy pet /
Skelicorn until Pet Pen slots + 1 grow (Bucks: the picked egg); age / bucks potions on the farmed
pet that still grows (Farm.AutoPotions; never fly / ride potions); opens gifts and chests

(Farm.AutoOpen); fuses 4 of your full grown pets of one kind into 1 neon, and 4 full grown neons
into 1 mega neon (Farm.AutoNeon)"}}local function B(k)local P={}for k in pairs(k)do
table.insert(P,k)end table.sort(P)return P end function l.isAllowedField(k)return
l.WEBHOOK_FIELDS[k]~=nil end function l.buildStartLine(k,P)local B=k.Telemetry or{}local U=P
and("Bug reports go to the developer (your Roblox name, "..(((B.IncludeInventory and"an inventory
summary, "or"")).."this script\'s logs); off: Telemetry = { Enabled = false }"))or"Bug reports:
off"return string.format("%s v%s \226\128\162 %s \226\128\162 Full report: Config > Settings > What
this script does \226\128\162 Stop:
getgenv().AdoptMeFarm.Stop()",k.General.ScriptName,l.VERSION,U)end function
l.buildStartLines(k,P,B,U,Z)Z=Z or{fromLoader=false,settingsSource="SETTINGS block in this
file"}local m={"===== "..(k.General.ScriptName..(" v"..(l.VERSION.." (plain, readable Luau)
====="))),Z.fromLoader and("STARTED BY: your loader, which downloaded this program from:
"..tostring(Z.loaderUrl))or"STARTED BY: running this file directly (the program itself was not
downloaded)","SETTINGS FROM: "..tostring(Z.settingsSource),"Window: "..((((k.Interface and
k.Interface.Enabled))and("ON \226\128\148 loads the Starlight UI library from
raw.nebulasoftworks.xyz"..(((k.Interface.RememberSettings~=false and"; remembers your changes in it
on this device"or"")).." (Interface.Enabled = false: no window)"))or"OFF (Interface.Enabled =
false)")),"Can do (each ONLY when you switch it on; all off at the first start): pet + baby needs,
daily quests, the Halloween event (Ghost Gallery, Crypt, Stray Cat, nest), Pet Pen, age potions,
gifts, neon fusion. Only for YOUR pet / baby / items.","Features on now:
"..l.featureSummary(k),"Developer logs: "..tostring(U);"Your webhook: "..tostring(B);"Files:
"..table.concat(P,"; "),"Every game action it may send: getgenv().AdoptMeFarm.Disclosure()
Stop:
getgenv().AdoptMeFarm.Stop()"}if not k.Farm.Enabled then table.insert(m,3,"Game actions: NONE
(Farm.Enabled = false: the script only watches until you switch"..(" \'Farm running\' on"..
(l.helperText(k)..")")))end return m end function l.featureSummary(k)local
l,B=P.countFeatures(k)return string.format("%d of %d%s",l,B,k.Preset and(" (preset "..
(tostring(k.Preset)..")"))or"")end function l.helperText(k)local P={}if k.Farm.AntiAfk then
table.insert(P,"the Anti-AFK click")end if k.Farm.AutoAcceptMenu then table.insert(P,"the main
menu\'s Play button")end return#P>0 and("; still on: "..table.concat(P," and "))or""end function
l.buildLines(k,P,U,Z,m,H)Z=Z or{fromLoader=false,settingsSource="SETTINGS block in this file"}local
Q={}local function A(k)table.insert(Q,k)end A("================ WHAT THIS SCRIPT DOES
================")A(k.General.ScriptName..(" v"..l.VERSION))A("Source is plain, readable Luau: no
obfuscation.")if Z.fromLoader then A("STARTED BY: your loader, which downloaded this program
from:")A(" "..tostring(Z.loaderUrl))else A("STARTED BY: running this file directly (the program
itself was not downloaded)")end A("SETTINGS FROM: "..tostring(Z.settingsSource))A("")A("READS:")for
k,P in ipairs(l.BEHAVIOUR.reads)do A(" - "..P)end A("HOW IT DECIDES:")for k,P in
ipairs(l.BEHAVIOUR.behaviour)do A(" - "..P)end A(" - features on now:
"..l.featureSummary(k))A("GAME ACTIONS IT SENDS:")if not k.Farm.Enabled then A(" - NONE
(Farm.Enabled = false: the script only watches"..(l.helperText(k)..")"))elseif not m then A(" NONE (not in Adopt Me)")else A(" - only these remotes, nothing else (enforced in code):")for k,P
in ipairs(m)do A("
* "..P)end A(" - only for YOUR pet / YOUR baby, one task at a time, each
with a time limit")end A("NETWORK:")A(" - Window: "..((((k.Interface and
k.Interface.Enabled))and("loads the Starlight UI library (raw.nebulasoftworks.xyz/starlight), which
keeps its own empty folder \'Starlight Interface Suite/AdoptMeFarm\'; its Support tab shows the
developer\'s picture (downloaded once from raw.githubusercontent.com when your executor can show
it, else Roblox\'s own avatar picture); Interface.Enabled = false: nothing loaded")or"OFF (nothing
loaded)")))A(" - Developer logs (Telemetry): "..tostring(H or"OFF"))A(" - Hauntlet squad finder:
ONLY when you set a private squad key (Farm.Event.HauntletSquadKey; empty by default = nothing
sent): your Roblox user id and the run\'s session id go to the relay\'s /squad, at most 3 times a
run; it answers only to the same key, with the user ids of your other accounts in that run")A(" "..U)A(" - Webhook summaries show the farmed pet\'s own picture: its address is asked once from
Roblox\'s thumbnail service (thumbnails.roblox.com; only the picture\'s number is sent there)")A("
- Webhook messages can only contain these fields:")for k,P in ipairs(B(l.WEBHOOK_FIELDS))do A("
* "..(P..(": "..l.WEBHOOK_FIELDS[P])))end A("FILES:")for k,P in ipairs(P)do A(" - "..P)end
A("NEVER:")for k,P in ipairs(l.BEHAVIOUR.never)do A(" - "..P)end A("Stop any time with:
getgenv().AdoptMeFarm.Stop()")A("=======================================================")return Q
end function l.buildShortText()local k=B(l.WEBHOOK_FIELDS)return"This script only sends these
fields to this webhook: "..(table.concat(k,", ").." (+ the farmed pet\'s picture). No other data
leaves the device.")end return l end P["Services/Notifier"]=function(...)local k=...local
P=k("Core/Enums")local l=k("Core/Util")local B=k("Services/Disclosure")local
U=game:GetService("Players")local Z={}Z.__index=Z local m={SessionStarted={title="Session
started",color=3908957,route="Summary",toggle="SendOnStartStop"},SessionStopped={title="Session
stopped";color=7634829;route="Summary";toggle="SendOnStartStop";ping="SessionStopped"},Summary=
{title="Farm summary";color=5793266;route="Summary",ping="Summary"},TaskCompleted={title="Need
completed",color=5763719,route="Summary",toggle="SendOnTaskComplete";ping="TaskCompleted"},Error=
{title="Error",color=15548997;route="Alerts",toggle="SendOnError",ping="Error",cooldown=true};Kicke
d={title="Disconnected /
kicked";color=15548997,route="Alerts";toggle="SendOnKick",ping="Kick"},PreviousSessionEnded=
{title="Previous run ended without
Stop()";color=15105570;route="Alerts";toggle="SendOnKick",ping="PreviousSession"};Test=
{title="Webhook test";color=16705372,route="Summary"}}local H=1000 local Q=3500 function
Z.new(k,P,B,U)local m=setmetatable({},Z)m._config=k m._logger=P m._scriptName=B m._version=U
m._requestFunction=l.getRequestFunction()m._queues={}m._lastAlertAt=-math.huge
m._suppressedAlerts=0 m.SentCount=0 m.DroppedCount=0 return m end function Z._offReason(k)local

P=k._config.Webhooks if not k._config.Enabled then return"Notifications.Enabled = false"elseif
P.Summary==""and P.Alerts==""then return"no webhook URL set"elseif not k._requestFunction then
return"executor has no HTTP request function"end return nil end function Z.isEnabled(k)return
k:_offReason()==nil end function Z.getStatusText(k)local P=k:_offReason()if P then return"Discord
webhooks: OFF ("..(P.."). Nothing is sent over the network.")end local l=k._config.Webhooks local
B={}if l.Summary~=""then table.insert(B,"Summary")end if l.Alerts~=""then
table.insert(B,"Alerts")end return"Discord webhooks: ON ("..(table.concat(B," + ").." webhook set
by you). Messages go ONLY to discord.com webhook URLs from your config.")end function
Z._resolveRoute(P,k)local l=P._config.Webhooks if l[k]~=""then return k,l[k]end local
B=k=="Alerts"and"Summary"or"Alerts"if l[B]~=""then return B,l[B]end return nil,nil end function
Z._getQueue(l,k,P)local B=l._queues[k]if not B then B={name=k,url=P;items=
{},inFlight=false;nextAllowed=0;disabled=false}l._queues[k]=B elseif B.url~=P then B.url=P
B.disabled=false end return B end Z.FIELD_EMOJI={Player="\240\159\145\164";["Session
time"]="\226\143\177\239\184\143",Bucks="\240\159\146\181",["Bucks
earned"]="\240\159\146\181";Candy="\240\159\141\172";["Candy earned"]="\240\159\141\172",["Needs
completed"]="\226\156\133",["Last
task"]="\240\159\147\139";Pet="\240\159\144\190",Error="\226\157\140",Reason="\240\159\154\170";
["Log counts"]="\240\159\167\190",Version="\240\159\143\183\239\184\143",["Previous
session"]="\240\159\149\152"}local function A(k)local P=Z.FIELD_EMOJI[k]return P and(P..(" "..k))or
k end local function f(k,P)local Z={}if k._config.IncludeUsername then local k=U.LocalPlayer
table.insert(Z,{name=A("Player"),value=k and k.Name or"?";inline=true})end for P,U in ipairs(P
or{})do if B.isAllowedField(U.name)then table.insert(Z,
{name=A(U.name),value=l.truncate(U.value,H);inline=U.inline==true})else
k._logger:warn("Notifier","Blocked a field that is not in the disclosure list:
"..tostring(U.name))end end table.insert(Z,{name=A("Version"),value=k._version,inline=true})return
Z end function Z.notify(H,k,B,U,Z)local A=m[P.NotifyEvent[k]]if not H:isEnabled()then return false
end if A.toggle and not H._config[A.toggle]then return false end if A.cooldown then local
k=l.now()if k-H._lastAlertAt<H._config.AlertCooldownSeconds then
H._suppressedAlerts=H._suppressedAlerts+(1)return false end H._lastAlertAt=k if
H._suppressedAlerts>0 then U=((U and(U.."\n")or""))..string.format("(%d more alerts were suppressed
by the cooldown)",H._suppressedAlerts)H._suppressedAlerts=0 end end local
Y,n=H:_resolveRoute(A.route)if not n then return false end local L=H:_getQueue(Y,n)if L.disabled
then return false end local b=H._config.PingDiscordUserId local M=H._config.Ping~=false
and(b~=""and(A.ping~=nil and H._config.PingOn[A.ping]==true))local O={title=A.title;description=U
and l.truncate(U,Q)or nil;color=A.color,fields=f(H,B),footer={text=H._scriptName}}local
C=type(Z)=="table"and Z.thumbnail if type(C)=="string"and
string.match(C,"^https://tr%.rbxcdn%.com/[%w%-%._/]+$")then O.thumbnail={url=C}end
pcall(function()O.timestamp=(DateTime.now()):ToIsoDate()end)local G={username=H._scriptName;embeds=
{O},allowed_mentions=M and{users={b}}or{parse={}}}if M then G.content="<@"..(b..">")end local
w,V=l.jsonEncode(G)if not w then H._logger:error("Notifier","Could not encode message:
"..tostring(V))return false end if#L.items>=H._config.MaxQueueSize then
table.remove(L.items,1)H.DroppedCount=H.DroppedCount+(1)H._logger:warn("Notifier",L.name.." queue
full; dropped the oldest message")end table.insert(L.items,{body=w;event=k,attempts=0})return true
end function Z._send(P,k)local B=k.items[1]if not B then k.inFlight=false return end local
U,Z=pcall(P._requestFunction,{Url=k.url,Method="POST",Headers={["ContentType"]="application/json"},Body=B.body})local m=U and(type(Z)=="table"and tonumber(Z.StatusCode))or
nil local H=l.now()if m and(m>=200 and m<300)then table.remove(k.items,1)P.SentCount=P.SentCount+
(1)k.nextAllowed=H+P._config.MinSecondsBetweenMessages P._logger:debug("Notifier","Sent "..
(B.event..(" to "..(k.name.." webhook"))))elseif m==429 then local B=5 local
U=type(Z.Body)=="string"and l.jsonDecode(Z.Body)if type(U)=="table"and tonumber(U.retry_after)then
B=tonumber(U.retry_after)end k.nextAllowed=(H+B)+.5
P._logger:warn("Notifier",string.format("Discord rate limit on %s webhook; waiting %.1f
s",k.name,B))elseif m==401 or m==403 or m==404 then k.disabled=true P.DroppedCount=P.DroppedCount+
(#k.items)table.clear(k.items)P._logger:error("Notifier",string.format("%s webhook rejected (HTTP
%d). Check the URL. This webhook is now off.",k.name,m))elseif m==400 then
table.remove(k.items,1)P.DroppedCount=P.DroppedCount+(1)P._logger:error("Notifier","Discord refused
a "..(B.event..(" message (HTTP 400): "..l.truncate(tostring(Z.Body),200))))else
B.attempts=B.attempts+(1)local Q=U and("HTTP "..tostring(m))or tostring(Z)if
B.attempts>P._config.MaxRetries then table.remove(k.items,1)P.DroppedCount=P.DroppedCount+
(1)P._logger:error("Notifier","Gave up sending "..(B.event..(" after retries:
"..l.truncate(Q,200))))else k.nextAllowed=H+(2^B.attempts)P._logger:warn("Notifier","Send failed
("..(l.truncate(Q,120)..("); retry "..B.attempts)))end end k.inFlight=false end function
Z.pump(k)if not k:isEnabled()then return end local P=l.now()for l,B in pairs(k._queues)do if not
B.inFlight and(not B.disabled and(#B.items>0 and P>=B.nextAllowed))then B.inFlight=true
task.spawn(function()local P,l=pcall(k._send,k,B)if not P then B.inFlight=false
k._logger:error("Notifier","Internal send error: "..tostring(l))end end)end end end function
Z.pendingCount(k)local P=0 for k,l in pairs(k._queues)do if not l.disabled then P=P+(#l.items)end
end return P end function Z.flush(P,k)local B=l.now()+k while P:pendingCount()>0 and l.now()<B do
P:pump()task.wait(.25)end return P:pendingCount()==0 end return Z end
P["Services/SessionWatcher"]=function(...)local k=...local P=k("Core/Enums")local
l=game:GetService("GuiService")local B={}function B.start(k,B,U,Z,m)local
H,Q=pcall(function()return l.ErrorMessageChanged end)if not H or Q==nil then
B:warn("Session","GuiService.ErrorMessageChanged unavailable; kick detection is off")return false
end local A=nil k:Give(Q:Connect(function(k)local H=type(k)=="string"and k or""if H==""then

pcall(function()H=l:GetErrorMessage()end)end if type(H)~="string"or H==""or H==A then return end
A=H Z:set("session.disconnectReason",H,"SessionWatcher")if m then m:recordMessage(H)end
B:warn("Session","Roblox disconnect/kick message: "..H)B:flush()U:notify(P.NotifyEvent.Kicked,
{{name="Reason",value=H}})U:pump()end))B:debug("Session","Kick detection active")return true end
return B end P["Services/SessionStore"]=function(...)local k=...local P=k("Core/Util")local l=
{}l.__index=l l.FOLDER="AdoptMeFarm"l.PATH=((function()local
k,P=pcall(function()return(game:GetService("Players")).LocalPlayer.Name end)local l=((k and
type(P)=="string"))and string.gsub(P,"[^%w_]","")or""return l~=""and("AdoptMeFarm/session_state_"..
(l..".json"))or"AdoptMeFarm/session_state.json"end))()function l.new(k,P,B)local
U=setmetatable({},l)U._logger=k U._version=P U._record=nil U._available=B~=false
and(type(writefile)=="function"and(type(readfile)=="function"and type(isfile)=="function"))return U
end function l.isAvailable(k)return k._available end function l._write(k)if not k._available or not
k._record then return end local B=P.jsonEncode(k._record)if not B then return end local
U,Z=pcall(writefile,l.PATH,B)if not U then k._available=false k._logger:warn("SessionStore","Could
not write session file; delayed reports disabled: "..tostring(Z))end end function l.begin(k)if not
k._available then k._logger:debug("SessionStore","readfile/isfile/writefile missing; delayed
reports disabled")return nil end P.ensureFolder(l.FOLDER)local B=nil local U,Z=pcall(function()if
isfile(l.PATH)then return readfile(l.PATH)end return nil end)if U and(type(Z)=="string"and
Z~="")then local l=P.jsonDecode(Z)if type(l)=="table"and l.cleanStop==false then B=l elseif l==nil
then k._logger:warn("SessionStore","Session file was unreadable; starting a new one")end end local
m=os.time()k._record=
{version=k._version;startedAt=m;lastSeen=m;cleanStop=false,lastMessage=""}k:_write()return B end
function l.heartbeat(k)if k._record then k._record.lastSeen=os.time()k:_write()end end function
l.recordMessage(P,k)if P._record then
P._record.lastSeen=os.time()P._record.lastMessage=tostring(k)P:_write()end end function
l.markCleanStop(k)if k._record then k._record.lastSeen=os.time()k._record.cleanStop=true
k:_write()end end function l.describe(k)local function P(k)return tonumber(k)and os.date("%Y-%m-%d
%H:%M",tonumber(k))or"?"end local l=((type(k.lastMessage)=="string"and k.lastMessage~=""))and
k.lastMessage or"no Roblox message was recorded"return string.format("Previous run (started %s)
ended without Stop() around %s. Last Roblox message: %s",P(k.startedAt),P(k.lastSeen),l)end return
l end P["Services/Telemetry"]=function(...)local k=...local P=k("Core/Util")local
l=k("Core/Enums")local B={}B.__index=B local U="^https://[%w%-]+%.
[%w%-]+%.workers%.dev/[%w%-/]*$"local Z=150 local m=80 local H=200 function B.isAllowedUrl(k)return
type(k)=="string"and string.match(k,U)~=nil end function B.new(k,l,U,Z)local
m=setmetatable({},B)m._config=k or{}m._logger=l m._version=U m._state=Z m._lines={}m._counts=
{}m._dropped=0 m._failures=0 m._nextSend=0 m._nextSummary=P.now()+
((tonumber(m._config.SummaryMinutes)or 30))*60
m._session=string.format("%x%x",os.time()%16777215,math.random(0,65535))m._startPending=true
m._request=P.getRequestFunction()local H,Q=pcall(function()return identifyexecutor and
table.concat({identifyexecutor()}," ")or nil end)m._executor=H and Q or nil
m._off="disabled"m._config.Enabled=false return m end function B.isEnabled(k)return k._off==nil and
k._config.Enabled~=false end function B.statusText(k)if k._off then return"OFF ("..(k._off..")")end
if k._config.Enabled==false then return"OFF (turned off in the window)"end return"ON: every "..
(tostring(k._config.SummaryMinutes or 30)..(" min your Roblox name, executor name, a session"..("
summary (needs, Bucks, candy, rounds), this script\'s state (team, place, task, pet, needs, why it
waits),"..(" task results, its warnings / errors and its last "..(m..(" log lines"..
(((k._config.IncludeInventory and" + an inventory summary (Telemetry.IncludeInventory)"or""))..("
(and that this run started) go to "..(tostring(k._config.Owner or"the developer")..(" via "..
(k._config.Url.." to fix bugs. Turn off: Telemetry = { Enabled = false }")))))))))))end local
function Q(k)k=P.truncate(tostring(k),H)local
l,B=pcall(function()return(game:GetService("Players")):GetPlayers()end)local U=
(game:GetService("Players")).LocalPlayer for P,l in ipairs(l and B or{})do if l~=U
and(type(l.Name)=="string"and#l.Name>=3)then k=string.gsub(k,(string.gsub(l.Name,"%p","%%%0")),"
<player>")end end return k end local A={{key="rounds",pattern="^Ghost Gallery: %d+ points"},
{key="keys";pattern="Rusty Key EARNED"},{key="quests",pattern="^Quests: .* claimed"};
{key="potions",pattern="^Age potion:"},{key="gifts";pattern="^Opened "};
{key="houseVisits",pattern="^Quest %a+: visited"}}local f=
{"halloween_2026_rusty_key";"halloween_2026_twig","pet_age_potion";"tiny_pet_age_potion";"trade_lic
ense"}local Y=40 function B._inventory(k)local P=k._gameData and k._gameData:get("inventory")if
type(P)~="table"then return nil end local l,B,U={},{},{}for k,P in ipairs(f)do U[P]=true end for
k,P in pairs(P)do if type(P)=="table"then local Z=0 for k,P in pairs(P)do if type(P)=="table"then
Z=Z+(1)if U[P.id]then B[P.id]=((B[P.id]or 0))+1 end end end l[tostring(k)]=Z end end local Z,m,H,Q=
{},0,0,{}for k,P in pairs(type(P.pets)=="table"and P.pets or{})do if type(P)=="table"then m=m+
(1)local k=type(P.properties)=="table"and P.properties or{}local l=tostring(P.kind or P.id
or"?")local B=tonumber(k.age)if B and B>=6 then H=H+(1)end local U={}for k,P in pairs(k)do if
P==true then table.insert(U,tostring(k))end end table.sort(U)local A=l..(((B and(" a"..B)or""))..
((#U>0 and(" ["..(table.concat(U,",").."]"))or"")))Z[A]=((Z[A]or 0))+1 Q[l]=true end end local A=
{}for k,P in pairs(Z)do table.insert(A,{label=k,n=P})end table.sort(A,function(k,P)if k.n~=P.n then
return k.n>P.n end return k.label<P.label end)local n={}for k,P in ipairs(A)do if k>Y then
table.insert(n,"... "..((#A-Y).." more groups"))break end table.insert(n,P.label..(" x"..P.n))end
local L=0 for k in pairs(Q)do L=L+(1)end
return{categories=l,items=B,pets=n,petCount=m,fullGrown=H,petKinds=L}end function
B.setDiagnostics(P,k)P._diagnostics=k end function B.setGameData(P,k)P._gameData=k local l=k and
tonumber(k:get("candy_2026"))P._candyStart=P._candyStart or l end function B.start(P,k)if not

P:isEnabled()then return end P._lines={}P._counts={}P._tail={}P._tasks=
{}k:Give(P._logger.OnEntry:Connect(function(k,B,U)if B=="Telemetry"or B=="Disclosure"then return
end U=tostring(U)if k~=l.LogLevel.DEBUG then table.insert(P._tail,string.format("%s [%s] %s:
%s",os.date("%H:%M:%S"),k,B,Q(U)))if#P._tail>m then table.remove(P._tail,1)end end local
H=string.gsub(U,"^(%u+:) %(side%) ","%1 ",1)H=string.gsub(H,"^(Done:) %(side%) ","%1 ",1)local
f=string.match(H,"^Done: ([%w_]+)")local Y=string.match(H,"^FAILED: ([%w_]+)")or
string.match(H,"^TIMEOUT: ([%w_]+)")local n=f or Y if n and B=="Tasks"then local
k=P._tasks[n]or{done=0,failed=0}if f then k.done=k.done+(1)else k.failed=k.failed+(1)end
P._tasks[n]=k end for k,l in ipairs(A)do if string.find(U,l.pattern)then P._counts[l.key]=
((P._counts[l.key]or 0))+1 end end local L=k==l.LogLevel.WARN or k==l.LogLevel.ERROR
or(k==l.LogLevel.INFO and((B=="HauntletDigest"or(B=="Hauntlet"and string.find(U,"^New message
type")~=nil))))if L then if#P._lines>=Z then table.remove(P._lines,1)P._dropped=P._dropped+(1)end
table.insert(P._lines,string.format("%s [%s] %s: %s",os.date("%H:%M:%S"),k,B,Q(U)))end end))end
function B._summary(k)local l=k._logger.Counts or{}local B=k._gameData local U=B and
tonumber(B:get("candy_2026"))if U and not k._candyStart then k._candyStart=U end
return{minutes=math.floor(((P.now()-((k._state:get("session.startedAt")or
P.now()))))/60);needs=k._state:get("stats.needsCompleted")or
0,bucks=k._state:get("stats.bucksEarned")or 0,bucksNow=B and tonumber(B:get("money"))or nil;candy=
((U and k._candyStart))and(U-k._candyStart)or nil;candyNow=U,rounds=k._counts.rounds or
0,keys=k._counts.keys or 0,quests=k._counts.quests or 0;potions=k._counts.potions or
0,gifts=k._counts.gifts or 0;houseVisits=k._counts.houseVisits or 0,warnings=l.WARN or
0,errors=l.ERROR or 0;executor=k._executor;tasks=k._tasks;state=k._diagnostics and
select(2,pcall(k._diagnostics))or nil;inventory=k._config.IncludeInventory and
select(2,pcall(k._inventory,k))or nil}end function B._payload(P,k)local l=
(game:GetService("Players")).LocalPlayer local B={v=P._version;user=l and l.Name or"?";userId=l and
l.UserId or 0,session=P._session;start=P._startPending or nil}P._startPending=false if k then
B.report=true B.summary=P:_summary()B.lines=P._lines B.dropped=P._dropped B.tail=P._tail P._lines=
{}P._dropped=0 end return B end function B.pump(l,k)if not l:isEnabled()or l._inFlight then return
end if not l._candyStart and l._gameData then
l._candyStart=tonumber(l._gameData:get("candy_2026"))end local B=P.now()local U=k or
B>=l._nextSummary if not U and not l._startPending then return end if U then l._nextSummary=B+
((tonumber(l._config.SummaryMinutes)or 30))*60 end local Z=l:_payload(U)local m,H=P.jsonEncode(Z)if
not m and Z.report then l._logger:warn("Telemetry","Report could not be encoded ("..
(tostring(H).."): sending the short one"))local k=Z.summary
or{}k.state,k.inventory,k.tasks=nil,nil,nil Z.lines,Z.tail={"full report not encodable:
"..P.truncate(tostring(H),150)},nil m=P.jsonEncode(Z)end if not m then return end l._inFlight=true
task.spawn(function()local k,B=pcall(l._request,{Url=l._config.Url;Method="POST";Headers=
{["Content-Type"]="application/json"},Body=m})local U=k and(type(B)=="table"and
tonumber(B.StatusCode))or nil if U and(U>=200 and U<300)then l._failures=0 elseif U==429 then
l._nextSummary=math.min(l._nextSummary,P.now()+120)else l._failures=l._failures+(1)if
l._failures>=3 then l._off="the relay did not answer 3 times"l._logger:warn("Telemetry","Developer
logs turned off for this session: "..l._off)end end l._inFlight=false end)end return B end
P["Services/Lang"]=function(...)local k={}k.LANGUAGES={{code="en";name="English";country="GB"};
{code="tr",name="T\195\188rk\195\167e";country="TR"};
{code="es";name="Espa\195\177ol",country="ES"};
{code="pt";name="Portugu\195\170s",country="BR"}}k.COUNTRY=
{TR="tr",CY="tr";ES="es";MX="es",AR="es",CO="es",CL="es",PE="es",VE="es";EC="es",GT="es",CU="es",BO
="es",DO="es";HN="es",PY="es";SV="es",NI="es";CR="es";PA="es";UY="es";PR="es",GQ="es",BR="pt";PT="p
t",AO="pt";MZ="pt";CV="pt";GW="pt",ST="pt";TL="pt"}k.current="en"function
k.flag(k)k=string.upper(tostring(k or""))if not string.match(k,"^%u%u$")then return""end return
utf8.char((127462+string.byte(k,1))-65,(127462+string.byte(k,2))-65)end function k.info(P)for k,l
in ipairs(k.LANGUAGES)do if l.code==P then return l end end return nil end function k.pick(P,l,B)if
type(P)=="string"and(P~="Auto"and k.info(P))then return P end local
U=k.COUNTRY[string.upper(tostring(l or""))]if U then return U end local
Z=string.match(string.lower(tostring(B or"")),"^(%a%a)")if Z and k.info(Z)then return Z end
return"en"end function k.use(P)k.current=k.info(P)and P or"en"return k.current end local P=
{}k.STRINGS=P local function l(k,l,B,U)P[k]={tr=l,es=B,pt=U}end
l("Farm","\195\135iftlik","Granja","Fazenda")l("Setup","Kurulum","Ajustes","Ajustes")l("Support","D
estek","Apoyo","Apoio")l("Main","Ana
sayfa","Principal","Principal")l("Event","Etkinlik","Evento","Evento")l("Webhook","Webhook","Webhoo
k","Webhook")l("Config","Ayarlar","Config","Config")l("Dashboard","Panel","Panel","Painel")l("Farm
status","\195\135iftlik durumu","Estado de la granja","Status da fazenda")l("Quick
actions","H\196\177zl\196\177 i\197\159lemler","Acciones r\195\161pidas","A\195\167\195\181es
r\195\161pidas")l("Auto tasks","Otomatik g\195\182revler","Tareas autom\195\161ticas","Tarefas
autom\195\161ticas")l("Pet Pen","Pet A\196\159\196\177l\196\177","Corral","Cercadinho")l("Auto
needs","Otomatik ihtiya\195\167lar","Necesidades autom\195\161ticas","Necessidades
autom\195\161ticas")l("Pets","Petler","Mascotas","Pets")l("Potions & neon","\196\176ksirler ve
neon","Pociones y ne\195\179n","Po\195\167\195\181es e neon")l("Halloween 2026","Cad\196\177lar
Bayram\196\177 2026","Halloween 2026","Halloween
2026")l("Crypt","Mahzen","Cripta","Cripta")l("Candy Shop","\197\158eker
D\195\188kkan\196\177","Tienda de dulces","Loja de doces")l("Event status","Etkinlik
durumu","Estado del evento","Status do evento")l("Discord webhook","Discord webhook","Webhook de
Discord","Webhook do
Discord")l("Messages","Mesajlar","Mensajes","Mensagens")l("Configs","Kay\196\177tl\196\177

ayarlar","Configuraciones","Configura\195\167\195\181es")l("Settings","Genel","Opciones","Op\195\16
7\195\181es")l("Presets by the developer","Geli\197\159tiricinin haz\196\177r
ayarlar\196\177","Ajustes del desarrollador","Predefini\195\167\195\181es do
desenvolvedor")l("Advanced","Geli\197\159mi\197\159","Avanzado","Avan\195\167ado")l("Developer","Ge
li\197\159tirici","Desarrollador","Desenvolvedor")l("Changelog","Yenilikler","Novedades","Novidades
")l("Executor","Executor","Executor","Executor")l("Donate","Ba\196\159\196\177\197\159","Donar","Do
ar")l("Game passes","Oyun ge\195\167i\197\159leri","Pases de juego","Passes de jogo")l("Crypto (tap
to copy)","Kripto (kopyalamak i\195\167in dokun)","Cripto (toca para copiar)","Cripto (toque para
copiar)")l("Discord","Discord","Discord","Discord")l("Farm running","\195\135iftlik
\195\167al\196\177\197\159\196\177yor","Granja activa","Fazenda ligada")l("Go home","Eve git","Ir a
casa","Ir para casa")l("Skip current task","\197\158u anki g\195\182revi atla","Saltar tarea
actual","Pular tarefa atual")l("Retry resting tasks","Dinlenen g\195\182revleri dene","Reintentar
tareas en pausa","Tentar tarefas em pausa")l("Stop the farm","\195\135iftli\196\159i
durdur","Detener la granja","Parar a fazenda")l("Claim quests","G\195\182revleri topla","Reclamar
misiones","Resgatar miss\195\181es")l("Visit homes for quests","G\195\182rev i\195\167in ev
ziyareti","Visitar casas (misiones)","Visitar casas (miss\195\181es)")l("Collect cashback","Para
iadesini topla","Cobrar reembolso","Coletar cashback")l("Open gifts and chests","Hediye ve
sand\196\177k a\195\167","Abrir regalos y cofres","Abrir presentes e ba\195\186s")l("Auto Pet
Pen","Otomatik Pet A\196\159\196\177l\196\177","Corral autom\195\161tico","Cercadinho
autom\195\161tico")l("Claim every","Toplama aral\196\177\196\159\196\177","Reclamar cada","Coletar
a cada")l("Keep it full (buys eggs)","Dolu tut (yumurta al\196\177r)","Mantener lleno (compra
huevos)","Manter cheio (compra ovos)")l("Claim Pet Pen now","Pet
A\196\159\196\177l\196\177n\196\177 \197\159imdi topla","Reclamar corral ahora","Coletar cercadinho
agora")l("Baby needs too","Bebek ihtiya\195\167lar\196\177 da","Tambi\195\169n
beb\195\169s","Beb\195\170s tamb\195\169m")l("Skip these needs","Bu ihtiya\195\167lar\196\177
atla","Saltar estas necesidades","Pular estas necessidades")l("Keep growing pet
equipped","B\195\188y\195\188yen pet hep elde","Mascota en crecimiento equipada","Manter pet
crescendo equipado")l("Farm first","\195\150nce bunlar\196\177 besle","Primero estas","Primeiro
estes")l("Buy an egg if none grows","B\195\188y\195\188yen yoksa yumurta al","Comprar huevo si nada
crece","Comprar ovo se nada cresce")l("Egg to buy","Al\196\177nacak yumurta","Huevo a comprar","Ovo
para comprar")l("Use potions","\196\176ksir kullan","Usar pociones","Usar
po\195\167\195\181es")l("Don\'t use","Kullanma","No usar","N\195\163o usar")l("Auto neon
pets","Otomatik neon pet","Mascotas ne\195\179n autom\195\161ticas","Pets neon
autom\195\161ticos")l("Auto mega neon pets","Otomatik mega neon pet","Mega ne\195\179n
autom\195\161tico","Mega neon autom\195\161tico")l("Ghost Gallery","Hayalet
Galerisi","Galer\195\173a de fantasmas","Galeria dos fantasmas")l("Auto Stray Cat","Otomatik sokak
kedisi","Gato callejero autom\195\161tico","Gato de rua autom\195\161tico")l("Use Rusty
Keys","Pasl\196\177 anahtarlar\196\177 kullan","Usar llaves oxidadas","Usar chaves
enferrujadas")l("Open","A\195\167","Abrir","Abrir")l("Give twigs to the nest","Dallar\196\177
yuvaya g\195\182t\195\188r","Llevar ramitas al nido","Levar gravetos ao ninho")l("Auto
buy","Otomatik sat\196\177n al","Compra autom\195\161tica","Compra
autom\195\161tica")l("Buy","Sat\196\177n al","Comprar","Comprar")l("Your
event","Etkinli\196\159in","Tu evento","Seu evento")l("Webhook URL","Webhook adresi","URL del
webhook","URL do webhook")l("User ID","Kullan\196\177c\196\177 ID","ID de usuario","ID de
usu\195\161rio")l("Ping me","Beni etiketle","Mencionarme","Me mencionar")l("Ping me
on","\197\158unlarda etiketle","Mencionarme en","Me mencionar em")l("Send summary","\195\150zet
g\195\182nder","Enviar resumen","Enviar resumo")l("Summary every","\195\150zet
aral\196\177\196\159\196\177","Resumen cada","Resumo a cada")l("Send test message","Test
mesaj\196\177 g\195\182nder","Enviar mensaje de prueba","Enviar mensagem de teste")l("Each finished
need","Biten her ihtiya\195\167","Cada necesidad hecha","Cada necessidade feita")l("Kick /
disconnect","At\196\177lma / ba\196\159lant\196\177 kopmas\196\177","Expulsi\195\179n /
desconexi\195\179n","Expuls\195\163o /
desconex\195\163o")l("Errors","Hatalar","Errores","Erros")l("Start / stop","Ba\197\159lat /
durdur","Inicio / parada","In\195\173cio / parada")l("Show my Roblox name","Roblox
ad\196\177m\196\177 g\195\182ster","Mostrar mi nombre de Roblox","Mostrar meu nome do
Roblox")l("Alerts URL","Uyar\196\177 adresi","URL de alertas","URL de alertas")l("Config
name","Kay\196\177t ad\196\177","Nombre","Nome")l("Saved configs","Kay\196\177tl\196\177
ayarlar","Configuraciones guardadas","Configura\195\167\195\181es salvas")l("Save as new
config","Yeni kay\196\177t olarak sakla","Guardar como nueva","Salvar como nova")l("Overwrite
selected","Se\195\167ilenin \195\188zerine yaz","Sobrescribir seleccionada","Sobrescrever
selecionada")l("Load selected","Se\195\167ileni y\195\188kle","Cargar seleccionada","Carregar
selecionada")l("Delete selected","Se\195\167ileni sil","Borrar seleccionada","Apagar
selecionada")l("Autosave","Otomatik kaydet","Guardado autom\195\161tico","Salvamento
autom\195\161tico")l("Autoload selected","Se\195\167ileni a\195\167\196\177l\196\177\197\159ta
y\195\188kle","Cargar al iniciar","Carregar ao iniciar")l("Anti-AFK","Anti-AFK","Anti-AFK","AntiAFK")l("Auto click Play (menu)","Men\195\188de Play\'e otomatik bas","Pulsar Play en el
men\195\186","Clicar em Play no menu")l("Camera guard","Kamera korumas\196\177","Protector de
c\195\161mara","Prote\195\167\195\163o da c\195\162mera")l("Event pop-ups","Olay
bildirimleri","Avisos de eventos","Avisos de eventos")l("Autoclose GUI on
execute","A\195\167\196\177l\196\177\197\159ta pencereyi gizle","Ocultar ventana al
ejecutar","Ocultar janela ao executar")l("Theme","Tema","Tema","Tema")l("UI scale","Aray\195\188z
boyutu","Tama\195\177o de la interfaz","Tamanho da interface")l("How big the window is drawn (Auto:
smaller on phones)","Pencerenin boyutu (Otomatik: telefonda daha
k\195\188\195\167\195\188k)","Tama\195\177o de la ventana (Autom\195\161tico: m\195\161s

peque\195\177a en m\195\179viles)","Tamanho da janela (Autom\195\161tico: menor no
celular)")l("Language","Dil","Idioma","Idioma")l("Hide / show key","Gizle / g\195\182ster
tu\197\159u","Tecla mostrar / ocultar","Tecla mostrar / ocultar")l("Help lines","Yard\196\177m
sat\196\177rlar\196\177","L\195\173neas de ayuda","Linhas de ajuda")l("Reset to loader
settings","Loader ayarlar\196\177na d\195\182n","Volver a los ajustes del loader","Voltar \195\160s
op\195\167\195\181es do loader")l("What this script does (report)","Bu script ne yap\196\177yor
(rapor)","Qu\195\169 hace este script (informe)","O que este script faz
(relat\195\179rio)")l("Closed the window?","Pencereyi kapatt\196\177n m\196\177?","\194\191Cerraste
la ventana?","Fechou a janela?")l("Needs doable here first","Burada yap\196\177labilenler
\195\182nce","Primero lo que se hace aqu\195\173","Primeiro o que d\195\161 pra fazer
aqui")l("Stuck recovery (go home)","Tak\196\177l\196\177nca kurtar (eve git)","Recuperar si se
atasca (a casa)","Recuperar se travar (ir pra casa)")l("Stuck after","Tak\196\177lm\196\177\197\159
say\196\177lma","Atascado tras","Travado ap\195\179s")l("Rejoin when
stuck","Tak\196\177l\196\177nca yeniden kat\196\177l","Reunirse si se atasca","Reentrar se
travar")l("Rejoin after","Yeniden kat\196\177lma","Reunirse tras","Reentrar ap\195\179s")l("Game
travel (doors)","Oyunun kap\196\177lar\196\177yla git","Viajar por puertas","Viajar pelas
portas")l("Go home by respawn","Eve respawn ile git","Ir a casa reapareciendo","Ir pra casa
renascendo")l("Food bowl trips","Mama kab\196\177 yolculuklar\196\177","Viajes al plato","Idas ao
pote de comida")l("Camp / beach","Kamp / plaj","Campamento / playa","Acampamento / praia")l("Retry
failed after","Ba\197\159ar\196\177s\196\177z\196\177 tekrar deneme","Reintentar fallidas
tras","Tentar falhas ap\195\179s")l("Fails before rest","Dinlenmeden \195\182nce hata","Fallos
antes de pausar","Falhas antes da pausa")l("Rest for","Dinlenme s\195\188resi","Pausa de","Pausa
de")l("Console shows","Konsolda g\195\182ster","La consola muestra","O console mostra")l("Copy
Discord invite","Discord davetini kopyala","Copiar invitaci\195\179n de Discord","Copiar convite do
Discord")l("Copy GitHub link","GitHub ba\196\159lant\196\177s\196\177n\196\177 kopyala","Copiar
enlace de GitHub","Copiar link do GitHub")l("Your setup","Kurulumun","Tu equipo","Seu
sistema")l("Correct network only","Sadece do\196\159ru a\196\159","Solo la red correcta","Somente a
rede certa")l("Auto","Otomatik","Autom\195\161tico","Autom\195\161tico")l("Pet me","Sev
beni","Acar\195\173ciame","Me
acaricie")l("Hungry","A\195\167","Hambre","Fome")l("Thirsty","Susam\196\177\197\159","Sed","Sede")l
("Play","Oyun","Jugar","Brincar")l("Sleepy","Uykulu","Sue\195\177o","Sono")l("Dirty","Kirli","Sucio
","Sujo")l("Toilet","Tuvalet","Ba\195\177o","Banheiro")l("Walk","Y\195\188r\195\188y\195\188\197\15
9","Paseo","Passeio")l("Ride","Gezinti","Paseo en carrito","Passeio de carrinho")l("Mystery
card","Gizemli kart","Carta misteriosa","Carta
misteriosa")l("Salon","Kuaf\195\182r","Sal\195\179n","Sal\195\163o")l("Cat Cafe","Kedi
Kafe","Caf\195\169 de gatos","Caf\195\169 dos gatos")l("Pizza party","Pizza partisi","Fiesta de
pizza","Festa da
pizza")l("School","Okul","Escuela","Escola")l("Sick","Hasta","Enfermo","Doente")l("Camping","Kamp",
"Campamento","Acampamento")l("Beach party","Plaj partisi","Fiesta en la playa","Festa na
praia")l("Bored","S\196\177k\196\177lm\196\177\197\159","Aburrido","Entediado")l("Age-Up
Potion","Ya\197\159 \196\176ksiri","Poci\195\179n de edad","Po\195\167\195\163o de idade")l("Tiny
Age-Up Potion","K\195\188\195\167\195\188k Ya\197\159 \196\176ksiri","Poci\195\179n de edad
peque\195\177a","Po\195\167\195\163o de idade pequena")l("Bucks Potion","Bucks
\196\176ksiri","Poci\195\179n de Bucks","Po\195\167\195\163o de Bucks")l("Next floor (Mummy
Spider)","Sonraki kat (Mumya \195\150r\195\188mcek)","Siguiente piso (Ara\195\177a
momia)","Pr\195\179ximo andar (Aranha m\195\186mia)")l("Twig","Dal","Ramita","Graveto")l("Big candy
pile","B\195\188y\195\188k \197\159eker y\196\177\196\159\196\177n\196\177","Mont\195\179n grande
de dulces","Pilha grande de doces")l("Small candy pile","K\195\188\195\167\195\188k \197\159eker
y\196\177\196\159\196\177n\196\177","Mont\195\179n peque\195\177o de dulces","Pilha pequena de
doces")l("Cracked Egg (350 Bucks)","\195\135atlak Yumurta (350 Bucks)","Huevo agrietado (350
Bucks)","Ovo rachado (350 Bucks)")l("Pet Egg (600 Bucks)","Pet Yumurtas\196\177 (600 Bucks)","Huevo
de mascota (600 Bucks)","Ovo de pet (600 Bucks)")l("Fairytale Egg (event)","Masal Yumurtas\196\177
(etkinlik)","Huevo de cuento (evento)","Ovo de conto
(evento)")l("Summaries","\195\150zetler","Res\195\186menes","Resumos")l("Finished needs","Biten
ihtiya\195\167lar","Necesidades hechas","Necessidades
feitas")l("Stopped","Durduruldu","Detenido","Parado")l("Last run ended badly","Son
\195\167al\196\177\197\159ma k\195\182t\195\188 bitti","La \195\186ltima sesi\195\179n
termin\195\179 mal","A \195\186ltima sess\195\163o terminou mal")l("Neon pets","Neon
petler","Mascotas ne\195\179n","Pets neon")l("Oldest pets (closest to grown)","En
ya\197\159l\196\177 petler (b\195\188y\195\188meye yak\196\177n)","Las m\195\161s viejas (casi
adultas)","Os mais velhos (quase
adultos)")l("Teleport","I\197\159\196\177nlan","Teletransporte","Teleporte")l("Shop
door","D\195\188kkan kap\196\177s\196\177","Puerta de la tienda","Porta da loja")l("Nothing
skipped: every need","Hi\195\167biri atlanm\196\177yor: her ihtiya\195\167","Nada saltado:
todas","Nada pulado: todas")l("Any growing pet (youngest first)","B\195\188y\195\188yen herhangi
bir pet (en gen\195\167 \195\182nce)","Cualquiera que crezca (la m\195\161s joven
primero)","Qualquer pet crescendo (o mais novo primeiro)")l("Using every potion","Her iksir
kullan\196\177l\196\177yor","Usando todas las pociones","Usando todas as
po\195\167\195\181es")l("Pick what to buy","Al\196\177nacaklar\196\177 se\195\167","Elige
qu\195\169 comprar","Escolha o que comprar")l("No pings","Etiket yok","Sin menciones","Sem
men\195\167\195\181es")l("Pick a saved config","Kay\196\177tl\196\177 bir ayar se\195\167","Elige
una configuraci\195\179n","Escolha uma configura\195\167\195\163o")l("e.g. main farm","\195\182r.
ana \195\167iftlik","ej. granja principal","ex. fazenda principal")l("digits, e.g.
123456789012345678","rakamlar, \195\182r. 123456789012345678","d\195\173gitos, ej.

123456789012345678","d\195\173gitos, ex. 123456789012345678")l("errors / kicks go here; empty = the
main one","hatalar / at\196\177lmalar buraya; bo\197\159 = ana adres","errores / expulsiones
aqu\195\173; vac\195\173o = el principal","erros / expuls\195\181es aqui; vazio = o
principal")l("Stops the running task and goes home (respawn first).","\195\135al\196\177\197\159an
g\195\182revi durdurur ve eve gider (\195\182nce respawn).","Detiene la tarea y va a casa
(reaparece primero).","Para a tarefa e vai pra casa (renasce primeiro).")l("Stops the running task;
it is not chosen again for 90 s.","\195\135al\196\177\197\159an g\195\182revi durdurur; 90 sn
tekrar se\195\167ilmez.","Detiene la tarea; no se elige otra vez en 90 s.","Para a tarefa;
n\195\163o \195\169 escolhida de novo por 90 s.")l("Tasks that failed 3 times in a row may run
again now.","\195\156st \195\188ste 3 kez ba\197\159ar\196\177s\196\177z olan g\195\182revler
\197\159imdi tekrar \195\167al\196\177\197\159abilir.","Las tareas que fallaron 3 veces seguidas
pueden volver a correr.","Tarefas que falharam 3 vezes seguidas podem rodar de novo.")l("Everything
stops and cleans up (run the loader again to start).","Her \197\159ey durur ve temizlenir
(ba\197\159latmak i\195\167in loader\'\196\177 tekrar \195\167al\196\177\197\159t\196\177r).","Todo
se detiene y se limpia (ejecuta el loader para empezar).","Tudo para e \195\169 limpo (rode o
loader de novo para come\195\167ar).")l("Claims the pen (at home), takes full grown pets out, fills
it with pets that still grow","A\196\159\196\177l\196\177 toplar (evde),
b\195\188y\195\188m\195\188\197\159 petleri \195\167\196\177kar\196\177r,
b\195\188y\195\188yenlerle doldurur","Reclama el corral (en casa), saca las adultas y lo llena con
las que crecen","Coleta o cercadinho (em casa), tira os adultos e enche com pets crescendo")l("Buys
eggs (Bucks) so the pen always has pets that grow; needs \'Buy an egg\'","A\196\159\196\177lda hep
b\195\188y\195\188yen pet olsun diye yumurta al\196\177r (Bucks); \'Yumurta al\' a\195\167\196\177k
olmal\196\177","Compra huevos (Bucks) para que el corral tenga mascotas que crecen; necesita
\'Comprar huevo\'","Compra ovos (Bucks) para o cercadinho ter pets crescendo; precisa de \'Comprar
ovo\'")l("Goes home if needed and claims / refills the Pet Pen once.","Gerekirse eve gider ve Pet
A\196\159\196\177l\196\177n\196\177 bir kez toplar / doldurur.","Va a casa si hace falta y reclama
/ rellena el corral una vez.","Vai pra casa se preciso e coleta / enche o cercadinho uma
vez.")l("Does every pet need; pick below the ones to skip. Buys 1 food / water only when it has
none.","Her pet ihtiyac\196\177n\196\177 yapar; atlanacaklar\196\177 a\197\159a\196\159\196\177dan
se\195\167. Yiyecek / su yoksa sadece 1 tane al\196\177r.","Hace cada necesidad; elige abajo las
que saltar. Compra 1 comida / agua solo si no tiene.","Faz cada necessidade; escolha abaixo as que
pular. Compra 1 comida / \195\161gua s\195\179 quando n\195\163o tem.")l("Needs picked here are NOT
done","Burada se\195\167ilen ihtiya\195\167lar YAPILMAZ","Las elegidas aqu\195\173 NO se hacen","As
escolhidas aqui N\195\131O s\195\163o feitas")l("Keeps a pet that still grows equipped; a full
grown one is swapped","B\195\188y\195\188yen bir peti elde tutar;
b\195\188y\195\188m\195\188\197\159 olan de\196\159i\197\159tirilir","Mantiene equipada una mascota
que crece; una adulta se cambia","Mant\195\169m um pet crescendo equipado; um adulto \195\169
trocado")l("These pets get the needs, potions and Pet Pen first","Bu petler ihtiya\195\167, iksir
ve Pet A\196\159\196\177l\196\177nda \195\182nceliklidir","Estas mascotas reciben primero
necesidades, pociones y corral","Estes pets recebem primeiro necessidades, po\195\167\195\181es e
cercadinho")l("Uses every potion that helps farming on the growing pet; pick below the ones to
keep","Farma yard\196\177m eden her iksiri b\195\188y\195\188yen pette kullan\196\177r;
saklanacaklar\196\177 a\197\159a\196\159\196\177dan se\195\167","Usa cada poci\195\179n \195\186til
en la mascota que crece; elige abajo las que guardar","Usa toda po\195\167\195\163o \195\186til no
pet crescendo; escolha abaixo as que guardar")l("Potions picked here are kept (never used)","Burada
se\195\167ilen iksirler saklan\196\177r (kullan\196\177lmaz)","Las elegidas aqu\195\173 se guardan
(nunca se usan)","As escolhidas aqui s\195\163o guardadas (nunca usadas)")l("4 full grown pets of
one kind -> 1 neon","Ayn\196\177 t\195\188rden 4 b\195\188y\195\188m\195\188\197\159 pet -> 1
neon","4 adultas del mismo tipo -> 1 ne\195\179n","4 adultos do mesmo tipo -> 1 neon")l("4 full
grown neons of one kind -> 1 mega neon","Ayn\196\177 t\195\188rden 4
b\195\188y\195\188m\195\188\197\159 neon -> 1 mega neon","4 neones adultos del mismo tipo -> 1 mega
ne\195\179n","4 neons adultos do mesmo tipo -> 1 mega neon")l("Joins every round and vacuums the
ghosts (Rusty Keys)","Her tura kat\196\177l\196\177r ve hayaletleri s\195\188p\195\188r\195\188r
(Pasl\196\177 Anahtar)","Entra a cada ronda y aspira fantasmas (llaves oxidadas)","Entra em cada
rodada e aspira fantasmas (chaves enferrujadas)")l("Opens Crypt graves with your Rusty Keys; pick
below what to open","Pasl\196\177 anahtarlarla mahzen mezarlar\196\177n\196\177 a\195\167ar; ne
a\195\167\196\177laca\196\159\196\177n\196\177 a\197\159a\196\159\196\177dan se\195\167","Abre
tumbas de la cripta con tus llaves; elige abajo qu\195\169 abrir","Abre t\195\186mulos da cripta
com suas chaves; escolha abaixo o que abrir")l("What a Rusty Key opens, in this
order","Pasl\196\177 anahtar\196\177n a\195\167acaklar\196\177, bu s\196\177rayla","Lo que abre una
llave, en este orden","O que uma chave abre, nesta ordem")l("Has a Crypt Twig: takes it to the
Hotel nest","Mahzen dal\196\177 varsa Otel\'deki yuvaya g\195\182t\195\188r\195\188r","Si tiene una
ramita, la lleva al nido del hotel","Se tiver um graveto, leva ao ninho do hotel")l("Buys the pets
picked below with candy, as many as the candy pays for","A\197\159a\196\159\196\177da
se\195\167ilen petleri \197\159ekerle, \197\159ekerin yetti\196\159i kadar al\196\177r","Compra con
dulces las mascotas elegidas, tantas como alcance","Compra com doces os pets escolhidos, quantos
der")l("No limit: bought whenever the candy is enough","S\196\177n\196\177r yok: \197\159eker
yettik\195\167e al\196\177n\196\177r","Sin l\195\173mite: se compra cuando alcanza","Sem limite:
compra quando der")l("Sends one test message to your webhook.","Webhook\'una bir test mesaj\196\177
g\195\182nderir.","Env\195\173a un mensaje de prueba a tu webhook.","Envia uma mensagem de teste
para o seu webhook.")l("@mentions you on the messages picked below","A\197\159a\196\159\196\177da
se\195\167ilen mesajlarda seni etiketler","Te menciona en los mensajes elegidos abajo","Menciona
voc\195\170 nas mensagens escolhidas abaixo")l("Which messages @mention you","Hangi mesajlar seni
etiketlesin","Qu\195\169 mensajes te mencionan","Quais mensagens mencionam voc\195\170")l("A

summary message (needs done, Bucks, pet) every few minutes","Birka\195\167 dakikada bir \195\182zet
mesaj\196\177 (ihtiya\195\167lar, Bucks, pet)","Un resumen (necesidades, Bucks, mascota) cada pocos
minutos","Um resumo (necessidades, Bucks, pet) a cada poucos minutos")l("Saves every setting of the
window under the name above.","Penceredeki t\195\188m ayarlar\196\177 yukar\196\177daki adla
saklar.","Guarda todos los ajustes con el nombre de arriba.","Salva todas as op\195\167\195\181es
com o nome acima.")l("Saves the current settings into the picked config.","\197\158u anki
ayarlar\196\177 se\195\167ilen kayda yazar.","Guarda los ajustes actuales en la elegida.","Salva as
op\195\167\195\181es atuais na escolhida.")l("Puts the picked config\'s settings in place
now.","Se\195\167ilen kayd\196\177n ayarlar\196\177n\196\177 \197\159imdi uygular.","Aplica ahora
los ajustes elegidos.","Aplica agora as op\195\167\195\181es escolhidas.")l("Deletes the picked
config file.","Se\195\167ilen kay\196\177t dosyas\196\177n\196\177 siler.","Borra el archivo
elegido.","Apaga o arquivo escolhido.")l("On: every change in the window is kept on this device.
Off: changes last until you leave; save a config instead","A\195\167\196\177k: penceredeki her
de\196\159i\197\159iklik bu cihazda saklan\196\177r. Kapal\196\177: oyundan \195\167\196\177kana
kadar s\195\188rer; bunun yerine kay\196\177t al","S\195\173: cada cambio se guarda en este
dispositivo. No: dura hasta salir; guarda una configuraci\195\179n","Ligado: cada mudan\195\167a
fica salva neste aparelho. Desligado: dura at\195\169 sair; salve uma
configura\195\167\195\163o")l("At every start, the config picked above is put in place","Her
a\195\167\196\177l\196\177\197\159ta yukar\196\177da se\195\167ilen kay\196\177t
uygulan\196\177r","En cada inicio se aplica la configuraci\195\179n elegida","A cada in\195\173cio
a configura\195\167\195\163o escolhida \195\169 aplicada")l("Clicks on Roblox\'s idle warning (no
idle kick)","Roblox\'un bo\197\159ta uyar\196\177s\196\177na t\196\177klar
(at\196\177lmazs\196\177n)","Pulsa el aviso de inactividad (sin expulsi\195\179n)","Clica no aviso
de inatividade (sem expuls\195\163o)")l("The camera went inside your character: it is zoomed back
out","Kamera karakterinin i\195\167ine girerse geri uzakla\197\159t\196\177r\196\177l\196\177r","Si
la c\195\161mara entra en tu personaje, se aleja","Se a c\195\162mera entrar no personagem, ela se
afasta")l("Pop-ups for keys, neon, purchases, rounds","Anahtar, neon,
al\196\177\197\159veri\197\159 ve tur bildirimleri","Avisos de llaves, ne\195\179n, compras,
rondas","Avisos de chaves, neon, compras, rodadas")l("Every change made in the window goes back to
the loader\'s value, now and at the next start.","Pencerede yap\196\177lan her
de\196\159i\197\159iklik loader de\196\159erine d\195\182ner, \197\159imdi ve sonraki
a\195\167\196\177l\196\177\197\159ta.","Cada cambio vuelve al valor del loader, ahora y al
pr\195\179ximo inicio.","Cada mudan\195\167a volta ao valor do loader, agora e no pr\195\179ximo
in\195\173cio.")l("Back to the loader\'s settings.","Loader ayarlar\196\177na
d\195\182n\195\188ld\195\188.","Ajustes del loader de nuevo.","Op\195\167\195\181es do loader de
novo.")l("Drag, or tap the number to type a value.","S\195\188r\195\188kle ya da say\196\177ya
dokunup yaz.","Arrastra o toca el n\195\186mero para escribirlo.","Arraste ou toque no
n\195\186mero para digitar.")l("Copies the Discord invite","Discord davetini kopyalar","Copia la
invitaci\195\179n de Discord","Copia o convite do Discord")l("Which language the window uses (Auto:
your country\'s)","Pencerenin dili (Otomatik: \195\188lkenin dili)","Idioma de la ventana
(Autom\195\161tico: el de tu pa\195\173s)","Idioma da janela (Autom\195\161tico: o do seu
pa\195\173s)")l("Master switch. Off = no game actions at all","Ana \197\159alter. Kapal\196\177 =
hi\195\167bir oyun i\197\159lemi yok","Interruptor principal. No = ninguna acci\195\179n","Chave
geral. Desligado = nenhuma a\195\167\195\163o")l("Joins the Babies team to do baby needs
too","Bebek ihtiya\195\167lar\196\177 i\195\167in Bebek tak\196\177m\196\177na ge\195\167er","Se
une al equipo Beb\195\169s para sus necesidades","Entra no time Beb\195\170s para as necessidades
deles")l("While waiting at a place: food, drink, toy, petting","Bir yerde beklerken: yemek,
i\195\167ecek, oyuncak, sevme","Mientras espera: comida, bebida, juguete, caricias","Enquanto
espera: comida, bebida, brinquedo, carinho")l("No drink left: buys 1 water (1
Buck)","\196\176\195\167ecek kalmazsa 1 su al\196\177r (1 Buck)","Sin bebida: compra 1 agua (1
Buck)","Sem bebida: compra 1 \195\161gua (1 Buck)")l("No food left: buys 1 sandwich /
hotdog","Yiyecek kalmazsa 1 sandvi\195\167 / sosisli al\196\177r","Sin comida: compra 1
s\195\161ndwich / perrito","Sem comida: compra 1 sandu\195\173che / cachorro-quente")l("No pet out:
equips a pet that still grows","Pet yoksa b\195\188y\195\188yen bir pet
\195\167\196\177kar\196\177r","Sin mascota: equipa una que crece","Sem pet: equipa um que ainda
cresce")l("Swaps a full grown pet for a growing one","B\195\188y\195\188m\195\188\197\159 peti
b\195\188y\195\188yen biriyle de\196\159i\197\159tirir","Cambia una adulta por una que
crece","Troca um adulto por um que cresce")l("Growing neon pets are farmed
first","B\195\188y\195\188yen neon petler \195\182nce beslenir","Primero las ne\195\179n que
crecen","Primeiro os neons crescendo")l("Age potions on the farmed growing pet","Beslenen pete
ya\197\159 iksiri","Pociones de edad en la mascota","Po\195\167\195\181es de idade no pet")l("4
full grown of one kind -> 1 neon","Ayn\196\177 t\195\188rden 4 b\195\188y\195\188m\195\188\197\159
-> 1 neon","4 adultas del mismo tipo -> 1 ne\195\179n","4 adultos do mesmo tipo -> 1 neon")l("No
growing pet left: buys 1 egg (Bucks only)","B\195\188y\195\188yen pet kalmazsa 1 yumurta
al\196\177r (sadece Bucks)","Sin mascota que crezca: compra 1 huevo (solo Bucks)","Sem pet
crescendo: compra 1 ovo (s\195\179 Bucks)")l("Opens gifts and chests in your
backpack","\195\135antandaki hediye ve sand\196\177klar\196\177 a\195\167ar","Abre regalos y cofres
de tu mochila","Abre presentes e ba\195\186s da mochila")l("Master switch for every Halloween
job","T\195\188m Cad\196\177lar Bayram\196\177 i\197\159leri i\195\167in ana
\197\159alter","Interruptor de todo Halloween","Chave geral do Halloween")l("Auto
Hauntlet","Otomatik Hauntlet","Hauntlet autom\195\161tico","Hauntlet autom\195\161tico")l("Auto
Hauntlet \226\128\148 join runs, pick safer doors, use keys/items","Otomatik Hauntlet \226\128\148
kat\196\177l, daha g\195\188venli kap\196\177 se\195\167, item kullan","Hauntlet autom\195\161tico
\226\128\148 entra, elige puertas seguras, usa llaves/objetos","Hauntlet autom\195\161tico

\226\128\148 entra, escolhe portas seguras, usa chaves/itens")l("Hauntlet run","Hauntlet
turu","Partida de Hauntlet","Partida de Hauntlet")l("Auto Skelicorn","Otomatik
Skelicorn","Skelicorn autom\195\161tico","Skelicorn autom\195\161tico")l("Lightning Lever from the
Crypt -> machine by the Manor -> 1 Skelicorn (120k candy)","Crypt\'ten \197\158im\197\159ek Kolu ->
Malikane yan\196\177ndaki makine -> 1 Skelicorn (120k \197\159eker)","Palanca del Rayo de la Cripta
-> m\195\161quina junto a la Mansi\195\179n -> 1 Skelicorn (120k dulces)","Alavanca do Raio da
Cripta -> m\195\161quina perto da Mans\195\163o -> 1 Skelicorn (120k doces)")l("Hauntlet before
Ghost Gallery","Hauntlet, Ghost Gallery\'den \195\182nce","Hauntlet antes que Ghost
Gallery","Hauntlet antes da Ghost Gallery")l("A Hauntlet run comes first when a Ghost Gallery round
is near","Ghost Gallery turu yak\196\177nken \195\182nce Hauntlet\'e girer","Primero Hauntlet si
una ronda de Ghost Gallery est\195\161 cerca","Primeiro Hauntlet se uma rodada da Ghost Gallery
estiver perto")l("Hauntlet squad play","Hauntlet tak\196\177m oyunu","Hauntlet en equipo","Hauntlet
em equipe")l("Your accounts in one run take turns with phone / keys / wand","Ayn\196\177 runda
hesaplar\196\177n telefon / anahtar / asa i\195\167in s\196\177ra al\196\177r","Tus cuentas en una
partida se turnan con tel\195\169fono / llaves / varita","Suas contas na partida revezam telefone /
chaves / varinha")l("Joins each round, vacuums ghosts (Rusty Keys)","Her tura
kat\196\177l\196\177r, hayaletleri s\195\188p\195\188r\195\188r (Pasl\196\177 Anahtar)","Entra a
cada ronda, aspira fantasmas","Entra em cada rodada, aspira fantasmas")l("Joins by standing in the
Manor circle","Malikanedeki \195\167embere girerek kat\196\177l\196\177r","Entra par\195\161ndose
en el c\195\173rculo de la mansi\195\179n","Entra ficando no c\195\173rculo da
mans\195\163o")l("Uses Rusty Keys on the grave going down","A\197\159a\196\159\196\177 inerken
mezarda Pasl\196\177 Anahtar kullan\196\177r","Usa llaves en la tumba al bajar","Usa chaves no
t\195\186mulo ao descer")l("Bottom of the Crypt: takes the spider","Mahzenin dibinde
\195\182r\195\188mce\196\159i al\196\177r","Fondo de la cripta: toma la ara\195\177a","Fundo da
cripta: pega a aranha")l("Claims finished daily + board quests","Biten g\195\188nl\195\188k ve pano
g\195\182revlerini toplar","Reclama misiones diarias y del tablero","Resgata miss\195\181es
di\195\161rias e do quadro")l("Visit-homes quests: visits houses here","Ev ziyareti
g\195\182revleri: buradaki evleri gezer","Misiones de visitas: visita casas
aqu\195\173","Miss\195\181es de visita: visita casas aqui")l("Puts Crypt Twigs into the Hotel
nest","Mahzen dallar\196\177n\196\177 Otel\'deki yuvaya koyar","Pone ramitas en el nido del
hotel","P\195\181e gravetos no ninho do hotel")l("Twig graves first until the nest is built","Yuva
bitene kadar \195\182nce dall\196\177 mezarlar","Primero tumbas con ramitas hasta el
nido","Primeiro t\195\186mulos com gravetos at\195\169 o ninho")l("1 water to the Stray Cat a day
(+candy)","Sokak kedisine g\195\188nde 1 su (+\197\159eker)","1 agua al gato callejero al
d\195\173a (+dulces)","1 \195\161gua ao gato de rua por dia (+doces)")l("Claims the pen, keeps it
full (at home)","A\196\159\196\177l\196\177 toplar, dolu tutar (evde)","Reclama el corral y lo
llena (en casa)","Coleta o cercadinho e mant\195\169m cheio (em casa)")l("Buys eggs so the pen
stays full","A\196\159\196\177l dolu kals\196\177n diye yumurta al\196\177r","Compra huevos para
llenar el corral","Compra ovos para manter o cercadinho cheio")l("How often the pen is
claimed","A\196\159\196\177l\196\177n ne s\196\177kl\196\177kla
topland\196\177\196\159\196\177","Cada cu\195\161nto se reclama el corral","De quanto em quanto
tempo coletar")l("Saves candy for the pets in your list","Listendeki petler i\195\167in
\197\159eker biriktirir","Ahorra dulces para tu lista","Guarda doces para a sua lista")l("Clicks on
Roblox\'s idle warning (also paused)","Roblox\'un bo\197\159ta uyar\196\177s\196\177na
t\196\177klar (durakken de)","Pulsa el aviso de inactividad (tambi\195\169n en pausa)","Clica no
aviso de inatividade (tamb\195\169m pausado)")l("Clicks Play on the main menu (also paused)","Ana
men\195\188de Play\'e basar (durakken de)","Pulsa Play en el men\195\186 (tambi\195\169n en
pausa)","Clica em Play no menu (tamb\195\169m pausado)")l("Collects cashback Bucks (while
running)","Para iadesi Bucks\'lar\196\177 toplar (\195\167al\196\177\197\159\196\177rken)","Cobra
el reembolso de Bucks (activa)","Coleta o cashback de Bucks (ligada)")l("No place / character:
rejoins a PUBLIC server","Yer / karakter yoksa HERKESE A\195\135IK sunucuya girer","Sin lugar /
personaje: entra a un servidor P\195\154BLICO","Sem lugar / personagem: entra num servidor
P\195\154BLICO")l("How long before that rejoin","Yeniden kat\196\177lmadan \195\182nceki
s\195\188re","Cu\195\161nto antes de reunirse","Quanto antes de reentrar")l("Travels with the
game\'s own doors","Oyunun kendi kap\196\177lar\196\177yla gider","Viaja por las puertas del
juego","Viaja pelas portas do jogo")l("Goes home by respawn (fastest)","Eve respawn ile gider (en
h\196\177zl\196\177)","Va a casa reapareciendo (m\195\161s r\195\161pido)","Vai pra casa renascendo
(mais r\195\161pido)")l("Route to camping / beach / playground","Kamp / plaj / oyun park\196\177
yolu","Ruta al campamento / playa / parque","Rota para acampamento / praia / parquinho")l("Goes
home for the free bowl even with food","Yiyecek olsa da bedava mama kab\196\177 i\195\167in eve
gider","Va a casa por el plato gratis aunque tenga comida","Vai pra casa pelo pote gr\195\161tis
mesmo com comida")l("Which growing pet first: youngest / oldest","\195\150nce hangi pet: en
gen\195\167 / en ya\197\159l\196\177","Cu\195\161l primero: la m\195\161s joven / vieja","Qual
primeiro: o mais novo / velho")l("Egg bought with Bucks (never Robux)","Bucks ile al\196\177nan
yumurta (asla Robux)","Huevo con Bucks (nunca Robux)","Ovo com Bucks (nunca Robux)")l("Pet kinds
farmed first, comma separated","\195\150nce beslenen t\195\188rler, virg\195\188lle","Tipos
primero, separados por comas","Tipos primeiro, separados por v\195\173rgula")l("Potions only on
these kinds (empty = any)","\196\176ksir sadece bu t\195\188rlere (bo\197\159 = hepsi)","Pociones
solo en estos tipos (vac\195\173o = todos)","Po\195\167\195\181es s\195\179 nestes tipos (vazio =
todos)")l("Needs doable right here go first","Burada yap\196\177labilen ihtiya\195\167lar
\195\182nce","Primero lo que se hace aqu\195\173","Primeiro o que d\195\161 pra fazer aqui")l("Not
moving, tasks failing: respawn home","Hareket yok, g\195\182revler ba\197\159ar\196\177s\196\177z:
eve respawn","Sin moverse y fallando: reaparece en casa","Parado e falhando: renasce em
casa")l("How long before it counts as stuck","Tak\196\177lm\196\177\197\159 say\196\177lmadan

\195\182nceki s\195\188re","Cu\195\161nto antes de contar como atascado","Quanto antes de contar
como travado")l("3 fails in a row: rest (0 = whole session)","\195\156st \195\188ste 3 hata: dinlen
(0 = t\195\188m oturum)","3 fallos seguidos: pausa (0 = toda la sesi\195\179n)","3 falhas seguidas:
pausa (0 = sess\195\163o toda)")l("Max food / water buys (0 = no limit)","En fazla yiyecek / su
al\196\177m\196\177 (0 = s\196\177n\196\177rs\196\177z)","M\195\161x. compras de comida / agua (0 =
sin l\195\173mite)","M\195\161x. compras de comida / \195\161gua (0 = sem limite)")l("Max egg buys
(0 = no limit)","En fazla yumurta al\196\177m\196\177 (0 =
s\196\177n\196\177rs\196\177z)","M\195\161x. huevos (0 = sin l\195\173mite)","M\195\161x. ovos (0 =
sem limite)")l("Window colours","Pencere renkleri","Colores de la ventana","Cores da
janela")l("These lines (the window opens again)","Bu sat\196\177rlar (pencere yeniden
a\195\167\196\177l\196\177r)","Estas l\195\173neas (la ventana se reabre)","Estas linhas (a janela
reabre)")l("Starts closed: the key / paw button opens it","Kapal\196\177 ba\197\159lar: tu\197\159
/ pati d\195\188\196\159mesi a\195\167ar","Empieza cerrada: la tecla / bot\195\179n de pata la
abre","Come\195\167a fechada: a tecla / bot\195\163o de pata abre")l("Bug reports to the developer
(off: at once)","Geli\197\159tiriciye hata raporu (kapat\196\177nca hemen durur)","Informes de
errores al desarrollador","Relat\195\179rios de erro ao desenvolvedor")l("How often cashback is
collected","Para iadesinin toplanma s\196\177kl\196\177\196\159\196\177","Cada cu\195\161nto se
cobra el reembolso","De quanto em quanto coletar o cashback")l("4 free slots; 5 with the extra-slot
pass","4 bedava yer; ek yer ge\195\167i\197\159iyle 5","4 espacios gratis; 5 con el pase","4 vagas
gr\195\161tis; 5 com o passe")l("Buys pen eggs only above these Bucks","A\196\159\196\177l
yumurtas\196\177n\196\177 sadece bu Bucks \195\188st\195\188nde al\196\177r","Compra huevos solo
con m\195\161s Bucks que esto","Compra ovos s\195\179 acima destes Bucks")l("Which quick needs run
beside a place need","Bir yer ihtiyac\196\177n\196\177n yan\196\177nda hangi h\196\177zl\196\177
ihtiya\195\167lar","Qu\195\169 necesidades r\195\161pidas van junto a otra","Quais necessidades
r\195\161pidas junto de outra")l("Pause between two quick needs","\196\176ki h\196\177zl\196\177
ihtiya\195\167 aras\196\177 bekleme","Pausa entre dos necesidades r\195\161pidas","Pausa entre duas
necessidades r\195\161pidas")l("Pet kinds that are never fused","Asla birle\197\159tirilmeyen
t\195\188rler","Tipos que nunca se fusionan","Tipos que nunca s\195\163o fundidos")l("Gifts /
chests that are never opened","Asla a\195\167\196\177lmayan hediye / sand\196\177klar","Regalos /
cofres que nunca se abren","Presentes / ba\195\186s que nunca s\195\163o abertos")l("Which age
potions may be used","Hangi ya\197\159 iksirleri kullan\196\177labilir","Qu\195\169 pociones de
edad se usan","Quais po\195\167\195\181es de idade usar")l("Wait after a failed task before a
retry","Ba\197\159ar\196\177s\196\177z g\195\182revden sonra tekrar deneme beklemesi","Espera tras
un fallo antes de reintentar","Espera ap\195\179s falha antes de tentar")l("Fails in a row before a
task rests","G\195\182rev dinlenmeden \195\182nce \195\188st \195\188ste hata","Fallos seguidos
antes de pausar","Falhas seguidas antes da pausa")l("Experimental: leave home by its
door","Deneysel: evden kap\196\177dan \195\167\196\177k","Experimental: salir por la
puerta","Experimental: sair pela porta")l("Candy kept back, whatever the list wants","Liste ne
isterse istesin ayr\196\177lan \197\159eker","Dulces que se guardan siempre","Doces guardados
sempre")l("How much the console shows (OFF = quiet)","Konsolun ne kadar g\195\182sterdi\196\159i
(OFF = sessiz)","Cu\195\161nto muestra la consola (OFF = silencio)","Quanto o console mostra (OFF =
sil\195\170ncio)")l("Reports also list item / pet counts","Raporlar e\197\159ya / pet
say\196\177lar\196\177n\196\177 da g\195\182sterir","Los informes listan objetos /
mascotas","Relat\195\179rios listam itens / pets")l("Key that hides / shows this window","Bu
pencereyi gizleyen / g\195\182steren tu\197\159","Tecla que muestra / oculta la ventana","Tecla que
mostra / oculta a janela")l("Message when the farm starts / stops","\195\135iftlik
ba\197\159lay\196\177nca / durunca mesaj","Mensaje al iniciar / detener","Mensagem ao iniciar /
parar")l("One message per finished need (many)","Biten her ihtiya\195\167 i\195\167in mesaj
(\195\167ok)","Un mensaje por necesidad (muchos)","Uma mensagem por necessidade
(muitas)")l("Message on this script\'s errors","Script hatalar\196\177nda mesaj","Mensaje en
errores del script","Mensagem nos erros do script")l("Message on a kick /
disconnect","At\196\177lma / kopmada mesaj","Mensaje al ser expulsado / desconectado","Mensagem ao
ser expulso / desconectado")l("Your Roblox name in the messages","Mesajlarda Roblox
ad\196\177n","Tu nombre de Roblox en los mensajes","Seu nome do Roblox nas mensagens")l("@mention
you for these messages","Bu mesajlarda seni etiketler","Te menciona en estos mensajes","Menciona
voc\195\170 nestas mensagens")l("Pets your pet until the need is done","\196\176htiya\195\167
bitene kadar peti sever","Acaricia a tu mascota hasta terminar","Acaricia o pet at\195\169
terminar")l("Bowl at home, else your food; buys if on","Evdeki mama kab\196\177, yoksa
yiyece\196\159in; a\195\167\196\177ksa al\196\177r","Plato en casa, si no tu comida; compra si
est\195\161 activo","Pote em casa, sen\195\163o sua comida; compra se ligado")l("Your water / milk;
buys 1 water if on","Suyun / s\195\188t\195\188n; a\195\167\196\177ksa 1 su al\196\177r","Tu agua /
leche; compra 1 agua si est\195\161 activo","Sua \195\161gua / leite; compra 1 \195\161gua se
ligado")l("Throws your squeaky bone","\195\150t\195\188c\195\188 kemi\196\159ini atar","Lanza tu
hueso con sonido","Joga seu osso de apertar")l("Your bed at home (goes home)","Evdeki
yata\196\159\196\177n (eve gider)","Tu cama en casa (va a casa)","Sua cama em casa (vai pra
casa)")l("Your shower at home (goes home)","Evdeki du\197\159un (eve gider)","Tu ducha en casa (va
a casa)","Seu chuveiro em casa (vai pra casa)")l("Your toilet at home (goes home)","Evdeki
tuvaletin (eve gider)","Tu ba\195\177o en casa (va a casa)","Seu vaso em casa (vai pra
casa)")l("Walks your character until done","Bitene kadar karakterini
y\195\188r\195\188t\195\188r","Camina hasta terminar","Anda at\195\169 terminar")l("Walks with your
stroller until done","Bitene kadar bebek arabas\196\177yla y\195\188r\195\188r","Pasea con el
carrito hasta terminar","Passeia com o carrinho at\195\169 terminar")l("Picks a card this script
can do","Scriptin yapabildi\196\159i bir kart se\195\167er","Elige una carta que el script puede
hacer","Escolhe uma carta que o script consegue")l("Goes to the Salon and waits","Kuaf\195\182re

gidip bekler","Va al sal\195\179n y espera","Vai ao sal\195\163o e espera")l("Goes to the Cat Cafe
and waits","Kedi Kafe\'ye gidip bekler","Va al caf\195\169 de gatos y espera","Vai ao caf\195\169
dos gatos e espera")l("Goes to the Pizza Shop and waits","Pizzac\196\177ya gidip bekler","Va a la
pizzer\195\173a y espera","Vai \195\160 pizzaria e espera")l("Goes to School and waits","Okula
gidip bekler","Va a la escuela y espera","Vai \195\160 escola e espera")l("Hospital: talks to the
doctor","Hastane: doktorla konu\197\159ur","Hospital: habla con el doctor","Hospital: fala com o
m\195\169dico")l("Camp site spot on the map","Haritadaki kamp yeri","Zona de campamento del
mapa","Ponto de acampamento no mapa")l("Beach spot on the map","Haritadaki plaj yeri","Zona de
playa del mapa","Ponto da praia no mapa")l("Playground spot on the map","Haritadaki oyun
park\196\177","Parque del mapa","Parquinho no mapa")l("Stop the farm?","\195\135iftlik durdurulsun
mu?","\194\191Detener la granja?","Parar a fazenda?")l("Everything stops and cleans up. Run the
loader again to start.","Her \197\159ey durur ve temizlenir. Ba\197\159latmak i\195\167in
loader\'\196\177 tekrar \195\167al\196\177\197\159t\196\177r.","Todo se detiene. Ejecuta el loader
para empezar.","Tudo para. Rode o loader de novo para
come\195\167ar.")l("Stop","Durdur","Detener","Parar")l("Cancel","Vazge\195\167","Cancelar","Cancela
r")l("Apply","Uygula","Aplicar","Aplicar")l("Apply + start","Uygula + ba\197\159lat","Aplicar +
iniciar","Aplicar +
iniciar")l("Reset","S\196\177f\196\177rla","Restablecer","Redefinir")l("Delete","Sil","Borrar","Apa
gar")l("Stopped.","Durduruldu.","Detenido.","Parado.")l("Done","Tamam","Hecho","Feito")l("Not
possible now","\197\158u an olmuyor","No es posible ahora","N\195\163o d\195\161 agora")l("Not
valid","Ge\195\167ersiz","No v\195\161lido","Inv\195\161lido")l("Not available in this version","Bu
s\195\188r\195\188mde yok","No disponible en esta versi\195\179n","Indispon\195\173vel nesta
vers\195\163o")l("Window","Pencere","Ventana","Janela")l("Building the window again...","Pencere
yeniden kuruluyor...","Rehaciendo la ventana...","Refazendo a janela...")l("Applies when the window
opens again.","Pencere yeniden a\195\167\196\177l\196\177nca ge\195\167erli olur.","Se aplica al
reabrir la ventana.","Vale ao reabrir a janela.")l("Type a name first","\195\150nce bir ad
yaz","Escribe un nombre primero","Digite um nome primeiro")l("Pick a saved config
first","\195\150nce kay\196\177tl\196\177 bir ayar se\195\167","Elige una configuraci\195\179n
primero","Escolha uma configura\195\167\195\163o primeiro")l("The config file is deleted from this
device.","Kay\196\177t dosyas\196\177 bu cihazdan silinir.","El archivo se borra de este
dispositivo.","O arquivo \195\169 apagado deste
aparelho.")l("Autoload","A\195\167\196\177l\196\177\197\159ta y\195\188kle","Carga al
iniciar","Carregar ao iniciar")l("Autoload: off","A\195\167\196\177l\196\177\197\159ta
y\195\188kleme: kapal\196\177","Carga al iniciar: no","Carregar ao iniciar: n\195\163o")l("Autosave
off: save a config instead","Otomatik kay\196\177t kapal\196\177: bunun yerine kay\196\177t
al","Guardado autom\195\161tico no: guarda una configuraci\195\179n","Salvamento autom\195\161tico
desligado: salve uma configura\195\167\195\163o")l("Autosave: on (this device)","Otomatik
kay\196\177t: a\195\167\196\177k (bu cihaz)","Guardado autom\195\161tico: s\195\173 (este
dispositivo)","Salvamento autom\195\161tico: ligado (este aparelho)")l("Reset to loader
settings?","Loader ayarlar\196\177na d\195\182n\195\188ls\195\188n m\195\188?","\194\191Volver a
los ajustes del loader?","Voltar \195\160s op\195\167\195\181es do loader?")l("Transparency
report","\197\158effafl\196\177k raporu","Informe de transparencia","Relat\195\179rio de
transpar\195\170ncia")l("Printed to the console (F9 / executor console).","Konsola
yaz\196\177ld\196\177 (F9 / executor konsolu).","Escrito en la consola (F9 / consola del
executor).","Escrito no console (F9 / console do executor).")l("Hide / show: tap the round paw
button","Gizle / g\195\182ster: yuvarlak pati d\195\188\196\159mesine dokun","Mostrar / ocultar:
toca el bot\195\179n de pata","Mostrar / ocultar: toque no bot\195\163o de pata")l("the round paw
button","yuvarlak pati d\195\188\196\159mesi","el bot\195\179n redondo de pata","o bot\195\163o
redondo de pata")l("the hide / show key","gizle / g\195\182ster tu\197\159u","la tecla mostrar /
ocultar","a tecla mostrar / ocultar")l("Run:
getgenv().AdoptMeFarm.OpenInterface()","\195\135al\196\177\197\159t\196\177r:
getgenv().AdoptMeFarm.OpenInterface()","Ejecuta: getgenv().AdoptMeFarm.OpenInterface()","Rode:
getgenv().AdoptMeFarm.OpenInterface()")l("The farm is running.","\195\135iftlik
\195\167al\196\177\197\159\196\177yor.","La granja est\195\161 activa.","A fazenda est\195\161
ligada.")l("Switch \'Farm running\' on to start.","Ba\197\159latmak i\195\167in \'\195\135iftlik
\195\167al\196\177\197\159\196\177yor\'u a\195\167.","Activa \'Granja activa\' para
empezar.","Ligue \'Fazenda ligada\' para
come\195\167ar.")l("Webhook","Webhook","Webhook","Webhook")l("Webhook removed.","Webhook
kald\196\177r\196\177ld\196\177.","Webhook eliminado.","Webhook removido.")l("Saved on this device.
Press \'Send test message\'.","Bu cihaza kaydedildi. \'Test mesaj\196\177 g\195\182nder\'e
bas.","Guardado aqu\195\173. Pulsa \'Enviar mensaje de prueba\'.","Salvo aqui. Toque em \'Enviar
mensagem de teste\'.")l("That is not a Discord webhook URL (Channel settings > Integrations >
Webhooks)","Bu bir Discord webhook adresi de\196\159il (Kanal ayarlar\196\177 > Entegrasyonlar >
Webhooklar)","No es una URL de webhook de Discord (Canal > Integraciones > Webhooks)","N\195\163o
\195\169 uma URL de webhook do Discord (Canal > Integra\195\167\195\181es > Webhooks)")l("That is
not a Discord webhook URL","Bu bir Discord webhook adresi de\196\159il","No es una URL de webhook
de Discord","N\195\163o \195\169 uma URL de webhook do Discord")l("Digits only (Discord: Settings >
Advanced > Developer Mode, then right click yourself > Copy ID)","Sadece rakam (Discord: Ayarlar >
Geli\197\159mi\197\159 > Geli\197\159tirici Modu, sonra kendine sa\196\159 t\196\177k > ID\'yi
kopyala)","Solo d\195\173gitos (Discord: Ajustes > Avanzado > Modo desarrollador, luego clic
derecho en ti > Copiar ID)","S\195\179 d\195\173gitos (Discord: Configura\195\167\195\181es >
Avan\195\167ado > Modo desenvolvedor, depois clique direito em voc\195\170 > Copiar
ID)")l("Webhook: checking...","Webhook: kontrol ediliyor...","Webhook: comprobando...","Webhook:
verificando...")l("Webhook: ON","Webhook: A\195\135IK","Webhook: S\195\141","Webhook:

LIGADO")l("Webhook: OFF (no URL yet)","Webhook: KAPALI (adres yok)","Webhook: NO (sin
URL)","Webhook: DESLIGADO (sem URL)")l("Waiting for your data...","Verilerin
bekleniyor...","Esperando tus datos...","Esperando seus dados...")l("Join script","Kat\196\177lma
scripti","Script para unirse","Script para entrar")l("Copied: run it in your executor to join this
server","Kopyaland\196\177: bu sunucuya girmek i\195\167in executor\'da
\195\167al\196\177\197\159t\196\177r","Copiado: ejec\195\186talo para unirte a este
servidor","Copiado: rode no executor para entrar neste servidor")l("Could not
copy","Kopyalanamad\196\177","No se pudo copiar","N\195\163o deu para copiar")l("Rusty Key
earned","Pasl\196\177 Anahtar kazan\196\177ld\196\177","Llave oxidada ganada","Chave enferrujada
ganha")l("Mummy Spider claimed","Mumya \195\150r\195\188mcek al\196\177nd\196\177","Ara\195\177a
momia obtenida","Aranha m\195\186mia pega")l("Neon fusion","Neon birle\197\159tirme","Fusi\195\179n
ne\195\179n","Fus\195\163o neon")l("Mega neon!","Mega neon!","\194\161Mega ne\195\179n!","Mega
neon!")l("Candy shop","\197\158eker d\195\188kkan\196\177","Tienda de dulces","Loja de
doces")l("Quest reward","G\195\182rev \195\182d\195\188l\195\188","Premio de
misi\195\179n","Pr\195\170mio de miss\195\163o")l("Pigeon nest built","G\195\188vercin
yuvas\196\177 bitti","Nido de paloma hecho","Ninho de pombo pronto")l("Ghost Gallery
round","Hayalet Galerisi turu","Ronda de la galer\195\173a","Rodada da galeria")l("Task
resting","G\195\182rev dinleniyor","Tarea en pausa","Tarefa em pausa")l("Stuck: going
home","Tak\196\177ld\196\177: eve gidiyor","Atascado: a casa","Travado: indo pra casa")l("Made
Adopt Victims: plain, readable Luau.","Adopt Victims\'\196\177 yapt\196\177: sade, okunabilir
Luau.","Cre\195\179 Adopt Victims: Luau simple y legible.","Criou o Adopt Victims: Luau simples e
leg\195\173vel.")l("Thank you for using it!","Kulland\196\177\196\159\196\177n i\195\167in
te\197\159ekk\195\188rler!","\194\161Gracias por usarlo!","Obrigado por usar!")l("Send each coin
only on the network written next to it. Tokens sent on another network are lost.","Her coini sadece
yan\196\177nda yazan a\196\159dan g\195\182nder. Ba\197\159ka a\196\159dan g\195\182nderilen
tokenler kaybolur.","Env\195\173a cada moneda solo por la red indicada. Los tokens en otra red se
pierden.","Envie cada moeda s\195\179 pela rede indicada. Tokens em outra rede se
perdem.")l("supported","destekleniyor","compatible","compat\195\173vel")l("not tested with this
script","bu scriptle denenmedi","no probado con este script","n\195\163o testado com este
script")l("Everything stopped. Run the loader again to start.","Her \197\159ey durdu.
Ba\197\159latmak i\195\167in loader\'\196\177 tekrar \195\167al\196\177\197\159t\196\177r.","Todo
detenido. Ejecuta el loader para empezar.","Tudo parado. Rode o loader de novo para
come\195\167ar.")l("Nothing is on yet: switch features on (Main / Event) or pick a preset (Config),
then switch Farm running on.","Hen\195\188z hi\195\167bir \197\159ey a\195\167\196\177k
de\196\159il: \195\182zellikleri a\195\167 (Ana sayfa / Etkinlik) ya da haz\196\177r ayar
se\195\167 (Ayarlar), sonra \'\195\135iftlik \195\167al\196\177\197\159\196\177yor\'u
a\195\167.","Nada activo a\195\186n: activa funciones (Principal / Evento) o elige un ajuste
(Config) y luego \'Granja activa\'.","Nada ligado ainda: ligue fun\195\167\195\181es (Principal /
Evento) ou escolha uma predefini\195\167\195\163o (Config) e depois \'Fazenda ligada\'.")l("Waiting
for the game to load...","Oyunun y\195\188klenmesi bekleniyor...","Esperando a que cargue el
juego...","Esperando o jogo carregar...")l("Running, but no feature is on: pick a preset or switch
features on.","\195\135al\196\177\197\159\196\177yor ama hi\195\167bir \195\182zellik
a\195\167\196\177k de\196\159il: haz\196\177r ayar se\195\167 ya da \195\182zellik
a\195\167.","Activa, pero sin funciones: elige un ajuste o activa funciones.","Ligada, mas sem
fun\195\167\195\181es: escolha uma predefini\195\167\195\163o ou ligue
fun\195\167\195\181es.")l("Running","\195\135al\196\177\197\159\196\177yor","Activa","Ligada")l("Pa
used: no game actions.","Duraklat\196\177ld\196\177: oyun i\197\159lemi yok.","En pausa: ninguna
acci\195\179n.","Pausada: nenhuma a\195\167\195\163o.")l("FARM:
STOPPED","\195\135\196\176FTL\196\176K: DURDU","GRANJA: DETENIDA","FAZENDA: PARADA")l("FARM:
OFF","\195\135\196\176FTL\196\176K: KAPALI","GRANJA: APAGADA","FAZENDA: DESLIGADA")l("FARM:
ON","\195\135\196\176FTL\196\176K: A\195\135IK","GRANJA: ACTIVA","FAZENDA: LIGADA")l("nothing
yet","hen\195\188z yok","nada a\195\186n","nada ainda")l("none equipped","elde pet yok","ninguna
equipada","nenhum equipado")l("Next Ghost Gallery: unknown yet","Sonraki Hayalet Galerisi:
hen\195\188z bilinmiyor","Pr\195\179xima galer\195\173a: a\195\186n no se sabe","Pr\195\179xima
galeria: ainda n\195\163o se sabe")l("Tap to join the discord of your script.","Scriptin
Discord\'una kat\196\177lmak i\195\167in dokun.","Toca para unirte al Discord del script.","Toque
para entrar no Discord do script.")l("Your Executor Seems To Be Supported By This
Script.","Executor\'\196\177n bu scriptle uyumlu g\195\182r\195\188n\195\188yor.","Tu executor
parece compatible con este script.","Seu executor parece compat\195\173vel com este
script.")l("Your Executor Is Supported By \nThis Script.","Executor\'\196\177n bu scriptle
\nuyumlu.","Tu executor es compatible \ncon este script.","Seu executor \195\169 compat\195\173vel
\ncom este script.")l("Your Executor Is Unsupported \nBy This Script.","Executor\'\196\177n bu
scriptle \nuyumlu de\196\159il.","Tu executor no es compatible \ncon este script.","Seu executor
n\195\163o \195\169 compat\195\173vel \ncom este script.")l("Everything Off","Hepsi
kapal\196\177","Todo apagado","Tudo desligado")l("Full AutoFarm","Tam otomatik
\195\167iftlik","AutoFarm completo","AutoFarm completo")l("Mega Mummy Spider\'s","Mega Mumya
\195\150r\195\188mcek","Mega Ara\195\177a momia","Mega Aranha m\195\186mia")l("Mummy Spiders only:
keys straight down the Crypt, every spider grown (needs, potions, Pet Pen), then neon + mega neon.
No eggs, no candy pets, no nest / Stray Cat.","Sadece Mumya \195\150r\195\188mcekler: anahtarlar
do\196\159rudan mahzenin dibine, her \195\182r\195\188mcek b\195\188y\195\188t\195\188l\195\188r
(ihtiya\195\167, iksir, Pet A\196\159\196\177l\196\177), sonra neon + mega neon. Yumurta yok,
\197\159eker peti yok, yuva / sokak kedisi yok.","Solo ara\195\177as momia: llaves directo al fondo
de la cripta, cada ara\195\177a crece (necesidades, pociones, corral), luego ne\195\179n + mega
ne\195\179n. Sin huevos, sin mascotas de dulces, sin nido / gato.","S\195\179 aranhas m\195\186mia:

chaves direto ao fundo da cripta, cada aranha cresce (necessidades, po\195\167\195\181es,
cercadinho), depois neon + mega neon. Sem ovos, sem pets de doces, sem ninho / gato.")l("Mega
Skelicorn","Mega Skelicorn","Mega Skelicorn","Mega Skelicorn")l("Skelicorns only: candy from the
whole event, Lightning Lever from the Crypt, a Skelicorn every 120k candy (up to 5 growing), grown
+ neon + mega neon.","Sadece Skelicorn: t\195\188m etkinlikten \197\159eker, mahzenden
\197\158im\197\159ek Kolu, her 120k \197\159ekerde bir Skelicorn (en fazla 5
b\195\188y\195\188yen), b\195\188y\195\188t + neon + mega neon.","Solo Skelicorns: dulces de todo
el evento, palanca del rayo de la cripta, un Skelicorn cada 120k dulces (hasta 5 creciendo), crecer
+ ne\195\179n + mega ne\195\179n.","S\195\179 Skelicorns: doces do evento todo, alavanca do raio da
cripta, um Skelicorn a cada 120k doces (at\195\169 5 crescendo), crescer + neon + mega
neon.")l("Mega a Pet","Bir Peti Mega Yap","Mega una mascota","Mega um pet")l("Pick one pet or egg
below. Egg: bought and hatched on repeat. Candy pet: 5 bought (1 raised, 4 in the Pet Pen). Any
pet: grown, neon, mega neon on repeat, its copies in the Pet Pen.","A\197\159a\196\159\196\177dan
bir pet ya da yumurta se\195\167. Yumurta: s\195\188rekli al\196\177n\196\177r ve
a\195\167\196\177l\196\177r. \197\158eker peti: 5 tane al\196\177n\196\177r (1
b\195\188y\195\188t\195\188l\195\188r, 4 Pet A\196\159\196\177l\196\177\'na). Her pet:
b\195\188y\195\188t, neon, mega neon s\195\188rekli, kopyalar\196\177 Pet
A\196\159\196\177l\196\177\'nda.","Elige una mascota o un huevo abajo. Huevo: se compra y se abre
sin parar. Mascota de dulces: 5 compradas (1 criada, 4 en el corral). Cualquier mascota: crecer,
ne\195\179n, mega ne\195\179n sin parar, sus copias en el corral.","Escolha um pet ou ovo abaixo.
Ovo: comprado e chocado sem parar. Pet de doces: 5 comprados (1 criado, 4 no cercadinho). Qualquer
pet: crescer, neon, mega neon sem parar, as c\195\179pias no cercadinho.")l("Mega a Pet:
pick","Mega yap\196\177lacak pet","Mega: elige","Mega: escolha")l("Nothing (normal
farm)","Hi\195\167biri (normal \195\167iftlik)","Nada (granja normal)","Nada (fazenda
normal)")l("Picked:","Se\195\167ilen:","Elegido:","Escolhido:")l("Pick a pet or an egg in \'Mega a
Pet: pick\' first.","\195\150nce \'Mega yap\196\177lacak pet\' k\196\177sm\196\177ndan bir pet ya
da yumurta se\195\167.","Primero elige una mascota o un huevo en \'Mega: elige\'.","Primeiro
escolha um pet ou ovo em \'Mega: escolha\'.")l("Egg: bought and hatched on repeat. Pet: grown,
neon, mega neon, its copies in the Pet Pen. Works right away; the \'Mega a Pet\' button also turns
on needs, potions, neon and the Pet Pen.","Yumurta: s\195\188rekli al\196\177n\196\177r ve
a\195\167\196\177l\196\177r. Pet: b\195\188y\195\188t, neon, mega neon, kopyalar\196\177 Pet
A\196\159\196\177l\196\177\'nda. Hemen \195\167al\196\177\197\159\196\177r; \'Bir Peti Mega Yap\'
d\195\188\196\159mesi ihtiya\195\167lar\196\177, iksirleri, neonu ve Pet
A\196\159\196\177l\196\177\'n\196\177 da a\195\167ar.","Huevo: se compra y se abre sin parar.
Mascota: crecer, ne\195\179n, mega ne\195\179n, sus copias en el corral. Funciona al instante; el
bot\195\179n \'Mega una mascota\' tambi\195\169n activa necesidades, pociones, ne\195\179n y el
corral.","Ovo: comprado e chocado sem parar. Pet: crescer, neon, mega neon, as c\195\179pias no
cercadinho. Funciona na hora; o bot\195\163o \'Mega um pet\' tamb\195\169m liga necessidades,
po\195\167\195\181es, neon e o cercadinho.")l("Mummy Spider (Crypt)","Mumya \195\150r\195\188mcek
(Mahzen)","Ara\195\177a momia (cripta)","Aranha m\195\186mia (cripta)")l("Skelicorn (120k
candy)","Skelicorn (120k \197\159eker)","Skelicorn (120k dulces)","Skelicorn (120k doces)")l("Event
Only","Sadece etkinlik","Solo evento","S\195\179 evento")l("Needs Only","Sadece
ihtiya\195\167lar","Solo necesidades","S\195\179 necessidades")l("Every feature off (the defaults).
Anti-AFK and the Play button stay on.","Her \195\182zellik kapal\196\177 (varsay\196\177lan). AntiAFK ve Play d\195\188\196\159mesi a\195\167\196\177k kal\196\177r.","Todo apagado (por defecto).
Anti-AFK y el bot\195\179n Play siguen activos.","Tudo desligado (padr\195\163o). Anti-AFK e o
bot\195\163o Play continuam ligados.")l("Everything: every need, eggs, potions, neon + mega neon,
gifts, cashback, quests and the whole event.","Her \197\159ey: t\195\188m ihtiya\195\167lar,
yumurta, iksir, neon + mega neon, hediye, para iadesi, g\195\182revler ve t\195\188m
etkinlik.","Todo: necesidades, huevos, pociones, ne\195\179n + mega ne\195\179n, regalos,
reembolso, misiones y el evento.","Tudo: necessidades, ovos, po\195\167\195\181es, neon + mega
neon, presentes, cashback, miss\195\181es e o evento todo.")l("Only Halloween: Ghost Gallery, Crypt
+ Mummy Spider, quests, Pet Pen. No pet / baby needs.","Sadece Cad\196\177lar Bayram\196\177:
Hayalet Galerisi, Mahzen + Mumya \195\150r\195\188mcek, g\195\182revler, Pet
A\196\159\196\177l\196\177. Pet / bebek ihtiyac\196\177 yok.","Solo Halloween: galer\195\173a,
cripta + ara\195\177a momia, misiones, corral. Sin necesidades.","S\195\179 Halloween: galeria,
cripta + aranha m\195\186mia, miss\195\181es, cercadinho. Sem necessidades.")l("Only pet + baby
needs (with eggs when nothing grows). The event stays off.","Sadece pet + bebek
ihtiya\195\167lar\196\177 (b\195\188y\195\188yen yoksa yumurta). Etkinlik kapal\196\177
kal\196\177r.","Solo necesidades de mascota + beb\195\169 (huevos si nada crece). El evento queda
apagado.","S\195\179 necessidades de pet + beb\195\170 (ovos se nada cresce). O evento fica
desligado.")l("New window: game icons, your language, live Farm card, presets.","Yeni pencere: oyun
ikonlar\196\177, senin dilin, canl\196\177 \195\135iftlik kart\196\177, haz\196\177r
ayarlar.","Ventana nueva: iconos del juego, tu idioma, tarjeta de granja en vivo, ajustes.","Janela
nova: \195\173cones do jogo, seu idioma, cart\195\163o da fazenda ao vivo,
predefini\195\167\195\181es.")l("Game icons","Oyun ikonlar\196\177","Iconos del
juego","\195\141cones do jogo")l("The game\'s icons and your language","Oyunun ikonlar\196\177 ve
senin dilin","Iconos del juego y tu idioma","\195\141cones do jogo e seu idioma")l("Game icons
everywhere; the window speaks your language (flag = your country).","Her yerde oyun
ikonlar\196\177; pencere senin dilinde (bayrak = \195\188lken).","Iconos del juego en todas partes;
la ventana habla tu idioma.","\195\141cones do jogo em todo lugar; a janela fala o seu
idioma.")l("The window in your language: English, T\195\188rk\195\167e, Espa\195\177ol,
Portugu\195\170s","Pencere senin dilinde: English, T\195\188rk\195\167e, Espa\195\177ol,
Portugu\195\170s","La ventana en tu idioma: English, T\195\188rk\195\167e, Espa\195\177ol,

Portugu\195\170s","A janela no seu idioma: English, T\195\188rk\195\167e, Espa\195\177ol,
Portugu\195\170s")l("Your country\'s flag on the Dashboard","Panelde \195\188lkenin
bayra\196\159\196\177","La bandera de tu pa\195\173s en el panel","A bandeira do seu pa\195\173s no
painel")l("The game\'s own icons: Bucks, candy, home, eggs, potions, keys","Oyunun kendi
ikonlar\196\177: Bucks, \197\159eker, ev, yumurta, iksir, anahtar","Iconos del juego: Bucks,
dulces, casa, huevos, pociones, llaves","\195\141cones do jogo: Bucks, doces, casa, ovos,
po\195\167\195\181es, chaves")l("No emojis: coloured status icons","Emoji yok: renkli durum
ikonlar\196\177","Sin emojis: iconos de estado con color","Sem emojis: \195\173cones de status
coloridos")l("See-through dashboard cards","Yar\196\177 saydam panel kartlar\196\177","Tarjetas del
panel transl\195\186cidas","Cart\195\181es do painel transl\195\186cidos")l("Webhook: candy + your
pet\'s picture","Webhook: \197\159eker + petinin resmi","Webhook: dulces + foto de tu
mascota","Webhook: doces + foto do seu pet")l("Autoclose GUI on execute (Config >
Settings)","A\195\167\196\177l\196\177\197\159ta pencereyi gizle (Ayarlar > Ayarlar)","Ocultar
ventana al ejecutar (Config > Opciones)","Ocultar janela ao executar (Config >
Op\195\167\195\181es)")l("Good Morning!","G\195\188nayd\196\177n!","\194\161Buenos
d\195\173as!","Bom dia!")l("How\'s Your Day Going?","G\195\188n\195\188n nas\196\177l
ge\195\167iyor?","\194\191Qu\195\169 tal tu d\195\173a?","Como est\195\161 seu dia?")l("Sweet
Dreams.","Tatl\196\177 r\195\188yalar.","Dulces sue\195\177os.","Bons sonhos.")l("Jeez you should
be asleep...","Hey, uyuman laz\196\177m...","Deber\195\173as estar durmiendo...","Voc\195\170 devia
estar dormindo...")local B={}k.TEMPLATES=B local function U(k,P,U,Z)l(k,P,U,Z)table.insert(B,k)end
U("Copied: %s","Kopyaland\196\177: %s","Copiado: %s","Copiado: %s")U("Error: %s","Hata: %s","Error:
%s","Erro: %s")U("Delete \'%s\'?","\'%s\' silinsin mi?","\194\191Borrar \'%s\'?","Apagar
\'%s\'?")U("Saved \'%s\'","\'%s\' kaydedildi","\'%s\' guardada","\'%s\' salva")U("Overwrote
\'%s\'","\'%s\' \195\188zerine yaz\196\177ld\196\177","\'%s\' sobrescrita","\'%s\'
sobrescrita")U("Could not read \'%s\'","\'%s\' okunamad\196\177","No se pudo leer
\'%s\'","N\195\163o deu para ler \'%s\'")U("Loaded \'%s\' (%d settings)","\'%s\' y\195\188klendi
(%d ayar)","\'%s\' cargada (%d ajustes)","\'%s\' carregada (%d op\195\167\195\181es)")U("\'%s\'
exists: pick it and press Overwrite","\'%s\' zaten var: se\195\167 ve \195\156zerine yaz\'a
bas","\'%s\' ya existe: el\195\173gela y pulsa Sobrescribir","\'%s\' j\195\161 existe: escolha e
toque em Sobrescrever")U("Deleted \'%s\'","\'%s\' silindi","\'%s\' borrada","\'%s\'
apagada")U("Autoload: \'%s\' at start","A\195\167\196\177l\196\177\197\159ta y\195\188kle:
\'%s\'","Carga al iniciar: \'%s\'","Carregar ao iniciar: \'%s\'")U("Autosave: %d change(s)
kept","Otomatik kay\196\177t: %d de\196\159i\197\159iklik sakland\196\177","Guardado
autom\195\161tico: %d cambio(s)","Salvamento autom\195\161tico: %d mudan\195\167a(s)")U("Preset:
%s","Haz\196\177r ayar: %s","Ajuste: %s","Predefini\195\167\195\163o: %s")U("%d of %d features on.
%s","%d/%d \195\182zellik a\195\167\196\177k. %s","%d de %d funciones activas. %s","%d de %d
fun\195\167\195\181es ligadas. %s")U("%s Your other settings stay.","%s Di\196\159er
ayarlar\196\177n ayn\196\177 kal\196\177r.","%s Tus otros ajustes se quedan.","%s Suas outras
op\195\167\195\181es ficam.")U("The window starts hidden: %s opens it","Pencere gizli
ba\197\159lar: %s a\195\167ar","La ventana empieza oculta: %s la abre","A janela come\195\167a
oculta: %s abre")U("Hide / show: %s","Gizle / g\195\182ster: %s","Mostrar / ocultar: %s","Mostrar /
ocultar: %s")U("Ready. %s hides / shows the window.","Haz\196\177r. %s pencereyi gizler /
g\195\182sterir.","Listo. %s muestra / oculta la ventana.","Pronto. %s mostra / oculta a
janela.")U("Ready. Round paw button: hide / show. Square button at the top: full screen. Sliders:
tap the number to type.","Haz\196\177r. Yuvarlak pati d\195\188\196\159mesi: gizle / g\195\182ster.
\195\156stteki kare d\195\188\196\159me: tam ekran. Kayd\196\177r\196\177c\196\177lar:
say\196\177ya dokunup yaz.","Listo. Bot\195\179n de pata: mostrar / ocultar. Bot\195\179n cuadrado
arriba: pantalla completa. Deslizadores: toca el n\195\186mero para escribir.","Pronto.
Bot\195\163o de pata: mostrar / ocultar. Bot\195\163o quadrado no topo: tela cheia. Controles:
toque no n\195\186mero para digitar.")U("Executor: %s","Executor: %s","Executor: %s","Executor:
%s")U("Status: %s","Durum: %s","Estado: %s","Status: %s")U("Player: %s","Oyuncu: %s","Jugador:
%s","Jogador: %s")U("Server: %s players","Sunucu: %s oyuncu","Servidor: %s jugadores","Servidor: %s
jogadores")U("Script: v%s","Script: v%s","Script: v%s","Script: v%s")U("What\'s new in v%s","v%s
yenilikleri","Novedades de v%s","Novidades da v%s")U("\226\128\162 %s","\226\128\162
%s","\226\128\162 %s","\226\128\162 %s")U("Welcome, %s","Ho\197\159 geldin, %s","Bienvenido,
%s","Bem-vindo, %s")U("%s | %s","%s | %s","%s | %s","%s | %s")U("%s (%s candy)","%s (%s
\197\159eker)","%s (%s dulces)","%s (%s doces)")U("%d/%d features on","%d/%d \195\182zellik
a\195\167\196\177k","%d/%d funciones activas","%d/%d fun\195\167\195\181es ligadas")U("%d of %d
features on","%d/%d \195\182zellik a\195\167\196\177k","%d de %d funciones activas","%d de %d
fun\195\167\195\181es ligadas")U("Paused: no game actions. %s","Duraklat\196\177ld\196\177: oyun
i\197\159lemi yok. %s","En pausa: ninguna acci\195\179n. %s","Pausada: nenhuma a\195\167\195\163o.
%s")U("Switch Farm running on to start.","Ba\197\159latmak i\195\167in \'\195\135iftlik
\195\167al\196\177\197\159\196\177yor\'u a\195\167.","Activa \'Granja activa\' para
empezar.","Ligue \'Fazenda ligada\' para come\195\167ar.")U("Waiting for the game to load...
%s","Oyunun y\195\188klenmesi bekleniyor... %s","Esperando a que cargue el juego... %s","Esperando
o jogo carregar... %s")U("Running \226\128\162 %s","\195\135al\196\177\197\159\196\177yor
\226\128\162 %s","Activa \226\128\162 %s","Ligada \226\128\162 %s")U("preset %s","haz\196\177r ayar
%s","ajuste %s","predefini\195\167\195\163o %s")U("%s features on","%s \195\182zellik
a\195\167\196\177k","%s funciones activas","%s fun\195\167\195\181es ligadas")U("Last done:
%s","Son yap\196\177lan: %s","Lo \195\186ltimo: %s","\195\154ltima: %s")U("Pet: %s","Pet:
%s","Mascota: %s","Pet: %s")U("%s (age %s)","%s (ya\197\159 %s)","%s (edad %s)","%s (idade
%s)")U("Session: %d min \226\128\162 %s needs","Oturum: %d dk \226\128\162 %s
ihtiya\195\167","Sesi\195\179n: %d min \226\128\162 %s necesidades","Sess\195\163o: %d min
\226\128\162 %s necessidades")U("Bucks: %s (+%s)","Bucks: %s (+%s)","Bucks: %s (+%s)","Bucks: %s

(+%s)")U("Candy: %s (+%s)","\197\158eker: %s (+%s)","Dulces: %s (+%s)","Doces: %s (+%s)")U("Tasks:
%s done \226\128\162 %s failed","G\195\182revler: %s bitti \226\128\162 %s hata","Tareas: %s hechas
\226\128\162 %s fallidas","Tarefas: %s feitas \226\128\162 %s falhas")U("Doing:
%s","Yap\196\177lan: %s","Haciendo: %s","Fazendo: %s")U("Doing: nothing (stopped)","Yap\196\177lan:
hi\195\167bir \197\159ey (durdu)","Haciendo: nada (detenida)","Fazendo: nada (parada)")U("Doing:
nothing (paused)","Yap\196\177lan: hi\195\167bir \197\159ey
(duraklat\196\177ld\196\177)","Haciendo: nada (en pausa)","Fazendo: nada (pausada)")U("Doing:
nothing to do right now","Yap\196\177lan: \197\159u an i\197\159 yok","Haciendo: nada por
ahora","Fazendo: nada por agora")U("Needs: %s","\196\176htiya\195\167lar: %s","Necesidades:
%s","Necessidades: %s")U("Needs: none","\196\176htiya\195\167lar: yok","Necesidades:
ninguna","Necessidades: nenhuma")U("Ghost Gallery: off","Galeri: kapal\196\177","Galer\195\173a:
apagada","Galeria: desligada")U("Ghost Gallery: in %s","Galeri: %s sonra","Galer\195\173a: en
%s","Galeria: em %s")U("Ghost Gallery: waiting","Galeri: bekleniyor","Galer\195\173a:
esperando","Galeria: esperando")U("Pet Pen: off","Pet A\196\159\196\177l\196\177:
kapal\196\177","Corral: apagado","Cercadinho: desligado")U("Pet Pen: %d/%d \226\128\162 claim
%s","Pet A\196\159\196\177l\196\177: %d/%d \226\128\162 toplama %s","Corral: %d/%d \226\128\162
reclamar en %s","Cercadinho: %d/%d \226\128\162 coletar em %s")U("Pet Pen: %d/%d \226\128\162 claim
now","Pet A\196\159\196\177l\196\177: %d/%d \226\128\162 \197\159imdi topla","Corral: %d/%d
\226\128\162 reclamar ya","Cercadinho: %d/%d \226\128\162 coletar agora")U("Pet Pen: no data
yet","Pet A\196\159\196\177l\196\177: hen\195\188z veri yok","Corral: sin datos
a\195\186n","Cercadinho: sem dados ainda")U("Resting: %s","Dinlenen: %s","En pausa: %s","Em pausa:
%s")U("Resting: none","Dinlenen: yok","En pausa: ninguna","Em pausa: nenhuma")U("%s (%d min)","%s
(%d dk)","%s (%d min)","%s (%d min)")U("Rusty Keys: %s \226\128\162 Twigs: %s","Pasl\196\177
Anahtar: %s \226\128\162 Dal: %s","Llaves oxidadas: %s \226\128\162 Ramitas: %s","Chaves
enferrujadas: %s \226\128\162 Gravetos: %s")U("Nest: %s / 8 twigs","Yuva: %s / 8 dal","Nido: %s /
8 ramitas","Ninho: %s / 8 gravetos")U("Nest: ?","Yuva: ?","Nido: ?","Ninho: ?")U("Next Ghost
Gallery in %s","Sonraki Hayalet Galerisi: %s","Pr\195\179xima galer\195\173a en %s","Pr\195\179xima
galeria em %s")U("%s/%s players","%s/%s oyuncu","%s/%s jugadores","%s/%s jogadores")U("%s FPS
\226\128\162 %s ms","%s FPS \226\128\162 %s ms","%s FPS \226\128\162 %s ms","%s FPS \226\128\162 %s
ms")U("server %s","sunucu %s","servidor %s","servidor %s")U("baby %s","bebek %s","beb\195\169
%s","beb\195\170 %s")local Z={["pet me"]={"sevme";"caricias";"carinho"},hungry=
{"a\195\167","hambre";"fome"},thirsty={"susam\196\177\197\159";"sed";"sede"};play=
{"oyun","jugar","brincar"},sleepy={"uykulu","sue\195\177o","sono"},dirty=
{"kirli","sucio";"sujo"},toilet={"tuvalet";"ba\195\177o";"banheiro"};walk=
{"y\195\188r\195\188y\195\188\197\159","paseo","passeio"},ride=
{"gezinti";"carrito";"carrinho"};mystery={"gizem";"misterio","mist\195\169rio"};salon=
{"kuaf\195\182r";"sal\195\179n";"sal\195\163o"},["cat cafe"]={"kedi kafe","caf\195\169 de
gatos","caf\195\169 dos gatos"};["pizza party"]={"pizza partisi","fiesta de pizza";"festa da
pizza"},school={"okul","escuela";"escola"};sick={"hasta";"enfermo";"doente"};camping=
{"kamp","campamento";"acampamento"};["beach party"]={"plaj partisi";"fiesta en la playa";"festa na
praia"},bored={"s\196\177k\196\177lm\196\177\197\159";"aburrido";"entediado"};["ghost gallery"]=
{"hayalet galerisi";"galer\195\173a","galeria"},["pet pen"]={"pet
a\196\159\196\177l\196\177","corral";"cercadinho"}}for k,B in pairs(Z)do if not P[k]then
l(k,B[1],B[2],B[3])end end local function m(l)local B=P[l]local U=B and B[k.current]if U then
return U end local Z,m,H=string.match(l,"^(%s*)(.-)(%s*)$")if m~=l and m~=""then B=P[m]U=B and
B[k.current]if U then return Z..(U..H)end end return nil end local H k._memo,k._memoSize={},0 local
function Q()H={}for k,P in ipairs(B)do local l=0 local B=string.gsub(P,"(%%?)(.)",function(k,P)if
k=="%"and((P=="s"or P=="d"))then l=l+(1)return P=="s"and"(.-)"or"(%-?[%d,]+)"end local B=k..P
return(string.gsub(B,"[%^%$%(%)%%%.%[%]%*%+%-%?]","%%%0"))end)if l>0 then table.insert(H,
{key=P,pattern="^"..(B.."$"),count=l})end end table.sort(H,function(k,P)return#k.key>#P.key end)end
local function A(k,P)local l=0 return(string.gsub(k,"%%([sd])",function()l=l+(1)return
P[l]or""end))end function k.tr(l)if k.current=="en"or type(l)~="string"or l==""then return l end
local B=m(l)if B then return B end if string.find(l,"\n",1,true)then local P={}for l in
string.gmatch(l.."\n","(.-)\n")do table.insert(P,k.tr(l))end return table.concat(P,"\n")end if not
H then Q()end local U=k._memo[k.current]if U and U[l]then return U[l]end local Z=l for B,U in
ipairs(H)do local H={string.match(l,U.pattern)}if#H==U.count then for k,P in ipairs(H)do
H[k]=m(P)or P end Z=A(P[U.key][k.current]or U.key,H)break end end U=U or{}if k._memoSize>400 then
U,k._memoSize={},0 end U[l]=Z k._memo[k.current]=U k._memoSize=k._memoSize+(1)return Z end function
k.t(P,...)local l=k.tr(P)if select("#",...)==0 then return l end local
B,U=pcall(string.format,l,...)if B then return U end return string.format(P,...)end return k end
P["Services/Interface"]=function(...)local k=...local P=k("Core/Config")local
l=k("Services/Lang")local B=l.t local U={}U.TITLE="Shxdrag hub"U.EDITION="Adopt
Me"U.LIBRARY_URL="https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"U.DISCORD_
INVITE=""U.DONATION_LINKS={}U.CRYPTO={}U.GAMEPASSES={}local Z={activity=1.167856356889e+14;["atsign"]=1.0431458275855e+14,baby=1.3478092389066e+14;["badgecheck"]=1.0286423304831e+14,banknote=83624352345036;bed=1.0370346015835e+14,bell=1.1172524187335e+1
4;bird=1.2708203257077e+14;bitcoin=1.2016582390841e+14,bone=93032826374472;bug=1.0806462645646e+14,
camera=1.0291186011124e+14,candy=1.2160279695341e+14,cat=1.3258701225285e+14,check=83827110621355;
["circle-dot"]=73332621255981;["circle-gauge"]=84688454826847;["circlepause"]=75601858754638;code=1.0285885709876e+14;coffee=75171771078867,coins=1.2878456903233e+14,cop
y=87942399647942;cpu=1.1578178716682e+14,crosshair=1.1492901728794e+14;["cupsoda"]=1.1606463090891e+14;dices=1.1782103023375e+14;dog=1.1157181294587e+14;["dooropen"]=1.3381406523126e+14,download=93868047445509,egg=73908680452587;eraser=1.0151421286661e+14,
["eye-off"]=1.1237573949123e+14,fence=1.360271775524e+14;["file-text"]=77346633411296;["flask-

conical"]=77588155748536;footprints=1.2829337558345e+14;gem=1.1175031867567e+14,ghost=1.21912141443
71e+14,gift=1.0409862219758e+14,["graduation-cap"]=1.3704848540557e+14;["handheart"]=1.1234896556801e+14,heart=1.112841555156e+14;["hearthandshake"]=1.1692119092004e+14,history=87356875172942,hourglass=97354459771104;house=1.27889862453
15e+14,info=1.1719461005375e+14,["keyround"]=80439075172197,keyboard=78021479821645;layers=92401939426051;link=73034596791310;["listchecks"]=86457557777962;["list-ordered"]=90091028350622,["mappin"]=1.2558985704422e+14;monitor=73331152826648;["mouse-pointer-click"]=1.0770979857718e+14,
["octagon-x"]=1.1701830625114e+14;package=1.3293570209965e+14,palette=72590019059979,["partypopper"]=1.0904155921798e+14,["paw-print"]=92297066485556;["ph:discordlogo"]=1.0135983220504e+14;pizza=95650659741106;power=1.3982190777009e+14;["refreshcw"]=76845925482586;rocket=79846157539863,["rotateccw"]=1.0359382359288e+14,save=1.2678608181894e+14,scissors=73848300538397,["scrolltext"]=86918746287564;send=1.2013123850753e+14;settings=1.0146388380542e+14,["shieldcheck"]=83449656859552,["shopping-bag"]=1.2883591941966e+14,["shower-head"]=73619400343212;["skipforward"]=96350165788710;skull=89401908547230;["slidershorizontal"]=1.0402121961159e+14;smartphone=1.0947689689192e+14,sparkles=1.3060242520131e+14,stetho
scope=1.059825827173e+14,sun=79901529465096;target=81035867308138,tent=1.3583466919808e+14;ticket=1
.0433678393904e+14;timer=96119720980390;toilet=82858381666593;["trash-2"]=79564839810840;["treepalm"]=1.2816412044724e+14;["trianglealert"]=76712741040235,utensils=92328553872866;wallet=82693664006746;["wandsparkles"]=1.0963622524897e+14;wrench=1.0876418526462e+14,users=1.090236556021e+14;scaling=72422884
764012,wifi=1.0136039360704e+14;globe=1.1157878330709e+14;languages=99917326264912,zap=995469405650
21}U.GAME_ICON_FALLBACK={["game:bucks"]="banknote";["game:candy"]="candy",
["game:home"]="house"}U.gameIconIds={}local function m(k,P)if type(k)=="string"and
string.find(k,"|",1,true)then k,P=string.match(k,"^(.-)|(.*)$")end if
type(k)=="string"and((string.sub(k,1,5)=="game:"or string.sub(k,1,5)=="item:"))then local l if
type(U.gameIcon)=="function"then local P,B=pcall(U.gameIcon,k)l=P and(type(B)=="string"and
tonumber(string.match(B,"^rbxassetid://(%d+)$")or string.match(B,"[?&]id=(%d+)")))or nil end if l
then U.gameIconIds[l]=true return l end return Z[P or U.GAME_ICON_FALLBACK[k]or"circle-dot"]end
return Z[k]end U.I=m U.ICON_IDS=Z U.SPEEDRUN_PRESET=P.SPEEDRUN_CHANGES U.TOASTS={{pattern="Rusty
Key EARNED";title="Rusty Key earned",icon="key-round"};{pattern="^Crypt: Mummy Spider
claimed",title="Mummy Spider claimed";icon="bug"},{pattern="^Neon fusion: ";title="Neon
fusion",icon="wand-sparkles"},{pattern="^Mega neon fusion: ",title="Mega neon!",icon="sparkles"},
{pattern="^Bought halloween_2026_",title="Candy shop",icon="candy"};{pattern="^Quests: .*
claimed";title="Quest reward",icon="scroll-text"},{pattern="^Nest completed",title="Pigeon nest
built",icon="bird"},{pattern="^Ghost Gallery: %d+ points",title="Ghost Gallery
round",icon="ghost"},{pattern="failures in a row: disabled";title="Task resting",icon="octagon-x"},
{pattern="^Stuck in .*Farm.StuckRecovery",title="Stuck: going home";icon="rotate-ccw"}}U.THEMES=
{}U.THEME_NAMES={}U.THEME_PROFILES={}U.PALETTE={}U.BOX_COLORS={}U.DASHBOARD_COLORS=
{}U.DASHBOARD_KNOWN={}U.SUPPORTED_EXECUTORS={}U.CHANGELOG={"Shxdrag hub - Adopt Me Farm (WindUI
edition)"}U.NEED_NAMES={{"pet_me";"Pet me"};{"hungry";"Hungry"},{"thirsty";"Thirsty"},
{"play";"Play"};{"sleepy";"Sleepy"};{"dirty";"Dirty"};{"toilet","Toilet"},{"walk","Walk"},
{"ride";"Ride"};{"mystery","Mystery card"},{"salon","Salon"};{"cat_cafe";"Cat Cafe"},
{"pizza_party";"Pizza party"};{"school","School"},{"sick","Sick"};{"camping","Camping"};
{"beach_party";"Beach party"},{"bored";"Bored"}}U.POTION_NAMES={pet_age_potion="Age-Up
Potion",tiny_pet_age_potion="Tiny Age-Up Potion",pet_bonus_bucks_potion="Bucks
Potion"}U.CRYPT_NAMES={{"ladder","Next floor (Mummy Spider)"},{"lever";"Lightning Lever
(Skelicorn)"};{"twig";"Twig"},{"candy_corn_pile_ginormous";"Big candy pile"};
{"candy_corn_pile_small";"Small candy pile"}}U.SHOP_NAMES={halloween_2026_jump_scare="Jump
Scare";halloween_2026_jacobean_pigeon="Jacobean Pigeon"}U.EGG_NAMES={{"cracked_egg";"Cracked Egg
(350 Bucks)"};{"pet_egg";"Pet Egg (600 Bucks)"},{"fairytale_egg_2026_fairytale_egg";"Fairytale Egg
(event)"}}U.PING_FLAGS=
{"Kick","Error","Summary";"TaskCompleted","SessionStopped","PreviousSession"}U.PING_NAMES=
{Kick="Kick / disconnect";Error="Errors";Summary="Summaries";TaskCompleted="Finished
needs",SessionStopped="Stopped",PreviousSession="Last run ended badly"}U.KEYBINDS=
{"F1","F2";"F3";"F4";"F5";"F6","F7","F8","F9","F10","F11","F12","RightShift";"LeftShift","RightCont
rol";"LeftControl","RightAlt","LeftAlt";"Insert";"Home";"Delete","End";"PageUp","PageDown","NumLock
","Pause","ScrollLock","Backspace"}U.UI_SCALES=
{"Auto";"0.5";"0.6";"0.7";"0.8","0.9";"1","1.1","1.2","1.3";"1.4","1.5"}U.PC_SIZE=
{900;540}U.CONSOLE_LEVELS={"Info";"Warn";"Error"}U.DESCRIPTIONS={}U.DEVELOPER={name="Shxdrag
hub",user="Shxdrag";github="https://github.com/",avatarUrl="",avatarFile=""}U.SAVE_PATH="ShxdragHub
/window_settings.txt"U.CONFIG_FOLDER="ShxdragHub/configs"U.CONFIG_EXTENSION=".cfg"U.META_KEYS=
{["Interface.Keybind"]=true,["Interface.Theme"]=true,["Interface.UIScale"]=true}U.PRIVATE_KEYS=
{["Notifications.Webhooks.Summary"]=true;["Notifications.Webhooks.Alerts"]=true;
["Notifications.PingDiscordUserId"]=true}local function H(k)if type(k)~="table"then return k end
local P={}for k,l in pairs(k)do P[H(k)]=H(l)end return P end local function Q(k,P)if
type(k)~=type(P)then return false end if type(k)~="table"then return k==P end for k,l in pairs(k)do
if not Q(l,P[k])then return false end end for P in pairs(P)do if k[P]==nil then return false end
end return true end local function A(k)if type(k)~="table"then return false end for k,P in
ipairs(k)do if type(P)~="string"then return false end end return true end local function f(k)local
P=0 for k in pairs(k)do P+=1 end return P end local function Y(k)if type(k)~="string"then return
tostring(k)end local P=string.gsub(k,"_"," ")return
string.upper(string.sub(P,1,1))..string.sub(P,2)end local function n(k)local P={}for k in

string.gmatch(k,"[^.]+")do table.insert(P,k)end return P end function U.resolve(k,P)local l=k for
k=1,#P-1,1 do if type(l)~="table"then return nil,nil end l=l[P[k]]end return l,P[#P]end function
U.canSave(k)return type(k)=="string"and k~=""end U.saved={changes={};originals={}}function
U.encodeSaved(k)local P={}for k,l in pairs(k)do local B=type(l)=="table"and("["..
(table.concat(l,",").."]"))or tostring(l)table.insert(P,k..("="..B))end table.sort(P)return
table.concat(P,"\n")end function U.writeSaved(k,P)if not P then return end pcall(function()local
P=string.match(U.SAVE_PATH,"^(.+)/[^/]+$")if P and not isfolder(P)then makefolder(P)end
writefile(U.SAVE_PATH,U.encodeSaved(k))end)end function U.applySaved(k,P)local
l,B=pcall(function()local P=isfile(U.SAVE_PATH)and readfile(U.SAVE_PATH)or nil if not P or
P==""then return 0 end local l=0 for P in string.gmatch(P,"[^\n]+")do local
B,Z=string.match(P,"^([^=]+)=(.*)$")if B then local P=n(B)local m,H=U.resolve(k,P)if
type(m)=="table"and m[H]~=nil then local k=m[H]if type(k)=="boolean"then m[H]=(Z=="true")elseif
type(k)=="number"then local k=tonumber(Z)if k then m[H]=k end elseif type(k)=="string"then m[H]=Z
elseif type(k)=="table"then local k={}for P in string.gmatch(string.gsub(Z,"^%[(.*)%]$","%1"),"
[^,]+")do table.insert(k,P)end m[H]=k end l=l+(1)end end end return l end)return l and B or 0 end
function U.configPath(k)return U.CONFIG_FOLDER..("/"..(k..U.CONFIG_EXTENSION))end function
U.listConfigs()local k={}pcall(function()if not isfolder(U.CONFIG_FOLDER)then return end for P,l in
ipairs(listfiles(U.CONFIG_FOLDER))do local B=string.match(l,"([^/\\]+)"..
(U.CONFIG_EXTENSION.."$"))if B then table.insert(k,B)end end end)table.sort(k)return k end function
U.configName(k)return(string.match(tostring(k or""),"^%s*(.-)%s*$")):gsub("[/\\:*?\"<>|]","")end
function U.writeConfig(k,P)local l,B=pcall(function()for k,P in
ipairs({"ShxdragHub",U.CONFIG_FOLDER})do if not isfolder(P)then makefolder(P)end end
writefile(U.configPath(k),U.encodeSaved(P))end)return l,B end function U.readConfig(k)local
P,l=pcall(function()local P=readfile(U.configPath(k))local l={}for k in string.gmatch(P,"[^\n]+")do
local P,B=string.match(k,"^([^=]+)=(.*)$")if P then l[P]=B end end return l end)return P and l or
nil end function U.deleteConfig(k)pcall(function()delfile(U.configPath(k))end)end function
U.stateHeader(k)if type(k)~="table"then return"Farm status","Waiting for first status...","gray"end
if k.stopped then return"Farm stopped",k.stopReason or"Stopped","stopped"end if not k.farmEnabled
then return"Farm paused","Toggle \'Farm running\' to start","paused"end if not k.ready then
return"Starting up","Loading game data...","starting"end if k.featuresOn==0 then return"No features
on","Turn on at least one task below","idle"end local P=k.currentTask if type(P)=="string"and
P~=""then return"Running",P,"running"end return"Running","Waiting for next task...","running"end
function U.statusRows(k,P)if type(k)~="table"then return{}end local l={}local function
B(k,P,B,U)table.insert(l,{key=k;icon=P;text=B,game=U})end if type(k.tasksDone)=="number"then
B("done","badge-check","Done: "..tostring(k.tasksDone))end if type(k.bucks)=="number"then
B("bucks","game:bucks","Bucks: "..tostring(k.bucks),"game:bucks")end if
type(k.uptime)=="number"then local P=math.floor(k.uptime/60)local l=k.uptime%60
B("uptime","timer",string.format("Uptime: %d:%02d",P,l))end return l end function
U.scaleFor(k,P,l)if type(k)=="number"then return k end if type(k)=="string"and k~="Auto"then local
P=tonumber(k)if P then return P end end if P then return 1 end if l and(tonumber(l.X)and
tonumber(l.X)<1280)then return.8 end return 1 end function U.lookupCountry()return nil end function
U.developerAvatar()return nil end function U.tintGroupbox() end function U.tintFrame() end function
U.paintDashboard() end function U.fillFarmCard() end function U.serverChipTexts()return{}end
function U.hideWindow()return nil end function U.themeChoice()return nil end function
U.localizeFields() end function U.localize() end function U.localizeTree() end U.CARD_TINT=
{}function U.start(k,B)B=B or{}assert(type(k)=="table"and type(k.Config)=="table","Interface: the
farm\'s control API is missing")if U.current then pcall(U.current.Close)U.current=nil end local
Z=k.Config local m=Z.Interface or B.settings or{}local f=Z.Farm local Y=f.Event or{}local L local
b=B.loadLibrary or function()return(loadstring(game:HttpGet(U.LIBRARY_URL)))()end local
M,O=pcall(b)if not M or type(O)~="table"then error("WindUI could not be loaded:
"..tostring(O),0)end L=O U.gameIcon=type(k.GameIcon)=="function"and k.GameIcon or nil local C
pcall(function()C=(game:GetService("LocalizationService")).RobloxLocaleId end)local
G=U.lookupCountry()l.use(l.pick(m.Language,G,C))local w=B.touch if w==nil then local
k,P=pcall(function()return(game:GetService("UserInputService")).TouchEnabled end)w=k and P==true
end local V pcall(function()V=workspace.CurrentCamera.ViewportSize end)local t=V~=nil and
tonumber(V.X)~=nil local R=true local q={}local K={touch=w}function K.Close()if not R then return
end R=false for k,P in ipairs(q)do pcall(function()P:Disconnect()end)end
pcall(function()L:Destroy()end)end local function
y(k,P,l)pcall(function()L:Notify({Title=k,Content=tostring(P or""),Duration=4})end)end local i=
{}local d=false K.bound={}local function s(k,P)table.insert(i,{key=k,refresh=P})K.bound[k]=true end
local function a(k)local P=d d=true for P,l in ipairs(i)do if k==nil or l.key==k then
pcall(l.refresh)end end d=P end local function X(k)local P,l=U.resolve(Z,k)if type(P)=="table"then
return P[l]end return nil end local F=false local function h(k,P,l)if d or not U.canSave(k)then
return end if m.RememberSettings==false and not U.META_KEYS[k]then return end local B=U.saved if
B.originals[k]==nil then B.originals[k]=H(l)end if Q(P,B.originals[k])then
B.changes[k],B.originals[k]=nil,nil else B.changes[k]=H(P)end if not F then F=true
task.delay(1,function()F=false U.writeSaved(U.saved.changes,m.RememberSettings~=false)end)end end
local function p(k,P)local l,B=U.resolve(Z,k)if type(l)~="table"then return end local m=l[B]if
Q(m,P)then return end l[B]=P local H=table.concat(k,".")h(H,P,m)a(H)end local function
x(P,...)local l=k[P]if type(l)~="function"then return false,"Not available"end return l(...)end
local function E(k,P,l,B,U)local Z=k:Toggle({Title=P;Desc=l~=""and l or
nil,Value=B,Callback=U})return Z end local function I(k,P,l,B,U,Z,m,H,Q)local
A=k:Slider({Title=P;Desc=l~=""and l or nil,Value={Min=B;Max=U;Default=m};Step=Z;Callback=Q})return
A end local function o(k,P,l,B,U,Z,m)local H={}if Z then if type(U)=="table"then H=U end else H=U

or(B[1]and B[1].Title or"")end local Q=k:Dropdown({Title=P,Desc=l~=""and l or
nil,Values=B,Value=H;Multi=Z or false,Callback=m})return Q end local function e(k,P,l,B,U,Z)local
m=k:Input({Title=P,Desc=l~=""and l or nil,Value=U or"",Placeholder=B,Callback=Z})return m end local
function u(k,P,l,B)k:Button({Title=P;Desc=l~=""and l or nil,Callback=function()local
k,l,U=pcall(B)if not k then y(P,"Error: "..tostring(l))elseif U~=false then y(P,tostring(U or(l
and"Done"or"Not available now")))end end})end local function T(k,P,l,B)if type(X(B))~="boolean"then
return end local U=E(k,P,l
or"",X(B),function(k)p(B,k==true)end)s(table.concat(B,"."),function()pcall(function()local k=X(B)if
U.Value~=k then U:Set(k)end end)end)end local function r(k,P,l,B,U,Z,m,H)if
type(X(B))~="number"then return end local Q=I(k,P,l or"",U,Z,m,math.clamp(tonumber(X(B))or
U,U,Z),H,function(k)p(B,math.clamp(tonumber(k)or
U,U,Z))end)s(table.concat(B,"."),function()pcall(function()local k=math.clamp(tonumber(X(B))or
U,U,Z)if Q.Value~=k then Q:Set(k)end end)end)end local function v(k,P,l,B,U,Z)local m={}local H=
{}local Q={}for k,P in ipairs(U)do local l,B=P[1],P[2]table.insert(m,{Title=B})H[B]=l Q[l]=B end if
Z then if not A(X(B))then return end local function U()local k={}for P,l in ipairs(X(B)or{})do if
Q[l]then table.insert(k,Q[l])end end return k end local Z=o(k,P,l or"",m,U(),true,function(k)local
P={}if type(k)=="table"then for k,l in ipairs(k)do if H[l.Title or l]then table.insert(P,H[l.Title
or l])end end end p(B,P)end)s(table.concat(B,"."),function()pcall(function()Z:Set(U())end)end)else
if type(X(B))~="string"then return end local function U()return Q[X(B)]or m[1]and m[1].Title
or""end local Z=o(k,P,l or"",m,U(),false,function(k)local P=H[type(k)=="table"and((k.Title or""))or
k]if P then p(B,P)end
end)s(table.concat(B,"."),function()pcall(function()Z:Set({Title=U()})end)end)end end local
J=tostring(m.Keybind or"RightShift")local
c=L:CreateWindow({Title=U.TITLE;Folder="ShxdragHub",Icon="pawprint";NewElements=true,HideSearchBar=false,OpenButton={Title="Open
"..U.TITLE;CornerRadius=UDim.new(1,0),Enabled=true,Draggable=true,OnlyMobile=false}})pcall(function
()c:SetToggleKey(Enum.KeyCode[J])end)local D=c:Tab({Title="Farm";Icon="solar:leaf-bold"})local
S=D:Section({Title="Farm Status"})local j=D:Section({Title="Status:
loading...";TextSize=16,TextTransparency=.3})u(D,"Start Farm","Resume all farm actions \226\128\148
tasks, candy buy, events, needs, etc.",function()if X({"Farm";"Enabled"})==true then return
false,"Farm is already running."end p({"Farm";"Enabled"},true)return true,"Farm started
\226\128\148 resuming on next tick."end)u(D,"Stop Farm","Pause the farm (watch-only). Press Start
Farm to resume anytime.",function()if X({"Farm","Enabled"})==false then return false,"Farm is
already paused."end p({"Farm","Enabled"},false)return true,"Farm paused \226\128\148 press Start
Farm to resume."end)D:Space()local W=D:Section({Title="Quick Actions"})u(D,"Go Home","Stops current
task and goes home",function()return x("GoHome")end)u(D,"Skip Task","Skip current task (won\'t run
for 90s)",function()return x("SkipTask")end)u(D,"Retry Resting Tasks","Tasks that failed 3x may run
again",function()return x("RetryDisabled")end)D:Space()local z=D:Section({Title="Auto
Tasks"})T(D,"Claim Quests","",{"Farm";"Event","Quests"})T(D,"Visit Homes","Visit homes for quests",
{"Farm";"Event","HouseVisits"})T(D,"Collect Cashback","",{"Farm";"CollectCashback"})T(D,"Open Gifts
& Chests","",{"Farm","AutoOpen";"Enabled"})D:Space()local g=D:Section({Title="Pet Pen"})T(D,"Auto
Pet Pen","Claims pen, takes grown pets out, fills with growing ones",
{"Farm","Event","PetPen"})r(D,"Claim Every (min)","",
{"Farm";"Event";"PetPenMinutes"},1,60,1,"min")T(D,"Keep Full (buy eggs)","Buys eggs so pen always
has growing pets",{"Farm";"Event";"PetPenStock"})u(D,"Claim Pet Pen Now","Goes home if needed and
claims / refills the Pen once",function()return x("ClaimPetPen")end)D:Space()local
N=D:Section({Title="Auto Needs"})T(D,"Auto Needs","Handles every pet need; picks food/water if it
has none",{"Farm";"AutoNeeds","Enabled"})T(D,"Baby Needs Too","",{"Farm","BabyMode"})v(D,"Skip
These Needs","Needs selected here are NOT done",
{"Farm";"AutoNeeds";"Skip"},U.NEED_NAMES,true)D:Space()local kN=D:Section({Title="Pets"})T(D,"Keep
Growing Pet Equipped","Keeps a growing pet equipped; swaps out full-grown ones",
{"Farm","KeepPetEquipped"})T(D,"Buy Egg if None Grows","",{"Farm";"BuyEgg"})v(D,"Egg to Buy","",
{"Farm";"EggToBuy"},U.EGG_NAMES,false)D:Space()local PN=D:Section({Title="Potions & Neon"})T(D,"Use
Potions","Uses every farming potion on the growing pet",{"Farm","AutoPotions","Enabled"})T(D,"Auto
Neon Pets","4 full grown of same kind \226\134\146 1 neon",{"Farm","AutoNeon";"Enabled"})T(D,"Auto
Mega Neon Pets","4 neons of same kind \226\134\146 1 mega neon",{"Farm";"AutoNeon";"Mega"})local
lN=c:Tab({Title="Event",Icon="solar:ghost-bold"})local BN=lN:Section({Title="Halloween
2026"})T(lN,"Ghost Gallery","Joins every round and vacuums the ghosts (Rusty Keys)",
{"Farm","Event","GhostGallery"})T(lN,"Join by Zone","Joins Ghost Gallery by standing in the Manor
circle",{"Farm";"Event","GhostJoinByZone"})T(lN,"Auto Hauntlet","Auto Hauntlet \226\128\148 join
runs, pick safer doors, use keys/items",{"Farm","Event";"Hauntlet"})T(lN,"Hauntlet before Ghost
Gallery","A Hauntlet run comes first when a Ghost Gallery round is near",
{"Farm";"Event";"HauntletFirst"})T(lN,"Use the game\'s teleport prompt","Home before a minigame,
then Yes on the game\'s own Teleport prompt (fewer white screens)",
{"Farm";"Event";"UsePrompt"})v(lN,"Door move","How the bot reaches a door: tween (smooth), walk, or
teleport",{"Farm","Event";"HauntletMove"},{{"tween","Tween (smooth)"},{"walk","Walk"},
{"tp","Teleport"}},false)r(lN,"Move time","Tween: seconds to reach a door (shorter = faster)",
{"Farm";"Event","HauntletMoveSeconds"},.1,5,.1,"s")T(lN,"Auto Stray Cat","",
{"Farm";"Event","StrayCat"})lN:Space()local UN=lN:Section({Title="Crypt"})T(lN,"Use Rusty
Keys","Opens Crypt graves with your Rusty Keys; pick below what to open",
{"Farm","Event";"Crypt"})T(lN,"Auto Mummy Spider","Bottom of the Crypt: takes the Mummy Spider",
{"Farm","Event","MummySpider"})v(lN,"Open","What a Rusty Key opens, in this order",
{"Farm","Event","CryptOpen"},U.CRYPT_NAMES,true)T(lN,"Give Twigs to Nest","Has a Crypt Twig: takes
it to the Hotel nest",{"Farm","Event","PigeonNest"})T(lN,"Auto Nest","Twig graves first until the

nest is built",{"Farm","Event";"AutoNest"})T(lN,"Auto Skelicorn","Lightning Lever from the Crypt
\226\134\146 machine by the Manor \226\134\146 1 Skelicorn (120k candy)",
{"Farm";"Event";"AutoSkelicorn"})lN:Space()local ZN=lN:Section({Title="Pet Pen"})r(lN,"Pen
Slots","4 free slots; 5 with the extra-slot pass",{"Farm","Event";"PetPenSlots"},4,5,1)r(lN,"Min
Bucks to Stock","Buys pen eggs only above this Bucks reserve",
{"Farm","Event","PetPenStockMinBucks"},0,5000,50,"B")lN:Space()local mN=lN:Section({Title="Candy
Shop"})local HN=type(Y)=="table"and Y.CandyPets or nil if type(HN)=="table"then T(lN,"Auto
buy","Buys the pets picked below with candy, as many as the candy pays for",
{"Farm";"Event";"CandyPets";"Enabled"})local k=U.SHOP_NAMES or{halloween_2026_jump_scare="Jump
Scare";halloween_2026_jacobean_pigeon="Jacobean Pigeon",halloween_2026_skelicorn="Skelicorn"}local
function P(k)return(((k:gsub("halloween_%d+_","")):gsub("_"," ")):gsub("^%l",string.upper))end
local function l(k)return((((tostring(k)):reverse()):gsub("
(%d%d%d)","%1,")):reverse()):gsub("^,","")end local B={}for U,Z in ipairs(type(HN.Buy)=="table"and
HN.Buy or{})do if type(Z)=="table"and type(Z.id)=="string"then local U=k[Z.id]or P(Z.id)local
m=Z.price and string.format("%s (%s candy)",U,l(Z.price))or(U.." (box)")table.insert(B,{Z.id;m})end
end v(lN,"Buy","No limit: bought whenever the candy is enough",
{"Farm","Event","CandyPets","Pick"},B,true)if type(HN.MaxBuy)~="boolean"then HN.MaxBuy=false end
T(lN,"Max buy","On: as many as your candy pays for, in one purchase. Off: one every 0.5 s until the
candy runs out",{"Farm";"Event";"CandyPets";"MaxBuy"})if type(HN.KeepCandy)~="number"then
HN.KeepCandy=0 end if type(HN.KeepBucks)~="number"then HN.KeepBucks=0 end r(lN,"Keep candy","Candy
the shop never spends",{"Farm";"Event";"CandyPets";"KeepCandy"},0,5000000,1000,"")r(lN,"Keep
Bucks","Bucks the shop never spends (boxes sold for Bucks)",
{"Farm","Event","CandyPets";"KeepBucks"},0,1000000,100,"")end local
QN=c:Tab({Title="Config";Icon="solar:settings-bold"})local AN=QN:Section({Title="Saved
Configs"})local fN=""e(QN,"Config Name","Name for saving","e.g. main
farm","",function(k)fN=tostring(k or"")end)local YN=nil local nN local function LN()local k={}for
P,l in ipairs(U.listConfigs())do table.insert(k,{Title=l})end return k end
nN=QN:Dropdown({Title="Saved Configs",Values=LN(),Callback=function(k)YN=k and((k.Title or k))or
nil end})local function bN()local k={}for P in pairs(K.bound)do if U.canSave(P)and(not
U.PRIVATE_KEYS[P]and not U.META_KEYS[P])then k[P]=H(X(n(P)))end end return k end local function
MN(k)YN=k or YN pcall(function()nN:Refresh(LN(),YN and{Title=YN}or nil)end)end u(QN,"Save as New
Config","Saves every window setting under the name above",function()local k=U.configName(fN)if
k==""then return false,"Type a name first"end if table.find(U.listConfigs(),k)then return
false,"\'"..(k.."\' already exists: pick it and press Overwrite")end local
P,l=U.writeConfig(k,bN())if P then MN(k)end return P,P and("Saved \'"..(k.."\'"))or l
end)u(QN,"Overwrite Selected","Saves current settings into the selected config",function()if not YN
then return false,"Pick a config first"end local k,P=U.writeConfig(YN,bN())return k,k
and("Overwrote \'"..(YN.."\'"))or P end)u(QN,"Load Selected","Loads the selected config\'s settings
now",function()if not YN then return false,"Pick a config first"end local k=U.readConfig(YN)if not
k then return false,"Could not read \'"..(YN.."\'")end local P=0 for k,l in pairs(k)do if
U.canSave(k)and not U.PRIVATE_KEYS[k]then local B=n(k)local m,H=U.resolve(Z,B)local
Q=type(m)=="table"and m[H]if Q~=nil then local k if type(Q)=="boolean"then k=(l=="true")elseif
type(Q)=="number"then k=tonumber(l)elseif type(Q)=="string"then k=l elseif type(Q)=="table"then k=
{}for P in string.gmatch(string.gsub(tostring(l),"^%[(.*)%]$","%1"),"[^,]+")do table.insert(k,P)end
end if k~=nil then p(B,k)P+=1 end end end end a()return true,string.format("Loaded \'%s\' (%d
settings)",YN,P)end)u(QN,"Delete Selected","Deletes the selected config file",function()if not YN
then return false,"Pick a config first"end U.deleteConfig(YN)YN=nil MN(nil)return
true,"Deleted."end)T(QN,"Autosave","On: every change is kept on this device. Off: changes reset on
next start",{"Interface","RememberSettings"})QN:Space()local
ON=QN:Section({Title="Settings"})T(QN,"Anti-AFK","Clicks Roblox idle warning",
{"Farm","AntiAfk"})T(QN,"Auto Click Play","",{"Farm","AutoAcceptMenu"})T(QN,"Camera Guard","Zooms
camera back out if it goes inside character",{"Farm";"CameraGuard"})T(QN,"Event Pop-ups","Pop-ups
for keys, neon, purchases, rounds",{"Interface","Toasts"})T(QN,"Autoclose GUI","Window starts
hidden; press keybind to show",{"Interface";"StartHidden"})v(QN,"Language","",
{"Interface";"Language"},((function()local k={{"Auto","Auto"}}for P,l in ipairs(l.LANGUAGES or{})do
table.insert(k,{l.code;l.name})end return k end))(),false)if not w then v(QN,"Hide/Show Key","",
{"Interface";"Keybind"},((function()local k={}for P,l in ipairs(U.KEYBINDS)do table.insert(k,
{l,l})end return k end))(),false)end QN:Space()local CN=QN:Section({Title="Developer Presets"})for
k,l in ipairs(P.Presets or{})do u(QN,l.name,l.about or"",function()local k=P.presetValues and
P.presetValues(l.id,type(Z.Farm.Focus)=="string"and Z.Farm.Focus or"")if not k then return
false,"Preset not available"end for k,P in ipairs(k)do p(P[1],H(P[2]))end Z.Preset=l.id a()local
B,U=P.countFeatures and P.countFeatures(Z)or 0,0 return true,string.format("Preset applied. %d
features on.",B)end)end QN:Space()local GN=QN:Section({Title="Advanced"})T(QN,"Smart Priority","",
{"Farm";"SmartPriority"})T(QN,"Stuck Recovery","Go home when stuck",
{"Farm","StuckRecovery";"Enabled"})r(QN,"Stuck After (min)","",
{"Farm","StuckRecovery","Seconds"},1,10,.5,"min")T(QN,"Rejoin When Stuck","Rejoins a PUBLIC
server",{"Farm";"AutoRejoin"})r(QN,"Rejoin After (min)","",
{"Farm","StuckRejoinSeconds"},1,10,.5,"min")T(QN,"Game Travel (Doors)","",
{"Farm","GameTravel"})T(QN,"Go Home by Respawn","",{"Farm";"HomeByRespawn"})T(QN,"Food Bowl
Trips","",{"Farm";"FoodBowlTrip"})v(QN,"Camp / Beach","",{"Farm";"SpotTravel"},
{{"teleport";"Teleport"};{"door","Shop Door"}},false)r(QN,"Retry Failed After (s)","",
{"Farm";"FailureCooldownSeconds"},1,120,1,"s")r(QN,"Fails Before Rest","",
{"Farm";"MaxConsecutiveFailures"},1,10,1)r(QN,"Rest For (min)","",
{"Farm";"DisableMinutes"},0,60,1,"min")local wN=c:Tab({Title="Info",Icon="solar:info-square-

bold"})local VN=wN:Section({Title="About Shxdrag Hub"})wN:Paragraph({Title="Shxdrag hub
\226\128\148 Adopt Me Farm"})wN:Paragraph({Title="WindUI by Footagesus"})u(wN,"Print Transparency
Report","Prints what the script does to the console (F9)",function()k.Disclosure()return
true,"Printed to console (F9)"end)u(wN,"Copy Re-Open Command","Copy the command to reopen the
window if it
closes",function()pcall(function()setclipboard("getgenv().AdoptMeFarm.OpenInterface()")end)return
true,"Copied: getgenv().AdoptMeFarm.OpenInterface()"end)local tN=0 local function RN()if not R then
return end local P,l=pcall(function()return type(k.Status)=="function"and k.Status()or nil end)if P
and type(l)=="table"then local k=U.stateHeader(l)pcall(function()j:SetTitle("Status: "..k)end)end
end local qN={}if B.logger and B.logger.OnEntry then
table.insert(q,B.logger.OnEntry:Connect(function(k,P,l)if not R or m.Toasts==false then return end
l=tostring(l)for k,P in ipairs(U.TOASTS)do if string.find(l,P.pattern)then if#qN>=3 then
table.remove(qN,1)end table.insert(qN,{title=P.title,content=string.sub(l,1,140)})break end end
end))end task.spawn(function()while R do if tN%2==0 then RN()end tN=tN+(1)task.wait(1)end
end)task.spawn(function()while R do local k=table.remove(qN,1)if k then
y(k.title,k.content)task.wait(3.5)else task.wait(.5)end end
end)pcall(function()L:OnDestroy(function()K.Close()end)end)U.opened=((U.opened or 0))+1 U.current=K
y(U.TITLE,"Ready! "..(J.." hides/shows the window."),"paw-print")return K end return U end
P["Game/GameConstants"]=function(...)local k={}k.PlaceId=920587237 k.Remotes=
{Folder="API",DataChanged="DataAPI/DataChanged";DataPartiallyChanged="DataAPI/DataPartiallyChanged"
;PetAilmentCompleted="AilmentsAPI/PetAilmentCompleted";BabyAilmentCompleted="AilmentsAPI/BabyAilmen
tCompleted",MinigameMessage="MinigameAPI/MessageClient";EventFolder="adoptme_new_net"}k.DataKeys=
{Ailments="ailments_manager",Money="money";Equip="equip_manager";Team="team";Interior="house_interi
or",PetWrappers="pet_char_wrappers_raw",Inventory="inventory";StateManager="state_manager_raw";Char
Wrapper="char_wrapper_raw";Candy="candy_2026";PetPen="idle_progression_manager",StrayCat="halloween
_2026_stray_cat_manager";Crypt="halloween_2026_crypt_manager";PigeonNest="halloween_2026_jacobean_p
igeon_nest_manager",LightningLever="halloween_2026_lightning_lever_manager";GhostCycle="ghost_clust
ers_cycle_timestamp";Dailies="dailies_manager";Hauntlet="halloween_2026_hauntlet_manager",HauntletC
ycle="hauntlet_cycle_timestamp"}k.PetsFolderName="Pets"k.PetModelIdAttribute="StreamingId"k.ClientD
ataModulePath={"ClientModules";"Core","ClientData"}k.Actions={ChooseTeam=
{remote="TeamAPI/ChooseTeam",purpose="switch your team to Babies (Farm.BabyMode)"};FocusPet=
{remote="AdoptAPI/FocusPet";purpose="pet_me: focus your pet"};PetPetted=
{remote="PetAPI/PetPetted";purpose="pet_me: pet your pet"},ProgressPetMe=
{remote="AilmentsAPI/ProgressPetMeAilment",purpose="pet_me: report the petting"};UnfocusPet=
{remote="AdoptAPI/UnfocusPet";purpose="pet_me: unfocus your pet"},DoorEnter=
{remote="AdoptAPI/SendPassiveDoorEnter",purpose="travel: enter a place (house, salon, cat cafe,
main map)"},SetLocation={remote="LocationAPI/SetLocation";purpose="travel: move to that
place"};SubscribeToHouse={remote="HousingAPI/SubscribeToHouse";purpose="travel: load YOUR house
when going home"};UnsubscribeFromHouse={remote="HousingAPI/UnsubscribeFromHouse";purpose="travel:
unload YOUR house when leaving it"};MarkEnteredDoorTime=
{remote="AdoptAPI/MarkEnteredDoorTime";purpose="leaving your house: the game\'s own door-time mark
(no arguments)"};PushFurnitureChanges={remote="HousingAPI/PushFurnitureChanges";purpose="leaving
your house: sent EMPTY ({}) as the game does; never changes
furniture";emptyOnly=true};CollectCashback={remote="PayAPI/Collect";purpose="collect your cashback
Bucks (Farm.CollectCashback)"},ChooseMystery=
{remote="AilmentsAPI/ChooseMysteryAilment",purpose="mystery: pick a need this script can
do"};ActivateFurniture={remote="HousingAPI/ActivateFurniture",purpose="use YOUR bed / shower /
toilet for your pet or baby",answersWhenDone=true},ExitSeatStates=
{remote="AdoptAPI/ExitSeatStates";purpose="get your character (baby) up from
furniture"},ExitFurnitureUseStates={remote="PetAPI/ExitFurnitureUseStates";purpose="get your pet up
if it stays on furniture"},EquipItem={remote="ToolAPI/Equip";purpose="hold YOUR food, drink, toy,
Rusty Key, Crypt Twig or the loaned Ghost Vacuum; re-equip YOUR pet ({equip_as_last=true}, as the
game at spawn); neon fusion: hold each of the 4 pets once"};Respawn=
{remote="TeamAPI/Spawn",purpose="go home fast by respawning (Farm.HomeByRespawn); recover when
stuck on the loading screen"},UseTool={remote="ToolAPI/ServerUseTool";purpose="eat / drink / throw
the item you hold; switch on the Ghost Vacuum (its answer is the vacuum token)"};UnequipItem=
{remote="ToolAPI/Unequip";purpose="put the item away"};ActivateInteriorFurniture=
{remote="HousingAPI/ActivateInteriorFurniture";purpose="sick: talk to the doctor in the
Hospital"},UnequipStroller={remote="AdoptAPI/UnequipStroller",purpose="ride: put the stroller
away"};CreatePetObject={remote="PetObjectAPI/CreatePetObject";purpose="give food/drink to your pet,
throw a toy for it"},ConsumeFoodObject={remote="PetAPI/ConsumeFoodObject",purpose="your pet eats
the given food (only if the game did not)"};GrabPetObject=
{remote="PetObjectAPI/GrabPetObject",purpose="your pet catches the toy (only if the game did
not)"};DropPetObject={remote="PetObjectAPI/DropPetObject";purpose="your pet gives the toy
back"};PetPenAdd={remote="IdleProgressionAPI/AddPet";purpose="Pet Pen: put one of YOUR growing pets
in the pen (Farm.Event.PetPen)"},PetPenRemove={remote="IdleProgressionAPI/RemovePet";purpose="Pet
Pen: take a FULL GROWN pet out of the pen"},PetPenClaim=
{remote="IdleProgressionAPI/CommitAllProgression",purpose="Pet Pen: CLAIM ALL (the pen\'s xp and
Bucks)"},PetPerformance={remote="PetAPI/ReplicateActivePerformances",purpose="pet_me: show the
petting animation, as the game does"};StrayCatFeed=
{remote="Halloween2026/StrayCatGiftFood";folder="EventFolder";purpose="Halloween: give 1 water to
the Stray Cat once a day (Farm.Event.StrayCat)"};UnlockPadlock=
{remote="Halloween2026/UnlockPadlock",folder="EventFolder";purpose="Halloween: use YOUR Rusty Key
on a Crypt grave (Farm.Event.Crypt)"};PigeonNestTwig=

{remote="Halloween2026/JacobeanPigeonNestContributeTwig",folder="EventFolder";purpose="Halloween:
put YOUR Crypt Twig in the Hotel nest (Farm.Event.PigeonNest)"},MinigameJoin=
{remote="MinigameAPI/AttemptJoin";purpose="Halloween: join the Ghost Gallery minigame
(Farm.Event.GhostGallery)"},MinigameLeave={remote="MinigameAPI/AttemptJoin";purpose="Ghost Gallery:
leave a round I could not get into (the game\'s own exit call)",leaveOnly=true},MinigameMessage=
{remote="MinigameAPI/MessageServer";purpose="Ghost Gallery: vacuum a ghost or a haunted prop (start
/ stop only)",allowedMessages=
{start_contribute=true;stop_contribute=true;start_prop_contribute=true;stop_prop_contribute=true}};
HauntletJoin={remote="MinigameAPI/AttemptJoin",purpose="Halloween: join a Hauntlet run
(Farm.Event.Hauntlet)";joinPrefix="hauntlet"};HauntletMessage=
{remote="MinigameAPI/MessageServer";purpose="Hauntlet: pick a door (1-3) or use one of MY run
items";hauntletMessage=true},UnlockHauntletJournal=
{remote="Halloween2026API/UnlockHauntletJournalPage";purpose="Hauntlet journal page unlock
(Farm.Event.Hauntlet)";noArgs=true};QuestClaim=
{remote="adoptme_new.modules.Dailies.DailiesNetService:9",folder="EventFolder",purpose="claim a
finished daily quest (Halloween / normal tab) (Farm.Event.Quests)";allowedFirstArg=
{halloween_2026=true,vanilla=true}},QuestTabReward=
{remote="adoptme_new.modules.Dailies.DailiesNetService:15";folder="EventFolder",purpose="claim a
quest board reward after 3 quests of the day (Rusty Key / egg)
(Farm.Event.Quests)";allowedFirstArg={halloween_2026=true,vanilla=true}},OpenGift=
{remote="ShopAPI/OpenGift";purpose="open YOUR gift (Farm.AutoOpen)"},OpenChest=
{remote="LootBoxAPI/ExchangeItemForReward",purpose="open YOUR chest
(Farm.AutoOpen)"},LightningLeverDeliver=
{remote="Halloween2026/LightningLeverDeliver",folder="EventFolder",purpose="Halloween: install YOUR
Lightning Lever in the machine by the Manor, once
(Farm.Event.AutoSkelicorn)",recordedArgs="deliver"};LightningLeverActivate=
{remote="Halloween2026/LightningLeverActivate";folder="EventFolder";purpose="Halloween: pull the
installed Lightning Lever (Farm.Event.AutoSkelicorn)",recordedArgs="activate"};ClaimTombSpider=
{remote="Halloween2026/ClaimTombSpider";folder="EventFolder";purpose="Halloween: take the Mummy
Spider at the bottom of the Crypt (Farm.Event.Crypt)"};NeonFusion=
{remote="PetAPI/DoNeonFusion";purpose="neon fusion: 4 of YOUR full grown pets of one kind -> 1 neon
(Farm.AutoNeon)"};BuyItem={remote="ShopAPI/BuyItem",purpose="buy 1 water / 1 hotdog when you have
none; 1 egg (Farm.EggToBuy) when you have no pet that still grows (Farm.BuyEgg); Halloween pets
with candy (Farm.Event.CandyPets)"}}k.BabiesTeam="Babies"k.ChooseTeamOptions=
{dont_respawn=true;source_for_logging="avatar_editor"}k.Travel={housing=
{door="MainDoor";spawn=nil;ownHouse=true},Salon={door="MainDoor",spawn=nil};MainMap=
{door="Neighborhood!MainDoor",spawn="Default"},CatCafe={door="MainDoor",spawn=nil};PizzaShop=
{door="MainDoor";spawn=nil},School={door="MainDoor",spawn=nil},Hospital=
{door="MainDoor";spawn=nil};CampingShop={door="MainDoor",spawn=nil};BeachShop=
{door="MainDoor";spawn=nil},BabyShop={door="MainDoor";spawn=nil};Nursery=
{door="MainDoor";spawn=nil};HauntedManor={door="MainDoor",spawn=nil};TheCrypt=
{door="MainDoor",spawn=nil},HauntedHotel={door="MainDoor",spawn=nil}}k.CharWrapperPlaces=
{TheCrypt=true}k.InteriorTalkForAilment={sick=
{furniture="doctor",use="UseBlock",choice="Yes"}}k.SpotDoor={camping={place="CampingShop";exit=
{x=-50.4;z=-1197.7}};beach_party={place="BeachShop";exit={x=-704.8,z=-1442.3}};bored=
{place="BabyShop",exit={x=-457.4,z=-1672.1}}}k.LocationForAilment=
{salon="Salon",bored="MainMap",cat_cafe="CatCafe";pizza_party="PizzaShop",school="School";sick="Hos
pital";camping="MainMap",beach_party="MainMap"}k.PlayButtonPath=
{"NewsApp";"EnclosingFrame";"MainFrame","Buttons";"PlayButton"}k.MysteryPreference=
{"toilet";"dirty","sleepy","hungry","thirsty";"pet_me";"play";"sick";"cat_cafe","salon";"school","p
izza_party";"camping";"beach_party";"bored";"walk","ride"}k.MysterySlot=1
k.StrollerCategory="strollers"k.WalkSeconds=45 k.Spots={camping=
{x=-18.443;y=37.204,z=-1046.005;purpose="camping: the camp site in the neighborhood"};beach_party=
{x=-579.456,y=25.634,z=-1496.408;purpose="beach_party: the beach in the neighborhood"};bored=
{x=-401.629;y=29.779;z=-1760.047;purpose="bored: the playground in the neighborhood"},stray_cat=
{x=-243.6;y=87;z=-1118.2,purpose="Halloween: next to the Stray Cat"}}k.SpotForAilment=
{camping="camping";beach_party="beach_party";bored="bored"}k.HouseInteriorName="housing"k.HouseExit
Destination="exit_housing"k.HouseExitCameraOffset=
{x=.68896484375,y=8.55078125;z=8.8720703125;rx=-0.73691004514694,ry=.057421416044235,rz=.0520308017
73071}k.FullGrownAge=6 function k.focusOf(P)local l=type(P)=="table"and(type(P.Focus)=="string"and
string.match(P.Focus,"^%s*(.-)%s*$"))or""if l==""then return nil end if k.isEgg(l)then
return{id=l,kind="egg"}end local B=k.Event or{}if l==B.MummySpiderKind then
return{id=l,kind="spider"}end if l==B.Skelicorn then return{id=l;kind="skelicorn"}end local
U=type(P.Event)=="table"and(type(P.Event.CandyPets)=="table"and P.Event.CandyPets)or{}for k,P in
ipairs(type(U.Buy)=="table"and U.Buy or{})do local B=tonumber(P.price)if((P.id or P[1]))==l and(B
and B>0)then return{id=l;kind="candy",price=B;keepCandy=tonumber(U.KeepCandy)or 0}end end
return{id=l,kind="pet"}end function k.focusKind(P)local l=k.focusOf(P)return l and(l.kind~="egg"and
l.id)or nil end function k.kindRank(P)local l=type(P)=="table"and P.FarmPetKinds local
B=k.focusOf(P)local U=B and B.id if((type(l)~="table"or#l==0))and not U then return nil end local
Z={}if U then Z[U]=0 end for k,P in ipairs(type(l)=="table"and l or{})do Z[P]=Z[P]or k end return Z
end function k.isNeonPet(k)return type(k)=="table"and((k.neon==true or k.mega_neon==true))end
k.Eggs={"cracked_egg";"pet_egg";"fairytale_egg_2026_fairytale_egg"}k.NeverBuyEggs=
{royal_egg=true}k.EggCategory="pets"k.NotFarmablePets={practice_dog=true}function k.isEgg(P)if
type(P)~="string"then return false end for k,l in ipairs(k.Eggs)do if P==l then return true end end

return P=="royal_egg"or string.match(P,"_egg$")~=nil and not string.find(P,"^basic_egg_")end
function k.isOnMainMapArea(k)return k.X>-1500 and(k.X<1000 and(k.Z>-3000 and k.Z<0))end
k.HouseFurnitureFolderPath=
{"HouseInteriors";"furniture"}k.FurnitureUniqueAttribute="furniture_unique"k.FurnitureForAilment=
{sleepy={"basicbed"};dirty={"stylishshower";"modernshower";"cheap_pet_bathtub_tutorial"},toilet=
{"toilet"}}k.PetFoodBowls={"ailments_refresh_2024_cheap_food_bowl"}k.PetOnlyFurniture=
{cheap_pet_bathtub_tutorial=true}k.UseBlockForFurniture=
{modernshower="UseBlock";cheap_pet_bathtub_tutorial="UseBlock",ailments_refresh_2024_cheap_food_bow
l="UseBlock";basicbed="Seat1",stylishshower="UseBlock";toilet="Seat1"}k.ItemCategory="food"k.ItemsF
orAilment={hungry={"sandwich-default";"cheese","hotdog"},thirsty=
{"water","chocolate_milk"}}k.BuyForAilment={thirsty={category="food",ids={"water"};options=
{},setting="BuyWater"};hungry={category="food";ids={"hotdog"};options=
{buy_count=1};setting="BuyFood"}}k.PetObjectsFolderName="PetObjects"k.FoodObjectCreator="__Enum_Pet
ObjectCreatorType_2"k.ToyObjectCreator="__Enum_PetObjectCreatorType_1"k.ThrowToyReaction="ThrowToyR
eaction"k.ToyCategory="toys"k.ToysForPlay={"squeaky_bone_default"}k.AgePotions=
{"pet_age_potion";"tiny_pet_age_potion"}k.GiftCategory="gifts"k.GiftPatterns=
{gift="gift$";chest="_chest$"}k.Event=
{RustyKey="halloween_2026_rusty_key";Twig="halloween_2026_twig",Vacuum="halloween_2026_ghost_vacuum
",NestTwigs=8;CatFood={"water";"chocolate_milk"};Ladder="ladder";GraveValue=
{candy_corn_pile_ginormous=3,candy_corn_pile_small=2,twig=1};OpenedIdPerFloor=16;PetPenSlots=4,Mini
gameId="ghost_clusters",JoinZoneTeleportPath=
{"StaticMap","TeleportLocations","ghost_clusters"},JoinZoneModelPath=
{"Interiors","HauntedManor","GhostClustersMinigameJoinZone"};JoinZoneRadius=15;MinigameInteriorPref
ix="ManorMinigameInterior";HauntletId="hauntlet",HauntletInteriorPrefix="HauntletInterior",Hauntlet
Lobby="HauntedHotel";HauntletClientPath=
{"SharedModules","ContentPacks","Halloween2026","Minigames";"HauntletMinigameClient"};HauntletItems
=
{cell_phone=true;key=true,gold_key=true,red_potion=true,ghost_potion=true;gold_potion=true;rainbow_
wand=true},HauntletStrategy=
{revealWaitSeconds=5;planSeconds=5;commitBySeconds=10,slotStart=1;slotGap=.6;preferLockedWhenSafe=t
rue;kindPenalty={}};HauntletDebug=false;HauntletDBPath=
{"SharedModules","ContentPacks";"Halloween2026";"Game";"Hauntlet"};RoundSeconds=600,GhostsFolder="G
hostClustersVisuals",GhostNamePattern="^Ghost_%a+_([%x%-]+)$",BossSize="Large",HoldBelowStuds=50;Pr
opStandOff=10;QuestTabs={"halloween_2026","vanilla"},QuestsPerBoardReward=3;CryptRewards=
{"ladder","twig";"candy_corn_pile_ginormous","candy_corn_pile_small"},LightningLever="halloween_202
6_lightning_lever";Skelicorn="halloween_2026_skelicorn";MummySpiderKind="halloween_2026_tomb_spider
";SkelicornPrice=120000,LeverMachinePatterns={"lightning","lever"},SkelicornArgs={deliver=
{}}}k.FarmPotions={"pet_age_potion","tiny_pet_age_potion";"pet_bonus_bucks_potion"}function
k.needOn(k,P)if type(k)~="table"then return false end local l=type(k.Tasks)=="table"and k.Tasks
or{}local B=k.AutoNeeds if type(B)~="table"then return l[P]==true end if B.Enabled~=true or
l[P]==false then return false end for k,l in ipairs(type(B.Skip)=="table"and B.Skip or{})do if l==P
then return false end end return true end return k end P["Game/GameData"]=function(...)local
k=...local P=k("Core/Signal")local l=k("Game/GameConstants")local B=game:GetService("Players")local
U=game:GetService("ReplicatedStorage")local Z={}Z.__index=Z local m=12 local function H(k,P,l)if
type(k)~="table"then return k end P=P or 0 l=l or{}if l[k]then return l[k]end if P>m then return
nil end local B={}l[k]=B for k,U in pairs(k)do B[H(k,P+1,l)]=H(U,P+1,l)end return B end
Z.deepCopy=H function Z.new(k)local B=setmetatable({},Z)B._logger=k B._data={}B._tracked={}for k,P
in pairs(l.DataKeys)do B._tracked[P]=true end
B.KeyChanged=P.new("GameData.KeyChanged")B.SnapshotSource=nil return B end function
Z.get(P,k)return P._data[k]end function Z.isTracked(P,k)return P._tracked[k]==true end function
Z._setKey(l,k,P)if not l._tracked[k]then return end
l._data[k]=H(P)l.KeyChanged:Fire(k,l._data[k])end function Z._applyPartial(P,k)if
type(k)~="table"or type(k.replicated_key_path)~="table"then return end local
l=k.replicated_key_path local B=l[1]if not P._tracked[B]then return end if#l==1 then
P:_setKey(B,k.serialized_partial_value)return end if type(P._data[B])~="table"then P._data[B]={}end
local U=P._data[B]for k=2,#l-1,1 do local P=l[k]if type(U[P])~="table"then U[P]={}end U=U[P]end
U[l[#l]]=H(k.serialized_partial_value)P.KeyChanged:Fire(B,P._data[B])end local function Q(k,P)local
l=k for k,P in ipairs(P)do l=l and l:FindFirstChild(P)end return l end local function A(k,P)local
l={}for k in pairs(k)do table.insert(l,tostring(k))if#l>=P then break end end return
table.concat(l,", ")end function Z._loadSnapshot(k)local P=Q(U,l.ClientDataModulePath)if not P then
return nil,"ClientData module not found"end local Z,m=pcall(require,P)if not Z or
type(m)~="table"then return nil,"require(ClientData) failed: "..tostring(m)end if
type(m.get_data)~="function"then return nil,"ClientData.get_data is not a function"end local
H,f=pcall(m.get_data)if not H then return nil,"ClientData.get_data() failed: "..tostring(f)end if
type(f)~="table"then return nil,"ClientData.get_data() returned "..typeof(f)end local
Y=B.LocalPlayer and B.LocalPlayer.Name local n=Y and f[Y]if type(n)=="table"then return
n,"ClientData.get_data()[playerName]"end if f[l.DataKeys.Ailments]~=nil or f[l.DataKeys.Money]~=nil
then return f,"ClientData.get_data()"end return nil,"ClientData.get_data() returned an unknown
shape (keys: "..(A(f,8)..")")end function Z.start(P,k)local Z=B.LocalPlayer and B.LocalPlayer.Name
local m=U:FindFirstChild(l.Remotes.Folder)if not m then
P._logger:error("GameData","ReplicatedStorage."..(l.Remotes.Folder.." not found; game data
unavailable"))return false end local H=m:FindFirstChild(l.Remotes.DataChanged)if not((H and
H:IsA("RemoteEvent")))then P._logger:error("GameData",l.Remotes.DataChanged.." not found; game data
unavailable")return false end k:Give(H.OnClientEvent:Connect(function(k,l,B)if k~=Z then return end

P:_setKey(l,B)end))local Q=m:FindFirstChild(l.Remotes.DataPartiallyChanged)if Q and
Q:IsA("RemoteEvent")then k:Give(Q.OnClientEvent:Connect(function(k,l)if k~=Z or
type(l)~="table"then return end for k,l in ipairs(l)do P:_applyPartial(l)end end))else
P._logger:warn("GameData",l.Remotes.DataPartiallyChanged.." not found; nested updates will be
missed")end local A,f=P:_loadSnapshot()if A then P.SnapshotSource=f for k in pairs(P._tracked)do if
A[k]~=nil and P._data[k]==nil then P:_setKey(k,A[k])end end P._logger:info("GameData","Initial data
loaded via "..f)else P.SnapshotSource=nil P._logger:warn("GameData","No initial data ("..
(tostring(f).."). Values appear as the game sends updates."))end return true end function
Z.getPetKind(P,k)local B=P._data[l.DataKeys.Equip]if type(B)=="table"and type(B.pets)=="table"then
for P,l in pairs(B.pets)do if type(l)=="table"and l.unique==k then return l.kind or l.id end end
end local U=P._data[l.DataKeys.PetWrappers]if type(U)=="table"then for P,l in pairs(U)do if
type(l)=="table"and l.pet_unique==k then return l.pet_id end end end local
Z=P._data[l.DataKeys.Inventory]local m=type(Z)=="table"and(type(Z.pets)=="table"and Z.pets[k])if
type(m)=="table"then return m.kind or m.id end return nil end function Z.isPetEquipped(P,k)local
B=P._data[l.DataKeys.Equip]if type(B)~="table"or type(B.pets)~="table"then return true end for P,l
in pairs(B.pets)do if type(l)=="table"and l.unique==k then return true end end return false end
function Z.findItems(B,k,P)local U=B._data[l.DataKeys.Inventory]local Z=type(U)=="table"and
U[k]local m={}if type(Z)~="table"then return m end local H={}for k,P in ipairs(P or{})do H[P]=k end
for k,l in pairs(Z)do if type(l)=="table"and(l.id~=nil and((P==nil or H[l.id])))then local
P=type(l.properties)=="table"and l.properties or{}table.insert(m,{unique=tostring(l.unique or
k);id=l.id,usesLeft=tonumber(P.uses_left)})end end table.sort(m,function(k,P)if
H[k.id]~=H[P.id]then return H[k.id]<H[P.id]end return k.unique<P.unique end)return m end function
Z.itemUsesLeft(B,k,P)local U=B._data[l.DataKeys.Inventory]local
Z=type(U)=="table"and(type(U[k])=="table"and U[k][P])if type(Z)~="table"then return nil end local
m=type(Z.properties)=="table"and Z.properties or{}return tonumber(m.uses_left)or 1 end function
Z.equippedPetCount(k)local P=k._data[l.DataKeys.Equip]local B=0 for k,P in
pairs(type(P)=="table"and(type(P.pets)=="table"and P.pets)or{})do if type(P)=="table"and P.unique
then B=B+(1)end end return B,P~=nil end function Z.firstEquippedPet(k)local
P=k._data[l.DataKeys.Equip]for k,P in pairs(type(P)=="table"and(type(P.pets)=="table"and
P.pets)or{})do if type(P)=="table"and P.unique then return P.unique end end return nil end function
Z.equippedPetList(k)local P=k._data[l.DataKeys.Equip]local B={}for P,l in
pairs(type(P)=="table"and(type(P.pets)=="table"and P.pets)or{})do if type(l)=="table"and l.unique
then local P=type(l.properties)=="table"and l.properties or{}local U=tonumber(P.age)if U==nil then
U=k:petAge(l.unique)end table.insert(B,{unique=l.unique,age=U})end end return B end function
Z.petAge(P,k)local B=P._data[l.DataKeys.Inventory]local U=type(B)=="table"and B.pets local
Z=type(U)=="table"and U[k]local m=type(Z)=="table"and(type(Z.properties)=="table"and
Z.properties)return m and tonumber(m.age)or nil end function Z.petPenPets(k)local
P=k._data[l.DataKeys.PetPen]local B={}for k,P in
pairs(type(P)=="table"and(type(P.active_pets)=="table"and P.active_pets)or{})do
B[tostring(k)]=type(P)=="table"and P or{}end return B end function Z.isPetNeon(P,k)local
B=P._data[l.DataKeys.Inventory]local U=type(B)=="table"and B.pets local Z=type(U)=="table"and
U[k]return type(Z)=="table"and l.isNeonPet(Z.properties)end function Z.growingCopies(P,k)local
B=P._data[l.DataKeys.Inventory]local U=type(B)=="table"and(type(B.pets)=="table"and
B.pets)or{}local Z=0 for P,B in pairs(U)do if type(B)=="table"and tostring(B.kind or B.id)==k then
local k=type(B.properties)=="table"and B.properties or{}local P=tonumber(k.age)if P==nil or
P<l.FullGrownAge then Z=Z+(1)end end end return Z end function Z.growablePets(U,k,P,B)local
Z=U._data[l.DataKeys.Inventory]local m=type(Z)=="table"and Z.pets local H=U:petPenPets()local Q=
{}for k,P in pairs(type(m)=="table"and m or{})do if type(P)=="table"and not H[tostring(P.unique or
k)]then local B=type(P.properties)=="table"and P.properties or{}local U=tonumber(B.age)local
Z=tostring(P.kind or P.id or"?")if U==nil and l.isEgg(Z)then U=0 end if U and(U<l.FullGrownAge and
not l.NotFarmablePets[Z])then table.insert(Q,{unique=tostring(P.unique or
k);age=U;kind=Z;neon=l.isNeonPet(B)})end end end table.sort(Q,function(l,U)local Z=P and
P[l.kind]or math.huge local m=P and P[U.kind]or math.huge if Z~=m then return Z<m end if k and
l.neon~=U.neon then return l.neon end if l.age~=U.age then if B then return l.age<U.age end return
l.age>U.age end return l.unique<U.unique end)return Q end function Z.neonFusionGroups(B,k,P)local
U=B._data[l.DataKeys.Inventory]local Z=type(U)=="table"and U.pets local m=B:petPenPets()local H=
{}for B,U in pairs(type(Z)=="table"and Z or{})do if type(U)=="table"and
type(U.properties)=="table"then local Z=tostring(U.unique or B)local Q=tostring(U.kind or U.id
or"?")local A=tonumber(U.properties.age)local f if P then f=U.properties.neon==true and
U.properties.mega_neon~=true else f=not l.isNeonPet(U.properties)end if A==l.FullGrownAge and(f
and(not m[Z]and(not((k and k[Q]))and not l.NotFarmablePets[Q])))then
H[Q]=H[Q]or{}table.insert(H[Q],Z)end end end for k,P in pairs(H)do table.sort(P)end return H end
function Z.neonCountOfKind(P,k)local B=P._data[l.DataKeys.Inventory]local U=type(B)=="table"and
B.pets local Z=0 for P,l in pairs(type(U)=="table"and U or{})do if
type(l)=="table"and(tostring(l.kind or l.id)==k and(type(l.properties)=="table"and
l.properties.neon==true))then Z=Z+(1)end end return Z end function Z.megaCountOfKind(P,k)local
B=P._data[l.DataKeys.Inventory]local U=type(B)=="table"and B.pets local Z=0 for P,l in
pairs(type(U)=="table"and U or{})do if type(l)=="table"and(tostring(l.kind or l.id)==k
and(type(l.properties)=="table"and l.properties.mega_neon==true))then Z=Z+(1)end end return Z end
function Z.isPetMega(P,k)local B=P._data[l.DataKeys.Inventory]local U=type(B)=="table"and B.pets
local Z=type(U)=="table"and U[k]return type(Z)=="table"and(type(Z.properties)=="table"and
Z.properties.mega_neon==true)end function Z.petInventoryKnown(k)local
P=k._data[l.DataKeys.Inventory]return type(P)=="table"and type(P.pets)=="table"end function
Z.petUniquesOfKind(P,k)local B=P._data[l.DataKeys.Inventory]local U=type(B)=="table"and B.pets

local Z={}for P,l in pairs(type(U)=="table"and U or{})do if type(l)=="table"and tostring(l.kind or
l.id)==k then Z[tostring(l.unique or P)]=true end end return Z end function Z.itemsOfId(l,k,P)local
B={}for k,P in ipairs(l:findItems(k,{P}))do table.insert(B,P.unique)end return B end function
Z.isSitting(k)local P=k._data[l.DataKeys.StateManager]return type(P)=="table"and P.is_sitting==true
end function Z.destroy(k)k.KeyChanged:DisconnectAll()end return Z end
P["Game/GameIcons"]=function(...)local k={}k.__index=k k.KNOWN={bucks={path=
{"Resources","BucksBillboard","BillboardGui","Frame";"ImageLabel"};id=3577407233};candy={path=
{"Resources","CRYPT_PIECES";"Crypt_2026_Floor03","Game","RewardSign","SurfaceGui","Frame";"RewardTe
mplate","Icon"},id=14845052425},home={path=
{"Resources";"HomeBillboard","ImageLabel"},id=2000934070}}local P=10 local l=20 function
k.new(P,l)local B=setmetatable({},k)B._logger=P B._clock=l or os.clock B._items={}B._currency=
{}B._tries={}B._lastTry={}return B end function k.image(k)if type(k)=="number"then
return"rbxassetid://"..math.floor(k)end if
type(k)=="string"and((string.find(k,"^rbxassetid://%d+")or string.find(k,"^rbxasset://")or
string.find(k,"^https?://")))then return k end return nil end function k.assetId(k)if
type(k)~="string"then return nil end return tonumber(string.match(k,"^rbxassetid://(%d+)")or
string.match(k,"[?&]id=(%d+)"))end function k._db(k)if k._dbState~=nil then return k._dbState or
nil end local P,l=pcall(function()local k=game:GetService("ReplicatedStorage")local
P=k:FindFirstChild("Fsys")if P then local k=require(P)if type(k)=="table"and
type(k.load)=="function"then local P=k.load("InventoryDB")if type(P)=="table"then return P end end
end local l=k:FindFirstChild("ClientDB")local B=l and l:FindFirstChild("InventoryDB",true)if B and
B:IsA("ModuleScript")then local k=require(B)if type(k)=="table"then return k end end return nil
end)k._dbState=P and(type(l)=="table"and l)or false if not k._dbState and k._logger then
k._logger:debug("Icons","The game\'s item list was not found: the window keeps its own icons")end
return k._dbState or nil end function k.known(l,P)local B=k.KNOWN[P]if not B then return nil end if
l._known and l._known[P]then return l._known[P]end local U pcall(function()local
P=game:GetService("ReplicatedStorage")for k,l in ipairs(B.path)do P=P and P:FindFirstChild(l)end if
P and((P:IsA("ImageLabel")or P:IsA("ImageButton")))then U=k.image(P.Image)end end)U=U or
k.image(B.id)l._known=l._known or{}l._known[P]=U return U end function k.picture(P,k)if
type(k)~="string"then return nil end local l,B=string.match(k,"^(%a+):(.+)$")if l=="game"then
return P:known(B)elseif l=="item"then return P:item(B)end return nil end function k.item(l,P)if
type(P)~="string"then return nil end if l._items[P]~=nil then return l._items[P]or nil end local
B=false local U=l:_db()if U then pcall(function()for l,U in pairs(U)do local Z=type(U)=="table"and
rawget(U,P)if type(Z)=="table"and k.image(Z.image)then B=k.image(Z.image)return end end end)end
l._items[P]=B return B or nil end function k.nearestPicture(k)local P,l local
B=k.AbsolutePosition+k.AbsoluteSize/2 for U,Z in ipairs({k.Parent;k.Parent and k.Parent.Parent})do
if Z and not P then for U,Z in ipairs(Z:GetDescendants())do if((Z:IsA("ImageLabel")or
Z:IsA("ImageButton")))and(Z.Visible and Z.Image~="")then local U=Z.AbsoluteSize local m=U.Y>0 and
U.X/U.Y or 0 if m>.6 and(m<1.6 and U.Y<=k.AbsoluteSize.Y*3)then local k=
((((Z.AbsolutePosition+U/2))-B)).Magnitude if not P or k<l then P,l=Z.Image,k end end end end end
end return P end local function B(k)return(string.gsub(tostring(k or""),"%D",""))end function
k.currency(m,U,Z)if m._currency[U]then return m._currency[U]end Z=tonumber(Z)if not Z or Z<10 then
return nil end local H=m._clock()local Q=m._tries[U]or 0 if Q>=P or(m._lastTry[U]and Hm._lastTry[U]<l)then return nil end m._tries[U],m._lastTry[U]=Q+1,H local
A=tostring(math.floor(Z))local f,Y=pcall(function()local P=
(game:GetService("Players")).LocalPlayer:FindFirstChild("PlayerGui")for P,l in ipairs(P and
P:GetChildren()or{})do if l:IsA("ScreenGui")and l.Enabled then for P,l in
ipairs(l:GetDescendants())do if l:IsA("TextLabel")and(l.Visible and B(l.Text)==A)then local
P=k.nearestPicture(l)if P then return P end end end end end return nil end)if f and Y then
m._currency[U]=Y return Y end return nil end return k end P["Game/PetLocator"]=function(...)local
k=...local P=k("Game/GameConstants")local l={}l.__index=l function l.new(k)return
setmetatable({_gameData=k},l)end function l.getStreamingId(l,k)local
B=l._gameData:get(P.DataKeys.PetWrappers)if type(B)~="table"then return nil end for P,l in
pairs(B)do if type(l)=="table"and(l.pet_unique==k and type(l.char)=="string")then return l.char end
end return nil end function l.findModel(l,k)local B=l:getStreamingId(k)if not B then return nil,"no
pet wrapper for this pet yet"end local U=workspace:FindFirstChild(P.PetsFolderName)if not U then
return nil,"workspace."..(P.PetsFolderName.." not found")end for k,l in ipairs(U:GetChildren())do
local U,Z=pcall(function()return l:GetAttribute(P.PetModelIdAttribute)end)if U and Z==B then return
l end end return nil,"model not streamed in yet"end function l.getEquippedPets(k)local
l=k._gameData:get(P.DataKeys.Equip)local B={}if type(l)~="table"or type(l.pets)~="table"then return
B end for k,P in pairs(l.pets)do if type(P)=="table"and type(P.unique)=="string"then local
k=type(P.properties)=="table"and P.properties or{}table.insert(B,
{unique=P.unique,kind=tostring(P.kind or P.id or"?");age=tonumber(k.age);xp=tonumber(k.xp)})end end
table.sort(B,function(k,P)return k.unique<P.unique end)return B end return l end
P["Game/PlayerSync"]=function(...)local k=...local P=k("Game/GameConstants")local l={}local
B=P.DataKeys local function U(k)local P={}for k,l in pairs(type(k.furniture)=="table"and
k.furniture or{})do if type(l)=="table"and type(l.id)=="string"then P[l.id]=((P[l.id]or 0))+1 end
end local l={}for k,P in pairs(P)do table.insert(l,k..(" x"..P))end table.sort(l)return#l>0 and
table.concat(l,", ")or"none"end function l.start(k,l,Z,m,H)local Q=nil local function A()local
k=Z:get(B.CharWrapper)local l=type(k)=="table"and(type(k.location)=="table"and k.location)local U=l
and l.destination_id return((type(U)=="string"and P.CharWrapperPlaces[U]))and U or nil end local
function f(k,f)if k==B.CharWrapper then local P=Z:get(B.Interior)local U=A()if U
and(l:get("player.interior")==nil and(type(P)=="table"and(type(P.interior_name)~="string"and
P.house_pos==nil)))then l:set("player.interior",U,"DataChanged:"..k)end return end if k==B.Money

and tonumber(f)then l:set("player.bucks",tonumber(f),"DataChanged:"..k)elseif k==B.Team and
type(f)=="string"then l:set("player.team",f,"DataChanged:"..k)elseif k==B.Interior and
type(f)=="table"then local B=type(f.interior_name)=="string"and f.interior_name
or(((f.house_pos~=nil or next(type(f.furniture)=="table"and f.furniture or{})~=nil))and
P.HouseInteriorName or nil)B=B or A()l:set("player.interior",B,"DataChanged:"..k)if B==nil then
return end if H and Q~=B then Q=B H:debug("Furniture","In "..(B..(": "..U(f))))end elseif
k==B.Equip then l:set("pets.equipped",m:getEquippedPets(),"DataChanged:"..k)end end
k:Give(Z.KeyChanged:Connect(f))for k,P in ipairs({B.Money,B.Team;B.Interior;B.Equip})do local
l=Z:get(P)if l~=nil then f(P,l)end end end return l end P["Game/AilmentTracker"]=function(...)local
k=...local P=k("Core/Enums")local l=k("Core/Signal")local B=k("Game/GameConstants")local
U=game:GetService("Players")local Z=game:GetService("ReplicatedStorage")local m={}m.__index=m local
H="DataChanged:"..B.DataKeys.Ailments function m.new(k,P,B,U)local Z=setmetatable({},m)Z._logger=k
Z._state=P Z._notifier=B Z._gameData=U Z._previous=
{}Z.Completed=l.new("AilmentTracker.Completed")return Z end local function
Q(k)return((k.owner=="baby"and"baby"or k.petUnique))..("|"..k.kind)end function m.ownerLabel(P,k)if
k.owner=="baby"then return"baby"end return"pet "..tostring(k.petKind or"?")end local function
A(k,P)local l=type(k)=="table"and k.components local B=type(l)=="table"and l.preference local
U=type(k)=="table"and tonumber(k.rate)or 0 local Z=nil local m=type(l)=="table"and l.mystery if
type(m)=="table"and type(m.components)=="table"then Z={}for k in pairs(m.components)do
table.insert(Z,tostring(k))end table.sort(Z)end
return{mysteryOptions=Z;mysterySeed=type(m)=="table"and m.random_seed or
nil,kind=tostring(type(k)=="table"and k.kind or
P),rate=U,inProgress=U>0;progress=type(k)=="table"and tonumber(k.progress)or
0,createdAt=type(k)=="table"and tonumber(k.created_timestamp)or
nil,preferredItem=type(B)=="table"and B.item_kind or nil}end function m.parse(P,k)local l={}if
type(k)~="table"then return l end if type(k.ailments)=="table"then for k,B in pairs(k.ailments)do
if type(B)=="table"then for B,U in pairs(B)do local
Z=A(U,B)Z.owner="pet"Z.petUnique=tostring(k)Z.petKind=P._gameData:getPetKind(Z.petUnique)table.inse
rt(l,Z)end end end end if type(k.baby_ailments)=="table"then for k,P in pairs(k.baby_ailments)do
local B=A(P,k)B.owner="baby"table.insert(l,B)end end table.sort(l,function(k,P)return((k.createdAt
or 0))<((P.createdAt or 0))end)return l end function m._onAilmentsChanged(P,k)local
l=P:parse(k)local B={}for k,l in ipairs(l)do local U=Q(l)B[U]=l local Z=P._previous[U]local
m=P:ownerLabel(l)..(" "..l.kind)if not Z then local k=l.preferredItem and(" (prefers "..
(l.preferredItem..")"))or""P._logger:info("Needs","New need: "..(m..k))elseif l.inProgress and not
Z.inProgress then P._logger:info("Needs",string.format("In progress: %s (about %d
s)",m,math.floor(1/l.rate+.5)))elseif not l.inProgress and Z.inProgress then if
P._state:get("farm.currentTask")==l.kind then P._logger:info("Needs","Progress stopped: "..m)else
P._logger:debug("Needs","Progress stopped: "..m)end end end for k,l in pairs(P._previous)do if not
B[k]then P._logger:debug("Needs","Removed from list: "..(P:ownerLabel(l)..(" "..l.kind)))end end
P._previous=B P._state:set("ailments.active",l,H)P._state:set("ailments.known",true,H)end function
m._isMyPet(P,k)if P._gameData:getPetKind(k)~=nil then return true end for P,l in
pairs(P._previous)do if l.petUnique==k then return true end end return false end function
m._onCompleted(m,k,l,U,Z)local H=type(Z)=="table"and tonumber(Z.bucks)or 0 local
Q=type(Z)=="table"and tonumber(Z.xp)or nil local A=k=="baby"and"baby"or("pet
"..tostring(m._gameData:getPetKind(l)or"?"))local f=k=="baby"and B.Remotes.BabyAilmentCompleted or
B.Remotes.PetAilmentCompleted local Y=m._state:increment("stats.needsCompleted",1,f)local
n=m._state:increment("stats.bucksEarned",H,f)local L=A..("
"..tostring(U))m._state:set("stats.lastTask",L,f)m._logger:success("Needs",string.format("Completed
: %s (+%d Bucks%s)",L,H,Q and(", +"..(Q.."
XP"))or""))m.Completed:Fire(k,l,tostring(U))m._notifier:notify(P.NotifyEvent.TaskCompleted,
{{name="Last task";value=L;inline=true};{name="Needs completed",value=tostring(Y);inline=true},
{name="Bucks earned";value=tostring(n),inline=true}})end function
m.start(P,k)k:Give(function()P.Completed:DisconnectAll()end)k:Give(P._gameData.KeyChanged:Connect(f
unction(k,l)if k==B.DataKeys.Ailments then P:_onAilmentsChanged(l)end end))local
l=P._gameData:get(B.DataKeys.Ailments)if l~=nil then P:_onAilmentsChanged(l)end local
m=Z:FindFirstChild(B.Remotes.Folder)local H=m and m:FindFirstChild(B.Remotes.PetAilmentCompleted)if
H and H:IsA("RemoteEvent")then k:Give(H.OnClientEvent:Connect(function(k,l,B)if not
P:_isMyPet(tostring(k))then P._logger:debug("Needs","Ignored a completion for a pet that is not
mine")return end P:_onCompleted("pet",tostring(k),l,B)end))else
P._logger:warn("Needs",B.Remotes.PetAilmentCompleted.." not found; pet completions not counted")end
local Q=m and m:FindFirstChild(B.Remotes.BabyAilmentCompleted)if Q and Q:IsA("RemoteEvent")then
k:Give(Q.OnClientEvent:Connect(function(k,l,B)if k~=U.LocalPlayer then
P._logger:debug("Needs","Ignored a baby completion for another player")return end
P:_onCompleted("baby",nil,l,B)end))else P._logger:warn("Needs",B.Remotes.BabyAilmentCompleted.."
not found; baby completions not counted")end end return m end
P["Game/Interaction"]=function(...)local k=...local P=k("Core/Util")local
l=k("Game/GameConstants")local B=game:GetService("ReplicatedStorage")local U={}U.__index=U local
Z=10 function U.new(k,P)local l=setmetatable({},U)l._logger=k l._state=P l._sent=0 return l end
function U.describeActions()local k={}for P in pairs(l.Actions)do table.insert(k,P)end
table.sort(k)local P={}for k,B in ipairs(k)do local U=l.Actions[B]table.insert(P,U.remote..("
\226\128\148 "..U.purpose))end table.insert(P,"LOCAL teleport of your character inside the
neighborhood to the camp site / beach / playground (Farm.SpotTravel)")table.insert(P,"LOCAL click
on the main menu Play button and then HOME in \"Choose Location!\" \226\128\148 only on the menu
(Farm.AutoAcceptMenu)")table.insert(P,"LOCAL call of the game\'s OWN travel function

(InteriorsM.enter, the one every door uses): it sends the game\'s own door / location requests
(Farm.GameTravel); also to visit other players\' houses for the \"Visit player homes\" quests
(Farm.Event.HouseVisits)")table.insert(P,"LOCAL walking of your character in long diagonal legs
(~30 studs) \226\128\148 ONLY for the walk need (and ride); if the game left it anchored on solid
ground, it is un-anchored first")table.insert(P,"LOCAL teleport of your character next to the Stray
Cat (Halloween map), into the Ghost Gallery join circle in the Haunted Manor (where the popup\'s
Yes puts you) and, inside the minigame only, 50 studs under the ghost it vacuums (held every frame,
back on the floor after the round) (Farm.Event)")table.insert(P,"LOCAL teleport of your character
into the selected door\'s join circle inside the Hauntlet rooms, requesting nearby room streaming
when needed (Farm.Event.Hauntlet)")table.insert(P,"LOCAL virtual click \226\128\148 only when
Roblox says you are idle, to avoid the 20-minute kick (Farm.AntiAfk)")table.insert(P,"ROBLOX rejoin
of a server of this game (TeleportService) \226\128\148 only after 3 min with no place / no
character, e.g. a white screen in a dead minigame (Farm.AutoRejoin)")return P end function
U.virtualClick()return pcall(function()local
k=game:GetService("VirtualUser")k:CaptureController()k:ClickButton2(Vector2.new(0,0))end)end
U.CLICK_METHODS={"firesignal","connections";"touch","mouse"}local m=
{"Activated";"MouseButton1Click";"MouseButton1Down","MouseButton1Up"}local function H(k)local
P=k:FindFirstAncestorOfClass("ScreenGui")local l=((P and P.IgnoreGuiInset))and
Vector2.new(0,0)or(game:GetService("GuiService")):GetGuiInset()return(k.AbsolutePosition.X+k.Absolu
teSize.X/2)+l.X,(k.AbsolutePosition.Y+k.AbsoluteSize.Y/2)+l.Y end function U.clickButton(k,P)if
P=="connections"then if type(getconnections)~="function"then return false,"getconnections
missing"end local P=0 for l,B in ipairs(m)do pcall(function()for k,l in
ipairs(getconnections(k[B]))do if pcall(function()l:Fire()end)or pcall(l.Function)then P=P+(1)end
end end)end return P>0,"("..(P.." connections)")elseif P=="firesignal"then if
type(firesignal)~="function"then return false,"firesignal missing"end for P,l in ipairs(m)do
pcall(firesignal,k[l])end return true,""end local l,B=pcall(function()local
l=game:GetService("VirtualInputManager")local B,U=H(k)if P=="touch"then
l:SendTouchEvent(1,0,B,U)task.wait(.1)l:SendTouchEvent(1,2,B,U)else
l:SendMouseButtonEvent(B,U,0,true,game,0)task.wait(.1)l:SendMouseButtonEvent(B,U,0,false,game,0)end
end)return l,l and""or tostring(B)end function U.teleportTo(P,k)local B=l.Spots[k]if not B then
error("Interaction: spot is not in the allowlist: "..tostring(k),2)end local U=
(game:GetService("Players")).LocalPlayer local Z=U.Character local m=Z and
Z:FindFirstChild("HumanoidRootPart")if not m then return false,"no character"end P._sent=P._sent+
(1)P._state:set("farm.actionsSent",P._sent,"Interaction")local H=0 while m.Anchored and H<10 do
task.wait(.5)H=H+(.5)end local Q=true local function A()local k local P=pcall(function()local
P=RaycastParams.new()P.FilterType=Enum.RaycastFilterType.Exclude P.FilterDescendantsInstances=
{Z}local l=workspace:Raycast(Vector3.new(B.x,B.y+60,B.z),Vector3.new(0,-200,0),P)k=l and
l.Position.Y end)Q=P return k end local
f=pcall(function()U:RequestStreamAroundAsync(Vector3.new(B.x,B.y,B.z),15)end)P._logger:debug("Actio
n","Stream around "..(k..(": "..((f and"requested"or"not available")))))local Y=A()for l=1,3,1 do
local U,H=pcall(function()Z:PivotTo(CFrame.new(B.x,Y and(Y+3)or(B.y+2),B.z))end)if not U then
return false,tostring(H)end task.wait(2)local f=m.Position if math.abs(f.X-B.x)<25 and
math.abs(f.Z-B.z)<25 then if not Y and Q then local l=0 while not Y and l<20 do task.wait(1)l=l+
(1)Y=A()end if not Y then return false,"the map at "..(k.." did not load within 20 s")end
P._logger:debug("Action",string.format("Map at %s loaded after %d s: standing on
it",k,l))pcall(function()Z:PivotTo(CFrame.new(B.x,Y+3,B.z))end)elseif Y then
P._logger:debug("Action",string.format("Ground at %s: y=%.1f (recorded %.1f)",k,Y,B.y))end return
true end P._logger:debug("Action",string.format("Teleport to %s undone (now at %.0f, %.0f), try
%d",k,f.X,f.Z,l))end return false,"the game moved the character back"end function
U.teleportNearPart(l,k,P)local B=(game:GetService("Players")).LocalPlayer local U=B and B.Character
local Z=U and U:FindFirstChild("HumanoidRootPart")if not((Z and(k and k.Parent)))then return
false,"no character / part"end local m=0 while Z.Anchored and m<10 do task.wait(.5)m=m+(.5)end
local H=((Z.Position-k.Position))*Vector3.new(1,0,1)local Q=H.Magnitude>1 and H.Unit or
Vector3.new(0,0,1)local A=(k.Position+Q*((P or 6)))+Vector3.new(0,3,0)l._sent=l._sent+
(1)l._state:set("farm.actionsSent",l._sent,"Interaction")local
f,Y=pcall(function()U:PivotTo(CFrame.lookAt(A,Vector3.new(k.Position.X,A.Y,k.Position.Z)))end)if
not f then return false,tostring(Y)end task.wait(1)return((Z.Position-k.Position)).Magnitude<((P or
6))+15,"moved back by the game"end function U.teleportToJoinZone(k)local P=l.Event local function
B(k)local P=workspace for k,l in ipairs(k)do P=P and P:FindFirstChild(l)end return P end local
U=B(P.JoinZoneTeleportPath)local Z=(game:GetService("Players")).LocalPlayer.Character local m=Z and
Z:FindFirstChild("HumanoidRootPart")if not U or not U:IsA("BasePart")or not m then return false,not
U and"join circle spot not found"or"no character"end k._sent=k._sent+
(1)k._state:set("farm.actionsSent",k._sent,"Interaction")local H,Q=pcall(function()local
k=U.Position Z:PivotTo(CFrame.new(k.X,k.Y+1.5,k.Z))end)if not H then return false,tostring(Q)end
local A=m.Position local f,Y=A.X-U.Position.X,A.Z-U.Position.Z return math.sqrt(f*f+Y*Y)
<=P.JoinZoneRadius,"not in the circle after the teleport"end function
U.teleportToHauntletJoinZone(k)local l=game:GetService("Players")local B=l.LocalPlayer local U=B
and B.Character local Z=U and U:FindFirstChild("HumanoidRootPart")if not Z then return
false,"character root not found"end local m=P.now()+10 local H repeat local
k=workspace:FindFirstChild("Interiors")local l=k and k:FindFirstChild("HauntedHotel")local B=l and
l:FindFirstChild("HauntletMinigameJoinZone")if B then local k=nil if not B:IsA("BasePart")then
k=B:FindFirstChild("Ring",true)end if k then if k:IsA("BasePart")then H=k else
H=k:FindFirstChild("Part")if not((H and H:IsA("BasePart")))then
H=k:FindFirstChildWhichIsA("BasePart",true)end end end if not H then if B:IsA("BasePart")then H=B

else H=B:FindFirstChildWhichIsA("BasePart",true)end end end if not H then task.wait(.25)end until H
or P.now()>=m if not H then return false,"Hauntlet join zone not found"end local
Q=H.Position+Vector3.new(0,((H.Size and H.Size.Y or 2))*.5+2.5,0)local
A,f=pcall(function()U:PivotTo(CFrame.new(Q)*CFrame.Angles(0,math.rad(Z.Orientation.Y),0))end)if not
A then return false,tostring(f)end k._sent=k._sent+
(1)k._state:set("farm.actionsSent",k._sent,"Interaction")task.wait(.6)local Y=Z.Position local
n,L=Y.X-H.Position.X,Y.Z-H.Position.Z local b=math.sqrt(n*n+L*L)if b>18 then return false,"not in
the join circle after teleport (dist "..(string.format("%.1f",b)..")")end return
true,H:GetFullName()end local function Q(k)if k:IsA("BasePart")then return k end local
P=k:FindFirstChild("Part")if P and P:IsA("BasePart")then return P end return
k:FindFirstChildWhichIsA("BasePart",true)end local A A=function(k)if k:IsA("BasePart")then return
k.Position end local P,l=nil,0 for k,B in ipairs(k:GetDescendants())do if B:IsA("BasePart")then P=P
and(P+B.Position)or B.Position l=l+(1)end end return l>0 and P/l or nil end function
U.hauntletCircleFor(k,P,l)l=l or{}if k.Name=="Elevators"then local B={}for k,P in
ipairs(k:GetChildren())do local U=P:FindFirstChild("JoinCircle",true)if U and(U:IsA("BasePart")and
not l[U])then table.insert(B,{node=P,part=U})end end for k,l in ipairs(B)do if
l.node.Name==tostring(P)then return l.part,"elevator \'"..(P.."\'"),true end end local U=k.Parent
and k.Parent:FindFirstChild("AreaDisplays")local Z=U and U:FindFirstChild(tostring(P))local m=Z and
A(Z)if m and#B>0 then table.sort(B,function(k,P)return((k.part.Positionm)).Magnitude<((P.part.Position-m)).Magnitude end)return B[1].part,"elevator nearest
AreaDisplays."..P,true end if B[P]then return B[P].part,"GUESS elevator "..P,false end return
nil,"no elevator for door "..P end local B=k:FindFirstChild(tostring(P))local U=B and Q(B)if U and
not l[U]then return U,"circle \'"..(P.."\'"),true end local Z={}for k,P in
ipairs(k:GetChildren())do local B=Q(P)if B and not l[B]then table.insert(Z,B)end end if#Z==0 then
return nil,"no circle part"end local m=k.Parent for k,l in
ipairs({"DoorPositions","Doors";"DoorCounters"})do local B=m and m:FindFirstChild(l)local U=B and
B:FindFirstChild(tostring(P))local H=U and A(U)if H then local k,B=nil,math.huge for P,l in
ipairs(Z)do local U=((l.Position-H)).Magnitude if U<B then k,B=l,U end end return
k,string.format("circle nearest %s.%d",l,P),true end end return Z[math.clamp(P,1,#Z)],"GUESS (no
named circle or door marker)",false end local f=setmetatable({},{__mode="k"})local Y=0 function
U.hauntletCircleId(k)if not f[k]then Y=Y+(1)f[k]=Y end return f[k]end local n=setmetatable({},
{__mode="k"})local L=setmetatable({},{__mode="k"})local b=0 local M=setmetatable({},
{__mode="k"})local function O(k)return k.Name=="DoorJoinCircles"or k.Name=="Elevators"end
U.hauntletIsCircleGroup=O function U.watchHauntletInterior(k)if not k or M[k]then return end local
P=pcall(function()k.DescendantAdded:Connect(function(k)if O(k)then b=b+(1)n[k],L[k]=b,os.clock()end
end)end)M[k]=P or nil end local function C(k)local P=workspace:FindFirstChild("Interiors")if not P
then return nil end local B=l.Event.HauntletInteriorPrefix local U=type(k)=="string"and
P:FindFirstChild(k)or nil if not U then for k,P in ipairs(P:GetChildren())do if
string.sub(P.Name,1,#B)==B then return P end end end return U end function
U.watchHauntlet(P,k)local l=C(k)U.watchHauntletInterior(l)return l~=nil end local function
G(k,P)local l=k and k:FindFirstChild("AttachmentPoints")local B=l and l:FindFirstChild(P)if not B
and(l and((P=="Exit"or P=="Entrance")))then for k,l in ipairs(l:GetChildren())do if
l:IsA("Attachment")and string.sub(l.Name,1,#P)==P then B=l break end end end return B
and(B:IsA("Attachment")and B.WorldPosition)or nil end U.hauntletAttachmentPoint=G
U.hauntletCenter=function(k)return A(k)end function U.hauntletCircles(Q,k,P,B,Z,m,H)local
f=Q:_myRoot()local Y=workspace:FindFirstChild("Interiors")if not((f and Y))then return nil,"no
character / Interiors"end local b=l.Event.HauntletInteriorPrefix local M=type(k)=="string"and
Y:FindFirstChild(k)or nil if not M then for k,P in ipairs(Y:GetChildren())do if
string.sub(P.Name,1,#b)==b then M=P break end end end if not M then return nil,"no "..(b.."
interior")end U.watchHauntletInterior(M)local O={}local C=P and(P.__elevators
and"Elevators")or"DoorJoinCircles"for k,P in ipairs(M:GetDescendants())do if P.Name==C
and#P:GetChildren()>0 then local k=A(P)if k then table.insert(O,{node=P;dist=((kf.Position)).Magnitude;added=n[P]or 0,seen=L[P]})end end end table.sort(O,function(k,P)if
k.added~=P.added then return k.added>P.added end return k.dist<P.dist end)P=P or{}local w=B
and(B.from and(B.from.Parent and G(B.from.Parent,B.exit or"Exit")))if w then local
k,l=nil,math.huge for U,Z in ipairs(O)do local m=Z.node~=B.from and(not P[Z.node]and
G(Z.node.Parent,"Entrance"))if m and((m-w)).Magnitude<l then k,l=Z,((m-w)).Magnitude end end if k
and l<12 then return k.node,k.dist,#O,k.seen,"the room after the last one"end end if Z and not((P
and P.__elevators))then m=m or{}local k=0 for P,l in ipairs(O)do l.fromBase=((A(l.node)Z)).Magnitude if m[l.node]then k=math.max(k,l.fromBase)end end local function l(k)return H~=nil
and(H.base~=nil and((A(k.node)-H.base)).Magnitude<((tonumber(H.limit)or 0))-5)end local B for U,Z
in ipairs(O)do if not P[Z.node]and(Z.fromBase>k+5 and(not l(Z)and((not B or
Z.fromBase<B.fromBase))))then B=Z end end if B then return
B.node,B.dist,#O,B.seen,string.format("next room forward (%d studs from the
start)",math.floor(B.fromBase))end return nil,"the next room is not loaded yet"end for k,l in
ipairs(O)do if not P[l.node]then return l.node,l.dist,#O,l.seen end end if O[1]and next(m
or{})==nil then return O[1].node,O[1].dist,#O,O[1].seen end return nil,"no DoorJoinCircles near
(interior "..(M.Name..")")end function U.hauntletNextGroup(B,k,P,l)local U=C(k)local Z=U and
U:FindFirstChild("Rooms")local m=P and P.Parent local H=m and G(m,l or"Exit")if not((Z and H))then
return nil,"no chain start ("..(tostring(l)..")")end local Q={[m]=true}for k=1,4,1 do local
P,l=nil,12 for k,B in ipairs(Z:GetChildren())do if not Q[B]then local k=G(B,"Entrance")if k and((kH)).Magnitude<l then P,l=B,((k-H)).Magnitude end end end if not P then return nil,"the next room is
not loaded yet"end Q[P]=true for k,l in ipairs({"DoorJoinCircles","Elevators"})do local
B=P:FindFirstChild(l)if B and#B:GetChildren()>0 then return B end end H=G(P,"Exit")if not H then

return nil,"a room without circles or exit"end end return nil,"no room with circles along the
chain"end function U._myRoot(k)local P=(game:GetService("Players")).LocalPlayer local l=P and
P.Character return l and l:FindFirstChild("HumanoidRootPart"),l,P end function
U.teleportToHauntletDoor(B,k,P,l)l=l or{}if type(P)~="number"or P<1 or P>4 then return false,"door
index out of range: "..tostring(P)end local Z,m,H=B:_myRoot()if not Z then return false,"no
character"end local Q,A,f,Y,n,L,b,M if l.group and l.group.Parent then Q=l.group
A,f,Y=U.hauntletCircleFor(Q,P,l.bad)if A then f=string.format("%s of the room on the chain (%d
studs away)",tostring(f),math.floor(((A.Position-Z.Position)).Magnitude))end end for m=1,(A and 0
or 6),1 do local O={}for k,P in pairs(l.avoid or{})do O[k]=P end for k,P in pairs(l.visited or{})do
O[k]=P end for k,P in pairs(l.passed or{})do O[k]=P end O.__elevators=l.nexus or nil
Q,n,L,b,M=B:hauntletCircles(k,O,l.link,l.base,l.visited,l.behind)if Q then
A,f,Y=U.hauntletCircleFor(Q,P,l.bad)if A then f=string.format("%s of group #%d (%d studs away, %s,
%d group%s in the run)",tostring(f),U.hauntletCircleId(Q),math.floor(tonumber(n)or 0),M or(b and
string.format("added %.0f s ago",os.clock()-b)or"nearest"),L or 1,((L or 1))==1 and""or"s")break
end end pcall(function()H:RequestStreamAroundAsync(Z.Position,2)end)task.wait(l.base and.4 or 1)end
if not A then return false,"door "..(P..(" circle not found ("..(tostring(f or(type(n)=="string"and
n)or"no circles near me")..")")))end local O=0 while Z.Anchored and O<8 do task.wait(.5)O=O+(.5)end
task.spawn(pcall,function()H:RequestStreamAroundAsync(A.Position,2)end)B._sent=B._sent+
(1)B._state:set("farm.actionsSent",B._sent,"Interaction")local
C=A.Position+Vector3.new(0,A.Size.Y*.5+3,0)local G=l.method or"tween"local function w()local
k=math.clamp(tonumber(l.seconds)or(((Z.Position-C)).Magnitude/50),.1,5)local P=
(game:GetService("TweenService")):Create(Z,TweenInfo.new(k,Enum.EasingStyle.Linear),
{CFrame=CFrame.new(C)*((Z.CFrame-Z.CFrame.Position))})P:Play()local B=(os.clock()+k)+1 while
P.PlaybackState==Enum.PlaybackState.Playing and os.clock()<B do task.wait(.05)end end local
V,t=pcall(function()if G=="tp"then m:PivotTo(CFrame.new(C))elseif G=="walk"then local
k=m:FindFirstChildOfClass("Humanoid")k:MoveTo(Vector3.new(C.X,Z.Position.Y,C.Z))local
P=os.clock()+math.clamp(((Z.Position-C)).Magnitude/12,2,12)while os.clock()<P do
if(Vector3.new(Z.Position.X-C.X,0,Z.Position.Z-C.Z)).Magnitude<3 then return end task.wait(.1)end
w()else w()end end)if not V then return false,tostring(t)end
B._logger:debug("Action",string.format("Hauntlet: door %d -> %s (%s,
%s)",P,A:GetFullName(),tostring(f),G))return true,f,A,Q,Y end function U.keepNear(P,k)local B=
{corrections=0}local U=true local Z=game:GetService("Players")local function m()local
k=Z.LocalPlayer.Character return k and k:FindFirstChild("HumanoidRootPart"),k end local H=m()local
Q=H and H.Position or nil local A=nil local f=false local function Y(k)local P,l=m()if not P or f
then return end local U=P.Position local Z,H,Q=U.X-k.X,U.Y-k.Y,U.Z-k.Z if(Z*Z+H*H)+Q*Q>62500 then
f=true return end pcall(function()P.AssemblyLinearVelocity=Vector3.new(0,0,0)end)local A=P.Position
local Y,n,L=A.X-k.X,A.Y-k.Y,A.Z-k.Z if(Y*Y+n*n)+L*L<=1 then return end if
pcall(function()l:PivotTo(CFrame.new(k.X,k.Y,k.Z))end)then B.corrections=B.corrections+(1)end end
local function n()local P,B=k()if P==false then f=true return end if P~=nil
and(type(P.X)=="number"and(type(P.Y)=="number"and type(P.Z)=="number"))then if B=="below"then
A=Vector3.new(P.X,P.Y-l.Event.HoldBelowStuds,P.Z)else local k=m()local l=k and k.Position or P
local U=tonumber(B)or 10 local Z,H=l.X-P.X,l.Z-P.Z local f=math.sqrt(Z*Z+H*H)local Y=f>.1 and P.X+
(Z/f)*U or P.X+U local n=f>.1 and P.Z+(H/f)*U or P.Z A=Vector3.new(Y,Q and Q.Y or l.Y,n)end end if
A then Y(A)end end local L local b=pcall(function()L=
(game:GetService("RunService")).Heartbeat:Connect(function()if U then n()end end)end)if not b or
not L then task.spawn(function()while U do n()task.wait(.05)end end)end local function M(k)if not U
then return end U=false if L then L:Disconnect()L=nil end local P,l=m()local B=false if P and(A and
not f)then local k=P.Position local l,U,Z=k.X-A.X,k.Y-A.Y,k.Z-A.Z B=(l*l+U*U)+Z*Z<=900 end if
k~=false and(B and Q)then
pcall(function()P.AssemblyLinearVelocity=Vector3.new(0,0,0)l:PivotTo(CFrame.new(Q.X,Q.Y+2,Q.Z))end)
end end return M,B,n end function U.releaseAnchor(B,k,P,l)if not k or not k.Anchored then return
true end local U pcall(function()local
l=RaycastParams.new()l.FilterType=Enum.RaycastFilterType.Exclude l.FilterDescendantsInstances=
{P}local B=workspace:Raycast(k.Position,Vector3.new(0,-25,0),l)U=B and B.Position end)if not U then
B._logger:debug("Action","Root anchored, no ground under it yet: leaving it")return false end local
Z=pcall(function()k.Anchored=false end)B._logger:info("Action","My character was left anchored by
the game ("..(tostring(l)..("): released it"..((Z and""or" (failed)")))))return Z and not
k.Anchored end function U.walkAround(B,k,P,l)local U=
(game:GetService("Players")).LocalPlayer.Character local Z=U and
U:FindFirstChildOfClass("Humanoid")local m=U and U:FindFirstChild("HumanoidRootPart")if not Z or
not m then return false end B._logger:debug("Action","Walking long diagonal legs for up to "..(k.."
s"))if m.Anchored then local k=0 while m.Anchored and k<3 do task.wait(.5)k=k+(.5)end
B:releaseAnchor(m,U,"before walking")end local H=m.Position local Q,A=0,-1 pcall(function()local
k=m.CFrame.LookVector local P=math.sqrt(k.X*k.X+k.Z*k.Z)if P>.1 then Q,A=k.X/P,k.Z/P end end)local
f,Y=-A,Q local n=30 local L={Vector3.new(H.X+((Q-f))*n,H.Y,H.Z+((A-Y))*n);Vector3.new(H.X+
((Q+f))*n,H.Y,H.Z+((A+Y))*n),Vector3.new(H.X,H.Y,H.Z)}local b,M=0,0 while b<k do if P()then return
true end M=M%#L+1 local H=L[M]local Q,A,f=0,0,m.Position while Q<5 and b<k do
Z:MoveTo(H)task.wait(.5)Q=Q+(.5)b=b+(.5)if l then l()end if P()then return true end local
k=m.Position if math.sqrt(((k.X-H.X))^2+((k.Z-H.Z))^2)<4 then break end if math.sqrt(((k.X-f.X))^2+
((k.Z-f.Z))^2)<.5 then A=A+(.5)if A==1 then local P=
{}pcall(function()table.insert(P,"anchored="..tostring(m.Anchored))table.insert(P,"sit="..tostring(
Z.Sit))table.insert(P,"platformStand="..tostring(Z.PlatformStand))table.insert(P,"walkSpeed="..tost
ring(Z.WalkSpeed))table.insert(P,"state="..tostring(Z:GetState()))end)B.walkDiag=table.concat(P,"
")B:releaseAnchor(m,U,"while walking")pcall(function()if Z.Sit then Z.Sit=false end if

Z.PlatformStand then Z.PlatformStand=false end local P,l=H.X-k.X,H.Z-k.Z local
B=math.sqrt(P*P+l*l)if B>.1 then Z:Move(Vector3.new(P/B,0,l/B),false)end end)elseif A>=2.5 then
break end else A=0 B.walkDiag=nil end f=k end end return P()end function U.moveTo(P,k)local
B=l.Spots[k]if not B then error("Interaction: spot is not in the allowlist: "..tostring(k),2)end
local U=(game:GetService("Players")).LocalPlayer.Character local Z=U and
U:FindFirstChildOfClass("Humanoid")local m=U and U:FindFirstChild("HumanoidRootPart")if not Z or
not m then return false,"no character"end P._sent=P._sent+
(1)P._state:set("farm.actionsSent",P._sent,"Interaction")local H=0 while m.Anchored and H<10 do
task.wait(.5)H=H+(.5)end local Q=Vector3.new(B.x,B.y,B.z)local function A()local k=m.Position
return math.sqrt(((k.X-B.x))^2+((k.Z-B.z))^2)end local function f(k,P)Z:MoveTo(k)local l=0 while
l<P do task.wait(.25)l=l+(.25)local P=m.Position if math.sqrt(((P.X-k.X))^2+((P.Z-k.Z))^2)<4 then
return true end end return false end P._logger:debug("Action",string.format("Walking to %s (%.0f,
%.0f), %.0f studs",k,B.x,B.z,A()))local Y pcall(function()local k=
(game:GetService("PathfindingService")):CreatePath({AgentCanJump=true})k:ComputeAsync(m.Position,Q)
if k.Status==Enum.PathStatus.Success then Y=k:GetWaypoints()end end)local n=os.clock()if Y then for
k,P in ipairs(Y)do if P.Action==Enum.PathWaypointAction.Jump then Z.Jump=true end f(P.Position,4)if
os.clock()-n>90 then break end end else P._logger:debug("Action","No path found: walking
straight")for k=1,12,1 do if f(Q,8)or A()<10 then break end end end if A()<15 then return true end
return false,string.format("could not walk there (still %.0f studs away)",A())end local function
w(...)local k={}for P=1,select("#",...),1 do local l=select(P,...)if typeof(l)=="Instance"then
table.insert(k,"<"..(l.Name..">"))elseif type(l)=="table"then table.insert(k,"{...}")else
table.insert(k,tostring(l))end end return table.concat(k,", ")end function U.send(U,k,...)local
m=l.Actions[k]if not m then error("Interaction: action is not in the allowlist:
"..tostring(k),2)end if m.emptyOnly then local P=...if select("#",...)~=1 or type(P)~="table"or
next(P)~=nil then error("Interaction: "..(k.." may only be sent with an empty table"),2)end end if
m.allowedFirstArg then local P=...if not m.allowedFirstArg[P]then error("Interaction: "..(k..(" may
not be sent with "..tostring(P))),2)end end if m.leaveOnly then local P,l=...if select("#",...)~=2
or type(P)~="string"or string.sub(P,1,15)~="ghost_clusters:"or l~=false then error("Interaction:
"..(k.." may only be sent as (\"ghost_clusters::<id>\", false)"),2)end end if m.allowedMessages
then local P,l=...if not m.allowedMessages[l]then error("Interaction: "..(k..(" may not send
message "..tostring(l))),2)end end if m.recordedArgs then local
P=type(l.Event.SkelicornArgs)=="table"and l.Event.SkelicornArgs[m.recordedArgs]if
type(P)~="table"then error("Interaction: "..(k.." has no recorded arguments yet"),2)end local
function B(k,P,l)if k=="$LEVER"then return type(P)=="string"and P~=""end if
type(k)=="table"and(type(P)=="table"and l<3)then for k,U in pairs(k)do if not B(U,P[k],l+1)then
return false end end for P in pairs(P)do if k[P]==nil then return false end end return true end
return k==P end local U=select("#",...)local Z=U==#P for k=1,U,1 do if not B(P[k],
(select(k,...)),0)then Z=false end end if not Z then error("Interaction: "..(k.." may only be sent
with the recorded arguments"),2)end end if m.noArgs and select("#",...)~=0 then error("Interaction:
"..(k.." is sent without arguments"),2)end if m.joinPrefix then local P,l=...local B=m.joinPrefix
if type(P)~="string"or not((P==B or string.sub(P,1,#B+2)==B.."::"))or l~=true then
error("Interaction: "..(k..(" may only be sent as (\""..(B.."[::<id>]\", true)"))),2)end end if
m.hauntletMessage then local P,B,U=...local Z=type(P)=="string"and
string.sub(P,1,10)=="hauntlet::"local m=B=="try_pick_door"and((U==1 or U==2 or U==3))local
H=B=="try_use_item"and(type(U)=="string"and l.Event.HauntletItems[U]==true)if select("#",...)~=3 or
not Z or not((m or H))then error("Interaction: "..(k..(" may not send "..(tostring(B)..("
"..tostring(U))))),2)end end local H=m.folder and l.Remotes[m.folder]or l.Remotes.Folder local
Q=B:FindFirstChild(H)local A=Q and Q:FindFirstChild(m.remote)if not A then
U._logger:error("Action","Remote not found: "..m.remote)return false,"remote not found"end
U._sent=U._sent+
(1)U._state:set("farm.actionsSent",U._sent,"Interaction")U._logger:debug("Action","Send "..
(m.remote..("("..(w(...)..")"))))if A:IsA("RemoteFunction")then local k,l,B=false,false,nil local
H=table.pack(...)task.spawn(function()l,B=pcall(function()return
A:InvokeServer(table.unpack(H,1,H.n))end)k=true end)local Q=P.now()+((m.answersWhenDone and 2 or
Z))while not k and P.now()<Q do task.wait(.1)end if not k and m.answersWhenDone then return
true,"pending"end if not k then U._logger:warn("Action",m.remote..(" did not answer within "..(Z.."
s")))return false,"no answer from server"end if not l then U._logger:warn("Action",m.remote..("
failed: "..tostring(B)))return false,tostring(B)end return true,B end if A:IsA("RemoteEvent")then
local k,P=pcall(function(...)A:FireServer(...)end,...)if not k then
U._logger:warn("Action",m.remote..(" failed: "..tostring(P)))return false,tostring(P)end return
true end U._logger:error("Action",m.remote..(" is a "..(A.ClassName..", not a remote")))return
false,"not a remote"end return U end P["Game/Travel"]=function(...)local k=...local
P=k("Core/Util")local l=k("Game/GameConstants")local B=game:GetService("Players")local U=
{}U.__index=U local Z=1 local m=12 function U.new(k,P,l,B)return
setmetatable({_logger=k,_state=P,_interaction=l;_farmConfig=B},U)end function U.canGoTo(P,k)return
l.Travel[k]~=nil end function U.isAt(P,k)local l=P._state:get("player.interior")return
type(l)=="string"and string.sub(l,1,#k)==k end function U.exitToMainMap(k)local
B=k._state:get("player.interior")if type(B)~="string"or not l.Travel[B]or B=="MainMap"then return
false,"not in a building"end k._logger:info("Travel","Leaving "..(B.." through its door"))local
U,H=k._interaction:send("DoorEnter","MainMap",B.."/MainDoor",{start_transparency=1})if not U then
return false,"door enter failed: "..tostring(H)end
task.wait(Z)U,H=k._interaction:send("SetLocation","MainMap",nil,"Default")if not U then return
false,"set location failed: "..tostring(H)end local Q=P.now()+m while P.now()<Q do if
k:isAt("MainMap")then k._logger:info("Travel","Arrived: MainMap (from "..(B..")"))return true end

task.wait(.25)end return false,"still in "..tostring(k._state:get("player.interior"))end function
U.exitHouse(k)local U=B.LocalPlayer local Z=workspace:FindFirstChild("HouseInteriors")Z=Z and
Z:FindFirstChild("blueprint")local H=Z and Z:FindFirstChild(U.Name)local Q=H and
H:FindFirstChild("Doors")local A=Q and Q:FindFirstChild("MainDoor")if not A then return
false,"house door not found (workspace.HouseInteriors.blueprint."..(U.Name..".Doors.MainDoor)")end
local f pcall(function()local k=U.Character and U.Character:FindFirstChild("HumanoidRootPart")local
P=workspace.CurrentCamera if k and P then f=k.CFrame:ToObjectSpace(P.CFrame)end end)if not f then
local k=l.HouseExitCameraOffset
pcall(function()f=CFrame.new(k.x,k.y,k.z)*CFrame.Angles(k.rx,k.ry,k.rz)end)end
k._logger:info("Travel","Leaving the house through its door")local
Y,n=k._interaction:send("DoorEnter",l.HouseExitDestination,"MainDoor",
{skip_set_player_collisions=true;skip_send_passive_door_request=true,house_owner=U;camera_rootpart_
cframe_offset=f;exiting_door=A})if not Y then return false,"door enter failed: "..tostring(n)end
k._interaction:send("MarkEnteredDoorTime")k._interaction:send("PushFurnitureChanges",
{})k._interaction:send("ExitFurnitureUseStates")k._interaction:send("UnsubscribeFromHouse",U)local
L=P.now()+m while P.now()<L do local P=k._state:get("player.interior")if P~=nil and
P~=l.HouseInteriorName then k._logger:info("Travel","Out of the house: "..tostring(P))return true
end task.wait(.25)end return false,"still in "..(tostring(k._state:get("player.interior")).." after
the house door")end local function H()local k=B.LocalPlayer.Character local P=k and
k:FindFirstChild("HumanoidRootPart")return P and P.Position end function
U._waitPlacedOnMainMap(B,k)local U=P.now()+k while P.now()<U do local k=H()if not k or
l.isOnMainMapArea(k)then return true end task.wait(.25)end return false end function
U._checkPlacedOnMainMap(l,k,P)if l:_waitPlacedOnMainMap(8)then return true end local
B=H()l._logger:warn("Travel",string.format("Data says MainMap but my character is still at (%.0f,
%.0f) (an interior\'s area): asking for MainMap once
more",B.X,B.Z))l._interaction:send("SetLocation","MainMap",nil,k.spawn)if
l:_waitPlacedOnMainMap(8)then l._logger:info("Travel","Placed on MainMap after asking again")return
true end B=H()return false,string.format("not placed on MainMap (character at %.0f,
%.0f)",B.X,B.Z)end local Q={"ClientModules","Core","InteriorsM","InteriorsM"}function
U._interiorsModule(k)if k._interiorsM~=nil then return k._interiorsM or nil end local
P=game:GetService("ReplicatedStorage")for k,l in ipairs(Q)do P=P and P:FindFirstChild(l)end local
l,B=false,nil if P then l,B=pcall(require,P)end if l and(type(B)=="table"and
type(B.enter)=="function")then k._interiorsM=B k._logger:info("Travel","Using the game\'s own
travel (InteriorsM.enter)")return B end k._interiorsM=false k._logger:warn("Travel","The game\'s
travel module was not found: using the remote route")return nil end local function
A(k)return(string.gsub(k.door,"!","/"))end function U._waitArrival(U,k,l)local Z=P.now()+l while
P.now()<Z do if U:isAt(k)then local k=B.LocalPlayer.Character local l=k and
k:FindFirstChild("HumanoidRootPart")local U=P.now()+5 while l and(l.Anchored and P.now()<U)do
task.wait(.25)end return true end task.wait(.25)end return false end function
U._gameTravel(l,k,P)local U=B.LocalPlayer local Z=l._state:get("player.interior")if P.ownHouse and
l._farmConfig.HomeByRespawn~=false then l._logger:info("Travel","Going home by respawn (now in "..
(tostring(Z)..")"))local P=l._interaction:send("Respawn")if P and l:_waitArrival(k,m+5)then
l._logger:info("Travel","Arrived: "..(tostring(l._state:get("player.interior")).."
(respawn)"))return true end l._logger:info("Travel","Respawn did not bring me home: using the
game\'s door instead")if l:isAt(k)then return true end end local H=l:_interiorsModule()if not H
then return false,"no InteriorsM"end local Q={}if P.ownHouse then Q.house_owner=U end local
f=A(P)l._logger:info("Travel","Going to "..(k..(" (now in "..(tostring(Z)..(", game travel via "..
(f..")"))))))task.spawn(function()local P,B=pcall(H.enter,k,f,Q)if not P then
l._logger:warn("Travel","InteriorsM.enter failed: "..tostring(B))end end)if not
l:_waitArrival(k,m+5)then return false,"still in "..tostring(l._state:get("player.interior"))end
l._logger:info("Travel","Arrived: "..tostring(l._state:get("player.interior")))if k=="MainMap"then
return l:_checkPlacedOnMainMap(P,U)end return true end function U.visitHouse(P,k)local
l=P:_interiorsModule()if not l then return false,"no InteriorsM"end
P._logger:info("Travel","Visiting the house of "..(tostring(k.Name).."
(quest)"))task.spawn(function()local B,U=pcall(l.enter,"housing","MainDoor",{house_owner=k})if not
B then P._logger:warn("Travel","InteriorsM.enter (house visit) failed: "..tostring(U))end
end)return true end function U.goTo(U,k)local H=l.Travel[k]if not H then return false,"no known
route to "..tostring(k)end if U:isAt(k)then U._logger:debug("Travel","Already at "..k)return true
end if U._farmConfig and(U._farmConfig.HouseDoorExit and(not H.ownHouse and
U:isAt(l.HouseInteriorName)))then local P,l=U:exitHouse()if not P then
U._logger:warn("Travel","House door exit did not work ("..(tostring(l).."): going directly"))elseif
U:isAt(k)then return true end end if U._farmConfig and U._farmConfig.GameTravel~=false then local
P,l=U:_gameTravel(k,H)if P then return true end U._logger:info("Travel","Game travel to "..(k..("
did not work ("..(tostring(l).."): using the remote route"))))if U:isAt(k)then return true end end
if k~="MainMap"and U:isAt("TheCrypt")then local l=U:_interiorsModule()if l then
U._logger:info("Travel","Leaving the Crypt first (its door to the main
map)")task.spawn(pcall,l.enter,"MainMap","TheCrypt/MainDoor",{})local B=P.now()+15 while P.now()<B
and not U:isAt("MainMap")do task.wait(.25)end if U:isAt("MainMap")and U:_gameTravel(k,H)then return
true end end end local Q=U._state:get("player.interior")U._logger:info("Travel","Going to "..(k..("
(now in "..(tostring(Q)..")"))))local A=B.LocalPlayer local f={start_transparency=1}if H.ownHouse
then f.house_owner=A end local Y,n=U._interaction:send("DoorEnter",k,H.door,f)if not Y then return
false,"door enter failed: "..tostring(n)end if H.ownHouse then
U._interaction:send("SubscribeToHouse",A)end
task.wait(Z)Y,n=U._interaction:send("SetLocation",k,H.ownHouse and A or nil,H.spawn)if not Y then

return false,"set location failed: "..tostring(n)end local L=P.now()local b=L+m local M=false while
P.now()<b do local l=U._state:get("player.interior")if l~=nil and l~=Q then
U._logger:info("Travel","Arrived: "..tostring(l))if k=="MainMap"then return
U:_checkPlacedOnMainMap(H,A)end return true end if H.ownHouse and(not M and P.now()-L>6)then M=true
U._logger:info("Travel","House data did not arrive: subscribing
again")U._interaction:send("UnsubscribeFromHouse",A)U._interaction:send("SubscribeToHouse",A)end
task.wait(.25)end return false,"still in "..(tostring(U._state:get("player.interior"))..(" after
"..(m.." s")))end return U end P["Game/Furniture"]=function(...)local k=...local
P=k("Game/GameConstants")local l=game:GetService("Players")local B={}B.__index=B function
B.new(k,P)return setmetatable({_gameData=k,_state=P},B)end function B._keysOfKinds(l,k)local B=
{}for k,P in ipairs(k)do B[P]=true end local U=l._gameData:get(P.DataKeys.Interior)local Z={}if
type(U)~="table"or type(U.furniture)~="table"then return Z end for k,P in pairs(U.furniture)do if
type(P)=="table"and B[P.id]then table.insert(Z,{key=tostring(k);kind=P.id})end end
table.sort(Z,function(k,P)return k.key<P.key end)return Z end function B._findModel(B,k)local
U=workspace for k,P in ipairs(P.HouseFurnitureFolderPath)do U=U and U:FindFirstChild(P)end if not U
then return nil end local Z=l.LocalPlayer.Name.."/"local m="/"..k for l,B in
ipairs(U:GetChildren())do local U=B.Name if string.sub(U,1,#Z)==Z and string.sub(U,-(#m))==m then
for l,B in ipairs(B:GetChildren())do if B:IsA("Model")and
B:GetAttribute(P.FurnitureUniqueAttribute)==k then return B end end end end return nil end function
B.useCFrame(k)return k.CFrame*CFrame.new(0,k.Size.Y/2,0)end function B.findSpot(l,k)if
l._state:get("player.interior")~=P.HouseInteriorName then return nil,"not at home"end local
U=l:_keysOfKinds(k)if#U==0 then return nil,"no "..(table.concat(k,"/").." in your house")end for
k,U in ipairs(U)do local Z=l:_findModel(U.key)local m=P.UseBlockForFurniture[U.kind]local H=Z and
Z:FindFirstChild("UseBlocks")local Q=H and(m and H:FindFirstChild(m))if Q then
return{key=U.key,kind=U.kind,useName=m;cframe=B.useCFrame(Q)}end end return
nil,table.concat(k,"/").." model not loaded yet"end return B end P["Game/Tasks"]=function(...)local
k=...local P=k("Game/GameConstants")local l=k("Core/Util")local B local
U=game:GetService("Players")local Z={}local function m(k)if not k.gameData or not
k.gameData:isSitting()then return true end k.logger:info("Tasks","Your character is sitting:
getting up first")k.interaction:send("ExitSeatStates")if k.waitUntil(function()return not
k.gameData:isSitting()end,4)then return true end return false,"your character is still sitting
(ExitSeatStates had no effect)"end Z.standUp=m local function H(k,l)local
B=k.petLocator:getStreamingId(l)local U=k.gameData and k.gameData:get(P.DataKeys.Interior)if not B
or type(U)~="table"or type(U.furniture)~="table"then return true end local function Z()local
l=k.gameData:get(P.DataKeys.Interior)for k,P in
pairs(type(l)=="table"and(type(l.furniture)=="table"and l.furniture)or{})do if type(P)=="table"and
type(P.occupied)=="table"then for k,P in pairs(P.occupied)do if P==B then return true end end end
end return false end if not Z()then return true end k.logger:info("Tasks","Your pet is still on
furniture: getting it off first")k.interaction:send("ExitFurnitureUseStates",l)if
k.waitUntil(function()return not Z()end,4)then return true end return false,"pet is still on
furniture (ExitFurnitureUseStates had no effect)"end Z.petOffFurniture=H local function Q(k,l)local
B=k.gameData and k.gameData:get(P.DataKeys.Interior)local
U=type(B)=="table"and(type(B.furniture)=="table"and B.furniture[l])local Z={}if type(U)=="table"and
type(U.occupied)=="table"then for k,P in pairs(U.occupied)do table.insert(Z,tostring(P))end end
return Z end Z.pet_me={id="pet_me",handles=function(k)return
k=="pet_me"end;timeoutSeconds=40,run=function(k,P,l)local Z=P.petEntry if not Z then return
false,"pet_me is only for pets"end local m,Q=B(k,Z.petUnique)if not m then return false,"pet model:
"..tostring(Q)end local A,f=H(k,Z.petUnique)if not A then return false,f end local
Y,n=k.interaction:send("FocusPet",m)if not Y then return false,"focus failed: "..tostring(n)end
k.maid:Give(function()k.interaction:send("UnfocusPet",m)end)local function L()return
k.completedSince("pet_me","pet",Z.petUnique)end if k.waitUntil(L,3.3)then return true end
k.interaction:send("PetPerformance",m,{FocusPet=true,Petting=true})if k.waitUntil(L,3.5)then return
true end k.interaction:send("PetPerformance",m,{FocusPet=true;PettingHappy=true})if
k.waitUntil(L,1.2)then return true end k.interaction:send("PetPerformance",m,
{FocusPet=true})k.interaction:send("PetPetted",Z.petUnique,U.LocalPlayer)k.interaction:send("Progre
ssPetMe",Z.petUnique)if k.waitUntil(function()return
k.completedSince("pet_me","pet",Z.petUnique)end,6)then return true end return false,"no completion
after petting"end}local A=10 local f=20 local Y=6 local n=20 local function L(k,l)local
B=P.Spots[k]local Z=U.LocalPlayer.Character local m=Z and Z:FindFirstChild("HumanoidRootPart")if
not B or not m or not m.Position then return false end local H=m.Position return math.sqrt(((H.XB.x))^2+((H.Z-B.z))^2)<=l end Z._nearSpot=L local b=P.isOnMainMapArea Z._isOnMainMapArea=b local
function M(k,P)return k.waitUntil(function()local k=U.LocalPlayer.Character local P=k and
k:FindFirstChild("HumanoidRootPart")return P~=nil end,P)end local function O(k,P)if not P then
return false,"no pet known"end if not M(k,10)then return false,"no character"end task.wait(2)local
l,B=k.interaction:send("EquipItem",P,{equip_as_last=true})if not l then return false,"Equip failed:
"..tostring(B)end local function U()local l=k.gameData:equippedPetCount()return
k.gameData:isPetEquipped(P)and l>0 end if k.waitUntil(U,8)then task.wait(1)if U()then return true
end return false,"the pet was equipped, then gone again"end return false,"the pet did not appear as
equipped"end Z._equipPetAgain=O B=function(k,P)local l,B=k.petLocator:findModel(P)if l then return
l end if k.gameData and not k.gameData:isPetEquipped(P)then k.waitUntil(function()return
k.gameData:isPetEquipped(P)end,4)if not k.gameData:isPetEquipped(P)then k.logger:info("Tasks","Pet
not equipped after the trip: equipping it before using it")O(k,P)end end
k.waitUntil(function()l,B=k.petLocator:findModel(P)return l~=nil end,10)return l,B end local
function C(k,P)if not P.petEntry or not k.gameData then return false end local

l,B=k.gameData:equippedPetCount()return B and l==0 end Z.location=
{id="location";handles=function(k)return P.LocationForAilment[k]~=nil
end,timeoutSeconds=180;run=function(k,B,Z)local H=P.LocationForAilment[B.kind]local Q,M=m(k)if not
Q then return false,M end if not B.anyInProgress then local l,Z=k.travel:goTo(H)if not l then
return false,"travel: "..tostring(Z)end local m=P.SpotForAilment[B.kind]local Q=m
and(k.farmConfig.SpotTravel=="door"and P.SpotDoor[m])or nil local f=m and
k.farmConfig.SpotTravel=="teleport"if m then local function P()local P=k.currentGroup(B.kind)return
P==nil or P.anyInProgress end if k.waitUntil(P,Y)then k.logger:info("Tasks",B.kind.." started where
I am: not moving")f,Q=false,nil end end if f and L(m,n)then k.logger:info("Tasks","Already at the
"..(m.." spot: no teleport"))f,Q=false,nil end if f then task.wait(1)local
P,l=k.interaction:teleportTo(m)k.logger:info("Tasks","Teleport to "..(m..(": "..((P and"ok"or
tostring(l))))))if P then Q=nil if B.petEntry and(k.waitUntil(function()local
P=k.currentGroup(B.kind)return C(k,B)or(P~=nil and P.anyInProgress)end,8)and C(k,B))then
k.logger:info("Tasks","Pet unequipped after the teleport (map not loaded): equipping it and
teleporting
again")O(k,B.petEntry.petUnique)P,l=k.interaction:teleportTo(m)k.logger:info("Tasks","Teleport
again to "..(m..(": "..((P and"ok"or tostring(l))))))end end end if Q then local
P=k.travel:goTo(Q.place)if P then task.wait(1)local P,B=k.travel:exitToMainMap()if not P then
l,Z=k.travel:goTo(H)if not l then return false,"travel after "..(tostring(B)..(":
"..tostring(Z)))end end end local B=U.LocalPlayer.Character local m=B and
B:FindFirstChild("HumanoidRootPart")if m then local P=m.Position local l=math.sqrt(((P.XQ.exit.x))^2+((P.Z-Q.exit.z))^2)<60 k.logger:info("Tasks",string.format("After the %s door: at
(%.0f, %.0f), %s",Q.place,P.X,P.Z,l and"at the door"or"NOT at the door"))if not b(P)then
k.logger:warn("Tasks",string.format("After the %s door I am OUTSIDE MainMap (%.0f, %.0f): the game
did not place me (white-screen state)",Q.place,P.X,P.Z))return false,"the door exit left me outside
MainMap"end end end local function M()local P=k.currentGroup(B.kind)return P==nil or
P.anyInProgress end local G=P.InteriorTalkForAilment[B.kind]local w if G then w=k.waitUntil(M,4)if
not w then local l=k.gameData:get(P.DataKeys.Interior)local B for k,P in
pairs(type(l)=="table"and(type(l.furniture)=="table"and l.furniture)or{})do if type(P)=="table"and
P.id==G.furniture then B=k end end if B then k.logger:info("Tasks","Talking to the "..
(G.furniture..(" ("..
(B..")"))))k.interaction:send("ActivateInteriorFurniture",B,G.use,G.choice,U.LocalPlayer.Character)
else k.logger:warn("Tasks","No "..(G.furniture..(" in "..H)))end end end w=w or k.waitUntil(M,A)if
not w then return false,"arrived at "..(H.." but the need did not start")end end local G=0 local
function w()if not C(k,B)then return"no"end if G>=2 then return"fail"end G=G+
(1)k.logger:info("Tasks","Your pet was unequipped at "..(H..": equipping it again, then
waiting"))local P,l=O(k,B.petEntry.petUnique)if not P then k.logger:warn("Tasks","Equipping the pet
again failed: "..tostring(l))end return"again"end local V=0 local t=false local R=l.now()-1 local
q=k.currentGroup(B.kind)if k.setWaiting then k.setWaiting(true)end while true do if q==nil then
local P=w()if P=="fail"then return false,"the pet was unequipped (its need is hidden, not
completed)"elseif P=="no"then if k.kindCompletedSince and not k.kindCompletedSince(B.kind,R)then
k.waitUntil(function()return k.kindCompletedSince(B.kind,R)or k.currentGroup(B.kind)~=nil end,6)if
not k.kindCompletedSince(B.kind,R)then if k.currentGroup(B.kind)~=nil then
k.logger:info("Tasks",B.kind.." was removed and re-added (reset): still
waiting")q=k.currentGroup(B.kind)continue end return false,B.kind.." vanished without a completion
(expired?)"end end return true end q=k.currentGroup(B.kind)else local P=q.maxRate>0
and(1/q.maxRate)or 50 local U=(P+f)-V if U<=0 then return false,B.kind.." did not complete in
time"end k.logger:info("Tasks",string.format("Waiting at %s for %s (about %d
s)",H,B.kind,math.floor(P+.5)))local Z=l.now()local m=k.waitUntil(function()return
k.isKindGone(B.kind)end,U)V=V+(math.max(l.now()-Z,0))if not m then local P=k.currentGroup(B.kind)if
not t and(P and P.anyInProgress)then t=true local l=((P.maxRate>0 and(1/P.maxRate)or 50))+10
k.logger:info("Tasks",string.format("%s still in progress: waiting %d s
more",B.kind,math.floor(l)))if k.waitUntil(function()return k.isKindGone(B.kind)end,l)then q=nil
continue end end return false,B.kind.." did not complete in time"end q=nil end end end}local G=5
local w=10 Z.furniture={id="furniture";handles=function(k)return P.FurnitureForAilment[k]~=nil
end;timeoutSeconds=110,run=function(k,l)local Z=P.FurnitureForAilment[l.kind]local A,f=m(k)if not A
then return false,f end if not k.travel:isAt(P.HouseInteriorName)then local
l,B=k.travel:goTo(P.HouseInteriorName)if not l then return false,"going home: "..tostring(B)end end
local Y,n=nil,nil k.waitUntil(function()Y,n=k.furniture:findSpot(Z)return Y~=nil end,10)if not Y
then return false,tostring(n)end local L=table.clone(l.entries)table.sort(L,function(k,P)return
k.owner=="pet"and P.owner~="pet"end)local b if P.PetOnlyFurniture[Y.kind]then local l={}for k,B in
ipairs(Z)do if not P.PetOnlyFurniture[B]then table.insert(l,B)end end if#l>0 then
k.waitUntil(function()b=k.furniture:findSpot(l)return b~=nil end,10)end end local M=Y for Z,A in
ipairs(L)do local f=(A.owner=="baby"and b)or M local Y=A.owner=="baby"and"baby"or("pet
"..tostring(A.petKind or"?"))local n=k.findEntry(l.kind,A.owner,A.petUnique)if n then if not
n.inProgress then local Z if A.owner=="pet"then Z=B(k,A.petUnique)else Z=U.LocalPlayer.Character
end if not Z then return false,"no model to put on the "..(f.kind..(" ("..(Y..")")))end if
A.owner=="baby"and P.PetOnlyFurniture[f.kind]then return false,"the "..(f.kind..(" is only for pets
(baby "..(l.kind..")")))end if A.owner=="pet"then local P,l=H(k,A.petUnique)if not P then return
false,l end end k.logger:info("Tasks",string.format("Using %s %s for %s",f.kind,f.key,Y))local
m,Q=k.interaction:send("ActivateFurniture",U.LocalPlayer,f.key,f.useName,{cframe=f.cframe},Z)if not
m then return false,"ActivateFurniture failed: "..tostring(Q)end local
n=k.waitUntil(function()local P=k.findEntry(l.kind,A.owner,A.petUnique)return P==nil or
P.inProgress end,G)if not n then return false,"used the "..(f.kind..(" but the "..(Y.." need did

not start")))end end local Z=k.findEntry(l.kind,A.owner,A.petUnique)local L=((Z and
Z.rate>0))and(1/Z.rate)or 15 if not k.waitUntil(function()return
k.findEntry(l.kind,A.owner,A.petUnique)==nil end,L+w)then return false,Y..(" "..(l.kind.." did not
complete in time"))end if A.owner=="baby"then k.waitUntil(function()return not
k.gameData:isSitting()end,1)local P,l=m(k)if not P then return false,l end else local
P=k.petLocator:getStreamingId(A.petUnique)local function l()for k,l in ipairs(Q(k,f.key))do if l==P
then return true end end return false end if P and not k.waitUntil(function()return not
l()end,2)then k.logger:info("Tasks","Your pet is still on the "..(f.kind..": getting it
off"))k.interaction:send("ExitFurnitureUseStates",A.petUnique)if not k.waitUntil(function()return
not l()end,4)then return false,"pet is still on the "..f.kind end end end end end return true
end}local function V()local k=workspace:FindFirstChild(P.PetObjectsFolderName)local l={}if k then
for k,P in ipairs(k:GetChildren())do l[P]=true end end return l end local function t(k)local
l=workspace:FindFirstChild(P.PetObjectsFolderName)if not l then return nil end for P,l in
ipairs(l:GetChildren())do if not k[l]then return l end end return nil end local function
R(k,l)local B=P.ItemsForAilment[l]local U=k.gameData:findItems(P.ItemCategory,B)if U[1]then return
U[1]end local Z=P.BuyForAilment[l]if not((Z and k.farmConfig[Z.setting]))then return nil,"no "..
(table.concat(B," / ").." in your backpack")end for U,m in ipairs(Z.ids)do local
H=k.gameData.buysThisSession or 0 local Q=k.farmConfig.MaxBuysPerSession if
type(Q)=="number"and(Q>0 and H>=Q)then return nil,"purchase limit reached ("..(Q.." this
session)")end H=H+(1)k.gameData.buysThisSession=H local
A=k.gameData:get(P.DataKeys.Money)k.logger:info("Tasks",string.format("Nothing for %s: buying 1 %s
(purchase %d this
session)",l,m,H))k.interaction:send("BuyItem",Z.category,m,table.clone(Z.options))local f
k.waitUntil(function()f=(k.gameData:findItems(P.ItemCategory,B))[1]return f~=nil end,6)if f then
local l=k.gameData:get(P.DataKeys.Money)if type(A)=="number"and type(l)=="number"then
k.logger:info("Tasks",string.format("Bought %s for %d Bucks",m,A-l))end return f end
k.logger:warn("Tasks","Bought "..(m.." but it did not appear in your backpack"))end return
nil,"could not buy "..table.concat(Z.ids," / ")end local q=10 function
Z.givePetItem(k,l,U,Z,m)local H,Q=B(k,l)if not H then return false,"pet model: "..tostring(Q)end
local A=V()local f=true k.maid:Give(function()if f then
k.interaction:send("UnequipItem",U.unique,nil)end end)k.logger:info("Tasks",string.format("Giving
%s to your pet (%s)",U.id,m))k.interaction:send("EquipItem",U.unique,
{})task.wait(.5)k.interaction:send("FocusPet",H)k.interaction:send("UseTool",U.unique,"START")local
Y,n=k.interaction:send("CreatePetObject",P.FoodObjectCreator,{additional_consume_uniques=
{},pet_unique=l,unique_id=U.unique})k.interaction:send("UnequipItem",U.unique,nil)f=false
k.interaction:send("UnfocusPet",H)if not Y then return false,string.format("the game refused %s for
%s (age %s):
%s",U.id,tostring(k.gameData:getPetKind(l)),tostring(k.gameData:petAge(l)),tostring(n))end if
k.waitUntil(Z,q)then return true end local L=t(A)if not L then return false,"no object appeared for
your pet"end k.logger:info("Tasks","Your pet did not take it by itself: sending
ConsumeFoodObject")k.interaction:send("ConsumeFoodObject",L,l)if k.waitUntil(Z,5)then return true
end return false,m..(" not done after giving "..U.id)end local function K(k,l,U,Z)local
m,H=B(k,U.petUnique)if not m then return false,"pet model: "..tostring(H)end local Q=V()local
A=true k.maid:Give(function()if A then k.interaction:send("UnequipItem",Z.unique,nil)end
end)k.logger:info("Tasks",string.format("Giving %s to your pet
(%s)",Z.id,l))k.interaction:send("EquipItem",Z.unique,
{})task.wait(.5)k.interaction:send("FocusPet",m)k.interaction:send("UseTool",Z.unique,"START")k.int
eraction:send("CreatePetObject",P.FoodObjectCreator,{additional_consume_uniques=
{};pet_unique=U.petUnique;unique_id=Z.unique})k.interaction:send("UnequipItem",Z.unique,nil)A=false
k.interaction:send("UnfocusPet",m)local function f()return k.completedSince(l,"pet",U.petUnique)or
k.findEntry(l,"pet",U.petUnique)==nil end if k.waitUntil(f,q)then return true end local Y=t(Q)if
not Y then return false,"no food object appeared for your pet"end k.logger:info("Tasks","Your pet
did not eat by itself: sending
ConsumeFoodObject")k.interaction:send("ConsumeFoodObject",Y,U.petUnique)if k.waitUntil(f,5)then
return true end return false,"pet "..(l.." not completed after feeding")end local y=1.5 local
function i(k,l,B)local U=true k.maid:Give(function()if U then
k.interaction:send("UnequipItem",B.unique,nil)end end)k.logger:info("Tasks",string.format("Baby
uses %s (%s)",B.id,l))k.interaction:send("EquipItem",B.unique,{})task.wait(.5)local function
Z()return k.completedSince(l,"baby",nil)or k.findEntry(l,"baby",nil)==nil end for l=1,12,1 do if
Z()then break end local U=k.gameData:itemUsesLeft(P.ItemCategory,B.unique)if U==nil then break end
k.interaction:send("UseTool",B.unique,"START")task.wait(y)k.interaction:send("UseTool",B.unique,"EN
D",nil)if not k.waitUntil(function()local l=k.gameData:itemUsesLeft(P.ItemCategory,B.unique)return
Z()or l==nil or l<U end,3)then return false,B.id..": uses_left did not go down"end task.wait(.3)end
if k.gameData:itemUsesLeft(P.ItemCategory,B.unique)~=nil then
k.interaction:send("UnequipItem",B.unique,nil)end U=false k.waitUntil(Z,3)return Z()end local
function d(k,l,Z)if not k.travel:isAt(P.HouseInteriorName)then local
l,B=k.travel:goTo(P.HouseInteriorName)if not l then return false,"going home: "..tostring(B)end end
local m k.waitUntil(function()m=k.furniture:findSpot(P.PetFoodBowls)return m~=nil end,5)if not m
then return nil end local Q,A=B(k,Z.petUnique)if not Q then return false,"pet model:
"..tostring(A)end local f,Y=H(k,Z.petUnique)if not f then return false,Y end
k.logger:info("Tasks",string.format("Using food bowl %s for your pet",m.key))local
n,L=k.interaction:send("ActivateFurniture",U.LocalPlayer,m.key,m.useName,{cframe=m.cframe},Q)if not
n then return false,"ActivateFurniture failed: "..tostring(L)end if not k.waitUntil(function()local
P=k.findEntry(l,"pet",Z.petUnique)return P==nil or P.inProgress end,5)then return false,"used the

food bowl but hungry did not start"end local b=k.findEntry(l,"pet",Z.petUnique)local M=((b and
b.rate>0))and(1/b.rate)or 7 if k.waitUntil(function()return k.findEntry(l,"pet",Z.petUnique)==nil
end,M+10)then return true end return false,"pet hungry did not complete at the food bowl"end
Z.feed={id="feed",handles=function(k)return P.ItemsForAilment[k]~=nil
end;timeoutSeconds=120;run=function(k,l)local B,U=m(k)if not B then return false,U end local
Z=table.clone(l.entries)table.sort(Z,function(k,P)return k.owner=="pet"and P.owner~="pet"end)for
B,U in ipairs(Z)do for B=1,3,1 do if not k.findEntry(l.kind,U.owner,U.petUnique)then break end
local Z=U.owner=="pet"and(l.kind=="hungry"and(not U.triedBowl and not k.side))if Z and(not
k.farmConfig.FoodBowlTrip and(k.travel and(not
k.travel:isAt(P.HouseInteriorName)and(k.gameData:findItems(P.ItemCategory,P.ItemsForAilment[l.kind]
))[1]~=nil)))then U.triedBowl=true k.logger:info("Tasks","Food in your backpack: feeding here, no
trip home for the bowl (Farm.FoodBowlTrip)")end if U.owner=="pet"and(l.kind=="hungry"and(not
U.triedBowl and not k.side))then U.triedBowl=true local P,B=d(k,l.kind,U)if P==false then return
false,B elseif P==true then break end end local m,H=R(k,l.kind)if not m then return false,H end
local Q,A if U.owner=="pet"then Q,A=K(k,l.kind,U,m)if not Q then return false,A end else
Q,A=i(k,l.kind,m)if A then return false,A end end end if
k.findEntry(l.kind,U.owner,U.petUnique)then return false,((U.owner=="baby"and"baby"or"pet"))..("
"..(l.kind.." still there after 3 items"))end end return true end}local s=6 Z.play=
{id="play",handles=function(k)return k=="play"end,timeoutSeconds=80;run=function(k,l)local
U=l.petEntry if not U then return false,"play is only for pets"end local Z,H=m(k)if not Z then
return false,H end local Q=(k.gameData:findItems(P.ToyCategory,P.ToysForPlay))[1]if not Q then
return false,"no "..(table.concat(P.ToysForPlay," / ").." in your backpack")end local
A,f=B(k,U.petUnique)if not A then return false,"pet model: "..tostring(f)end local Y=false
k.maid:Give(function()if Y then k.interaction:send("EquipItem",Q.unique,
{})k.interaction:send("DropPetObject",A)k.interaction:send("UnequipItem",Q.unique,nil)end end)local
function n()return k.findEntry("play","pet",U.petUnique)end for l=1,6,1 do local B=n()if not B or
k.completedSince("play","pet",U.petUnique)then return true end local Z=B.progress or 0 local
m=V()k.logger:info("Tasks",string.format("Throwing %s (throw %d, progress
%d%%)",Q.id,l,math.floor(Z*100+.5)))k.interaction:send("EquipItem",Q.unique,{})if Y then
k.interaction:send("DropPetObject",A)Y=false end
task.wait(.5)k.interaction:send("UseTool",Q.unique,"START")k.interaction:send("CreatePetObject",P.T
oyObjectCreator,
{reaction_name=P.ThrowToyReaction;unique_id=Q.unique})k.interaction:send("UnequipItem",Q.unique,
{from_throw_toy=true})k.interaction:send("UseTool",Q.unique,"END",nil)local function H()local
k=n()return k==nil or((k.progress or 0))>Z end if not k.waitUntil(H,s)then local P=t(m)if not P
then return false,"no toy object appeared after the throw"end k.logger:info("Tasks","Your pet did
not catch the toy by itself: sending GrabPetObject")k.interaction:send("GrabPetObject",A,P,nil)if
not k.waitUntil(H,4)then return false,"play progress did not rise after throw "..l end end Y=true
task.wait(1)end if n()then return false,"play not completed after 6 throws"end return true
end}Z.mystery={id="mystery",handles=function(k)return
k=="mystery"end,timeoutSeconds=90,run=function(k,l)local B=l.petEntry if not B then return
false,"mystery is only handled for pets"end local U={}for k,P in ipairs(B.mysteryOptions or{})do
U[P]=true end local m={}for l,H in ipairs(P.MysteryPreference)do local
Q=H~="mystery"and(Z.findFor(H)~=nil and P.needOn(k.farmConfig,H))if Q and(((B.mysteryOptions==nil
or U[H]))and not k.findEntry(H,"pet",B.petUnique))then table.insert(m,H)end end local H=#m for k,P
in ipairs(B.mysteryOptions or{})do if P~="mystery"and not table.find(m,P)then table.insert(m,P)end
end if#m==0 then return false,"no doable need among the mystery options"end if H==0 then
k.logger:info("Tasks","Mystery: no doable kind on the cards: picking any offered one to end it")end
k.logger:info("Tasks",string.format("Mystery: pool %s, seed %s, %d kinds, one kind on all 3 cards
at a time",table.concat(B.mysteryOptions or{},","),tostring(B.mysterySeed),#m))local function
Q()return k.findEntry("mystery","pet",B.petUnique)==nil end for P,l in ipairs(m)do if Q()then break
end for P=1,3,1 do
pcall(function()k.interaction:send("ChooseMystery",B.petUnique,"mystery",P,l)end)end if
k.waitUntil(Q,.8)then k.logger:info("Tasks",string.format("Mystery accepted: %s (kind %d of %d,
seed %s)",l,P,#m,tostring(B.mysterySeed)))return true end end if k.waitUntil(Q,2)then return true
end return false,"mystery did not change into a chosen need"end}local function
a(k)return{id=k;handles=function(P)return P==k end,timeoutSeconds=170;run=function(l,B)local
Z=B.petEntry if not Z then return false,k.." is only for pets"end local H,Q=m(l)if not H then
return false,Q end if not l.travel:isAt("MainMap")then local k,P=l.travel:goTo("MainMap")if not k
then return false,"travel: "..tostring(P)end task.wait(3)end local A if k=="ride"then local k=
(l.gameData:findItems(P.StrollerCategory,{"stroller-default"}))[1]or((function()local
k=l.gameData:get(P.DataKeys.Inventory)for k,P in pairs(type(k)=="table"and k.strollers or{})do if
type(P)=="table"then return{unique=tostring(P.unique or k),id=P.id}end end return nil end))()if not
k then return false,"no stroller in your backpack"end local B,m
l.waitUntil(function()B,m=l.petLocator:findModel(Z.petUnique)return B~=nil end,8)if not B then
return false,"pet model: "..tostring(m)end local H=l.gameData:get(P.DataKeys.PetWrappers)local Q
for k,P in pairs(type(H)=="table"and H or{})do if type(P)=="table"and P.pet_unique==Z.petUnique
then Q=table.clone(P)end end if not Q then return false,"no data for the pet"end Q.char=B
Q.controller=U.LocalPlayer Q.entity_controller=U.LocalPlayer Q.player=U.LocalPlayer A=k.unique
l.maid:Give(function()l.interaction:send("UnequipStroller")l.interaction:send("UnequipItem",A,nil)e
nd)l.logger:info("Tasks","Putting your pet in the stroller ("..
(tostring(k.id)..")"))l.interaction:send("EquipItem",A,{chars_to_sit={Q}})task.wait(1)end local
f=15 local Y=Z.petUnique local function n()return l.findEntry(k,"pet",Y)end local function
L()return n()==nil and not C(l,B)end local M=U.LocalPlayer.Character local G=M and

M:FindFirstChild("HumanoidRootPart")local w=G and G.Position local V,t,R,q=0,0,0,0 local K=
((n()or{})).progress or 0 local y=0 local function i()local k=l.petLocator:findModel(Y)if not k or
not G then return nil end local P,B=pcall(function()return(k:GetPivot()).Position end)if not P or
not B then return nil end return math.sqrt(((B.X-G.Position.X))^2+((B.Z-G.Position.Z))^2)end local
function d()local k=n()local P=k and k.progress or K local l=k~=nil and((k.inProgress or P>K+1e06))if P>K then K=P end if l then R=0 else R=R+(2)end return k,l end local s=false local a=0 local
function X()a=a+(1)if A and os.clock()-y>2 then
y=os.clock()l.interaction:send("UseTool",A,"START")l.interaction:send("UseTool",A,"END",nil)end if
G and w then local k=G.Position V=V+(math.sqrt(((k.X-w.X))^2+((k.Z-w.Z))^2))w=k end if a%4==0 then
q=q+(2)local P,B=d()if q-t>=6 then t=q local U=i()local Z=""if G then local k=G.Position
Z=string.format(", at (%.0f, %.0f)%s",k.X,k.Z,b(k)and""or" NOT ON MAINMAP")end
l.logger:info("Tasks",string.format("%s: progress %d%%, %s, moved %d studs, pet
%s%s%s",k,math.floor((((P and P.progress)or K))*100),B and"running"or"NOT running",math.floor(V),U
and(math.floor(U).." studs away")or"not found",Z,((V<1 and l.interaction.walkDiag))and(" [not
moving: "..(l.interaction.walkDiag.."]"))or""))V=0 end if R>=f then s=true end end end local
function F(k)s,R=false,0 M=U.LocalPlayer.Character G=M and M:FindFirstChild("HumanoidRootPart")w=G
and G.Position return l.interaction:walkAround(k,function()return L()or s end,X)end F(75)if L()then
return true end if s and P.Spots.beach_party then l.logger:info("Tasks",k.." is not progressing
here: moving to the open beach spot and walking there")local
P,U=l.interaction:teleportTo("beach_party")l.logger:info("Tasks","Teleport to beach_party: "..((P
and"ok"or tostring(U))))if C(l,B)or l.waitUntil(function()return C(l,B)end,5)then O(l,Y)end F(60)if
L()then return true end elseif not s then F(45)if L()then return true end end local h=n()if
C(l,B)then return false,"the pet was unequipped while walking"end return false,string.format("%s
stopped progressing (progress %d%%)",k,math.floor((((h and h.progress)or K))*100))end}end
Z.walk=a("walk")Z.ride=a("ride")Z.recover={id="recover";handles=function()return false
end;timeoutSeconds=40,run=function(k)k.logger:info("Tasks","Recover:
respawning")k.interaction:send("Respawn")if k.waitUntil(function()return
k.travel:isAt(P.HouseInteriorName)end,20)then return true end k.logger:info("Tasks","Recover:
respawn did not bring me home, travelling")local l,B=k.travel:goTo(P.HouseInteriorName)if not l
then return false,"recover: "..tostring(B)end return true end}Z.equipPet=
{id="equip_pet";handles=function()return false
end;timeoutSeconds=15,run=function(k,P)k.logger:info("Tasks","Your pet is not equipped: equipping
it again")local l,B=O(k,P.petUnique)if not l and P.onFail then P.onFail()end return l,B
end}Z.buyEgg={name="buy_egg";timeoutSeconds=90,run=function(k,l)local
B=P.focusOf(k.farmConfig)local U=B and(B.kind=="egg"and B.id)or k.farmConfig.EggToBuy
or"cracked_egg"if P.NeverBuyEggs[U]then return false,U.." costs Robux: never bought"end local
Z=false for k,P in ipairs(P.Eggs)do Z=Z or P==U end if not Z then
k.logger:warn("Tasks","Farm.EggToBuy = "..(tostring(U).." is not in the egg list: trying it
anyway"))end local function m(l)local B=k.gameData:petUniquesOfKind(U)local
Z=k.gameData:get(P.DataKeys.Money)k.logger:info("Tasks","No pet that still grows: buying 1 "..
(U..l))local m,H=k.interaction:send("BuyItem",P.EggCategory,U,{buy_count=1})if not m then
k.logger:warn("Tasks","BuyItem("..(U..(") failed: "..tostring(H))))end local Q
k.waitUntil(function()for k in pairs(k.gameData:petUniquesOfKind(U))do if not B[k]then Q=k return
true end end return false end,8)if Q then local
l=k.gameData:get(P.DataKeys.Money)k.logger:info("Tasks",string.format("Bought %s%s",U,
((tonumber(Z)and tonumber(l)))and string.format(" for %d Bucks",Z-l)or""))end return Q end local
H=m("")if not H and k.travel:canGoTo("Nursery")then local P,l=k.travel:goTo("Nursery")if not P then
return false,"egg not bought, and the Nursery trip failed: "..tostring(l)end H=m(" in the
Nursery")end if not H then return false,"no "..(U.." arrived in your backpack (not enough Bucks, or
the shop call differs)")end if l and l.onBought then l.onBought()end return true end}Z.team=
{id="team",timeoutSeconds=25;run=function(k)local
l,B=k.interaction:send("ChooseTeam",P.BabiesTeam,table.clone(P.ChooseTeamOptions))if not l then
return false,"ChooseTeam failed: "..tostring(B)end if k.waitUntil(function()return
k.state:get("player.team")==P.BabiesTeam end,10)then return true end return false,"team is still
"..tostring(k.state:get("player.team"))end}Z.ALL=
{Z.pet_me,Z.location,Z.furniture,Z.feed;Z.play,Z.mystery;Z.walk,Z.ride}function Z.findFor(k)for P,l
in ipairs(Z.ALL)do if l.handles(k)then return l end end return nil end return Z end
P["Game/Minigame"]=function(...)local k=...local P=k("Core/Util")local
l=k("Game/GameConstants")local B=game:GetService("ReplicatedStorage")local U={}U.__index=U function
U.new(k)local P=setmetatable({},U)P._logger=k P:reset()return P end function
U.reset(k)k.joinAcceptedAt=nil k.join=nil k.enter=nil k.score=0 k.scoreCount=0 k.lastScoreAt=nil
k.leave=nil k.haunted={}k.propProgress={}k.propsResolved=0 k.bossOut=false end function
U.serverNow()local k,P=pcall(function()return workspace:GetServerTimeNow()end)if k and
type(P)=="number"then return P end return os.time()end local function Z(k)local
P=l.Event.MinigameId return type(k)=="string"and((k==P or string.sub(k,1,#P+2)==P.."::"))end local
m=
{join_accepted=true,join_minigame=true;enter_game=true,ghost_clusters_score=true,leave_game=true,gh
ost_clusters_cast_wave=true;ghost_clusters_prop_progress=true,ghost_clusters_prop_resolved=true;gho
st_clusters_prop_restored=true,ghost_clusters_boss_breakout=true;ghost_clusters_props=true,ghost_cl
usters_vacuum_beam=true;ghost_clusters_attack_windup=true;ghost_clusters_attack_fire=true,ghost_clu
sters_attack_end=true,ghost_clusters_tornado_catch=true;ghost_clusters_tornado_release=true}local
function H(k,P)P=P or 0 if type(k)=="table"then if P>=3 then return"{...}"end local l,B={},0 for
k,U in pairs(k)do B=B+(1)if B>12 then table.insert(l,"...")break end table.insert(l,tostring(k)..
("="..H(U,P+1)))end return"{"..(table.concat(l,", ").."}")end return tostring(k)end function

U._onMessage(A,k,B,U,Q)if not Z(k)then return end if type(B)=="string"and not m[B]then
A._seenTypes=A._seenTypes or{}if not A._seenTypes[B]then A._seenTypes[B]=true
A._logger:info("Minigame","New message type: "..(B..(" "..P.truncate(H(U)..(" "..H(Q)),300))))end
end local f=P.now()if B=="join_accepted"then A.joinAcceptedAt=f elseif B=="join_minigame"and
type(Q)=="string"then A.join={interior=U;gameId=Q,at=f}A._logger:info("Minigame","Round starting:
"..tostring(Q))elseif B=="enter_game"and type(U)=="table"then A.enter=
{intermissionEnd=tonumber(U.intermission_end_time);endTime=tonumber(U.end_time),at=f}elseif
B=="ghost_clusters_cast_wave"and type(U)=="table"then for k,P in pairs(U)do if
type(P)=="table"and(P.haunted==true and(P.resolved~=true and type(P.unique)=="string"))then
A.haunted[P.unique]=true end end elseif B=="ghost_clusters_boss_breakout"then A.bossOut=true
A._logger:info("Minigame","Boss is out: guards first, then the boss")elseif
B=="ghost_clusters_prop_progress"and type(U)=="string"then A.propProgress[U]=tonumber(Q)or 0 elseif
B=="ghost_clusters_prop_resolved"and type(U)=="string"then A.haunted[U]=nil
A.propsResolved=A.propsResolved+(1)elseif B=="ghost_clusters_prop_restored"and
type(U)=="string"then A.haunted[U]=nil elseif B=="ghost_clusters_score"and tonumber(U)then
A.score=A.score+(tonumber(U))A.scoreCount=A.scoreCount+(1)A.lastScoreAt=f elseif
B=="leave_game"then local k=0 if type(U)=="table"and type(U.rewards)=="table"then for P,B in
pairs(U.rewards)do if type(B)=="table"and B.kind==l.DataKeys.Candy then k=k+((tonumber(B.amount)or
0))end end end A.leave={candy=k,results=type(U)=="table"and U.results or
nil,at=f}A._logger:info("Minigame",string.format("Round over: %d points from %d hits, reward %d
candy",A.score,A.scoreCount,k))A._logger:info("Minigame","Round result: "..P.truncate(H(U)..(" |
"..H(Q)),400))end end function U.start(P,k)local U=B:FindFirstChild(l.Remotes.Folder)local Z=U and
U:FindFirstChild(l.Remotes.MinigameMessage)if not((Z and Z:IsA("RemoteEvent")))then
P._logger:warn("Minigame",l.Remotes.MinigameMessage.." not found: Ghost Gallery is off")return
false end k:Give(Z.OnClientEvent:Connect(function(...)local k,l=pcall(P._onMessage,P,...)if not k
then P._logger:debug("Minigame","message not understood: "..tostring(l))end end))P.available=true
return true end return U end P["Game/Hauntlet"]=function(...)local k=...local P=k("Core/Util")local
l=k("Game/GameConstants")local B=game:GetService("ReplicatedStorage")local U={}U.__index=U
U.DEFAULTS=
{revealWaitSeconds=5;planSeconds=5,commitBySeconds=10,slotStart=1;slotGap=.6,potionReserve=1,reserv
eBreakRisk=.05;redPotionMissing=2;preferLockedWhenSafe=true;phoneAtRisk=.01;wandAtRisk=.15,potionAt
Risk=.01;tempHearts=1,tempHeartsLate=2,multiGhostFromRoom=8;safeFirstRoom=true,kindPenalty=
{}}function U.new(k,P)local l=setmetatable({},U)l._logger=k l._userId=P and tostring(P)or nil
l:reset()return l end function U.reset(k)k.joinAcceptedAt=nil k.join=nil k.sessionAcceptedAt=nil
k.enter=nil k.room=nil k.roomSeq=0 k.roomsOpened=0 k.revealedGhost=nil
k._heartDumps,k._heartSign=0,nil k.lastPickSeq,k.lastPickAt=nil,nil k.usedItems={}k.usedSeq=0
k.picked=nil k.inventory={}k.health,k.maxHealth,k.tempHealth=nil,nil,0 k.ghostShield=false
k.kicked=nil k.leave=nil k.counters={0,0,0;0}k.myDoor,k.myDoorAt=nil,nil k._awaitPick=false
k.lastOpened=nil k.history={}k.runners={}k.expectDoor,k.expectAt=nil,nil k.pickedAt=nil
k.mappingSuspect=nil k.revealedAt=nil k.squadIds=nil k._squadAsked={}end local function Z(k)local
P=l.Event.HauntletId return type(k)=="string"and((k==P or string.sub(k,1,#P+2)==P.."::"))end
U._isMine=Z local function m(k,P)if type(P)~="table"then return end for P,l in pairs(P)do if
type(l)=="string"then k[l]=((k[l]or 0))+1 elseif type(P)=="string"and tonumber(l)then k[P]=((k[P]or
0))+tonumber(l)end end end function U._damage(P,k)k=tonumber(k)or 0 if k<=0 or not P.health then
return end local l=math.min(P.tempHealth,k)P.tempHealth=P.tempHealth(l)P.health=math.max(0,P.health-((k-l)))if l>0 then P.ghostShield=P.tempHealth>0 end end function
U.hearts(k)return((k.health or 3))+((k.tempHealth or 0))end function U._runnerDamage(l,k,P)local
B=l.runners[k]if not B or P<=0 then return end local U=math.min(B.temp,P)B.temp=B.temp(U)B.health=math.max(0,B.health-((P-U)))end function U.heartsOf(P,k)k=tostring(k)local l=P.room and
P.room.heartSnap if l and l[k]then return l[k]end local B=P.runners[k]return B
and(B.health+B.temp)or 3 end U.SHARED_ITEMS=
{cell_phone=true,rainbow_wand=true,key=true,gold_key=true}function U.squadOrder(k)local P=k.room
or{}local l,B={},{}local U=k.squadIds for P in pairs(P.alive or{})do P=tostring(P)if not
B[P]and((U==nil or U[P]or P==k._userId))then B[P]=true table.insert(l,P)end end if k._userId and
not B[k._userId]then table.insert(l,k._userId)end local Z=tostring(k.join and k.join.sessionId
or"")local function m(k)local P=5381 local l=Z..("|"..k)for k=1,#l,1 do P=
((P*33+string.byte(l,k)))%2147483647 end return P end table.sort(l,function(P,l)local
B,U=k:heartsOf(P),k:heartsOf(l)if B~=U then return B<U end local Z,H=m(P),m(l)if Z~=H then return
Z<H end return((tonumber(P)or 0))<((tonumber(l)or 0))end)local H=1 for P,l in ipairs(l)do if
l==k._userId then H=P end end return l,H end function U.turnAt(B,k,P,l)local function Z(k)local P=l
and l[k]if P==nil then P=U.DEFAULTS[k]end return tonumber(P)or 0 end local
m,H,Q=Z("slotStart"),Z("slotGap"),Z("planSeconds")local A=m if k=="rainbow_wand"then
A=math.max(m,Q-3)elseif k=="key"or k=="gold_key"then local k=B.room local P=B.revealedAt and(k
and(B.revealedAt-k.at))or nil A=((k and k.safe))and m or(P and math.max(m,P+.3))or math.max(m,Q2)end return math.min(A+((math.max(1,P)-1))*H,Z("commitBySeconds")-2.5)end function
U.setSquadRelay(l,k,P)l._squadUrl=nil l._squadKeyOf=nil l._request=nil end function
U._squadKey(k)local P,l=pcall(k._squadKeyOf or function()return nil end)l=P
and(type(l)=="string"and string.match(l,"^%s*(.-)%s*$"))or nil return((l and#l>=8))and l or nil end
function U.askSquad(l,k)local B=l.join and l.join.sessionId local U=l:_squadKey()if not((U
and(l._squadUrl and(l._request and l._userId))))or type(B)~="string"or l._squadBusy or
l._squadAsked[k]then return end l._squadAsked[k]=true l._squadBusy=true task.spawn(function()local
Z=P.jsonEncode({session=B,userId=l._userId})local m,H=pcall(l._request,
{Url=l._squadUrl;Method="POST",Headers={["Content-Type"]="application/json",["X-SquadKey"]=U};Body=Z})l._squadBusy=false local Q=m and(type(H)=="table"and tonumber(H.StatusCode))or nil

local A=Q==200 and P.jsonDecode(tostring(H.Body))or nil if type(A)~="table"or
type(A.members)~="table"or not((l.join and l.join.sessionId==B))then if k=="join"then local k=m
and(type(H)=="table"and P.truncate(tostring(H.Body or""),120))or""l._logger:info("Hauntlet","Squad
relay did not answer ("..(tostring(Q)..(((k~=""and(": "..k)or"")).."): everyone alive counts")))end
return end local f,Y={},0 for k,P in ipairs(A.members)do if not f[tostring(P)]then
f[tostring(P)]=true Y=Y+(1)end end if not f[l._userId]then f[l._userId]=true Y=Y+(1)end local
n=l.squadIds==nil for k in pairs(f)do if not((l.squadIds and l.squadIds[k]))then n=true end end
l.squadIds=f if n then l._logger:info("Hauntlet",string.format("Squad: %d of your account%s in this
run",Y,Y==1 and""or"s"))end if k=="join"then task.delay(4,function()l:askSquad("join+4")end)end
end)end local H=
{join_accepted=true;join_minigame=true;enter_game=true,started_room=true;revealed_ghost=true,used_i
tem=true;grey_locks_removed=true;door_counters_updated=true,picked_door=true;doors_opened=true,temp
_health_gained=true,kicked_from_game=true,leave_game=true,gained_items=true;all_locks_removed=true;
max_health_gained=true,health_restored=true,door_effect_triggered=true,ghosts_dispelled=true}functi
on U._onMessage(Y,k,B,Q,A,f)if not Z(k)then return end if Y.debugLines then local k={}for l,B in
ipairs({Q,A,f})do local U=type(B)=="table"and((P.jsonEncode(B)or"{?}"))or
tostring(B)table.insert(k,P.truncate(U,400))end table.insert(Y.debugLines,string.format("%7.1f RECV
%s | %s",P.now()-((Y.debugStart or 0)),tostring(B),table.concat(k," | ")))end if
type(B)=="string"and not H[B]then Y._seenTypes=Y._seenTypes or{}if not Y._seenTypes[B]then
Y._seenTypes[B]=true Y._logger:info("Hauntlet","New message type: "..B)end end local n=P.now()local
L=k~=l.Event.HauntletId if B=="join_accepted"then if L then Y.sessionAcceptedAt=n else
Y.joinAcceptedAt=n end elseif B=="join_minigame"and type(A)=="string"then Y.join=
{interior=Q;sessionId=A,at=n}Y._logger:info("Hauntlet","Run starting:
"..A)Y:_debugStart(A,Q)Y:askSquad("join")elseif B=="enter_game"and type(Q)=="table"then Y.enter=
{at=n}local k=type(Q.serialized_runners)=="table"and Q.serialized_runners or{}Y.runners={}for k,P
in pairs(k)do if type(P)=="table"then Y.runners[tostring(k)]={health=tonumber(P.health)or
3;maxHealth=tonumber(P.max_health)or 3,temp=tonumber(P.temp_health)or 0}end end local P=Y._userId
and((k[Y._userId]or k[tonumber(Y._userId)]))if type(P)=="table"then Y.health=tonumber(P.health)or 3
Y.maxHealth=tonumber(P.max_health)or 3 Y.tempHealth=tonumber(P.temp_health)or 0 Y.inventory=
{}m(Y.inventory,P.inventory)end elseif B=="started_room"and type(Q)=="table"then local k={}for
P=1,4,1 do local l=type(Q.doors)=="table"and Q.doors[P]or nil local B=type(l)=="table"and((l.kind
and tostring(l.kind)or(l.area_kind and("area:"..tostring(l.area_kind)))))or"unknown"k[P]=
{exists=type(l)=="table";kind=B,gold=type(l)=="table"and tonumber(l.gold_locks)or
0,grey=type(l)=="table"and tonumber(l.grey_locks)or 0}k[P].wasLocked=k[P].gold+k[P].grey>0 end
Y.roomSeq=Y.roomSeq+(1)local P={}for k,l in pairs(type(f)=="table"and f or{})do if l then
P[tostring(k)]=true end end if Y.room then Y.lastReveal=
{seq=Y.room.seq;door=Y.revealedGhost,at=Y.revealedAt and(Y.revealedAt-Y.room.at)or
nil;safe=Y.room.safe}end Y.room=
{area=Q.area_kind,kind=Q.kind;doors=k,at=n;seq=Y.roomSeq,startServer=tonumber(A);alive=P;safe=false
,lockVersion=0}Y.tempHealth=0 for k,P in pairs(Y.runners)do P.temp=0 end
Y.revealedGhost,Y.revealedAt=nil,nil
Y.expectDoor,Y.expectAt,Y.pickedAt,Y.mappingSuspect=nil,nil,nil,nil local l={}for k,P in
pairs(Y.runners)do l[k]=P.health+P.temp end Y.room.heartSnap=l if Y.roomSeq==2 then
Y:askSquad("room 2")end Y.picked=nil Y.counters={0,0,0;0}Y.myDoor,Y.myDoorAt=nil,nil
Y._awaitPick=false Y.ghostShield=((Y.tempHealth or 0))>0 if Y.debugLines then local k=Y.join and
Y.join.interior local P=tostring(Y.health)..("/"..tostring(Y.maxHealth))local l=((Y._heartDumps or
0))<8 and((Y.roomSeq<=1 or P~=Y._heartSign))Y._heartSign=P
task.delay(1.5,function()Y:_debugNote(U.describeRooms(k))if l then Y._heartDumps=((Y._heartDumps or
0))+1 Y:_debugNote("counted hearts "..(P..(" (room "..(tostring(Y.roomSeq)..(") |
"..U.describeHeartUi())))))end Y:_debugFlush()end)end elseif B=="gained_items"then
m(Y.inventory,Q)elseif B=="revealed_ghost"and tonumber(Q)then
Y.revealedGhost=tonumber(Q)Y.revealedAt=n elseif B=="used_item"and type(Q)=="string"then
Y.usedSeq=Y.usedSeq+(1)Y.usedItems[Y.usedSeq]={item=Q;ok=A==true}if A==true then
Y.inventory[Q]=math.max(0,((Y.inventory[Q]or 1))-1)if Q=="red_potion"and Y.maxHealth then
Y.health=Y.maxHealth elseif Q=="gold_potion"and Y.health then Y.maxHealth=((Y.maxHealth or 3))+1
Y.health=Y.health+(1)elseif Q=="ghost_potion"then Y.ghostShield=true elseif Q=="rainbow_wand"and
Y.room then Y.room.safe=true end elseif Q=="ghost_potion"and((Y.tempHealth or 0))>0 then
U.learnedTempCap=math.max(U.learnedTempCap or 0,Y.tempHealth,2)else Y.inventory[Q]=0 end elseif
B=="ghosts_dispelled"and Y.room then Y.room.safe=true Y.room.dispelledAt=n if Y.debugLines then
Y:_debugNote("ghosts_dispelled: room "..tostring(Y.room.seq))end elseif
B=="all_locks_removed"and(type(Q)=="table"and Y.room)then for k,P in pairs(Q)do local
l=Y.room.doors[tonumber(P)or 0]if l then l.grey,l.gold=0,0 end end Y.room.lockVersion=
((Y.room.lockVersion or 0))+1 elseif B=="grey_locks_removed"and(type(Q)=="table"and Y.room)then for
k,P in pairs(Q)do local l=Y.room.doors[tonumber(P)or 0]if l then l.grey=math.max(0,l.grey-1)end end
Y.room.lockVersion=((Y.room.lockVersion or 0))+1 elseif B=="door_counters_updated"and
type(Q)=="table"then local k={}for P=1,4,1 do k[P]=tonumber(Q[P])or 0 end local P,l,B={},0,0 for
U=1,4,1 do local Z=k[U]-((Y.counters[U]or 0))if Z>0 then table.insert(P,U)l=l+(Z)elseif Z<0 then
B=B-(Z)end end if Y.expectDoor and(Y.expectAt and(((k[Y.expectDoor]or 0))>
((Y.counters[Y.expectDoor]or 0))and not((Y.myDoorAt and Y.myDoorAt>=Y.expectAt))))then
Y.myDoor,Y.myDoorAt=Y.expectDoor,n end if Y._awaitPick then if#P==1 and(l==1 and(B<=1
and(Y.expectDoor and P[1]~=Y.expectDoor)))then Y.mappingSuspect=P[1]end Y._awaitPick=false end
Y.counters=k elseif B=="picked_door"then Y.picked=Q==true if Q==true then Y._awaitPick=true
Y.pickedAt=n Y.pickedSeq=Y.room and Y.room.seq Y.lastPickSeq,Y.lastPickAt=Y.pickedSeq,n if
Y.expectDoor then Y.myDoor,Y.myDoorAt=Y.expectDoor,n end end elseif B=="doors_opened"then

Y.roomsOpened=Y.roomsOpened+(1)local k=0 if type(A)=="table"and Y._userId then
k=tonumber(A[Y._userId]or A[tonumber(Y._userId)])or 0 Y:_damage(k)for k,P in pairs(A)do
Y:_runnerDamage(tostring(k),tonumber(P)or 0)end end m(Y.inventory,f)local P={}for k=1,4,1 do
P[k]=type(Q)=="table"and((tonumber(Q[k])or 0))>0 or false end local l=Y.room Y.lastOpened=
{seq=Y.roomSeq;ghosts=P,myDoor=Y.myDoor,damage=k,items=type(f)=="table"and f
or{}}table.insert(Y.history,{seq=Y.roomSeq,area=l and l.area;kinds=l
and{l.doors[1].kind;l.doors[2].kind;l.doors[3].kind}or{},ghosts=P,revealed=Y.revealedGhost,myDoor=Y
.myDoor;damage=k})elseif B=="temp_health_gained"and Q~=nil then if Y._userId and
tostring(Q)==Y._userId then Y.tempHealth=Y.tempHealth+((tonumber(A)or 0))end local
k=Y.runners[tostring(Q)]if k then k.temp=k.temp+((tonumber(A)or 0))end elseif
B=="health_restored"and Q~=nil then if Y._userId and tostring(Q)==Y._userId then
Y.health=Y.maxHealth or Y.health end local k=Y.runners[tostring(Q)]if k then k.health=k.maxHealth
end elseif B=="max_health_gained"and Q~=nil then local k=Y.runners[tostring(Q)]if k then
k.maxHealth=k.maxHealth+(1)k.health=k.health+(1)end elseif B=="door_effect_triggered"and Y.room
then Y.room.effects=Y.room.effects or{}Y.room.effects[tonumber(A)or 0]=tostring(f)if
tostring(f)=="player_take_damage"then if Y._userId and tostring(Q)==Y._userId then Y:_damage(1)end
local k=Y.runners[tostring(Q)]if k then local P=math.min(k.temp,1)k.temp=k.temp(P)k.health=math.max(0,k.health-((1-P)))end end elseif B=="kicked_from_game"then
Y.kicked=tostring(Q)if Y._userId and Y.runners[Y._userId]then Y.runners[Y._userId].health=0 end
Y._logger:info("Hauntlet","Kicked from the run: "..(tostring(Q)..(" (room "..
(Y.roomSeq..")"))))elseif B=="leave_game"then local k,P=0,{}if type(Q)=="table"and
type(Q.rewards)=="table"then for P,B in pairs(Q.rewards)do if type(B)=="table"and
B.kind==l.DataKeys.Candy then k=k+((tonumber(B.amount)or 0))end end end if type(Q)=="table"and
type(Q.results)=="table"then for k,l in pairs(Q.results)do if type(l)=="table"and
type(l.title)=="string"then P[l.title]=tonumber(l.value)end end end Y.leave=
{candy=k;roomReached=P["ROOM REACHED"];best=P["ALL TIME BEST"];plays=P["TOTAL
PLAYS"],completed=type(A)=="table"and
A.completed_game==true,at=n}Y._logger:info("Hauntlet",string.format("Run over: room %s, reward %d
candy",tostring(Y.leave.roomReached),k))Y:_debugStop()end if B=="doors_opened"then
Y:_debugFlush()end end U.DEBUG_FILE="AdoptMeFarm/hauntlet_debug.log"function U._debugStart(Z,k,B)if
not((l.Event.HauntletDebug or Z:_squadKey()))or type(writefile)~="function"then return end
Z:_debugStop()pcall(function()if type(isfolder)=="function"and(type(makefolder)=="function"and not
isfolder("AdoptMeFarm"))then makefolder("AdoptMeFarm")end end)Z.debugStart=P.now()Z.debugLines=
{string.format("Hauntlet debug %s, session %s, interior %s (recorded for the bot and for
you)",os.date("%Y-%m-%d
%H:%M:%S"),tostring(k),tostring(B))}pcall(function()Z._debugConn=Z._logger.OnEntry:Connect(function
(k,l,B)B=tostring(B)if Z.debugLines and((l=="Hauntlet"or string.find(B,"Hauntlet",1,true)))then
table.insert(Z.debugLines,string.format("%7.1f %s [%s] %s",P.now()Z.debugStart,tostring(k),tostring(l),B))end end)end)if not U._dbDumped then U._dbDumped=true
pcall(writefile,"AdoptMeFarm/hauntlet_db.txt",table.concat(U.describeDatabases(),"\n"))end
Z:_debugNote(U.describeRooms(B))Z:_debugFlush()end function U._debugNote(l,k)if l.debugLines then
table.insert(l.debugLines,string.format("%7.1f %s",P.now()-((l.debugStart or 0)),tostring(k)))end
end function U._debugFlush(k)if k.debugLines and type(writefile)=="function"then
pcall(writefile,U.DEBUG_FILE,table.concat(k.debugLines,"\n").."\n")end end function
U._debugStop(k)if not k.debugLines then return end
k:_debugFlush()pcall(function()k._debugConn:Disconnect()end)k.debugLines,k._debugConn=nil,nil end
local Q=setmetatable({},{__mode="k"})local A=0 function U.readHotbar()local k pcall(function()local
P=(game:GetService("Players")).LocalPlayer:FindFirstChildOfClass("PlayerGui")local B=P and
P:FindFirstChild("MinigameHotbarApp")local U=B and(B.Enabled~=false and
B:FindFirstChild("Hotbar"))if not U then return end local Z={}for k in pairs(l.Event.HauntletItems
or{})do local P=U:FindFirstChild(k)if P then local
l=P:FindFirstChild("Button")and(P.Button:FindFirstChild("StackCount")and
P.Button.StackCount:FindFirstChild("TextLabel"))local B=l and
tonumber(string.match(tostring(l.Text),"(%d+)"))if B==nil then return end Z[k]=P.Visible==false and
0 or B end end if next(Z)then k=Z end end)return k end function U.describeHeartUi()local k,l={},260
local function B(P)if l>0 then l=l-(1)table.insert(k,P)end end pcall(function()local k=
(game:GetService("Players")).LocalPlayer local function l(k,l)local U,Z=pcall(function()return
l:GetAttributes()end)if U and(type(Z)=="table"and next(Z)~=nil)then local l={}for k,B in pairs(Z)do
table.insert(l,tostring(k)..("="..P.truncate(tostring(B),40)))end table.sort(l)B("ATTR "..(k..(":
"..table.concat(l,", "))))end end l("player",k)if k.Character then l("character",k.Character)end
for k,l in ipairs(k.Character and k.Character:GetDescendants()or{})do if l:IsA("BillboardGui")or
l:IsA("SurfaceGui")or(l:IsA("TextLabel")and
l:FindFirstAncestorWhichIsA("BillboardGui"))or(l:IsA("ImageLabel")and
l:FindFirstAncestorWhichIsA("BillboardGui"))then local k=""pcall(function()if
l:IsA("TextLabel")then k=" text="..P.truncate(tostring(l.Text),30)elseif l:IsA("ImageLabel")then
k=" vis="..(tostring(l.Visible)..(" img="..tostring(l.Image)))end end)B("CHAR "..
(string.gsub(l:GetFullName(),"^.-Workspace%.","")..(" ["..(l.ClassName..("]"..k)))))end end local
U=k:FindFirstChildOfClass("PlayerGui")local Z={}for k,P in ipairs(U and U:GetChildren()or{})do
local l=true pcall(function()l=P.Enabled~=false end)table.insert(Z,P.Name..((l and""or"(off)")))end
table.sort(Z)B("SCREENS "..table.concat(Z,", "))for k,l in ipairs(U and U:GetDescendants()or{})do
local U=l:GetFullName()local Z=string.lower(U)local m=string.find(Z,"journalapp",1,true)or
string.find(Z,"exitbutton",1,true)or string.find(Z,"xboxbutton",1,true)if not m
and((string.find(Z,"aunt")or string.find(Z,"heart")or string.find(Z,"health")or
string.find(Z,"minigame")or string.find(Z,"lives")or string.find(Z,"potion")))then local

k=""pcall(function()if l:IsA("GuiObject")then k=k..((" vis="..tostring(l.Visible)))end if
l:IsA("ImageLabel")or l:IsA("ImageButton")then k=k..(((" img="..(tostring(l.Image)..("
transp="..tostring(l.ImageTransparency)))))..(" color="..tostring(l.ImageColor3)))elseif
l:IsA("TextLabel")or l:IsA("TextButton")then k=k..(("
text="..P.truncate(tostring(l.Text),40)))elseif l:IsA("ValueBase")then k=k..(("
value="..P.truncate(tostring(l.Value),40)))end end)B("UI "..(string.gsub(U,"^.-PlayerGui%.","")..("
["..(l.ClassName..("]"..k)))))end end local m=0 for k,P in
ipairs((game:GetService("ReplicatedStorage")):GetDescendants())do if m<25
and(P:IsA("ModuleScript")and string.find(string.lower(P.Name),"aunt"))then m=m+(1)B("MODULE
"..P:GetFullName())end end end)if#k==0 then return"HEART UI: nothing found"end return"HEART UI ("..
(#k..(" lines):\n "..table.concat(k,"\n ")))end function U.describeRooms(k)local P={}local
l,B=pcall(function()local l=workspace:FindFirstChild("Interiors")local B=l and(type(k)=="string"and
l:FindFirstChild(k))local U=B and B:FindFirstChild("Rooms")if not U then table.insert(P,"ROOMS: no
Rooms folder (interior "..(tostring(k)..")"))return end local Z=
(game:GetService("Players")).LocalPlayer.Character local m=Z and
Z:FindFirstChild("HumanoidRootPart")local H,f,Y={},nil,-1 for k,P in ipairs(U:GetChildren())do if
not Q[P]then A=A+(1)Q[P]=A end local
l="?"pcall(function()l=tostring(math.floor((((P:GetPivot()).Positionm.Position)).Magnitude))end)table.insert(H,string.format("#%d %s %s studs",Q[P],P.Name,l))if Q[P]>Y
then f,Y=P,Q[P]end end table.insert(P,"ROOMS: "..table.concat(H,", "))if f then local k={}for P,l
in ipairs(f:GetChildren())do local B={}local U=l:GetChildren()if#U<=40 then for k,P in ipairs(U)do
if#B<8 then table.insert(B,P.Name)end end end table.insert(k,l.Name..("("..(l.ClassName..(((#B>0
and(": "..table.concat(B,","))or(#U>0 and(": "..(#U.." children"))or"")))..")"))))end
table.insert(P,string.format("NEWEST ROOM #%d %s: %s",Y,f.Name,table.concat(k,"; ")))end end)if not
l then table.insert(P,"ROOMS: "..tostring(B))end return table.concat(P,"\n")end function
U.roomElapsed(k)return k.room and math.max(0,P.now()-k.room.at)or 0 end function U.view(k)local
P=k.room or{}local l=0 for P in pairs(P.alive or{})do if tostring(P)~=k._userId then l=l+(1)end end
return{seq=P.seq,area=P.area;doors=P.doors
or{},revealedGhost=k.revealedGhost;safe=P.safe==true;inventory=k.inventory,health=k.health or
3,maxHealth=k.maxHealth or 3,tempHealth=k.tempHealth or
0,shield=k.ghostShield==true,elapsed=k:roomElapsed();others=l;tempCap=U.learnedTempCap}end
U.DOOR_FALLBACK={bouncy={ghost=80,effect="player_bounce",drops=1};copycat=
{ghost=300;effect="transform";drops=0},electric=
{ghost=30;effect="player_take_damage",value=1,drops=1.3},gold_locked={ghost=0,drops=1};locked=
{ghost=30;drops=.25},nightmare={ghost=180;drops=1.6};rotten={ghost=120,drops=.9},security=
{ghost=20,drops=1.2};shadow={ghost=150;drops=1.3};webbed=
{ghost=5,effect="player_lose_item";value=1,drops=.3},wooden={ghost=90,drops=.45}}U.GHOST_OVERRIDE=
{}U.MEASURED_GHOST=
{shadow=255;rotten=100;wooden=90;bouncy=85;copycat=70,electric=50;locked=23,webbed=5;security=2,gol
d_locked=0}U.TWO_GHOSTS={[8]=.8,[9]=.7,[16]=.6,[17]=.5,[18]=.55;[19]=.3;[24]=.5,[25]=.4,[26]=.85;
[27]=.85,[28]=.7;[29]=.5}function U.twoGhostChance(k)k=tonumber(k)or 0 local P=U.TWO_GHOSTS[k]if P
then return P end if k<30 then return k<=1 and 0 or.02 end if k>=41 then return.95 end
return(k%10==1)and.2 or.6 end function U.worstHit(k)return((tonumber(k)or 0))>=16 and 2 or 1 end
U.AREA_COST=
{spider=4;hallway=8;carnival=10;laboratory=12;copycat=15;mechanical=25,nightmare=30}local f
function U.doorInfo(k)local P=type(k)=="string"and string.match(k,"^area:(.+)$")if P then
return{ghost=0;drops=0;area=P,cost=U.AREA_COST[P]or 15}end if f==nil then f=false
pcall(function()local k=B for P,l in ipairs(l.Event.HauntletDBPath)do k=k and
k:FindFirstChild(l)end local P=k and require(k:FindFirstChild("HauntletDoorDB"))if
type(P)~="table"then return end local U={}for k,P in pairs(P)do if type(P)=="table"and
tonumber(P.ghost_weight)then local l,B=0,0 for k,P in pairs(type(P.drop_table)=="table"and
P.drop_table or{})do P=tonumber(P)or 0 l=l+(P)B=B+(((tonumber(string.match(tostring(k),":
(%d+)$"))or 0))*P)end U[tostring(k)]=
{ghost=tonumber(P.ghost_weight),effect=P.enter_effect;value=tonumber(P.enter_effect_value)or
1;drops=l>0 and B/l or 0}end end if next(U)then f=U end end)end local Z=(f and f[k])or
U.DOOR_FALLBACK[k]or{ghost=90,drops=.5}local m=U.MEASURED_GHOST[k]or U.GHOST_OVERRIDE[k]if m
and((tonumber(Z.ghost)or 0))~=m then local k={}for P,l in pairs(Z)do k[P]=l end k.ghost=m Z=k end
return Z end local function Y(k,P)return tonumber(k and k[P])or 0 end local function n(k)local P=0
for k,l in pairs(k or{})do P=P+(math.max(0,tonumber(l)or 0))end return P end function
U.decide(k,P)P=P or U.DEFAULTS local function l(k)local l=P[k]if l==nil then l=U.DEFAULTS[k]end
return l end local B,Z=k.inventory or{},k.tried or{}local function m(k)return Y(B,k)>0 and not
Z[k]end local H,Q=tonumber(k.health)or 3,tonumber(k.maxHealth)or 3 local
A=tonumber(k.revealedGhost)local f=k.safe==true or A~=nil local L=l("safeFirstRoom")~=false and
k.seq==1 local b=U.twoGhostChance(k.seq)local M=b>=.3 local O=tonumber(k.tempHealth)or 0 if
k.shield and O<=0 then O=1 end local C=U.worstHit(k.seq)local G=Q-H if G>0
and(m("red_potion")and((G>=((tonumber(l("redPotionMissing"))or 1))or(H+O)-C<=1 or
Y(B,"red_potion")>=2)))then return{use="red_potion",reason=string.format("hearts %d/%d (a ghost can
take %d): the red potion fills them",H,Q,C)}end if m("gold_potion")then
return{use="gold_potion";reason="one more heart for the rest of the run (run items end with the
run)"}end local w,V,t=k.doors or{},{},0 for k=1,4,1 do local P=w[k]if P and P.exists~=false then
t=t+((U.doorInfo(P.kind)).ghost)end end local R=math.huge local function q(k)local
P,l=tonumber(k.gold)or 0,tonumber(k.grey)or 0 return((P==0 or(Y(B,"gold_key")>=P and not
Z.gold_key)))and((l==0 or(Y(B,"key")>=l and not Z.key)))end local K=A
and(w[A]and(w[A].exists~=false and(U.doorInfo(w[A].kind)).ghost))or 0 for P=1,4,1 do local l=w[P]if

l and l.exists~=false then if k.safe==true or L or(U.doorInfo(l.kind)).area then V[P]=0 elseif A
then if P==A then V[P]=1 elseif b>0 and t-K>0 then V[P]=(b*(U.doorInfo(l.kind)).ghost)/((t-K))else
V[P]=0 end elseif t>0 then local k=(U.doorInfo(l.kind)).ghost local B=k/t local Z=B for l=1,4,1 do
local B=w[l]if l~=P and(B and B.exists~=false)then local P=(U.doorInfo(B.kind)).ghost if t-P>0 then
Z=Z+(((P/t))*((k/((t-P)))))end end end V[P]=((1-b))*B+b*math.min(1,Z)else V[P]=.33333333333333 end
if q(l)then R=math.min(R,V[P])end end end local y=H+O<=C local i=y and.001 or l("phoneAtRisk")local
d=y and.001 or l("wandAtRisk")if not f and(not L and(R>0 and R>=i))then if m("cell_phone")then
return{use="cell_phone",reason=string.format("the safest door is still %d%% ghost: the phone shows
the ghost\'s door, the other doors are then safe",math.floor(R*100+.5))}elseif m("rainbow_wand")and
R>=d then return{use="rainbow_wand";reason="no phone: the wand clears every ghost in this
room"}elseif((tonumber(k.others)or 0))>0 and((tonumber(k.elapsed)or 0))<((l("revealWaitSeconds")or
0))then return{wait=true,reason="ghost unknown: waiting a moment for another player\'s phone"}end
end local s=P.rng or math.random local a=P.kindPenalty or{}local X,F,h,p,x={},nil,math.huge,nil,nil
for k=1,4,1 do local m=w[k]if m and m.exists~=false then local H=U.doorInfo(m.kind)local
Q,A=tonumber(m.gold)or 0,tonumber(m.grey)or 0 local L=V[k]local b=Q>0 and"gold_key"or(A>0
and"key"or nil)local M=Q>0 and Q or A local O=(L*100+((tonumber(a[m.kind])or 0)))((tonumber(H.drops)or 0))*3 local C={}if H.area then O=O+(H.cost)if H.area=="laboratory"and
Y(B,"key")<2 then O=O+(20)table.insert(C,"its doors need 2 keys each")end table.insert(C,"next
area: "..(H.area..(" (cost "..(H.cost..")"))))end if H.effect=="player_take_damage"then O=O+(100*
((tonumber(H.value)or 1)))table.insert(C,"entering costs a heart")elseif
H.effect=="player_lose_item"and n(B)>0 then local k=
((Y(B,"red_potion")+Y(B,"gold_potion"))+Y(B,"ghost_potion"))+Y(B,"rainbow_wand")O=O+((k>0 and 18 or
8))table.insert(C,k>0 and"entering costs an item (maybe a heart item)"or"entering costs an
item")elseif H.effect=="player_bounce"then O=O+(10)table.insert(C,"bounces me to a random
door")elseif H.effect=="transform"then O=O+(3)end if b and((Y(B,b)<M or Z[b]))then O=O+
(1000)table.insert(C,string.format("locked (%d %s lock%s), cannot open
it",M,b=="gold_key"and"gold"or"grey",M==1 and""or"s"))elseif b then if f and(L==0 and
l("preferLockedWhenSafe"))then O=O-(5)table.insert(C,"safe and locked: the "..(b.." opens the
richer path"))else O=O+(5)table.insert(C,"needs a "..b)end elseif m.wasLocked and(L==0 and
l("preferLockedWhenSafe"))then O=O-(5)table.insert(C,"safe and unlocked now: the richer path")end
if L>=1 then table.insert(C,1,"the ghost was revealed here")end O=O+((((type(P.tie)=="table"and
tonumber(P.tie[k]))or s()))*.5)X[k]=string.format("door %d (%s): risk %s, score
%.1f%s",k,tostring(m.kind),L==0 and"none"or(L>=1 and"GHOST"or(math.floor(L*100+.5).."%")),O,#C>0
and(" - "..table.concat(C,"; "))or"")if O<h then F,h,x=k,O,L p=((b and O<1000))and b or nil end end
end if not F then return{wait=true;reason="no door data yet"}end local E=k.safe==true and"the wand
cleared this room"or(A and string.format("the ghost is behind door %d",A))or(L and"room 1 never had
a ghost")or string.format("ghost unknown: door %d is the least likely
(%d%%)",F,math.floor(x*100+.5))if p then return{use=p,door=F,reason=E..("; door "..(F..(" needs a
"..p))),notes=X}end if x>0 and(x>=d and(k.safe~=true and m("rainbow_wand")))then
return{use="rainbow_wand",door=F;reason=string.format("%s; door %d is still %d%% ghost: the wand
clears the room first",E,F,math.floor(x*100+.5)),notes=X}end local I=Y(B,"ghost_potion")local o=((M
or H<=2 or x>=.3))and l("tempHeartsLate")or l("tempHearts")if x>=.5 and((k.seq or 0))>=16 then
o=math.max(o,3)end if I>=4 and x>=.1 then o=o+(1)end local e=tonumber(k.tempCap)if e and e>0 then
o=math.min(o,e)end local u=((H+O)-C<=1 and x>=.05)or x>=((tonumber(l("reserveBreakRisk"))or
0))local T=I>((tonumber(l("potionReserve"))or 0))or u if x>0 and(x>=l("potionAtRisk")and(O<o
and(m("ghost_potion")and T)))then return{use="ghost_potion";door=F,reason=string.format("%s; temp
heart %d of %d for door %d",E,O+1,o,F),notes=X}end
return{door=F;reason=E,notes=X;risky=x>0;risk=x;worstHit=C}end function U.plan(k,P)local l={}for
k,P in pairs(k)do l[k]=P end l.inventory,l.tried,l.doors={},{},{}for k,P in pairs(k.inventory
or{})do l.inventory[k]=P end for k,P in pairs(k.tried or{})do l.tried[k]=P end for k,P in
pairs(k.doors or{})do local B={}for k,P in pairs(P)do B[k]=P end l.doors[k]=B end
l.tempHealth=tonumber(l.tempHealth)or 0 if l.shield and l.tempHealth<=0 then l.tempHealth=1 end
local B={}for k=1,12,1 do local Z=U.decide(l,P)if Z.use then local k=Z.use
l.inventory[k]=math.max(0,((tonumber(l.inventory[k])or 0))-1)if k=="red_potion"then
l.health=l.maxHealth l.tried[k]=true table.insert(B,"red potion (hearts full)")elseif
k=="gold_potion"then l.maxHealth=((tonumber(l.maxHealth)or 3))+1 l.health=((tonumber(l.health)or
3))+1 table.insert(B,"gold potion (+1 heart)")elseif k=="ghost_potion"then
l.tempHealth=l.tempHealth+(1)l.shield=true table.insert(B,"ghost potion (+1 temp heart)")elseif
k=="rainbow_wand"then l.safe=true l.tried[k]=true table.insert(B,"wand (no ghost
left)")elseif((k=="key"or k=="gold_key"))and(Z.door and l.doors[Z.door])then local
P=l.doors[Z.door]if k=="key"then P.grey=math.max(0,((tonumber(P.grey)or 0))-1)else P.gold=0 end
table.insert(B,string.format("%s for door %d",k=="key"and"key"or"gold key",Z.door))elseif
k=="cell_phone"then table.insert(B,"phone (shows the ghost\'s door, then a new plan)")return B,nil
else l.tried[k]=true table.insert(B,k)end elseif Z.wait then table.insert(B,"wait for another
player\'s phone")return B,nil else local k=tonumber(Z.risk)or 0 if k<=0 then
table.insert(B,string.format("door %d (safe)",Z.door))else local P=tonumber(Z.worstHit)or 1 local
U=(((tonumber(l.health)or 3))+((tonumber(l.tempHealth)or 0)))-P table.insert(B,string.format("door
%d (%d%% ghost; worst hit -%d -> %s)",Z.door,math.floor(k*100+.5),P,U>0 and(U..(" heart"..(((U==1
and""or"s")).." left")))or"DEAD"))end return B,Z end end return B,nil end function
U.describeDoors(k)local P={}for l=1,4,1 do local B=k and k[l]if B and B.exists~=false then local k=
((B.gold or 0))>0 and(" "..(B.gold.." gold lock"))or(((B.grey or 0))>0 and(" "..(B.grey.."
lock"))or"")table.insert(P,l..("="..(tostring(B.kind)..k)))end end return table.concat(P,", ")end
function U.describeItems(k)local P={}for k,l in pairs(k or{})do if((tonumber(l)or 0))>0 then
table.insert(P,k..((l>1 and(" x"..l)or"")))end end table.sort(P)return#P>0 and table.concat(P,",

")or"none"end function U.describeDatabases()local k={}local P=B for k,l in
ipairs(l.Event.HauntletDBPath)do P=P and P:FindFirstChild(l)end if not P then return{"Hauntlet
databases not found"}end local function U(k)if type(k)=="table"then local P={}for k,l in pairs(k)do
if type(l)~="table"and(type(l)~="function"and#P<12)then table.insert(P,tostring(k)..
("="..tostring(l)))end end table.sort(P)return"{ "..(table.concat(P,", ").." }")end return
tostring(k)end for l,B in ipairs({"HauntletDoorDB","HauntletItemDB","HauntletAreaDB"})do local
Z=P:FindFirstChild(B)local m,H=pcall(require,Z)table.insert(k,"== "..(B..((m and""or(" ("..
(tostring(H)..")"))))))if m and type(H)=="table"then local P={}for k in pairs(H)do
table.insert(P,tostring(k))end table.sort(P)for P,l in ipairs(P)do local B=H[l]local Z={}if
type(B)=="table"then for k,P in pairs(B)do if type(P)~="function"then table.insert(Z,tostring(k)..
("="..U(P)))end end table.sort(Z)end table.insert(k,l..(": "..table.concat(Z,"; ")))end end end
return k end function U.client()local k=B for P,l in ipairs(l.Event.HauntletClientPath)do k=k and
k:FindFirstChild(l)end if not k or not k:IsA("ModuleScript")then return nil end local
P,U=pcall(require,k)return P and(type(U)=="table"and U)or nil end function U.start(P,k)local
Z=B:FindFirstChild(l.Remotes.Folder)local m=Z and Z:FindFirstChild(l.Remotes.MinigameMessage)if
not((m and m:IsA("RemoteEvent")))then P._logger:warn("Hauntlet",l.Remotes.MinigameMessage.." not
found: Hauntlet is off")return false end k:Give(m.OnClientEvent:Connect(function(...)local
k,l=pcall(P._onMessage,P,...)if not k then P._logger:debug("Hauntlet","message not understood:
"..tostring(l))end end))P.available=true if l.Event.HauntletDebug and
type(writefile)=="function"then
task.delay(5,function()pcall(writefile,"AdoptMeFarm/hauntlet_rooms.txt",U.describeTemplates())end)e
nd return true end function U.describeTemplates()local k,P={},{}local function l(k)local P={}for
k,l in ipairs(k:GetChildren())do local B,U={},l:GetChildren()if#U<=40 then for k,P in ipairs(U)do
if#B<10 then table.insert(B,P.Name..("<"..(P.ClassName..">")))end end end table.insert(P,l.Name..("
("..(l.ClassName..(((#B>0 and(": "..table.concat(B,","))or(#U>0 and(": "..(#U.."
children"))or"")))..")"))))end return table.concat(P,"; ")end local U,Z=pcall(function()for B,U in
ipairs(B:GetDescendants())do if#k>=80 then break end local Z=string.lower(U.Name)local m=
(string.find(Z,"joincircle",1,true)and U.Parent)or(((Z=="nexus"or Z=="final_nexus"))and U)or nil if
m and not P[m]then P[m]=true table.insert(k,m:GetFullName()..(" <"..(m.ClassName..(">:
"..l(m)))))end end end)if not U then table.insert(k,"error: "..tostring(Z))end if#k==0 then
table.insert(k,"no room templates with door circles found in ReplicatedStorage")end return
table.concat(k,"\n")end return U end P["Game/EventTasks"]=function(...)local k=...local
P=k("Core/Util")local l=k("Game/GameConstants")local B=k("Game/Minigame")local
U=k("Game/Hauntlet")local Z=k("Game/Tasks")local m={}local H=l.Event local Q=l.DataKeys local
A=l.ToyCategory local function f(k)local P=0 for k in pairs(k)do P=P+(1)end return P end local
function Y(k)local P={}for k in pairs(type(k)=="table"and k or{})do if tonumber(k)then
table.insert(P,tonumber(k))end end table.sort(P)return P end function m.cryptPlan(k,P)if
type(k)~="table"or type(k.floors)~="table"then return nil,"crypt data not known yet"end if P then
local P=m.reachableTwigGrave(k)if P then return P end end local l={}for k,P in
pairs(type(k.opened)=="table"and k.opened or{})do if tonumber(P)then l[tonumber(P)]=true end end
local function B(k,P)return k[P]or k[tostring(P)]end for P,U in ipairs(Y(k.floors))do local
Z=B(k.floors,U)Z=type(Z)=="table"and Z.coffins if type(Z)=="table"then local k for P,l in
ipairs(Y(Z))do if B(Z,l)==H.Ladder then k=l end end if k then if not l[U*H.OpenedIdPerFloor+k]then
return{floor=U,grave=k,reward=H.Ladder}end else local k,P for m,Q in ipairs(Y(Z))do if not
l[U*H.OpenedIdPerFloor+Q]then local l=H.GraveValue[B(Z,Q)]or 0 if not k or l>P then k,P=Q,l end end
end if k then return{floor=U,grave=k;reward=tostring(B(Z,k))}end return{spider=true;floor=U}end end
end if#Y(k.floors)>0 then return{spider=true}end return nil,"no Crypt floors in your data yet"end
function m.cryptPick(k,P,l)if type(P)~="table"or#P==0 then return m.cryptPlan(k,l)end if
type(k)~="table"or type(k.floors)~="table"then return nil,"crypt data not known yet"end if l then
local P=m.reachableGrave(k,"twig")if P then return P end end for P,l in ipairs(P)do if l==H.Ladder
then local P=m.cryptPlan(k)if P then return P end else local P=m.reachableGrave(k,l)if P then
return P end end end return nil,"no grave with "..(table.concat(P," / ").." left on the floors you
can reach")end function m.reachableTwigGrave(k)return m.reachableGrave(k,"twig")end function
m.isLeverReward(k)if k==H.LightningLever then return true end local P={}local function l(k,B)if
type(k)=="table"and B<3 then for k,U in pairs(k)do table.insert(P,tostring(k))l(U,B+1)end elseif
k~=nil then table.insert(P,tostring(k))end end l(k,0)local B=string.lower(table.concat(P,"
"))return string.find(B,"lever",1,true)~=nil or string.find(B,"lightning",1,true)~=nil end function
m.reachableGrave(k,P)if type(k)~="table"or type(k.floors)~="table"then return nil end local l={}for
k,P in pairs(type(k.opened)=="table"and k.opened or{})do if tonumber(P)then l[tonumber(P)]=true end
end local function B(k,P)return k[P]or k[tostring(P)]end for U,Z in ipairs(Y(k.floors))do local
Q=B(k.floors,Z)Q=type(Q)=="table"and Q.coffins if type(Q)=="table"then local k,U=false,false for
A,f in ipairs(Y(Q))do local Y=B(Q,f)local n=l[Z*H.OpenedIdPerFloor+f]==true local L=Y==P
or(P=="twig"and Y==H.Twig)or(P=="lever"and m.isLeverReward(Y))if L and Y~=H.Ladder then if not n
then return{floor=Z;grave=f;reward=P}end elseif Y==H.Ladder then U=true k=n end end if U and not k
then return nil end end end return nil end function m.nestState(k,P,l)if type(k)~="table"then
return"UNKNOWN",0,P or 0 end local B=tonumber(k.twigs_contributed)or 0 P=P or 0 if B>=H.NestTwigs
then return"COMPLETE",B,P elseif B+P>=H.NestTwigs then return"BUILD_NEST",B,P elseif((l or 0))>0
then return"COLLECT_TWIGS",B,P end return"WAIT_KEY",B,P end function m.questsToClaim(k)local P=
{}local l=type(k)=="table"and(type(k.serialized_tabs)=="table"and k.serialized_tabs)or{}for k,B in
ipairs(H.QuestTabs)do local U=l[B]if type(U)=="table"then local k,l=0,0 for P,B in
pairs(type(U.active_dailies)=="table"and U.active_dailies or{})do local
U=type(B)=="table"and(type(B.state)=="table"and B.state)or{}local
Z,m=tonumber(U.steps_to_complete),tonumber(U.steps_completed)if Z and(m and m>=Z)then k=k+(1)else
l=l+(1)end end if k>0 then table.insert(P,{action="QuestClaim",tab=B})end if

U.reward_claimed==false and((tonumber(U.total_dailies_completed_today)or
0))>=H.QuestsPerBoardReward then table.insert(P,{action="QuestTabReward";tab=B})end end end return
P end function m.describeQuests(k)local P=type(k)=="table"and(type(k.serialized_tabs)=="table"and
k.serialized_tabs)if not P then return"no quest data"end local l={}for k,B in ipairs(H.QuestTabs)do
local U=P[B]if type(U)=="table"then local k={}for P,l in pairs(type(U.active_dailies)=="table"and
U.active_dailies or{})do local B=type(l)=="table"and(type(l.state)=="table"and
l.state)or{}table.insert(k,string.format("%s
%s/%s",tostring(P),tostring(B.steps_completed),tostring(B.steps_to_complete)))end
table.sort(k)table.insert(l,string.format("%s [%s] done today %s, board reward %s",B,#k>0 and
table.concat(k,", ")or"no open
quests",tostring(U.total_dailies_completed_today),U.reward_claimed==true and"claimed"or"not
claimed"))end end return#l>0 and table.concat(l," | ")or"no Halloween / normal board"end function
m.nextRoundStart(k,P)local l=type(k)=="table"and tonumber(k.timestamp)if not l or
type(P)~="number"then return nil end while l+20<P do l=l+(H.RoundSeconds)end return l end function
m.penPlan(k,P,l,B,U,Z)local m={claim=f(k)>0;remove={},add={}}local H={}for k,P in pairs(k)do if
type(P)=="table"and P.max_age==true then table.insert(m.remove,k)elseif U and(Z and Z(k)~=U)then
table.insert(H,k)end end table.sort(m.remove)table.sort(H)local Q=(B-f(k))+#m.remove if U then
local k=0 for P,B in ipairs(P)do if B.kind==U and not l[B.unique]then k=k+(1)end end while k>Q
and#H>0 do table.insert(m.remove,table.remove(H,1))Q=Q+(1)end end for k,P in ipairs(P)do if Q<=0
then break end if not l[P.unique]then table.insert(m.add,P.unique)Q=Q-(1)end end return m end
function m.findGhosts(k)local P={}if not k then return P end for k,l in ipairs(k:GetChildren())do
local B=string.match(l.Name,H.GhostNamePattern)if B then table.insert(P,
{id=B;model=l;size=string.match(l.Name,"^Ghost_(%a+)_")})end end return P end local function
n()local k=(game:GetService("Players")).LocalPlayer.Character return k and
k:FindFirstChild("HumanoidRootPart")end local function L(k)local
P,l=pcall(function()return(k:GetPivot()).Position end)return P and l or nil end local function
b(k,P)return math.sqrt((((k.X-P.X))^2+((k.Y-P.Y))^2)+((k.Z-P.Z))^2)end local function M(k,P,l)local
B,U=k.interaction:send("EquipItem",P,{})if not B then return false,"could not hold the item:
"..tostring(U)end k.maid:Give(function()if k.gameData:itemUsesLeft(l,P)~=nil then
k.interaction:send("UnequipItem",P,nil)end end)return true end local function O(k)local P={}for k,l
in pairs(k.gameData:petPenPets())do table.insert(P,k..(":"..(tostring(l.xp_timestamp)..
(":"..tostring(l.currency_timestamp)))))end table.sort(P)return table.concat(P,"|")end m.petPen=
{id="pet_pen",timeoutSeconds=60;run=function(k,P)if not k.travel:isAt(l.HouseInteriorName)then
return false,"the Pet Pen job runs only at home"end local B={}for k,P in
ipairs(k.gameData:equippedPetList())do B[P.unique]=true end if P and P.keep then B[P.keep]=true end
local U=tonumber(k.farmConfig.Event.PetPenSlots)or H.PetPenSlots local
Z=m.penPlan(k.gameData:petPenPets(),k.gameData:growablePets(k.farmConfig.PreferNeon==true,l.kindRan
k(k.farmConfig)),B,U,l.focusKind(k.farmConfig),function(P)return k.gameData:getPetKind(P)end)local
A={}if Z.claim then local P=O(k)local
l=k.gameData:get(Q.Money)k.interaction:send("PetPenClaim",true)if not k.waitUntil(function()return
O(k)~=P end,8)then return false,"CLAIM ALL had no effect in my data"end local
B=k.gameData:get(Q.Money)table.insert(A,"claimed"..((((tonumber(B)and(tonumber(l)and B>l)))and
string.format(" (+%d Bucks)",B-l)or"")))end local Y=k.gameData:petPenPets()for P,l in
ipairs(Z.remove)do local B=type(Y[l])=="table"and Y[l].max_age==true
k.interaction:send("PetPenRemove",l)if not k.waitUntil(function()return(k.gameData:petPenPets())
[l]==nil end,6)then return false,"pet "..(l.." did not leave the pen")end table.insert(A,B and"took
out a full grown pet"or("made room for the focus pet (took out "..
(tostring(k.gameData:getPetKind(l)or l)..")")))end for P,l in ipairs(Z.add)do
k.interaction:send("PetPenAdd",l)if not k.waitUntil(function()return(k.gameData:petPenPets())
[l]~=nil end,6)then return false,"pet "..(l.." did not arrive in the pen")end table.insert(A,"added
"..tostring(k.gameData:getPetKind(l)or l))end k.logger:info("Event","Pet Pen: "..(((#A>0 and
table.concat(A,", ")or"nothing to do"))..string.format(" (%d of %d slots
used)",f(k.gameData:petPenPets()),U)))return true end}local function C(k,P)local B=l.Spots[k]local
U=n()if not((B and U))then return false end local Z=U.Position return math.sqrt(((Z.X-B.x))^2+
((Z.Z-B.z))^2)<=P end m._nearSpot=C local function G(k,P)for l=1,2,1 do local
B,U=k.travel:goTo("MainMap")if not B then return false,"travel to the Halloween map failed:
"..tostring(U)end local Z,m=k.interaction:teleportTo(P)task.wait(1.5)if Z and(C(P,20)and
k.travel:isAt("MainMap"))then return true end k.logger:info("Event",string.format("Not next to %s
after the teleport (%s), try %d",P,Z and"moved away again"or tostring(m),l))end return false,"could
not stay next to "..P end m.strayCat={id="stray_cat",timeoutSeconds=90,run=function(k)local
function P()local P=k.gameData:get(Q.StrayCat)return type(P)=="table"and P or{}end
if(P()).fed_today==true then return true end local B=tonumber((P()).total_gifts)or 0 local U=
(k.gameData:findItems(l.ItemCategory,H.CatFood))[1]if not U then if not k.farmConfig.BuyWater then
return false,"no water for the cat (Farm.BuyWater = false)"end
k.interaction:send("BuyItem","food","water",{})k.waitUntil(function()U=
(k.gameData:findItems(l.ItemCategory,H.CatFood))[1]return U~=nil end,8)if not U then return
false,"could not buy a water for the cat"end end local Z,m=G(k,"stray_cat")if not Z then return
false,m end local A,f=M(k,U.unique,l.ItemCategory)if not A then return false,f end
task.wait(1)local Y,n=k.interaction:send("StrayCatFeed",{unique=U.unique})local
L=type(n)=="table"and n.reason or nil for P=1,2,1 do if L~="too_far"then break end
k.logger:info("Event","Stray Cat: too far, moving next to it again")if not G(k,"stray_cat")then
break end Y,n=k.interaction:send("StrayCatFeed",{unique=U.unique})L=type(n)=="table"and n.reason or
nil end if k.waitUntil(function()return(P()).fed_today==true or((tonumber((P()).total_gifts)or
0))>B end,5)then k.logger:success("Event",string.format("Stray Cat fed with %s%s",U.id,

((type(n)=="table"and n.amount))and(" (+"..(tostring(n.amount).." candy)"))or""))return true end if
L=="cat_full"then k.logger:info("Event","Stray Cat is already full today")return true end return
false,"the cat did not take it ("..(((Y and("answer: "..tostring(L or n))or"send
failed"))..")")end}m.crypt={id="crypt";timeoutSeconds=90;run=function(k)local l=
(k.gameData:itemsOfId(A,H.RustyKey))[1]local
B=m.nestState(k.gameData:get(Q.PigeonNest),#k.gameData:itemsOfId(A,H.Twig),l and 1 or 0)local
U=k.farmConfig.Event.AutoNest~=false and B=="COLLECT_TWIGS"local
Z,f=m.cryptPick(k.gameData:get(Q.Crypt),k.farmConfig.Event.CryptOpen,U)local
Y=m.skelicornOn(k.farmConfig)and m.skelicornStep(k.gameData,k.farmConfig)if Y and((Y=="crypt"or
m.skelicornNeedsLever(k.gameData)))then local l=k.gameData:get(Q.Crypt)local
B=m.reachableGrave(l,"lever")Z=B or m.cryptPlan(l)or Z U=false local
f=P.truncate(P.jsonEncode(type(l)=="table"and l.floors or l)or"?",400)if f~=m._leverFloorsLogged
then m._leverFloorsLogged=f k.logger:info("Skelicorn","Crypt floors: "..f)m.skelicornNote("Crypt
floors: "..P.truncate(P.jsonEncode(type(l)=="table"and l.floors or l)or"?",3000))end local Y=B and
string.format("Lever grave: floor %s grave %s",tostring(B.floor),tostring(B.grave))or("No lever
grave on the floors I can reach: "..((Z and(Z.spider and"the Mummy Spider (the Crypt starts
again)")or(Z and string.format("floor %s grave %s
(%s)",tostring(Z.floor),tostring(Z.grave),tostring(Z.reward)))or"nothing to
open")))k.logger:info("Skelicorn",Y)m.skelicornNote(Y..(" | Rusty Keys
"..#k.gameData:itemsOfId(A,H.RustyKey)))end if not Z then k.logger:info("Event","Crypt:
"..tostring(f))return true end if not Z.spider and not l then return true end local
n,L=k.travel:goTo("TheCrypt")if not n then return false,"travel to the Crypt failed:
"..tostring(L)end if Z.spider then local function P()local P=k.gameData:get(Q.Crypt)local
l=type(P)=="table"and(type(P.opened)=="table"and#P.opened)or-1 return tostring(type(P)=="table"and
P.seed)..("/"..l)end local l=P()local B,U=k.interaction:send("ClaimTombSpider")if
k.waitUntil(function()return P()~=l end,8)then k.logger:success("Event","Crypt: Mummy Spider
claimed, the Crypt starts again")return true end return false,"the Mummy Spider claim changed
nothing in my data (answer: "..(tostring(U)..")")end local function b()local P,l={},0 local
B=k.gameData:get(Q.Crypt)for k,B in pairs(type(B)=="table"and(type(B.opened)=="table"and
B.opened)or{})do P[tonumber(B)or B]=true l=l+(1)end return P,l end local O,C=b()local
G,w=M(k,l,A)if not G then return false,w end
task.wait(1)k.logger:info("Event",string.format("Crypt: opening grave %d on floor %d
(%s)",Z.grave,Z.floor,Z.reward))local V,t=k.interaction:send("UnlockPadlock",
{padlock_index=Z.grave;floor_index=Z.floor})if not k.waitUntil(function()local k,P=b()return P>C
end,6)then return false,"the grave did not open (answer: "..(tostring(t)..")")end local R=b()if not
R[Z.floor*H.OpenedIdPerFloor+Z.grave]then k.logger:warn("Event","Crypt: a grave opened, but not
with the expected id (floor * 16 + grave)")end k.logger:success("Event","Crypt: opened "..
(Z.reward..(" on floor "..Z.floor)))if U then local
P,l,B=m.nestState(k.gameData:get(Q.PigeonNest),#k.gameData:itemsOfId(A,H.Twig),0)k.logger:info("Aut
oNest",string.format("Twig progress: %d/%d",l+B,H.NestTwigs))end return true end}m.pigeonNest=
{id="pigeon_nest";timeoutSeconds=150;run=function(k)local function P()local
P=k.gameData:get(Q.PigeonNest)return type(P)=="table"and tonumber(P.twigs_contributed)or 0 end
local l=k.gameData:itemsOfId(A,H.Twig)local B=k.farmConfig.Event.AutoNest~=false if#l==0 or
P()>=H.NestTwigs then return true end if B and P()+#l<H.NestTwigs then return true end local
U,Z=k.travel:goTo("HauntedHotel")if not U then return false,"travel to the Hotel failed:
"..tostring(Z)end if B then k.logger:info("AutoNest",string.format("Building Nest (%d placed + %d
twigs)",P(),#l))end for l,U in ipairs(l)do if P()>=H.NestTwigs then break end local Z=P()local
m,Q=M(k,U,A)if not m then return false,Q end task.wait(1)local
f,Y=k.interaction:send("PigeonNestTwig",{unique=U})if not k.waitUntil(function()return P()>Z
end,6)then return false,"the nest did not take the twig (answer: "..(tostring(Y)..")")end
k.logger:success("Event",string.format("Pigeon nest: twig placed (%d of %d)",P(),H.NestTwigs))if
not B then return true end end if B then k.logger:info("AutoNest","Verifying Nest")if P()
<H.NestTwigs then return false,string.format("nest not finished after building (%d of
%d)",P(),H.NestTwigs)end k.logger:success("AutoNest","Nest completed")end return true
end}m._skelicorn={delivered=false,activated=false,bought=false;logged=nil}m._skelicornNotes=
{}function m.skelicornNote(k)local P=m._skelicornNotes table.insert(P,os.date("%m-%d %H:%M:%S
")..tostring(k))while#P>80 do table.remove(P,1)end if type(writefile)=="function"then
pcall(function()if type(makefolder)=="function"and(type(isfolder)=="function"and not
isfolder("AdoptMeFarm"))then makefolder("AdoptMeFarm")end
writefile("AdoptMeFarm/skelicorn.log",table.concat(P,"\n").."\n")end)end end function
m.findLever(k)local P=k:get(Q.Inventory)for k,P in pairs(type(P)=="table"and P or{})do if
type(P)=="table"then for P,l in pairs(P)do if type(l)=="table"and l.id==H.LightningLever then
return tostring(l.unique or P),k end end end end return nil end function m.leverState(k)local
P,l=false,false local function B(k,U)for k,Z in pairs(k)do local m=string.lower(tostring(k))if
type(Z)=="table"then if U<2 then B(Z,U+1)end elseif Z==true or(type(Z)=="number"and Z>0)then if
string.find(m,"install")or string.find(m,"deliver")or string.find(m,"placed")or
string.find(m,"insert")then P=true end if string.find(m,"activ")or string.find(m,"pull")then l=true
end end end end if type(k)=="table"then local P=k.lever_state if type(P)=="string"then local
k=string.lower(P)if k~="deactivated"and(k~=""and(k~="none"and k~="missing"))then return true,true
end return false,false end B(k,0)end return P,l end function m.skelicornPrice()local
k=H.SkelicornPrice pcall(function()local P=
(game:GetService("ReplicatedStorage")):FindFirstChild("Fsys")local l=P
and(require(P)).load("InventoryDB")local B=type(l)=="table"and(type(l.pets)=="table"and
l.pets[H.Skelicorn])local U=type(B)=="table"and tonumber(B.cost or B.price)if U and U>0 then k=U

end end)return k end function m.skelicornOn(k)local
P=l.focusOf(k)return(type(k)=="table"and(type(k.Event)=="table"and
k.Event.AutoSkelicorn==true))or(P~=nil and P.kind=="skelicorn")end function
m.skelicornStep(k,B)local U=m._skelicorn local Z=l.focusOf(B)if Z and Z.kind=="skelicorn"then local
P=type(B.Event)=="table"and B.Event or{}local l=((tonumber(P.PetPenSlots)or H.PetPenSlots or 4))+1
local U=k:growingCopies(H.Skelicorn)if U>=l then return nil,string.format("%d Skelicorns still grow
(%d wanted): idle",U,l)end elseif U.bought or next(k:petUniquesOfKind(H.Skelicorn))~=nil then
return nil,"a Skelicorn is yours: idle"end local A,f=m.leverState(k:get(Q.LightningLever))A=A or
U.delivered or next(k:petUniquesOfKind(H.Skelicorn))~=nil f=f or U.activated if not A then if
m.findLever(k)then return"install"end local l=tonumber(k:get(Q.Candy))or 0 if
l>=m.skelicornPrice()and(not U.leverRequired and P.now()-((U.buyRefusedAt or-1000000000))>110)then
return"buy"end return"crypt"end if not f and(type(H.SkelicornArgs)=="table"and
type(H.SkelicornArgs.activate)=="table")then return"activate"end local Y=tonumber(k:get(Q.Candy))or
0 if Y>=m.skelicornPrice()then return"buy"end return nil,string.format("waiting for candy (%d /
%d)",Y,m.skelicornPrice())end function m.skelicornNeedsLever(k)local P=m._skelicorn local
l=m.leverState(k:get(Q.LightningLever))return not((l or P.delivered))and m.findLever(k)==nil end
function m.findLeverMachine()local k pcall(function()for P,l in
ipairs(workspace:GetDescendants())do if l:IsA("Model")or l:IsA("BasePart")then local
P=string.lower(l.Name)local B=true for k,l in ipairs(H.LeverMachinePatterns)do if not
string.find(P,l,1,true)then B=false end end if B then local P=l:IsA("BasePart")and l or
l.PrimaryPart or l:FindFirstChildWhichIsA("BasePart",true)if P then k=k or{node=l,part=P}end end
end end end)return k end local function w(k,P)local l=type(H.SkelicornArgs)=="table"and
H.SkelicornArgs[k]if type(l)~="table"then return nil end local function B(k,l)if k=="$LEVER"then
return P end if type(k)=="table"and l<3 then local P={}for k,U in pairs(k)do P[k]=B(U,l+1)end
return P end return k end local U={}for k,P in ipairs(l)do U[k]=B(P,0)end return U end m.skelicorn=
{id="skelicorn",timeoutSeconds=120,run=function(k)local B=m._skelicorn local
U=k.gameData:get(Q.LightningLever)local Z=P.truncate(P.jsonEncode(U)or tostring(U),300)if
Z~=B.logged then B.logged=Z k.logger:info("Skelicorn","Lever data: "..Z)m.skelicornNote("Lever
data: "..Z)end local A,f=m.skelicornStep(k.gameData,k.farmConfig)if not A or A=="crypt"then
k.logger:info("Skelicorn",tostring(f or"no lever yet: the Crypt looks for it"))return true end if
A=="buy"then local U=m.skelicornPrice()local Z=k.gameData:petUniquesOfKind(H.Skelicorn)local
A=tonumber(k.gameData:get(Q.Candy))or 0 local
f,Y=k.interaction:send("BuyItem",l.EggCategory,H.Skelicorn,{buy_count=1})local
n=k.waitUntil(function()for k in pairs(k.gameData:petUniquesOfKind(H.Skelicorn))do if not Z[k]then
return true end end return false end,8)if not n then B.buyRefusedAt=P.now()if
string.find(string.lower(tostring(Y)),"not for sale",1,true)then B.leverRequired=true
m.skelicornNote("shop: not for sale until this account\'s lever is in the machine")return true end
return false,string.format("no Skelicorn arrived (price %d, candy %d, answer %s
%s)",U,A,tostring(f),P.truncate(tostring(Y),60))end B.bought=true B.delivered=true local
L=l.focusKind(k.farmConfig)==H.Skelicorn k.logger:success("Skelicorn",string.format("Skelicorn
bought for %d candy: %s",A-((tonumber(k.gameData:get(Q.Candy))or A)),L and"Mega Skelicorn buys the
next one at 120k candy"or"Auto Skelicorn is done"))return true end local
Y,n=k.travel:goTo("MainMap")if not Y then return false,"travel to the main map failed:
"..tostring(n)end local L=m.findLeverMachine()if not L then return false,"the lever machine was not
found in the map (a model named lightning + lever)"end local
b,M=k.interaction:teleportNearPart(L.part,6)if not b then return false,"could not stand at the
machine: "..tostring(M)end k.logger:info("Skelicorn","At the machine: "..L.node:GetFullName())local
O=m.findLever(k.gameData)local C=w(A=="install"and"deliver"or"activate",O)if A=="install"and(C and
O)then k.interaction:send("EquipItem",O,{})task.wait(.6)end if not C then return false,"the "..
(((A=="install"and"LightningLeverDeliver"or"LightningLeverActivate")).." arguments are not recorded
yet (one manual install with a remote spy, then SkelicornArgs)")end local
G=function()return((P.jsonEncode(k.gameData:get(Q.LightningLever))or""))..
("|"..tostring(m.findLever(k.gameData)))end local V=G()local
t,R=k.interaction:send(A=="install"and"LightningLeverDeliver"or"LightningLeverActivate",table.unpac
k(C))local q=k.waitUntil(function()return G()~=V end,6)if A=="install"then if not q then return
false,"the lever install showed no change in my data (answer: "..(tostring(t)..(" "..
(P.truncate(tostring(R),60)..")")))end B.delivered=true B.activated=true
k.logger:success("Skelicorn","Lightning Lever installed: the Skelicorn is unlocked")else
B.activated=true k.logger:success("Skelicorn","Lightning Lever pulled"..((q and""or" (no data
change seen)")))end return true end}do local k=m.skelicorn.run m.skelicorn.run=function(P,...)local
l,B=k(P,...)m.skelicornNote(l and"task done"or("task FAILED: "..tostring(B)))return l,B end end
m.ghostGallery={id="ghost_gallery",timeoutSeconds=330;run=function(k,U)local Z=k.minigame if not Z
or not Z.available then return false,"minigame messages are not available"end local f=U and U.start
if not f then return false,"round time unknown"end local Y=tonumber(k.gameData:get(Q.Candy))local
n=#k.gameData:itemsOfId(A,H.RustyKey)local b,M=k.travel:goTo("HauntedManor")if not b then return
false,"travel to the Manor failed: "..tostring(M)end Z:reset()local O=not((k.farmConfig.Event and
k.farmConfig.Event.GhostJoinByZone==false))local C=false if O then local P
C,P=k.interaction:teleportToJoinZone()k.logger:info("Event","Ghost Gallery: standing in the join
circle"..((C and""or(" failed ("..(tostring(P)..")")))))end k.waitUntil(function()return
B.serverNow()>=f-3 end,math.max(0,f-B.serverNow())+5)if O then
C=k.interaction:teleportToJoinZone()end k.logger:info("Event","Ghost Gallery: joining the round"..
((C and" (join circle)"or"")))if C then k.waitUntil(function()return Z.joinAcceptedAt~=nil or
Z.join~=nil end,20)if Z.joinAcceptedAt or Z.join then k.logger:info("Event","Ghost Gallery: the
game queued me from the join circle")else k.logger:info("Event","Ghost Gallery: the circle did not

queue me in 20 s: joining by call")end end local G=P.now()+30 while not Z.joinAcceptedAt and(not
Z.join and P.now()<G)do
k.interaction:send("MinigameJoin",H.MinigameId,true,nil)k.waitUntil(function()return
Z.joinAcceptedAt~=nil or Z.join~=nil end,3)end if not Z.joinAcceptedAt and not Z.join then return
false,"join was not accepted"end if not k.waitUntil(function()return Z.join~=nil end,40)then return
false,"accepted, but the round did not take me in"end local w=Z.join.gameId local function
V()return k.travel:isAt(H.MinigameInteriorPrefix)end if not k.waitUntil(V,15)then
k.interaction:send("MinigameJoin",w,true,nil)end if not k.waitUntil(V,20)then
k.logger:warn("Event","Ghost Gallery: not in the round after 35 s: leaving it ("..
(tostring(w)..")"))if type(w)=="string"then k.interaction:send("MinigameLeave",w,false)end return
false,"did not arrive in the minigame (left the round)"end local t=B.serverNow()+170 local function
R(P,U)k.waitUntil(function()return Z.leave~=nil or not V()end,math.max(0,tB.serverNow())+25)k.waitUntil(function()return not V()end,15)local
m,H=k.travel:goTo(l.HouseInteriorName)if not m then k.logger:info("Event","Ghost Gallery: going
home after the round did not work ("..(tostring(H)..")"))end return P,U end local q
k.waitUntil(function()q=(k.gameData:itemsOfId(A,H.Vacuum))[1]return q~=nil end,10)if not q then
return R(false,"no vacuum in the backpack")end k.interaction:send("EquipItem",q,
{})k.waitUntil(function()return Z.enter~=nil end,10)t=(Z.enter and Z.enter.endTime)or t if Z.enter
and Z.enter.intermissionEnd then k.waitUntil(function()return
B.serverNow()>=Z.enter.intermissionEnd end,40)end local
K=workspace:FindFirstChild(H.GhostsFolder)local y,i,d,s=0,0,0,0 local a={target=nil}local
X,F,h=k.interaction:keepNear(function()local k=a.target if Z.leave or not V()then return false end
if not k then return nil end if k.kind=="ghost"then if not k.model or k.model.Parent==nil then
return nil end return L(k.model),"below"end return k.position,H.PropStandOff
end)k.maid:Give(X)while not Z.leave and B.serverNow()<t+5 do K=K or
workspace:FindFirstChild(H.GhostsFolder)local P=m.pickTarget(k,K,Z)if not P then s=s+
(1)task.wait(.5)else a.target=P h()k.interaction:send("UseTool",q,"START")local l=m.newToken()y=y+
(1)local B=P.kind=="ghost"local U=B and{use_token=l;ghost_id=P.id}or{use_token=l;unique=P.id}local
H=B and"start_contribute"or"start_prop_contribute"local Q=B
and"stop_contribute"or"stop_prop_contribute"for l=1,8,1 do if Z.leave or(B and
P.model.Parent==nil)or(not B and not Z.haunted[P.id])then break end if P.boss and(l>1
and(m.pickTarget(k,K,Z)~=nil and not(m.pickTarget(k,K,Z)).boss))then break end
k.interaction:send("MinigameMessage",w,H,U)task.wait(.3)end
k.interaction:send("MinigameMessage",w,Q,U)if B then i=i+(1)else d=d+(1)end end end a.target=nil
X(V()and not Z.leave)k.logger:info("Event",string.format("Ghost Gallery: held %d studs under the
ghosts (%d position corrections)",H.HoldBelowStuds,F.corrections))k.waitUntil(function()return
Z.leave~=nil end,20)local p=tonumber(k.gameData:get(Q.Candy))local x=((p and Y))and(p-Y)or nil
local E=0 for k,P in pairs(Z.propProgress)do if P>0 then E=E+(1)end end
k.logger:info("Event",string.format("Ghost Gallery: %d points (%d hits), props moved %d, vacuum
uses %d (ghosts %d, props %d), reward %s candy%s",Z.score,Z.scoreCount,E,y,i,d,tostring(Z.leave and
Z.leave.candy or"?"),x and string.format(", candy %+d",x)or""))local
I=#k.gameData:itemsOfId(A,H.RustyKey)k.logger:info("Event",string.format("Ghost Gallery: Rusty Key
%s (score %d, boss %s)",I>n and"EARNED (+1)"or"not earned",Z.score,Z.bossOut and"came out"or"did
not come out"))if Z.scoreCount==0 and(not((Z.leave and Z.leave.candy>0))and not((x and x>0)))then
return R(false,y==0 and"no ghost or haunted prop found"or"no points and no reward: vacuuming did
not count")end return R(true)end}m._journalAt=nil m.hauntlet=
{id="hauntlet";timeoutSeconds=1200;run=function(k,Z)local A=k.hauntlet if not A or not A.available
then return false,"minigame messages are not available"end local
f=tonumber(k.gameData:get(Q.Candy))local function Y()return
k.travel:isAt(H.HauntletInteriorPrefix)end local L=A.join~=nil and(not A.leave and(not A.kicked and
P.now()-A.join.at<90))if not L then local l,U=k.travel:goTo(H.HauntletLobby)if not l then return
false,"travel to the Hotel failed: "..tostring(U)end A:reset()local f=30 local Y=B.serverNow()local
n=(Z and tonumber(Z.start))or m.nextRoundStart(k.gameData:get(Q.HauntletCycle),Y)if n and n-Y>f
then local P=math.floor((n-Y)-f)k.logger:info("Event",string.format("Hauntlet: next run in ~%ds,
waiting until T-%d before entering the circle",math.floor(n-Y),f))k.waitUntil(function()return
A.joinAcceptedAt~=nil or A.join~=nil or B.serverNow()>=n-f end,P+8)elseif n then
k.logger:info("Event",string.format("Hauntlet: cycle in ~%ds, entering join circle
now",math.floor(n-Y)))else k.logger:info("Event","Hauntlet: no cycle timestamp, entering join
circle")end if A.join or A.joinAcceptedAt then else local l,B=false,"not attempted"for P=1,3,1 do
l,B=k.interaction:teleportToHauntletJoinZone()if l then break end task.wait(1)end if l then
k.logger:info("Event","Hauntlet: in hotel join circle ("..(tostring(B)..") \226\128\148 waiting for
auto-queue"))else k.logger:warn("Event","Hauntlet: join circle unavailable ("..
(tostring(B)..")"))end local U=P.now()+120 local Z=P.now()+20 while not A.joinAcceptedAt and(not
A.join and P.now()<U)do if l and P.now()>=Z then
k.interaction:teleportToHauntletJoinZone()Z=P.now()+20 end k.waitUntil(function()return
A.joinAcceptedAt~=nil or A.join~=nil end,2)end if not A.joinAcceptedAt and not A.join then return
false,"not auto-queued from the join circle within 120 s"end end if not
k.waitUntil(function()return A.join~=nil end,90)then return false,"queued, but no run took me in
within 90 s"end else k.logger:info("Event","Hauntlet: resuming pending run ("..
(tostring(A.join.sessionId)..")"))end local b=A.join and A.join.sessionId if type(b)~="string"then
return false,"no session id after join"end A.lastRunStart=(Z and tonumber(Z.start))or
B.serverNow()if not k.waitUntil(function()return A.enter~=nil or Y()or A.leave~=nil or
A.kicked~=nil end,45)then return false,"did not get into the run ("..(tostring(b)..")")end local
function M()return A.leave~=nil or A.kicked~=nil end local O=H.HauntletStrategy or U.DEFAULTS local

C=H.HauntletDebug==true or A:_squadKey()~=nil local function G(P)k.logger:info("Hauntlet",P)end
local function w(P)if C then k.logger:info("Hauntlet",P)else k.logger:debug("Hauntlet",P)end end
local function V()local P=k.farmConfig return type(P)=="table"and((P.Enabled==false
or(type(P.Event)=="table"and P.Event.Hauntlet==false)))end
pcall(function()k.interaction:watchHauntlet(A.join and A.join.interior)end)local t,R,q,K=0,0,0,nil
local y=nil local i={}local d=nil local s={}local a=nil local X,F=nil,nil local function h(P)local
l,B=pcall(function()return k.interaction.hauntletCenter(P)end)return l and B or nil end G("Client
state synchronized: hearts "..(tostring(A.health or"?")..("/"..(tostring(A.maxHealth or"?")..(",
items "..U.describeItems(A.inventory))))))while not M()do if V()then G("Stopped: Auto Hauntlet or
Farm running was switched off")break end if not k.waitUntil(function()return M()or
V()or(A.room~=nil and A.room.seq~=q)end,90)then k.logger:warn("Hauntlet","No new room for 90 s:
leaving the run loop")break end if M()or V()then break end local l=A.room q=l.seq
G(string.format("Room detected: #%d %s/%s, doors
%s",l.seq,tostring(l.area),tostring(l.kind),U.describeDoors(l.doors)))G(string.format("Health:
%d/%d%s | Items available: %s",A.health or 3,A.maxHealth or 3,((A.tempHealth or 0))>0 and(" +"..
(A.tempHealth.." shield"))or"",U.describeItems(A.inventory)))k.waitUntil(function()local
k=n()return M()or A.room~=l or(k~=nil and not k.Anchored)end,6)local B,Z,m,Q,f,Y={},nil,nil,{},0,0
local L=type(k.farmConfig)=="table"and(type(k.farmConfig.Event)=="table"and
k.farmConfig.Event.HauntletMove)or"tween"local
C=type(k.farmConfig)=="table"and(type(k.farmConfig.Event)=="table"and
tonumber(k.farmConfig.Event.HauntletMoveSeconds))or nil local p={}local x,E=false,0 local I={items=
{},hearts=string.format("%d/%d%s",A.health or 3,A.maxHealth or 3,((A.tempHealth or 0))>0
and("+"..A.tempHealth)or"")}local
o=type(k.farmConfig)=="table"and(type(k.farmConfig.Event)=="table"and
k.farmConfig.Event.HauntletSquad~=false)local e,u=A:squadOrder()local T=A.squadIds local function
r()if A.squadIds~=T then T=A.squadIds e,u=A:squadOrder()end return o and#e>1 end if r()then
G(string.format("Squad: %d player%s%s, I am #%d (fewest hearts first) | phone turn at %.1f
s",#e,#e==1 and""or"s",A.squadIds and" (your accounts)"or" (everyone
alive)",u,A:turnAt("cell_phone",u,O)))end local v=nil local J="Exit"if F and((F.kind=="nexus"or
F.kind=="final_nexus"))then for k=1,4,1 do local P=F.doors[k]if P and
P.kind=="area:"..tostring(l.area)then J="Exit"..k end end end local function c()if v and v.Parent
then return v end v=nil if X and X.Parent then local P,l=pcall(function()return
k.interaction:hauntletNextGroup(A.join and A.join.interior,X,J)end)if P and l then v=l end end
return v end k.waitUntil(function()return M()or A.room~=l or c()~=nil or X==nil end,3)do local
k=U.readHotbar()if k and A.room==l then local P={}for k,l in pairs(k)do if((A.inventory[k]or 0))~=l
then table.insert(P,string.format("%s %d -> %d",k,A.inventory[k]or 0,l))A.inventory[k]=l end end
if#P>0 then table.sort(P)G("Items from the game\'s hotbar: "..table.concat(P,", "))end end end
O=setmetatable({tie={math.random();math.random();math.random();math.random()}},
{__index=H.HauntletStrategy or U.DEFAULTS})local D=tonumber(O.planSeconds)or U.DEFAULTS.planSeconds
local S=tonumber(O.commitBySeconds)or U.DEFAULTS.commitBySeconds while not M()and(A.room==l and not
V())do f=f+(1)if f>150 then k.logger:warn("Hauntlet","Room "..(l.seq..": too many steps, waiting
for the room to end"))k.waitUntil(function()return M()or A.room~=l end,30)break end local
H=A:view()H.tried=B local n=U.decide(H,O)if not x then x=true local k,P=pcall(U.plan,H,O)if k
and(type(P)=="table"and#P>0)then G(string.format("Plan for room %d (hearts %d/%d%s):
%s",l.seq,A.health or 3,A.maxHealth or 3,((A.tempHealth or 0))>0 and(" +"..(A.tempHealth.."
temp"))or"",table.concat(P," -> ")))end end local V=A:roomElapsed()if n.use
and(U.SHARED_ITEMS[n.use]and(r()and V<S))then local P=A:turnAt(n.use,u,O)if V<P then local
B,U,Z=A.revealedGhost,l.safe,l.lockVersion w(string.format("Waiting for my turn (#%d) for the %s:
%.1f s -> %.1f s",u,n.use,V,P))k.waitUntil(function()return M()or A.room~=l or A.revealedGhost~=B
or l.safe~=U or l.lockVersion~=Z or A:roomElapsed()>=P end,(P-V)+.1)if A.revealedGhost~=B and
A.revealedGhost then G("Door outcomes: a squad phone shows the ghost behind door
"..A.revealedGhost)x=false end continue end end if not n.use and(not n.wait and(n.risky
and(r()and(A.revealedGhost==nil and(not l.safe and V<D)))))then local P,B=A.revealedGhost,l.safe
w(string.format("Ghost unknown: the squad picks at %.0f s (now %.1f
s)",D,V))k.waitUntil(function()return M()or A.room~=l or A.revealedGhost~=P or l.safe~=B or
A:roomElapsed()>=D end,(D-V)+.1)if A.revealedGhost then G("Door outcomes: a phone shows the ghost
behind door "..A.revealedGhost)x=false end continue end if n.use then if n.use~="ghost_potion"then
B[n.use]=true end local Z=A.tempHealth or 0 local H=0 for k=1,4,1 do local P=l.doors[k]if P
and((((P.grey or 0))>0 or((P.gold or 0))>0))then H=H+(1)end end if false and(((n.use=="key"or
n.use=="gold_key"))and(n.door and H>1))then
A.expectDoor,A.expectAt,A.mappingSuspect=n.door,P.now(),nil local
l,B,U,Z=k.interaction:teleportToHauntletDoor(A.join and A.join.interior,n.door,
{avoid=p,bad=Q;method=L,link=y,visited=i;base=d;passed=s;behind=a;seconds=C;group=c()})if l then
m=Z w("At door "..(n.door..(" for the key ("..(tostring(B)..")"))))end end local f=A.usedSeq local
Y=pcall(function()k.interaction:send("HauntletMessage",b,"try_use_item",n.use)end)if Y then
k.waitUntil(function()return A.usedSeq>f or M()or A.room~=l end,5)end local O=A.usedItems[f+1]if O
and O.ok then R=R+(1)G(string.format("Used %s | Reason:
%s",n.use,n.reason))table.insert(I.items,string.format("%s@%.1f",
(string.gsub(n.use,"_potion","P")),A:roomElapsed()))if n.use=="cell_phone"then
k.waitUntil(function()return A.revealedGhost~=nil or M()or A.room~=l end,4)if A.revealedGhost then
local k=U.twoGhostChance(l.seq)G("Door outcomes: ghost behind door "..(A.revealedGhost..((k>=.1 and
string.format(" (a second ghost elsewhere: %d%%)",math.floor(k*100+.5))or", the other doors are
safe"))))x=false end elseif((n.use=="key"or n.use=="gold_key"))and n.door then
k.waitUntil(function()local k=l.doors[n.door]return M()or A.room~=l or(k~=nil and(((k.grey or

0))==0 and((k.gold or 0))==0))end,4)elseif n.use=="rainbow_wand"then G("Door outcomes: the wand
cleared this room, every door is safe")elseif n.use=="ghost_potion"then E=E+
(1)k.waitUntil(function()return((A.tempHealth or 0))>Z or M()or A.room~=l end,1.5)if A.room==l
and(not M()and((A.tempHealth or 0))<=Z)then B.ghost_potion=true if Z>0 then
U.learnedTempCap=math.max(U.learnedTempCap or 0,Z,2)G("Ghost potion refused at "..(Z.." temp
hearts"))end end if E>=4 then B.ghost_potion=true end end else B[n.use]=true G(string.format("%s
was not used (%s)",n.use,O and"the game refused it"or"no answer"))end elseif n.wait then
w(n.reason)k.waitUntil(function()return M()or A.room~=l or A.revealedGhost~=nil end,1)if
A.revealedGhost then G("Door outcomes: another player\'s phone shows the ghost behind door
"..A.revealedGhost)x=false end else local B=n.door local U=l.doors[B]and l.doors[B].kind or"?"if
B~=Z then for k=1,4,1 do if n.notes and n.notes[k]then w(n.notes[k])end end
G(string.format("Decision: door %d (%s) | Reason: %s%s",B,U,n.reason,n.risky and" (not verified
safe)"or""))Z=B end if A.myDoor==B then local P,U,Z=A.revealedGhost,l.safe,l.lockVersion
k.waitUntil(function()return M()or A.room~=l or A.revealedGhost~=P or l.safe~=U or A.myDoor~=B or
l.lockVersion~=Z end,2)else G(string.format("Entering selected door %d at %.1f
s",B,A:roomElapsed()))I.door,I.doorAt=B,A:roomElapsed()local
U=P.now()A.expectDoor,A.expectAt,A.mappingSuspect=B,U,nil local
Z,H,f,n,b=k.interaction:teleportToHauntletDoor(A.join and A.join.interior,B,
{avoid=p;bad=Q;method=L,nexus=l.kind=="nexus"or
l.kind=="final_nexus";link=y,visited=i;base=d;passed=s;behind=a,seconds=C,group=c()})if Z then m=n
t=t+(1)k.waitUntil(function()return M()or A.room~=l or(A.myDoorAt~=nil and
A.myDoorAt>=U)end,1.5)local P=A.lastPickSeq==l.seq and(A.lastPickAt~=nil and A.lastPickAt>=U)if P
and(n and not v)then v=n end if P and n then if l.kind=="nexus"or l.kind=="final_nexus"then local
k=h(n)for k in pairs(i)do s[k]=true end if d and k then a={base=d;limit=((k-d)).Magnitude}end i=
{}d=k elseif d==nil then d=h(n)end i[n]=true local k=(A.room==l and A.myDoor)or(A.lastOpened
and(A.lastOpened.seq==l.seq and A.lastOpened.myDoor))or B y={from=n;exit=((l.kind=="nexus"or
l.kind=="final_nexus"))and("Exit"..tostring(k))or"Exit"}end if A.room==l and not M()then local
P=A.mappingSuspect if A.myDoorAt and(A.myDoorAt>=U and(not b and(P and P~=B)))then
k.logger:warn("Hauntlet",string.format("Door mapping WRONG: %s is door %d, not %d; trying another
circle",tostring(H),P,B))Q[f]=true A.myDoor=P elseif A.myDoorAt and A.myDoorAt>=U then
G(string.format("Picked: door %d (%s%s)",B,tostring(H),b and""or", guessed circle"))else Y=Y+
(1)G(string.format("No pick seen after the move to door %d (%s%s), try %d: trying another circle
group",B,tostring(H),b and""or", unverified",Y))if n then if p[n]then p={}Q={}else p[n]=true end
end end end else Y=Y+(1)k.logger:warn("Hauntlet","Could not reach door "..(B..(":
"..tostring(H))))task.wait(1)end end end end K=m or K X,F=v,l
A:_debugFlush()k.waitUntil(function()return M()or(A.lastOpened~=nil and
A.lastOpened.seq==l.seq)end,3)local j=A.lastOpened if j and j.seq==l.seq then local k={}for P=1,4,1
do if j.ghosts[P]then table.insert(k,tostring(P))end end G(string.format("Room transition verified:
room %d, I was at door %s, ghost behind %s%s",l.seq,tostring(j.myDoor or"?"),#k>0 and
table.concat(k,", ")or"no door",j.damage>0 and string.format(" (-%d heart%s)",j.damage,j.damage==1
and""or"s")or""))end pcall(function()local P={}for k=1,4,1 do local B=l.doors[k]if B and
B.exists~=false then table.insert(P,string.sub(tostring(B.kind),1,8)..(((B.wasLocked
and"*")or"")))end end local B={}for k=1,4,1 do if j and(j.seq==l.seq and j.ghosts[k])then
table.insert(B,tostring(k))end end k.logger:info("HauntletDigest",string.format("R%d %s | sq %d
#%d%s | h %s | %s | reveal %s | %s | door %s@%s | ghost %s | dmg
%s",l.seq,tostring(l.area),#e,u,A.squadIds and"k"or"",I.hearts,table.concat(P,","),
((function()local k=((A.lastReveal and A.lastReveal.seq==l.seq))and A.lastReveal
or{door=A.revealedGhost,at=A.revealedAt and(A.revealedAt-l.at);safe=l.safe}if k.safe then
return"wand"end return k.door and string.format("d%d@%.1f",k.door,k.at or 0)or"-"end))(),#I.items>0
and table.concat(I.items," ")or"no items",tostring((j and(j.seq==l.seq and j.myDoor))or I.door
or"?"),I.doorAt and string.format("%.1f",I.doorAt)or"?",#B>0 and
table.concat(B,"+")or"none",tostring(j and(j.seq==l.seq and j.damage)or"?")))end)end if V()and not
M()then G("Switched off during the run: the run is yours now (no travel, nothing more sent)")return
false,"switched off during the run"end k.waitUntil(function()return A.leave~=nil
end,25)k.waitUntil(function()return not Y()end,15)local p=tonumber(k.gameData:get(Q.Candy))local x=
((p and f))and(p-f)or nil local E=A.leave k.logger:info("Event",string.format("Hauntlet: %s, room
reached %s (best %s), %d door steps, %d items, reward %s candy%s",A.kicked
and((A.kicked=="died"and"died"or("kicked out ("..(A.kicked..")"))))or"run finished",tostring(E and
E.roomReached or A.roomSeq),tostring(E and E.best or"?"),t,R,tostring(E and E.candy or"?"),x and
string.format(", candy %+d",x)or""))if E and((m._journalAt==nil or P.now()-m._journalAt>600))then
m._journalAt=P.now()local
l=k.gameData:get(Q.Hauntlet)pcall(function()k.interaction:send("UnlockHauntletJournal")end)k.waitUn
til(function()return k.gameData:get(Q.Hauntlet)~=l end,5)local B=k.gameData:get(Q.Hauntlet)if
type(B)=="table"then k.logger:info("Event","Hauntlet: journal pages
"..tostring(B.pages_unlocked))end end if A.leave~=nil or not Y()then local
P,B=k.travel:goTo(l.HouseInteriorName)if not P then k.logger:info("Event","Hauntlet: going home
after the run did not work ("..(tostring(B)..")"))end else k.logger:info("Event","Hauntlet: the run
is still going: no travel out of a run")end if t==0 then return false,A.kicked and("kicked before a
door: "..A.kicked)or"no door stepped into"end if not E and not((x and x>0))then return
false,A.kicked and("died in room "..(A.roomSeq..", no reward seen"))or"run did not end"end return
true end}function m.newToken()local
k,P=pcall(function()return(game:GetService("HttpService")):GenerateGUID(false)end)return
string.lower(k and tostring(P)or string.format("%08x-0000-4000-8000%012x",math.random(0,2147483647),os.time()))end function m.pickTarget(k,P,l)local B=n()if not B

then return nil end local U,Z,A for k,P in ipairs(m.findGhosts(P))do local l=L(P.model)if l then
local k={kind="ghost";id=P.id,position=l;model=P.model,boss=P.size==H.BossSize}if k.boss then A=A
or k else local P=b(l,B.Position)if not U or P<Z then U,Z=k,P end end end end if U or A then return
U or A end local f=k.gameData:get(Q.Interior)local
Y=type(f)=="table"and(type(f.furniture)=="table"and f.furniture)or{}for k in pairs(l.haunted)do
local P=Y[k]local l,m=pcall(function()return P.cframe.Position end)if l and(m~=nil and
type(m.X)=="number")then local P=b(m,B.Position)if not U or P<Z then U,Z=
{kind="prop",id=k;position=m},P end end end return U end m.quests=
{id="quests";timeoutSeconds=30,run=function(k)local function P(P)local
l=k.gameData:get(Q.Dailies)local B=type(l)=="table"and(type(l.serialized_tabs)=="table"and
l.serialized_tabs[P])if type(B)~="table"then return"none"end local U=
{tostring(B.reward_claimed),tostring(B.total_dailies_completed)}for k,P in
pairs(type(B.active_dailies)=="table"and B.active_dailies or{})do local
l=type(P)=="table"and(type(P.state)=="table"and P.state)or{}table.insert(U,tostring(k)..
(":"..tostring(l.steps_completed)))end table.sort(U)return table.concat(U,"|")end local
l=m.questsToClaim(k.gameData:get(Q.Dailies))if#l==0 then return true end local B=0 for l,U in
ipairs(l)do local Z=P(U.tab)local
m,H=k.gameData:get(Q.Money),k.gameData:get(Q.Candy)k.interaction:send(U.action,U.tab)if
k.waitUntil(function()return P(U.tab)~=Z end,6)then B=B+(1)local P={}local
l,Z=k.gameData:get(Q.Money),k.gameData:get(Q.Candy)if tonumber(m)and(tonumber(l)and l>m)then
table.insert(P,"+"..((l-m).." Bucks"))end if tonumber(H)and(tonumber(Z)and Z>H)then
table.insert(P,"+"..((Z-H).." candy"))end k.logger:success("Event",string.format("Quests: %s
claimed on the %s board%s",U.action=="QuestTabReward"and"board reward"or"finished quest",U.tab,#P>0
and(" ("..(table.concat(P,", ")..")"))or""))else k.logger:info("Event","Quests: "..(U.action..("
("..(U.tab..") changed nothing in my data"))))end end if B==0 then return false,"no quest claim
changed my data"end return true end}m.VisitQuests=
{housewarming=true;neighborhood_tour=true}function m.visitQuest(k)local
P=type(k)=="table"and(type(k.serialized_tabs)=="table"and k.serialized_tabs)or{}for k,P in
pairs(P)do for k,P in pairs(type(P)=="table"and(type(P.active_dailies)=="table"and
P.active_dailies)or{})do local l=type(P)=="table"and(type(P.state)=="table"and P.state)or nil if
m.VisitQuests[k]and l then local P,B=tonumber(l.steps_to_complete)or
0,tonumber(l.steps_completed)or 0 if B<P then local U={}for k in
pairs(type(l.houses_visited_by_userid)=="table"and l.houses_visited_by_userid or{})do
U[tostring(k)]=true end return{kind=k;need=P,done=B;visited=U}end end end end return nil end
m._visitTried={}local V=2 m.houseVisits={id="house_visits";timeoutSeconds=120,run=function(k)local
l=m.visitQuest(k.gameData:get(Q.Dailies))if not l then return true end local
B=game:GetService("Players")local U=B.LocalPlayer local Z,H=0,0 for B,A in ipairs(B:GetPlayers())do
if H>=V then break end local f=tostring(A.UserId)local Y=m._visitTried[f]if A~=U and(not
l.visited[f]and not((Y and P.now()-Y<1800)))then H=H+
(1)m._visitTried[f]=P.now()k.travel:visitHouse(A)local B=k.waitUntil(function()local
P=m.visitQuest(k.gameData:get(Q.Dailies))return P==nil or P.visited[f]==true or P.done>l.done
end,15)if B then Z=Z+(1)local
P=m.visitQuest(k.gameData:get(Q.Dailies))k.logger:success("Event",string.format("Quest %s: visited
%s\'s house (%d of %d)",l.kind,A.Name,P and P.done or l.need,l.need))else
k.logger:info("Event","Quest "..(l.kind..(": the visit to "..(A.Name.." did not count"))))end
k.travel:goTo("MainMap")l=m.visitQuest(k.gameData:get(Q.Dailies))if not l then break end end end if
H==0 then k.logger:info("Event","Quest: no other player\'s house left to visit on this
server")return true end if Z==0 then return false,"house visits did not count for the quest"end
return true end}function m.potionList(k)local P=type(k.AutoPotions)=="table"and k.AutoPotions
or{}local B={}for k,P in ipairs(type(P.Skip)=="table"and P.Skip or{})do B[P]=true end local U={}for
k,P in ipairs(type(P.Potions)=="table"and P.Potions or l.AgePotions)do if not B[P]then
table.insert(U,P)end end return U end function m.potionTarget(k,P)local
B=type(P.AutoPotions)=="table"and P.AutoPotions or{}local U={}for k,P in
ipairs(type(B.PetKinds)=="table"and B.PetKinds or{})do U[P]=true end local Z=l.focusKind(P)if Z
then U={[Z]=true}end for P,B in ipairs(k:equippedPetList())do local Z=B.unique and
k:petAge(B.unique)if Z and(Z<l.FullGrownAge and((next(U)==nil or
U[k:getPetKind(B.unique)or""])))then return B.unique end end return nil end m.agePotion=
{id="age_potion",timeoutSeconds=40;run=function(k)local
P=m.potionTarget(k.gameData,k.farmConfig)local B=m.potionList(k.farmConfig)local U=#B>0
and(k.gameData:findItems(l.ItemCategory,B))[1]or nil if not P or not U then return true end local
H=k.gameData:petAge(P)local Q=k.gameData:getPetKind(P)or P local
A,f=Z.givePetItem(k,P,U,function()return k.gameData:itemUsesLeft(l.ItemCategory,U.unique)==nil
or((k.gameData:petAge(P)or 0))>((H or 0))end,"age potion")if not A then return false,f end
k.waitUntil(function()return((k.gameData:petAge(P)or 0))>((H or
0))end,3)k.logger:success("Event",string.format("Potion %s on %s (age %s ->
%s)",U.id,Q,tostring(H),tostring(k.gameData:petAge(P))))return true end}function
m.neonPick(k,P,B)local U=type(P.AutoNeon)=="table"and P.AutoNeon or{}local Z={}for k,P in
ipairs(type(U.Exclude)=="table"and U.Exclude or{})do Z[P]=true end local m,H local
Q=k:neonFusionGroups(Z,B)local A=l.focusKind(P)if A and(type(Q[A])=="table"and#Q[A]>=4)then local
k=Q[A]return A,{k[1],k[2];k[3];k[4]}end for k,P in pairs(Q)do if#P>=4 and((not H or#P>#H or(#P==#H
and k<m)))then m,H=k,P end end if not H then return nil end return m,{H[1];H[2];H[3],H[4]}end local
t,R,q=.12,.08,.15 local function K(k)return{id=k
and"mega_fusion"or"neon_fusion";timeoutSeconds=40;run=function(l)local
B,U=m.neonPick(l.gameData,l.farmConfig,k)if not B then return true end local function Z()return k

and l.gameData:megaCountOfKind(B)or l.gameData:neonCountOfKind(B)end local H=Z()for k,P in
ipairs(U)do l.interaction:send("EquipItem",P,
{equip_as_last=false,use_sound_delay=false})task.wait(t)l.interaction:send("UnequipItem",P,nil)task
.wait(R)end task.wait(q)local Q,A=l.interaction:send("NeonFusion",{U[1],U[2];U[3],U[4]})local
f=type(A)=="string"and A or nil local function Y()if f and((k and l.gameData:isPetMega(f)or not k
and l.gameData:isPetNeon(f)))then return true end local P=0 for k,B in ipairs(U)do if
l.gameData:petAge(B)==nil then P=P+(1)end end return P>=3 and Z()>H end if l.waitUntil(Y,6)then if
k then l.logger:success("Event",string.format("Mega neon fusion: 4 neon %s -> 1 mega neon %s (mega
%s now: %d)",B,B,B,Z()))else l.logger:success("Event",string.format("Neon fusion: 4 %s -> 1 neon %s
(neon %s now: %d)",B,B,B,Z()))end return true end return false,string.format("%s fusion of 4 %s not
seen in my data (server answer: %s %s)",k and"mega
neon"or"neon",B,tostring(Q),P.truncate(tostring(A),60))end}end
m.neonFusion=K(false)m.megaFusion=K(true)function m.candyPetTarget(k,P)local
B=tonumber(k:get(l.DataKeys.Candy))if not B then return nil end if type(P.Pick)=="table"then local
k={}for P,l in ipairs(P.Pick)do k[l]=true end for l,U in ipairs(type(P.Buy)=="table"and P.Buy
or{})do local Z,m=U.id or U[1],tonumber(U.price)if type(Z)=="string"and(k[Z]and(m and(m>0 and B((tonumber(P.KeepCandy)or 0))>=m)))then return{id=Z,price=m}end end return nil end for l,U in
ipairs(type(P.Buy)=="table"and P.Buy or{})do local Z,m,H=U.id or
U[1],tonumber(U.price),tonumber(U.max)or 0 if type(Z)=="string"and(m and m>0)then local l=0 for k
in pairs(k:petUniquesOfKind(Z))do l=l+(1)end if H<=0 or l<H then if B-((tonumber(P.KeepCandy)or
0))>=m then return{id=Z,price=m}end return nil end end end return nil end m.buyCandyPet=
{id="candy_pet",timeoutSeconds=75;run=function(k,B)local U=k.farmConfig.Event and
k.farmConfig.Event.CandyPets or{}local Z=B and B.pick or m.candyPetTarget(k.gameData,U)if not Z
then return true end local H,Q=math.max(1,math.min(tonumber(Z.count)or 1,8)),0 local
A=tonumber(k.gameData:get(l.DataKeys.Candy))or 0 for B=1,H,1 do local
U=tonumber(k.gameData:get(l.DataKeys.Candy))or 0 if Q>0 and U-((tonumber(Z.keepCandy)or 0))<Z.price
then break end local m=k.gameData:petUniquesOfKind(Z.id)local
H,A=k.interaction:send("BuyItem",l.EggCategory,Z.id,{buy_count=1})local f k.waitUntil(function()for
k in pairs(k.gameData:petUniquesOfKind(Z.id))do if not m[k]then f=k return true end end return
false end,8)if not f then if Q>0 then break end return false,string.format("no %s arrived in your
backpack (server answer: %s %s)",Z.id,tostring(H),P.truncate(tostring(A),60))end Q=Q+(1)end local
f=tonumber(k.gameData:get(l.DataKeys.Candy))or A k.logger:success("Event",string.format("Bought %d
x %s for %d candy (candy left: %d)",Q,Z.id,A-f,f))if B and B.onBought then B.onBought()end return
true end}function m.nextGift(k,P)local B=type(P.AutoOpen)=="table"and P.AutoOpen or{}local U={}for
k,P in ipairs(type(B.Exclude)=="table"and B.Exclude or{})do U[P]=true end local Z={}for k,P in
ipairs(k:findItems(l.GiftCategory,nil))do if not U[P.id]then for k,l in pairs(l.GiftPatterns)do if
string.find(P.id,l)then table.insert(Z,{unique=P.unique,id=P.id;how=k})end end end end
table.sort(Z,function(k,P)return k.unique<P.unique end)return Z[1]end m.openGift=
{id="open_gift",timeoutSeconds=30,run=function(k)local P=m.nextGift(k.gameData,k.farmConfig)if not
P then return true end local function B()return
k.gameData:itemUsesLeft(l.GiftCategory,P.unique)==nil end k.interaction:send("EquipItem",P.unique,
{})task.wait(.5)k.interaction:send("UseTool",P.unique,"START")task.wait(1)if P.how=="gift"then
k.interaction:send("OpenGift",P.unique)k.waitUntil(B,4)k.interaction:send("UseTool",P.unique,"END",
nil)else
k.interaction:send("UnequipItem",P.unique,nil)k.interaction:send("UseTool",P.unique,"END",nil)k.int
eraction:send("OpenChest",P.id,P.unique)end if k.waitUntil(B,6)then
k.logger:success("Event","Opened "..P.id)return true end
k.interaction:send("UnequipItem",P.unique,nil)return false,P.id.." is still in the backpack after
opening"end}return m end P["Game/TaskManager"]=function(...)local k=...local P=k("Core/Util")local
l=k("Core/Maid")local B=k("Game/GameConstants")local U=k("Game/Tasks")local
Z=k("Game/EventTasks")local m=k("Game/Minigame")local H={}H.__index=H local Q="team"local A=
{ghost_gallery=120,stray_cat=1800;crypt=60;pigeon_nest=60,quests=300,pen_stock=20;age_potion=5;open
_gift=3;neon_fusion=2,mega_fusion=2,candy_pet=30;house_visits=300;hauntlet=90;skelicorn=120}local
f=75 local Y=50 local n=45 local L=420 local b=42 local M=270 local O=600 local C=
{ghost_gallery=true;hauntlet=true,recover=true;team=true;neon_fusion=true;mega_fusion=true}local G=
{neon_fusion=true,mega_fusion=true;team=true}local w=90 local V=12 local t=8 local R=3 local q=4
local K=2 function H.new(k)local l=setmetatable({},H)l._logger=k.logger l._state=k.state
l._tracker=k.tracker l._interaction=k.interaction l._travel=k.travel l._petLocator=k.petLocator
l._furniture=k.furniture l._gameData=k.gameData l._farmConfig=k.farmConfig l._minigame=k.minigame
l._hauntlet=k.hauntlet l._nextEventAt={}l._running=nil l._stopped=false l._failures=
{}l._cooldownUntil={}l._disabled={}l._disabledUntil={}l._lastSuccessAt=P.now()l._completions=
{}l._announcedUnsupported={}l._state:set("farm.currentTask","none","TaskManager")return l end
function H.start(l,k)k:Give(l._tracker.Completed:Connect(function(k,B,U)l._completions[U..("|"..
(k..("|"..tostring(B))))]=P.now()end))k:Give(function()l:stop()end)end function H._isDoable(P,k)if
k.owner~="pet"or not P._gameData then return true end return
P._gameData:isPetEquipped(k.petUnique)end function H._group(P,k)local l=nil for B,U in
ipairs(P._state:get("ailments.active",{}))do if U.kind==k and P:_isDoable(U)then l=l
or{kind=k,entries={},anyInProgress=false;maxRate=0;oldest=math.huge}table.insert(l.entries,U)if
U.owner=="pet"and not l.petEntry then l.petEntry=U end if U.inProgress then l.anyInProgress=true
end l.maxRate=math.max(l.maxRate,U.rate or 0)l.oldest=math.min(l.oldest,U.createdAt or
math.huge)end end return l end function H._isBlocked(l,k)return l._disabled[k]or P.now()
<((l._cooldownUntil[k]or 0))end function H._expireDisabled(k)local l=P.now()for P,B in
pairs(k._disabledUntil)do if l>=B then k._disabledUntil[P]=nil k._disabled[P]=nil k._failures[P]=0
k._logger:info("Tasks","\'"..(tostring(P).."\' rested long enough: trying it again

(Farm.DisableMinutes)"))end end end function H._priorityOf(l,k,P)local
U=l._farmConfig.Priority[k]or 0 if l._farmConfig.SmartPriority==false or not l._travel then return
U end local Z=B.LocationForAilment[k]if Z and(not B.SpotForAilment[k]and l._travel:isAt(Z))then
U=U+(V)elseif B.FurnitureForAilment[k]and l._travel:isAt(B.HouseInteriorName)then U=U+(t)end if P
and P.anyInProgress then U=U+(R)end return U end function H._selectGroup(k)if k._travel then for
P,l in ipairs(k._state:get("ailments.active",{}))do local Z=B.LocationForAilment[l.kind]if
l.inProgress and(Z and(not B.SpotForAilment[l.kind]and(not
k._disabled[l.kind]and(B.needOn(k._farmConfig,l.kind)and k._travel:isAt(Z)))))then local
P=k:_group(l.kind)if P then return P,U.findFor(l.kind)end end end end local P,l,Z=nil,nil,math.huge local m={}for H,Q in ipairs(k._state:get("ailments.active",{}))do local A=Q.kind if not
m[A]then m[A]=true local H=U.findFor(A)if not H or not B.needOn(k._farmConfig,A)then if not
k._announcedUnsupported[A]then k._announcedUnsupported[A]=true local P=H and"switched off: Auto
needs is off or this need is skipped"or"no automatic task yet"k._logger:info("Tasks","Skipping
\'"..(A..("\' ("..(P..")"))))end elseif not k:_isBlocked(A)then local B=k:_group(A)local U=B and
k:_priorityOf(A,B)or 0 if B and((U>Z or(U==Z and B.oldest<P.oldest)))then P,l,Z=B,H,U end end end
end return P,l end function H._needsTeamSwitch(k)local P=k._state:get("player.team")return
k._farmConfig.BabyMode and(P~=nil and(P~=B.BabiesTeam and not k:_isBlocked(Q)))end local y=
{goTo=true,exitToMainMap=true;visitHouse=true}local function i(k)if not k then return nil end
return setmetatable({},{__index=function(P,l)if y[l]then return function()return false,"side task:
no travel (the main task holds the place)"end end local B=k[l]if type(B)=="function"then return
function(P,...)return B(k,...)end end return B end})end function H._makeContext(U,k,l,B)local Z=
{logger=U._logger,state=U._state;interaction=U._interaction;travel=B and(B.side and i(U._travel))or
U._travel;side=B and B.side or
nil,petLocator=U._petLocator,furniture=U._furniture,gameData=U._gameData;farmConfig=U._farmConfig;m
inigame=U._minigame;hauntlet=U._hauntlet;maid=k}function Z.waitUntil(k,l)local B=P.now()+l while
true do if k()then return true end if P.now()>=B then return false end task.wait(.25)end end
function Z.completedSince(k,P,B)local Z=U._completions[k..("|"..(P..("|"..tostring(B))))]return
Z~=nil and Z>=l end function Z.setWaiting(k)if B then B.waiting=k==true end end function
Z.currentGroup(k)return U:_group(k)end function Z.findEntry(k,P,l)for B,U in
ipairs(U._state:get("ailments.active",{}))do if U.kind==k and(U.owner==P and((P=="baby"or
U.petUnique==l)))then return U end end return nil end function Z.isKindGone(k)return
U:_group(k)==nil end function Z.kindCompletedSince(k,P)for l,B in pairs(U._completions)do if B>=P
and string.sub(l,1,#k+1)==k.."|"then return true end end return false end return Z end function
H._start(Q,k,B,U,Z,m,H)local A=H and"_side"or"_running"local f=((Q._failures[k]or 0))+1 local
Y=l.new()local n=P.now()local L=
{key=k;label=B,startedAt=n;deadline=n+U.timeoutSeconds;maid=Y;eventJob=m==true,side=H==true}Q[A]=L
if H then L.label="(side) "..B else Q._state:set("farm.currentTask",k,"TaskManager")end
Q._logger:info("Tasks",string.format("Start: %s (attempt %d, limit %d
s)",L.label,f,U.timeoutSeconds))local b=Q:_makeContext(Y,n,L)L.thread=task.spawn(function()local
k,P,l=pcall(U.run,b,Z,f)if Q[A]~=L then return end if not k then Q:_finish("FAILED","script error:
"..tostring(P),A)elseif P==true then Q:_finish("SUCCESS",nil,A)else Q:_finish("FAILED",tostring(l
or"unknown reason"),A)end end)end function H._finish(U,k,l,B)B=B or"_running"local Z=U[B]if not Z
then return end U[B]=nil if B=="_side"then local k=U._farmConfig.MultiNeed
U._sideNextAt=P.now()+math.max(0,tonumber(type(k)=="table"and k.GapSeconds)or 2)end if Z.thread and
coroutine.running()~=Z.thread then pcall(task.cancel,Z.thread)end
task.spawn(function()Z.maid:Clean()end)if B=="_running"then
U._state:set("farm.currentTask","none","TaskManager")end local m=Z.key local H=P.now()-Z.startedAt
if k=="INTERRUPTED"then if Z.eventJob then U._nextEventAt[m]=0 end
U._logger:info("Tasks",string.format("Interrupted: %s after %.1f s
(%s)",Z.label,H,tostring(l)))return end if Z.eventJob then local k=m=="pet_pen"and
math.max(1,tonumber(U._farmConfig.Event.PetPenMinutes)or 15)*60 or A[m]or 60
U._nextEventAt[m]=P.now()+k end if m=="ghost_gallery"then local k=U:_autoNest()if
k=="COLLECT_TWIGS"or k=="BUILD_NEST"then U._logger:info("Ghost","Minigame complete: resuming
AutoNest ("..(k..")"))end end local
Q=k~="SUCCESS"and(type(l)=="string"and((string.find(l,"travel",1,true)or string.find(l,"still
in",1,true)or string.find(l,"going home",1,true))))if Q and(m~="recover"and B=="_running")then
U._travelFailures=((U._travelFailures or 0))+1 elseif k=="SUCCESS"then U._travelFailures=0 end if
k=="SUCCESS"then U._stuckSince=nil U._lastSuccessAt=P.now()U._watch=nil U._failures[m]=0
U._state:increment("farm.tasksSucceeded",1,"TaskManager")U._logger:success("Tasks",string.format("D
one: %s in %.1f s",Z.label,H))return end U._state:increment("farm.tasksFailed",1,"TaskManager")if
k=="CANCELLED"then U._logger:info("Tasks",string.format("Stopped: %s after %.1f s
(%s)",Z.label,H,tostring(l)))return end if type(l)=="string"and(string.sub(l,1,3)=="no "and
string.find(l," in your house",1,true))then U._cooldownUntil[m]=P.now()+O
U._logger:info("Tasks",string.format("Skipped for %d min: %s \226\128\148 %s (buy one to farm this
need)",O/60,Z.label,l))return end local f=((U._failures[m]or 0))+1 U._failures[m]=f
U._cooldownUntil[m]=P.now()+U._farmConfig.FailureCooldownSeconds if U._watch then
U._watch.failures=U._watch.failures+(1)end local Y=string.format("%s: %s after %.1f s \226\128\148
%s",k,Z.label,H,tostring(l))if f>=U._farmConfig.MaxConsecutiveFailures and m~="recover"then
U._disabled[m]=true local k=tonumber(U._farmConfig.DisableMinutes)or 0 if k>0 then
U._disabledUntil[m]=P.now()+k*60 U._logger:error("Tasks",Y..string.format(" (%d failures in a row:
disabled for %s min, then tried again)",f,tostring(k)))else
U._logger:error("Tasks",Y..string.format(" (%d failures in a row: disabled for this
session)",f))end else U._logger:warn("Tasks",Y..string.format(" (retry in %d
s)",U._farmConfig.FailureCooldownSeconds))end end function H._trackPet(k)if not k._gameData then

return end local P=k._gameData:firstEquippedPet()if P then k._lastPet=P k._farmPet=k._farmPet or P
if k._badPets then k._badPets[P]=nil end end end function H.tick(k)local l=P.now()local
B=math.min(l-((k._lastTickAt or l)),5)k._lastTickAt=l k._why=nil k:_tickInner()k._idle=k._idle
or{}if k._running then k._busy=((k._busy or 0))+B else local P=k._why or"nothing to do (no need /
job due)"k._idle[P]=((k._idle[P]or 0))+B end end function H.getDiagnostics(k)local l={}for k,P in
pairs(k._idle or{})do l[k]=math.floor(P/6+.5)/10 end local B={}for k,P in pairs(k._disabled or{})do
if P then table.insert(B,k)end end table.sort(B)local U={}for k,l in pairs(k._disabledUntil or{})do
U[k]=math.max(0,math.ceil(((l-P.now()))/60))end return{idle=l,busyMinutes=math.floor(((k._busy or
0))/6+.5)/10,disabled=B;restMinutes=U,running=k._running and k._running.label or nil;side=k._side
and k._side.label or nil}end function H._hasWork(k)for P,l in
ipairs(k._state:get("ailments.active",{}))do local Z=l.kind if
B.needOn(k._farmConfig,Z)and(U.findFor(Z)and(not k:_isBlocked(Z)and k:_isDoable(l)))then return
true end end return false end function H._stuckCheck(k)local l=k._farmConfig.StuckRecovery if
type(l)~="table"or not l.Enabled or k._state:get("game.ready")~=true or
k._state:get("session.disconnectReason")~=nil then k._watch=nil return false end if k._running and
C[k._running.key]then k._watch=nil return false end local B=
(game:GetService("Players")).LocalPlayer.Character local Z=B and
B:FindFirstChild("HumanoidRootPart")local m=Z and Z.Position local
H=k._state:get("player.interior")if not m or H==nil then return false end local Q=P.now()local
A=k._watch local f=A and math.sqrt(((m.X-A.x))^2+((m.Z-A.z))^2)>=q if not A or A.interior~=H or f
then k._watch={interior=H;x=m.X,z=m.Z;since=Q,failures=0}return false end local
Y=math.max(60,tonumber(l.Seconds)or 240)if Q-A.since<Y or A.failures<K then return false end if not
k._running and not k:_hasWork()then return false end k._watch=nil
k._logger:warn("Tasks",string.format("Stuck in %s: not moving, %d tasks failed, none finished for
%d s: going home (Farm.StuckRecovery)",tostring(H),A.failures,math.floor(QA.since)))k:_finish("INTERRUPTED","stuck recovery")k:_finish("INTERRUPTED","stuck
recovery","_side")k:_start("recover","recover: stuck, go home",U.recover,nil)return true end
function H._whiteScreenCheck(k)if k._state:get("session.disconnectReason")~=nil or(k._running
and(C[k._running.key]and k._running.key~="recover"))then k._blankSince,k._blankStep=nil,nil return
false end local l=(game:GetService("Players")).LocalPlayer.Character local B=l and
l:FindFirstChild("HumanoidRootPart")local U=k._state:get("game.ready")==true local
Z=k._state:get("player.team")local m=k._state:get("player.interior")if(B and(m~=nil and(U and
Z~="Choosing")))or(Z=="Choosing"and k._farmConfig.AutoAcceptMenu==false)then
k._blankSince,k._blankStep=nil,nil return false end local H=P.now()k._blankSince=k._blankSince or H
local Q=H-k._blankSince local A=string.format("ready %s, team %s, place %s, character
%s",tostring(U),tostring(Z),tostring(m),B and"yes"or"NO")local f=k._blankStep or 0 if(f==0 and
Q>90)or(f==1 and Q>180)then k._blankStep=f+1 k._logger:warn("Tasks",string.format("White screen? %d
s without a usable character / place (%s): respawning (try %d)",math.floor(Q),A,f+1))if
k._logger.saveProblemReport then k._logger:saveProblemReport()end
pcall(function()k._interaction:send("Respawn")end)return false end local
Y=math.max(120,tonumber(k._farmConfig.StuckRejoinSeconds)or 180)if f>=1
and(Q>math.max(Y,240)and(k._farmConfig.AutoRejoin and not k._rejoinSent))then k._rejoinSent=true
k:_rejoin(string.format("white screen for %d s (%s)",math.floor(Q),A))return true end return false
end function H._tickInner(k)if k._stopped or not k._farmConfig.Enabled then k._why=k._stopped
and"stopped"or"Farm.Enabled = false (watch only)"return end if k:_whiteScreenCheck()then return end
k:_expireDisabled()k:_trackPet()if k._side and P.now()>k._side.deadline then
k:_finish("TIMEOUT","no result within "..(math.floor(k._side.deadline-k._side.startedAt).."
s"),"_side")end if k:_stuckCheck()then return end if k._running then if P.now()>k._running.deadline
then k:_finish("TIMEOUT","no result within "..(math.floor(k._running.deadlinek._running.startedAt).." s"))elseif not C[k._running.key]and(k:_hauntletFirst()and
k:_hauntletRoundDue(b))then k._logger:info("Hauntlet","Priority interrupt: stopping "..
(k._running.label.." for the Hauntlet run"))k:_finish("INTERRUPTED","Hauntlet
run")k:_finish("INTERRUPTED","Hauntlet run","_side")elseif not
C[k._running.key]and(k:_ghostRoundDue(Y)and not((k:_hauntletFirst()and
k:_hauntletRoundDue(Y+M))))then k._logger:info("Ghost","Priority interrupt: stopping "..
(k._running.label.." for the Ghost Gallery round"))k:_finish("INTERRUPTED","Ghost Gallery
round")k:_finish("INTERRUPTED","Ghost Gallery round","_side")else k:_maybeStartSide()end return end
if k._side then k._why="side task finishing"return end if
k._state:get("session.disconnectReason")~=nil or k._state:get("game.ready")~=true then
k._why=k._state:get("session.disconnectReason")~=nil and"disconnected / kicked"or"game not ready
(loading)"return end if k._state:get("player.team")=="Choosing"then k._why="Play menu still open
(team Choosing)"return end if k._wantHome then k._wantHome=nil if k._travel and
k._travel:isAt(B.HouseInteriorName)then k._logger:info("Tasks","Go home: you are already home")else
k:_start("go_home","go home (you asked)",U.recover,nil)return end end do local l=
(game:GetService("Players")).LocalPlayer.Character local B=k._state:get("player.interior")==nil or
not((l and l:FindFirstChild("HumanoidRootPart")))if B then k._stuckSince=k._stuckSince or
P.now()local l=tonumber(k._farmConfig.StuckRejoinSeconds)or 180 if k._farmConfig.AutoRejoin and(not
k._rejoinSent and P.now()-k._stuckSince>l)then k._rejoinSent=true k:_rejoin(string.format("no place
/ no character for %d s",math.floor(P.now()-k._stuckSince)))return end else k._stuckSince=nil end
end if k._state:get("player.interior")==nil and k._hadPlace then k._why="changing place (no place
in my data)"k._transitSince=k._transitSince or P.now()if P.now()-k._transitSince>25 then
k._transitSince=nil k._logger:warn("Tasks","Stuck while changing place for 25 s: going home to
recover")k:_start("recover","recover: go home",U.recover,nil)return end else
k._hadPlace=k._state:get("player.interior")~=nil or k._hadPlace k._transitSince=nil end

if((k._travelFailures or 0))>=2 then k._travelFailures=0 k._logger:warn("Tasks","2 trips in a row
failed: recovering")k:_start("recover","recover: go home",U.recover,nil)return end if k._gameData
and k._farmConfig.KeepPetEquipped then local l=k._gameData:firstEquippedPet()local
Z,m=k._gameData:equippedPetCount()local H=k._farmConfig.SkipFullGrown local
Q=k._gameData:equippedPetList()local A=false for k,P in ipairs(Q)do if P.age==nil or
P.age<B.FullGrownAge then A=true end end k._badPets=k._badPets or{}local function f(P)return P~=nil
and((k._badPets[P]or 0))<2 end local Y=k._farmConfig.PreferNeon==true local
n=B.kindRank(k._farmConfig)local L=k._farmConfig.PetOrder~="oldest"local function b(P)local
l=k._gameData:getPetKind(P)return n and(l and n[l])or math.huge,Y and k._gameData:isPetNeon(P)end
local function M(k,P)local l=n and n[k.kind]or math.huge local B,U=b(P)if l~=B then return l<B end
return Y and(k.neon and not U)end local function O()local P=k._farmPet and
k._gameData:petAge(k._farmPet)local l=f(k._farmPet)and(P and P<B.FullGrownAge)for P,B in
ipairs(k._gameData:growablePets(Y,n,L))do if l and not M(B,k._farmPet)then return k._farmPet end if
f(B.unique)then return B.unique end end return l and k._farmPet or nil end local function
C(P)return function()k._badPets[P]=((k._badPets[P]or 0))+1 if k._badPets[P]==2 then
k._logger:warn("Tasks","Pet "..(tostring(P).." could not be equipped twice: skipping it"))end end
end if not l and(m and Z==0)then local l=P.now()if not k._lastNoPetLog or l-k._lastNoPetLog>60 then
k._lastNoPetLog=l k._logger:info("Tasks",string.format("No pet equipped: %d pets in the backpack
still grow (usable: %s), pet list %s, egg buying
%s",#k._gameData:growablePets(),tostring(O()~=nil),k._gameData:petInventoryKnown()and"known"or"NOT
known yet",not k._farmConfig.BuyEgg and"off"or(k:_isBlocked("buy_egg")and"paused after
failures"or"on")))end end local G=k._lastPet~=nil and k._gameData:petAge(k._lastPet)==nil local
w=B.focusOf(k._farmConfig)if w and(w.kind=="egg"and(m
and(k._gameData:petInventoryKnown()and(k._gameData:growingCopies(w.id)==0 and(not((G and not l))and
not k:_isBlocked("buy_egg"))))))then local P=tonumber(k._farmConfig.MaxEggBuysPerSession)or 0
k._eggBuys=k._eggBuys or 0 if P<=0 or k._eggBuys<P then k:_start("buy_egg","Mega a Pet: buy the
next "..w.id,U.buyEgg,{onBought=function()k._eggBuys=k._eggBuys+(1)end})return end end
if((k._farmConfig.BuyEgg or(w and w.kind=="egg")))and(m and(k._gameData:petInventoryKnown()and(not
O()and(not((G and not l))and not k:_isBlocked("buy_egg")))))then local
P=tonumber(k._farmConfig.MaxEggBuysPerSession)or 0 k._eggBuys=k._eggBuys or 0 if P<=0 or
k._eggBuys<P then local P=(not l and(Z==0 and not k._lastPet))local B=#Q>0 and not A if P or B
or(not l and Z==0)then k:_start("buy_egg","buy an egg",U.buyEgg,
{onBought=function()k._eggBuys=k._eggBuys+(1)end})return end end end if not l and(m and(Z==0 and
not k:_isBlocked("equip_pet")))then local P=H and((O()or k._lastPet))or k._lastPet if P and
f(P)then k:_start("equip_pet","equip pet",U.equipPet,{petUnique=P;onFail=C(P)})return end elseif((Y
or n))and(A and not k:_isBlocked("keep_pet"))then local P for l,U in ipairs(Q)do if U.unique
and((U.age==nil or U.age<B.FullGrownAge))then local l=
{unique=U.unique,kind=k._gameData:getPetKind(U.unique),neon=k._gameData:isPetNeon(U.unique)}if not
P or M(l,P.unique)then P=l end end end local l=O()local Z=l
and{unique=l;kind=k._gameData:getPetKind(l),neon=k._gameData:isPetNeon(l)}if Z and(P
and(l~=P.unique and M(Z,P.unique)))then k._logger:info("Tasks","A better pet still grows ("..
(tostring(Z.kind)..(((Z.neon and", neon"or"")).."): farming it first (Farm.FarmPetKinds /
Farm.PreferNeon)")))k._farmPet=l k:_start("keep_pet","equip the better pet",U.equipPet,
{petUnique=l;onFail=C(l)})return end end if H and(#Q>0 and(not A and not
k:_isBlocked("keep_pet")))then local P=O()if P then k._logger:info("Tasks","Your equipped pet is
full grown: equipping one that still grows (Farm.SkipFullGrown)")k._farmPet=P
k:_start("keep_pet","equip a pet that still grows",U.equipPet,{petUnique=P,onFail=C(P)})return
elseif not k._announcedAllGrown then k._announcedAllGrown=true k._logger:warn("Tasks","Every pet in
your backpack is full grown: farming the equipped one"..((k._farmConfig.BuyEgg and" (buying an egg
was not possible)"or" (Farm.BuyEgg = false)")))end end end if k:_needsTeamSwitch()then
k:_start(Q,"switch team to "..B.BabiesTeam,U.team,nil)return end local
l,Z,m,H=k:_selectEventJob()if l then k:_start(l,Z,m,H,true)return end local A,f=k:_selectGroup()if
A then local P={}for k,l in ipairs(A.entries)do table.insert(P,l.owner=="baby"and"baby"or
tostring(l.petKind or"pet"))end k:_start(A.kind,A.kind..(" ("..(table.concat(P," +
")..")")),f,A)end end function H._maybeStartSide(k)local l=k._farmConfig.MultiNeed local
Z=k._running if type(l)~="table"or not l.Enabled or k._side or not Z or not Z.waiting then return
end local m=P.now()if m<((k._sideNextAt or 0))or Z.deadline-m<10 then return end local H,Q for P,l
in ipairs(type(l.Kinds)=="table"and l.Kinds or{})do local m=U.findFor(l)if l~=Z.key and(m
and(B.needOn(k._farmConfig,l)and not k:_isBlocked(l)))then local P=k:_group(l)local B=l=="pet_me"or
l=="play"if P and((not B or P.petEntry))then H,Q=P,m break end end end if H then local P={}for k,l
in ipairs(H.entries)do table.insert(P,l.owner=="baby"and"baby"or tostring(l.petKind or"pet"))end
k:_start(H.kind,H.kind..(" ("..(table.concat(P," + ")..")")),Q,H,false,true)end end function
H._ghostRoundDue(l,k)local U=l._farmConfig.Event local H=l._gameData if type(U)~="table"or not
U.Enabled or not U.GhostGallery or not H or not l._minigame or not l._minigame.available or
l:_isBlocked("ghost_gallery")or P.now()<((l._nextEventAt.ghost_gallery or 0))then return nil end
local Q=m.serverNow()local A=Z.nextRoundStart(H:get(B.DataKeys.GhostCycle),Q)if A and(A-Q<=k and AQ>-10)then return A end return nil end function H._hauntletFirst(k)local P=k._farmConfig.Event
return type(P)=="table"and(P.Enabled==true and(P.Hauntlet==true and(P.HauntletFirst~=false
and(k._hauntlet~=nil and k._hauntlet.available==true))))end function H._hauntletRoundDue(l,k)local
U=l._farmConfig.Event local H=l._gameData if type(U)~="table"or U.Hauntlet~=true or not H or not
l._hauntlet or not l._hauntlet.available or l:_isBlocked("hauntlet")or P.now()
<((l._nextEventAt.hauntlet or 0))then return nil end local Q=m.serverNow()local
A=Z.nextRoundStart(H:get(B.DataKeys.HauntletCycle),Q)if A and(l._hauntlet.lastRunStart and Al._hauntlet.lastRunStart<900)then A=A+B.Event.RoundSeconds end if A and(A-Q<=k and A-Q>-15)then

return A end return nil end function H._autoNest(k)local P=k._farmConfig.Event local l=k._gameData
if type(P)~="table"or P.AutoNest==false or P.PigeonNest==false or not l then return nil end local
U=B.Event local
m,H,Q=Z.nestState(l:get(B.DataKeys.PigeonNest),#l:itemsOfId(B.ToyCategory,U.Twig),#l:itemsOfId(B.To
yCategory,U.RustyKey))local A=H+Q local f=m..(":"..A)if f~=k._nestSignature then k._nestSignature=f
if m=="COMPLETE"then k._logger:info("AutoNest","Nest completed: one-time objective complete ("..
(H..("/"..(U.NestTwigs..")"))))elseif m~="UNKNOWN"then k._logger:info("AutoNest",string.format("%s,
twig progress: %d/%d",m,A,U.NestTwigs))end end return m end function H._selectEventJob(k)local
l=k._farmConfig.Event local m=k._gameData if not m then return nil end local
H=k._state:get("player.team")local Q=(game:GetService("Players")).LocalPlayer.Character if
H~="Parents"and H~=B.BabiesTeam or not((Q and Q:FindFirstChild("HumanoidRootPart")))then return nil
end if k._penWanted then if m:get(B.DataKeys.PetPen)==nil then k._penWanted=nil
k._logger:warn("Event","Pet Pen now: there is no Pet Pen in your data")elseif k._travel and
k._travel:isAt(B.HouseInteriorName)then k._penWanted=nil return"pet_pen","Pet Pen (you
asked)",Z.petPen,{keep=k._farmPet}elseif k._disabled.pen_trip then k._penWanted=nil
k._logger:warn("Event","Pet Pen now: could not get home, request dropped")elseif not
k:_isBlocked("pen_trip")then return"pen_trip","go home for the Pet Pen (you asked)",U.recover,nil
end end do local l=P.now()local function U(P)return not k:_isBlocked(P)and l>=((k._nextEventAt[P]or
0))end local H=k._farmConfig.AutoPotions if type(H)=="table"and(H.Enabled
and(U("age_potion")and(Z.potionTarget(m,k._farmConfig)and(m:findItems(B.ItemCategory,Z.potionList(k
._farmConfig)))[1])))then return"age_potion","age potion",Z.agePotion,nil end local
Q=k._farmConfig.AutoOpen if type(Q)=="table"and(Q.Enabled and(U("open_gift")and
Z.nextGift(m,k._farmConfig)))then return"open_gift","open a gift",Z.openGift,nil end local
A=k._farmConfig.AutoNeon if type(A)=="table"and(A.Enabled and U("neon_fusion"))then local
P=Z.neonPick(m,k._farmConfig)if P then return"neon_fusion","neon fusion (4 "..
(P..")"),Z.neonFusion,nil end end if type(A)=="table"and(A.Mega and U("mega_fusion"))then local
P=Z.neonPick(m,k._farmConfig,true)if P then return"mega_fusion","mega neon fusion (4 neon "..
(P..")"),Z.megaFusion,nil end end end if type(l)~="table"or not l.Enabled then return nil end local
A=P.now()local function Y(P)return l[P]~=false and(not k:_isBlocked(P)and A>=((k._nextEventAt[P]or
0)))end local b=B.Event local O=B.DataKeys local C=k._hauntlet local G=l.Hauntlet==true and(C~=nil
and(C.available and not k:_isBlocked("hauntlet")))local w=G and l.HauntletFirst~=false local V=G
and(C.join~=nil and(not C.leave and(not C.kicked and P.now()-C.join.at<90)))if w then local
P=k:_hauntletRoundDue(n)if V or P then return"hauntlet","Hauntlet run",Z.hauntlet,P and{start=P}or
nil end end local t=k:_ghostRoundDue(f)if t and not((w and k:_hauntletRoundDue(f+M)))then
k._logger:info("Ghost","Minigame available: starting the Ghost Gallery
round")return"ghost_gallery","Ghost Gallery round",Z.ghostGallery,{start=t}end if G and not w then
local P=k:_hauntletRoundDue(n)if V or(P and not((l.GhostGallery and k:_ghostRoundDue(L))))then
return"hauntlet","Hauntlet run",Z.hauntlet,P and{start=P}or nil end end local R=l.PigeonNest~=false
and k:_autoNest()if R=="BUILD_NEST"and Y("pigeon_nest")then return"pigeon_nest","build the nest
(AutoNest)",Z.pigeonNest,nil elseif R=="COLLECT_TWIGS"and(l.Crypt
and(Y("crypt")and(m:get(O.Crypt)~=nil and Z.cryptPlan(m:get(O.Crypt),true))))then
return"crypt","collect twigs in the Crypt (AutoNest)",Z.crypt,nil end local
q=B.focusOf(k._farmConfig)if Z.skelicornOn(k._farmConfig)and m:petInventoryKnown()then local
P,l=Z.skelicornStep(m,k._farmConfig)do local U=#m:itemsOfId(B.ToyCategory,b.RustyKey)local
H=tonumber(m:get(O.Candy))or 0 local Q=string.format("Skelicorn: %s | lever in bag %s | Rusty Keys
%d | candy %d / %d | Crypt %s",P or("idle:
"..tostring(l)),Z.findLever(m)and"yes"or"no",U,math.floor(H/1000)*1000,Z.skelicornPrice(),m:get(O.C
rypt)~=nil and"known"or"NOT known")if Q~=k._skelicornLine then k._skelicornLine=Q
k._logger:info("Skelicorn",Q)Z.skelicornNote(Q)end end local U=P=="crypt"or(P=="buy"and
Z.skelicornNeedsLever(m))if U and(Y("crypt")and(m:get(O.Crypt)~=nil
and#m:itemsOfId(B.ToyCategory,b.RustyKey)>0))then return"crypt","look for the Lightning Lever in
the Crypt (Auto Skelicorn)",Z.crypt,nil elseif P and(P~="crypt"and Y("skelicorn"))then
return"skelicorn","Auto Skelicorn: "..P,Z.skelicorn,nil end end if q
and(q.kind=="candy"and(Y("candy_pet")and m:petInventoryKnown()))then local P=
((tonumber(l.PetPenSlots)or b.PetPenSlots or 4))+1 local B=m:growingCopies(q.id)local
U=tonumber(m:get(O.Candy))or 0 local H=math.floor(((U-q.keepCandy))/q.price)local Q=math.min(PB,H)if Q>0 then return"candy_pet",string.format("Mega a Pet: buy %d x %s (%d grow, %d
wanted)",Q,q.id,B,P),Z.buyCandyPet,{pick=
{id=q.id,price=q.price;count=Q,keepCandy=q.keepCandy},onBought=function()k._nextEventAt.pet_pen=0
end}end end local K=l.CandyPets if type(K)=="table"and(K.Enabled and(Y("candy_pet")and
m:petInventoryKnown()))then local k=Z.candyPetTarget(m,K)if k then return"candy_pet","buy "..
(k.id..(" ("..(k.price.." candy)"))),Z.buyCandyPet,nil end end if l.StrayCat and Y("stray_cat")then
local k=m:get(O.StrayCat)if type(k)=="table"and k.fed_today==false then return"stray_cat","feed the
Stray Cat",Z.strayCat,nil end end local y=l.Crypt or(q~=nil and q.kind=="spider")local
i=Z.skelicornOn(k._farmConfig)and(m:petInventoryKnown()and(Z.skelicornStep(m,k._farmConfig)~=nil
and Z.skelicornNeedsLever(m)))if y and(not i and(Y("crypt")and m:get(O.Crypt)~=nil))then local
k=Z.cryptPick(m:get(O.Crypt),l.CryptOpen)if k and(k.spider and l.MummySpider~=false)then
return"crypt","claim the Mummy Spider",Z.crypt,nil elseif k and(not k.spider
and#m:itemsOfId(B.ToyCategory,b.RustyKey)>0)then return"crypt","open a Crypt grave",Z.crypt,nil end
end if l.Quests and A>=((k._questLogAt or 0))then k._questLogAt=A+600
k._logger:info("Event","Quests: "..Z.describeQuests(m:get(O.Dailies)))end if l.HouseVisits~=false
and(l.Quests and(Y("house_visits")and Z.visitQuest(m:get(O.Dailies))))then
return"house_visits","visit player homes (quest)",Z.houseVisits,nil end if l.Quests
and(Y("quests")and#Z.questsToClaim(m:get(O.Dailies))>0)then return"quests","claim

quests",Z.quests,nil end if l.PigeonNest and(l.AutoNest==false
and(Y("pigeon_nest")and#m:itemsOfId(B.ToyCategory,b.Twig)>0))then local k=m:get(O.PigeonNest)if
type(k)=="table"and((tonumber(k.twigs_contributed)or 0))<b.NestTwigs then return"pigeon_nest","twig
to the pigeon nest",Z.pigeonNest,nil end end local d=q~=nil and q.kind=="egg"local s=not q or d if
l.PetPen and(l.PetPenStock~=false and(((k._farmConfig.BuyEgg or d))and(s and(Y("pen_stock")and(not
k:_isBlocked("buy_egg")and(m:get(O.PetPen)~=nil
and(m:petInventoryKnown()and(((tonumber(m:get(O.Money))or 0))>=((tonumber(l.PetPenStockMinBucks)or
750))and(k._travel and k._travel:isAt(B.HouseInteriorName))))))))))then local P=
((tonumber(l.PetPenSlots)or b.PetPenSlots))+1 local B=0 for k in pairs(m:petPenPets())do B=B+(1)end
local Z=B+#m:growablePets()local H=tonumber(k._farmConfig.MaxEggBuysPerSession)or 0
k._eggBuys=k._eggBuys or 0 if Z<P and((H<=0 or k._eggBuys<H))then
k._logger:info("Event",string.format("Pet Pen stock: %d of %d pets still grow (pen %d): buying an
egg",Z,P,B))return"pen_stock","buy an egg for the Pet Pen",U.buyEgg,
{onBought=function()k._eggBuys=k._eggBuys+(1)k._nextEventAt.pet_pen=0 end}end end if l.PetPen
and(Y("pet_pen")and(m:get(O.PetPen)~=nil and(k._travel and
k._travel:isAt(B.HouseInteriorName))))then return"pet_pen","Pet Pen",Z.petPen,{keep=k._farmPet}end
return nil end function H._rejoin(P,k)P._logger:warn("Tasks","Stuck: "..(k..": rejoining a server
(Farm.AutoRejoin)"))local l,B=pcall(function()local k=game:GetService("Players");
(game:GetService("TeleportService")):Teleport(game.PlaceId,k.LocalPlayer)end)if not l then
P._logger:warn("Tasks","Rejoin failed: "..tostring(B))end end function H.sendDirect(P,k,...)if
P._running or P._side or P._stopped then return false,"busy"end return
P._interaction:send(k,...)end function H.isBusy(k)return k._running~=nil or k._side~=nil end
function H.requestGoHome(k)if k._running and C[k._running.key]then k._wantHome=true return
true,"Going home after "..k._running.label end k:_finish("INTERRUPTED","you asked to go
home")k:_finish("INTERRUPTED","you asked to go home","_side")k._wantHome=true return true,"Going
home"end function H.skipCurrent(k)local l=k._running if not l then return false,"Nothing is
running"end if G[l.key]then return false,l.label.." always finishes (it is safe that way)"end local
B,U=l.key,l.label k:_finish("INTERRUPTED","skipped by you")k:_finish("INTERRUPTED","skipped by
you","_side")k._cooldownUntil[B]=P.now()+w if k._nextEventAt[B]~=nil then
k._nextEventAt[B]=P.now()+w end return true,string.format("Skipped %s (not chosen again for %d
s)",U,w)end function H.requestPetPen(k)k._penWanted=true k._nextEventAt.pet_pen=0
k._cooldownUntil.pen_trip=nil return true,k._travel
and(k._travel:isAt(B.HouseInteriorName)and"Claiming the Pet Pen")or"Going home, then claiming the
Pet Pen"end function H.retryDisabled(k)local P=0 for k in pairs(k._disabled)do P=P+(1)end
k._disabled={}k._disabledUntil={}k._failures={}k._cooldownUntil=
{}k._logger:info("Tasks",string.format("Retry: %d resting task%s may run again (you asked)",P,P==1
and""or"s"))return P end function H.getPenInfo(k)local l=k._gameData local U=k._farmConfig.Event
local Z={known=false;slots=tonumber(type(U)=="table"and U.PetPenSlots)or 4}if l and
l:get(B.DataKeys.PetPen)~=nil then Z.known=true local B=0 for k in pairs(l:petPenPets())do B=B+
(1)end Z.pets=B local U=k._nextEventAt.pet_pen Z.nextClaimIn=U and math.max(0,math.floor(UP.now()))or 0 end return Z end function H.stop(k)if k._stopped then return end k._stopped=true if
k._running then k:_finish("CANCELLED","farm stopped")end k:_finish("CANCELLED","farm
stopped","_side")end return H end P.main=function(...)local k=...local P=k("Core/Enums")local
l=k("Core/Util")local B=k("Core/Config")local U=k("Core/Maid")local Z=k("Core/Logger")local
m=k("Core/State")local H=k("Core/Scheduler")local Q=k("Services/Disclosure")local
A=k("Services/Notifier")local f=k("Services/SessionWatcher")local Y=k("Services/SessionStore")local
n=k("Services/Telemetry")local L=k("Game/GameConstants")local b=k("Game/GameData")local
M=k("Game/GameIcons")local O=k("Game/PetLocator")local C=k("Game/PlayerSync")local
G=k("Game/AilmentTracker")local w=k("Game/Interaction")local V=k("Game/Travel")local
t=k("Game/TaskManager")local R=k("Game/Furniture")local q=k("Game/Minigame")local
K=k("Game/Hauntlet")local y=k("Game/EventTasks")local i=k("Services/Interface")local
d=game:GetService("Players")local s="AdoptMeFarm"local a=6 local X=30 local F=5 local h=.5 local
p=30 local x=30 local E=1.5 local I=10 local function o(k,P,B,U)local
Z=k:get("session.startedAt",l.now())local m={{name="Session time",value=l.formatDuration(l.now()Z);inline=true};{name="Needs
completed";value=tostring(k:get("stats.needsCompleted",0)),inline=true};{name="Bucks
earned",value=tostring(k:get("stats.bucksEarned",0));inline=true}}local H=k:get("player.bucks")if H
then table.insert(m,{name="Bucks";value=tostring(H),inline=true})end if B then table.insert(m,
{name="Candy",value=tostring(B);inline=true})table.insert(m,{name="Candy earned",value=tostring(U
or 0),inline=true})end local Q=k:get("pets.equipped",{})if#Q>0 then local k={}for P,l in
ipairs(Q)do table.insert(k,l.kind..((l.age and(" (age "..(l.age..")"))or"")))end table.insert(m,
{name="Pet";value=table.concat(k,", "),inline=true})end local A=k:get("stats.lastTask")if A then
table.insert(m,{name="Last task";value=A,inline=true})end table.insert(m,{name="Log
counts";value=string.format("%d warnings, %d
errors",P.Counts.WARN,P.Counts.ERROR),inline=true})return m end local function e(k,P)local l=
{}table.insert(l,"Bucks "..tostring(k:get("player.bucks","?")))table.insert(l,"team
"..tostring(k:get("player.team","?")))table.insert(l,"in
"..tostring(k:get("player.interior","?")))local B={}for k,l in ipairs(k:get("pets.equipped",{}))do
local U=P:findModel(l.unique)table.insert(B,string.format("%s age %s%s",l.kind,tostring(l.age
or"?"),U and""or" [model not found]"))end table.insert(l,"pets: "..((#B>0 and table.concat(B,",
")or"none")))if not k:get("ailments.known",false)then table.insert(l,"needs: unknown yet")else
local P={}for k,l in ipairs(k:get("ailments.active",{}))do local B=l.owner=="baby"and"baby"or
tostring(l.petKind or"pet")table.insert(P,B..(":"..(l.kind..((l.inProgress and"*"or"")))))end
table.insert(l,"needs: "..((#P>0 and table.concat(P,", ")or"none")))end table.insert(l,"task:

"..tostring(k:get("farm.currentTask","none")))return table.concat(l," | ")end return
function(k,u)local T=l.getSharedEnvironment()local r=T[s]if type(r)=="table"and
type(r.Stop)=="function"then pcall(r.Stop,"replaced by a new execution")end local
v,J=B.build(k)local c=U.new()local D=Z.new(v.Logging)D.reportHeader=function()local
k="?"pcall(function()k=type(identifyexecutor)=="function"and
tostring((identifyexecutor()))or"?"end)return string.format("Adopt Victims %s | executor %s |
%s",Q.VERSION,k,os.date("!%Y-%m-%d %H:%M UTC"))end for k,P in ipairs(J)do D:warn("Config",P)end
local S=m.new()local j=d.LocalPlayer S:set("session.startedAt",l.now(),"main")S:set("player.name",j
and j.Name
or"?","Players.LocalPlayer")S:set("stats.needsCompleted",0,"main")S:set("stats.bucksEarned",0,"main
")local W=v.Interface.Enabled and v.Interface.RememberSettings~=false local z=W and
i.applySaved(v,D)or 0 local g=A.new(v.Notifications,D,v.General.ScriptName,Q.VERSION)local
N=Y.new(D,Q.VERSION,v.Logging.SessionFile)local kN=N:begin()local PN={}local
lN,BN=D:getFilePath()table.insert(PN,lN and("log: "..lN)or("no log file ("..(tostring(BN)..")")))if
N:isAvailable()then table.insert(PN,"session status: "..(Y.PATH.." (start time, last seen, clean
stop, last Roblox message)"))end if W then table.insert(PN,string.format("window settings: %s (your
changes in the window; %d applied over these settings; holds your webhook URL when you typed one in
the window)",i.SAVE_PATH,z))table.insert(PN,"configs: "..(i.CONFIG_FOLDER..("/<name>"..
(i.CONFIG_EXTENSION.." (only the configs you save in the window)"))))end local
UN=game.PlaceId==L.PlaceId local ZN=UN and w.describeActions()or nil local
mN=n.new(v.Telemetry,D,Q.VERSION,S)mN:start(c)local
HN=Q.buildStartLines(v,PN,g:getStatusText(),mN:statusText(),u)table.insert(HN,"")for k,P in
ipairs(Q.buildLines(v,PN,g:getStatusText(),u,ZN,mN:statusText()))do table.insert(HN,P)end
D:report("Disclosure",Q.buildStartLine(v,mN:isEnabled()))c:Give(D.OnEntry:Connect(function(k,l,B)if
k==P.LogLevel.ERROR and l~="Notifier"then g:notify(P.NotifyEvent.Error,{{name="Error";value=l..(":
"..B)}})end end))if kN then local
k=Y.describe(kN)D:warn("Session",k)g:notify(P.NotifyEvent.PreviousSessionEnded,{{name="Previous
session",value=k}})end local QN=nil local AN=nil local fN=nil local YN=nil local nN=M.new(D)local
LN={}local function bN()local k=fN and tonumber(fN:get("candy_2026"))or nil if k and not YN then
YN=k end return k,((k and YN))and(k-YN)or nil end local function MN()return o(S,D,bN())end local
function ON()local k=(S:get("pets.equipped",{}))[1]local P=k and M.assetId(nN:item(k.kind))if not P
then return nil end if LN[P]==nil then LN[P]=false task.spawn(function()local
k,B=pcall(function()local k=l.jsonDecode(game:HttpGet("https://thumbnails.roblox.com/v1/assets?
assetIds="..(P.."&size=150x150&format=Png")))return k.data[1].imageUrl end)if k
and(type(B)=="string"and string.find(B,"^https://tr%.rbxcdn%.com/"))then LN[P]=B end end)end return
LN[P]or nil end if not UN then D:warn("Game",string.format("PlaceId %s is not Adopt Me (%d): game
features are off",tostring(game.PlaceId),L.PlaceId))else local k,P=pcall(function()return
game:IsLoaded()end)if k and not P then D:info("Game","Waiting for
game:IsLoaded()...")game.Loaded:Wait()end local l=game:GetService("ReplicatedStorage")if not
l:FindFirstChild(L.Remotes.Folder)then D:info("Game","Waiting for the game to finish
loading...")local k=0 while not l:FindFirstChild(L.Remotes.Folder)and k<120 do task.wait(1)k=k+
(1)end end local B=w.new(D,S)local U=(game:GetService("Players")).LocalPlayer local
Z=type(U.FindFirstChild)=="function"and U:FindFirstChild("PlayerGui")local function m()local k=Z
for P,l in ipairs(L.PlayButtonPath)do k=k and k:FindFirstChild(l)end return k end local function
H(k)local P,l=pcall(function()local P=Z:FindFirstChild(L.PlayButtonPath[1])return k.Parent~=nil
and(k.Visible~=false and((P==nil or P.Enabled~=false)))end)return P and l==true end local function
Q(k,P,l)D:info("Game",k.." is open: clicking")for B,U in ipairs(w.CLICK_METHODS)do local
Z,m=w.clickButton(P,U)if Z then local P=0 while l()and P<8 do task.wait(1)P=P+(1)end if not l()then
D:success("Game",k..(": click worked ("..(U..")")))return true end D:warn("Game",k..(": click ("..
(U..(") had no effect "..tostring(m or"")))))else D:warn("Game",k..(": click ("..(U..(") not
available: "..tostring(m)))))end end D:warn("Game","Could not close "..(k.."; please tap it
yourself"))return false end local function A(k)local P,l=pcall(function()local
P=k:FindFirstAncestorOfClass("ScreenGui")if not P or not P.Enabled then return false end local l=k
while l and l~=P do if l:IsA("GuiObject")and l.Visible==false then return false end l=l.Parent end
return true end)return P and l==true end local function f(k)if k~=Z then return{k}end local P={}for
k,l in ipairs(k:GetChildren())do local B,U=pcall(function()return l:IsA("ScreenGui")and
l.Enabled~=false end)if B and U then table.insert(P,l)end end return P end local function Y(k,P)if
type(P)=="string"then P={P}end for k,l in ipairs(f(k))do for k,l in ipairs(l:GetDescendants())do
if((l:IsA("TextLabel")or l:IsA("TextButton")))and type(l.Text)=="string"then local
k=string.lower(l.Text)for P,B in ipairs(P)do if string.find(k,B)and A(l)then return l end end end
end end return nil end local function n()for k=1,30,1 do local P=Y(Z,"choose location")if P then
task.wait(1.5)local k=P:FindFirstAncestorOfClass("ScreenGui")local l=Y(k,"^%s*home%s*$")local B=l
and((l:IsA("GuiButton")and l or l:FindFirstAncestorWhichIsA("GuiButton")))if B then Q("Choose
Location (Home)",B,function()return A(P)end)else local P={}for k,l in ipairs(k:GetDescendants())do
if l:IsA("GuiButton")and A(l)then table.insert(P,l:GetFullName())end end D:warn("Game","Choose
Location dialog: no HOME button found. Visible buttons: "..table.concat(P," | "))end return end
task.wait(1)end D:debug("Game","No Choose Location dialog after Play")end local M={"buy
bucks";"^%s*sale%s*$"}local function y(k)local function P(k)k=string.lower(tostring(k or""))return
string.find(k,"buy")~=nil or string.find(k,"purchase")~=nil or string.find(k,"robux")~=nil end if
P(k.Name)or(k:IsA("TextButton")and P(k.Text))then return true end for k,l in
ipairs(k:GetDescendants())do if((l:IsA("TextLabel")or l:IsA("TextButton")))and P(l.Text)then return
true end end return false end local function i()local k=0 for P=1,90,1 do local l=Y(Z,M)if not l
then k=k+(1)if k>=15 then local k={}for P,l in ipairs(f(Z))do for P,l in
ipairs(l:GetDescendants())do local B=string.lower(l.Name)if

l:IsA("GuiButton")and(((string.find(B,"close")or string.find(B,"exit")or B=="x"))and A(l))then
table.insert(k,l:GetFullName())end end end D:debug("Game","No popup text found. Visible close-like
buttons: "..((#k>0 and table.concat(k," | ")or"none")))return end else k=0 task.wait(1.5)local
P=l:FindFirstAncestorOfClass("ScreenGui")local B local U={}for k,P in ipairs(P:GetDescendants())do
if P:IsA("GuiButton")and A(P)then table.insert(U,P:GetFullName())local k=string.lower(P.Name)if not
B and(not y(P)and((string.find(k,"close")or string.find(k,"exit")or k=="x")))then B=P end end end
if not B then D:warn("Game","Popup \'"..(tostring(l.Text)..("\': no close button found. Visible
buttons: "..table.concat(U," | "))))return end if not Q("Popup \'"..(tostring(l.Text).."\'
(close)"),B,function()return A(l)end)then return end end task.wait(1)end end if
v.Farm.AutoAcceptMenu and Z then local function k()local k=0 while k<20 do local
P=v.Farm.AutoAcceptMenu and m()if P and H(P)then task.wait(2)k=k+(1)if Q("Main menu
(Play)",P,function()return H(P)end)then n()i()end task.wait(5)else task.wait(2)end end end
c:Give(task.spawn(k))end local d=b.new(D)fN=d
mN:setGameData(d)c:Give(function()d:destroy()end)QN=O.new(d)if d:start(c)then
C.start(c,S,d,QN,D)local k=G.new(D,S,g,d)k:start(c)local P=q.new(D)P:start(c)local l=K.new(D,
(game:GetService("Players")).LocalPlayer.UserId)l:start(c)pcall(function()local k=v.Telemetry and
v.Telemetry.Url if type(k)=="string"and string.match(k,"/log$")then
l:setSquadRelay((string.gsub(k,"/log$","/squad")),function()local k=v.Farm and v.Farm.Event return
type(k)=="table"and k.HauntletSquadKey or nil end)end end)mN:setDiagnostics(function()local k=AN
and AN:getDiagnostics()or{}k.status=QN and e(S,QN)or nil
k.team=S:get("player.team")k.place=S:get("player.interior")k.ready=S:get("game.ready")k.farmEnabled
=v.Farm.Enabled local P=(game:GetService("Players")).LocalPlayer.Character k.character=P~=nil and
P:FindFirstChild("HumanoidRootPart")~=nil return k
end)AN=t.new({minigame=P;hauntlet=l,logger=D;state=S;tracker=k,interaction=B,travel=V.new(D,S,B,v.F
arm);petLocator=QN;furniture=R.new(d,S);gameData=d,farmConfig=v.Farm})AN:start(c)S:set("game.ready"
,true,"main")else S:set("game.ready",false,"main")end end local
CN=H.new(D,v.General.TickSeconds)CN:addJob("LogFlush",v.Logging.FlushSeconds,function()D:flush()end
)CN:addJob("TelemetryPump",5,function()mN:pump()end)CN:addJob("NotifierPump",1,function()g:pump()en
d,{runImmediately=true})CN:addJob("SessionHeartbeat",X,function()N:heartbeat()end)do local
k=l.now()CN:addJob("SummaryWebhook",x,function()local
B=tonumber(v.Notifications.SummaryIntervalMinutes)or 0 if not g:isEnabled()or
v.Notifications.SendSummary==false or B<=0 then k=l.now()return end local U=ON()if l.now()-k>=B*60
then k=l.now()g:notify(P.NotifyEvent.Summary,MN(),nil,{thumbnail=U})end end)end if QN then local
k=nil CN:addJob("GameStatus",F,function()local P=e(S,QN)if P~=k then k=P D:info("Status",P)end end,
{runImmediately=true})end if AN then CN:addJob("Tasks",h,function()AN:tick()end)end if AN then
local k=l.now()CN:addJob("Cashback",p,function()if not((v.Farm.Enabled and
v.Farm.CollectCashback))then return end if l.now()-k<math.max(1,tonumber(v.Farm.CashbackMinutes)or
10)*60 then return end if S:get("game.ready")~=true or S:get("session.disconnectReason")~=nil then
return end local P=S:get("player.bucks")if not AN:sendDirect("CollectCashback")then return end
k=l.now()task.delay(5,function()local k=S:get("player.bucks")if
type(P)=="number"and(type(k)=="number"and k>P)then D:success("Cashback",string.format("Collected:
+%d Bucks",k-P))else D:debug("Cashback","Nothing collected (Bucks unchanged)")end end)end)end
CN:addJob("Heartbeat",60,function()D:debug("Core",string.format("Heartbeat: ticks=%d, webhook
sent=%d dropped=%d
pending=%d",CN.TickCount,g.SentCount,g.DroppedCount,g:pendingCount()))end)f.start(c,D,g,S,N)do
local k=(game:GetService("Players")).LocalPlayer local P=k and k.Idled if P then
c:Give(P:Connect(function()if not v.Farm.AntiAfk then return end local k,P=w.virtualClick()if k
then D:info("AntiAfk","Idle warning from Roblox: sent a virtual click")else
D:warn("AntiAfk","Virtual click failed: "..tostring(P))end end))else
D:warn("AntiAfk","LocalPlayer.Idled not available: idle kick cannot be prevented")end end do local
k,P=false,-math.huge CN:addJob("CameraGuard",1,function()if not v.Farm.CameraGuard or k then return
end pcall(function()local B=d.LocalPlayer local U=workspace.CurrentCamera local Z=B and B.Character
local m=Z and Z:FindFirstChild("Head")if not((U and m))or U.CameraType~=Enum.CameraType.Custom or
B.CameraMode==Enum.CameraMode.LockFirstPerson then return end if((U.CFrame.Positionm.Position)).Magnitude>E then return end k=true local H=B.CameraMinZoomDistance
B.CameraMinZoomDistance=math.max(H,I)task.delay(.3,function()pcall(function()B.CameraMinZoomDistanc
e=H end)k=false end)if l.now()-P>60 then P=l.now()D:debug("Camera","Camera was inside your
character: zoomed it back out (Farm.CameraGuard)")end end)end)end
g:notify(P.NotifyEvent.SessionStarted,{{name="Session
time";value="00:00:00";inline=true}},Q.buildShortText())if v.Notifications.SendTestMessageOnStart
then g:notify(P.NotifyEvent.Test,{},"If you can read this, the webhook works.")end
CN:start()D:success("Core","Started. Version "..Q.VERSION)local GN=
{Version=Q.VERSION,State=S;Disclosure=function()for k,P in ipairs(HN)do D:report("Disclosure",P)end
end}local wN=false GN.Config=v function GN.Icons()local k=(S:get("pets.equipped",{}))
[1]return{bucks=nN:known("bucks")or
nN:currency("bucks",S:get("player.bucks"));candy=nN:known("candy")or nN:currency("candy",fN and
fN:get("candy_2026"));pet=k and nN:item(k.kind)or nil}end function GN.GameIcon(k)return
nN:picture(k)end function GN.Status()local k=AN and AN:getDiagnostics()or{}local
P=S:get("session.startedAt")local U=bN()local Z={}for k,P in ipairs(S:get("pets.equipped",{}))do
table.insert(Z,{kind=P.kind,age=P.age})end local m={}for k,P in ipairs(S:get("ailments.active",
{}))do table.insert(m,{owner=P.owner,kind=P.kind;inProgress=P.inProgress==true})end local H=nil
pcall(function()local k=q.serverNow()local P=fN and
y.nextRoundStart(fN:get(L.DataKeys.GhostCycle),k)if P then H=math.max(0,math.floor(P-k))end
end)local A=v.Farm.Event local f,Y=B.countFeatures(v)local n,b,M if fN then

pcall(function()n=#fN:itemsOfId(L.ToyCategory,L.Event.RustyKey)b=#fN:itemsOfId(L.ToyCategory,L.Even
t.Twig)local k=fN:get(L.DataKeys.PigeonNest)M=type(k)=="table"and tonumber(k.twigs_contributed)or
nil end)end
return{lastTask=S:get("stats.lastTask");rustyKeys=n;twigs=b,nestTwigs=M,featuresOn=f;featuresTotal=
Y,preset=v.Preset,ghostEnabled=A.Enabled==true and
A.GhostGallery==true,petPenEnabled=A.Enabled==true and A.PetPen==true;pen=AN and AN:getPenInfo()or
nil,webhooksOn=g:isEnabled();restMinutes=k.restMinutes,version=Q.VERSION,stopped=wN;farmEnabled=v.F
arm.Enabled==true,ready=S:get("game.ready")==true;team=S:get("player.team");place=S:get("player.int
erior"),task=S:get("farm.currentTask","none");sideTask=k.side,minutes=P and math.floor(((l.now()P))/60)or
0;needsDone=S:get("stats.needsCompleted",0),bucksEarned=S:get("stats.bucksEarned",0),bucks=S:get("p
layer.bucks"),candy=U;candyEarned=((U and YN))and(U-YN)or
nil,pets=Z,needs=m;nextRoundIn=H,tasksSucceeded=S:get("farm.tasksSucceeded",0),tasksFailed=S:get("f
arm.tasksFailed",0),disabled=k.disabled,line=QN and e(S,QN)or nil}end local function VN(k)if wN
then return false,"The farm is stopped: run the loader again"end if not AN then return false,"Not
in Adopt Me, or the game is not ready yet"end if not v.Farm.Enabled then return false,"Paused:
switch \'Farm running\' on first (paused = no game actions)"end return k()end function
GN.GoHome()return VN(function()return AN:requestGoHome()end)end function GN.SkipTask()return
VN(function()return AN:skipCurrent()end)end function GN.ClaimPetPen()return VN(function()return
AN:requestPetPen()end)end function GN.RetryDisabled()if not AN then return false,"Not in Adopt Me,
or the game is not ready yet"end local k=AN:retryDisabled()return true,k>0 and string.format("%d
resting task%s may run again",k,k==1 and""or"s")or"No task was resting"end function
GN.Catalog()local k={petKinds={},giftIds={}}if not fN then return k end local P={}local
l=fN:get(L.DataKeys.Inventory)local B=type(l)=="table"and(type(l.pets)=="table"and l.pets)or{}for
l,B in pairs(B)do local U=type(B)=="table"and tostring(B.kind or B.id or"")or""if U~=""and(not
P[U]and not L.NotFarmablePets[U])then P[U]=true table.insert(k.petKinds,U)end end local U={}for P,l
in ipairs(fN:findItems(L.GiftCategory,nil))do local B=tostring(l.id)if not U[B]then for P,l in
pairs(L.GiftPatterns)do if string.find(B,l)and not U[B]then U[B]=true table.insert(k.giftIds,B)end
end end end table.sort(k.petKinds)table.sort(k.giftIds)return k end function GN.TestWebhook()if not
g:isEnabled()then return false,"Set a webhook URL first ("..(g:getStatusText()..")")end
g:notify(P.NotifyEvent.Test,{},"If you can read this, the webhook works.")g:pump()return true,"Test
message sent: check your Discord channel"end function GN.ApplyPreset(k,P)local
l,U=B.presetValues(k,P or v.Farm.Focus)if not l then return false,"No preset called
"..tostring(k)end for k,P in ipairs(l)do local l=B.valueAt(v,{table.unpack(P[1],1,#P[1]-1)})if
type(l)=="table"then l[P[1][#P[1]]]=P[2]end end v.Preset=U.id D:info("Core","Preset applied:
"..U.name)return true,U.name end function GN.Stop(k)if wN then return end wN=true k=tostring(k
or"stopped by user")CN:stop()if AN then AN:stop()end N:markCleanStop()D:info("Core","Stopping:
"..k)mN:pump(true)g:notify(P.NotifyEvent.SessionStopped,MN(),"Reason: "..k,{thumbnail=ON()})if
T[s]==GN then T[s]=nil end c:Clean()task.spawn(function()g:flush(a)D:info("Core","Stopped
cleanly")D:close()S:destroy()end)end function GN.OpenInterface()local k,P=pcall(i.start,GN,
{logger=D;settings=v.Interface})if not k then D:warn("Interface","Window not opened (the farm keeps
running): "..tostring(P))end return k end T[s]=GN if v.Interface.Enabled then
task.spawn(GN.OpenInterface)end return GN end end local Z,m=pcall(function()local P=
(type(getgenv)=="function"and getgenv())or _G local l=k local B=
{fromLoader=false,settingsSource="SETTINGS block in this file"}if
type(P.AdoptMeFarmSettings)=="table"then l=P.AdoptMeFarmSettings B.settingsSource="your loader
(getgenv().AdoptMeFarmSettings)"end local Z=P.AdoptMeFarmLoaderInfo if type(Z)=="table"and
type(Z.Url)=="string"then B.fromLoader=true B.loaderUrl=Z.Url end return(U("main"))(l,B)end)if not
Z then warn("[AdoptMe Farm] Failed to start: "..tostring(m))end


