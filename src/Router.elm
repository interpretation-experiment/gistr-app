module Router
    exposing
        ( ExploreRoute(..)
        , ProfileRoute(..)
        , Route(..)
        , parse
        , normalize
        , toUrl
        )

import Maybe.Extra exposing (isJust, unwrap)
import Navigation
import String
import Types
import UrlQueryParser
    exposing
        ( (</>)
        , (<?>)
        , QueryParser
        , UrlParser
        , customQ
        , format
        , int
        , intQ
        , maybeQ
        , oneOf
        , s
        , stringQ
        )


-- ROUTES


type Route
    = Home
    | About
    | Login (Maybe Route)
    | Recover
    | Reset Types.ResetTokens
    | Register (Maybe String)
    | Error
    | Prolific
    | Profile ProfileRoute
    | Experiment
    | Admin
    | Explore ExploreRoute


type ProfileRoute
    = Dashboard
    | Settings
    | Emails
    | Confirm String
    | Questionnaire
    | WordSpan


type ExploreRoute
    = Trees (Maybe Int) (Maybe Int) (Maybe String)
    | Tree Int


normalize : Types.AuthStatus -> Route -> Route
normalize auth route =
    case auth of
        Types.Anonymous ->
            case route of
                Home ->
                    route

                About ->
                    route

                Login _ ->
                    route

                Recover ->
                    route

                Reset _ ->
                    route

                Register _ ->
                    route

                Error ->
                    route

                Prolific ->
                    route

                Profile _ ->
                    Login (Just route)

                Experiment ->
                    Login (Just route)

                Admin ->
                    Login (Just route)

                Explore _ ->
                    Login (Just route)

        Types.Authenticated { user } ->
            case route of
                Home ->
                    route

                About ->
                    route

                Login _ ->
                    Home

                Recover ->
                    Profile Settings

                Reset _ ->
                    route

                Register _ ->
                    Home

                Error ->
                    route

                Prolific ->
                    Home

                Profile profileRoute ->
                    case profileRoute of
                        Dashboard ->
                            route

                        Settings ->
                            route

                        Emails ->
                            route

                        Confirm _ ->
                            route

                        Questionnaire ->
                            if isJust user.profile.questionnaireId then
                                Profile Dashboard
                            else
                                route

                        WordSpan ->
                            route

                Experiment ->
                    route

                Admin ->
                    if user.isStaff then
                        route
                    else
                        Home

                Explore _ ->
                    if user.isStaff then
                        route
                    else
                        Home

        Types.Authenticating ->
            route



-- URL -> ROUTE


parse : Navigation.Location -> ( String, Route )
parse location =
    let
        url =
            location.pathname ++ location.search
    in
        ( url
        , String.dropLeft 1 url
            |> UrlQueryParser.parse identity urlParser
            |> Result.withDefault Home
        )


routeQ : String -> QueryParser (Route -> a) a
routeQ =
    customQ "ROUTE" (UrlQueryParser.parse identity urlParser << String.dropLeft 1)


urlParser : UrlParser (Route -> a) a
urlParser items formatter =
    oneOf
        [ format Home (s "")
        , format About (s "about")
        , format Login (s "login" <?> maybeQ (routeQ "next"))
        , format Recover (s "login" </> s "recover")
        , format (\uid token -> Reset (Types.ResetTokens uid token))
            (s "login" </> s "reset" <?> stringQ "uid" <?> stringQ "token")
        , format Register (s "register" <?> maybeQ (stringQ "prolific_id"))
        , format Error (s "error")
        , format Prolific (s "register" </> s "prolific")
        , format (Profile Dashboard) (s "profile")
        , format Profile (s "profile" </> profileUrlParser)
        , format Experiment (s "experiment")
        , format Admin (s "admin")
        , format (\page pageSize rootBucket -> Explore (Trees page pageSize rootBucket))
            (s "explore" <?> maybeQ (intQ "page") <?> maybeQ (intQ "page_size") <?> maybeQ (stringQ "root_bucket"))
        , format (Explore << Tree) (s "explore" </> int)
        ]
        items
        formatter


profileUrlParser : UrlParser (ProfileRoute -> a) a
profileUrlParser =
    oneOf
        [ format Dashboard (s "dashboard")
        , format Settings (s "settings")
        , format Emails (s "emails")
        , format Confirm (s "emails" </> s "confirm" <?> stringQ "key")
        , format Questionnaire (s "questionnaire")
        , format WordSpan (s "word-span")
        ]



-- ROUTE -> URL


toUrl : Route -> String
toUrl route =
    case route of
        Home ->
            "/"

        About ->
            "/about"

        Login maybeNext ->
            case maybeNext of
                Nothing ->
                    "/login"

                Just next ->
                    "/login?next=" ++ (toUrl next)

        Recover ->
            "/login/recover"

        Reset { uid, token } ->
            "/login/reset?token=" ++ token ++ "&uid=" ++ uid

        Register maybeProlific ->
            case maybeProlific of
                Nothing ->
                    "/register"

                Just prolificId ->
                    "/register?prolific_id=" ++ prolificId

        Error ->
            "/error"

        Prolific ->
            "/register/prolific"

        Profile profileRoute ->
            "/profile" ++ (toProfileUrl profileRoute)

        Experiment ->
            "/experiment"

        Admin ->
            "/admin"

        Explore (Trees maybePage maybePageSize maybeRootBucket) ->
            let
                query =
                    unwrap [] (\page -> [ "page=" ++ toString page ]) maybePage
                        ++ (unwrap [] (\pageSize -> [ "page_size=" ++ toString pageSize ]) maybePageSize)
                        ++ (unwrap [] (\rootBucket -> [ "root_bucket=" ++ rootBucket ]) maybeRootBucket)
                        |> String.join "&"
            in
                "/explore"
                    ++ (if String.isEmpty query then
                            ""
                        else
                            "?" ++ query
                       )

        Explore (Tree id) ->
            "/explore/" ++ (toString id)


toProfileUrl : ProfileRoute -> String
toProfileUrl profileRoute =
    case profileRoute of
        Dashboard ->
            "/dashboard"

        Settings ->
            "/settings"

        Emails ->
            "/emails"

        Confirm key ->
            "/emails/confirm?key=" ++ key

        Questionnaire ->
            "/questionnaire"

        WordSpan ->
            "/word-span"
