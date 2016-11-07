module Auth.Msg exposing (Msg(..))

import Types


type Msg
    = -- LOGIN
      LoginFormInput Types.Credentials
    | LoginFail Types.Error
    | Login Types.Credentials
    | LoginSuccess Types.Auth
      -- LOCAL TOKEN LOGIN
    | GotLocalToken (Maybe Types.Token)
    | LoginLocalTokenFail Types.Error
      -- LOGOUT
    | Logout
    | LogoutFail Types.Error
    | LogoutSuccess
      -- PROLIFIC
    | SetProlificFormInput String
    | SetProlific String
      -- PASSWORD RECOVERY
    | RecoverFormInput String
    | RecoverFail Types.Error
    | Recover String
    | RecoverSuccess String
