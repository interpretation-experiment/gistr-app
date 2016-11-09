module Experiment.Update exposing (update)

import Api
import Experiment.Instructions as Instructions
import Experiment.Model as ExpModel
import Experiment.Msg exposing (Msg(..))
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
import Types


update :
    (Msg -> AppMsg.Msg)
    -> Types.Auth
    -> Msg
    -> Model
    -> ( Model, Cmd AppMsg.Msg, Maybe AppMsg.Msg )
update lift auth msg model =
    case msg of
        PreloadTraining meta seed ->
            let
                mothertongue =
                    auth.user.profile.mothertongue

                isOthertongue =
                    mothertongue == meta.otherLanguage

                rootLanguage =
                    if isOthertongue then
                        meta.otherLanguage
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
                        , ( "sample", toString meta.trainingWork )
                        ]
                        Nothing
                        auth

                toSentences treePage =
                    treePage.items
                        |> List.map .root
                        |> Helpers.shuffle seed

                fetchForTraining =
                    fetchTrees
                        |> Task.map toSentences
                        |> Task.perform AppMsg.Error (lift << Run)

                cmd =
                    if Lifecycle.mustTrainExperiment auth.user.profile then
                        fetchForTraining
                    else
                        Cmd.none
            in
                ( model
                , cmd
                , Just <| AppMsg.GotMeta meta
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
                        , updateProfile
                        , Nothing
                        )

        {-
           TRIAL
        -}
        StartTrial ->
            -- TODO: load sentence or use preLoaded
            Debug.crash "todo"



-- HELPERS


updateRunningOrIgnore :
    Model
    -> (ExpModel.RunningModel
        -> ( ExpModel.RunningModel, Cmd AppMsg.Msg, Maybe AppMsg.Msg )
       )
    -> ( Model, Cmd AppMsg.Msg, Maybe AppMsg.Msg )
updateRunningOrIgnore model updater =
    case model.experiment of
        ExpModel.Running running ->
            let
                ( newRunning, cmd, maybeOut ) =
                    updater running
            in
                ( { model | experiment = ExpModel.Running newRunning }
                , cmd
                , maybeOut
                )

        _ ->
            ( model
            , Cmd.none
            , Nothing
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
