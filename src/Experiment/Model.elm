module Experiment.Model
    exposing
        ( Model(..)
        , RunningModel
        , State(..)
        , TrialState(..)
        , initialModel
        , initialRunningModel
        , instructionsState
        )

import Clock
import Experiment.Instructions as Instructions
import Form
import Intro
import Types


instructionsState : Model -> Intro.State Instructions.Node
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


initialModel : Model
initialModel =
    Init


type Model
    = -- Loading training sentences and server meta information
      Init
    | Running RunningModel
      -- If a sentence sampling doesn't return what's needed. If profile
      -- signals there aren't enough sentences to finish the current sequence,
      -- the view shows it (it's different from this Error).
    | Error


initialRunningModel : List Types.Sentence -> Model
initialRunningModel sentences =
    Running <| RunningModel sentences False (Instructions Intro.hide)


type alias RunningModel =
    { preLoaded : List Types.Sentence
    , loadingNext : Bool
    , state : State
    }


type State
    = JustFinished
    | Instructions (Intro.State Instructions.Node)
    | Trial Types.Sentence TrialState
    | Pause


type TrialState
    = Reading Clock.Model
    | Tasking Clock.Model
    | Writing Clock.Model (Form.Model String)
    | Timeout
