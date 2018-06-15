#!/bin/bash
set -e

text_color_red="\033[37;41;1m"
text_color_green="\033[37;42;1m"
text_color_reset="\033[0m"
target_branch=$1

git fetch

# masterの最新のcommitを取得する
latest_commit=$(git log origin/master -n 1 | head -1 | sed -e "s/commit \(.*$\)/\1/")

# target_branchがmasterのどのcommitから枝分かれしたのかを調べる
base_commit=$(git show-branch --merge-base origin/$target_branch origin/master | head -1)

echo "latest commit: $(git log $latest_commit --oneline | head -1)"
echo "based  commit: $(git log $base_commit --oneline | head -1)"

# 「mastarの最新commit」と「枝分かれしたcommit」を比較
if [ "$latest_commit" = "$base_commit" ]; then
  comment="最新のmasterが取り込まれています"
  icon="✅ "
  event="APPROVE"
  echo -e "${text_color_green}${comment}${text_color_reset}"
else
  comment="masterが進んでいる可能性があります"
  icon="🚫 "
  event="REQUEST_CHANGES"
  echo -e "${text_color_red}${comment}${text_color_reset}"
fi

# CIによる実行でなければここで終了
if [ "$CI" == false ] || [ -z "$CI" ]; then
  exit 0
fi

# 該当のPull Requestを取得できているか確認する
if [ "$CI_PULL_REQUEST" == false ] || [ -z "$CI_PULL_REQUEST" ]; then
  echo 'Fail to find a pull request.' && exit 0
fi
pr_number=$(echo ${CI_PULL_REQUEST} | sed -e "s/^.*pull\/\(.*$\)/\1/")

# 結果をPull RequestにReviewとしてコメントする
curl -XPOST \
  -H "Authorization: token $GITHUB_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"body\": \"$icon$comment\", \"event\": \"$event\"}" \
 https://github.com/api/v3/repos/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME/pulls/$pr_number/reviews