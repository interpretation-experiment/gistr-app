module Experiment.Update exposing (update)

import Api
import Clock
import Experiment.Instructions as Instructions
import Experiment.Model as ExpModel
import Experiment.Msg exposing (Msg(..))
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
import Task
import Time
import Types


update :
    (Msg -> AppMsg.Msg)
    -> Types.Auth
    -> Msg
    -> Model
    -> ( Model, Cmd AppMsg.Msg, Maybe AppMsg.Msg )
update lift auth msg model =
    case msg of
        PreloadTraining seed ->
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
                        , ( "root_bucket", Lifecycle.bucket auth.user.profile )
                        , ( "sample", toString auth.meta.trainingWork )
                        ]
                        Nothing
                        auth

                toSentences treePage =
                    treePage.items
                        |> List.map .root
                        |> Helpers.shuffle seed

                cmd =
                    case Lifecycle.state auth.user.profile of
                        Lifecycle.Training _ ->
                            fetchTrees
                                |> Task.map toSentences
                                |> Task.perform AppMsg.Error (lift << Run)

                        Lifecycle.Experiment _ ->
                            Cmd.none
            in
                ( model
                , cmd
                , Nothing
                )

        Run sentences ->
            let
                newModel =
                    { model | experiment = ExpModel.initialRunningModel sentences }
            in
                if not auth.user.profile.introducedExpPlay then
                    update lift auth InstructionsStart newModel
                else
                    ( newModel
                    , Cmd.none
                    , Nothing
                    )

        Error ->
            ( { model | experiment = ExpModel.Error }
            , Cmd.none
            , Nothing
            )

        UpdateProfile profile ->
            ( Helpers.updateProfile model profile
            , Cmd.none
            , Nothing
            )

        ClockMsg msg ->
            updateRunningTrialOrIgnore model <|
                \_ _ state ->
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
                \_ running ->
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
        StartTrial ->
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
                    , ( "root_bucket", Lifecycle.bucket auth.user.profile )
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
                                        Types.Unrecoverable "Found no suitable tree for profile"
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
                    \_ running ->
                        case running.preLoaded of
                            [] ->
                                ( { running | loadingNext = True }
                                , fetchTree
                                    |> Task.map .root
                                    |> Task.perform AppMsg.Error (lift << TrialRead)
                                , Nothing
                                )

                            sentence :: rest ->
                                ( { running | preLoaded = rest, loadingNext = False }
                                , Cmd.none
                                , Just <| lift <| TrialRead sentence
                                )

        TrialRead sentence ->
            updateRunningOrIgnore model <|
                \auth running ->
                    let
                        reading =
                            Clock.init (Helpers.readTime auth.meta sentence)
                                |> ExpModel.Reading
                    in
                        ( { running | state = ExpModel.Trial sentence reading }
                        , Cmd.none
                        , Nothing
                        )

        TrialTask ->
            updateRunningTrialOrIgnore model <|
                \_ _ _ ->
                    ( ExpModel.Tasking (Clock.init <| 2 * Time.second)
                    , Cmd.none
                    , Nothing
                    )

        TrialWrite ->
            updateRunningTrialOrIgnore model <|
                \auth sentence _ ->
                    ( ExpModel.Writing
                        (Clock.init <| Helpers.writeTime auth.meta sentence)
                        (Form.empty ())
                    , Cmd.none
                    , Nothing
                    )

        TrialTimeout ->
            updateRunningTrialOrIgnore model <|
                \_ _ _ ->
                    ( ExpModel.Timeout
                    , Cmd.none
                    , Nothing
                    )



-- HELPERS


updateRunningOrIgnore :
    Model
    -> (Types.Auth
        -> ExpModel.RunningModel
        -> ( ExpModel.RunningModel, Cmd AppMsg.Msg, Maybe AppMsg.Msg )
       )
    -> ( Model, Cmd AppMsg.Msg, Maybe AppMsg.Msg )
updateRunningOrIgnore model updater =
    Helpers.authenticatedOr model ( model, Cmd.none, Nothing ) <|
        \auth ->
            Helpers.runningOr model ( model, Cmd.none, Nothing ) <|
                \running ->
                    let
                        ( newRunning, cmd, maybeOut ) =
                            updater auth running
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
        \_ running ->
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
    -> (Types.Auth
        -> Types.Sentence
        -> ExpModel.TrialState
        -> ( ExpModel.TrialState, Cmd AppMsg.Msg, Maybe AppMsg.Msg )
       )
    -> ( Model, Cmd AppMsg.Msg, Maybe AppMsg.Msg )
updateRunningTrialOrIgnore model updater =
    updateRunningOrIgnore model <|
        \auth running ->
            case running.state of
                ExpModel.Trial sentence state ->
                    let
                        ( newState, cmd, maybeOut ) =
                            updater auth sentence state
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
