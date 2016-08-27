module App.Types exposing (..)

import App.Routes exposing (..)
import Components.Home.Types as HomeTypes
import Components.Play.Types as PlayTypes
import Components.Explore.Types as ExploreTypes
import Components.About.Types as AboutTypes
import Components.Profile.Types as ProfileTypes
import Components.Login.Types as LoginTypes
import Services.Account.Types as AccountTypes


-- MODEL


type RouteModel
    = HomeModel HomeTypes.Model
    | PlayModel PlayTypes.Model
    | ExploreModel ExploreTypes.Model
    | AboutModel AboutTypes.Model
    | ProfileModel ProfileTypes.Model
    | LoginModel LoginTypes.Model


type alias Model =
    { routeModel : RouteModel
    , account : AccountTypes.Model
    }



-- MESSAGES


type Msg
    = NavigateTo Route
    | HomeMsg HomeTypes.Msg
    | PlayMsg PlayTypes.Msg
    | ExploreMsg ExploreTypes.Msg
    | AboutMsg AboutTypes.Msg
    | ProfileMsg ProfileTypes.Msg
    | LoginMsg LoginTypes.Msg
    | AccountMsg AccountTypes.Msg
