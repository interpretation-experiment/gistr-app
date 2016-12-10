module Profile.View.Questionnaire exposing (view)

import Feedback
import Form
import Helpers
import Html
import Html.Attributes as Attributes
import Html.Events as Events
import Model exposing (Model)
import Msg as AppMsg
import Profile.Msg exposing (Msg(..))
import String
import Strings
import Styles exposing (class, classList, id)
import Types


view : (Msg -> AppMsg.Msg) -> Model -> Types.Meta -> List (Html.Html AppMsg.Msg)
view lift model meta =
    [ Html.h2 [] [ Html.text "General questionnaire" ]
    , Html.div [] (List.map (\p -> Html.p [] [ Html.text p ]) Strings.questionnaireIntro)
    , form lift model.questionnaire meta
    ]


form :
    (Msg -> AppMsg.Msg)
    -> Form.Model Types.QuestionnaireForm
    -> Types.Meta
    -> Html.Html AppMsg.Msg
form lift { input, feedback, status } meta =
    let
        genderRadio gender =
            Html.label []
                [ Html.input
                    [ Attributes.disabled (status /= Form.Entering)
                    , Attributes.type_ "radio"
                    , Attributes.value gender.name
                    , Attributes.checked (input.gender == gender.name)
                    , Events.onCheck <|
                        always <|
                            lift <|
                                QuestionnaireFormInput { input | gender = gender.name }
                    ]
                    []
                , Html.text gender.label
                ]

        informedDetails =
            Html.div [ class [ Styles.FormPage ] ]
                [ Html.div [ class [ Styles.FormBlock ], Helpers.feedbackStyles "informedHow" feedback ]
                    [ Html.label [ Attributes.for "inputInformedHow" ]
                        Strings.questionnaireInformedHow
                    , Helpers.textarea
                        [ Attributes.id "inputInformedHow"
                        , classList [ ( Styles.Disabled, status /= Form.Entering ) ]
                        , Helpers.onInputContent <|
                            lift
                                << QuestionnaireFormInput
                                << \h -> { input | informedHow = h }
                        ]
                    , Html.div [] [ Html.text (Feedback.getError "informedHow" feedback) ]
                    ]
                , Html.div [ class [ Styles.FormBlock ], Helpers.feedbackStyles "informedWhat" feedback ]
                    [ Html.label [ Attributes.for "inputInformedWhat" ]
                        Strings.questionnaireInformedWhat
                    , Helpers.textarea
                        [ Attributes.id "inputInformedWhat"
                        , classList [ ( Styles.Disabled, status /= Form.Entering ) ]
                        , Helpers.onInputContent <|
                            lift
                                << QuestionnaireFormInput
                                << \w -> { input | informedWhat = w }
                        ]
                    , Html.div [] [ Html.text (Feedback.getError "informedWhat" feedback) ]
                    ]
                ]

        jobOption job =
            Html.option
                [ Attributes.disabled (String.isEmpty job.name)
                , Attributes.value job.name
                , Attributes.selected (input.jobType == job.name)
                ]
                [ Html.text job.label ]

        ( submitButtons, submitMsg ) =
            case status of
                Form.Entering ->
                    ( [ Html.button
                            [ Attributes.type_ "submit"
                            , class [ Styles.Btn, Styles.BtnPrimary ]
                            ]
                            [ Html.text "Confirm answers" ]
                      ]
                    , lift <| QuestionnaireFormConfirm input
                    )

                _ ->
                    ( [ Helpers.evButton
                            [ Attributes.disabled (status /= Form.Confirming)
                            , class [ Styles.Btn ]
                            ]
                            (lift QuestionnaireFormCorrect)
                            "Correct answers"
                      , Html.button
                            [ Attributes.type_ "submit"
                            , Attributes.disabled (status /= Form.Confirming)
                            , class [ Styles.Btn, Styles.BtnPrimary ]
                            ]
                            [ Html.text "Send answers" ]
                      ]
                    , lift <| QuestionnaireFormSubmit input
                    )
    in
        Html.form [ class [ Styles.FormPage ], Events.onSubmit submitMsg ]
            [ Html.h3 [] [ Html.text "About you" ]
            , Html.div [ class [ Styles.FormInline ], Helpers.feedbackStyles "age" feedback ]
                [ Html.label [ Attributes.for "inputAge" ]
                    [ Html.strong [] [ Html.text "Age" ] ]
                , Html.div [ class [ Styles.Input ] ]
                    [ Html.input
                        [ Attributes.id "inputAge"
                        , Attributes.disabled (status /= Form.Entering)
                        , Attributes.type_ "number"
                        , Attributes.value input.age
                        , Events.onInput <|
                            lift
                                << QuestionnaireFormInput
                                << \a -> { input | age = a }
                        ]
                        []
                    ]
                , Html.div [] [ Html.text (Feedback.getError "age" feedback) ]
                ]
            , Html.div
                [ class [ Styles.FormBlock ]
                , Helpers.feedbackStyles "gender" feedback
                ]
                [ Html.label [ Attributes.for "inputGender" ]
                    [ Html.strong [] [ Html.text "Gender" ] ]
                , Html.div [ Attributes.id "inputGender" ]
                    (List.map genderRadio meta.genderChoices)
                , Html.div [] [ Html.text (Feedback.getError "gender" feedback) ]
                ]
            , Html.div [ class [ Styles.FormBlock ] ]
                [ Html.label [ Attributes.for "inputInformed" ]
                    [ Html.input
                        [ Attributes.id "inputInformed"
                        , Attributes.disabled (status /= Form.Entering)
                        , Attributes.type_ "checkbox"
                        , Attributes.value "informed"
                        , Attributes.checked input.informed
                        , Events.onCheck <|
                            lift
                                << QuestionnaireFormInput
                                << \i -> { input | informed = i, informedHow = "", informedWhat = "" }
                        ]
                        []
                    , Html.text Strings.questionnaireInformed
                    ]
                ]
            , if input.informed then
                informedDetails
              else
                Html.div [] []
            , Html.h3 [] [ Html.text "What you do" ]
            , Html.p [] [ Html.text Strings.questionnaireJobIntro ]
            , Html.div [ class [ Styles.FormBlock ], Helpers.feedbackStyles "jobType" feedback ]
                [ Html.label [ Attributes.for "inputJobType" ]
                    [ Html.strong [] [ Html.text Strings.questionnaireJobType ] ]
                , Html.select
                    [ Attributes.id "inputJobType"
                    , Attributes.disabled (status /= Form.Entering)
                    , Events.onInput <|
                        lift
                            << QuestionnaireFormInput
                            << \j -> { input | jobType = j }
                    ]
                    (List.map jobOption ({ name = "", label = Strings.selectPlease } :: meta.jobTypeChoices))
                , Html.div [] [ Html.text (Feedback.getError "jobType" feedback) ]
                ]
            , Html.div [ class [ Styles.FormBlock ], Helpers.feedbackStyles "jobFreetext" feedback ]
                [ Html.label [ Attributes.for "inputJobFreetext" ]
                    Strings.questionnaireJobFreetext
                , Helpers.textarea
                    [ Attributes.id "inputJobFreetext"
                    , classList [ ( Styles.Disabled, status /= Form.Entering ) ]
                    , Helpers.onInputContent <|
                        lift
                            << QuestionnaireFormInput
                            << \t -> { input | jobFreetext = t }
                    ]
                , Html.div [] [ Html.text (Feedback.getError "jobFreetext" feedback) ]
                ]
            , Html.div
                [ class [ Styles.RequestBox, Styles.SmoothAppearing ]
                , classList [ ( Styles.Hidden, status == Form.Entering ) ]
                ]
                [ Html.div [] [ Html.p [] Strings.questionnaireCheck ] ]
            , Html.div [ class [ Styles.Error ] ]
                ((Html.div [] [ Html.text (Feedback.getError "global" feedback) ]) :: submitButtons)
            , Html.p [] Strings.questionnaireComment
            ]
