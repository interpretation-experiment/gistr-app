module Lifecycle
    exposing
        ( Preliminary(..)
        , State(..)
        , Test(..)
        , isProfilePreliminary
        , state
        , testsRemaining
        )

import Types
import Validate


type State
    = Preliminaries (List Preliminary)
    | Experiment



{-
   ...
   | Finished
-}


type Test
    = Questionnaire
    | WordSpan


type Preliminary
    = ProfilePreliminary Test
    | Training


isProfilePreliminary : Preliminary -> Bool
isProfilePreliminary preliminary =
    case preliminary of
        ProfilePreliminary _ ->
            True

        Training ->
            False


state : Types.Profile -> State
state profile =
    case preliminariesRemaining profile of
        [] ->
            Experiment

        remaining ->
            Preliminaries remaining


testsRemaining : Types.Profile -> List Test
testsRemaining =
    Validate.all
        [ .questionnaireId >> Validate.ifNothing Questionnaire
        , .wordSpanId >> Validate.ifNothing WordSpan
        ]


preliminariesRemaining : Types.Profile -> List Preliminary
preliminariesRemaining =
    Validate.all
        [ testsRemaining >> List.map ProfilePreliminary
        , Validate.ifInvalid .trained Training
        ]
