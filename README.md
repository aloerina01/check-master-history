# check-master-history
masterブランチが知らぬ間に進んでいないかを確認できる

## Overview

* 現在のmasterの最新コミットと、対象ブランチがmasterを最後に取り込んだコミットを比較します
* 比較結果の文言を標準出力します
* CIから実行した場合は、対象となるPull Requestに結果をコメントします

## How to use

```shell
$ check_master_history.sh release/hoge
```
