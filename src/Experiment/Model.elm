module Experiment.Model
    exposing
        ( LoadingState(..)
        , Model
        , Node(..)
        , State(..)
        , TrialModel
        , TrialState(..)
        , initialModel
        , instructionsState
        , setLoading
        , setState
        , trial
        )

import Clock
import Experiment.Msg
import Form
import Intro
import Types


initialModel : Model
initialModel =
    { loadingNext = Loaded
    , state = Instructions Intro.hide
    }


type alias Model =
    { loadingNext : LoadingState
    , state : State
    }


type LoadingState
    = Loaded
    | Loading
    | Waiting


type State
    = JustFinished
    | Instructions (Intro.State Node)
    | Trial TrialModel


type alias TrialModel =
    { current : Types.Sentence
    , clock : Clock.Model Experiment.Msg.Msg
    , state : TrialState
    }


type TrialState
    = Reading
    | Tasking
    | Writing (Form.Model String)
    | Timeout
    | Standby



-- INSTRUCTIONS


type Node
    = Title
    | Read
    | Task
    | Write
    | Tree
    | Break
    | Images
    | Progress



-- HELPERS


instructionsState : Model -> Intro.State Node
instructionsState model =
    case model.state of
        Instructions state ->
            state

        _ ->
            Intro.hide


setLoading : LoadingState -> Model -> Model
setLoading loading model =
    { model | loadingNext = loading }


setState : State -> Model -> Model
setState state model =
    { model | state = state }


trial : Types.Sentence -> Clock.Model Experiment.Msg.Msg -> TrialModel
trial current clock =
    { current = current
    , clock = clock
    , state = Reading
    }
