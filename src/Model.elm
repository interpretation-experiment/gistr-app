module Model exposing (Model, LoginModel, initialModel, emptyForms)

import Router
import Types


type alias Model =
    { route : Router.Route
    , auth : Types.Auth
    , loginModel : LoginModel
    }


type alias LoginModel =
    { input : Types.Credentials
    , feedback : Types.Feedback
    }


initialModel : Router.Route -> Model
initialModel route =
    { route = route
    , auth =
        Types.Anonymous
        -- TODO: change to authenticating at start
    , loginModel = initialLoginModel
    }


initialLoginModel : LoginModel
initialLoginModel =
    { input = Types.Credentials "" ""
    , feedback = Types.emptyFeedback
    }


emptyForms : Model -> Model
emptyForms model =
    { model
        | loginModel = initialLoginModel
    }
