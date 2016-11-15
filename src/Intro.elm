module Intro
    exposing
        ( Msg
        , State
        , UpdateConfig
        , ViewConfig
        , customViewConfig
        , hide
        , isActive
        , isFuture
        , isPast
        , isRunning
        , node
        , overlay
        , start
        , subscription
        , update
        , updateConfig
        , viewConfig
        )

import Html
import Html.Attributes as Attributes
import Html.Events as Events
import Keyboard exposing (KeyCode)
import List
import List.Zipper as Zipper
import List.Zipper exposing (Zipper)
import List.Nonempty as Nonempty
import List.Nonempty exposing (Nonempty)
import Maybe.Extra exposing ((?))


-- CONFIG


type UpdateConfig id msg
    = UpdateConfig
        { onQuit : Int -> msg
        , onDone : msg
        }


updateConfig :
    { onQuit : Int -> msg
    , onDone : msg
    }
    -> UpdateConfig id msg
updateConfig { onQuit, onDone } =
    UpdateConfig
        { onQuit = onQuit
        , onDone = onDone
        }



-- ZIPPER


length : Zipper a -> Int
length zipper =
    1 + (List.length (Zipper.before zipper)) + (List.length (Zipper.after zipper))


isFirst : Zipper a -> Bool
isFirst zipper =
    List.length (Zipper.before zipper) == 0


isLast : Zipper a -> Bool
isLast zipper =
    List.length (Zipper.after zipper) == 0


currentIndex : Zipper a -> Int
currentIndex zipper =
    List.length (Zipper.before zipper)



-- MODEL


type State id
    = Hidden
    | Running (Zipper id)


isRunning : State id -> Bool
isRunning state =
    case state of
        Hidden ->
            False

        Running _ ->
            True


hide : State id
hide =
    Hidden


start : Nonempty id -> State id
start order =
    Zipper.singleton (Nonempty.head order)
        |> Zipper.updateAfter (always (Nonempty.tail order))
        |> Running


isPast : id -> State id -> Bool
isPast id state =
    case state of
        Hidden ->
            False

        Running zipper ->
            List.member id (Zipper.before zipper)


isActive : id -> State id -> Bool
isActive id state =
    case state of
        Hidden ->
            False

        Running zipper ->
            Zipper.current zipper == id


isFuture : id -> State id -> Bool
isFuture id state =
    case state of
        Hidden ->
            False

        Running zipper ->
            List.member id (Zipper.after zipper)



-- UPDATE


type Msg
    = KeyDown KeyCode
    | StepNext
    | StepBack
    | Quit
    | Done


update : UpdateConfig id msg -> Msg -> State id -> ( State id, Maybe msg )
update (UpdateConfig config) msg state =
    case state of
        Hidden ->
            ( state, Nothing )

        Running zipper ->
            case msg of
                KeyDown keyCode ->
                    if keyCode == 37 then
                        -- Left arrow
                        update (UpdateConfig config) StepBack state
                    else if keyCode == 39 then
                        -- Right arrow
                        update (UpdateConfig config) StepNext state
                    else if keyCode == 27 then
                        -- Escape
                        update (UpdateConfig config) Quit state
                    else
                        ( state, Nothing )

                StepNext ->
                    case Zipper.next zipper of
                        Nothing ->
                            update (UpdateConfig config) Done state

                        Just newZipper ->
                            ( Running newZipper, Nothing )

                StepBack ->
                    case Zipper.previous zipper of
                        Nothing ->
                            ( state, Nothing )

                        Just newZipper ->
                            ( Running newZipper, Nothing )

                Quit ->
                    ( Hidden
                    , Just <| config.onQuit (currentIndex zipper)
                    )

                Done ->
                    ( Hidden, Just config.onDone )



-- SUBSCRIPTION


subscription : (Msg -> msg) -> State id -> Sub msg
subscription lift state =
    if isRunning state then
        Keyboard.downs (lift << KeyDown)
    else
        Sub.none



-- VIEW


type ViewConfig id msg
    = ViewConfig
        { labelQuit : String
        , labelDone : String
        , labelBack : String
        , labelNext : String
        , liftMsg : Msg -> msg
        , tooltip : Int -> Html.Html msg
        }


viewConfig :
    { liftMsg : Msg -> msg
    , tooltip : Int -> Html.Html msg
    }
    -> ViewConfig id msg
viewConfig { liftMsg, tooltip } =
    customViewConfig
        { labelQuit = "Skip"
        , labelDone = "Done"
        , labelBack = "← Back"
        , labelNext = "Next →"
        , liftMsg = liftMsg
        , tooltip = tooltip
        }


customViewConfig :
    { labelQuit : String
    , labelDone : String
    , labelBack : String
    , labelNext : String
    , liftMsg : Msg -> msg
    , tooltip : Int -> Html.Html msg
    }
    -> ViewConfig id msg
customViewConfig { labelQuit, labelDone, labelBack, labelNext, liftMsg, tooltip } =
    ViewConfig
        { labelQuit = labelQuit
        , labelDone = labelDone
        , labelBack = labelBack
        , labelNext = labelNext
        , liftMsg = liftMsg
        , tooltip = tooltip
        }


overlay : State id -> Html.Html msg
overlay state =
    let
        attributes =
            if isRunning state then
                [ Attributes.style
                    [ ( "position", "fixed" )
                    , ( "top", "0" )
                    , ( "bottom", "0" )
                    , ( "left", "0" )
                    , ( "right", "0" )
                    , ( "backgroundColor", "black" )
                    , ( "opacity", "0.8" )
                    , ( "zIndex", "9999" )
                    ]
                , Attributes.class "elm-intro-overlayActive"
                ]
            else
                []
    in
        Html.div ((Attributes.class "elm-intro-overlay") :: attributes) []


node :
    ViewConfig id msg
    -> State id
    -> id
    -> (List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg)
    -> List (Html.Attribute msg)
    -> List (Html.Html msg)
    -> Html.Html msg
node config state id makeNode attributes contents =
    let
        ( introAttributes, tooltip ) =
            case state of
                Hidden ->
                    ( []
                    , Html.div [] []
                    )

                Running zipper ->
                    if Zipper.current zipper == id then
                        activeDetails config zipper
                    else
                        ( []
                        , Html.div [] []
                        )
    in
        makeNode
            (attributes ++ (Attributes.class "elm-intro-node") :: introAttributes)
            (contents ++ [ tooltip ])


progress : Zipper id -> Html.Html a
progress zipper =
    (toString <| 1 + List.length (Zipper.before zipper))
        ++ " / "
        ++ (toString <| length zipper)
        |> Html.text


activeDetails :
    ViewConfig id msg
    -> Zipper id
    -> ( List (Html.Attribute msg), Html.Html msg )
activeDetails (ViewConfig config) zipper =
    let
        outButton =
            if isLast zipper then
                Html.button
                    [ Events.onClick <| config.liftMsg Done ]
                    [ Html.text config.labelDone ]
            else
                Html.button
                    [ Events.onClick <| config.liftMsg Quit ]
                    [ Html.text config.labelQuit ]

        nextButton =
            Html.button
                [ Attributes.disabled (isLast zipper)
                , Events.onClick <| config.liftMsg StepNext
                ]
                [ Html.text config.labelNext ]

        backButton =
            Html.button
                [ Attributes.disabled (isFirst zipper)
                , Events.onClick <| config.liftMsg StepBack
                ]
                [ Html.text config.labelBack ]
    in
        ( [ Attributes.class "elm-intro-nodeActive"
          , Attributes.style
                [ ( "position", "relative" )
                , ( "zIndex", "99999" )
                , ( "backgroundColor", "white" )
                , ( "boxShadow", "0 0 1px 3px white" )
                ]
          ]
        , Html.div
            [ Attributes.class "elm-intro-tooltipActive"
            , Attributes.style
                [ ( "position", "absolute" )
                , ( "width", "275px" )
                , ( "marginTop", "10px" )
                , ( "marginLeft", "-137px" )
                , ( "left", "50%" )
                , ( "padding", "5px" )
                , ( "backgroundColor", "white" )
                , ( "fontSize", "initial" )
                , ( "fontWeight", "initial" )
                , ( "fontHeight", "initial" )
                ]
            ]
            [ config.tooltip (currentIndex zipper)
            , progress zipper
            , outButton
            , backButton
            , nextButton
            ]
        )
