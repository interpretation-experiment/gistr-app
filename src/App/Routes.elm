module App.Routes exposing (..)

import Components.Home.Routes as HomeRoutes
import Components.Play.Routes as PlayRoutes
import Components.Explore.Routes as ExploreRoutes
import Components.About.Routes as AboutRoutes
import Components.Profile.Routes as ProfileRoutes
import Components.Login.Routes as LoginRoutes


-- ROUTES


type Route
    = HomeRoute (Maybe HomeRoutes.Route)
    | PlayRoute (Maybe PlayRoutes.Route)
    | ExploreRoute (Maybe ExploreRoutes.Route)
    | AboutRoute (Maybe AboutRoutes.Route)
    | ProfileRoute (Maybe ProfileRoutes.Route)
    | LoginRoute (Maybe LoginRoutes.Route)
