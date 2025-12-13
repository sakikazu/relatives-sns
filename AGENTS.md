# Repository Guidelines

## 前提とコミュニケーション
- 可能な限り日本語で回答・記述してください（コメント・PR説明・レビュー返信など）。英語ログは必要に応じて併記で可。This document stays in Japanese to keep a consistent tone across the team.

## プロジェクト構成
- Rails 6 / Ruby 2.7。主要コードは `app/models` `app/controllers`、Slim のビューは `app/views`。資産は SCSS + Bootstrap4 の `app/assets/stylesheets`、JS は `app/assets/javascripts`。
- バックグラウンド処理やメディア補助は `app/jobs` `app/services` `lib/` に配置。単発メンテは `oneshot_scripts/`。
- 設定は `config/`（デプロイ: `Capfile` `config/deploy.rb`、ジョブ: `config/initializers/sidekiq.rb`、Unicorn設定）。テストはアプリ構造をなぞる形で `spec/`。
- 静的ファイルは `public/`、キャッシュやログは `tmp/` `log/`。`Procfile` で本番に近いプロセス構成を確認可能。

## セットアップ・開発コマンド
- 依存導入: `bundle install`。
- DB: MySQL を起動し `bin/rails db:setup`（または `db:create` + `db:migrate`、seed があれば `db:seed`）。
- ローカル起動: `bin/rails s`。`foreman start` で `Procfile`/Unicorn 前提の挙動を確認。ジョブは `bundle exec sidekiq`。
- メール開発: `mailcatcher` 起動後 http://localhost:1080。Sidekiq 用に Redis が必要。ffmpeg / ImageMagick がアップロード・エンコードで必須。
- デプロイ系タスクは capistrano (`bundle exec cap production deploy`) を参照。cron/whenever 更新は `bundle exec whenever -i`。

## コーディングスタイル
- Ruby は2スペースインデント。共有ファイルを触る際は `bundle exec rubocop` を意識しつつ可読性優先。
- コントローラ/ビューは RESTful 命名、部分テンプレは `_xxx`。テンプレは Slim 推奨、スタイルは SCSS。
- ファイル名は snake_case、クラスは CamelCase。ジョブやサービスは意図が分かる名（例: `EncodeVideoJob`）。
- i18n 文言や定数は `config/locales` や設定ファイルで集中管理し、マジックナンバーを避ける。長いメソッドは早めにサービス/ヘルパへ分離。

## テストガイド
- RSpec + FactoryBot + Capybara、DatabaseRewinder でクリーンアップ。`spec/` はモデル・リクエスト・ビュー・ルーティング別に配置。
- 実行: `bundle exec rspec`。作業中は対象ファイルに絞る（例: `bundle exec rspec spec/models/user_spec.rb`）。
- 新規ルートはリクエストスペック、業務ロジックはモデルスペック、分岐が多いビューはビュー/ヘルパスペックを追加。`let`/`subject` や shared context で共通化。
- テストデータは FactoryBot を優先し、固定値は trait で整理。UI 変更は system spec/Capybara で主要フローをカバー。

## コミット・PR
- コミットは短く具体的に（日本語可、例: `ランキング集計の nil ガード追加`）。意図のないフォーマットのみ変更は避ける。
- PR では目的・影響範囲・マイグレーションやバッチ/ジョブへの影響を記載。`bundle exec rspec` の結果、UI 変更はスクショ/GIF を添付。
- 関連 issue を紐付け、必要な環境変数やデプロイ手順（capistrano タスク、Sidekiq/cron 再起動など）を明記。
- レビューで指摘された点は再現手順と修正方針を日本語で返答し、追加テストの結果を残すと確認がスムーズ。

## セキュリティと設定
- 機密情報は `.env`（dotenv）で管理しコミットしない。`config/deploy.rb` の linked_files/dirs を守り、Unicorn/Sidekiq 設定をデプロイ前に確認。
- メディア処理は ffmpeg / ImageMagick 依存。新環境では先に導入を確認し、アップロード・エンコード系の回帰を防止。
