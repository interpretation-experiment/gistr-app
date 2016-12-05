module Auth.Update exposing (update)

import Api
import Auth.Msg exposing (Msg(..))
import Feedback
import Form
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
import Validate


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

        Login credentials ->
            ( { model | login = Form.setStatus Form.Sending model.login }
            , Api.login credentials |> Task.attempt (lift << LoginResult)
            , Nothing
            )

        LoginResult (Ok auth) ->
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

        LoginResult (Err error) ->
            Helpers.extractFeedback error
                model
                [ ( "username", "username" )
                , ( "password", "password" )
                , ( "non_field_errors", "global" )
                ]
            <|
                \feedback ->
                    ( { model | login = Form.fail feedback model.login }
                    , Cmd.none
                    , Nothing
                    )

        {-
           LOCAL TOKEN LOGIN
        -}
        GotLocalToken maybeToken ->
            case maybeToken of
                Just token ->
                    ( model
                    , Api.getAuth token |> Task.attempt (lift << LoginLocalTokenResult)
                    , Nothing
                    )

                Nothing ->
                    Helpers.updateAuth Types.Anonymous model

        LoginLocalTokenResult (Ok auth) ->
            ( model
            , Cmd.none
            , Just <| lift <| LoginResult <| Ok auth
            )

        LoginLocalTokenResult (Err _) ->
            Helpers.updateAuth Types.Anonymous model !!! [ LocalStorage.tokenClear ]

        {-
           LOGOUT
        -}
        Logout ->
            Helpers.authenticatedOr model ( model, Cmd.none, Nothing ) <|
                \auth ->
                    Helpers.updateAuth Types.Authenticating model
                        !!! [ Api.logout auth |> Task.attempt (lift << LogoutResult)
                            , LocalStorage.tokenClear
                            ]

        LogoutResult (Ok ()) ->
            case model.route of
                Router.Reset _ ->
                    Helpers.updateAuth Types.Anonymous model

                _ ->
                    Helpers.updateAuthNav Types.Anonymous Router.Home model

        LogoutResult (Err error) ->
            let
                _ =
                    Debug.log "error logging user out" (toString error)
            in
                ( model
                , Cmd.none
                , Just <| lift <| LogoutResult <| Ok ()
                )

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

        Recover email ->
            case model.recover of
                Model.Form form ->
                    ( { model | recover = Model.Form (Form.setStatus Form.Sending form) }
                    , Api.recover email |> Task.attempt (lift << RecoverResult email)
                    , Nothing
                    )

                Model.Sent _ ->
                    ( model
                    , Cmd.none
                    , Nothing
                    )

        RecoverResult email (Ok ()) ->
            ( { model | recover = Model.Sent email }
            , Cmd.none
            , Nothing
            )

        RecoverResult _ (Err error) ->
            Helpers.extractFeedback error model [ ( "email", "global" ) ] <|
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

        {-
           PASSWORD RESET
        -}
        ResetFormInput input ->
            case model.reset of
                Model.Form form ->
                    ( { model | reset = Model.Form (Form.input input form) }
                    , Cmd.none
                    , Nothing
                    )

                Model.Sent _ ->
                    ( model
                    , Cmd.none
                    , Nothing
                    )

        Reset credentials tokens ->
            case model.reset of
                Model.Form form ->
                    let
                        feedback =
                            [ .password1 >> Helpers.ifShorterThan 6 ( "password1", Strings.passwordTooShort )
                            , Validate.ifInvalid
                                (\c -> c.password1 /= c.password2)
                                ( "global", Strings.passwordsDontMatch )
                            ]
                                |> Validate.all
                                |> Feedback.fromValidator credentials
                    in
                        if Feedback.isEmpty feedback then
                            ( { model | reset = Model.Form (Form.setStatus Form.Sending form) }
                            , Api.reset tokens credentials
                                |> Task.attempt (lift << ResetResult)
                            , Nothing
                            )
                        else
                            ( { model | reset = Model.Form (Form.fail feedback form) }
                            , Cmd.none
                            , Nothing
                            )

                Model.Sent _ ->
                    ( model
                    , Cmd.none
                    , Nothing
                    )

        ResetResult (Ok ()) ->
            update lift Logout { model | reset = Model.Sent () }

        ResetResult (Err error) ->
            let
                transpose =
                    Just Strings.resetProblem
                        |> Feedback.updateError "resetCredentials"
            in
                Helpers.extractFeedback error
                    model
                    [ ( "new_password1", "password1" )
                    , ( "new_password2", "password2" )
                    , ( "token", "resetCredentials" )
                    , ( "uid", "resetCredentials" )
                    ]
                <|
                    \feedback ->
                        case model.reset of
                            Model.Form form ->
                                ( { model
                                    | reset =
                                        Model.Form (Form.fail (transpose feedback) form)
                                  }
                                , Cmd.none
                                , Nothing
                                )

                            Model.Sent _ ->
                                ( model
                                , Cmd.none
                                , Nothing
                                )

        {-
           REGISTRATION
        -}
        RegisterFormInput input ->
            ( { model | register = Form.input input model.register }
            , Cmd.none
            , Nothing
            )

        Register maybeProlific credentials ->
            ( { model | register = Form.setStatus Form.Sending model.register }
            , Api.register credentials maybeProlific
                |> Task.attempt (lift << RegisterResult)
            , Nothing
            )

        RegisterResult (Ok auth) ->
            ( model
            , Cmd.none
            , Just <| lift <| LoginResult <| Ok auth
            )

        RegisterResult (Err error) ->
            Helpers.extractFeedback error
                model
                [ ( "username", "username" )
                , ( "email", "email" )
                , ( "password1", "password1" )
                , ( "password2", "password2" )
                , ( "__all__", "global" )
                ]
            <|
                \feedback ->
                    ( { model | register = Form.fail feedback model.register }
                    , Cmd.none
                    , Nothing
                    )
