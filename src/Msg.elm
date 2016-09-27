module Msg exposing (Msg(..))

import Router
import Types


type Msg
    = NoOp
      -- NAVIGATION
    | NavigateTo Router.Route
    | Error Types.Error
      -- LOGIN
    | LoginFormInput Types.Credentials
    | Login Types.Credentials
    | LoginFail Types.Error
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
    | Recover String
    | RecoverFail Types.Error
    | RecoverSuccess
      -- PASSWORD RESET
    | ResetFormInput Types.ResetCredentials
    | Reset Types.ResetCredentials Types.ResetTokens
    | ResetFail Types.Error
    | ResetSuccess
      -- REGISTRATION
    | RegisterFormInput Types.RegisterCredentials
    | Register (Maybe String) Types.RegisterCredentials
    | RegisterFail Types.Error
      -- EMAIL MANAGEMENT
    | RequestEmailVerification Types.Email
    | RequestEmailVerificationSuccess Types.Email
    | PrimaryEmail Types.Email
    | PrimaryEmailSuccess Types.User
    | DeleteEmail Types.Email
    | DeleteEmailSuccess Types.User
    | AddEmailFormInput String
    | AddEmail String
    | AddEmailFail Types.Error
    | AddEmailSuccess Types.User
