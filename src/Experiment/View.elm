module Experiment.View exposing (view, instructions)

import Clock
import Experiment.Model as ExpModel
import Experiment.Msg exposing (Msg(..))
import Feedback
import Form
import Helpers
import Html
import Html.Attributes as Attributes
import Html.Events as Events
import Intro
import Lifecycle
import List.Nonempty as Nonempty
import List.Nonempty exposing (Nonempty)
import Model exposing (Model)
import Msg as AppMsg
import Router
import Strings
import Styles exposing (class, classList, id)
import Types


-- INSTRUCTIONS


instructionsConfig : (Msg -> AppMsg.Msg) -> Intro.ViewConfig ExpModel.Node AppMsg.Msg
instructionsConfig lift =
    Intro.viewConfig
        { liftMsg = lift << InstructionsMsg
        , tooltip = (\i -> Tuple.second (Nonempty.get i instructions))
        }


instructions : Nonempty ( ExpModel.Node, ( Intro.Position, Html.Html AppMsg.Msg ) )
instructions =
    -- TODO: move to Strings.elm
    Nonempty.Nonempty
        ( ExpModel.Title, ( Intro.Bottom, Html.p [] [ Html.text "This is the title!" ] ) )
        [ ( ExpModel.A, ( Intro.Right, Html.p [] [ Html.text "This is stuff A" ] ) )
        , ( ExpModel.A, ( Intro.Top, Html.p [] [ Html.text "This is stuff A again" ] ) )
        , ( ExpModel.B, ( Intro.Left, Html.p [] [ Html.text "And finally stuff B" ] ) )
        ]



-- VIEW


view : (Msg -> AppMsg.Msg) -> Model -> List (Html.Html AppMsg.Msg)
view lift model =
    case model.auth of
        Types.Authenticated { user, meta } ->
            [ Html.header [] (header lift user.profile meta model.experiment)
            , Html.main_ [] [ (body lift user.profile meta model.experiment) ]
            ]

        Types.Authenticating ->
            [ Helpers.loading Styles.Big ]

        Types.Anonymous ->
            [ Helpers.notAuthed ]



-- HEADER


header :
    (Msg -> AppMsg.Msg)
    -> Types.Profile
    -> Types.Meta
    -> ExpModel.Model
    -> List (Html.Html AppMsg.Msg)
header lift profile meta model =
    let
        title =
            case Lifecycle.state meta profile of
                Lifecycle.Training _ ->
                    "Experiment — Training"

                Lifecycle.Experiment _ ->
                    "Experiment"

                Lifecycle.Done ->
                    "Experiment — Done"
    in
        [ Html.nav [] [ Helpers.navIcon [ class [ Styles.Big ] ] Router.Home "home" ]
        , Intro.node
            (instructionsConfig lift)
            (ExpModel.instructionsState model)
            ExpModel.Title
            Html.h1
            []
            [ Html.text title ]
        ]



-- BODY


body :
    (Msg -> AppMsg.Msg)
    -> Types.Profile
    -> Types.Meta
    -> ExpModel.Model
    -> Html.Html AppMsg.Msg
body lift profile meta model =
    let
        expView =
            case model.state of
                ExpModel.JustFinished ->
                    Html.div [ class [ Styles.Narrow ] ]
                        [ Html.div [] [ Html.text "TODO: just finished previous run" ] ]

                ExpModel.Instructions introState ->
                    Html.div [ class [ Styles.Normal ] ]
                        [ Html.div [] (instructionsView lift model.loadingNext introState) ]

                ExpModel.Trial trialModel ->
                    Html.div [ class [ Styles.Narrow ] ]
                        [ Html.div [ class [ Styles.Trial ] ]
                            (trial lift model.loadingNext trialModel)
                        ]

        finishProfileView =
            Html.div [ class [ Styles.Narrow ] ]
                [ Html.div [] [ Html.text "TODO: go finish your profile" ] ]

        uncompletableView =
            Html.div [ class [ Styles.Narrow ] ]
                [ Html.div [] [ Html.text "TODO: state uncompletable error" ] ]
    in
        case Lifecycle.state meta profile of
            Lifecycle.Experiment tests ->
                if List.length tests == 0 then
                    if Lifecycle.stateIsCompletable meta profile then
                        expView
                    else
                        uncompletableView
                else
                    finishProfileView

            Lifecycle.Training _ ->
                if Lifecycle.stateIsCompletable meta profile then
                    expView
                else
                    uncompletableView

            Lifecycle.Done ->
                Html.div [ class [ Styles.Narrow ] ]
                    [ Html.div [] [ Html.text "TODO: exp done" ] ]



-- INSTRUCTIONS


instructionsView :
    (Msg -> AppMsg.Msg)
    -> Bool
    -> Intro.State ExpModel.Node
    -> List (Html.Html AppMsg.Msg)
instructionsView lift loading state =
    [ Intro.node
        (instructionsConfig lift)
        state
        ExpModel.A
        Html.p
        []
        [ Html.text "First stuff" ]
    , Intro.node
        (instructionsConfig lift)
        state
        ExpModel.B
        Html.p
        []
        [ Html.text "Second stuff" ]
    , Helpers.evButton
        [ Attributes.disabled loading, class [ Styles.Btn ] ]
        (lift InstructionsStart)
        "Replay instructions"
    , Helpers.evButton
        [ Attributes.disabled loading, class [ Styles.Btn, Styles.BtnPrimary ] ]
        (lift LoadTrial)
        "Start"
    , Intro.overlay state
    ]



-- TRIAL


trial : (Msg -> AppMsg.Msg) -> Bool -> ExpModel.TrialModel -> List (Html.Html AppMsg.Msg)
trial lift loading trialModel =
    case trialModel.state of
        ExpModel.Reading ->
            [ Html.div [ class [ Styles.Header ] ]
                [ Html.span [ class [ Styles.Clock ] ] [ Clock.view trialModel.clock ]
                , Html.h4 [] [ Html.text Strings.expReadMemorize ]
                ]
            , Html.blockquote [] [ Html.text trialModel.current.text ]
            ]

        ExpModel.Tasking ->
            [ Html.text "Tasking"
            , Clock.view trialModel.clock
            ]

        ExpModel.Writing form ->
            write lift loading trialModel form

        ExpModel.Timeout ->
            [ Html.text "TODO: timeout"
            , Helpers.evButton
                [ Attributes.disabled loading, class [ Styles.Btn, Styles.BtnPrimary ] ]
                (lift LoadTrial)
                "Next"
            ]

        ExpModel.Pause ->
            [ Html.text "TODO: pause"
            , Helpers.evButton
                [ Attributes.disabled loading, class [ Styles.Btn, Styles.BtnPrimary ] ]
                (lift LoadTrial)
                "Next"
            ]


write :
    (Msg -> AppMsg.Msg)
    -> Bool
    -> ExpModel.TrialModel
    -> Form.Model String
    -> List (Html.Html AppMsg.Msg)
write lift loading trialModel { input, feedback, status } =
    [ Html.text "Write"
    , Html.form [ class [ Styles.FormPage ], Events.onSubmit (lift <| WriteSubmit input) ]
        [ Html.div
            [ class [ Styles.FormBlock ]
            , Helpers.feedbackStyles "global" feedback
            ]
            [ Html.label [ Helpers.forId Styles.InputAutofocus ] [ Html.text "Write:" ]
            , Helpers.textarea
                [ id Styles.InputAutofocus
                , Attributes.autofocus True
                , classList [ ( Styles.Disabled, (loading || (status /= Form.Entering)) ) ]
                , Helpers.onInputContent (lift << WriteInput)
                ]
            , Html.div [] [ Html.text (Feedback.getError "global" feedback) ]
            ]
        , Html.button
            [ Attributes.type_ "submit"
            , Attributes.disabled (loading || (status /= Form.Entering))
            , class [ Styles.Btn, Styles.BtnPrimary ]
            ]
            [ Html.text "Send" ]
        ]
    , Clock.view trialModel.clock
    ]
