--Essence by sirelKilla (v3rm)
--Put this script in your autoexec folder!

--hidden feature: ALT+B to toggle the default backpack
--// init //
local settings = {noclipKey="World69",clicktpKey="T",cmdKey="Semicolon",clickespKey="LeftControl"} --blank=World69
local tpIgnore = false
local tpExact = true
local espLimit = 9999
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
player = Players.LocalPlayer
local cam = workspace.CurrentCamera
math.randomseed(tick())
local root
if readfile then
	pcall(function()
		local new = game:GetService("HttpService"):JSONDecode(readfile("EssenceSettings.txt"))
		--corruption?
		local doOverwrite=false
		for k,v in pairs(new) do
			if settings[k]==nil then
				doOverwrite=true
				new[k]=nil
			end
		end
		for k,v in pairs(settings) do
			if new[k]==nil then
				doOverwrite=true
				new[k]=v
			end
		end
		--use input
		if doOverwrite then
			writefile("EssenceSettings.txt",game:GetService("HttpService"):JSONEncode(new))
		end
		settings = new
	end)
	game.Close:Connect(function()
		writefile("EssenceSettings.txt",game:GetService("HttpService"):JSONEncode(settings))
	end)
end
--feel free to add commands
local adminCommands = {
rj = function() game:GetService("TeleportService"):Teleport(game.PlaceId,player) end,
rejoin = function() game:GetService("TeleportService"):Teleport(game.PlaceId,player) end,
ws = function(argsString) player.Character.Humanoid.WalkSpeed = tonumber(argsString) end,
jp = function(argsString) player.Character.Humanoid.JumpPower = tonumber(argsString) end,
hh = function(argsString)
	if argsString == '' then
		if player.Character.Humanoid.HipHeight > 2.5 then
			player.Character.Humanoid.HipHeight = 2
		else
			player.Character.Humanoid.HipHeight = 10
		end
	else
		player.Character.Humanoid.HipHeight = tonumber(argsString)
	end
end,
goto = function(argsString)
	local target = getPlayer(argsString)
	if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
		if game.PlaceId==606849621 then
			local door = workspace.Apartments.Skyscraper6.ExitDoor.Touch
			local oldcf = door.CFrame
			door.CFrame = root.CFrame
			wait()
			door.CFrame = oldcf
		end
		if tpExact then
			root.CFrame = target.Character.HumanoidRootPart.CFrame
		else
			player.Character:MoveTo(target.Character.HumanoidRootPart.CFrame.p)
		end
	end
end,
}
--// utilities //
function getFirstChild(service,str,modifier)
	local children = service:GetChildren()
	for i=1,#children do
		local v = children[i]
		for s in string.gmatch(v.Name,"%S+") do
			if modifier(s:sub(1,#str)) == str then
				return v
			end
		end
	end
end
function findObject(service,str)
	if service and str and #str>0 then
		--exact match
		local targ = service:FindFirstChild(str) or service:FindFirstChild(str:lower())
		if targ then
			return targ
		else
			--loose match
			return getFirstChild(service,str,(str:lower()==str and string.lower) or function(x) return x end)
		end
	end
end
function getPlayer(str)
	if str:lower()=="me" then
		return player
	elseif str:lower()=="random" then
		local players = Players:GetPlayers()
		for i=1,#players do
			if players[i]==player then
				table.remove(players,i)
				break
			end
		end
		return players[math.random(1,#players)]
	elseif str:sub(1,1)=='%' then
		local team = findObject(game:GetService('Teams'),str:sub(2))
		if team then
			local players = team:GetPlayers()
			for i=1,#players do
				if players[i]==player then
					table.remove(players,i)
					break
				end
			end
			return players[math.random(1,#players)]
		end
	else
		return findObject(Players,str)
	end
end
local espManagementTick = 0
local function espManage()
	espManagementTick = tick()
	local camPos = cam.CFrame.p
	local folders = espGui:GetChildren()
	for i=1,#folders do
		folders[i].Box.Visible = false
		folders[i].BillboardGui.Enabled = false
	end
	local players = Players:GetPlayers()
	for i=1,#players do
		local p = players[i]
		local folder = espGui:FindFirstChild(p.Name)
		if not folder then
			folder = Instance.new("Folder")
			folder.Name = p.Name
			boxTemplate:Clone().Parent = folder
			bbTemplate:Clone().Parent = folder
			folder.BillboardGui.NameTag.Text = p.Name
			folder.Parent = espGui
		end
		if p~=player and p.Character then
			local pRoot = p.Character:FindFirstChild("HumanoidRootPart")
			if pRoot then
				local distance = (pRoot.Position-camPos).Magnitude
				if distance < espLimit then
					local box,bbgui = folder.Box,folder.BillboardGui
					bbgui.NameTag.TextColor3 = p.TeamColor.Color
					bbgui.Adornee = pRoot
					bbgui.Enabled = true
					if distance > 900 then
						box.Visible = false
						bbgui.NameTag.TextStrokeTransparency = 1
						bbgui.Dot.BackgroundColor3 = p.TeamColor.Color
						bbgui.Dot.Visible = true
					else
						box.Color3 = p.TeamColor.Color
						box.Adornee = pRoot
						box.Visible = true
						bbgui.Dot.Visible = false
						bbgui.NameTag.TextStrokeTransparency = 0.3
						if distance > 300 then
							box.Transparency = 0
						else
							box.Transparency = 0.5
						end
					end
				end
			end
		end
	end
end
local function shortenKey(name)
	if name=="World69" then
		return ""
	elseif name=="LeftControl" or name=="RightControl" then
		return "CTRL"
	elseif name=="LeftShift" or name=="RightShift" then
		return "SHIFT"
	elseif name=="LeftAlt" or name=="RightAlt" then
		return "ALT"
	end
	local succ,c = pcall(string.char,Enum.KeyCode[name].Value)
	if succ and c:match("%S") then
		return c:upper()
	end
	return name:upper()
end
--// interface //
Create = function(class,parent,props)
	local new = Instance.new(class)
	for k,v in next,props do
		new[k]=v
	end
	new.Parent = parent
	return new
end
gui=Create("ScreenGui",CoreGui,{Name="Essence", ZIndexBehavior="Sibling", ResetOnSpawn=false, DisplayOrder=0})
Main=Create("ImageLabel",gui,{Name="Main", Image="rbxassetid://2851925780", BorderSizePixel=0, SliceCenter=Rect.new(15,15,15,15), ScaleType="Slice", BorderColor3=Color3.new(0.106,0.165,0.208), 
	BackgroundTransparency=1, Position=UDim2.new(0.75,0,1,-133), ImageColor3=Color3.new(0.176,0.176,0.176), Size=UDim2.new(0,171,0,310), BackgroundColor3=Color3.new(1,1,1), ImageTransparency=0.15})
noclipFrame=Create("ImageLabel",Main,{Name="noclipFrame", Image="rbxassetid://2851928141", SliceCenter=Rect.new(8,8,8,8), ScaleType="Slice", BorderColor3=Color3.new(0.106,0.165,0.208), BackgroundTransparency=1, 
	Position=UDim2.new(0,11,0,30), ImageColor3=Color3.new(0.902,0.902,0.902), Size=UDim2.new(0,150,0,25), BackgroundColor3=Color3.new(1,1,1)})
noclipBtn=Create("ImageButton",noclipFrame,{Name="noclipBtn", Image="rbxassetid://2851928141", SliceCenter=Rect.new(8,8,8,8), ScaleType="Slice", BorderColor3=Color3.new(0.106,0.165,0.208), Position=UDim2.new(0,1,0,1), 
	ImageColor3=Color3.new(0.176,0.176,0.176), Size=UDim2.new(1,-2,1,-2), BackgroundTransparency=1, BackgroundColor3=Color3.new(1,1,1)})
noclipLbl=Create("TextLabel",noclipBtn,{Name="noclipLbl", TextWrapped=true, Size=UDim2.new(0.4,0,1,0), BorderColor3=Color3.new(0.106,0.165,0.208), Text="OFF", TextSize=20, 
	TextXAlignment="Left", Font="SourceSansSemibold", BackgroundTransparency=1, Position=UDim2.new(0.6,0,0,0), TextColor3=Color3.new(0.902,0.902,0.902), BackgroundColor3=Color3.new(1,1,1)})
Label=Create("TextLabel",noclipBtn,{TextWrapped=true, Size=UDim2.new(0.58,0,1,0), BorderColor3=Color3.new(0.106,0.165,0.208), Text="NoClip:", TextSize=20, TextXAlignment="Right", 
	Font="SourceSansSemibold", BackgroundTransparency=1, TextColor3=Color3.new(0.902,0.902,0.902), BackgroundColor3=Color3.new(1,1,1)})
tpmodeFrame=Create("ImageLabel",Main,{Name="tpmodeFrame", Image="rbxassetid://2851928141", SliceCenter=Rect.new(8,8,8,8), ScaleType="Slice", BorderColor3=Color3.new(0.106,0.165,0.208), BackgroundTransparency=1, 
	Position=UDim2.new(0,11,0,78), ImageColor3=Color3.new(0.902,0.902,0.902), Size=UDim2.new(0,150,0,25), BackgroundColor3=Color3.new(1,1,1)})
tpmodeBtn=Create("ImageButton",tpmodeFrame,{Name="tpmodeBtn", Image="rbxassetid://2851928141", SliceCenter=Rect.new(8,8,8,8), ScaleType="Slice", BorderColor3=Color3.new(0.106,0.165,0.208), Position=UDim2.new(0,1,0,1), 
	ImageColor3=Color3.new(0.176,0.176,0.176), Size=UDim2.new(1,-2,1,-2), BackgroundTransparency=1, BackgroundColor3=Color3.new(1,1,1)})
tpmodeLbl=Create("TextLabel",tpmodeBtn,{Name="tpmodeLbl", TextWrapped=true, Size=UDim2.new(0.4,0,1,0), BorderColor3=Color3.new(0.106,0.165,0.208), Text=tpExact and "EXACT" or "MOVE", TextSize=20, 
	TextXAlignment="Left", Font="SourceSansSemibold", BackgroundTransparency=1, Position=UDim2.new(0.6,0,0,0), TextColor3=Color3.new(0.902,0.902,0.902), BackgroundColor3=Color3.new(1,1,1)})
Label_2=Create("TextLabel",tpmodeBtn,{TextWrapped=true, Size=UDim2.new(0.58,0,1,0), BorderColor3=Color3.new(0.106,0.165,0.208), Text="TpMode:", TextSize=20, TextXAlignment="Right", 
	Font="SourceSansSemibold", BackgroundTransparency=1, TextColor3=Color3.new(0.902,0.902,0.902), BackgroundColor3=Color3.new(1,1,1)})
espFrame=Create("ImageLabel",Main,{Name="espFrame", Image="rbxassetid://2851928141", SliceCenter=Rect.new(8,8,8,8), ScaleType="Slice", BorderColor3=Color3.new(0.106,0.165,0.208), BackgroundTransparency=1, 
	Position=UDim2.new(0,11,0,54), ImageColor3=Color3.new(0.902,0.902,0.902), Size=UDim2.new(0,150,0,25), BackgroundColor3=Color3.new(1,1,1)})
espBtn=Create("ImageButton",espFrame,{Name="espBtn", Image="rbxassetid://2851928141", SliceCenter=Rect.new(8,8,8,8), ScaleType="Slice", BorderColor3=Color3.new(0.106,0.165,0.208), Position=UDim2.new(0,1,0,1), 
	ImageColor3=Color3.new(0.176,0.176,0.176), Size=UDim2.new(1,-2,1,-2), BackgroundTransparency=1, BackgroundColor3=Color3.new(1,1,1)})
espLbl=Create("TextLabel",espBtn,{Name="espLbl", TextWrapped=true, Size=UDim2.new(0.4,0,1,0), BorderColor3=Color3.new(0.106,0.165,0.208), Text="OFF", TextSize=20, 
	TextXAlignment="Left", Font="SourceSansSemibold", BackgroundTransparency=1, Position=UDim2.new(0.6,0,0,0), TextColor3=Color3.new(0.902,0.902,0.902), BackgroundColor3=Color3.new(1,1,1)})
Label_3=Create("TextLabel",espBtn,{TextWrapped=true, Size=UDim2.new(0.58,0,1,0), BorderColor3=Color3.new(0.106,0.165,0.208), Text="BoxESP:", TextSize=20, TextXAlignment="Right", 
	Font="SourceSansSemibold", BackgroundTransparency=1, TextColor3=Color3.new(0.902,0.902,0.902), BackgroundColor3=Color3.new(1,1,1)})
cmdFrame=Create("ImageLabel",Main,{Name="cmdFrame", Image="rbxassetid://2851928141", SliceCenter=Rect.new(8,8,8,8), ScaleType="Slice", BorderColor3=Color3.new(0.106,0.165,0.208), BackgroundTransparency=1, 
	Position=UDim2.new(0,11,0,107), ImageColor3=Color3.new(0.902,0.902,0.902), Size=UDim2.new(0,150,0,23), BackgroundColor3=Color3.new(1,1,1)})
cmdBox=Create("TextBox",cmdFrame,{Name="cmdBox", TextWrapped=true, PlaceholderColor3=Color3.new(0.498,0.498,0.498), PlaceholderText=string.gsub(";rj ;goto ;hh ;ws ;jp",";",shortenKey(settings.cmdKey)), Size=UDim2.new(0.9,0,0.8,0),
	BorderColor3=Color3.new(0.106,0.165,0.208), Text="", TextSize=20, TextColor3=Color3.new(0.176,0.176,0.176), Font="SourceSans", BackgroundTransparency=1, Position=UDim2.new(0.05,0,0.05,0), BackgroundColor3=Color3.new(1,1,1)})
arrowBtn=Create("ImageButton",Main,{Name="arrowBtn", Image="rbxassetid://3070990525", BorderColor3=Color3.new(0.106,0.165,0.208), Rotation=90, Position=UDim2.new(0,71,0,-21), ImageColor3=Color3.new(0.902,0.902,0.902), 
	Size=UDim2.new(0,25,0,70), BackgroundTransparency=1, BackgroundColor3=Color3.new(1,1,1)})
cogBtn=Create("ImageButton",Main,{Name="cogBtn", Image="rbxassetid://1533715539", BorderColor3=Color3.new(0.106,0.165,0.208), Position=UDim2.new(0,13,0,3), ImageColor3=Color3.new(0.902,0.902,0.902), Size=UDim2.new(0,23,0,23), 
	BackgroundTransparency=1, BackgroundColor3=Color3.new(1,1,1)})
Options=Create("Folder",Main,{Name="Options"})
noclipKeyBox=Create("TextBox",Options,{Name="noclipKeyBox", TextWrapped=true, PlaceholderColor3=Color3.new(0.698,0.698,0.698), Size=UDim2.new(0,35,0,16), BorderColor3=Color3.new(0.106,0.165,0.208), Text=shortenKey(settings.noclipKey), 
	TextSize=14, TextColor3=Color3.new(0.176,0.176,0.176), Font="SourceSansBold", Position=UDim2.new(0,125,0,162), TextScaled=true, BackgroundColor3=Color3.new(0.902,0.902,0.902)})
noclipKeyLbl=Create("TextLabel",Options,{Name="noclipKeyLbl", TextWrapped=true, Size=UDim2.new(0,105,0,16), BorderColor3=Color3.new(0.106,0.165,0.208), Text="Noclip key", TextSize=17, 
	Font="Fantasy", BackgroundTransparency=1, Position=UDim2.new(0,11,0,160), TextColor3=Color3.new(0.902,0.902,0.902), BackgroundColor3=Color3.new(1,1,1), TextXAlignment="Left"})
clicktpKeyBox=Create("TextBox",Options,{Name="clicktpKeyBox", TextWrapped=true, PlaceholderColor3=Color3.new(0.698,0.698,0.698), Size=UDim2.new(0,35,0,16), BorderColor3=Color3.new(0.106,0.165,0.208), Text=shortenKey(settings.clicktpKey), 
	TextSize=14, TextColor3=Color3.new(0.176,0.176,0.176), Font="SourceSansBold", Position=UDim2.new(0,125,0,210), TextScaled=true, BackgroundColor3=Color3.new(0.902,0.902,0.902)})
clicktpKeyLbl=Create("TextLabel",Options,{Name="clicktpKeyLbl", TextWrapped=true, Size=UDim2.new(0,105,0,16), BorderColor3=Color3.new(0.106,0.165,0.208), Text="ClickTP key", TextSize=17, 
	Font="Fantasy", BackgroundTransparency=1, Position=UDim2.new(0,11,0,208), TextColor3=Color3.new(0.902,0.902,0.902), BackgroundColor3=Color3.new(1,1,1), TextXAlignment="Left"})
cmdKeyBox=Create("TextBox",Options,{Name="cmdKeyBox", TextWrapped=true, PlaceholderColor3=Color3.new(0.698,0.698,0.698), Size=UDim2.new(0,35,0,16), BorderColor3=Color3.new(0.106,0.165,0.208), Text=shortenKey(settings.cmdKey), 
	TextSize=14, TextColor3=Color3.new(0.176,0.176,0.176), Font="SourceSansBold", Position=UDim2.new(0,125,0,138), TextScaled=true, BackgroundColor3=Color3.new(0.902,0.902,0.902)})
cmdKeyLbl=Create("TextLabel",Options,{Name="cmdKeyLbl", TextWrapped=true, Size=UDim2.new(0,105,0,16), BorderColor3=Color3.new(0.106,0.165,0.208), Text="Command key", TextSize=17, 
	Font="Fantasy", BackgroundTransparency=1, Position=UDim2.new(0,11,0,138), TextColor3=Color3.new(0.902,0.902,0.902), BackgroundColor3=Color3.new(1,1,1), TextXAlignment="Left"})
clickespKeyBox=Create("TextBox",Options,{Name="clickespKeyBox", TextWrapped=true, PlaceholderColor3=Color3.new(0.698,0.698,0.698), Size=UDim2.new(0,35,0,16), BorderColor3=Color3.new(0.106,0.165,0.208), Text=shortenKey(settings.clickespKey), 
	TextSize=14, TextColor3=Color3.new(0.176,0.176,0.176), Font="SourceSansBold", Position=UDim2.new(0,125,0,186), TextScaled=true, BackgroundColor3=Color3.new(0.902,0.902,0.902)})
clickespKeyLbl=Create("TextLabel",Options,{Name="clickespKeyLbl", TextWrapped=true, Size=UDim2.new(0,105,0,16), BorderColor3=Color3.new(0.106,0.165,0.208), Text="ClickESP key", TextSize=17, 
	Font="Fantasy", BackgroundTransparency=1, Position=UDim2.new(0,11,0,184), TextColor3=Color3.new(0.902,0.902,0.902), BackgroundColor3=Color3.new(1,1,1), TextXAlignment="Left"})
tpignoreBtn=Create("TextButton",Options,{Name="tpignoreBtn", TextWrapped=true, Size=UDim2.new(0,25,0,16), TextColor3=Color3.new(0.176,0.176,0.176), BorderColor3=Color3.new(0.106,0.165,0.208), Text=tpIgnore and 'X' or '', 
	Font="SourceSansBold", Position=UDim2.new(0,131,0,258), TextSize=23, BackgroundColor3=Color3.new(0.902,0.902,0.902)})
tpignoreLbl=Create("TextLabel",Options,{Name="tpignoreLbl", TextWrapped=true, Size=UDim2.new(0,105,0,40), BorderColor3=Color3.new(0.106,0.165,0.208), Text="Clicks ignore transparent", TextSize=17, 
	Font="Fantasy", BackgroundTransparency=1, Position=UDim2.new(0,11,0,256), TextColor3=Color3.new(0.902,0.902,0.902), TextYAlignment="Top", BackgroundColor3=Color3.new(1,1,1), TextXAlignment="Left"})
espLimitBox=Create("TextBox",Options,{Name="espLimitBox", TextWrapped=true, PlaceholderColor3=Color3.new(0.698,0.698,0.698), Size=UDim2.new(0,35,0,16), BorderColor3=Color3.new(0.106,0.165,0.208), Text=tostring(espLimit), 
	TextSize=14, TextColor3=Color3.new(0.176,0.176,0.176), Font="SourceSansBold", Position=UDim2.new(0,125,0,234), TextScaled=true, BackgroundColor3=Color3.new(0.902,0.902,0.902)})
espLimitLbl=Create("TextLabel",Options,{Name="espLimitLbl", TextWrapped=true, Size=UDim2.new(0,105,0,16), BorderColor3=Color3.new(0.106,0.165,0.208), Text="ESP max studs", TextSize=17, 
	Font="Fantasy", BackgroundTransparency=1, Position=UDim2.new(0,11,0,232), TextColor3=Color3.new(0.902,0.902,0.902), BackgroundColor3=Color3.new(1,1,1), TextXAlignment="Left"})
containerStats=Create("Frame",gui,{Name="containerStats", BorderColor3=Color3.new(0.106,0.165,0.208), BackgroundTransparency=1, Size=UDim2.new(0,200,0,50), Position=UDim2.new(0.75,175,1,-51)})
fpsLbl=Create("TextLabel",containerStats,{Name="fpsLbl", TextWrapped=true, TextStrokeTransparency=0.30000001192093, Size=UDim2.new(0.33,0,0.5,0), BorderColor3=Color3.new(0.106,0.165,0.208), Text="60 FPS", 
	TextSize=25, Font="SourceSans", BackgroundTransparency=1, Position=UDim2.new(0.15,0,0,0), TextColor3=Color3.new(1,1,1), BackgroundColor3=Color3.new(1,1,1)})
timeLbl=Create("TextLabel",containerStats,{Name="timeLbl", TextWrapped=true, TextStrokeTransparency=0.30000001192093, Size=UDim2.new(0.33,0,0.5,0), BorderColor3=Color3.new(0.106,0.165,0.208), Text="0:00", 
	TextSize=25, Font="SourceSans", BackgroundTransparency=1, Position=UDim2.new(0.52,0,0,0), TextColor3=Color3.new(1,1,1)})
xLbl=Create("TextLabel",containerStats,{Name="xLbl", TextWrapped=true, TextStrokeTransparency=0.30000001192093, Size=UDim2.new(0.333,0,0.5,0), BorderColor3=Color3.new(0.106,0.165,0.208), Text="0.00", 
	TextSize=25, Font="SourceSans", BackgroundTransparency=1, Position=UDim2.new(0,0,0.5,0), TextColor3=Color3.new(1,0,0)})
yLbl=Create("TextLabel",containerStats,{Name="yLbl", TextWrapped=true, TextStrokeTransparency=0.30000001192093, Size=UDim2.new(0.333,0,0.5,0), BorderColor3=Color3.new(0.106,0.165,0.208), Text="0.00", 
	TextSize=25, Font="SourceSans", BackgroundTransparency=1, Position=UDim2.new(0.333,0,0.5,0), TextColor3=Color3.new(0,1,0)})
zLbl=Create("TextLabel",containerStats,{Name="zLbl", TextWrapped=true, TextStrokeTransparency=0.30000001192093, Size=UDim2.new(0.333,0,0.5,0), BorderColor3=Color3.new(0.106,0.165,0.208), Text="0.00", 
	TextSize=25, Font="SourceSans", BackgroundTransparency=1, Position=UDim2.new(0.666,0,0.5,0), TextColor3=Color3.new(1,1,0)})
copyPosBtn=Create("TextButton",containerStats,{Name="copyPosBtn", BackgroundTransparency=1, Size=UDim2.new(1,0,0.5,0), Position=UDim2.new(0,0,0.5,0), TextScaled=true, Text="Copy position", TextColor3=Color3.new(1,1,1),
	BackgroundColor3=Color3.new(), Font="SourceSansLight", BorderSizePixel=0, ZIndex=2, TextTransparency=1})
partInfoGui=Create("BillboardGui",gui,{Name="partInfoGui", AlwaysOnTop=true, StudsOffset=Vector3.new(0,5,0), ResetOnSpawn=false, Size=UDim2.new(0,40,0,40), Enabled=false, Active=true})
partNameLbl=Create("TextLabel",partInfoGui,{Name="partNameLbl", BackgroundTransparency=1, Size=UDim2.new(1,0,0.5,0), Font="Highway", TextColor3=Color3.new(1,0.667,0), TextSize=26, TextStrokeTransparency=0})
partPosLbl=Create("TextLabel",partInfoGui,{Name="partPosLbl", BackgroundTransparency=1, Size=UDim2.new(1,0,0.5,0), Position=UDim2.new(0,0,0.5,0), TextColor3=Color3.new(1,1,1), TextSize=13, TextStrokeTransparency=0})
partInfoBox=Create("SelectionBox",partInfoGui,{Color3=Color3.new(1,0.5,0), LineThickness=0.2})
partDelBtn=Create("ImageButton",partInfoGui,{Name="partDelBtn", BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), ZIndex=2, Image="rbxassetid://2290983952", ImageTransparency=1})
espGui = Create("Folder",CoreGui,{Name="EssenceESP"})
bbTemplate = Create("BillboardGui",nil,{AlwaysOnTop=true, ResetOnSpawn=false, Size=UDim2.new(1,200,1,17), SizeOffset=Vector2.new(0,0.375), StudsOffset=Vector3.new(0,2.5,0)})
Create("TextLabel",bbTemplate,{Name="NameTag", BackgroundTransparency=1, Size=UDim2.new(1,0,0.75,0), TextScaled=true, Font="SourceSansBold"})
Create("Frame",bbTemplate,{Name="Dot", BorderSizePixel=0, Size=UDim2.new(0,4,0,4), Position=UDim2.new(0.5,-2,0.75,0)})
boxTemplate = Create("BoxHandleAdornment",nil,{Name="Box", AlwaysOnTop=true, ZIndex=1, Size=Vector3.new(4,5.5,2), CFrame=CFrame.new(0,-0.25,0)})
creditLbl = Create("TextLabel",Main,{BackgroundTransparency=1, Size=UDim2.new(0,80,0,20), Position=UDim2.new(1,63,0.7,0), Font="SourceSansLight", TextColor3=Color3.new(1,1,1), TextScaled=true, Text="by sirelKilla", TextStrokeTransparency=.8})
--gui code
local function clickEffect(img)
	local oldcol = img.ImageColor3
	if oldcol.r*255 < 89 then
		img.ImageColor3 = Color3.fromRGB(90,90,90)
		wait(0.07)
		img.ImageColor3 = oldcol
	end
end
local cogOut = false
local arrowOut = true
local function onArrowClicked()
	if not cogOut then
		arrowOut = not arrowOut
		if arrowOut then
			Main:TweenPosition(UDim2.new(0.75,0,1,-133),nil,"Quart",0.2,true)
		else
			Main:TweenPosition(UDim2.new(0.75,0,1,-30),nil,"Quart",0.2,true)
		end
	end
end
arrowBtn.MouseButton1Click:Connect(onArrowClicked)
local cogReturnPos = Main.Position
cogBtn.MouseButton1Click:Connect(function()
	cogOut = not cogOut
	if cogOut then
		cogReturnPos = Main.Position
		Main:TweenPosition(UDim2.new(0.75,0,1,-292),nil,"Quart",0.3,true)
		local dir = 1
		while cogOut do
			local n = cogBtn.ImageTransparency
			cogBtn.ImageTransparency = n+0.0333*dir
			if (dir==1 and n>0.5) or (dir==-1 and n<=0) then
				dir = -dir
			end
			wait()
		end
		cogBtn.ImageTransparency = 0
	else
		cogBtn.ImageTransparency = 0
		Main:TweenPosition(cogReturnPos,nil,"Quart",0.3,true)
	end
end)
local oldNameDist = player.NameDisplayDistance
local espOn = false
espBtn.MouseButton1Down:Connect(function()
	espOn = not espOn
	espLbl.Text = espOn and "ON" or "OFF"
	if espOn then
		player.NameDisplayDistance = 0
		espManage()
	else
		player.NameDisplayDistance = oldNameDist
		for _,folder in ipairs(espGui:GetChildren()) do
			if Players:FindFirstChild(folder.Name) then
				folder.Box.Visible = false
				folder.BillboardGui.Enabled = false
			else
				folder:Destroy()
			end
		end
	end
	clickEffect(espBtn)
end)
local noclipOn = false
noclipBtn.MouseButton1Down:Connect(function()
	noclipOn = not noclipOn
	noclipLbl.Text = noclipOn and "ON" or "OFF"
	clickEffect(noclipBtn)
end)
tpmodeBtn.MouseButton1Down:Connect(function()
	tpExact = not tpExact
	tpmodeLbl.Text = tpExact and "EXACT" or "MOVE"
	clickEffect(tpmodeBtn)
end)
tpignoreBtn.MouseButton1Click:Connect(function()
	tpIgnore = not tpIgnore
	tpignoreBtn.Text = tpIgnore and 'X' or ''
end)
local tweenDelOut = game:GetService("TweenService"):Create(partDelBtn,TweenInfo.new(0.33),{ImageTransparency=0})
local tweenDelIn = game:GetService("TweenService"):Create(partDelBtn,TweenInfo.new(0.33),{ImageTransparency=1})
partDelBtn.MouseEnter:Connect(function() tweenDelOut:Play()  end)
partDelBtn.MouseLeave:Connect(function() tweenDelIn:Play() end)
local function hidePartInfo()
	partInfoBox.Adornee = nil
	partInfoGui.Adornee = nil
	partInfoGui.Enabled = false
	partInfoBox.Visible = false
	partDelBtn.ImageTransparency = 1
	tweenDelIn:Play()
end
partDelBtn.MouseButton1Click:Connect(function()
	if partInfoGui.Adornee and partInfoGui.Adornee.Parent and partDelBtn.ImageTransparency < 0.1 and not UIS:IsKeyDown(settings.clickespKey) then
		partInfoGui.Adornee:Destroy()
		hidePartInfo()
	end
end)
cmdBox.FocusLost:Connect(function(enterPressed)
	local msg = cmdBox.Text:lower()
	cmdBox.Text = ''
	if enterPressed then
		if msg:sub(1,1):byte() == Enum.KeyCode[settings.cmdKey].Value then
			msg = msg:sub(2)
		end
		for cmd,callback in pairs(adminCommands) do
			if msg:sub(1,#cmd)==cmd and (msg..' '):sub(#cmd+1,#cmd+1) == ' ' then
				callback(msg:sub(#cmd+2))
				break
			end
		end
	end
end)
local oldEspLimit = espLimitBox.Text
espLimitBox:GetPropertyChangedSignal("Text"):Connect(function()
	if #espLimitBox.Text>4 or espLimitBox.Text:match("%D") then
		espLimitBox.Text = oldEspLimit
	end
	oldEspLimit = espLimitBox.Text
end)
if setclipboard or Clipboard then
	local tweenCopyOut = game:GetService("TweenService"):Create(copyPosBtn,TweenInfo.new(0.33),{TextTransparency=0,BackgroundTransparency=0.4})
	local tweenCopyIn = game:GetService("TweenService"):Create(copyPosBtn,TweenInfo.new(0.33),{TextTransparency=1,BackgroundTransparency=1})
	copyPosBtn.MouseEnter:Connect(function() tweenCopyOut:Play() end)
	copyPosBtn.MouseLeave:Connect(function() tweenCopyIn:Play() end)
	copyPosBtn.MouseButton1Click:Connect(function()
		local pos = root.Position
		if setclipboard then
			setclipboard(string.format("%.2f, %.2f, %.2f",pos.X,pos.Y,pos.Z))
		else
			Clipboard.set(string.format("%.2f, %.2f, %.2f",pos.X,pos.Y,pos.Z))
		end
	end)
end
--// input //
local function onMouseDown()
	if UIS:IsKeyDown(settings.clickespKey) or UIS:IsKeyDown(settings.clicktpKey) then
		local UnitRay = cam:ViewportPointToRay(UIS:GetMouseLocation().X,UIS:GetMouseLocation().Y)
		local part,hitp,normal
		repeat
			part,hitp,normal = workspace:FindPartOnRayWithIgnoreList(Ray.new(hitp or UnitRay.Origin,UnitRay.Direction*5000),{player.Character,part})
		until part==nil or tpIgnore==false or part.Transparency<0.9
		if part then
			if UIS:IsKeyDown(settings.clicktpKey) then
				if game.PlaceId==606849621 then
					local door = workspace.Apartments.Skyscraper6.ExitDoor.Touch
					local oldcf = door.CFrame
					door.CFrame = root.CFrame
					wait()
					door.CFrame = oldcf
				end
				if tpExact then
					root.CFrame = (root.CFrame-root.CFrame.p)+(hitp+normal*3.2)
				else
					player.Character:MoveTo(hitp+Vector3.new(0,3.2,0))
				end
			elseif partInfoBox.Adornee == part then
				hidePartInfo()
			else
				partNameLbl.Text = "Workspace".. part:GetFullName():sub(#workspace.Name+1)
				partPosLbl.Text = string.format("%.2f, %.2f, %.2f",part.Position.X,part.Position.Y,part.Position.Z)
				partInfoGui.Adornee = part
				partInfoBox.Adornee = part
				partInfoGui.Enabled = true
				partInfoBox.Visible = true
			end
		end
	end
end
local noclipPressedTick = 0
UIS.InputBegan:Connect(function(input,gpe)
	local box = UIS:GetFocusedTextBox()
	if input.KeyCode==Enum.KeyCode.F9 then
		--old console
		local visible = not StarterGui:GetCore("DeveloperConsoleVisible")
		StarterGui:SetCore("DevConsoleVisible", false)
		StarterGui:SetCore("DeveloperConsoleVisible", visible)
		wait()
		StarterGui:SetCore("DevConsoleVisible", false)
		StarterGui:SetCore("DeveloperConsoleVisible", visible)
		if visible then
			local optionsFrame = CoreGui.RobloxGui:WaitForChild("DeveloperConsole"):WaitForChild("Interior"):WaitForChild("OptionsClippingFrame"):WaitForChild("OptionsFrame"):WaitForChild("Log")
			wait()
			for _,v in ipairs(optionsFrame:GetChildren()) do
				if v.Name=="Checkbox" and v.Position.X.Offset > 200 and v.Button.Check.Visible==false then
					--enable word wrap
					local btn = v.Button
					btn.BackgroundTransparency = 1
					btn.Check.BackgroundTransparency = 1
					btn.Parent = CoreGui.RobloxGui.DeveloperConsole
					wait()
					game:GetService("VirtualInputManager"):SendMouseButtonEvent(btn.AbsolutePosition.X+99, btn.AbsolutePosition.Y+99, 0, true, game)
					wait()
					game:GetService("VirtualInputManager"):SendMouseButtonEvent(btn.AbsolutePosition.X+99, btn.AbsolutePosition.Y+99, 0, false, game)
					wait()
					btn.Check.BackgroundTransparency = 0
					btn.Parent = v
					break
				end
			end
		end
	elseif box then
		if box ~= espLimitBox and box.Parent == Options and input.UserInputType==Enum.UserInputType.Keyboard then
			box.Text = shortenKey(input.KeyCode.Name)
			box:ReleaseFocus()
			settings[box.Name:sub(1,-4)] = input.KeyCode.Name
			noclipPressedTick = tick()
			cmdBox.PlaceholderText = string.gsub(";rj ;goto ;hh ;ws ;jp",";",shortenKey(settings.cmdKey))
		end
	elseif input.UserInputType==Enum.UserInputType.MouseButton1 then
		onMouseDown()
	elseif input.KeyCode == Enum.KeyCode.B and UIS:IsKeyDown(Enum.KeyCode.LeftAlt) then
		--press ALT+B to toggle backpack
		StarterGui:SetCoreGuiEnabled("Backpack", not StarterGui:GetCoreGuiEnabled("Backpack"))
	elseif input.KeyCode.Name == settings.cmdKey then
		wait()
		cmdBox:CaptureFocus()
		if not arrowOut then
			onArrowClicked()
		end
	elseif input.KeyCode.Name == settings.noclipKey then
		noclipOn = not noclipOn
		noclipLbl.Text = noclipOn and "ON" or "OFF"
		noclipPressedTick = tick()
	end
end)
UIS.InputEnded:Connect(function(input,gpe)
	if UIS:GetFocusedTextBox()==nil and input.KeyCode.Name == settings.noclipKey and tick()-noclipPressedTick > 0.1 then
		noclipOn = not noclipOn
		noclipLbl.Text = noclipOn and "ON" or "OFF"
	end
end)
UIS.TextBoxFocusReleased:Connect(function(box)
	if box == espLimitBox then
		if tonumber(espLimitBox.Text) then
			espLimit=tonumber(espLimitBox.Text)
		end
		espLimitBox.Text=tostring(espLimit)
		if espOn then
			espManage()
		end
	elseif box.Parent == Options and box.Text == '' then
		settings[box.Name:sub(1,-4)] = "World69"
	end
end)
--// handle character //
local noclipParts = {}
local lastRootCf
local function onRootChanged()
	if (root.CFrame.p-Vector3.new(-38.7,19.5,1094.2)).magnitude < 1 then
		root.CFrame = lastRootCf
	end
end
local function onNewChar(char)
	if not char then return end
	root = char:WaitForChild("HumanoidRootPart",4)
	root:GetPropertyChangedSignal("CFrame"):Connect(onRootChanged)
	wait(0.5)
	if char~=player.Character then return end
	noclipParts = {}
	for _,v in ipairs(char:GetChildren()) do
		if v:IsA("BasePart") then
			noclipParts[#noclipParts+1]=v
		end
	end
end
player.CharacterAdded:Connect(onNewChar)
onNewChar(player.Character)
game:GetService("RunService").Stepped:Connect(function()
	if root then
		lastRootCf = root.CFrame
	end
	if noclipOn then
		for i=1,#noclipParts do
			noclipParts[i].CanCollide=false
		end
	end
end)
--// stats loops //
local elapsed = 0
local frames = 0
game:GetService("RunService"):BindToRenderStep(tostring(math.random()),1,function(delta)
	elapsed=elapsed+delta
	if elapsed > 1 then
		fpsLbl.Text = tostring(frames).." FPS"
		elapsed = 0
		frames = 0
	else
		frames=frames+1
	end
end)
while true do
	if root then
		xLbl.Text = string.format("%.2f",root.Position.X)
		yLbl.Text = string.format("%.2f",root.Position.Y)
		zLbl.Text = string.format("%.2f",root.Position.Z)
	end
	timeLbl.Text = string.format("%d:%.2d", workspace.DistributedGameTime/60,workspace.DistributedGameTime%60)
	if partInfoGui.Enabled and partInfoGui.Adornee then
		local pos = partInfoGui.Adornee.Position
		partPosLbl.Text = string.format("%.2f, %.2f, %.2f",pos.X,pos.Y,pos.Z)
	end
	if espOn and tick()-espManagementTick > ((Random==nil or PluginManager==nil) and 1 or 0.5) then
		espManage()
	end
	wait(0.1)
end