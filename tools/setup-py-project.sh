#!/bin/bash
set -e
# Pythonプロジェクトをセットアップする
# コマンドライン引数にプロジェクト名を受け取る
if [ -z "$1" ]; then
  echo "Usage: $0 <project_name>"
  exit 1
fi

PROJECT_NAME="$1"

# プロジェクトディレクトリを作成する
# ディレクトリがすでにある場合は処理終了
if [ -d "$PROJECT_NAME" ]; then
  echo "Directory $PROJECT_NAME already exists."
  exit 1
fi

mkdir "$PROJECT_NAME"
cd "$PROJECT_NAME"

echo "📁: `pwd`"
# Python環境の構築
uv init
curl -L https://gitignore.io/api/python,visualstudiocode > .gitignore
# 不要ファイルの削除
rm *.py
git add .
git commit -m "initial commit"
git switch -c dev-tools
uv add --group dev pytest pytest-cov ruff mypy pre-commit
git add pyproject.toml uv.lock
git commit -m "add dev tools: pytest, ruff, mypy, pre-commit"

# pre-commit の設定
cat << EOF > .pre-commit-config.yaml
# See https://pre-commit.com for more information
# See https://pre-commit.com/hooks.html for more hooks
repos:
-   repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v5.0.0
    hooks:
    -   id: trailing-whitespace
    -   id: end-of-file-fixer
    -   id: mixed-line-ending
        args: [--fix=lf]

-   repo: local
    hooks:
    -   id: lint
        name: Lint Python files
        entry: uv run ruff check
        language: python
        types: [file, python]
        exclude: ^(tests/|scripts/).*$

    -   id: type-check
        name: Type check Python files
        entry: uv run mypy
        language: python
        types: [file, python]
        exclude: ^(tests/|scripts/).*$

    -   id: aws-credential-check
        name: Check for AWS credentials
        entry: git secrets --scan
        language: system
        types: [text]

    -   id: unit-test
        name: Run unit tests
        entry: uv run pytest --cov src --cov-branch --cov-report term-missing --cov-report xml --cov-report html
        language: python
        types: [file, python]
        stages: [pre-merge-commit]
        pass_filenames: false

default_install_hook_types: [pre-commit, pre-merge-commit]
EOF
uv run pre-commit install --install-hooks
git add .pre-commit-config.yaml
git commit -m "pre-commit の設定を追加"

# ruff の設定
cat << EOF >> pyproject.toml

# linter / formatter
[tool.ruff]
line-length = 100
indent-width = 4
[tool.ruff.format]
quote-style = "double"
indent-style = "space"
[tool.ruff.lint.isort]
known-first-party = []
EOF
git add pyproject.toml
git commit -m "ruff の設定を追記"

# mypy の設定
cat << EOF >> pyproject.toml

# type-checker
[tool.mypy]
check_untyped_defs = true  # 関数の引数/戻り値の型をチェックする
EOF
git add pyproject.toml
git commit -m "mypy の設定を追記"

# pytest の設定
cat << EOF >> pyproject.toml

# test
[tool.pytest.ini_options]
pythonpath = ["src"]
testpaths = ["tests"]
addopts = "--cov src --cov-branch --cov-report term-missing --cov-report xml --cov-report html"
EOF
git add pyproject.toml
git commit -m "pytest の設定を追記"

# VSCode の設定
mkdir -p .vscode
cat << EOF >> .vscode/settings.json
{
  "files.eol": "\n",
  "files.exclude": {
    "**/__pycache__": true,
    "**/.mypy_cache": true,
    "**/.pytest_cache": true,
    "**/.ruff_cache": true,
  },
  "code-eol.color": "#8e8e8e",
  "[python]": {
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
      "source.fixAll": "explicit",
      "source.organizeImports": "explicit"
    },
    "editor.defaultFormatter": "charliermarsh.ruff"
  },
  "ruff.enable": true,
  "ruff.configuration": "pyproject.toml",
  "mypy-type-checker.args": [
    "--config=pyproject.toml",
  ],
  "cSpell.words": [
    "pyproject",
    "ruff",
    "mypy",
    "pytest",
    "autodocstring",
    "isort",
  ]
}
EOF
cat << EOF >> .vscode/extensions.json
{
  "recommendations": [
    // Utility
    "sohamkamani.code-eol",
    "oderwat.indent-rainbow",
    "mechatroner.rainbow-csv",
    "ryanluker.vscode-coverage-gutters",
    "vscode-icons-team.vscode-icons",
    "streetsidesoftware.code-spell-checker",
    "MS-CEINTL.vscode-language-pack-ja",
    "redhat.vscode-yaml",
    "ms-vscode.live-server",
    "be5invis.toml",
    // AI
    "Anthropic.claude-code",
    // Git / GitHub
    "mhutchie.git-graph",
    "github.vscode-github-actions",
    "me-dutour-mathieu.vscode-github-actions",
    // Markdown
    "shd101wyy.markdown-preview-enhanced",
    "bierner.markdown-mermaid",
    "bpruitt-goddard.mermaid-markdown-syntax-highlighting",
    "DavidAnson.vscode-markdownlint",
    // Terraform
    "hashicorp.terraform",
    // Docker
    "ms-azuretools.vscode-docker",
    // Python
    "ms-python.python",
    "ms-python.vscode-pylance",
    "ms-python.mypy-type-checker",
    "charliermarsh.ruff",
    "njpwerner.autodocstring"
  ]
}
EOF
git add .vscode/
git commit -m "VSCode の設定を追記"

# ソースコードとテストコードのディレクトリを作成
mkdir -p {src,tests}/$PROJECT_NAME

# dev-tools をマージする
git switch main
git merge dev-tools
git branch -d dev-tools
