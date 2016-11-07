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
            case model.experiment of
                ExpModel.Instructions state ->
                    let
                        ( newState, maybeOut ) =
                            Intro.update (Instructions.updateConfig lift) msg state

                        newModel =
                            { model | experiment = ExpModel.Instructions newState }
                    in
                        ( newModel
                        , Cmd.none
                        , maybeOut
                        )

                _ ->
                    ( model
                    , Cmd.none
                    , Nothing
                    )

        InstructionsRestart ->
            ( { model
                | experiment = ExpModel.Instructions (Intro.start Instructions.order)
              }
            , Cmd.none
            , Nothing
            )

        InstructionsQuit index ->
            if index + 1 == Nonempty.length Instructions.order then
                update lift auth InstructionsDone model
            else
                ( { model | experiment = ExpModel.Instructions Intro.hide }
                , Cmd.none
                , Nothing
                )

        InstructionsDone ->
            -- TODO: set intro read
            ( { model | experiment = ExpModel.Instructions Intro.hide }
            , Cmd.none
            , Nothing
            )

        Start ->
            -- TODO: if trained, do exp directly, if not, do training
            ( { model
                | experiment = ExpModel.Training (ExpModel.Trial () ExpModel.Reading)
              }
            , Cmd.none
            , Nothing
            )
