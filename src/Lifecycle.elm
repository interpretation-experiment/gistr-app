module Lifecycle
    exposing
        ( State(..)
        , Test(..)
        , bucket
        , state
        , stateIsCompletable
        , testsRemaining
        )

import Types
import Validate


type State
    = Training (List Test)
    | Experiment (List Test)
    | Done


type Test
    = Questionnaire
    | WordSpan


state : Types.Meta -> Types.Profile -> State
state meta profile =
    let
        tests =
            testsRemaining profile
    in
        case ( profile.trained, profile.reformulationsCount >= meta.experimentWork ) of
            ( False, _ ) ->
                Training tests

            ( True, False ) ->
                Experiment tests

            ( True, True ) ->
                Done


bucket : Types.Meta -> Types.Profile -> String
bucket meta profile =
    case state meta profile of
        Training _ ->
            "training"

        Experiment _ ->
            "experiment"

        Done ->
            "game"


stateIsCompletable : Types.Meta -> Types.Profile -> Bool
stateIsCompletable meta profile =
    case state meta profile of
        Training _ ->
            meta.trainingWork <= profile.availableTreeCounts.training

        Experiment _ ->
            ((meta.experimentWork - profile.reformulationsCount)
                <= profile.availableTreeCounts.experiment
            )

        Done ->
            True


testsRemaining : Types.Profile -> List Test
testsRemaining =
    Validate.all
        [ .questionnaireId >> Validate.ifNothing Questionnaire
        , .wordSpanId >> Validate.ifNothing WordSpan
        ]
