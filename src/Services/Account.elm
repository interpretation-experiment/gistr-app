port module Services.Account exposing (service, translator)

import Task
import Json.Encode as Encode
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (decode, optional, required)
import Maybe.Extra exposing (mapDefault)
import HttpBuilder exposing (..)
import Services.Account.Types exposing (..)
import Wiring exposing (Service)


service =
    Service init update subscriptions



-- TRANSLATION


translator : TranslationDictionary t parentMsg -> Translator parentMsg
translator dictionary msg =
    case msg of
        LoggedIn ->
            dictionary.onLoggedIn

        LoggedOut ->
            dictionary.onLoggedOut



-- MODEL


init : ( Model, Cmd Msg )
init =
    ( Authenticating FetchingToken, getLocalToken Nothing )



-- UPDATE


port setLocalToken : Maybe Token -> Cmd msg



{- The int argument to getLocalToken is never used -}


port getLocalToken : Maybe Int -> Cmd msg


update : Msg -> Model -> ( Model, Cmd Msg, Maybe OutMsg )
update msg model =
    case msg of
        Login credentials ->
            ( Authenticating FetchingToken, fetchToken credentials, Nothing )

        TokenSucceed token ->
            ( Authenticating FetchingUser
            , Cmd.batch [ setLocalToken (Just token), fetchUser token ]
            , Nothing
            )

        TokenFail feedback ->
            ( Anonymous feedback, Cmd.none, Nothing )

        UserSucceed token user ->
            ( Authenticated token user, Cmd.none, Just LoggedIn )

        UserFail error ->
            let
                _ =
                    Debug.log "error fetching user" error
            in
                ( Anonymous (Feedback Nothing Nothing Nothing)
                , Cmd.none
                , Nothing
                )

        ClearFeedback ->
            case model of
                Anonymous _ ->
                    ( Anonymous (Feedback Nothing Nothing Nothing)
                    , Cmd.none
                    , Nothing
                    )

                -- Ignore any other status (there's no feedback to clear)
                _ ->
                    ( model, Cmd.none, Nothing )

        Logout ->
            case model of
                Authenticated token _ ->
                    ( Authenticating LoggingOut
                    , Cmd.batch [ setLocalToken Nothing, logout token ]
                    , Nothing
                    )

                -- Ignore any other status (there's no one to log out)
                _ ->
                    ( model, Cmd.none, Nothing )

        LogoutSucceed ->
            ( Anonymous (Feedback Nothing Nothing Nothing)
            , Cmd.none
            , Just LoggedOut
            )

        LogoutFail error ->
            let
                _ =
                    Debug.log "error logging user out" error
            in
                ( Anonymous (Feedback Nothing Nothing Nothing)
                , Cmd.none
                , Just LoggedOut
                )


fetchToken : Credentials -> Cmd Msg
fetchToken credentials =
    let
        jsonCredentials =
            Encode.object
                [ ( "username", Encode.string credentials.username )
                , ( "password", Encode.string credentials.password )
                ]

        tokenDecoder =
            Decode.at [ "key" ] Decode.string

        errorDecoder =
            let
                maybeOneString =
                    Decode.maybe (Decode.tuple1 identity Decode.string)

                checkEmptyFeedback feedback =
                    case ( feedback.username, feedback.password, feedback.global ) of
                        ( Nothing, Nothing, Nothing ) ->
                            Decode.fail "Unknown error"

                        _ ->
                            Decode.succeed feedback
            in
                (decode Feedback
                    |> optional "username" maybeOneString Nothing
                    |> optional "password" maybeOneString Nothing
                    |> optional "non_field_errors" maybeOneString Nothing
                )
                    `Decode.andThen` checkEmptyFeedback

        feedbackError error =
            case error of
                BadResponse response ->
                    response.data

                _ ->
                    toString error
                        |> Just
                        |> Feedback Nothing Nothing

        task =
            post "//127.0.0.1:8000/api/rest-auth/login/"
                |> withJsonBody jsonCredentials
                |> withHeader "Content-Type" "application/json"
                |> withHeader "Accept" "application/json"
                |> send (jsonReader tokenDecoder) (jsonReader errorDecoder)
    in
        Task.perform (TokenFail << feedbackError) (TokenSucceed << .data) task


fetchUser : Token -> Cmd Msg
fetchUser token =
    let
        userDecoder =
            decode User
                |> required "id" Decode.int
                |> required "username" Decode.string
                |> required "is_active" Decode.bool
                |> required "is_staff" Decode.bool

        errorDecoder =
            Decode.at [ "detail" ] Decode.string

        stringError error =
            case error of
                BadResponse response ->
                    response.data

                _ ->
                    toString error

        task =
            get "//127.0.0.1:8000/api/users/me/"
                |> withHeader "Authorization" ("Token " ++ token)
                |> withHeader "Content-Type" "application/json"
                |> withHeader "Accept" "application/json"
                |> send (jsonReader userDecoder) (jsonReader errorDecoder)
    in
        Task.perform (UserFail << stringError) (UserSucceed token << .data) task


logout : Token -> Cmd Msg
logout token =
    let
        errorDecoder =
            Decode.at [ "detail" ] Decode.string

        stringError error =
            case error of
                BadResponse response ->
                    response.data

                _ ->
                    toString error

        task =
            post "//127.0.0.1:8000/api/rest-auth/logout/"
                |> withHeader "Authorization" ("Token " ++ token)
                |> withHeader "Content-Type" "application/json"
                |> withHeader "Accept" "application/json"
                |> send (always (Ok "")) (jsonReader errorDecoder)
    in
        Task.perform (LogoutFail << stringError) (always LogoutSucceed) task



-- SUBSCRIPTIONS


port localToken : (Maybe Token -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    mapDefault (TokenFail (Feedback Nothing Nothing Nothing)) TokenSucceed
        |> localToken
