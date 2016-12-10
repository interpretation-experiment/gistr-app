module Msg exposing (Msg(..))

import Admin.Msg as Admin
import Animation
import Api
import Auth.Msg as Auth
import Experiment.Msg as Experiment
import Home.Msg as Home
import Html
import Notification
import Profile.Msg as Profile
import Router
import Types


type Msg
    = NoOp
    | Animate Animation.Msg
      -- NOTIFICATIONS
    | Notify (Notification.Msg ( String, Html.Html Msg, Types.Notification ))
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
