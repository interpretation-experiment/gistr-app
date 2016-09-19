module Msg exposing (Msg(..))

import Router
import Types


type Msg
    = NavigateTo Router.Route
    | LoginFormUsername String
    | LoginFormPassword String
    | Login Types.Credentials
    | LoginTokenSuccess Types.Token
    | LoginTokenFail Types.Feedback
    | LoginUserSuccess Types.Token Types.User
    | LoginUserFail String
    | Logout
    | LogoutSuccess
    | LogoutFail String
