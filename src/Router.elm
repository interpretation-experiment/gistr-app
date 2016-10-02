module Router
    exposing
        ( ProfileRoute(..)
        , Route(..)
        , authRedirect
        , locationParser
        , toUrl
        )

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


type ProfileRoute
    = Dashboard
    | Settings
    | Emails
    | Confirm String
    | Questionnaire
    | WordSpan


authRedirect : Types.AuthStatus -> Route -> Route
authRedirect auth route =
    case auth of
        Types.Anonymous ->
            case route of
                Profile profileRoute ->
                    Login (Just route)

                _ ->
                    route

        Types.Authenticated _ ->
            case route of
                Login _ ->
                    Home

                Recover ->
                    Profile Settings

                Register _ ->
                    Home

                Prolific ->
                    Home

                _ ->
                    route

        Types.Authenticating ->
            route



-- URL -> ROUTE


locationParser : Navigation.Location -> ( String, Maybe Route )
locationParser location =
    let
        path =
            location.pathname

        query =
            location.search
    in
        ( path ++ query
        , String.dropLeft 1 path
            ++ query
            |> UrlQueryParser.parse identity urlParser
            |> Result.toMaybe
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
