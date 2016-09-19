module Helpers exposing (cmd, evButton, navButton, evA, navA, loading)

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


evButton : Msg -> String -> Html.Html Msg
evButton msg text =
    Html.button
        [ Events.onClick msg ]
        [ Html.text text ]


navButton : Router.Route -> String -> Html.Html Msg
navButton route text =
    evButton (NavigateTo route) text


evA : String -> Msg -> String -> Html.Html Msg
evA url msg text =
    Html.a
        [ Attributes.href url, onClickMsg msg ]
        [ Html.text text ]


navA : Router.Route -> String -> Html.Html Msg
navA route text =
    evA (Router.toUrl route) (NavigateTo route) text


onClickMsg : a -> Html.Attribute a
onClickMsg msg =
    Events.onWithOptions
        "click"
        { stopPropagation = True, preventDefault = True }
        (msg |> Decode.succeed)


loading : Html.Html msg
loading =
    Html.p [] [ Html.text "Loading..." ]
