module Fruits exposing (main)

import Browser
import Html exposing (Html, button, div, h1, h2, hr, pre, text)
import Html.Events exposing (onClick)
import Http
import Json.Decode as D exposing (Decoder, field, int, string)
import Html exposing (p)
import Json.Decode exposing (list)



-- API Configuration


baseApiUrl : String
baseApiUrl =
    "http://localhost:3000/"



-- INIT


initialModel : Model
initialModel =
    { fruit = noFruit
    , fruitList = [] 
    , store = ""
    , storeList = ""
    , customer = ""
    , order = ""
    }



-- MODEl


type alias Model =
    { fruit : Fruit
    , fruitList : List Fruit
    , store : String
    , storeList : String
    , customer : String
    , order : String
    }

type alias Fruit = 
    { name : String
    , price : Int
    }

noFruit : Fruit 
noFruit = 
    { name= ""
    , price= 0
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
    | GotFruit (Result Http.Error Fruit)
    | GotFruitList (Result Http.Error (List Fruit))
    | GotStore (Result Http.Error String)
    | GotStoreList (Result Http.Error String)
    | GotCustomer (Result Http.Error String)
    | GotOrder (Result Http.Error String)



-- DECODER


fruitDecoder : Decoder Fruit
fruitDecoder =
    D.map2 Fruit
        (field "name" string)
        (field "price" int)

fruitListDecoder : Decoder (List Fruit)
fruitListDecoder = 
    field "fruits" (list fruitDecoder)


-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetData endpoint ->
            case endpoint of
                GetFruit ->
                    ( { model | fruit = noFruit }
                    , Http.get
                        { url = baseApiUrl ++ "fruit"
                        , expect = Http.expectJson GotFruit fruitDecoder
                        }
                    )

                GetFruitList ->
                    ( { model | fruitList = [] }
                    , Http.get
                        { url = baseApiUrl ++ "fruits"
                        , expect = Http.expectJson GotFruitList fruitListDecoder
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
                    ( { model | fruit = noFruit }
                    , Cmd.none
                    )

        GotFruitList result ->
            case result of
                Ok fruitlist ->
                    ( { model | fruitList = fruitlist }
                    , Cmd.none
                    )

                _ ->
                    ( { model | fruitList = [] }
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
        , viewFruitItem "果物" GetFruit model.fruit
        , viewFruitListItem "果物（複数）" GetFruitList model.fruitList
        ]


viewFruitItem : String -> Endpoint -> Fruit -> Html Msg
viewFruitItem label endpoint fruit =
    let
        showItem = div [] [ p [] [ text fruit.name ]
                          , p [] [ text <| String.fromInt fruit.price]
                          ]
    in
    div []
        [ h2 [] [ text label ]
        , viewGetterButton endpoint label
        , div [] [ showItem ]
        , hr [] []
        ]

viewFruitListItem : String -> Endpoint -> List Fruit -> Html Msg
viewFruitListItem label endpoint fruitList =
    let
        showItem = fruitList |> 
                    List.map (\fruit -> (p [] [ text fruit.name, text <| String.fromInt fruit.price]))
    in
    div []
        [ h2 [] [ text label ]
        , viewGetterButton endpoint label
        , div [] showItem
        , hr [] []
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
