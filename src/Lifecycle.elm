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



{-
   ...
   | Finished
-}


type Test
    = Questionnaire
    | WordSpan


state : Types.Profile -> State
state profile =
    let
        tests =
            testsRemaining profile
    in
        if not profile.trained then
            Training tests
        else
            Experiment tests


bucket : Types.Profile -> String
bucket profile =
    case state profile of
        Training _ ->
            "training"

        Experiment _ ->
            "experiment"


stateIsCompletable : Types.Meta -> Types.Profile -> Bool
stateIsCompletable meta profile =
    case state profile of
        Training _ ->
            meta.trainingWork <= profile.availableTreeCounts.training

        Experiment _ ->
            meta.experimentWork <= profile.availableTreeCounts.experiment


testsRemaining : Types.Profile -> List Test
testsRemaining =
    Validate.all
        [ .questionnaireId >> Validate.ifNothing Questionnaire
        , .wordSpanId >> Validate.ifNothing WordSpan
        ]
