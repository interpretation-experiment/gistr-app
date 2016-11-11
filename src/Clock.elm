module Clock
    exposing
        ( Model
        , Msg
        , init
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


type Msg
    = Tick Time.Time


update : a -> Msg -> Model -> ( Model, Maybe a )
update endMsg msg (Model model) =
    case msg of
        Tick time ->
            case model.status of
                Init ->
                    ( Model { model | status = Running time time }
                    , Nothing
                    )

                Running start _ ->
                    if time < start + model.duration then
                        ( Model { model | status = Running start time }
                        , Nothing
                        )
                    else
                        ( Model { model | status = Finished }
                        , Just endMsg
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

        Finished ->
            Sub.none


progress : Model -> Float
progress (Model model) =
    case model.status of
        Init ->
            0

        Running start current ->
            (current - start) / model.duration

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
