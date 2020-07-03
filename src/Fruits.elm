module Fruits exposing (main)

import Browser
import Html exposing (Html, button, div, h1, h2, h3, hr, li, p, text, ul)
import Html.Events exposing (onClick)
import Http
import Json.Decode as D exposing (Decoder, field, int, list, string, succeed)
import Json.Decode.Pipeline exposing (optional, required)



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
    , customer = noCustomer
    , order = noOrder
    }



-- MODEl


type alias Model =
    { fruit : Fruit
    , fruitList : List Fruit
    , store : Store
    , storeList : List Store
    , customer : Customer
    , order : OrderDetail
    }


type alias Fruit =
    { name : String
    , price : Int
    , amount : Int
    }


type alias Store =
    { address : String
    , owner : Maybe String
    }


type alias Customer =
    { username : String
    , email : String
    , isVip : Bool
    }


type alias OrderDetail =
    { customer : Customer
    , store : Store
    , fruits : List Fruit
    }


noFruit : Fruit
noFruit =
    { name = ""
    , price = 0
    , amount = 0
    }


noStore : Store
noStore =
    { address = ""
    , owner = Nothing
    }


noCustomer : Customer
noCustomer =
    { username = ""
    , email = ""
    , isVip = False
    }


noOrder : OrderDetail
noOrder =
    { customer = noCustomer
    , store = noStore
    , fruits = []
    }


type Endpoint
    = GetFruit
    | GetFruitList
    | GetStore
    | GetStoreList
    | GetCustomer
    | GetOrderDetail



-- MSG


type Msg
    = GetData Endpoint
    | GotFruit (Result Http.Error Fruit)
    | GotFruitList (Result Http.Error (List Fruit))
    | GotStore (Result Http.Error Store)
    | GotStoreList (Result Http.Error (List Store))
    | GotCustomer (Result Http.Error Customer)
    | GotOrderDetail (Result Http.Error OrderDetail)



-- DECODERS


fruitDecoder : Decoder Fruit
fruitDecoder =
    D.succeed Fruit
        |> required "name" D.string
        |> required "price" D.int
        |> optional "amount" D.int 0

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


customerDecoder : Decoder Customer
customerDecoder =
    D.succeed Customer
        |> required "username" D.string
        |> required "email" D.string
        |> required "isVip" D.bool


orderDetailDecoder : Decoder OrderDetail
orderDetailDecoder =
    field "order_details"
        (D.succeed OrderDetail
            |> required "customer" customerDecoder
            |> required "store" storeDecoder
            |> required "fruits" (list fruitDecoder)
        )



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

                GetCustomer ->
                    ( { model | customer = noCustomer }
                    , Http.get
                        { url = baseApiUrl ++ "customer"
                        , expect = Http.expectJson GotCustomer customerDecoder
                        }
                    )

                GetOrderDetail ->
                    ( { model | order = noOrder }
                    , Http.get
                        { url = baseApiUrl ++ "order"
                        , expect = Http.expectJson GotOrderDetail orderDetailDecoder
                        }
                    )

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

        GotCustomer result ->
            case result of
                Ok customer ->
                    ( { model | customer = customer }
                    , Cmd.none
                    )

                _ ->
                    ( { model | customer = noCustomer }
                    , Cmd.none
                    )

        GotOrderDetail result ->
            case result of
                Ok order ->
                    ( { model | order = order }
                    , Cmd.none
                    )

                _ ->
                    ( { model | order = noOrder }
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
        , viewCustomerItem "顧客情報" GetCustomer model.customer
        , viewOrderDetailItem "注文情報" GetOrderDetail model.order
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


viewCustomerItem : String -> Endpoint -> Customer -> Html Msg
viewCustomerItem label endpoint customer =
    let
        showItem =
            div []
                [ p [] [ text customer.username ]
                , p [] [ text customer.email ]
                , p []
                    [ text <|
                        if customer.isVip == True then
                            "☆VIP☆"

                        else
                            ""
                    ]
                ]
    in
    div []
        [ h2 [] [ text label ]
        , viewGetterButton endpoint label
        , div [] [ showItem ]
        , hr [] []
        ]


viewOrderDetailItem : String -> Endpoint -> OrderDetail -> Html Msg
viewOrderDetailItem label endpoint order =
    let
        customer =
            order.customer

        customerItem =
            div []
                [ h3 [] [ text "顧客情報" ]
                , p [] [ text customer.username ]
                , p [] [ text customer.email ]
                , p []
                    [ text <|
                        if customer.isVip == True then
                            "☆VIP☆"

                        else
                            ""
                    ]
                ]

        store =
            order.store

        storeOwner =
            case store.owner of
                Nothing ->
                    Html.text ""

                Just owner ->
                    p [] [ text owner ]

        storeItem =
            div []
                [ h3 [] [ text "店舗情報" ]
                , p [] [ text store.address ]
                , storeOwner
                ]

        fruitList =
            order.fruits

        fruitListItem =
            div []
                ([ h3 [] [ text "注文内容" ] ]
                    ++ (fruitList
                            |> List.map
                                (\fruit ->
                                    p []
                                        [ text <| fruit.name ++ " / "
                                        , text <| String.fromInt fruit.price ++ " Yen / "
                                        , text <| String.fromInt fruit.amount ++ " pcs"
                                        ]
                                )
                       )
                )
        totalPrice =
            fruitList 
                |> List.map (\fruit -> fruit.price * fruit.amount)
                |> List.foldl (+) 0

        totalPriceItem = 
            div [] 
                [ h3 [] [ text "合計"]
                , p [] [ text <| String.fromInt totalPrice ++ " JPY"]]
    in
    div []
        [ h2 [] [ text label ]
        , viewGetterButton endpoint label
        , customerItem
        , storeItem
        , fruitListItem
        , totalPriceItem
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
