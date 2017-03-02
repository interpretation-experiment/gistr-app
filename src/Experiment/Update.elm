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
                        ( newClock, maybeOut ) =
                            Clock.update msg trial.clock
                    in
                        ( { trial | clock = newClock }
                        , Cmd.none
                        , maybeToList <| Maybe.map lift maybeOut
                        )

        CtrlEnter ->
            ( model
            , Dom.Extra.click (toString Styles.CtrlNext)
            , []
            )

        {-
           COPY-PASTE PREVENTION
        -}
        CopyPasteEvent ->
            ( model
            , Cmd.none
            , [ Helpers.notify Types.NoCopyPaste ]
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
                        ( if auth.user.profile.introducedExpPlay then
                            Intro.hide
                          else
                            state
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
                loadUnshapedTreeRootSentence =
                    -- FIXME: this will fail if there are no free trees. But
                    -- that's not relevant for training, so we should fetch
                    -- non-free trees too.
                    Shaping.fetchUnshapedUntouchedTree auth
                        |> Task.map .root
                        |> Task.attempt (lift << LoadTrialResult)

                loadShapedTreeTipOrRootSentence =
                    Shaping.fetchPossiblyShapedUntouchedTree auth
                        |> Task.andThen (Shaping.selectTipSentence auth)
                        |> Task.attempt (lift << LoadTrialResult)

                loadingModel =
                    { model | experiment = ExpModel.setLoading True model.experiment }
            in
                case Lifecycle.state auth.meta auth.user.profile of
                    Lifecycle.Training _ ->
                        -- Load one remote sentence
                        ( loadingModel
                        , loadUnshapedTreeRootSentence
                        , []
                        )

                    Lifecycle.Experiment _ ->
                        -- Load one remote sentence
                        ( loadingModel
                        , loadShapedTreeTipOrRootSentence
                        , []
                        )

                    Lifecycle.Done ->
                        -- Ignore
                        ( model
                        , Cmd.none
                        , []
                        )

        LoadTrialResult (Ok current) ->
            let
                clock =
                    Clock.start (Helpers.readTime auth.meta current) TrialTask

                newTrial =
                    case model.experiment.state of
                        ExpModel.Trial trial ->
                            -- Update current trial
                            { trial
                                | current = current
                                , clock = clock
                                , state = ExpModel.Reading
                            }

                        _ ->
                            -- Create a new trial
                            ExpModel.trial current clock
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
                        , clock = Clock.start (2 * Time.second) TrialWrite
                      }
                    , Cmd.none
                    , []
                    )

        TrialWrite ->
            updateTrialOrIgnore model <|
                \trial ->
                    ( { trial
                        | state = ExpModel.Writing <| Form.empty ""
                        , clock =
                            Clock.start (Helpers.writeTime auth.meta trial.current)
                                TrialTimeout
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

        TrialStandby ->
            updateTrialOrIgnore model <|
                \trial ->
                    ( { trial | state = ExpModel.Standby, clock = Clock.disabled }
                    , Cmd.none
                    , []
                    )

        WriteInput input ->
            updateTrialOrIgnore model <|
                \trial ->
                    case trial.state of
                        ExpModel.Writing form ->
                            ( { trial
                                | state = ExpModel.Writing (Form.input input form)
                                , clock = Clock.resume trial.clock
                              }
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
            --   if yes, pause clock and submit new sentence
            --     if in training, also save trained in profile if trainingWork is reached
            let
                feedback =
                    [ Helpers.ifShorterThanWords auth.meta.minTokens
                        ( "text", Strings.sentenceTooShort auth.meta.minTokens )
                    ]
                        |> Validate.all
                        |> Feedback.fromValidator input

                newSentence trial progress =
                    { text = input
                    , language = trial.current.language
                    , bucket = trial.current.bucket
                    , readTimeProportion = 1
                    , readTimeAllotted = Helpers.readTime auth.meta trial.current
                    , writeTimeProportion = progress
                    , writeTimeAllotted = Helpers.writeTime auth.meta trial.current
                    , parentId = Just trial.current.id
                    }

                postSentence trial =
                    Clock.progress trial.clock
                        |> Task.andThen (Api.postSentence auth << newSentence trial)

                updateProfileTraining profile =
                    if profile.reformulationsCounts.training == auth.meta.trainingWork then
                        -- Save our newly trained status
                        Api.updateProfile auth { profile | trained = True }
                    else
                        Task.succeed profile

                trialFormState trial form =
                    { trial
                        | state = ExpModel.Writing form
                        , clock = Clock.pause trial.clock
                    }
            in
                updateTrialOrIgnore model <|
                    \trial ->
                        case trial.state of
                            ExpModel.Writing form ->
                                if Feedback.isEmpty feedback then
                                    case Lifecycle.state auth.meta auth.user.profile of
                                        Lifecycle.Training _ ->
                                            -- Post the new sentence
                                            ( trialFormState trial
                                                (Form.setStatus Form.Sending form)
                                            , postSentence trial
                                                |> Task.andThen updateProfileTraining
                                                |> Task.attempt (lift << WriteResult)
                                            , []
                                            )

                                        Lifecycle.Experiment _ ->
                                            -- Post the new sentence
                                            ( trialFormState trial
                                                (Form.setStatus Form.Sending form)
                                            , postSentence trial
                                                |> Task.attempt (lift << WriteResult)
                                            , []
                                            )

                                        Lifecycle.Done ->
                                            ( trial
                                            , Cmd.none
                                            , []
                                            )
                                else
                                    ( trialFormState trial (Form.fail feedback form)
                                    , Cmd.none
                                    , []
                                    )

                            _ ->
                                ( trial
                                , Cmd.none
                                , []
                                )

        WriteResult (Ok profile) ->
            -- compare previous profile lifecycle to current
            -- update profile
            -- if lifecycle has changed, JustFinished
            -- if not, Standby
            let
                stateChanged =
                    Lifecycle.state auth.meta auth.user.profile
                        /= Lifecycle.state auth.meta profile

                profileModel =
                    Helpers.updateProfile model profile
            in
                if stateChanged then
                    ( { profileModel
                        | experiment =
                            ExpModel.setState ExpModel.JustFinished
                                model.experiment
                      }
                    , Cmd.none
                    , []
                    )
                else
                    update lift auth TrialStandby profileModel

        WriteResult (Err error) ->
            Helpers.extractFeedback error model [ ( "text", "text" ) ] <|
                \feedback ->
                    updateTrialOrIgnore model <|
                        \trial ->
                            case trial.state of
                                ExpModel.Writing form ->
                                    ( { trial
                                        | state = ExpModel.Writing (Form.fail feedback form)
                                      }
                                    , Cmd.none
                                    , []
                                    )

                                _ ->
                                    ( trial
                                    , Cmd.none
                                    , []
                                    )

        Heartbeat ->
            let
                heartbeat =
                    Helpers.trialOr model Cmd.none <|
                        \{ current } ->
                            Api.heartbeatTree auth current.treeId
                                |> Task.attempt (lift << HeartbeatResult)
            in
                ( model
                , heartbeat
                , []
                )

        HeartbeatResult (Ok ()) ->
            -- Do nothing, we kept our lock
            ( model
            , Cmd.none
            , []
            )

        HeartbeatResult (Err error) ->
            -- We lost our lock, this should never happen
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
