module App exposing (init, view, update, subscriptions, delta2url, location2messages)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Navigation exposing (Location)
import RouteUrl exposing (UrlChange)
import RouteUrl.Builder as Builder
import App.Types exposing (..)
import App.Routes exposing (..)
import Wiring
    exposing
        ( wireComponent
        , wireComponentUpdater
        , wireComponentNavigator
        , wireService
        , wireServiceUpdater
        )
import Components.Home as Home
import Components.Play as Play
import Components.Explore as Explore
import Components.About as About
import Components.Profile as Profile
import Components.Login as Login
import Services.Account as Account
import Services.Account.Types as AccountTypes


-- COMPONENTS


translationDictionary =
    { onNavigateBack = NavigateTo (HomeRoute Nothing)
    , onNavigateTo = NavigateTo
    , onLoggedIn = NavigateTo (HomeRoute Nothing)
    , onLoggedOut = NavigateTo (HomeRoute Nothing)
    , onLoginUser = AccountTypes.Login >> AccountMsg
    , onClearLoginFeedback = AccountMsg AccountTypes.ClearFeedback
    , onLogout = AccountMsg AccountTypes.Logout
    }


homeComponent =
    wireComponent
        { modelTag = HomeModel
        , msgTag = HomeMsg
        , routeTag = HomeRoute
        , path = ""
        , translator = Home.translator translationDictionary
        , component = Home.component
        }


playComponent =
    wireComponent
        { modelTag = PlayModel
        , msgTag = PlayMsg
        , routeTag = PlayRoute
        , path = "play"
        , translator = Play.translator translationDictionary
        , component = Play.component
        }


exploreComponent =
    wireComponent
        { modelTag = ExploreModel
        , msgTag = ExploreMsg
        , routeTag = ExploreRoute
        , path = "explore"
        , translator = Explore.translator translationDictionary
        , component = Explore.component
        }


aboutComponent =
    wireComponent
        { modelTag = AboutModel
        , msgTag = AboutMsg
        , routeTag = AboutRoute
        , path = "about"
        , translator = About.translator translationDictionary
        , component = About.component
        }


profileComponent =
    wireComponent
        { modelTag = ProfileModel
        , msgTag = ProfileMsg
        , routeTag = ProfileRoute
        , path = "profile"
        , translator = Profile.translator translationDictionary
        , component = Profile.component
        }


loginComponent =
    wireComponent
        { modelTag = LoginModel
        , msgTag = LoginMsg
        , routeTag = LoginRoute
        , path = "login"
        , translator = Login.translator translationDictionary
        , component = Login.component
        }


componentUpdate =
    wireComponentUpdater update


componentNavigate =
    wireComponentNavigator update


accountService =
    wireService
        { modelUpdater = \model subModel -> { model | account = subModel }
        , msgTag = AccountMsg
        , translator = Account.translator translationDictionary
        , service = Account.service
        }


serviceUpdate =
    wireServiceUpdater update



-- MODEL


init : ( Model, Cmd Msg )
init =
    let
        ( initAccount, initAccountCmd ) =
            accountService.init

        ( initHome, initHomeCmd ) =
            homeComponent.init
    in
        Model initHome initAccount ! [ initAccountCmd, initHomeCmd ]



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( (Debug.log "msg" msg), model.routeModel ) of
        ( NavigateTo (HomeRoute maybeHomeRoute), _ ) ->
            componentNavigate homeComponent maybeHomeRoute model

        ( NavigateTo (PlayRoute maybePlayRoute), _ ) ->
            componentNavigate playComponent maybePlayRoute model

        ( NavigateTo (ExploreRoute maybeExploreRoute), _ ) ->
            componentNavigate exploreComponent maybeExploreRoute model

        ( NavigateTo (AboutRoute maybeAboutRoute), _ ) ->
            componentNavigate aboutComponent maybeAboutRoute model

        ( NavigateTo (ProfileRoute maybeProfileRoute), _ ) ->
            componentNavigate profileComponent maybeProfileRoute model

        ( NavigateTo (LoginRoute maybeLoginRoute), _ ) ->
            componentNavigate loginComponent maybeLoginRoute model

        ( HomeMsg homeMsg, HomeModel homeModel ) ->
            componentUpdate homeComponent homeMsg homeModel model

        ( HomeMsg homeMsg, _ ) ->
            model ! []

        ( PlayMsg playMsg, PlayModel playModel ) ->
            componentUpdate playComponent playMsg playModel model

        ( PlayMsg playMsg, _ ) ->
            model ! []

        ( ExploreMsg exploreMsg, ExploreModel exploreModel ) ->
            componentUpdate exploreComponent exploreMsg exploreModel model

        ( ExploreMsg exploreMsg, _ ) ->
            model ! []

        ( AboutMsg aboutMsg, AboutModel aboutModel ) ->
            componentUpdate aboutComponent aboutMsg aboutModel model

        ( AboutMsg aboutMsg, _ ) ->
            model ! []

        ( ProfileMsg profileMsg, ProfileModel profileModel ) ->
            componentUpdate profileComponent profileMsg profileModel model

        ( ProfileMsg profileMsg, _ ) ->
            model ! []

        ( LoginMsg loginMsg, LoginModel loginModel ) ->
            componentUpdate loginComponent loginMsg loginModel model

        ( LoginMsg loginMsg, _ ) ->
            model ! []

        ( AccountMsg accountMsg, _ ) ->
            serviceUpdate accountService accountMsg model.account model



-- VIEW


view : Model -> Html Msg
view model =
    case model.routeModel of
        HomeModel homeModel ->
            homeComponent.view model.account homeModel

        PlayModel playModel ->
            playComponent.view model.account playModel

        ExploreModel exploreModel ->
            exploreComponent.view model.account exploreModel

        AboutModel aboutModel ->
            aboutComponent.view model.account aboutModel

        ProfileModel profileModel ->
            profileComponent.view model.account profileModel

        LoginModel loginModel ->
            loginComponent.view model.account loginModel



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        routeSubscriptions =
            case model.routeModel of
                HomeModel homeModel ->
                    homeComponent.subscriptions homeModel

                PlayModel playModel ->
                    playComponent.subscriptions playModel

                ExploreModel exploreModel ->
                    exploreComponent.subscriptions exploreModel

                AboutModel aboutModel ->
                    aboutComponent.subscriptions aboutModel

                ProfileModel profileModel ->
                    profileComponent.subscriptions profileModel

                LoginModel loginModel ->
                    loginComponent.subscriptions loginModel
    in
        Sub.batch [ accountService.subscriptions model.account, routeSubscriptions ]



-- ROUTING


delta2url : Model -> Model -> Maybe UrlChange
delta2url previous current =
    model2builder current
        |> Maybe.map Builder.toUrlChange


model2builder : Model -> Maybe Builder.Builder
model2builder model =
    case model.routeModel of
        HomeModel homeModel ->
            homeComponent.model2builder homeModel

        PlayModel playModel ->
            playComponent.model2builder playModel

        ExploreModel exploreModel ->
            exploreComponent.model2builder exploreModel

        AboutModel aboutModel ->
            aboutComponent.model2builder aboutModel

        ProfileModel profileModel ->
            profileComponent.model2builder profileModel

        LoginModel loginModel ->
            loginComponent.model2builder loginModel


location2messages : Location -> List Msg
location2messages location =
    let
        ( route, messages ) =
            builder2routeMessages (Builder.fromUrl location.href)
    in
        (NavigateTo route) :: messages


builder2routeMessages : Builder.Builder -> ( Route, List Msg )
builder2routeMessages builder =
    case Builder.path builder of
        head :: tail ->
            let
                subBuilder =
                    Builder.replacePath tail builder
            in
                case head of
                    "" ->
                        homeComponent.builder2routeMessages subBuilder

                    "play" ->
                        playComponent.builder2routeMessages subBuilder

                    "explore" ->
                        exploreComponent.builder2routeMessages subBuilder

                    "about" ->
                        aboutComponent.builder2routeMessages subBuilder

                    "profile" ->
                        profileComponent.builder2routeMessages subBuilder

                    "login" ->
                        loginComponent.builder2routeMessages subBuilder

                    _ ->
                        ( HomeRoute Nothing, [] )

        _ ->
            ( HomeRoute Nothing, [] )
