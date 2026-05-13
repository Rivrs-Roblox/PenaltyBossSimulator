local GridFunctions = {}

local GetTableAmount = require(script.Parent.Parent.Table.GetTableAmount)
local DeepCopy = require(script.Parent.Parent.Table.DeepCopy)
local TemplateForCoach = require(script.Parent.InfoTemplate)

local function GetPlacementInformation(PetAmount)
    local Rows = math.round(math.sqrt(PetAmount)) --// Squareroot the pet amount to get a  x by x amount and round it
    local Columns = math.ceil(PetAmount / Rows) --// Take total pet amount and divide by amount of rows
    return Rows, Columns
end

function GridFunctions.GetGrids(Coaches, OldGrids, Player)
    local Grids = {}

    local TotalCoachAmount = GetTableAmount(Coaches)

    local Rows, Columns, RemainderColumns = GetPlacementInformation(TotalCoachAmount)
    local RowIndex = 1
    local ColumnIndex = 0
    local LoopedIndex = 0

    for i, v in pairs(Coaches) do
        if ColumnIndex == Columns then --// Reset columns and add a row to the index
            RowIndex = RowIndex + 1
            ColumnIndex = 0
        end
        ColumnIndex = ColumnIndex + 1

        local IsOnFinalRow = (tonumber(RowIndex) == tonumber(Rows) and true) or false --// If final row then find the remainder columnms
        if IsOnFinalRow and RemainderColumns == nil then
            RemainderColumns = #Coaches - LoopedIndex
        end

        local Template

        if OldGrids[i] then
            Template = OldGrids[i]
        else
            Template = DeepCopy(TemplateForCoach)
        end

        Template.Index = i

        Template.Row = RowIndex
        Template.Column = ColumnIndex

        --[[if IsOnFinalRow then
            if TotalPetAmount % 5 == 2 then
                if LoopedIndex + 1 == TotalPetAmount then Template.Column += 2
                else Template.Column += 1 end
            end
        end]]--

        if Template.CoachData == "None" then
            Template.CoachData = v
        else
            Template.CoachData = v
        end

        if Template.Information.Target == nil then
            local character = Player.Character or Player.CharacterAdded:Wait()
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart")
            Template.Information.Target = humanoidRootPart
        end

        Template.TotalRows = Rows
        Template.TotalColumns = --[[(IsOnFinalRow == true and RemainderColumns) or]] Columns

        Grids[i] = Template
        LoopedIndex = LoopedIndex + 1
    end

    return Grids
end

return GridFunctions