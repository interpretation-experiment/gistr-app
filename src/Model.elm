module Model exposing (Model, LoginModel, initialModel)

import Router
import Types


type alias Model =
    { route : Router.Route
    , auth : Types.Auth
    , loginModel : LoginModel
    }


type alias LoginModel =
    { input : Types.Credentials
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
    { input = Types.Credentials "" "" }
