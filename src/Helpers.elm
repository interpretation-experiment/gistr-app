module Helpers
    exposing
        ( (!!)
        , (!!!)
        , alreadyAuthed
        , authenticatedOr
        , authenticatedOrIgnore
        , avatar
        , cmd
        , evA
        , evButton
        , evIconButton
        , extractFeedback
        , feedbackStyles
        , forId
        , hrefIcon
        , icon
        , ifShorterThan
        , ifShorterThanWords
        , ifThenValidate
        , loading
        , navA
        , navButton
        , navIcon
        , navigateTo
        , nonemptyMaximum
        , nonemptyMinimum
        , notAuthed
        , notStaff
        , notify
        , onEventPreventMsg
        , onInputContent
        , readTime
        , resultToTask
        , sample
        , seed
        , shuffle
        , textarea
        , tooltip
        , trialOr
        , updateAuth
        , updateAuthNav
        , updateProfile
        , updateUser
        , writeTime
        )

import Cmds
import Decoders
import Experiment.Model as ExpModel
import Feedback
import Html
import Html.Attributes as Attributes
import Html.Events as Events
import Http
import Json.Decode as JD
import List
import List.Extra exposing (splitAt)
import List.Nonempty as Nonempty
import List.Nonempty exposing (Nonempty(Nonempty))
import MD5
import Maybe.Extra exposing ((?), unwrap)
import Model exposing (Model)
import Msg exposing (Msg(NavigateTo, Error, Notify))
import Notification
import Random
import Router
import String
import Styles exposing (class, classList, id)
import Svg
import Svg.Attributes as SvgAttributes
import Task
import Time
import Types
import Validate


cmd : a -> Cmd a
cmd msg =
    Task.perform (always msg) (Task.succeed ())



-- TODO: break out Update helpers and View helpers
-- UPDATES


(!!) : ( model, Cmd msg ) -> List (Cmd msg) -> ( model, Cmd msg )
(!!) ( model, cmd ) cmds =
    model ! (cmd :: cmds)


(!!!) : ( model, Cmd msg, List msg ) -> List (Cmd msg) -> ( model, Cmd msg, List msg )
(!!!) ( model, cmd, msgs ) cmds =
    ( model, Cmd.batch (cmd :: cmds), msgs )


authenticatedOr : { a | auth : Types.AuthStatus } -> b -> (Types.Auth -> b) -> b
authenticatedOr model default authFunc =
    case model.auth of
        Types.Authenticated auth ->
            authFunc auth

        _ ->
            default


trialOr : { a | experiment : ExpModel.Model } -> b -> (ExpModel.TrialModel -> b) -> b
trialOr model default trialFunc =
    case model.experiment.state of
        ExpModel.Trial trial ->
            trialFunc trial

        _ ->
            default


updateUser :
    { a | auth : Types.AuthStatus }
    -> Types.User
    -> { a | auth : Types.AuthStatus }
updateUser model user =
    authenticatedOr model model <|
        \auth -> { model | auth = Types.Authenticated { auth | user = user } }


updateProfile :
    { a | auth : Types.AuthStatus }
    -> Types.Profile
    -> { a | auth : Types.AuthStatus }
updateProfile model profile =
    authenticatedOr model model <|
        \auth ->
            let
                user =
                    auth.user

                newUser =
                    { user | profile = profile }
            in
                { model | auth = Types.Authenticated { auth | user = newUser } }


navigateTo : Model -> Router.Route -> ( Model, Cmd Msg )
navigateTo model request =
    let
        finalRoute =
            Router.normalize model.auth (Debug.log "nav request" request)

        newModel =
            if finalRoute /= model.route then
                Model.emptyForms { model | route = (Debug.log "nav final" finalRoute) }
            else
                model
    in
        newModel ! Cmds.cmdsForModel newModel


authenticatedOrIgnore :
    Model
    -> (Types.Auth -> ( Model, Cmd Msg ))
    -> ( Model, Cmd Msg )
authenticatedOrIgnore model authFunc =
    authenticatedOr model (model ! []) authFunc


extractFeedback :
    Types.Error
    -> Model
    -> List ( String, String )
    -> (Feedback.Feedback -> ( Model, Cmd Msg, List Msg ))
    -> ( Model, Cmd Msg, List Msg )
extractFeedback error model fields feedbackFunc =
    case error of
        Types.HttpError httpError ->
            case httpError of
                Http.BadStatus response ->
                    case JD.decodeString (Decoders.feedback fields) response.body of
                        Ok feedback ->
                            feedbackFunc feedback

                        Err _ ->
                            ( model, Cmd.none, [ Error error ] )

                _ ->
                    ( model, Cmd.none, [ Error error ] )

        Types.Unrecoverable _ ->
            ( model, Cmd.none, [ Error error ] )


notify : String -> Html.Html Msg -> Types.Notification -> Msg
notify title content tipe =
    Notify <|
        Notification.Notify <|
            Notification.notification ( title, content, tipe ) (Just <| 10 * Time.second)



-- ROUTING WITH AUTH


updateAuth :
    Types.AuthStatus
    -> Model
    -> ( Model, Cmd Msg, List Msg )
updateAuth authStatus model =
    ( { model | auth = authStatus }
    , Cmd.none
    , [ NavigateTo model.route ]
    )


updateAuthNav :
    Types.AuthStatus
    -> Router.Route
    -> Model
    -> ( Model, Cmd Msg, List Msg )
updateAuthNav authStatus route model =
    updateAuth authStatus { model | route = route }



-- VIEWS


avatar : Types.User -> Router.Route -> Html.Html Msg
avatar user route =
    let
        email =
            case List.filter .primary user.emails of
                [] ->
                    Maybe.map .email (List.head user.emails) ? ""

                primary :: _ ->
                    primary.email

        hash =
            MD5.hex <| String.toLower <| String.trim email
    in
        Html.a
            [ Attributes.href (Router.toUrl route)
            , onClickMsg (NavigateTo route)
            , class [ Styles.Avatar ]
            ]
            [ Html.img
                [ Attributes.src ("//www.gravatar.com/avatar/" ++ hash ++ "?d=retro&s=40")
                , Attributes.alt "Profile"
                ]
                []
            ]


tooltip : String -> Html.Attribute msg
tooltip text =
    Attributes.attribute "data-tooltip" text


evButton : List (Html.Attribute Msg) -> Msg -> String -> Html.Html Msg
evButton attrs msg text =
    Html.button ((onClickMsg msg) :: attrs) [ Html.text text ]


evIconButton : List (Html.Attribute Msg) -> Msg -> String -> Html.Html Msg
evIconButton attrs msg name =
    Html.button
        ([ onClickMsg msg, class [ Styles.BtnIcon ] ] ++ attrs)
        [ icon name ]


navButton : List (Html.Attribute Msg) -> Router.Route -> String -> Html.Html Msg
navButton attrs route text =
    evButton attrs (NavigateTo route) text


evA : List (Html.Attribute Msg) -> String -> Msg -> String -> Html.Html Msg
evA attrs url msg text =
    Html.a
        ([ Attributes.href url, onClickMsg msg ] ++ attrs)
        [ Html.text text ]


navA : List (Html.Attribute Msg) -> Router.Route -> String -> Html.Html Msg
navA attrs route text =
    evA attrs (Router.toUrl route) (NavigateTo route) text


hrefIcon : List (Html.Attribute Msg) -> String -> String -> Html.Html Msg
hrefIcon attrs href name =
    Html.a
        ([ Attributes.href href, class [ Styles.NavIcon ] ] ++ attrs)
        [ icon name ]


navIcon : List (Html.Attribute Msg) -> Router.Route -> String -> Html.Html Msg
navIcon attrs route name =
    Html.a
        ([ Attributes.href (Router.toUrl route)
         , onClickMsg (NavigateTo route)
         , class [ Styles.NavIcon ]
         ]
            ++ attrs
        )
        [ icon name ]


icon : String -> Html.Html Msg
icon name =
    Svg.svg
        [ SvgAttributes.viewBox "0 0 100 100" ]
        [ Svg.use
            [ SvgAttributes.xlinkHref
                ("/assets/img/icons.svg#si-awesome-" ++ name)
            ]
            []
        ]


onEventPreventMsg : String -> a -> Html.Attribute a
onEventPreventMsg name msg =
    Events.onWithOptions name
        { stopPropagation = True, preventDefault = True }
        (JD.succeed msg)


onClickMsg : a -> Html.Attribute a
onClickMsg msg =
    onEventPreventMsg "click" msg


loading : Styles.CssClasses -> Html.Html msg
loading size =
    Html.div [ class [ Styles.Loader, size ] ] []


notAuthed : Html.Html msg
notAuthed =
    Html.p [] [ Html.text "Not signed in" ]


notStaff : Html.Html msg
notStaff =
    Html.div []
        [ Html.h3 [] [ Html.text "Oops, you're not staff!" ]
        , Html.p []
            [ Html.text "If you think you should have access to this page, you'd better"
            , Html.a
                [ Attributes.href "mailto:sl@mehho.net"
                , Attributes.title "Email the Developers"
                ]
                [ Html.text "contact the developers" ]
            , Html.text "."
            ]
        ]


alreadyAuthed : Types.User -> Html.Html msg
alreadyAuthed user =
    Html.p [] [ Html.text ("Signed in as " ++ user.username) ]


textarea : List (Html.Attribute msg) -> Html.Html msg
textarea attrs =
    Html.div ([ class [ Styles.Textarea ], Attributes.contenteditable True ] ++ attrs) []


onInputContent : (String -> msg) -> Html.Attribute msg
onInputContent tagger =
    Events.on "input" (JD.map tagger targetInnerText)


targetInnerText : JD.Decoder String
targetInnerText =
    JD.at [ "target", "textContent" ] JD.string


forId : a -> Html.Attribute msg
forId =
    Attributes.for << toString


feedbackStyles : String -> Feedback.Feedback -> Html.Attribute msg
feedbackStyles key feedback =
    classList [ ( Styles.Error, Feedback.hasError key feedback ) ]



-- VALIDATION


ifShorterThan : Int -> error -> Validate.Validator error String
ifShorterThan length error =
    Validate.ifInvalid (String.length >> (>) length) error


ifShorterThanWords : Int -> error -> Validate.Validator error String
ifShorterThanWords length error =
    Validate.ifInvalid (String.words >> List.length >> (>) length) error


ifThenValidate : (subject -> Bool) -> Validate.Validator error subject -> Validate.Validator error subject
ifThenValidate condition validator subject =
    if condition subject then
        validator subject
    else
        []



-- RANDOMNESS


seed : Task.Task x Random.Seed
seed =
    Task.map (Random.initialSeed << round << Time.inMilliseconds) Time.now


sample : Random.Seed -> Nonempty a -> a
sample seed nonempty =
    Random.step (Random.int 0 <| Nonempty.length nonempty - 1) seed
        |> Tuple.first
        |> (\i -> Nonempty.get i nonempty)


shuffle : Random.Seed -> List a -> List a
shuffle seed list =
    shuffleHelp ( list, seed ) |> Tuple.first


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



-- NONEMPTY


nonemptyMaximum : Nonempty comparable -> comparable
nonemptyMaximum (Nonempty head tail) =
    List.maximum tail
        |> Maybe.withDefault head
        |> max head


nonemptyMinimum : Nonempty comparable -> comparable
nonemptyMinimum (Nonempty head tail) =
    List.minimum tail
        |> Maybe.withDefault head
        |> min head



-- EXPERIMENT FACTORS


readTime : { a | readFactor : Int } -> { b | text : String } -> Time.Time
readTime { readFactor } { text } =
    toFloat (List.length (String.words text) * readFactor) * Time.second


writeTime : { a | writeFactor : Int } -> { b | text : String } -> Time.Time
writeTime { writeFactor } { text } =
    toFloat (List.length (String.words text) * writeFactor) * Time.second



-- MISC


resultToTask : Result a b -> Task.Task a b
resultToTask result =
    case result of
        Ok value ->
            Task.succeed value

        Err error ->
            Task.fail error
