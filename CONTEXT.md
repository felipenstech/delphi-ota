# Contexto do Projeto Delphi OTA

Este arquivo serve como referência de contexto para criação de novas features, correções e releases do projeto `delphi-ota`.

## Visão Geral

- Projeto: plugin de design-time para Delphi 10.1 Berlin.
- Objetivo: criar um pacote que estende o IDE Delphi usando a Open Tools API (OTA).
- Recursos principais:
  - menu customizado no IDE com ações específicas.
  - registro de ícones na Splash Screen e na caixa "About".
  - integração com o editor e toolbox da IDE.

## Estrutura de Pastas

- `dclMenus.dpk` - package Delphi principal do plugin.
- `dclMenus.dproj`, `dclMenus.dproj.local` - arquivos de projeto Delphi.
- `src/` - unidades-fonte do pacote:
  - `MyPlugins.MainMenuItems.pas` - wizard/menu do IDE.
  - `MyPlugins.RegisterPlugin.pas` - registro do wizard no package.
  - `MyPlugins.Views.ViewLab.pas` + `.dfm` - formulário visual de exemplo.
  - `MyPlugins.SplashScreen.pas` - registro de Splash Screen e About Box.
  - `MyPlugins.Strings.pas` - resource strings compartilhadas para Splash Screen/About e futura i18n.
- `icons/` - ícones usados pelo package.
- `Win32/Debug`, `bpl/`, `dcp/`, `dcu/` - artefatos de compilação.
- `__history/` - backups e versões anteriores de arquivos.

## Como Compilar

- Use `msbuild` para compilar o pacote Delphi a partir do arquivo `dclMenus.dproj`.
- Antes de rodar `msbuild`, carregue as variáveis de ambiente definidas em `rsvars.bat`.
- Exemplo de comando:
  - `cmd.exe /c "call rsvars.bat && msbuild dclMenus.dproj /t:Build /p:Config=Debug /p:Platform=Win32"`
- Isso garante que as configurações do Delphi e o ambiente de build sejam definidos corretamente.

## Padrões de Código

- Classes: `T` prefixado, ex: `TOtimizyWizard`.
- Campos privados: prefixo `F`, ex: `FMainMenu`, `FImageIndexSite`.
- Variáveis locais: prefixo `l`, ex: `lMenuItemSite`, `lBmp`.
- Parâmetros: prefixo `A`, ex: `ANTAService`, `ASender`.
- Eventos: prefixo `Ev`, ex: `EvMenuSiteClick`, `EvMenuExecutarClick`.
- Strings de recurso: prefixo `rs`, ex: `rsPackageName`.
- Resource strings devem ser extraídas para `MyPlugins.Strings.pas` para permitir separação, reutilização e futura internacionalização.
- Constantes: `UPPER_SNAKE_CASE` sem qualquer prefixo que indique ser uma constante, ex: `TELEMETRY_APP_FOLDER`, `DEFAULT_PLUGIN_VERSION`.
- Interfaces OTA: uso de `IOTAWizard`, `INTAServices`, `IOTAEditorServices`.

## Áreas de Melhoria e Correções

- Corrigir inicialização de `FImageIndexExec` em `MyPlugins.MainMenuItems.pas`.
- Implementar ação de tradução em `EvMenuTraduzirClick`.
- Completar ou remover o método `TOtimizyWizard.Execute` se não for necessário.
- Evitar `FMainMenu.Free` no `Destroy` caso `ANTAService.MainMenu.Items.Add(FMainMenu)` assuma propriedade do item.
- Revisar uso de `CodeSiteLogging` para garantir que não impacte build de release.
- Documentar assets de recurso (`MyPlugins.SplashScreen.rc`, `ID_SITE`, `ID_EXEC`, `ID_SPLASH`, `ID_ABOUT`).

## Possíveis Novas Features

- Ação de tradução usando API externa e retorno ao editor.
- Menu para abrir documentação ou página de suporte diretamente no IDE.
- Integração com ferramentas de produtividade (por exemplo, commands de build, snippets ou templates).
- Painel customizado com formulários OTA adicionais, usando `MyPlugins.Views.ViewLab` como base.
- Registro de atalhos de teclado para as ações do menu.

## Releases

- Este projeto é um laboratório/teste, então cada release deve focar em:
  1. estabilidade do pacote no IDE.
  2. compatibilidade com Delphi 10.1 Berlin.
  3. documentação de install/uninstall.

- Sugestão de workflow de release:
  - `v0.1.0` - plugin básico com menu e ícones OTA ativos.
  - `v0.2.0` - inclusão da ação de tradução funcional.
  - `v0.3.0` - suporte a recursos adicionais na aba About.

## Notas Gerais

- O package é um plugin de IDE, não uma aplicação desktop tradicional.
- O foco principal está em demonstrar e testar a Open Tools API do Delphi.
- A convenção de nomes segue o estilo Delphi clássico, com prefixos claros.

---

> Use este arquivo como base para planejar funcionalidades, priorizar correções e documentar releases no repositório.
