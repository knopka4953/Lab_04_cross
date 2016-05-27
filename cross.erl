-module(cross).
-export([main/1, roomStart/0, serverStart/0]).

serverStart() ->
    PID = spawn(?MODULE, main, [[]]),
    global:register_name(cross_server, PID),
    PID.

roomStart() -> 
    spawn(room, main, [[], [{a, -1, -1, -1}, {b, -1, -1, -1}, {c, -1, -1, -1}]]).
    
main(Rooms) ->
    receive                        
        {wantToPlay, Console, GamerPID} -> 
            Len = length(Rooms),
            if Len == 0 ->
                   RoomPID = roomStart(), 
                   Console ! {inGameSuccess},
                   RoomPID ! {connect, GamerPID},
                   NewRooms = Rooms ++ [{RoomPID, 1}],
                   main(NewRooms);
               true ->
                   case lists:keyfind(1, 2, Rooms) of
                       {R, 1} ->                           
                            Console ! {inGameSuccess},
                            R ! {connect, GamerPID},
                            NewRooms = lists:keyreplace(R, 1, Rooms, {R, 2}),
                            main(NewRooms);
                       false ->
                            R2 = roomStart(),
                            Console ! {inGameSuccess},
                            R2 ! {connect, GamerPID},
                            NewRooms = Rooms ++ [{R2, 1}],
                            main(NewRooms)
                   end
             end
    end.