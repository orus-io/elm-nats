module Nats
    exposing
        ( State
        , Msg
        , init
        , setAuthToken
        , setUserPass
        , setName
        , update
        , listen
        , publish
        , subscribe
        , queuesubscribe
        , request
        , requestWithTimeout
        , merge
        )

{-| This library provides a pure elm implementation of the NATS client
protocol on top of WebSocket.

The NATS server does not support websocket natively, so a NATS/websocket
proxy must be used. The only compatible one is
<https://github.com/orus-io/nats-websocket-gw>


# Types

@docs State, Msg


# Operations

@docs subscribe, queuesubscribe, publish, request, requestWithTimeout


# TEA entry points

@docs init, update, merge, listen


# Settings

@docs setAuthToken, setUserPass, setName

-}

import Debug
import WebSocket
import Dict exposing (Dict)
import Time exposing (Time)
import Random
import Random.Char
import Random.String
import Task
import Nats.Protocol as Protocol
import Nats.Cmd as NatsCmd
import Nats.Sub as NatsSub
import Nats.Errors exposing (Timeout)


defaultTimeout : Time
defaultTimeout =
    30 * Time.second


defaultConnectOptions : Protocol.ConnectOptions
defaultConnectOptions =
    { verbose = False
    , pedantic = False

    -- , ssl_required: Indicates whether the client requires an SSL connection.
    , auth_token = Nothing
    , user = Nothing
    , pass = Nothing
    , name = Nothing
    , lang = "elm"
    , version = "1.0.0"
    , protocol = 0
    }


{-| Type of message the update function takes
-}
type Msg
    = Receive Protocol.Operation
    | ReceptionError String
    | RequestInbox ( String, String ) String String
    | RequestResponse Sid Protocol.Message
    | RequestTimeout Sid Time


type alias Sid =
    String


{-| A NATS subscription
-}
type alias Subscription msg =
    { subject : String
    , tag : String
    , queueGroup : String
    , sid : Sid
    , tagger : Protocol.Message -> msg
    }


type alias Request msg =
    { inbox : String
    , timeout : Time
    , sid : Sid
    , tagger : Result Timeout Protocol.Message -> msg
    }


{-| The NATS state to add to the application model (once)
-}
type alias State msg =
    { url : String
    , tagger : Msg -> msg
    , connectOptions : Protocol.ConnectOptions
    , sidCounter : Int
    , subscriptions : Dict Sid (Subscription msg)
    , requests : Dict Sid (Request msg)
    , serverInfo : Maybe Protocol.ServerInfo
    , inboxPrefix : String
    , debug : Bool
    }


log : State msg -> String -> a -> a
log state msg value =
    if state.debug then
        Debug.log msg value
    else
        value


receive : State msg -> (Msg -> msg) -> Result String Protocol.Operation -> msg
receive state tagger operation =
    case operation of
        Err err ->
            tagger <| ReceptionError err

        Ok operation ->
            case operation of
                Protocol.MSG sid natsMsg ->
                    case Dict.get sid state.subscriptions of
                        Just sub ->
                            sub.tagger natsMsg

                        Nothing ->
                            case Dict.get sid state.requests of
                                Just req ->
                                    tagger <| RequestResponse sid natsMsg

                                Nothing ->
                                    tagger <| Receive operation

                _ ->
                    tagger <| Receive operation


{-| Creates a Sub for the whole applications
It takes a list of all the active subscriptions from all the application
parts, which are used to tag the WebSocket message into the message
type each component need.
-}
listen : State msg -> Sub msg
listen state =
    Sub.batch <|
        [ WebSocket.listen
            state.url
            (log state "Receiving" >> Protocol.parseOperation >> receive state state.tagger)
        ]
            ++ (List.map
                    (\req ->
                        RequestTimeout req.sid |> Time.every req.timeout |> Sub.map state.tagger
                    )
                <|
                    Dict.values state.requests
               )


{-| Initialize a Nats State for a given websocket URL
-}
init : (Msg -> msg) -> String -> State msg
init tagger url =
    { url = url
    , tagger = tagger
    , connectOptions = defaultConnectOptions
    , sidCounter = 0
    , subscriptions = Dict.empty
    , requests = Dict.empty
    , serverInfo = Nothing
    , inboxPrefix = "_INBOX."
    , debug = False
    }


{-| Set the auth_token connect option. Will be sent to the server each time
'INFO' is received.

    init =
        { nats =
            Nats.init NatsMsg "ws://yourserver.com/nats"
                |> setAuthToken "YOUR_AUTH_TOKEN"
        }

-}
setAuthToken : String -> State msg -> State msg
setAuthToken auth_token state =
    let
        connectOptions =
            state.connectOptions
    in
        { state
            | connectOptions = { connectOptions | auth_token = Just auth_token }
        }


{-| Set the user and pass connect options. Will be sent to the server each time
'INFO' is received.

    init =
        { nats =
            Nats.init NatsMsg "ws://yourserver.com/nats"
                |> setUserPass "username" "password"
        }

-}
setUserPass : String -> String -> State msg -> State msg
setUserPass user pass state =
    let
        connectOptions =
            state.connectOptions
    in
        { state
            | connectOptions =
                { connectOptions
                    | user = Just user
                    , pass = Just pass
                }
        }


{-| Set the name connect option. Will be sent to the server each time
'INFO' is received.

    init =
        { nats =
            Nats.init NatsMsg "ws://yourserver.com/nats"
                |> setName "clientname"
        }

-}
setName : String -> State msg -> State msg
setName name state =
    let
        connectOptions =
            state.connectOptions
    in
        { state
            | connectOptions = { connectOptions | name = Just name }
        }


send : State msg -> Protocol.Operation -> Cmd Msg
send state op =
    Protocol.toString op |> log state "Sending" |> WebSocket.send state.url


sendAll : State msg -> List Protocol.Operation -> Cmd Msg
sendAll state ops =
    (String.join "" <|
        List.map Protocol.toString ops
    )
        |> log state "Sending"
        |> WebSocket.send state.url


sendMsg : msg -> Cmd msg
sendMsg msg =
    Task.perform identity <| Task.succeed msg


{-| The update function
Will make sure PING commands from the server are honored with a PONG,
-}
update : Msg -> State msg -> ( State msg, Cmd msg )
update msg state =
    case msg of
        Receive op ->
            case op of
                Protocol.PING ->
                    state ! [ Cmd.map state.tagger <| send state Protocol.PONG ]

                Protocol.INFO serverInfo ->
                    -- A (re)connection. Update the server info, send CONNECT
                    -- and reinitialize all the subscriptions
                    { state | serverInfo = Just serverInfo }
                        ! [ Cmd.map state.tagger <|
                                sendAll state <|
                                    List.concat
                                        [ [ Protocol.CONNECT state.connectOptions ]
                                        , List.map
                                            (\sub ->
                                                Protocol.SUB sub.subject sub.queueGroup sub.sid
                                            )
                                          <|
                                            Dict.values state.subscriptions
                                        , List.map
                                            (\req ->
                                                Protocol.SUB req.inbox "" req.sid
                                            )
                                          <|
                                            Dict.values state.requests
                                        ]
                          ]

                _ ->
                    state ! []

        ReceptionError err ->
            state ! []

        RequestInbox ( subject, data ) sid inboxSuffix ->
            case Dict.get sid state.requests of
                Just req ->
                    let
                        newReq =
                            { req
                                | inbox = state.inboxPrefix ++ inboxSuffix
                            }
                    in
                        { state
                            | requests = Dict.insert sid newReq state.requests
                        }
                            ! [ Cmd.map state.tagger <|
                                    sendAll state
                                        [ Protocol.SUB newReq.inbox "" newReq.sid
                                        , Protocol.PUB
                                            { subject = subject
                                            , replyTo = newReq.inbox
                                            , data = data
                                            }
                                        ]
                              ]

                Nothing ->
                    -- TODO report an error somehow ? crash the app ?
                    state ! []

        RequestResponse sid natsMsg ->
            case Dict.get sid state.requests of
                Just req ->
                    { state
                        | requests = Dict.remove sid state.requests
                    }
                        ! [ sendMsg <| req.tagger (Ok natsMsg) ]

                Nothing ->
                    state ! []

        RequestTimeout sid time ->
            case Dict.get sid state.requests of
                Just req ->
                    { state
                        | requests = Dict.remove sid state.requests
                    }
                        ! [ sendMsg <| req.tagger (Err time) ]

                Nothing ->
                    state ! []


splitSubject : String -> ( String, String )
splitSubject s =
    let
        sp =
            String.split "#" s
    in
        ( Maybe.withDefault "" (List.head sp)
        , Maybe.withDefault "" (List.head <| Maybe.withDefault [] <| List.tail sp)
        )


initSubscription : String -> String -> (Protocol.Message -> msg) -> Subscription msg
initSubscription subject queueGroup tagger =
    let
        ( cleanSubject, tag ) =
            splitSubject subject
    in
        { subject = cleanSubject
        , tag = tag
        , queueGroup = queueGroup
        , sid = ""
        , tagger = tagger
        }


initRequest : Time -> (Result Timeout Protocol.Message -> msg) -> Request msg
initRequest timeout tagger =
    { inbox = ""
    , timeout = timeout
    , sid = ""
    , tagger = tagger
    }


{-| a basic nats subscription
-}
subscribe : String -> (Protocol.Message -> msg) -> NatsSub.Sub msg
subscribe subject tagger =
    NatsSub.Subscribe subject "" tagger


{-| a queue nats subscription
-}
queuesubscribe : String -> String -> (Protocol.Message -> msg) -> NatsSub.Sub msg
queuesubscribe subject queueGroup tagger =
    NatsSub.Subscribe subject queueGroup tagger


applyNatsSub : State msg -> NatsSub.Sub msg -> ( List String, State msg, List (Cmd Msg) )
applyNatsSub state sub =
    -- for each sub, check if it already exists. If not, add it and send a SUB
    -- return updated state and a list of sid
    case sub of
        NatsSub.None ->
            ( [], state, [] )

        NatsSub.BatchSub list ->
            List.foldl
                (\sub ( sids, state, cmds ) ->
                    let
                        ( nSids, nState, nCmds ) =
                            applyNatsSub state sub
                    in
                        ( sids ++ nSids, nState, cmds ++ nCmds )
                )
                ( [], state, [] )
                list

        NatsSub.Subscribe subject queueGroup tagger ->
            let
                ( cleanSubject, tag ) =
                    splitSubject subject
            in
                case
                    List.head <|
                        List.filter
                            (\sub ->
                                sub.subject == cleanSubject && sub.queueGroup == queueGroup && sub.tag == tag
                            )
                            (Dict.values state.subscriptions)
                of
                    Just sub ->
                        ( [ sub.sid ], state, [] )

                    Nothing ->
                        let
                            ( nSub, nState, cmd ) =
                                initSubscription subject queueGroup tagger
                                    |> setupSubscription state
                        in
                            ( [ nSub.sid ], nState, [ cmd ] )


cleanSubs : State msg -> List String -> ( State msg, List (Cmd Msg) )
cleanSubs state sids =
    let
        ( keep, remove ) =
            Dict.partition
                (\sid v ->
                    List.member sid sids
                )
                state.subscriptions
    in
        ( { state
            | subscriptions = keep
          }
        , List.map ((flip Protocol.UNSUB) 0 >> send state) <| Dict.keys remove
        )


mergeNatsSub : State msg -> NatsSub.Sub msg -> ( State msg, Cmd Msg )
mergeNatsSub state sub =
    -- apply the sub
    -- for each establish sub without an incoming sub, delete it and send a UNSUB
    let
        ( sids, nState, subCmds ) =
            applyNatsSub state sub

        ( finalState, unsubCmds ) =
            cleanSubs nState sids
    in
        ( finalState, Cmd.batch (subCmds ++ unsubCmds) )


{-| Apply NatsCmd in the Nats State and return somd actual Cmd
-}
mergeNatsCmd : State msg -> NatsCmd.Cmd msg -> ( State msg, Cmd Msg )
mergeNatsCmd state cmd =
    case cmd of
        NatsCmd.Publish subject data ->
            state
                ! [ send state <|
                        Protocol.PUB
                            { subject = subject
                            , replyTo = ""
                            , data = data
                            }
                  ]

        NatsCmd.Request timeout subject data tagger ->
            -- prepare a subject-less subscription
            -- get a random id
            let
                ( req, newState ) =
                    setupRequest state <| initRequest timeout tagger
            in
                newState
                    ! [ Random.generate (RequestInbox ( subject, data ) req.sid) <|
                            Random.String.string 12 Random.Char.latin
                      ]

        NatsCmd.Batch natsCmds ->
            let
                folder natsCmd ( state, cmds ) =
                    let
                        ( newState, cmd ) =
                            mergeNatsCmd state natsCmd
                    in
                        ( newState, cmd :: cmds )

                ( newState, cmds ) =
                    List.foldl folder ( state, [] ) natsCmds
            in
                newState ! cmds

        NatsCmd.None ->
            state ! []


{-| merges nats subscriptions and commands into a Nats State, and returns
a Cmd Msg for side effects.
-}
merge : State msg -> NatsSub.Sub msg -> NatsCmd.Cmd msg -> ( State msg, Cmd msg )
merge state sub cmd =
    let
        ( subState, subCmd ) =
            mergeNatsSub state sub

        ( cmdState, cmdCmd ) =
            mergeNatsCmd subState cmd
    in
        ( cmdState, Cmd.map state.tagger <| Cmd.batch [ subCmd, cmdCmd ] )


{-| Add a subscription to the State
-}
setupSubscription : State msg -> Subscription msg -> ( Subscription msg, State msg, Cmd Msg )
setupSubscription state subscription =
    let
        sub : Subscription msg
        sub =
            { subscription
                | sid = toString state.sidCounter
            }
    in
        ( sub
        , { state
            | sidCounter = state.sidCounter + 1
            , subscriptions = Dict.insert sub.sid sub state.subscriptions
          }
        , send state <| Protocol.SUB sub.subject sub.queueGroup sub.sid
        )


setupRequest : State msg -> Request msg -> ( Request msg, State msg )
setupRequest state request =
    let
        req : Request msg
        req =
            { request
                | sid = toString state.sidCounter
            }
    in
        ( req
        , { state
            | sidCounter = state.sidCounter + 1
            , requests = Dict.insert req.sid req state.requests
          }
        )


{-| Publish a message on a subject
-}
publish : String -> String -> NatsCmd.Cmd msg
publish subject data =
    NatsCmd.Publish subject data


{-| Send a request
-}
request : String -> String -> (Result Timeout Protocol.Message -> msg) -> NatsCmd.Cmd msg
request =
    NatsCmd.Request defaultTimeout


{-| Send a request with a custom timeout
-}
requestWithTimeout : Time -> String -> String -> (Result Timeout Protocol.Message -> msg) -> NatsCmd.Cmd msg
requestWithTimeout =
    NatsCmd.Request
