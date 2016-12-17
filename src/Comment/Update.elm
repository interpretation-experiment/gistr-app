module Comment.Update exposing (update)

import Api
import Comment.Model as CommentModel
import Comment.Msg exposing (Msg(..))
import Form
import Helpers
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
        Hide ->
            ( { model | comment = CommentModel.Hidden }
            , Cmd.none
            , []
            )

        Show ->
            let
                newComment =
                    CommentModel.Showing <|
                        Form.empty <|
                            Types.commentFromUserMeta auth.user
                                ("route: " ++ toString model.route)
            in
                ( { model | comment = newComment }
                , Cmd.none
                , []
                )

        Toggle ->
            case model.comment of
                CommentModel.Hidden ->
                    update lift auth Show model

                CommentModel.Showing _ ->
                    update lift auth Hide model

        CommentInput comment ->
            showingOrIgnore model <|
                \form ->
                    ( Form.input comment form
                    , Cmd.none
                    , []
                    )

        CommentSubmit comment ->
            showingOrIgnore model <|
                \form ->
                    ( Form.setStatus Form.Sending form
                    , Api.postComment auth comment
                        |> Task.attempt (lift << CommentResult)
                    , []
                    )

        CommentResult (Ok profile) ->
            ( Helpers.updateProfile { model | comment = CommentModel.Hidden } profile
            , Cmd.none
            , [ Helpers.notify Types.CommentSent ]
            )

        CommentResult (Err error) ->
            showingOrIgnore model <|
                \form ->
                    Helpers.extractFeedback error
                        form
                        [ ( "email", "email" )
                        , ( "text", "text" )
                        ]
                    <|
                        \feedback ->
                            ( Form.fail feedback form
                            , Cmd.none
                            , []
                            )



-- HELPERS


showingOrIgnore :
    Model
    -> (Form.Model Types.Comment
        -> ( Form.Model Types.Comment, Cmd AppMsg.Msg, List AppMsg.Msg )
       )
    -> ( Model, Cmd AppMsg.Msg, List AppMsg.Msg )
showingOrIgnore model func =
    case model.comment of
        CommentModel.Hidden ->
            ( model
            , Cmd.none
            , []
            )

        CommentModel.Showing form ->
            let
                ( newForm, cmd, out ) =
                    func form
            in
                ( { model | comment = CommentModel.Showing newForm }
                , cmd
                , out
                )
