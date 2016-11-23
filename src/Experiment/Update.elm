module Experiment.Update exposing (update)

import Api
import Clock
import Experiment.Instructions as Instructions
import Experiment.Model as ExpModel
import Experiment.Msg exposing (Msg(..))
import Feedback
import Form
import Helpers
import Intro
import Lifecycle
import List
import List.Nonempty as Nonempty
import Model exposing (Model)
import Msg as AppMsg
import Random
import String
import Strings
import Task
import Time
import Types
import Validate


update :
    (Msg -> AppMsg.Msg)
    -> Types.Auth
    -> Msg
    -> Model
    -> ( Model, Cmd AppMsg.Msg, Maybe AppMsg.Msg )
update lift auth msg model =
    case msg of
        NoOp ->
            ( model
            , Cmd.none
            , Nothing
            )

        UpdateProfile profile ->
            ( Helpers.updateProfile model profile
            , Cmd.none
            , Nothing
            )

        ClockMsg msg ->
            updateTrialOrIgnore model <|
                \trial ->
                    let
                        outMsg =
                            case trial.state of
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
                        , maybeOut
                        )

        {-
           INSTRUCTIONS
        -}
        InstructionsMsg msg ->
            updateInstructionsOrIgnore model <|
                \state ->
                    let
                        ( newState, maybeOut ) =
                            Intro.update (Instructions.updateConfig lift) msg state
                    in
                        ( newState
                        , Cmd.none
                        , maybeOut
                        )

        InstructionsStart ->
            -- TODO: differentiate training and exp, and set intro path accordingly
            let
                instructions =
                    ExpModel.Instructions (Intro.start Instructions.order)
            in
                ( { model | experiment = model.experiment |> ExpModel.setState instructions }
                , Cmd.none
                , Nothing
                )

        InstructionsQuit index ->
            if Nonempty.length Instructions.order == index + 1 then
                update lift auth InstructionsDone model
            else
                updateInstructionsOrIgnore model <|
                    \state ->
                        ( Intro.hide
                        , Cmd.none
                        , Nothing
                        )

        InstructionsDone ->
            let
                profile =
                    auth.user.profile

                updateProfile =
                    Api.updateProfile { profile | introducedExpPlay = True } auth
                        |> Task.perform AppMsg.Error (lift << UpdateProfile)
            in
                updateInstructionsOrIgnore model <|
                    \state ->
                        ( Intro.hide
                        , if not profile.introducedExpPlay then
                            updateProfile
                          else
                            Cmd.none
                        , Nothing
                        )

        {-
           TRIAL
        -}
        LoadTrial ->
            -- TODO: select branch in tree, not root
            let
                -- LANGUAGE VARIABLES
                mothertongue =
                    auth.user.profile.mothertongue

                isOthertongue =
                    mothertongue == auth.meta.otherLanguage

                rootLanguage =
                    if isOthertongue then
                        auth.meta.otherLanguage
                    else
                        mothertongue

                -- LANGUAGE AND BUCKET FILTER
                preFilter =
                    [ ( "root_language", rootLanguage )
                    , ( "with_other_mothertongue"
                      , String.toLower <| toString isOthertongue
                      )
                    , ( "without_other_mothertongue"
                      , String.toLower <| toString <| not isOthertongue
                      )
                    , ( "root_bucket", Lifecycle.bucket auth.meta auth.user.profile )
                    ]

                -- SEVERAL-SENTENCES FILTER
                severalFilter =
                    preFilter ++ [ ( "sample", toString auth.meta.trainingWork ) ]

                -- SINGLE-SENTENCE FILTERS
                unshapedSingleFilter =
                    preFilter
                        ++ [ ( "untouched_by_profile", toString auth.user.profile.id )
                           , ( "sample", toString 1 )
                           ]

                shapedSingleFilter =
                    unshapedSingleFilter
                        ++ [ ( "branches_count_lte"
                             , toString auth.meta.targetBranchCount
                             )
                           , ( "shortest_branch_depth_lte"
                             , toString auth.meta.targetBranchDepth
                             )
                           ]

                -- SEVERAL-SENTENCES FETCHING TASKS
                fetchSeveralSentences =
                    Api.fetchMany model.store.trees severalFilter Nothing auth
                        |> Task.map (\page -> List.map .root page.items)

                seed =
                    Time.now
                        |> Task.map (Random.initialSeed << round << Time.inMilliseconds)

                fetchRandomizedSentences =
                    Task.map2 Helpers.shuffle seed fetchSeveralSentences

                -- SINGLE-SENTENCE FETCHING TASKS
                firstRootOr default page =
                    case page.items of
                        tree :: _ ->
                            Task.succeed tree.root

                        [] ->
                            default

                fetchUnshapedSingleSentence =
                    Api.fetchMany model.store.trees unshapedSingleFilter Nothing auth
                        |> Task.andThen
                            (firstRootOr <|
                                Task.fail <|
                                    Types.Unrecoverable "Found no suitable tree for profile"
                            )

                fetchSingleSentence =
                    Api.fetchMany model.store.trees shapedSingleFilter Nothing auth
                        |> Task.andThen (firstRootOr fetchUnshapedSingleSentence)

                -- LOADING AND PRELOADING HELPERS
                selectPreloaded preLoaded =
                    case preLoaded of
                        [] ->
                            Err <| Types.Unrecoverable "No preloaded trees to select from"

                        head :: rest ->
                            Ok ( rest, head )

                preloadAndSelect =
                    fetchRandomizedSentences
                        |> Task.andThen (selectPreloaded >> Task.fromResult)
                        |> Task.perform AppMsg.Error (lift << LoadedTrial)

                loadSingle =
                    fetchSingleSentence
                        |> Task.perform AppMsg.Error (lift << LoadedTrial << (,) [])

                loadingModel =
                    { model | experiment = ExpModel.setLoading True model.experiment }
            in
                case Lifecycle.state auth.meta auth.user.profile of
                    Lifecycle.Training _ ->
                        case model.experiment.state of
                            ExpModel.JustFinished ->
                                -- Preload training sentences
                                ( loadingModel
                                , preloadAndSelect
                                , Nothing
                                )

                            ExpModel.Instructions _ ->
                                -- Preload training sentences
                                ( loadingModel
                                , preloadAndSelect
                                , Nothing
                                )

                            ExpModel.Trial trial ->
                                case selectPreloaded trial.preLoaded of
                                    Err error ->
                                        -- Load one remote sentence
                                        ( loadingModel
                                        , loadSingle
                                        , Nothing
                                        )

                                    Ok preLoadedSelected ->
                                        -- Use preloaded sentence
                                        update lift
                                            auth
                                            (LoadedTrial preLoadedSelected)
                                            model

                    Lifecycle.Experiment _ ->
                        -- Load one remote sentence
                        ( loadingModel
                        , loadSingle
                        , Nothing
                        )

                    Lifecycle.Done ->
                        -- Ignore
                        ( model
                        , Cmd.none
                        , Nothing
                        )

        LoadedTrial ( preLoaded, current ) ->
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
                , Nothing
                )

        TrialTask ->
            updateTrialOrIgnore model <|
                \trial ->
                    ( { trial
                        | state = ExpModel.Tasking
                        , clock = Clock.init <| 2 * Time.second
                      }
                    , Cmd.none
                    , Nothing
                    )

        TrialWrite ->
            updateTrialOrIgnore model <|
                \trial ->
                    ( { trial
                        | state = ExpModel.Writing <| Form.empty ""
                        , clock = Clock.init <| Helpers.writeTime auth.meta trial.current
                      }
                    , Cmd.none
                    , Nothing
                    )

        TrialTimeout ->
            updateTrialOrIgnore model <|
                \trial ->
                    ( { trial | state = ExpModel.Timeout, clock = Clock.disabled }
                    , Cmd.none
                    , Nothing
                    )

        TrialPause ->
            updateTrialOrIgnore model <|
                \trial ->
                    ( { trial | state = ExpModel.Pause, clock = Clock.disabled }
                    , Cmd.none
                    , Nothing
                    )

        WriteInput input ->
            updateTrialOrIgnore model <|
                \trial ->
                    case trial.state of
                        ExpModel.Writing form ->
                            ( { trial | state = ExpModel.Writing (Form.input input form) }
                            , Cmd.none
                            , Nothing
                            )

                        _ ->
                            ( trial
                            , Cmd.none
                            , Nothing
                            )

        WriteFail error ->
            Helpers.feedbackOrUnrecoverable error model <|
                \feedback ->
                    updateTrialOrIgnore model <|
                        \trial ->
                            case trial.state of
                                ExpModel.Writing form ->
                                    ( { trial
                                        | state =
                                            ExpModel.Writing
                                                (Form.fail feedback form)
                                        , clock = Clock.resume trial.clock
                                      }
                                    , Cmd.none
                                    , Nothing
                                    )

                                _ ->
                                    ( trial
                                    , Cmd.none
                                    , Nothing
                                    )

        WriteSubmit input ->
            -- validate if enough words
            --   if not, Fail with feedback
            --   if yes, pause clock and:
            --     if in training:
            --       if sentences left, TrialSuccess directly with same profile
            --       if nothing left, save trained in profile, getting back profile in TrialSuccess
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
                                , Api.updateProfile { profile | trained = True } auth
                                    |> Task.perform AppMsg.Error (lift << TrialSuccess)
                                , Nothing
                                )
                            else
                                -- Move directly to next training trial
                                ( trialState trial form
                                , Cmd.none
                                , Just <| lift (TrialSuccess profile)
                                )

                        Lifecycle.Experiment _ ->
                            -- Post the new sentence
                            ( trialState trial form
                            , Api.postSentence (newSentence trial) auth
                                |> Task.perform AppMsg.Error (lift << TrialSuccess)
                            , Nothing
                            )

                        Lifecycle.Done ->
                            ( trial
                            , Cmd.none
                            , Nothing
                            )

                inputInvalid trial =
                    ( trial
                    , Cmd.none
                    , Just <| lift <| WriteFail (Types.ApiFeedback feedback)
                    )
            in
                updateTrialOrIgnore model <|
                    \trial ->
                        case trial.state of
                            ExpModel.Writing form ->
                                if Feedback.isEmpty feedback then
                                    inputValid trial form
                                else
                                    inputInvalid trial

                            _ ->
                                ( trial
                                , Cmd.none
                                , Nothing
                                )

        TrialSuccess profile ->
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
                            , Nothing
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
                        , Nothing
                        )



-- HELPERS


updateTrialOrIgnore :
    Model
    -> (ExpModel.TrialModel -> ( ExpModel.TrialModel, Cmd AppMsg.Msg, Maybe AppMsg.Msg ))
    -> ( Model, Cmd AppMsg.Msg, Maybe AppMsg.Msg )
updateTrialOrIgnore model updater =
    Helpers.trialOr model ( model, Cmd.none, Nothing ) <|
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
    -> (Intro.State Instructions.Node
        -> ( Intro.State Instructions.Node, Cmd AppMsg.Msg, Maybe AppMsg.Msg )
       )
    -> ( Model, Cmd AppMsg.Msg, Maybe AppMsg.Msg )
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
            , Nothing
            )
