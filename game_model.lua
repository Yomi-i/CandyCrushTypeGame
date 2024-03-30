Cell = {}

function Cell:new(gem)
    local cell = {}
    cell.gem = gem

    function cell:getGem()
        return self.gem
    end

    setmetatable(cell, self)
    self.__index = self
    return cell
end

Gem = {}

function Gem:new(value)
    local map = {
        [-1] = "x",
        [0] = "A",
        [1] = "B",
        [2] = "C",
        [3] = "D",
        [4] = "E",
        [5] = "F"
    }

    local gem = {}
    gem.value = value

    function Gem:drawGem()
        return map[self.value]
    end

    function Gem:getValue()
        return self.value
    end

    function Gem:getName()
        return map[self.value]
    end

    setmetatable(gem, self)
    self.__index = self
    return gem
end

Board = {}

function Board:new(size)
    local size = size
    local board = {}

    function board:Init()
        board:CreateBoard()
        board:Dump()

        local matches = board:FindMatches()
        while matches ~= 0 do
            board:RemoveMatches()
            board:StartGravity()
            matches = board:FindMatches()
        end
        board:Dump()

        board:FillBoard()
        board:Dump()

        io.write('Use "m x y dir" to move gem (dir: l, r, u, d).\n')
        board:CheckForMoves()
    end

    function board:Tick()
        io.write('new tick\n')

        local score = 0
        local matches = board:FindMatches()
        while matches ~= 0 do
            score = score + board:RemoveMatches()
            board:Dump()
            board:StartGravity()
            matches = board:FindMatches()
        end

        board:FillBoard()
        board:Dump()

        totalScore = totalScore + score

        io.write('gems removed '..score..'!\n')
        board:CheckForMoves()
    end

    function board:CheckForMoves()
        if (board:AvaliableMoves() == 0) then
            io.write('No more moves! Type "mix" to mix.\n')
        end
    end

    function board:Move(from, to) 
        local fromGem = Gem:new(board[from.y][from.x]:getGem():getValue())
        local toGem = Gem:new(board[to.y][to.x]:getGem():getValue())
    
        board[from.y][from.x] = Cell:new(toGem)
        board[to.y][to.x] = Cell:new(fromGem)
    end
    
    function board:CreateBoard()
        math.randomseed(os.time())
        for y = 0, size - 1 do
            local row = {}
            for x = 0, size - 1 do
                local newGem = Gem:new(math.random(0,5))
                local newCell = Cell:new(newGem)
                row[x] = newCell
            end
            board[y] = row
        end
    end

    function board:FillBoard()
        for y = 0, size - 1 do
            for x = 0, size - 1 do
                if board[y][x]:getGem():getValue() == -1 then

                    local newGem = Gem:new(math.random(0,5))
                    local isGemFits = false
                    repeat
                        newGem = Gem:new(math.random(0,5))
                        isGemFits = board:TryPutNewGem(y, x, newGem)
                    until isGemFits == true
    
                    local newCell = Cell:new(newGem)
                    board[y][x] = newCell

                end
            end
        end
    end

    function board:MixBoard()
        math.randomseed(os.time())
        for y = 0, size - 1 do
            for x = 0, size - 1 do
                local fromGem = Gem:new(board[y][x]:getGem():getValue())
                local from = {}
                local to = {}
                local newX = math.random(0, size - 1)
                local newY = math.random(0, size - 1)

                local mixNum = 0
                local isGemFits = false
                repeat
                    newX = math.random(0, size - 1)
                    newY = math.random(0, size - 1)
                    local toGem = Gem:new(board[newY][newX]:getGem():getValue())
                    isGemFits = board:TryPutNewGem(newY, newX, fromGem) and board:TryPutNewGem(y, x, toGem)
                    mixNum = mixNum + 1
                    if mixNum >= 1000 then
                        break;
                    end
                until isGemFits == true
                
                from.x = newX
                from.y = newY
                to.x = x
                to.y = y
                
                board:Move(from, to)
            end
        end
    end

    function board:AvaliableMoves()
        local moves = 0
        local to = {}
        local from = {}
        for y = 0, size - 1 do
            for x = 0, size - 1 do
                for direction = 0, 3 do
                    local isProperMove = false
                    from.x = x
                    from.y = y
                    if direction == 0 and x > 0 then
                        to.x = x - 1
                        to.y = y
                        isProperMove = true
                    end
                    if direction == 1 and x < size - 1 then
                        to.x = x + 1
                        to.y = y
                        isProperMove = true
                    end
                    if direction == 2 and y > 0 then
                        to.x = x
                        to.y = y - 1
                        isProperMove = true
                    end
                    if direction == 3 and y < size - 1 then
                        to.x = x
                        to.y = y + 1
                        isProperMove = true
                    end
                    if isProperMove == true then
                        moves = moves + board:TestMoveGem(from, to)
                    end
                end
                if moves > 0 then 
                    return moves
                end
            end
        end
        return moves
    end

    function board:TestMoveGem(from, to)
        local fromGem = Gem:new(board[from.y][from.x]:getGem():getValue())
        local toGem = Gem:new(board[to.y][to.x]:getGem():getValue())

        local temp = board[from.y][from.x]
        board[from.y][from.x] = board[to.y][to.x]
        board[to.y][to.x] = temp

        local matches = board:FindMatches()

        board[from.y][from.x] = Cell:new(fromGem)
        board[to.y][to.x] = Cell:new(toGem)

        if matches > 0 then
            return 1
        end
        return 0
    end

    function board:TryPutNewGem(y, x, newGem)
        local sameGemsAround = 0
        for yi = y - 2, y + 2 do
            if yi >=0 and yi <= size - 1 and board[yi][x]:getGem():getValue() == newGem:getValue() then
                sameGemsAround = sameGemsAround + 1
            end
        end
        for xi = x - 2, x + 2 do
            if xi >= 0 and xi <= size - 1 and board[y][xi]:getGem():getValue() == newGem:getValue() then
                sameGemsAround = sameGemsAround + 1
            end
        end

        if sameGemsAround <= 1 then
            return true
        end
        return false
    end

    function board:FindMatches()
        local matches = 0
        for y = 0, size - 1 do
            for x = 0, size - 1 do
                local result = board:FindCompleteLine(y, x)
                if result.count >= 3 and result.gemValue >= 0 then
                    matches = matches + result.count
                end
            end
        end
        return matches
    end
    
    function board:RemoveMatches()
        local removedCount = 0
        for y = 0, size - 1 do
            for x = 0, size - 1 do
                local result = board:FindCompleteLine(y, x)
                if result.count >= 3 and result.gemValue >= 0 then
                    board:RemoveCompleteLine(y, x, result.count, result.direction)
                    removedCount = removedCount + result.count
                end
            end
        end
        return removedCount
    end

    function board:StartGravity()
        for pass = 1, size do
            for y = size - 1, 1, -1 do
                for x = size - 1, 0, -1 do
                    if board[y][x]:getGem():getValue() == -1 and board[y-1][x]:getGem():getValue() ~= -1 then

                        local emptyGem = Gem:new(-1)
                        local epmtyCell = Cell:new(emptyGem)
                        
                        local fallGem = Gem:new(board[y-1][x]:getGem():getValue())
                        local fallCell = Cell:new(fallGem)

                        board[y][x] = fallCell
                        board[y-1][x] = epmtyCell
                    end
                end
            end
        end
    end

    function board:RemoveCompleteLine(y, x, count, direction)
        if direction == 'H' then
            local maxX = x + count - 1
            for xi = x, maxX do 
                local emptyGem = Gem:new(-1)
                local newCell = Cell:new(emptyGem)
                board[y][xi] = newCell
            end
        end
        if direction == 'V' then
            local maxY = y + count - 1
            for yi = y, maxY do 
                local emptyGem = Gem:new(-1)
                local newCell = Cell:new(emptyGem)
                board[yi][x] = newCell
            end
        end
    end

    function board:FindCompleteLine(y, x)
        local resultHorizontal = board:HorizontalMatches(y, x)
        if resultHorizontal >= 3 then
            return {
                count = resultHorizontal,
                direction = 'H',
                gemValue = board[y][x]:getGem():getValue()
            }
        end

        local resultVertical = board:VerticalMatches(y, x)
        if resultVertical >= 3 then
            return {
                count = resultVertical,
                direction = 'V',
                gemValue = board[y][x]:getGem():getValue()
            }
        end

        return {
            count = 0,
            direction = 'NONE',
            gemValue = nil
        }
    end

    function board:HorizontalMatches(y, x)
        local gemValue = board[y][x]:getGem():getValue()
        local matches = 0

        if x < size - 1 then
            local xr = x
            while board[y][xr]:getGem():getValue() == gemValue and xr ~= size - 1 do
                matches = matches + 1
                if xr == size - 2 and board[y][size - 1]:getGem():getValue() == gemValue then
                    matches = matches + 1
                end
                xr = xr + 1
            end 
        end
        return matches
    end

    function board:VerticalMatches(y, x)
        local gemValue = board[y][x]:getGem():getValue()
        local matches = 0

        if y < size - 1 then
            local yd = y
            while board[yd][x]:getGem():getValue() == gemValue and yd ~= size - 1 do
                matches = matches + 1
                if yd == size - 2 and board[size - 1][x]:getGem():getValue() == gemValue then
                    matches = matches + 1
                end
                yd = yd + 1
            end 
        end
        return matches
    end

    function board:Dump()
        io.write('------------------\n')
        for x = 0, size - 1 do 
            io.write(' ')
            io.write(x .. ' ')
        end
        io.write('\n')
        for y = 0, size - 1 do
            io.write(y)
            for x = 0, size - 1 do 
                io.write(' ' .. board[y][x]:getGem():drawGem() .. ' ')
            end
            io.write('\n')
        end
    end

    setmetatable(board, self)
    self.__index = self
    return board
end
