module Fruits exposing (main)

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
    { fruit = ""
    , fruitList = ""
    , store = ""
    , storeList = ""
    , customer = ""
    , order = ""
    }



-- MODEl


type alias Model =
    { fruit : String
    , fruitList : String
    , store : String
    , storeList : String
    , customer : String
    , order : String
    }


type Endpoint
    = GetFruit
    | GetFruitList
    | GetStore
    | GetStoreList
    | GetCustomer
    | GetOrder



-- MSG


type Msg
    = GetData Endpoint
    | GotFruit (Result Http.Error String)
    | GotFruitList (Result Http.Error String)
    | GotStore (Result Http.Error String)
    | GotStoreList (Result Http.Error String)
    | GotCustomer (Result Http.Error String)
    | GotOrder (Result Http.Error String)



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetData endpoint ->
            case endpoint of
                GetFruit ->
                    ( { model | fruit = "" }
                    , Http.get
                        { url = baseApiUrl ++ "fruit"
                        , expect = Http.expectString GotFruit
                        }
                    )

                GetFruitList ->
                    ( { model | fruit = "" }
                    , Http.get
                        { url = baseApiUrl ++ "fruits"
                        , expect = Http.expectString GotFruitList
                        }
                    )

                _ ->
                    ( model, Cmd.none )

        GotFruit result ->
            case result of
                Ok fruit ->
                    ( { model | fruit = fruit }
                    , Cmd.none
                    )

                _ ->
                    ( { model | fruit = "Failed :(" }
                    , Cmd.none
                    )

        GotFruitList result ->
            case result of
                Ok fruitlist ->
                    ( { model | fruitList = fruitlist }
                    , Cmd.none
                    )

                _ ->
                    ( { model | fruitList = "Failed :(" }
                    , Cmd.none
                    )

        _ ->
            ( model
            , Cmd.none
            )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "果物販売管理システム 🍇🍍🍒" ]
        , viewItem "果物" GetFruit model.fruit
        , viewItem "果物（複数）" GetFruitList model.fruitList
        ]


viewItem : String -> Endpoint -> String -> Html Msg
viewItem label endpoint item =
    let
        showItem =
            pre [] [ text item ]
    in
    div []
        [ h2 [] [ text label ]
        , viewGetterButton endpoint label
        , div [] [ showItem ]
        , hr [] []
        ]



-- VIEW HELPERS


viewGetterButton : Endpoint -> String -> Html Msg
viewGetterButton endpoint label =
    div [] [ button [ onClick (GetData endpoint) ] [ text <| label ++ "をGET" ] ]



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> ( initialModel, Cmd.none )
        , update = update
        , subscriptions = always Sub.none
        }
