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
    }


emptyForms : Model -> Model
emptyForms model =
    { model
        | loginModel = emptyLoginModel
        , recoverModel = emptyRecoverModel
        , resetModel = emptyResetModel
        , prolificModel = emptyProlificModel
        , registerModel = emptyRegisterModel
        , emailsModel = emptyEmailsModel
        , emailConfirmationModel = SendingConfirmation
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
