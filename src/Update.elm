module Update exposing (update)

import Auth.Update as AuthUpdate
import Experiment.Update as ExperimentUpdate
import Form
import Helpers exposing ((!!))
import Model exposing (Model)
import Msg exposing (Msg(..))
import Navigation
import Profile.Update as ProfileUpdate
import Router
import Store


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
           EXPERIMENT
        -}
        ExperimentMsg msg ->
            Helpers.authenticatedOrIgnore model <|
                \auth ->
                    (ExperimentUpdate.update ExperimentMsg auth msg model |> processMaybeMsg)



-- UPDATE HELPERS


processMaybeMsg : ( Model, Cmd Msg, Maybe Msg ) -> ( Model, Cmd Msg )
processMaybeMsg ( model, cmd, maybeMsg ) =
    case maybeMsg of
        Nothing ->
            ( model, cmd )

        Just msg ->
            update msg model !! [ cmd ]
