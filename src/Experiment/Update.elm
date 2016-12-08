module Experiment.Update exposing (update)

import Api
import Clock
import Cmds
import Dom.Extra
import Experiment.Model as ExpModel
import Experiment.Msg exposing (Msg(..))
import Experiment.Shaping as Shaping
import Experiment.View as View
import Feedback
import Form
import Helpers
import Intro
import Lifecycle
import List
import List.Nonempty as Nonempty
import Maybe.Extra exposing (maybeToList)
import Model exposing (Model)
import Msg as AppMsg
import Strings
import Styles
import Task
import Time
import Types
import Validate


-- INSTRUCTIONS


instructionsConfig : (Msg -> AppMsg.Msg) -> Intro.UpdateConfig ExpModel.Node AppMsg.Msg
instructionsConfig lift =
    Intro.updateConfig
        { onQuit = lift << InstructionsQuit
        , onDone = lift InstructionsDone
        }



-- UPDATE


update :
    (Msg -> AppMsg.Msg)
    -> Types.Auth
    -> Msg
    -> Model
    -> ( Model, Cmd AppMsg.Msg, List AppMsg.Msg )
update lift auth msg model =
    case msg of
        NoOp ->
            ( model
            , Cmd.none
            , []
            )

        ClockMsg msg ->
            updateTrialOrIgnore model <|
                \trial ->
                    let
                        outMsg =
                            case trial.state of
                                -- TODO: move this into clock state, when
                                -- refactoring to animate with CSS
                                ExpModel.Reading ->
                                    TrialTask

                                ExpModel.Tasking ->
                                    TrialWrite

                                ExpModel.Writing _ ->
                                    TrialTimeout

                                ExpModel.Timeout ->
                                    -- There's no clock in Timeout
                                    NoOp

                                ExpModel.Pause ->
                                    -- There's no clock in Pause
                                    NoOp

                        ( newClock, maybeOut ) =
                            Clock.update (lift outMsg) msg trial.clock
                    in
                        ( { trial | clock = newClock }
                        , Cmd.none
                        , maybeToList maybeOut
                        )

        CtrlEnter ->
            ( model
            , Dom.Extra.click (toString Styles.CtrlNext)
            , []
            )

        {-
           INSTRUCTIONS
        -}
        InstructionsMsg msg ->
            updateInstructionsOrIgnore model <|
                \state ->
                    let
                        ( newState, maybeOut ) =
                            Intro.update (instructionsConfig lift) msg state
                    in
                        ( newState
                        , Cmd.none
                        , maybeToList maybeOut
                        )

        InstructionsStart ->
            let
                instructions =
                    ExpModel.Instructions <|
                        Intro.start <|
                            Nonempty.map Tuple.first <|
                                View.instructions auth.user.profile auth.meta
            in
                ( { model | experiment = ExpModel.setState instructions model.experiment }
                , Cmd.none
                , []
                )

        InstructionsQuit index ->
            if
                (Nonempty.length (View.instructions auth.user.profile auth.meta)
                    == (index + 1)
                )
            then
                ( model
                , Cmd.none
                , [ lift InstructionsDone ]
                )
            else
                updateInstructionsOrIgnore model <|
                    \state ->
                        ( Intro.hide
                        , Cmd.none
                        , []
                        )

        InstructionsDone ->
            let
                profile =
                    auth.user.profile

                updateProfile =
                    Api.updateProfile auth { profile | introducedExpPlay = True }
                        |> Task.attempt (lift << InstructionsDoneResult)
            in
                updateInstructionsOrIgnore model <|
                    \state ->
                        ( Intro.hide
                        , if not profile.introducedExpPlay then
                            updateProfile
                          else
                            Cmd.none
                        , []
                        )

        InstructionsDoneResult (Ok profile) ->
            ( Helpers.updateProfile model profile
            , Cmd.none
            , []
            )

        InstructionsDoneResult (Err error) ->
            ( model
            , Cmd.none
            , [ AppMsg.Error error ]
            )

        {-
           TRIAL
        -}
        LoadTrial ->
            let
                selectPreloaded preLoaded =
                    case preLoaded of
                        [] ->
                            Err <| Types.Unrecoverable "No preloaded trees to select from"

                        head :: rest ->
                            Ok ( rest, head )

                preloadTrainingAndSelect =
                    Shaping.fetchRandomizedUnshapedTrees auth.meta.trainingWork auth
                        |> Task.map (List.map .root)
                        |> Task.andThen (selectPreloaded >> Helpers.resultToTask)
                        |> Task.attempt (lift << LoadTrialResult)

                loadSentence =
                    Shaping.fetchPossiblyShapedUntouchedTree auth
                        |> Task.andThen (Shaping.selectTipSentence auth)
                        |> Task.attempt (lift << LoadTrialResult << Result.map ((,) []))

                loadingModel =
                    { model | experiment = ExpModel.setLoading True model.experiment }
            in
                case Lifecycle.state auth.meta auth.user.profile of
                    Lifecycle.Training _ ->
                        case model.experiment.state of
                            ExpModel.JustFinished ->
                                -- Ignore, this should never happen
                                ( model
                                , Cmd.none
                                , []
                                )

                            ExpModel.Instructions _ ->
                                -- Preload training sentences
                                ( loadingModel
                                , preloadTrainingAndSelect
                                , []
                                )

                            ExpModel.Trial trial ->
                                case selectPreloaded trial.preLoaded of
                                    Err error ->
                                        -- Load one remote sentence
                                        ( loadingModel
                                        , loadSentence
                                        , []
                                        )

                                    Ok ( preLoaded, selected ) ->
                                        -- Use preloaded sentence
                                        ( model
                                        , Cmd.none
                                        , [ Ok ( preLoaded, selected )
                                                |> LoadTrialResult
                                                |> lift
                                          ]
                                        )

                    Lifecycle.Experiment _ ->
                        -- Load one remote sentence
                        ( loadingModel
                        , loadSentence
                        , []
                        )

                    Lifecycle.Done ->
                        -- Ignore
                        ( model
                        , Cmd.none
                        , []
                        )

        LoadTrialResult (Ok ( preLoaded, current )) ->
            let
                newTrial =
                    case model.experiment.state of
                        ExpModel.Trial trial ->
                            -- Update current trial
                            { trial
                                | preLoaded = preLoaded
                                , current = current
                                , clock = (Clock.init <| Helpers.readTime auth.meta current)
                                , state = ExpModel.Reading
                            }

                        _ ->
                            -- Create a new trial
                            ExpModel.trial
                                preLoaded
                                current
                                (Clock.init <| Helpers.readTime auth.meta current)
            in
                ( { model
                    | experiment =
                        model.experiment
                            |> ExpModel.setLoading False
                            |> ExpModel.setState (ExpModel.Trial newTrial)
                  }
                , Cmd.none
                , []
                )

        LoadTrialResult (Err error) ->
            ( model
            , Cmd.none
            , [ AppMsg.Error error ]
            )

        TrialTask ->
            updateTrialOrIgnore model <|
                \trial ->
                    ( { trial
                        | state = ExpModel.Tasking
                        , clock = Clock.init <| 2 * Time.second
                      }
                    , Cmd.none
                    , []
                    )

        TrialWrite ->
            updateTrialOrIgnore model <|
                \trial ->
                    ( { trial
                        | state = ExpModel.Writing <| Form.empty ""
                        , clock = Clock.init <| Helpers.writeTime auth.meta trial.current
                      }
                    , Cmds.autofocus
                    , []
                    )

        TrialTimeout ->
            updateTrialOrIgnore model <|
                \trial ->
                    ( { trial | state = ExpModel.Timeout, clock = Clock.disabled }
                    , Cmd.none
                    , []
                    )

        TrialPause ->
            updateTrialOrIgnore model <|
                \trial ->
                    ( { trial | state = ExpModel.Pause, clock = Clock.disabled }
                    , Cmd.none
                    , []
                    )

        WriteInput input ->
            updateTrialOrIgnore model <|
                \trial ->
                    case trial.state of
                        ExpModel.Writing form ->
                            ( { trial | state = ExpModel.Writing (Form.input input form) }
                            , Cmd.none
                            , []
                            )

                        _ ->
                            ( trial
                            , Cmd.none
                            , []
                            )

        WriteSubmit input ->
            -- validate if enough words
            --   if not, Fail with feedback
            --   if yes, pause clock and:
            --     if in training:
            --       if sentences left, WriteResult Ok directly with same profile
            --       if nothing left, save trained in profile, getting back profile in WriteResult
            --     submit if not in training, getting back profile
            let
                profile =
                    auth.user.profile

                feedback =
                    [ Helpers.ifShorterThanWords auth.meta.minTokens
                        ( "global", Strings.sentenceTooShort auth.meta.minTokens )
                    ]
                        |> Validate.all
                        |> Feedback.fromValidator input

                newSentence trial =
                    { text = input
                    , language = trial.current.language
                    , bucket = trial.current.bucket
                    , readTimeProportion = 1
                    , readTimeAllotted = Helpers.readTime auth.meta trial.current
                    , writeTimeProportion = Clock.progress trial.clock
                    , writeTimeAllotted = Helpers.writeTime auth.meta trial.current
                    , parentId = Just trial.current.id
                    }

                trialState trial form =
                    { trial
                        | state = ExpModel.Writing (Form.setStatus Form.Sending form)
                        , clock = Clock.pause trial.clock
                    }

                inputValid trial form =
                    case Lifecycle.state auth.meta profile of
                        Lifecycle.Training _ ->
                            if trial.streak + 1 == auth.meta.trainingWork then
                                -- Save our newly trained status
                                ( trialState trial form
                                , Api.updateProfile auth { profile | trained = True }
                                    |> Task.attempt (lift << WriteResult)
                                , []
                                )
                            else
                                -- Move directly to next training trial
                                ( trialState trial form
                                , Cmd.none
                                , [ lift <| WriteResult <| Ok profile ]
                                )

                        Lifecycle.Experiment _ ->
                            -- Post the new sentence
                            ( trialState trial form
                            , Api.postSentence auth (newSentence trial)
                                |> Task.attempt (lift << WriteResult)
                            , []
                            )

                        Lifecycle.Done ->
                            ( trial
                            , Cmd.none
                            , []
                            )

                inputInvalid trial form =
                    ( { trial
                        | state = ExpModel.Writing (Form.fail feedback form)
                        , clock = Clock.resume trial.clock
                      }
                    , Cmd.none
                    , []
                    )
            in
                updateTrialOrIgnore model <|
                    \trial ->
                        case trial.state of
                            ExpModel.Writing form ->
                                if Feedback.isEmpty feedback then
                                    inputValid trial form
                                else
                                    inputInvalid trial form

                            _ ->
                                ( trial
                                , Cmd.none
                                , []
                                )

        WriteResult (Ok profile) ->
            -- get previous profile lifecycle
            -- update profile
            -- if lifecycle has changed, JustFinished
            -- if not, LoadTrial or Pause
            let
                stateChanged =
                    Lifecycle.state auth.meta auth.user.profile
                        /= Lifecycle.state auth.meta profile

                profileModel =
                    Helpers.updateProfile model profile

                next trial =
                    if trial.streak % auth.meta.pausePeriod == 0 then
                        TrialPause
                    else
                        LoadTrial
            in
                case model.experiment.state of
                    ExpModel.Trial trial ->
                        if stateChanged then
                            ( { profileModel
                                | experiment =
                                    ExpModel.setState
                                        ExpModel.JustFinished
                                        model.experiment
                              }
                            , Cmd.none
                            , []
                            )
                        else
                            let
                                newTrial =
                                    { trial | streak = trial.streak + 1 }

                                newModel =
                                    { profileModel
                                        | experiment =
                                            ExpModel.setState
                                                (ExpModel.Trial newTrial)
                                                profileModel.experiment
                                    }
                            in
                                update lift auth (next newTrial) newModel

                    _ ->
                        ( model
                        , Cmd.none
                        , []
                        )

        WriteResult (Err error) ->
            ( model
            , Cmd.none
            , [ AppMsg.Error error ]
            )



-- HELPERS


updateTrialOrIgnore :
    Model
    -> (ExpModel.TrialModel -> ( ExpModel.TrialModel, Cmd AppMsg.Msg, List AppMsg.Msg ))
    -> ( Model, Cmd AppMsg.Msg, List AppMsg.Msg )
updateTrialOrIgnore model updater =
    Helpers.trialOr model ( model, Cmd.none, [] ) <|
        \trial ->
            let
                ( newTrial, cmd, maybeOut ) =
                    updater trial

                experiment =
                    model.experiment

                newExperiment =
                    { experiment | state = ExpModel.Trial newTrial }
            in
                ( { model | experiment = newExperiment }
                , cmd
                , maybeOut
                )


updateInstructionsOrIgnore :
    Model
    -> (Intro.State ExpModel.Node
        -> ( Intro.State ExpModel.Node, Cmd AppMsg.Msg, List AppMsg.Msg )
       )
    -> ( Model, Cmd AppMsg.Msg, List AppMsg.Msg )
updateInstructionsOrIgnore model updater =
    case model.experiment.state of
        ExpModel.Instructions state ->
            let
                ( newState, cmd, maybeOut ) =
                    updater state

                experiment =
                    model.experiment

                newExperiment =
                    { experiment | state = ExpModel.Instructions newState }
            in
                ( { model | experiment = newExperiment }
                , cmd
                , maybeOut
                )

        _ ->
            ( model
            , Cmd.none
            , []
            )
