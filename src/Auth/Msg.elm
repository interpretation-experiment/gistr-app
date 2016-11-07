module Auth.Msg exposing (Msg(..))

import Types


type Msg
    = -- LOGIN
      LoginFormInput Types.Credentials
    | LoginFail Types.Error
    | Login Types.Credentials
    | LoginSuccess Types.Auth
