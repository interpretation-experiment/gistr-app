module Profile.View.Questionnaire exposing (view)

import Autoresize
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
    , form lift model meta
    ]


form :
    (Msg -> AppMsg.Msg)
    -> Model
    -> Types.Meta
    -> Html.Html AppMsg.Msg
form lift model meta =
    let
        { input, feedback, status } =
            model.questionnaire

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
                [ Html.div [ class [ Styles.FormBlock ], Helpers.errorStyle "informedHow" feedback ]
                    [ Html.label [ Attributes.for "inputInformedHow" ]
                        Strings.questionnaireInformedHow
                    , Autoresize.textarea
                        { lift = AppMsg.AutoresizeMsg
                        , model = model.autoresize
                        , id = "inputInformedHow"
                        , onInput =
                            lift
                                << QuestionnaireFormInput
                                << \h -> { input | informedHow = h }
                        }
                        [ Attributes.disabled (status /= Form.Entering) ]
                        input.informedHow
                    , Html.div [] [ Html.text (Feedback.getError "informedHow" feedback) ]
                    ]
                , Html.div [ class [ Styles.FormBlock ], Helpers.errorStyle "informedWhat" feedback ]
                    [ Html.label [ Attributes.for "inputInformedWhat" ]
                        Strings.questionnaireInformedWhat
                    , Autoresize.textarea
                        { lift = AppMsg.AutoresizeMsg
                        , model = model.autoresize
                        , id = "inputInformedWhat"
                        , onInput =
                            lift
                                << QuestionnaireFormInput
                                << \w -> { input | informedWhat = w }
                        }
                        [ Attributes.disabled (status /= Form.Entering) ]
                        input.informedWhat
                    , Html.div [] [ Html.text (Feedback.getError "informedWhat" feedback) ]
                    ]
                ]

        educationOption education =
            Html.option
                [ Attributes.disabled (String.isEmpty education.name)
                , Attributes.value education.name
                , Attributes.selected (input.educationLevel == education.name)
                ]
                [ Html.text education.label ]

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
                    ( [ Html.input
                            [ Attributes.type_ "submit"
                            , class [ Styles.Btn, Styles.BtnPrimary ]
                            , Attributes.value "Confirm answers"
                            ]
                            []
                      ]
                    , lift <| QuestionnaireFormConfirm input
                    )

                _ ->
                    ( [ Html.input
                            [ Attributes.type_ "button"
                            , Attributes.disabled (status /= Form.Confirming)
                            , class [ Styles.Btn ]
                            , Events.onClick (lift QuestionnaireFormCorrect)
                            , Attributes.value "Correct answers"
                            ]
                            []
                      , Html.input
                            [ Attributes.type_ "submit"
                            , Attributes.disabled (status /= Form.Confirming)
                            , class [ Styles.Btn, Styles.BtnPrimary ]
                            , Attributes.value "Send answers"
                            ]
                            []
                      ]
                    , lift <| QuestionnaireFormSubmit input
                    )
    in
        Html.form [ class [ Styles.FormPage ], Events.onSubmit submitMsg ]
            [ Html.h3 [] [ Html.text "About you" ]
            , Html.div [ class [ Styles.FormInline ], Helpers.errorStyle "age" feedback ]
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
                , Helpers.errorStyle "gender" feedback
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
            , Html.h3 [] [ Html.text "Your schooling and what you do" ]
            , Html.p [] [ Html.text Strings.questionnaireEducationJobIntro ]
            , Html.div [ class [ Styles.FormBlock ], Helpers.errorStyle "educationLevel" feedback ]
                [ Html.label [ Attributes.for "inputEducationLevel" ]
                    [ Html.strong [] [ Html.text Strings.questionnaireEducationLevel ] ]
                , Html.select
                    [ Attributes.id "inputEducationLevel"
                    , Attributes.disabled (status /= Form.Entering)
                    , Helpers.onChange <|
                        lift
                            << QuestionnaireFormInput
                            << \e -> { input | educationLevel = e }
                    ]
                    (List.map educationOption ({ name = "", label = Strings.selectPlease } :: meta.educationLevelChoices))
                , Html.div [] [ Html.text (Feedback.getError "educationLevel" feedback) ]
                ]
            , Html.div [ class [ Styles.FormBlock ], Helpers.errorStyle "educationFreetext" feedback ]
                [ Html.label [ Attributes.for "inputEducationFreetext" ]
                    Strings.questionnaireEducationFreetext
                , Autoresize.textarea
                    { lift = AppMsg.AutoresizeMsg
                    , model = model.autoresize
                    , id = "inputEducationFreetext"
                    , onInput =
                        lift
                            << QuestionnaireFormInput
                            << \t -> { input | educationFreetext = t }
                    }
                    [ Attributes.disabled (status /= Form.Entering) ]
                    input.educationFreetext
                , Html.div [] [ Html.text (Feedback.getError "educationFreetext" feedback) ]
                ]
            , Html.div [ class [ Styles.FormBlock ], Helpers.errorStyle "jobType" feedback ]
                [ Html.label [ Attributes.for "inputJobType" ]
                    [ Html.strong [] [ Html.text Strings.questionnaireJobType ] ]
                , Html.select
                    [ Attributes.id "inputJobType"
                    , Attributes.disabled (status /= Form.Entering)
                    , Helpers.onChange <|
                        lift
                            << QuestionnaireFormInput
                            << \j -> { input | jobType = j }
                    ]
                    (List.map jobOption ({ name = "", label = Strings.selectPlease } :: meta.jobTypeChoices))
                , Html.div [] [ Html.text (Feedback.getError "jobType" feedback) ]
                ]
            , Html.div [ class [ Styles.FormBlock ], Helpers.errorStyle "jobFreetext" feedback ]
                [ Html.label [ Attributes.for "inputJobFreetext" ]
                    Strings.questionnaireJobFreetext
                , Autoresize.textarea
                    { lift = AppMsg.AutoresizeMsg
                    , model = model.autoresize
                    , id = "inputJobFreetext"
                    , onInput =
                        lift
                            << QuestionnaireFormInput
                            << \t -> { input | jobFreetext = t }
                    }
                    [ Attributes.disabled (status /= Form.Entering) ]
                    input.jobFreetext
                , Html.div [] [ Html.text (Feedback.getError "jobFreetext" feedback) ]
                ]
            , Html.div
                [ class [ Styles.RequestBox, Styles.SmoothAppearing ]
                , classList [ ( Styles.Hidden, status == Form.Entering ) ]
                ]
                [ Html.div [] [ Html.p [] Strings.questionnaireCheck ] ]
            , Html.div [ class [ Styles.Error ] ]
                [ Html.div [] [ Html.text (Feedback.getError "global" feedback) ] ]
            , Html.div [ class [ Styles.FormBlock ] ] submitButtons
            , Html.p [] Strings.questionnaireComment
            ]
