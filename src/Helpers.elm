module Helpers
    exposing
        ( (!!)
        , alreadyAuthed
        , authenticatedOrIgnore
        , cmd
        , evA
        , evButton
        , feedbackOrUnrecoverable
        , ifShorterThan
        , ifThenValidate
        , loading
        , navA
        , navButton
        , navigateTo
        , notAuthed
        , updateAuth
        , updateAuthNav
        , updateUser
        )

import Cmds
import Feedback
import Html
import Html.Attributes as Attributes
import Html.Events as Events
import Json.Decode as Decode
import List.Nonempty as Nonempty
import Model exposing (Model)
import Msg exposing (Msg(NavigateTo, Error))
import Router
import String
import Task
import Types
import Validate


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
            Router.normalize model.auth (Debug.log "nav request" route)

        emptyOnChange =
            if authRoute /= model.route then
                Model.emptyForms
            else
                identity
    in
        emptyOnChange { model | route = (Debug.log "nav final" authRoute) }
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


feedbackOrUnrecoverable :
    (Msg -> Model -> ( Model, Cmd Msg ))
    -> Types.Error
    -> Model
    -> (Feedback.Feedback -> ( Model, Cmd Msg ))
    -> ( Model, Cmd Msg )
feedbackOrUnrecoverable update error model feedbackFunc =
    case error of
        Types.Unrecoverable _ ->
            update (Error error) model

        Types.ApiFeedback feedback ->
            feedbackFunc feedback



-- ROUTING WITH AUTH


updateAuth :
    (Msg -> Model -> ( Model, Cmd Msg ))
    -> Types.AuthStatus
    -> Model
    -> ( Model, Cmd Msg )
updateAuth update authStatus model =
    update (NavigateTo model.route) { model | auth = authStatus }


updateAuthNav :
    (Msg -> Model -> ( Model, Cmd Msg ))
    -> Types.AuthStatus
    -> Router.Route
    -> Model
    -> ( Model, Cmd Msg )
updateAuthNav update authStatus route model =
    updateAuth update authStatus { model | route = route }



-- VIEWS


evButton : List (Html.Attribute Msg) -> Msg -> String -> Html.Html Msg
evButton attrs msg text =
    Html.button ((onClickMsg msg) :: attrs) [ Html.text text ]


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



-- VALIDATION


ifShorterThan : Int -> error -> Validate.Validator error String
ifShorterThan length error =
    Validate.ifInvalid (String.length >> (>) length) error


ifThenValidate : (subject -> Bool) -> Validate.Validator error subject -> Validate.Validator error subject
ifThenValidate condition validator subject =
    if condition subject then
        validator subject
    else
        []
