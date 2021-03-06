module Helpers
    exposing
        ( (!!)
        , (!!!)
        , alreadyAuthed
        , authenticatedOr
        , authenticatedOrIgnore
        , avatar
        , cmd
        , errorStyle
        , evA
        , evButton
        , evIconButton
        , evLoadingButton
        , extractFeedback
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
        , navigateToNoflush
        , nonemptyMaximum
        , nonemptyMinimum
        , notAuthed
        , notStaff
        , notify
        , onChange
        , onEventPreventMsg
        , plural
        , readTime
        , resultToTask
        , sample
        , seed
        , shuffle
        , splitFirst
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
import Msg exposing (Msg(NavigateTo, Error, NotificationMsg))
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
        newModel =
            navigateToNoflush model request |> Tuple.first

        flushedModel =
            if newModel.route /= model.route then
                Model.emptyForms newModel
            else
                model
    in
        flushedModel ! Cmds.cmdsForModel flushedModel


navigateToNoflush : Model -> Router.Route -> ( Model, Cmd Msg )
navigateToNoflush model request =
    let
        finalRoute =
            Router.normalize model.auth (Debug.log "nav request" request)

        newModel =
            if finalRoute /= model.route then
                { model | route = (Debug.log "nav final" finalRoute) }
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
    -> model
    -> List ( String, String )
    -> (Feedback.Feedback -> ( model, Cmd Msg, List Msg ))
    -> ( model, Cmd Msg, List Msg )
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


notify : Types.NotificationId -> Msg
notify id =
    NotificationMsg <|
        Notification.New <|
            Notification.new id (Just <| 10 * Time.second)



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


evLoadingButton :
    ExpModel.LoadingState
    -> List (Html.Attribute Msg)
    -> Msg
    -> ( String, String, String )
    -> Html.Html Msg
evLoadingButton status attrs msg ( loadedText, loadingText, waitingText ) =
    let
        contents =
            case status of
                ExpModel.Loaded ->
                    [ Html.text loadedText ]

                ExpModel.Loading ->
                    [ Html.text loadingText ]

                ExpModel.Waiting ->
                    [ Html.text waitingText
                    , loading Styles.Small
                    ]
    in
        Html.button
            ((onClickMsg msg) :: (Attributes.disabled (status /= ExpModel.Loaded)) :: attrs)
            contents


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


onChange : (String -> msg) -> Html.Attribute msg
onChange tagger =
    Events.on "change" (JD.map tagger Events.targetValue)


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


forId : a -> Html.Attribute msg
forId =
    Attributes.for << toString


errorStyle : String -> Feedback.Feedback -> Html.Attribute msg
errorStyle key feedback =
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


readTime : { a | readFactor : Float } -> { b | text : String } -> Time.Time
readTime { readFactor } { text } =
    toFloat (List.length (String.words text)) * readFactor * Time.second


writeTime : { a | writeFactor : Float } -> { b | text : String } -> Time.Time
writeTime { writeFactor } { text } =
    toFloat (List.length (String.words text)) * writeFactor * Time.second



-- STRING


splitFirst : String -> String -> ( String, Maybe String )
splitFirst splitter string =
    let
        parts =
            String.split splitter string
    in
        case parts of
            [] ->
                ( string, Nothing )

            [ head ] ->
                ( head, Nothing )

            head :: tail ->
                ( head, Just <| String.join splitter tail )



-- MISC


plural : String -> String -> Int -> String
plural singularForm pluralForm count =
    if count == 1 then
        singularForm
    else
        pluralForm


resultToTask : Result a b -> Task.Task a b
resultToTask result =
    case result of
        Ok value ->
            Task.succeed value

        Err error ->
            Task.fail error
