---
published: false
title: "Como monto meu ambiente Windows do Zero"
cover_image: "https://raw.githubusercontent.com/reinaldocoelho/dev.to/master/blog-posts/como-monto-meu-ambiente-windows-do-zero/assets/top.jpg"
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

- Script PowerShell - Instalação de pacotes Windows.
- Chocolatey.org - Gerenciador de pacotes para instalação de aplicativos.

## Começando

Imagine que você acabou de formatar a máquina e precisa reinstalar tudo (ou quase, você entenderá ao final) que você tinha na máquina para voltar as atividades.

E agora, como você pode preparar seu ambiente novamente em 3 passos?

### 1 - Instando as Features do Windows

- **NOTA:** A instalação de features do windows varia se você estiver tratando de uma versão Desktop ou Server, por isso vale dar uma lida [neste artigo](https://peter.hahndorf.eu/blog/WindowsFeatureViaCmd.html).
- **NOTA2:** Este post está apresentando como tratar em Windows10 Desktop.

Atualmente o powershell nos dá bastante poder em relação ao windows e nos permite instalar praticamente tudo via script.
Para isso bastam 2 passos:

1. Liberar acesso a política de execução de script do powershell.
2. Escolher a lista de features que gostaria de instalar.

Abaixo segue o script básico que uso na minha máquina como desenvolvedor para ter acesso a funções de IIS, Hyper-V, DotNet Core Hosting e Telnet Client (basicamente o mais importante).

```txt
// code/config-windows.ps1

#######################################################
### PASSO 1 - Efetua liberação de acesso ao powershell.
#######################################################
Set-ExecutionPolicy Bypass -Scope Process

# ##############################################################################################
### PASSO 2 - Efetua um teste de conexão com a internet para garantir os recursos necessários.
###     ALERTA: O Windows tem comandos diferentes de acordo com a sua versão, se os comandos abaixo
###             não funcionarem, verifique: https://peter.hahndorf.eu/blog/WindowsFeatureViaCmd.html
# ##############################################################################################
Write-Host "Verificando se ha conexao com a internet..."
$hasInternet = (Test-Connection google.com -Count 3 -Quiet);
if ($hasInternet -eq $false) {
  Write-Host "Concluido teste de internet com FALHA..."
  return $false
}
Write-Host "Concluido teste de internet com sucesso..."

Write-Host "Instalando recurso Hostable Web Core"
Enable-WindowsOptionalFeature -Online -FeatureName "IIS-HostableWebCore" -NoRestart

Write-Host "Instalando HTTP Redirect"
Enable-WindowsOptionalFeature -Online -FeatureName "IIS-HttpRedirect" -NoRestart

Write-Host "Instalando WebDAV (File access and manipulation. More: https://www.cloudwards.net/what-is-webdav/)"
Enable-WindowsOptionalFeature -Online -FeatureName "IIS-WebDAV" -NoRestart

Write-Host "Instalando recurso WebSocket"
Enable-WindowsOptionalFeature -Online -FeatureName "IIS-WebSockets" -NoRestart

Write-Host "Instalando Logging IIS"
Enable-WindowsOptionalFeature -Online -FeatureName "IIS-CustomLogging" -NoRestart
Enable-WindowsOptionalFeature -Online -FeatureName "IIS-HttpLogging" -NoRestart
Enable-WindowsOptionalFeature -Online -FeatureName "IIS-LoggingLibraries" -NoRestart
Enable-WindowsOptionalFeature -Online -FeatureName "IIS-ODBCLogging" -NoRestart
Enable-WindowsOptionalFeature -Online -FeatureName "IIS-ManagementScriptingTools" -NoRestart
Enable-WindowsOptionalFeature -Online -FeatureName "IIS-HttpTracing" -NoRestart
Enable-WindowsOptionalFeature -Online -FeatureName "IIS-RequestMonitor" -NoRestart

Write-Host "Instalando DotNetFramework"
Enable-WindowsOptionalFeature -Online -FeatureName "WCF-Services45" -NoRestart

Write-Host "Ativando recurso: ASPNET45"
Enable-WindowsOptionalFeature -Online -FeatureName "IIS-ASPNET45" -NoRestart # -LimitAccess

Write-Host "Ativando recurso: Hyper-V"
Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Hyper-V" -NoRestart # -LimitAccess
Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Hyper-V-Management-Clients" -NoRestart # -LimitAccess
Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Hyper-V-Management-PowerShell" -NoRestart # -LimitAccess
Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Hyper-V-Offline" -NoRestart # -LimitAccess
Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Hyper-V-Online" -NoRestart # -LimitAccess

## Detalhes em: https://docs.microsoft.com/en-us/iis/install/installing-iis-85/installing-iis-85-on-windows-server-2012-r2
Write-Host "Instalando recurso: IIS"
Enable-WindowsOptionalFeature -Online -FeatureName "IIS-WebServer" -NoRestart
Enable-WindowsOptionalFeature -Online -FeatureName "IIS-WebServerManagementTools" -NoRestart
Enable-WindowsOptionalFeature -Online -FeatureName "IIS-ManagementConsole" -NoRestart
Enable-WindowsOptionalFeature -Online -FeatureName "IIS-DefaultDocument" -NoRestart
Enable-WindowsOptionalFeature -Online -FeatureName "IIS-HttpLogging" -NoRestart
Enable-WindowsOptionalFeature -Online -FeatureName "IIS-LoggingLibraries" -NoRestart

Write-Host "Instalando recurso: Application Initialization"
Enable-WindowsOptionalFeature -Online -FeatureName "IIS-ApplicationInit" -NoRestart

## Outros apoios opcionais:
Enable-WindowsOptionalFeature -Online -FeatureName "TelnetClient" -NoRestart

```

### 2 - Instando o Chocolatey

Estando com o windows ajustado, temos agora que instalar nosso gerenciador de pacotes, para que possamos instalar os aplicativos que vamos usar em nosso ambiente.

No site do [chocolatey](https://chocolatey.org/install) você tem os passos mais recentes da instalação, mas se for utilizar a forma mais simples (com o repositório do nuget.org), é só executar o comando powershell de instalação.

- **NOTA:** Sim, é possível instalar um repositório privado de programas, seja para você ou para a empresa, isso também se encontra na documentação do site.

Para nosso exemplo, precisamos apenas executar o script:

```txt
// code/install-chocolatey.ps1

Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
```

- **Informação adicional:** O & antes dos comandos no Powershell é uma das formas de executar comandos console no script powershell.

## Como encontrar programas

Uma das suas dúvidas neste momento pode ser "E como eu encontro meus programas?". O choco (apelido carinhoso do chocolatey) tem vários comandos úteis, um deles é o **search** que permite pesquisar no repositório.

Imagine que você gostaria de saber por exemplo o que existem de opções relacionadas a office no repositório, então você poderia pesquisar com o comando abaixo:

```txt
// code/chocolatey-search.txt

& choco search office

```

Você terá um resultado parecido com:

```txt
// code/resultado-pesquisa.txt

Chocolatey v0.10.15
office-to-pdf 1.8 [Approved]
officeribboneditor 4.4.2 - Possibly broken
kingsoft-office-free 9.1.0.20140820 - Possibly broken
office-online-chrome 1.5.0.20170115 [Approved]
Office365ProPlus 2016.20190418 [Approved]
wps-office-free 11.2.0.8970 [Approved] Downloads cached for licensed users
Office365Business 11509.33604 [Approved]
microsoft-office-deployment 16.0.11901.20022 [Approved]
cryptopro-office-signature 2.0.11980 [Approved] Downloads cached for licensed users
OfficeProPlus2013 15.0.4827 [Approved] Downloads cached for licensed users
disableofficenag-winconfig 0.0.1 [Approved]
Office365HomePremium 2016.20160728 [Approved] Downloads cached for licensed users
disableofficemacros-winconfig 0.0.1 [Approved]
officecustomuieditor 1.1 - Possibly broken
8x8virtualoffice 6.2.4.4 [Approved]
office2013-proofingtools-nl 15.0.4420.1017 [Approved] Downloads cached for licensed users
office365-2016-deployment-tool 16.0.7614.3602 [Approved] Downloads cached for licensed users - Possibly broken for FOSS users (due to original download location changes by vendor)
officedevtools 14.0.23930 [Approved] Downloads cached for licensed users
visualstudio2017-workload-office 1.2.2 [Approved]
visualstudio2019-workload-office 1.0.0 [Approved]
libreoffice-help 5.2.0 [Approved] - Possibly broken
windows-iso-downloader 8.21 [Approved] Downloads cached for licensed users
OffCAT 2.1 [Approved] Downloads cached for licensed users - Possibly broken for FOSS users (due to original download location changes by vendor)
crealogix-paymaker-office 5.0.8.1 [Approved] Downloads cached for licensed users - Possibly broken for FOSS users (due to original download location changes by vendor)
libreoffice-fresh 6.2.5 [Approved] Downloads cached for licensed users
libreoffice-still 6.0.7 [Approved] Downloads cached for licensed users - Possibly broken for FOSS users (due to original download location changes by vendor)
officetabenterprise 9.80 - Possibly broken
officetabfree 9.70.20140510 - Possibly broken
officeremote 1.1.3.0 [Approved]
vstor2010 10.0.60828 [Approved] Downloads cached for licensed users
onlyoffice 5.3.5 [Approved] Downloads cached for licensed users
officegate-configuration-tool 1.2.8 [Approved] Downloads cached for licensed users
Excel.Viewer 12.0.6219.1000 - Possibly broken
Powerpoint.Viewer 12.0.6219.1000 - Possibly broken
Word.Viewer 12.0.6219.1000 - Possibly broken
visualstudio2019-workload-officebuildtools 1.0.0 [Approved]
visualstudio2017-workload-officebuildtools 1.0.1 [Approved]
sharepoint.2010.sdk 12.0.0.1 - Possibly broken
FoxitReader 9.6.0.25144 [Approved] Downloads cached for licensed users
SkypeForBusiness 11107.33602 [Approved] Downloads cached for licensed users - Possibly broken for FOSS users (due to original download location changes by vendor)
invantive-control-for-excel 17.32.70 [Approved] Downloads cached for licensed users
CutePDF 3.2 [Approved] Downloads cached for licensed users
contract-tools 1.30.6.0 [Approved] Downloads cached for licensed users
officeins 1.20 [Approved] Downloads cached for licensed users
wsus-offline-update 11.8.1 [Approved] Downloads cached for licensed users
project.2010.sdk 12.0.0.1 - Possibly broken
kontur-addtotrusted 2.0.18.2 [Approved] Downloads cached for licensed users
kontur-addtotrusted.portable 2.0.18.2 [Approved] Downloads cached for licensed users
kontur-plugin 3.10.2 [Approved] Downloads cached for licensed users
wordcontentcontroltoolkit 1.3 - Possibly broken
SkypeForBusinessBasic 11107.33602 [Approved] Downloads cached for licensed users - Possibly broken for FOSS users (due to original download location changes by vendor)
previewhandlerpack 1.0.0.0 - Possibly broken
kontur-certificates 4.7.27.6074 [Approved] Downloads cached for licensed users
tomboy 1.15.7 [Approved] Downloads cached for licensed users
rutoken-web-tool 1.4.0.42 [Approved] Downloads cached for licensed users
cryptopro-pdf 2.0.0811 [Approved] Downloads cached for licensed users - Possibly broken for FOSS users (due to original download location changes by vendor)
gosuslugi-plugin 3.0.7.0 [Approved] Downloads cached for licensed users
microsoft-teams.install 1.2.00.24753 [Approved] Downloads cached for licensed users
microsoft-teams 1.2.00.24753 [Approved] Downloads cached for licensed users
yed 3.19 [Approved]
onenote 16.0.11929.20300 [Approved] Downloads cached for licensed users
OpenOffice 4.1.6 [Approved]
produkey.install 1.93 [Approved] Downloads cached for licensed users
produkey.portable 1.93 [Approved] Downloads cached for licensed users
ProduKey 1.92 [Approved] - Possibly broken
FileFormatConverters 1.0.1 - Possibly broken
rutoken-drivers 4.2.5.0 [Approved] Downloads cached for licensed users
rutoken-egais-drivers 4.3.2.0 [Approved] Downloads cached for licensed users
rutoken-magistra-drivers 1.06.00.0035 [Approved] Downloads cached for licensed users
rutoken-web-plugin 1.6.2.0 [Approved] Downloads cached for licensed users
rutoken-plugin 4.0.1.0 [Approved] Downloads cached for licensed users
libreoffice 5.4.4.20180111 [Approved] - Possibly broken
libreoffice-oldstable 5.3.7.20180111 [Approved] - Possibly broken
driver-officegate 1.0.0.0 [Approved] Downloads cached for licensed users
MSAccess2010-redist 1.0
MSAccess2010-redist-x64 1.1 [Approved]
MSAccess2010-redist-x86 1.2 [Approved]
azure-information-protection-client 1.48.204.0 [Approved] Downloads cached for licensed users - Possibly broken for FOSS users (due to original download location changes by vendor)
azure-information-protection-unified-labeling-client 2.0.779.0 [Approved] Downloads cached for licensed users - Possibly broken for FOSS users (due to original download location changes by vendor)
MSFilterPack2-redist-x64 1.1 [Approved]
msoidcli 2.1 [Approved] Downloads cached for licensed users
rubberduck 1.4.3 [Approved] Downloads cached for licensed users
msoid-cli 7.250 [Approved] Downloads cached for licensed users
brutaldoom-goingdown 1.0.0 [Approved] Downloads cached for licensed users
winscan2pdf 4.98 [Approved]
kopano-deskapp-nightly 2.4.1 [Approved]
tidytabs 1.3.5 [Approved] - Possibly broken
tidytabs.portable 1.3.5 [Approved] Downloads cached for licensed users - Possibly broken for FOSS users (due to original download location changes by vendor)
tidytabs.install 1.3.5 [Approved] Downloads cached for licensed users - Possibly broken for FOSS users (due to original download location changes by vendor)
cdmessenger 3.3 [Approved] Downloads cached for licensed users
ekeyfinder 0.1.7 [Approved]
teamviewer-chrome 13.0.281 [Approved]
polleverywhere 2.11.1 [Approved] Downloads cached for licensed users
made2010 2016.07.01 [Approved] Downloads cached for licensed users
projectlibre.portable 1.9.1 [Approved] Downloads cached for licensed users
InSync 1.5.5.37367 [Approved] Downloads cached for licensed users
xmlspy 2019.3.1 [Approved] Downloads cached for licensed users
ammyy-admin 3.9.0.0 [Approved]
hdguard 10.0.0.4 [Approved] Downloads cached for licensed users
softkey-revealer.portable 2.8.0.20161009 [Approved] Downloads cached for licensed users
greenshot 1.2.10.6 [Approved] Downloads cached for licensed users
keyfinder 2.0.10.13 [Approved]
expandrive 7.0.16 [Approved] Downloads cached for licensed users
doPDF 10.3.115 [Approved] Downloads cached for licensed users
bioviadraw-ae 2018.0.0.20180925 [Approved] Downloads cached for licensed users
password-generator 3.0.0 [Approved] Downloads cached for licensed users - Possibly broken for FOSS users (due to original download location changes by vendor)
invantive-dotnet-optimizer 17.8.8 [Approved]
clamav 0.99.3 [Approved] Downloads cached for licensed users
hardentools 1.0 [Approved]
teamviewer 14.6.2452 [Approved] Downloads cached for licensed users
sparkleshare 1.5.0.20161115 [Approved] Downloads cached for licensed users
batch-docs 5.6.0 [Approved] Downloads cached for licensed users
biorhythms-calculator 2.0.0 [Approved] Downloads cached for licensed users - Possibly broken for FOSS users (due to original download location changes by vendor)
batch-word-replace 5.6.0 [Approved] Downloads cached for licensed users
envelope-printer 2.0.1 [Approved] Downloads cached for licensed users
save-to-google-drive-chrome 2.1.1 [Approved]
openchrom 1.3.0 [Approved] Downloads cached for licensed users
ultimate-settings-panel 6.3 [Approved] Downloads cached for licensed users
gsuite-migration-exchange 5.1.20.0 [Approved] Downloads cached for licensed users
dropbox 81.4.195 [Approved] Downloads cached for licensed users
leanify 0.4.2 [Approved] Downloads cached for licensed users
ost2 2.13.0.28 [Approved] Downloads cached for licensed users
bginfo 4.28 [Approved] Downloads cached for licensed users
123 packages found.

```

Outras opções principais de comando no chocolatey são:

- _choco install [nome do pacote]_ - Instala o programa.
- _choco uninstall [nome do pacote]_ - Remove o programa.
- _choco update [nome do pacote]_ - Atualiza o programa.

É possível também utilizar algumas abreviações como por exemplo:

- _cup all -y_ - Atualiza todos os programas que tiverem versão atualizada.

## Limitações

Quando utilizamos a instalação padrão e o repositório publico do Chocolatey, você normalmente não terá acesso a programas que não sejam freeware, trial ou opensource.

Os programas licensiados como pacote Office da Microsoft por exemplo não se encontram na listagem.

Se você tem a necessidade de ter programas registrados o que pode fazer é criar um repositório seu e criar os scripts de instalação você mesmo para o seu programa.

A boa notícia é que com algumas exceções, você consegue ter pelo menos a grande maioria dos seus programas instalados, já que o chocolatey está contando com um repositório bem abrangente.

## Conclusões

Se você achou que executar 3 scripts ainda assim é trabalhoso, pode juntá-los num só e executar apenas um script para efetuar todos esses passos em sequência, e ao formatar a máquina ter praticamente tudo instalado com literalmente um clique.

Eu sou muito adepto a projetos open-source e tenho basicamente todo o meu pacote de programas disponíveis no Chocolatey.

Espero que tenham gostado, e me informem se este artigo te ajudou em alguma coisa.
