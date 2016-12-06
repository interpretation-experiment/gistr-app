module Intro
    exposing
        ( Msg
        , Position(..)
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
import List.Nonempty as Nonempty
import List.Nonempty exposing (Nonempty)
import List.Zipper as Zipper
import List.Zipper exposing (Zipper)
import Styles exposing (class, classList, id)
import Time


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


type TransitionState
    = Start
    | End


type State id
    = Hidden
    | Running TransitionState (Zipper id)


isRunning : State id -> Bool
isRunning state =
    case state of
        Hidden ->
            False

        Running _ _ ->
            True


hide : State id
hide =
    Hidden


start : Nonempty id -> State id
start order =
    Zipper.singleton (Nonempty.head order)
        |> Zipper.mapAfter (always (Nonempty.tail order))
        |> Running Start


isPast : id -> State id -> Bool
isPast id state =
    case state of
        Hidden ->
            False

        Running _ zipper ->
            List.member id (Zipper.before zipper)


isActive : id -> State id -> Bool
isActive id state =
    case state of
        Hidden ->
            False

        Running _ zipper ->
            Zipper.current zipper == id


isFuture : id -> State id -> Bool
isFuture id state =
    case state of
        Hidden ->
            False

        Running _ zipper ->
            List.member id (Zipper.after zipper)



-- UPDATE


type Msg
    = KeyDown KeyCode
    | StepNext
    | StepBack
    | Quit
    | Done
    | FinishTransition


update : UpdateConfig id msg -> Msg -> State id -> ( State id, Maybe msg )
update (UpdateConfig config) msg state =
    case state of
        Hidden ->
            ( state, Nothing )

        Running _ zipper ->
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
                            ( Running Start newZipper, Nothing )

                StepBack ->
                    case Zipper.previous zipper of
                        Nothing ->
                            ( state, Nothing )

                        Just newZipper ->
                            ( Running Start newZipper, Nothing )

                Quit ->
                    ( Hidden
                    , Just <| config.onQuit (currentIndex zipper)
                    )

                Done ->
                    ( Hidden, Just config.onDone )

                FinishTransition ->
                    ( Running End zipper, Nothing )



-- SUBSCRIPTION


subscription : (Msg -> msg) -> State id -> Sub msg
subscription lift state =
    case state of
        Hidden ->
            Sub.none

        Running Start _ ->
            Sub.batch
                [ Keyboard.downs (lift << KeyDown)
                , Time.every (100 * Time.millisecond) (always <| lift FinishTransition)
                ]

        Running End _ ->
            Keyboard.downs (lift << KeyDown)



-- VIEW


type Position
    = Top
    | Right
    | Bottom
    | Left


type ViewConfig id msg
    = ViewConfig
        { labelQuit : String
        , labelDone : String
        , labelBack : String
        , labelNext : String
        , liftMsg : Msg -> msg
        , tooltip : Int -> ( Position, Html.Html msg )
        }


viewConfig :
    { liftMsg : Msg -> msg
    , tooltip : Int -> ( Position, Html.Html msg )
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
    , tooltip : Int -> ( Position, Html.Html msg )
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
        activeState =
            if isRunning state then
                [ Attributes.class "elm-intro-overlayActive"
                , Attributes.style [ ( "opacity", "0.8" ) ]
                ]
            else
                [ Attributes.style [ ( "opacity", "0" ), ( "pointerEvents", "none" ) ] ]
    in
        Html.div
            ([ Attributes.class "elm-intro-overlay"
             , Attributes.style
                [ ( "position", "fixed" )
                , ( "top", "0" )
                , ( "bottom", "0" )
                , ( "left", "0" )
                , ( "right", "0" )
                , ( "backgroundImage"
                  , "radial-gradient(ellipse, "
                        ++ "rgba(0, 0, 0, 0.4) 0px, "
                        ++ "rgba(0, 0, 0, 0.9) 100%)"
                  )
                , ( "opacity", "0.8" )
                , ( "zIndex", "9999" )
                , ( "transition", "opacity 0.3s ease-out" )
                ]
             ]
                ++ activeState
            )
            []


node :
    ViewConfig id msg
    -> State id
    -> id
    -> (List (Html.Attribute msg) -> List (Html.Html msg) -> Html.Html msg)
    -> List (Html.Attribute msg)
    -> List (Html.Html msg)
    -> Html.Html msg
node config state id makeNode attributes content =
    makeNode
        (attributes ++ (nodeAttributes state id))
        (content ++ (tooltip config state id))


nodeAttributes : State id -> id -> List (Html.Attribute msg)
nodeAttributes state id =
    let
        activeState =
            case state of
                Hidden ->
                    []

                Running _ zipper ->
                    if Zipper.current zipper == id then
                        [ Attributes.class "elm-intro-nodeActive"
                        , Attributes.style
                            [ ( "position", "relative" )
                            , ( "zIndex", "99999" )
                            , ( "backgroundColor", "rgba(255, 255, 255, 0.9)" )
                            , ( "boxShadow"
                              , "0 0 0 4px rgba(255, 255, 255, 0.9), "
                                    ++ "0 2px 15px 4px rgba(0, 0, 0, .4)"
                              )
                            , ( "borderRadius", "1px" )
                            , ( "transition", "all .3s ease-in-out" )
                            ]
                        ]
                    else
                        -- This little hack lets us animate the box-shadow
                        -- color only (vs. also its size) on the instruction
                        -- nodes once the intro is running
                        [ Attributes.style
                            [ ( "boxShadow"
                              , "0 0 0 4px rgba(255, 255, 255, 0), "
                                    ++ "0 2px 15px 4px rgba(0, 0, 0, 0)"
                              )
                            ]
                        ]
    in
        activeState ++ [ Attributes.class "elm-intro-node" ]


progress : Zipper id -> Html.Html a
progress zipper =
    let
        dot color =
            Html.div
                [ Attributes.style
                    [ ( "width", "6px" )
                    , ( "height", "6px" )
                    , ( "backgroundColor", color )
                    , ( "margin", "2px" )
                    , ( "border-radius", "100%" )
                    ]
                ]
                [ Html.text " " ]
    in
        Html.div
            [ Attributes.style
                [ ( "display", "flex" )
                , ( "alignItems", "center" )
                , ( "justifyContent", "center" )
                , ( "margin", "10px 10px" )
                ]
            ]
            ((List.repeat (List.length <| Zipper.before zipper) (dot "#ccc"))
                ++ [ dot "#999" ]
                ++ (List.repeat (List.length <| Zipper.after zipper) (dot "#ccc"))
            )


tooltip : ViewConfig id msg -> State id -> id -> List (Html.Html msg)
tooltip config state id =
    case state of
        Hidden ->
            []

        Running transition zipper ->
            if Zipper.current zipper == id then
                let
                    visibilityAttributes =
                        case transition of
                            Start ->
                                [ ( "opacity", "0" )
                                , ( "pointerEvents", "none" )
                                ]

                            End ->
                                [ ( "opacity", "1" )
                                , ( "transition", "opacity 0.3s ease-in-out" )
                                ]
                in
                    [ Html.div
                        [ Attributes.class "elm-intro-tooltipActive"
                        , Attributes.class "elm-intro-tooltip"
                        , Attributes.style visibilityAttributes
                        , tooltipPositionAttributes config zipper
                        , Attributes.style
                            [ ( "position", "absolute" )
                            , ( "padding", "10px" )
                            , ( "boxSizing", "border-box" )
                            , ( "backgroundColor", "white" )
                            , ( "borderRadius", "3px" )
                            , ( "boxShadow", "0 1px 10px rgba(0, 0, 0, .4)" )
                            , ( "fontSize", "0.85rem" )
                            , ( "fontWeight", "400" )
                            , ( "textAlign", "left" )
                            ]
                        ]
                        (tooltipContent config zipper)
                    ]
            else
                []


tooltipPositionAttributes : ViewConfig id msg -> Zipper id -> Html.Attribute msg
tooltipPositionAttributes (ViewConfig config) zipper =
    case Tuple.first (config.tooltip (currentIndex zipper)) of
        Top ->
            Attributes.style
                [ ( "marginBottom", "10px" )
                , ( "marginLeft", "-137px" )
                , ( "left", "50%" )
                , ( "bottom", "100%" )
                , ( "width", "275px" )
                ]

        Right ->
            Attributes.style
                [ ( "marginLeft", "10px" )
                , ( "marginTop", "-4px" )
                , ( "top", "0" )
                , ( "left", "100%" )
                , ( "width", "225px" )
                ]

        Bottom ->
            Attributes.style
                [ ( "marginTop", "10px" )
                , ( "marginLeft", "-137px" )
                , ( "left", "50%" )
                , ( "width", "275px" )
                ]

        Left ->
            Attributes.style
                [ ( "marginRight", "10px" )
                , ( "marginTop", "-4px" )
                , ( "top", "0" )
                , ( "right", "100%" )
                , ( "width", "225px" )
                ]


tooltipContent : ViewConfig id msg -> Zipper id -> List (Html.Html msg)
tooltipContent (ViewConfig config) zipper =
    let
        outButton =
            if isLast zipper then
                Html.button
                    [ Events.onClick <| config.liftMsg Done
                    , class [ Styles.Btn, Styles.BtnSmall ]
                    , Attributes.style [ ( "marginRight", "5px" ) ]
                    ]
                    [ Html.text config.labelDone ]
            else
                Html.button
                    [ Events.onClick <| config.liftMsg Quit
                    , class [ Styles.Btn, Styles.BtnSmall ]
                    , Attributes.style [ ( "marginRight", "5px" ) ]
                    ]
                    [ Html.text config.labelQuit ]

        nextButton =
            Html.button
                [ Attributes.disabled (isLast zipper)
                , class [ Styles.Btn, Styles.BtnSmall ]
                , Events.onClick <| config.liftMsg StepNext
                ]
                [ Html.text config.labelNext ]

        backButton =
            Html.button
                [ Attributes.disabled (isFirst zipper)
                , class [ Styles.Btn, Styles.BtnSmall ]
                , Events.onClick <| config.liftMsg StepBack
                ]
                [ Html.text config.labelBack ]

        arrow =
            Html.div
                [ Attributes.style
                    [ ( "position", "absolute" )
                    , ( "border", "5px solid white" )
                    ]
                , arrowPositionAttributes (ViewConfig config) zipper
                ]
                []
    in
        [ config.tooltip (currentIndex zipper) |> Tuple.second
        , progress zipper
        , Html.div
            [ Attributes.style [ ( "float", "right" ) ] ]
            [ outButton, backButton, nextButton ]
        , arrow
        ]


arrowPositionAttributes : ViewConfig id msg -> Zipper id -> Html.Attribute msg
arrowPositionAttributes (ViewConfig config) zipper =
    case Tuple.first (config.tooltip (currentIndex zipper)) of
        Top ->
            Attributes.style
                [ ( "bottom", "-10px" )
                , ( "left", "50%" )
                , ( "margin-left", "-130px" )
                , ( "borderTopColor", "white" )
                , ( "borderRightColor", "transparent" )
                , ( "borderBottomColor", "transparent" )
                , ( "borderLeftColor", "transparent" )
                ]

        Right ->
            Attributes.style
                [ ( "top", "7px" )
                , ( "left", "-10px" )
                , ( "borderTopColor", "transparent" )
                , ( "borderRightColor", "white" )
                , ( "borderBottomColor", "transparent" )
                , ( "borderLeftColor", "transparent" )
                ]

        Bottom ->
            Attributes.style
                [ ( "top", "-10px" )
                , ( "left", "50%" )
                , ( "margin-left", "-130px" )
                , ( "borderTopColor", "transparent" )
                , ( "borderRightColor", "transparent" )
                , ( "borderBottomColor", "white" )
                , ( "borderLeftColor", "transparent" )
                ]

        Left ->
            Attributes.style
                [ ( "top", "7px" )
                , ( "right", "-10px" )
                , ( "borderTopColor", "transparent" )
                , ( "borderRightColor", "transparent" )
                , ( "borderBottomColor", "transparent" )
                , ( "borderLeftColor", "white" )
                ]
