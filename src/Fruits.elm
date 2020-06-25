module Fruits exposing (main)

import Browser
import Html exposing (Html, button, div, h2, hr, p, pre, text)
import Html.Events exposing (onClick)
import Http



-- API Configuration


baseApiUrl : String
baseApiUrl =
    "http://localhost:3000/"



-- INIT


initialModel : Model
initialModel =
    { fruitStatus = NotLoaded
    }



-- MODEl


type alias Model =
    { fruitStatus : ApiResultStatus
    }


type ApiResultStatus
    = NotLoaded
    | Loading
    | Failure
    | Success String


type Endpoint
    = GetFruit



-- MSG


type Msg
    = GetData Endpoint
    | GotFruit (Result Http.Error String)



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetData endpoint ->
            case endpoint of
                GetFruit ->
                    ( { model | fruitStatus = Loading }
                    , Http.get
                        { url = baseApiUrl ++ "fruit"
                        , expect = Http.expectString GotFruit
                        }
                    )

        GotFruit result ->
            case result of
                Ok fruit ->
                    ( { model | fruitStatus = Success fruit }
                    , Cmd.none
                    )

                _ ->
                    ( { model | fruitStatus = Failure }
                    , Cmd.none
                    )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        (viewData "果物" GetFruit model.fruitStatus)


viewData : String -> Endpoint -> ApiResultStatus -> List (Html Msg)
viewData label endpoint apiResultStatus =
    let
        showResult =
            case apiResultStatus of
                NotLoaded ->
                    text "Not loaded"

                Loading ->
                    text "Loading..."

                Failure ->
                    text "Failed to get data :("

                Success resultString ->
                    pre [] [ text resultString ]
    in
    [ h2 [] [ text label ]
    , div [] [ button [ onClick (GetData endpoint) ] [ text "Get Data" ] ]
    , div [] [ showResult ]
    , hr [] []
    ]



-- VIEW HELPERS


viewGetterButton : Endpoint -> String -> Html Msg
viewGetterButton endpoint label =
    div [] [ button [ onClick (GetData endpoint) ] [ text label ] ]


viewNotLoadedText : Html msg
viewNotLoadedText =
    text "Not Loaded"



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> ( initialModel, Cmd.none )
        , update = update
        , subscriptions = always Sub.none
        }
