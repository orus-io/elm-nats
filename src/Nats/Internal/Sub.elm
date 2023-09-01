module Nats.Internal.Sub exposing
    ( RealSub(..)
    , Sub(..)
    , batch
    , connect
    , map
    , none
    , socket
    , subscribe
    , tag
    )

{-| A way of telling Nats : "Please subscribe to this subject and send
back messages to me".
-}

import Nats.Events exposing (SocketEvent)
import Nats.Protocol exposing (ConnectOptions, Message)
import Nats.Socket exposing (Socket)


type Sub datatype msg
    = Sub (List (RealSub datatype msg))


type RealSub datatype msg
    = Connect ConnectOptions Socket (SocketEvent -> msg)
    | Subscribe { sid : Maybe String, subject : String, group : String, onMessage : Message datatype -> msg }


connect :
    ConnectOptions
    -> Socket
    -> (SocketEvent -> msg)
    -> Sub datatype msg
connect options socket_ onEvent =
    Sub [ Connect options socket_ onEvent ]


subscribe :
    { sid : Maybe String, subject : String, group : String, onMessage : Message datatype -> msg }
    -> Sub datatype msg
subscribe props =
    Sub [ Subscribe props ]


sortPriority : RealSub datatype msg -> Int
sortPriority sub =
    case sub of
        Connect _ _ _ ->
            1

        Subscribe _ ->
            2


sort : List (RealSub datatype msg) -> List (RealSub datatype msg)
sort =
    List.sortBy sortPriority


{-| Batch several subscriptions
-}
batch : List (Sub datatype msg) -> Sub datatype msg
batch =
    -- A batch subscription is always flat and sorted so the 'Connect' are
    -- always handled first
    List.foldl
        (\(Sub l) ->
            List.append l
        )
        []
        >> sort
        >> Sub


{-| Map a Sub a to a Sub msg
-}
map : (a -> msg) -> Sub datatype a -> Sub datatype msg
map aToMsg (Sub sub) =
    sub
        |> List.map
            (\s ->
                case s of
                    Connect options sock onEvent ->
                        Connect options sock (onEvent >> aToMsg)

                    Subscribe { sid, subject, group, onMessage } ->
                        Subscribe
                            { sid = sid
                            , subject = subject
                            , group = group
                            , onMessage = onMessage >> aToMsg
                            }
            )
        |> Sub


tagSubject : String -> String -> String
tagSubject atag subject =
    case String.split "#" subject |> List.reverse of
        [] ->
            "#" ++ atag

        [ s ] ->
            s ++ "#" ++ atag

        t :: s ->
            (t ++ "_" ++ atag)
                :: s
                |> List.reverse
                |> String.join "#"


{-| Add a #tag to the subscription(s) subject
Id the subject already has a tag, the two are combined with a '\_' separator
-}
tag : String -> Sub datatype msg -> Sub datatype msg
tag atag sub =
    sub


{-| Set a different socket id on the subscription
-}
socket : String -> Sub datatype msg -> Sub datatype msg
socket sid (Sub sub) =
    sub
        |> List.map
            (\s ->
                case s of
                    Subscribe props ->
                        Subscribe { props | sid = Just sid }

                    any ->
                        any
            )
        |> Sub


{-| An null subscription
-}
none : Sub datatype msg
none =
    Sub []
