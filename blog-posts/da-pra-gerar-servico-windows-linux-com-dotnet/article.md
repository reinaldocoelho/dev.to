---
published: true
title: 'Dá pra gerar serviço Windows/Linux com .Net?'
cover_image: 'https://raw.githubusercontent.com/reinaldocoelho/dev.to/master/blog-posts/da-pra-gerar-servico-windows-linux-com-dotnet/assets/topshelf.png'
description: 'tags: topshelf, dotnetcore, services, windows, linux'
series:
canonical_url:
---

Recentemente tive a necessidade de manter um código de serviço Windows que também pudesse ser executado como um serviço no Linux.

Estudando algumas possibilidades, a maneira mais elegante que encontrei foi aproveitar o mesmo projeto dotnetcore para gera o serviço do Windows ou um CLI que permite a configuração como serviço no Linux.

Vou explicar em seguida, todos os passos que fiz para que isso funcionasse utilizando a biblioteca TopShelf e gerando uma compilação para cada plataforma.

Todo código apresentado abaixo está disponível no GitHub:

- [dotnet-service-cross-platform](https://github.com/reinaldocoelho/dotnet-service-cross-platform)

## O que é a biblioteca TopShelf

[TopShelf](http://topshelf-project.com/) é uma biblioteca que visa facilitar e organizar o processo para gerar serviço Windows.

A partir da versão 4.1, está suportando o padrão **netstandard2.0** que nos permite compilar o projeto para FullFramework e dotnetcore.

Atualmente ela trabalha da seguinte forma, você cria uma aplicação console utilizando a biblioteca TopShelf, ela irá entender automaticamente alguns comandos como “install” por exemplo, que efetua a instalação do serviço do Windows. Se você não informar nenhum parâmetro esperado pelo TopShelf, a aplicação irá executar como um console, e isso nos permite fazer o que esperamos.

## Criando o código comum

O código comum será um projeto console em dotnetcore (estou usando a versão 2.1 no caso), onde vou adicionar a dependência para a biblioteca TopShelf.

A sequência inicial de comandos para criar o projeto será:

```
c:\code\simple-service-counter> dotnet new console
```

Em seguida adicionamos a referência ao TopShelf:

```
c:\code\simple-service-counter > dotnet add package Topshelf --version 4.1.0.177-develop
```

Em seguida vamos a um detalhe importante, vamos ajustar o projeto para dar suporte a mais de um Framework, possibilitando que nosso build compile para ambas as plataformas.

![Repare que a tag de projeto foi renomeada para “TargetFrameworks”, no plural, indicando que o projeto aceitará mais de um Framework.](./assets/image1.png 'Repare que a tag de projeto foi renomeada para “TargetFrameworks”, no plural, indicando que o projeto aceitará mais de um Framework.')

Vamos criar uma classe (**ImplementacaoServico.cs**) que será nosso código do serviço. Nosso serviço será um simples contador, mas você poderá implementar o que precisar.

![Classe com a implamentação do contador (nosso serviço Fake).](./assets/image2.png 'Classe com a implamentação do contador (nosso serviço Fake).')

Vamos agora configurar a classe inicial do projeto console para utilizar o TopShelf e chamar nossa lógica.

![Implementação simples do método Main, incluindo a chamada do serviço.](./assets/image3.png 'Implementação simples do método Main, incluindo a chamada do serviço.')

Perfeito, com esses poucos passos você pode executar seu projeto simplesmente para verificar se está funcionando como um console normal.

Execute o comando abaixo para ver seu serviço executado como um console:

```
c:\code\simple-service-counter > dotnet run --framework net461 (ou netcoreapp2.1)
```

Se tudo estiver correto, você deverá ter um resultado como este:

![Resultado de console esperado se o código estiver correto.](./assets/image4.png 'Resultado de console esperado se o código estiver correto.')

Tudo OK até aqui? Então vamos seguir para gerar e instalar o serviço no Windows e em seguida no Linux.

## Publicando e instalando no Windows

Primeiramente vamos publicar nosso serviço apontando para o framework 4.6.1 que nos permite instalar o serviço no windows.

Execute o seguinte comando para gerar a publicação:

```
c:\code\simple-service-counter > dotnet publish simple-service-counter.csproj -c Release -f net461 -o dist\windows --self-contained
```

Agora vamos instala-lo no windows, para isso entre na pasta “dist\windows” dentro da pasta do projeto e digite:

```
c:\code\simple-service-counter\dist\windows > simple-service-counter.exe install
```

E você deverá ter a seguinte saída:

![Saída esperada com a instalação correta do serviço.](./assets/image5.png 'Saída esperada com a instalação correta do serviço.')

Se você abrir o gerenciador de serviços do Windows, poderá iniciar e parar o serviço.

![Serviço instalado já nos registros de serviços do windows. (neste momento pode ser iniciado e parado).](./assets/image6.png 'Serviço instalado já nos registros de serviços do windows. (neste momento pode ser iniciado e parado).')

Para remover o serviço, somente digite:

```
c:\code\simple-service-counter\dist\windows > simple-service-counter.exe uninstall
```

Fácil né.

## Publicando e instalando no Linux

Para o Linux vamos fazer uma publicação utilizando dotnetcore 2.1 e publicar para Linux utilizando a opção **self-contained** (Que leva com a publicação todas as dependências, incluindo o framework evitando a necessidade de instalá-lo no Linux).

Para gerar a publicação, execute o comando:

```
c:\code\simple-service-counter > dotnet publish simple-service-counter.csproj -c Release -f netcoreapp2.1 -o dist\linux -r linux-x64 --self-contained
```

Agora vamos compactar a pasta “**dist\linux**” onde foi publicado o projeto e vamos levar esta pasta para um servidor (ou VM) com Linux (meu caso Lubuntu 18.10).

Note que o arquivo compactado fica grande ~30MB. E isso é porque está levando junto todas as dependências, incluindo o framework.

Copie o arquivo compactado para sua máquina Linux. ( Use o programa scp ou outro recurso qualquer para copiar).

Já no Linux, descompacte o arquivo com o comando

```
$ unzip <arquivo>.zip -d ~/meuservico
```

Em seguida precisamos dar permissão de execução para o programa executável, então entre na pasta onde estão os arquivos e altere a permissão para:

```
$ chmod 755 simple-service-counter
```

Podemos agora testar se nosso console funciona simplesmente executando ele no Shell:

```
$ ./simple-service-counter
```

Veja que a saída de console do programa funciona conforme esperado.

![Resultado funcional!](./assets/image7.png 'Resultado funcional!')

O que precisamos agora para torná-lo um serviço, que possa ser iniciado e parado nos padrões _systemd_ é seguir os passos:

1. Criar um arquivo de configuração em “_/etc/systemd/system/servico-counter.service_”, com o conteúdo:

```
[Unit]
Description=Servico contador
After=network.target
[Service]
User=root
Restart=on-failure
Type=exec
ExecStart=/<LOCAL>/meuservico/linux/simple-service-counter
[Install]
WantedBy=multi-user.target
```

2. Iniciar o serviço executando:

```
$ sudo systemctl start servico-counter
```

3. Verificar o status do serviço para verificar se está em execução, com o comando:

```
$ sudo systemctl status servico-counter
```

Esta checagem se estiver ok irá apresentar a seguinte saida:

![O status apresenta tanto a situação, como um possível erro ou um trecho da saída para confirmar a execução.](./assets/image8.png 'O status apresenta tanto a situação, como um possível erro ou um trecho da saída para confirmar a execução.')

4. Podemos definir para que ele seja iniciado com o boot se desejar, utilizando o comando:

```
$ sudo systemctl enable servico-counter
```

5. Podemos também pará-lo, com o comando:

```
$ sudo systemctl stop servico-counter
```

6. Para remover o serviço, basta apagar o arquivo “/etc/systemd/system/servico-counter.service” e em seguida excluir a pasta da aplicação.

Simples também né!!!

## Conclusão

Como vimos é muito simples criar uma estrutura que nos permita portar um serviço entre windows e Linux mantendo um único código fonte para ambos.

Espero que este artigo ajude e que eu possa gerar muitos outros em seguida.

Tem alguma dica, sugestão, crítica ou dúvida, pode me enviar.

Muito obrigado.

## NOTAS IMPORTANTES

Um problema que identifiquei em todas as versões posteriores que utilizei do TopShelf é que algo nele não está mais permitindo a execução como console no Linux :-(.

Abri uma issue no projeto do TopShelf para verificarem este ponto, ou entendermos o porque de ter parado:
[Topshelf#513](https://github.com/Topshelf/Topshelf/issues/513)
