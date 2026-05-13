local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)

local TemplateController = Knit.CreateController({
	Name = "TemplateController",
})

-- #region Local Functions
local function localTestFunction()
	print("Local Test Function called")
end
-- #endregion Local Functions

-- #region Functions
function TemplateController:TestFunction()
	print("TemplateController TestFunction called")
end
-- #endregion Functions

-- #region Knit Lifecycle
function TemplateController:KnitInit()
	print("TemplateController Initialized")
end

function TemplateController:KnitStart()
	print("TemplateController Started")
end
-- #endregion Knit Lifecycle

return TemplateController
