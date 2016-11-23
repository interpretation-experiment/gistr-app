module Experiment.Subscription exposing (subscription)

import Clock
import Experiment.Model as ExpModel
import Experiment.Msg exposing (Msg(..))
import Helpers
import Intro
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

                        ExpModel.Pause ->
                            Sub.none
    in
        Sub.batch
            [ Intro.subscription
                (lift << InstructionsMsg)
                (ExpModel.instructionsState model.experiment)
            , trialTimer
            ]
