unit MyPlugins.Strings;

{ ---------------------------------------------------------------------------
  MyPlugins.Strings.pas
  Contém todas as ResourceStrings usadas pelo plugin.
  Essa unidade permite separar textos estáticos para reutilização futura
  e facilita a internacionalização (i18n).
  --------------------------------------------------------------------------- }

interface

resourcestring
  { Nome exibido na Splash Screen ao lado do ícone }
  rsPackageName = 'Meu Pacote de Componentes';

  { Texto de licença exibido logo abaixo do nome na Splash Screen }
  rsLicenseText = 'Licença: Open Source / Freeware';

  { Título exibido na aba do About Box }
  rsAboutTitle = 'Meu Pacote de Componentes';

  { Linha(s) de copyright exibidas no About Box }
  rsAboutCopyright = 'Copyright © 2024 – Seu Nome / Sua Empresa Ltda.';

  { Descrição completa exibida na área de texto do About Box }
  rsAboutDescription = 'Meu Pacote de Componentes é uma coleção de controles e utilitários ' +
    'desenvolvidos para agilizar o desenvolvimento de aplicações Delphi. ' +
    'Visite https://github.com/felipenstech/delphi-ota para mais informações.';

implementation

end.
