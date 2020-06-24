module Main exposing (main)

import Browser
import Html exposing (Html, button, div, h1, h2, hr, pre, text)
import Html.Events exposing (onClick)
import Http



-- API Configuration


baseApiUrl : String
baseApiUrl =
    "http://localhost:3000/"



-- INIT


initialModel : Model
initialModel =
    { pizzaNameStatus = NotLoaded
    }



-- MODEl


type alias Model =
    { pizzaNameStatus : ApiResultStatus
    }


type ApiResultStatus
    = NotLoaded
    | Loading
    | Failure
    | Success String



-- MSG


type Msg
    = GetPizzaName
    | GotApiResponse (Result Http.Error String)



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetPizzaName ->
            ( { model | pizzaNameStatus = Loading }
            , Http.get
                { url = baseApiUrl ++ "pizza-name"
                , expect = Http.expectString GotApiResponse
                }
            )

        GotApiResponse result ->
            case result of
                Ok resultText ->
                    ( { model | pizzaNameStatus = Success resultText }
                    , Cmd.none
                    )

                Err _ ->
                    ( { model | pizzaNameStatus = Failure }
                    , Cmd.none
                    )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        ([]
            ++ viewSinglePizza model.pizzaNameStatus
        )


viewSinglePizza : ApiResultStatus -> List (Html Msg)
viewSinglePizza apiResultStatus =
    let
        showResult =
            case apiResultStatus of
                NotLoaded ->
                    text "Not loaded"

                Loading ->
                    text "Loading..."

                Failure ->
                    text "Failed to get pizza name :("

                Success resultString ->
                    pre [] [ text resultString ]
    in
    [ h2 [] [ text "Pizza Name" ]
    , div [] [ button [ onClick GetPizzaName ] [ text "Get Pizza Name" ] ]
    , div [] [ showResult ]
    , hr [] []
    ]



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> ( initialModel, Cmd.none )
        , update = update
        , subscriptions = always Sub.none
        }
