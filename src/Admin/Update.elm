module Admin.Update exposing (update)

import Admin.Model as AdminModel
import Admin.Msg exposing (Msg(..))
import Api
import Feedback
import Form
import Helpers
import Model exposing (Model)
import Msg as AppMsg
import Strings
import Task
import Types
import Validate


update :
    (Msg -> AppMsg.Msg)
    -> Types.Auth
    -> Msg
    -> Model
    -> ( Model, Cmd AppMsg.Msg, List AppMsg.Msg )
update lift auth msg model =
    case msg of
        WriteInput input ->
            ( { model | admin = Form.input input model.admin }
            , Cmd.none
            , []
            )

        WriteSubmit input ->
            let
                feedback =
                    [ .text
                        >> Helpers.ifShorterThanWords auth.meta.minTokens
                            ( "text", Strings.sentenceTooShort auth.meta.minTokens )
                    , .bucket
                        >> Validate.ifBlank ( "bucket", Strings.bucketPlease )
                    ]
                        |> Validate.all
                        |> Feedback.fromValidator input
            in
                if Feedback.isEmpty feedback then
                    ( { model | admin = Form.setStatus Form.Sending model.admin }
                    , Api.postSentence auth input
                        |> Task.attempt (lift << WriteResult)
                    , []
                    )
                else
                    ( { model | admin = Form.fail feedback model.admin }
                    , Cmd.none
                    , []
                    )

        WriteResult (Ok profile) ->
            let
                feedback =
                    Feedback.setGlobalSuccess Strings.adminSentenceCreated
                        model.admin.feedback

                newForm =
                    Form.succeed AdminModel.emptyForm feedback model.admin
            in
                ( Helpers.updateProfile
                    { model | admin = newForm }
                    profile
                , Cmd.none
                , []
                )

        WriteResult (Err error) ->
            Helpers.extractFeedback error
                model
                [ ( "text", "text" )
                , ( "bucket", "bucket" )
                ]
            <|
                \feedback ->
                    ( { model | admin = Form.fail feedback model.admin }
                    , Cmd.none
                    , []
                    )
