module Msg exposing (Msg(..))

import Router
import Types


type Msg
    = NoOp
    | NavigateTo Router.Route
    | Error String
    | LoginFormInput Types.Credentials
    | Login Types.Credentials
    | LoginFail Types.Feedback
    | GotToken (Maybe String) Types.Token
    | GotLocalToken (Maybe Types.Token)
    | GotUser (Maybe String) Types.Token Types.User
    | GetUserFail Types.Feedback
    | Logout Types.Token
    | LogoutSuccess
    | LogoutFail String
    | ProlificFormInput String
    | ProlificFormSubmit String
    | Recover String
    | RecoverFormInput String
    | RecoverFail Types.Feedback
    | RecoverSuccess
    | Reset Types.ResetCredentials String String
    | ResetFormInput Types.ResetCredentials
    | ResetFail Types.Feedback
    | ResetSuccess
    | Register (Maybe String) Types.RegisterCredentials
    | RegisterFormInput Types.RegisterCredentials
    | RegisterFail Types.Feedback
    | CreatedProfile Types.Token Types.User Types.Profile
    | VerifyEmail Types.Email
    | VerifyEmailSent
    | PrimaryEmail Types.Email
    | PrimariedEmail
    | DeleteEmail Types.Email
    | DeletedEmail
    | EmailFormInput String
    | AddEmail String
    | AddEmailFail Types.Feedback
