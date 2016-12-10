module Admin.View exposing (view)

import Admin.Model as AdminModel
import Admin.Msg exposing (Msg(..))
import Animation
import Feedback
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


view : (Msg -> AppMsg.Msg) -> Model -> List (Html.Html AppMsg.Msg)
view lift model =
    case model.auth of
        Types.Authenticated auth ->
            if auth.user.isStaff then
                [ Html.header [] header
                , Html.main_ []
                    [ Html.div [ class [ Styles.Narrow ] ]
                        (body lift model.admin auth.meta)
                    ]
                ]
            else
                [ Helpers.notStaff ]

        Types.Authenticating ->
            [ Helpers.loading Styles.Big ]

        Types.Anonymous ->
            [ Helpers.notAuthed ]


header : List (Html.Html AppMsg.Msg)
header =
    [ Html.nav [] [ Helpers.navIcon [ class [ Styles.Big ] ] Router.Home "home" ]
    , Html.h1 [] [ Html.text "Admin" ]
    ]


body :
    (Msg -> AppMsg.Msg)
    -> AdminModel.Model
    -> Types.Meta
    -> List (Html.Html AppMsg.Msg)
body lift { input, feedback, status } meta =
    let
        bucketRadio bucket =
            Html.label []
                [ Html.input
                    [ Attributes.disabled (status /= Form.Entering)
                    , Attributes.type_ "radio"
                    , Attributes.value bucket.name
                    , Attributes.checked (input.bucket == bucket.name)
                    , Events.onCheck <|
                        always <|
                            lift <|
                                WriteInput { input | bucket = bucket.name }
                    ]
                    []
                , Html.text bucket.label
                ]
    in
        [ Html.h2 [] [ Html.text Strings.adminAddSentence ]
        , Html.form
            [ class [ Styles.FormPage ], Events.onSubmit (lift <| WriteSubmit input) ]
            [ Html.div
                [ class [ Styles.FormBlock ]
                , Helpers.feedbackStyles "text" feedback
                ]
                [ Html.label [ Helpers.forId Styles.InputAutofocus ]
                    [ Html.text Strings.adminTypeSentence ]
                , Helpers.textarea
                    [ id Styles.InputAutofocus
                    , Attributes.autofocus True
                    , classList [ ( Styles.Disabled, status /= Form.Entering ) ]
                    , Helpers.onInputContent <|
                        lift
                            << WriteInput
                            << \t -> { input | text = t }
                    ]
                , Html.div [] [ Html.text (Feedback.getError "text" feedback) ]
                ]
            , Html.div
                [ class [ Styles.FormBlock ]
                , Helpers.feedbackStyles "bucket" feedback
                ]
                [ Html.label [ Attributes.for "inputBucket" ]
                    [ Html.strong [] [ Html.text Strings.adminCreateBucket ] ]
                , Html.div [ Attributes.id "inputBucket" ]
                    (List.map bucketRadio meta.bucketChoices)
                , Html.div [] [ Html.text (Feedback.getError "bucket" feedback) ]
                ]
            , Html.div [ class [ Styles.Error ] ]
                [ Html.div [] [ Html.text (Feedback.getError "global" feedback) ] ]
            , Html.button
                [ Attributes.type_ "submit"
                , Attributes.disabled (status /= Form.Entering)
                , class [ Styles.Btn, Styles.BtnPrimary ]
                ]
                [ Html.text "Create sentence" ]
            , Html.span
                ((Animation.render <| Feedback.getSuccess "global" feedback)
                    ++ [ class [ Styles.BadgeSuccess ] ]
                )
                [ Html.text Strings.adminSentenceCreated ]
            ]
        ]
