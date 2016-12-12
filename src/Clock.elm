module Clock
    exposing
        ( Model
        , Msg
        , disabled
        , init
        , pause
        , progress
        , resume
        , subscription
        , update
        , view
        )

import AnimationFrame
import Html
import Svg
import Svg.Attributes as Attributes
import Time


type Status
    = Init
    | Running Time.Time Time.Time
    | Paused Time.Time
    | Resuming Time.Time
    | Finished


type Model msg
    = Model
        { status : Status
        , duration : Time.Time
        , endMsg : Maybe msg
        }


init : Time.Time -> msg -> Model msg
init duration endMsg =
    Model
        { status = Init
        , duration = duration
        , endMsg = Just endMsg
        }


disabled : Model msg
disabled =
    Model
        { status = Finished
        , duration = 1
        , endMsg = Nothing
        }


pause : Model msg -> Model msg
pause (Model model) =
    case model.status of
        Init ->
            Model model

        Running start current ->
            Model { model | status = Paused (current - start) }

        Paused _ ->
            Model model

        Resuming elapsed ->
            Model { model | status = Paused elapsed }

        Finished ->
            Model model


resume : Model msg -> Model msg
resume (Model model) =
    case model.status of
        Init ->
            Model model

        Running _ _ ->
            Model model

        Paused elapsed ->
            Model { model | status = Resuming elapsed }

        Resuming _ ->
            Model model

        Finished ->
            Model model


type Msg
    = Tick Time.Time


update : Msg -> Model msg -> ( Model msg, Maybe msg )
update (Tick now) (Model model) =
    case model.status of
        Init ->
            ( Model { model | status = Running now now }
            , Nothing
            )

        Running start _ ->
            if now < start + model.duration then
                ( Model { model | status = Running start now }
                , Nothing
                )
            else
                ( Model { model | status = Finished }
                , model.endMsg
                )

        Paused _ ->
            ( Model model
            , Nothing
            )

        Resuming elapsed ->
            -- Elapsed is always computed as (current - start), which
            -- is always < duration, so no need to check if we've
            -- finished the duration
            ( Model { model | status = Running (now - elapsed) now }
            , Nothing
            )

        Finished ->
            ( Model model
            , Nothing
            )


subscription : (Msg -> a) -> Model msg -> Sub a
subscription lift (Model model) =
    case model.status of
        Init ->
            AnimationFrame.times (lift << Tick)

        Running _ _ ->
            AnimationFrame.times (lift << Tick)

        Paused _ ->
            Sub.none

        Resuming _ ->
            AnimationFrame.times (lift << Tick)

        Finished ->
            Sub.none


progress : Model msg -> Float
progress (Model model) =
    case model.status of
        Init ->
            0

        Running start current ->
            (current - start) / model.duration

        Paused elapsed ->
            elapsed / model.duration

        Resuming elapsed ->
            elapsed / model.duration

        Finished ->
            1


view : Model msg -> Html.Html a
view model =
    let
        modelProgress =
            progress model

        radius =
            10

        scaling =
            0.8

        ( centerX, centerY ) =
            ( radius / scaling, radius / scaling )

        zero =
            radians (pi / 2)

        offset =
            radians (pi / 6)

        ( offsetX, offsetY ) =
            let
                ( x, y ) =
                    fromPolar ( radius, zero - offset )
            in
                ( centerX + x, centerY - y )

        arc =
            offset + modelProgress * (radians (2 * pi) - offset)

        ( tipX, tipY ) =
            let
                ( x, y ) =
                    fromPolar ( radius, zero - arc )
            in
                ( centerX + x, centerY - y )

        largeFlag =
            if (arc - offset) < (radians pi) then
                "0"
            else
                "1"

        hue =
            let
                split =
                    0.75

                startHue =
                    44

                endHue =
                    0
            in
                if modelProgress < split then
                    120
                else
                    startHue + (modelProgress - split) * (endHue - startHue) / (1 - split)
    in
        Svg.svg
            [ Attributes.viewBox ("0 0 " ++ toString (2 * centerX) ++ " " ++ toString (2 * centerY))
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
            , Svg.path
                [ Attributes.stroke <| "hsla(" ++ (toString hue) ++ ",82%,50%," ++ (toString modelProgress) ++ ")"
                , Attributes.strokeWidth "2"
                , Attributes.fill "transparent"
                , Attributes.d
                    ("M"
                        ++ toString centerX
                        ++ " "
                        ++ toString (centerY - radius)
                        ++ " A "
                        ++ toString radius
                        ++ " "
                        ++ toString radius
                        ++ " 0 0 1 "
                        ++ toString offsetX
                        ++ " "
                        ++ toString offsetY
                        ++ " A "
                        ++ toString radius
                        ++ " "
                        ++ toString radius
                        ++ " 0 "
                        ++ largeFlag
                        ++ " 1 "
                        ++ toString tipX
                        ++ " "
                        ++ toString tipY
                    )
                ]
                []
            ]
