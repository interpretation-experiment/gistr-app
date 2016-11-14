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


type Model
    = Model
        { status : Status
        , duration : Time.Time
        }


init : Time.Time -> Model
init duration =
    Model
        { status = Init
        , duration = duration
        }


disabled : Model
disabled =
    Model
        { status = Finished
        , duration = 1
        }


pause : Model -> Model
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


resume : Model -> Model
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


update : a -> Msg -> Model -> ( Model, Maybe a )
update endMsg msg (Model model) =
    case msg of
        Tick now ->
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
                        , Just endMsg
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


subscription : (Msg -> a) -> Model -> Sub a
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


progress : Model -> Float
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


view : Model -> Html.Html msg
view model =
    let
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
            offset + (progress model) * (radians (2 * pi) - offset)

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
    in
        Svg.svg
            [ Attributes.viewBox ("0 0 " ++ toString (2 * centerX) ++ " " ++ toString (2 * centerY))
            , Attributes.width "150px"
            ]
            [ Svg.path
                [ Attributes.stroke "red"
                , Attributes.strokeLinecap "round"
                , Attributes.strokeWidth "1"
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
