module Fruits exposing (main)

import Browser
import Html exposing (Html, button, div, h1, h2, hr, p, text)
import Html.Events exposing (onClick)
import Http
import Json.Decode as D exposing (Decoder, field, int, list, string, succeed)
import Json.Decode.Pipeline exposing (optional, required)
import Html exposing (li)
import Html exposing (ul)



-- API Configuration


baseApiUrl : String
baseApiUrl =
    "http://localhost:3000/"



-- INIT


initialModel : Model
initialModel =
    { fruit = noFruit
    , fruitList = []
    , store = noStore
    , storeList = []
    , customer = ""
    , order = ""
    }



-- MODEl


type alias Model =
    { fruit : Fruit
    , fruitList : List Fruit
    , store : Store
    , storeList : List Store
    , customer : String
    , order : String
    }


type alias Fruit =
    { name : String
    , price : Int
    }


type alias Store =
    { address : String
    , owner : Maybe String
    }


noFruit : Fruit
noFruit =
    { name = ""
    , price = 0
    }


noStore : Store
noStore =
    { address = ""
    , owner = Nothing
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
    | GotStore (Result Http.Error Store)
    | GotStoreList (Result Http.Error (List Store))
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


storeDecoder : Decoder Store
storeDecoder =
    D.succeed Store
        |> required "address" D.string
        |> optional "owner" (D.map Just D.string) Nothing


storeListDecoder : Decoder (List Store)
storeListDecoder =
    field "stores" (list storeDecoder)



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

                GetStore ->
                    ( { model | store = noStore }
                    , Http.get
                        { url = baseApiUrl ++ "store"
                        , expect = Http.expectJson GotStore storeDecoder
                        }
                    )

                GetStoreList ->
                    ( { model | storeList = [] }
                    , Http.get
                        { url = baseApiUrl ++ "stores"
                        , expect = Http.expectJson GotStoreList storeListDecoder
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

        GotStore result ->
            case result of
                Ok store ->
                    ( { model | store = store }
                    , Cmd.none
                    )

                _ ->
                    ( { model | store = noStore }
                    , Cmd.none
                    )

        GotStoreList result ->
            case result of
                Ok storelist ->
                    ( { model | storeList = storelist }
                    , Cmd.none
                    )

                _ ->
                    ( { model | storeList = [] }
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
        , viewStoreItem "店舗" GetStore model.store
        , viewStoreListItem "店舗（複数）" GetStoreList model.storeList
        ]


viewFruitItem : String -> Endpoint -> Fruit -> Html Msg
viewFruitItem label endpoint fruit =
    let
        showItem =
            div []
                [ p [] [ text fruit.name ]
                , p [] [ text <| String.fromInt fruit.price ]
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
        showItem =
            fruitList
                |> List.map (\fruit -> p [] [ text fruit.name, text <| String.fromInt fruit.price ])
    in
    div []
        [ h2 [] [ text label ]
        , viewGetterButton endpoint label
        , div [] showItem
        , hr [] []
        ]


viewStoreItem : String -> Endpoint -> Store -> Html Msg
viewStoreItem label endpoint store =
    let
        storeOwner =
            case store.owner of
                Nothing ->
                    Html.text ""

                Just owner ->
                    p [] [ text owner ]

        showItem =
            div []
                [ p [] [ text store.address ]
                , storeOwner
                ]
    in
    div []
        [ h2 [] [ text label ]
        , viewGetterButton endpoint label
        , div [] [ showItem ]
        , hr [] []
        ]


viewStoreListItem : String -> Endpoint -> List Store -> Html Msg
viewStoreListItem label endpoint storeList =
    let
        showItem =
            storeList
                |> List.map
                    (\store ->
                        ul []
                            [ li [] [ text ("Address:" ++ store.address) ]
                            , li [] [ text ("Owner: " ++ Maybe.withDefault "nobody" store.owner) ]
                            , hr [] []
                            ]
                    )
    in
    div []
        [ h2 [] [ text label ]
        , viewGetterButton endpoint label
        , div [] showItem
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
