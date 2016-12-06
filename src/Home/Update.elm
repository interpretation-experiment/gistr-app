module Home.Update exposing (update)

import Api
import Helpers
import Home.Instructions as Instructions
import Home.Msg exposing (Msg(..))
import Intro
import List.Nonempty as Nonempty
import Maybe.Extra exposing (maybeToList)
import Model exposing (Model)
import Msg as AppMsg
import Task
import Types


update :
    (Msg -> AppMsg.Msg)
    -> Types.Auth
    -> Msg
    -> Model
    -> ( Model, Cmd AppMsg.Msg, List AppMsg.Msg )
update lift auth msg model =
    case msg of
        InstructionsMsg msg ->
            let
                ( newHome, maybeOut ) =
                    Intro.update (Instructions.updateConfig lift) msg model.home
            in
                ( { model | home = newHome }
                , Cmd.none
                , maybeToList maybeOut
                )

        InstructionsStart ->
            -- TODO: differentiate training and exp, and set intro path accordingly
            ( { model | home = Intro.start Instructions.order }
            , Cmd.none
            , []
            )

        InstructionsQuit index ->
            if Nonempty.length Instructions.order == index + 1 then
                ( model
                , Cmd.none
                , [ lift InstructionsDone ]
                )
            else
                ( { model | home = Intro.hide }
                , Cmd.none
                , []
                )

        InstructionsDone ->
            let
                profile =
                    auth.user.profile

                updateProfile =
                    Api.updateProfile auth { profile | introducedExpHome = True }
                        |> Task.attempt (lift << InstructionsDoneResult)
            in
                ( { model | home = Intro.hide }
                , if not profile.introducedExpHome then
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
