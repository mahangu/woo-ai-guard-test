# woo-ai-guard-test

Throwaway repo that tests the caller-org guard in `woocommerce/.github/.github/workflows/ai-code-review.yml`.

Expected behavior when a PR is opened here: the `guard` job rejects the caller because `github.repository_owner == 'mahangu'`, not `woocommerce` or `mailpoet`. The `ai-review` job is skipped.

Proves the guard works.

Test change.
