repeat task.wait(1) until game:IsLoaded()

task.wait(3)

local quene = ""
local queued = false

local SetStatus = function(text)
	game.StarterGui:SetCore("SendNotification", {
		Title = "Dropfarm 2019",
		Text = text,
		Duration = 1.2,
	})
end

local ServerHop = function()
	
	SetStatus("Server hopping...")
	
	if queued == false then
		queued = true

		quene = quene .. ' loadstring(game:HttpGet("https://dropfarms.xyz/og.lua",true))()'
		if syn then
			syn.queue_on_teleport(quene)
		else
			queue_on_teleport(quene)
		end
	end
	
	while true do
		local Servers = "https://games.roblox.com/v1/games/".. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
		local Server, Next = nil, nil

		local function ListServers(cursor)
			local Raw = game:HttpGet(Servers .. ((cursor and "&cursor="..cursor) or ""))

			return game:GetService("HttpService"):JSONDecode(Raw)
		end

		repeat
			local Servers = ListServers(Next)
			Server = Servers.data[math.random(1, (#Servers.data / 3))]
			Next = Servers.nextPageCursor
		until Server

		if Server.playing < Server.maxPlayers and Server.id ~= game.JobId then
			pcall(function()
				game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, Server.id, game.Players.LocalPlayer)
			end)
		end

		task.wait(10)
	end
end

local RobDrop = function(drop)
	local timeout = tick()

	if drop then
		
		SetStatus("Collecting drop...")
		
		task.spawn(function()
			while drop do
				wait()
				for _, spec in pairs(require(game.ReplicatedStorage.Module.UI).CircleAction.Specs) do
					if spec.Name == "Pick up briefcase" then
						spec:Callback(true)
					end
				end
			end
		end)

		repeat
			task.wait()

			game.Players.LocalPlayer.Character:PivotTo(drop.PrimaryPart.CFrame)
		until drop == nil or drop.PrimaryPart == nil or tick() - timeout > 5

		drop:Remove()
	end
end

while wait() do
	if game.Workspace:FindFirstChild("Drop") then
		pcall(RobDrop, game.Workspace.Drop)
	else
		ServerHop()
	end
end
