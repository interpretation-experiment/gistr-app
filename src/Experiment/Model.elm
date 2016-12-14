module Experiment.Model
    exposing
        ( Model
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
    { loadingNext = False
    , state = Instructions Intro.hide
    }


type alias Model =
    { loadingNext : Bool
    , state : State
    }


type State
    = JustFinished
    | Instructions (Intro.State Node)
    | Trial TrialModel


type alias TrialModel =
    { preLoaded : List Types.Sentence
    , streak : Int
    , current : Types.Sentence
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
    | Read1
    | Read2
    | Task
    | Write
    | Tree
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


setLoading : Bool -> Model -> Model
setLoading loading model =
    { model | loadingNext = loading }


setState : State -> Model -> Model
setState state model =
    { model | state = state }


trial : List Types.Sentence -> Types.Sentence -> Clock.Model Experiment.Msg.Msg -> TrialModel
trial preLoaded current clock =
    { preLoaded = preLoaded
    , streak = 0
    , current = current
    , clock = clock
    , state = Reading
    }
