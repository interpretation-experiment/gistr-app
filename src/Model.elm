module Model
    exposing
        ( FormStatus(..)
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
    , auth : Types.Auth
    , loginModel : LoginModel
    , recoverModel : RecoverModel
    , resetModel : ResetModel
    , prolificModel : ProlificModel
    , registerModel : RegisterModel
    }


type FormStatus
    = Entering
    | Sending
    | Sent


initialModel : Router.Route -> Model
initialModel route =
    { route = route
    , auth = Types.Authenticating
    , loginModel = emptyLoginModel
    , recoverModel = emptyRecoverModel
    , resetModel = emptyResetModel
    , prolificModel = emptyProlificModel
    , registerModel = emptyRegisterModel
    }


emptyForms : Model -> Model
emptyForms model =
    { model
        | loginModel = emptyLoginModel
        , recoverModel = emptyRecoverModel
        , resetModel = emptyResetModel
        , prolificModel = emptyProlificModel
        , registerModel = emptyRegisterModel
    }



-- LOGIN


type alias LoginModel =
    { input : Types.Credentials
    , feedback : Types.Feedback
    }


emptyLoginModel : LoginModel
emptyLoginModel =
    { input = Types.emptyCredentials
    , feedback = Types.emptyFeedback
    }



-- RECOVER


type alias RecoverModel =
    { input : String
    , feedback : Types.Feedback
    , status : FormStatus
    }


emptyRecoverModel : RecoverModel
emptyRecoverModel =
    { input = ""
    , feedback = Types.emptyFeedback
    , status = Entering
    }



-- RESET


type alias ResetModel =
    { input : Types.ResetCredentials
    , feedback : Types.Feedback
    , status : FormStatus
    }


emptyResetModel : ResetModel
emptyResetModel =
    { input = Types.emptyResetCredentials
    , feedback = Types.emptyFeedback
    , status = Entering
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
    }


emptyRegisterModel : RegisterModel
emptyRegisterModel =
    { input = Types.emptyRegisterCredentials
    , feedback = Types.emptyFeedback
    }
