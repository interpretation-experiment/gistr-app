module Explore.View.Trees exposing (view)

import Explore.Router exposing (ViewConfig)
import Helpers
import Html
import Explore.Model exposing (Model)
import Msg exposing (Msg)
import Router
import Styles exposing (class, classList, id)


view : Model -> ViewConfig -> List (Html.Html Msg)
view model config =
    [ Html.header [] header
    , Html.main_ [] [ Html.div [ class [ Styles.Narrow ] ] (body model config) ]
    ]


header : List (Html.Html Msg)
header =
    [ Html.nav [] [ Helpers.navIcon [ class [ Styles.Big ] ] Router.Home "home" ]
    , Html.h1 [] [ Html.text "Explore Trees" ]
    ]


body : Model -> ViewConfig -> List (Html.Html Msg)
body { trees } { page, pageSize, rootBucket } =
    case trees of
        Nothing ->
            [ Helpers.loading Styles.Big ]

        Just trees ->
            [ Html.div [] <| List.map (\t -> Html.div [] [ Html.text t.root.text ]) trees.items
            ]
