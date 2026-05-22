# Splash Screen & About Box — Delphi OTA

Registro de imagem na **Splash Screen** e no **About Box** do Delphi via
Open Tools API (OTA), seguindo o padrão do repositório
[felipenstech/delphi-ota](https://github.com/felipenstech/delphi-ota).

---

## Arquivos gerados

| Arquivo | Papel |
|---|---|
| `uSplashScreen.pas` | Registra o bitmap na Splash Screen e no About Box |
| `uRegister.pas` | Ponto de entrada do pacote; chama `ForceDemandLoadState` |
| `uSplashScreen.rc` | Fonte do arquivo de recursos (bitmaps) |

---

## Passo a passo

### 1. Prepare os bitmaps

| Recurso | Tamanho | Onde aparece |
|---|---|---|
| `splash_24x24.bmp` | **24 × 24 px** | Splash Screen do Delphi |
| `about_48x48.bmp` | **48 × 48 px** | Help → About Delphi |

Salve ambos na mesma pasta de `uSplashScreen.rc`.

### 2. Compile o arquivo de recursos

Abra um terminal (Prompt de Comando ou Terminal do Delphi) e execute:

```bat
brcc32.exe uSplashScreen.rc
```

O `brcc32.exe` fica em `<Delphi>\bin\`. Isso gera `uSplashScreen.res`
na mesma pasta.

> **Dica:** você pode criar um script `compile_res.bat` com o comando
> acima para facilitar a recompilação sempre que trocar as imagens.

### 3. Adicione os arquivos ao pacote (.dpk)

Abra `dclMenus.dpk` (ou seu pacote) e inclua as duas units na seção
`contains`:

```pascal
package dclMenus;

{$R *.res}

requires
  rtl,
  DesignIDE;

contains
  uRegister    in 'src\uRegister.pas',
  uSplashScreen in 'src\uSplashScreen.pas';

end.
```

### 4. Ajuste as strings de identificação

Em `uSplashScreen.pas`, edite as `resourcestring` conforme seu pacote:

```pascal
resourcestring
  rsPackageName    = 'Meu Pacote de Componentes';
  rsLicenseText    = 'Licença: Open Source / Freeware';
  rsAboutTitle     = 'Meu Pacote de Componentes';
  rsAboutCopyright = 'Copyright © 2024 – Seu Nome / Sua Empresa Ltda.';
  rsAboutDescription = 'Descrição do seu pacote...';
```

### 5. Compile e instale o pacote

No Delphi:

1. **Project → Build** — compila o BPL.
2. **Component → Install Packages** → Add → selecione o BPL gerado.

ou, com o pacote aberto:

- Clique em **Compile** e depois **Install**.

### 6. Verifique o resultado

- **About Box:** `Help → About Embarcadero Delphi` — seu ícone e texto
  aparecem imediatamente após a instalação.
- **Splash Screen:** feche e reabra o Delphi — seu ícone aparece durante
  o carregamento da IDE.

---

## Como funciona

```
Delphi inicia
    └─► Carrega os BPLs instalados
            └─► initialization de uSplashScreen.pas executa
                    ├─► RegisterSplashScreen  →  SplashScreenServices.AddPluginBitmap
                    └─► RegisterAboutBox      →  IOTAAboutBoxServices.AddPluginInfo

Delphi encerra
    └─► finalization de uSplashScreen.pas executa
            └─► UnregisterAboutBox  →  IOTAAboutBoxServices.RemovePluginInfo
```

### Por que `ForceDemandLoadState(dlDisable)`?

Por padrão o Delphi usa **carregamento por demanda**: um BPL só é
inicializado quando algum componente seu é inserido num form. Isso
impede que a `initialization` de `uSplashScreen` rode a tempo de
exibir o ícone na Splash. Chamar `ForceDemandLoadState(dlDisable)` em
`uRegister.Register` força o carregamento imediato do pacote.

---

## Estrutura de pastas sugerida

```
delphi-ota/
├── src/
│   ├── uRegister.pas
│   ├── uSplashScreen.pas
│   └── uSplashScreen.rc        ← fonte dos recursos
├── res/
│   ├── splash_24x24.bmp        ← bitmap 24x24 para a Splash
│   ├── about_48x48.bmp         ← bitmap 48x48 para o About
│   └── uSplashScreen.res       ← gerado pelo brcc32 (não commitar)
├── dclMenus.dpk
└── dclMenus.dproj
```

---

## Dependências no .dpk

```pascal
requires
  rtl,
  DesignIDE;   // contém ToolsAPI, DesignIntf, SplashScreenServices etc.
```

> Não adicione `vcl` ou `vcldesign` se o pacote for apenas de OTA —
> o `DesignIDE` já puxa tudo que é necessário.
