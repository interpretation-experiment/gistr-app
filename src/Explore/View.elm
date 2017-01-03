module Explore.View exposing (view)

import Explore.Router
import Explore.View.Trees
import Helpers
import Html
import Model exposing (Model)
import Msg exposing (Msg)
import Router
import Styles exposing (class, classList, id)
import Types


view : Model -> Router.ExploreRoute -> List (Html.Html Msg)
view model route =
    case model.auth of
        Types.Authenticated auth ->
            if auth.user.isStaff then
                case route of
                    Router.Trees config ->
                        Explore.View.Trees.view Msg.ExploreMsg
                            model.explore.trees
                            auth
                            (Explore.Router.viewConfig config)

                    Router.Tree id ->
                        []
            else
                [ Helpers.notStaff ]

        Types.Authenticating ->
            [ Helpers.loading Styles.Big ]

        Types.Anonymous ->
            [ Helpers.notAuthed ]
