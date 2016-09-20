module Model
    exposing
        ( FormModel
        , Model
        , emptyForms
        , initialModel
        )

import Router
import Types


-- MAIN MODEL


type alias Model =
    { route : Router.Route
    , auth : Types.Auth
    , loginModel : FormModel Types.Credentials
    , recoverModel : FormModel ()
    }


initialModel : Router.Route -> Model
initialModel route =
    { route = route
    , auth = Types.Authenticating
    , loginModel = formModel Types.emptyCredentials
    , recoverModel = formModel ()
    }



-- FORMS


type alias FormModel a =
    { input : a
    , feedback : Types.Feedback
    }


formModel : a -> FormModel a
formModel input =
    { input = input
    , feedback = Types.emptyFeedback
    }


emptyForms : Model -> Model
emptyForms model =
    { model
        | loginModel = formModel Types.emptyCredentials
        , recoverModel = formModel ()
    }
