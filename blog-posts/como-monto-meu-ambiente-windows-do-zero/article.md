---
published: false
title: "Como monto meu ambiente Windows do Zero"
cover_image: "https://raw.githubusercontent.com/reinaldocoelho/dev.to/master/blog-posts/como-monto-meu-ambiente-windows-do-zero/assets/top.png"
description: "Como instalar e montar sua máquina windows de forma rápida e prática logo após a formatação."
tags: windows, chocolatey, install
series:
canonical_url:
---

Motivado pelo post do @LuizCarlosFaria:
[Dev Desktop fresh setup windows features tools](https://gago.io/blog/dev-desktop-fresh-setup-windows-features-tools/)

## Porque automatizar

Porque devemos automatizar nosso setup de Desktop?
Pelo mesmo motivo pelo qual fazemos qualquer automação, para poupar tempo e esforço.
Se você não tem a necessidade de vez ou outra recriar sua máquina, provavelmente este artigo não é para você.

## O que vou usar

Para o processo, vou utilizar basicamente:

* Script PowerShell - Instalação de pacotes Windows.
* Chocolatey.org - Gerenciador de pacotes para instalação de aplicativos.

## Começando

Imagine que você acabou de formatar a máquina e precisa reinstalar tudo (ou quase, você entenderá ao final) que você tinha na máquina para voltar as atividades.

E agora, como você pode preparar seu ambiente novamente em 3 passos?

### 1 - Instando as Features do Windows

* **NOTA:** A instalação de features do windows varia se você estiver tratando de uma versão Desktop ou Server, por isso vale dar uma lida [neste artigo](https://peter.hahndorf.eu/blog/WindowsFeatureViaCmd.html).
* **NOTA2:** Este post está apresentando como tratar em Windows10 Desktop.

Atualmente o powershell nos dá bastante poder em relação ao windows e nos permite instalar praticamente tudo via script.
Para isso bastam 2 passos:

1. Liberar acesso a política de execução de script do powershell.
2. Escolher a lista de features que gostaria de instalar.

Abaixo segue o script básico que uso na minha máquina como desenvolvedor para ter acesso a funções de IIS, Hyper-V, DotNet Core Hosting e Telnet Client (basicamente o mais importante).

```txt
// code/config-windows.ps1
```

### 2 - Instando o Chocolatey

Estando com o windows ajustado, temos agora que instalar nosso gerenciador de pacotes, para que possamos instalar os aplicativos  que vamos usar em nosso ambiente.

No site do [chocolatey](https://chocolatey.org/install) você tem os passos mais recentes da instalação, mas se for utilizar a forma mais simples (com o repositório do nuget.org), é só executar o comando powershell de instalação.

* **NOTA:** Sim, é possível instalar um repositório privado de programas, seja para você ou para a empresa, isso também se encontra na documentação do site.

Para nosso exemplo, precisamos apenas executar o script:

```txt
// code/install-chocolatey.ps1
```

* **Informação adicional:** O & antes dos comandos no Powershell é uma das formas de executar comandos console no script powershell.

## Como encontrar programas

Uma das suas dúvidas neste momento pode ser "E como eu encontro meus programas?". O choco (apelido carinhoso do chocolatey) tem vários comandos úteis, um deles é o **search** que permite pesquisar no repositório.

Imagine que você gostaria de saber por exemplo o que existem de opções relacionadas a office no repositório, então você poderia pesquisar com o comando abaixo:

```
& choco search office
```

Você terá um resultado parecido com:

```txt
// code/resultado-pesquisa.txt
```

Outras opções principais de comando no chocolatey são:

* *choco install [nome do pacote]* - Instala o programa.
* *choco uninstall [nome do pacote]* - Remove o programa.
* *choco update [nome do pacote]* - Atualiza o programa.

É possível também utilizar algumas abreviações como por exemplo:

* *cup all -y* - Atualiza todos os programas que tiverem versão atualizada.

## Limitações

Quando utilizamos a instalação padrão e o repositório publico do Chocolatey, você normalmente não terá acesso a programas que não sejam freeware, trial ou opensource.

Os programas licensiados como pacote Office da Microsoft por exemplo não se encontram na listagem.

Se você tem a necessidade de ter programas registrados o que pode fazer é criar um repositório seu e criar os scripts de instalação você mesmo para o seu programa.

A boa notícia é que com algumas exceções, você consegue ter pelo menos a grande maioria dos seus programas instalados, já que o chocolatey está contando com um repositório bem abrangente.

## Conclusões

Se você achou que executar 3 scripts ainda assim é trabalhoso, pode juntá-los num só e executar apenas um script para efetuar todos esses passos em sequência, e ao formatar a máquina ter praticamente tudo instalado com literalmente um clique.

Eu sou muito adepto a projetos open-source e tenho basicamente todo o meu pacote de programas disponíveis no Chocolatey.

Espero que tenham gostado, e me informem se este artigo te ajudou em alguma coisa.
