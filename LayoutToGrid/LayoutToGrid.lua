local destinationLayout;

local function log(arg)
	Printf(arg)
end

local function arrayHasValue(tab, val)
	for index, value in ipairs(tab) do
			if value == val then
					return true
			end
	end
	return false
end

local function highestXValue(elements)
	local result = 0
	for i = 1, #elements do
			if elements[i].posX > result then
					result = elements[i].posX
			end
	end
	return result
end

local function executeCommand(command) 
	Cmd(command)
end

local function selectCellInGrid(element)
	executeCommand("Grid " .. (element.posX) .. "/" .. (element.posY - 1))
	executeCommand(element.id)
end

local function setIntoGrid(elements)

		local temp;
		local current;
		local x = 0;

		for l = 1, highestXValue(elements) do

			x = l - 1

			for i = 1, #elements do

				current = elements[i]

				if x <= current.posX - 1 then

					temp = {
						id = current.id,
						posX = x,
						posY = current.posY
					}

					selectCellInGrid(temp)
				end
			end
		end
end

local function normalizeX(array)
    local result = {}
    local current
    local last
    local counter = 0
    for i = 1, #array do
        current = array[i].posX
        if current ~= last then
            counter = counter + 1
        end
        result[i] = counter;
        last = current
    end
    return result
end

local function normalizeY(array)
    local keys = {}
    local levels = {}
    local result = {}

    for i = 1, #array do
        if not arrayHasValue(levels, array[i].posY) then
            table.insert(levels, array[i].posY)
        end
    end

    table.sort(levels)

    for i = 1, #levels do
        keys[levels[i]] = i
    end

    for i = 1, #array do
        result[i] = keys[array[i].posY]
    end

    return result
end

local function twosCompToInt(val)
	if val > 32767 then
			return val - 65536
	else
			return val
	end
end

local function convert(elements)
	table.sort(elements, function(left, right)
			return left.posX < right.posX
	end)

	local result = {}
	local yCalc = normalizeY(elements)
	local xCalc = normalizeX(elements)

	for i = 1, #elements do
			local temp = {
					id = elements[i].id,
					posX = xCalc[i],
					posY = yCalc[i]
			}
			table.insert(result, temp)
	end

	return result
end

local function getElements()
    local layout = DataPool().Layouts[destinationLayout]
    local elements = {}

    for i = 1, #layout do
        if layout[i].assignType == "Fixture" then

            local temp = {
                id = layout[i]:Get("Object"):ToAddr(),
                posX = twosCompToInt(layout[i].posx),
                posY = twosCompToInt(layout[i].posy)
            }

            table.insert(elements, temp)
        end
    end

    return elements
end

local function main()

	local numbers = "0123456789"
	local pufferDefault = 10;

	local layoutInput = {
		{
		name = "Destinationlayout (ID)",
		value = "",
		whiteFilter = numbers
	}
}

	local messageBox = MessageBox(
		{
			title = "Layout to SelectionGrid converter",
			message = "Which layout should be Converted?",
			message_align_h = Enums.AlignmentH.Middle,
			commands = {{value = 1, name = "Go!"}, {value = 0, name = "Cancel :("}},
			inputs = layoutInput,
			backColor = "Global.Default",
			titleTextColor = "Global.Text",
			messageTextColor = "Global.Text",
		}
	)

	if messageBox.result == 1 then

		for k,v in pairs(messageBox.inputs) do
			destinationLayout = math.tointeger(v);
		end

		executeCommand("Clear")

		local elements = convert(getElements()) 

		table.sort(elements, function (left, right)
				return left.posY < right.posY
			end)

		setIntoGrid(elements)
	end
end

return main