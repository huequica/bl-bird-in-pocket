# bl-bird-in-pocket
やましい気持ち100%で作られている、青い鳥消化スクリプト  

# 概要
[pocket](https://getpocket.com)に入っているTwitterのリンクを見つけて、画像があったら全部ローカルに落とす(同時にアーカイブもしてくれる)スクリプト  

ようはやましい気持ちで放り込みすぎてたいへん溜まってるやつを全部キレイキレイしてくれます  

これの開発にあたってソースコードをいくらか勝手に拝借していますごめんなさい  

# 使用法

## 依存gem
+ **Twitter**
+ json
+ HTTP

Twitterだけ入れれば問題ないと思う

## 実行までの流れ
1. param.rb.tempにpocket、TwitterのAPIの情報、画像を保存するディレクトリを書き込む  
pocketのAPIはトークンを自分で発行しないといけないけど、curlとか使って頑張れ
```bash
$ vim param.rb.temp
```

2. param.rb.tempをparam.rbに名称変更
```bash
$ mv param.rb.temp param.rb
```

3. main.rbをコマンドラインで実行
```bash
$ ruby main.rb
```

# 設定
param.rb一番下の```$action_set```なるグローバル変数ですが、画像を保存したのちアーカイブするか削除するかの設定になります  
変えたければ変えてください  
ただし、Twitterから情報を取得する際ツイートが消えていてエラーが吐かれた場合残しても意味がないので**pocketから削除します**