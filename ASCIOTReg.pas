{$I ACBr.inc}

unit ASCIOTReg;

interface

uses
  SysUtils, Classes, ASCIOT, pcnConversao,
  {$IFDEF VisualCLX} QDialogs {$ELSE} Dialogs, FileCtrl {$ENDIF},
  {$IFDEF FPC}
     LResources, LazarusPackageIntf, PropEdits, componenteditors
  {$ELSE}
    {$IFNDEF COMPILER6_UP}
       DsgnIntf
    {$ELSE}
       DesignIntf,
       DesignEditors
    {$ENDIF}
  {$ENDIF} ;


type
  { Editor de Proriedades de Componente para mostrar o AboutACBr }
  TASAboutDialogProperty = class(TPropertyEditor)
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
    function GetValue: string; override;
  end;

  THRWEBSERVICEUFProperty = class( TStringProperty )
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure GetValues( Proc : TGetStrProc) ; override;
  end;

  { Editor de Proriedades de Componente para chamar OpenDialog }
  TASCIOTDirProperty = class( TStringProperty )
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
  end;

procedure Register;

implementation

uses ASCIOTConfiguracoes;
//
//{$IFNDEF FPC}
//   {$R ASCIOT.dcr}
//{$ENDIF}

procedure Register;
begin
  RegisterComponents('ACBr', [TAmsCIOT]);
  RegisterPropertyEditor(TypeInfo(TAmsCIOTAboutInfo), nil, 'AboutAmsCIOT', TASAboutDialogProperty);
  RegisterPropertyEditor(TypeInfo(TCertificadosConf), TConfiguracoes, 'Certificados', TClassProperty);
  RegisterPropertyEditor(TypeInfo(TConfiguracoes), TAMSCIOT, 'Configuracoes', TClassProperty);
  RegisterPropertyEditor(TypeInfo(TWebServicesConf), TConfiguracoes, 'WebServices', TClassProperty);
  RegisterPropertyEditor(TypeInfo(String), TWebServicesConf, 'UF', THRWEBSERVICEUFProperty);
  RegisterPropertyEditor(TypeInfo(TGeralConf), TConfiguracoes, 'Geral', TClassProperty);
  RegisterPropertyEditor(TypeInfo(String), TGeralConf, 'PathSalvar', TASCIOTDirProperty);
  RegisterPropertyEditor(TypeInfo(TArquivosConf), TConfiguracoes, 'Arquivos', TClassProperty);

end;

{ TASAboutDialogProperty }
procedure TASAboutDialogProperty.Edit;
begin
  ACBrAboutDialog ;
end;

function TASAboutDialogProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog, paReadOnly];
end;

function TASAboutDialogProperty.GetValue: string;
begin
  Result := 'Versão: ' + AmsCIOT_VERSAO ;
end;

{ THRWEBSERVICEUFProperty }

function THRWEBSERVICEUFProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paValueList, paAutoUpdate];
end;

procedure THRWEBSERVICEUFProperty.GetValues(Proc: TGetStrProc);
var
 i : integer;
begin
  inherited;
  for i:= 0 to High(NFeUF) do
    Proc(NFeUF[i]);
end;

{ TACBrCIOTDirProperty }

procedure TASCIOTDirProperty.Edit;
Var
{$IFNDEF VisualCLX} Dir : String ; {$ELSE} Dir : WideString ; {$ENDIF}
begin
  {$IFNDEF VisualCLX}
  Dir := GetValue ;
  if SelectDirectory(Dir,[],0) then
     SetValue( Dir ) ;
  {$ELSE}
  Dir := '' ;
  if SelectDirectory('Selecione o Diretório','',Dir) then
     SetValue( Dir ) ;
  {$ENDIF}
end;

function TASCIOTDirProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog];
end;

initialization
{$IFDEF FPC}
   {$i ACBrCIOT.lrs}
{$ENDIF}

end.
