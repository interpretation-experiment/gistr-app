module Msg exposing (Msg(..))

import Admin.Msg as Admin
import Api
import Auth.Msg as Auth
import Autoresize
import Experiment.Msg as Experiment
import Home.Msg as Home
import Html
import Notification
import Profile.Msg as Profile
import Router
import Types


type Msg
    = NoOp
    | Log String
      -- NOTIFICATIONS
    | NotificationMsg (Notification.Msg ( String, Html.Html Msg, Types.Notification ))
      -- AUTORESIZE TEXTAREAS
    | Autoresize (Autoresize.Msg Msg)
      -- NAVIGATION
    | UrlUpdate String Router.Route
    | NavigateTo Router.Route
    | Error Types.Error
      -- STORE
    | WordSpanResult (Api.Result Types.WordSpan)
      -- HOME
    | HomeMsg Home.Msg
      -- AUTH
    | AuthMsg Auth.Msg
      -- PROFILE
    | ProfileMsg Profile.Msg
      -- EXPERIMENT
    | ExperimentMsg Experiment.Msg
      -- ADMIN
    | AdminMsg Admin.Msg
