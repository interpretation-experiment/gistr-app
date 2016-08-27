module Wiring
    exposing
        ( Component
        , wireComponent
        , wireComponentUpdater
        , wireComponentNavigator
        , Service
        , wireService
        , wireServiceUpdater
        )

import Html exposing (Html)
import Html.App as App
import RouteUrl.Builder as Builder
import Update.Extra as Update
import Update.Extra.Infix exposing ((:>))
import Maybe.Extra exposing ((?))
import Services.Account.Types as AccountTypes


{-
   COMPOMENT WIRING
-}
{-
   Base component
-}


type alias Component model msg outMsg route =
    { init : ( model, Cmd msg )
    , update : msg -> model -> ( model, Cmd msg, Maybe outMsg )
    , view : AccountTypes.Model -> model -> Html msg
    , subscriptions : model -> Sub msg
    , navigateTag : route -> msg
    , model2builder : model -> Maybe Builder.Builder
    , builder2routeMessages : Builder.Builder -> ( route, List msg )
    }



{-
   Component once it is wired
-}


type alias WiredComponent model parentSubmodel msg parentMsg route parentRoute =
    { init : ( parentSubmodel, Cmd parentMsg )
    , update : msg -> model -> ( parentSubmodel, Cmd parentMsg, Maybe parentMsg )
    , view : AccountTypes.Model -> model -> Html parentMsg
    , subscriptions : model -> Sub parentMsg
    , navigate : route -> ( parentSubmodel, Cmd parentMsg, Maybe parentMsg )
    , model2builder : model -> Maybe Builder.Builder
    , builder2routeMessages : Builder.Builder -> ( parentRoute, List parentMsg )
    }



{-
   Wire a component to its parent
-}


wireComponent :
    { modelTag : model -> parentSubmodel
    , msgTag : msg -> parentMsg
    , routeTag : Maybe route -> parentRoute
    , path : String
    , translator : outMsg -> parentMsg
    , component : Component model msg outMsg route
    }
    -> WiredComponent model parentSubmodel msg parentMsg route parentRoute
wireComponent args =
    let
        -- Convert component model and commands to the parent's version
        init =
            let
                ( initModel, initCmd ) =
                    args.component.init
            in
                ( args.modelTag initModel, Cmd.map args.msgTag initCmd )

        -- Convert component model and commands to the parent's version,
        -- and translate the outgoing message to the parent
        update msg model =
            let
                ( model', cmd, outMsg ) =
                    args.component.update msg model
            in
                ( args.modelTag model'
                , Cmd.map args.msgTag cmd
                , Maybe.map args.translator outMsg
                )

        -- Convert component messages to the parent's version
        view account model =
            App.map args.msgTag (args.component.view account model)

        -- Convert component messages to the parent's version
        subscriptions model =
            Sub.map args.msgTag (args.component.subscriptions model)

        -- Initialize the component and send it the navigation command, getting
        -- back the parent's version of model, commands, and outgoing message.
        -- This is later used in ComponentNavigator to finish treating the
        -- outgoing message.
        navigate route =
            let
                ( initModel, initCmd ) =
                    args.component.init

                ( model, cmd, outMsg ) =
                    update (args.component.navigateTag route) initModel
            in
                ( model
                , Cmd.batch [ Cmd.map args.msgTag initCmd, cmd ]
                , outMsg
                )

        -- Prepend the component's path to its internal RouteUrl.Builder
        model2builder model =
            args.component.model2builder model
                |> Maybe.map (Builder.prependToPath [ args.path ])

        -- Convert the component's route and messages to the parent's version
        builder2routeMessages builder =
            let
                ( route, messages ) =
                    args.component.builder2routeMessages builder
            in
                ( args.routeTag (Just route), List.map args.msgTag messages )
    in
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        , navigate = navigate
        , model2builder = model2builder
        , builder2routeMessages = builder2routeMessages
        }



{-
   Parent model, when the parent does some routing
-}


type alias RoutingParentModel parentSubmodel parentModel =
    { parentModel | routeModel : parentSubmodel }



{-
   Parent update function, when the parent does some routing
-}


type alias RoutingParentUpdater parentSubmodel parentModel parentMsg =
    parentMsg
    -> RoutingParentModel parentSubmodel parentModel
    -> ( RoutingParentModel parentSubmodel parentModel, Cmd parentMsg )



{-
   Wired parent update function, updating a component and processing any
   outgoing message from the component through the parent's update function
-}


type alias ComponentUpdater model parentSubmodel parentModel msg parentMsg route parentRoute =
    WiredComponent model parentSubmodel msg parentMsg route parentRoute
    -> msg
    -> model
    -> RoutingParentModel parentSubmodel parentModel
    -> ( RoutingParentModel parentSubmodel parentModel, Cmd parentMsg )



{-
   Wire a parent's update function into a function that performs component
   updates, automatically processing component outgoing messages through the
   parent update function
-}


wireComponentUpdater :
    RoutingParentUpdater parentSubmodel parentModel parentMsg
    -> ComponentUpdater model parentSubmodel parentModel msg parentMsg route parentRoute
wireComponentUpdater parentUpdate =
    \component msg model parentModel ->
        let
            -- Get wired component's model, commands, and outgoing message
            -- resulting from the update
            ( model', cmd, outMsg ) =
                component.update msg model
        in
            -- If present, process the outgoing message through the parent's
            -- update function
            { parentModel | routeModel = model' }
                ! [ cmd ]
                :> Maybe.map parentUpdate outMsg
                ? Update.identity



{-
   Wired parent navigation function, navigating to a component and processing
   any outgoing message from the initial component navigation through the
   parent's update function
-}


type alias ComponentNavigator model parentSubmodel parentModel msg parentMsg route parentRoute =
    WiredComponent model parentSubmodel msg parentMsg route parentRoute
    -> Maybe route
    -> RoutingParentModel parentSubmodel parentModel
    -> ( RoutingParentModel parentSubmodel parentModel, Cmd parentMsg )



{-
   Wire a parent's update function into a function that navigates to a
   component, automatically processing outgoing messages from the component
   navigation
-}


wireComponentNavigator :
    RoutingParentUpdater parentSubmodel parentModel parentMsg
    -> ComponentNavigator model parentSubmodel parentModel msg parentMsg route parentRoute
wireComponentNavigator parentUpdate =
    \component maybeRoute parentModel ->
        let
            -- Get initial model, commands, and outgoing message from
            -- navigating to the component
            ( initModel, initCmd, outMsg ) =
                case maybeRoute of
                    Nothing ->
                        -- We have no internal route to navigate to, so just
                        -- get the component's init
                        let
                            ( initModel, initCmd ) =
                                component.init
                        in
                            ( initModel, initCmd, Nothing )

                    Just route ->
                        -- We have an internal route to navigate to
                        component.navigate route
        in
            -- If present, process the outgoing message through the parent's
            -- update function
            { parentModel | routeModel = initModel }
                ! [ initCmd ]
                :> Maybe.map parentUpdate outMsg
                ? Update.identity



{-
   SERVICE WIRING
-}
{-
   Base service
-}


type alias Service model msg outMsg =
    { init : ( model, Cmd msg )
    , update : msg -> model -> ( model, Cmd msg, Maybe outMsg )
    , subscriptions : model -> Sub msg
    }



{-
   Service once it is wired
-}


type alias WiredService model parentModel msg parentMsg =
    { init : ( model, Cmd parentMsg )
    , update : msg -> model -> parentModel -> ( parentModel, Cmd parentMsg, Maybe parentMsg )
    , subscriptions : model -> Sub parentMsg
    }



{-
   Wire a service to its parent
-}


wireService :
    { modelUpdater : parentModel -> model -> parentModel
    , msgTag : msg -> parentMsg
    , translator : outMsg -> parentMsg
    , service : Service model msg outMsg
    }
    -> WiredService model parentModel msg parentMsg
wireService args =
    let
        -- Convert service model and commands to the parent's version
        init =
            let
                ( initModel, initCmd ) =
                    args.service.init
            in
                ( initModel, Cmd.map args.msgTag initCmd )

        -- Convert service model and commands to the parent's version,
        -- and translate the outgoing message to the parent
        update msg model parentModel =
            let
                ( model', cmd, outMsg ) =
                    args.service.update msg model
            in
                ( args.modelUpdater parentModel model'
                , Cmd.map args.msgTag cmd
                , Maybe.map args.translator outMsg
                )

        -- Convert component messages to the parent's version
        subscriptions model =
            Sub.map args.msgTag (args.service.subscriptions model)
    in
        { init = init
        , update = update
        , subscriptions = subscriptions
        }



{-
   Parent update function, when we don't care if the parent does any routing
-}


type alias ParentUpdater parentModel parentMsg =
    parentMsg
    -> parentModel
    -> ( parentModel, Cmd parentMsg )



{-
   Wired parent update function, updating a service and processing any outgoing
   message from the service through the parent's update function
-}


type alias ServiceUpdater model parentModel msg parentMsg =
    WiredService model parentModel msg parentMsg
    -> msg
    -> model
    -> parentModel
    -> ( parentModel, Cmd parentMsg )



{-
   Wire a parent's update function into a function that performs service
   updates, automatically processing service outgoing messages through the
   parent update function
-}


wireServiceUpdater :
    ParentUpdater parentModel parentMsg
    -> ServiceUpdater model parentModel msg parentMsg
wireServiceUpdater parentUpdate =
    \service msg model parentModel ->
        let
            -- Get wired service's model, commands, and outgoing message
            -- resulting from the update
            ( parentModel', cmd, outMsg ) =
                service.update msg model parentModel
        in
            -- If present, process the outgoing message through the parent's
            -- update function
            parentModel'
                ! [ cmd ]
                :> Maybe.map parentUpdate outMsg
                ? Update.identity
