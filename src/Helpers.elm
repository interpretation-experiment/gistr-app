module Helpers
    exposing
        ( alreadyAuthed
        , cmd
        , evA
        , evButton
        , feedbackGet
        , loading
        , navA
        , navButton
        , notAuthed
        , withFeedback
        , withInput
        , withStatus
        , (!!)
        , updateUser
        , navigateTo
        , authenticatedOrIgnore
        )

import Cmds
import Dict
import Html
import Html.Attributes as Attributes
import Html.Events as Events
import Json.Decode as Decode
import Maybe.Extra exposing ((?))
import Model exposing (Model)
import Msg exposing (Msg(NavigateTo))
import Router
import Task
import Types


cmd : a -> Cmd a
cmd msg =
    Task.perform (always msg) (always msg) (Task.succeed ())



-- UPDATES


(!!) : ( model, Cmd msg ) -> List (Cmd msg) -> ( model, Cmd msg )
(!!) ( model, cmd ) cmds =
    model ! (cmd :: cmds)


updateUser :
    { a | auth : Types.AuthStatus }
    -> Types.User
    -> { a | auth : Types.AuthStatus }
updateUser model user =
    case model.auth of
        Types.Authenticated auth ->
            { model | auth = Types.Authenticated { auth | user = user } }

        _ ->
            model


navigateTo : Model -> Router.Route -> ( Model, Cmd Msg )
navigateTo model route =
    let
        authRoute =
            Router.authRedirect model.auth (Debug.log "nav request" route)
    in
        Model.emptyForms { model | route = (Debug.log "nav final" authRoute) }
            ! Cmds.cmdsForRoute model authRoute


authenticatedOrIgnore :
    Model
    -> (Types.Auth -> ( Model, Cmd Msg ))
    -> ( Model, Cmd Msg )
authenticatedOrIgnore model authFunc =
    case model.auth of
        Types.Authenticated auth ->
            authFunc auth

        _ ->
            model ! []



-- VIEWS


evButton : List (Html.Attribute Msg) -> Msg -> String -> Html.Html Msg
evButton attrs msg text =
    Html.button ((Events.onClick msg) :: attrs) [ Html.text text ]


navButton : Router.Route -> String -> Html.Html Msg
navButton route text =
    evButton [] (NavigateTo route) text


evA : String -> Msg -> String -> Html.Html Msg
evA url msg text =
    Html.a
        [ Attributes.href url, onClickMsg msg ]
        [ Html.text text ]


navA : Router.Route -> String -> Html.Html Msg
navA route text =
    evA (Router.toUrl route) (NavigateTo route) text


onClickMsg : a -> Html.Attribute a
onClickMsg msg =
    Events.onWithOptions
        "click"
        { stopPropagation = True, preventDefault = True }
        (msg |> Decode.succeed)


loading : Html.Html msg
loading =
    Html.p [] [ Html.text "Loading..." ]


notAuthed : Html.Html msg
notAuthed =
    Html.p [] [ Html.text "Not signed in" ]


alreadyAuthed : Types.User -> Html.Html msg
alreadyAuthed user =
    Html.p [] [ Html.text ("Signed in as " ++ user.username) ]



-- FORMS


withFeedback :
    Types.Feedback
    -> { a | feedback : Types.Feedback }
    -> { a | feedback : Types.Feedback }
withFeedback feedback form =
    { form | feedback = feedback }


withInput : b -> { a | input : b } -> { a | input : b }
withInput input form =
    { form | input = input }


withStatus : b -> { a | status : b } -> { a | status : b }
withStatus status form =
    { form | status = status }


feedbackGet : String -> Types.Feedback -> String
feedbackGet key feedback =
    Dict.get key feedback ? ""
