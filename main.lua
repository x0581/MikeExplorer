local Iris = loadstring(game:HttpGet("https://raw.githubusercontent.com/x0581/Iris-Exploit-Bundle/main/bundle.lua"))().Init()
local PropertyAPIDump = game.HttpService:JSONDecode(game:HttpGet("https://anaminus.github.io/rbx/json/api/latest.json"))

local function GetPropertiesForInstance(Instance)
    local Properties = {}
    for i,v in next, PropertyAPIDump do
        if v.Class == Instance.ClassName and v.type == "Property" then
            pcall(function()
                Properties[v.Name] = {
                    Value = Instance[v.Name],
                    Type = v.ValueType,
                }
            end)
        end
    end
    return Properties
end

local ScriptContent = [[]]
local SelectedInstance = nil
local Properties = {}

local function CrawlInstances(Inst)
    for _, Instance in next, Inst:GetChildren() do
        local InstTree = Iris.Tree({Instance.Name})

        Iris.SameLine() do
            if Instance:IsA("LocalScript") or Instance:IsA("ModuleScript") then
                if Iris.SmallButton({"View Script"}).clicked then
                    ScriptContent = decompile(Instance)
                end
            end
            if Iris.SmallButton({"View Properties"}).clicked then
                SelectedInstance = Instance
                Properties = GetPropertiesForInstance(Instance)
            end
            Iris.End()
        end

        if InstTree.state.isUncollapsed.value then
            CrawlInstances(Instance)
        end
        Iris.End()
    end
end

Iris:Connect(function()
    local InstanceViewer = Iris.State(false)
    local PropertyViewer = Iris.State(false)
    local ScriptViewer = Iris.State(false)

    Iris.Window({"MikeExplorer Settings", [Iris.Args.Window.NoResize] = true}, {size = Iris.State(Vector2.new(400, 75)), position = Iris.State(Vector2.new(0, 0))}) do
        Iris.SameLine() do
            Iris.Checkbox({"Instance Viewer"}, {isChecked = InstanceViewer})
            Iris.Checkbox({"Property Viewer"}, {isChecked = PropertyViewer})
            Iris.Checkbox({"Script Viewer"}, {isChecked = ScriptViewer})
            Iris.End()
        end
        Iris.End()
    end

    if InstanceViewer.value then
        Iris.Window({"MikeExplorer Instance Viewer", [Iris.Args.Window.NoClose] = true}, {size = Iris.State(Vector2.new(400, 300)), position = Iris.State(Vector2.new(0, 75))}) do
            CrawlInstances(game)
            Iris.End()
        end
    end

    if PropertyViewer.value then
        Iris.Window({"MikeExplorer Property Viewer", [Iris.Args.Window.NoClose] = true}, {size = Iris.State(Vector2.new(400, 200)), position = Iris.State(Vector2.new(0, 375))}) do
            Iris.Text({("Viewing Properties For: %s"):format(
                SelectedInstance and SelectedInstance:GetFullName() or "UNKNOWN INSTNACE"
            )})
            Iris.Table({3, [Iris.Args.Table.RowBg] = true}) do
                for PropertyName, PropDetails in next, Properties do
                    Iris.Text({PropertyName})
                    Iris.NextColumn()
                    Iris.Text({PropDetails.Type})
                    Iris.NextColumn()
                    Iris.Text({tostring(PropDetails.Value)})
                    Iris.NextColumn()
                end
                Iris.End()
            end
        end
        Iris.End()
    end

    if ScriptViewer.value then
        Iris.Window({"MikeExplorer Script Viewer", [Iris.Args.Window.NoClose] = true}, {size = Iris.State(Vector2.new(600, 575)), position = Iris.State(Vector2.new(400, 0))}) do
            if Iris.Button({"Copy To Clipboard"}).clicked then
                setclipboard(ScriptContent)
            end
            local Lines = ScriptContent:split("\n")
            for I, Line in next, Lines do
                Iris.Text({Line})
            end
            Iris.End()
        end
    end
end)
