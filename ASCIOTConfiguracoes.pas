{$I ACBr.inc}

unit ASCIOTConfiguracoes;

interface

uses
  ASCIOTUtil, pciotCIOT,
 {$IFNDEF ACBrCTeOpenSSL}
  ACBrCAPICOM_TLB, JwaWinCrypt, JwaWinType, ACBrMSXML2_TLB,
 {$ENDIF}
  Classes, Sysutils, pcnConversao, ActiveX;

{$IFNDEF ACBrCTeOpenSSL}
  const CAPICOM_STORE_NAME = 'My'; //My CA Root AddressBook
{$ENDIF}

type

  TCertificadosConf = class(TComponent)
  private
    FSenhaCert: AnsiString;
    {$IFDEF ACBrCTeOpenSSL}
       FCertificado: AnsiString;
    {$ELSE}
       FNumeroSerie: AnsiString;
       FDataVenc: TDateTime;
       procedure SetNumeroSerie(const Value: AnsiString);
       function GetNumeroSerie: AnsiString;
       function GetDataVenc: TDateTime;
    {$ENDIF}
  public
    {$IFNDEF ACBrCTeOpenSSL}
       function SelecionarCertificado:AnsiString;
       function GetCertificado: ICertificate2;
    {$ENDIF}
  published
    {$IFDEF ACBrCTeOpenSSL}
       property Certificado: AnsiString read FCertificado write FCertificado;
    {$ELSE}
       property NumeroSerie: AnsiString read GetNumeroSerie write SetNumeroSerie;
       property DataVenc: TDateTime read GetDataVenc;
    {$ENDIF}
       property Senha: AnsiString read FSenhaCert write FSenhaCert;
  end;

  TWebServicesConf = Class(TComponent)
  private
    FVisualizar : Boolean;
    FAmbiente: TpcnTipoAmbiente;
    FAmbienteCodigo: Integer;
    FProxyHost: String;
    FProxyPort: String;
    FProxyUser: String;
    FProxyPass: String;
    FAguardarConsultaRet : Cardinal;
    FTentativas : Integer;
    FIntervaloTentativas : Cardinal;
    FAjustaAguardaConsultaRet : Boolean;
    procedure SetAmbiente(AValue: TpcnTipoAmbiente);
    procedure SetTentativas(const Value: Integer);
    procedure SetIntervaloTentativas(const Value: Cardinal);
  public
    constructor Create(AOwner: TComponent); override ;
  published
    property Visualizar: Boolean read FVisualizar write FVisualizar default False ;
    property Ambiente: TpcnTipoAmbiente read FAmbiente write SetAmbiente default taHomologacao ;
    property AmbienteCodigo: Integer read FAmbienteCodigo;
    property ProxyHost: String read FProxyHost write FProxyHost;
    property ProxyPort: String read FProxyPort write FProxyPort;
    property ProxyUser: String read FProxyUser write FProxyUser;
    property ProxyPass: String read FProxyPass write FProxyPass;
    property AguardarConsultaRet : Cardinal read FAguardarConsultaRet write FAguardarConsultaRet;
    property Tentativas : Integer read FTentativas write SetTentativas default 5;
    property IntervaloTentativas : Cardinal read FIntervaloTentativas write SetIntervaloTentativas;
    property AjustaAguardaConsultaRet : Boolean read FAjustaAguardaConsultaRet write FAjustaAguardaConsultaRet;
  end;

  TGeralConf = class(TComponent)
  private
    FFormaEmissao: TpcnTipoEmissao;
    FFormaEmissaoCodigo: Integer;
    FSalvar: Boolean;
    FAtualizarXMLCancelado: Boolean;
    FPathSalvar: String;
    FPathSchemas: String;
    FExibirErroSchema: boolean;
    FFormatoAlerta: string;
  {$IFDEF ACBrCTeOpenSSL}
    FIniFinXMLSECAutomatico: boolean;
  {$ENDIF}
    procedure SetFormaEmissao(AValue: TpcnTipoEmissao);
    function GetPathSalvar: String;
    function GetFormatoAlerta: string;
  public
    constructor Create(AOwner: TComponent); override ;
    function Save(AXMLName: String; AXMLFile: WideString; aPath: String = ''): Boolean;
  published
    property FormaEmissao: TpcnTipoEmissao read FFormaEmissao
      write SetFormaEmissao default teNormal ;
    property FormaEmissaoCodigo: Integer read FFormaEmissaoCodigo;
    property Salvar: Boolean read FSalvar write FSalvar default False;
    property AtualizarXMLCancelado: Boolean read FAtualizarXMLCancelado write FAtualizarXMLCancelado default True ;
    property PathSalvar: String read GetPathSalvar write FPathSalvar;
    property PathSchemas: String read FPathSchemas write FPathSchemas;
    property ExibirErroSchema: Boolean read FExibirErroSchema write FExibirErroSchema;
    property FormatoAlerta: string read GetFormatoAlerta write FFormatoAlerta;
  {$IFDEF ACBrCTeOpenSSL}
    property IniFinXMLSECAutomatico: Boolean read FIniFinXMLSECAutomatico write FIniFinXMLSECAutomatico;
  {$ENDIF}
  end;

  TArquivosConf = class(TComponent)
  private
    FSalvar         : Boolean;
    FMensal         : Boolean;
    FLiteral        : Boolean;
    FPathPDF: String;
    FPathLog: String;
  public
    constructor Create(AOwner: TComponent); override ;
  published
    property Salvar     : Boolean read FSalvar  write FSalvar  default False ;
    property PastaMensal: Boolean read FMensal  write FMensal  default False ;
    property AdicionarLiteral: Boolean read FLiteral write FLiteral default False ;
    property PathLog : String read FPathLog  write FPathLog;
    property PathPDF: String read FPathPDF write FPathPDF;
  end;

  TConfiguracoes = class(TComponent)
  private
    FGeral: TGeralConf;
    FWebServices: TWebServicesConf;
    FCertificados: TCertificadosConf;
    FArquivos: TArquivosConf;
    FIntegradora: TIntegradora;
    procedure setIntegradora(const Value: TIntegradora);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Geral: TGeralConf read FGeral ;
    property WebServices: TWebServicesConf read FWebServices ;
    property Certificados: TCertificadosConf read FCertificados ;
    property Integradora: TIntegradora read FIntegradora write setIntegradora;
    property Arquivos: TArquivosConf read FArquivos ;
  end;

implementation

uses Math, StrUtils, ACBrUtil, ACBrDFeUtil, DateUtils;

{ TConfiguracoes }

constructor TConfiguracoes.Create(AOwner: TComponent);
begin
  inherited Create( AOwner ) ;

  FGeral      := TGeralConf.Create(Self);
  FGeral.Name := 'GeralConf' ;
  {$IFDEF COMPILER6_UP}
   FGeral.SetSubComponent( true );{ para gravar no DFM/XFM }
  {$ENDIF}

  FWebServices      := TWebServicesConf.Create(self);
  FWebServices.Name := 'WebServicesConf' ;
  {$IFDEF COMPILER6_UP}
   FWebServices.SetSubComponent( true );{ para gravar no DFM/XFM }
  {$ENDIF}

  FCertificados      := TCertificadosConf.Create(self);
  FCertificados.Name := 'CertificadosConf' ;
  {$IFDEF COMPILER6_UP}
   FCertificados.SetSubComponent( true );{ para gravar no DFM/XFM }
  {$ENDIF}

  FArquivos      := TArquivosConf.Create(self);
  FArquivos.Name := 'ArquivosConf' ;
  {$IFDEF COMPILER6_UP}
   FArquivos.SetSubComponent( true );{ para gravar no DFM/XFM }
  {$ENDIF}

  FIntegradora := TIntegradora.Create;
end;

destructor TConfiguracoes.Destroy;
begin
  FGeral.Free;
  FWebServices.Free;
  FCertificados.Free;
  FArquivos.Free;
  FIntegradora.Free;
  inherited;
end;

procedure TConfiguracoes.setIntegradora(const Value: TIntegradora);
begin
  FIntegradora := Value;
end;

{ TGeralConf }

constructor TGeralConf.Create(AOwner: TComponent);
begin
  Inherited Create( AOwner );

  FFormaEmissao          := teNormal;
  FFormaEmissaoCodigo    := StrToInt(TpEmisToStr(FFormaEmissao));
  FSalvar                := False;
  FAtualizarXMLCancelado := True;
  FPathSalvar            := '' ;
  FPathSchemas           := '' ;
  FExibirErroSchema      := True;
  FFormatoAlerta         := 'TAG:%TAGNIVEL% ID:%ID%/%TAG%(%DESCRICAO%) - %MSG%.';
  // O Formato da mensagem de erro pode ser alterado pelo usuario alterando-se a property FFormatoAlerta: onde;
  // %TAGNIVEL%  : Representa o Nivel da TAG; ex: <transp><vol><lacres>
  // %TAG%       : Representa a TAG; ex: <nLacre>
  // %ID%        : Representa a ID da TAG; ex X34
  // %MSG%       : Representa a mensagem de alerta
  // %DESCRICAO% : Representa a Descrição da TAG
{$IFDEF ACBrCTeOpenSSL}
  FIniFinXMLSECAutomatico:=True;
{$ENDIF}
end;

function TGeralConf.GetFormatoAlerta: string;
begin
  if (FFormatoAlerta = '') or (
     (pos('%TAGNIVEL%',FFormatoAlerta) <= 0) and
     (pos('%TAG%',FFormatoAlerta) <= 0) and
     (pos('%ID%',FFormatoAlerta) <= 0) and
     (pos('%MSG%',FFormatoAlerta) <= 0) and
     (pos('%DESCRICAO%',FFormatoAlerta) <= 0) )then
     Result := 'TAG:%TAGNIVEL% ID:%ID%/%TAG%(%DESCRICAO%) - %MSG%.'
  else
     Result := FFormatoAlerta;
end;

function TGeralConf.GetPathSalvar: String;
begin
  if DFeUtil.EstaVazio(FPathSalvar) then
    Result := DFeUtil.PathAplication
  else
    Result := FPathSalvar;

  Result := PathWithDelim( Trim(Result) ) ;
end;

function TGeralConf.Save(AXMLName: String; AXMLFile: WideString; aPath: String = ''): Boolean;
var
  vSalvar: TStrings;
begin
  Result  := False;
  vSalvar := TStringList.Create;
  try
    try
      if DFeUtil.NaoEstaVazio(ExtractFilePath(AXMLName)) then
       begin
         aPath    := ExtractFilePath(AXMLName);
         AXMLName := StringReplace(AXMLName,aPath,'',[rfIgnoreCase]);
       end
      else
       begin
         if DFeUtil.EstaVazio(aPath) then
            aPath := PathSalvar
         else
            aPath := PathWithDelim(aPath);
       end;

      vSalvar.Text := AXMLFile;
      if not DirectoryExists( aPath ) then
         ForceDirectories( aPath );

      vSalvar.SaveToFile( aPath + AXMLName);
      Result := True;
    except on E: Exception do
      raise Exception.Create('Erro ao salvar .'+E.Message);
    end;
  finally
    vSalvar.Free;
  end;
end;

procedure TGeralConf.SetFormaEmissao(AValue: TpcnTipoEmissao);
begin
  FFormaEmissao       := AValue;
  FFormaEmissaoCodigo := StrToInt(TpEmisToStr(FFormaEmissao));
end;

{ TWebServicesConf }

constructor TWebServicesConf.Create(AOwner: TComponent);
begin
  Inherited Create( AOwner );

  FAmbiente       := taHomologacao;
  FVisualizar     := False ;
  FAmbienteCodigo := StrToInt(TpAmbToStr(FAmbiente));
end;

procedure TWebServicesConf.SetAmbiente(AValue: TpcnTipoAmbiente);
begin
  FAmbiente       := AValue;
  FAmbienteCodigo := StrToInt(TpAmbToStr(AValue));
end;

procedure TWebServicesConf.SetIntervaloTentativas(const Value: Cardinal);
begin
  if (Value > 0) and (Value < 1000) then
     FIntervaloTentativas := 1000
  else
     FIntervaloTentativas := Value;
end;

procedure TWebServicesConf.SetTentativas(const Value: Integer);
begin
  if Value <= 0 then
     FTentativas := 5
  else
     FTentativas := Value;
end;

{ TCertificadosConf }

{$IFNDEF ACBrCTeOpenSSL}
function TCertificadosConf.GetCertificado: ICertificate2;
var
  Store : IStore3;
  Certs : ICertificates2;
  Cert  : ICertificate2;
  i     : Integer;

  xmldoc  : IXMLDOMDocument3;
  xmldsig : IXMLDigitalSignature;
  dsigKey : IXMLDSigKey;
  SigKey  : IXMLDSigKeyEx;

  PrivateKey     : IPrivateKey;
  hCryptProvider : HCRYPTPROV;

  XML : String;
begin
  CoInitialize(nil); // PERMITE O USO DE THREAD
  if DFeUtil.EstaVazio( FNumeroSerie ) then
    raise Exception.Create('Número de Série do Certificado Digital não especificado !');

  Result := nil;
  Store  := CoStore.Create;
  Store.Open(CAPICOM_CURRENT_USER_STORE, CAPICOM_STORE_NAME, CAPICOM_STORE_OPEN_MAXIMUM_ALLOWED);

  Certs := Store.Certificates as ICertificates2;
  for i:= 1 to Certs.Count do
  begin
    Cert := IInterface(Certs.Item[i]) as ICertificate2;
    if Cert.SerialNumber = FNumeroSerie then
    begin
      if DFeUtil.EstaVazio(NumCertCarregado) then
         NumCertCarregado := Cert.SerialNumber;

      PrivateKey := Cert.PrivateKey;

      if  CertStoreMem = nil then
       begin
         CertStoreMem := CoStore.Create;
         CertStoreMem.Open(CAPICOM_MEMORY_STORE, 'Memoria', CAPICOM_STORE_OPEN_MAXIMUM_ALLOWED);
         CertStoreMem.Add(Cert);

         if (FSenhaCert <> '') and PrivateKey.IsHardwareDevice then
          begin
            XML := XML + '<Signature xmlns="http://www.w3.org/2000/09/xmldsig#"><SignedInfo><CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"/><SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1" />';
            XML := XML + '<Reference URI="#">';
            XML := XML + '<Transforms><Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature" /><Transform Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315" /></Transforms><DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1" />';
            XML := XML + '<DigestValue></DigestValue></Reference></SignedInfo><SignatureValue></SignatureValue><KeyInfo></KeyInfo></Signature>';

            xmldoc                    := CoDOMDocument50.Create;
            xmldoc.async              := False;
            xmldoc.validateOnParse    := False;
            xmldoc.preserveWhiteSpace := True;
            xmldoc.loadXML(XML);
            xmldoc.setProperty('SelectionNamespaces', DSIGNS);

            xmldsig           := CoMXDigitalSignature50.Create;
            xmldsig.signature := xmldoc.selectSingleNode('.//ds:Signature');
            xmldsig.store     := CertStoreMem;

            dsigKey := xmldsig.createKeyFromCSP(PrivateKey.ProviderType, PrivateKey.ProviderName, PrivateKey.ContainerName, 0);
            if (dsigKey = nil) then
               raise Exception.Create('Erro ao criar a chave do CSP.');

            SigKey := dsigKey as IXMLDSigKeyEx;
            SigKey.getCSPHandle( hCryptProvider );

            try
              CryptSetProvParam( hCryptProvider , PP_SIGNATURE_PIN, LPBYTE(FSenhaCert), 0 );
            finally
              CryptReleaseContext(hCryptProvider, 0);
            end;

            SigKey  := nil;
            dsigKey := nil;
            xmldsig := nil;
            xmldoc  := nil;
         end;
       end;

      Result    := Cert;
      FDataVenc := Cert.ValidToDate;
      break;
    end;
  end;

  if not(Assigned(Result)) then
    raise Exception.Create('Certificado Digital não encontrado!');
   CoUninitialize;
end;

function TCertificadosConf.GetNumeroSerie: AnsiString;
begin
  Result := Trim(UpperCase(StringReplace(FNumeroSerie,' ','',[rfReplaceAll] )));
end;

procedure TCertificadosConf.SetNumeroSerie(const Value: AnsiString);
begin
  FNumeroSerie := Trim(UpperCase(StringReplace(Value,' ','',[rfReplaceAll] )));
end;

function TCertificadosConf.SelecionarCertificado: AnsiString;
var
  Store  : IStore3;
  Certs  : ICertificates2;
  Certs2 : ICertificates2;
  Cert   : ICertificate2;
begin
  CoInitialize(nil); // PERMITE O USO DE THREAD
  Store := CoStore.Create;
  Store.Open(CAPICOM_CURRENT_USER_STORE, CAPICOM_STORE_NAME, CAPICOM_STORE_OPEN_MAXIMUM_ALLOWED);

  Certs  := Store.Certificates as ICertificates2;
  Certs2 := Certs.Select('Certificado(s) Digital(is) disponível(is)', 'Selecione o Certificado Digital para uso no aplicativo', false);

  if not(Certs2.Count = 0) then
  begin
    Cert         := IInterface(Certs2.Item[1]) as ICertificate2;
    FNumeroSerie := Cert.SerialNumber;
    FDataVenc    := Cert.ValidToDate;
  end;

  Result := FNumeroSerie;
  CoUninitialize;
end;

function TCertificadosConf.GetDataVenc: TDateTime;
begin
 if DFeUtil.NaoEstaVazio(FNumeroSerie) then
  begin
    if FDataVenc = 0 then
       GetCertificado;
    Result := FDataVenc;
  end
 else
    Result := 0;
end;
{$ENDIF}

{ TArquivosConf }

constructor TArquivosConf.Create(AOwner: TComponent);
begin
  inherited;
end;


end.
