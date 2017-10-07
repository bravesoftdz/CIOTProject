{$I ACBr.inc}

unit ASCIOTWebServices;

interface

uses Classes, SysUtils,
  {$IFDEF VCL} Dialogs, {$ELSE} QDialogs, {$ENDIF}
  {$IFDEF ACBrCTeOpenSSL}
    HTTPSend,
  {$ELSE}
     SOAPHTTPTrans, WinInet, ACBrCAPICOM_TLB, SOAPConst,
  {$ENDIF}
  pcnAuxiliar, pcnConversao,
  ASCIOTConfiguracoes,

  pciotCiot, ASCIOTUtil,

  pCiotVeiculoW, pCiotVeiculoR,
  pCiotMotoristaW, pCiotMotoristaR,
  pCiotProprietarioW, pCiotProprietarioR,
  pCiotOperacaoTransporteW, pCiotOperacaoTransporteR,

  ActiveX;

type

  TWebServicesBase = Class
  private
  	procedure DoVeiculo(AOperacao: TpciotOperacao);
    procedure DoMotorista(AOperacao: TpciotOperacao);
    procedure DoProprietario(AOperacao: TpciotOperacao);
    procedure DoOperacaoTransporte(AOperacao: TpciotOperacao);

    {$IFDEF ACBrCTeOpenSSL}
       procedure ConfiguraHTTP( HTTP : THTTPSend; Action : AnsiString);
    {$ELSE}
       procedure ConfiguraReqResp( ReqResp : THTTPReqResp);
       procedure OnBeforePost(const HTTPReqResp: THTTPReqResp; Data:Pointer);
    {$ENDIF}
  protected
    FCabMsg: AnsiString;
    FDadosMsg: AnsiString;
    FRetornoWS: AnsiString;
    FRetWS: AnsiString;
    FMsg: AnsiString;
    FURL: WideString;
    FConfiguracoes: TConfiguracoes;
    FAmSCIOT : TComponent;
    FPathArqResp: AnsiString;
    FPathArqEnv: AnsiString;

    procedure LoadMsgEntrada(AOperacao: TpciotOperacao; ALayout: Integer = 0);
    procedure LoadURL;
  public
    constructor Create(AOwner : TComponent); virtual;
    function Obter: Boolean; virtual;
    function Adicionar: Boolean; virtual;

    property CabMsg: AnsiString read FCabMsg;
    property DadosMsg: AnsiString read FDadosMsg;
    property RetornoWS: AnsiString read FRetornoWS;
    property RetWS: AnsiString read FRetWS;
    property Msg: AnsiString read FMsg;
    property PathArqEnv: AnsiString read FPathArqEnv;
    property PathArqResp: AnsiString read FPathArqResp;
  end;

  TCIOTVeiculo = Class(TWebServicesBase)
  private
    FVeiculo: TVeiculo;
    FSucesso: Boolean;
    FMensagem: String;

    function Obter: Boolean; overload; override;
  public
    constructor Create(AOwner : TComponent);reintroduce;
    destructor destroy; override;
    procedure Clear;

    function Obter(APlaca: string; ARNTRC: string): Boolean; overload;
    function Adicionar: Boolean; overload; override;

    property Sucesso: Boolean read FSucesso;
    property Mensagem: String read FMensagem;
    property Veiculo: TVeiculo read FVeiculo write FVeiculo;
  end;

  TCIOTMotorista = Class(TWebServicesBase)
  private
    FSucesso: Boolean;
    FMensagem: String;
    FRetMotorista : TMotoristaR;
    FMotorista: TMotorista;

    function Obter: Boolean; overload; override;
  public
    constructor Create(AOwner : TComponent);reintroduce;
    destructor Destroy; override;
    procedure Clear;

    function Obter(ACPF, ACNH: string): Boolean; overload;
    function Adicionar: Boolean; overload; override;

    property Sucesso: Boolean read FSucesso;
    property Mensagem: String read FMensagem;
    property RetMotorista: TMotoristaR read FRetMotorista;
    property Motorista: TMotorista read FMotorista write FMotorista;
  end;

  TCIOTProprietario = Class(TWebServicesBase)
  private
    FSucesso: Boolean;
    FMensagem: String;
    FRetProprietario : TProprietarioR;
    FProprietario: TProprietario;

    procedure SetJustificativa(AValue: WideString);

    function Obter: Boolean; overload; override;
  public
    constructor Create(AOwner : TComponent);reintroduce;
    destructor Destroy; override;
    procedure Clear;

    function Obter(ACNPJ: string; ARNTRC: string): Boolean; overload;
    function Adicionar: Boolean; overload; override;

    property Sucesso: Boolean read FSucesso;
    property Mensagem: String read FMensagem;
    property RetProprietario: TProprietarioR read FRetProprietario;
    property Proprietario: TProprietario read FProprietario write FProprietario;
  end;

  TCIOTOperacaoTransporte = Class(TWebServicesBase)
  private
    FSucesso: Boolean;
    FMensagem: String;
    FOperacoesTransporte : TOperacoesTransporte;
    FRetOperacaoTransporte: TOperacaoTransporteR;
    FTipoImpressao: TpciotTipoImpressao;

    function Obter: Boolean; override;
  public
    constructor Create(AOwner : TComponent);reintroduce;
    destructor Destroy; override;
    procedure Clear;

    function Adicionar: Boolean; overload; override;
    function ObterPDF(ANroCIOT: string; ATipoImpressao: TpciotTipoImpressao = tiPDF; AImprimir: Boolean = True): Boolean;
    function Retificar: Boolean;
    function Cancelar(ANumeroCIOT, AMotivo: string): Boolean;
    procedure Imprimir;

    function AdicionarViagens: Boolean;
    function AdicionarPagamento: Boolean;
    function CancelarPagamento(AIdPagamento, AMotivo: string): Boolean;
    function Encerrar: Boolean;

    property OperacoesTransporte: TOperacoesTransporte read FOperacoesTransporte write FOperacoesTransporte;
    property Sucesso: Boolean read FSucesso;
    property Mensagem: String read FMensagem;
    property RetOperacaoTransporte: TOperacaoTransporteR read FRetOperacaoTransporte;
  end;

  TWebServices = Class(TWebServicesBase)
  private
    FACBrCIOT: TComponent;

    FVeiculo: TCIOTVeiculo;
    FProprietario: TCIOTProprietario;
    FMotorista: TCIOTMotorista;
    FOperacaoTransporte: TCIOTOperacaoTransporte;
  public
    constructor Create(AFCIOT: TComponent = nil);reintroduce;
    destructor Destroy; override;
//  published
    property ACBrCIOT: TComponent read FACBrCIOT write FACBrCIOT;

    property Veiculo: TCIOTVeiculo read FVeiculo write FVeiculo;
    property Proprietario: TCIOTProprietario read FProprietario write FProprietario;
    property Motorista: TCIOTMotorista read FMotorista write FMotorista;
    property OperacaoTransporte: TCIOTOperacaoTransporte read FOperacaoTransporte write FOperacaoTransporte;
  end;

implementation

uses {$IFDEF ACBrCTeOpenSSL}
        ssl_openssl,
     {$ENDIF}
     ACBrUtil, ASCIOT, ACBrDFeUtil,
     pcnGerador, pcnCabecalho, pcnLeitor;

{$IFNDEF ACBrCTeOpenSSL}
const
  INTERNET_OPTION_CLIENT_CERT_CONTEXT = 84;
{$ENDIF}

{ TWebServicesBase }
constructor TWebServicesBase.Create(AOwner: TComponent);
begin
  FConfiguracoes := TConfiguracoes( TAmSCIOT( AOwner ).Configuracoes );
  FAmsCIOT       := TAmSCIOT( AOwner );
end;

{$IFDEF ACBrCTeOpenSSL}
procedure TWebServicesBase.ConfiguraHTTP( HTTP : THTTPSend; Action : AnsiString);
begin
  if FileExists(FConfiguracoes.Certificados.Certificado) then
    HTTP.Sock.SSL.PFXfile := FConfiguracoes.Certificados.Certificado
  else
    HTTP.Sock.SSL.PFX     := FConfiguracoes.Certificados.Certificado;

  HTTP.Sock.SSL.KeyPassword := FConfiguracoes.Certificados.Senha;

  HTTP.ProxyHost := FConfiguracoes.WebServices.ProxyHost;
  HTTP.ProxyPort := FConfiguracoes.WebServices.ProxyPort;
  HTTP.ProxyUser := FConfiguracoes.WebServices.ProxyUser;
  HTTP.ProxyPass := FConfiguracoes.WebServices.ProxyPass;

  // Linha abaixo comentada por Italo em 08/09/2010
//  HTTP.Sock.RaiseExcept := True;

  HTTP.MimeType  := 'text/xml; charset=utf-8';
  HTTP.UserAgent := '';
  HTTP.Protocol  := '1.1';

  HTTP.AddPortNumberToHost := False;
  HTTP.Headers.Add(Action);
end;

{$ELSE}
function TWebServicesBase.Adicionar: Boolean;
begin
  Result   := False;

  if FConfiguracoes.Certificados.NumeroSerie = '' then
    FConfiguracoes.Certificados.NumeroSerie := FConfiguracoes.Certificados.SelecionarCertificado;

  LoadMsgEntrada(opAdicionar);
  LoadURL;
end;

procedure TWebServicesBase.ConfiguraReqResp( ReqResp : THTTPReqResp);
begin
  if FConfiguracoes.WebServices.ProxyHost <> '' then
   begin
     ReqResp.Proxy    := FConfiguracoes.WebServices.ProxyHost+':'+FConfiguracoes.WebServices.ProxyPort;
     ReqResp.UserName := FConfiguracoes.WebServices.ProxyUser;
     ReqResp.Password := FConfiguracoes.WebServices.ProxyPass;
   end;
  ReqResp.OnBeforePost := OnBeforePost;
end;

function TWebServicesBase.Obter: Boolean;
begin
  Result   := False;

  if FConfiguracoes.Certificados.NumeroSerie = '' then
    FConfiguracoes.Certificados.NumeroSerie := FConfiguracoes.Certificados.SelecionarCertificado;

  LoadMsgEntrada(opObter);
  LoadURL;
end;

procedure TWebServicesBase.OnBeforePost(const HTTPReqResp: THTTPReqResp;
  Data: Pointer);
var
  Cert         : ICertificate2;
  CertContext  : ICertContext;
  PCertContext : Pointer;
  ContentHeader: string;
begin
  Cert        := FConfiguracoes.Certificados.GetCertificado;
  CertContext :=  Cert as ICertContext;
  CertContext.Get_CertContext(Integer(PCertContext));

  if not InternetSetOption(Data, INTERNET_OPTION_CLIENT_CERT_CONTEXT, PCertContext,SizeOf(CertContext)*5) then
   begin
     if Assigned(TAmSCIOT( FAmsCIOT ).OnGerarLog) then
        TAmSCIOT( FAmsCIOT ).OnGerarLog('ERRO: Erro OnBeforePost: ' + IntToStr(GetLastError));
     raise Exception.Create( 'Erro OnBeforePost: ' + IntToStr(GetLastError) );
   end;

   if trim(FConfiguracoes.WebServices.ProxyUser) <> '' then begin
     if not InternetSetOption(Data, INTERNET_OPTION_PROXY_USERNAME, PChar(FConfiguracoes.WebServices.ProxyUser), Length(FConfiguracoes.WebServices.ProxyUser)) then
       raise Exception.Create( 'Erro OnBeforePost: ' + IntToStr(GetLastError) );
   end;
   if trim(FConfiguracoes.WebServices.ProxyPass) <> '' then begin
     if not InternetSetOption(Data, INTERNET_OPTION_PROXY_PASSWORD, PChar(FConfiguracoes.WebServices.ProxyPass),Length (FConfiguracoes.WebServices.ProxyPass)) then
       raise Exception.Create( 'Erro OnBeforePost: ' + IntToStr(GetLastError) );
   end;

  ContentHeader := Format(ContentTypeTemplate, ['application/soap+xml; charset=utf-8']);
  HttpAddRequestHeaders(Data, PChar(ContentHeader), Length(ContentHeader), HTTP_ADDREQ_FLAG_REPLACE);
end;
{$ENDIF}

procedure TWebServicesBase.DoProprietario(AOperacao: TpciotOperacao);
var
  ProprietarioW: TProprietarioW;
begin
  ProprietarioW := TProprietarioW.Create(TCIOTProprietario(Self).FProprietario, AOperacao);
  ProprietarioW.GerarXML;

  FDadosMsg := ProprietarioW.Gerador.ArquivoFormatoXML;
  ProprietarioW.Free;
end;

procedure TWebServicesBase.DoMotorista(AOperacao: TpciotOperacao);
var
  MotoristaW: TMotoristaW;
begin
  MotoristaW := TMotoristaW.Create(TCIOTMotorista(Self).FMotorista, AOperacao);
  MotoristaW.GerarXML;

  FDadosMsg := MotoristaW.Gerador.ArquivoFormatoXML;
  MotoristaW.Free;
end;

procedure TWebServicesBase.DoVeiculo(AOperacao: TpciotOperacao);
var
  VeiculoW: TVeiculoW;
begin
  VeiculoW := TVeiculoW.Create(TCIOTVeiculo(Self).FVeiculo, AOperacao);
  VeiculoW.GerarXML;

  FDadosMsg := VeiculoW.Gerador.ArquivoFormatoXML;
  VeiculoW.Free;
end;

procedure TWebServicesBase.DoOperacaoTransporte(AOperacao: TpciotOperacao);
var
  OperacaoTransporteW: TOperacaoTransporteW;
begin
  OperacaoTransporteW := TOperacaoTransporteW.Create(TCIOTOperacaoTransporte(Self).FOperacoesTransporte.Items[0], AOperacao);
  OperacaoTransporteW.GerarXML;

  FDadosMsg := OperacaoTransporteW.Gerador.ArquivoFormatoXML;
  OperacaoTransporteW.Free;
end;

procedure TWebServicesBase.LoadMsgEntrada(AOperacao: TpciotOperacao; ALayout: Integer = 0);
begin
  if (self is TCIOTVeiculo) then
    DoVeiculo(AOperacao)
  else if (self is TCIOTOperacaoTransporte) then
    DoOperacaoTransporte(AOperacao)
  else if (self is TCIOTProprietario) then
    DoProprietario(AOperacao)
  else if (self is TCIOTMotorista) then
    DoMotorista(AOperacao)
end;

procedure TWebServicesBase.LoadURL;
begin
  if (self is TCIOTVeiculo) then
    FURL := CIOTUtil.GetURL(FConfiguracoes.Integradora.Tecnologia, FConfiguracoes.WebServices.AmbienteCodigo, LayVeiculo)
  else if (self is TCIOTProprietario) then
    FURL := CIOTUtil.GetURL(FConfiguracoes.Integradora.Tecnologia, FConfiguracoes.WebServices.AmbienteCodigo, LayProprietario)
  else if (self is TCIOTOperacaoTransporte) then
    FURL := CIOTUtil.GetURL(FConfiguracoes.Integradora.Tecnologia, FConfiguracoes.WebServices.AmbienteCodigo, LayOperacaoTransporte)
  else if (self is TCIOTMotorista) then
    FURL := CIOTUtil.GetURL(FConfiguracoes.Integradora.Tecnologia, FConfiguracoes.WebServices.AmbienteCodigo, LayMotorista);
end;

{ TWebServices }
constructor TWebServices.Create(AFCIOT: TComponent);
begin
 inherited Create( AFCIOT );
  FACBrCIOT          := TAmSCIOT(AFCIOT);

  FVeiculo := TCIOTVeiculo.create(AFCIOT);
  FProprietario := TCIOTProprietario.Create(AFCIOT);
  FMotorista := TCIOTMotorista.Create(AFCIOT);
  FOperacaoTransporte := TCIOTOperacaoTransporte.Create(AFCIOT);
end;

destructor TWebServices.Destroy;
begin
  FVeiculo.Free;
  FProprietario.Free;
  FMotorista.Free;
  FOperacaoTransporte.Free;
  inherited;
end;


{ TCTeRecepcao }

function TCIOTVeiculo.Adicionar: Boolean;
var
  CIOTRetorno: TVeiculoR;
  aMsg  : string;
  Texto : String;
  Acao  : TStringList;
  Stream: TMemoryStream;
  StrStream: TStringStream;

  {$IFDEF ACBrCTeOpenSSL}
     HTTP: THTTPSend;
  {$ELSE}
     ReqResp: THTTPReqResp;
  {$ENDIF}
begin
  inherited Adicionar;

  Result := False;

  Acao   := TStringList.Create;
  Stream := TMemoryStream.Create;

  Texto := '<?xml version="1.0" encoding="utf-8"?>';
  Texto := Texto + '<soap12:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap12="http://www.w3.org/2003/05/soap-envelope">';
  Texto := Texto +   '<soap12:Body>';
  Texto := Texto +   '  <Gravar xmlns="http://schemas.ipc.adm.br/efrete/veiculos">';
  Texto := Texto + FDadosMsg;
  Texto := Texto +   '  </Gravar>';
  Texto := Texto +   '</soap12:Body>';
  Texto := Texto + '</soap12:Envelope>';

  Acao.Text := Texto;

  {$IFDEF ACBrCTeOpenSSL}
     Acao.SaveToStream(Stream);
     HTTP := THTTPSend.Create;
  {$ELSE}
     ReqResp := THTTPReqResp.Create(nil);
     ConfiguraReqResp( ReqResp );
     ReqResp.URL := Trim(FURL);
     ReqResp.UseUTF8InHeader := True;
     ReqResp.SoapAction := 'http://schemas.ipc.adm.br/efrete/veiculos/Gravar';
  {$ENDIF}

  try
    TAmSCIOT( FAmsCIOT ).SetStatus( stCIOTObtendo );
    if FConfiguracoes.Geral.Salvar then
     begin
       FPathArqEnv := FormatDateTime('yyyymmddhhnnss',Now)+'-adicionar-veiculo.xml';
       FConfiguracoes.Geral.Save(FPathArqEnv, FDadosMsg, FConfiguracoes.Arquivos.PathLog);
     end;

    try
      {$IFDEF ACBrCTeOpenSSL}
         HTTP.Document.LoadFromStream(Stream);
         ConfiguraHTTP(HTTP,'SOAPAction: "http://schemas.ipc.adm.br/efrete/veiculos/Gravar"');
         HTTP.HTTPMethod('POST', FURL);
         StrStream := TStringStream.Create('') ;
         StrStream.CopyFrom(HTTP.Document, 0);

         FRetornoWS := TiraAcentos(ParseText(StrStream.DataString, True));
         FRetWS := SeparaDados( FRetornoWS, 'GravarResponse');
         StrStream.Free;
      {$ELSE}
         ReqResp.Execute(Acao.Text, Stream);
         StrStream := TStringStream.Create('');
         StrStream.CopyFrom(Stream, 0);
         FRetornoWS := TiraAcentos(ParseText(StrStream.DataString, True));
         FRetWS := SeparaDados( FRetornoWS, 'GravarResponse');
         StrStream.Free;
      {$ENDIF}

      CIOTRetorno := TVeiculoR.Create(FVeiculo, opAdicionar);
      CIOTRetorno.Leitor.Arquivo := FRetWS;
      CIOTRetorno.LerXml;

      TAmSCIOT( FAmSCIOT ).SetStatus( stCIOTIdle );
      aMsg := 'Placa : '+CIOTRetorno.Veiculo.Placa+LineBreak+
              'Ano Modelo : '+IntToStr(CIOTRetorno.Veiculo.AnoModelo)+LineBreak+
              'Ano Fabricacao : '+IntToStr(CIOTRetorno.Veiculo.AnoFabricacao)+LineBreak +
              'Sucesso : '+BoolToStr(CIOTRetorno.Sucesso)+LineBreak+
              'Mensagem : '+CIOTRetorno.Mensagem+LineBreak;

      if FConfiguracoes.WebServices.Visualizar then
        ShowMessage(aMsg);

      if Assigned(TAmSCIOT( FAmSCIOT ).OnGerarLog) then
         TAmSCIOT( FAmSCIOT ).OnGerarLog(aMsg);

      FMsg   := LineBreak+CIOTRetorno.Mensagem;
      Result := (CIOTRetorno.Sucesso);

      FSucesso := CIOTRetorno.Sucesso;
      FMensagem := CIOTRetorno.Mensagem;

      CIOTRetorno.Free;

      if FConfiguracoes.Geral.Salvar then
       begin
         FPathArqResp := FormatDateTime('yyyymmddhhnnss',Now)+'-response-Addveiculos.xml';
         FConfiguracoes.Geral.Save(FPathArqResp, FRetWS);
       end;

    except on E: Exception do
      begin
       if Assigned(TAmSCIOT( FAmSCIOT ).OnGerarLog) then
          TAmSCIOT( FAmSCIOT ).OnGerarLog('WebService Veiculos (Inclusao):'+LineBreak+
                                          '- Inativo ou Inoperante tente novamente.'+LineBreak+
                              '- '+FMensagem + LineBreak +
                              '- '+E.Message);
       raise Exception.Create('WebService Veiculos (Inclusao):'+LineBreak+
                              '- Inativo ou Inoperante tente novamente.'+LineBreak+
                              '- '+FMensagem + LineBreak +
                              '- '+E.Message);
      end;
    end;

  finally
    {$IFDEF ACBrCTeOpenSSL}
       HTTP.Free;
    {$ELSE}
      ReqResp.Free;
    {$ENDIF}
    Acao.Free;
    Stream.Free;
    DFeUtil.ConfAmbiente;
    TAmSCIOT( FAmSCIOT ).SetStatus( stCIOTIdle );
  end;
end;

procedure TCIOTVeiculo.Clear;
begin
  FMensagem := '';
  FSucesso := False;

//  if Assigned(FVeiculo) then FVeiculo.Free;
end;

constructor TCIOTVeiculo.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FVeiculo := TVeiculo.Create(AOwner);
end;

destructor TCIOTVeiculo.destroy;
begin
  FVeiculo.Free;
  inherited;
end;

function TCIOTVeiculo.Obter(APlaca: string; ARNTRC: string): Boolean;
begin
  Clear;

  FVeiculo := TVeiculo.Create(FAmSCIOT);
  FVeiculo.Placa := APlaca;
  FVeiculo.RNTRC := ARNTRC;

  Self.Obter;

  result := Self.Sucesso;
end;

function TCIOTVeiculo.Obter: Boolean;
var
  CIOTRetorno: TVeiculoR;
  aMsg  : string;
  Texto : String;
  Acao  : TStringList;
  Stream: TMemoryStream;
  StrStream: TStringStream;

  {$IFDEF ACBrCTeOpenSSL}
     HTTP: THTTPSend;
  {$ELSE}
     ReqResp: THTTPReqResp;
  {$ENDIF}
begin
  inherited Obter;

  Result := False;

  Acao   := TStringList.Create;
  Stream := TMemoryStream.Create;

  Texto := '<?xml version="1.0" encoding="utf-8"?>';
  Texto := Texto + '<soap12:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap12="http://www.w3.org/2003/05/soap-envelope">';
  Texto := Texto +   '<soap12:Body>';
  Texto := Texto +   '  <ObterPorPlaca xmlns="http://schemas.ipc.adm.br/efrete/veiculos">';
  Texto := Texto + FDadosMsg;
  Texto := Texto +   '  </ObterPorPlaca>';
  Texto := Texto +   '</soap12:Body>';
  Texto := Texto + '</soap12:Envelope>';

  Acao.Text := Texto;

  {$IFDEF ACBrCTeOpenSSL}
     Acao.SaveToStream(Stream);
     HTTP := THTTPSend.Create;
  {$ELSE}
     ReqResp := THTTPReqResp.Create(nil);
     ConfiguraReqResp( ReqResp );
     ReqResp.URL := Trim(FURL);
     ReqResp.UseUTF8InHeader := True;
     ReqResp.SoapAction := 'http://schemas.ipc.adm.br/efrete/veiculos/ObterPorPlaca';
  {$ENDIF}

  try
    TAmSCIOT( FAmSCIOT ).SetStatus( stCIOTObtendo );
    if FConfiguracoes.Geral.Salvar then
     begin
       FPathArqEnv := FormatDateTime('yyyymmddhhnnss',Now)+'-obter-veiculo.xml';
       FConfiguracoes.Geral.Save(FPathArqEnv, FDadosMsg, FConfiguracoes.Arquivos.PathLog);
     end;

    try
      {$IFDEF ACBrCTeOpenSSL}
         HTTP.Document.LoadFromStream(Stream);
         ConfiguraHTTP(HTTP,'SOAPAction: "http://schemas.ipc.adm.br/efrete/veiculos/ObterPorPlaca"');
         HTTP.HTTPMethod('POST', FURL);
         StrStream := TStringStream.Create('') ;
         StrStream.CopyFrom(HTTP.Document, 0);

         FRetornoWS := TiraAcentos(ParseText(StrStream.DataString, True));
         FRetWS := SeparaDados( FRetornoWS, 'ObterPorPlacaResponse');
         StrStream.Free;
      {$ELSE}
         ReqResp.Execute(Acao.Text, Stream);
         StrStream := TStringStream.Create('');
         StrStream.CopyFrom(Stream, 0);
         FRetornoWS := TiraAcentos(ParseText(StrStream.DataString, True));
         FRetWS := SeparaDados( FRetornoWS, 'ObterPorPlacaResponse');
         StrStream.Free;
      {$ENDIF}

      CIOTRetorno := TVeiculoR.Create(FVeiculo);
      CIOTRetorno.Leitor.Arquivo := FRetWS;
      CIOTRetorno.LerXml;

      TAmSCIOT( FAmSCIOT ).SetStatus( stCIOTIdle );
      aMsg := 'Placa : '+CIOTRetorno.Veiculo.Placa+LineBreak+
              'Ano Modelo : '+IntToStr(CIOTRetorno.Veiculo.AnoModelo)+LineBreak+
              'Ano Fabricacao : '+IntToStr(CIOTRetorno.Veiculo.AnoFabricacao)+LineBreak +
              'Sucesso : '+BoolToStr(CIOTRetorno.Sucesso)+LineBreak+
              'Mensagem : '+CIOTRetorno.Mensagem+LineBreak;

      if FConfiguracoes.WebServices.Visualizar then
        ShowMessage(aMsg);

      if Assigned(TAmSCIOT( FAmSCIOT ).OnGerarLog) then
         TAmSCIOT( FAmSCIOT ).OnGerarLog(aMsg);

      FMsg   := LineBreak+CIOTRetorno.Mensagem;
      Result := (CIOTRetorno.Sucesso);

      FSucesso := CIOTRetorno.Sucesso;
      FMensagem := CIOTRetorno.Mensagem;

      CIOTRetorno.Free;

      if FConfiguracoes.Geral.Salvar then
       begin
         FPathArqResp := FormatDateTime('yyyymmddhhnnss',Now)+'-response-veiculos.xml';
         FConfiguracoes.Geral.Save(FPathArqResp, FRetWS);
       end;

    except on E: Exception do
      begin

       if Assigned(TAmSCIOT( FAmSCIOT ).OnGerarLog) then
          TAmSCIOT( FAmSCIOT ).OnGerarLog('WebService Veiculos:'+LineBreak+
                                          '- Inativo ou Inoperante tente novamente.'+LineBreak+
                              '- '+FMensagem + LineBreak +
                              '- '+E.Message);
       raise Exception.Create('WebService Veiculos:'+LineBreak+
                              '- Inativo ou Inoperante tente novamente.'+LineBreak+
                              '- '+FMensagem + LineBreak +
                              '- '+E.Message);
      end;
    end;

  finally
    {$IFDEF ACBrCTeOpenSSL}
       HTTP.Free;
    {$ELSE}
      ReqResp.Free;
    {$ENDIF}
    Acao.Free;
    Stream.Free;
    DFeUtil.ConfAmbiente;
    TAmSCIOT( FAmSCIOT ).SetStatus( stCIOTIdle );
  end;
end;


{ TCIOTProprietario }


function TCIOTProprietario.Adicionar: Boolean;
var
  CIOTRetorno: TProprietarioR;
  aMsg  : string;
  Texto : String;
  Acao  : TStringList;
  Stream: TMemoryStream;
  StrStream: TStringStream;

  {$IFDEF ACBrCTeOpenSSL}
     HTTP: THTTPSend;
  {$ELSE}
     ReqResp: THTTPReqResp;
  {$ENDIF}
begin
  inherited Adicionar;

  Result := False;

  Acao   := TStringList.Create;
  Stream := TMemoryStream.Create;

  Texto := '<?xml version="1.0" encoding="utf-8"?>';
  Texto := Texto + '<soap12:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap12="http://www.w3.org/2003/05/soap-envelope">';
  Texto := Texto +   '<soap12:Body>';
  Texto := Texto +   '  <Gravar xmlns="http://schemas.ipc.adm.br/efrete/proprietarios">';
  Texto := Texto + FDadosMsg;
  Texto := Texto +   '  </Gravar>';
  Texto := Texto +   '</soap12:Body>';
  Texto := Texto + '</soap12:Envelope>';

  Acao.Text := Texto;

  {$IFDEF ACBrCTeOpenSSL}
     Acao.SaveToStream(Stream);
     HTTP := THTTPSend.Create;
  {$ELSE}
     ReqResp := THTTPReqResp.Create(nil);
     ConfiguraReqResp( ReqResp );
     ReqResp.URL := Trim(FURL);
     ReqResp.UseUTF8InHeader := True;
     ReqResp.SoapAction := 'http://schemas.ipc.adm.br/efrete/proprietarios/Gravar';
  {$ENDIF}

  try
    TAmSCIOT( FAmSCIOT ).SetStatus( stCIOTObtendo );
    if FConfiguracoes.Geral.Salvar then
     begin
       FPathArqEnv := FormatDateTime('yyyymmddhhnnss',Now)+'-adicionar-Proprietario.xml';
       FConfiguracoes.Geral.Save(FPathArqEnv, FDadosMsg, FConfiguracoes.Arquivos.PathLog);
     end;

    try
      {$IFDEF ACBrCTeOpenSSL}
         HTTP.Document.LoadFromStream(Stream);
         ConfiguraHTTP(HTTP,'SOAPAction: "http://schemas.ipc.adm.br/efrete/proprietarios/Gravar"');
         HTTP.HTTPMethod('POST', FURL);
         StrStream := TStringStream.Create('') ;
         StrStream.CopyFrom(HTTP.Document, 0);

         FRetornoWS := TiraAcentos(ParseText(StrStream.DataString, True));
         FRetWS := SeparaDados( FRetornoWS, 'GravarResponse');
         StrStream.Free;
      {$ELSE}
         ReqResp.Execute(Acao.Text, Stream);
         StrStream := TStringStream.Create('');
         StrStream.CopyFrom(Stream, 0);
         FRetornoWS := TiraAcentos(ParseText(StrStream.DataString, True));
         FRetWS := SeparaDados( FRetornoWS, 'GravarResponse');
         StrStream.Free;
      {$ENDIF}

      CIOTRetorno := TProprietarioR.Create(FProprietario, opAdicionar);
      CIOTRetorno.Leitor.Arquivo := FRetWS;
      CIOTRetorno.LerXml;

      TAmSCIOT( FAmSCIOT ).SetStatus( stCIOTIdle );
      aMsg := 'CNPJ : '+CIOTRetorno.Proprietario.CNPJ+LineBreak+
              'RazaoSocial : '+CIOTRetorno.Proprietario.RazaoSocial+LineBreak+
              'Proprietario.Endereco.Rua : '+CIOTRetorno.Proprietario.Endereco.Rua+LineBreak +
              'Sucesso : '+BoolToStr(CIOTRetorno.Sucesso)+LineBreak+
              'Mensagem : '+CIOTRetorno.Mensagem+LineBreak;

      if FConfiguracoes.WebServices.Visualizar then
        ShowMessage(aMsg);

      if Assigned(TAmSCIOT( FAmSCIOT ).OnGerarLog) then
         TAmSCIOT( FAmSCIOT ).OnGerarLog(aMsg);

      FMsg   := LineBreak+CIOTRetorno.Mensagem;
      Result := (CIOTRetorno.Sucesso);

      FSucesso := CIOTRetorno.Sucesso;
      FMensagem := CIOTRetorno.Mensagem;

      CIOTRetorno.Free;

      if FConfiguracoes.Geral.Salvar then
       begin
         FPathArqResp := FormatDateTime('yyyymmddhhnnss',Now)+'-response-AddProprietario.xml';
         FConfiguracoes.Geral.Save(FPathArqResp, FRetWS, FConfiguracoes.Arquivos.PathLog);
       end;

    except on E: Exception do
      begin
       if Assigned(TAmSCIOT( FAmSCIOT ).OnGerarLog) then
          TAmSCIOT( FAmSCIOT ).OnGerarLog('WebService Proprietario (Inclusao):'+LineBreak+
                                          '- Inativo ou Inoperante tente novamente.'+LineBreak+
                              '- '+FMensagem + LineBreak +
                              '- '+E.Message);
       raise Exception.Create('WebService Proprietario (Inclusao):'+LineBreak+
                              '- Inativo ou Inoperante tente novamente.'+LineBreak+
                              '- '+FMensagem + LineBreak +
                              '- '+E.Message);
      end;
    end;

  finally
    {$IFDEF ACBrCTeOpenSSL}
       HTTP.Free;
    {$ELSE}
      ReqResp.Free;
    {$ENDIF}
    Acao.Free;
    Stream.Free;
    DFeUtil.ConfAmbiente;
    TAmSCIOT( FAmSCIOT ).SetStatus( stCIOTIdle );
  end;
end;

procedure TCIOTProprietario.Clear;
begin
  FMensagem := '';
  FSucesso  := False;
end;

constructor TCIOTProprietario.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FProprietario := TProprietario.Create(AOwner);
end;

destructor TCIOTProprietario.Destroy;
begin
  FProprietario.Free;
  inherited;
end;

function TCIOTProprietario.Obter(ACNPJ: string; ARNTRC: string): Boolean;
begin
  Clear;

  FProprietario := TProprietario.Create(FAmSCIOT);
  FProprietario.CNPJ := ACNPJ;
  FProprietario.RNTRC := ARNTRC;

  Obter;

  result := Self.Sucesso;
end;

function TCIOTProprietario.Obter: Boolean;
var
  aMsg  : string;
  Texto : String;
  Acao  : TStringList;
  Stream: TMemoryStream;
  StrStream: TStringStream;

  {$IFDEF ACBrCTeOpenSSL}
     HTTP: THTTPSend;
  {$ELSE}
     ReqResp: THTTPReqResp;
  {$ENDIF}
begin
  inherited Obter;

  Result := False;

  Acao   := TStringList.Create;
  Stream := TMemoryStream.Create;
  FSucesso := False;

  Texto := '<?xml version="1.0" encoding="utf-8"?>';
  Texto := Texto + '<soap12:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap12="http://www.w3.org/2003/05/soap-envelope">';
  Texto := Texto +   '<soap12:Body>';
  Texto := Texto +   '  <Obter xmlns="http://schemas.ipc.adm.br/efrete/proprietarios">';
  Texto := Texto + FDadosMsg;
  Texto := Texto +   '  </Obter>';
  Texto := Texto +   '</soap12:Body>';
  Texto := Texto + '</soap12:Envelope>';

  Acao.Text := Texto;

  {$IFDEF ACBrCTeOpenSSL}
     Acao.SaveToStream(Stream);
     HTTP := THTTPSend.Create;
  {$ELSE}
     ReqResp := THTTPReqResp.Create(nil);
     ConfiguraReqResp( ReqResp );
     ReqResp.URL := Trim(FURL);
     ReqResp.UseUTF8InHeader := True;
     ReqResp.SoapAction := 'http://schemas.ipc.adm.br/efrete/proprietarios/Obter';
  {$ENDIF}

  try
    TAmSCIOT( FAmSCIOT ).SetStatus( stCIOTObtendo );
    if FConfiguracoes.Geral.Salvar then
     begin
       FPathArqEnv := FormatDateTime('yyyymmddhhnnss',Now)+'-obter-proprietarios.xml';
       FConfiguracoes.Geral.Save(FPathArqEnv, FDadosMsg, FConfiguracoes.Arquivos.PathLog);
     end;

    try
      {$IFDEF ACBrCTeOpenSSL}
         HTTP.Document.LoadFromStream(Stream);
         ConfiguraHTTP(HTTP,'SOAPAction: "http://schemas.ipc.adm.br/efrete/proprietarios/Obter"');
         HTTP.HTTPMethod('POST', FURL);
         StrStream := TStringStream.Create('') ;
         StrStream.CopyFrom(HTTP.Document, 0);

         FRetornoWS := TiraAcentos(ParseText(StrStream.DataString, True));
         FRetWS := SeparaDados( FRetornoWS, 'ObterResponse');
         StrStream.Free;
      {$ELSE}
         ReqResp.Execute(Acao.Text, Stream);
         StrStream := TStringStream.Create('');
         StrStream.CopyFrom(Stream, 0);
         FRetornoWS := TiraAcentos(ParseText(StrStream.DataString, True));
         FRetWS := SeparaDados( FRetornoWS, 'ObterResponse');
         StrStream.Free;
      {$ENDIF}

      FRetProprietario := TProprietarioR.Create(FProprietario);
      FRetProprietario.Leitor.Arquivo := FRetWS;
      FRetProprietario.LerXml;

      TAmSCIOT( FAmSCIOT ).SetStatus( stCIOTIdle );
      aMsg := 'CPF : '+FProprietario.CNPJ+LineBreak+
              'CNH : '+FProprietario.RNTRC+LineBreak+
              'Nome : '+FProprietario.RazaoSocial+LineBreak +
              'Sucesso : '+BoolToStr(FRetProprietario.Sucesso)+LineBreak+
              'Mensagem : '+FRetProprietario.Mensagem+LineBreak;

      if FConfiguracoes.WebServices.Visualizar then
        ShowMessage(aMsg);

      if Assigned(TAmSCIOT( FAmSCIOT ).OnGerarLog) then
         TAmSCIOT( FAmSCIOT ).OnGerarLog(aMsg);

      FMsg   := LineBreak+FRetProprietario.Mensagem;
      Result := FRetProprietario.Sucesso;

      FRetProprietario.Free;

      if FConfiguracoes.Geral.Salvar then
       begin
         FPathArqResp := FormatDateTime('yyyymmddhhnnss',Now)+'-response-proprietarios.xml';
         FConfiguracoes.Geral.Save(FPathArqResp, FRetWS, FConfiguracoes.Arquivos.PathLog);
       end;

    except on E: Exception do
      begin
       if Assigned(TAmSCIOT( FAmSCIOT ).OnGerarLog) then
          TAmSCIOT( FAmSCIOT ).OnGerarLog('WebService Proprietario:'+LineBreak+
                                          '- Inativo ou Inoperante tente novamente.'+LineBreak+
                              '- '+FMensagem + LineBreak +
                              '- '+E.Message);
       raise Exception.Create('WebService Proprietario:'+LineBreak+
                              '- Inativo ou Inoperante tente novamente.'+LineBreak+
                              '- '+FMensagem + LineBreak +
                              '- '+E.Message);
      end;
    end;

  finally
    {$IFDEF ACBrCTeOpenSSL}
       HTTP.Free;
    {$ELSE}
      ReqResp.Free;
    {$ENDIF}
    Acao.Free;
    Stream.Free;
    DFeUtil.ConfAmbiente;
    TAmSCIOT( FAmSCIOT ).SetStatus( stCIOTIdle );
  end;
end;

procedure TCIOTProprietario.SetJustificativa(AValue: WideString);
begin
  if DFeUtil.EstaVazio(AValue) then
   begin
     if Assigned(TAmSCIOT( FAmSCIOT ).OnGerarLog) then
        TAmSCIOT( FAmSCIOT ).OnGerarLog('ERRO: Informar uma Justificativa para cancelar o Conhecimento Eletrônico');
     raise Exception.Create('Informar uma Justificativa para cancelar o Conhecimento Eletrônico')
   end
  else
    AValue := DFeUtil.TrataString(AValue);

  if Length(AValue) < 15 then
   begin
     if Assigned(TAmSCIOT( FAmSCIOT ).OnGerarLog) then
        TAmSCIOT( FAmSCIOT ).OnGerarLog('ERRO: A Justificativa para Cancelamento do Conhecimento Eletrônico deve ter no minimo 15 caracteres');
     raise Exception.Create('A Justificativa para Cancelamento do Conhecimento Eletrônico deve ter no minimo 15 caracteres')
   end
//  else
//    FJustificativa := Trim(AValue);
end;

procedure TCIOTMotorista.Clear;
begin
  FMensagem := '';
  FSucesso  := False;

//  if Assigned(FMotorista) then FMotorista.Free;
end;

constructor TCIOTMotorista.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FMotorista := TMotorista.Create(AOwner);
end;

destructor TCIOTMotorista.destroy;
begin
  FMotorista.Free;

  inherited;
end;

function TCIOTMotorista.Obter(ACPF, ACNH: string): Boolean;
begin
  Clear;

  FMotorista := TMotorista.Create(FAmSCIOT);
  FMotorista.CPF := ACPF;
  FMotorista.CNH := ACNH;

  Obter;

  result := Self.Sucesso;
end;

function TCIOTMotorista.Obter: Boolean;
var
  aMsg  : string;
  Texto : String;
  Acao  : TStringList;
  Stream: TMemoryStream;
  StrStream: TStringStream;

  {$IFDEF ACBrCTeOpenSSL}
     HTTP: THTTPSend;
  {$ELSE}
     ReqResp: THTTPReqResp;
  {$ENDIF}
begin
  inherited Obter;

  Result := False;

  Acao   := TStringList.Create;
  Stream := TMemoryStream.Create;
  FSucesso := False;

  Texto := '<?xml version="1.0" encoding="utf-8"?>';
  Texto := Texto + '<soap12:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap12="http://www.w3.org/2003/05/soap-envelope">';
  Texto := Texto +   '<soap12:Body>';
  Texto := Texto +   '  <Obter xmlns="http://schemas.ipc.adm.br/efrete/motoristas">';
  Texto := Texto + FDadosMsg;
  Texto := Texto +   '  </Obter>';
  Texto := Texto +   '</soap12:Body>';
  Texto := Texto + '</soap12:Envelope>';

  Acao.Text := Texto;

  {$IFDEF ACBrCTeOpenSSL}
     Acao.SaveToStream(Stream);
     HTTP := THTTPSend.Create;
  {$ELSE}
     ReqResp := THTTPReqResp.Create(nil);
     ConfiguraReqResp( ReqResp );
     ReqResp.URL := Trim(FURL);
     ReqResp.UseUTF8InHeader := True;
     ReqResp.SoapAction := 'http://schemas.ipc.adm.br/efrete/motoristas/Obter';
  {$ENDIF}

  try
    TAmSCIOT( FAmSCIOT ).SetStatus( stCIOTObtendo );
    if FConfiguracoes.Geral.Salvar then
     begin
       FPathArqEnv := FormatDateTime('yyyymmddhhnnss',Now)+'-obter-motoristas.xml';
       FConfiguracoes.Geral.Save(FPathArqEnv, FDadosMsg, FConfiguracoes.Arquivos.PathLog);
     end;

    try
      {$IFDEF ACBrCTeOpenSSL}
         HTTP.Document.LoadFromStream(Stream);
         ConfiguraHTTP(HTTP,'SOAPAction: "http://schemas.ipc.adm.br/efrete/motoristas/Obter"');
         HTTP.HTTPMethod('POST', FURL);
         StrStream := TStringStream.Create('') ;
         StrStream.CopyFrom(HTTP.Document, 0);

         FRetornoWS := TiraAcentos(ParseText(StrStream.DataString, True));
         FRetWS := SeparaDados( FRetornoWS, 'ObterResponse');
         StrStream.Free;
      {$ELSE}
         ReqResp.Execute(Acao.Text, Stream);
         StrStream := TStringStream.Create('');
         StrStream.CopyFrom(Stream, 0);
         FRetornoWS := TiraAcentos(ParseText(StrStream.DataString, True));
         FRetWS := SeparaDados( FRetornoWS, 'ObterResponse');
         StrStream.Free;
      {$ENDIF}

      FRetMotorista := TMotoristaR.Create(FMotorista);
      FRetMotorista.Leitor.Arquivo := FRetWS;
      FRetMotorista.LerXml;

      TAmSCIOT( FAmSCIOT ).SetStatus( stCIOTIdle );
      aMsg := 'CPF : '+FMotorista.CPF+LineBreak+
              'CNH : '+FMotorista.CNH+LineBreak+
              'Nome : '+FMotorista.Nome+LineBreak +
              'Sucesso : '+BoolToStr(FRetMotorista.Sucesso)+LineBreak+
              'Mensagem : '+FRetMotorista.Mensagem+LineBreak;

      if FConfiguracoes.WebServices.Visualizar then
        ShowMessage(aMsg);

      if Assigned(TAmSCIOT( FAmSCIOT ).OnGerarLog) then
         TAmSCIOT( FAmSCIOT ).OnGerarLog(aMsg);

      FMsg   := LineBreak+FRetMotorista.Mensagem;
      Result := FRetMotorista.Sucesso;

      FRetMotorista.Free;

      if FConfiguracoes.Geral.Salvar then
       begin
         FPathArqResp := FormatDateTime('yyyymmddhhnnss',Now)+'-response-motoristas.xml';
         FConfiguracoes.Geral.Save(FPathArqResp, FRetWS, FConfiguracoes.Arquivos.PathLog);
       end;

    except on E: Exception do
      begin
       if Assigned(TAmSCIOT( FAmSCIOT ).OnGerarLog) then
          TAmSCIOT( FAmSCIOT ).OnGerarLog('WebService Motorista:'+LineBreak+
                                          '- Inativo ou Inoperante tente novamente.'+LineBreak+
                              '- '+FMensagem + LineBreak +
                              '- '+E.Message);
       raise Exception.Create('WebService Motorista:'+LineBreak+
                              '- Inativo ou Inoperante tente novamente.'+LineBreak+
                              '- '+FMensagem + LineBreak +
                              '- '+E.Message);
      end;
    end;

  finally
    {$IFDEF ACBrCTeOpenSSL}
       HTTP.Free;
    {$ELSE}
      ReqResp.Free;
    {$ENDIF}
    Acao.Free;
    Stream.Free;
    DFeUtil.ConfAmbiente;
    TAmSCIOT( FAmSCIOT ).SetStatus( stCIOTIdle );
  end;
end;

function TCIOTMotorista.Adicionar: Boolean;
var
  aMsg  : String;
  Texto : String;
  Acao  : TStringList;
  Stream: TMemoryStream;
  StrStream: TStringStream;
  {$IFDEF ACBrCTeOpenSSL}
     HTTP: THTTPSend;
  {$ELSE}
     ReqResp: THTTPReqResp;
  {$ENDIF}
begin
  inherited Adicionar;

  Acao := TStringList.Create;
  Stream := TMemoryStream.Create;

  Texto := '<?xml version="1.0" encoding="utf-8"?>';
  Texto := Texto + '<soap12:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap12="http://www.w3.org/2003/05/soap-envelope">';
  Texto := Texto +   '<soap12:Body>';
  Texto := Texto +   '  <Gravar xmlns="http://schemas.ipc.adm.br/efrete/motoristas">';
  Texto := Texto + FDadosMsg;
  Texto := Texto +   '  </Gravar>';
  Texto := Texto +   '</soap12:Body>';
  Texto := Texto +'</soap12:Envelope>';

  Acao.Text := Texto;

  {$IFDEF ACBrCTeOpenSSL}
     Acao.SaveToStream(Stream);
     HTTP := THTTPSend.Create;
  {$ELSE}
     ReqResp := THTTPReqResp.Create(nil);
     ConfiguraReqResp( ReqResp );
     ReqResp.URL := Trim(FURL);
     ReqResp.UseUTF8InHeader := True;
     ReqResp.SoapAction := 'http://schemas.ipc.adm.br/efrete/motoristas/Gravar';
  {$ENDIF}
  try
    TAmSCIOT( FAmSCIOT ).SetStatus( stCIOTAdicionando );

    if FConfiguracoes.Geral.Salvar then
     begin
       FPathArqEnv := FormatDateTime('yyyymmddhhnnss',Now)+'-adicionar-motoristas.xml';
       FConfiguracoes.Geral.Save(FPathArqEnv, FDadosMsg, FConfiguracoes.Arquivos.PathLog);
     end;

    FRetWS := '';
    {$IFDEF ACBrCTeOpenSSL}
       HTTP.Document.LoadFromStream(Stream);
       ConfiguraHTTP(HTTP,'SOAPAction: "http://schemas.ipc.adm.br/efrete/motoristas/Gravar"');
       HTTP.HTTPMethod('POST', FURL);

       StrStream := TStringStream.Create('');
       StrStream.CopyFrom(HTTP.Document, 0);
       FRetornoWS := TiraAcentos(ParseText(StrStream.DataString, True));
       FRetWS := SeparaDados( FRetornoWS,'GravarResponse');
       StrStream.Free;
    {$ELSE}
       ReqResp.Execute(Acao.Text, Stream);
       StrStream := TStringStream.Create('');
       StrStream.CopyFrom(Stream, 0);
       FRetornoWS := TiraAcentos(ParseText(StrStream.DataString, True));
       FRetWS := SeparaDados( FRetornoWS,'GravarResponse');
       StrStream.Free;
    {$ENDIF}

    if FConfiguracoes.Geral.Salvar then
     begin
       FPathArqResp := FormatDateTime('yyyymmddhhnnss',Now)+'-response-AddMotorista.xml';
       FConfiguracoes.Geral.Save(FPathArqResp, FRetWS, FConfiguracoes.Arquivos.PathLog);
     end;

      FRetMotorista := TMotoristaR.Create(FMotorista, opAdicionar);
      FRetMotorista.Leitor.Arquivo := FRetWS;
      FRetMotorista.LerXml;

      TAmSCIOT( FAmSCIOT ).SetStatus( stCIOTIdle );
      aMsg := 'CNPJ : '+FRetMotorista.Motorista.CPF+LineBreak+
              'RazaoSocial : '+FRetMotorista.Motorista.Nome+LineBreak+
              'Proprietario.Endereco.Rua : '+FRetMotorista.Motorista.Endereco.Rua+LineBreak +
              'Sucesso : '+BoolToStr(FRetMotorista.Sucesso)+LineBreak+
              'Mensagem : '+FRetMotorista.Mensagem+LineBreak;

    if FConfiguracoes.WebServices.Visualizar then
      ShowMessage(aMsg);

    if Assigned(TAmSCIOT( FAmSCIOT ).OnGerarLog) then
       TAmSCIOT( FAmSCIOT ).OnGerarLog(aMsg);


      FMsg   := LineBreak+FRetMotorista.Mensagem;
      Result := (FRetMotorista.Sucesso);

      FSucesso := FRetMotorista.Sucesso;
      FMensagem := FRetMotorista.Mensagem;
      FRetMotorista.Free;
  finally
    {$IFDEF ACBrCTeOpenSSL}
       HTTP.Free;
    {$ELSE}
      ReqResp.Free;
    {$ENDIF}
    Acao.Free;
    Stream.Free;
    DFeUtil.ConfAmbiente;
    TAmSCIOT( FAmSCIOT ).SetStatus( stCIOTIdle );
  end;
end;


{ TCIOTOperacaoTransporte }

function TCIOTOperacaoTransporte.AdicionarPagamento: Boolean;
var
  CIOTRetorno: TOperacaoTransporteR;
  aMsg  : string;
  Texto : String;
  Acao  : TStringList;
  Stream: TMemoryStream;
  StrStream: TStringStream;

  {$IFDEF ACBrCTeOpenSSL}
     HTTP: THTTPSend;
  {$ELSE}
     ReqResp: THTTPReqResp;
  {$ENDIF}
begin
  Result   := False;

  if FConfiguracoes.Certificados.NumeroSerie = '' then
    FConfiguracoes.Certificados.NumeroSerie := FConfiguracoes.Certificados.SelecionarCertificado;

  LoadMsgEntrada(opAdicionarPagamento);
  LoadURL;

  Result := False;

  Acao   := TStringList.Create;
  Stream := TMemoryStream.Create;

  Texto := '<?xml version="1.0" encoding="utf-8"?>';
  Texto := Texto + '<soap12:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap12="http://www.w3.org/2003/05/soap-envelope">';
  Texto := Texto +   '<soap12:Body>';
  Texto := Texto +   '  <AdicionarPagamento xmlns="http://schemas.ipc.adm.br/efrete/pef"> ';
  Texto := Texto + FDadosMsg;
  Texto := Texto +   '  </AdicionarPagamento>';
  Texto := Texto +   '</soap12:Body>';
  Texto := Texto + '</soap12:Envelope>';

  Acao.Text := Texto;

  {$IFDEF ACBrCTeOpenSSL}
     Acao.SaveToStream(Stream);
     HTTP := THTTPSend.Create;
  {$ELSE}
     ReqResp := THTTPReqResp.Create(nil);
     ConfiguraReqResp( ReqResp );
     ReqResp.URL := Trim(FURL);
     ReqResp.UseUTF8InHeader := True;
     ReqResp.SoapAction := 'http://schemas.ipc.adm.br/efrete/pef/AdicionarPagamento';
  {$ENDIF}

  try
    TAmSCIOT( FAmSCIOT ).SetStatus( stCIOTObtendo );
    if FConfiguracoes.Geral.Salvar then
     begin
       FPathArqEnv := FormatDateTime('yyyymmddhhnnss',Now)+'-adicionar-Pagamento.xml';
       FConfiguracoes.Geral.Save(FPathArqEnv, FDadosMsg, FConfiguracoes.Arquivos.PathLog);
     end;

    try
      {$IFDEF ACBrCTeOpenSSL}
         HTTP.Document.LoadFromStream(Stream);
         ConfiguraHTTP(HTTP,'SOAPAction: "http://schemas.ipc.adm.br/efrete/pef/AdicionarPagamento"');
         HTTP.HTTPMethod('POST', FURL);
         StrStream := TStringStream.Create('') ;
         StrStream.CopyFrom(HTTP.Document, 0);

         FRetornoWS := TiraAcentos(ParseText(StrStream.DataString, True));
         FRetWS := SeparaDados( FRetornoWS, 'AdicionarPagamentoResponse');
         StrStream.Free;
      {$ELSE}
         ReqResp.Execute(Acao.Text, Stream);
         StrStream := TStringStream.Create('');
         StrStream.CopyFrom(Stream, 0);
         FRetornoWS := TiraAcentos(ParseText(StrStream.DataString, True));
         FRetWS := SeparaDados( FRetornoWS, 'AdicionarPagamentoResponse');
         StrStream.Free;
      {$ENDIF}

      CIOTRetorno := TOperacaoTransporteR.Create(FOperacoesTransporte.Items[0], opAdicionarPagamento);
      CIOTRetorno.Leitor.Arquivo := FRetWS;
      CIOTRetorno.LerXml;

      TAmSCIOT( FAmSCIOT ).SetStatus( stCIOTIdle );
      aMsg := 'CIOT Gerado: '+CIOTRetorno.OperacaoTransporte.NumeroCIOT+LineBreak+
              'Mensagem : '+CIOTRetorno.Mensagem+LineBreak;

      if FConfiguracoes.WebServices.Visualizar then
        ShowMessage(aMsg);

      if Assigned(TAmSCIOT( FAmSCIOT ).OnGerarLog) then
         TAmSCIOT( FAmSCIOT ).OnGerarLog(aMsg);

      FMsg   := LineBreak+CIOTRetorno.Mensagem;
      Result := (CIOTRetorno.Sucesso);

      FSucesso := CIOTRetorno.Sucesso;
      FMensagem := CIOTRetorno.Mensagem;

      CIOTRetorno.Free;

      if FConfiguracoes.Geral.Salvar then
       begin
         FPathArqResp := FormatDateTime('yyyymmddhhnnss',Now)+'-response-adicionar-Pagamento.xml';
         FConfiguracoes.Geral.Save(FPathArqResp, FRetWS, FConfiguracoes.Arquivos.PathLog);
       end;

    except on E: Exception do
      begin
       if Assigned(TAmSCIOT( FAmSCIOT ).OnGerarLog) then
          TAmSCIOT( FAmSCIOT ).OnGerarLog('WebService OperacaoTransporte (AddPagamento):'+LineBreak+
                                          '- Inativo ou Inoperante tente novamente.'+LineBreak+
                              '- '+FMensagem + LineBreak +
                              '- '+E.Message);
       raise Exception.Create('WebService OperacaoTransporte (AddPagamento):'+LineBreak+
                              '- Inativo ou Inoperante tente novamente.'+LineBreak+
                              '- '+FMensagem + LineBreak +
                              '- '+E.Message);
      end;
    end;

  finally
    {$IFDEF ACBrCTeOpenSSL}
       HTTP.Free;
    {$ELSE}
      ReqResp.Free;
    {$ENDIF}
    Acao.Free;
    Stream.Free;
    DFeUtil.ConfAmbiente;
    TAmSCIOT( FAmSCIOT ).SetStatus( stCIOTIdle );
  end;
end;

function TCIOTOperacaoTransporte.AdicionarViagens: Boolean;
var
  CIOTRetorno: TOperacaoTransporteR;
  aMsg  : string;
  Texto : String;
  Acao  : TStringList;
  Stream: TMemoryStream;
  StrStream: TStringStream;

  {$IFDEF ACBrCTeOpenSSL}
     HTTP: THTTPSend;
  {$ELSE}
     ReqResp: THTTPReqResp;
  {$ENDIF}
begin
  Result   := False;

  if FConfiguracoes.Certificados.NumeroSerie = '' then
    FConfiguracoes.Certificados.NumeroSerie := FConfiguracoes.Certificados.SelecionarCertificado;

  LoadMsgEntrada(opAdicionarViagem);
  LoadURL;

  Result := False;

  Acao   := TStringList.Create;
  Stream := TMemoryStream.Create;

  Texto := '<?xml version="1.0" encoding="utf-8"?>';
  Texto := Texto + '<soap12:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap12="http://www.w3.org/2003/05/soap-envelope">';
  Texto := Texto +   '<soap12:Body>';
  Texto := Texto +   '  <AdicionarViagem xmlns="http://schemas.ipc.adm.br/efrete/pef"> ';
  Texto := Texto + FDadosMsg;
  Texto := Texto +   '  </AdicionarViagem>';
  Texto := Texto +   '</soap12:Body>';
  Texto := Texto + '</soap12:Envelope>';

  Acao.Text := Texto;

  {$IFDEF ACBrCTeOpenSSL}
     Acao.SaveToStream(Stream);
     HTTP := THTTPSend.Create;
  {$ELSE}
     ReqResp := THTTPReqResp.Create(nil);
     ConfiguraReqResp( ReqResp );
     ReqResp.URL := Trim(FURL);
     ReqResp.UseUTF8InHeader := True;
     ReqResp.SoapAction := 'http://schemas.ipc.adm.br/efrete/pef/AdicionarViagem';
  {$ENDIF}

  try
    TAmSCIOT( FAmSCIOT ).SetStatus( stCIOTObtendo );
    if FConfiguracoes.Geral.Salvar then
     begin
       FPathArqEnv := FormatDateTime('yyyymmddhhnnss',Now)+'-adicionar-Viagem.xml';
       FConfiguracoes.Geral.Save(FPathArqEnv, FDadosMsg, FConfiguracoes.Arquivos.PathLog);
     end;

    try
      {$IFDEF ACBrCTeOpenSSL}
         HTTP.Document.LoadFromStream(Stream);
         ConfiguraHTTP(HTTP,'SOAPAction: "http://schemas.ipc.adm.br/efrete/pef/AdicionarViagem"');
         HTTP.HTTPMethod('POST', FURL);
         StrStream := TStringStream.Create('') ;
         StrStream.CopyFrom(HTTP.Document, 0);

         FRetornoWS := TiraAcentos(ParseText(StrStream.DataString, True));
         FRetWS := SeparaDados( FRetornoWS, 'AdicionarViagemResponse');
         StrStream.Free;
      {$ELSE}
         ReqResp.Execute(Acao.Text, Stream);
         StrStream := TStringStream.Create('');
         StrStream.CopyFrom(Stream, 0);
         FRetornoWS := TiraAcentos(ParseText(StrStream.DataString, True));
         FRetWS := SeparaDados( FRetornoWS, 'AdicionarViagemResponse');
         StrStream.Free;
      {$ENDIF}

      CIOTRetorno := TOperacaoTransporteR.Create(FOperacoesTransporte.Items[0], opAdicionarViagem);
      CIOTRetorno.Leitor.Arquivo := FRetWS;
      CIOTRetorno.LerXml;

      TAmSCIOT( FAmSCIOT ).SetStatus( stCIOTIdle );
      aMsg := 'CIOT Gerado: '+CIOTRetorno.OperacaoTransporte.NumeroCIOT+LineBreak+
              'Mensagem : '+CIOTRetorno.Mensagem+LineBreak;

      if FConfiguracoes.WebServices.Visualizar then
        ShowMessage(aMsg);

      if Assigned(TAmSCIOT( FAmSCIOT ).OnGerarLog) then
         TAmSCIOT( FAmSCIOT ).OnGerarLog(aMsg);

      FMsg   := LineBreak+CIOTRetorno.Mensagem;
      Result := (CIOTRetorno.Sucesso);

      FSucesso := CIOTRetorno.Sucesso;
      FMensagem := CIOTRetorno.Mensagem;

      CIOTRetorno.Free;

      if FConfiguracoes.Geral.Salvar then
       begin
         FPathArqResp := FormatDateTime('yyyymmddhhnnss',Now)+'-response-adicionar-Viagem.xml';
         FConfiguracoes.Geral.Save(FPathArqResp, FRetWS, FConfiguracoes.Arquivos.PathLog);
       end;

    except on E: Exception do
      begin
       if Assigned(TAmSCIOT( FAmSCIOT ).OnGerarLog) then
          TAmSCIOT( FAmSCIOT ).OnGerarLog('WebService OperacaoTransporte (AddViagem):'+LineBreak+
                                          '- Inativo ou Inoperante tente novamente.'+LineBreak+
                              '- '+FMensagem + LineBreak +
                              '- '+E.Message);
       raise Exception.Create('WebService OperacaoTransporte (AddViagem):'+LineBreak+
                              '- Inativo ou Inoperante tente novamente.'+LineBreak+
                              '- '+FMensagem + LineBreak +
                              '- '+E.Message);
      end;
    end;

  finally
    {$IFDEF ACBrCTeOpenSSL}
       HTTP.Free;
    {$ELSE}
      ReqResp.Free;
    {$ENDIF}
    Acao.Free;
    Stream.Free;
    DFeUtil.ConfAmbiente;
    TAmSCIOT( FAmSCIOT ).SetStatus( stCIOTIdle );
  end;
end;

function TCIOTOperacaoTransporte.Cancelar(ANumeroCIOT, AMotivo: string): Boolean;
var
  CIOTRetorno: TOperacaoTransporteR;
  aMsg  : string;
  Texto : String;
  Acao  : TStringList;
  Stream: TMemoryStream;
  StrStream: TStringStream;

  {$IFDEF ACBrCTeOpenSSL}
     HTTP: THTTPSend;
  {$ELSE}
     ReqResp: THTTPReqResp;
  {$ENDIF}
begin
  Clear;
  Result := False;

  if not Assigned(FOperacoesTransporte.Items[0]) then
    FOperacoesTransporte.Add;
//    FOT := TOperacaoTransporte.Create(FAmSCIOT);

  FOperacoesTransporte.Items[0].NumeroCIOT := ANumeroCIOT;
  FOperacoesTransporte.Items[0].Cancelamento.Motivo := AMotivo;

  if FConfiguracoes.Certificados.NumeroSerie = '' then
    FConfiguracoes.Certificados.NumeroSerie := FConfiguracoes.Certificados.SelecionarCertificado;

  LoadMsgEntrada(opCancelar);
  LoadURL;

  Acao   := TStringList.Create;
  Stream := TMemoryStream.Create;

  Texto := '<?xml version="1.0" encoding="utf-8"?>';
  Texto := Texto + '<soap12:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap12="http://www.w3.org/2003/05/soap-envelope">';
  Texto := Texto +   '<soap12:Body>';
  Texto := Texto +   '  <CancelarOperacaoTransporte xmlns="http://schemas.ipc.adm.br/efrete/pef">';
  Texto := Texto + FDadosMsg;
  Texto := Texto +   '  </CancelarOperacaoTransporte>';
  Texto := Texto +   '</soap12:Body>';
  Texto := Texto + '</soap12:Envelope>';

  Acao.Text := Texto;

  {$IFDEF ACBrCTeOpenSSL}
     Acao.SaveToStream(Stream);
     HTTP := THTTPSend.Create;
  {$ELSE}
     ReqResp := THTTPReqResp.Create(nil);
     ConfiguraReqResp( ReqResp );
     ReqResp.URL := Trim(FURL);
     ReqResp.UseUTF8InHeader := True;
     ReqResp.SoapAction := 'http://schemas.ipc.adm.br/efrete/pef/CancelarOperacaoTransporte';
  {$ENDIF}

  try
    TAmSCIOT( FAmSCIOT ).SetStatus( stCIOTObtendo );
    if FConfiguracoes.Geral.Salvar then
     begin
       FPathArqEnv := FormatDateTime('yyyymmddhhnnss',Now)+'-cancelar-OperacaoTransporte.xml';
       FConfiguracoes.Geral.Save(FPathArqEnv, FDadosMsg, FConfiguracoes.Arquivos.PathLog);
     end;

    try
      {$IFDEF ACBrCTeOpenSSL}
         HTTP.Document.LoadFromStream(Stream);
         ConfiguraHTTP(HTTP,'SOAPAction: "http://schemas.ipc.adm.br/efrete/pef/CancelarOperacaoTransporte');
         HTTP.HTTPMethod('POST', FURL);
         StrStream := TStringStream.Create('') ;
         StrStream.CopyFrom(HTTP.Document, 0);

         FRetornoWS := TiraAcentos(ParseText(StrStream.DataString, True));
         FRetWS := SeparaDados( FRetornoWS, 'CancelarOperacaoTransporteResponse');
         StrStream.Free;
      {$ELSE}
         ReqResp.Execute(Acao.Text, Stream);
         StrStream := TStringStream.Create('');
         StrStream.CopyFrom(Stream, 0);
         FRetornoWS := TiraAcentos(ParseText(StrStream.DataString, True));
         FRetWS := SeparaDados( FRetornoWS, 'CancelarOperacaoTransporteResponse');
         StrStream.Free;
      {$ENDIF}

      CIOTRetorno := TOperacaoTransporteR.Create(FOperacoesTransporte.Items[0], opCancelar);
      CIOTRetorno.Leitor.Arquivo := FRetWS;
      CIOTRetorno.LerXml;

      TAmSCIOT( FAmSCIOT ).SetStatus( stCIOTIdle );
//      aMsg := 'CNPJ : '+CIOTRetorno.OperacaoTransporte.CNPJ+LineBreak+
//              'RazaoSocial : '+CIOTRetorno.OperacaoTransporte.RazaoSocial+LineBreak+
//              'Proprietario.Endereco.Rua : '+CIOTRetorno.OperacaoTransporte.Endereco.Rua+LineBreak +
//              'Sucesso : '+BoolToStr(CIOTRetorno.Sucesso)+LineBreak+
//              'Mensagem : '+CIOTRetorno.Mensagem+LineBreak;

      if FConfiguracoes.WebServices.Visualizar then
        ShowMessage(aMsg);

      if Assigned(TAmSCIOT( FAmSCIOT ).OnGerarLog) then
         TAmSCIOT( FAmSCIOT ).OnGerarLog(aMsg);

      FMsg   := LineBreak+CIOTRetorno.Mensagem;
      Result := (CIOTRetorno.Sucesso) or (FOperacoesTransporte.Items[0].Cancelamento.Protocolo <> '');
      FSucesso := CIOTRetorno.Sucesso;
      FMensagem := CIOTRetorno.Mensagem;

      CIOTRetorno.Free;

      if FConfiguracoes.Geral.Salvar then
       begin
         FPathArqResp := FormatDateTime('yyyymmddhhnnss',Now)+'-response-CancelarOperacaoTransporte.xml';
         FConfiguracoes.Geral.Save(FPathArqResp, FRetWS, FConfiguracoes.Arquivos.PathLog);
       end;

    except on E: Exception do
      begin
       if Assigned(TAmSCIOT( FAmSCIOT ).OnGerarLog) then
          TAmSCIOT( FAmSCIOT ).OnGerarLog('WebService OperacaoTransporte (Cancelar):'+LineBreak+
                                          '- Inativo ou Inoperante tente novamente.'+LineBreak+
                              '- '+FMensagem + LineBreak +
                              '- '+E.Message);
       raise Exception.Create('WebService OperacaoTransporte (Cancelar):'+LineBreak+
                              '- Inativo ou Inoperante tente novamente.'+LineBreak+
                              '- '+FMensagem + LineBreak +
                              '- '+E.Message);
      end;
    end;

  finally
    {$IFDEF ACBrCTeOpenSSL}
       HTTP.Free;
    {$ELSE}
      ReqResp.Free;
    {$ENDIF}
    Acao.Free;
    Stream.Free;
    DFeUtil.ConfAmbiente;
    TAmSCIOT( FAmSCIOT ).SetStatus( stCIOTIdle );
  end;
end;

function TCIOTOperacaoTransporte.CancelarPagamento(AIdPagamento, AMotivo: string): Boolean;
var
  CIOTRetorno: TOperacaoTransporteR;
  aMsg  : string;
  Texto : String;
  Acao  : TStringList;
  Stream: TMemoryStream;
  StrStream: TStringStream;

  {$IFDEF ACBrCTeOpenSSL}
     HTTP: THTTPSend;
  {$ELSE}
     ReqResp: THTTPReqResp;
  {$ENDIF}
begin
  Clear;
  Result := False;

  if not Assigned(FOperacoesTransporte.Items[0]) then
    FOperacoesTransporte.Add;
//    FOperacoesTransporte := TOperacaoTransporte.Create(FAmSCIOT);

  FOperacoesTransporte.Items[0].Cancelamento.IdPagamentoCliente := AIdPagamento;
  FOperacoesTransporte.Items[0].Cancelamento.Motivo := AMotivo;

  if FConfiguracoes.Certificados.NumeroSerie = '' then
    FConfiguracoes.Certificados.NumeroSerie := FConfiguracoes.Certificados.SelecionarCertificado;

  LoadMsgEntrada(opCancelarPagamento);
  LoadURL;

  Acao   := TStringList.Create;
  Stream := TMemoryStream.Create;

  Texto := '<?xml version="1.0" encoding="utf-8"?>';
  Texto := Texto + '<soap12:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap12="http://www.w3.org/2003/05/soap-envelope">';
  Texto := Texto +   '<soap12:Body>';
  Texto := Texto +   '  <CancelarPagamento xmlns="http://schemas.ipc.adm.br/efrete/pef">';
  Texto := Texto + FDadosMsg;
  Texto := Texto +   '  </CancelarPagamento>';
  Texto := Texto +   '</soap12:Body>';
  Texto := Texto + '</soap12:Envelope>';

  Acao.Text := Texto;

  {$IFDEF ACBrCTeOpenSSL}
     Acao.SaveToStream(Stream);
     HTTP := THTTPSend.Create;
  {$ELSE}
     ReqResp := THTTPReqResp.Create(nil);
     ConfiguraReqResp( ReqResp );
     ReqResp.URL := Trim(FURL);
     ReqResp.UseUTF8InHeader := True;
     ReqResp.SoapAction := 'http://schemas.ipc.adm.br/efrete/pef/CancelarPagamento';
  {$ENDIF}

  try
    TAmSCIOT( FAmSCIOT ).SetStatus( stCIOTObtendo );
    if FConfiguracoes.Geral.Salvar then
     begin
       FPathArqEnv := FormatDateTime('yyyymmddhhnnss',Now)+'-cancelar-Pagamento.xml';
       FConfiguracoes.Geral.Save(FPathArqEnv, FDadosMsg, FConfiguracoes.Arquivos.PathLog);
     end;

    try
      {$IFDEF ACBrCTeOpenSSL}
         HTTP.Document.LoadFromStream(Stream);
         ConfiguraHTTP(HTTP,'SOAPAction: "http://schemas.ipc.adm.br/efrete/pef/CancelarPagamento"');
         HTTP.HTTPMethod('POST', FURL);
         StrStream := TStringStream.Create('') ;
         StrStream.CopyFrom(HTTP.Document, 0);

         FRetornoWS := TiraAcentos(ParseText(StrStream.DataString, True));
         FRetWS := SeparaDados( FRetornoWS, 'CancelarOperacaoTransporteResponse');
         StrStream.Free;
      {$ELSE}
         ReqResp.Execute(Acao.Text, Stream);
         StrStream := TStringStream.Create('');
         StrStream.CopyFrom(Stream, 0);
         FRetornoWS := TiraAcentos(ParseText(StrStream.DataString, True));
         FRetWS := SeparaDados( FRetornoWS, 'CancelarOperacaoTransporteResponse');
         StrStream.Free;
      {$ENDIF}

      CIOTRetorno := TOperacaoTransporteR.Create(FOperacoesTransporte.Items[0], opCancelarPagamento);
      CIOTRetorno.Leitor.Arquivo := FRetWS;
      CIOTRetorno.LerXml;

      TAmSCIOT( FAmSCIOT ).SetStatus( stCIOTIdle );
      aMsg := 'Pagamento cancelado: '+FOperacoesTransporte.Items[0].Cancelamento.IdPagamentoCliente+LineBreak+
              'Mensagem : '+CIOTRetorno.Mensagem+LineBreak;

      if FConfiguracoes.WebServices.Visualizar then
        ShowMessage(aMsg);

      if Assigned(TAmSCIOT( FAmSCIOT ).OnGerarLog) then
         TAmSCIOT( FAmSCIOT ).OnGerarLog(aMsg);

      FMsg   := LineBreak+CIOTRetorno.Mensagem;
      Result := (CIOTRetorno.Sucesso);
      FSucesso := CIOTRetorno.Sucesso;
      FMensagem := CIOTRetorno.Mensagem;

      CIOTRetorno.Free;

      if FConfiguracoes.Geral.Salvar then
       begin
         FPathArqResp := FormatDateTime('yyyymmddhhnnss',Now)+'-response-Pagamento.xml';
         FConfiguracoes.Geral.Save(FPathArqResp, FRetWS, FConfiguracoes.Arquivos.PathLog);
       end;

    except on E: Exception do
      begin
       if Assigned(TAmSCIOT( FAmSCIOT ).OnGerarLog) then
          TAmSCIOT( FAmSCIOT ).OnGerarLog('WebService OperacaoTransporte (Cancelar Pagamento):'+LineBreak+
                                          '- Inativo ou Inoperante tente novamente.'+LineBreak+
                              '- '+FMensagem + LineBreak +
                              '- '+E.Message);
       raise Exception.Create('WebService OperacaoTransporte (Cancelar Pagamento):'+LineBreak+
                              '- Inativo ou Inoperante tente novamente.'+LineBreak+
                              '- '+FMensagem + LineBreak +
                              '- '+E.Message);
      end;
    end;

  finally
    {$IFDEF ACBrCTeOpenSSL}
       HTTP.Free;
    {$ELSE}
      ReqResp.Free;
    {$ENDIF}
    Acao.Free;
    Stream.Free;
    DFeUtil.ConfAmbiente;
    TAmSCIOT( FAmSCIOT ).SetStatus( stCIOTIdle );
  end;
end;

procedure TCIOTOperacaoTransporte.Clear;
begin
  FMensagem := '';
  FSucesso  := False;

//  if Assigned(FOperacaoTransporte) then FOperacaoTransporte.Free;
end;

constructor TCIOTOperacaoTransporte.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FOperacoesTransporte := TOperacoesTransporte.Create(AOwner, TOperacaoTransporte);
end;

destructor TCIOTOperacaoTransporte.Destroy;
begin
  FOperacoesTransporte.Free;
//  if Assigned(FEventoRetorno) then
//     FEventoRetorno.Free;
  inherited;
end;

function TCIOTOperacaoTransporte.Encerrar: Boolean;
var
  CIOTRetorno: TOperacaoTransporteR;
  aMsg  : string;
  Texto : String;
  Acao  : TStringList;
  Stream: TMemoryStream;
  StrStream: TStringStream;

  {$IFDEF ACBrCTeOpenSSL}
     HTTP: THTTPSend;
  {$ELSE}
     ReqResp: THTTPReqResp;
  {$ENDIF}
begin
  Result   := False;

  if FConfiguracoes.Certificados.NumeroSerie = '' then
    FConfiguracoes.Certificados.NumeroSerie := FConfiguracoes.Certificados.SelecionarCertificado;

  LoadMsgEntrada(opEncerrar);
  LoadURL;

  Acao   := TStringList.Create;
  Stream := TMemoryStream.Create;

  Texto := '<?xml version="1.0" encoding="utf-8"?>';
  Texto := Texto + '<soap12:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap12="http://www.w3.org/2003/05/soap-envelope">';
  Texto := Texto +   '<soap12:Body>';
  Texto := Texto +   '  <EncerrarOperacaoTransporte xmlns="http://schemas.ipc.adm.br/efrete/pef">';
  Texto := Texto + FDadosMsg;
  Texto := Texto +   '  </EncerrarOperacaoTransporte>';
  Texto := Texto +   '</soap12:Body>';
  Texto := Texto + '</soap12:Envelope>';

  Acao.Text := Texto;

  {$IFDEF ACBrCTeOpenSSL}
     Acao.SaveToStream(Stream);
     HTTP := THTTPSend.Create;
  {$ELSE}
     ReqResp := THTTPReqResp.Create(nil);
     ConfiguraReqResp( ReqResp );
     ReqResp.URL := Trim(FURL);
     ReqResp.UseUTF8InHeader := True;
     ReqResp.SoapAction := 'http://schemas.ipc.adm.br/efrete/pef/EncerrarOperacaoTransporte';
  {$ENDIF}

  try
    TAmSCIOT( FAmSCIOT ).SetStatus( stCIOTObtendo );
    if FConfiguracoes.Geral.Salvar then
     begin
       FPathArqEnv := FormatDateTime('yyyymmddhhnnss',Now)+'-adicionar-Encerramento.xml';
       FConfiguracoes.Geral.Save(FPathArqEnv, FDadosMsg, FConfiguracoes.Arquivos.PathLog);
     end;

    try
      {$IFDEF ACBrCTeOpenSSL}
         HTTP.Document.LoadFromStream(Stream);
         ConfiguraHTTP(HTTP,'SOAPAction: "http://schemas.ipc.adm.br/efrete/pef/EncerrarOperacaoTransporte"');
         HTTP.HTTPMethod('POST', FURL);
         StrStream := TStringStream.Create('') ;
         StrStream.CopyFrom(HTTP.Document, 0);

         FRetornoWS := TiraAcentos(ParseText(StrStream.DataString, True));
         FRetWS := SeparaDados( FRetornoWS, 'EncerrarOperacaoTransporteResponse');
         StrStream.Free;
      {$ELSE}
         ReqResp.Execute(Acao.Text, Stream);
         StrStream := TStringStream.Create('');
         StrStream.CopyFrom(Stream, 0);
         FRetornoWS := TiraAcentos(ParseText(StrStream.DataString, True));
         FRetWS := SeparaDados( FRetornoWS, 'EncerrarOperacaoTransporteResponse');
         StrStream.Free;
      {$ENDIF}

      CIOTRetorno := TOperacaoTransporteR.Create(FOperacoesTransporte.Items[0], opEncerrar);
      CIOTRetorno.Leitor.Arquivo := FRetWS;
      CIOTRetorno.LerXml;

      TAmSCIOT( FAmSCIOT ).SetStatus( stCIOTIdle );
      aMsg := 'CIOT Encerramento: '+CIOTRetorno.OperacaoTransporte.NumeroCIOT+LineBreak+
              'Mensagem : '+CIOTRetorno.Mensagem+LineBreak;

      if FConfiguracoes.WebServices.Visualizar then
        ShowMessage(aMsg);

      if Assigned(TAmSCIOT( FAmSCIOT ).OnGerarLog) then
         TAmSCIOT( FAmSCIOT ).OnGerarLog(aMsg);

      FMsg   := LineBreak+CIOTRetorno.Mensagem;
      Result := (CIOTRetorno.Sucesso);

      FSucesso := CIOTRetorno.Sucesso;
      FMensagem := CIOTRetorno.Mensagem;

      CIOTRetorno.Free;

      if FConfiguracoes.Geral.Salvar then
       begin
         FPathArqResp := FormatDateTime('yyyymmddhhnnss',Now)+'-response-EncerramentoCIOT.xml';
         FConfiguracoes.Geral.Save(FPathArqResp, FRetWS, FConfiguracoes.Arquivos.PathLog);
       end;

    except on E: Exception do
      begin
       if Assigned(TAmSCIOT( FAmSCIOT ).OnGerarLog) then
          TAmSCIOT( FAmSCIOT ).OnGerarLog('WebService OperacaoTransporte (Encerramento):'+LineBreak+
                                          '- Inativo ou Inoperante tente novamente.'+LineBreak+
                              '- '+FMensagem + LineBreak +
                              '- '+E.Message);
       raise Exception.Create('WebService OperacaoTransporte (Encerramento):'+LineBreak+
                              '- Inativo ou Inoperante tente novamente.'+LineBreak+
                              '- '+FMensagem + LineBreak +
                              '- '+E.Message);
      end;
    end;

  finally
    {$IFDEF ACBrCTeOpenSSL}
       HTTP.Free;
    {$ELSE}
      ReqResp.Free;
    {$ENDIF}
    Acao.Free;
    Stream.Free;
    DFeUtil.ConfAmbiente;
    TAmSCIOT( FAmSCIOT ).SetStatus( stCIOTIdle );
  end;
end;

procedure TCIOTOperacaoTransporte.Imprimir;
var
  sArquivo: string;
begin
  if FOperacoesTransporte.Items[0].NumeroCIOT <> '' then
  begin
    sArquivo := StringReplace(StringReplace(FOperacoesTransporte.Items[0].NumeroCIOT, '\', '_', []), '/', '_', []) + '.pdf';

    CIOTUtil.ImprimirArquivo(PathWithDelim(TAmSCIOT( FOperacoesTransporte.Owner ).Configuracoes.Arquivos.PathPDF) + sArquivo);
  //  CIOTUtil.ImprimirArquivoDebenuPDF(PathWithDelim(TAmSCIOT( FOperacaoTransporte.Owner ).Configuracoes.Arquivos.PathPDF) + sArquivo);
  end;
end;

function TCIOTOperacaoTransporte.ObterPDF(ANroCIOT: string; ATipoImpressao: TpciotTipoImpressao; AImprimir: Boolean): Boolean;
begin
  Clear;

//  if not Assigned(FOperacoesTransporte) then
//    FOperacoesTransporte := TOperacaoTransporte.Create(FAmSCIOT);
  if not Assigned(FOperacoesTransporte.Items[0]) then
    FOperacoesTransporte.Add;

  FOperacoesTransporte.Items[0].NumeroCIOT := ANroCIOT;
  FTipoImpressao := ATipoImpressao;
  Obter;

  result := Self.Sucesso;// (FOperacoesTransporte.NumeroCIOT <> '');

  if (FOperacoesTransporte.Items[0].NumeroCIOT <> '') and AImprimir then
    Imprimir;
end;

function TCIOTOperacaoTransporte.Retificar: Boolean;
var
  CIOTRetorno: TOperacaoTransporteR;
  aMsg  : string;
  Texto : String;
  Acao  : TStringList;
  Stream: TMemoryStream;
  StrStream: TStringStream;

  {$IFDEF ACBrCTeOpenSSL}
     HTTP: THTTPSend;
  {$ELSE}
     ReqResp: THTTPReqResp;
  {$ENDIF}
begin
  Clear;
  Result := False;

  if FConfiguracoes.Certificados.NumeroSerie = '' then
    FConfiguracoes.Certificados.NumeroSerie := FConfiguracoes.Certificados.SelecionarCertificado;

  LoadMsgEntrada(opRetificar);
  LoadURL;

  Acao   := TStringList.Create;
  Stream := TMemoryStream.Create;

  Texto := '<?xml version="1.0" encoding="utf-8"?>';
  Texto := Texto + '<soap12:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap12="http://www.w3.org/2003/05/soap-envelope">';
  Texto := Texto +   '<soap12:Body>';
  Texto := Texto +   '  <RetificarOperacaoTransporte xmlns="http://schemas.ipc.adm.br/efrete/pef">';
  Texto := Texto + FDadosMsg;
  Texto := Texto +   '  </RetificarOperacaoTransporte>';
  Texto := Texto +   '</soap12:Body>';
  Texto := Texto + '</soap12:Envelope>';

  Acao.Text := Texto;

  {$IFDEF ACBrCTeOpenSSL}
     Acao.SaveToStream(Stream);
     HTTP := THTTPSend.Create;
  {$ELSE}
     ReqResp := THTTPReqResp.Create(nil);
     ConfiguraReqResp( ReqResp );
     ReqResp.URL := Trim(FURL);
     ReqResp.UseUTF8InHeader := True;
     ReqResp.SoapAction := 'http://schemas.ipc.adm.br/efrete/pef/RetificarOperacaoTransporte';
  {$ENDIF}

  try
    TAmSCIOT( FAmSCIOT ).SetStatus( stCIOTObtendo );
    if FConfiguracoes.Geral.Salvar then
     begin
       FPathArqEnv := FormatDateTime('yyyymmddhhnnss',Now)+'-retificar-OperacaoTransporte.xml';
       FConfiguracoes.Geral.Save(FPathArqEnv, FDadosMsg, FConfiguracoes.Arquivos.PathLog);
     end;

    try
      {$IFDEF ACBrCTeOpenSSL}
         HTTP.Document.LoadFromStream(Stream);
         ConfiguraHTTP(HTTP,'SOAPAction: "http://schemas.ipc.adm.br/efrete/pef/RetificarOperacaoTransporte"');
         HTTP.HTTPMethod('POST', FURL);
         StrStream := TStringStream.Create('') ;
         StrStream.CopyFrom(HTTP.Document, 0);

         FRetornoWS := TiraAcentos(ParseText(StrStream.DataString, True));
         FRetWS := SeparaDados( FRetornoWS, 'RetificarOperacaoTransporteResponse');
         StrStream.Free;
      {$ELSE}
         ReqResp.Execute(Acao.Text, Stream);
         StrStream := TStringStream.Create('');
         StrStream.CopyFrom(Stream, 0);
         FRetornoWS := TiraAcentos(ParseText(StrStream.DataString, True));
         FRetWS := SeparaDados( FRetornoWS, 'RetificarOperacaoTransporteResponse');
         StrStream.Free;
      {$ENDIF}

      CIOTRetorno := TOperacaoTransporteR.Create(FOperacoesTransporte.Items[0], opRetificar);
      CIOTRetorno.Leitor.Arquivo := FRetWS;
      CIOTRetorno.LerXml;

      TAmSCIOT( FAmSCIOT ).SetStatus( stCIOTIdle );
//      aMsg := 'CNPJ : '+CIOTRetorno.OperacaoTransporte.CNPJ+LineBreak+
//              'RazaoSocial : '+CIOTRetorno.OperacaoTransporte.RazaoSocial+LineBreak+
//              'Proprietario.Endereco.Rua : '+CIOTRetorno.OperacaoTransporte.Endereco.Rua+LineBreak +
//              'Sucesso : '+BoolToStr(CIOTRetorno.Sucesso)+LineBreak+
//              'Mensagem : '+CIOTRetorno.Mensagem+LineBreak;

      if FConfiguracoes.WebServices.Visualizar then
        ShowMessage(aMsg);

      if Assigned(TAmSCIOT( FAmSCIOT ).OnGerarLog) then
         TAmSCIOT( FAmSCIOT ).OnGerarLog(aMsg);

      FMsg   := LineBreak+CIOTRetorno.Mensagem;
      Result := (CIOTRetorno.Sucesso);

      FSucesso := CIOTRetorno.Sucesso;
      FMensagem := CIOTRetorno.Mensagem;

      CIOTRetorno.Free;

      if FConfiguracoes.Geral.Salvar then
       begin
         FPathArqResp := FormatDateTime('yyyymmddhhnnss',Now)+'-response-RetificarOperacaoTransporte.xml';
         FConfiguracoes.Geral.Save(FPathArqResp, FRetWS, FConfiguracoes.Arquivos.PathLog);
       end;

    except on E: Exception do
      begin
       if Assigned(TAmSCIOT( FAmSCIOT ).OnGerarLog) then
          TAmSCIOT( FAmSCIOT ).OnGerarLog('WebService OperacaoTransporte (Retificar):'+LineBreak+
                                          '- Inativo ou Inoperante tente novamente.'+LineBreak+
                              '- '+FMensagem + LineBreak +
                              '- '+E.Message);
       raise Exception.Create('WebService OperacaoTransporte (Retificar):'+LineBreak+
                              '- Inativo ou Inoperante tente novamente.'+LineBreak+
                              '- '+FMensagem + LineBreak +
                              '- '+E.Message);
      end;
    end;

  finally
    {$IFDEF ACBrCTeOpenSSL}
       HTTP.Free;
    {$ELSE}
      ReqResp.Free;
    {$ENDIF}
    Acao.Free;
    Stream.Free;
    DFeUtil.ConfAmbiente;
    TAmSCIOT( FAmSCIOT ).SetStatus( stCIOTIdle );
  end;
end;

function TCIOTOperacaoTransporte.Obter: Boolean;
var
  CIOTRetorno: TOperacaoTransporteR;
  aMsg  : string;
  Texto : String;
  Acao  : TStringList;
  Stream: TMemoryStream;
  StrStream: TStringStream;

  {$IFDEF ACBrCTeOpenSSL}
     HTTP: THTTPSend;
  {$ELSE}
     ReqResp: THTTPReqResp;
  {$ENDIF}
begin
  inherited Obter;

  Result := False;

  Acao   := TStringList.Create;
  Stream := TMemoryStream.Create;

  Texto := '<?xml version="1.0" encoding="utf-8"?>';
  Texto := Texto + '<soap12:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap12="http://www.w3.org/2003/05/soap-envelope">';
  Texto := Texto +   '<soap12:Body>';

  if FTipoImpressao = tiPDF then Texto := Texto +   '  <ObterOperacaoTransportePdf xmlns="http://schemas.ipc.adm.br/efrete/pef">'
  else Texto := Texto +   '  <ObterOperacaoTransporteParaImpressao xmlns="http://schemas.ipc.adm.br/efrete/pef">';

  Texto := Texto + FDadosMsg;

  if FTipoImpressao = tiPDF then Texto := Texto +   '  </ObterOperacaoTransportePdf>'
  else Texto := Texto +   '  </ObterOperacaoTransporteParaImpressao>';

  Texto := Texto +   '</soap12:Body>';
  Texto := Texto + '</soap12:Envelope>';

  Acao.Text := Texto;

  {$IFDEF ACBrCTeOpenSSL}
     Acao.SaveToStream(Stream);
     HTTP := THTTPSend.Create;
  {$ELSE}
     ReqResp := THTTPReqResp.Create(nil);
     ConfiguraReqResp( ReqResp );
     ReqResp.URL := Trim(FURL);
     ReqResp.UseUTF8InHeader := True;

     if FTipoImpressao = tiPDF then ReqResp.SoapAction := 'http://schemas.ipc.adm.br/efrete/pef/ObterOperacaoTransportePdf'
     else ReqResp.SoapAction := 'http://schemas.ipc.adm.br/efrete/pef/ObterOperacaoTransporteParaImpressao';
  {$ENDIF}

  try
    TAmSCIOT( FAmSCIOT ).SetStatus( stCIOTObtendo );
    if FConfiguracoes.Geral.Salvar then
     begin
       FPathArqEnv := FormatDateTime('yyyymmddhhnnss',Now)+'-obter-operacao_transporte.xml';
       FConfiguracoes.Geral.Save(FPathArqEnv, FDadosMsg, FConfiguracoes.Arquivos.PathLog);
     end;

    try
      {$IFDEF ACBrCTeOpenSSL}
         HTTP.Document.LoadFromStream(Stream);
         if FTipoImpressao = tiPDF then ConfiguraHTTP(HTTP,'SOAPAction: "http://schemas.ipc.adm.br/efrete/pef/ObterOperacaoTransportePdf"')
         else ConfiguraHTTP(HTTP,'SOAPAction: "http://schemas.ipc.adm.br/efrete/pef/ObterOperacaoTransporteParaImpressao"');

         HTTP.HTTPMethod('POST', FURL);
         StrStream := TStringStream.Create('') ;
         StrStream.CopyFrom(HTTP.Document, 0);
         FRetornoWS := TiraAcentos(ParseText(StrStream.DataString, True));
         StrStream.Free;
      {$ELSE}
         ReqResp.Execute(Acao.Text, Stream);
         StrStream := TStringStream.Create('');
         StrStream.CopyFrom(Stream, 0);
         FRetornoWS := TiraAcentos(ParseText(StrStream.DataString, True));
         StrStream.Free;
      {$ENDIF}

      if FTipoImpressao = tiPDF then FRetWS := SeparaDados( FRetornoWS, 'ObterOperacaoTransportePdfResponse')
      else FRetWS := SeparaDados( FRetornoWS, 'ObterOperacaoTransporteParaImpressaoResponse');

      CIOTRetorno := TOperacaoTransporteR.Create(FOperacoesTransporte.Items[0]);
      CIOTRetorno.Leitor.Arquivo := FRetWS;
      CIOTRetorno.LerXml;

      TAmSCIOT( FAmSCIOT ).SetStatus( stCIOTIdle );
      aMsg := 'Placa : '+CIOTRetorno.OperacaoTransporte.Contratado.CpfOuCnpj+LineBreak+
              'Ano Modelo : '+CIOTRetorno.OperacaoTransporte.CodigoIdentificacaoOperacaoPrincipal+LineBreak+
              'Ano Fabricacao : '+DateToStr(CIOTRetorno.OperacaoTransporte.DataFimViagem)+LineBreak +
              'Sucesso : '+BoolToStr(CIOTRetorno.Sucesso)+LineBreak+
              'Mensagem : '+CIOTRetorno.Mensagem+LineBreak;

      if FConfiguracoes.WebServices.Visualizar then
        ShowMessage(aMsg);

      if Assigned(TAmSCIOT( FAmSCIOT ).OnGerarLog) then
         TAmSCIOT( FAmSCIOT ).OnGerarLog(aMsg);

      FMsg   := LineBreak+CIOTRetorno.Mensagem;
      Result := (CIOTRetorno.Sucesso);

      FSucesso := CIOTRetorno.Sucesso;
      FMensagem := CIOTRetorno.Mensagem;

      CIOTRetorno.Free;

      if FConfiguracoes.Geral.Salvar then
       begin
         FPathArqResp := FormatDateTime('yyyymmddhhnnss',Now)+'-response-operacao_transporte.xml';
         FConfiguracoes.Geral.Save(FPathArqResp, FRetWS, FConfiguracoes.Arquivos.PathLog);
       end;

    except on E: Exception do
      begin
       if Assigned(TAmSCIOT( FAmSCIOT ).OnGerarLog) then
          TAmSCIOT( FAmSCIOT ).OnGerarLog('WebService Operacao de Transporte:'+LineBreak+
                                          '- Inativo ou Inoperante tente novamente.'+LineBreak+
                              '- '+FMensagem + LineBreak +
                              '- '+E.Message);
       raise Exception.Create('WebService Operacao de Transporte:'+LineBreak+
                              '- Inativo ou Inoperante tente novamente.'+LineBreak+
                              '- '+FMensagem + LineBreak +
                              '- '+E.Message);
      end;
    end;

  finally
    {$IFDEF ACBrCTeOpenSSL}
       HTTP.Free;
    {$ELSE}
      ReqResp.Free;
    {$ENDIF}
    Acao.Free;
    Stream.Free;
    DFeUtil.ConfAmbiente;
    TAmSCIOT( FAmSCIOT ).SetStatus( stCIOTIdle );
  end;
end;

function TCIOTOperacaoTransporte.Adicionar: Boolean;
var
  CIOTRetorno: TOperacaoTransporteR;
  aMsg  : string;
  Texto : String;
  Acao  : TStringList;
  Stream: TMemoryStream;
  StrStream: TStringStream;

  {$IFDEF ACBrCTeOpenSSL}
     HTTP: THTTPSend;
  {$ELSE}
     ReqResp: THTTPReqResp;
  {$ENDIF}
begin
  inherited Adicionar;

  Result := False;

  Acao   := TStringList.Create;
  Stream := TMemoryStream.Create;

  Texto := '<?xml version="1.0" encoding="utf-8"?>';
  Texto := Texto + '<soap12:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap12="http://www.w3.org/2003/05/soap-envelope">';
  Texto := Texto +   '<soap12:Body>';
  Texto := Texto +   '  <AdicionarOperacaoTransporte xmlns="http://schemas.ipc.adm.br/efrete/pef">';
  Texto := Texto + FDadosMsg;
  Texto := Texto +   '  </AdicionarOperacaoTransporte>';
  Texto := Texto +   '</soap12:Body>';
  Texto := Texto + '</soap12:Envelope>';

  Acao.Text := Texto;

  {$IFDEF ACBrCTeOpenSSL}
     Acao.SaveToStream(Stream);
     HTTP := THTTPSend.Create;
  {$ELSE}
     ReqResp := THTTPReqResp.Create(nil);
     ConfiguraReqResp( ReqResp );
     ReqResp.URL := Trim(FURL);
     ReqResp.UseUTF8InHeader := True;
     ReqResp.SoapAction := 'http://schemas.ipc.adm.br/efrete/pef/AdicionarOperacaoTransporte';
  {$ENDIF}

  try
    TAmSCIOT( FAmSCIOT ).SetStatus( stCIOTObtendo );
    if FConfiguracoes.Geral.Salvar then
     begin
       FPathArqEnv := FormatDateTime('yyyymmddhhnnss',Now)+'-adicionar-OperacaoTransporte.xml';
       FConfiguracoes.Geral.Save(FPathArqEnv, FDadosMsg, FConfiguracoes.Arquivos.PathLog);
     end;

    try
      {$IFDEF ACBrCTeOpenSSL}
         HTTP.Document.LoadFromStream(Stream);
         ConfiguraHTTP(HTTP,'SOAPAction: "http://schemas.ipc.adm.br/efrete/pef/AdicionarOperacaoTransporte"');
         HTTP.HTTPMethod('POST', FURL);
         StrStream := TStringStream.Create('') ;
         StrStream.CopyFrom(HTTP.Document, 0);

         FRetornoWS := TiraAcentos(ParseText(StrStream.DataString, True));
         FRetWS := SeparaDados( FRetornoWS, 'AdicionarOperacaoTransporteResponse');
         StrStream.Free;
      {$ELSE}
         ReqResp.Execute(Acao.Text, Stream);
         StrStream := TStringStream.Create('');
         StrStream.CopyFrom(Stream, 0);
         FRetornoWS := TiraAcentos(ParseText(StrStream.DataString, True));
         FRetWS := SeparaDados( FRetornoWS, 'AdicionarOperacaoTransporteResponse');
         StrStream.Free;
      {$ENDIF}

      CIOTRetorno := TOperacaoTransporteR.Create(FOperacoesTransporte.Items[0], opAdicionar);
      CIOTRetorno.Leitor.Arquivo := FRetWS;
      CIOTRetorno.LerXml;

      TAmSCIOT( FAmSCIOT ).SetStatus( stCIOTIdle );
      aMsg := 'CIOT Gerado: '+CIOTRetorno.OperacaoTransporte.NumeroCIOT+LineBreak+
              'Mensagem : '+CIOTRetorno.Mensagem+LineBreak;

      if FConfiguracoes.WebServices.Visualizar then
        ShowMessage(aMsg);

      if Assigned(TAmSCIOT( FAmSCIOT ).OnGerarLog) then
         TAmSCIOT( FAmSCIOT ).OnGerarLog(aMsg);

      FMsg   := LineBreak+CIOTRetorno.Mensagem;
      Result := (CIOTRetorno.Sucesso);

      FSucesso := CIOTRetorno.Sucesso;
      FMensagem := CIOTRetorno.Mensagem;

      CIOTRetorno.Free;

      if FConfiguracoes.Geral.Salvar then
       begin
         FPathArqResp := FormatDateTime('yyyymmddhhnnss',Now)+'-response-AddOperacaoTransporte.xml';
         FConfiguracoes.Geral.Save(FPathArqResp, FRetWS, FConfiguracoes.Arquivos.PathLog);
       end;

    except on E: Exception do
      begin
       if Assigned(TAmSCIOT( FAmSCIOT ).OnGerarLog) then
          TAmSCIOT( FAmSCIOT ).OnGerarLog('WebService OperacaoTransporte (Inclusao):'+LineBreak+
                                          '- Inativo ou Inoperante tente novamente.'+LineBreak+
                              '- '+FMensagem + LineBreak +
                              '- '+E.Message);
       raise Exception.Create('WebService OperacaoTransporte (Inclusao):'+LineBreak+
                              '- Inativo ou Inoperante tente novamente.'+LineBreak+
                              '- '+FMensagem + LineBreak +
                              '- '+E.Message);
      end;
    end;

  finally
    {$IFDEF ACBrCTeOpenSSL}
       HTTP.Free;
    {$ELSE}
      ReqResp.Free;
    {$ENDIF}
    Acao.Free;
    Stream.Free;
    DFeUtil.ConfAmbiente;
    TAmSCIOT( FAmSCIOT ).SetStatus( stCIOTIdle );
  end;
end;

end.

