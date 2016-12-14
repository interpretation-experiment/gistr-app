module Auth.View.Register exposing (view)

import Auth.Msg exposing (Msg(..))
import Feedback
import Form
import Helpers
import Html
import Html.Attributes as Attributes
import Html.Events as Events
import Model exposing (Model)
import Msg as AppMsg
import Router
import Strings
import Styles exposing (class, classList, id)
import Types


view : (Msg -> AppMsg.Msg) -> Model -> Maybe String -> List (Html.Html AppMsg.Msg)
view lift model maybeProlific =
    [ Html.header [] header
    , Html.main_ [] [ Html.div [ class [ Styles.Narrow ] ] (body lift model maybeProlific) ]
    ]


header : List (Html.Html AppMsg.Msg)
header =
    [ Html.nav [] [ Helpers.navIcon [ class [ Styles.Big ] ] Router.Home "home" ]
    , Html.h1 [] [ Html.text "Sign up" ]
    ]


body : (Msg -> AppMsg.Msg) -> Model -> Maybe String -> List (Html.Html AppMsg.Msg)
body lift model maybeProlific =
    let
        inner =
            case model.auth of
                Types.Anonymous ->
                    form lift model.register maybeProlific

                Types.Authenticating ->
                    [ Helpers.loading Styles.Big ]

                Types.Authenticated { user } ->
                    [ Helpers.alreadyAuthed user ]
    in
        [ Html.div [] inner ]


form :
    (Msg -> AppMsg.Msg)
    -> Form.Model Types.RegisterCredentials
    -> Maybe String
    -> List (Html.Html AppMsg.Msg)
form lift { input, feedback, status } maybeProlific =
    [ Html.form
        [ class [ Styles.FormFlex ]
        , Events.onSubmit <| lift (Register maybeProlific input)
        ]
        [ Html.div [ class [ Styles.FormBlock ] ] [ prolificLogin maybeProlific ]
        , Html.div [ class [ Styles.FormBlock ], Helpers.errorStyle "username" feedback ]
            [ Html.label [ Helpers.forId Styles.InputAutofocus ] [ Html.text "Username" ]
            , Html.div [ class [ Styles.Input, Styles.Label ] ]
                [ Html.span [ class [ Styles.Label ] ] [ Helpers.icon "user" ]
                , Html.input
                    [ id Styles.InputAutofocus
                    , Attributes.disabled (status /= Form.Entering)
                    , Attributes.autofocus True
                    , Attributes.placeholder Strings.usernamePlaceholder
                    , Attributes.type_ "text"
                    , Attributes.value input.username
                    , Events.onInput <|
                        lift
                            << (RegisterFormInput << \u -> { input | username = u })
                    ]
                    []
                ]
            , Html.div [] [ Html.text (Feedback.getError "username" feedback) ]
            ]
        , Html.div [ class [ Styles.FormBlock ], Helpers.errorStyle "email" feedback ]
            [ Html.label [ Attributes.for "inputEmail" ] [ Html.text "Email" ]
            , Html.div [ class [ Styles.Input, Styles.Label ] ]
                [ Html.span [ class [ Styles.Label ] ] [ Helpers.icon "envelope" ]
                , Html.input
                    [ Attributes.id "inputEmail"
                    , Attributes.disabled (status /= Form.Entering)
                    , Attributes.placeholder Strings.optionalEmailPlaceholder
                    , Attributes.type_ "email"
                    , Attributes.value input.email
                    , Events.onInput <|
                        lift
                            << (RegisterFormInput << \e -> { input | email = e })
                    ]
                    []
                ]
            , Html.div [] <|
                if String.length input.email > 0 then
                    [ Html.text Strings.registerEmailVerify ]
                else
                    []
            , Html.div [] [ Html.text (Feedback.getError "email" feedback) ]
            ]
        , Html.div
            [ class [ Styles.FormBlock ]
            , Helpers.errorStyle "password1" feedback
            ]
            [ Html.label [ Attributes.for "inputPassword1" ] [ Html.text "Password" ]
            , Html.div [ class [ Styles.Input, Styles.Label ] ]
                [ Html.span [ class [ Styles.Label ] ] [ Helpers.icon "lock" ]
                , Html.input
                    [ Attributes.id "inputPassword1"
                    , Attributes.disabled (status /= Form.Entering)
                    , Attributes.placeholder Strings.passwordPlaceholder1
                    , Attributes.type_ "password"
                    , Attributes.value input.password1
                    , Events.onInput <|
                        lift
                            << (RegisterFormInput << \p -> { input | password1 = p })
                    ]
                    []
                ]
            , Html.div [] [ Html.text (Feedback.getError "password1" feedback) ]
            ]
        , Html.div
            [ class [ Styles.FormBlock ]
            , Helpers.errorStyle "password2" feedback
            ]
            [ Html.label [ Attributes.for "inputPassword2" ]
                [ Html.text "Confirm password" ]
            , Html.div [ class [ Styles.Input, Styles.Label ] ]
                [ Html.span [ class [ Styles.Label ] ] [ Helpers.icon "lock" ]
                , Html.input
                    [ Attributes.id "inputPassword2"
                    , Attributes.disabled (status /= Form.Entering)
                    , Attributes.placeholder Strings.passwordPlaceholder2
                    , Attributes.type_ "password"
                    , Attributes.value input.password2
                    , Events.onInput <|
                        lift
                            << (RegisterFormInput << \p -> { input | password2 = p })
                    ]
                    []
                ]
            , Html.div [] [ Html.text (Feedback.getError "password2" feedback) ]
            ]
        , Html.div [ class [ Styles.FormBlock ] ]
            [ Html.div [ class [ Styles.Error ] ]
                [ Html.text (Feedback.getError "global" feedback) ]
            , Html.div []
                [ Html.button
                    [ Attributes.type_ "submit"
                    , Attributes.disabled (status /= Form.Entering)
                    , class [ Styles.Btn, Styles.BtnPrimary ]
                    ]
                    [ Html.text "Sign up" ]
                ]
            ]
        ]
    ]


prolificLogin : Maybe String -> Html.Html AppMsg.Msg
prolificLogin maybeProlific =
    case maybeProlific of
        Just prolificId ->
            Html.div [ class [ Styles.InfoBox ] ]
                [ Html.div []
                    [ Html.p []
                        [ Html.text Strings.registerProlificYourIdIs
                        , Html.text " "
                        , Html.span [ class [ Styles.BadgeDefault ] ]
                            [ Html.text prolificId ]
                        ]
                    , Html.p [] Strings.registerProlificSignUp
                    , Html.p [] Strings.registerProlificGoBack
                    ]
                ]

        Nothing ->
            Html.div []
                [ Html.div [ class [ Styles.RequestBox ] ]
                    [ Html.div [] Strings.registerProlificQuestion ]
                , Html.div [ class [ Styles.InfoBox ] ]
                    [ Html.div [] Strings.registerAlreadyAccount ]
                ]
