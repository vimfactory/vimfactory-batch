# del_container.rb
一定時間過ぎたdockerコンテナを削除するスクリプト。
memcachedのデータと同時に消すことを考えたが、memcachedは全データをなめて処理することを推奨していないので、  
memcachedにはキャッシュ期限をつけて削除、dockerコンテナは本スクリプトで削除するようにした。

## 使い方
オプションは３つ

- -s x秒たったdockerコンテナを削除する(デフォルト7200)
- -H dockerホスト(デフォルト localhost)
- -P dockerポート(デフォルト 4243)

```
bundle exec ruby del_container.rb [-s xxxx] [-H xxxx] [-P xxxx]
```
