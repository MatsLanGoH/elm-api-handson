module Main exposing (main)

import Browser
import Html exposing (Html, button, div, h2, hr, pre, text)
import Html.Events exposing (onClick)
import Http
import Json.Decode exposing (..)



-- API Configuration


baseApiUrl : String
baseApiUrl =
    "http://localhost:3000/"



-- INIT


initialModel : Model
initialModel =
    { pizzaNameStatus = NotLoaded
    , pizzaNamesStatus = NotLoaded
    , drinkStatus = NotLoaded
    }



-- MODEl


type alias Model =
    { pizzaNameStatus : ApiResultStatus
    , pizzaNamesStatus : ApiResultStatus
    , drinkStatus : ApiResultStatus
    }


type ApiResultStatus
    = NotLoaded
    | Loading
    | Failure
    | Success String


type Endpoint
    = PizzaName
    | PizzaNames
    | Drink



-- MSG


type Msg
    = GetData Endpoint
    | GotPizzaName (Result Http.Error String)
    | GotPizzaNames (Result Http.Error (List String))
    | GotDrink (Result Http.Error String)



-- DECODERS


pizzaNameDecoder : Decoder String
pizzaNameDecoder =
    field "pizza" string


pizzaNamesDecoder : Decoder (List String)
pizzaNamesDecoder =
    field "pizzas" (list string)


drinkDecoder : Decoder String
drinkDecoder =
    field "name" string



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetData endpoint ->
            case endpoint of
                PizzaName ->
                    ( { model | pizzaNameStatus = Loading }
                    , Http.get
                        { url = baseApiUrl ++ "pizza-name"
                        , expect = Http.expectJson GotPizzaName pizzaNameDecoder
                        }
                    )

                PizzaNames ->
                    ( { model | pizzaNamesStatus = Loading }
                    , Http.get
                        { url = baseApiUrl ++ "pizza-names"
                        , expect = Http.expectJson GotPizzaNames pizzaNamesDecoder
                        }
                    )

                Drink ->
                    ( { model | drinkStatus = Loading }
                    , Http.get
                        { url = baseApiUrl ++ "drink"
                        , expect = Http.expectJson GotDrink drinkDecoder
                        }
                    )

        GotPizzaNames result ->
            let
                status =
                    case result of
                        Ok resultText ->
                            Success (String.join ", " resultText)

                        Err _ ->
                            Failure

                updatedModel =
                    { model | pizzaNamesStatus = status }
            in
            ( updatedModel, Cmd.none )

        GotPizzaName result ->
            let
                status =
                    case result of
                        Ok resultBody ->
                            Success resultBody

                        _ ->
                            Failure

                updatedModel =
                    { model | pizzaNameStatus = status }
            in
            ( updatedModel, Cmd.none )

        GotDrink result ->
            let
                status =
                    case result of
                        Ok resultBody ->
                            Success resultBody

                        _ ->
                            Failure

                updatedModel =
                    { model | drinkStatus = status }
            in
            ( updatedModel, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        (viewData "Pizza Name" PizzaName model.pizzaNameStatus
            ++ viewData "Pizza Names" PizzaNames model.pizzaNamesStatus
            ++ viewData "Drink" Drink model.drinkStatus
        )


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



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> ( initialModel, Cmd.none )
        , update = update
        , subscriptions = always Sub.none
        }
