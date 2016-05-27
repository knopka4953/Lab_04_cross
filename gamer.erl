-module(gamer).
-export([main/1, printField/1, getSymbol/1, makeTurn/2, startGame/0]).

getSymbol(TurnType) ->
    case TurnType of
        -1 -> " ";
        0  -> "O";
        1  -> "X"
    end.

printField(Field) ->
    {_, A1, A2, A3} = lists:keyfind(a, 1, Field),
    {_, B1, B2, B3} = lists:keyfind(b, 1, Field),
    {_, C1, C2, C3} = lists:keyfind(c, 1, Field),    
    io:format("     1   2   3 ~n    --- --- --- ~nA  | ~s | ~s | ~s | ~n    --- --- --- ~nB  | ~s | ~s | ~s | ~n    --- --- --- ~nC  | ~s | ~s | ~s | ~n    --- --- --- ~n~n", [getSymbol(A1), getSymbol(A2), getSymbol(A3), getSymbol(B1), getSymbol(B2), getSymbol(B3), getSymbol(C1), getSymbol(C2), getSymbol(C3)]).
        
        
 
main(RoomPID) ->
    receive 
        {makeTurn, Turn} ->
            RoomPID ! {turn, self(), Turn},
            main(RoomPID);
        {gameOver, X, Field} ->
            printField(Field),
            if X == winner ->
                    io:format("Event: Game over! You are the winner!");
               X == loser ->
                    io:format("Event: Game over! You are the loser!");
               true ->
                   io:format("Event: Game over!")
            end;          
        {inGame_first, R_PID, Field} -> 
            printField(Field),
            io:format("Event: You are the first gamer! Please, wait for a second gamer. ~n"),
            main(R_PID);
        {inGame_second, R_PID, Field} ->
            printField(Field),
            io:format("Event: You are the second gamer! Game is started! ~nPlease, wait for a turn of the first gamer. ~n"), 
            main(R_PID);
        {error_roomIsFull} ->
            io:format("Event: Error! There are no space in the Room anymore! ~n");
        {error_notInGame} ->
            io:format("Event: Error! You are not in the GamerList if this Room, so you can't send a message to it! ~n");
        {gameStart} ->
            io:format("Event: Now there is you turn! Use the command \"makeTurn(MyGamerpID, {Letter, Digit})\" to make you turn.~n"), 
            main(RoomPID);
        {wait, Field} ->
            printField(Field),
            io:format("Event: Please, wait for a turn of opponent. ~n"),
            main(RoomPID); 
        {nextTurn, Field} ->
            printField(Field),
            io:format("Event: Now there is you turn! Use the command \"makeTurn(MyGamerpID, {Letter, Digit})\" to make you turn.~n"), 
            main(RoomPID)
    end.
    
makeTurn(MyGamerPID, Turn) -> 
       MyGamerPID ! {makeTurn, Turn}.
       
startGame() ->
    GamerPID = spawn(gamer, main, [null]),
    global:send(cross_server, {wantToPlay, self(), GamerPID}),
    receive
        {inGameSuccess} ->
            GamerPID
    end.

    