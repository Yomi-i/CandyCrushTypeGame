function Init()
    boardSize = 10
    totalScore = 0
    os.execute("cls")
    gameBoard = Board:new(boardSize)
    gameBoard:Init()
end 

function ExecCommand(cmd)
    if cmd[1] == 'q' then 
        os.exit()
    end

    if cmd[1] == 'mix' then
        gameBoard:MixBoard()
        gameBoard:Dump()
        io.write('Board mixed.\n')
        gameBoard:CheckForMoves()
        return
    end

    if cmd[1] == 'm' and cmd[2] ~= '' and cmd[3] ~= '' and cmd[4] ~= '' then
        local inputError = false
        local x = tonumber(cmd[2])
        local y = tonumber(cmd[3])
        local direction = cmd[4]
        if x < 0 or x > boardSize - 1 or y < 0 or y > boardSize - 1 or (direction ~= 'l' and direction ~= 'r' and direction ~= 'u' and direction ~= 'd') then
            inputError = true
        end

        local from = {}
        local to = {}
        from.y = y
        from.x = x

        local moveError = false

        if direction == 'l' then
            if x - 1 < 0 then
                moveError = true
            end
            if x - 1 >= 0 then
                to.x = x - 1
                to.y = y
            end
        end

        if direction == 'r' then
            if x + 1 > boardSize - 1 then
                moveError = true
            end
            if x + 1 <= boardSize - 1 then
                to.x = x + 1
                to.y = y
            end
        end

        if direction == 'u' then
            if y - 1 < 0 then
                moveError = true
            end
            if y - 1 >= 0 then
                to.x = x
                to.y = y - 1
            end
        end

        if direction == 'd' then
            if y + 1 > boardSize - 1 then
                moveError = true
            end
            if y + 1 <= boardSize - 1 then
                to.x = x
                to.y = y + 1
            end
        end

        if inputError == false and moveError == false then
            local moveResult = gameBoard:TestMoveGem(from, to)
            if moveResult == 1 then
                gameBoard:Move(from, to)
                gameBoard:Tick()
            else
                io.write('Error move\n')
                gameBoard:Dump()
                gameBoard:CheckForMoves()
            end
        else
            if inputError == true then
                io.write('Invalid move! Please use "m x y dir" (dir: l, r, u, d).\n')
            end
            if moveError == true then
                io.write('Cannot move gem out of the board!\n')
            end
            gameBoard:CheckForMoves()
        end

        return
    end

    io.write('Unknown command! Please use "m x y dir" (dir: l, r, u, d), "mix" to shuffle, or "q" to quit.\n')
    gameBoard:CheckForMoves()
end
