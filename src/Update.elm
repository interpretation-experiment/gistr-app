module Update exposing (update)

import Admin.Update as AdminUpdate
import Auth.Update as AuthUpdate
import Autoresize
import Comment.Update as CommentUpdate
import Experiment.Update as ExperimentUpdate
import Explore.Update as ExploreUpdate
import Helpers exposing ((!!))
import Home.Update as HomeUpdate
import Maybe.Extra exposing (maybeToList)
import Model exposing (Model)
import Msg exposing (Msg(..))
import Navigation
import Notification
import Profile.Update as ProfileUpdate
import Router


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case (Debug.log "msg" msg) of
        NoOp ->
            model ! []

        Log log ->
            let
                _ =
                    Debug.log "info" log
            in
                model ! []

        {-
           NOTIFICATIONS
        -}
        NotificationMsg msg ->
            let
                ( notifications, cmd ) =
                    Notification.update NotificationMsg msg model.notifications
            in
                ( { model | notifications = notifications }
                , cmd
                )

        {-
           AUTORESIZE TEXTAREAS
        -}
        AutoresizeMsg msg ->
            let
                ( autoresize, cmd, maybeOut ) =
                    Autoresize.update AutoresizeMsg msg model.autoresize
            in
                processMsgs
                    ( { model | autoresize = autoresize }
                    , cmd
                    , maybeToList maybeOut
                    )

        {-
           COMMENT
        -}
        CommentMsg msg ->
            Helpers.authenticatedOrIgnore model <|
                \auth ->
                    (CommentUpdate.update CommentMsg auth msg model |> processMsgs)

        {-
           NAVIGATION
        -}
        UrlUpdate newUrl route ->
            if (Debug.log "url" newUrl) /= Router.toUrl model.route then
                -- URL has changed, do something about it
                let
                    ( finalModel, navigationCmd ) =
                        Helpers.navigateTo model route

                    finalUrl =
                        Router.toUrl finalModel.route

                    urlCorrection =
                        if newUrl /= finalUrl then
                            Navigation.modifyUrl (Debug.log "url correction" finalUrl)
                        else
                            Cmd.none
                in
                    if finalModel.route /= model.route then
                        -- Update the model and return corresponding commands,
                        -- and also fix the browser's url if necessary.
                        finalModel ! [ navigationCmd, urlCorrection ]
                    else
                        -- Then necessarily newUrl /= finalUrl. So don't update the model,
                        -- but fix the browser's url.
                        model ! [ urlCorrection ]
            else
                -- URL hasn't changed, do nothing
                model ! []

        NavigateTo route ->
            let
                ( newModel, cmd ) =
                    Helpers.navigateTo model route
            in
                newModel ! [ cmd, Navigation.newUrl (Router.toUrl newModel.route) ]

        Error error ->
            -- Don't use `udpate (NavigateTo ...)` here so as not to lose the form inputs
            { model | route = Router.Error, error = Just error }
                ! [ Navigation.newUrl (Router.toUrl Router.Error) ]

        {-
           STORE
        -}
        WordSpanResult (Ok wordSpan) ->
            let
                store =
                    model.store

                newStore =
                    { store | wordSpan = Just wordSpan }
            in
                { model | store = newStore } ! []

        WordSpanResult (Err error) ->
            update (Error error) model

        {-
           HOME
        -}
        HomeMsg msg ->
            Helpers.authenticatedOrIgnore model <|
                \auth ->
                    (HomeUpdate.update HomeMsg auth msg model |> processMsgs)

        {-
           AUTH
        -}
        AuthMsg msg ->
            AuthUpdate.update AuthMsg msg model |> processMsgs

        {-
           PROFILE
        -}
        ProfileMsg msg ->
            Helpers.authenticatedOrIgnore model <|
                \auth ->
                    (ProfileUpdate.update ProfileMsg auth msg model |> processMsgs)

        {-
           EXPERIMENT
        -}
        ExperimentMsg msg ->
            Helpers.authenticatedOrIgnore model <|
                \auth ->
                    (ExperimentUpdate.update ExperimentMsg auth msg model |> processMsgs)

        {-
           ADMIN
        -}
        AdminMsg msg ->
            Helpers.authenticatedOrIgnore model <|
                \auth ->
                    (AdminUpdate.update AdminMsg auth msg model |> processMsgs)

        {-
           EXPLORE
        -}
        ExploreMsg msg ->
            let
                ( explore, cmd, outMsgs ) =
                    ExploreUpdate.update ExploreMsg msg model.explore
            in
                processMsgs
                    ( { model | explore = explore }
                    , cmd
                    , outMsgs
                    )



-- UPDATE HELPERS


processMsgs : ( Model, Cmd Msg, List Msg ) -> ( Model, Cmd Msg )
processMsgs ( model, cmd, msgs ) =
    List.foldl
        (\msg ( lastModel, lastCmd ) -> update msg lastModel !! [ lastCmd ])
        ( model, cmd )
        msgs
