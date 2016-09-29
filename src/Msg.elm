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
      -- PASSWORD RESET
    | ResetFormInput Types.ResetCredentials
    | ResetFail Types.Error
    | Reset Types.ResetCredentials Types.ResetTokens
    | ResetSuccess
      -- REGISTRATION
    | RegisterFormInput Types.RegisterCredentials
    | RegisterFail Types.Error
    | Register (Maybe String) Types.RegisterCredentials
      -- PASSWORD MANAGEMENT
    | ChangePasswordFormInput Types.PasswordCredentials
    | ChangePasswordFail Types.Error
    | ChangePassword Types.PasswordCredentials
    | ChangePasswordSuccess Types.Auth
    | ChangePasswordRecover
    | ChangePasswordRecoverSuccess
      -- USERNAME MANAGEMENT
    | ChangeUsernameFormInput String
    | ChangeUsernameFail Types.Error
    | ChangeUsername String
    | ChangeUsernameSuccess Types.User
      -- EMAIL MANAGEMENT
    | RequestEmailVerification Types.Email
    | RequestEmailVerificationSuccess Types.Email
    | EmailConfirmationFail Types.Error
    | EmailConfirmationSuccess Types.User
    | PrimaryEmail Types.Email
    | PrimaryEmailSuccess Types.User
    | DeleteEmail Types.Email
    | DeleteEmailSuccess Types.User
    | AddEmailFormInput String
    | AddEmailFail Types.Error
    | AddEmail String
    | AddEmailSuccess Types.User
