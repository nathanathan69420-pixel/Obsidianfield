--[[==================== LIBRARY CORE ====================]]--
local Library = {}
local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local RunService = game:GetService("RunService")

local GradientColors = {
    Color3.fromRGB(255,140,0),
    Color3.fromRGB(255,60,60),
    Color3.fromRGB(255,200,0),
    Color3.fromRGB(255,100,20)
}

local function Lerp(a,b,t)
    return a + (b-a)*t
end

local function ColorLerp(c1,c2,t)
    return Color3.new(
        Lerp(c1.R,c2.R,t),
        Lerp(c1.G,c2.G,t),
        Lerp(c1.B,c2.B,t)
    )
end

local gradientIndex = 1
local gradientNext = 2
local gradientT = 0

RunService.Heartbeat:Connect(function(dt)
    gradientT = gradientT + dt * 0.15
    if gradientT >= 1 then
        gradientT = 0
        gradientIndex = gradientNext
        gradientNext = gradientNext + 1
        if gradientNext > #GradientColors then gradientNext = 1 end
    end
end)

local function GetCurrentColor()
    local c1 = GradientColors[gradientIndex]
    local c2 = GradientColors[gradientNext]
    return ColorLerp(c1,c2,gradientT)
end

--[[==================== DRAGGING ====================]]--
local function MakeDraggable(frame,dragger)
    local UIS = game:GetService("UserInputService")
    local dragging = false
    local dragStart
    local startPos

    dragger.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
end

--[[==================== WINDOW ====================]]--
function Library:Window(title)
    local Gui = Instance.new("ScreenGui", PlayerGui)
    local Main = Instance.new("Frame", Gui)
    Main.Size = UDim2.new(0,500,0,320)
    Main.Position = UDim2.new(0.5,-250,0.5,-160)
    Main.BackgroundColor3 = GetCurrentColor()
    Main.BorderSizePixel = 0

    local Top = Instance.new("Frame", Main)
    Top.Size = UDim2.new(1,0,0,40)
    Top.BackgroundTransparency = 1

    MakeDraggable(Main,Top)

    local Title = Instance.new("TextLabel", Top)
    Title.Size = UDim2.new(1,0,1,0)
    Title.BackgroundTransparency = 1
    Title.Text = title
    Title.TextColor3 = Color3.fromRGB(255,255,255)
    Title.TextScaled = true

    local Tabs = Instance.new("Frame", Main)
    Tabs.Size = UDim2.new(0,130,1,-40)
    Tabs.Position = UDim2.new(0,0,0,40)
    Tabs.BackgroundTransparency = 1

    local TabList = Instance.new("UIListLayout", Tabs)
    TabList.Padding = UDim.new(0,6)

    local Body = Instance.new("Frame", Main)
    Body.Size = UDim2.new(1,-130,1,-40)
    Body.Position = UDim2.new(0,130,0,40)
    Body.BackgroundTransparency = 1

    RunService.Heartbeat:Connect(function()
        Main.BackgroundColor3 = GetCurrentColor()
    end)

    local Window = {}

    --[[==================== TAB ====================]]--
    function Window:Tab(name)
        local B = Instance.new("TextButton", Tabs)
        B.Size = UDim2.new(1,0,0,34)
        B.BackgroundColor3 = GetCurrentColor()
        B.Text = name
        B.TextColor3 = Color3.fromRGB(255,255,255)
        B.TextScaled = true
        B.BorderSizePixel = 0

        local Page = Instance.new("ScrollingFrame", Body)
        Page.Size = UDim2.new(1,0,1,0)
        Page.CanvasSize = UDim2.new(0,0,0,0)
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Page.ScrollBarThickness = 4
        Page.Visible = false

        local PL = Instance.new("UIListLayout", Page)
        PL.Padding = UDim.new(0,8)

        B.MouseButton1Click:Connect(function()
            for _,v in ipairs(Body:GetChildren()) do
                if v:IsA("ScrollingFrame") then v.Visible = false end
            end
            Page.Visible = true
        end)

        local TabObj = {}

        --[[==================== SECTION ====================]]--
        function TabObj:Section(name)
            local S = Instance.new("TextLabel", Page)
            S.Size = UDim2.new(1,-10,0,26)
            S.BackgroundColor3 = GetCurrentColor()
            S.TextColor3 = Color3.fromRGB(255,255,255)
            S.TextScaled = true
            S.BorderSizePixel = 0
            S.Text = name

            local E = Instance.new("Frame", Page)
            E.BackgroundTransparency = 1

            local L = Instance.new("UIListLayout", E)
            L.Padding = UDim.new(0,6)

            local Sec = {}

            --[[==================== BUTTON ====================]]--
            function Sec:Button(text,callback)
                local Bn = Instance.new("TextButton", E)
                Bn.Size = UDim2.new(1,-10,0,32)
                Bn.BackgroundColor3 = GetCurrentColor()
                Bn.Text = text
                Bn.TextColor3 = Color3.fromRGB(255,255,255)
                Bn.TextScaled = true
                Bn.BorderSizePixel = 0
                Bn.MouseButton1Click:Connect(callback)
            end

            --[[==================== TOGGLE ====================]]--
            function Sec:Toggle(text,default,callback)
                local T = Instance.new("TextButton", E)
                T.Size = UDim2.new(1,-10,0,32)
                T.BackgroundColor3 = GetCurrentColor()
                T.TextColor3 = Color3.fromRGB(255,255,255)
                T.TextScaled = true
                local val = default
                T.Text = text .. ": " .. tostring(val)
                T.MouseButton1Click:Connect(function()
                    val = not val
                    T.Text = text .. ": " .. tostring(val)
                    callback(val)
                end)
            end

            --[[==================== SLIDER ====================]]--
            function Sec:Slider(text,min,max,default,callback)
                local F = Instance.new("Frame", E)
                F.Size = UDim2.new(1,-10,0,42)
                F.BackgroundColor3 = GetCurrentColor()

                local Lb = Instance.new("TextLabel", F)
                Lb.Size = UDim2.new(1,0,0,18)
                Lb.BackgroundTransparency = 1
                Lb.Text = text .. ": " .. default
                Lb.TextColor3 = Color3.new(1,1,1)
                Lb.TextScaled = true

                local Bar = Instance.new("Frame", F)
                Bar.Size = UDim2.new(1,-10,0,10)
                Bar.Position = UDim2.new(0,5,0,22)
                Bar.BackgroundColor3 = Color3.fromRGB(20,20,20)

                local Fill = Instance.new("Frame", Bar)
                Fill.Size = UDim2.new((default-min)/(max-min),0,1,0)
                Fill.BackgroundColor3 = Color3.fromRGB(255,255,255)

                local UIS = game:GetService("UserInputService")
                local val = default

                Bar.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then
                        local c; c = UIS.InputChanged:Connect(function(m)
                            if m.UserInputType == Enum.UserInputType.MouseMovement then
                                local pos = math.clamp((m.Position.X - Bar.AbsolutePosition.X)/Bar.AbsoluteSize.X,0,1)
                                Fill.Size = UDim2.new(pos,0,1,0)
                                val = math.floor(min + (max-min)*pos)
                                Lb.Text = text .. ": " .. val
                                callback(val)
                            end
                        end)
                        i.Changed:Connect(function()
                            if i.UserInputState == Enum.UserInputState.End then c:Disconnect() end
                        end)
                    end
                end)
            end

            --[[==================== DROPDOWN ====================]]--
            function Sec:Dropdown(text,list,callback)
                local D = Instance.new("TextButton", E)
                D.Size = UDim2.new(1,-10,0,32)
                D.BackgroundColor3 = GetCurrentColor()
                D.TextColor3 = Color3.fromRGB(255,255,255)
                D.TextScaled = true
                D.Text = text
                local open = false

                D.MouseButton1Click:Connect(function()
                    if open then
                        for _,v in ipairs(E:GetChildren()) do
                            if v.Name == text.."_opt" then v:Destroy() end
                        end
                        open = false
                    else
                        for _,item in ipairs(list) do
                            local O = Instance.new("TextButton", E)
                            O.Name = text.."_opt"
                            O.Size = UDim2.new(1,-10,0,32)
                            O.BackgroundColor3 = Color3.fromRGB(40,40,40)
                            O.TextColor3 = Color3.fromRGB(255,255,255)
                            O.TextScaled = true
                            O.Text = item
                            O.MouseButton1Click:Connect(function()
                                D.Text = text..": "..item
                                callback(item)
                            end)
                        end
                        open = true
                    end
                end)
            end

            --[[==================== KEYBIND ====================]]--
            function Sec:Keybind(text,key,callback)
                local K = Instance.new("TextButton", E)
                K.Size = UDim2.new(1,-10,0,32)
                K.BackgroundColor3 = GetCurrentColor()
                K.TextColor3 = Color3.fromRGB(255,255,255)
                K.TextScaled = true
                K.Text = text .. ": " .. key.Name

                local waiting = false
                K.MouseButton1Click:Connect(function()
                    K.Text = text .. ": ..."
                    waiting = true
                end)

                game:GetService("UserInputService").InputBegan:Connect(function(i)
                    if waiting and i.KeyCode ~= Enum.KeyCode.Unknown then
                        waiting = false
                        K.Text = text .. ": " .. i.KeyCode.Name
                        callback(i.KeyCode)
                    end
                end)
            end

            return Sec
        end

        return TabObj
    end

    return Window
end

--[[==================== NOTIFY ====================]]--
function Library:Notify(text,time)
    local G = Instance.new("ScreenGui", PlayerGui)
    local F = Instance.new("Frame", G)
    F.Size = UDim2.new(0,280,0,50)
    F.Position = UDim2.new(0.5,-140,0.1,0)
    F.BackgroundColor3 = GetCurrentColor()
    F.BorderSizePixel = 0

    local T = Instance.new("TextLabel", F)
    T.Size = UDim2.new(1,0,1,0)
    T.BackgroundTransparency = 1
    T.TextColor3 = Color3.new(1,1,1)
    T.TextScaled = true
    T.Text = text

    task.delay(time or 2,function()
        G:Destroy()
    end)
end

return Library            
