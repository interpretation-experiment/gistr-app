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
    = --| WORDSPAN: WordSpan
      Questionnaire


state : Types.Meta -> Types.Profile -> State
state meta profile =
    let
        tests =
            testsRemaining profile
    in
        -- Note the small inconsistency here, whereby training could be tracked
        -- through the number of training reformulations completed
        -- (profile.reformulationsCounts.training), but is tracked through the
        -- profile.trained boolean (meaning that if meta.trainingWork is later
        -- raised, that won't affect the users' training state), whereas
        -- completion of the experiment is tracked through the number of
        -- experiment reformulations completed.
        case ( profile.trained, profile.reformulationsCounts.experiment >= meta.experimentWork ) of
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
            ((meta.trainingWork - profile.reformulationsCounts.training)
                <= profile.availableTreeCounts.training
            )

        Experiment _ ->
            ((meta.experimentWork - profile.reformulationsCounts.experiment)
                <= profile.availableTreeCounts.experiment
            )

        Done ->
            True


testsRemaining : Types.Profile -> List Test
testsRemaining =
    Validate.all
        [ .questionnaireId >> Validate.ifNothing Questionnaire
          -- WORDSPAN: , .wordSpanId >> Validate.ifNothing WordSpan
        ]
