module Components.Login exposing (component, translator)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import RouteUrl.Builder as Builder
import Maybe.Extra exposing ((?))
import Components.Login.Types exposing (..)
import Components.Login.Routes exposing (..)
import Services.Account.Types as AccountTypes
import Wiring exposing (Component)


-- MODEL


init : ( Model, Cmd Msg )
init =
    ( Model "" "", Cmd.none )



-- MESSAGES


translator : TranslationDictionary t parentMsg -> Translator parentMsg
translator dictionary msg =
    case msg of
        OutNavigateBack ->
            dictionary.onNavigateBack

        OutLoginUser user ->
            dictionary.onLoginUser user

        OutClearLoginFeedback ->
            dictionary.onClearLoginFeedback



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg, Maybe OutMsg )
update msg model =
    case msg of
        RequestNavigateBack ->
            ( model, Cmd.none, Just OutNavigateBack )

        NavigateTo route ->
            ( model, Cmd.none, Nothing )

        InputUsername username ->
            ( { model | username = username }, Cmd.none, Just OutClearLoginFeedback )

        InputPassword password ->
            ( { model | password = password }, Cmd.none, Just OutClearLoginFeedback )

        Login ->
            ( model, Cmd.none, Just (OutLoginUser model) )



-- VIEW


view : AccountTypes.Model -> Model -> Html Msg
view account model =
    let
        body =
            case account of
                AccountTypes.Anonymous feedback ->
                    loginFormView feedback model False

                AccountTypes.Authenticating _ ->
                    loginFormView (AccountTypes.Feedback Nothing Nothing Nothing) model True

                AccountTypes.Authenticated _ user ->
                    p [] [ text ("Signed in as " ++ user.username) ]
    in
        div []
            [ button [ onClick RequestNavigateBack ] [ text "Back" ]
            , div [] [ body ]
            ]


loginFormView : AccountTypes.Feedback -> Model -> Bool -> Html Msg
loginFormView feedback model isDisabled =
    div []
        [ h2 [] [ text "Sign in" ]
          -- TODO: no account / sign up link
        , Html.form [ onSubmit Login ]
            [ div []
                [ label [ for "inputUsername" ] [ text "Username" ]
                , input
                    [ id "inputUsername"
                    , disabled isDisabled
                    , autofocus True
                    , placeholder "joey"
                    , type' "text"
                    , value model.username
                    , onInput InputUsername
                    ]
                    []
                , span [] [ text (feedback.username ? "") ]
                ]
            , div []
                [ label [ for "inputPassword" ] [ text "Password" ]
                , input
                    [ id "inputPassword"
                    , disabled isDisabled
                    , placeholder "ubA1oh"
                    , type' "password"
                    , value model.password
                    , onInput InputPassword
                    ]
                    []
                , span [] [ text (feedback.password ? "") ]
                ]
            , div []
                [ span [] [ text (feedback.global ? "") ]
                , button
                    [ type' "submit"
                    , disabled isDisabled
                    ]
                    [ text "Sign in" ]
                  -- TODO: forgotten password link
                ]
            ]
        ]



-- ROUTING


model2builder : Model -> Maybe Builder.Builder
model2builder model =
    Builder.builder
        |> Builder.replacePath []
        |> Just


builder2routeMessages : Builder.Builder -> ( Route, List Msg )
builder2routeMessages builder =
    ( IndexRoute, [] )



-- COMPONENT


component =
    Component init update view (always Sub.none) NavigateTo model2builder builder2routeMessages
