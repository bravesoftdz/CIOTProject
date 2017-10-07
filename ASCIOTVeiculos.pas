{$I ACBr.inc}

unit ACBrCIOTVeiculos;

interface

uses
  Classes, Sysutils, Dialogs, Forms, StrUtils,
  ACBrCIOTUtil, ACBrCIOTConfiguracoes,
//  ACBrCTeDACTEClass,
  smtpsend, ssl_openssl, mimemess, mimepart, // units para enviar email
  pciotCIOT, pciotVeiculoR, pciotVeiculoW, pcnConversao, pcnAuxiliar, pcnLeitor;

type

  Veiculo = class(TCollectionItem)
  private
    FVeiculo: TVeiculo;
    FXML: AnsiString;
    FConfirmado : Boolean;
    FMsg : AnsiString ;
    FAlertas: AnsiString;
    FErroValidacao: AnsiString;
    FNomeArq: String;
  public
    constructor Create(Collection2: TCollection); override;
    destructor Destroy; override;
    procedure Imprimir;
    procedure ImprimirPDF;
    function SaveToFile(CaminhoArquivo: string = ''): boolean;
    function SaveToStream(Stream: TStringStream): boolean;
    procedure EnviarEmail(const sSmtpHost,
                                sSmtpPort,
                                sSmtpUser,
                                sSmtpPasswd,
                                sFrom,
                                sTo,
                                sAssunto: String;
                                sMensagem : TStrings;
                                SSL : Boolean;
                                EnviaPDF: Boolean = true;
                                sCC: TStrings = nil;
                                Anexos:TStrings=nil;
                                PedeConfirma: Boolean = False;
                                AguardarEnvio: Boolean = False;
                                NomeRemetente: String = '';
                                TLS : Boolean = True;
                                UsarThread: Boolean = True);
    property Veiculo: TVeiculo  read FVeiculo write FVeiculo;
    property XML: AnsiString  read FXML write FXML;//GetCTeXML write FXML;
    property Confirmado: Boolean  read FConfirmado write FConfirmado;
    property Msg: AnsiString  read FMsg write FMsg;
    property Alertas: AnsiString read FAlertas write FAlertas;
    property ErroValidacao: AnsiString read FErroValidacao write FErroValidacao;
    property NomeArq: String read FNomeArq write FNomeArq;
  end;

  TVeiculos = class(TOwnedCollection)
  private
    FConfiguracoes : TConfiguracoes;
    FACBrCIOT : TComponent ;

    function GetItem(Index: Integer): Veiculo;
    procedure SetItem(Index: Integer; const Value: Veiculo);
  public
    constructor Create(AOwner: TPersistent; ItemClass: TCollectionItemClass);

    procedure Imprimir;
    procedure ImprimirPDF;
    function  Add: Veiculo;
    function Insert(Index: Integer): Veiculo;
    property Items[Index: Integer]: Veiculo read GetItem  write SetItem;

    property Configuracoes: TConfiguracoes read FConfiguracoes  write FConfiguracoes;
    function GetNamePath: string; override ;

    function LoadFromFile(CaminhoArquivo: string): boolean;
    function LoadFromStream(Stream: TStringStream): boolean;
    function LoadFromString(AString: String): boolean;
    function SaveToFile(PathArquivo: string = ''): boolean;
    property ACBrCIOT : TComponent read FACBrCIOT ;
  end;

  TSendMailThread = class(TThread)
  private
    FException : Exception;
    // FOwner: Conhecimento;
    procedure DoHandleException;
  public
    OcorreramErros: Boolean;
    Terminado: Boolean;
    smtp : TSMTPSend;
    sFrom : String;
    sTo : String;
    sCC : TStrings;
    slmsg_Lines : TStrings;
    constructor Create;
    destructor Destroy; override;
  protected
    procedure Execute; override;
    procedure HandleException;
  end;


implementation

uses ACBrCIOT, ACBrUtil, ACBrDFeUtil, pcnGerador;


{ Veiculo }

constructor Veiculo.Create(Collection2: TCollection);
begin
  inherited;

  inherited Create(Collection2);
  FVeiculo := TVeiculo.Create;
end;

destructor Veiculo.Destroy;
begin
  FVeiculo.Free;
  inherited;
end;

procedure Veiculo.EnviarEmail(const sSmtpHost, sSmtpPort, sSmtpUser,
  sSmtpPasswd, sFrom, sTo, sAssunto: String; sMensagem: TStrings; SSL,
  EnviaPDF: Boolean; sCC, Anexos: TStrings; PedeConfirma,
  AguardarEnvio: Boolean; NomeRemetente: String; TLS, UsarThread: Boolean);
begin

end;

procedure Veiculo.Imprimir;
begin
//  if not Assigned( TACBrCIOT( TOperacoesTransporte( Collection ).ACBrCTe ).DACTE ) then
//     raise Exception.Create('Componente DACTE não associado.')
//  else
//     TACBrCIOT( TOperacoesTransporte( Collection ).ACBrCTe ).DACTE.ImprimirDACTE(CTe);
end;

procedure Veiculo.ImprimirPDF;
begin
//  if not Assigned( TACBrCIOT( TOperacoesTransporte( Collection ).ACBrCTe ).DACTE ) then
//     raise Exception.Create('Componente DACTE não associado.')
//  else
//     TACBrCIOT( TOperacoesTransporte( Collection ).ACBrCTe ).DACTE.ImprimirDACTEPDF(CTe);
end;

function Veiculo.SaveToFile(CaminhoArquivo: string): boolean;
var
  LocVeiculoW : TVeiculoW;
begin
  try
     Result  := True;
     LocVeiculoW := TVeiculoW.Create(TVeiculo(Self));
     try
        LocVeiculoW.Gerador.Opcoes.FormatoAlerta := TACBrCIOT( TVeiculo( Collection )).Configuracoes.Geral.FormatoAlerta;
        LocVeiculoW.GerarXml;
        if DFeUtil.EstaVazio(CaminhoArquivo) then
           CaminhoArquivo := PathWithDelim(TACBrCIOT( TVeiculo( Collection )).Configuracoes.Geral.PathSalvar)+Veiculo.Placa+'-cte.xml';
        if DFeUtil.EstaVazio(CaminhoArquivo) or not DirectoryExists(ExtractFilePath(CaminhoArquivo)) then
           raise Exception.Create('Caminho Inválido: ' + CaminhoArquivo);
        LocVeiculoW.Gerador.SalvarArquivo(CaminhoArquivo);
        NomeArq := CaminhoArquivo;
     finally
        LocVeiculoW.Free;
     end;
  except
     raise;
     Result := False;
  end;
end;

function Veiculo.SaveToStream(Stream: TStringStream): boolean;
begin

end;

{ TVeiculos }

function TVeiculos.Add: Veiculo;
begin
  Result := Veiculo(inherited Add);
end;

constructor TVeiculos.Create(AOwner: TPersistent; ItemClass: TCollectionItemClass);
begin
  if not (AOwner is TACBrCIOT ) then
     raise Exception.Create( 'AOwner deve ser do tipo TACBrCIOT') ;

  inherited;

  FACBrCIOT := TACBrCIOT( AOwner ) ;
end;

function TVeiculos.GetItem(Index: Integer): Veiculo;
begin
  Result := Veiculo(inherited Items[Index]);
end;

function TVeiculos.GetNamePath: string;
begin
  Result := 'Veiculo';
end;

procedure TVeiculos.Imprimir;
begin
//  if not Assigned( TACBrCIOT( FACBrCIOT ).DACTE ) then
//     raise Exception.Create('Componente DACTE não associado.')
//  else
//     TACBrCIOT( FACBrCIOT ).DACTe.ImprimirDACTe(nil);
end;

procedure TVeiculos.ImprimirPDF;
begin
//  if not Assigned( TACBrCIOT( FACBrCIOT ).DACTE ) then
//     raise Exception.Create('Componente DACTE não associado.')
//  else
//     TACBrCIOT( FACBrCIOT ).DACTe.ImprimirDACTePDF(nil);
end;

function TVeiculos.Insert(Index: Integer): Veiculo;
begin
  Result := Veiculo(inherited Insert(Index));
end;

function TVeiculos.LoadFromFile(CaminhoArquivo: string): boolean;
var
  LocVeiculoR : TVeiculoR;
  ArquivoXML: TStringList;
  XML, XMLOriginal : AnsiString;
begin
 try
    ArquivoXML := TStringList.Create;
    try
      ArquivoXML.LoadFromFile(CaminhoArquivo {$IFDEF DELPHI2009_UP}, TEncoding.UTF8{$ENDIF});
      XMLOriginal := ArquivoXML.Text;
      Result := True;
      while pos('</CTe>',ArquivoXML.Text) > 0 do
       begin
         if pos('</cteProc>',ArquivoXML.Text) > 0  then
          begin
            XML := copy(ArquivoXML.Text,1,pos('</cteProc>',ArquivoXML.Text)+5);
            ArquivoXML.Text := Trim(copy(ArquivoXML.Text,pos('</cteProc>',ArquivoXML.Text)+10,length(ArquivoXML.Text)));
          end
         else
          begin
            XML := copy(ArquivoXML.Text,1,pos('</CTe>',ArquivoXML.Text)+5);
            ArquivoXML.Text := Trim(copy(ArquivoXML.Text,pos('</CTe>',ArquivoXML.Text)+6,length(ArquivoXML.Text)));
          end;
//         LocCTeR := TCTeR.Create(Self.Add.CTe);
         try
            LocVeiculoR.Leitor.Arquivo := XML;
            LocVeiculoR.LerXml;
            Items[Self.Count-1].XML := LocVeiculoR.Leitor.Arquivo;
//            Items[Self.Count-1].XMLOriginal := XMLOriginal;
            Items[Self.Count-1].NomeArq := CaminhoArquivo;
//            if AGerarCTe then GerarCTe;
         finally
            LocVeiculoR.Free;
         end;
       end;
    finally
      ArquivoXML.Free;
    end;
 except
    raise;
    Result := False;
 end;
end;

function TVeiculos.LoadFromStream(Stream: TStringStream): boolean;
begin

end;

function TVeiculos.LoadFromString(AString: String): boolean;
begin

end;

function TVeiculos.SaveToFile(PathArquivo: string): boolean;
begin

end;

procedure TVeiculos.SetItem(Index: Integer; const Value: Veiculo);
begin
  Items[Index].Assign(Value);
end;

{ TSendMailThread }

constructor TSendMailThread.Create;
begin
  smtp        := TSMTPSend.Create;
  slmsg_Lines := TStringList.Create;
  sCC         := TStringList.Create;
  sFrom       := '';
  sTo         := '';

  FreeOnTerminate := True;

  inherited Create(True);
end;

destructor TSendMailThread.Destroy;
begin
  slmsg_Lines.Free;
  sCC.Free;
  smtp.Free;

  inherited;
end;

procedure TSendMailThread.DoHandleException;
begin
//   TACBrCIOT(TVeiculos(FOwner.GetOwner).ACBrCTe).SetStatus( stCTeIdle );
//
//   FOwner.Alertas := FException.Message;

  if FException is Exception then
    Application.ShowException(FException)
  else
    SysUtils.ShowException(FException, nil);
end;

procedure TSendMailThread.Execute;
var
 i: integer;
begin
  inherited;

  try
    Terminado := False;
    try
      if not smtp.Login() then
        raise Exception.Create('SMTP ERROR: Login:' + smtp.EnhCodeString+sLineBreak+smtp.FullResult.Text);

      if not smtp.MailFrom( sFrom, Length(sFrom)) then
        raise Exception.Create('SMTP ERROR: MailFrom:' + smtp.EnhCodeString+sLineBreak+smtp.FullResult.Text);

      if not smtp.MailTo(sTo) then
        raise Exception.Create('SMTP ERROR: MailTo:' + smtp.EnhCodeString+sLineBreak+smtp.FullResult.Text);

      if (sCC <> nil) then
      begin
        for I := 0 to sCC.Count - 1 do
        begin
          if not smtp.MailTo(sCC.Strings[i]) then
            raise Exception.Create('SMTP ERROR: MailTo:' + smtp.EnhCodeString+sLineBreak+smtp.FullResult.Text);
        end;
      end;

      if not smtp.MailData(slmsg_Lines) then
        raise Exception.Create('SMTP ERROR: MailData:' + smtp.EnhCodeString+sLineBreak+smtp.FullResult.Text);

      if not smtp.Logout() then
        raise Exception.Create('SMTP ERROR: Logout:' + smtp.EnhCodeString+sLineBreak+smtp.FullResult.Text);
    finally
      try
        smtp.Sock.CloseSocket;
      except
      end ;
      Terminado := True;
    end;
  except
    Terminado := True;
    HandleException;
  end;
end;

procedure TSendMailThread.HandleException;
begin
  FException := Exception(ExceptObject);
  try
    // Não mostra mensagens de EAbort
    if not (FException is EAbort) then
      Synchronize(DoHandleException);
  finally
    FException := nil;
  end;
end;

end.
