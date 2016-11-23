module Auth.Msg exposing (Msg(..))

import Api
import Types


type Msg
    = -- LOGIN
      LoginFormInput Types.Credentials
    | Login Types.Credentials
    | LoginResult (Api.Result Types.Auth)
      -- LOCAL TOKEN LOGIN
    | GotLocalToken (Maybe Types.Token)
    | LoginLocalTokenResult (Api.Result Types.Auth)
      -- LOGOUT
    | Logout
    | LogoutResult (Api.Result ())
      -- PROLIFIC
    | SetProlificFormInput String
    | SetProlific String
      -- PASSWORD RECOVERY
    | RecoverFormInput String
    | Recover String
    | RecoverResult String (Api.Result ())
      -- PASSWORD RESET
    | ResetFormInput Types.ResetCredentials
    | Reset Types.ResetCredentials Types.ResetTokens
    | ResetResult (Api.Result ())
      -- REGISTRATION
    | RegisterFormInput Types.RegisterCredentials
    | Register (Maybe String) Types.RegisterCredentials
    | RegisterResult (Api.Result Types.Auth)
