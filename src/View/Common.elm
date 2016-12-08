module View.Common exposing (prolificCompletion)

import Config
import Html
import Html.Attributes as Attributes
import Strings
import Styles exposing (class, classList, id)
import Types


prolificCompletion : Types.Profile -> List (Html.Html msg)
prolificCompletion profile =
    case profile.prolificId of
        Nothing ->
            []

        Just _ ->
            [ Html.p [] [ Html.text Strings.prolificCompletion ]
            , Html.p []
                [ Html.a
                    [ Attributes.href Config.prolificCompletionUrl
                    , class [ Styles.Btn ]
                    ]
                    [ Html.text Strings.prolificCompletionButton ]
                ]
            ]
