{$I ACBr.inc}

unit ASCIOTUtil;

interface

uses
{$IFNDEF ACBrCTeOpenSSL}
  ACBrCAPICOM_TLB, ACBrMSXML2_TLB, JwaWinCrypt,
{$ENDIF}
  Classes, Forms,
{$IFDEF FPC}
  LResources, Controls, Graphics, Dialogs,
{$ELSE}
  StrUtils, Winapi.Windows,
{$ENDIF}
  pcnConversao, ACBrDFeUtil, Vcl.Controls,

  shellapi, printers, System.DateUtils;


type
  TpciotIntegradora = (IeFrete, INDDDigita, IPamcary, IPolicard, IRepom, IRodocred, ITicket);
  TpciotTipoViagem = (Indefinido, Padrao, TAC_Agregado);
  TpciotTipoPagamento = (TransferenciaBancaria, eFRETE);
  TpciotViagemTipoDeCalculo = (SemQuebra, QuebraSomenteUltrapassado, QuebraIntegral);
  TpciotUnidadeDeMedidaDaMercadoria = (umIndefinido, umTonelada, umKg);
  TpciotTipoProporcao = (tpNenhum, tpPorcentagem, tpValorAbsoluto);
  TpciotDiferencaFreteTipo = (SemDiferenca, SomenteUltrapassado, Integral);
  TpciotDiferencaFreteBaseCalculo = (QuantidadeDesembarque, QuantidadeMenor);
  TpciotOperacao = (opObter, opAdicionar, opRetificar, opCancelar, opAdicionarViagem, opAdicionarPagamento, opCancelarPagamento, opEncerrar);
  TpciotTipoImpressao = (tiPDF, tiHTML);
  TpciotTipoProprietario = (tpTAC, tpETC, tpCTC);
  TpciotTipoCategoriaPagamento = (Adiantamento, Estadia, Quitacao, SemCategoria);
  TStatusACBrCIOT = ( stCIOTIdle, stCIOTObtendo, stCIOTAdicionando, stCIOTEmail);

  TLayOut = (LayVeiculo, LayMotorista, LayProprietario, LayOperacaoTransporte);

  TGeradorOpcoes = class;

  TGerador = class(TPersistent)
  private
    FArquivoFormatoXML: AnsiString;
    FArquivoFormatoTXT: AnsiString;
    FLayoutArquivoTXT: TstringList;
    FListaDeAlertas: TStringList;
    FTagNivel: string;
    FIDNivel: string;
    FOpcoes: TGeradorOpcoes;
    FPrefixo : string;
  public
    FIgnorarTagNivel: string;
    FIgnorarTagIdentacao: string;
    constructor Create;
    destructor Destroy; override;
    function SalvarArquivo(const CaminhoArquivo: string; const FormatoGravacao: TpcnFormatoGravacao = fgXML): Boolean;
    procedure wGrupo(const TAG: string; ID: string = ''; const Identar: Boolean = True);
    procedure wCampo(const Tipo: TpcnTipoCampo; ID, TAG: string; const min, max, ocorrencias: smallint; const valor: variant; const Descricao: string = ''; const NameSpace: string = '');
    procedure wAlerta(const ID, TAG, Descricao, Alerta: string);
    procedure wTexto(const Texto: string);
    procedure gtNivel(ID: string);
    procedure gtCampo(const Tag, ConteudoProcessado: string);
    procedure gtAjustarRegistros(const ID: string);
  published
    property ArquivoFormatoXML: AnsiString read FArquivoFormatoXML write FArquivoFormatoXML;
    property ArquivoFormatoTXT: AnsiString read FArquivoFormatoTXT write FArquivoFormatoTXT;
    property IDNivel: string read FIDNivel write FIDNivel;
    property ListaDeAlertas: TStringList read FListaDeAlertas write FListaDeAlertas;
    property LayoutArquivoTXT: TStringList read FLayoutArquivoTXT write FLayoutArquivoTXT;
    property Opcoes: TGeradorOpcoes read FOpcoes write FOpcoes;
    property Prefixo: string read FPrefixo write FPrefixo;
  end;

  TGeradorOpcoes = class(TPersistent)
  private
    FSomenteValidar: boolean;
    FIdentarXML: boolean;
    FRetirarEspacos: boolean;
    FRetirarAcentos: boolean;
    FNivelIdentacao: integer;
    FTamanhoIdentacao: integer;
    FSuprimirDecimais: boolean;
    FTagVaziaNoFormatoResumido: boolean;
    FFormatoAlerta: string;
  published
    property SomenteValidar: boolean read FSomenteValidar write FSomenteValidar;
    property RetirarEspacos: boolean read FRetirarEspacos write FRetirarEspacos;
    property RetirarAcentos: boolean read FRetirarAcentos write FRetirarAcentos;
    property IdentarXML: boolean read FIdentarXML write FIdentarXML;
    property TamanhoIdentacao: integer read FTamanhoIdentacao write FTamanhoIdentacao;
    property SuprimirDecimais: boolean read FSuprimirDecimais write FSuprimirDecimais;
    property TagVaziaNoFormatoResumido: boolean read FTagVaziaNoFormatoResumido write FTagVaziaNoFormatoResumido;
    property FormatoAlerta: string read FFormatoAlerta write FFormatoAlerta;
  end;

  TLeitor = class(TPersistent)
  private
    FArquivo: AnsiString;
    FGrupo: AnsiString;
    FNivel: TStringList;
  public
    constructor Create;
    destructor Destroy; override;
    function rExtrai(const nivel: integer; const TagInicio: string; TagFim: string = ''; const item: integer = 1): AnsiString;
    function rCampo(const Tipo: TpcnTipoCampo; TAG: string; TAGparada: string = ''): variant;
    function rCampoCNPJCPF(TAGparada: string = ''): string;
    function rAtributo(Atributo: string): variant;
    function CarregarArquivo(const CaminhoArquivo: string): boolean; overload;
    function CarregarArquivo(const Stream: TStringStream): boolean; overload;
    function PosLast(const SubStr, S: AnsiString ): Integer;
  published
    property Arquivo: AnsiString read FArquivo write FArquivo;
    property Grupo: AnsiString read FGrupo write FGrupo;
  end;



const
  NAME_SPACE_EFRETE_OBJECTS = 'xmlns="http://schemas.ipc.adm.br/efrete/objects"';
  NAME_SPACE_EFRETE_PEFOBTER_OBJECTS = 'xmlns="http://schemas.ipc.adm.br/efrete/pef/ObterOperacaoTransporteObjects"';
  NAME_SPACE_EFRETE_PEFADICIONAR_OBJECTS = 'xmlns="http://schemas.ipc.adm.br/efrete/pef/AdicionarOperacaoTransporte"';
  NAME_SPACE_EFRETE_PEFADICIONAR_VIAGEM = 'xmlns="http://schemas.ipc.adm.br/efrete/pef/AdicionarViagem"';
  NAME_SPACE_EFRETE_PEFADICIONAR_PAGAMENTOS = 'xmlns="http://schemas.ipc.adm.br/efrete/pef/AdicionarPagamento"';
  NAME_SPACE_EFRETE_PEFENCERRAR_OPERACAO = 'xmlns="http://schemas.ipc.adm.br/efrete/pef/EncerrarOperacaoTransporte"';

  NAME_SPACE_EFRETE_PEFRETIFICAR_OBJECTS = 'xmlns="http://schemas.ipc.adm.br/efrete/pef/RetificarOperacaoTransporte"';
  NAME_SPACE_EFRETE_OPERACAOTRANSPORTE_EFRETE = 'xmlns="http://schemas.ipc.adm.br/efrete/pef/objects"';

  NAME_SPACE_EFRETE_VEICULOS_EFRETE = 'xmlns="http://schemas.ipc.adm.br/efrete/veiculos/objects"';
  NAME_SPACE_EFRETE_MOTORISTAS_EFRETE = 'xmlns="http://schemas.ipc.adm.br/efrete/motoristas/objects"';
  NAME_SPACE_EFRETE_PROPRIETARIOS_EFRETE = 'xmlns="http://schemas.ipc.adm.br/efrete/proprietarios/objects"';



  ERR_MSG_MAIOR = 'Tamanho maior que o máximo permitido';
  ERR_MSG_MENOR = 'Tamanho menor que o mínimo permitido';
  ERR_MSG_VAZIO = 'Nenhum valor informado';
  ERR_MSG_INVALIDO = 'Conteúdo inválido';
  ERR_MSG_MAXIMO_DECIMAIS = 'Numero máximo de casas decimais permitidas';
  ERR_MSG_MAIOR_MAXIMO = 'Número de ocorrências maior que o máximo permitido - Máximo ';
  ERR_MSG_GERAR_CHAVE = 'Erro ao gerar a chave da NFe!';
  ERR_MSG_FINAL_MENOR_INICIAL = 'O numero final não pode ser menor que o inicial';
  ERR_MSG_ARQUIVO_NAO_ENCONTRADO = 'Arquivo não encontrado';
  ERR_MSG_SOMENTE_UM = 'Somente um campo deve ser preenchido';
 // Incluido por Italo em 18/07/2012
  ERR_MSG_MENOR_MINIMO = 'Número de ocorrências menor que o mínimo permitido - Mínimo ';



{$IFDEF ACBrCTeOpenSSL}

  cDTD     = '<!DOCTYPE test [<!ATTLIST inFCIOT Id ID #IMPLIED>]>';
  cDTDCanc = '<!DOCTYPE test [<!ATTLIST infCanc Id ID #IMPLIED>]>';
  cDTDInut = '<!DOCTYPE test [<!ATTLIST infInut Id ID #IMPLIED>]>';
  cDTDEven = '<!DOCTYPE test [<!ATTLIST infEvento Id ID #IMPLIED>]>';
{$ELSE}

  DSIGNS = 'xmlns:ds="http://www.w3.org/2000/09/xmldsig#"';
{$ENDIF}
{$IFNDEF ACBrCTeOpenSSL}
var
  CertStore    : IStore3;
  CertStoreMem : IStore3;
  PrivateKey   : IPrivateKey;
  Certs        : ICertificates2;
  Cert         : ICertificate2;
  NumCertCarregado : String;
{$ENDIF}

type
  CIOTUtil = class
  private
    class function GetURLeFrete(AAmbiente: Integer; ALayOut: TLayOut): WideString;
  protected
  public
    class function GetURL(const AIntegradora: TpciotIntegradora; const AAmbiente: Integer; ALayOut: TLayOut): WideString;
    class function ImprimirArquivo(const ANomeArquivo: string): Boolean;
    class function ImprimirArquivoDebenuPDF(const ANomeArquivo: string): Boolean;

    class function FormatarValor(mask: TpcteMask; const AValue: real): string;
  end;



function TpViagemToStr(const t: TpciotTipoViagem): string;
function StrToTpViagem(var ok: boolean; const s: string): TpciotTipoViagem;
function TpProprietarioToStr(const t: TpciotTipoProprietario): string;
function StrToTpProprietario(var ok: boolean; const s: string): TpciotTipoProprietario;
function TpCatPagToStr(const t: TpciotTipoCategoriaPagamento): string;
function StrToTpCatPag(var ok: boolean; const s: string): TpciotTipoCategoriaPagamento;
function TpPagamentoToStr(const t: TpciotTipoPagamento): string;
function StrToTpPagamento(var ok: boolean; const s: string): TpciotTipoPagamento;
function TpVgTipoCalculoToStr(const t: TpciotViagemTipoDeCalculo): string;
function StrToTpVgTipoCalculo(var ok: boolean; const s: string): TpciotViagemTipoDeCalculo;
function TpProporcaoToStr(const t: TpciotTipoProporcao): string;
function StrToTpProporcao(var ok: boolean; const s: string): TpciotTipoProporcao;
function TpDiferencaFreteBCToStr(const t: TpciotDiferencaFreteBaseCalculo): string;
function StrToTpDiferencaFreteBC(var ok: boolean; const s: string): TpciotDiferencaFreteBaseCalculo;
function TpUnMedMercToStr(const t: TpciotUnidadeDeMedidaDaMercadoria): string;
function StrToTpTpUnMedMerc(var ok: boolean; const s: string): TpciotUnidadeDeMedidaDaMercadoria;
function TpDifFreteToStr(const t: TpciotDiferencaFreteTipo): string;
function StrToTpDifFrete(var ok: boolean; const s: string): TpciotDiferencaFreteTipo;
function TpCarroceriaToStrTxt(const t: TpcteTipoCarroceria): string;
function TpRodadoToStrTxt(const t: TpcteTipoRodado): string;




implementation

uses
  Sysutils, Variants, ACBrUtil, ACBrConsts, pcnAuxiliar;

{ CIOTUtil }

class function CIOTUtil.GetURL(const AIntegradora: TpciotIntegradora; const AAmbiente: Integer; ALayOut: TLayOut): WideString;
begin
  case AIntegradora of
    IeFrete: Result := CIOTUtil.GetURLeFrete(AAmbiente, ALayout);
  end;

 if Result = '' then
   raise Exception.Create('URL não disponível para a Tecnologia solicitada.');
end;

class function CIOTUtil.GetURLeFrete(AAmbiente: Integer; ALayOut: TLayOut): WideString;
begin
  case ALayOut of
    LayVeiculo: Result := DFeUtil.SeSenao(AAmbiente = 1, 'https://sistema.efrete.com/Services/VeiculosService.asmx', 'https://sistema.efrete.com:6061/Services/VeiculosService.asmx');
    LayMotorista: Result := DFeUtil.SeSenao(AAmbiente = 1, 'https://sistema.efrete.com/Services/MotoristasService.asmx', 'https://sistema.efrete.com:6061/Services/MotoristasService.asmx');
    LayProprietario: Result := DFeUtil.SeSenao(AAmbiente = 1, 'https://sistema.efrete.com/Services/ProprietariosService.asmx', 'https://sistema.efrete.com:6061/Services/ProprietariosService.asmx');
    LayOperacaoTransporte: Result := DFeUtil.SeSenao(AAmbiente = 1, 'https://sistema.efrete.com/Services/PefService.asmx', 'https://sistema.efrete.com:6061/Services/PefService.asmx');

  end;
end;

class function CIOTUtil.FormatarValor(mask: TpcteMask; const AValue: real): string;
begin
  result := FormatFloat(TpMaskToStrText(mask), AValue);
end;

class function CIOTUtil.ImprimirArquivo(const ANomeArquivo: string): Boolean;
begin
  if FileExists(PChar(ANomeArquivo)) then
    ShellExecute(Application.Handle, PChar('print'), PChar(ANomeArquivo), nil, nil, SW_HIDE) ; //PChar('')
end;

class function CIOTUtil.ImprimirArquivoDebenuPDF(const ANomeArquivo: string): Boolean;
type
  tdll = function (PrinterName: WideString; StartPage, EndPage, Options: Integer): Integer;
var
  lHandle                     : THandle;
  vretVersao                  : tdll;
begin
  Result := False;

  try
    try
      lHandle := LoadLibrary(PWideChar('DebenuPDFLibraryLite1012.dll'));

      if lHandle <> 0 then
      begin
        vretVersao := tdll(GetProcAddress(lHandle, 'PrintDocument'));
        vretVersao(PWideChar(ANomeArquivo), 1, 99, 0);

        Result := True;

        vretVersao := nil;
      end
      else
      begin
        result := False;
      end;
    finally
      FreeLibrary(lHandle);
//      LiberarDLL(FindWindow('lHandle',Nil));
    end;
  except
    Result := False;;
    FreeLibrary(lHandle);
  end;

//function TDebenuPDFLibrary1012.PrintDocument(PrinterName: WideString;StartPage, EndPage, Options: Integer): Integer;
//  if FileExists(PChar(ANomeArquivo)) then
//    ShellExecute(Application.Handle, PChar('print'), PChar(ANomeArquivo), nil, nil, SW_HIDE) ; //PChar('')

end;

function TpViagemToStr(const t: TpciotTipoViagem): string;
begin
  result := EnumeradoToStr(t, ['Indefinido', 'Padrao', 'TAC_Agregado'],
                              [Indefinido, Padrao, TAC_Agregado]);
end;

function StrToTpViagem(var ok: boolean; const s: string): TpciotTipoViagem;
begin
  result := StrToEnumerado(ok, s, ['Indefinido', 'Padrao', 'TAC_Agregado'],
                                  [Indefinido, Padrao, TAC_Agregado]);
end;

function TpProprietarioToStr(const t: TpciotTipoProprietario): string;
begin
  result := EnumeradoToStr(t, ['TAC', 'ETC', 'CTC'],
                              [tpTAC, tpETC, tpCTC]);
end;

function StrToTpProprietario(var ok: boolean; const s: string): TpciotTipoProprietario;
begin
  result := StrToEnumerado(ok, s, ['TAC', 'ETC', 'CTC'],
                                  [tpTAC, tpETC, tpCTC]);
end;

function TpCatPagToStr(const t: TpciotTipoCategoriaPagamento): string;
begin
  result := EnumeradoToStr(t, ['Adiantamento', 'Estadia', 'Quitacao', 'SemCategoria'],
                              [Adiantamento, Estadia, Quitacao, SemCategoria]);
end;

function StrToTpCatPag(var ok: boolean; const s: string): TpciotTipoCategoriaPagamento;
begin
  result := StrToEnumerado(ok, s, ['Adiantamento', 'Estadia', 'Quitacao', 'SemCategoria'],
                              [Adiantamento, Estadia, Quitacao, SemCategoria]);
end;

function TpPagamentoToStr(const t: TpciotTipoPagamento): string;
begin
  result := EnumeradoToStr(t, ['TransferenciaBancaria', 'eFRETE'],
                              [TransferenciaBancaria, eFRETE]);
end;

function StrToTpPagamento(var ok: boolean; const s: string): TpciotTipoPagamento;
begin
  result := StrToEnumerado(ok, s, ['TransferenciaBancaria', 'eFRETE'],
                                  [TransferenciaBancaria, eFRETE]);
end;

function TpVgTipoCalculoToStr(const t: TpciotViagemTipoDeCalculo): string;
begin
  result := EnumeradoToStr(t, ['SemQuebra', 'QuebraSomenteUltrapassado', 'QuebraIntegral'],
                              [SemQuebra, QuebraSomenteUltrapassado, QuebraIntegral]);
end;

function StrToTpVgTipoCalculo(var ok: boolean; const s: string): TpciotViagemTipoDeCalculo;
begin
  result := StrToEnumerado(ok, s, ['SemQuebra', 'QuebraSomenteUltrapassado', 'QuebraIntegral'],
                                  [SemQuebra, QuebraSomenteUltrapassado, QuebraIntegral]);
end;

function TpProporcaoToStr(const t: TpciotTipoProporcao): string;
begin
  result := EnumeradoToStr(t, ['Nenhum', 'Porcentagem', 'ValorAbsoluto'],
                              [tpNenhum, tpPorcentagem, tpValorAbsoluto]);
end;

function StrToTpProporcao(var ok: boolean; const s: string): TpciotTipoProporcao;
begin
  result := StrToEnumerado(ok, s, ['Nenhum', 'Porcentagem', 'ValorAbsoluto'],
                                  [tpNenhum, tpPorcentagem, tpValorAbsoluto]);
end;

function TpDiferencaFreteBCToStr(const t: TpciotDiferencaFreteBaseCalculo): string;
begin
  result := EnumeradoToStr(t, ['QuantidadeDesembarque', 'QuantidadeMenor'],
                              [QuantidadeDesembarque, QuantidadeMenor]);
end;

function StrToTpDiferencaFreteBC(var ok: boolean; const s: string): TpciotDiferencaFreteBaseCalculo;
begin
  result := StrToEnumerado(ok, s, ['QuantidadeDesembarque', 'QuantidadeMenor'],
                                  [QuantidadeDesembarque, QuantidadeMenor]);
end;

function TpUnMedMercToStr(const t: TpciotUnidadeDeMedidaDaMercadoria): string;
begin
  result := EnumeradoToStr(t, ['Tonelada', 'Kg'],
                              [umTonelada, umKg]);
end;

function StrToTpTpUnMedMerc(var ok: boolean; const s: string): TpciotUnidadeDeMedidaDaMercadoria;
begin
  result := StrToEnumerado(ok, s, ['Tonelada', 'Kg'],
                                  [umTonelada, umKg]);
end;

function TpDifFreteToStr(const t: TpciotDiferencaFreteTipo): string;
begin
  result := EnumeradoToStr(t,['SemDiferenca', 'SomenteUltrapassado', 'Integral'],
                             [SemDiferenca, SomenteUltrapassado, Integral]);
end;

function StrToTpDifFrete(var ok: boolean; const s: string): TpciotDiferencaFreteTipo;
begin
  result := StrToEnumerado(ok, s, ['SemDiferenca', 'SomenteUltrapassado', 'Integral'],
                                  [SemDiferenca, SomenteUltrapassado, Integral]);
end;

function TpCarroceriaToStrTxt(const t: TpcteTipoCarroceria): string;
begin
  result := EnumeradoToStr(t, ['NaoAplicavel','Aberta','FechadaOuBau','Graneleira','PortaContainer','Sider'],
   [tcNaoAplicavel, tcAberta, tcFechada, tcGraneleira, tcPortaContainer, tcSider]);
end;

function TpRodadoToStrTxt(const t: TpcteTipoRodado): string;
begin
  result := EnumeradoToStr(t, ['NaoAplicavel','Truck','Toco','Cavalo','VAN','Utilitario','Outros'],
   [trNaoAplicavel, trTruck, trToco, trCavaloMecanico, trVAN, trUtilitario, trOutros]);
end;

{ TGerador }

constructor TGerador.Create;
begin
  FOpcoes := TGeradorOpcoes.Create;
  FOpcoes.FIdentarXML := False;
  FOpcoes.FTamanhoIdentacao := 3;
  FOpcoes.FFormatoAlerta := 'TAG:%TAGNIVEL% ID:%ID%/%TAG%(%DESCRICAO%) - %MSG%.'; // Vide comentário em wAlerta
  FOpcoes.FRetirarEspacos := True;
  FOpcoes.FRetirarAcentos := True;
  FOpcoes.FSuprimirDecimais := False;
  FOpcoes.FSomenteValidar := False;
  FOpcoes.FTagVaziaNoFormatoResumido := True;
  FListaDeAlertas := TStringList.Create;
  FLayoutArquivoTXT := TStringList.Create;
end;

destructor TGerador.Destroy;
begin
  FOpcoes.Free;
  FListaDeAlertas.Free;
  FLayoutArquivoTXT.Free;
  FIgnorarTagNivel := '!@#';
  FIgnorarTagIdentacao := '!@#';
  inherited Destroy;
end;

procedure TGerador.gtAjustarRegistros(const ID: string);
var
  i, j, k: integer;
  s, idLocal: string;
  ListArquivo: TstringList;
  ListCorrigido: TstringList;
  ListTAGs: TstringList;
begin
  if FLayoutArquivoTXT.Count = 0 then
    exit;
  ListTAGs := TStringList.Create;
  ListArquivo := TStringList.Create;
  ListCorrigido := TStringList.Create;
  // Elimina registros não utilizados
  ListArquivo.Text := FArquivoFormatoTXT;
  for i := 0 to ListArquivo.count - 1 do
  begin
    k := 0;
    for j := 0 to FLayoutArquivoTXT.count - 1 do
      if listArquivo[i] = FLayoutArquivoTXT[j] then
        if pos('¨', listArquivo[i]) > 0 then
          k := 1;
    if k = 0 then
      ListCorrigido.add(ListArquivo[i]);
  end;
  // Insere dados da chave da Nfe
  for i := 0 to ListCorrigido.count - 1 do
    if pos('^ID^', ListCorrigido[i]) > 1 then
      ListCorrigido[i] := StringReplace(ListCorrigido[i], '^ID^', ID, []);
  // Elimina Nome de TAG sem informação
  for j := 0 to FLayoutArquivoTXT.count - 1 do
  begin
    s := FLayoutArquivoTXT[j];
    while (pos('|', s) > 0) and (pos('¨', s) > 0) do
    begin
      s := copy(s, pos('|', s), maxInt);
      ListTAGs.add(copy(s, 1, pos('¨', s)));
      s := copy(s, pos('¨', s) + 1, maxInt);
    end;
  end;
  for i := 0 to ListCorrigido.count - 1 do
    for j := 0 to ListTAGs.count - 1 do
      ListCorrigido[i] := StringReplace(ListCorrigido[i], ListTAGs[j], '|', []);
  // Elimina Bloco <ID>
  for i := 0 to ListCorrigido.count - 1 do
    if pos('>', ListCorrigido[i]) > 0 then
     begin
      ListCorrigido[i] := Trim(copy(ListCorrigido[i], pos('>', ListCorrigido[i]) + 1, maxInt));
      idLocal := copy(ListCorrigido[i],1,pos('|',ListCorrigido[i])-1);

      if (length(idLocal) > 2) and (UpperCase(idLocal) <> 'NOTA FISCAL') and
         (copy(idLocal,length(idLocal),1) <> SomenteNumeros(copy(idLocal,length(idLocal),1))) then
       begin
         idLocal := copy(idLocal,1,length(idLocal)-1)+LowerCase(copy(idLocal,length(idLocal),1));
         ListCorrigido[i] := StringReplace(ListCorrigido[i],idLocal,idLocal,[rfIgnoreCase]);
       end;
     end;
  FArquivoFormatoTXT := ListCorrigido.Text;
  //
  ListTAGs.Free;
  ListArquivo.Free;
  ListCorrigido.Free;
end;

procedure TGerador.gtCampo(const Tag, ConteudoProcessado: string);
var
  i: integer;
  List: TstringList;
begin
  if FLayoutArquivoTXT.Count = 0 then
    exit;
  List := TStringList.Create;
  List.Text := FArquivoFormatoTXT;
  //
  for i := 0 to List.count - 1 do
    if pos('<' + FIDNivel + '>', List.Strings[i]) > 0 then
      if pos('|' + UpperCase(Tag) + '¨', UpperCase(List.Strings[i])) > 0 then
        List[i] := StringReplace(List[i], '|' + UpperCase(Trim(TAG)) + '¨', '|' + conteudoProcessado, []);
  //
  FArquivoFormatoTXT := List.Text;
  List.Free;
end;

procedure TGerador.gtNivel(ID: string);
var
  i: integer;
begin
  ID := UpperCase(ID);
  FIDNivel := ID;
  if (FLayoutArquivoTXT.Count = 0) or (ID = '') then
    exit;
  for i := 0 to FLayoutArquivoTXT.Count - 1 do
    if pos('<' + ID + '>', UpperCase(FLayoutArquivoTXT.Strings[i])) > 0 then
      FArquivoFormatoTXT := FArquivoFormatoTXT + FLayoutArquivoTXT.Strings[i] + #13;
end;

function TGerador.SalvarArquivo(const CaminhoArquivo: string;
  const FormatoGravacao: TpcnFormatoGravacao): Boolean;
var
  ArquivoGerado: TStringList;
begin
  // Formato de gravação somente é válido para NFe
  ArquivoGerado := TStringList.Create;
  try
    try
      if FormatoGravacao = fgXML then
        ArquivoGerado.Add(FArquivoFormatoXML)
      else
        ArquivoGerado.Add(FArquivoFormatoTXT);
      ArquivoGerado.SaveToFile(CaminhoArquivo);
      Result := True;
    except
      Result := False;
      raise;
    end;
  finally
    ArquivoGerado.Free;
  end;
end;

procedure TGerador.wAlerta(const ID, TAG, Descricao, Alerta: string);
var
  s: string;
begin
  // O Formato da mensagem de erro pode ser alterado pelo usuario alterando-se a property FFormatoAlerta: onde;
  // %TAGNIVEL%  : Representa o Nivel da TAG; ex: <transp><vol><lacres>
  // %TAG%       : Representa a TAG; ex: <nLacre>
  // %ID%        : Representa a ID da TAG; ex X34
  // %MSG%       : Representa a mensagem de alerta
  // %DESCRICAO% : Representa a Descrição da TAG
  s := FOpcoes.FFormatoAlerta;
  s := stringReplace(s, '%TAGNIVEL%', FTagNivel, [rfReplaceAll]);
  s := stringReplace(s, '%TAG%', TAG, [rfReplaceAll]);
  s := stringReplace(s, '%ID%', ID, [rfReplaceAll]);
  s := stringReplace(s, '%MSG%', Alerta, [rfReplaceAll]);
  s := stringReplace(s, '%DESCRICAO%', Trim(Descricao), [rfReplaceAll]);
  if Trim(Alerta) <> '' then
    FListaDeAlertas.Add(s);
end;

procedure TGerador.wCampo(const Tipo: TpcnTipoCampo; ID, TAG: string; const min,
  max, ocorrencias: smallint; const valor: variant; const Descricao,
  NameSpace: string);
var
  NumeroDecimais: smallint;
  Limite: Integer;
  alerta, ConteudoProcessado: string;
  wAno, wMes, wDia, wHor, wMin, wSeg, wMse: Word;
  EstaVazio: boolean;
//  VlrExt:Extended;
begin
  ID                  := Trim(ID);
  Tag                 := Trim(TAG);
  EstaVazio           := False;
  NumeroDecimais      := 0;
  ConteudoProcessado  := '';
  Limite              := max;
  case Tipo of
    tcStr   : begin
                ConteudoProcessado := trim(valor);
                EstaVazio := ConteudoProcessado = '';

              end;
    tcDat,
    tcDatCFe: begin
                DecodeDate(valor, wAno, wMes, wDia);
                ConteudoProcessado := FormatFloat('0000', wAno) + '-' + FormatFloat('00', wMes) + '-' + FormatFloat('00', wDia);
                if Tipo = tcDatCFe then
                  ConteudoProcessado := SomenteNumeros(ConteudoProcessado);
                EstaVazio := ((wAno = 1899) and (wMes = 12) and (wDia = 30));
              end;
    tcHor,
    tcHorCFe: begin
                DecodeTime(valor, wHor, wMin, wSeg, wMse);
                ConteudoProcessado := FormatFloat('00', wHor) + ':' + FormatFloat('00', wMin) + ':' + FormatFloat('00', wSeg);
                if Tipo = tcHorCFe then
                   ConteudoProcessado := SomenteNumeros(ConteudoProcessado);
                EstaVazio := (wHor = 0) and (wMin = 0) and (wSeg = 0);
              end;
    tcDatHor : begin
                DecodeDateTime(valor, wAno, wMes, wDia, wHor, wMin, wSeg, wMse);
                ConteudoProcessado := FormatFloat('0000', wAno) + '-' +
                FormatFloat('00', wMes) + '-' +
                FormatFloat('00', wDia) + 'T' +
                FormatFloat('00', wHor) + ':' +
                FormatFloat('00', wMin) + ':' +
                FormatFloat('00', wSeg);
                EstaVazio := ((wAno = 1899) and (wMes = 12) and (wDia = 30));
              end;
      tcDe2,
      tcDe3,
      tcDe4,
      tcDe6,  // Incluido por Italo em 30/09/2010
      tcDe10 : begin
                // adicionar um para que o máximo não considere a virgula
                Limite := Limite + 1;

                // Tipo numerico com decimais
                  case Tipo of
                    tcDe2 : NumeroDecimais :=  2;
                    tcDe3 : NumeroDecimais :=  3;
                    tcDe4 : NumeroDecimais :=  4;
                    tcDe6 : NumeroDecimais :=  6; // Incluido por Italo em 30/09/2010
                    tcDe10: NumeroDecimais := 10;
                  end;
                  //VlrExt := StrToFloat(valor);
                  ConteudoProcessado  := FormatFloat('0.0000000000', valor);
                  EstaVazio           := (valor = 0) and (ocorrencias = 0);
                  if StrToIntDef(Copy(ConteudoProcessado, pos(DecimalSeparator, ConteudoProcessado) + NumeroDecimais + 1, 10),0) > 0 then
                    walerta(ID, Tag, Descricao, ERR_MSG_MAXIMO_DECIMAIS + ' ' + IntToStr(NumeroDecimais));

                  ConteudoProcessado := FormatFloat('0.' + StringOfChar('0', NumeroDecimais), valor);
                  ConteudoProcessado := StringReplace(ConteudoProcessado, ',', '.', [rfReplaceAll]);
                  // Caso não seja um valor fracionário; retira os decimais.
                  if FOpcoes.FSuprimirDecimais then
                    if int(Valor) = Valor then
                     ConteudoProcessado := IntToStr(Round(Integer(valor)));

              end;
      tcEsp : begin
                  // Tipo String - somente numeros
                  ConteudoProcessado  := trim(valor);
                  EstaVazio           := valor = '';
                  if not ValidarNumeros(ConteudoProcessado) then walerta(ID, Tag, Descricao, ERR_MSG_INVALIDO);
              end;
      tcInt : begin
                  // Tipo Inteiro
                  ConteudoProcessado := IntToStr(valor);
                  EstaVazio := (valor = 0) and (ocorrencias = 0);
                  if min = Limite then
                  begin
                    ConteudoProcessado := StringOfChar('0', 60) + ConteudoProcessado;
                    ConteudoProcessado := copy(ConteudoProcessado, length(ConteudoProcessado) - Limite + 1, Limite);
                  end;
              end;
    end;
    alerta := '';
    //(Existem tags obrigatórias que podem ser nulas ex. cEAN)  if (ocorrencias = 1) and (EstaVazio) then
    if (ocorrencias = 1) and (EstaVazio) and (min > 0)                                            then alerta := ERR_MSG_VAZIO;
    if (length(ConteudoProcessado) < min) and (alerta = '') and (length(ConteudoProcessado) > 1)  then alerta := ERR_MSG_MENOR;
    if length(ConteudoProcessado) > Limite                                                        then alerta := ERR_MSG_MAIOR;
      // Grava alerta //
    if (alerta <> '') and (pos(ERR_MSG_VAZIO, alerta) = 0) and (not EstaVazio)                    then alerta := alerta + ' [' + VarToStr(valor) + ']';
    walerta(ID, TAG, Descricao, alerta);
    // Sai se for apenas para validar //
    if FOpcoes.FSomenteValidar  then exit;
    // Grava no Formato Texto
    if not EstaVazio            then
      gtCampo(tag, ConteudoProcessado)
    else
      gtCampo(tag, '');

    // Grava a tag no arquivo - Quando não existir algum conteúdo
    if ((ocorrencias = 1) and (EstaVazio)) then
    begin
      if FOpcoes.FIdentarXML then
      begin
        if FOpcoes.FTagVaziaNoFormatoResumido then
          FArquivoFormatoXML := FArquivoFormatoXML + StringOfChar(' ', FOpcoes.FTamanhoIdentacao * FOpcoes.FNivelIdentacao) + '<' + tag + NameSpace + '/>' + #13#10
        else
          FArquivoFormatoXML := FArquivoFormatoXML + StringOfChar(' ', FOpcoes.FTamanhoIdentacao * FOpcoes.FNivelIdentacao) + '<' + tag + NameSpace + '></' + tag + '>' + #13#10
      end
      else
      begin
        if FOpcoes.FTagVaziaNoFormatoResumido then
          FArquivoFormatoXML := FArquivoFormatoXML + '<' + tag + NameSpace + '/>'
        else
          FArquivoFormatoXML := FArquivoFormatoXML + '<' + tag + NameSpace + '></' + tag + '>';
      end;
      exit;
    end;
    // Grava a tag no arquivo - Quando existir algum conteúdo
    if ((ocorrencias = 1) or (not EstaVazio)) then
      if FOpcoes.FIdentarXML then
        FArquivoFormatoXML := FArquivoFormatoXML + StringOfChar(' ', FOpcoes.FTamanhoIdentacao * FOpcoes.FNivelIdentacao) + '<' + tag + NameSpace + '>' + FiltrarTextoXML(FOpcoes.FRetirarEspacos, ConteudoProcessado, FOpcoes.FRetirarAcentos) + '</' + tag + '>' + #13#10
    else
      FArquivoFormatoXML := FArquivoFormatoXML + '<' + tag + NameSpace + '>' + FiltrarTextoXML(FOpcoes.FRetirarEspacos, ConteudoProcessado, FOpcoes.FRetirarAcentos) + '</' + tag + '>';
end;

procedure TGerador.wGrupo(const TAG: string; ID: string;
  const Identar: Boolean);
begin
  // A propriedade FIgnorarTagNivel é utilizada para Ignorar TAG
  // na construção dos níveis para apresentação na mensagem de erro.
  gtNivel(ID);
  // Caso a tag seja um Grupo com Atributo
  if (pos('="', TAG) > 0) or (pos('= "', TAG) > 0) then
    gtCampo(RetornarConteudoEntre(TAG, ' ', '='), RetornarConteudoEntre(TAG, '"', '"'));
  //
  if not SubStrEmSubStr(TAG, FIgnorarTagNivel) then
  begin
    if TAG[1] <> '/' then
      FTagNivel := FTagNivel + '<' + TAG + '>';
    if (TAG[1] = '/') and (Copy(TAG, 2, 3) = 'det') then
      FTagNivel := copy(FTagNivel, 1, pos('<det', FTagNivel) - 1)
    else
      FTagNivel := StringReplace(FTagNivel, '<' + Copy(TAG, 2, MaxInt) + '>', '', []);
  end;
  //
  if (Identar) and (TAG[1] = '/') then
    Dec(FOpcoes.FNivelIdentacao);
  if SubStrEmSubStr(TAG, FIgnorarTagIdentacao) then
    Dec(FOpcoes.FNivelIdentacao);
  //
  if FOpcoes.IdentarXML then
    FArquivoFormatoXML := FArquivoFormatoXML + StringOfChar(' ', FOpcoes.FTamanhoIdentacao * FOpcoes.FNivelIdentacao) + '<' + tag + '>' + #13#10
  else
    FArquivoFormatoXML := FArquivoFormatoXML + '<' + tag + '>';
  if (Identar) and (TAG[1] <> '/') then
    Inc(FOpcoes.FNivelIdentacao);
end;

procedure TGerador.wTexto(const Texto: string);
begin
  FArquivoFormatoXML := FArquivoFormatoXML + Texto;
end;

{ TLeitor }

function TLeitor.CarregarArquivo(const Stream: TStringStream): boolean;
begin
  //NOTA: Carrega o arquivo xml na memória para posterior leitura de sua tag's
  try
    FArquivo := Stream.DataString;
    Result := True;
  except
    raise;
  end;
end;

function TLeitor.CarregarArquivo(const CaminhoArquivo: string): boolean;
var
  ArquivoXML: TStringList;
begin
  //NOTA: Carrega o arquivo xml na memória para posterior leitura de sua tag's
  ArquivoXML := TStringList.Create;
  try
    try
      ArquivoXML.LoadFromFile(CaminhoArquivo);
      FArquivo := ArquivoXML.Text;
      Result := True;
    except
      Result := False;
      raise;
    end;
  finally
    ArquivoXML.Free;
  end;
end;

constructor TLeitor.Create;
var
  i: integer;
begin
  inherited Create;
  FNivel := TStringList.Create;
  for i := 1 to 10 do
    FNivel.add('');
end;

destructor TLeitor.Destroy;
begin
  FNivel.Free;
  inherited;
end;

function TLeitor.PosLast(const SubStr, S: AnsiString): Integer;
Var P : Integer ;
begin
  Result := 0 ;
  P := Pos( SubStr, S) ;
  while P <> 0 do
  begin
     Result := P ;
     P := RetornarPosEx( SubStr, S, P+1) ;
  end ;
end;

function TLeitor.rAtributo(Atributo: string): variant;
var
  ConteudoTag, Aspas: string;
  inicio, fim: integer;
begin
  Result := '';
  Atributo := Trim(Atributo);
  inicio   := pos(Atributo, FGrupo);
  if inicio > 0 then
  begin
     inicio := inicio + Length(Atributo);
    ConteudoTag := trim(copy(FGrupo, inicio, maxInt));

    if Pos('"', ConteudoTag) <> 0 then
      Aspas := '"'
     else
      Aspas := '''';

    inicio := pos(Aspas, ConteudoTag) + 1;
    if inicio > 0 then
    begin
      ConteudoTag := trim(copy(ConteudoTag, inicio, maxInt));
      fim := pos(Aspas, ConteudoTag) - 1;
      if fim > 0 then
      begin
        ConteudoTag := copy(ConteudoTag, 1, fim);
        result := ReverterFiltroTextoXML(ConteudoTag)
      end
    end ;
  end ;
end;

function TLeitor.rCampo(const Tipo: TpcnTipoCampo; TAG,
  TAGparada: string): variant;
var
  ConteudoTag: string;
  inicio, fim, inicioTAGparada: integer;
begin
  Tag := UpperCase(Trim(TAG));
  inicio := pos('<' + Tag + '>', UpperCase(FGrupo));

  if Trim(TAGparada) <> '' then
   begin
    inicioTAGparada := pos('<' + UpperCase(Trim(TAGparada)) + '>', UpperCase(FGrupo));
    if inicioTAGparada = 0 then
      inicioTAGparada := inicio;
   end
   else
    inicioTAGparada := 0;//inicio;

  if (inicio = 0) {or (InicioTAGparada < inicio) }then
    ConteudoTag := ''
  else
  begin
    inicio := inicio + Length(Tag) + 2;

    if inicioTAGparada > 0 then
      fim := inicioTAGparada - inicio
//      pos('</' + Tag + '>', UpperCase(FGrupo)) - inicio;
    else
      fim := pos('</' + Tag + '>', UpperCase(FGrupo)) - inicio;

    ConteudoTag := trim(copy(FGrupo, inicio, fim));
  end;
  case Tipo of
    tcStr     : result := ReverterFiltroTextoXML(ConteudoTag);
    tcDat     : begin
                  if length(ConteudoTag)>0 then
                    result := EncodeDate(StrToInt(copy(ConteudoTag, 01, 4)), StrToInt(copy(ConteudoTag, 06, 2)), StrToInt(copy(ConteudoTag, 09, 2)))
                  else
                    result:=0;
                  end;
    tcDatCFe  : begin
                  if length(ConteudoTag)>0 then
                    result := EncodeDate(StrToInt(copy(ConteudoTag, 01, 4)), StrToInt(copy(ConteudoTag, 05, 2)), StrToInt(copy(ConteudoTag, 07, 2)))
                  else
                    result:=0;
                  end;
    tcDatHor  : begin
                    if length(ConteudoTag)>0 then
                      result := EncodeDate(StrToInt(copy(ConteudoTag, 01, 4)), StrToInt(copy(ConteudoTag, 06, 2)), StrToInt(copy(ConteudoTag, 09, 2))) +
                      EncodeTime(StrToInt(copy(ConteudoTag, 12, 2)), StrToInt(copy(ConteudoTag, 15, 2)), StrToInt(copy(ConteudoTag, 18, 2)), 0)
                    else
                      result:=0;
                  end;
    tcHor     : begin
                    if length(ConteudoTag)>0 then
                    result := EncodeTime(StrToInt(copy(ConteudoTag, 1, 2)), StrToInt(copy(ConteudoTag, 4, 2)), StrToInt(copy(ConteudoTag, 7, 2)), 0)
                    else
                    result:=0;
                  end;
    tcHorCFe  : begin
                    if length(ConteudoTag)>0 then
                    result := EncodeTime(StrToInt(copy(ConteudoTag, 1, 2)), StrToInt(copy(ConteudoTag, 3, 2)), StrToInt(copy(ConteudoTag, 5, 2)), 0)
                    else
                    result:=0;
                  end;
    tcDe2,
    tcDe3,
    tcDe4,
    tcDe6,
    tcDe10    : result := StrToFloatDef(StringReplace(ConteudoTag, '.', DecimalSeparator, []),0);
    tcEsp     : result := ConteudoTag;
    tcInt     : result := StrToIntDef(Trim(SomenteNumeros(ConteudoTag)),0);
    else
      raise Exception.Create('Tag <' + Tag + '> com conteúdo inválido. '+ConteudoTag);
  end;
end;

function TLeitor.rCampoCNPJCPF(TAGparada: string): string;
begin
  result := rCampo(tcStr, 'CNPJ', TAGparada);
  if trim(result) = '' then
    result := rCampo(tcStr, 'CPF', TAGparada);
end;

function TLeitor.rExtrai(const nivel: integer; const TagInicio: string;
  TagFim: string; const item: integer): AnsiString;
var
  Texto: AnsiString;
  i,j: integer;
begin
  //NOTA: Extrai um grupo de dentro do nivel informado
  FNivel.strings[0] := FArquivo;
  if Trim(TagFim) = '' then
    TagFim := TagInicio;
  Texto := FNivel.Strings[nivel - 1];
  Result := '';
  FGrupo := '';
  for i := 1 to item do
    if i < item then
      Texto := copy(Texto, pos('</' + Trim(TagFim) + '>', Texto) + length(Trim(TagFim)) + 3, maxInt);

  j := pos('</' + Trim(TagFim) + '>', Texto);
  if j = 0 then
    j := pos('</' + Trim(TagFim) + ':', Texto); // Correção para WebServices do Ceará/MG

  //Correção para leitura de tags em que a primeira é diferente da segunda Ex: <infProt id=XXX> e a segunda apenas <infProt>
//  Texto := copy(Texto, 1, pos('</' + Trim(TagFim) + '>', Texto) + length(Trim(TagFim)) + 3);
  Texto := copy(Texto, 1, j + length(Trim(TagFim)) + 3);

  i := pos('<' + Trim(TagInicio) + '>', Texto);
  if i = 0 then
    i := pos('<' + Trim(TagInicio) + ' ', Texto);
  if i = 0 then
    i := pos('<' + Trim(TagInicio) + ':', Texto); //correção para webservice do Ceará
  if i = 0 then
    exit;
  Texto := copy(Texto, i, maxInt);

  // Alterado por Claudemir em 13/03/2013: j:=pos('</' + Trim(TagFim) + '>',Texto);
//  j:=pos('</' + Trim(TagFim) + '>', Texto) + length(Trim(TagFim)) + 3;
  j:=pos('</' + Trim(TagFim) + '>', Texto);

  if j=0 then
   j:=pos('</' + Trim(TagFim) + ':', Texto); //correção para webservice do Ceará

//  Result := TrimRight(copy(Texto, 1, j - 1));
  Result := TrimRight(copy(Texto, 1, j - 1 + (length(Trim(TagFim)) + 3)));
  FNivel.strings[nivel] := Result;
  FGrupo := result;
end;

end.

