module View.About exposing (view)

import Helpers
import Html
import Model exposing (Model)
import Msg exposing (Msg)
import Router
import Styles exposing (class, classList, id)


view : Model -> List (Html.Html Msg)
view model =
    [ Html.header [] header
    , Html.main_ [] [ Html.div [ class [ Styles.Narrow ] ] body ]
    ]


header : List (Html.Html Msg)
header =
    [ Html.nav [] [ Helpers.navIcon [ class [ Styles.Big ] ] Router.Home "home" ]
    , Html.h1 [] [ Html.text "About" ]
    ]


body : List (Html.Html Msg)
body =
    [ Html.div []
        [ Html.p [] [ Html.text "Some text about Gistr." ] ]
    ]
