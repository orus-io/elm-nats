module Nats exposing
    ( State, Msg, SideEffect(..)
    , subscribe, queuesubscribe, requestSubscribe, publish, publishRequest, request, requestWithTimeout, onConnect, compile
    , init, update, merge, listen, handleNatsSideEffects, receive
    , setAuthToken, setUserPass, setName
    )

{-| This library provides a pure elm implementation of the NATS client
protocol on top of WebSocket.

The NATS server does not support websocket natively, so a NATS/websocket
proxy must be used. The only compatible one is
<https://github.com/orus-io/nats-websocket-gw>


# Types

@docs State, Msg, SideEffect


# Operations

@docs subscribe, queuesubscribe, requestSubscribe, publish, publishRequest, request, requestWithTimeout, onConnect, compile


# TEA entry points

@docs init, update, merge, listen, handleNatsSideEffects, receive


# Settings

@docs setAuthToken, setUserPass, setName

-}

import Cmd.Extra exposing (addCmd, addCmds, withCmd, withCmds)
import Debug
import Dict exposing (Dict)
import Nats.Cmd as NatsCmd
import Nats.Errors exposing (Timeout)
import Nats.Protocol as Protocol
import Nats.Sub as NatsSub
import Random
import Random.Char
import Random.String
import Task
import Time exposing (Posix)


defaultTimeout : Float
defaultTimeout =
    30


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
    | RequestSubscribeInbox String String
    | RequestTimeout Sid Posix


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
    , timeout : Float
    , sid : Sid
    , tagger : Result Timeout Protocol.Message -> msg
    }


type alias RequestSubscription msg =
    { subject : String
    , tag : String
    , request : String
    , inbox : String
    , timeout : Float
    , sid : Sid
    , tagger : Result Timeout Protocol.Message -> msg
    }


{-| The NATS state to add to the application model (once)
-}
type alias State msg =
    { url : String
    , tagger : Msg -> msg
    , onConnect : List (Protocol.ServerInfo -> msg)
    , connectOptions : Protocol.ConnectOptions
    , sidCounter : Int
    , subscriptions : Dict Sid (Subscription msg)
    , requests : Dict Sid (Request msg)
    , requestSubscriptions : Dict Sid (RequestSubscription msg)
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


receive : String -> Msg
receive message =
    case Protocol.parseOperation message of
        Err err ->
            ReceptionError err

        Ok op ->
            Receive op


listen : State msg -> Sub Msg
listen state =
    Dict.values state.requests
        |> List.map
            (\req ->
                RequestTimeout req.sid |> Time.every req.timeout
            )
        |> Sub.batch


{-| Initialize a Nats State for a given websocket URL
-}
init : (Msg -> msg) -> String -> State msg
init tagger url =
    { url = url
    , tagger = tagger
    , onConnect = []
    , connectOptions = defaultConnectOptions
    , sidCounter = 0
    , subscriptions = Dict.empty
    , requests = Dict.empty
    , requestSubscriptions = Dict.empty
    , serverInfo = Nothing
    , inboxPrefix = "_INBOX."
    , debug = False
    }


{-| Set the auth\_token connect option. Will be sent to the server each time
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


compile : Protocol.Operation -> String
compile op =
    Protocol.toString op


type SideEffect msg
    = AppCmd (Cmd Msg)
    | AppMsg msg
    | NatsOp Protocol.Operation


{-| The update function
Will make sure PING commands from the server are honored with a PONG,
-}
update : Msg -> State msg -> ( State msg, List (SideEffect msg) )
update msg state =
    case msg of
        Receive op ->
            case op of
                Protocol.PING ->
                    ( state
                    , [ NatsOp Protocol.PONG ]
                    )

                Protocol.INFO serverInfo ->
                    -- A (re)connection. Update the server info, send CONNECT
                    -- and reinitialize all the subscriptions
                    ( { state | serverInfo = Just serverInfo }
                    , List.concat
                        [ List.map NatsOp <|
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
                        , List.map (\x -> x serverInfo |> AppMsg) state.onConnect
                        ]
                    )

                Protocol.MSG sid natsMsg ->
                    case
                        ( Dict.get sid state.subscriptions
                        , Dict.get sid state.requestSubscriptions
                        , Dict.get sid state.requests
                        )
                    of
                        ( Just sub, _, _ ) ->
                            ( state, [ AppMsg <| sub.tagger natsMsg ] )

                        ( _, Just rsub, _ ) ->
                            -- TODO detect EOS and UNSUB the corresponding sub
                            ( state, [ AppMsg <| rsub.tagger (Ok natsMsg) ] )

                        ( _, _, Just req ) ->
                            ( { state
                                | requests = Dict.remove sid state.requests
                              }
                            , [ AppMsg <| req.tagger (Ok natsMsg) ]
                            )

                        _ ->
                            ( state, [] )

                _ ->
                    ( state
                    , []
                    )

        ReceptionError err ->
            ( state
            , []
            )

        RequestInbox ( subject, data ) sid inboxSuffix ->
            case Dict.get sid state.requests of
                Just req ->
                    let
                        newReq =
                            { req
                                | inbox = state.inboxPrefix ++ inboxSuffix
                            }
                    in
                    ( { state
                        | requests = Dict.insert sid newReq state.requests
                      }
                    , List.map NatsOp
                        [ Protocol.SUB newReq.inbox "" newReq.sid
                        , Protocol.PUB
                            { subject = subject
                            , replyTo = newReq.inbox
                            , data = data
                            }
                        ]
                    )

                Nothing ->
                    -- TODO report an error somehow ? crash the app ?
                    ( state
                    , []
                    )

        RequestSubscribeInbox sid inboxSuffix ->
            case Dict.get sid state.requestSubscriptions of
                Just rsub ->
                    let
                        newRSub =
                            { rsub
                                | inbox = state.inboxPrefix ++ inboxSuffix
                            }
                    in
                    ( { state
                        | requestSubscriptions = Dict.insert sid newRSub state.requestSubscriptions
                      }
                    , List.map NatsOp
                        [ Protocol.SUB newRSub.inbox "" newRSub.sid
                        , Protocol.PUB
                            { subject = newRSub.subject
                            , replyTo = newRSub.inbox
                            , data = newRSub.request
                            }
                        ]
                    )

                Nothing ->
                    ( state
                    , []
                    )

        RequestTimeout sid time ->
            case Dict.get sid state.requests of
                Just req ->
                    ( { state
                        | requests = Dict.remove sid state.requests
                      }
                    , [ AppMsg <| req.tagger (Err time) ]
                    )

                Nothing ->
                    ( state
                    , []
                    )


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


initRequest : Float -> (Result Timeout Protocol.Message -> msg) -> Request msg
initRequest timeout tagger =
    { inbox = ""
    , timeout = timeout
    , sid = ""
    , tagger = tagger
    }


initRequestSubscription :
    String
    -> String
    -> (Result Timeout Protocol.Message -> msg)
    -> RequestSubscription msg
initRequestSubscription subject req tagger =
    let
        ( cleanSubject, tag ) =
            splitSubject subject
    in
    { subject = cleanSubject
    , tag = tag
    , inbox = ""
    , timeout = defaultTimeout
    , request = req
    , sid = ""
    , tagger = tagger
    }


{-| subscribe to new connections
-}
onConnect : (Protocol.ServerInfo -> msg) -> NatsSub.Sub msg
onConnect tagger =
    NatsSub.OnConnect tagger


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


{-| A streamed reply subscription
Implements the "streamed reply" pattern from nrpc
-}
requestSubscribe :
    String
    -> String
    -> (Result Timeout Protocol.Message -> msg)
    -> NatsSub.Sub msg
requestSubscribe =
    NatsSub.RequestSubscribe


applyNatsSub : State msg -> NatsSub.Sub msg -> ( ( List String, List String ), State msg, List (SideEffect msg) )
applyNatsSub state natsSub =
    -- for each sub, check if it already exists. If not, add it and send a SUB
    -- return updated state and a list of sid
    case natsSub of
        NatsSub.None ->
            ( ( [], [] ), state, [] )

        NatsSub.OnConnect sub ->
            ( ( [], [] )
            , { state | onConnect = sub :: state.onConnect }
            , []
            )

        NatsSub.BatchSub list ->
            List.foldl
                (\sub ( ( sids, rsids ), fromState, cmds ) ->
                    let
                        ( ( nSids, nRsids ), nState, nCmds ) =
                            applyNatsSub fromState sub
                    in
                    ( ( sids ++ nSids, rsids ++ nRsids ), nState, cmds ++ nCmds )
                )
                ( ( [], [] ), state, [] )
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
                    ( ( [ sub.sid ], [] ), state, [] )

                Nothing ->
                    let
                        ( nSub, nState, cmd ) =
                            initSubscription subject queueGroup tagger
                                |> setupSubscription state
                    in
                    ( ( [ nSub.sid ], [] ), nState, [ cmd ] )

        NatsSub.RequestSubscribe subject req tagger ->
            let
                ( cleanSubject, tag ) =
                    splitSubject subject
            in
            case
                List.head <|
                    List.filter
                        (\sub ->
                            sub.subject == cleanSubject && sub.tag == tag
                        )
                        (Dict.values state.requestSubscriptions)
            of
                Just rsub ->
                    ( ( [], [ rsub.sid ] ), state, [] )

                Nothing ->
                    let
                        ( nRep, nState, sideEffects ) =
                            initRequestSubscription subject req tagger
                                |> setupRequestSubscription state
                    in
                    ( ( [], [ nRep.sid ] ), nState, sideEffects )


cleanSubs : State msg -> List String -> List String -> ( State msg, List (SideEffect msg) )
cleanSubs state sids rsids =
    let
        ( keep, remove ) =
            Dict.partition
                (\sid v ->
                    List.member sid sids
                )
                state.subscriptions

        ( rkeep, rremove ) =
            Dict.partition
                (\rsid v ->
                    List.member rsid rsids
                )
                state.requestSubscriptions
    in
    ( { state
        | subscriptions = keep
        , requestSubscriptions = rkeep
      }
    , List.concat
        [ List.map (\a -> Protocol.UNSUB a 0 |> NatsOp) <| Dict.keys remove
        , List.map (\a -> Protocol.UNSUB a 0 |> NatsOp) <| Dict.keys rremove
        ]
    )


mergeNatsSub : State msg -> NatsSub.Sub msg -> ( State msg, List (SideEffect msg) )
mergeNatsSub state sub =
    -- apply the sub
    -- for each establish sub without an incoming sub, delete it and send a UNSUB
    let
        ( ( sids, rsids ), nState, subCmds ) =
            applyNatsSub { state | onConnect = [] } sub

        ( finalState, unsubCmds ) =
            cleanSubs nState sids rsids
    in
    ( finalState, subCmds ++ unsubCmds )


{-| Apply NatsCmd in the Nats State and return side effects
-}
mergeNatsCmd : State msg -> NatsCmd.Cmd msg -> ( State msg, List (SideEffect msg) )
mergeNatsCmd state cmd =
    case cmd of
        NatsCmd.Publish subject replyTo data ->
            ( state
            , [ NatsOp <|
                    Protocol.PUB
                        { subject = subject
                        , replyTo = replyTo
                        , data = data
                        }
              ]
            )

        NatsCmd.Request timeout subject data tagger ->
            -- prepare a subject-less subscription
            -- get a random id
            let
                ( req, newState ) =
                    setupRequest state <| initRequest timeout tagger
            in
            ( newState
            , [ AppCmd
                    (Random.generate (RequestInbox ( subject, data ) req.sid) <|
                        Random.String.string 12 Random.Char.latin
                    )
              ]
            )

        NatsCmd.Batch natsCmds ->
            let
                folder natsCmd ( instate, inEffects ) =
                    let
                        ( s, effects ) =
                            mergeNatsCmd instate natsCmd
                    in
                    ( s, effects ++ inEffects )

                ( newState, sideEffects ) =
                    List.foldl folder ( state, [] ) natsCmds
            in
            ( newState
            , sideEffects
            )

        NatsCmd.None ->
            ( state
            , []
            )


{-| merges nats subscriptions and commands into a Nats State, and returns
side effects to apply
-}
merge : State msg -> NatsSub.Sub msg -> NatsCmd.Cmd msg -> ( State msg, List (SideEffect msg) )
merge state sub cmd =
    let
        ( subState, subEffects ) =
            mergeNatsSub state sub

        ( cmdState, cmdEffects ) =
            mergeNatsCmd subState cmd
    in
    ( cmdState, subEffects ++ cmdEffects )


{-| Add a subscription to the State
-}
setupSubscription : State msg -> Subscription msg -> ( Subscription msg, State msg, SideEffect msg )
setupSubscription state subscription =
    let
        sub : Subscription msg
        sub =
            { subscription
                | sid = String.fromInt state.sidCounter
            }
    in
    ( sub
    , { state
        | sidCounter = state.sidCounter + 1
        , subscriptions = Dict.insert sub.sid sub state.subscriptions
      }
    , NatsOp <| Protocol.SUB sub.subject sub.queueGroup sub.sid
    )


setupRequest : State msg -> Request msg -> ( Request msg, State msg )
setupRequest state baserequest =
    let
        req : Request msg
        req =
            { baserequest
                | sid = String.fromInt state.sidCounter
            }
    in
    ( req
    , { state
        | sidCounter = state.sidCounter + 1
        , requests = Dict.insert req.sid req state.requests
      }
    )


setupRequestSubscription : State msg -> RequestSubscription msg -> ( RequestSubscription msg, State msg, List (SideEffect msg) )
setupRequestSubscription state requestSubscription =
    let
        rsub : RequestSubscription msg
        rsub =
            { requestSubscription
                | sid = String.fromInt state.sidCounter
            }
    in
    ( rsub
    , { state
        | sidCounter = state.sidCounter + 1
        , requestSubscriptions = Dict.insert rsub.sid rsub state.requestSubscriptions
      }
    , [ AppCmd
            (Random.generate (RequestSubscribeInbox rsub.sid) <|
                Random.String.string 12 Random.Char.latin
            )
      ]
    )


{-| Publish a message on a subject
-}
publish : String -> String -> NatsCmd.Cmd msg
publish subject data =
    NatsCmd.Publish subject "" data


{-| Publish a message with a reply subject
-}
publishRequest : String -> String -> String -> NatsCmd.Cmd msg
publishRequest =
    NatsCmd.Publish


{-| Send a request
-}
request : String -> String -> (Result Timeout Protocol.Message -> msg) -> NatsCmd.Cmd msg
request =
    NatsCmd.Request defaultTimeout


{-| Send a request with a custom timeout
-}
requestWithTimeout : Float -> String -> String -> (Result Timeout Protocol.Message -> msg) -> NatsCmd.Cmd msg
requestWithTimeout =
    NatsCmd.Request


type alias AppConfig msg model =
    { update : msg -> model -> ( model, Cmd msg )
    , tagger : Msg -> msg
    , natsSend : String -> Cmd msg
    }


handleNatsSideEffect :
    AppConfig msg model
    -> SideEffect msg
    -> model
    -> ( model, Cmd msg )
handleNatsSideEffect config effect model =
    case effect of
        AppCmd cmd ->
            model
                |> withCmd (Cmd.map config.tagger cmd)

        AppMsg msg ->
            config.update msg model

        NatsOp op ->
            model
                |> withCmd
                    (compile op
                        |> config.natsSend
                    )


handleNatsSideEffects : AppConfig msg model -> List (SideEffect msg) -> model -> ( model, Cmd msg )
handleNatsSideEffects config effects model =
    List.foldl
        (\effect ( m, cmd ) ->
            handleNatsSideEffect config effect m
                |> addCmd cmd
        )
        ( model, Cmd.none )
        effects
