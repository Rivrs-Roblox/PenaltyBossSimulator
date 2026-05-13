local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)

local TemplateService = Knit.CreateService({
	Name = "TemplateService",
})

-- #region Local Functions
local function localTestFunction()
	print("Local Test Function called")
end
-- #endregion Local Functions

-- #region Client Functions
function TemplateService.Client:TestFunction()
	print("TemplateService TestFunction called")
end
-- #endregion Client Functions

-- #region Server Functions
function TemplateService:TestFunction()
	print("TemplateService TestFunction called")
end
-- #endregion Server Functions

-- #region Knit Lifecycle
function TemplateService:KnitInit()
	print("TemplateService Initialized")
end

function TemplateService:KnitStart()
	print("TemplateService Started")
end
-- #endregion Knit Lifecycle

return TemplateService
