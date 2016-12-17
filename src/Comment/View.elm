module Comment.View exposing (view)

import Comment.Model as CommentModel
import Comment.Msg exposing (Msg(..))
import Experiment.Model as ExpModel
import Feedback
import Form
import Helpers
import Html
import Html.Attributes as Attributes
import Html.Events as Events
import Model exposing (Model)
import Msg as AppMsg
import Router
import Strings
import Styles exposing (class, classList, id)
import Types


view : (Msg -> AppMsg.Msg) -> Model -> Html.Html AppMsg.Msg
view lift model =
    let
        ( comment, active ) =
            case model.comment of
                CommentModel.Hidden ->
                    ( Form.empty Types.emptyComment, False )

                CommentModel.Showing comment ->
                    ( comment, True )

        available =
            isAvailable model
    in
        Html.div
            [ class [ Styles.CommentBoxOverlay ]
            , classList [ ( Styles.CommentBoxActive, active && available ) ]
            ]
            [ Html.div
                [ class [ Styles.CommentBox ]
                , classList
                    [ ( Styles.CommentBoxActive, active && available )
                    , ( Styles.CommentBoxHidden, not available )
                    ]
                ]
                [ header lift model.comment
                , form lift comment
                ]
            ]


isAvailable : Model -> Bool
isAvailable model =
    case model.auth of
        Types.Authenticated _ ->
            case model.route of
                Router.Home ->
                    True

                Router.About ->
                    True

                Router.Login _ ->
                    False

                Router.Recover ->
                    False

                Router.Reset _ ->
                    False

                Router.Register _ ->
                    False

                Router.Error ->
                    False

                Router.Prolific ->
                    False

                Router.Profile _ ->
                    True

                Router.Experiment ->
                    case model.experiment.state of
                        ExpModel.JustFinished ->
                            True

                        ExpModel.Instructions _ ->
                            True

                        ExpModel.Trial _ ->
                            False

                Router.Admin ->
                    True

        Types.Authenticating ->
            False

        Types.Anonymous ->
            False


header : (Msg -> AppMsg.Msg) -> CommentModel.Model -> Html.Html AppMsg.Msg
header lift model =
    Html.header
        [ Events.onClick (lift Toggle) ]
        [ Html.div [] [ Html.text "Feedback" ] ]


form : (Msg -> AppMsg.Msg) -> Form.Model Types.Comment -> Html.Html AppMsg.Msg
form lift { input, feedback, status } =
    Html.div []
        [ Html.form
            [ class [ Styles.FormPage ]
            , Events.onSubmit (lift <| CommentSubmit input)
            ]
            [ Html.div [ class [ Styles.FormBlock ] ]
                [ Html.div [ class [ Styles.InfoBox ] ]
                    [ Html.div []
                        [ Html.text Strings.commentIntro ]
                    ]
                ]
            , Html.div
                [ class [ Styles.FormBlock ]
                , Helpers.errorStyle "email" feedback
                ]
                [ Html.label [ Attributes.for "inputFeedbackEmail" ]
                    [ Html.text "Email" ]
                , Html.div [ class [ Styles.Input, Styles.Label ] ]
                    [ Html.span [ class [ Styles.Label ] ] [ Helpers.icon "envelope" ]
                    , Html.input
                        [ Attributes.id "inputFeedbackEmail"
                        , Attributes.disabled (status /= Form.Entering)
                        , Attributes.placeholder Strings.emailPlaceholder
                        , Attributes.type_ "email"
                        , Attributes.value input.email
                        , Events.onInput
                            (lift << CommentInput << \e -> { input | email = e })
                        ]
                        []
                    ]
                , Html.div [] [ Html.text (Feedback.getError "email" feedback) ]
                ]
            , Html.div
                [ class [ Styles.FormBlock ]
                , Helpers.errorStyle "text" feedback
                ]
                [ Html.label [ Attributes.for "inputFeedbackText" ] [ Html.text "Your comment" ]
                , Html.div [ class [ Styles.Input ] ]
                    [ Html.textarea
                        [ Attributes.id "inputFeedbackText"
                        , Attributes.disabled (status /= Form.Entering)
                        , Attributes.placeholder Strings.commentPlaceholder
                        , Attributes.value input.text
                        , Attributes.style [ ( "resize", "none" ), ( "overflow", "auto" ) ]
                        , Events.onInput
                            (lift << CommentInput << \t -> { input | text = t })
                        ]
                        []
                    ]
                , Html.div [] [ Html.text (Feedback.getError "text" feedback) ]
                ]
            , Html.div [ class [ Styles.FormBlock ] ]
                [ Html.div [ class [ Styles.Error ] ]
                    [ Html.text (Feedback.getError "global" feedback) ]
                , Html.div []
                    [ Html.input
                        [ Attributes.type_ "button"
                        , Attributes.disabled (status /= Form.Entering)
                        , class [ Styles.Btn ]
                        , Events.onClick (lift Hide)
                        , Attributes.value "Cancel"
                        ]
                        []
                    , Html.input
                        [ Attributes.type_ "submit"
                        , Attributes.disabled (status /= Form.Entering)
                        , class [ Styles.Btn, Styles.BtnPrimary ]
                        , Attributes.value "Send comment"
                        ]
                        []
                    ]
                ]
            ]
        ]
