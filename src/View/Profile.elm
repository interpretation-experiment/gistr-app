module View.Profile exposing (view)

import Helpers
import Html
import Html.Attributes as Attributes
import Html.Events as Events
import Model exposing (Model)
import Msg exposing (Msg(..))
import Router
import Types


view : Model -> Router.ProfileRoute -> Html.Html Msg
view model route =
    let
        contents =
            case model.auth of
                Types.Authenticated { user } ->
                    [ menu route, body model route user ]

                Types.Authenticating ->
                    [ Helpers.loading ]

                Types.Anonymous ->
                    [ Helpers.notAuthed ]
    in
        Html.div [] ((header model) :: contents)


header : Model -> Html.Html Msg
header model =
    let
        logout =
            case model.auth of
                Types.Authenticated auth ->
                    Helpers.evButton [] Logout "Logout"

                _ ->
                    Html.span [] []
    in
        Html.div []
            [ Helpers.navButton Router.Home "Back"
            , logout
            , Html.h1 [] [ Html.text "Profile" ]
            ]


menu : Router.ProfileRoute -> Html.Html Msg
menu route =
    Html.ul []
        [ Html.li [] [ Helpers.navButton (Router.Profile Router.Tests) "Tests" ]
        , Html.li [] [ Helpers.navButton (Router.Profile Router.Settings) "Settings" ]
        , Html.li [] [ Helpers.navButton (Router.Profile Router.Emails) "Emails" ]
        ]


body : Model -> Router.ProfileRoute -> Types.User -> Html.Html Msg
body model route user =
    case route of
        Router.Tests ->
            Html.text "Tests"

        Router.Settings ->
            Html.text "Settings"

        Router.Emails ->
            emails model.emailsModel user.emails


emails : Model.EmailsModel -> List Types.Email -> Html.Html Msg
emails { input, feedback, status } emails' =
    let
        emailList =
            case emails' of
                [] ->
                    Html.p [] [ Html.text "You have no emails configured" ]

                _ ->
                    Html.ul [] (List.map email emails')
    in
        Html.div []
            [ Html.h2 [] [ Html.text "Email" ]
            , Html.p []
                [ Html.text "Your "
                , Html.strong [] [ Html.text "primary email address" ]
                , Html.text " is used for account-related information and password reset."
                ]
            , emailList
            , Html.h2 [] [ Html.text "Add an email address" ]
            , Html.form [ Events.onSubmit (AddEmail input) ]
                [ Html.span [] [ Html.text (Helpers.feedbackGet "global" feedback) ]
                , Html.input
                    [ Attributes.id "inputEmail"
                    , Attributes.disabled (status == Model.Sending)
                    , Attributes.type' "email"
                    , Attributes.value input
                    , Events.onInput AddEmailFormInput
                    ]
                    []
                , Html.button
                    [ Attributes.type' "submit"
                    , Attributes.disabled (status == Model.Sending)
                    ]
                    [ Html.text "Add" ]
                ]
            ]


email : Types.Email -> Html.Html Msg
email email' =
    let
        disabled =
            Attributes.disabled email'.transacting

        primary =
            if email'.primary then
                [ Html.span [] [ Html.text "Primary" ] ]
            else
                []

        verified =
            if email'.verified then
                []
            else
                [ Html.span [] [ Html.text "Unverified" ]
                , Helpers.evButton [ disabled ] (VerifyEmail email') "Send verification email"
                ]

        setPrimary =
            if email'.verified && (not email'.primary) then
                [ Helpers.evButton [ disabled ] (PrimaryEmail email') "Set as primary" ]
            else
                []
    in
        Html.div []
            ([ Html.span [] [ Html.text email'.email ] ]
                ++ primary
                ++ verified
                ++ setPrimary
                ++ [ Helpers.evButton [ disabled ] (DeleteEmail email') "Delete" ]
            )
