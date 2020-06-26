## 起動手順

### 1. API 起動

`json-server` インストール&起動

```bash
 $ npm install -g json-server
 $ json-server --watch json/fruits.json
```

有効なエンドポイントが端末に表示される。
また、 http://localhost:3000 からも確認できる。

### 2. Elm 環境起動

今回はアプリを用意せず、 `elm-live` を使う想定。

```bash
 $ elm-live src/Fruits.elm --port 8000
```

### 3. Elm の基本実装

それぞれのエンドポイントからのレスポンスを受け取り文字列で表示しましょう。
※ API + アプリ同時に起動してね。

### 4. JSON Decoding

それぞれのエンドポイントから受け取ったレスポンスを受け取り、
いい感じに表示しましょう。

### 5. 課題的なあれ

- [ ] 未実装のエンドポイントを `Http.expectString` で取得して、表示してみよう
- [ ] それぞれのエンドポイントにあった `Model` つくってみよう
- [ ] `Http.expectJson` + `Decoder` の組み合わせでJSONをレコードに変換してみよう
- [ ] それぞれ取得したデータを、いい感じに表示してみよう

### エンドポイントについて

| エンドポイント                 | レスポンスについて |
| ------------------------------ | ------------------ |
| http://localhost:3000/fruit    | Fruit ※            |
| http://localhost:3000/fruits   | List Fruit ※       |
| http://localhost:3000/store    | Store ※            |
| http://localhost:3000/stores   | List Store ※       |
| http://localhost:3000/customer | Customer ※         |
| http://localhost:3000/order    | Order ※            |

`※` は Custom Model を定義することになることになりそう。

### 実装ヒント

* 公式ガイド: [JSON · An Introduction to Elm](https://guide.elm-lang.jp/effects/json.html)
* [elm-json-decode-pipeline](https://package.elm-lang.org/packages/NoRedInk/elm-json-decode-pipeline)

  ```elm
  -- 標準ライブラリ
  fruitDecoder : Decoder Fruit
  fruitDecoder = 
      map2 Fruit
          (field "name" string)
          (field "price" int)
          
  -- json-decode-pipeline
  fruitDecoder : Decoder Fruit
  fruitDecoder =
      Decode.succeed Fruit
          |> required "name" string
          |> required "price" int
  ```
        
* （まとめていないが、 https://github.com/MatsLanGoH/elm-pokedex のコードちょっと参考になるかも）
