module Msg exposing (Msg(..))

import Router
import Types


type Msg
    = NoOp
    | NavigateTo Router.Route
    | LoginFormUsername String
    | LoginFormPassword String
    | Login Types.Credentials
    | LoginFail Types.Feedback
    | GotToken Types.Token
    | GotLocalToken (Maybe Types.Token)
    | GotUser Types.Token Types.User
    | GetUserFail Types.Feedback
    | Logout
    | LogoutSuccess
    | LogoutFail String
    | Recover String
    | RecoverFormInput String
    | RecoverFail Types.Feedback
    | RecoverSuccess
