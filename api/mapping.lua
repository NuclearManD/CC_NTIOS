

-- Note that the Y and Z axes are swapped vs minecraft coordinates.
-- On this program, Z is up and Y is horizontal.  Z can also be thought
-- of as the "layer" of the map.  Z can even be a string, for instance
-- your layer names may be: "underground", "surface", "sky", etc

-- The scale factor is just metadata saved in the map, to tell how big a tile is.
-- With a scale of 1, a tile is just one block.  A scale of 16, and a tile is a chunk.
-- The scale specifies the number of blocks per tile on each axis.


local function setTile(this, x, y, z, color, material)
    --x = math.floor(x / this.data.scale)
    --y = math.floor(y / this.data.scale)
    if this.data.layers[z] == nil then
        this.data.layers[z] = {}
    end
    local layer = this.data.layers[z]
    local key = tostring(x) .. "_" .. tostring(y)
    local old = layer[key]
    layer[key] = {
        color = color, material = material
    }
    return old
end

local function getTile(this, x, y, z)
    --x = math.floor(x / this.data.scale)
    --y = math.floor(y / this.data.scale)
    if this.data.layers[z] == nil then
        return nil
    end
    local key = tostring(x) .. "_" .. tostring(y)
    return this.data.layers[z][key]
end

local function serialize(this)
    return textutils.serializeJSON(this.data)
end

local function setWaypoint(this, x, y, z, name, metadata)
    local waypoint = {x=x, y=y, z=z}
    if metadata ~= nil then
        waypoint.metadata=metadata
    end
    this.data.waypoints[name] = waypoint
end

local function getWaypointByPosition(this, x, y, z)
    for name, position in pairs(this.data.waypoints) do
        if position.x == x and position.y == y then
            if z == nil or z == position.z then
                return name
            end
        end
    end
end

local function addRegion(this, name, polygon, metadata)
    local region = {}
    region.name = name
    region.polygon = polygon
    region.metadata = metadata
    table.insert(this.data.regions, regions)
    return region
end

local function getRegion(this, name)
    for _, region in ipairs(this.data.regions) do
        if region.name == name then
            return region
        end
    end
end

local function tilesToNfpImage(this, centerx, centery, z, w, h)
    local text = ""
    local y1 = centery + math.floor(h/2)
    local y2 = y1 - h + 1
    local x1 = centerx - math.floor(w/2)
    local x2 = x1 + w - 1
    for y = y1, y2, -1 do
        local sLine = ""
        for x = x1, x2 do
            local c = " "
            local tile = this.getTile(x, y, z)
            if tile then
                c = imaging.colorToChar(tile.color)
            end
            sLine = sLine .. c
        end
        text = text .. sLine .. "\n"
    end
    return text
end

local function waypointsToText(this, centerx, centery, z, w, h)
    local text = ""
    local y1 = centery + math.floor(h/2)
    local y2 = y1 - h + 1
    local x1 = centerx - math.floor(w/2)
    local x2 = x1 + w - 1
    for y = y1, y2, -1 do
        local line = ""
        local waypointCharIndex = nil
        local waypointName = nil
        local i = 1
        for x = x1, x2 do
            local c = " "
            local waypoint = this.getWaypointByPosition(x, y, z)
            if waypoint then
                c = "*"
                waypointName = waypoint
                waypointCharIndex = i
            end
            line = line .. c
            i = i + 1
        end
        if waypointCharIndex then
            line = line:sub(1, waypointCharIndex + 1) .. waypointName
        end
        text = text .. line .. "\n"
    end
    return text
end


local function initMap(data)
    local this = {}

    this.data = data

    this.setTile     = function(...) return setTile(this, ...) end
    this.getTile     = function(...) return getTile(this, ...) end
    this.setWaypoint = function(...) return setWaypoint(this, ...) end
    this.addRegion   = function(...) return addRegion(this, ...) end
    this.getRegion   = function(...) return getRegion(this, ...) end
    this.serialize   = function(...) return serialize(this, ...) end

    this.tilesToNfpImage = function(...) return tilesToNfpImage(this, ...) end
    this.waypointsToText = function(...) return waypointsToText(this, ...) end
    this.getWaypointByPosition = function(...) return getWaypointByPosition(this, ...) end

    return this
end

function Map(scale)
    data = {
        layers = {},
        waypoints = {},
        regions = {},
        scale = scale
    }
    return initMap(data)
end
    
function deserializeMap(string)
    data = textutils.unserializeJSON(string)
    if data.layers == nil then
        data.layers = {}
    end
    if data.waypoints == nil then
        data.waypoints = {}
    end
    if data.regions == nil then
        data.regions = {}
    end
    return initMap(data)
end
