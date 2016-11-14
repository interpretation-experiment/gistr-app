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
        UpdateProfile profile ->
            ( Helpers.updateProfile model profile
            , Cmd.none
            , Nothing
            )

        ClockMsg msg ->
            updateRunningTrialOrIgnore model <|
                \_ state ->
                    case state of
                        ExpModel.Reading clock ->
                            let
                                ( newClock, maybeOut ) =
                                    Clock.update (lift TrialTask) msg clock
                            in
                                ( ExpModel.Reading newClock
                                , Cmd.none
                                , maybeOut
                                )

                        ExpModel.Tasking clock ->
                            let
                                ( newClock, maybeOut ) =
                                    Clock.update (lift TrialWrite) msg clock
                            in
                                ( ExpModel.Tasking newClock
                                , Cmd.none
                                , maybeOut
                                )

                        ExpModel.Writing clock form ->
                            let
                                ( newClock, maybeOut ) =
                                    Clock.update (lift TrialTimeout) msg clock
                            in
                                ( ExpModel.Writing newClock form
                                , Cmd.none
                                , maybeOut
                                )

                        ExpModel.Timeout ->
                            ( state
                            , Cmd.none
                            , Nothing
                            )

        {-
           EXPERIMENT STATE
        -}
        Preload seed ->
            let
                mothertongue =
                    auth.user.profile.mothertongue

                isOthertongue =
                    mothertongue == auth.meta.otherLanguage

                rootLanguage =
                    if isOthertongue then
                        auth.meta.otherLanguage
                    else
                        mothertongue

                fetchTrees =
                    Api.fetchMany
                        model.store.trees
                        [ ( "root_language", rootLanguage )
                        , ( "with_other_mothertongue"
                          , String.toLower <| toString isOthertongue
                          )
                        , ( "without_other_mothertongue"
                          , String.toLower <| toString <| not isOthertongue
                          )
                        , ( "root_bucket", Lifecycle.bucket auth.meta auth.user.profile )
                        , ( "sample", toString auth.meta.trainingWork )
                        ]
                        Nothing
                        auth

                toSentences treePage =
                    treePage.items
                        |> List.map .root
                        |> Helpers.shuffle seed
            in
                case Lifecycle.state auth.meta auth.user.profile of
                    Lifecycle.Training _ ->
                        ( model
                        , fetchTrees
                            |> Task.map toSentences
                            |> Task.perform AppMsg.Error (lift << Run)
                        , Nothing
                        )

                    Lifecycle.Experiment _ ->
                        update lift auth (Run []) model

                    Lifecycle.Done ->
                        ( model
                        , Cmd.none
                        , Nothing
                        )

        Run sentences ->
            let
                runningModel =
                    { model | experiment = ExpModel.initialRunningModel sentences }

                ( newModel, cmd, outMsg ) =
                    if not auth.user.profile.introducedExpPlay then
                        update lift auth InstructionsStart runningModel
                    else
                        ( runningModel
                        , Cmd.none
                        , Nothing
                        )
            in
                case Lifecycle.state auth.meta auth.user.profile of
                    -- If in training and not enough sentences to finish it, move to Error
                    Lifecycle.Training _ ->
                        if List.length sentences < auth.meta.trainingWork then
                            update lift auth Error model
                        else
                            ( newModel
                            , cmd
                            , outMsg
                            )

                    Lifecycle.Experiment _ ->
                        ( newModel
                        , cmd
                        , outMsg
                        )

                    Lifecycle.Done ->
                        -- Ignore if the experiment is done
                        ( model
                        , Cmd.none
                        , Nothing
                        )

        Error ->
            ( { model | experiment = ExpModel.Error }
            , Cmd.none
            , Nothing
            )

        {-
           INSTRUCTIONS
        -}
        InstructionsMsg msg ->
            updateRunningInstructionsOrIgnore model <|
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
            updateRunningOrIgnore model <|
                \running ->
                    ( { running
                        | state = ExpModel.Instructions (Intro.start Instructions.order)
                      }
                    , Cmd.none
                    , Nothing
                    )

        InstructionsQuit index ->
            if index + 1 == Nonempty.length Instructions.order then
                update lift auth InstructionsDone model
            else
                updateRunningInstructionsOrIgnore model <|
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
                updateRunningInstructionsOrIgnore model <|
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
            let
                mothertongue =
                    auth.user.profile.mothertongue

                isOthertongue =
                    mothertongue == auth.meta.otherLanguage

                rootLanguage =
                    if isOthertongue then
                        auth.meta.otherLanguage
                    else
                        mothertongue

                unshapedFilter =
                    [ ( "root_language", rootLanguage )
                    , ( "with_other_mothertongue"
                      , String.toLower <| toString isOthertongue
                      )
                    , ( "without_other_mothertongue"
                      , String.toLower <| toString <| not isOthertongue
                      )
                    , ( "root_bucket", Lifecycle.bucket auth.meta auth.user.profile )
                    , ( "untouched_by_profile", toString auth.user.profile.id )
                    , ( "sample", toString 1 )
                    ]

                shapedFilter =
                    unshapedFilter
                        ++ [ ( "branches_count_lte"
                             , toString auth.meta.targetBranchCount
                             )
                           , ( "shortest_branch_depth_lte"
                             , toString auth.meta.targetBranchDepth
                             )
                           ]

                fetchUnshapedTree =
                    Api.fetchMany model.store.trees unshapedFilter Nothing auth
                        `Task.andThen`
                            \page ->
                                case page.items of
                                    tree :: _ ->
                                        Task.succeed tree

                                    [] ->
                                        Types.Unrecoverable
                                            "Found no suitable tree for profile"
                                            |> Task.fail

                fetchTree =
                    Api.fetchMany model.store.trees shapedFilter Nothing auth
                        `Task.andThen`
                            \page ->
                                case page.items of
                                    tree :: _ ->
                                        Task.succeed tree

                                    [] ->
                                        fetchUnshapedTree
            in
                updateRunningOrIgnore model <|
                    \running ->
                        case running.preLoaded of
                            [] ->
                                ( { running | loadingNext = True }
                                , fetchTree
                                    |> Task.map .root
                                    |> Task.perform AppMsg.Error (lift << LoadedTrial)
                                , Nothing
                                )

                            sentence :: rest ->
                                ( { running | preLoaded = rest, loadingNext = False }
                                , Cmd.none
                                , Just <| lift <| LoadedTrial sentence
                                )

        LoadedTrial sentence ->
            updateRunningOrIgnore model <|
                \running ->
                    let
                        reading =
                            Clock.init (Helpers.readTime auth.meta sentence)
                                |> ExpModel.Reading
                    in
                        ( { running
                            | state = ExpModel.Trial sentence reading
                            , loadingNext = False
                          }
                        , Cmd.none
                        , Nothing
                        )

        TrialTask ->
            updateRunningTrialOrIgnore model <|
                \_ _ ->
                    ( ExpModel.Tasking (Clock.init <| 2 * Time.second)
                    , Cmd.none
                    , Nothing
                    )

        TrialWrite ->
            updateRunningTrialOrIgnore model <|
                \sentence _ ->
                    ( ExpModel.Writing
                        (Clock.init <| Helpers.writeTime auth.meta sentence)
                        (Form.empty "")
                    , Cmd.none
                    , Nothing
                    )

        TrialTimeout ->
            updateRunningTrialOrIgnore model <|
                \_ _ ->
                    ( ExpModel.Timeout
                    , Cmd.none
                    , Nothing
                    )

        WriteInput input ->
            updateRunningTrialOrIgnore model <|
                \_ state ->
                    case state of
                        ExpModel.Writing clock form ->
                            ( ExpModel.Writing clock (Form.input input form)
                            , Cmd.none
                            , Nothing
                            )

                        _ ->
                            ( state
                            , Cmd.none
                            , Nothing
                            )

        WriteFail error ->
            Helpers.feedbackOrUnrecoverable error model <|
                \feedback ->
                    updateRunningTrialOrIgnore model <|
                        \_ state ->
                            case state of
                                ExpModel.Writing clock form ->
                                    ( ExpModel.Writing
                                        (Clock.resume clock)
                                        (Form.fail feedback form)
                                    , Cmd.none
                                    , Nothing
                                    )

                                _ ->
                                    ( state
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

                newSentence sentence clock =
                    { text = input
                    , language = sentence.language
                    , bucket = sentence.bucket
                    , readTimeProportion = 1
                    , readTimeAllotted = Helpers.readTime auth.meta sentence
                    , writeTimeProportion = Clock.progress clock
                    , writeTimeAllotted = Helpers.writeTime auth.meta sentence
                    , parentId = Just sentence.id
                    }

                runningState running sentence clock form =
                    { running
                        | state =
                            ExpModel.Trial sentence <|
                                ExpModel.Writing
                                    (Clock.pause clock)
                                    (Form.setStatus Form.Sending form)
                    }

                inputValid running sentence clock form =
                    case Lifecycle.state auth.meta profile of
                        Lifecycle.Training _ ->
                            -- TODO: use a running.streak variable instead
                            if List.length running.preLoaded > 0 then
                                -- Move directly to next training trial
                                ( runningState running sentence clock form
                                , Cmd.none
                                , Just <| lift (TrialSuccess profile)
                                )
                            else
                                -- Save our newly trained status
                                ( runningState running sentence clock form
                                , Api.updateProfile { profile | trained = True } auth
                                    |> Task.perform AppMsg.Error (lift << TrialSuccess)
                                , Nothing
                                )

                        Lifecycle.Experiment _ ->
                            -- Post the new sentence
                            ( runningState running sentence clock form
                            , Api.postSentence (newSentence sentence clock) auth
                                |> Task.perform AppMsg.Error (lift << TrialSuccess)
                            , Nothing
                            )

                        Lifecycle.Done ->
                            ( running
                            , Cmd.none
                            , Nothing
                            )

                inputInvalid running =
                    ( running
                    , Cmd.none
                    , Just <| lift <| WriteFail (Types.ApiFeedback feedback)
                    )
            in
                updateRunningOrIgnore model <|
                    \running ->
                        case running.state of
                            ExpModel.Trial sentence trialState ->
                                case trialState of
                                    ExpModel.Writing clock form ->
                                        if Feedback.isEmpty feedback then
                                            inputValid running sentence clock form
                                        else
                                            inputInvalid running

                                    _ ->
                                        ( running
                                        , Cmd.none
                                        , Nothing
                                        )

                            _ ->
                                ( running
                                , Cmd.none
                                , Nothing
                                )

        TrialSuccess profile ->
            -- get previous profile lifecycle
            -- update profile
            -- if lifecycle has changed, JustFinished
            -- if not, LoadTrial or Pause
            let
                previousProfile =
                    auth.user.profile

                previousState =
                    Lifecycle.state auth.meta previousProfile

                currentState =
                    Lifecycle.state auth.meta profile

                profileUpdatedModel =
                    Helpers.updateProfile model profile
            in
                updateRunningOrIgnore profileUpdatedModel <|
                    \running ->
                        if previousState /= currentState then
                            ( { running | state = ExpModel.JustFinished }
                            , Cmd.none
                            , Nothing
                            )
                        else
                            -- TODO: or pause once we have running.streak
                            ( running
                            , Cmd.none
                            , Just <| lift LoadTrial
                            )

        {-
           OTHER RUN STATE
        -}
        Pause ->
            -- TODO
            Debug.crash "todo"



-- HELPERS


updateRunningOrIgnore :
    Model
    -> (ExpModel.RunningModel
        -> ( ExpModel.RunningModel, Cmd AppMsg.Msg, Maybe AppMsg.Msg )
       )
    -> ( Model, Cmd AppMsg.Msg, Maybe AppMsg.Msg )
updateRunningOrIgnore model updater =
    Helpers.runningOr model ( model, Cmd.none, Nothing ) <|
        \running ->
            let
                ( newRunning, cmd, maybeOut ) =
                    updater running
            in
                ( { model | experiment = ExpModel.Running newRunning }
                , cmd
                , maybeOut
                )


updateRunningInstructionsOrIgnore :
    Model
    -> (Intro.State Instructions.Node
        -> ( Intro.State Instructions.Node, Cmd AppMsg.Msg, Maybe AppMsg.Msg )
       )
    -> ( Model, Cmd AppMsg.Msg, Maybe AppMsg.Msg )
updateRunningInstructionsOrIgnore model updater =
    updateRunningOrIgnore model <|
        \running ->
            case running.state of
                ExpModel.Instructions state ->
                    let
                        ( newState, cmd, maybeOut ) =
                            updater state
                    in
                        ( { running | state = ExpModel.Instructions newState }
                        , cmd
                        , maybeOut
                        )

                _ ->
                    ( running
                    , Cmd.none
                    , Nothing
                    )


updateRunningTrialOrIgnore :
    Model
    -> (Types.Sentence
        -> ExpModel.TrialState
        -> ( ExpModel.TrialState, Cmd AppMsg.Msg, Maybe AppMsg.Msg )
       )
    -> ( Model, Cmd AppMsg.Msg, Maybe AppMsg.Msg )
updateRunningTrialOrIgnore model updater =
    updateRunningOrIgnore model <|
        \running ->
            case running.state of
                ExpModel.Trial sentence state ->
                    let
                        ( newState, cmd, maybeOut ) =
                            updater sentence state
                    in
                        ( { running | state = ExpModel.Trial sentence newState }
                        , cmd
                        , maybeOut
                        )

                _ ->
                    ( running
                    , Cmd.none
                    , Nothing
                    )
