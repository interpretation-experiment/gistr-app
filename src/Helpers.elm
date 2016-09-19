module Helpers exposing (msgCmd, navButton, loading)

import Html
import Html.Events
import Msg exposing (Msg(NavigateTo))
import Router
import Task


msgCmd : a -> Cmd a
msgCmd msg =
    Task.perform (always msg) (always msg) (Task.succeed ())


navButton : Router.Route -> String -> Html.Html Msg
navButton route text =
    Html.button [ Html.Events.onClick (NavigateTo route) ] [ Html.text text ]


loading : Html.Html msg
loading =
    Html.p [] [ Html.text "Loading..." ]
