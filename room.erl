-module(room).
-export([main/2, check/1, length2/1]).

length2([]) -> 0;
length2([Head | Tail]) -> 1 + length2(Tail).

main(Gamers, Field) ->
    receive
        {closeRoom} ->
            ok;
        {connect, GamerPID} -> 
            Len = length(Gamers),          
            if Len == 0 -> 
                    GamerPID ! {inGame_first, self(), Field},  
                    NewGamers = Gamers ++ [{1, GamerPID}],                 
                    main(NewGamers, Field);
                Len == 1 ->                                      
                    NewGamers = Gamers ++ [{2, GamerPID}],   
                    {_, GamerFirst} = lists:nth(1, Gamers),
                    GamerPID ! {inGame_second, self(), Field},  
                    GamerFirst ! {gameStart},              
                    main(NewGamers, Field);
                true ->
                    GamerPID ! {error_roomIsFull},
                    main(Gamers, Field)              
            end;
        {turn, GamerPID, Turn} ->
            {_, PID1} = lists:nth(1, Gamers),
            {_, PID2} = lists:nth(2, Gamers),
            %io:format("Hello!"),
            if GamerPID == PID1 ->
                    TurnType = 1;
                GamerPID == PID2 ->
                    TurnType = 0;
                true ->
                    TurnType = -1,
                    GamerPID ! {error_notInGame}
            end,
            case Turn of
                {a, 1} ->
                    {_, V1, V2, V3} = lists:keyfind(a, 1, Field),
                    if 
                        V1 == -1 ->
                            sendGameMessage(lists:keyreplace(a, 1, Field, {a, TurnType, V2, V3}), GamerPID, PID2),
                            main(Gamers, lists:keyreplace(a, 1, Field, {a, TurnType, V2, V3}));                               
                        true -> 
                            GamerPID ! {error_incorrectTurn},
                            main(Gamers, Field)
                    end;
                {a, 2} ->
                    {_, V1, V2, V3} = lists:keyfind(a, 1, Field),
                    if 
                        V2 == -1 ->
                            sendGameMessage(lists:keyreplace(a, 1, Field, {a, V1, TurnType, V3}), GamerPID, PID2),
                            main(Gamers, lists:keyreplace(a, 1, Field, {a, V1, TurnType, V3}));     
                        true -> 
                            GamerPID ! {error_incorrectTurn},
                            main(Gamers, Field)
                    end;
                {a, 3} ->
                    {_, V1, V2, V3} = lists:keyfind(a, 1, Field),
                    if 
                        V3 == -1 ->
                            sendGameMessage(lists:keyreplace(a, 1, Field, {a, V1, V2, TurnType}), GamerPID, PID2),
                            main(Gamers, lists:keyreplace(a, 1, Field, {a, V1, V2, TurnType}));    
                        true -> 
                            GamerPID ! {error_incorrectTurn},
                            main(Gamers, Field)
                    end;
                {b, 1} ->
                    {_, V1, V2, V3} = lists:keyfind(b, 1, Field),
                    if 
                        V1 == -1 ->
                            sendGameMessage(lists:keyreplace(b, 1, Field, {b, TurnType, V2, V3}), GamerPID, PID2),
                            main(Gamers, lists:keyreplace(b, 1, Field, {b, TurnType, V2, V3}));    
                        true -> 
                            GamerPID ! {error_incorrectTurn},
                            main(Gamers, Field)
                    end;
                {b, 2} ->
                    {_, V1, V2, V3} = lists:keyfind(b, 1, Field),
                    %io:format("Hello!"),
                    if 
                        V2 == -1 ->
                            sendGameMessage(lists:keyreplace(b, 1, Field, {b, V1, TurnType, V3}), GamerPID, PID2),
                            main(Gamers, lists:keyreplace(b, 1, Field, {b, V1, TurnType, V3}));   
                        true -> 
                            GamerPID ! {error_incorrectTurn},
                            main(Gamers, Field)
                    end;
                {b, 3} ->
                    {_, V1, V2, V3} = lists:keyfind(b, 1, Field),
                    if 
                        V3 == -1 ->
                            sendGameMessage(lists:keyreplace(b, 1, Field, {b, V1, V2, TurnType}), GamerPID, PID2),
                            main(Gamers, lists:keyreplace(b, 1, Field, {b, V1, V2, TurnType})); 
                        true -> 
                            GamerPID ! {error_incorrectTurn},
                            main(Gamers, Field)
                    end;
                {c, 1} ->
                    {_, V1, V2, V3} = lists:keyfind(c, 1, Field),
                    if 
                        V1 == -1 ->
                            sendGameMessage(lists:keyreplace(c, 1, Field, {c, TurnType, V2, V3}), GamerPID, PID2),
                            main(Gamers, lists:keyreplace(c, 1, Field, {c, TurnType, V2, V3}));
                        true -> 
                            GamerPID ! {error_incorrectTurn},
                            main(Gamers, Field)
                    end;
                {c, 2} ->
                    {_, V1, V2, V3} = lists:keyfind(c, 1, Field),
                    if 
                        V2 == -1 ->
                            sendGameMessage(lists:keyreplace(c, 1, Field, {c, V1, TurnType, V3}), GamerPID, PID2),
                            %io:format("Hello 2!"),
                            main(Gamers, lists:keyreplace(c, 1, Field, {c, V1, TurnType, V3}));
                        true -> 
                            GamerPID ! {error_incorrectTurn},
                            main(Gamers, Field)
                    end;
                {c, 3} ->
                    {_, V1, V2, V3} = lists:keyfind(c, 1, Field),
                    if 
                        V3 == -1 ->
                            sendGameMessage(lists:keyreplace(c, 1, Field, {c, V1, V2, TurnType}), GamerPID, PID2),
                            main(Gamers, lists:keyreplace(c, 1, Field, {c, V1, V2, TurnType}));
                        true -> 
                            GamerPID ! {error_incorrectTurn},
                            main(Gamers, Field)
                    end
            end
    end.
    
    
check(Field) ->
    {_, A1, A2, A3} = lists:keyfind(a, 1, Field),
    {_, B1, B2, B3} = lists:keyfind(b, 1, Field),
    {_, C1, C2, C3} = lists:keyfind(c, 1, Field),
    if 
        A1 /= -1, A1 == A2, A2 == A3 -> true;
        B1 /= -1, B1 == B2, B2 == B3 -> true;
        C1 /= -1, C1 == C2, C2 == C3 -> true;
        A1 /= -1, A1 == B1, B1 == C1 -> true;
        A2 /= -1, A2 == B2, B2 == C2 -> true;
        A3 /= -1, A3 == B3, B3 == C3 -> true;
        A1 /= -1, A1 == B2, B2 == C3 -> true;
        A3 /= -1, A3 == B2, B2 == C1 -> true;
        true -> false
    end.
    

sendGameMessage(Field, G1_PID, G2_PID) ->
    case check(Field) of
        true -> 
            G1_PID ! {gameOver, winner, Field},
            G2_PID ! {gameOver, loser, Field};
        false ->
            %io:format("Hello!"),
            G1_PID ! {wait, Field},
            G2_PID ! {nextTurn, Field}                                    
    end.
    