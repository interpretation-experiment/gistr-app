module Router
    exposing
        ( Route(..)
        , ProfileRoute(..)
        , locationParser
        , toUrl
        )

import Navigation
import String
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
    | Reset String String
    | Profile ProfileRoute


type ProfileRoute
    = Tests
    | Settings
    | Emails



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
        , format Recover (s "login" </> s "recover")
        , format Reset
            (s "login" </> s "reset" <?> stringQ "uid" <?> stringQ "token")
        , format Login (s "login" <?> maybeQ (routeQ "next"))
        , format Profile (s "profile" </> profileUrlParser)
        , format (Profile Tests) (s "profile")
        ]
        items
        formatter


profileUrlParser : UrlParser (ProfileRoute -> a) a
profileUrlParser =
    oneOf
        [ format Tests (s "tests")
        , format Settings (s "settings")
        , format Emails (s "emails")
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

        Reset uid token ->
            "/login/reset?token=" ++ token ++ "&uid=" ++ uid

        Profile profileRoute ->
            "/profile" ++ (toProfileUrl profileRoute)


toProfileUrl : ProfileRoute -> String
toProfileUrl profileRoute =
    case profileRoute of
        Tests ->
            "/tests"

        Settings ->
            "/settings"

        Emails ->
            "/emails"
