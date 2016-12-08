module View.About exposing (view)

import Helpers
import Html
import Lifecycle
import Model exposing (Model)
import Msg exposing (Msg)
import Router
import Strings
import Styles exposing (class, classList, id)
import Types


view : Model -> List (Html.Html Msg)
view model =
    [ Html.header [] header
    , Html.main_ [] [ Html.div [ class [ Styles.Narrow ] ] (body model) ]
    ]


header : List (Html.Html Msg)
header =
    [ Html.nav [] [ Helpers.navIcon [ class [ Styles.Big ] ] Router.Home "home" ]
    , Html.h1 [] [ Html.text "About" ]
    ]


body : Model -> List (Html.Html Msg)
body model =
    [ Html.div [] ((about model) ++ privacy ++ authors) ]


about : Model -> List (Html.Html Msg)
about model =
    let
        contents =
            case model.auth of
                Types.Anonymous ->
                    aboutTeaser

                Types.Authenticating ->
                    aboutTeaser

                Types.Authenticated { user, meta } ->
                    if user.isStaff then
                        aboutFull
                    else
                        case Lifecycle.state meta user.profile of
                            Lifecycle.Training _ ->
                                aboutTeaser

                            Lifecycle.Experiment _ ->
                                aboutTeaser

                            Lifecycle.Done ->
                                aboutFull
    in
        (Html.h1 [] [ Html.text Strings.aboutAboutTitle ]) :: contents


aboutTeaser : List (Html.Html Msg)
aboutTeaser =
    [ Html.p [] [ Html.text Strings.aboutAboutTeaserHowGood ]
    , Html.p [] [ Html.text Strings.aboutAboutTeaserShows ]
    , Html.p [] Strings.aboutAboutTeaserMore
    ]


aboutFull : List (Html.Html Msg)
aboutFull =
    [ Html.p [] Strings.aboutAboutFullSay
    , Html.p [] [ Html.strong [] [ Html.text Strings.aboutAboutFullWhat ] ]
    , Html.p [] [ Html.text Strings.aboutAboutFullGistr ]
    , Html.p [] Strings.aboutAboutFullOpen
    ]


privacy : List (Html.Html Msg)
privacy =
    [ Html.h1 [] [ Html.text Strings.aboutPrivacyTitle ]
    , Html.p [] [ Html.text Strings.aboutPrivacyCollects ]
    , Html.p [] [ Html.text Strings.aboutPrivacyDont ]
    , Html.ul []
        [ Html.li [] [ Html.text Strings.aboutPrivacyQuestionnaire ]
        , Html.li [] [ Html.text Strings.aboutPrivacyWordSpan ]
        , Html.li [] [ Html.text Strings.aboutPrivacyEmail ]
        ]
    , Html.p [] [ Html.text Strings.aboutPrivacyPrivate ]
    ]


authors : List (Html.Html Msg)
authors =
    [ Html.h1 [] [ Html.text Strings.aboutAuthorsTitle ]
    , Html.p [] Strings.aboutAuthorsCreated
    ]
