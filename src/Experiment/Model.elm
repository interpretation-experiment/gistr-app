module Experiment.Model
    exposing
        ( Model(..)
        , RunningModel
        , State(..)
        , TrialState(..)
        , initialModel
        , instructionsState
        )

import Experiment.Instructions as Instructions
import Form
import Intro


instructionsState : Model a -> Intro.State Instructions.Node
instructionsState model =
    case model of
        Running runningModel ->
            case runningModel.state of
                Instructions state ->
                    state

                _ ->
                    Intro.hide

        _ ->
            Intro.hide


initialModel : Model ()
initialModel =
    InitialLoading


type Model a
    = -- Loading training sentences and server meta information
      InitialLoading
    | Running (RunningModel a)
      -- If a sentence sampling doesn't return what's needed. If profile
      -- signals there aren't enough sentences to finish the current sequence,
      -- the view shows it (it's different from this Error).
    | Error


type alias RunningModel a =
    { preLoaded : List a
    , loadingNext : Bool
    , state : State a
    }


type State a
    = Instructions (Intro.State Instructions.Node)
    | Trial a TrialState
    | Pause
    | Finished


type TrialState
    = Reading
    | Tasking
    | Writing (Form.Model ())
