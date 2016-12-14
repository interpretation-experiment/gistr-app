module Experiment.Subscription exposing (subscription)

import Clock
import Dom.Extra
import Experiment.Model as ExpModel
import Experiment.Msg exposing (Msg(..))
import Helpers
import Intro
import Lifecycle
import Model exposing (Model)


subscription : (Msg -> msg) -> Model -> Sub msg
subscription lift model =
    let
        trialTimer =
            Helpers.trialOr model Sub.none <|
                \trial ->
                    case trial.state of
                        ExpModel.Reading ->
                            Clock.subscription (lift << ClockMsg) trial.clock

                        ExpModel.Tasking ->
                            Clock.subscription (lift << ClockMsg) trial.clock

                        ExpModel.Writing _ ->
                            Clock.subscription (lift << ClockMsg) trial.clock

                        ExpModel.Timeout ->
                            Sub.none

                        ExpModel.Standby ->
                            Sub.none

        ctrlEnter =
            Helpers.authenticatedOr model Sub.none <|
                \{ user, meta } ->
                    case ( Lifecycle.state meta user.profile, model.experiment.state ) of
                        ( Lifecycle.Training _, ExpModel.JustFinished ) ->
                            Sub.none

                        ( Lifecycle.Training _, ExpModel.Instructions introState ) ->
                            if Intro.isRunning introState then
                                Sub.none
                            else
                                Dom.Extra.ctrlEnter (always <| lift CtrlEnter)

                        ( Lifecycle.Training _, ExpModel.Trial _ ) ->
                            Dom.Extra.ctrlEnter (always <| lift CtrlEnter)

                        ( Lifecycle.Experiment _, ExpModel.JustFinished ) ->
                            Dom.Extra.ctrlEnter (always <| lift CtrlEnter)

                        ( Lifecycle.Experiment _, ExpModel.Instructions introState ) ->
                            if Intro.isRunning introState then
                                Sub.none
                            else
                                Dom.Extra.ctrlEnter (always <| lift CtrlEnter)

                        ( Lifecycle.Experiment _, ExpModel.Trial _ ) ->
                            Dom.Extra.ctrlEnter (always <| lift CtrlEnter)

                        ( Lifecycle.Done, _ ) ->
                            Sub.none
    in
        Sub.batch
            [ Intro.subscription
                (lift << InstructionsMsg)
                (ExpModel.instructionsState model.experiment)
            , trialTimer
            , ctrlEnter
            ]
