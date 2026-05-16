local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local CSRoot = game:GetService("ReplicatedStorage").Products.CharacterSelection.Characters
local marshmallowData = {
    ["Marshmallow"] = "http://www.roblox.com/asset/?id=4921967564",
    ["Mr.Coconut Marshmallow"] = "http://www.roblox.com/asset/?id=4993225404",
    ["Cook Surprise Marshmallow"] = "http://www.roblox.com/asset/?id=4993211976",
    ["Soda Marshmallow"] = "http://www.roblox.com/asset/?id=13424792834",
    ["Dino Marshmallow"] = "http://www.roblox.com/asset/?id=13424788699",
    ["Official 3-4 Marshmallow"] = "http://www.roblox.com/asset/?id=9005433388",
    ["Furious Trout Marshmallow"] = "http://www.roblox.com/asset/?id=13557360275",
    ["Orange Marshmallow"] = "http://www.roblox.com/asset/?id=4993231360",
    ["Cabbage Marshmallow"] = "http://www.roblox.com/asset/?id=13424785412",
    ["Toxic Marshmallow"] = "http://www.roblox.com/asset/?id=4939073413",
    ["Grip Marshmallow"] = "http://www.roblox.com/asset/?id=14253207872",
    ["Vote Me Marshmallow"] = "http://www.roblox.com/asset/?id=13424797492",
    ["Honey Dipped Marshmallow"] = "http://www.roblox.com/asset/?id=13424799638",
    ["Banana Marshmallow"] = "http://www.roblox.com/asset/?id=4922748526",
    ["Cursed Idol Marshmallow"] = "http://www.roblox.com/asset/?id=4993221853",
    ["Choc Dipped Marshmallow"] = "http://www.roblox.com/asset/?id=10420319581",
    ["Candyfloss Marshmallow"] = "http://www.roblox.com/asset/?id=4939071806",
    ["Guilty Gift Marshmallow"] = "http://www.roblox.com/asset/?id=13424790186",
    ["Coconut Marshmallow"] = "http://www.roblox.com/asset/?id=4922749819",
    ["Official Marshmallow"] = "http://www.roblox.com/asset/?id=6190482040",
    ["Chocolate Marshmallow"] = "http://www.roblox.com/asset/?id=8989965765",
    ["Toasted Marshmallow"] = "http://www.roblox.com/asset/?id=11109548044",
    ["Surfboard Marshmallow"] = "http://www.roblox.com/asset/?id=14253216830",
    ["Official 2 Marshmallow"] = "http://www.roblox.com/asset/?id=6918605850",
    ["Stink Bomb Marshmallow"] = "http://www.roblox.com/asset/?id=14253212538",
    ["Deathly Frog Marshmallow"] = "http://www.roblox.com/asset/?id=13557357445",
    ["Heart Marshmallow"] = "http://www.roblox.com/asset/?id=11109545563",
    ["Burnt Marshmallow"] = "http://www.roblox.com/asset/?id=4939257688",
    ["Spooky Skull Marshmallow"] = "http://www.roblox.com/asset/?id=13424794215",
    ["Camo Marshmallow"] = "http://www.roblox.com/asset/?id=4993218908",
    ["Star Barrel Marshmallow"] = "http://www.roblox.com/asset/?id=13557362587",
    ["Candycane Marshmallow"] = "http://www.roblox.com/asset/?id=8087099712",
    ["Claus Marshmallow"] = "http://www.roblox.com/asset/?id=8087103731",
    ["Gingerbread Marshmallow"] = "http://www.roblox.com/asset/?id=8087104305",
    ["Snowflake Marshmallow"] = "http://www.roblox.com/asset/?id=8087108522",
    ["Snowman Marshmallow"] = "http://www.roblox.com/asset/?id=8087109234",
    ["Xmas Tree Marshmallow"] = "http://www.roblox.com/asset/?id=8087102391",
    ["Official 5 Marshmallow"] = "http://www.roblox.com/asset/?id=12089683577",
    ["Refresher Marshmallow"] = "http://www.roblox.com/asset/?id=10420322407",
    ["Friendly Fish Marshmallow"] = "http://www.roblox.com/asset/?id=6213300124",
    ["Popcorn Marshmallow"] = "http://www.roblox.com/asset/?id=14253210682",
    ["Salt&Pepper Marshmallow"] = "http://www.roblox.com/asset/?id=4939073043",
    ["Grape Marshmallow"] = "http://www.roblox.com/asset/?id=4939072171",
    ["Mutant Marshmallow"] = "http://www.roblox.com/asset/?id=4993228141",
    ["Blue Sky Marshmallow"] = "http://www.roblox.com/asset/?id=6213301823",
    ["Rainbow Marshmallow"] = "http://www.roblox.com/asset/?id=11109546611",
    ["Animatronic Marshmallow"] = "http://www.roblox.com/asset/?id=14253197608",
    ["Fly Trap Marshmallow"] = "http://www.roblox.com/asset/?id=13557358447",
    ["Lightning Marshmallow"] = "http://www.roblox.com/asset/?id=6213299603",
    ["Official 6 Marshmallow"] = "http://www.roblox.com/asset/?id=13883154348",
    ["Cave Marshmallow"] = "http://www.roblox.com/asset/?id=14253202968",
    ["Briefcase Marshmallow"] = "http://www.roblox.com/asset/?id=14253200770",
    ["Alien Slime Marshmallow"] = "http://www.roblox.com/asset/?id=14253195386",
    ["Strawberry Marshmallow"] = "http://www.roblox.com/asset/?id=8989965284",
    ["Gaffer Marshmallow"] = "http://www.roblox.com/asset/?id=14253205269",
    ["Bane Marshmallow"] = "http://www.roblox.com/asset/?id=4939072726",
    ["All Star Marshmallow"] = "http://www.roblox.com/asset/?id=4993216167",
    ["Voting Machine Marshmallow"] = "http://www.roblox.com/asset/?id=14253219599",
    ["Mint Choc Chip Marshmallow"] = "http://www.roblox.com/asset/?id=10420505533",
    ["Dropped Marshmallow"] = "http://www.roblox.com/asset/?id=6213298209",
    ["Spiderweb Marshmallow"] = "http://www.roblox.com/asset/?id=14891850347",
    ["Mummy Marshmallow"] = "http://www.roblox.com/asset/?id=14891849082",
    ["Jack-o-lantern Marshmallow"] = "http://www.roblox.com/asset/?id=14891848232",
    ["Cauldron Marshmallow"] = "http://www.roblox.com/asset/?id=14891845147",
    ["Ghost Marshmallow"] = "http://www.roblox.com/asset/?id=14891847267",
    ["Candy Corn Marshmallow"] = "http://www.roblox.com/asset/?id=14891843386",
    ["Black Cat Marshmallow"] = "http://www.roblox.com/asset/?id=14891842127",
    ["Frankenstein Marshmallow"] = "http://www.roblox.com/asset/?id=14891846020",
    ["Candy Cane Marshmallow"] = "http://www.roblox.com/asset/?id=15484725814",
    ["Christmas Gift Marshmallow"] = "http://www.roblox.com/asset/?id=15484726913",
    ["Christmas Tree Marshmallow"] = "http://www.roblox.com/asset/?id=15484727551",
    ["Festive Lights Marshmallow"] = "http://www.roblox.com/asset/?id=15484728253",
    ["Frosted Marshmallow"] = "http://www.roblox.com/asset/?id=15484728905",
    ["Hot Chocolate Marshmallow"] = "http://www.roblox.com/asset/?id=15484729538",
    ["Jingle Bell Marshmallow"] = "http://www.roblox.com/asset/?id=15484730291",
    ["Mr Snow Marshmallow"] = "http://www.roblox.com/asset/?id=15484731148",
    ["Reindeer Marshmallow"] = "http://www.roblox.com/asset/?id=15484731823",
    ["Santa Suit Marshmallow"] = "http://www.roblox.com/asset/?id=15484732509",
    ["Snowglobe Marshmallow"] = "http://www.roblox.com/asset/?id=15484733560",
    ["The Grunch Marshmallow"] = "http://www.roblox.com/asset/?id=15484734379",
    ["Bacon Grease Marshmallow"] = "http://www.roblox.com/asset/?id=16029143731",
    ["Pink Paint Marshmallow"] = "http://www.roblox.com/asset/?id=16029151877",
    ["Skunk Tail Marshmallow"] = "http://www.roblox.com/asset/?id=16029163767",
    ["Rodent Face Marshmallow"] = "http://www.roblox.com/asset/?id=16029162747",
    ["Candy Marshmallow"] = "http://www.roblox.com/asset/?id=16029146948",
    ["Lychee Soda Marshmallow"] = "http://www.roblox.com/asset/?id=16029149121",
    ["Banana Soda Marshmallow"] = "http://www.roblox.com/asset/?id=16029144639",
    ["The Wolves Marshmallow"] = "http://www.roblox.com/asset/?id=16029164794",
    ["Young Chester Marshmallow"] = "http://www.roblox.com/asset/?id=16029185414",
    ["Owl Mascot Marshmallow"] = "http://www.roblox.com/asset/?id=16029150192",
    ["Racoon Marshmallow"] = "http://www.roblox.com/asset/?id=16029160256",
    ["Abstract Cake Marshmallow"] = "http://www.roblox.com/asset/?id=16029142769",
    ["Circus Snake Marshmallow"] = "http://www.roblox.com/asset/?id=16029148014",
    ["Bogey Marshmallow"] = "http://www.roblox.com/asset/?id=16029145643",
    ["Sap Removal Marshmallow"] = "http://www.roblox.com/asset/?id=16029165998",
    ["Carrot Marshmallow"] = "http://www.roblox.com/asset/?id=16735788642",
    ["Easter Basket Marshmallow"] = "http://www.roblox.com/asset/?id=16735790050",
    ["Easter Bunny Marshmallow"] = "http://www.roblox.com/asset/?id=16726342799",
    ["Easter Chick Marshmallow"] = "http://www.roblox.com/asset/?id=16735787584",
    ["Easter Egg Marshmallow"] = "http://www.roblox.com/asset/?id=16735791814",
    ["Lion Marshmallow"] = "http://www.roblox.com/asset/?id=16726346946",
    ["Official 7 Marshmallow"] = "http://www.roblox.com/asset/?id=16752097514",
}
local marshmallowList = {}
for name in pairs(marshmallowData) do
    table.insert(marshmallowList, name)
end
table.sort(marshmallowList)
local function applyMarshmallow(texture)
    local char = LocalPlayer.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end
    local gui = head:FindFirstChild("MarshmallowGUI")
    if not gui then return end
    local sector = gui:FindFirstChild("Sector")
    if not sector then return end
    local imageLabel = sector:FindFirstChildOfClass("ImageLabel")
    if imageLabel then
        imageLabel.Image = texture
    end
end
local skinList = {}
local skinMap = {}
local skinFaceMap = {}
local charSkinIndex = {}
for _, gender in ipairs(CSRoot:GetChildren()) do
    for _, character in ipairs(gender:GetChildren()) do
        local skins = character:FindFirstChild("Skins")
        if skins then
            local charKey = gender.Name .. " | " .. character.Name
            if not charSkinIndex[charKey] then charSkinIndex[charKey] = 0 end
            for _, skin in ipairs(skins:GetChildren()) do
                local label = charKey .. " | " .. skin.Name
                table.insert(skinList, label)
                skinMap[label] = skin
                charSkinIndex[charKey] += 1
                local faceDecal = skin:FindFirstChildOfClass("Decal")
                if faceDecal then
                    skinFaceMap[label] = faceDecal.Texture
                else
                    local charFaceDecal = character:FindFirstChildOfClass("Decal")
                    skinFaceMap[label] = charFaceDecal and charFaceDecal.Texture or ""
                end
            end
        end
    end
end
local function findAttachmentInChar(char, attName)
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("Attachment") and part.Name == attName then return part end
    end
end
local function applySkin(skinObj, faceTexture)
    local char = LocalPlayer.Character
    if not char then return end
    for _, v in ipairs(char:GetChildren()) do
        if v:IsA("Shirt") or v:IsA("Pants") or v:IsA("Accessory")
        or v:IsA("ShirtGraphic") or v:IsA("CharacterMesh") or v:IsA("Hat") then
            v:Destroy()
        end
    end
    local function doApplyFace()
        local head = char:FindFirstChild("Head")
        if not head or not faceTexture or faceTexture == "" then return end
        local fc = head:FindFirstChildOfClass("FaceControls")
        if fc then fc:Destroy() end
        local sa = head:FindFirstChildOfClass("SurfaceAppearance")
        if sa then sa.ColorMap = faceTexture end
        local decal = head:FindFirstChildOfClass("Decal")
        if not decal then
            decal = Instance.new("Decal")
            decal.Name = "face"
            decal.Face = Enum.NormalId.Front
            decal.Parent = head
        end
        decal.Texture = faceTexture
    end
    doApplyFace()
    task.delay(0.2, doApplyFace)
    task.delay(0.7, doApplyFace)
    local clothesFolder = skinObj:FindFirstChild("Clothes")
    if not clothesFolder then return end
    local shirt = clothesFolder:FindFirstChildOfClass("Shirt")
    if shirt then shirt:Clone().Parent = char end
    local pants = clothesFolder:FindFirstChildOfClass("Pants")
    if pants then pants:Clone().Parent = char end
    local bodyColors = clothesFolder:FindFirstChildOfClass("BodyColors")
    if bodyColors then
        local existing = char:FindFirstChildOfClass("BodyColors")
        if existing then existing:Destroy() end
        bodyColors:Clone().Parent = char
    end
    for _, v in ipairs(clothesFolder:GetChildren()) do
        if v:IsA("CharacterMesh") then v:Clone().Parent = char end
    end
    for _, v in ipairs(clothesFolder:GetChildren()) do
        if v:IsA("Accessory") then
            local clone = v:Clone()
            local handle = clone:FindFirstChild("Handle")
            if handle then
                handle.Massless = true
                local handleAtt = nil
                for _, child in ipairs(handle:GetDescendants()) do
                    if child:IsA("Attachment") then handleAtt = child break end
                end
                if handleAtt then
                    local charAtt = findAttachmentInChar(char, handleAtt.Name)
                    if charAtt then
                        local rigid = Instance.new("RigidConstraint")
                        rigid.Attachment0 = charAtt
                        rigid.Attachment1 = handleAtt
                        rigid.Parent = clone
                    end
                end
            end
            clone.Parent = char
        elseif v:IsA("Hat") then
            v:Clone().Parent = char
        end
    end
    -- Fix: disable collision on all character parts after skin apply
    local function disableCollision()
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
    disableCollision()
    task.delay(0.1, disableCollision)
    task.delay(0.5, disableCollision)
end
local UIS = game:GetService("UserInputService")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TRDSelector"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui
local EXPANDED_HEIGHT = 360
local COLLAPSED_HEIGHT = 34
local WINDOW_WIDTH = 260
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, WINDOW_WIDTH, 0, EXPANDED_HEIGHT)
Main.Position = UDim2.new(0.5, -WINDOW_WIDTH / 2, 0.5, -EXPANDED_HEIGHT / 2)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, COLLAPSED_HEIGHT)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 8)
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -70, 1, 0)
TitleLabel.Position = UDim2.new(0, 8, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Skin Changer"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 13
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar
local minimised = false
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 24, 0, 24)
MinBtn.Position = UDim2.new(1, -58, 0, 5)
MinBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize = 16
MinBtn.Font = Enum.Font.GothamBold
MinBtn.BorderSizePixel = 0
MinBtn.Parent = TitleBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -30, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 12
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
CloseBtn.MouseButton1Click:Connect(function() Main:Destroy() end)
local dragging, dragInput, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, 0, 1, -COLLAPSED_HEIGHT)
ContentFrame.Position = UDim2.new(0, 0, 0, COLLAPSED_HEIGHT)
ContentFrame.BackgroundTransparency = 1
ContentFrame.ClipsDescendants = false
ContentFrame.Visible = true
ContentFrame.Parent = Main
MinBtn.MouseButton1Click:Connect(function()
    minimised = not minimised
    ContentFrame.Visible = not minimised
    TweenService:Create(Main, TweenInfo.new(0.15), {
        Size = UDim2.new(0, WINDOW_WIDTH, 0, minimised and COLLAPSED_HEIGHT or EXPANDED_HEIGHT)
    }):Play()
    MinBtn.Text = minimised and "+" or "-"
end)
local TAB_BAR_Y = 0
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, 0, 0, 28)
TabBar.Position = UDim2.new(0, 0, 0, TAB_BAR_Y)
TabBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TabBar.BorderSizePixel = 0
TabBar.Parent = ContentFrame
local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Parent = TabBar
local CONTENT_Y = 28
local function makeTabContent()
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 1, -(CONTENT_Y + 30))
    Container.Position = UDim2.new(0, 0, 0, CONTENT_Y)
    Container.BackgroundTransparency = 1
    Container.Visible = false
    Container.Parent = ContentFrame
    local SearchBox = Instance.new("TextBox")
    SearchBox.Size = UDim2.new(1, -16, 0, 26)
    SearchBox.Position = UDim2.new(0, 8, 0, 4)
    SearchBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    SearchBox.BorderSizePixel = 0
    SearchBox.PlaceholderText = "Search..."
    SearchBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    SearchBox.Text = ""
    SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    SearchBox.TextSize = 12
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.Parent = Container
    Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 6)
    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Size = UDim2.new(1, -16, 1, -36)
    ScrollFrame.Position = UDim2.new(0, 8, 0, 34)
    ScrollFrame.BackgroundTransparency = 1
    ScrollFrame.BorderSizePixel = 0
    ScrollFrame.ScrollBarThickness = 3
    ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    ScrollFrame.Parent = Container
    local ListLayout = Instance.new("UIListLayout")
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Padding = UDim.new(0, 3)
    ListLayout.Parent = ScrollFrame
    ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 4)
    end)
    return Container, SearchBox, ScrollFrame
end
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -16, 0, 24)
StatusLabel.Position = UDim2.new(0, 8, 1, -28)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = ""
StatusLabel.TextColor3 = Color3.fromRGB(120, 255, 120)
StatusLabel.TextSize = 11
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextXAlignment = Enum.TextXAlignment.Center
StatusLabel.Parent = ContentFrame
local function makeButton(parent, label, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 28)
    Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Btn.BorderSizePixel = 0
    Btn.Text = label
    Btn.TextColor3 = Color3.fromRGB(220, 220, 220)
    Btn.TextSize = 11
    Btn.Font = Enum.Font.Gotham
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Btn.TextTruncate = Enum.TextTruncate.AtEnd
    Btn.Parent = parent
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    local P = Instance.new("UIPadding", Btn)
    P.PaddingLeft = UDim.new(0, 7)
    Btn.MouseButton1Click:Connect(function()
        callback()
        TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(60,60,60)}):Play()
        task.delay(0.2, function()
            TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(35,35,35)}):Play()
        end)
    end)
    return Btn
end
local tabs = {}
local activeTab = nil
local function makeTab(name, order)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0, WINDOW_WIDTH / 2, 1, 0)
    TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TabBtn.BorderSizePixel = 0
    TabBtn.Text = name
    TabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    TabBtn.TextSize = 11
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.LayoutOrder = order
    TabBtn.Parent = TabBar
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 0)
    local Container, SearchBox, ScrollFrame = makeTabContent()
    local tabData = {
        btn = TabBtn,
        container = Container,
        search = SearchBox,
        scroll = ScrollFrame,
        buttons = {}
    }
    table.insert(tabs, tabData)
    TabBtn.MouseButton1Click:Connect(function()
        for _, t in ipairs(tabs) do
            t.container.Visible = false
            t.btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            t.btn.TextColor3 = Color3.fromRGB(180, 180, 180)
        end
        Container.Visible = true
        TabBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        activeTab = tabData
    end)
    return tabData
end
local skinTab = makeTab("Skins", 1)
local mallowTab = makeTab("Marshmallows", 2)
skinTab.container.Visible = true
skinTab.btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
skinTab.btn.TextColor3 = Color3.fromRGB(255, 255, 255)
activeTab = skinTab
table.sort(skinList)
for _, label in ipairs(skinList) do
    local btn = makeButton(skinTab.scroll, label, function()
        local skin = skinMap[label]
        local face = skinFaceMap[label]
        if skin then
            applySkin(skin, face)
            StatusLabel.Text = "✓ " .. skin.Name
        end
    end)
    table.insert(skinTab.buttons, {btn = btn, label = label})
end
skinTab.search:GetPropertyChangedSignal("Text"):Connect(function()
    local q = skinTab.search.Text:lower()
    for _, item in ipairs(skinTab.buttons) do
        item.btn.Visible = item.label:lower():find(q) ~= nil
    end
end)
for _, name in ipairs(marshmallowList) do
    local btn = makeButton(mallowTab.scroll, name, function()
        applyMarshmallow(marshmallowData[name])
        StatusLabel.Text = "✓ " .. name
    end)
    table.insert(mallowTab.buttons, {btn = btn, label = name})
end
mallowTab.search:GetPropertyChangedSignal("Text"):Connect(function()
    local q = mallowTab.search.Text:lower()
    for _, item in ipairs(mallowTab.buttons) do
        item.btn.Visible = item.label:lower():find(q) ~= nil
    end
end)
