repeat wait() until game:IsLoaded()

local SlashMacLIB = {}

do
	local getService = function(name)
		repeat wait() until game:GetService(name) ~= nil
		return game:GetService(name)
	end
	
	local sendNotification = function(title, content)
		getService('StarterGui'):SetCore('SendNotification', {
			Title = title or 'No Title';
			Text = content or 'No Content';
		})
	end
	
	local Main = {
		Services = {
			['CoreGui'] = getService('CoreGui');
			['Players'] = getService('Players');
			['ReplicatedStorage'] = getService('ReplicatedStorage');
			['RunService'] = getService('RunService');
			['UserInputService'] = getService('UserInputService');
			['Workspace'] = getService('Workspace');
		};
	
		REQUIRED = {
			['getgenv'] = pcall(function()return getgenv end) and getgenv;
			-- ['Drawing'] = pcall(function()return Drawing end) and Drawing;
		};
	
		MISSING = {};
	
		COLOR = {
			WINDOW = Color3.fromRGB(40,40,40);
			WINDOW_CLOSED = Color3.fromRGB(80, 0, 140);
			WINDOW_OPENED = Color3.fromRGB(0, 0, 140);
			TEXT = Color3.fromRGB(180,180,180);
			BUTTONBG = Color3.fromRGB(60,60,60);
			BUTTONTEXT = Color3.fromRGB(180,180,180);
			SELECTEDBG = Color3.fromRGB(80,80,80);
			SELECTEDTEXT = Color3.fromRGB(200,200,200);
			TITLEBAR = Color3.fromRGB(30,30,30);
		}
	}

	for a,b in next, Main.REQUIRED do
		if not b then
			table.insert(Main.MISSING, a)
		end
	end

	if #Main.MISSING ~= 0 then
		sendNotification('[UI LIB] Missing Feature(s)', table.concat(Main.MISSING, ', '))
		script:Destroy()
		return nil
	end

	if getgenv().LBConnections and typeof(getgenv().LBConnections) == 'table' then
		for a,b in next, getgenv().LBConnections do
			b:Disconnect()
		end
	end

	for a,b in next, Main.Services.CoreGui:children() do
		if string.find(b.Name, 'LB UI Library') then
			b:Destroy()
		end
	end

	if getgenv().UILibrary_Loading then return nil end
	getgenv().UILibrary_Loading = true

	if Drawing then
    local RunService = game:GetService("RunService")
    local camera = workspace.CurrentCamera
    local center = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)

    local bg = Drawing.new("Square")
    bg.Size = camera.ViewportSize
    bg.Position = Vector2.new(0,0)
    bg.Color = Color3.fromRGB(245,245,247)
    bg.Filled = true
    bg.Transparency = 0
    bg.Visible = true

    for i = 0,1,0.05 do
        bg.Transparency = i
        RunService.RenderStepped:Wait()
    end

    local logo = Drawing.new("Circle")
    logo.Radius = 0
    logo.Position = center
    logo.Color = Color3.fromRGB(0,0,0)
    logo.Filled = true
    logo.Transparency = 1
    logo.Visible = true

    for i = 1,40 do
        RunService.RenderStepped:Wait()
        logo.Radius = i
    end

    local text = Drawing.new("Text")
    text.Text = "Loading..."
    text.Center = true
    text.Color = Color3.fromRGB(60,60,60)
    text.Size = 20
    text.Position = center + Vector2.new(0,60)
    text.Transparency = 1
    text.Visible = true

    for i = 0,1,0.05 do
        RunService.RenderStepped:Wait()
        text.Transparency = i
    end

    local barBg = Drawing.new("Square")
    barBg.Size = Vector2.new(200,6)
    barBg.Position = center + Vector2.new(-100,100)
    barBg.Color = Color3.fromRGB(220,220,220)
    barBg.Filled = true
    barBg.Transparency = 1
    barBg.Visible = true

    local bar = Drawing.new("Square")
    bar.Size = Vector2.new(0,6)
    bar.Position = barBg.Position
    bar.Color = Color3.fromRGB(0,0,0)
    bar.Filled = true
    bar.Transparency = 1
    bar.Visible = true

    for i = 0,200 do
        RunService.RenderStepped:Wait()
        bar.Size = Vector2.new(i,6)
    end

    task.wait(0.5)

    for i = 1,0,-0.03 do
        RunService.RenderStepped:Wait()
        bg.Transparency = i
        logo.Transparency = i
        text.Transparency = i
        bar.Transparency = i
        barBg.Transparency = i
    end

    bg:Remove()
    logo:Remove()
    text:Remove()
    bar:Remove()
    barBg:Remove()
end

	getgenv().UILibrary_Loading = false

	Main.GUI = Instance.new('ScreenGui', Main.Services.CoreGui)
    Main.GUI.ZIndexBehavior = Enum.ZIndexBehavior.Global
	Main.GUI.Name = 'LB UI Library' .. getService('HttpService'):GenerateGUID()
	sendNotification('Library Loaded!', 'Press F1 to show/hide windows!\n - Palmheungmin')

	function SlashMacLIB:Create(window, instance, props)
		local a = Instance.new(instance)
		for b,c in next, props do
			if b ~= 'Parent' then
				pcall(function()a[b]=c;end)
				pcall(function()a['BorderSizePixel']=0;end)
				pcall(function()a['ZIndex']=0;end)
			end
		end

		if window then
			a.Parent = window
		else
			a.Parent = Main.GUI
		end

		return a
	end

	local windowPos = 0
	getgenv().LBConnections = {}

	local windowMoving = false
	local currentWindow = nil
	local windowFocused = false
	local sliderFocused = false
	local sliderMoving = false
	local selectionOpened = false
	local mouseDown = false

	table.insert(getgenv().LBConnections,
		Main.Services.UserInputService.InputEnded:connect(function(key)
			if key.UserInputType == Enum.UserInputType.MouseButton1 then
				mouseDown = false
			end
		end)
	)

	function SlashMacLIB:AddWindow(title)
		local height = 40
		local transition = false
		local closed = false
		local window = self:Create(nil, 'Frame', {
			AnchorPoint = Vector2.new(0,0);
			BackgroundColor3 = Main.COLOR.WINDOW;
			Position = UDim2.new(0,windowPos,0,0);
			Size = UDim2.new(0,200,0,height);
			ZIndex = 0;
		})

		self:Create(window, 'Frame', {
			BackgroundColor3 = Main.COLOR.TITLEBAR;
			Position = UDim2.new(0,0,0,0);
			Size = UDim2.new(1,0,0,25);
		})

		table.insert(getgenv().LBConnections,
			Main.Services.UserInputService.InputBegan:connect(function(key)
				if window ~= nil then
					if key.KeyCode == Enum.KeyCode.F1 then
						window.Visible = not window.Visible
					elseif key.UserInputType == Enum.UserInputType.MouseButton1 then
						mouseDown = true
					end
				end
			end)
		)

        local function bringToFront(gui)
            for _, v in pairs(gui:GetDescendants()) do
                if v:IsA("GuiObject") then
                    v.ZIndex = 999
                end
            end
            gui.ZIndex = 999
        end
		
		windowPos = windowPos + 250
		
		self:Create(window, 'TextLabel', {
			BackgroundTransparency = 1;
			Position = UDim2.new(.5,0,0,1);
			TextColor3 = Main.COLOR.TEXT;
			TextSize = 14;
			TextXAlignment = 2;
			TextYAlignment = 0;
			Text = title or 'Untitled';
			Font = Enum.Font.Gotham;
		})
		
		------------------

		local rBtn = self:Create(window, 'ImageButton', {
			BackgroundTransparency = 1;
			Image = 'rbxthumb://type=Asset&id=4693046251&w=150&h=150';
			ImageTransparency = 0;
			Position = UDim2.new(0,29,0,5);
			Size = UDim2.new(0,10,0,10);
			ScaleType = Enum.ScaleType.Fit;
			Text = '';
			TextColor3 = Main.COLOR.TEXT
		})

		rBtn.MouseButton1Click:connect(function()
			if currentWindow == window then
				if #Main.GUI:children() == 1 then
					currentWindow = nil
					Main.GUI:Destroy()
					script:Destroy()
				end
				pcall(function()
					windowPos = windowPos - 250
					if connection then
						pcall(function()
							for a,b in next, getgenv().LBConnections do
								if b == connection then
									table.remove(getgenv().LBConnections, a)
									connection:Disconnect()
								end
							end
						end)
					end
					currentWindow = nil
					window:Destroy()
				end)
			end
		end)

		------------------

		local gBtn = self:Create(window, 'ImageButton', {
			BackgroundTransparency = 1;
			Image = 'rbxthumb://type=Asset&id=4693044547&w=150&h=150';
			ImageTransparency = 0;
			Position = UDim2.new(0,5,0,5);
			Size = UDim2.new(0,10,0,10);
			ScaleType = Enum.ScaleType.Fit;
			Text = '';
			TextColor3 = Main.COLOR.TEXT
		})

		gBtn.MouseButton1Click:connect(function()
			if currentWindow == window then
				if not transition then
					if closed then
						transition = true
						closed = false
						for i=25,height,4 do
							Main.Services.RunService.Heartbeat:wait()
							window.Size = UDim2.new(0,200,0,i)
						end
						window.ClipsDescendants = false
						window.Size = UDim2.new(0,200,0,height)
						transition = false
					end
				end
			end
		end)

		------------------

		local oBtn = self:Create(window, 'ImageButton', {
			BackgroundTransparency = 1;
			Image = 'rbxthumb://type=Asset&id=4693046726&w=150&h=150';
			ImageTransparency = 0;
			Position = UDim2.new(0,17.8,0,5);
			Size = UDim2.new(0,10,0,10);
			ScaleType = Enum.ScaleType.Fit;
			Text = '';
			TextColor3 = Main.COLOR.TEXT
		})

		oBtn.MouseButton1Click:connect(function()
			if currentWindow == window then
				if not transition then
					if not closed then
						transition = true
						window.ClipsDescendants = true
						closed = true
						for i=height,25,-4 do
							Main.Services.RunService.Heartbeat:wait()
							window.Size = UDim2.new(0,200,0,i)
						end
						window.Size = UDim2.new(0,200,0,25)
						transition = false
					end
				end
			end
		end)

		------------------

		window.MouseMoved:connect(function()
			if not currentWindow and not selectionOpened then
				for a,b in next, window:children() do
					if b.ClassName ~= 'ScrollingFrame' then
						pcall(function()b.ZIndex = 1;end)
						pcall(function()b.Frame.ZIndex = 1;end)
						pcall(function()b.TextLabel.ZIndex = 1;end)
						pcall(function()b.TextButton.ZIndex = 1;end)
					end
				end
				window.ZIndex = 1
				currentWindow = window
				windowFocused = true
			end
		end)

		------------------
		
		window.MouseLeave:connect(function()
			if currentWindow == window then
				windowFocused = false
			end
			if currentWindow == window and not windowMoving and not sliderMoving and not selectionOpened then
				for a,b in next, window:children() do
					if b.ClassName ~= 'ScrollingFrame' then
						pcall(function()b.ZIndex = 0;end)
						pcall(function()b.Frame.ZIndex = 0;end)
						pcall(function()b.TextLabel.ZIndex = 0;end)
						pcall(function()b.TextButton.ZIndex = 0;end)
					end
				end
				window.ZIndex = 0
				currentWindow = nil
				windowFocused = false
			end
		end)

		------------------

		window.InputBegan:connect(function(key)
			if window == currentWindow then
				if not sliderFocused then
					local mouse = Main.Services.Players.LocalPlayer:GetMouse()
					local mb1 = Enum.UserInputType.MouseButton1
					local m = {
						x = 0;
						y = 0;
					}
					if key.UserInputType == mb1 then
						windowMoving = true
						local as = window.AbsolutePosition
						local pos = Vector2.new(mouse.X-as.X,mouse.Y-as.Y)
						while Main.Services.RunService.Heartbeat:wait() and Main.Services.UserInputService:IsMouseButtonPressed(mb1) and currentWindow == window do
							local obj = {
								mouse.X-pos.X,
								window.Size.X.Offset*window.AnchorPoint.X,
								mouse.Y-pos.Y,
								window.Size.Y.Offset*window.AnchorPoint.Y
							}
							if m.X ~= mouse.X or m.Y ~= mouse.Y then
								window:TweenPosition(
									UDim2.new(
										0,
										obj[1]+obj[2],
										0,
										obj[3]+obj[4]
									),
									'Out', 'Quad', .2,
									true
								)
							end
							m.X = mouse.X
							m.Y = mouse.Y
						end
						windowMoving = false
					end
				end
			end
		end)

		------------------

		local windowModule = {}
		function windowModule:Label(text)
			if not text or typeof(text) ~= 'string' then
				return sendNotification('Invalid Text!', 'You must set the text as a string for this label!')
			end

			SlashMacLIB:Create(window, 'TextLabel', {
				BackgroundTransparency = 1;

				Position = UDim2.new(0,12,0,height-5);
				Size = UDim2.new(0,170,0,15);

				TextSize = 12;
				Font = Enum.Font.Gotham;

				TextXAlignment = Enum.TextXAlignment.Left;
				TextYAlignment = Enum.TextYAlignment.Center;

				Text = text or 'Untitled';
				TextColor3 = Main.COLOR.TEXT;
			})

			height = height + 15
			window.Size = UDim2.new(0,200,0,height)

			return windowModule
		end

		------------------

		function windowModule:Button(text, callback)
			if not text or typeof(text) ~= 'string' then
				return sendNotification('Invalid Text!', 'You must set the text as a string for this button!')
			end
			if not callback or typeof(callback) ~= 'function' then
				return sendNotification('Invalid Callback!', 'You must set the callback as a function for this button: ' .. text)
			end
			local btn = SlashMacLIB:Create(window, 'TextButton', {
				BackgroundColor3 = Main.COLOR.BUTTONBG;
				Position = UDim2.new(0,10,0,height-4);
				Size = UDim2.new(0, 180, 0, 20);
				Text = text or 'Untitled';
				TextColor3 = Main.COLOR.BUTTONTEXT;
				TextXAlignment = 2;
				TextYAlignment = 1;
			})
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 4)
            corner.Parent = btn
            local pad = Instance.new("UIPadding")
            pad.PaddingLeft = UDim.new(0, 8)
            pad.Parent = btn

            local stroke = Instance.new("UIStroke")
            stroke.Thickness = 1
            stroke.Color = Color3.fromRGB(80,80,80)
            stroke.Transparency = 0
            stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            stroke.Parent = btn

            btn.MouseEnter:Connect(function()
                btn:TweenSize(UDim2.new(0, 180, 0, 22), "Out", "Quad", 0.1, true)
                btn.BackgroundColor3 = Color3.fromRGB(80,80,80)
            end)

            btn.MouseLeave:Connect(function()
                btn:TweenSize(UDim2.new(0, 180, 0, 20), "Out", "Quad", 0.1, true)
                btn.BackgroundColor3 = Main.COLOR.BUTTONBG
            end)

            btn.MouseButton1Down:Connect(function()
                btn:TweenSize(UDim2.new(0, 175, 0, 18), "Out", "Quad", 0.05, true)
            end)

            btn.MouseButton1Up:Connect(function()
                btn:TweenSize(UDim2.new(0, 180, 0, 22), "Out", "Quad", 0.1, true)
            end)

			btn.MouseButton1Click:connect(function()
				if window == currentWindow then
					callback()
				end
			end)

			Size = UDim2.new(0,180,0,22)
            height += 24
			window.Size = UDim2.new(0,200,0,height)
			return windowModule
		end

		------------------

function windowModule:Toggle(text, callback)
    if not text or typeof(text) ~= 'string' then
        return sendNotification('Invalid Text!', 'Toggle text must be string')
    end
    if not callback or typeof(callback) ~= 'function' then
        return sendNotification('Invalid Callback!', 'Toggle callback must be function')
    end

    local state = false

    -- main button
    local btn = SlashMacLIB:Create(window, 'TextButton', {
        BackgroundColor3 = Color3.fromRGB(55,55,55), -- muted mac gray
        Position = UDim2.new(0,10,0,height-5),
        Size = UDim2.new(0, 180, 0, 20),
        Text = text,
        TextColor3 = Color3.fromRGB(220,220,220),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        AutoButtonColor = false,
    })

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,6)
    corner.Parent = btn

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0,8)
    pad.Parent = btn

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0,10,0,10)
    dot.Position = UDim2.new(1,-16,0.5,0)
    dot.AnchorPoint = Vector2.new(0.5,0.5)
    dot.BackgroundColor3 = Color3.fromRGB(120,120,120)
    dot.Parent = btn

    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1,0)
    dotCorner.Parent = dot

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Transparency = 0.4
    stroke.Color = Color3.fromRGB(90,90,90)
    stroke.Parent = dot

    local tweenService = game:GetService("TweenService")

    local function tween(obj, prop)
        tweenService:Create(obj, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), prop):Play()
    end

    btn.MouseButton1Click:Connect(function()
        if window ~= currentWindow then return end

        state = not state

        if state then
            -- ON (green muted mac style)
            tween(dot, {
                BackgroundColor3 = Color3.fromRGB(22, 170, 68)
            })
        else
            -- OFF
            tween(dot, {
                BackgroundColor3 = Color3.fromRGB(120,120,120)
            })
        end

        callback(state)
    end)

    height += 22
    window.Size = UDim2.new(0,200,0,height)

    return windowModule
end

		------------------

        function windowModule:Selection(title, options, callback)
			if not title or typeof(title) ~= 'string' then
				return sendNotification('Invalid Title!', 'You must set the title as a string for this selection!')
			end
			if not options or typeof(options) ~= 'table' then
				return sendNotification('Invalid Options!', 'You must set the options as a table for this selection: ' .. title)
			end
			
			if #options == 0 then
				table.insert(options, '')
			end
			
			local opts = {selected=tostring(options[1]), index=1}
			

			local labelWindow = SlashMacLIB:Create(window, "Frame", {
                BackgroundColor3 = Main.COLOR.SELECTEDBG;
                Position = UDim2.new(0,10,0,height-4);
                Size = UDim2.new(0,180,0,20);
            })

			local tweenService = game:GetService("TweenService")
			local function tween(obj, prop)
				tweenService:Create(obj, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), prop):Play()
			end
			-- hover ทั้งกล่อง
			labelWindow.MouseEnter:Connect(function()
				tween(labelWindow, {
					BackgroundColor3 = Color3.fromRGB(95,95,95)
				})
			end)
			labelWindow.MouseLeave:Connect(function()
				tween(labelWindow, {
					BackgroundColor3 = Main.COLOR.SELECTEDBG
				})
			end)
			
            -- rounded
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0,6)
            corner.Parent = labelWindow

            local label = SlashMacLIB:Create(labelWindow, "TextLabel", {
                BackgroundTransparency = 1;

                Size = UDim2.new(1, 0, 1, 0);
                Position = UDim2.new(0, 0, 0, 0);

                Text = tostring(options[1]);
                TextColor3 = Main.COLOR.SELECTEDTEXT;

                TextXAlignment = Enum.TextXAlignment.Center;
                TextYAlignment = Enum.TextYAlignment.Center;

                Font = Enum.Font.Gotham;
                TextSize = 12;
            })

            -- padding feel
            local pad = Instance.new("UIPadding")
            pad.PaddingLeft = UDim.new(0, 6)
            pad.Parent = label


			local selectionHeight = 0
			local _transition = false
			local closed = true

			local selectionWindow = SlashMacLIB:Create(window, 'ScrollingFrame', {
                BackgroundColor3 = Color3.fromRGB(60,60,60);

                Position = UDim2.new(0, 10, 0, height + 19),

                Size = UDim2.new(0, 180, 0, 0),

                Visible = false,
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollBarThickness = 4,
            })
            selectionWindow.ClipsDescendants = true
            selectionWindow.BorderSizePixel = 0
			selectionWindow.ZIndex = 100

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 6)
            corner.Parent = selectionWindow

            local stroke = Instance.new("UIStroke")
            stroke.Thickness = 1
            stroke.Transparency = 0
            stroke.Color = Color3.fromRGB(90,90,90)
            stroke.Parent = selectionWindow

			selectionWindow.ChildAdded:connect(function()
				selectionWindow.CanvasSize = UDim2.new(0,180,0,selectionHeight+20)
			end)

			local sBtn = SlashMacLIB:Create(labelWindow, 'TextButton', {
				BackgroundTransparency = 1;
				Size = UDim2.new(0,20,0,20);
				Position = UDim2.new(1,-20,0,0);
				Text = 'v';
				TextColor3 = Main.COLOR.BUTTONTEXT;
			})

			local lostFocusEvent = nil

			local closeFunc = function()
				if closed then
					selectionOpened = true
					sBtn.Text = '^'
					selectionWindow.Visible = true
                    bringToFront(selectionWindow)
                    selectionWindow:TweenSize(
                        UDim2.new(0,180,0,math.min(selectionHeight,140)),
                        "Out",
                        "Quad",
                        0.15,
                        true
                    )
					selectionWindow.Size = UDim2.new(0, 180, 0, selectionHeight >= 140 and 140 or selectionHeight)
					closed = false
				elseif not closed then
					selectionOpened = false
					sBtn.Text = 'v'
					if lostFocusEvent then
						lostFocusEvent:Disconnect()
						lostFocusEvent = nil
					end

					for i = selectionHeight >= 140 and 140 or selectionHeight,0, -5 do
						Main.Services.RunService.RenderStepped:wait()
						selectionWindow.Size = UDim2.new(0, 180, 0, i)
					end
					selectionWindow.Size = UDim2.new(0, 180, 0, 0)
					selectionWindow.Visible = false
					closed = true
				end
				return true
			end

			sBtn.MouseButton1Click:connect(function()
				if window == currentWindow and not _transition then
					_transition = true
					if closed then
						selectionOpened = true
						lostFocusEvent = selectionWindow.MouseLeave:connect(function()
							if not _transition then
								_transition = true
								closeFunc()
								selectionOpened = false
								_transition = false
								if not windowFocused then
									for a,b in next, window:children() do
										if b.ClassName ~= 'ScrollingFrame' then
											pcall(function()b.ZIndex = 0;end)
											pcall(function()b.Frame.ZIndex = 0;end)
											pcall(function()b.TextLabel.ZIndex = 0;end)
											pcall(function()b.TextButton.ZIndex = 0;end)
										end
									end
									window.ZIndex = 0
									currentWindow = nil
								end
							end
						end)
					else
						selectionOpened = false
					end
					
					closeFunc()
					_transition = false
				end
			end)

            for i, v in ipairs(options) do

                local btn = SlashMacLIB:Create(selectionWindow, "TextButton", {
                    BackgroundColor3 = Main.COLOR.BUTTONBG;
                    Position = UDim2.new(0, 0, 0, selectionHeight);
                    Size = UDim2.new(0, 160, 0, 22);
                    Text = tostring(v);
                    TextColor3 = Color3.fromRGB(235,235,235);
                    TextXAlignment = Enum.TextXAlignment.Left;
                    TextYAlignment = Enum.TextYAlignment.Center;
                    Font = Enum.Font.Gotham;
                    TextSize = 12;
                    AutoButtonColor = false;
                    ZIndex = 1000;

                })

                -- padding text
                local pad = Instance.new("UIPadding")
                pad.PaddingLeft = UDim.new(0, 8)
                pad.Parent = btn

                -- rounded corner
                local corner = Instance.new("UICorner")
                corner.CornerRadius = UDim.new(0, 6)
                corner.Parent = btn

                -- hover animation (smooth)
                local tweenService = game:GetService("TweenService")

                local function tween(obj, prop)
                    tweenService:Create(obj, TweenInfo.new(0.12), prop):Play()
                end

                btn.MouseEnter:Connect(function()
                    tween(btn, {BackgroundColor3 = Color3.fromRGB(80,80,80)})
                end)

                btn.MouseLeave:Connect(function()
                    tween(btn, {BackgroundColor3 = Main.COLOR.BUTTONBG})
                end)

                btn.MouseButton1Down:Connect(function()
                    tween(btn, {BackgroundColor3 = Color3.fromRGB(110,110,110)})
                end)

                btn.MouseButton1Up:Connect(function()
                    tween(btn, {BackgroundColor3 = Color3.fromRGB(80,80,80)})
                end)
                btn.MouseButton1Click:Connect(function()
                    opts.selected = v
                    opts.index = i

                    label.Text = tostring(v) -- 🔥 อันนี้คือหัวใจ (โชว์ค่าที่เลือก)

                    if callback then
                        callback(v, i)
                    end

                    closeFunc()
                end)
                selectionHeight += 22
            end
            

			height = height + 24
			window.Size = UDim2.new(0,200,0,height)

            function opts:Add(v)
                table.insert(options, v)

                local btn = SlashMacLIB:Create(selectionWindow, 'TextButton', {
                    BackgroundColor3 = Main.COLOR.BUTTONBG;
                    Position = UDim2.new(0,0,0,selectionHeight);
                    Size = UDim2.new(0, 160, 0, 20);
                    Text = tostring(v);
                    TextColor3 = Main.COLOR.TEXT;
                    TextYAlignment = 1;
                    TextXAlignment = 2;
                })

                btn.MouseButton1Click:connect(function()
                    label.Text = tostring(v)
                    opts.index = #options
                    opts.selected = tostring(v)

                    if callback then
                        callback(v, #options)
                    end

                    closeFunc()
                end)

                btn.ZIndex = 100
                selectionHeight = selectionHeight + 20
            end

            function opts:Clear()
                options = {}

                opts.selected = nil
                opts.index = 0

                selectionHeight = 0

                for _, v in next, selectionWindow:GetChildren() do
                    if v:IsA("TextButton") then
                        v:Destroy()
                    end
                end

                selectionWindow.CanvasSize = UDim2.new(0,180,0,0)

                label.Text = tostring(title or '')
                sBtn.Text = 'v'

                selectionWindow.Visible = false
                selectionWindow.Size = UDim2.new(0,180,0,0)

                closed = true
            end
			return opts
		end

		------------------

		function windowModule:Slider(title, minValue, maxValue, callback)
			if not title or typeof(title) ~= 'string' then
				return sendNotification('Invalid Title!', 'You must set a title as a string for this slider!')
			end
			if (callback and typeof(callback) ~= 'function') then
				return sendNotification('Invalid Callback!', 'You must set a callback as a function for this slider: ' .. title)
			end
			if not maxValue then maxValue = 100 end
			if not minValue then minValue = 0 end
			if maxValue and typeof(maxValue) ~= 'number' then maxValue = 100 end
			if maxValue < 0 then maxValue = 100 end
			if minValue and typeof(minValue) ~= 'number' then minValue = 0 end
			if minValue < 0 then minValue = 0 end
			minValue = math.floor(minValue)
			maxValue = math.floor(maxValue)
			local tbl = {value=minValue;}
			local frame = SlashMacLIB:Create(window, 'Frame', {
				BackgroundColor3 = Color3.fromRGB(65,65,65);
				Position = UDim2.new(0,10,0,height-4);
				Size = UDim2.new(0,180,0,20);
			})
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 6)
            corner.Parent = frame

            local stroke = Instance.new("UIStroke")
            stroke.Thickness = 1
            stroke.Transparency = 0
            stroke.Color = Color3.fromRGB(80,80,80)
            stroke.Parent = frame
            frame.MouseEnter:Connect(function()
                frame:TweenSize(UDim2.new(0,180,0,21), "Out", "Quad", 0.1, true)
            end)

            frame.MouseLeave:Connect(function()
                frame:TweenSize(UDim2.new(0,180,0,20), "Out", "Quad", 0.1, true)
            end)
			local cursor = SlashMacLIB:Create(frame, 'Frame', {
				BackgroundColor3 = Color3.fromRGB(180,180,180);
				Position = UDim2.new(0,0,0,5);
				Size = UDim2.new(0,12,0,12);
			})
            local cursorCorner = Instance.new("UICorner")
            cursorCorner.CornerRadius = UDim.new(1, 0)
            cursorCorner.Parent = cursor
			local cursorStroke = Instance.new("UIStroke")
            cursorStroke.Thickness = 0.5
            cursorStroke.Transparency = 0
            cursorStroke.Color = Color3.fromRGB(80,80,80)
            cursorStroke.Parent = cursor
            cursor.MouseEnter:Connect(function()
                cursor:TweenSize(UDim2.new(0,14,0,14), "Out", "Quad", 0.1, true)
            end)

            cursor.MouseLeave:Connect(function()
                cursor:TweenSize(UDim2.new(0,12,0,12), "Out", "Quad", 0.1, true)
            end)

			local numValue = SlashMacLIB:Create(frame, 'TextLabel', {
				BackgroundTransparency = 1;
				Position = UDim2.new(.5,0,0,5);
				Text = tostring(minValue);
				TextColor3 = Color3.fromRGB(255,255,255);
				TextYAlignment = 0;
			})
            numValue.TextSize = 11
            numValue.Font = Enum.Font.Gotham

			local aaa = SlashMacLIB:Create(window, 'TextLabel', {
				BackgroundTransparency = 1;
				Position = UDim2.new(0.005,10,0,height);
				Size = UDim2.new(0,180,0,20);
				Text = title;
				TextColor3 = Color3.fromRGB(255,255,255);
				TextXAlignment = 0;
				TextYAlignment = 0;
                Font = Enum.Font.Gotham;
                TextSize = 11;
			})

			frame.InputBegan:connect(function()
				if not windowMoving and not sliderMoving and currentWindow == window and not mouseDown then
					local mouse = Main.Services.Players.LocalPlayer:GetMouse()
					local mouseAxis = {['x']=0;['y']=0;}
					local AbsolutePos = Vector2.new(
						frame.AbsolutePosition.X,
						frame.AbsolutePosition.Y
					)
					if not sliderMoving then
						while Main.Services.RunService.Heartbeat:wait() and Main.Services.UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
							sliderMoving = true
							if mouseAxis.x ~= mouse.X then
								local pos = nil;
								if mouse.X >= (AbsolutePos.X + 170) then
									pos=UDim2.new(0,170,0,5)
								elseif mouse.X <= AbsolutePos.X then
									pos=UDim2.new(0,0,0,5)
								else
									pos=UDim2.new(0,mouse.X-AbsolutePos.X,0,5)
								end
								cursor:TweenPosition(pos, 'Out', 'Quad', .2, true)
							end
							mouseAxis.x = mouse.X
						end
						sliderMoving = false
					end
				end
			end)

			------------------

			cursor:GetPropertyChangedSignal('Position'):connect(function()
				numValue.Text = tostring(
					math.clamp(
							math.floor(
							(
								(cursor.Position.X.Offset)
							/
								((frame.AbsoluteSize.X)-10)
							) * maxValue
						),
						minValue,
						maxValue
					)
				)
			end)

			numValue:GetPropertyChangedSignal('Text'):connect(function(property)
				tbl.value = tonumber(numValue.Text)
				if callback then
					callback(tonumber(numValue.Text))
				end
			end)

			frame.MouseEnter:connect(function()
				sliderFocused = true
			end)

			frame.MouseLeave:connect(function()
				sliderFocused = false
			end)

			height = height + 24
			window.Size = UDim2.new(0,200,0,height)

			return tbl
		end

		------------------

		function windowModule:Text(placeholderText)
			local tbl = {Text = ''}

			local bg = SlashMacLIB:Create(window, 'Frame', {
				BackgroundColor3 = Color3.fromRGB(240,240,245);
				Position = UDim2.new(0,10,0,height-5);
				Size = UDim2.new(0,180,0,20);
			})

			SlashMacLIB:Create(bg, 'UICorner', {
				CornerRadius = UDim.new(0,6)
			})

			local txtBox = SlashMacLIB:Create(bg, 'TextBox', {
				BackgroundTransparency = 1;
				ClearTextOnFocus = false;
				PlaceholderColor3 = Color3.fromRGB(150,150,150);
				PlaceholderText = placeholderText or "Text...";

				Size = UDim2.new(1,-8,1,0);
				Position = UDim2.new(0,8,0,0);

				Text = '';
				TextColor3 = Color3.fromRGB(35,35,35);
				TextSize = 12; -- 🔽 จาก 14 → 12
				Font = Enum.Font.Gotham;

				TextXAlignment = Enum.TextXAlignment.Left;
			})


			txtBox.Focused:Connect(function()
				bg.BackgroundColor3 = Color3.fromRGB(220,220,230)
			end)

			txtBox.FocusLost:Connect(function()
				bg.BackgroundColor3 = Color3.fromRGB(240,240,245)
			end)

			txtBox:GetPropertyChangedSignal("Text"):Connect(function()
				tbl.Text = txtBox.Text
			end)

			height = height + 24 -- 🔽 spacing กระชับขึ้น
			window.Size = UDim2.new(0,200,0,height)

			return tbl
		end

		------------------

		function windowModule:KeyBind(title, key, callback)
			if not title or typeof(title) ~= 'string' then
				return sendNotification('Invalid Title!', 'You must set the title as a string for this keybind!')
			end

			if not pcall(function() return Enum.KeyCode[key] end) then
				return sendNotification('Invalid KeyCode!', 'You cannot set `'..tostring(key)..'` as a keybind!')
			end

			local keyCode = nil
			for a,b in next, Enum.KeyCode:GetEnumItems() do
				if tostring(b) == string.format('Enum.KeyCode.%s', key) then
					keyCode = b
					break
				end
			end

			if not callback or typeof(callback) ~= 'function' then
				return sendNotification('Invalid Callback!', 'You must set the callback function for this keybind: ' .. key)
			end

			table.insert(getgenv().LBConnections,
				Main.Services.UserInputService.InputBegan:connect(function(key)
					if key.KeyCode == keyCode then
						callback()
					end
				end)
			)

			SlashMacLIB:Create(window, 'TextLabel', {
				BackgroundTransparency = 1,
				Position = UDim2.new(0,10,0,height-10);
				Size = UDim2.new(0,180,0,20),
				TextSize = 10;
				TextXAlignment = 0;
				TextYAlignment = 0;
				Text = string.format('%s', title);
				TextColor3 = Main.COLOR.TEXT;
			})

			SlashMacLIB:Create(window, 'TextLabel', {
				BackgroundTransparency = 1,
				Position = UDim2.new(0,10,0,height-10);
				Size = UDim2.new(0,180,0,20),
				TextSize = 10;
				TextXAlignment = 1;
				TextYAlignment = 0;
				Text = string.format('[%s]', key);
				TextColor3 = Main.COLOR.TEXT;
			})

			height = height + 20
			window.Size = UDim2.new(0,200,0,height)

			return window
		end

		------------------

		function windowModule:GUIDestroy()
			for a,b in next, getgenv().LBConnections do
				b:Disconnect()
			end
			script:Destroy()
			Main.GUI:Destroy()
		end

		return windowModule
	end
end
return SlashMacLIB
