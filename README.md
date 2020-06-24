## 起動手順

### 1. API 起動

`json-server` インストール&起動

```bash
 $ npm install -g json-server
 $ json-server --watch json/pizzazz.json
```

有効なエンドポイントが端末に表示される。
また、 http://localhost:3000 からも確認できる。

### 2. (TODO) Elm 環境起動

今回はアプリを用意せず、 `elm-live` を使う想定。
`create-elm-app` でもよい。

### 3. Elm の基本実装

それぞれのエンドポイントからのレスポンスを受け取り文字列で表示しましょう。

### 4. JSON Decoding

それぞれのエンドポイントから受け取ったレスポンスを受け取り、
いい感じに表示しましょう。

### エンドポイントについて

| エンドポイント                     | レスポンスについて |
| ---------------------------------- | ------------------ |
| http://localhost:3000/pizza-name   | String             |
| http://localhost:3000/pizza-names  | List String        |
| http://localhost:3000/drink        | Drink ※            |
| http://localhost:3000/drinks       | List Drink ※       |
| http://localhost:3000/simple-order | SimpleOrder ※      |
| http://localhost:3000/pizza-mino   | Pizza ※            |
| http://localhost:3000/pizza-menu   | ComplexOrder ※     |

`※` は Custom Model を定義することになることになりそう。

### 実装ヒント

（まとめていないが、 https://github.com/MatsLanGoH/elm-pokedex のコードちょっと参考になるかも）
