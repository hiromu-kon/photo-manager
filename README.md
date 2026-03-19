# 写真管理アプリケーション

## セットアップ
1. リポジトリを取得
   ```bash
   git clone https://github.com/hiromu-kon/photo-manager.git
   cd photo-manager
   ```

2. 鍵を`config/credentials/development.key`に配置

3. アプリケーションを起動
   ```bash
   docker compose up --build
   ```

4. 起動後、`http://localhost:3000`にアクセス:

5. seedデータ投入
   ```bash
   docker compose exec app bin/rails db:seed
   ```

6. アプリケーションにログイン
  - email: `test@example.com`
  - password: `password123`

## テスト実行
```bash
docker compose run --rm app bash -lc "bundle install && DATABASE_URL=postgres://postgres:postgres@db:5432/app_test RAILS_ENV=test bin/rails test"
```
