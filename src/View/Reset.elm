module View.Reset exposing (view)

import Helpers
import Html
import Model exposing (Model)
import Msg exposing (Msg)
import Router


view : Model -> String -> String -> Html.Html Msg
view model uid token =
    Html.div [] [ header, body model uid token ]


header : Html.Html Msg
header =
    Html.div []
        [ Helpers.navButton (Router.Login Nothing) "Back"
        , Html.h1 [] [ Html.text "Set new password" ]
        ]


body : Model -> String -> String -> Html.Html Msg
body model uid token =
    Html.div []
        [ Html.p [] [ Html.text ("uid: " ++ uid) ]
        , Html.p [] [ Html.text ("token: " ++ token) ]
        ]
