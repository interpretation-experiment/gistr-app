module Msg exposing (Msg(..))

import Animation
import Api
import Auth.Msg as Auth
import Experiment.Msg as Experiment
import Notification
import Profile.Msg as Profile
import Router
import Types


type Msg
    = NoOp
    | Animate Animation.Msg
      -- NOTIFICATIONS
    | Notify (Notification.Msg String)
      -- NAVIGATION
    | UrlUpdate String Router.Route
    | NavigateTo Router.Route
    | Error Types.Error
      -- STORE
    | WordSpanResult (Api.Result Types.WordSpan)
      -- AUTH
    | AuthMsg Auth.Msg
      -- PROFILE
    | ProfileMsg Profile.Msg
      -- EXPERIMENT
    | ExperimentMsg Experiment.Msg
