module Nats.Internal.SocketStateCollection exposing
    ( SocketStateCollection
    , empty
    , findByID
    , fromList
    , insert
    , mapWithEffect
    , removeByID
    , toList
    , update
    )

import Nats.Internal.Ports as Ports
import Nats.Internal.SocketState as SocketState exposing (SocketState)
import Nats.Internal.Types exposing (Config)


type SocketStateCollection datatype msg
    = SocketStateCollection (List (SocketState datatype msg))


empty : SocketStateCollection datatype msg
empty =
    SocketStateCollection []


toList : SocketStateCollection datatype msg -> List (SocketState datatype msg)
toList (SocketStateCollection list) =
    list


fromList : List (SocketState datatype msg) -> SocketStateCollection datatype msg
fromList =
    SocketStateCollection


findByID : String -> SocketStateCollection datatype msg -> Maybe (SocketState datatype msg)
findByID sid (SocketStateCollection list) =
    list
        |> List.filter
            (\{ socket } ->
                socket.id == sid
            )
        |> List.head


insert :
    SocketState datatype msg
    -> SocketStateCollection datatype msg
    -> SocketStateCollection datatype msg
insert socket (SocketStateCollection list) =
    list
        |> internalRemove socket.socket.id
        |> (::) socket
        |> SocketStateCollection


internalRemove : String -> List (SocketState datatype msg) -> List (SocketState datatype msg)
internalRemove sid =
    List.filter
        (\{ socket } ->
            socket.id /= sid
        )


removeByID : String -> SocketStateCollection datatype msg -> SocketStateCollection datatype msg
removeByID sid (SocketStateCollection list) =
    internalRemove sid list
        |> SocketStateCollection


mapWithEffect :
    (SocketState datatype msg -> ( SocketState datatype msg, effect ))
    -> SocketStateCollection datatype msg
    -> ( SocketStateCollection datatype msg, List effect )
mapWithEffect fn (SocketStateCollection list) =
    List.foldr
        (\socket ( newList, effectList ) ->
            let
                ( newSocket, effect ) =
                    fn socket
            in
            ( newSocket :: newList, effect :: effectList )
        )
        ( [], [] )
        list
        |> Tuple.mapFirst SocketStateCollection


update :
    Config datatype portdatatype msg
    -> String
    -> SocketState.Msg datatype
    -> SocketStateCollection datatype msg
    -> ( SocketStateCollection datatype msg, ( List msg, List (Ports.Command portdatatype) ) )
update cfg sid msg collection =
    case findByID sid collection of
        Just state ->
            let
                ( newState, effect ) =
                    SocketState.update cfg msg state
            in
            ( insert newState collection, effect )

        Nothing ->
            ( collection, ( [], [] ) )
