module Helpers exposing (cmd, navButton, navA, loading)

import Html
import Html.Attributes as Attributes
import Html.Events as Events
import Json.Decode as Decode
import Msg exposing (Msg(NavigateTo))
import Router
import Task


cmd : a -> Cmd a
cmd msg =
    Task.perform (always msg) (always msg) (Task.succeed ())


navButton : Router.Route -> String -> Html.Html Msg
navButton route text =
    Html.button
        [ Events.onClick (NavigateTo route) ]
        [ Html.text text ]


navA : Router.Route -> String -> Html.Html Msg
navA route text =
    Html.a
        [ Attributes.href (Router.toUrl route)
        , onClickMsg (NavigateTo route)
        ]
        [ Html.text text ]


onClickMsg : a -> Html.Attribute a
onClickMsg msg =
    Events.onWithOptions
        "click"
        { stopPropagation = True, preventDefault = True }
        (msg |> Decode.succeed)


loading : Html.Html msg
loading =
    Html.p [] [ Html.text "Loading..." ]
