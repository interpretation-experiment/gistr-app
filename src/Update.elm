module Update exposing (update)

import Api
import Auth.Msg as AuthMsg
import Auth.Update as AuthUpdate
import Experiment
import Experiment.Reformulation as Reformulation
import Feedback
import Form
import Helpers exposing ((!!))
import Instructions
import List.Nonempty as Nonempty
import LocalStorage
import Maybe.Extra exposing ((?), or)
import Model exposing (Model)
import Msg exposing (Msg(..))
import Navigation
import Profile.Msg as ProfileMsg
import Profile.Update as ProfileUpdate
import Regex
import Router
import Store
import String
import Strings
import Task
import Types
import Validate


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Animate _ ->
            doUpdate msg model

        _ ->
            let
                _ =
                    Debug.log "msg" msg
            in
                doUpdate msg model


doUpdate : Msg -> Model -> ( Model, Cmd Msg )
doUpdate msg model =
    case msg of
        NoOp ->
            model ! []

        Animate msg ->
            { model
                | password = Form.animate msg model.password
                , username = Form.animate msg model.username
                , emails = Form.animate msg model.emails
            }
                ! []

        {-
           NAVIGATION
        -}
        NavigateTo route ->
            let
                ( model', cmd ) =
                    Helpers.navigateTo model route
            in
                model' ! [ cmd, Navigation.newUrl (Router.toUrl model'.route) ]

        Error error ->
            -- Don't use `udpate (NavigateTo ...)` here so as not to lose the form inputs
            { model | route = Router.Error, error = Just error }
                ! [ Navigation.newUrl (Router.toUrl Router.Error) ]

        {-
           AUTH
        -}
        AuthMsg msg ->
            AuthUpdate.update AuthMsg msg model |> processMaybeMsg

        {-
           PROFILE
        -}
        ProfileMsg msg ->
            Helpers.authenticatedOrIgnore model <|
                \auth ->
                    (ProfileUpdate.update ProfileMsg auth msg model |> processMaybeMsg)

        {-
           STORE
        -}
        GotStoreItem item ->
            { model | store = Store.set item model.store } ! []

        GotMeta meta ->
            let
                store =
                    model.store
            in
                { model | store = { store | meta = Just meta } } ! []

        {-
           REFORMULATIONS EXPERIMENT
        -}
        ReformulationInstructions msg ->
            case model.experiment of
                Experiment.Instructions state ->
                    let
                        ( newState, maybeOut ) =
                            Instructions.update
                                Reformulation.instructionsUpdateConfig
                                msg
                                state

                        newModel =
                            { model | experiment = Experiment.Instructions newState }
                    in
                        case maybeOut of
                            Nothing ->
                                newModel ! []

                            Just outMsg ->
                                update outMsg newModel

                _ ->
                    model ! []

        ReformulationInstructionsRestart ->
            { model
                | experiment =
                    Experiment.Instructions
                        (Instructions.start Reformulation.instructionsOrder)
            }
                ! []

        ReformulationInstructionsQuit index ->
            if index + 1 == Nonempty.length Reformulation.instructionsOrder then
                update ReformulationInstructionsDone model
            else
                { model | experiment = Experiment.Instructions Instructions.hide } ! []

        ReformulationInstructionsDone ->
            -- TODO: set intro read
            { model | experiment = Experiment.Instructions Instructions.hide } ! []

        ReformulationExpStart ->
            -- TODO: if trained, do exp directly, if not, do training
            { model
                | experiment =
                    Experiment.Training
                        (Reformulation.Trial () Reformulation.Reading)
            }
                ! []



-- UPDATE HELPERS


processMaybeMsg : ( Model, Cmd Msg, Maybe Msg ) -> ( Model, Cmd Msg )
processMaybeMsg ( model, cmd, maybeMsg ) =
    case maybeMsg of
        Nothing ->
            ( model, cmd )

        Just msg ->
            update msg model !! [ cmd ]


feedbackOrUnrecoverable :
    Types.Error
    -> Model
    -> (Feedback.Feedback -> ( Model, Cmd Msg ))
    -> ( Model, Cmd Msg )
feedbackOrUnrecoverable error model feedbackFunc =
    case error of
        Types.Unrecoverable _ ->
            update (Error error) model

        Types.ApiFeedback feedback ->
            feedbackFunc feedback
