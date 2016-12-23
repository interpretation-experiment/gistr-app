module Explore.View exposing (view)

import Explore.Router
import Explore.View.Trees
import Html
import Model exposing (Model)
import Msg exposing (Msg)
import Router


view : Model -> Router.ExploreRoute -> List (Html.Html Msg)
view model route =
    case route of
        Router.Trees config ->
            Explore.View.Trees.view model (Explore.Router.viewConfig config)

        Router.Tree id ->
            []
