module Helpers
    exposing
        ( (!!)
        , (!!!)
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
        , shuffle
        , updateAuth
        , updateAuthNav
        , updateProfile
        , updateUser
        )

import Cmds
import Feedback
import Html
import Html.Attributes as Attributes
import Html.Events as Events
import Json.Decode as Decode
import List
import List.Extra exposing (splitAt)
import List.Nonempty as Nonempty
import Model exposing (Model)
import Msg exposing (Msg(NavigateTo, Error))
import Random
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


(!!!) : ( model, Cmd msg, Maybe msg ) -> List (Cmd msg) -> ( model, Cmd msg, Maybe msg )
(!!!) ( model, cmd, maybeMsg ) cmds =
    ( model, Cmd.batch (cmd :: cmds), maybeMsg )


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


updateProfile :
    { a | auth : Types.AuthStatus }
    -> Types.Profile
    -> { a | auth : Types.AuthStatus }
updateProfile model profile =
    case model.auth of
        Types.Authenticated auth ->
            let
                user =
                    auth.user

                newUser =
                    { user | profile = profile }
            in
                { model | auth = Types.Authenticated { auth | user = newUser } }

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
    Types.Error
    -> Model
    -> (Feedback.Feedback -> ( Model, Cmd Msg, Maybe Msg ))
    -> ( Model, Cmd Msg, Maybe Msg )
feedbackOrUnrecoverable error model feedbackFunc =
    case error of
        Types.Unrecoverable _ ->
            ( model, Cmd.none, Just (Error error) )

        Types.ApiFeedback feedback ->
            feedbackFunc feedback



-- ROUTING WITH AUTH


updateAuth :
    Types.AuthStatus
    -> Model
    -> ( Model, Cmd Msg, Maybe Msg )
updateAuth authStatus model =
    ( { model | auth = authStatus }
    , Cmd.none
    , Just (NavigateTo model.route)
    )


updateAuthNav :
    Types.AuthStatus
    -> Router.Route
    -> Model
    -> ( Model, Cmd Msg, Maybe Msg )
updateAuthNav authStatus route model =
    updateAuth authStatus { model | route = route }



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



-- MISC


shuffle : Random.Seed -> List a -> List a
shuffle seed list =
    shuffleHelp ( list, seed ) |> fst


shuffleHelp : ( List a, Random.Seed ) -> ( List a, Random.Seed )
shuffleHelp ( list, seed ) =
    case list of
        [] ->
            ( [], seed )

        head :: [] ->
            ( [ head ], seed )

        head :: rest ->
            let
                ( shuffledRest, newSeed ) =
                    shuffleHelp ( rest, seed )

                ( j, finalSeed ) =
                    Random.step (Random.int 0 (List.length rest)) newSeed

                finalList =
                    case splitAt j shuffledRest of
                        ( left, target :: right ) ->
                            left ++ (head :: right) ++ [ target ]

                        ( left, [] ) ->
                            left ++ [ head ]
            in
                ( finalList, finalSeed )
