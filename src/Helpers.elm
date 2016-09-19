module Helpers exposing (msgCmd, navButton)

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
