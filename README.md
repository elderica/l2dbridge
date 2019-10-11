l2dbridge
=========

LINEとDiscordの間で発言を中継するbotです。  
今のところLINEからDiscordへの中継部分の作成に注力しています。

Herokuへの設置方法
------------

Linuxでのやり方を書きます。WSLでも同様にできると思います。

1. Heroku CLIを導入しましょう。例えば、x86_64環境ならば

```sh
$ cd $HOME
$ curl https://cli-assets.heroku.com/heroku-linux-x64.tar.gz | gzip -dc | pax -r
$ PATH="$HOME/heroku/bin:$PATH"
```

2. gitも必要です。

```sh
$ sudo apt-get update
$ sudo apt-get install git
```

3. Herokuにアカウントがなければここで作ってください。そのあと、Heroku CLIでログインします。
```sh
$ heroku login
```

4. Herokuにアプリを用意します。
``` sh
$ heroku create
```

5. 連携用の設定を書きましょう。
```sh
$ heroku config:edit
DISCORD_WEBHOOK_URL='Discordのチャット設定でWebhookを登録して得たURL'
LINE_CHANNEL_SECRET='LINE Developersで作ったボットのチャネル基本設定に書いてあるChannel Secret'
LINE_CHANNEL_TOKEN='LINE Developersで作ったボットのチャネル基本設定で発行したアクセストークン（ロングターム）'
```

6. 設置します。
``` sh
git push heroku master
```

7. HerokuからアプリにアクセスするためのURLが発行されるのでLINE DevelopersのWebhook URLに登録しましょう。
   **最後に`/line`をつけることを忘れないように！**

何か誤りがあればIssuesにて。
