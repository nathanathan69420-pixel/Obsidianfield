--[[==================== LIBRARY CORE ====================]]--
local Library = {}
Library.Theme = {
    Background = Color3.fromRGB(255,140,0),
    Accent = Color3.fromRGB(255,180,60),
    Text = Color3.fromRGB(255,255,255),
    Dark = Color3.fromRGB(200,110,0)
}

local PlayerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")

--[[==================== WINDOW ====================]]--
function Library:Window(title)
    local ScreenGui = Instance.new("ScreenGui", PlayerGui)
    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.new(0,480,0,300)
    Main.Position = UDim2.new(0.5,-240,0.5,-150)
    Main.BackgroundColor3 = self.Theme.Background
    Main.BorderSizePixel = 0

    local Tabs = Instance.new("Frame", Main)
    Tabs.Size = UDim2.new(0,120,1,0)
    Tabs.BackgroundColor3 = self.Theme.Dark
    Tabs.BorderSizePixel = 0

    local TabList = Instance.new("UIListLayout", Tabs)
    TabList.Padding = UDim.new(0,6)

    local Body = Instance.new("Frame", Main)
    Body.Size = UDim2.new(1,-120,1,0)
    Body.Position = UDim2.new(0,120,0,0)
    Body.BackgroundTransparency = 1

    local Window = {}

    --[[==================== ADD TAB ====================]]--
    function Window:Tab(tabName)
        local TabButton = Instance.new("TextButton", Tabs)
        TabButton.Size = UDim2.new(1,0,0,36)
        TabButton.BackgroundColor3 = Library.Theme.Accent
        TabButton.Text = tabName
        TabButton.TextColor3 = Library.Theme.Text
        TabButton.TextScaled = true
        TabButton.BorderSizePixel = 0

        local Page = Instance.new("ScrollingFrame", Body)
        Page.Size = UDim2.new(1,0,1,0)
        Page.CanvasSize = UDim2.new(0,0,0,0)
        Page.ScrollBarThickness = 4
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Page.Visible = false

        local PageList = Instance.new("UIListLayout", Page)
        PageList.Padding = UDim.new(0,8)

        TabButton.MouseButton1Click:Connect(function()
            for _,child in ipairs(Body:GetChildren()) do
                if child:IsA("ScrollingFrame") then child.Visible = false end
            end
            Page.Visible = true
        end)

        local TabObj = {}

        --[[==================== SECTION ====================]]--
        function TabObj:Section(name)
            local S = Instance.new("Frame", Page)
            S.Size = UDim2.new(1,-10,0,30)
            S.BackgroundColor3 = Library.Theme.Dark

            local T = Instance.new("TextLabel", S)
            T.Size = UDim2.new(1,0,1,0)
            T.BackgroundTransparency = 1
            T.Text = name
            T.TextColor3 = Library.Theme.Text
            T.TextScaled = true

            local E = Instance.new("Frame", Page)
            E.BackgroundTransparency = 1

            local L = Instance.new("UIListLayout", E)
            L.Padding = UDim.new(0,6)

            local Sec = {}

            --[[==================== BUTTON ====================]]--
            function Sec:Button(txt,callback)
                local B = Instance.new("TextButton", E)
                B.Size = UDim2.new(1,-10,0,32)
                B.BackgroundColor3 = Library.Theme.Accent
                B.Text = txt
                B.TextColor3 = Library.Theme.Text
                B.TextScaled = true
                B.BorderSizePixel = 0
                B.MouseButton1Click:Connect(callback)
            end

            --[[==================== TOGGLE ====================]]--
            function Sec:Toggle(txt,default,callback)
                local T = Instance.new("TextButton", E)
                T.Size = UDim2.new(1,-10,0,32)
                T.BackgroundColor3 = Library.Theme.Accent
                T.TextColor3 = Library.Theme.Text
                T.TextScaled = true
                T.BorderSizePixel = 0
                local state = default
                T.Text = txt .. ": " .. tostring(state)
                T.MouseButton1Click:Connect(function()
                    state = not state
                    T.Text = txt .. ": " .. tostring(state)
                    callback(state)
                end)
            end

            --[[==================== SLIDER ====================]]--
            function Sec:Slider(txt,min,max,default,callback)
                local F = Instance.new("Frame", E)
                F.Size = UDim2.new(1,-10,0,38)
                F.BackgroundColor3 = Library.Theme.Accent

                local Lb = Instance.new("TextLabel", F)
                Lb.Size = UDim2.new(1,0,0,18)
                Lb.BackgroundTransparency = 1
                Lb.Text = txt .. ": " .. tostring(default)
                Lb.TextColor3 = Library.Theme.Text
                Lb.TextScaled = true

                local Bar = Instance.new("Frame", F)
                Bar.Size = UDim2.new(1,-10,0,10)
                Bar.Position = UDim2.new(0.5,-(Bar.Size.X.Offset/2),0,20)
                Bar.BackgroundColor3 = Library.Theme.Dark

                local Fill = Instance.new("Frame", Bar)
                Fill.Size = UDim2.new((default-min)/(max-min),0,1,0)
                Fill.BackgroundColor3 = Library.Theme.Text

                local UIS = game:GetService("UserInputService")
                local val = default

                Bar.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then
                        local c; c = UIS.InputChanged:Connect(function(m)
                            if m.UserInputType == Enum.UserInputType.MouseMovement then
                                local pos = math.clamp((m.Position.X - Bar.AbsolutePosition.X)/Bar.AbsoluteSize.X,0,1)
                                Fill.Size = UDim2.new(pos,0,1,0)
                                val = math.floor(min + (max-min)*pos)
                                Lb.Text = txt .. ": " .. tostring(val)
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
            function Sec:Dropdown(txt,list,callback)
                local D = Instance.new("TextButton", E)
                D.Size = UDim2.new(1,-10,0,32)
                D.BackgroundColor3 = Library.Theme.Accent
                D.TextColor3 = Library.Theme.Text
                D.TextScaled = true
                D.Text = txt
                D.BorderSizePixel = 0

                local Opened = false
                D.MouseButton1Click:Connect(function()
                    if Opened then
                        for _,child in ipairs(E:GetChildren()) do
                            if child.Name == txt .. "_option" then child:Destroy() end
                        end
                        Opened = false
                    else
                        for _,v in ipairs(list) do
                            local O = Instance.new("TextButton", E)
                            O.Name = txt .. "_option"
                            O.Size = UDim2.new(1,-10,0,32)
                            O.BackgroundColor3 = Library.Theme.Dark
                            O.TextColor3 = Library.Theme.Text
                            O.TextScaled = true
                            O.Text = v
                            O.BorderSizePixel = 0
                            O.MouseButton1Click:Connect(function()
                                D.Text = txt .. ": " .. v
                                callback(v)
                            end)
                        end
                        Opened = true
                    end
                end)
            end

            --[[==================== KEYBIND ====================]]--
            function Sec:Keybind(txt,default,callback)
                local K = Instance.new("TextButton", E)
                K.Size = UDim2.new(1,-10,0,32)
                K.BackgroundColor3 = Library.Theme.Accent
                K.TextColor3 = Library.Theme.Text
                K.TextScaled = true
                K.Text = txt .. ": " .. default.Name

                local waiting = false
                K.MouseButton1Click:Connect(function()
                    K.Text = txt .. ": ..."
                    waiting = true
                end)

                game:GetService("UserInputService").InputBegan:Connect(function(i)
                    if waiting and i.KeyCode ~= Enum.KeyCode.Unknown then
                        waiting = false
                        K.Text = txt .. ": " .. i.KeyCode.Name
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

--[[==================== NOTIFICATIONS ====================]]--
function Library:Notify(msg,time)
    local Gui = Instance.new("ScreenGui", PlayerGui)
    local Frame = Instance.new("Frame", Gui)
    Frame.Size = UDim2.new(0,260,0,50)
    Frame.Position = UDim2.new(0.5,-130,0.05,0)
    Frame.BackgroundColor3 = Library.Theme.Accent
    Frame.BorderSizePixel = 0

    local T = Instance.new("TextLabel", Frame)
    T.Size = UDim2.new(1,0,1,0)
    T.BackgroundTransparency = 1
    T.TextColor3 = Library.Theme.Text
    T.TextScaled = true
    T.Text = msg

    task.delay(time or 2,function() Gui:Destroy() end)
end

return Library
