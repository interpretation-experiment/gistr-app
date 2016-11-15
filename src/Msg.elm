module Msg exposing (Msg(..))

import Animation
import Auth.Msg as Auth
import Experiment.Msg as Experiment
import Notification
import Profile.Msg as Profile
import Router
import Store
import Types


type Msg
    = NoOp
    | Animate Animation.Msg
      -- NOTIFICATIONS
    | Notify (Notification.Msg String)
      -- NAVIGATION
    | NavigateTo Router.Route
    | Error Types.Error
      -- STORE
    | GotStoreItem Store.Item
      -- AUTH
    | AuthMsg Auth.Msg
      -- PROFILE
    | ProfileMsg Profile.Msg
      -- EXPERIMENT
    | ExperimentMsg Experiment.Msg
