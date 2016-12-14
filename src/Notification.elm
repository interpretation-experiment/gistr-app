module Notification
    exposing
        ( Model
        , Msg(New)
        , Notification
        , ViewConfig
        , empty
        , new
        , update
        , view
        , viewConfig
        )

import Html
import Html.Attributes as Attributes
import List
import Process
import Task
import Time


-- CONFIG


config :
    { widthPx : Float
    , maxHeightPx : Float
    , enterDelay : Time.Time
    , enterDuration : Time.Time
    , dismissDuration : Time.Time
    }
config =
    { widthPx = 300
    , maxHeightPx = 500
    , enterDelay = Time.millisecond * 50
    , enterDuration = Time.millisecond * 500
    , dismissDuration = Time.millisecond * 700
    }



-- MODEL


type Model a
    = Model
        { notifications : List (DisplayedNotification a)
        , nextId : Int
        }


empty : Model a
empty =
    Model
        { notifications = []
        , nextId = 0
        }


type alias DisplayedNotification a =
    { id : Int
    , content : a
    , style : List ( String, String )
    }


type Notification a
    = Notification
        { content : a
        , duration : Maybe Time.Time
        }


new : a -> Maybe Time.Time -> Notification a
new content maybeDuration =
    Notification
        { content = content
        , duration = maybeDuration
        }


create : Int -> Notification a -> ( DisplayedNotification a, Cmd (Msg a) )
create id (Notification specs) =
    let
        autoDismiss =
            case specs.duration of
                Nothing ->
                    Cmd.none

                Just duration ->
                    delayMsg (Dismiss id) <|
                        config.enterDelay
                            + config.enterDuration
                            + duration
    in
        ( { id = id
          , content = specs.content
          , style = styleCreate
          }
        , Cmd.batch
            [ delayMsg (Enter id) config.enterDelay
            , autoDismiss
            ]
        )



-- UPDATE


type Msg a
    = New (Notification a)
    | Enter Int
    | Dismiss Int
    | Remove Int


update : (Msg a -> msg) -> Msg a -> Model a -> ( Model a, Cmd msg )
update lift msg (Model model) =
    case msg of
        New specs ->
            let
                ( newNotification, cmds ) =
                    create model.nextId specs
            in
                ( Model
                    { model
                        | notifications = model.notifications ++ [ newNotification ]
                        , nextId = model.nextId + 1
                    }
                , Cmd.map lift cmds
                )

        Enter id ->
            let
                enter id notification =
                    if notification.id == id then
                        { notification | style = styleEnter }
                    else
                        notification
            in
                ( Model { model | notifications = List.map (enter id) model.notifications }
                , Cmd.none
                )

        Dismiss id ->
            let
                dismiss id notification =
                    if notification.id == id then
                        { notification | style = styleDismiss }
                    else
                        notification
            in
                ( Model { model | notifications = List.map (dismiss id) model.notifications }
                , delayMsg (lift <| Remove id) config.dismissDuration
                )

        Remove id ->
            let
                notifications =
                    List.filter (\n -> n.id /= id) model.notifications
            in
                ( Model { model | notifications = notifications }
                , Cmd.none
                )


delayMsg : msg -> Time.Time -> Cmd msg
delayMsg msg delay =
    Task.perform (\_ -> msg) (Process.sleep delay)



-- DISPLAY STYLES


styleCreate : List ( String, String )
styleCreate =
    [ ( "opacity", "1" )
    , ( "max-height", toString config.maxHeightPx ++ "px" )
    , ( "transform", "translate(" ++ toString (config.widthPx + 200) ++ "px, 0px)" )
    ]


styleEnter : List ( String, String )
styleEnter =
    [ ( "opacity", "1" )
    , ( "max-height", toString config.maxHeightPx ++ "px" )
    , ( "transform", "translate(0px, 0px)" )
    , ( "transition"
      , "transform " ++ toString (Time.inSeconds config.enterDuration) ++ "s ease"
      )
    ]


styleDismiss : List ( String, String )
styleDismiss =
    [ ( "opacity", "0" )
    , ( "max-height", "0px" )
    , ( "transform", "translate(0px, 0px)" )
    , ( "transition"
      , "opacity "
            ++ toString (Time.inSeconds config.dismissDuration)
            ++ "s ease"
            ++ ", max-height "
            ++ toString (Time.inSeconds config.dismissDuration)
            ++ "s ease"
      )
    ]



-- VIEW


type ViewConfig a msg
    = ViewConfig
        { liftMsg : Msg a -> msg
        , template : a -> msg -> Html.Html msg
        }


viewConfig :
    (Msg a -> msg)
    -> (a -> msg -> Html.Html msg)
    -> ViewConfig a msg
viewConfig liftMsg template =
    ViewConfig
        { liftMsg = liftMsg
        , template = template
        }


view : ViewConfig a msg -> Model a -> Html.Html msg
view viewConfig (Model model) =
    Html.div
        [ Attributes.style
            [ ( "position", "absolute" )
            , ( "right", "0" )
            , ( "top", "10px" )
            , ( "bottom", "0" )
            , ( "padding-right", "20px" )
            , ( "width", toString config.widthPx ++ "px" )
            , ( "overflow", "hidden" )
            , ( "pointer-events", "none" )
            , ( "z-index", "999" )
            ]
        ]
        (List.map (notificationView viewConfig) model.notifications)


notificationView : ViewConfig a msg -> DisplayedNotification a -> Html.Html msg
notificationView (ViewConfig config) notification =
    Html.div
        [ Attributes.style <|
            [ ( "padding", "0.01px" ), ( "pointer-events", "auto" ) ]
                ++ notification.style
        ]
        [ config.template notification.content (config.liftMsg <| Dismiss notification.id) ]
