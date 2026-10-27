# Reinaldo Coelho's blog source

Fonte dos meus artigos publicados em <https://dev.to/reinaldocoelho>.

Os artigos são escritos em Markdown neste repositório e publicados automaticamente no dev.to por um GitHub Action
([publish-devto](https://github.com/sinedied/publish-devto), que usa o [devto-cli](https://github.com/sinedied/devto-cli)).

## Estrutura

```text
blog-posts/
  <slug-do-artigo>/
    article.md   # artigo com front matter
    assets/      # imagens (links relativos: ./assets/imagem.png)
    code/        # códigos de exemplo embutidos via embedme
```

## Configuração (uma vez só)

1. Gere uma API key em <https://dev.to/settings/extensions>.
2. No GitHub: **Settings → Secrets and variables → Actions → New repository secret**, nome `DEVTO_TOKEN`.
3. Em **Settings → Actions → General → Workflow permissions**, habilite **Read and write permissions**
   (o Action faz commit do `id` e da `date` no front matter do artigo).
4. Localmente: `npm install`. Para usar o CLI na máquina, crie um `.env` (já está no `.gitignore`) com `DEVTO_TOKEN=<sua-key>`.

## Escrevendo um novo artigo

```bash
npm run new -- blog-posts/meu-novo-artigo/article.md
```

Edite o front matter (`title`, `description`, `tags` — no máximo 4 —, `cover_image`, `series`, `canonical_url`)
mantendo `published: false` enquanto for rascunho.

- Imagens: salve em `./assets/` e use link relativo. Na publicação o link vira
  `https://raw.githubusercontent.com/reinaldocoelho/dev.to/main/...` (o repositório precisa ser público).
- Código de exemplo: salve em `./code/` e referencie com um bloco de código cuja primeira linha é o caminho do arquivo
  (ex.: `// ./code/demo-code.ts`); `npm run embedme:write` sincroniza o conteúdo.

Antes de commitar:

```bash
npm run format      # embedme + prettier
npm run push:dry    # simula a publicação sem alterar nada no dev.to
```

## Publicando

Faça push (ou merge de PR) na `main`. O workflow [publish.yml](.github/workflows/publish.yml):

1. Roda `npm run check` (prettier + embedme) — também em Pull Requests.
2. Envia ao dev.to os artigos que mudaram. Artigo sem `id` é **criado** (como rascunho se `published: false`) e o
   `id` é gravado de volta no arquivo via commit automático.

Para trocar de rascunho para publicado, basta mudar `published: true` e fazer push.

Artigos com `devto_sync: false` no front matter são ignorados (ex.: o modelo `blog-posts/name-of-your-blog-post`).

## Outros comandos

| Comando                 | O que faz                                                       |
| ----------------------- | --------------------------------------------------------------- |
| `npm run push`          | Publica localmente (sem esperar o CI)                           |
| `npm run reconcile:dry` | Simula a associação por título de artigos sem `id` já no dev.to |
| `npm run stats`         | Estatísticas dos últimos artigos publicados                     |
| `npm run check-updates` | Lista dependências desatualizadas                               |
