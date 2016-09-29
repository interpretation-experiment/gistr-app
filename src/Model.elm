module Model
    exposing
        ( ChangePasswordModel
        , ChangeUsernameModel
        , EmailConfirmationModel(..)
        , EmailsModel
        , FormStatus(..)
        , LoginModel
        , Model
        , PageStatus(..)
        , ProlificModel
        , RecoverModel
        , RegisterModel
        , ResetModel
        , emptyForms
        , initialModel
        )

import Feedback
import Router
import Types


-- MAIN MODEL


type alias Model =
    { route : Router.Route
    , auth : Types.AuthStatus
    , error : Maybe Types.Error
    , loginModel : LoginModel
    , recoverModel : RecoverModel
    , resetModel : ResetModel
    , prolificModel : ProlificModel
    , registerModel : RegisterModel
    , emailsModel : EmailsModel
    , emailConfirmationModel : EmailConfirmationModel
    , changePasswordModel : ChangePasswordModel
    , changeUsernameModel : ChangeUsernameModel
    }


initialModel : Router.Route -> Model
initialModel route =
    { route = route
    , auth = Types.Authenticating
    , error = Nothing
    , loginModel = emptyLoginModel
    , recoverModel = emptyRecoverModel
    , resetModel = emptyResetModel
    , prolificModel = emptyProlificModel
    , registerModel = emptyRegisterModel
    , emailsModel = emptyEmailsModel
    , emailConfirmationModel = SendingConfirmation
    , changePasswordModel = emptyChangePasswordModel
    , changeUsernameModel = emptyChangeUsernameModel
    }


emptyForms : Model -> Model
emptyForms model =
    let
        emptyModel =
            initialModel model.route
    in
        { emptyModel
            | auth = model.auth
            , error = model.error
        }


type FormStatus
    = Entering
    | Sending


type PageStatus
    = Form FormStatus
    | Sent



-- LOGIN


type alias LoginModel =
    { input : Types.Credentials
    , feedback : Feedback.Feedback
    , status : FormStatus
    }


emptyLoginModel : LoginModel
emptyLoginModel =
    { input = Types.emptyCredentials
    , feedback = Feedback.empty
    , status = Entering
    }



-- RECOVER


type alias RecoverModel =
    { input : String
    , feedback : Feedback.Feedback
    , status : PageStatus
    }


emptyRecoverModel : RecoverModel
emptyRecoverModel =
    { input = ""
    , feedback = Feedback.empty
    , status = Form Entering
    }



-- RESET


type alias ResetModel =
    { input : Types.ResetCredentials
    , feedback : Feedback.Feedback
    , status : PageStatus
    }


emptyResetModel : ResetModel
emptyResetModel =
    { input = Types.emptyResetCredentials
    , feedback = Feedback.empty
    , status = Form Entering
    }



-- PROLIFIC


type alias ProlificModel =
    { input : String
    , feedback : Feedback.Feedback
    }


emptyProlificModel : ProlificModel
emptyProlificModel =
    { input = ""
    , feedback = Feedback.empty
    }



-- REGISTER


type alias RegisterModel =
    { input : Types.RegisterCredentials
    , feedback : Feedback.Feedback
    , status : FormStatus
    }


emptyRegisterModel : RegisterModel
emptyRegisterModel =
    { input = Types.emptyRegisterCredentials
    , feedback = Feedback.empty
    , status = Entering
    }



-- PASSWORD


type alias ChangePasswordModel =
    { input : Types.PasswordCredentials
    , feedback : Feedback.Feedback
    , status : FormStatus
    }


emptyChangePasswordModel : ChangePasswordModel
emptyChangePasswordModel =
    { input = Types.emptyPasswordCredentials
    , feedback = Feedback.empty
    , status = Entering
    }



-- USERNAME


type alias ChangeUsernameModel =
    { input : String
    , feedback : Feedback.Feedback
    , status : FormStatus
    }


emptyChangeUsernameModel : ChangeUsernameModel
emptyChangeUsernameModel =
    { input = ""
    , feedback = Feedback.empty
    , status = Entering
    }



-- EMAILS


type alias EmailsModel =
    { input : String
    , feedback : Feedback.Feedback
    , status : FormStatus
    }


emptyEmailsModel : EmailsModel
emptyEmailsModel =
    { input = ""
    , feedback = Feedback.empty
    , status = Entering
    }


type EmailConfirmationModel
    = SendingConfirmation
    | ConfirmationFail
