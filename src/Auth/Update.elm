module Auth.Update exposing (update)

import Api
import Auth.Msg exposing (Msg(..))
import Feedback
import Form
import Helpers
import Helpers exposing ((!!!))
import LocalStorage
import Maybe.Extra exposing ((?))
import Model exposing (Model)
import Msg as AppMsg
import Regex
import Router
import Strings
import Task
import Types


update : (Msg -> AppMsg.Msg) -> Msg -> Model -> ( Model, Cmd AppMsg.Msg, Maybe AppMsg.Msg )
update lift msg model =
    case msg of
        {-
           LOGIN
        -}
        LoginFormInput input ->
            ( { model | login = Form.input input model.login }
            , Cmd.none
            , Nothing
            )

        LoginFail error ->
            Helpers.feedbackOrUnrecoverable error model <|
                \feedback ->
                    ( { model | login = Form.fail feedback model.login }
                    , Cmd.none
                    , Nothing
                    )

        Login credentials ->
            ( { model | login = Form.setStatus Form.Sending model.login }
            , Api.login credentials
                |> Task.perform (lift << LoginFail) (lift << LoginSuccess)
            , Nothing
            )

        LoginSuccess auth ->
            case model.route of
                Router.Login maybeNext ->
                    Helpers.updateAuthNav
                        (Types.Authenticated auth)
                        (maybeNext ? Router.Home)
                        model
                        !!! [ LocalStorage.tokenSet auth.token ]

                _ ->
                    Helpers.updateAuth (Types.Authenticated auth) model
                        !!! [ LocalStorage.tokenSet auth.token ]

        {-
           LOCAL TOKEN LOGIN
        -}
        GotLocalToken maybeToken ->
            case maybeToken of
                Just token ->
                    ( model
                    , Api.fetchAuth token
                        |> Task.perform (lift << LoginLocalTokenFail) (lift << LoginSuccess)
                    , Nothing
                    )

                Nothing ->
                    Helpers.updateAuth Types.Anonymous model

        LoginLocalTokenFail _ ->
            Helpers.updateAuth Types.Anonymous model !!! [ LocalStorage.tokenClear ]

        {-
           LOGOUT
        -}
        Logout ->
            case model.auth of
                Types.Authenticated auth ->
                    Helpers.updateAuth Types.Authenticating model
                        !!! [ Api.logout auth
                                |> Task.perform
                                    (lift << LogoutFail)
                                    (always <| lift LogoutSuccess)
                            , LocalStorage.tokenClear
                            ]

                _ ->
                    ( model
                    , Cmd.none
                    , Nothing
                    )

        LogoutFail error ->
            let
                _ =
                    Debug.log "error logging user out" (toString error)
            in
                update lift LogoutSuccess model

        LogoutSuccess ->
            case model.route of
                Router.Reset _ ->
                    Helpers.updateAuth Types.Anonymous model

                _ ->
                    Helpers.updateAuthNav Types.Anonymous Router.Home model

        {-
           PROLIFIC
        -}
        SetProlificFormInput input ->
            ( { model | prolific = Form.input input model.prolific }
            , Cmd.none
            , Nothing
            )

        SetProlific prolificId ->
            if Regex.contains (Regex.regex "^[a-z0-9]+$") prolificId then
                ( model
                , Cmd.none
                , Just <| AppMsg.NavigateTo <| Router.Register <| Just prolificId
                )
            else
                let
                    invalid =
                        Feedback.globalError Strings.invalidProlific
                in
                    ( { model | prolific = Form.fail invalid model.prolific }
                    , Cmd.none
                    , Nothing
                    )

        {-
           PASSWORD RECOVERY
        -}
        RecoverFormInput input ->
            case model.recover of
                Model.Form form ->
                    ( { model | recover = Model.Form (Form.input input form) }
                    , Cmd.none
                    , Nothing
                    )

                Model.Sent _ ->
                    ( model
                    , Cmd.none
                    , Nothing
                    )

        RecoverFail error ->
            Helpers.feedbackOrUnrecoverable error model <|
                \feedback ->
                    case model.recover of
                        Model.Form form ->
                            ( { model | recover = Model.Form (Form.fail feedback form) }
                            , Cmd.none
                            , Nothing
                            )

                        Model.Sent _ ->
                            ( model
                            , Cmd.none
                            , Nothing
                            )

        Recover email ->
            case model.recover of
                Model.Form form ->
                    ( { model | recover = Model.Form (Form.setStatus Form.Sending form) }
                    , Api.recover email
                        |> Task.perform
                            (lift << RecoverFail)
                            (always <| lift <| RecoverSuccess email)
                    , Nothing
                    )

                Model.Sent _ ->
                    ( model
                    , Cmd.none
                    , Nothing
                    )

        RecoverSuccess email ->
            ( { model | recover = Model.Sent email }
            , Cmd.none
            , Nothing
            )
