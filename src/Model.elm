module Model exposing (Model, initialModel)

import Router
import Types


type alias Model =
    { route : Router.Route
    , auth : Types.Auth
    }


initialModel : Router.Route -> Model
initialModel route =
    { route = route
    , auth =
        Types.Anonymous
        -- TODO: change to authenticating at start
    }
