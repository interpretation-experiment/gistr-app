module Notification
    exposing
        ( Kind(..)
        , Model
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
import Html.Events as Events
import List
import Time


-- CONFIG


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
    , kind : Kind
    , content : a
    , display : Messenger.State (Msg a)
    }


type Notification a
    = Notification
        { content : a
        , kind : Kind
        , duration : Time.Time
        }


type Kind
    = Dismissable
    | Disappearing
    | DismissableDisappearing


notification : Kind -> a -> Notification a
notification kind content =
    Notification
        { content = content
        , kind = kind
        , duration = 10 * Time.second
        }


displayNotification : Int -> Notification a -> DisplayedNotification a
displayNotification id (Notification specs) =
    let
        disappearance =
            case specs.kind of
                Dismissable ->
                    []

                Disappearing ->
                    [ Animation.wait specs.duration
                    , Messenger.send (Dismiss id)
                    ]

                DismissableDisappearing ->
                    [ Animation.wait specs.duration
                    , Messenger.send (Dismiss id)
                    ]
    in
        { id = id
        , kind = specs.kind
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
        , template : a -> Html.Html msg
        }


viewConfig : (Msg a -> msg) -> (a -> Html.Html msg) -> ViewConfig a msg
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
            ]
        ]
        (List.map (notificationView viewConfig) model.notifications)


notificationView : ViewConfig a msg -> DisplayedNotification a -> Html.Html msg
notificationView (ViewConfig config) notification =
    let
        dismissButton =
            Html.button [ Events.onClick <| config.liftMsg <| Dismiss notification.id ]
                [ Html.text "X" ]

        controls =
            case notification.kind of
                Dismissable ->
                    [ dismissButton ]

                Disappearing ->
                    []

                DismissableDisappearing ->
                    [ dismissButton ]
    in
        Html.div
            ((Animation.render notification.display)
                ++ [ Attributes.style
                        [ ( "padding", "0.01px" ) ]
                   ]
            )
            [ Html.div
                [ Attributes.style
                    [ ( "margin", "10px" )
                    , ( "background-color", "burlywood" )
                    , ( "box-shadow", "0 0 3px 3px burlywood" )
                    ]
                ]
                ([ config.template notification.content ] ++ controls)
            ]
