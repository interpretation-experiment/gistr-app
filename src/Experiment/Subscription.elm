module Experiment.Subscription exposing (subscription)

import Clock
import Dom.Extra
import Experiment.Model as ExpModel
import Experiment.Msg exposing (Msg(..))
import Form
import Helpers
import Intro
import Lifecycle
import Model exposing (Model)
import Time
import Types


loadTrialSub : ExpModel.LoadingState -> Types.Auth -> Sub Msg
loadTrialSub loading { meta } =
    case loading of
        ExpModel.Loaded ->
            Sub.none

        ExpModel.Loading ->
            Sub.none

        ExpModel.Waiting ->
            Time.every (Time.second * meta.heartbeat / 2) (always LoadTrial)


heartbeatSub : ExpModel.TrialModel -> Types.Auth -> Sub Msg
heartbeatSub trial { user, meta } =
    case ( Lifecycle.state meta user.profile, trial.state ) of
        ( Lifecycle.Training _, _ ) ->
            Sub.none

        ( Lifecycle.Experiment _, ExpModel.Reading ) ->
            Time.every (meta.heartbeat * Time.second) (always Heartbeat)

        ( Lifecycle.Experiment _, ExpModel.Tasking ) ->
            Time.every (meta.heartbeat * Time.second) (always Heartbeat)

        ( Lifecycle.Experiment _, ExpModel.Writing form ) ->
            if form.status /= Form.Sending then
                Time.every (meta.heartbeat * Time.second) (always Heartbeat)
            else
                Sub.none

        ( Lifecycle.Experiment _, ExpModel.Timeout ) ->
            Sub.none

        ( Lifecycle.Experiment _, ExpModel.Standby ) ->
            Sub.none

        ( Lifecycle.Done, _ ) ->
            Sub.none


trialTimerSub : ExpModel.TrialModel -> Sub Msg
trialTimerSub trial =
    case trial.state of
        ExpModel.Reading ->
            Clock.subscription ClockMsg trial.clock

        ExpModel.Tasking ->
            Clock.subscription ClockMsg trial.clock

        ExpModel.Writing _ ->
            Clock.subscription ClockMsg trial.clock

        ExpModel.Timeout ->
            Sub.none

        ExpModel.Standby ->
            Sub.none


ctrlEnterSub : ExpModel.State -> Types.Auth -> Sub Msg
ctrlEnterSub state { user, meta } =
    case ( Lifecycle.state meta user.profile, state ) of
        ( Lifecycle.Training _, ExpModel.JustFinished ) ->
            Sub.none

        ( Lifecycle.Training _, ExpModel.Instructions introState ) ->
            if Intro.isRunning introState then
                Sub.none
            else
                Dom.Extra.ctrlEnter (always CtrlEnter)

        ( Lifecycle.Training _, ExpModel.Trial _ ) ->
            Dom.Extra.ctrlEnter (always CtrlEnter)

        ( Lifecycle.Experiment _, ExpModel.JustFinished ) ->
            Dom.Extra.ctrlEnter (always CtrlEnter)

        ( Lifecycle.Experiment _, ExpModel.Instructions introState ) ->
            if Intro.isRunning introState then
                Sub.none
            else
                Dom.Extra.ctrlEnter (always CtrlEnter)

        ( Lifecycle.Experiment _, ExpModel.Trial _ ) ->
            Dom.Extra.ctrlEnter (always CtrlEnter)

        ( Lifecycle.Done, _ ) ->
            Sub.none


subscription : (Msg -> msg) -> Model -> Sub msg
subscription lift model =
    let
        loadTrial =
            Helpers.authenticatedOr
                model
                Sub.none
                (Sub.map lift << loadTrialSub model.experiment.loadingNext)

        heartbeat =
            Helpers.trialOr model Sub.none <|
                \trial ->
                    Helpers.authenticatedOr
                        model
                        Sub.none
                        (Sub.map lift << heartbeatSub trial)

        trialTimer =
            Helpers.trialOr
                model
                Sub.none
                (Sub.map lift << trialTimerSub)

        ctrlEnter =
            Helpers.authenticatedOr
                model
                Sub.none
                (Sub.map lift << ctrlEnterSub model.experiment.state)
    in
        Sub.batch
            [ Intro.subscription
                (lift << InstructionsMsg)
                (ExpModel.instructionsState model.experiment)
            , loadTrial
            , heartbeat
            , trialTimer
            , ctrlEnter
            ]
