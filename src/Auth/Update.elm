module Auth.Update exposing (update)

import Api
import Auth.Msg exposing (Msg(..))
import Form
import Helpers
import Helpers exposing ((!!))
import LocalStorage
import Maybe.Extra exposing ((?))
import Model exposing (Model)
import Msg as AppMsg
import Router
import Task
import Types
import Wiring exposing (UpdateConfig)


update : UpdateConfig Msg -> Msg -> Model -> ( Model, Cmd AppMsg.Msg )
update { lift, appUpdate } msg model =
    case msg of
        LoginFormInput input ->
            { model | login = Form.input input model.login } ! []

        LoginFail error ->
            Helpers.feedbackOrUnrecoverable appUpdate error model <|
                \feedback ->
                    { model | login = Form.fail feedback model.login } ! []

        Login credentials ->
            { model | login = Form.setStatus Form.Sending model.login }
                ! [ Api.login credentials
                        |> Task.perform (lift << LoginFail) (lift << LoginSuccess)
                  ]

        LoginSuccess auth ->
            case model.route of
                Router.Login maybeNext ->
                    Helpers.updateAuthNav appUpdate
                        (Types.Authenticated auth)
                        (maybeNext ? Router.Home)
                        model
                        !! [ LocalStorage.tokenSet auth.token ]

                _ ->
                    Helpers.updateAuth appUpdate (Types.Authenticated auth) model
                        !! [ LocalStorage.tokenSet auth.token ]
