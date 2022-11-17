RunService = game:GetService("RunService")
Functions = require(game.ReplicatedStorage.Common.Functions)

camera = workspace.CurrentCamera

player = game:GetService("Players").LocalPlayer

Circles = {}

RenderObjects = {}

pixelarray = {}

framearray = {}

RenderObject = {}

devisor = 12

GUI = Instance.new("ScreenGui")
GUI.Parent = player.PlayerGui

x = GUI.AbsoluteSize.x
y = GUI.AbsoluteSize.y

local imageAspectRatio = x/y
if x < y then
	imageAspectRatio = y/x
end



function buildpixelFrame(i,j)
	pixelarray[i][j] = Color3.new(1,0.5,1)

	local frame = Instance.new("Frame")
	frame.Position = UDim2.new(0,i,0,j)
	frame.Size = UDim2.new(0,devisor,0,devisor)
	frame.BorderSizePixel = 0
	frame.Name = i.." "..j
	frame.Parent = GUI
	framearray[i][j] = frame
end

for i = 0, x, devisor do
    pixelarray[i] = {}
	framearray[i] = {}
    for j = 0, y, devisor do
        buildpixelFrame(i,j)
    end
end

function SetFrameColor(i,j,Color)
	local pixel = nil
	pixel = GUI:WaitForChild(i.." "..j)
	if pixel == pixel then
		if typeof(Color) == "Color3" then
			if Color ~= pixel.BackgroundColor3 then
				pixel.BackgroundColor3 = Color
			end
		elseif typeof(Color) == "NumberValue" then 
			Color = Color3.new(Color,Color,Color)
			if Color ~= pixel.BackgroundColor3 then
				pixel.BackgroundColor3 = Color
			end
		end
	end
end

function RenderObject.newSphere(position,radius,color)
    local newObject = {}

    newObject.Position = position
    newObject.Size = radius 
    newObject.Color = color
    newObject.Rotation = Vector3.new(0,0,0)
    newObject. SDF = Functions.SphereDistance
    --newObject.Polygon = Instance.new("Part")
    --newObject.Polygon.Position = position
    --newObject.Polygon.Size = Vector3.new(radius*2,radius*2,radius*2)
    --newObject.Polygon.Parent = workspace
    --newObject.Polygon.Name ="X "..position.x.." Y "..position.y.." Z "..position.z.." Sphere"
    --newObject.Polygon.Shape = 0
    --newObject.Polygon.CanCollide = false
    --newObject.Polygon.Anchored = true
    return newObject
end

function RenderObject.newBox(position,size,color)
    local newObject = {}

    newObject.Position = position
    newObject.Size = size
    newObject.Color = color
    newObject.Rotation = Vector3.new(0,0,0)
    newObject.SDF = Functions.CubeDistance
    --newObject.Polygon = Instance.new("Part")
    --newObject.Polygon.Position = position
    --newObject.Polygon.Size = Vector3.new(size.x*2,size.y*2,size.z*2)
    --newObject.Polygon.Parent = workspace
    --newObject.Polygon.Name ="X "..position.x.." Y "..position.y.." Z "..position.z.." Box"
    --newObject.Polygon.Shape = 1
    --newObject.Polygon.CanCollide = false
    --newObject.Polygon.Anchored = true
    return newObject
end
function RenderObject.newGround(color)
    local newObject = {}

    newObject.Position = Vector3.new(0,0,0) -- I understand this is completely useles, but the code requires it and I don't feel like rewriting it
    newObject.Size = Vector3.new(0,0,0) -- Same with this
    newObject.Color = color
    newObject.Rotation = Vector3.new(0,0,0) -- and this
    newObject.SDF = Functions.GroundDistance
    return newObject
end
for i = 4, 54 do
    if i%2 == 0 then
        RenderObjects[i] = RenderObject.newSphere(Vector3.new(math.random(-100,100),math.random(0,20),math.random(-100,100)),math.random(1,10),Color3.fromRGB(math.random(0,255),math.random(0,255),math.random(0,255)))
    else
        RenderObjects[i] = RenderObject.newBox(Vector3.new(math.random(-100,100),math.random(0,20),math.random(-100,100)),Vector3.new(math.random(1,10),math.random(1,10),math.random(1,10)),Color3.fromRGB(math.random(0,255),math.random(0,255),math.random(0,255)))
    end
    
end
RenderObjects[0] = RenderObject.newGround(Color3.fromRGB(255, 0, 255))
RenderObjects[1] = RenderObject.newBox(Vector3.new(0,0,0),Vector3.new(6,0.5,6), Color3.fromRGB(0,255,0), Vector3.new(0,0,0))
RenderObjects[2] = RenderObject.newBox(Vector3.new(0,10,0),Vector3.new(6,0.5,6), Color3.fromRGB(0,255,0), Vector3.new(0,0,0))
RenderObjects[3] = RenderObject.newGround(Color3.fromRGB(12, 74, 0))
wait(5)
function RenderPixel(i,j,SunVector,DistanceObjects) 
    local unitRay = camera:ViewportPointToRay(i+(devisor/2), j+(devisor/2))
    local returnValue,maxMinDists,minMinDistsObject,minMinDistsPosition,minMinDists = Functions.Compute(unitRay,DistanceObjects)
    if returnValue == 1 then
        local Raw = Ray.new(minMinDistsPosition,SunVector)
        local ShadowObjects = Functions.shallowCopy(DistanceObjects)
        --table.remove(ShadowObjects,minMinDistsObject)
        local ShadowValue = Functions.ShadowCompute(Raw,ShadowObjects,minMinDists)
        --if ShadowValue == 1 then
        --    SetFrameColor(i,j,Color3.new(1,1,1))
        --elseif ShadowValue == 0 then
        --    SetFrameColor(i,j,Color3.new(0,0,0))
        --end
        --local Color = Color3.new(DistanceObjects[minMinDistsObject].Color.R*(((maxMinDists/100)*-1)+1)*ShadowValue,DistanceObjects[minMinDistsObject].Color.G*(((maxMinDists/100)*-1)+1)*ShadowValue,DistanceObjects[minMinDistsObject].Color.B*(((maxMinDists/100)*-1)+1)*ShadowValue)
        local Color = Color3.new(DistanceObjects[minMinDistsObject].Color.R*ShadowValue,DistanceObjects[minMinDistsObject].Color.G*ShadowValue,DistanceObjects[minMinDistsObject].Color.B*ShadowValue)
        SetFrameColor(i,j,Color)
    elseif returnValue == 2 then
            SetFrameColor(i,j,Color3.fromRGB(0, 255, 255))
    else
            SetFrameColor(i,j,Color3.fromRGB(255, 0, 255))
    end
end
RunService.Heartbeat:Connect(function(deltaTime)
    if deltaTime > 2 then
        print("Uh oh, Too long!")
        script.Disabled = true
    end
    local DistanceObjects = Functions.shallowCopy(RenderObjects)
    for key, value in pairs(DistanceObjects) do
        if Functions.distance(DistanceObjects[key].Position,camera.CFrame.Position) > 50 then
                table.remove( DistanceObjects, key)
        end
    end
    local  SunVector = game.Lighting:GetSunDirection()
    for i = 0,x,devisor do
        for j =  0,y,devisor do
            coroutine.wrap(RenderPixel)(i,j,SunVector,DistanceObjects) 
        end 
    end
    RenderObjects[2].Rotation = RenderObjects[2].Rotation + Vector3.new(0,1,0) 
end)