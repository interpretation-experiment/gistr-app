module Notification
    exposing
        ( Model
        , Msg(Notify, Animate)
        , Notification
        , ViewConfig
        , empty
        , notification
        , subscription
        , update
        , view
        , viewConfig
        )

import Animation
import Animation.Messenger as Messenger
import Html
import Html.Attributes as Attributes
import List
import Time


-- CONFIG


config : { widthPx : Float, maxHeightPx : Float }
config =
    { widthPx = 200
    , maxHeightPx = 500
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
    , display : Messenger.State (Msg a)
    }


type Notification a
    = Notification
        { content : a
        , duration : Maybe Time.Time
        }


notification : a -> Maybe Time.Time -> Notification a
notification content maybeDuration =
    Notification
        { content = content
        , duration = maybeDuration
        }


displayNotification : Int -> Notification a -> DisplayedNotification a
displayNotification id (Notification specs) =
    let
        disappearance =
            case specs.duration of
                Nothing ->
                    []

                Just duration ->
                    [ Animation.wait duration
                    , Messenger.send (Dismiss id)
                    ]
    in
        { id = id
        , content = specs.content
        , display =
            Animation.style
                [ Animation.opacity 1
                , Animation.translate (Animation.px (config.widthPx + 200)) (Animation.px 0)
                , Animation.custom "max-height" config.maxHeightPx "px"
                ]
                |> Animation.interrupt
                    ([ Animation.to
                        [ Animation.translate (Animation.px 0) (Animation.px 0) ]
                     ]
                        ++ disappearance
                    )
        }



-- UPDATE


type Msg a
    = Animate Animation.Msg
    | Notify (Notification a)
    | Dismiss Int
    | Remove Int


update : (Msg a -> msg) -> Msg a -> Model a -> ( Model a, Cmd msg )
update lift msg (Model model) =
    case msg of
        Animate msg ->
            let
                ( displayStates, cmds ) =
                    model.notifications
                        |> List.map (.display >> Messenger.update msg)
                        |> List.unzip

                notifications =
                    List.map2 (\n d -> { n | display = d })
                        model.notifications
                        displayStates
            in
                ( Model { model | notifications = notifications }
                , Cmd.map lift (Cmd.batch cmds)
                )

        Notify specs ->
            let
                notifications =
                    model.notifications ++ [ displayNotification model.nextId specs ]
            in
                ( Model
                    { model
                        | notifications = notifications
                        , nextId = model.nextId + 1
                    }
                , Cmd.none
                )

        Dismiss id ->
            let
                dismiss =
                    Animation.interrupt
                        [ Animation.to
                            [ Animation.opacity 0
                            , Animation.custom "max-height" 0 "px"
                            ]
                        , Messenger.send (Remove id)
                        ]

                displayStates =
                    model.notifications
                        |> List.map
                            (\n ->
                                if n.id == id then
                                    dismiss n.display
                                else
                                    n.display
                            )

                notifications =
                    List.map2 (\n d -> { n | display = d })
                        model.notifications
                        displayStates
            in
                ( Model { model | notifications = notifications }
                , Cmd.none
                )

        Remove id ->
            let
                notifications =
                    List.filter (\n -> n.id /= id) model.notifications
            in
                ( Model { model | notifications = notifications }
                , Cmd.none
                )



-- SUBSCRIPTION


subscription : (Msg a -> msg) -> Model a -> Sub msg
subscription lift (Model model) =
    Animation.subscription (lift << Animate) (List.map .display model.notifications)



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
        ((Animation.render notification.display)
            ++ [ Attributes.style
                    [ ( "padding", "0.01px" ), ( "pointer-events", "auto" ) ]
               ]
        )
        [ config.template notification.content (config.liftMsg <| Dismiss notification.id) ]
