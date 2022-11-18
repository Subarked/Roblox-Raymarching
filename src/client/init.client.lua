RunService = game:GetService("RunService")
Functions = require(game.ReplicatedStorage.Common.Functions)

camera = workspace.CurrentCamera

player = game:GetService("Players").LocalPlayer

PcameraPosititon = Vector3.new(0,0,0)

Circles = {}

RenderObjects = {}

pixelarray = {}

shadowarray = {}

sunrayarray = {}

mindistsarray = {}

deptharray = {}

objectidarray = {}

objectclosestdeptharray = {}

objectfarthestdeptharray  = {}

framearray = {}

SunVector = game.Lighting:GetSunDirection()

DistanceObjects = {}

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
    shadowarray[i][j] = Color3.new(1,1,1)
    sunrayarray[i][j] = nil
    mindistsarray[i][j] = 0
    deptharray[i][j] = 0
    objectidarray[i][j] = 0
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
    shadowarray[i] = {}
    sunrayarray[i] = {}
	framearray[i] = {}
    deptharray[i] = {}
    objectidarray[i] = {}
    mindistsarray[i] = {}
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
    newObject. SDF = Functions.sdSphere
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

function RenderObject.newCapsule(position,radius,color,w)
    local newObject = {}

    newObject.Position = position
    newObject.Size = radius 
    newObject.Color = color
    newObject.W = w
    newObject.Rotation = Vector3.new(0,0,0)
    newObject. SDF = Functions.sdVerticalCapsule
    return newObject
end


function RenderObject.newBox(position,size,color)
    local newObject = {}

    newObject.Position = position
    newObject.Size = size
    newObject.Color = color
    newObject.Rotation = Vector3.new(0,0,0)
    newObject.SDF = Functions.sdBox
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
for i = 5, 15 do
    if i%2 == 0 then
        RenderObjects[i] = RenderObject.newSphere(Vector3.new(math.random(-100,100),math.random(0,20),math.random(-100,100)),math.random(1,10),Color3.fromRGB(math.random(0,255),math.random(0,255),math.random(0,255)))
    else
        RenderObjects[i] = RenderObject.newBox(Vector3.new(math.random(-100,100),math.random(0,20),math.random(-100,100)),Vector3.new(math.random(1,10),math.random(1,10),math.random(1,10)),Color3.fromRGB(math.random(0,255),math.random(0,255),math.random(0,255)))
    end
    
end

function DumpPixelArray(RenderLayer)
    for i = 0,x,devisor do
        for j =  0,y,devisor do
            if RenderLayer == "BaseColors" then
                SetFrameColor(i,j,pixelarray[i][j])
            elseif RenderLayer == "Combined" then
                SetFrameColor(i,j,Color3.new(pixelarray[i][j].R*Functions.map(shadowarray[i][j].R,0,1,0,0.9),pixelarray[i][j].G*Functions.map(shadowarray[i][j].G,0,1,0,0.9),pixelarray[i][j].B*Functions.map(shadowarray[i][j].B,0,1,0,0.9)))
            elseif RenderLayer == "Combined&Depth" then
                --print(objectclosestdeptharray)
                --print(objectfarthestdeptharray)
                local Color =  Color3.new(pixelarray[i][j].R*Functions.map(shadowarray[i][j].R,0,1,0.25,1),pixelarray[i][j].G*Functions.map(shadowarray[i][j].G,0,1,0.25,1),pixelarray[i][j].B*Functions.map(shadowarray[i][j].B,0,1,0.25,1))
                local objectdepth = 1
                if objectidarray[i][j] ~= nil and objectidarray[i][j] ~= 3 then
                    objectdepth = Functions.map(deptharray[i][j],objectclosestdeptharray[objectidarray[i][j]],objectfarthestdeptharray[objectidarray[i][j]],0.5,1)
                end
                Color  = Color3.new(Color.R*objectdepth,Color.G*objectdepth,Color.B*objectdepth)
                local c = deptharray[i][j]*-1+1
                Color = Color:Lerp(Color3.new(0,1,1),c^3)
                SetFrameColor(i,j,Color)
            elseif RenderLayer == "Min Dists" then
                SetFrameColor(i,j,Color3.new(mindistsarray[i][j]*100))
            elseif RenderLayer == "Shadow Mask" then
                SetFrameColor(i,j,Color3.new(shadowarray[i][j].R,shadowarray[i][j].G,shadowarray[i][j].B))
            elseif RenderLayer == "Depth" then
                SetFrameColor(i,j,Color3.new(deptharray[i][j],deptharray[i][j],deptharray[i][j]))
            end
            

        end 
    end
end
RenderObjects[0] = RenderObject.newGround(Color3.fromRGB(255, 0, 255)) --error plane
RenderObjects[1] = RenderObject.newBox(Vector3.new(0,0,0),Vector3.new(6,0.5,6), Color3.fromRGB(0,255,0), Vector3.new(0,0,0)) -- spawn point
RenderObjects[2] = RenderObject.newBox(Vector3.new(0,10,0),Vector3.new(6,0.5,6), Color3.fromRGB(0,255,0), Vector3.new(0,0,0)) --spawn point spinner above
RenderObjects[3] = RenderObject.newGround(Color3.fromRGB(12, 74, 0)) --ground
RenderObjects[4] = RenderObject.newCapsule(Vector3.new(0,0,0),2.5,Color3.fromRGB(255/2,255/2,255/2),2.5) --player capsule
player.CharacterAdded:Wait()
wait(5)
function RenderPixel(i,j,SunVector,DistanceObjects) 
    local unitRay = camera:ViewportPointToRay(i+(devisor/2), j+(devisor/2))
    local returnValue,maxMinDists,minMinDistsObject,minMinDistsPosition,minMinDists = Functions.Compute(unitRay,DistanceObjects,RenderObjects)
    if returnValue == 1 then
        local Raw = Ray.new(minMinDistsPosition,SunVector)
        sunrayarray[i][j] = Raw
        mindistsarray[i][j] = tonumber(minMinDists)
        deptharray[i][j] = math.abs(((maxMinDists/50)*-1)+1)
        local objectindex =  DistanceObjects[minMinDistsObject]   
        objectidarray[i][j] = objectindex
        --print(objectindex)
        if objectindex ~= nil and objectindex ~= 3 then
            if objectclosestdeptharray[objectindex] > deptharray[i][j] then
               objectclosestdeptharray[objectindex] = deptharray[i][j]
            elseif objectfarthestdeptharray[objectindex] < deptharray[i][j] then
               objectfarthestdeptharray[objectindex] = deptharray[i][j]
            end
        end
        
        --table.remove(ShadowObjects,minMinDistsObject)
        --local ShadowValue = Functions.ShadowCompute(Raw,ShadowObjects,minMinDists)
        --if ShadowValue == 1 then
        --    SetFrameColor(i,j,Color3.new(1,1,1))
        --elseif ShadowValue == 0 then
        --    SetFrameColor(i,j,Color3.new(0,0,0))
        --end
        --local Color = Color3.new(DistanceObjects[minMinDistsObject].Color.R*(((maxMinDists/100)*-1)+1)*ShadowValue,DistanceObjects[minMinDistsObject].Color.G*(((maxMinDists/100)*-1)+1)*ShadowValue,DistanceObjects[minMinDistsObject].Color.B*(((maxMinDists/100)*-1)+1)*ShadowValue)
        local Color = Color3.new(RenderObjects[DistanceObjects[minMinDistsObject]].Color.R,RenderObjects[DistanceObjects[minMinDistsObject]].Color.G,RenderObjects[DistanceObjects[minMinDistsObject]].Color.B)
        pixelarray[i][j] = Color
        --shadowarray[i][j] = Color3.new(ShadowValue,ShadowValue,ShadowValue)
        --SetFrameColor(i,j,Color)
    elseif returnValue == 2 then
        pixelarray[i][j] = Color3.fromRGB(0, 255, 255)
        sunrayarray[i][j] = nil
        mindistsarray[i][j] = 0
        objectidarray[i][j] = nil
        deptharray[i][j] = 0
        shadowarray[i][j] = Color3.new(1,1,1)
        --SetFrameColor(i,j,Color3.fromRGB(0, 255, 255))
    else
        pixelarray[i][j] = Color3.fromRGB(255, 0, 255)
        sunrayarray[i][j] = nil
        mindistsarray[i][j] = 0
        deptharray[i][j] = 1
        shadowarray[i][j] = Color3.new(1,1,1)
        --SetFrameColor(i,j,Color3.fromRGB(255, 0, 255))
    end

end
function CalculateShadows(i,j,DistanceObjects) 
    if sunrayarray[i][j] ~= nil then
        local unitRay = sunrayarray[i][j]
        local returnValue = Functions.ShadowCompute(unitRay,DistanceObjects,mindistsarray[i][j],RenderObjects)
        shadowarray[i][j] = Color3.new(returnValue,returnValue,returnValue)
    end
end
Rendering = false
ErroredOut = false
RunService.Heartbeat:Connect(function(deltaTime)
    for key, value in pairs(RenderObjects) do
        objectclosestdeptharray[key] = math.huge
        objectfarthestdeptharray[key] = 0
    end
    if ErroredOut == true then
        return nil
    end
    if deltaTime > 2 then
        DumpPixelArray("Combined")
        ErroredOut = true
        error("Uh oh, Too long! gonna dump the pixel array to the screen!")
    end
    if Rendering == true then
        return nil
    end
    
    Rendering = true
    if PcameraPosition ~= camera.CFrame.Position then
        DistanceObjects = {}
        i = 1
        for key, value in pairs(RenderObjects) do
            if Functions.distance(RenderObjects[key].Position,camera.CFrame.Position) > 50 and key ~= 3 then
                    table.remove( DistanceObjects, key)
            else
                DistanceObjects[i] = key
                i += 1
            end
        end
    end
    
    
    
    for i = 0,x,devisor do
        for j =  0,y,devisor do
            coroutine.wrap(RenderPixel)(i,j,SunVector,DistanceObjects) 
        end 
    end
    DumpPixelArray("Depth")

    for i = 0,x,devisor do
        for j =  0,y,devisor do
            coroutine.wrap(CalculateShadows)(i,j,DistanceObjects) 
        end 
    end

    DumpPixelArray("Combined&Depth")
    
    Rendering = false
    RenderObjects[2].Rotation = RenderObjects[2].Rotation + Vector3.new(0,1,0) 
    RenderObjects[4].Position = player.character.PrimaryPart.Position
    PcameraPosition = camera.CFrame.Position
end)