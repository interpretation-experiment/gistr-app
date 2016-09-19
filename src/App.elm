module App exposing (..)

import Html
import Html.Events
import Navigation
import Router exposing (Route(..), ProfileRoute(..))


-- MODEL


type alias Model =
    { route : Route
    }


init : Maybe Route -> ( Model, Cmd Msg )
init maybeRoute =
    urlUpdate maybeRoute (Model Home)



-- MESSAGES


type Msg
    = NavigateTo Route



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case (Debug.log "msg" msg) of
        NavigateTo route ->
            model
                ! if model.route /= route then
                    [ Navigation.newUrl (Router.toUrl route) ]
                  else
                    []


urlUpdate : Maybe Route -> Model -> ( Model, Cmd Msg )
urlUpdate maybeRoute model =
    case (Debug.log "route" maybeRoute) of
        Just route ->
            { model | route = route } ! []

        Nothing ->
            model ! [ Navigation.modifyUrl (Router.toUrl model.route) ]



-- VIEW


view : Model -> Html.Html Msg
view model =
    case model.route of
        Home ->
            Html.div []
                [ Html.h1 [] [ Html.text "Home" ]
                , navButton About "About"
                , navButton (Profile Tests) "Profile"
                ]

        About ->
            Html.div []
                [ navButton Home "Back"
                , Html.h1 [] [ Html.text "About" ]
                ]

        Profile profileRoute ->
            Html.div []
                [ navButton Home "Back"
                , Html.h1 [] [ Html.text "Profile" ]
                , profileMenu profileRoute
                , profileView profileRoute
                ]


navButton : Route -> String -> Html.Html Msg
navButton route text =
    Html.button [ Html.Events.onClick (NavigateTo route) ] [ Html.text text ]


profileMenu : ProfileRoute -> Html.Html Msg
profileMenu profileRoute =
    Html.ul []
        [ Html.li [] [ navButton (Profile Tests) "Tests" ]
        , Html.li [] [ navButton (Profile Settings) "Settings" ]
        , Html.li [] [ navButton (Profile Emails) "Emails" ]
        ]


profileView : ProfileRoute -> Html.Html Msg
profileView profileRoute =
    case profileRoute of
        Tests ->
            Html.text "Tests"

        Settings ->
            Html.text "Settings"

        Emails ->
            Html.text "Emails"



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- APP


main : Program Never
main =
    Navigation.program (Navigation.makeParser Router.locationParser)
        { init = init
        , view = view
        , update = update
        , urlUpdate = urlUpdate
        , subscriptions = subscriptions
        }
