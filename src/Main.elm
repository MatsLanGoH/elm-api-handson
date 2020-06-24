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
    | GotApiResponse Endpoint (Result Http.Error String)



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetData endpoint ->
            let
                ( resource, modelUpdate ) =
                    case endpoint of
                        PizzaName ->
                            ( "pizza-name", { model | pizzaNameStatus = Loading } )

                        PizzaNames ->
                            ( "pizza-names", { model | pizzaNamesStatus = Loading } )

                        Drink ->
                            ( "drink", { model | drinkStatus = Loading } )
            in
            ( modelUpdate
            , Http.get
                { url = baseApiUrl ++ resource
                , expect = Http.expectString (GotApiResponse endpoint)
                }
            )

        GotApiResponse endpoint result ->
            let
                status =
                    case result of
                        Ok resultText ->
                            Success resultText

                        Err _ ->
                            Failure

                modelUpdate =
                    case endpoint of
                        PizzaName ->
                            { model | pizzaNameStatus = status }

                        PizzaNames ->
                            { model | pizzaNamesStatus = status }

                        Drink ->
                            { model | drinkStatus = status }
            in
            ( modelUpdate, Cmd.none )



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
