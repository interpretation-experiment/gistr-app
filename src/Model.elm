module Model
    exposing
        ( EmailsModel
        , EmailConfirmationModel(..)
        , PageStatus(..)
        , FormStatus(..)
        , LoginModel
        , Model
        , ProlificModel
        , RecoverModel
        , ResetModel
        , RegisterModel
        , ChangePasswordModel
        , ChangeUsernameModel
        , emptyForms
        , initialModel
        )

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


type FormStatus
    = Entering
    | Sending


type PageStatus
    = Form FormStatus
    | Sent


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



-- LOGIN


type alias LoginModel =
    { input : Types.Credentials
    , feedback : Types.Feedback
    , status : FormStatus
    }


emptyLoginModel : LoginModel
emptyLoginModel =
    { input = Types.emptyCredentials
    , feedback = Types.emptyFeedback
    , status = Entering
    }



-- RECOVER


type alias RecoverModel =
    { input : String
    , feedback : Types.Feedback
    , status : PageStatus
    }


emptyRecoverModel : RecoverModel
emptyRecoverModel =
    { input = ""
    , feedback = Types.emptyFeedback
    , status = Form Entering
    }



-- RESET


type alias ResetModel =
    { input : Types.ResetCredentials
    , feedback : Types.Feedback
    , status : PageStatus
    }


emptyResetModel : ResetModel
emptyResetModel =
    { input = Types.emptyResetCredentials
    , feedback = Types.emptyFeedback
    , status = Form Entering
    }



-- PROLIFIC


type alias ProlificModel =
    { input : String
    , feedback : Types.Feedback
    }


emptyProlificModel : ProlificModel
emptyProlificModel =
    { input = ""
    , feedback = Types.emptyFeedback
    }



-- REGISTER


type alias RegisterModel =
    { input : Types.RegisterCredentials
    , feedback : Types.Feedback
    , status : FormStatus
    }


emptyRegisterModel : RegisterModel
emptyRegisterModel =
    { input = Types.emptyRegisterCredentials
    , feedback = Types.emptyFeedback
    , status = Entering
    }



-- PASSWORD


type alias ChangePasswordModel =
    { input : Types.PasswordCredentials
    , feedback : Types.Feedback
    , status : FormStatus
    }


emptyChangePasswordModel : ChangePasswordModel
emptyChangePasswordModel =
    { input = Types.emptyPasswordCredentials
    , feedback = Types.emptyFeedback
    , status = Entering
    }



-- USERNAME


type alias ChangeUsernameModel =
    { input : String
    , feedback : Types.Feedback
    , status : FormStatus
    }


emptyChangeUsernameModel : ChangeUsernameModel
emptyChangeUsernameModel =
    { input = ""
    , feedback = Types.emptyFeedback
    , status = Entering
    }



-- EMAILS


type alias EmailsModel =
    { input : String
    , feedback : Types.Feedback
    , status : FormStatus
    }


emptyEmailsModel : EmailsModel
emptyEmailsModel =
    { input = ""
    , feedback = Types.emptyFeedback
    , status = Entering
    }


type EmailConfirmationModel
    = SendingConfirmation
    | ConfirmationFail
