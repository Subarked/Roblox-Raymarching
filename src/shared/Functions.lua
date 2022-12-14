local module = {}
local lighting = game:GetService("Lighting")

module.length = function(v)
	return math.sqrt(v.x*v.x + v.y*v.y + v.z*v.z)
end

module.distance = function(a,b)
	return math.sqrt((b.x-a.x)^2 + (b.y-a.y)^2+(b.z-a.z)^2)
end

module.GroundDistance = function(eye)
    return eye.y
end

module.sdSphere = function(eye, centre, radius) 
    return module.distance(eye, centre) - radius
end

  p = eye-centre
  p -= Vector3.new(0,math.clamp( p.y, -w/2, w/2 ),0)
  return module.length(p) - radius
end

module.sdBox = function(eye, centre, size,rotation) 
    if rotation ~= Vector3.new(0,0,0) then
        local centerCFrame = CFrame.new(centre)
        local eyeTemp = centerCFrame:PointToObjectSpace(eye)
        local centerCFrame = centerCFrame * CFrame.fromEulerAnglesXYZ(math.rad(rotation.x),math.rad(rotation.y),math.rad(rotation.z))
        eye = centerCFrame:PointToWorldSpace(eyeTemp)
    end
    local o = Vector3.new(math.abs(eye.x-centre.x) - size.x,math.abs(eye.y-centre.y) - size.y,math.abs(eye.z-centre.z) - size.z)
    local ud = module.length(Vector3.new(math.max(o.x,0),math.max(o.y,0),math.max(o.z,0)));
    local n = math.max(math.max(math.min(o.x,0),math.min(o.y,0)), math.min(o.z,0));
    return ud+n;
end

module.ObjectRollover = function(Position,RenderObjects,DistanceObjects)
	local minDist = math.huge
    local minDistObject = 0
	for i = 1, #DistanceObjects do
        local dist = RenderObjects[DistanceObjects[i]].SDF(Position,RenderObjects[DistanceObjects[i]].Position,RenderObjects[DistanceObjects[i]].Size,RenderObjects[DistanceObjects[i]].Rotation,RenderObjects[DistanceObjects[i]].W)
        if dist == nil then
			dist = 100
		end
        if dist == 0 then
            dist = 0.001
		elseif dist < 0 then
			dist = 100
		end

        if dist < minDist and dist > 0 then
            minDist = dist
            minDistObject = i
        end
    end
	return minDist,minDistObject
end
module.ShadowCompute = function(unitRay,DistanceObjects,previousDist,RenderObjects)
    local maxMinDists = 0
    local minMinDists = math.huge
    local minDists = {}
    local i = 1
	local returnValue = 0 
    while (minMinDists >= previousDist/1.1 and maxMinDists < 100) do
        minDists[i] = math.huge
        Position = Vector3.new(unitRay.Origin.x+maxMinDists*unitRay.Direction.x,unitRay.Origin.y+maxMinDists*unitRay.Direction.y,unitRay.Origin.z+maxMinDists*unitRay.Direction.z)
        minDists[i],minDistsObject = module.ObjectRollover(Position,RenderObjects,DistanceObjects)
        if minDists[i] < minMinDists and minDists[i] > 0 then
            minMinDists = minDists[i]
        end
        maxMinDists += minDists[i]
        i += 1
    end
    if minMinDists < previousDist/1.1 then
		returnValue = 0
	elseif maxMinDists >= 100 then
		returnValue =  1
	end

	return returnValue,maxMinDists
end
module.shallowCopy = function(original)
    local copy = {}
    for key, value in pairs(original) do
        copy[key] = value
    end
    return copy
end

module.Compute = function(unitRay,DistanceObjects,RenderObjects)
	local maxMinDists = 0
    local minMinDistsObject = 0
    local minMinDistsPosition = Vector3.new(0,0,0)
    local minMinDists = math.huge
    local minDists = {}
    local i = 1
	local returnValue = 0 
    while minMinDists >= 0.002 and maxMinDists < 50 do
        --Circles[i] = Instance.new("Part")
        --Circles[i].Transparency = 0.5
        --Circles[i].Size = Vector3.new(2,2,2)
        --Circles[i].Parent = workspace
        --Circles[i].Name ="Circles["..i.."]"
        --Circles[i].Shape = 0
        --Circles[i].Anchored = true
        --Circles[i].CanCollide = false
        --Circles[i].CastShadow = false
        minDists[i] = math.huge
        Position = Vector3.new(unitRay.Origin.x+maxMinDists*unitRay.Direction.x,unitRay.Origin.y+maxMinDists*unitRay.Direction.y,unitRay.Origin.z+maxMinDists*unitRay.Direction.z)
        minDists[i],minDistsObject = module.ObjectRollover(Position,RenderObjects,DistanceObjects)
        --Circles[i].Size = Vector3.new(minDists[i]*2,minDists[i]*2,minDists[i]*2)
        if minDists[i] < minMinDists and minDists[i] > 0 then
            minMinDists = minDists[i]
            minMinDistsObject = minDistsObject
            minMinDistsPosition = Position
        end
        maxMinDists += minDists[i]
        i += 1
    end
	if minMinDists < 0.002 then
		returnValue = 1
	elseif maxMinDists >= 50 then
		returnValue =  2
	end

	return returnValue,maxMinDists,minMinDistsObject,minMinDistsPosition,minMinDists
end
module.map = function(x, in_min, in_max, out_min, out_max)
	return out_min + (x - in_min)*(out_max - out_min)/(in_max - in_min)
end
return module