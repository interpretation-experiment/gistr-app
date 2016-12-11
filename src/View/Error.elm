module View.Error exposing (view)

import Html
import Html.Attributes as Attributes
import Model exposing (Model)
import Styles exposing (class, classList, id)


view : Model -> List (Html.Html msg)
view model =
    [ Html.header [] []
    , Html.main_ [] [ Html.div [ class [ Styles.Narrow ] ] (body model) ]
    ]


body : Model -> List (Html.Html msg)
body model =
    [ Html.div []
        [ Html.h1 [] [ Html.text "Oops!" ]
        , Html.p []
            [ Html.text "There seems to have been an error. Make sure your internet connection is working properly, then try "
            , Html.a [ Attributes.href "/" ] [ Html.text "reloading the app" ]
            , Html.text "."
            ]
        , Html.p []
            [ Html.text "If the problem persists, please "
            , Html.a [ Attributes.href ("mailto:sl@mehho.net?subject=Gistr error report&body=Error details:%0A%0A" ++ toString model) ] [ Html.text "click here to send an automated email report" ]
            , Html.text " to the developers. Thanks for your cooperation!"
            ]
        ]
    ]
