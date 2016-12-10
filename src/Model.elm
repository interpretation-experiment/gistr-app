module Model
    exposing
        ( EmailConfirmationModel(..)
        , Model
        , FinishableForm(..)
        , emptyForms
        , initialModel
        )

import Admin.Model as AdminModel
import Autoresize
import Experiment.Model as ExpModel
import Form
import Home.Model as HomeModel
import Html
import Intro
import Msg exposing (Msg)
import Notification
import Router
import Store
import Types


-- MAIN MODEL


type alias Model =
    { route : Router.Route
    , auth : Types.AuthStatus
    , store : Store.Store
    , error : Maybe Types.Error
    , notifications : Notification.Model ( String, Html.Html Msg, Types.Notification )
    , -- Page-related data
      home : Intro.State HomeModel.Node
    , login : Form.Model Types.Credentials
    , recover : FinishableForm String String
    , reset : FinishableForm Types.ResetCredentials ()
    , prolific : Form.Model String
    , register : Form.Model Types.RegisterCredentials
    , emails : Form.Model String
    , emailConfirmation : EmailConfirmationModel
    , password : Form.Model Types.PasswordCredentials
    , username : Form.Model String
    , questionnaire : Form.Model Types.QuestionnaireForm
    , experiment : ExpModel.Model
    , admin : AdminModel.Model
    , -- Page-related utils
      autoresize : Autoresize.Model
    }


initialModel : Router.Route -> Model
initialModel route =
    { route = route
    , auth = Types.Authenticating
    , store = Store.emptyStore
    , error = Nothing
    , notifications = Notification.empty
    , -- Page-related data
      home = Intro.hide
    , login = Form.empty Types.emptyCredentials
    , recover = Form (Form.empty "")
    , reset = Form (Form.empty Types.emptyResetCredentials)
    , prolific = Form.empty ""
    , register = Form.empty Types.emptyRegisterCredentials
    , emails = Form.empty ""
    , emailConfirmation = SendingConfirmation
    , password = Form.empty Types.emptyPasswordCredentials
    , username = Form.empty ""
    , questionnaire = Form.empty Types.emptyQuestionnaireForm
    , experiment = ExpModel.initialModel
    , admin = AdminModel.initialModel
    , -- Page-related utils
      autoresize = Autoresize.initialModel
    }


emptyForms : Model -> Model
emptyForms model =
    let
        emptyModel =
            initialModel model.route
    in
        { emptyModel
            | auth = model.auth
            , store = model.store
            , error = model.error
            , notifications = model.notifications
        }


type FinishableForm a b
    = Form (Form.Model a)
    | Sent b


type EmailConfirmationModel
    = SendingConfirmation
    | ConfirmationFail
