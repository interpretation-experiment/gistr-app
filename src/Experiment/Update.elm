module Experiment.Update exposing (update)

import Experiment.Instructions as Instructions
import Experiment.Model as ExpModel
import Experiment.Msg exposing (Msg(..))
import Intro
import List.Nonempty as Nonempty
import Model exposing (Model)
import Msg as AppMsg
import Types


update :
    (Msg -> AppMsg.Msg)
    -> Types.Auth
    -> Msg
    -> Model
    -> ( Model, Cmd AppMsg.Msg, Maybe AppMsg.Msg )
update lift auth msg model =
    case msg of
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
            updateRunningInstructionsOrIgnore model <|
                \state ->
                    ( Intro.hide
                      -- TODO: set intro read
                    , Cmd.none
                    , Nothing
                    )

        StartTrial ->
            -- TODO: load sentence or use preLoaded
            Debug.crash "todo"


updateRunningOrIgnore :
    Model
    -> (ExpModel.RunningModel ()
        -> ( ExpModel.RunningModel (), Cmd AppMsg.Msg, Maybe AppMsg.Msg )
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
