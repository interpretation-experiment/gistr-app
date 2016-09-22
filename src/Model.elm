module Model
    exposing
        ( LoginModel
        , Model
        , RecoverModel
        , RecoverStatus(..)
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
    }


initialModel : Router.Route -> Model
initialModel route =
    { route = route
    , auth = Types.Authenticating
    , loginModel = emptyLoginModel
    , recoverModel = emptyRecoverModel
    }


emptyForms : Model -> Model
emptyForms model =
    { model
        | loginModel = emptyLoginModel
        , recoverModel = emptyRecoverModel
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
    , status : RecoverStatus
    }


type RecoverStatus
    = Form
    | Sending
    | Sent


emptyRecoverModel : RecoverModel
emptyRecoverModel =
    { input = ""
    , feedback = Types.emptyFeedback
    , status = Form
    }
