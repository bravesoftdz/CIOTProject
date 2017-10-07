{$I ACBr.inc}

unit ACBrCIOTOperacoesTransporte;

interface

uses
  Classes, Sysutils, Dialogs, Forms, StrUtils,
  ACBrCIOTUtil, ACBrCIOTConfiguracoes,
  //ACBrCTeDACTEClass,
  smtpsend, ssl_openssl, mimemess, mimepart, // units para enviar email
  pciotCIOT, pciotVeiculoR, pciotVeiculoW, pcnConversao, pcnAuxiliar, pcnLeitor;

type

  OperacaoTransporte = class(TCollectionItem)
  private
    FCIOT: TOperacaoTransporte;
    FXML: AnsiString;
    FXMLOriginal: AnsiString;
    FConfirmada : Boolean;
    FMsg : AnsiString ;
    FAlertas: AnsiString;
    FErroValidacao: AnsiString;
    FErroValidacaoCompleto: AnsiString;
    FNomeArq: String;
    function GetCTeXML: AnsiString;
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
    property CTe: TOperacaoTransporte  read FCIOT write FCIOT;
    property XML: AnsiString  read GetCTeXML write FXML;
    property XMLOriginal: AnsiString  read FXMLOriginal write FXMLOriginal;
    property Confirmada: Boolean  read FConfirmada write FConfirmada;
    property Msg: AnsiString  read FMsg write FMsg;
    property Alertas: AnsiString read FAlertas write FAlertas;
    property ErroValidacao: AnsiString read FErroValidacao write FErroValidacao;
    property ErroValidacaoCompleto: AnsiString read FErroValidacaoCompleto write FErroValidacaoCompleto;    
    property NomeArq: String read FNomeArq write FNomeArq;
  end;

  TOperacoesTransporte = class(TOwnedCollection)
  private
    FConfiguracoes : TConfiguracoes;
    FACBrCIOT : TComponent ;

    function GetItem(Index: Integer): OperacaoTransporte;
    procedure SetItem(Index: Integer; const Value: OperacaoTransporte);
  public
    constructor Create(AOwner: TPersistent; ItemClass: TCollectionItemClass);

    procedure GerarCTe;
    procedure Assinar;
    procedure Valida;
    function ValidaAssinatura(out Msg : String) : Boolean;
    procedure Imprimir;
    procedure ImprimirPDF;
    function  Add: OperacaoTransporte;
    function Insert(Index: Integer): OperacaoTransporte;
    property Items[Index: Integer]: OperacaoTransporte read GetItem  write SetItem;
    property Configuracoes: TConfiguracoes read FConfiguracoes  write FConfiguracoes;

    function GetNamePath: string; override ;
    // Incluido o Parametro AGerarCTe que determina se após carregar os dados do CTe
    // para o componente, será gerado ou não novamente o XML do CTe.
    function LoadFromFile(CaminhoArquivo: string; AGerarCTe: Boolean = True): boolean;
    function LoadFromStream(Stream: TStringStream; AGerarCTe: Boolean = True): boolean;
    function LoadFromString(AString: String; AGerarCTe: Boolean = True): boolean;
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

{ Conhecimento }

constructor OperacaoTransporte.Create(Collection2: TCollection);
begin
  inherited Create(Collection2);
  FCIOT := TOperacaoTransporte.Create;

//  FCIOT.Ide.tpCTe  := tcNormal;
//  FCIOT.Ide.modelo := '57';
//
//  FCIOT.Ide.verProc := 'ACBrCIOT';
//  FCIOT.Ide.tpAmb   := TACBrCIOT( TOperacoesTransporte( Collection ).ACBrCTe ).Configuracoes.WebServices.Ambiente;
//  FCIOT.Ide.tpEmis  := TACBrCIOT( TOperacoesTransporte( Collection ).ACBrCTe ).Configuracoes.Geral.FormaEmissao;
//  if Assigned(TACBrCIOT( TOperacoesTransporte( Collection ).ACBrCTe ).DACTe) then
//     FCIOT.Ide.tpImp   := TACBrCIOT( TOperacoesTransporte( Collection ).ACBrCTe ).DACTe.TipoDACTE;
end;

destructor OperacaoTransporte.Destroy;
begin
  FCIOT.Free;
  inherited Destroy;
end;

procedure OperacaoTransporte.Imprimir;
begin
//  if not Assigned( TACBrCIOT( TOperacoesTransporte( Collection ).ACBrCTe ).DACTE ) then
//     raise Exception.Create('Componente DACTE não associado.')
//  else
//     TACBrCIOT( TOperacoesTransporte( Collection ).ACBrCTe ).DACTE.ImprimirDACTE(CTe);
end;

procedure OperacaoTransporte.ImprimirPDF;
begin
//  if not Assigned( TACBrCIOT( TOperacoesTransporte( Collection ).ACBrCTe ).DACTE ) then
//     raise Exception.Create('Componente DACTE não associado.')
//  else
//     TACBrCIOT( TOperacoesTransporte( Collection ).ACBrCTe ).DACTE.ImprimirDACTEPDF(CTe);
end;

function OperacaoTransporte.SaveToFile(CaminhoArquivo: string = ''): boolean;
//var
//  LocCTeW : TCTeW;
begin
//  try
//     Result  := True;
//     LocCTeW := TCTeW.Create(CIOT);
//     try
//        LocCTeW.Gerador.Opcoes.FormatoAlerta := TACBrCIOT( TOperacoesTransporte( Collection ).ACBrCTe ).Configuracoes.Geral.FormatoAlerta;
//        LocCTeW.GerarXml;
//        if DFeUtil.EstaVazio(CaminhoArquivo) then
//           CaminhoArquivo := PathWithDelim(TACBrCIOT( TOperacoesTransporte( Collection ).ACBrCTe ).Configuracoes.Geral.PathSalvar)+copy(CTe.inFCTe.ID, (length(CTe.inFCTe.ID)-44)+1, 44)+'-cte.xml';
//        if DFeUtil.EstaVazio(CaminhoArquivo) or not DirectoryExists(ExtractFilePath(CaminhoArquivo)) then
//           raise Exception.Create('Caminho Inválido: ' + CaminhoArquivo);
//        LocCTeW.Gerador.SalvarArquivo(CaminhoArquivo);
//        NomeArq := CaminhoArquivo;
//     finally
//        LocCTeW.Free;
//     end;
//  except
//     raise;
//     Result := False;
//  end;
end;

function OperacaoTransporte.SaveToStream(Stream: TStringStream): boolean;
//var
//  LocCTeW : TCTeW;
begin
//  try
//     Result  := True;
//     LocCTeW := TCTeW.Create(CTe);
//     try
//        LocCTeW.Gerador.Opcoes.FormatoAlerta := TACBrCIOT( TOperacoesTransporte( Collection ).ACBrCTe ).Configuracoes.Geral.FormatoAlerta;
//        LocCTeW.GerarXml;
//        Stream.WriteString(LocCTeW.Gerador.ArquivoFormatoXML);
//     finally
//        LocCTeW.Free;
//     end;
//  except
//     Result := False;
//  end;
end;

procedure OperacaoTransporte.EnviarEmail(const sSmtpHost,
                                      sSmtpPort,
                                      sSmtpUser,
                                      sSmtpPasswd,
                                      sFrom,
                                      sTo,
                                      sAssunto: String;
                                      sMensagem : TStrings;
                                      SSL : Boolean;
                                      EnviaPDF: Boolean = true;
                                      sCC: TStrings=nil;
                                      Anexos:TStrings=nil;
                                      PedeConfirma: Boolean = False;
                                      AguardarEnvio: Boolean = False;
                                      NomeRemetente: String = '';
                                      TLS : Boolean = True;
                                      UsarThread: Boolean = True);
var
 NomeArq : String;
 AnexosEmail:TStrings ;
 StreamCTe : TStringStream;
begin
 AnexosEmail := TStringList.Create;
 StreamCTe  := TStringStream.Create('');
 try
    AnexosEmail.Clear;
    if Anexos <> nil then
      AnexosEmail.Text := Anexos.Text;
    if NomeArq <> '' then
     begin
       SaveToFile(NomeArq);
       AnexosEmail.Add(NomeArq);
     end
    else
     begin
       SaveToStream(StreamCTe) ;
     end;
    if (EnviaPDF) then
    begin
//       if TACBrCIOT( TOperacoesTransporte( Collection ).ACBrCTe ).DACTE <> nil then
//       begin
//          TACBrCIOT( TOperacoesTransporte( Collection ).ACBrCTe ).DACTE.ImprimirDACTEPDF(CTe);
//          NomeArq :=  StringReplace(CTe.infCTe.ID,'CTe', '', [rfIgnoreCase]);
//          NomeArq := PathWithDelim(TACBrCIOT( TOperacoesTransporte( Collection ).ACBrCTe ).DACTE.PathPDF)+NomeArq+'.pdf';
//          AnexosEmail.Add(NomeArq);
//       end;
    end;
//    TACBrCIOT( TOperacoesTransporte( Collection ).ACBrCTe ).EnviaEmail(sSmtpHost,
//                sSmtpPort,
//                sSmtpUser,
//                sSmtpPasswd,
//                sFrom,
//                sTo,
//                sAssunto,
//                sMensagem,
//                SSL,
//                sCC,
//                AnexosEmail,
//                PedeConfirma,
//                AguardarEnvio,
//                NomeRemetente,
//                TLS,
//                StreamCTe,
//                copy(CTe.infCTe.ID, (length(CTe.infCTe.ID)-44)+1, 44)+'-CTe.xml',
//                UsarThread);
 finally
    AnexosEmail.Free ;
    StreamCTe.Free ;
 end;
end;

function OperacaoTransporte.GetCTeXML: AnsiString;
//var
// LocCTeW : TCTeW;
begin
// LocCTeW := TCTeW.Create(Self.CTe);
// try
//    LocCTeW.Gerador.Opcoes.FormatoAlerta := TACBrCIOT( TOperacoesTransporte( Collection ).ACBrCTe ).Configuracoes.Geral.FormatoAlerta;
//    LocCTeW.GerarXml;
//    Result := LocCTeW.Gerador.ArquivoFormatoXML;
// finally
//    LocCTeW.Free;
// end;
end;

{ TOperacoesTransporte }
constructor TOperacoesTransporte.Create(AOwner: TPersistent;
  ItemClass: TCollectionItemClass);
begin
  if not (AOwner is TACBrCIOT ) then
     raise Exception.Create( 'AOwner deve ser do tipo TACBrCIOT') ;

  inherited;

  FACBrCIOT := TACBrCIOT( AOwner ) ;
end;


function TOperacoesTransporte.Add: OperacaoTransporte;
begin
  Result := OperacaoTransporte(inherited Add);

//  Result.CTe.Ide.tpAmb := Configuracoes.WebServices.Ambiente ;
end;

procedure TOperacoesTransporte.Assinar;
var
  i: Integer;
  vAssinada : AnsiString;
//  LocCTeW : TCTeW;
  Leitor: TLeitor;
  FMsg : AnsiString;
begin
  for i:= 0 to Self.Count-1 do
   begin
//     LocCTeW := TCTeW.Create(Self.Items[i].CTe);
     try
//        LocCTeW.Gerador.Opcoes.FormatoAlerta := FConfiguracoes.Geral.FormatoAlerta;
//        LocCTeW.GerarXml;
//        Self.Items[i].Alertas := LocCTeW.Gerador.ListaDeAlertas.Text;
{$IFDEF ACBrCTeOpenSSL}
//        if not(CTeUtil.Assinar(LocCTeW.Gerador.ArquivoFormatoXML, FConfiguracoes.Certificados.Certificado , FConfiguracoes.Certificados.Senha, vAssinada, FMsg)) then
//           raise Exception.Create('Falha ao assinar Conhecimento de Transporte Eletrônico '+
//                                   IntToStr(Self.Items[i].CTe.Ide.cCT)+FMsg);
{$ELSE}
//        if not(CTeUtil.Assinar(LocCTeW.Gerador.ArquivoFormatoXML, FConfiguracoes.Certificados.GetCertificado , vAssinada, FMsg)) then
//           raise Exception.Create('Falha ao assinar Conhecimento de Transporte Eletrônico '+
//                                   IntToStr(Self.Items[i].CTe.Ide.cCT)+FMsg);
{$ENDIF}
//        vAssinada := StringReplace( vAssinada, '<'+ENCODING_UTF8_STD+'>', '', [rfReplaceAll] ) ;
//        vAssinada := StringReplace( vAssinada, '<?xml version="1.0"?>', '', [rfReplaceAll] ) ;
//        Self.Items[i].XML := vAssinada;
//
//        Leitor := TLeitor.Create;
//        leitor.Grupo := vAssinada;
//        Self.Items[i].CTe.signature.URI := Leitor.rAtributo('Reference URI=');
//        Self.Items[i].CTe.signature.DigestValue := Leitor.rCampo(tcStr, 'DigestValue');
//        Self.Items[i].CTe.signature.SignatureValue := Leitor.rCampo(tcStr, 'SignatureValue');
//        Self.Items[i].CTe.signature.X509Certificate := Leitor.rCampo(tcStr, 'X509Certificate');
//        Leitor.Free;
//
//        if FConfiguracoes.Geral.Salvar then
//           FConfiguracoes.Geral.Save(StringReplace(Self.Items[i].CTe.infCTe.ID, 'CTe', '', [rfIgnoreCase])+'-cte.xml', vAssinada);
//
//        if DFeUtil.NaoEstaVazio(Self.Items[i].NomeArq) then
//           FConfiguracoes.Geral.Save(ExtractFileName(Self.Items[i].NomeArq), vAssinada, ExtractFilePath(Self.Items[i].NomeArq));
     finally
//        LocCTeW.Free;
     end;
   end;

end;

procedure TOperacoesTransporte.GerarCTe;
var
 i: Integer;
// LocCTeW : TCTeW;
begin
 for i:= 0 to Self.Count-1 do
  begin
//    LocCTeW := TCTeW.Create(Self.Items[i].CTe);
//    try
//       LocCTeW.Gerador.Opcoes.FormatoAlerta := FConfiguracoes.Geral.FormatoAlerta;
//       LocCTeW.GerarXml;
//       Self.Items[i].XML     := LocCTeW.Gerador.ArquivoFormatoXML;
//       Self.Items[i].Alertas := LocCTeW.Gerador.ListaDeAlertas.Text;
//    finally
//       LocCTeW.Free;
//    end;
  end;
end;

function TOperacoesTransporte.GetItem(Index: Integer): OperacaoTransporte;
begin
  Result := OperacaoTransporte(inherited Items[Index]);
end;

function TOperacoesTransporte.GetNamePath: string;
begin
  Result := 'OperacaoTransporte';
end;

procedure TOperacoesTransporte.Imprimir;
begin
//  if not Assigned( TACBrCIOT( FACBrCIOT ).DACTE ) then
//     raise Exception.Create('Componente DACTE não associado.')
//  else
//     TACBrCIOT( FACBrCIOT ).DACTe.ImprimirDACTe(nil);
end;

procedure TOperacoesTransporte.ImprimirPDF;
begin
//  if not Assigned( TACBrCIOT( FACBrCIOT ).DACTE ) then
//     raise Exception.Create('Componente DACTE não associado.')
//  else
//     TACBrCIOT( FACBrCIOT ).DACTe.ImprimirDACTePDF(nil);
end;

function TOperacoesTransporte.Insert(Index: Integer): OperacaoTransporte;
begin
  Result := OperacaoTransporte(inherited Insert(Index));
end;

procedure TOperacoesTransporte.SetItem(Index: Integer; const Value: OperacaoTransporte);
begin
  Items[Index].Assign(Value);
end;

procedure TOperacoesTransporte.Valida;
var
 i: Integer;
 FMsg : AnsiString;
begin
(*
  for i:= 0 to Self.Count-1 do
   begin
     if pos('<Signature',Self.Items[i].XML) = 0 then
        Assinar;
     if not(CTeUtil.Valida(('<CTe xmlns' +
        RetornarConteudoEntre(Self.Items[i].XML, '<CTe xmlns', '</CTe>')+ '</CTe>'),
         FMsg, Self.FConfiguracoes.Geral.PathSchemas)) then
       raise Exception.Create('Falha na validação dos dados do Conhecimento '+
                    IntToStr(Self.Items[i].CTe.Ide.nCT) +
                    sLineBreak + Self.Items[i].Alertas + FMsg);
  end;
 *)
//  for i:= 0 to Self.Count-1 do
//   begin
//     if pos('<Signature',Self.Items[i].XML) = 0 then
//        Assinar;
//     if not(CTeUtil.Valida(('<CTe xmlns' + RetornarConteudoEntre(Self.Items[i].XML, '<CTe xmlns', '</CTe>')+ '</CTe>'),
//                            FMsg, Self.FConfiguracoes.Geral.PathSchemas)) then
//      begin
//        Self.Items[i].ErroValidacaoCompleto := 'Falha na validação dos dados da nota '+
//                                               IntToStr(Self.Items[i].CTe.Ide.nCT)+sLineBreak+
//                                               Self.Items[i].Alertas+
//                                               FMsg;
//        Self.Items[i].ErroValidacao := 'Falha na validação dos dados da nota '+
//                                       IntToStr(Self.Items[i].CTe.Ide.nCT)+sLineBreak+
//                                       Self.Items[i].Alertas+
//                                       IfThen(Self.FConfiguracoes.Geral.ExibirErroSchema,FMsg,'');
//        raise Exception.Create(Self.Items[i].ErroValidacao);
//      end;
//  end;
end;

function TOperacoesTransporte.ValidaAssinatura(out Msg : String) : Boolean;
var
 i: Integer;
 FMsg : AnsiString;
begin
  Result := True;
  for i:= 0 to Self.Count-1 do
   begin
//     if not(CTeUtil.ValidaAssinatura(Self.Items[i].XMLOriginal, FMsg)) then
//      begin
        Result := False;
//        Msg := 'Falha na validação da assinatura do conhecimento '+
//                               IntToStr(Self.Items[i].CTe.Ide.nCT)+sLineBreak+FMsg
//      end
//     else
       Result := True;
  end;
end;

function TOperacoesTransporte.LoadFromFile(CaminhoArquivo: string; AGerarCTe: Boolean = True): boolean;
var
 LocCTeR : TVeiculoR;
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
            LocCTeR.Leitor.Arquivo := XML;
            LocCTeR.LerXml;
            Items[Self.Count-1].XML := LocCTeR.Leitor.Arquivo;
            Items[Self.Count-1].XMLOriginal := XMLOriginal;
            Items[Self.Count-1].NomeArq := CaminhoArquivo;
            if AGerarCTe then GerarCTe;
         finally
            LocCTeR.Free;
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

function TOperacoesTransporte.LoadFromStream(Stream: TStringStream; AGerarCTe: Boolean = True): boolean;
var
 LocCTeR : TVeiculoR;
begin
  try
    Result  := True;
//    LocCTeR := TCTeR.Create(Self.Add.CTe);
//    try
//       LocCTeR.Leitor.CarregarArquivo(Stream);
//       LocCTeR.LerXml;
//       Items[Self.Count-1].XML := LocCTeR.Leitor.Arquivo;
//       Items[Self.Count-1].XMLOriginal := Stream.DataString;
//       if AGerarCTe then GerarCTe;
//    finally
//       LocCTeR.Free
//    end;
  except
    Result := False;
  end;
end;

function TOperacoesTransporte.SaveToFile(PathArquivo: string = ''): boolean;
var
 i : integer;
 CaminhoArquivo : String;
begin
 Result := True;
 try
    for i:= 0 to TACBrCIOT( FACBrCIOT ).OperacoesTransporte.Count-1 do
     begin
        if DFeUtil.EstaVazio(PathArquivo) then
           PathArquivo := TACBrCIOT( FACBrCIOT ).Configuracoes.Geral.PathSalvar
        else
           PathArquivo := ExtractFilePath(PathArquivo);
//        CaminhoArquivo := PathWithDelim(PathArquivo)+copy(TACBrCIOT( FACBrCIOT ).OperacoesTransporte.Items[i].CTe.inFCTe.ID, (length(TACBrCIOT( FACBrCIOT ).OperacoesTransporte.Items[i].CTe.inFCTe.ID)-44)+1, 44)+'-cte.xml';
        TACBrCIOT( FACBrCIOT ).OperacoesTransporte.Items[i].SaveToFile(CaminhoArquivo)
     end;
 except
    Result := False;
 end;
end;

function TOperacoesTransporte.LoadFromString(AString: String; AGerarCTe: Boolean = True): boolean;
var
  XMLCTe: TStringStream;
begin
  try
    XMLCTe := TStringStream.Create('');
    try
      XMLCTe.WriteString(AString);
      Result := LoadFromStream(XMLCTe, AGerarCTe);
    finally
      XMLCTe.Free;
    end;
  except
    Result := False;
  end;
end;

{ TSendMailThread }

procedure TSendMailThread.DoHandleException;
begin
  // TACBrCIOT(TOperacoesTransporte(FOwner.GetOwner).ACBrCTe).SetStatus( stCTeIdle );

  // FOwner.Alertas := FException.Message;

  if FException is Exception then
    Application.ShowException(FException)
  else
    SysUtils.ShowException(FException, nil);
end;

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
