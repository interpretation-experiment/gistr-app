module View.Notification exposing (config)

import Helpers
import Html
import Msg exposing (Msg)
import Notification
import Strings
import Styles exposing (class, classList, id)
import Types


config : Notification.ViewConfig Types.NotificationId Msg
config =
    Notification.viewConfig Msg.NotificationMsg template


template : Types.NotificationId -> Msg -> Html.Html Msg
template id dismiss =
    let
        ( title, content, style ) =
            elements id
    in
        Html.div [ class [ style ] ]
            [ Helpers.evIconButton [] dismiss "close"
            , Html.p [] [ Html.strong [] [ Html.text title ] ]
            , Html.div [] [ content ]
            ]


elements : Types.NotificationId -> ( String, Html.Html Msg, Styles.CssClasses )
elements id =
    case id of
        Types.RecoverPasswordNoEmail ->
            ( Strings.recoverPasswordNoEmailTitle
            , Strings.recoverPasswordNoEmail
            , Styles.WarningNotification
            )

        Types.RecoverPasswordSent email ->
            ( Strings.recoverPasswordSentTitle
            , Strings.recoverPasswordSent email
            , Styles.InfoNotification
            )

        Types.VerifyEmailSent email ->
            ( Strings.verifyEmailSentTitle
            , Strings.verifyEmailSent email
            , Styles.InfoNotification
            )

        Types.EmailConfirmed ->
            ( Strings.emailConfirmedTitle
            , Strings.emailConfirmed
            , Styles.SuccessNotification
            )

        Types.QuestionnaireCompleted ->
            ( Strings.questionnaireCompletedTitle
            , Strings.questionnaireCompleted
            , Styles.SuccessNotification
            )

        Types.NoCopyPaste ->
            ( Strings.expNoCopyPasteTitle
            , Strings.expNoCopyPaste
            , Styles.WarningNotification
            )

        Types.CommentSent ->
            ( Strings.commentSentTitle
            , Strings.commentSent
            , Styles.SuccessNotification
            )
