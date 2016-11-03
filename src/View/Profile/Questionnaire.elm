module View.Profile.Questionnaire exposing (view)

import Feedback
import Form
import Helpers
import Html
import Html.Attributes as Attributes
import Html.Events as Events
import Model exposing (Model)
import Msg exposing (Msg)
import String
import Strings
import Types


view : Model -> Html.Html Msg
view model =
    let
        form' =
            case model.store.meta of
                Nothing ->
                    Helpers.loading

                Just meta ->
                    form model.questionnaire meta
    in
        Html.div []
            [ Html.h2 [] [ Html.text "General questionnaire" ]
            , intro model.questionnaire
            , form'
            ]


intro : Form.Model Types.QuestionnaireForm -> Html.Html Msg
intro { status } =
    case status of
        Form.Entering ->
            Html.div [] (List.map (\p -> Html.p [] [ Html.text p ]) Strings.questionnaireIntro)

        _ ->
            Html.div [] Strings.questionnaireCheck


form : Form.Model Types.QuestionnaireForm -> Types.Meta -> Html.Html Msg
form { input, feedback, status } meta =
    let
        genderRadio gender =
            Html.label []
                [ Html.input
                    [ Attributes.disabled (status /= Form.Entering)
                    , Attributes.type' "radio"
                    , Attributes.value gender.name
                    , Attributes.checked (input.gender == gender.name)
                    , Events.onCheck
                        (always <|
                            Msg.QuestionnaireFormInput { input | gender = gender.name }
                        )
                    ]
                    []
                , Html.text gender.label
                ]

        informedDetails =
            Html.div []
                [ Html.div []
                    [ Html.label [ Attributes.for "inputInformedHow" ]
                        Strings.questionnaireInformedHow
                    , Html.textarea
                        [ Attributes.id "inputInformedHow"
                        , Attributes.disabled (status /= Form.Entering)
                        , Attributes.value input.informedHow
                        , Events.onInput (Msg.QuestionnaireFormInput << \h -> { input | informedHow = h })
                        ]
                        []
                    , Html.span [] [ Html.text (Feedback.getError "informedHow" feedback) ]
                    ]
                , Html.div []
                    [ Html.label [ Attributes.for "inputInformedWhat" ]
                        Strings.questionnaireInformedWhat
                    , Html.textarea
                        [ Attributes.id "inputInformedWhat"
                        , Attributes.disabled (status /= Form.Entering)
                        , Attributes.value input.informedWhat
                        , Events.onInput (Msg.QuestionnaireFormInput << \w -> { input | informedWhat = w })
                        ]
                        []
                    , Html.span [] [ Html.text (Feedback.getError "informedWhat" feedback) ]
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
                    ( [ Html.button [ Attributes.type' "submit" ]
                            [ Html.text "Confirm answers" ]
                      ]
                    , Msg.QuestionnaireFormConfirm input
                    )

                _ ->
                    ( [ Helpers.evButton
                            [ Attributes.disabled (status /= Form.Confirming) ]
                            Msg.QuestionnaireFormCorrect
                            "Correct answers"
                      , Html.button
                            [ Attributes.type' "submit"
                            , Attributes.disabled (status /= Form.Confirming)
                            ]
                            [ Html.text "Send answers" ]
                      ]
                    , Msg.QuestionnaireFormSubmit input
                    )
    in
        Html.form [ Events.onSubmit submitMsg ]
            [ Html.h3 [] [ Html.text "About you" ]
            , Html.div []
                [ Html.label [ Attributes.for "inputAge" ]
                    [ Html.strong [] [ Html.text "Age" ] ]
                , Html.input
                    [ Attributes.id "inputAge"
                    , Attributes.disabled (status /= Form.Entering)
                    , Attributes.type' "number"
                    , Attributes.value input.age
                    , Events.onInput (Msg.QuestionnaireFormInput << \a -> { input | age = a })
                    ]
                    []
                , Html.span [] [ Html.text (Feedback.getError "age" feedback) ]
                ]
            , Html.div []
                [ Html.label [ Attributes.for "inputGender" ]
                    [ Html.strong [] [ Html.text "Gender" ] ]
                , Html.div [] (List.map genderRadio meta.genderChoices)
                , Html.span [] [ Html.text (Feedback.getError "gender" feedback) ]
                ]
            , Html.div []
                [ Html.label [ Attributes.for "inputInformed" ]
                    [ Html.input
                        [ Attributes.id "inputInformed"
                        , Attributes.disabled (status /= Form.Entering)
                        , Attributes.type' "checkbox"
                        , Attributes.value "informed"
                        , Attributes.checked input.informed
                        , Events.onCheck
                            (Msg.QuestionnaireFormInput
                                << \i -> { input | informed = i, informedHow = "", informedWhat = "" }
                            )
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
            , Html.div []
                [ Html.label [ Attributes.for "inputJobType" ]
                    [ Html.strong [] [ Html.text Strings.questionnaireJobType ] ]
                , Html.select
                    [ Attributes.id "inputJobType"
                    , Attributes.disabled (status /= Form.Entering)
                    , Events.onInput (Msg.QuestionnaireFormInput << \j -> { input | jobType = j })
                    ]
                    (List.map jobOption ({ name = "", label = Strings.selectPlease } :: meta.jobTypeChoices))
                , Html.span [] [ Html.text (Feedback.getError "jobType" feedback) ]
                ]
            , Html.div []
                [ Html.label [ Attributes.for "inputJobFreetext" ]
                    Strings.questionnaireJobFreetext
                , Html.textarea
                    [ Attributes.id "inputJobFreetext"
                    , Attributes.disabled (status /= Form.Entering)
                    , Attributes.value input.jobFreetext
                    , Events.onInput (Msg.QuestionnaireFormInput << \t -> { input | jobFreetext = t })
                    ]
                    []
                , Html.span [] [ Html.text (Feedback.getError "jobFreetext" feedback) ]
                ]
            , Html.div []
                ((Html.span [] [ Html.text (Feedback.getError "global" feedback) ]) :: submitButtons)
            , Html.p [] Strings.questionnaireComment
            ]
