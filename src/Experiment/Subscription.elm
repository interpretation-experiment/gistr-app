module Experiment.Subscription exposing (subscription)

import Clock
import Experiment.Model as ExpModel
import Experiment.Msg exposing (Msg(..))
import Helpers
import Intro
import Model exposing (Model)
import String
import Time
import Types


subscription : (Msg -> msg) -> Model -> Sub msg
subscription lift model =
    let
        trialTimer =
            runningTrialOrNone model <|
                \meta sentence state ->
                    case state of
                        ExpModel.Reading clock ->
                            Clock.subscription (lift << ClockMsg) clock

                        ExpModel.Tasking clock ->
                            Clock.subscription (lift << ClockMsg) clock

                        ExpModel.Writing _ ->
                            -- TODO: timer to Msg.TrialTimeout
                            Sub.none
    in
        Sub.batch
            [ Intro.subscription
                (lift << InstructionsMsg << Intro.KeyDown)
                (ExpModel.instructionsState model.experiment)
            , trialTimer
            ]


runningTrialOrNone :
    { a | experiment : ExpModel.Model, auth : Types.AuthStatus }
    -> (Types.Meta -> Types.Sentence -> ExpModel.TrialState -> Sub msg)
    -> Sub msg
runningTrialOrNone model sub =
    Helpers.authenticatedOr model Sub.none <|
        \auth ->
            Helpers.runningOr model Sub.none <|
                \running ->
                    case running.state of
                        ExpModel.Trial sentence state ->
                            sub auth.meta sentence state

                        _ ->
                            Sub.none
