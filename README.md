# woo-ai-guard-test

Throwaway repo that tests the caller-org guard in `woocommerce/.github/.github/workflows/ai-code-review.yml`.

Expected behavior when a PR is opened here: the `guard` job rejects the caller because `github.repository_owner == 'mahangu'`, not `woocommerce` or `mailpoet`. The `ai-review` job is skipped.

Proves the guard works.

## tasks-api (Haskell)

A small JSON HTTP API that lives in this repo as a Haskell playground.
Built with [scotty](https://hackage.haskell.org/package/scotty),
[aeson](https://hackage.haskell.org/package/aeson), and an STM-backed
in-memory store.

### Build & run

```
cabal build all
PORT=3000 cabal run tasks-api
```

`HOST` (default `127.0.0.1`) and `PORT` (default `3000`) are read from the
environment.

### Endpoints

| Method | Path           | Body                              | Response                       |
| ------ | -------------- | --------------------------------- | ------------------------------ |
| GET    | `/health`      | —                                 | `{"status":"ok"}`              |
| GET    | `/tasks`       | —                                 | `[Task, ...]`                  |
| POST   | `/tasks`       | `{"title": "...", "done"?: bool}` | `201 Task`                     |
| GET    | `/tasks/:id`   | —                                 | `Task` or `404`                |
| PATCH  | `/tasks/:id`   | `{"title"?: "...", "done"?: bool}`| `Task` or `404`                |
| DELETE | `/tasks/:id`   | —                                 | `204` or `404`                 |

### Tests

```
cabal test
```
