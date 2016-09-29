module Model
    exposing
        ( EmailConfirmationModel(..)
        , Model
        , SendableForm(..)
        , emptyForms
        , initialModel
        )

import Form
import Router
import Types


-- MAIN MODEL


type alias Model =
    { route : Router.Route
    , auth : Types.AuthStatus
    , error : Maybe Types.Error
    , login : Form.Model Types.Credentials
    , recover : SendableForm String String
    , reset : SendableForm Types.ResetCredentials ()
    , prolific : Form.Model String
    , register : Form.Model Types.RegisterCredentials
    , emails : Form.Model String
    , emailConfirmation : EmailConfirmationModel
    , password : Form.Model Types.PasswordCredentials
    , username : Form.Model String
    }


initialModel : Router.Route -> Model
initialModel route =
    { route = route
    , auth = Types.Authenticating
    , error = Nothing
    , login = Form.empty Types.emptyCredentials
    , recover = Form (Form.empty "")
    , reset = Form (Form.empty Types.emptyResetCredentials)
    , prolific = Form.empty ""
    , register = Form.empty Types.emptyRegisterCredentials
    , emails = Form.empty ""
    , emailConfirmation = SendingConfirmation
    , password = Form.empty Types.emptyPasswordCredentials
    , username = Form.empty ""
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


type SendableForm a b
    = Form (Form.Model a)
    | Sent b


type EmailConfirmationModel
    = SendingConfirmation
    | ConfirmationFail
