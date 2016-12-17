module Clock
    exposing
        ( Model
        , Msg
        , disabled
        , pause
        , progress
        , resume
        , start
        , subscription
        , update
        , view
        )

import AnimationFrame
import Html
import Svg
import Svg.Attributes as Attributes
import Task
import Time


type Status
    = Starting
    | -- start time
      Running Time.Time
    | -- start time
      Pausing Time.Time
    | Paused
    | Finished


type Model msg
    = Model
        { status : Status
        , fullDuration : Time.Time
        , remaining : Time.Time
        , endMsg : Maybe msg
        }


start : Time.Time -> msg -> Model msg
start duration endMsg =
    Model
        { status = Starting
        , fullDuration = duration
        , remaining = duration
        , endMsg = Just endMsg
        }


disabled : Model msg
disabled =
    Model
        { status = Finished
        , fullDuration = 0
        , remaining = 0
        , endMsg = Nothing
        }


pause : Model msg -> Model msg
pause (Model model) =
    case model.status of
        Starting ->
            Model { model | status = Paused }

        Running start ->
            Model { model | status = Pausing start }

        Pausing _ ->
            Model model

        Paused ->
            Model model

        Finished ->
            Model model


resume : Model msg -> Model msg
resume (Model model) =
    case model.status of
        Starting ->
            Model model

        Running _ ->
            Model model

        Pausing start ->
            Model { model | status = Running start }

        Paused ->
            Model { model | status = Starting }

        Finished ->
            Model model


progress : Model msg -> Task.Task x Float
progress (Model model) =
    case model.status of
        Starting ->
            Task.succeed ((model.fullDuration - model.remaining) / model.fullDuration)

        Running start ->
            Time.now
                |> Task.map (\now -> (model.fullDuration - model.remaining + (now - start)) / model.fullDuration)

        Pausing start ->
            Time.now
                |> Task.map (\now -> (model.fullDuration - model.remaining + (now - start)) / model.fullDuration)

        Paused ->
            Task.succeed ((model.fullDuration - model.remaining) / model.fullDuration)

        Finished ->
            Task.succeed 1


type Msg
    = Tick Time.Time


update : Msg -> Model msg -> ( Model msg, Maybe msg )
update (Tick now) (Model model) =
    case model.status of
        Starting ->
            ( Model { model | status = Running now }
            , Nothing
            )

        Running start ->
            if now < start + model.remaining then
                ( Model model
                , Nothing
                )
            else
                ( Model { model | status = Finished, remaining = 0 }
                , model.endMsg
                )

        Pausing start ->
            let
                remaining =
                    model.remaining - (now - start)
            in
                if remaining > 0 then
                    ( Model { model | status = Paused, remaining = remaining }
                    , Nothing
                    )
                else
                    ( Model { model | status = Finished, remaining = 0 }
                    , model.endMsg
                    )

        Paused ->
            ( Model model
            , Nothing
            )

        Finished ->
            ( Model model
            , Nothing
            )


subscription : (Msg -> a) -> Model msg -> Sub a
subscription lift (Model model) =
    case model.status of
        Starting ->
            AnimationFrame.times (lift << Tick)

        Running _ ->
            Time.every model.remaining (lift << Tick)

        Pausing _ ->
            AnimationFrame.times (lift << Tick)

        Paused ->
            Sub.none

        Finished ->
            Sub.none


view : Model msg -> Html.Html a
view (Model model) =
    let
        scaling =
            0.8

        radius =
            10

        perimeter =
            -- This must match the initial stroke-dashoffset value in the
            -- "clock" keyframes animation (see app.css)
            2 * pi * radius

        ( centerX, centerY ) =
            ( radius / scaling, radius / scaling )

        animation =
            "clock "
                ++ toString (Time.inSeconds model.fullDuration)
                ++ "s linear "
                ++ toString (Time.inSeconds (model.remaining - model.fullDuration))
                ++ "s"

        ( statusAttrs, statusStyle ) =
            case model.status of
                Starting ->
                    ( [ Attributes.stroke "#555"
                      , Attributes.strokeDashoffset <|
                            toString <|
                                perimeter
                                    * model.remaining
                                    / model.fullDuration
                      ]
                    , []
                    )

                Running _ ->
                    ( [ Attributes.stroke "red"
                      , Attributes.strokeDashoffset "0"
                      ]
                    , [ ( "animation", animation ) ]
                    )

                Pausing _ ->
                    ( [ Attributes.stroke "red"
                      , Attributes.strokeDashoffset "0"
                      ]
                    , [ ( "animation", animation ) ]
                    )

                Paused ->
                    ( [ Attributes.stroke "#555"
                      , Attributes.strokeDashoffset <|
                            toString <|
                                perimeter
                                    * model.remaining
                                    / model.fullDuration
                      ]
                    , []
                    )

                Finished ->
                    ( [ Attributes.stroke "red"
                      , Attributes.strokeDashoffset "0"
                      ]
                    , []
                    )

        toStyle listTuples =
            listTuples
                |> List.map (\( k, v ) -> k ++ ": " ++ v)
                |> String.join "; "
    in
        Svg.svg
            [ Attributes.viewBox
                ("0 0 " ++ toString (2 * centerX) ++ " " ++ toString (2 * centerY))
            ]
            [ Svg.circle
                [ Attributes.stroke "#ccc"
                , Attributes.strokeWidth "2"
                , Attributes.fill "transparent"
                , Attributes.cx (toString centerX)
                , Attributes.cy (toString centerY)
                , Attributes.r (toString radius)
                ]
                []
            , Svg.circle
                ([ Attributes.strokeWidth "2"
                 , Attributes.fill "transparent"
                 , Attributes.cx (toString centerX)
                 , Attributes.cy (toString centerY)
                 , Attributes.r (toString radius)
                 , Attributes.strokeDasharray (toString perimeter)
                 , [ ( "transform-origin", "center" )
                   , ( "transform", "rotate(-90deg)" )
                   , ( "transition", "stroke .1s ease-in-out" )
                   ]
                    ++ statusStyle
                    |> toStyle
                    |> Attributes.style
                 ]
                    ++ statusAttrs
                )
                []
            ]
