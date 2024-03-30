-- main.lua

dofile("game_model.lua")
dofile("game_visualization.lua")

Init()
while true do
    io.write("Command: ")
    local cmd = io.read()
    local split = {}
    for word in cmd:gmatch("%w+") do table.insert(split, word) end
    if split[1] == "mix" and gameBoard:AvaliableMoves() == 0 then
        ExecCommand(split)
    elseif split[1] == "mix" and gameBoard:AvaliableMoves() > 0 then
        io.write("Cannot mix while there are available moves.\n")
    else
        ExecCommand(split)
    end
end
