module Auth.Update exposing (update)

import Api
import Auth.Msg exposing (Msg(..))
import Form
import Helpers
import Helpers exposing ((!!!))
import LocalStorage
import Maybe.Extra exposing ((?))
import Model exposing (Model)
import Msg as AppMsg
import Router
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
