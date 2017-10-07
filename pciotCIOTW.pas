{$I ACBr.inc}

unit pciotCIOTW;

interface

uses
  SysUtils, Classes, pcnAuxiliar, pcnConversao, pcnGerador, pciotCIOT;

type

  TGeradorOpcoes = class;

  TCIOTW = class(TPersistent)
  private
    FGerador: TGerador;
    FCIOT: TCIOT;
    FOpcoes: TGeradorOpcoes;

    procedure GerarXmleFrete;     // Nivel 0

    procedure GerarIde;        // Nivel 1
    procedure GerarToma03;     // Nivel 2
    procedure GerarToma4;      // Nivel 2
    procedure GerarEnderToma;  // Nivel 3

    procedure GerarCompl;      // Nivel 1
    procedure GerarFluxo;      // Nivel 2
    procedure GerarEntrega;    // Nivel 2
    procedure GerarObsCont;    // Nivel 2
    procedure GerarObsFisco;   // Nivel 2

    procedure GerarEmit;       // Nivel 1
    procedure GerarEnderEmit;  // Nivel 2

    procedure GerarRem;        // Nivel 1
    procedure GerarEnderReme;  // Nivel 2
    procedure GerarLocColeta;  // Nivel 2

    procedure GerarExped;      // Nivel 1
    procedure GerarEnderExped; // Nivel 2

    procedure GerarReceb;      // Nivel 1
    procedure GerarEnderReceb; // Nivel 2

    procedure GerarDest;       // Nivel 1
    procedure GerarEnderDest;  // Nivel 2
    procedure GerarLocEnt;     // Nivel 2

    procedure GerarVPrest;     // Nivel 1
    procedure GerarComp;       // Nivel 2

    procedure GerarImp;        // Nivel 1
    procedure GerarICMS;       // Nivel 2
    procedure GerarCST00;      // Nivel 3
    procedure GerarCST20;      // Nivel 3
    procedure GerarCST45;      // Nivel 3
    procedure GerarCST60;      // Nivel 3
    procedure GerarCST90;      // Nivel 3
    procedure GerarICMSOutraUF;// Nivel 3
    procedure GerarICMSSN;     // Nivel 3

    procedure GerarInfCTeNorm; // Nivel 1
    procedure GerarinfCarga;   // Nivel 2
    procedure GerarInfQ;       // Nivel 3
    procedure GerarinfDoc;     // Nivel 2
    procedure GerarInfNF;      // Nivel 3
    procedure GerarInfNFe;     // Nivel 3
    procedure GerarInfOutros;  // Nivel 3

    procedure GerarDocAnt;     // Nivel 2
    procedure GerarInfSeg;     // Nivel 2

    procedure GerarRodo;       // Nivel 2
    procedure GerarOCC;        // Nivel 3
    procedure GerarValePed;    // Nivel 3
    procedure GerarVeic;       // Nivel 3
    procedure GerarLacre;      // Nivel 3
    procedure GerarMoto;       // Nivel 3

    procedure GerarAereo;      // Nivel 2

    procedure GerarAquav;      // Nivel 2

    procedure GerarFerrov;     // Nivel 2
    procedure GerarFerroEnv;   // Nivel 3
    procedure GerardetVag;     // Nivel 3

    procedure GerarDuto;       // Nivel 2

    procedure GerarMultimodal; // Nivel 2

    procedure GerarPeri;       // Nivel 2
    procedure GerarVeicNovos;  // Nivel 2
    procedure GerarCobr;       // Nivel 2
    procedure GerarCobrFat;
    procedure GerarCobrDup;
    procedure GerarInfCTeSub;  // Nivel 2

    procedure GerarInfCTeComp;      // Nivel 1
    procedure GerarImpComp;         // Nivel 2
    procedure GerarICMSComp;        // Nivel 3
    procedure GerarCST00Comp;       // Nivel 4
    procedure GerarCST20Comp;       // Nivel 4
    procedure GerarCST45Comp;       // Nivel 4
    procedure GerarCST60Comp;       // Nivel 4
    procedure GerarCST90Comp;       // Nivel 4
    procedure GerarICMSOutraUFComp; // Nivel 4
    procedure GerarICMSSNComp;      // Nivel 4

    procedure GerarInfCTeAnu; // Nivel 1
    procedure GerarautXML;    // Nivel 1

    procedure AjustarMunicipioUF(var xUF: string; var xMun: string; var cMun: integer; cPais: integer; vxUF, vxMun: string; vcMun: integer);
    function ObterNomeMunicipio(const xMun, xUF: string; const cMun: integer): string;
  public
    constructor Create(AOwner: TCIOT);
    destructor Destroy; override;
    function GerarXml: boolean;
    function ObterNomeArquivo: string;
  published
    property Gerador: TGerador read FGerador write FGerador;
    property CIOT: TCIOT read FCIOT write FCIOT;
    property Opcoes: TGeradorOpcoes read FOpcoes write FOpcoes;
  end;

  TGeradorOpcoes = class(TPersistent)
  private
    FAjustarTagNro: boolean;
    FNormatizarMunicipios: boolean;
    FGerarTagAssinatura: TpcnTagAssinatura;
    FPathArquivoMunicipios: string;
    FValidarInscricoes: boolean;
    FValidarListaServicos: boolean;
  published
    property AjustarTagNro: boolean read FAjustarTagNro write FAjustarTagNro;
    property NormatizarMunicipios: boolean read FNormatizarMunicipios write FNormatizarMunicipios;
    property GerarTagAssinatura: TpcnTagAssinatura read FGerarTagAssinatura write FGerarTagAssinatura;
    property PathArquivoMunicipios: string read FPathArquivoMunicipios write FPathArquivoMunicipios;
    property ValidarInscricoes: boolean read FValidarInscricoes write FValidarInscricoes;
    property ValidarListaServicos: boolean read FValidarListaServicos write FValidarListaServicos;
  end;

  ////////////////////////////////////////////////////////////////////////////////

implementation

// Regra a ser aplicada em ambiente de homologação a partir de 01/09/2012
const
 xRazao = 'CT-E EMITIDO EM AMBIENTE DE HOMOLOGACAO - SEM VALOR FISCAL';

{ TCTeW }

constructor TCIOTW.Create(AOwner: TCIOT);
begin
  FCIOT := AOwner;
  FGerador := TGerador.Create;
  FGerador.FIgnorarTagNivel := '|?xml version|CTe xmlns|infCTe versao|obsCont|obsFisco|';
  FOpcoes := TGeradorOpcoes.Create;
  FOpcoes.FAjustarTagNro := True;
  FOpcoes.FNormatizarMunicipios := False;
  FOpcoes.FGerarTagAssinatura := taSomenteSeAssinada;
  FOpcoes.FValidarInscricoes := False;
  FOpcoes.FValidarListaServicos := False;
end;

destructor TCIOTW.Destroy;
begin
  FGerador.Free;
  FOpcoes.Free;
  inherited Destroy;
end;

////////////////////////////////////////////////////////////////////////////////

function TCIOTW.ObterNomeArquivo: string;
begin
  Result := SomenteNumeros(CIOT.infCIOT.ID) + '-CIOT.xml';
end;

function TCIOTW.GerarXml: boolean;
var
  chave: AnsiString;
  Gerar: boolean;
  xProtCTe : String;
begin
  CIOT.infCIOT.ID := chave;
  CIOT.ide.cDV := RetornarDigito(CIOT.infCIOT.ID);
  CIOT.Ide.cCT := RetornarCodigoNumerico(CIOT.infCIOT.ID, 2);

  // Carrega Layout que sera utilizado para gera o txt
  Gerador.LayoutArquivoTXT.Clear;
  Gerador.ArquivoFormatoXML := '';
  Gerador.ArquivoFormatoTXT := '';

  Gerador.wGrupo(ENCODING_UTF8, '', False);
//  Gerador.wGrupo('CTe ' + NAME_SPACE_CTE);
//  Gerador.wGrupo('infCte versao="' + CTeenviCTe + '" Id="' + CIOT.infCIOT.ID + '"');

  GerarXmleFrete;
  Gerador.wGrupo('/infCte');

//  Gerador.wGrupo('/CTe');
//  Gerador.gtAjustarRegistros(CIOT.infCIOT.ID);
  Result := (Gerador.ListaDeAlertas.Count = 0);
end;

procedure TCIOTW.GerarXmleFrete;
begin
  GerarIde;
  GerarCompl;
  GerarEmit;
  GerarRem;
  GerarExped;
  GerarReceb;
  GerarDest;
  GerarvPrest;
  GerarImp;

  GerarInfCTeNorm; // Gerado somente se Tipo de CTe = tcNormal
  GerarinfCTeComp; // Gerado somente se Tipo de CTe = tcComplemento
  GerarInfCTeAnu;  // Gerado somente se Tipo de CTe = tcAnulacao

  GerarautXML;
end;

procedure TCIOTW.GerarIde;
begin
//  Gerador.wGrupo('ObterPorPlacaRequest ' + NAME_SPACE_VEICULOS_EFRETE);
//  Gerador.wTexto('<Integrador ' + NAME_SPACE_EFRETE + '>' + FIntegrador + '</Integrador>');
//  Gerador.wTexto('<Versao ' + NAME_SPACE_EFRETE + '>' + IntToStr(FVersao) + '</Versao>');

  Gerador.wGrupo('AdicionarOperacaoTransporteRequest ' + NAME_SPACE_VEICULOS_EFRETE, 'AP01');
  Gerador.wCampo(tcInt, 'AP02', 'CodigoIdentificacaoOperacaoPrincipal', 01, 01, 0, CIOT.ide.cUF, DSC_CUF);

  if not ValidarCodigoUF(CIOT.ide.cUF) then
    Gerador.wAlerta('#005', 'cUF', DSC_CUF, ERR_MSG_INVALIDO);

//NAME_SPACE_EFRETE = 'xmlns="http://schemas.ipc.adm.br/efrete/objects"';
//NAME_SPACE_VEICULOS_EFRETE = 'xmlns="http://schemas.ipc.adm.br/efrete/veiculos/objects"';
//
//AP01 AdicionarOperacaoTransporteRequest RAIZ - - - - - -
//  AP02 CodigoIdentificacaoOperacaoPrincipal E AP01 S 1-1 - - Informar um CIOT (se existente) que esteja relacionado à operação de transporte. Por exemplo: No caso da presença de um Subcontratante na operação de transporte informar o CIOT da operação na qual o Subcontratante foi o Contratado, se o CIOT existir.
//  AP03 CodigoNCMNaturezaCarga E AP01 N 1-1 4 - Código NCM da mercadoria. No caso de existir mais de um tipo de carga usar o código da mercadoria com maior valor comercial. Caso a carga seja composta por diversos produtos de grupos distintos e não for possível aplicar o critério anterior pode-se utilizar o Cópia de uso exclusivo da: - AMERICA SOFT INFORMATICA LTDA CNPJ: 03961263000155 IPC Administração Ltda. - www.efrete.com 22  Manual Técnico de Integração WebService – Sistema e-FRETE Empresa gestora IPC Administração LTDA. Especificador: IPC - Desenvolvimento Versão 2.4 código de carga diversa (0001).
//
//  AP04 Consignatario RAIZ AP01 - 0-1 - - Aquele que receberá as mercadorias transportadas em consignação, indicado no cadastramento da Operação de Transporte ou nos respectivos documentos fiscais.
//    AP05 CpfOuCnpj E AP04 N 0-1 - - CPF ou CNPJ do Consignatário.
//    AP06 EMail E AP04 S 0-1 - - Email do consignatário.
//    AP07 Endereco RAIZ AP04 - 0-1 - - -
//      AP08 Bairro E AP07 S 0-1 - - Bairro do Consignatário.
//      AP09 CEP E AP07 S 0-1 - - CEP do Consignatário.
//      AP10 CodigoMunicipio E AP07 N 0-1 7 - Código do município segundo o IBGE.
//      AP11 Rua E AP07 S 0-1 - - Rua e número do consignatário.
//      AP12 Numero E AP07 S 0-1 - - -
//      AP13 Complemento E AP07 S 0-1 - - -
//    AP14 NomeOuRazaoSocial E AP04 S 0-1 - - Nome ou Razão Social do Consignatário.
//    AP15 ResponsavelPeloPagamento E AP04 B 1-1 - - Informar se é o responsável pelo pagamento da Operação de Transporte. True = Sim.  False = Não.
//
  //  AP16 Telefones RAIZ AP04 - 0-1 - - -
  //    AP17 Celular RAIZ AP16 - 0-1 - - -
  //      AP18 DDD R AP17 N 0-1 2 - -
  //      AP19 Numero R AP17 N 0-1 8-9 - -
  //    AP20 Fax RAIZ AP16 - 0-1 - - -
  //      AP21 DDD E AP20 N 0-1 2 - -
  //      AP22 Numero E AP20 N 0-1 8-9 - -
  //    AP23 Fixo RAIZ AP16 - 0-1 - - -
  //      AP24 DDD E AP23 N 0-1 2 - -
  //      AP25 Numero E AP23 N 0-1 8-9 - -
  //
//  AP26 Contratado RAIZ AP01 - 1-1 - - TAC ou seu equiparado, que efetuar o transporte rodoviário de cargas por conta de terceiros e mediante remuneração, indicado no cadastramento da Operação Cópia de uso exclusivo da: - AMERICA SOFT INFORMATICA LTDA CNPJ: 03961263000155 IPC Administração Ltda. - www.efrete.com 23 Manual Técnico de Integração WebService – Sistema e-FRETE Empresa gestora IPC Administração LTDA. Especificador: IPC - Desenvolvimento Versão 2.4 de Transporte.
//    AP27 CpfOuCnpj E AP26 N 1-1 11-14 - CPF ou CNPJ do Contratado.
//    AP28 RNTRC E AP26 N 1-1 8 - RNTRC do Contratado.
//  AP29 Contratante RAIZ AP01 - 1-1 - - -
//    AP30 CpfOuCnpj E AP29 N 1-1 11-14 - CPF ou CNPJ do Contratante.
//    AP31 EMail E AP29 S 0-1 - - Email do Contratante.
//    AP32 Endereco RAIZ AP29 - 1-1 - - -
//      AP33 Bairro E AP32 S 1-1 - - Bairro do Contratante.
//      AP34 CEP E AP32 S 1-1 - - CEP do Contratante.
//      AP35 CodigoMunicipio E AP32 N 1-1 7 - Código do município segundo o IBGE.
//      AP36 Rua E AP32 S 1-1 - - Rua e número do Contratante.
//      AP37 Numero E AP32 S 1-1 - - -
//      AP38 Complemento E AP32 S 0-1 - - -
//    AP39 NomeOuRazaoSocial E AP29 S 1-1 - - Nome ou Razão Social do Contratante.
//    AP40 ResponsavelPeloPagamento E AP29 B 1-1 - - Informar se é o responsável pelo pagamento da Operação de Transporte. True = Sim. False = Não.
//    AP41 Telefones RAIZ AP29 - 0-1 - - -
//      AP42 Celular RAIZ AP41 - 0-1 - - -
//        AP43 DDD R AP42 N 0-1 2 - -
//        AP44 Numero R AP42 N 0-1 8-9 - -
//      AP45 Fax RAIZ AP41 - 0-1 - - -
//        AP46 DDD E AP45 N 0-1 2 - -
//        AP47 Numero E AP45 N 0-1 8-9 - -
//      AP48 Fixo RAIZ AP41 - 0-1 - - -
//        AP49 DDD E AP48 N 0-1 2 - -
//        AP50 Numero E AP48 N 0-1 8-9 - -
//  AP51 DataFimViagem E AP01 DT 1-1 - - Data prevista para o fim de viagem.
//  AP52 DataInicioViagem E AP01 DT 0-1 - - Data de início da viagem. Operação do tipo 1 seu preenchimento é obrigatório.
//  AP53 Destinatario RAIZ AP01 - 1-1 - - Destinatário da carga.
//    AP54 CpfOuCnpj E AP53 N 1-1 11-14 - CPF ou CNPJ do Destinatário.
//    AP55 EMail E AP53 S 0-1 - - Email do Destinatário. Cópia de uso exclusivo da: - AMERICA SOFT INFORMATICA LTDA CNPJ: 03961263000155 IPC Administração Ltda. - www.efrete.com 24 Manual Técnico de Integração WebService – Sistema e-FRETE Empresa gestora IPC Administração LTDA. Especificador: IPC - Desenvolvimento Versão 2.4
//    AP56 Endereco RAIZ AP53 - 1-1 - - -
//      AP57 Bairro E AP56 S 1-1 - - Bairro do Destinatário.
//      AP58 CEP E AP56 S 1-1 - - CEP do Destinatário.
//      AP59 CodigoMunicipio E AP56 N 1-1 7 - Código do município segundo o IBGE.
//      AP60 Rua E AP56 S 1-1 - - Rua e número do Destinatário.
//      AP61 Numero E AP56 S 1-1 - - -
//      AP62 Complemento E AP56 S 0-1 - - -
//    AP63 NomeOuRazaoSocial E AP53 S 1-1 - - Nome ou Razão Social do Destinatário.
//    AP64 ResponsavelPeloPagamento E AP53 B 1-1 - - Informar se é o responsável pelo pagamento da Operação de Transporte. True = Sim. False = Não.
//    AP65 Telefones RAIZ AP53 - 0-1 - - -
//      AP66 Celular RAIZ AP65 - 0-1 - - -
//        AP67 DDD R AP66 N 0-1 2 - -
//        AP68 Numero R AP66 N 0-1 8-9 - -
//      AP69 Fax RAIZ AP65 - 0-1 - - -
//        AP70 DDD E AP69 N 0-1 2 - -
//        AP71 Numero E AP69 N 0-1 8-9 - -
//      AP72 Fixo RAIZ AP65 - 0-1 - - -
//        AP73 DDD E AP72 N 0-1 2 - -
//        AP74 Numero E AP72 N 0-1 8-9 - -
//  AP75 FilialCNPJ E AP01 N 0-1 - - CPNJ da filial do Contratante, que está realizando a operação de transporte, se necessário.
//  AP76 IdOperacaoCliente E AP01 S - - - Id / Chave primária da operação de transporte no sistema do Cliente.
//  AP77 Integrador E AP01 S 1-1 - - Hash de referência ao integrador.
//  AP78 Impostos RAIZ AP01 - 1-1 - - -
//    AP79 DescricaoOutrosImpostos E AP78 S 0-1 - - Descrição dos impostos com valor no campo OutrosImpostos.
//    AP80 INSS E AP78 M 1-1 - - Valor destinado ao INSS. Este valor deverá fazer parte do valor de Adiantamento ou do valor de Quitação. Cópia de uso exclusivo da: - AMERICA SOFT INFORMATICA LTDA CNPJ: 03961263000155 IPC Administração Ltda. - www.efrete.com 25  Manual Técnico de Integração WebService – Sistema e-FRETE Empresa gestora IPC Administração LTDA. Especificador: IPC - Desenvolvimento Versão 2.4
//    AP81 IRRF E AP78 M 1-1 - - Valor destinado ao IRRF. Este valor deverá fazer parte do valor de Adiantamento ou do valor de Quitação.
//    AP82 ISSQN E AP78 M 1-1 - - Valor destinado ao ISSQN. Este valor deverá fazer parte do valor de Adiantamento ou do valor de Quitação.
//    AP83 OutrosImpostos E AP78 M 0-1 - - Valor destinado a outros impostos não previstos. Este valor deverá fazer parte do valor de Adiantamento ou do valor de Quitação.
//    AP84 SestSenat E AP78 M 1-1 - - Valor destinado ao SEST / SENAT. Este valor deverá fazer parte  do valor de Adiantamento ou do valor de Quitação.
//  AP85 MatrizCNPJ E AP01 N 1-1 - - CNPJ da Matriz da Transportadora.
//  AP86 Motorista RAIZ AP01 - 1-1 - - É o condutor do veículo que irá realizar a operação de transporte, pode ser o proprietário do veículo ou não.
//    AP87 Celular RAIZ AP86 N 1-1 - - -
//      AP88 DDD E AP87 N 1-1 2 - DDD do celular do Motorista.
//      AP89 Numero E AP87 N 1-1 8-9 - Número do celular do Motorista.
//    AP90 CpfOuCnpj E AP86 N 1-1 11-14 - CPF ou CNPJ do Motorista.
//  AP91 Pagamentos RAIZ AP01 - 1-N - - Pagamentos registrados. - Pode existir mais de 1 pagamento com uma mesma categoria (exceto para Quitacao). - A soma dos pagamentos c/ categoria Adiantamento, deverá ter o mesmo valor apontado na tag TotalAdiantamento da tag Viagem/Valores, e neste caso, a tag Documento do pagamento deverá conter o mesmo valor da tag DocumentoViagem da tag Viagem . - Se a viagem possuir a tag TotalQuitacao maior que zero, deverá ter um pagamento correspondente, com Categoria Quitacao e com o Documento o mesmo valor apontado na tag DocumentoViagem . Cópia de uso exclusivo da: - AMERICA SOFT INFORMATICA LTDA CNPJ: 03961263000155 IPC Administração Ltda. - www.efrete.com 26 Manual Técnico de Integração WebService – Sistema e-FRETE Empresa gestora IPC Administração LTDA. Especificador: IPC - Desenvolvimento Versão 2.4 AP92 Categoria E AP91 S 1-1 - - Categoria relacionada ao pagamento realizado. Restrita aos membros da ENUM: -Adiantamento, -Estadia, Quitacao, -SemCategoria
//    AP93 DataDeLiberacao E AP91 DT 0-N - - Data em que o pagamento será liberado para saque.
//    AP94 Documento E AP91 S - - - Documento relacionado a viagem.
//    AP95 IdPagamentoCliente E AP91 S 0-N - - Identificador do pagamento no sistema do Cliente.
//    AP96 InformacaoAdicional E AP91 S 0-N - - Informação adicional caso o cliente precise registrar alguma observação.
//    AP97 InformacoesBancarias RAIZ AP91 - - - - Dados da instituição bancária que irá ser realizado o pagamento.
//      AP98 Agencia E AP97 S 1-1 - - Agência na qual o contratado possui conta com dígito.
//      AP99 Conta E AP97 S 1-1 - - Conta do contratado com dígito.
//      AP100 InstituicaoBancaria E AP97 S 1-1 - - Nome da instituição bancária que será realizado o pagamento.
//    AP101 TipoPagamento E AP91 S 1-1 - - Tipo de pagamento que será usado pelo contratante. Restrito aos itens da enum: -TransferenciaBancaria -eFRETE
//    AP102 Valor E AP91 M 0-N - - Valor do pagamento.
//  AP103 PesoCarga E AP01 D 1-1 - N,5 Peso total da carga.
//  AP104 Subcontratante RAIZ AP01 - 0-1 - - É o transportador que contratar outro transportador para realização do transporte de cargas para o qual fora anteriormente contratado, indicado no cadastramento da Operação de Transporte.
//    AP105 CpfOuCnpj E AP104 N 0-1 11-14 - CPF ou CNPJ do Subcontratante.
//    AP106 EMail E AP104 S 0-1 - - Email do Subcontratante.
//    AP107 Endereco RAIZ AP104 - 0-1 - - Endereço do Subcontratante.
//      AP108 Bairro E AP107 S 0-1 - - Bairro do Subcontratante.
//      AP109 CEP E AP107 S 0-1 - - CEP do Subcontratante. Cópia de uso exclusivo da: - AMERICA SOFT INFORMATICA LTDA CNPJ: 03961263000155 IPC Administração Ltda. - www.efrete.com 27 Manual Técnico de Integração WebService – Sistema e-FRETE Empresa gestora IPC Administração LTDA. Especificador: IPC - Desenvolvimento Versão 2.4
//      AP110 CodigoMunicipio E AP107 N 0-1 7 - Código do município segundo o IBGE.
//      AP112 Rua E AP107 S 0-1 - - Rua e número do Subcontratante.
//      AP113 Numero E AP107 S 0-1 - - -
//      AP114 Complemento E AP107 S 0-1 - - -
//    AP115 NomeOuRazaoSocial E AP104 S 1-1 - - Nome ou Razão Social do Subcontratante.
//    AP116 ResponsavelPeloPagamento E AP104 B 1-1 - - Informar se é o responsável pelo pagamento da Operação de Transporte. True = Sim. False = Não.
//    AP117 Telefones RAIZ AP104 - 0-1 - - -
//      AP118 Celular RAIZ AP117 - 0-1 - - -
//        AP119 DDD R AP118 N 0-1 2 - -
//        AP120 Numero R AP118 N 0-1 8-9 - -
//      AP121 Fax RAIZ AP117 - 0-1 - - -
//        AP122 DDD E AP121 N 0-1 2 - -
//        AP123 Numero E AP121 N 0-1 8-9 - -
//      AP124 Fixo RAIZ AP117 - 0-1 - - -
//        AP125 DDD E AP124 N 0-1 2 - -
//        AP126 Numero E AP124 N 0-1 8-9 - -
//  AP127 TipoViagem E AP01 S 1-1 - - Restrito aos itens da enum: -SemVinculoANTT -Padrao -TAC_Agregado
//  AP128 Token E AP01 S 1-1 - - Token de autenticação do contratante.
//  AP129 Veiculos RAIZ AP01 - 1-5 - - Registro dos veículos participantes da operação de transporte.
//    AP130 Placa E AP129 S 1-1 7 - Placa do veículo conforme exemplo: AAA1234.
//  AP131 Versao E AP01 N 1-1 1 - Versão = 3
//  AP132 Viagens RAIZ AP01 - - - - Viagens registradas.
//    AP133 CodigoMunicipioDestino E AP132 N - 7 Código do Município de destino segundo IBGE
//    AP134 CodigoMunicipioOrigem E AP132 N - 7 Código do Município de origem segundo IBGE
//    AP135 DocumentoViagem E AP132 S 1-1 - Exemplo: CT-e / Serie, CTRC / Serie, Ordem de Cópia de uso exclusivo da: - AMERICA SOFT INFORMATICA LTDA CNPJ: 03961263000155 IPC Administração Ltda. - www.efrete.com 28 Manual Técnico de Integração WebService – Sistema e-FRETE Empresa gestora IPC Administração LTDA. Especificador: IPC - Desenvolvimento Versão 2.4 Serviço.
//    AP136 NotasFiscais RAIZ AP132 - 1-N - - Notas fiscais da Viagem.
//      AP137 CodigoNCMNaturezaCarga E AP136 N 1-1 4 - Código da mercadoria de acordo com a tabela NCM
//      AP138 Data E AP136 DT 0-1 - - Data da nota fiscal.
//      AP139 DescricaoDaMercadoria E AP136 S 0-1 - - Descrição adicional ao código NCM.
//      AP140 Numero E AP136 S 1-1 - - Número da nota fiscal.
//      AP141 QuantidadeDaMercadoriaNoEmbarque E AP136 D 1-1 - - Quantidade da mercadoria no embarque.
//      AP142 Serie E AP136 S 1-1 - - Série da nota fiscal.
//      AP143 TipoDeCalculo E AP136 S 1-1 - - Tipo de cálculo a ser efetuado para quebra de frete. Restrito aos itens da enum: -SemQuebra -QuebraSomenteUltrapassado -QuebraIntegral.
//      AP144 ToleranciaDePerdaDeMercadoria RAIZ AP136 - 1-1 - - Configuração da tolerância de perda de carga.
//        AP145 Tipo E AP144 S 1-1 - - Tipo de tolerância que será admitido para fretes com quebra. Restrito aos itens da enum: -Nenhum -Porcentagem -ValorAbsoluto.
//        AP146 Valor E AP144 M 1-1 - - Valor da tolerância admitido.
//      AP147 DiferencaDeFrete RAIZ AP136 - 0-1 - - Configuração para a diferença no valor a ser pago ao motorista referente apenas ao valor contratado do frete.
//        AP148 Tipo E AP147 S 1-1 - - Tipo de diferença do frete configurada. Restrito aos itens da Enum: - SemDiferenca; - SomenteUltrapassado; - Integral.
//        AP149 Base E AP147 S 1-1 - - Configuração de qual quantidade deve ser utilizada para o recalculo. Restrito aos itens da Enum: - QuantidadeDesembarque; - QuantidadeMenor.
//        AP150 Tolerancia RAIZ AP147 - 1-1 - - Configuração da tolerância aceita para cálculo.
//          AP151 Tipo E AP150 S 1-1 - - Definição do tipo da tolerância que será aceita. Restrito aos itens da Enum: Cópia de uso exclusivo da: - AMERICA SOFT INFORMATICA LTDA CNPJ: 03961263000155 IPC Administração Ltda. - www.efrete.com 29 Manual Técnico de Integração WebService – Sistema e-FRETE Empresa gestora IPC Administração LTDA. Especificador: IPC - Desenvolvimento Versão 2.4 - Nenhum; - Porcentagem; - Absoluto.
//          AP152 Valor E AP150 M 1-1 - - Valor da tolerância admitido. Nenhum: 0; Porcentagem: 0.00 – 100.00; Absoluto: Livre.
//        AP153 MargemGanho RAIZ AP147 1-1 - - - Configuração do máximo ganho de quantidade, utilizado para quando a diferença de frete tem como base a quantidade no desembarque e esta sendo maior que no embarque, serve para limitar (somente neste calculo) o aumento de peso.
//          AP154 Tipo E AP153 S 1-1 - - Definição do tipo da tolerância que será aceita. Restrito aos itens da Enum: - Nenhum; - Porcentagem; - Absoluto.
//          AP155 Valor E AP153 M 1-1 - - Valor da tolerância admitido.  Nenhum: 0; Porcentagem: 0.00 – 100.00; Absoluto: Livre.
//        AP156 MargemPerda RAIZ AP147 1-1 - - - Configuração da máxima perda de quantidade, serve para limitar (somente neste calculo) a perda de peso.
//          AP157 Tipo E AP156 S 1-1 - - Definição do tipo da tolerância que será aceita. Restrito aos itens da Enum: - Nenhum; - Porcentagem; - Absoluto.
//          AP158 Valor E AP156 M 1-1 - - Valor da tolerância admitido. Nenhum: 0; Porcentagem: 0.00 – 100.00; Absoluto: Livre.
//      AP159 UnidadeDeMedida DaMercadoria E AP136 S 1-1 - - Unidade de medida do produto. Restrito aos itens da enum: -Tonelada; -Kg;
//      AP160 ValorDaMercadoria PorUnidade E AP136 M 1-1 - - Valor da mercadoria por unidade AP161 ValorDoFretePorUnidadeDeMercadoria E AP136 M 0-1 - - Valor do frete por unidade de mercadoria, utilizado para cálculo da quebra. Em caso de frete com quebra seu preenchimento é obrigatório diferente de 0 (zero).
//      AP162 ValorTotal E AP136 M 1-1 - - Valor total da nota fiscal.
//    AP163 Valores RAIZ AP132 - - - - Valores monetários da viagem.
//      AP164 Combustivel E AP163 M 1-1 - - Valor destinado ao combustível. Este valor uma vez preenchido está contido dentro do valor informado para adiantamento.
//      AP165 JustificativaOutros Creditos E AP163 S - - - Justificativa para valor de outros créditos. No caso do campo OutrosCreditos ser maior que zero seu preenchimento torna-se obrigatório.
//      AP166 JustificativaOutros Debitos E AP163 S - - - Justificativa para valor de outros débitos. No caso do campo OutrosDebitos ser maior que zero seu preenchimento torna-se obrigatório.
//      AP167 OutrosCreditos E AP163 M 1-1 - - Valor livre. Este valor deverá fazer parte do valor de Adiantamento ou do valor de Quitação.
//      AP168 OutrosDebitos E AP163 M 1-1 - - Valor livre. Este valor deverá fazer parte do valor de Adiantamento ou do valor de Quitação.
//      AP169 Pedagio E AP163 M 1-1 - - Valor destinado ao pedágio. Este valor deverá fazer parte do valor de Adiantamento ou do valor de Quitação.
//      AP170 Seguro E AP163 M 1-1 - - Valor destinado ao seguro. Este valor deverá fazer parte do valor de Adiantamento ou do valor de Quitação.
//      AP171 TotalDeAdiantamento E AP163 M 1-1 - - Valor total disponibilizado para adiantamento.
//      AP172 TotalDeQuitacao E AP163 M 1-1 - - Valor total disponibilizado para quitação.
//      AP173 TotalOperacao E AP163 M 1-1 - - Valor total da operação de transporte incluindo os créditos e débitos extras. AP174 TotalViagem E AP163 M 1-1 - - Valor referente somente ao transporte.
//  AP175 EmissaoGratuita E AP01 B 1-1 - - Admite os valores True ou False.
//  AP176 ObservacoesAoTransportador E AP01 A 1-1 - - -
//    AP177 String E AP176 S 0-N - - Orientações destinadas ao contratado.
//  AP178 ObservacoesAoCredenciado E AP01 A 1-1 - - -
//    AP179 String E AP178 S 0-N - - Orientações destinadas ao credenciado.





  Gerador.wGrupo('/AdicionarOperacaoTransporteRequest');



  Gerador.wCampo(tcStr, '#006', 'cCT     ', 08, 08, 1, IntToStrZero(RetornarCodigoNumerico(CIOT.infCIOT.ID, 2), 8), DSC_CNF);
  Gerador.wCampo(tcInt, '#007', 'CFOP    ', 04, 04, 1, CIOT.ide.CFOP, DSC_CFOP);
  Gerador.wCampo(tcStr, '#008', 'natOp   ', 01, 60, 1, CIOT.ide.natOp, DSC_NATOP);
  Gerador.wCampo(tcStr, '#009', 'forPag  ', 01, 01, 1, tpforPagToStr(CIOT.ide.forPag), DSC_INDPAG);
  Gerador.wCampo(tcInt, '#010', 'mod     ', 02, 02, 1, CIOT.ide.modelo, DSC_MOD);
  Gerador.wCampo(tcInt, '#011', 'serie   ', 01, 03, 1, CIOT.ide.serie, DSC_SERIE);
  Gerador.wCampo(tcInt, '#012', 'nCT     ', 01, 09, 1, CIOT.ide.nCT, DSC_NNF);
  Gerador.wCampo(tcDatHor, '#013', 'dhEmi', 19, 19, 1, CIOT.ide.dhEmi, DSC_DEMI);
  Gerador.wCampo(tcStr, '#014', 'tpImp   ', 01, 01, 1, tpImpToStr(CIOT.Ide.tpImp), DSC_TPIMP);
  Gerador.wCampo(tcStr, '#015', 'tpEmis  ', 01, 01, 1, tpEmisToStr(CIOT.Ide.tpEmis), DSC_TPEMIS);
  Gerador.wCampo(tcInt, '#016', 'cDV     ', 01, 01, 1, CIOT.Ide.cDV, DSC_CDV);
  Gerador.wCampo(tcStr, '#017', 'tpAmb   ', 01, 01, 1, tpAmbToStr(CIOT.Ide.tpAmb), DSC_TPAMB);
  Gerador.wCampo(tcStr, '#018', 'tpCTe   ', 01, 01, 1, tpCTePagToStr(CIOT.Ide.tpCTe), DSC_TPCTE);
  Gerador.wCampo(tcStr, '#019', 'procEmi', 01, 01, 1, procEmiToStr(CIOT.Ide.procEmi), DSC_PROCEMI);
  Gerador.wCampo(tcStr, '#020', 'verProc', 01, 20, 1, CIOT.Ide.verProc, DSC_VERPROC);
  Gerador.wCampo(tcStr, '#021', 'refCTE ', 44, 44, 0, SomenteNumeros(CIOT.Ide.refCTE), DSC_REFCTE);
  if SomenteNumeros(CIOT.Ide.refCTe) <> '' then
    if not ValidarChave('NFe' + SomenteNumeros(CIOT.Ide.refCTe)) then
      Gerador.wAlerta('#021', 'refCTE', DSC_REFCTE, ERR_MSG_INVALIDO);
  Gerador.wCampo(tcInt, '#022', 'cMunEnv ', 07, 07, 1, CIOT.ide.cMunEnv, DSC_CMUNEMI);
  if not ValidarMunicipio(CIOT.ide.cMunEnv) then
    Gerador.wAlerta('#022', 'cMunEnv', DSC_CMUNEMI, ERR_MSG_INVALIDO);
  Gerador.wCampo(tcStr, '#023', 'xMunEnv ', 01, 60, 1, CIOT.ide.xMunEnv, DSC_XMUN);
  Gerador.wCampo(tcStr, '#024', 'UFEnv   ', 02, 02, 1, CIOT.ide.UFEnv, DSC_UF);
  if not ValidarUF(CIOT.ide.UFEnv) then
    Gerador.wAlerta('#024', 'UFEnv', DSC_UF, ERR_MSG_INVALIDO);
  Gerador.wCampo(tcStr, '#025', 'modal   ', 02, 02, 1, TpModalToStr(CIOT.Ide.modal), DSC_MODAL);
  Gerador.wCampo(tcStr, '#026', 'tpServ  ', 01, 01, 1, TpServPagToStr(CIOT.Ide.tpServ), DSC_TPSERV);
  Gerador.wCampo(tcInt, '#027', 'cMunIni ', 07, 07, 1, CIOT.ide.cMunIni, DSC_CMUNEMI);
  if not ValidarMunicipio(CIOT.ide.cMunIni) then
    Gerador.wAlerta('#027', 'cMunIni', DSC_CMUNEMI, ERR_MSG_INVALIDO);
  Gerador.wCampo(tcStr, '#028', 'xMunIni ', 01, 60, 1, CIOT.ide.xMunIni, DSC_XMUN);
  Gerador.wCampo(tcStr, '#029', 'UFIni   ', 02, 02, 1, CIOT.ide.UFIni, DSC_UF);
  if not ValidarUF(CIOT.ide.UFIni) then
    Gerador.wAlerta('#029', 'UFIni', DSC_UF, ERR_MSG_INVALIDO);
  Gerador.wCampo(tcInt, '#030', 'cMunFim ', 07, 07, 1, CIOT.ide.cMunFim, DSC_CMUNEMI);
  if not ValidarMunicipio(CIOT.ide.cMunFim) then
    Gerador.wAlerta('#030', 'cMunFim', DSC_CMUNEMI, ERR_MSG_INVALIDO);
  Gerador.wCampo(tcStr, '#031', 'xMunFim    ', 01, 60, 1, CIOT.ide.xMunFim, DSC_XMUN);
  Gerador.wCampo(tcStr, '#032', 'UFFim      ', 02, 02, 1, CIOT.ide.UFFim, DSC_UF);
  if not ValidarUF(CIOT.ide.UFFim) then
    Gerador.wAlerta('#032', 'UFFim', DSC_UF, ERR_MSG_INVALIDO);
  Gerador.wCampo(tcStr, '#033', 'retira     ', 01, 01, 1, TpRetiraPagToStr(CIOT.Ide.retira), DSC_RETIRA);
  Gerador.wCampo(tcStr, '#034', 'xDetRetira ', 01, 160, 0, CIOT.Ide.xdetretira, DSC_DRET);

  GerarToma03;
  GerarToma4;

  if CIOT.Ide.tpEmis = teFSDA
   then begin
     Gerador.wCampo(tcDatHor, '#057', 'dhCont ', 19, 019, 1, CIOT.ide.dhCont, DSC_DHCONT);
     Gerador.wCampo(tcStr,    '#058', 'xJust  ', 15, 256, 1, CIOT.ide.xJust, DSC_XJUSTCONT);
   end;
  Gerador.wGrupo('/ide');
end;

procedure TCIOTW.GerarToma03;
begin
  if (CIOT.Ide.Toma4.xNome = '') then
  begin
    Gerador.wGrupo('toma03', '#035');
    Gerador.wCampo(tcStr, '#036', 'toma ', 01, 01, 1, TpTomadorToStr(CIOT.ide.Toma03.Toma), DSC_TOMA);
    Gerador.wGrupo('/toma03');
  end;
end;

procedure TCIOTW.GerarToma4;
begin
  if (CIOT.Ide.Toma4.IE <> '') or
     (CIOT.Ide.Toma4.xNome <> '') then
  begin
    Gerador.wGrupo('toma4', '#037');
    Gerador.wCampo(tcStr, '#038', 'toma ', 01, 01, 1, TpTomadorToStr(CIOT.ide.Toma4.Toma), DSC_TOMA);

    if CIOT.Ide.Toma4.EnderToma.cPais = 1058 then
      Gerador.wCampoCNPJCPF('#039', '#040', CIOT.ide.Toma4.CNPJCPF, CIOT.Ide.Toma4.EnderToma.cPais)
     else
      Gerador.wCampo(tcStr, '#039', 'CNPJ', 00, 14, 1, '00000000000000', DSC_CNPJ);

    if CIOT.Ide.Toma4.IE <> ''
     then begin
      if Trim(CIOT.Ide.Toma4.IE) = 'ISENTO' then
        Gerador.wCampo(tcStr, '#041', 'IE ', 00, 14, 1, CIOT.Ide.Toma4.IE, DSC_IE)
      else
        Gerador.wCampo(tcStr, '#041', 'IE ', 00, 14, 1, SomenteNumeros(CIOT.Ide.Toma4.IE), DSC_IE);

      if (FOpcoes.ValidarInscricoes) then
        if not ValidarIE(CIOT.Ide.Toma4.IE, CIOT.Ide.Toma4.EnderToma.UF) then
          Gerador.wAlerta('#041', 'IE', DSC_IE, ERR_MSG_INVALIDO);
     end;

    Gerador.wCampo(tcStr, '#042', 'xNome  ', 01, 60, 1, CIOT.Ide.Toma4.xNome, DSC_XNOME);
    Gerador.wCampo(tcStr, '#043', 'xFant  ', 01, 60, 0, CIOT.Ide.Toma4.xFant, DSC_XFANT);
    Gerador.wCampo(tcStr, '#044', 'fone  ', 07, 12, 0, CIOT.Ide.Toma4.fone, DSC_FONE);

    GerarEnderToma;

    Gerador.wCampo(tcStr, '#056', 'email  ', 01, 60, 0, CIOT.Ide.Toma4.email, DSC_EMAIL);
    Gerador.wGrupo('/toma4');
  end;
end;

procedure TCIOTW.GerarEnderToma;
var
  cMun: integer;
  xMun: string;
  xUF: string;
begin
  AjustarMunicipioUF(xUF, xMun, cMun, CIOT.Ide.Toma4.EnderToma.cPais,
                                      CIOT.Ide.Toma4.EnderToma.UF,
                                      CIOT.Ide.Toma4.EnderToma.xMun,
                                      CIOT.Ide.Toma4.EnderToma.cMun);
  Gerador.wGrupo('enderToma', '#045');
  Gerador.wCampo(tcStr, '#046', 'xLgr   ', 01, 255, 1, CIOT.Ide.Toma4.EnderToma.xLgr, DSC_XLGR);
  Gerador.wCampo(tcStr, '#047', 'nro    ', 01, 60, 1, ExecutarAjusteTagNro(FOpcoes.FAjustarTagNro, CIOT.Ide.Toma4.EnderToma.nro), DSC_NRO);
  Gerador.wCampo(tcStr, '#048', 'xCpl   ', 01, 60, 0, CIOT.Ide.Toma4.EnderToma.xCpl, DSC_XCPL);
  Gerador.wCampo(tcStr, '#049', 'xBairro', 01, 60, 1, CIOT.Ide.Toma4.EnderToma.xBairro, DSC_XBAIRRO);
  Gerador.wCampo(tcInt, '#050', 'cMun   ', 07, 07, 1, cMun, DSC_CMUN);
  if not ValidarMunicipio(CIOT.Ide.Toma4.EnderToma.cMun) then
    Gerador.wAlerta('#050', 'cMun', DSC_CMUN, ERR_MSG_INVALIDO);
  Gerador.wCampo(tcStr, '#051', 'xMun   ', 01, 60, 1, xMun, DSC_XMUN);
  Gerador.wCampo(tcInt, '#052', 'CEP    ', 08, 08, 0, CIOT.Ide.Toma4.EnderToma.CEP, DSC_CEP);
  Gerador.wCampo(tcStr, '#053', 'UF     ', 02, 02, 1, xUF, DSC_UF);
  if not ValidarUF(xUF) then
    Gerador.wAlerta('#053', 'UF', DSC_UF, ERR_MSG_INVALIDO);
  Gerador.wCampo(tcInt, '#054', 'cPais  ', 04, 04, 0, CIOT.Ide.Toma4.EnderToma.cPais, DSC_CPAIS); // Conforme NT-2009/01
  Gerador.wCampo(tcStr, '#055', 'xPais  ', 01, 60, 0, CIOT.Ide.Toma4.EnderToma.xPais, DSC_XPAIS);
  Gerador.wGrupo('/enderToma');
end;

procedure TCIOTW.GerarCompl;
begin
  Gerador.wGrupo('compl', '#059');
  Gerador.wCampo(tcStr, '#060', 'xCaracAd  ', 01, 15, 0, CIOT.Compl.xCaracAd, DSC_XCARACAD);
  Gerador.wCampo(tcStr, '#061', 'xCaracSer ', 01, 30, 0, CIOT.Compl.xCaracSer, DSC_XCARACSET);
  Gerador.wCampo(tcStr, '#062', 'xEmi      ', 01, 20, 0, CIOT.Compl.xEmi, DSC_XEMI);

  GerarFluxo;

  // Alterado por Italo em 11/09/2013
  if (CIOT.Compl.Entrega.TipoData <> tdNaoInformado) and
     (CIOT.Compl.Entrega.TipoHora <> thNaoInformado)
   then GerarEntrega;

  Gerador.wCampo(tcStr, '#088', 'origCalc ', 01, 40, 0, CIOT.Compl.origCalc, DSC_ORIGCALC);
  Gerador.wCampo(tcStr, '#089', 'destCalc ', 01, 40, 0, CIOT.Compl.destCalc, DSC_DESTCALC);
  Gerador.wCampo(tcStr, '#090', 'xObs     ', 01, 2000, 0, CIOT.Compl.xObs, DSC_XOBS);

  GerarObsCont;
  GerarObsFisco;

  Gerador.wGrupo('/compl');
end;

procedure TCIOTW.GerarFluxo;
var
  i: integer;
begin
 if (CIOT.Compl.fluxo.xOrig<>'') or (CIOT.Compl.fluxo.pass.Count>0) or
    (CIOT.Compl.fluxo.xDest<>'') or (CIOT.Compl.fluxo.xRota<>'')
  then begin
   Gerador.wGrupo('fluxo', '#063');
   Gerador.wCampo(tcStr, '#064', 'xOrig ', 01, 15, 0, CIOT.Compl.fluxo.xOrig, DSC_XORIG);

   for i := 0 to CIOT.Compl.fluxo.pass.Count - 1 do
   begin
    Gerador.wGrupo('pass', '#065');
    Gerador.wCampo(tcStr, '#066', 'xPass ', 01, 15, 1, CIOT.Compl.fluxo.pass[i].xPass, DSC_XPASS);
    Gerador.wGrupo('/pass');
   end;
   if CIOT.Compl.fluxo.pass.Count > 990 then
    Gerador.wAlerta('#065', 'pass', '', ERR_MSG_MAIOR_MAXIMO + '990');

   Gerador.wCampo(tcStr, '#067', 'xDest ', 01, 15, 0, CIOT.Compl.fluxo.xDest, DSC_XDEST);
   Gerador.wCampo(tcStr, '#068', 'xRota ', 01, 10, 0, CIOT.Compl.fluxo.xRota, DSC_XROTA);
   Gerador.wGrupo('/fluxo');
  end;
end;

procedure TCIOTW.GerarEntrega;
begin
  Gerador.wGrupo('Entrega', '#069');

  case CIOT.Compl.Entrega.TipoData of
   tdSemData: begin
       Gerador.wGrupo('semData', '#070');
       Gerador.wCampo(tcStr, '#071', 'tpPer ', 01, 01, 1, TpDataPeriodoToStr(CIOT.Compl.Entrega.semData.tpPer), DSC_TPPER);
       Gerador.wGrupo('/semData');
      end;
  tdNaData, tdAteData, tdApartirData: begin
          Gerador.wGrupo('comData', '#072');
          Gerador.wCampo(tcStr, '#073', 'tpPer ', 01, 01, 1, TpDataPeriodoToStr(CIOT.Compl.Entrega.comData.tpPer), DSC_TPPER);
          Gerador.wCampo(tcDat, '#074', 'dProg ', 10, 10, 1, CIOT.Compl.Entrega.comData.dProg, DSC_DPROG);
          Gerador.wGrupo('/comData');
         end;
   tdNoPeriodo: begin
       Gerador.wGrupo('noPeriodo', '#075');
       Gerador.wCampo(tcStr, '#076', 'tpPer ', 01, 01, 1, TpDataPeriodoToStr(CIOT.Compl.Entrega.noPeriodo.tpPer), DSC_TPPER);
       Gerador.wCampo(tcDat, '#077', 'dIni  ', 10, 10, 1, CIOT.Compl.Entrega.noPeriodo.dIni, DSC_DINI);
       Gerador.wCampo(tcDat, '#078', 'dFim  ', 10, 10, 1, CIOT.Compl.Entrega.noPeriodo.dFim, DSC_DFIM);
       Gerador.wGrupo('/noPeriodo');
      end;
  end;

  case CIOT.Compl.Entrega.TipoHora of
   thSemHorario: begin
       Gerador.wGrupo('semHora', '#079');
       Gerador.wCampo(tcStr, '#080', 'tpHor ', 01, 01, 1, TpHorarioIntervaloToStr(CIOT.Compl.Entrega.semHora.tpHor), DSC_TPHOR);
       Gerador.wGrupo('/semHora');
      end;
  thNoHorario, thAteHorario, thApartirHorario: begin
          Gerador.wGrupo('comHora', '#081');
          Gerador.wCampo(tcStr, '#082', 'tpHor ', 01, 01, 1, TpHorarioIntervaloToStr(CIOT.Compl.Entrega.comHora.tpHor), DSC_TPHOR);
          Gerador.wCampo(tcStr, '#083', 'hProg ', 08, 08, 1, TimeToStr(CIOT.Compl.Entrega.comHora.hProg), DSC_HPROG);
          Gerador.wGrupo('/comHora');
         end;
   thNoIntervalo: begin
       Gerador.wGrupo('noInter', '#084');
       Gerador.wCampo(tcStr, '#085', 'tpHor ', 01, 01, 1, TpHorarioIntervaloToStr(CIOT.Compl.Entrega.noInter.tpHor), DSC_TPHOR);
       Gerador.wCampo(tcStr, '#086', 'hIni  ', 08, 08, 1, TimeToStr(CIOT.Compl.Entrega.noInter.hIni), DSC_HINI);
       Gerador.wCampo(tcStr, '#087', 'hFim  ', 08, 08, 1, TimeToStr(CIOT.Compl.Entrega.noInter.hFim), DSC_HFIM);
       Gerador.wGrupo('/noInter');
      end;
  end;

  Gerador.wGrupo('/Entrega');
end;

procedure TCIOTW.GerarObsCont;
var
  i: integer;
begin
  for i := 0 to CIOT.Compl.ObsCont.Count - 1 do
  begin
   Gerador.wGrupo('ObsCont xCampo="' + CIOT.Compl.ObsCont[i].xCampo + '"', '#092');
   Gerador.wCampo(tcStr, '#093', 'xTexto ', 01, 160, 1, CIOT.Compl.ObsCont[i].xTexto, DSC_OBSCONT);
   Gerador.wGrupo('/ObsCont');
  end;
  if CIOT.Compl.ObsCont.Count > 10 then
    Gerador.wAlerta('#091', 'ObsCont', DSC_OBSCONT, ERR_MSG_MAIOR_MAXIMO + '10');
end;

procedure TCIOTW.GerarObsFisco;
var
  i: integer;
begin
  for i := 0 to CIOT.Compl.ObsFisco.Count - 1 do
  begin
   Gerador.wGrupo('ObsFisco xCampo="' + CIOT.Compl.ObsFisco[i].xCampo + '"', '#095');
   Gerador.wCampo(tcStr, '#096', 'xTexto ', 01, 60, 1, CIOT.Compl.ObsFisco[i].xTexto, DSC_OBSFISCO);
   Gerador.wGrupo('/ObsFisco');
  end;
  if CIOT.Compl.ObsFisco.Count > 10 then
    Gerador.wAlerta('#094', 'ObsFisco', DSC_OBSFISCO, ERR_MSG_MAIOR_MAXIMO + '10');
end;

procedure TCIOTW.GerarEmit;
begin
  Gerador.wGrupo('emit', '#097');
  Gerador.wCampoCNPJ('#098', CIOT.Emit.CNPJ, CODIGO_BRASIL, True);
  Gerador.wCampo(tcStr, '#099', 'IE    ', 02, 14, 1, SomenteNumeros(CIOT.Emit.IE), DSC_IE);

  if (FOpcoes.ValidarInscricoes)
   then if not ValidarIE(CIOT.Emit.IE, CIOT.Emit.enderEmit.UF) then
         Gerador.wAlerta('#099', 'IE', DSC_IE, ERR_MSG_INVALIDO);
  Gerador.wCampo(tcStr, '#100', 'xNome ', 01, 60, 1, CIOT.Emit.xNome, DSC_XNOME);
  Gerador.wCampo(tcStr, '#101', 'xFant ', 01, 60, 0, CIOT.Emit.xFant, DSC_XFANT);

  GerarEnderEmit;
  Gerador.wGrupo('/emit');
end;

procedure TCIOTW.GerarEnderEmit;
var
  cMun: integer;
  xMun: string;
  xUF: string;
begin
  AjustarMunicipioUF(xUF, xMun, cMun, CODIGO_BRASIL,
                                      CIOT.Emit.enderEmit.UF,
                                      CIOT.Emit.enderEmit.xMun,
                                      CIOT.Emit.EnderEmit.cMun);
  Gerador.wGrupo('enderEmit', '#102');
  Gerador.wCampo(tcStr, '#103', 'xLgr   ', 01, 60, 1, CIOT.Emit.enderEmit.xLgr, DSC_XLGR);
  Gerador.wCampo(tcStr, '#104', 'nro    ', 01, 60, 1, ExecutarAjusteTagNro(FOpcoes.FAjustarTagNro, CIOT.Emit.enderEmit.nro), DSC_NRO);
  Gerador.wCampo(tcStr, '#105', 'xCpl   ', 01, 60, 0, CIOT.Emit.enderEmit.xCpl, DSC_XCPL);
  Gerador.wCampo(tcStr, '#106', 'xBairro', 01, 60, 1, CIOT.Emit.enderEmit.xBairro, DSC_XBAIRRO);
  Gerador.wCampo(tcInt, '#107', 'cMun   ', 07, 07, 1, cMun, DSC_CMUN);
  if not ValidarMunicipio(CIOT.Emit.EnderEmit.cMun) then
    Gerador.wAlerta('#107', 'cMun', DSC_CMUN, ERR_MSG_INVALIDO);
  Gerador.wCampo(tcStr, '#108', 'xMun   ', 01, 60, 1, xMun, DSC_XMUN);
  Gerador.wCampo(tcInt, '#109', 'CEP    ', 08, 08, 0, CIOT.Emit.enderEmit.CEP, DSC_CEP);
  Gerador.wCampo(tcStr, '#110', 'UF     ', 02, 02, 1, xUF, DSC_UF);
  if not ValidarUF(xUF) then
    Gerador.wAlerta('#110', 'UF', DSC_UF, ERR_MSG_INVALIDO);
  Gerador.wCampo(tcStr, '#111', 'fone   ', 07, 12, 0, somenteNumeros(CIOT.Emit.EnderEmit.fone), DSC_FONE);
  Gerador.wGrupo('/enderEmit');
end;

procedure TCIOTW.GerarRem;
begin
  if (CIOT.Rem.CNPJCPF <> '') or
     (CIOT.Rem.xNome <> '') then
    begin
      Gerador.wGrupo('rem', '#112');

      if CIOT.Rem.enderReme.cPais = 1058 then
        Gerador.wCampoCNPJCPF('#113', '#114', CIOT.Rem.CNPJCPF, CIOT.Rem.enderReme.cPais)
       else
        Gerador.wCampo(tcStr, '#113', 'CNPJ', 00, 14, 1, '00000000000000', DSC_CNPJ);

      if Trim(CIOT.Rem.IE) = 'ISENTO'
       then Gerador.wCampo(tcStr, '#115', 'IE ', 00, 14, 1, CIOT.Rem.IE, DSC_IE)
       else Gerador.wCampo(tcStr, '#115', 'IE ', 00, 14, 1, SomenteNumeros(CIOT.Rem.IE), DSC_IE);

      if (FOpcoes.ValidarInscricoes)
       then if not ValidarIE(CIOT.Rem.IE, CIOT.Rem.EnderReme.UF) then
        Gerador.wAlerta('#115', 'IE', DSC_IE, ERR_MSG_INVALIDO);

      if CIOT.Ide.tpAmb = taHomologacao
       then Gerador.wCampo(tcStr, '#116', 'xNome  ', 01, 60, 1, xRazao, DSC_XNOME)
       else Gerador.wCampo(tcStr, '#116', 'xNome  ', 01, 60, 1, CIOT.Rem.xNome, DSC_XNOME);
      Gerador.wCampo(tcStr, '#117', 'xFant  ', 01, 60, 0, CIOT.Rem.xFant, DSC_XFANT);
      Gerador.wCampo(tcStr, '#118', 'fone   ', 07, 12, 0, somenteNumeros(CIOT.Rem.fone), DSC_FONE);

      GerarEnderReme;
      Gerador.wCampo(tcStr, '#130', 'email  ', 01, 60, 0, CIOT.Rem.email, DSC_EMAIL);

      GerarLocColeta;
      Gerador.wGrupo('/rem');
    end;
end;

procedure TCIOTW.GerarEnderReme;
var
  cMun: integer;
  xMun: string;
  xUF: string;
begin
  AjustarMunicipioUF(xUF, xMun, cMun, CIOT.Rem.EnderReme.cPais,
                                      CIOT.Rem.EnderReme.UF,
                                      CIOT.Rem.EnderReme.xMun,
                                      CIOT.Rem.EnderReme.cMun);
  Gerador.wGrupo('enderReme', '#119');
  Gerador.wCampo(tcStr, '#120', 'xLgr    ', 01, 255, 1, CIOT.Rem.EnderReme.xLgr, DSC_XLGR);
  Gerador.wCampo(tcStr, '#121', 'nro     ', 01, 60, 1, ExecutarAjusteTagNro(FOpcoes.FAjustarTagNro, CIOT.Rem.EnderReme.nro), DSC_NRO);
  Gerador.wCampo(tcStr, '#122', 'xCpl    ', 01, 60, 0, CIOT.Rem.EnderReme.xCpl, DSC_XCPL);
  Gerador.wCampo(tcStr, '#123', 'xBairro ', 01, 60, 1, CIOT.Rem.EnderReme.xBairro, DSC_XBAIRRO);
  Gerador.wCampo(tcInt, '#124', 'cMun    ', 07, 07, 1, cMun, DSC_CMUN);
  if not ValidarMunicipio(CIOT.Rem.EnderReme.cMun) then
    Gerador.wAlerta('#124', 'cMun', DSC_CMUN, ERR_MSG_INVALIDO);
  Gerador.wCampo(tcStr, '#125', 'xMun    ', 01, 60, 1, xMun, DSC_XMUN);
  Gerador.wCampo(tcInt, '#126', 'CEP     ', 08, 08, 0, CIOT.Rem.EnderReme.CEP, DSC_CEP);
  Gerador.wCampo(tcStr, '#127', 'UF      ', 02, 02, 1, xUF, DSC_UF);
  if not ValidarUF(xUF) then
    Gerador.wAlerta('#127', 'UF', DSC_UF, ERR_MSG_INVALIDO);
  Gerador.wCampo(tcInt, '#128', 'cPais   ', 04, 04, 0, CIOT.Rem.EnderReme.cPais, DSC_CPAIS); // Conforme NT-2009/01
  Gerador.wCampo(tcStr, '#129', 'xPais   ', 01, 60, 0, CIOT.Rem.EnderReme.xPais, DSC_XPAIS);
  Gerador.wGrupo('/enderReme');
end;

procedure TCIOTW.GerarLocColeta;
begin
  if (CIOT.Rem.locColeta.CNPJCPF <> '') or
     (CIOT.Rem.locColeta.xNome <> '') then
  begin
    Gerador.wGrupo('locColeta', '#131');
    Gerador.wCampoCNPJCPF('#132', '#133', CIOT.Rem.locColeta.CNPJCPF, CODIGO_BRASIL);
    Gerador.wCampo(tcStr, '#134', 'xNome   ', 01, 60, 1, CIOT.Rem.locColeta.xNome, DSC_XNOME);
    Gerador.wCampo(tcStr, '#135', 'xLgr    ', 01, 255, 1, CIOT.Rem.locColeta.xLgr, DSC_XLGR);
    Gerador.wCampo(tcStr, '#136', 'nro     ', 01, 60, 1, ExecutarAjusteTagNro(FOpcoes.FAjustarTagNro, CIOT.Rem.locColeta.nro), DSC_NRO);
    Gerador.wCampo(tcStr, '#137', 'xCpl    ', 01, 60, 0, CIOT.Rem.locColeta.xCpl, DSC_XCPL);
    Gerador.wCampo(tcStr, '#138', 'xBairro ', 01, 60, 1, CIOT.Rem.locColeta.xBairro, DSC_XBAIRRO);
    Gerador.wCampo(tcInt, '#139', 'cMun    ', 07, 07, 1, CIOT.Rem.locColeta.cMun, DSC_CMUN);
    if not ValidarMunicipio(CIOT.Rem.locColeta.cMun) then
      Gerador.wAlerta('#139', 'cMun', DSC_CMUN, ERR_MSG_INVALIDO);
    Gerador.wCampo(tcStr, '#140', 'xMun    ', 01, 60, 1, CIOT.Rem.locColeta.xMun, DSC_XMUN);
    Gerador.wCampo(tcStr, '#141', 'UF      ', 02, 02, 1, CIOT.Rem.locColeta.UF, DSC_UF);
    if not ValidarUF(CIOT.Rem.locColeta.UF) then
      Gerador.wAlerta('#141', 'UF', DSC_UF, ERR_MSG_INVALIDO);
    Gerador.wGrupo('/locColeta');
  end;
end;

procedure TCIOTW.GerarExped;
begin
  if (CIOT.Exped.CNPJCPF <> '') or
     (CIOT.Exped.xNome <> '') then
  begin
    Gerador.wGrupo('exped', '#142');

    if CIOT.Exped.EnderExped.cPais = 1058 then
      Gerador.wCampoCNPJCPF('#143', '#144', CIOT.Exped.CNPJCPF, CIOT.Exped.EnderExped.cPais)
     else
      Gerador.wCampo(tcStr, '#143', 'CNPJ', 00, 14, 1, '00000000000000', DSC_CNPJ);

    if Trim(CIOT.Exped.IE) = 'ISENTO'
     then Gerador.wCampo(tcStr, '#145', 'IE ', 00, 14, 1, CIOT.Exped.IE, DSC_IE)
     else Gerador.wCampo(tcStr, '#145', 'IE ', 00, 14, 0, SomenteNumeros(CIOT.Exped.IE), DSC_IE);

    if (FOpcoes.ValidarInscricoes)
     then if not ValidarIE(CIOT.Exped.IE, CIOT.Exped.EnderExped.UF) then
      Gerador.wAlerta('#145', 'IE', DSC_IE, ERR_MSG_INVALIDO);

    if CIOT.Ide.tpAmb = taHomologacao
     then Gerador.wCampo(tcStr, '#146', 'xNome  ', 01, 60, 1, xRazao, DSC_XNOME)
     else Gerador.wCampo(tcStr, '#146', 'xNome  ', 01, 60, 1, CIOT.Exped.xNome, DSC_XNOME);
    Gerador.wCampo(tcStr, '#147', 'fone   ', 07, 12, 0, somenteNumeros(CIOT.Exped.fone), DSC_FONE);

    GerarEnderExped;
    Gerador.wCampo(tcStr, '#159', 'email  ', 01, 60, 0, CIOT.Exped.email, DSC_EMAIL);
    Gerador.wGrupo('/exped');
  end;
end;

procedure TCIOTW.GerarEnderExped;
var
  cMun: integer;
  xMun: string;
  xUF: string;
begin
  AjustarMunicipioUF(xUF, xMun, cMun, CIOT.Exped.EnderExped.cPais,
                                      CIOT.Exped.EnderExped.UF,
                                      CIOT.Exped.EnderExped.xMun,
                                      CIOT.Exped.EnderExped.cMun);
  Gerador.wGrupo('enderExped', '#148');
  Gerador.wCampo(tcStr, '#149', 'xLgr    ', 01, 255, 1, CIOT.Exped.EnderExped.xLgr, DSC_XLGR);
  Gerador.wCampo(tcStr, '#150', 'nro     ', 01, 60, 1, ExecutarAjusteTagNro(FOpcoes.FAjustarTagNro, CIOT.Exped.EnderExped.nro), DSC_NRO);
  Gerador.wCampo(tcStr, '#151', 'xCpl    ', 01, 60, 0, CIOT.Exped.EnderExped.xCpl, DSC_XCPL);
  Gerador.wCampo(tcStr, '#152', 'xBairro ', 01, 60, 1, CIOT.Exped.EnderExped.xBairro, DSC_XBAIRRO);
  Gerador.wCampo(tcInt, '#153', 'cMun    ', 07, 07, 1, cMun, DSC_CMUN);
  if not ValidarMunicipio(CIOT.Exped.EnderExped.cMun) then
    Gerador.wAlerta('#153', 'cMun', DSC_CMUN, ERR_MSG_INVALIDO);
  Gerador.wCampo(tcStr, '#154', 'xMun    ', 01, 60, 1, xMun, DSC_XMUN);
  Gerador.wCampo(tcInt, '#155', 'CEP     ', 08, 08, 0, CIOT.Exped.EnderExped.CEP, DSC_CEP);
  Gerador.wCampo(tcStr, '#156', 'UF      ', 02, 02, 1, xUF, DSC_UF);
  if not ValidarUF(xUF) then
    Gerador.wAlerta('#156', 'UF', DSC_UF, ERR_MSG_INVALIDO);
  Gerador.wCampo(tcInt, '#157', 'cPais   ', 04, 04, 0, CIOT.Exped.EnderExped.cPais, DSC_CPAIS); // Conforme NT-2009/01
  Gerador.wCampo(tcStr, '#158', 'xPais   ', 01, 60, 0, CIOT.Exped.EnderExped.xPais, DSC_XPAIS);
  Gerador.wGrupo('/enderExped');
end;

procedure TCIOTW.GerarReceb;
begin
  if (CIOT.Receb.CNPJCPF <> '') or
     (CIOT.Receb.xNome <> '') then
  Begin
    Gerador.wGrupo('receb', '#160');

    if CIOT.Receb.EnderReceb.cPais = 1058 then
      Gerador.wCampoCNPJCPF('#161', '#162', CIOT.Receb.CNPJCPF, CIOT.Receb.EnderReceb.cPais)
     else
      Gerador.wCampo(tcStr, '#161', 'CNPJ', 00, 14, 1, '00000000000000', DSC_CNPJ);

    if Trim(CIOT.Receb.IE) = 'ISENTO'
     then Gerador.wCampo(tcStr, '#163', 'IE ', 00, 14, 1, CIOT.Receb.IE, DSC_IE)
     else Gerador.wCampo(tcStr, '#163', 'IE ', 00, 14, 0, SomenteNumeros(CIOT.Receb.IE), DSC_IE);

    if (FOpcoes.ValidarInscricoes)
     then if not ValidarIE(CIOT.Receb.IE, CIOT.Receb.EnderReceb.UF) then
      Gerador.wAlerta('#163', 'IE', DSC_IE, ERR_MSG_INVALIDO);

    if CIOT.Ide.tpAmb = taHomologacao
     then Gerador.wCampo(tcStr, '#164', 'xNome  ', 01, 60, 1, xRazao, DSC_XNOME)
     else Gerador.wCampo(tcStr, '#164', 'xNome  ', 01, 60, 1, CIOT.Receb.xNome, DSC_XNOME);
    Gerador.wCampo(tcStr, '#165', 'fone   ', 07, 12, 0, somenteNumeros(CIOT.Receb.fone), DSC_FONE);

    GerarEnderReceb;
    Gerador.wCampo(tcStr, '#177', 'email  ', 01, 60, 0, CIOT.Receb.email, DSC_EMAIL);
    Gerador.wGrupo('/receb');
  end;
end;

procedure TCIOTW.GerarEnderReceb;
var
  cMun: integer;
  xMun: string;
  xUF: string;
begin
  AjustarMunicipioUF(xUF, xMun, cMun, CIOT.Receb.EnderReceb.cPais,
                                      CIOT.Receb.EnderReceb.UF,
                                      CIOT.Receb.EnderReceb.xMun,
                                      CIOT.Receb.EnderReceb.cMun);
  Gerador.wGrupo('enderReceb', '#166');
  Gerador.wCampo(tcStr, '#167', 'xLgr    ', 01, 255, 1, CIOT.Receb.EnderReceb.xLgr, DSC_XLGR);
  Gerador.wCampo(tcStr, '#168', 'nro     ', 01, 60, 1, ExecutarAjusteTagNro(FOpcoes.FAjustarTagNro, CIOT.Receb.EnderReceb.nro), DSC_NRO);
  Gerador.wCampo(tcStr, '#169', 'xCpl    ', 01, 60, 0, CIOT.Receb.EnderReceb.xCpl, DSC_XCPL);
  Gerador.wCampo(tcStr, '#170', 'xBairro ', 01, 60, 1, CIOT.Receb.EnderReceb.xBairro, DSC_XBAIRRO);
  Gerador.wCampo(tcInt, '#171', 'cMun    ', 07, 07, 1, cMun, DSC_CMUN);
  if not ValidarMunicipio(CIOT.Receb.EnderReceb.cMun) then
    Gerador.wAlerta('#171', 'cMun', DSC_CMUN, ERR_MSG_INVALIDO);
  Gerador.wCampo(tcStr, '#172', 'xMun    ', 01, 60, 1, xMun, DSC_XMUN);
  Gerador.wCampo(tcInt, '#173', 'CEP     ', 08, 08, 0, CIOT.Receb.EnderReceb.CEP, DSC_CEP);
  Gerador.wCampo(tcStr, '#174', 'UF      ', 02, 02, 1, xUF, DSC_UF);
  if not ValidarUF(xUF) then
    Gerador.wAlerta('#174', 'UF', DSC_UF, ERR_MSG_INVALIDO);
  Gerador.wCampo(tcInt, '#175', 'cPais   ', 04, 04, 0, CIOT.Receb.EnderReceb.cPais, DSC_CPAIS); // Conforme NT-2009/01
  Gerador.wCampo(tcStr, '#176', 'xPais   ', 01, 60, 0, CIOT.Receb.EnderReceb.xPais, DSC_XPAIS);
  Gerador.wGrupo('/enderReceb');
end;

procedure TCIOTW.GerarDest;
begin
  if (CIOT.Dest.CNPJCPF <> '') or
     (CIOT.Dest.xNome <> '') then
    begin
      Gerador.wGrupo('dest', '#178');

      if CIOT.Dest.EnderDest.cPais = 1058 then
        Gerador.wCampoCNPJCPF('#179', '#180', CIOT.Dest.CNPJCPF, CIOT.Dest.EnderDest.cPais)
       else
        Gerador.wCampo(tcStr, '#179', 'CNPJ', 00, 14, 1, '00000000000000', DSC_CNPJ);

      if CIOT.Dest.IE <> ''
       then begin
        if Trim(CIOT.Dest.IE) = 'ISENTO'
         then Gerador.wCampo(tcStr, '#181', 'IE ', 00, 14, 1, CIOT.Dest.IE, DSC_IE)
         else Gerador.wCampo(tcStr, '#181', 'IE ', 00, 14, 1, SomenteNumeros(CIOT.Dest.IE), DSC_IE);

        if (FOpcoes.ValidarInscricoes)
         then if not ValidarIE(CIOT.Dest.IE, CIOT.Dest.EnderDest.UF) then
          Gerador.wAlerta('#181', 'IE', DSC_IE, ERR_MSG_INVALIDO);
       end;

      if CIOT.Ide.tpAmb = taHomologacao
       then Gerador.wCampo(tcStr, '#182', 'xNome  ', 01, 60, 1, xRazao, DSC_XNOME)
       else Gerador.wCampo(tcStr, '#182', 'xNome  ', 01, 60, 1, CIOT.Dest.xNome, DSC_XNOME);

      Gerador.wCampo(tcStr, '#183', 'fone   ', 07, 12, 0, somenteNumeros(CIOT.Dest.fone), DSC_FONE);
      Gerador.wCampo(tcStr, '#184', 'ISUF   ', 08, 09, 0, CIOT.Dest.ISUF, DSC_ISUF);
      if (FOpcoes.ValidarInscricoes) and (CIOT.Dest.ISUF <> '') then
        if not ValidarISUF(CIOT.Dest.ISUF) then
          Gerador.wAlerta('#184', 'ISUF', DSC_ISUF, ERR_MSG_INVALIDO);

      GerarEnderDest;
      Gerador.wCampo(tcStr, '#196', 'email  ', 01, 60, 0, CIOT.Dest.email, DSC_EMAIL);
      GerarLocEnt;
      Gerador.wGrupo('/dest');
    end;
end;

procedure TCIOTW.GerarEnderDest;
var
  cMun: integer;
  xMun: string;
  xUF: string;
begin
  AjustarMunicipioUF(xUF, xMun, cMun, CIOT.Dest.EnderDest.cPais,
                                      CIOT.Dest.EnderDest.UF,
                                      CIOT.Dest.EnderDest.xMun,
                                      CIOT.Dest.EnderDest.cMun);
  Gerador.wGrupo('enderDest', '#185');
  Gerador.wCampo(tcStr, '#186', 'xLgr   ', 01, 255, 1, CIOT.Dest.EnderDest.xLgr, DSC_XLGR);
  Gerador.wCampo(tcStr, '#187', 'nro    ', 01, 60, 1, ExecutarAjusteTagNro(FOpcoes.FAjustarTagNro, CIOT.Dest.EnderDest.nro), DSC_NRO);
  Gerador.wCampo(tcStr, '#188', 'xCpl   ', 01, 60, 0, CIOT.Dest.EnderDest.xCpl, DSC_XCPL);
  Gerador.wCampo(tcStr, '#189', 'xBairro', 01, 60, 1, CIOT.Dest.EnderDest.xBairro, DSC_XBAIRRO);
  Gerador.wCampo(tcInt, '#190', 'cMun   ', 07, 07, 1, cMun, DSC_CMUN);
  if not ValidarMunicipio(CIOT.Dest.EnderDest.cMun) then
    Gerador.wAlerta('#190', 'cMun', DSC_CMUN, ERR_MSG_INVALIDO);
  Gerador.wCampo(tcStr, '#191', 'xMun   ', 01, 60, 1, xMun, DSC_XMUN);
  Gerador.wCampo(tcInt, '#192', 'CEP    ', 08, 08, 0, CIOT.Dest.EnderDest.CEP, DSC_CEP);
  Gerador.wCampo(tcStr, '#193', 'UF     ', 02, 02, 1, xUF, DSC_UF);
  if not ValidarUF(xUF) then
    Gerador.wAlerta('#193', 'UF', DSC_UF, ERR_MSG_INVALIDO);
  Gerador.wCampo(tcInt, '#194', 'cPais  ', 04, 04, 0, CIOT.Dest.EnderDest.cPais, DSC_CPAIS); // Conforme NT-2009/01
  Gerador.wCampo(tcStr, '#195', 'xPais  ', 01, 60, 0, CIOT.Dest.EnderDest.xPais, DSC_XPAIS);
  Gerador.wGrupo('/enderDest');
end;

procedure TCIOTW.GerarLocEnt;
begin
  if (CIOT.Dest.locEnt.CNPJCPF <> '') or
     (CIOT.Dest.locEnt.xNome <> '') then
  begin
    Gerador.wGrupo('locEnt', '#197');
    Gerador.wCampoCNPJCPF('#198', '#199', CIOT.Dest.locEnt.CNPJCPF, CODIGO_BRASIL);
    Gerador.wCampo(tcStr, '#200', 'xNome  ', 01, 60, 1, CIOT.Dest.locEnt.xNome, DSC_XNOME);
    Gerador.wCampo(tcStr, '#201', 'xLgr   ', 01, 255, 1, CIOT.Dest.locEnt.xLgr, DSC_XLGR);
    Gerador.wCampo(tcStr, '#202', 'nro    ', 01, 60, 1, ExecutarAjusteTagNro(FOpcoes.FAjustarTagNro, CIOT.Dest.locEnt.nro), DSC_NRO);
    Gerador.wCampo(tcStr, '#203', 'xCpl   ', 01, 60, 0, CIOT.Dest.locEnt.xCpl, DSC_XCPL);
    Gerador.wCampo(tcStr, '#204', 'xBairro', 01, 60, 1, CIOT.Dest.locEnt.xBairro, DSC_XBAIRRO);
    Gerador.wCampo(tcInt, '#205', 'cMun   ', 07, 07, 1, CIOT.Dest.locEnt.cMun, DSC_CMUN);
    if not ValidarMunicipio(CIOT.Dest.locEnt.cMun) then
      Gerador.wAlerta('#205', 'cMun', DSC_CMUN, ERR_MSG_INVALIDO);
    Gerador.wCampo(tcStr, '#206', 'xMun   ', 01, 60, 1, CIOT.Dest.locEnt.xMun, DSC_XMUN);
    Gerador.wCampo(tcStr, '#207', 'UF     ', 02, 02, 1, CIOT.Dest.locEnt.UF, DSC_UF);
    if not ValidarUF(CIOT.Dest.locEnt.UF) then
      Gerador.wAlerta('#207', 'UF', DSC_UF, ERR_MSG_INVALIDO);
    Gerador.wGrupo('/locEnt');
  end;
end;

procedure TCIOTW.GerarVPrest;
begin
  Gerador.wGrupo('vPrest', '#208');
  Gerador.wCampo(tcDe2, '#209', 'vTPrest ', 01, 15, 1, CIOT.vPrest.vTPrest, DSC_VTPREST);
  Gerador.wCampo(tcDe2, '#210', 'vRec    ', 01, 15, 1, CIOT.vPrest.vRec, DSC_VREC);

  GerarComp;
  Gerador.wGrupo('/vPrest');
end;

procedure TCIOTW.GerarComp;
var
  i: integer;
begin
  for i := 0 to CIOT.vPrest.comp.Count - 1 do
  begin
    if (CIOT.vPrest.comp[i].xNome <> '') and
      (CIOT.vPrest.comp[i].vComp <> 0) then
      begin
        Gerador.wGrupo('Comp', '#211');
        Gerador.wCampo(tcStr, '#212', 'xNome ', 01, 15, 1, CIOT.vPrest.comp[i].xNome, DSC_XNOMEC);
        Gerador.wCampo(tcDe2, '#213', 'vComp ', 01, 15, 1, CIOT.vPrest.comp[i].vComp, DSC_VCOMP);
        Gerador.wGrupo('/Comp');
      end;
  end;
end;

procedure TCIOTW.GerarImp;
begin
  Gerador.wGrupo('imp', '#214');
  GerarICMS;
  Gerador.wCampo(tcDe2, '#250', 'vTotTrib   ', 01, 15, 0, CIOT.Imp.vTotTrib, DSC_VCOMP);
  Gerador.wCampo(tcStr, '#251', 'infAdFisco ', 01, 2000, 0, CIOT.Imp.InfAdFisco, DSC_INFADFISCO);
  Gerador.wGrupo('/imp');
end;

procedure TCIOTW.GerarICMS;
begin
  Gerador.wGrupo('ICMS', '#215');

  if CIOT.Imp.ICMS.SituTrib = cst00 then
    GerarCST00
  else if CIOT.Imp.ICMS.SituTrib = cst20 then
    GerarCST20
  else if ((CIOT.Imp.ICMS.SituTrib = cst40) or
           (CIOT.Imp.ICMS.SituTrib = cst41) or
           (CIOT.Imp.ICMS.SituTrib = cst51)) then
    GerarCST45
  else if CIOT.Imp.ICMS.SituTrib = cst60 then
    GerarCST60
  else if CIOT.Imp.ICMS.SituTrib = cst90 then
    GerarCST90
  else if CIOT.Imp.ICMS.SituTrib = cstICMSOutraUF then
    GerarICMSOutraUF
  else if CIOT.Imp.ICMS.SituTrib = cstICMSSN then
    GerarICMSSN;

  Gerador.wGrupo('/ICMS');
end;

procedure TCIOTW.GerarCST00;
begin
  Gerador.wGrupo('ICMS00', '#216');
  Gerador.wCampo(tcStr, '#217', 'CST   ', 02, 02, 1, CSTICMSTOStr(CIOT.Imp.ICMS.ICMS00.CST), DSC_CST);
  Gerador.wCampo(tcDe2, '#218', 'vBC   ', 01, 15, 1, CIOT.Imp.ICMS.ICMS00.vBC, DSC_VBC);
  Gerador.wCampo(tcDe2, '#219', 'pICMS ', 01, 05, 1, CIOT.Imp.ICMS.ICMS00.pICMS, DSC_PICMS);
  Gerador.wCampo(tcDe2, '#220', 'vICMS ', 01, 15, 1, CIOT.Imp.ICMS.ICMS00.vICMS, DSC_VICMS);
  Gerador.wGrupo('/ICMS00');
end;

procedure TCIOTW.GerarCST20;
begin
  Gerador.wGrupo('ICMS20', '#221');
  Gerador.wCampo(tcStr, '#222', 'CST    ', 02, 02, 1, CSTICMSTOStr(CIOT.Imp.ICMS.ICMS20.CST), DSC_CST);
  Gerador.wCampo(tcDe2, '#223', 'pRedBC ', 01, 05, 1, CIOT.Imp.ICMS.ICMS20.pRedBC, DSC_PREDBC);
  Gerador.wCampo(tcDe2, '#224', 'vBC    ', 01, 15, 1, CIOT.Imp.ICMS.ICMS20.vBC, DSC_VBC);
  Gerador.wCampo(tcDe2, '#225', 'pICMS  ', 01, 05, 1, CIOT.Imp.ICMS.ICMS20.pICMS, DSC_PICMS);
  Gerador.wCampo(tcDe2, '#226', 'vICMS  ', 01, 15, 1, CIOT.Imp.ICMS.ICMS20.vICMS, DSC_VICMS);
  Gerador.wGrupo('/ICMS20');
end;

procedure TCIOTW.GerarCST45;
begin
  Gerador.wGrupo('ICMS45', '#227');
  Gerador.wCampo(tcStr, '#228', 'CST ', 02, 02, 1, CSTICMSTOStr(CIOT.Imp.ICMS.ICMS45.CST), DSC_CST);
  Gerador.wGrupo('/ICMS45');
end;

procedure TCIOTW.GerarCST60;
begin
  Gerador.wGrupo('ICMS60', '#229');
  Gerador.wCampo(tcStr, '#230', 'CST        ', 02, 02, 1, CSTICMSTOStr(CIOT.Imp.ICMS.ICMS60.CST), DSC_CST);
  Gerador.wCampo(tcDe2, '#231', 'vBCSTRet   ', 01, 15, 1, CIOT.Imp.ICMS.ICMS60.vBCSTRet, DSC_VBC);
  Gerador.wCampo(tcDe2, '#232', 'vICMSSTRet ', 01, 15, 1, CIOT.Imp.ICMS.ICMS60.vICMSSTRet, DSC_VICMS);
  Gerador.wCampo(tcDe2, '#233', 'pICMSSTRet ', 01, 05, 1, CIOT.Imp.ICMS.ICMS60.pICMSSTRet, DSC_PICMS);
  if CIOT.Imp.ICMS.ICMS60.vCred > 0 then
   Gerador.wCampo(tcDe2, '#234', 'vCred     ', 01, 15, 1, CIOT.Imp.ICMS.ICMS60.vCred, DSC_VCRED);
  Gerador.wGrupo('/ICMS60');
end;

procedure TCIOTW.GerarCST90;
begin
  Gerador.wGrupo('ICMS90', '#235');
  Gerador.wCampo(tcStr, '#236', 'CST      ', 02, 02, 1, CSTICMSTOStr(CIOT.Imp.ICMS.ICMS90.CST), DSC_CST);
  if CIOT.Imp.ICMS.ICMS90.pRedBC > 0 then
    Gerador.wCampo(tcDe2, '#237', 'pRedBC ', 01, 05, 1, CIOT.Imp.ICMS.ICMS90.pRedBC, DSC_PREDBC);
  Gerador.wCampo(tcDe2, '#238', 'vBC      ', 01, 15, 1, CIOT.Imp.ICMS.ICMS90.vBC, DSC_VBC);
  Gerador.wCampo(tcDe2, '#239', 'pICMS    ', 01, 05, 1, CIOT.Imp.ICMS.ICMS90.pICMS, DSC_PICMS);
  Gerador.wCampo(tcDe2, '#240', 'vICMS    ', 01, 15, 1, CIOT.Imp.ICMS.ICMS90.vICMS, DSC_VICMS);
  if CIOT.Imp.ICMS.ICMS90.vCred > 0 then
    Gerador.wCampo(tcDe2, '#241', 'vCred  ', 01, 15, 1, CIOT.Imp.ICMS.ICMS90.vCred, DSC_VCRED);
  Gerador.wGrupo('/ICMS90');
end;

procedure TCIOTW.GerarICMSOutraUF;
begin
  Gerador.wGrupo('ICMSOutraUF', '#242');
  Gerador.wCampo(tcStr, '#243', 'CST             ', 02, 02, 1, CSTICMSTOStr(CIOT.Imp.ICMS.ICMSOutraUF.CST), DSC_CST);
  if CIOT.Imp.ICMS.ICMSOutraUF.pRedBCOutraUF > 0 then
    Gerador.wCampo(tcDe2, '#244', 'pRedBCOutraUF ', 01, 05, 1, CIOT.Imp.ICMS.ICMSOutraUF.pRedBCOutraUF, DSC_PREDBC);
  Gerador.wCampo(tcDe2, '#245', 'vBCOutraUF      ', 01, 15, 1, CIOT.Imp.ICMS.ICMSOutraUF.vBCOutraUF, DSC_VBC);
  Gerador.wCampo(tcDe2, '#246', 'pICMSOutraUF    ', 01, 05, 1, CIOT.Imp.ICMS.ICMSOutraUF.pICMSOutraUF, DSC_PICMS);
  Gerador.wCampo(tcDe2, '#247', 'vICMSOutraUF    ', 01, 15, 1, CIOT.Imp.ICMS.ICMSOutraUF.vICMSOutraUF, DSC_VICMS);
  Gerador.wGrupo('/ICMSOutraUF');
end;

procedure TCIOTW.GerarICMSSN;
begin
  Gerador.wGrupo('ICMSSN', '#248');
  Gerador.wCampo(tcInt, '#249', 'indSN ', 01, 01, 1, CIOT.Imp.ICMS.ICMSSN.indSN, DSC_INDSN);
  Gerador.wGrupo('/ICMSSN');
end;

procedure TCIOTW.GerarInfCTeNorm;
begin
  if (CIOT.Ide.tpCTe = tcNormal) or (CIOT.Ide.tpCTe = tcSubstituto) then
  begin
    Gerador.wGrupo('infCTeNorm', '#252');
    GerarinfCarga;

    if (CIOT.Ide.tpServ <> tsIntermediario) and (CIOT.Ide.tpServ <> tsMultimodal)
     then GerarInfDoc;
     
    if CIOT.infCTeNorm.docAnt.emiDocAnt.Count>0
     then GerarDocAnt;
    GerarInfSeg;

    case StrToInt(TpModalToStr(CIOT.Ide.modal)) of
     01: Gerador.wGrupo('infModal versaoModal="' + CTeModalRodo + '"', '#366');
     02: Gerador.wGrupo('infModal versaoModal="' + CTeModalAereo + '"', '#366');
     03: Gerador.wGrupo('infModal versaoModal="' + CTeModalAqua + '"', '#366');
     04: Gerador.wGrupo('infModal versaoModal="' + CTeModalFerro + '"', '#366');
     05: Gerador.wGrupo('infModal versaoModal="' + CTeModalDuto + '"', '#366');
     06: Gerador.wGrupo('infModal versaoModal="' + CTeMultiModal + '"', '#366');
    end;
    case StrToInt(TpModalToStr(CIOT.Ide.modal)) of
     01: GerarRodo;       // Informações do Modal Rodoviário
     02: GerarAereo;      // Informações do Modal Aéreo
     03: GerarAquav;      // Informações do Modal Aquaviário
     04: GerarFerrov;     // Informações do Modal Ferroviário
     05: GerarDuto;       // Informações do Modal Dutoviário
     06: GerarMultimodal; // Informações do Multimodal
    end;
    Gerador.wGrupo('/infModal');

    GerarPeri; 
    GerarVeicNovos;
    GerarCobr;
    GerarInfCTeSub;

    Gerador.wGrupo('/infCTeNorm');
  end;
end;

procedure TCIOTW.GerarinfCarga;
begin
  Gerador.wGrupo('infCarga', '#253');
  Gerador.wCampo(tcDe2, '#254', 'vCarga  ', 01, 15, 1, CIOT.infCTeNorm.InfCarga.vCarga, DSC_VTMERC);
  Gerador.wCampo(tcStr, '#255', 'proPred ', 01, 60, 1, CIOT.infCTeNorm.InfCarga.proPred, DSC_PRED);
  Gerador.wCampo(tcStr, '#256', 'xOutCat ', 01, 30, 0, CIOT.infCTeNorm.InfCarga.xOutCat, DSC_OUTCAT);

  GerarInfQ;

  Gerador.wGrupo('/infCarga');
end;

procedure TCIOTW.GerarInfQ;
var
  i: integer;
begin
  for i := 0 to CIOT.infCTeNorm.InfCarga.InfQ.Count - 1 do
  begin
    Gerador.wGrupo('infQ', '#257');
    Gerador.wCampo(tcStr, '#258', 'cUnid  ', 02, 02, 1, UnidMedToStr(CIOT.infCTeNorm.InfCarga.InfQ[i].cUnid), DSC_CUNID);
    Gerador.wCampo(tcStr, '#259', 'tpMed  ', 01, 20, 1, CIOT.infCTeNorm.InfCarga.InfQ[i].tpMed, DSC_TPMED);
    Gerador.wCampo(tcDe4, '#260', 'qCarga ', 01, 15, 1, CIOT.infCTeNorm.InfCarga.InfQ[i].qCarga, DSC_QTD);

    Gerador.wGrupo('/infQ');
  end;

  if CIOT.infCTeNorm.InfCarga.InfQ.Count > 990 then
    Gerador.wAlerta('#257', 'infQ', DSC_INFQ, ERR_MSG_MAIOR_MAXIMO + '990');
end;

procedure TCIOTW.GerarinfDoc;
begin
  Gerador.wGrupo('infDoc', '#261');
  GerarInfNF;
  GerarInfNFe;
  GerarInfOutros;
  Gerador.wGrupo('/infDoc');
end;

procedure TCIOTW.GerarInfNF;
var
  i, j, k, l: integer;
begin
  for i := 0 to CIOT.infCTeNorm.infDoc.infNF.Count - 1 do
  begin
    Gerador.wGrupo('infNF', '#262');
    Gerador.wCampo(tcStr, '#263', 'nRoma ', 01, 20, 0, CIOT.infCTeNorm.infDoc.InfNF[i].nRoma, DSC_NROMA);
    Gerador.wCampo(tcStr, '#264', 'nPed  ', 01, 20, 0, CIOT.infCTeNorm.infDoc.InfNF[i].nPed, DSC_NPED);
    Gerador.wCampo(tcStr, '#265', 'mod   ', 02, 02, 1, ModeloNFToStr(CIOT.infCTeNorm.infDoc.InfNF[i].modelo), DSC_MOD);
    Gerador.wCampo(tcStr, '#266', 'serie ', 01, 03, 1, CIOT.infCTeNorm.infDoc.InfNF[i].serie, DSC_SERIE);
    Gerador.wCampo(tcEsp, '#267', 'nDoc  ', 01, 20, 1, SomenteNumeros(CIOT.infCTeNorm.infDoc.InfNF[i].nDoc), DSC_NDOC);
    Gerador.wCampo(tcDat, '#268', 'dEmi  ', 10, 10, 1, CIOT.infCTeNorm.infDoc.InfNF[i].dEmi, DSC_DEMI);
    Gerador.wCampo(tcDe2, '#269', 'vBC   ', 01, 15, 1, CIOT.infCTeNorm.infDoc.InfNF[i].vBC, DSC_VBCICMS);
    Gerador.wCampo(tcDe2, '#270', 'vICMS ', 01, 15, 1, CIOT.infCTeNorm.infDoc.InfNF[i].vICMS, DSC_VICMS);
    Gerador.wCampo(tcDe2, '#271', 'vBCST ', 01, 15, 1, CIOT.infCTeNorm.infDoc.InfNF[i].vBCST, DSC_VBCST);
    Gerador.wCampo(tcDe2, '#272', 'vST   ', 01, 15, 1, CIOT.infCTeNorm.infDoc.InfNF[i].vST, DSC_VST);
    Gerador.wCampo(tcDe2, '#273', 'vProd ', 01, 15, 1, CIOT.infCTeNorm.infDoc.InfNF[i].vProd, DSC_VPROD);
    Gerador.wCampo(tcDe2, '#274', 'vNF   ', 01, 15, 1, CIOT.infCTeNorm.infDoc.InfNF[i].vNF, DSC_VNF);
    Gerador.wCampo(tcInt, '#275', 'nCFOP ', 04, 04, 1, CIOT.infCTeNorm.infDoc.InfNF[i].nCFOP, DSC_CFOP);
    Gerador.wCampo(tcDe3, '#276', 'nPeso ', 01, 15, 0, CIOT.infCTeNorm.infDoc.InfNF[i].nPeso, DSC_PESO);
    Gerador.wCampo(tcStr, '#277', 'PIN   ', 02, 09, 0, CIOT.infCTeNorm.infDoc.InfNF[i].PIN, DSC_ISUF);
    if (FOpcoes.ValidarInscricoes) and (CIOT.infCTeNorm.infDoc.InfNF[i].PIN <> '') then
      if not ValidarISUF(CIOT.infCTeNorm.infDoc.InfNF[i].PIN) then
        Gerador.wAlerta('#277', 'PIN', DSC_ISUF, ERR_MSG_INVALIDO);
    Gerador.wCampo(tcDat, '#278', 'dPrev ', 10, 10, 0, CIOT.infCTeNorm.infDoc.InfNF[i].dPrev, DSC_DPREV);

    for j := 0 to CIOT.infCTeNorm.infDoc.infNF[i].infUnidTransp.Count - 1 do
    begin
      Gerador.wGrupo('infUnidTransp', '#279');
      Gerador.wCampo(tcStr, '#280', 'tpUnidTransp', 01, 01, 1, UnidTranspToStr(CIOT.infCTeNorm.infDoc.infNF[i].infUnidTransp[j].tpUnidTransp), DSC_TPUNIDTRANSP);
      Gerador.wCampo(tcStr, '#281', 'idUnidTransp', 01, 20, 1, CIOT.infCTeNorm.infDoc.infNF[i].infUnidTransp[j].idUnidTransp, DSC_IDUNIDTRANSP);

      for k := 0 to CIOT.infCTeNorm.infDoc.infNF[i].infUnidTransp[j].lacUnidTransp.Count - 1 do
      begin
        Gerador.wGrupo('lacUnidTransp', '#282');
        Gerador.wCampo(tcStr, '#283', 'nLacre', 01, 20, 1, CIOT.infCTeNorm.infDoc.infNF[i].infUnidTransp[j].lacUnidTransp[k].nLacre, DSC_NLACRE);
        Gerador.wGrupo('/lacUnidTransp');
      end;

      for k := 0 to CIOT.infCTeNorm.infDoc.infNF[i].infUnidTransp[j].infUnidCarga.Count - 1 do
      begin
        Gerador.wGrupo('infUnidCarga', '#284');
        Gerador.wCampo(tcStr, '#285', 'tpUnidCarga', 01, 01, 1, UnidCargaToStr(CIOT.infCTeNorm.infDoc.infNF[i].infUnidTransp[j].infUnidCarga[k].tpUnidCarga), DSC_TPUNIDCARGA);
        Gerador.wCampo(tcStr, '#286', 'idUnidCarga', 01, 20, 1, CIOT.infCTeNorm.infDoc.infNF[i].infUnidTransp[j].infUnidCarga[k].idUnidCarga, DSC_IDUNIDCARGA);

        for l := 0 to CIOT.infCTeNorm.infDoc.infNF[i].infUnidTransp[j].infUnidCarga[k].lacUnidCarga.Count - 1 do
        begin
          Gerador.wGrupo('lacUnidCarga', '#287');
          Gerador.wCampo(tcStr, '#288', 'nLacre', 01, 20, 1, CIOT.infCTeNorm.infDoc.infNF[i].infUnidTransp[j].infUnidCarga[k].lacUnidCarga[l].nLacre, DSC_NLACRE);
          Gerador.wGrupo('/lacUnidCarga');
        end;
        Gerador.wCampo(tcDe2, '#289', 'qtdRat', 01, 05, 0, CIOT.infCTeNorm.infDoc.infNF[i].infUnidTransp[j].infUnidCarga[k].qtdRat, DSC_QTDRAT);

        Gerador.wGrupo('/infUnidCarga');
      end;
      Gerador.wCampo(tcDe2, '#290', 'qtdRat', 01, 05, 0, CIOT.infCTeNorm.infDoc.infNF[i].infUnidTransp[j].qtdRat, DSC_QTDRAT);

      Gerador.wGrupo('/infUnidTransp');
    end;

    for j := 0 to CIOT.infCTeNorm.infDoc.infNF[i].infUnidCarga.Count - 1 do
    begin
      Gerador.wGrupo('infUnidCarga', '#291');
      Gerador.wCampo(tcStr, '#292', 'tpUnidCarga', 01, 01, 1, UnidCargaToStr(CIOT.infCTeNorm.infDoc.infNF[i].infUnidCarga[j].tpUnidCarga), DSC_TPUNIDCARGA);
      Gerador.wCampo(tcStr, '#293', 'idUnidCarga', 01, 20, 1, CIOT.infCTeNorm.infDoc.infNF[i].infUnidCarga[j].idUnidCarga, DSC_IDUNIDCARGA);

      for k := 0 to CIOT.infCTeNorm.infDoc.infNF[i].infUnidCarga[j].lacUnidCarga.Count - 1 do
      begin
        Gerador.wGrupo('lacUnidCarga', '#294');
        Gerador.wCampo(tcStr, '#295', 'nLacre', 01, 20, 1, CIOT.infCTeNorm.infDoc.infNF[i].infUnidCarga[j].lacUnidCarga[k].nLacre, DSC_NLACRE);
        Gerador.wGrupo('/lacUnidCarga');
      end;
      Gerador.wCampo(tcDe2, '#296', 'qtdRat', 01, 05, 0, CIOT.infCTeNorm.infDoc.infNF[i].infUnidCarga[j].qtdRat, DSC_QTDRAT);

      Gerador.wGrupo('/infUnidCarga');
    end;

    Gerador.wGrupo('/infNF');
  end;
  if CIOT.infCTeNorm.infDoc.InfNF.Count > 990 then
    Gerador.wAlerta('#262', 'infNF', DSC_INFNF, ERR_MSG_MAIOR_MAXIMO + '990');
end;

procedure TCIOTW.GerarInfNFe;
var
  i, j, k, l: integer;
begin
  for i := 0 to CIOT.infCTeNorm.infDoc.InfNFe.Count - 1 do
  begin
    Gerador.wGrupo('infNFe', '#297');
    Gerador.wCampo(tcEsp, '#298', 'chave', 44, 44, 1, SomenteNumeros(CIOT.infCTeNorm.infDoc.InfNFe[i].chave), DSC_REFNFE);
    if SomenteNumeros(CIOT.infCTeNorm.infDoc.InfNFe[i].chave) <> '' then
     if not ValidarChave('NFe' + SomenteNumeros(CIOT.infCTeNorm.infDoc.InfNFe[i].chave)) then
      Gerador.wAlerta('#298', 'chave', DSC_REFNFE, ERR_MSG_INVALIDO);
    Gerador.wCampo(tcStr, '#299', 'PIN   ', 02, 09, 0, CIOT.infCTeNorm.infDoc.InfNFe[i].PIN, DSC_ISUF);
    if (FOpcoes.ValidarInscricoes) and (CIOT.infCTeNorm.infDoc.InfNFe[i].PIN <> '') then
      if not ValidarISUF(CIOT.infCTeNorm.infDoc.InfNFe[i].PIN) then
        Gerador.wAlerta('#299', 'PIN', DSC_ISUF, ERR_MSG_INVALIDO);
    Gerador.wCampo(tcDat, '#300', 'dPrev ', 10, 10, 0, CIOT.infCTeNorm.infDoc.InfNFe[i].dPrev, DSC_DPREV);

    for j := 0 to CIOT.infCTeNorm.infDoc.infNFe[i].infUnidTransp.Count - 1 do
    begin
      Gerador.wGrupo('infUnidTransp', '#301');
      Gerador.wCampo(tcStr, '#302', 'tpUnidTransp', 01, 01, 1, UnidTranspToStr(CIOT.infCTeNorm.infDoc.infNFe[i].infUnidTransp[j].tpUnidTransp), DSC_TPUNIDTRANSP);
      Gerador.wCampo(tcStr, '#303', 'idUnidTransp', 01, 20, 1, CIOT.infCTeNorm.infDoc.infNFe[i].infUnidTransp[j].idUnidTransp, DSC_IDUNIDTRANSP);

      for k := 0 to CIOT.infCTeNorm.infDoc.infNFe[i].infUnidTransp[j].lacUnidTransp.Count - 1 do
      begin
        Gerador.wGrupo('lacUnidTransp', '#304');
        Gerador.wCampo(tcStr, '#305', 'nLacre', 01, 20, 1, CIOT.infCTeNorm.infDoc.infNFe[i].infUnidTransp[j].lacUnidTransp[k].nLacre, DSC_NLACRE);
        Gerador.wGrupo('/lacUnidTransp');
      end;

      for k := 0 to CIOT.infCTeNorm.infDoc.infNFe[i].infUnidTransp[j].infUnidCarga.Count - 1 do
      begin
        Gerador.wGrupo('infUnidCarga', '#306');
        Gerador.wCampo(tcStr, '#307', 'tpUnidCarga', 01, 01, 1, UnidCargaToStr(CIOT.infCTeNorm.infDoc.infNFe[i].infUnidTransp[j].infUnidCarga[k].tpUnidCarga), DSC_TPUNIDCARGA);
        Gerador.wCampo(tcStr, '#308', 'idUnidCarga', 01, 20, 1, CIOT.infCTeNorm.infDoc.infNFe[i].infUnidTransp[j].infUnidCarga[k].idUnidCarga, DSC_IDUNIDCARGA);

        for l := 0 to CIOT.infCTeNorm.infDoc.infNFe[i].infUnidTransp[j].infUnidCarga[k].lacUnidCarga.Count - 1 do
        begin
          Gerador.wGrupo('lacUnidCarga', '#309');
          Gerador.wCampo(tcStr, '#310', 'nLacre', 01, 20, 1, CIOT.infCTeNorm.infDoc.infNFe[i].infUnidTransp[j].infUnidCarga[k].lacUnidCarga[l].nLacre, DSC_NLACRE);
          Gerador.wGrupo('/lacUnidCarga');
        end;
        Gerador.wCampo(tcDe2, '#311', 'qtdRat', 01, 05, 0, CIOT.infCTeNorm.infDoc.infNFe[i].infUnidTransp[j].infUnidCarga[k].qtdRat, DSC_QTDRAT);

        Gerador.wGrupo('/infUnidCarga');
      end;
      Gerador.wCampo(tcDe2, '#312', 'qtdRat', 01, 05, 0, CIOT.infCTeNorm.infDoc.infNFe[i].infUnidTransp[j].qtdRat, DSC_QTDRAT);

      Gerador.wGrupo('/infUnidTransp');
    end;

    for j := 0 to CIOT.infCTeNorm.infDoc.infNFe[i].infUnidCarga.Count - 1 do
    begin
      Gerador.wGrupo('infUnidCarga', '#313');
      Gerador.wCampo(tcStr, '#314', 'tpUnidCarga', 01, 01, 1, UnidCargaToStr(CIOT.infCTeNorm.infDoc.infNFe[i].infUnidCarga[j].tpUnidCarga), DSC_TPUNIDCARGA);
      Gerador.wCampo(tcStr, '#315', 'idUnidCarga', 01, 20, 1, CIOT.infCTeNorm.infDoc.infNFe[i].infUnidCarga[j].idUnidCarga, DSC_IDUNIDCARGA);

      for k := 0 to CIOT.infCTeNorm.infDoc.infNFe[i].infUnidCarga[j].lacUnidCarga.Count - 1 do
      begin
        Gerador.wGrupo('lacUnidCarga', '#316');
        Gerador.wCampo(tcStr, '#317', 'nLacre', 01, 20, 1, CIOT.infCTeNorm.infDoc.infNFe[i].infUnidCarga[j].lacUnidCarga[k].nLacre, DSC_NLACRE);
        Gerador.wGrupo('/lacUnidCarga');
      end;
      Gerador.wCampo(tcDe2, '#318', 'qtdRat', 01, 05, 0, CIOT.infCTeNorm.infDoc.infNFe[i].infUnidCarga[j].qtdRat, DSC_QTDRAT);

      Gerador.wGrupo('/infUnidCarga');
    end;

    Gerador.wGrupo('/infNFe');
  end;
  if CIOT.infCTeNorm.infDoc.InfNFe.Count > 990 then
    Gerador.wAlerta('#297', 'infNFe', DSC_INFNFE, ERR_MSG_MAIOR_MAXIMO + '990');
end;

procedure TCIOTW.GerarInfOutros;
var
  i, j, k, l: integer;
begin
  for i := 0 to CIOT.infCTeNorm.infDoc.InfOutros.Count - 1 do
  begin
    Gerador.wGrupo('infOutros', '#319');
    Gerador.wCampo(tcStr, '#320', 'tpDoc      ', 02, 002, 1, TpDocumentoToStr(CIOT.infCTeNorm.infDoc.InfOutros[i].tpDoc), DSC_TPDOC);
    Gerador.wCampo(tcStr, '#321', 'descOutros ', 01, 100, 0, CIOT.infCTeNorm.infDoc.InfOutros[i].descOutros, DSC_OUTROS);
    Gerador.wCampo(tcStr, '#322', 'nDoc       ', 01, 020, 0, CIOT.infCTeNorm.infDoc.InfOutros[i].nDoc, DSC_NRO);
    Gerador.wCampo(tcDat, '#323', 'dEmi       ', 10, 010, 0, CIOT.infCTeNorm.infDoc.InfOutros[i].dEmi, DSC_DEMI);
    Gerador.wCampo(tcDe2, '#324', 'vDocFisc   ', 01, 015, 0, CIOT.infCTeNorm.infDoc.InfOutros[i].vDocFisc, DSC_VDOC);
    Gerador.wCampo(tcDat, '#325', 'dPrev      ', 10, 010, 0, CIOT.infCTeNorm.infDoc.infOutros[i].dPrev, DSC_DPREV);

    for j := 0 to CIOT.infCTeNorm.infDoc.infOutros[i].infUnidTransp.Count - 1 do
    begin
      Gerador.wGrupo('infUnidTransp', '#326');
      Gerador.wCampo(tcStr, '#327', 'tpUnidTransp', 01, 01, 1, UnidTranspToStr(CIOT.infCTeNorm.infDoc.infOutros[i].infUnidTransp[j].tpUnidTransp), DSC_TPUNIDTRANSP);
      Gerador.wCampo(tcStr, '#328', 'idUnidTransp', 01, 20, 1, CIOT.infCTeNorm.infDoc.infOutros[i].infUnidTransp[j].idUnidTransp, DSC_IDUNIDTRANSP);

      for k := 0 to CIOT.infCTeNorm.infDoc.infOutros[i].infUnidTransp[j].lacUnidTransp.Count - 1 do
      begin
        Gerador.wGrupo('lacUnidTransp', '#329');
        Gerador.wCampo(tcStr, '#330', 'nLacre', 01, 20, 1, CIOT.infCTeNorm.infDoc.infOutros[i].infUnidTransp[j].lacUnidTransp[k].nLacre, DSC_NLACRE);
        Gerador.wGrupo('/lacUnidTransp');
      end;

      for k := 0 to CIOT.infCTeNorm.infDoc.infOutros[i].infUnidTransp[j].infUnidCarga.Count - 1 do
      begin
        Gerador.wGrupo('infUnidCarga', '#331');
        Gerador.wCampo(tcStr, '#332', 'tpUnidCarga', 01, 01, 1, UnidCargaToStr(CIOT.infCTeNorm.infDoc.infOutros[i].infUnidTransp[j].infUnidCarga[k].tpUnidCarga), DSC_TPUNIDCARGA);
        Gerador.wCampo(tcStr, '#333', 'idUnidCarga', 01, 20, 1, CIOT.infCTeNorm.infDoc.infOutros[i].infUnidTransp[j].infUnidCarga[k].idUnidCarga, DSC_IDUNIDCARGA);

        for l := 0 to CIOT.infCTeNorm.infDoc.infOutros[i].infUnidTransp[j].infUnidCarga[k].lacUnidCarga.Count - 1 do
        begin
          Gerador.wGrupo('lacUnidCarga', '#334');
          Gerador.wCampo(tcStr, '#335', 'nLacre', 01, 20, 1, CIOT.infCTeNorm.infDoc.infOutros[i].infUnidTransp[j].infUnidCarga[k].lacUnidCarga[l].nLacre, DSC_NLACRE);
          Gerador.wGrupo('/lacUnidCarga');
        end;
        Gerador.wCampo(tcDe2, '#336', 'qtdRat', 01, 05, 0, CIOT.infCTeNorm.infDoc.infOutros[i].infUnidTransp[j].infUnidCarga[k].qtdRat, DSC_QTDRAT);

        Gerador.wGrupo('/infUnidCarga');
      end;
      Gerador.wCampo(tcDe2, '#337', 'qtdRat', 01, 05, 0, CIOT.infCTeNorm.infDoc.infOutros[i].infUnidTransp[j].qtdRat, DSC_QTDRAT);

      Gerador.wGrupo('/infUnidTransp');
    end;

    for j := 0 to CIOT.infCTeNorm.infDoc.InfOutros[i].infUnidCarga.Count - 1 do
    begin
      Gerador.wGrupo('infUnidCarga', '#338');
      Gerador.wCampo(tcStr, '#339', 'tpUnidCarga', 01, 01, 1, UnidCargaToStr(CIOT.infCTeNorm.infDoc.InfOutros[i].infUnidCarga[j].tpUnidCarga), DSC_TPUNIDCARGA);
      Gerador.wCampo(tcStr, '#340', 'idUnidCarga', 01, 20, 1, CIOT.infCTeNorm.infDoc.InfOutros[i].infUnidCarga[j].idUnidCarga, DSC_IDUNIDCARGA);

      for k := 0 to CIOT.infCTeNorm.infDoc.InfOutros[i].infUnidCarga[j].lacUnidCarga.Count - 1 do
      begin
        Gerador.wGrupo('lacUnidCarga', '#341');
        Gerador.wCampo(tcStr, '#342', 'nLacre', 01, 20, 1, CIOT.infCTeNorm.infDoc.InfOutros[i].infUnidCarga[j].lacUnidCarga[k].nLacre, DSC_NLACRE);
        Gerador.wGrupo('/lacUnidCarga');
      end;
      Gerador.wCampo(tcDe2, '#343', 'qtdRat', 01, 05, 0, CIOT.infCTeNorm.infDoc.InfOutros[i].infUnidCarga[j].qtdRat, DSC_QTDRAT);

      Gerador.wGrupo('/infUnidCarga');
    end;

    Gerador.wGrupo('/infOutros');
  end;
  if CIOT.infCTeNorm.infDoc.InfOutros.Count > 990 then
    Gerador.wAlerta('#319', 'infOutros', DSC_INFOUTRO, ERR_MSG_MAIOR_MAXIMO + '990');
end;

procedure TCIOTW.GerarDocAnt;
var
  i, i01, i02: integer;
begin
  Gerador.wGrupo('docAnt', '#344');

  for i := 0 to CIOT.infCTeNorm.docAnt.emiDocAnt.Count - 1 do
  begin
    Gerador.wGrupo('emiDocAnt', '#345');
    Gerador.wCampoCNPJCPF('#346', '#347', CIOT.infCTeNorm.docAnt.emiDocAnt[i].CNPJCPF, CODIGO_BRASIL);

    if Trim(CIOT.infCTeNorm.docAnt.emiDocAnt[i].IE) = 'ISENTO'
     then Gerador.wCampo(tcStr, '#348', 'IE ', 00, 14, 1, CIOT.infCTeNorm.docAnt.emiDocAnt[i].IE, DSC_IE)
     else Gerador.wCampo(tcStr, '#348', 'IE ', 02, 14, 1, SomenteNumeros(CIOT.infCTeNorm.docAnt.emiDocAnt[i].IE), DSC_IE);

    if (FOpcoes.ValidarInscricoes)
     then if not ValidarIE(CIOT.infCTeNorm.docAnt.emiDocAnt[i].IE, CIOT.infCTeNorm.docAnt.emiDocAnt[i].UF) then
      Gerador.wAlerta('#348', 'IE', DSC_IE, ERR_MSG_INVALIDO);

    Gerador.wCampo(tcStr, '#349', 'UF    ', 02, 02, 1, CIOT.infCTeNorm.docAnt.emiDocAnt[i].UF, DSC_UF);
    if not ValidarUF(CIOT.infCTeNorm.docAnt.emiDocAnt[i].UF) then
      Gerador.wAlerta('#349', 'UF', DSC_UF, ERR_MSG_INVALIDO);
    Gerador.wCampo(tcStr, '#350', 'xNome ', 01, 60, 1, CIOT.infCTeNorm.docAnt.emiDocAnt[i].xNome, DSC_XNOME);

    for i01 := 0 to CIOT.infCTeNorm.docAnt.emiDocAnt[i].idDocAnt.Count - 1 do
    begin
      Gerador.wGrupo('idDocAnt', '#351');

      for i02 := 0 to CIOT.infCTeNorm.docAnt.emiDocAnt[i].idDocAnt[i01].idDocAntPap.Count - 1 do
      begin
        Gerador.wGrupo('idDocAntPap', '#352');
        Gerador.wCampo(tcStr, '#353', 'tpDoc  ', 02, 02, 1, TpDocumentoAnteriorToStr(CIOT.infCTeNorm.docAnt.emiDocAnt[i].idDocAnt[i01].idDocAntPap[i02].tpDoc), DSC_TPNF);
        Gerador.wCampo(tcStr, '#354', 'serie  ', 01, 03, 1, CIOT.infCTeNorm.docAnt.emiDocAnt[i].idDocAnt[i01].idDocAntPap[i02].serie, DSC_SERIE);
        Gerador.wCampo(tcStr, '#355', 'subser ', 01, 02, 0, CIOT.infCTeNorm.docAnt.emiDocAnt[i].idDocAnt[i01].idDocAntPap[i02].subser, DSC_SERIE);
        Gerador.wCampo(tcInt, '#356', 'nDoc   ', 01, 20, 1, CIOT.infCTeNorm.docAnt.emiDocAnt[i].idDocAnt[i01].idDocAntPap[i02].nDoc, DSC_NNF);
        Gerador.wCampo(tcDat, '#357', 'dEmi   ', 10, 10, 1, CIOT.infCTeNorm.docAnt.emiDocAnt[i].idDocAnt[i01].idDocAntPap[i02].dEmi, DSC_DEMI);
        Gerador.wGrupo('/idDocAntPap');
      end;
      if CIOT.infCTeNorm.docAnt.emiDocAnt[i].idDocAnt[i01].idDocAntPap.Count > 990 then
        Gerador.wAlerta('#352', 'idDocAntPap', '', ERR_MSG_MAIOR_MAXIMO + '990');

      for i02 := 0 to CIOT.infCTeNorm.docAnt.emiDocAnt[i].idDocAnt[i01].idDocAntEle.Count - 1 do
      begin
        Gerador.wGrupo('idDocAntEle', '#358');
        Gerador.wCampo(tcStr, '#359', 'chave ', 44, 44, 1, SomenteNumeros(CIOT.infCTeNorm.docAnt.emiDocAnt[i].idDocAnt[i01].idDocAntEle[i02].chave), DSC_CHCTE);
        if SomenteNumeros(CIOT.infCTeNorm.docAnt.emiDocAnt[i].idDocAnt[i01].idDocAntEle[i02].chave) <> '' then
         if not ValidarChave('NFe' + SomenteNumeros(CIOT.infCTeNorm.docAnt.emiDocAnt[i].idDocAnt[i01].idDocAntEle[i02].chave)) then
          Gerador.wAlerta('#359', 'chave', DSC_REFCTE, ERR_MSG_INVALIDO);
        Gerador.wGrupo('/idDocAntEle');
      end;
      if CIOT.infCTeNorm.docAnt.emiDocAnt[i].idDocAnt[i01].idDocAntEle.Count > 990 then
        Gerador.wAlerta('#358', 'idDocAntEle', '', ERR_MSG_MAIOR_MAXIMO + '990');

      Gerador.wGrupo('/idDocAnt');
    end;
    if CIOT.infCTeNorm.docAnt.emiDocAnt[i].idDocAnt.Count > 2 then
      Gerador.wAlerta('#351', 'idDocAnt', '', ERR_MSG_MAIOR_MAXIMO + '02');

    Gerador.wGrupo('/emiDocAnt');
  end;
  if CIOT.infCTeNorm.docAnt.emiDocAnt.Count > 990 then
    Gerador.wAlerta('#345', 'emiDocAnt', '', ERR_MSG_MAIOR_MAXIMO + '990');

  Gerador.wGrupo('/docAnt');
end;

procedure TCIOTW.GerarInfSeg;
var
  i: integer;
begin
  for i := 0 to CIOT.infCTeNorm.seg.Count - 1 do
  begin
    Gerador.wGrupo('seg', '#360');
    Gerador.wCampo(tcStr, '#361', 'respSeg ', 01, 01, 1, TpRspSeguroToStr(CIOT.infCTeNorm.seg[i].respSeg), DSC_RESPSEG);
    Gerador.wCampo(tcStr, '#362', 'xSeg    ', 01, 30, 0, CIOT.infCTeNorm.seg[i].xSeg, DSC_XSEG);
    Gerador.wCampo(tcStr, '#363', 'nApol   ', 01, 20, 0, CIOT.infCTeNorm.seg[i].nApol, DSC_NAPOL);
    Gerador.wCampo(tcStr, '#364', 'nAver   ', 01, 20, 0, CIOT.infCTeNorm.seg[i].nAver, DSC_NAVER);
    Gerador.wCampo(tcDe2, '#365', 'vCarga  ', 01, 15, 0, CIOT.infCTeNorm.seg[i].vCarga, DSC_VMERC);
    Gerador.wGrupo('/seg');
  end;
  if CIOT.infCTeNorm.seg.Count > 990 then
    Gerador.wAlerta('#360', 'seg', DSC_INFSEG, ERR_MSG_MAIOR_MAXIMO + '990');
end;

procedure TCIOTW.GerarRodo;
begin
  Gerador.wGrupo('rodo', '#01');
  if CIOT.infCTeNorm.rodo.RNTRC = 'ISENTO'
   then Gerador.wCampo(tcStr, '#02', 'RNTRC ', 06, 06, 1, CIOT.infCTeNorm.rodo.RNTRC, DSC_RNTRC)
   else Gerador.wCampo(tcStr, '#02', 'RNTRC ', 08, 08, 1, SomenteNumeros(CIOT.infCTeNorm.rodo.RNTRC), DSC_RNTRC);
  Gerador.wCampo(tcDat, '#03', 'dPrev ', 10, 10, 1, CIOT.infCTeNorm.rodo.dPrev, DSC_DPREV);
  Gerador.wCampo(tcStr, '#04', 'lota  ', 01, 01, 1, TpLotacaoToStr(CIOT.infCTeNorm.rodo.Lota), DSC_LOTA);
  Gerador.wCampo(tcStr, '#05', 'CIOT  ', 12, 12, 0, CIOT.infCTeNorm.rodo.CIOT, DSC_CIOT);

  GerarOCC;

  if CIOT.infCTeNorm.rodo.Lota = ltSim
   then begin
    GerarValePed;
    GerarVeic;
   end;
  GerarLacre;

  if CIOT.infCTeNorm.rodo.Lota = ltSim then
   GerarMoto;

  Gerador.wGrupo('/rodo');
end;

procedure TCIOTW.GerarOCC;
var
 i: Integer;
begin
  for i := 0 to CIOT.infCTeNorm.rodo.occ.Count - 1 do
  begin
    Gerador.wGrupo('occ', '#06');
    Gerador.wCampo(tcStr, '#07', 'serie ', 01, 03, 0, CIOT.infCTeNorm.rodo.occ[i].serie, DSC_SERIE);
    Gerador.wCampo(tcInt, '#08', 'nOcc  ', 01, 06, 1, CIOT.infCTeNorm.rodo.occ[i].nOcc, DSC_NOCC);
    Gerador.wCampo(tcDat, '#09', 'dEmi  ', 10, 10, 1, CIOT.infCTeNorm.rodo.occ[i].dEmi, DSC_DEMI);

    Gerador.wGrupo('emiOcc', '#10');
    Gerador.wCampoCNPJ('#11', CIOT.infCTeNorm.rodo.occ[i].emiOcc.CNPJ, CODIGO_BRASIL, True);
    Gerador.wCampo(tcStr, '#12', 'cInt   ', 01, 10, 0, CIOT.infCTeNorm.rodo.occ[i].emiOcc.cInt, DSC_CINT);

    Gerador.wCampo(tcStr, '#13', 'IE ', 02, 14, 1, SomenteNumeros(CIOT.infCTeNorm.rodo.occ[i].emiOcc.IE), DSC_IE);

    if (FOpcoes.ValidarInscricoes)
     then if not ValidarIE(CIOT.infCTeNorm.rodo.occ[i].emiOcc.IE, CIOT.infCTeNorm.rodo.occ[i].emiOcc.UF) then
      Gerador.wAlerta('#13', 'IE', DSC_IE, ERR_MSG_INVALIDO);

    Gerador.wCampo(tcStr, '#14', 'UF   ', 02, 02, 1, CIOT.infCTeNorm.rodo.occ[i].emiOcc.UF, DSC_CUF);
    if not ValidarUF(CIOT.infCTeNorm.rodo.occ[i].emiOcc.UF) then
      Gerador.wAlerta('#14', 'UF', DSC_UF, ERR_MSG_INVALIDO);
    Gerador.wCampo(tcStr, '#15', 'fone ', 07, 12, 0, somenteNumeros(CIOT.infCTeNorm.rodo.occ[i].emiOcc.fone), DSC_FONE);
    Gerador.wGrupo('/emiOcc');

    Gerador.wGrupo('/occ');
  end;
  if CIOT.infCTeNorm.rodo.occ.Count > 10 then
    Gerador.wAlerta('#06', 'occ', '', ERR_MSG_MAIOR_MAXIMO + '10');
end;

procedure TCIOTW.GerarValePed;
var
 i: Integer;
begin
  for i := 0 to CIOT.infCTeNorm.rodo.valePed.Count - 1 do
  begin
    Gerador.wGrupo('valePed', '#16');
    Gerador.wCampo(tcStr, '#17', 'CNPJForn ', 14, 14, 1, CIOT.infCTeNorm.rodo.valePed[i].CNPJForn, DSC_CNPJ);
    Gerador.wCampo(tcStr, '#18', 'nCompra  ', 01, 20, 1, CIOT.infCTeNorm.rodo.valePed[i].nCompra, DSC_NCOMPRA);
    Gerador.wCampo(tcStr, '#19', 'CNPJPg   ', 14, 14, 0, CIOT.infCTeNorm.rodo.valePed[i].CNPJPg, DSC_CNPJ);
    Gerador.wCampo(tcDe2, '#20', 'vValePed ', 01, 15, 1, CIOT.infCTeNorm.rodo.valePed[i].vValePed, DSC_VVALEPED);
    Gerador.wGrupo('/valePed');
  end;
  if CIOT.infCTeNorm.rodo.valePed.Count > 990 then
    Gerador.wAlerta('#16', 'valePed', DSC_VVALEPED, ERR_MSG_MAIOR_MAXIMO + '990');
end;

procedure TCIOTW.GerarVeic;
var
  i: integer;
begin
  for i := 0 to CIOT.infCTeNorm.rodo.veic.Count - 1 do
  begin
    Gerador.wGrupo('veic', '#21');
    Gerador.wCampo(tcStr, '#22', 'cInt    ', 01, 10, 0, CIOT.infCTeNorm.rodo.veic[i].cInt, DSC_CINTV);
    Gerador.wCampo(tcStr, '#23', 'RENAVAM ', 09, 11, 1, CIOT.infCTeNorm.rodo.veic[i].RENAVAM, DSC_RENAVAM);
    Gerador.wCampo(tcStr, '#24', 'placa   ', 01, 07, 1, CIOT.infCTeNorm.rodo.veic[i].placa, DSC_PLACA);
    Gerador.wCampo(tcInt, '#25', 'tara    ', 01, 06, 1, CIOT.infCTeNorm.rodo.veic[i].tara, DSC_TARA);
    Gerador.wCampo(tcInt, '#26', 'capKG   ', 01, 06, 1, CIOT.infCTeNorm.rodo.veic[i].capKG, DSC_CAPKG);
    Gerador.wCampo(tcInt, '#27', 'capM3   ', 01, 03, 1, CIOT.infCTeNorm.rodo.veic[i].capM3, DSC_CAPM3);
    Gerador.wCampo(tcStr, '#28', 'tpProp  ', 01, 01, 1, TpPropriedadeToStr(CIOT.infCTeNorm.rodo.veic[i].tpProp), DSC_TPPROP);
    Gerador.wCampo(tcStr, '#29', 'tpVeic  ', 01, 01, 1, TpVeiculoToStr(CIOT.infCTeNorm.rodo.veic[i].tpVeic), DSC_TPVEIC);
    Gerador.wCampo(tcStr, '#30', 'tpRod   ', 02, 02, 1, TpRodadoToStr(CIOT.infCTeNorm.rodo.veic[i].tpRod), DSC_TPROD);
    Gerador.wCampo(tcStr, '#31', 'tpCar   ', 02, 02, 1, TpCarroceriaToStr(CIOT.infCTeNorm.rodo.veic[i].tpCar), DSC_TPCAR);
    Gerador.wCampo(tcStr, '#32', 'UF      ', 02, 02, 1, CIOT.infCTeNorm.rodo.veic[i].UF, DSC_CUF);
    if not ValidarUF(CIOT.infCTeNorm.rodo.veic[i].UF) then
      Gerador.wAlerta('#32', 'UF', DSC_UF, ERR_MSG_INVALIDO);

    if (CIOT.infCTeNorm.rodo.veic[i].prop.CNPJCPF <> '') or
       (CIOT.infCTeNorm.rodo.veic[i].prop.RNTRC <> '') or
       (CIOT.infCTeNorm.rodo.veic[i].prop.xNome <> '') then
    begin
      Gerador.wGrupo('prop', '#33');
      Gerador.wCampoCNPJCPF('#34', '#35', CIOT.infCTeNorm.rodo.veic[i].prop.CNPJCPF, CODIGO_BRASIL);
      if CIOT.infCTeNorm.rodo.veic[i].prop.RNTRC = 'ISENTO'
       then Gerador.wCampo(tcStr, '#36', 'RNTRC ', 06, 06, 1, CIOT.infCTeNorm.rodo.veic[i].prop.RNTRC, DSC_RNTRC)
       else Gerador.wCampo(tcStr, '#36', 'RNTRC ', 08, 08, 1, SomenteNumeros(CIOT.infCTeNorm.rodo.veic[i].prop.RNTRC), DSC_RNTRC);
      Gerador.wCampo(tcStr, '#37', 'xNome ', 01, 60, 1, CIOT.infCTeNorm.rodo.veic[i].prop.xNome, DSC_XNOME);

      if CIOT.infCTeNorm.rodo.veic[i].prop.IE <> ''
       then begin
        if CIOT.infCTeNorm.rodo.veic[i].prop.IE = 'ISENTO'
         then Gerador.wCampo(tcStr, '#38', 'IE ', 00, 14, 1, CIOT.infCTeNorm.rodo.veic[i].prop.IE, DSC_IE)
         else Gerador.wCampo(tcStr, '#38', 'IE ', 02, 14, 1, SomenteNumeros(CIOT.infCTeNorm.rodo.veic[i].prop.IE), DSC_IE);
        if (FOpcoes.ValidarInscricoes)
         then if not ValidarIE(CIOT.infCTeNorm.rodo.veic[i].prop.IE, CIOT.infCTeNorm.rodo.veic[i].prop.UF) then
          Gerador.wAlerta('#38', 'IE', DSC_IE, ERR_MSG_INVALIDO);
       end;

      Gerador.wCampo(tcStr, '#39', 'UF     ', 02, 02, 1, CIOT.infCTeNorm.rodo.veic[i].prop.UF, DSC_CUF);
      if not ValidarUF(CIOT.infCTeNorm.rodo.veic[i].prop.UF) then
       Gerador.wAlerta('#39', 'UF', DSC_UF, ERR_MSG_INVALIDO);
      Gerador.wCampo(tcStr, '#40', 'tpProp ', 01, 01, 1, TpPropToStr(CIOT.infCTeNorm.rodo.veic[i].prop.tpProp), DSC_TPPROP);
      Gerador.wGrupo('/prop');
    end;

    Gerador.wGrupo('/veic');
  end;
  if CIOT.infCTeNorm.rodo.veic.Count > 4 then
    Gerador.wAlerta('#21', 'veic', '', ERR_MSG_MAIOR_MAXIMO + '4');
end;

procedure TCIOTW.GerarLacre;
var
  i: integer;
begin
  for i := 0 to CIOT.infCTeNorm.rodo.lacRodo.Count - 1 do
  begin
    Gerador.wGrupo('lacRodo', '#41');
    Gerador.wCampo(tcStr, '#42', 'nLacre ', 01, 20, 1, CIOT.infCTeNorm.rodo.lacRodo[i].nLacre, DSC_NLACRE);
    Gerador.wGrupo('/lacRodo');
  end;
  if CIOT.infCTeNorm.rodo.lacRodo.Count > 990 then
    Gerador.wAlerta('#41', 'lacRodo', DSC_LACR, ERR_MSG_MAIOR_MAXIMO + '990');
end;

procedure TCIOTW.GerarMoto;
var
  i: integer;
begin
  for i := 0 to CIOT.infCTeNorm.rodo.moto.Count - 1 do
  begin
    Gerador.wGrupo('moto', '#43');
    Gerador.wCampo(tcStr, '#44', 'xNome ', 01, 60, 1, CIOT.infCTeNorm.rodo.moto[i].xNome, DSC_XNOME);
    Gerador.wCampo(tcStr, '#45', 'CPF   ', 11, 11, 1, CIOT.infCTeNorm.rodo.moto[i].CPF, DSC_CPF);
    Gerador.wGrupo('/moto');
  end;
  if CIOT.infCTeNorm.rodo.moto.Count > 990 then
    Gerador.wAlerta('#43', 'moto', DSC_LACR, ERR_MSG_MAIOR_MAXIMO + '990');
end;

procedure TCIOTW.GerarAereo;
begin
  Gerador.wGrupo('aereo', '#01');
  Gerador.wCampo(tcInt, '#02', 'nMinu     ', 09, 09, 0, CIOT.infCTeNorm.aereo.nMinu, DSC_NMINU);
  Gerador.wCampo(tcStr, '#03', 'nOCA      ', 11, 11, 0, CIOT.infCTeNorm.aereo.nOCA, DSC_NOCA);
  Gerador.wCampo(tcDat, '#04', 'dPrevAereo', 10, 10, 0, CIOT.infCTeNorm.aereo.dPrevAereo, DSC_DPREV);
  Gerador.wCampo(tcStr, '#05', 'xLAgEmi   ', 01, 20, 0, CIOT.infCTeNorm.aereo.xLAgEmi, DSC_XLAGEMI);
  Gerador.wCampo(tcStr, '#06', 'IdT       ', 01, 14, 0, CIOT.infCTeNorm.aereo.IdT, DSC_IDT);

  Gerador.wGrupo('tarifa', '#07');
  Gerador.wCampo(tcStr, '#08', 'CL     ', 01, 02, 0, CIOT.infCTeNorm.aereo.tarifa.CL, DSC_CL);
  Gerador.wCampo(tcStr, '#09', 'cTar   ', 01, 04, 0, CIOT.infCTeNorm.aereo.tarifa.cTar, DSC_CTAR);
  Gerador.wCampo(tcDe2, '#10', 'vTar   ', 01, 15, 0, CIOT.infCTeNorm.aereo.tarifa.vTar, DSC_VTAR);
  Gerador.wGrupo('/tarifa');

  if (CIOT.infCTeNorm.aereo.natCarga.xDime<>'') or (CIOT.infCTeNorm.aereo.natCarga.cinfManu<>0) or
     (CIOT.infCTeNorm.aereo.natCarga.cImp<>'')
   then begin
    Gerador.wGrupo('natCarga', '#11');
    Gerador.wCampo(tcStr, '#12', 'xDime   ', 05, 14, 0, CIOT.infCTeNorm.aereo.natCarga.xDime, DSC_XDIME);
    Gerador.wCampo(tcInt, '#13', 'cInfManu', 01, 02, 0, CIOT.infCTeNorm.aereo.natCarga.cinfManu, DSC_CINFMANU);
    Gerador.wCampo(tcStr, '#14', 'cIMP    ', 03, 03, 0, CIOT.infCTeNorm.aereo.natCarga.cIMP, DSC_CIMP);
    Gerador.wGrupo('/natCarga');
   end;

  Gerador.wGrupo('/aereo');
end;

procedure TCIOTW.GerarAquav;
var
 i: Integer;
begin
  Gerador.wGrupo('aquav', '#01');
  Gerador.wCampo(tcDe2, '#02', 'vPrest   ', 01, 15, 1, CIOT.infCTeNorm.aquav.vPrest, DSC_VPREST);
  Gerador.wCampo(tcDe2, '#03', 'vAFRMM   ', 01, 15, 1, CIOT.infCTeNorm.aquav.vAFRMM, DSC_VAFRMM);
  Gerador.wCampo(tcStr, '#04', 'nBooking ', 01, 10, 0, CIOT.infCTeNorm.aquav.nBooking, DSC_NBOOKING);
  Gerador.wCampo(tcStr, '#05', 'nCtrl    ', 01, 10, 0, CIOT.infCTeNorm.aquav.nCtrl, DSC_NCTRL);
  Gerador.wCampo(tcStr, '#06', 'xNavio   ', 01, 60, 1, CIOT.infCTeNorm.aquav.xNavio, DSC_XNAVIO);

  for i := 0 to CIOT.infCTeNorm.aquav.balsa.Count - 1 do
   begin
    Gerador.wGrupo('balsa', '#07');
    Gerador.wCampo(tcStr, '#08', 'xBalsa ', 01, 60, 1, CIOT.infCTeNorm.aquav.balsa.Items[i].xBalsa, DSC_XBALSA);
    Gerador.wGrupo('/balsa');
   end;
  if CIOT.infCTeNorm.aquav.balsa.Count > 3 then
   Gerador.wAlerta('#07', 'balsa', DSC_XBALSA, ERR_MSG_MAIOR_MAXIMO + '3');

  Gerador.wCampo(tcStr, '#09', 'nViag    ', 01, 10, 0, CIOT.infCTeNorm.aquav.nViag, DSC_NVIAG);
  Gerador.wCampo(tcStr, '#10', 'direc    ', 01, 01, 1, TpDirecaoToStr(CIOT.infCTeNorm.aquav.direc), DSC_DIREC);
  Gerador.wCampo(tcStr, '#11', 'prtEmb   ', 01, 60, 0, CIOT.infCTeNorm.aquav.prtEmb, DSC_PRTEMB);
  Gerador.wCampo(tcStr, '#12', 'prtTrans ', 01, 60, 0, CIOT.infCTeNorm.aquav.prtTrans, DSC_PRTTRANS);
  Gerador.wCampo(tcStr, '#13', 'prtDest  ', 01, 60, 0, CIOT.infCTeNorm.aquav.prtDest, DSC_PRTDEST);
  Gerador.wCampo(tcStr, '#14', 'tpNav    ', 01, 01, 1, TpNavegacaoToStr(CIOT.infCTeNorm.aquav.tpNav), DSC_TPNAV);
  Gerador.wCampo(tcStr, '#15', 'irin     ', 01, 10, 1, CIOT.infCTeNorm.aquav.irin, DSC_IRIN);

  Gerador.wGrupo('/aquav');
end;

procedure TCIOTW.GerarFerrov;
begin
  Gerador.wGrupo('ferrov', '#01');
  Gerador.wCampo(tcStr, '#02', 'tpTraf ', 01, 01, 1, TpTrafegoToStr(CIOT.infCTeNorm.ferrov.tpTraf), DSC_TPTRAF);
  Gerador.wGrupo('trafMut', '#03');
  Gerador.wCampo(tcStr, '#04', 'respFat ', 01, 01, 1, TrafegoMutuoToStr(CIOT.infCTeNorm.ferrov.trafMut.respFat), DSC_RESPFAT);
  Gerador.wCampo(tcStr, '#05', 'ferrEmi ', 01, 01, 1, TrafegoMutuoToStr(CIOT.infCTeNorm.ferrov.trafMut.ferrEmi), DSC_FERREMI);
  Gerador.wGrupo('/trafMut');
  Gerador.wCampo(tcStr, '#06', 'fluxo  ', 01, 10, 1, CIOT.infCTeNorm.ferrov.fluxo, DSC_FLUXO);
  Gerador.wCampo(tcStr, '#07', 'idTrem ', 01, 07, 0, CIOT.infCTeNorm.ferrov.idTrem, DSC_IDTREM);
  Gerador.wCampo(tcDe2, '#08', 'vFrete ', 01, 15, 1, CIOT.infCTeNorm.ferrov.vFrete, DSC_VFRETE);
  GerarFerroEnv;
  GerardetVag;
  Gerador.wGrupo('/ferrov');
end;

procedure TCIOTW.GerarFerroEnv;
var
 i, cMun: integer;
 xMun, xUF: string;
begin
  for i := 0 to CIOT.infCTeNorm.ferrov.ferroEnv.Count - 1 do
   begin
    if (CIOT.infCTeNorm.ferrov.ferroEnv[i].CNPJ <> '') or
       (CIOT.infCTeNorm.ferrov.ferroEnv[i].xNome <> '') then
    begin
      Gerador.wGrupo('ferroEnv', '#09');
      Gerador.wCampoCNPJ('#10', CIOT.infCTeNorm.ferrov.ferroEnv[i].CNPJ, CODIGO_BRASIL, True);
      Gerador.wCampo(tcStr, '#11', 'cInt ', 01, 10, 0, CIOT.infCTeNorm.ferrov.ferroEnv[i].cInt, DSC_CINTF);

      if CIOT.infCTeNorm.ferrov.ferroEnv[i].IE <> ''
       then begin
        Gerador.wCampo(tcStr, '#12', 'IE ', 02, 14, 1, SomenteNumeros(CIOT.infCTeNorm.ferrov.ferroEnv[i].IE), DSC_IE);

        if (FOpcoes.ValidarInscricoes)
         then if not ValidarIE(CIOT.infCTeNorm.ferrov.ferroEnv[i].IE, CIOT.infCTeNorm.ferrov.ferroEnv[i].enderFerro.UF) then
          Gerador.wAlerta('#12', 'IE', DSC_IE, ERR_MSG_INVALIDO);
       end;

      Gerador.wCampo(tcStr, '#13', 'xNome ', 01, 60, 1, CIOT.infCTeNorm.ferrov.ferroEnv[i].xNome, DSC_XNOME);

      AjustarMunicipioUF(xUF, xMun, cMun, CODIGO_BRASIL,
                                          CIOT.infCTeNorm.ferrov.ferroEnv[i].EnderFerro.UF,
                                          CIOT.infCTeNorm.ferrov.ferroEnv[i].EnderFerro.xMun,
                                          CIOT.infCTeNorm.ferrov.ferroEnv[i].EnderFerro.cMun);
      Gerador.wGrupo('enderFerro', '#14');
      Gerador.wCampo(tcStr, '#15', 'xLgr    ', 01, 255, 1, CIOT.infCTeNorm.ferrov.ferroEnv[i].EnderFerro.xLgr, DSC_XLGR);
      Gerador.wCampo(tcStr, '#16', 'nro     ', 01, 60, 0, ExecutarAjusteTagNro(FOpcoes.FAjustarTagNro, CIOT.infCTeNorm.ferrov.ferroEnv[i].EnderFerro.nro), DSC_NRO);
      Gerador.wCampo(tcStr, '#17', 'xCpl    ', 01, 60, 0, CIOT.infCTeNorm.ferrov.ferroEnv[i].EnderFerro.xCpl, DSC_XCPL);
      Gerador.wCampo(tcStr, '#18', 'xBairro ', 01, 60, 0, CIOT.infCTeNorm.ferrov.ferroEnv[i].EnderFerro.xBairro, DSC_XBAIRRO);
      Gerador.wCampo(tcInt, '#19', 'cMun    ', 07, 07, 1, cMun, DSC_CMUN);
      if not ValidarMunicipio(CIOT.infCTeNorm.ferrov.ferroEnv[i].EnderFerro.cMun) then
        Gerador.wAlerta('#19', 'cMun', DSC_CMUN, ERR_MSG_INVALIDO);
      Gerador.wCampo(tcStr, '#20', 'xMun    ', 01, 60, 1, xMun, DSC_XMUN);
      Gerador.wCampo(tcInt, '#21', 'CEP     ', 08, 08, 0, CIOT.infCTeNorm.ferrov.ferroEnv[i].EnderFerro.CEP, DSC_CEP);
      Gerador.wCampo(tcStr, '#22', 'UF      ', 02, 02, 1, xUF, DSC_UF);
      if not ValidarUF(xUF) then
        Gerador.wAlerta('#22', 'UF', DSC_UF, ERR_MSG_INVALIDO);
      Gerador.wGrupo('/enderFerro');

      Gerador.wGrupo('/ferroSub');
    end;

   end;
end;

procedure TCIOTW.GerardetVag;
var
 i: Integer;
begin
  for i := 0 to CIOT.infCTeNorm.ferrov.detVag.Count - 1 do
   begin
    Gerador.wGrupo('detVag', '#23');
    Gerador.wCampo(tcInt, '#24', 'nVag   ', 08, 08, 1, CIOT.infCTeNorm.ferrov.detVag.Items[i].nVag, DSC_VAGAO);
    Gerador.wCampo(tcDe2, '#25', 'cap    ', 01, 05, 0, CIOT.infCTeNorm.ferrov.detVag.Items[i].cap, DSC_CAPTO);
    Gerador.wCampo(tcStr, '#26', 'tpVag  ', 03, 03, 0, CIOT.infCTeNorm.ferrov.detVag.Items[i].tpVag, DSC_TPVAG);
    Gerador.wCampo(tcDe2, '#27', 'pesoR  ', 01, 05, 1, CIOT.infCTeNorm.ferrov.detVag.Items[i].pesoR, DSC_PESOR);
    Gerador.wCampo(tcDe2, '#28', 'pesoBC ', 01, 05, 1, CIOT.infCTeNorm.ferrov.detVag.Items[i].pesoBC, DSC_PESOBC);
   end;

  if CIOT.infCTeNorm.ferrov.detVag.Count > 990 then
   Gerador.wAlerta('#23', 'detVag', DSC_VAGAO, ERR_MSG_MAIOR_MAXIMO + '990');
end;

procedure TCIOTW.GerarDuto;
begin
  Gerador.wGrupo('duto', '#01');
  Gerador.wCampo(tcDe6, '#02', 'vTar ', 01, 15, 0, CIOT.infCTeNorm.duto.vTar, DSC_VTAR);
  Gerador.wCampo(tcDat, '#03', 'dIni ', 10, 10, 1, CIOT.infCTeNorm.duto.dIni, DSC_DINI);
  Gerador.wCampo(tcDat, '#04', 'dFim ', 10, 10, 1, CIOT.infCTeNorm.duto.dFim, DSC_DFIM);
  Gerador.wGrupo('/duto');
end;

procedure TCIOTW.GerarMultimodal;
begin
  Gerador.wGrupo('multimodal', '#01');
  Gerador.wCampo(tcStr, '#02', 'COTM         ', 01, 255, 1, CIOT.infCTeNorm.multimodal.COTM, DSC_COTM);
  Gerador.wCampo(tcStr, '#03', 'indNegociavel', 01, 001, 1, indNegociavelToStr(CIOT.infCTeNorm.multimodal.indNegociavel), DSC_INDNEG);
  Gerador.wGrupo('/multimodal');
end;

procedure TCIOTW.GerarPeri;
var
 i: Integer;
begin
  for i := 0 to CIOT.infCTeNorm.peri.Count - 1 do
   begin
    Gerador.wGrupo('peri', '#369');
    Gerador.wCampo(tcStr, '#370', 'nONU       ', 01,  04, 1, CIOT.infCTeNorm.peri.Items[i].nONU, DSC_NONU);
    Gerador.wCampo(tcStr, '#371', 'xNomeAE    ', 01, 150, 1, CIOT.infCTeNorm.peri.Items[i].xNomeAE, DSC_XNOMEAE);
    Gerador.wCampo(tcStr, '#372', 'xClaRisco  ', 01,  40, 1, CIOT.infCTeNorm.peri.Items[i].xClaRisco, DSC_XCLARISCO);
    Gerador.wCampo(tcStr, '#373', 'grEmb      ', 01,  06, 0, CIOT.infCTeNorm.peri.Items[i].grEmb, DSC_GREMB);
    Gerador.wCampo(tcStr, '#374', 'qTotProd   ', 01,  20, 1, CIOT.infCTeNorm.peri.Items[i].qTotProd, DSC_QTOTPROD);
    Gerador.wCampo(tcStr, '#375', 'qVolTipo   ', 01,  60, 0, CIOT.infCTeNorm.peri.Items[i].qVolTipo, DSC_QVOLTIPO);
    Gerador.wCampo(tcStr, '#375', 'pontoFulgor', 01,  06, 0, CIOT.infCTeNorm.peri.Items[i].pontoFulgor, DSC_PONTOFULGOR);
    Gerador.wGrupo('/peri');
   end;
  if CIOT.infCTeNorm.peri.Count > 990 then
   Gerador.wAlerta('#369', 'peri', '', ERR_MSG_MAIOR_MAXIMO + '990');
end;

procedure TCIOTW.GerarVeicNovos;
var
 i: Integer;
begin
  for i := 0 to CIOT.infCTeNorm.veicNovos.Count - 1 do
   begin
    Gerador.wGrupo('veicNovos', '#377');
    Gerador.wCampo(tcStr, '#378', 'chassi ', 17, 17, 1, CIOT.infCTeNorm.veicNovos.Items[i].chassi, DSC_CHASSI);
    Gerador.wCampo(tcStr, '#379', 'cCor   ', 01, 04, 1, CIOT.infCTeNorm.veicNovos.Items[i].cCor, DSC_CCOR);
    Gerador.wCampo(tcStr, '#380', 'xCor   ', 01, 40, 1, CIOT.infCTeNorm.veicNovos.Items[i].xCor, DSC_XCOR);
    Gerador.wCampo(tcStr, '#381', 'cMod   ', 01, 06, 1, CIOT.infCTeNorm.veicNovos.Items[i].cMod, DSC_CMOD);
    Gerador.wCampo(tcDe2, '#382', 'vUnit  ', 01, 15, 1, CIOT.infCTeNorm.veicNovos.Items[i].vUnit, DSC_VUNITV);
    Gerador.wCampo(tcDe2, '#383', 'vFrete ', 01, 15, 1, CIOT.infCTeNorm.veicNovos.Items[i].vFrete, DSC_VFRETEV);
    Gerador.wGrupo('/veicNovos');
   end;
  if CIOT.infCTeNorm.veicNovos.Count > 990 then
   Gerador.wAlerta('#377', 'veicNovos', '', ERR_MSG_MAIOR_MAXIMO + '990');
end;

procedure TCIOTW.GerarCobr;
begin
  if (Trim(CIOT.infCTeNorm.cobr.fat.nFat) <> '') or (CIOT.infCTeNorm.cobr.fat.vOrig > 0) or
     (CIOT.infCTeNorm.cobr.fat.vDesc > 0) or (CIOT.infCTeNorm.cobr.fat.vLiq > 0) or
     (CIOT.infCTeNorm.cobr.dup.Count > 0) then
  begin
    Gerador.wGrupo('cobr', '#384');
    GerarCobrFat;
    GerarCobrDup;
    Gerador.wGrupo('/cobr');
  end;
end;

procedure TCIOTW.GerarCobrFat;
begin
  if (Trim(CIOT.infCTeNorm.cobr.fat.nFat) <> '') or (CIOT.infCTeNorm.cobr.fat.vOrig > 0) or
     (CIOT.infCTeNorm.cobr.fat.vDesc > 0) or (CIOT.infCTeNorm.cobr.fat.vLiq > 0) then
  begin
    Gerador.wGrupo('fat', '#385');
    Gerador.wCampo(tcStr, '#386', 'nFat  ', 01, 60, 0, CIOT.infCTeNorm.cobr.fat.nFat, DSC_NFAT);
    Gerador.wCampo(tcDe2, '#387', 'vOrig ', 01, 15, 0, CIOT.infCTeNorm.cobr.fat.vOrig, DSC_VORIG);
    Gerador.wCampo(tcDe2, '#388', 'vDesc ', 01, 15, 0, CIOT.infCTeNorm.cobr.fat.vDesc, DSC_VDESC);
    Gerador.wCampo(tcDe2, '#389', 'vLiq  ', 01, 15, 0, CIOT.infCTeNorm.cobr.fat.vLiq, DSC_VLIQ);
    Gerador.wGrupo('/fat');
  end;
end;

procedure TCIOTW.GerarCobrDup;
var
  i: integer;
begin
  for i := 0 to CIOT.infCTeNorm.cobr.dup.Count - 1 do
  begin
    Gerador.wGrupo('dup', '#390');
    Gerador.wCampo(tcStr, '#391', 'nDup  ', 01, 60, 0, CIOT.infCTeNorm.cobr.dup[i].nDup, DSC_NDUP);
    Gerador.wCampo(tcDat, '#392', 'dVenc ', 10, 10, 0, CIOT.infCTeNorm.cobr.dup[i].dVenc, DSC_DVENC);
    Gerador.wCampo(tcDe2, '#393', 'vDup  ', 01, 15, 0, CIOT.infCTeNorm.cobr.dup[i].vDup, DSC_VDUP);
    Gerador.wGrupo('/dup');
  end;
end;

procedure TCIOTW.GerarInfCTeSub;  // S
begin
 if CIOT.infCTeNorm.infCTeSub.chCte<>''
  then begin
   Gerador.wGrupo('infCteSub', '#394');
   Gerador.wCampo(tcEsp, '#395', 'chCte ', 44, 44, 1, SomenteNumeros(CIOT.infCTeNorm.infCTeSub.chCte), DSC_CHCTE);
   if SomenteNumeros(CIOT.infCTeNorm.infCTeSub.chCte) <> '' then
    if not ValidarChave('NFe' + SomenteNumeros(CIOT.infCTeNorm.infCTeSub.chCte)) then
     Gerador.wAlerta('#395', 'chCte', DSC_REFNFE, ERR_MSG_INVALIDO);

   if (CIOT.infCTeNorm.infCTeSub.tomaNaoICMS.refCteAnu='')
    then begin
     Gerador.wGrupo('tomaICMS', '#396');
     if (CIOT.infCTeNorm.infCTeSub.tomaICMS.refNFe<>'')
      then begin
       Gerador.wCampo(tcEsp, '#397', 'refNFe ', 44, 44, 1, SomenteNumeros(CIOT.infCTeNorm.infCTeSub.tomaICMS.refNFe), DSC_CHAVE);
       if SomenteNumeros(CIOT.infCTeNorm.infCTeSub.tomaICMS.refNFe) <> '' then
        if not ValidarChave('NFe' + SomenteNumeros(CIOT.infCTeNorm.infCTeSub.tomaICMS.refNFe)) then
         Gerador.wAlerta('#397', 'refNFe', DSC_REFNFE, ERR_MSG_INVALIDO);
      end
      else begin
       if (CIOT.infCTeNorm.infCTeSub.tomaICMS.refNF.CNPJCPF<>'')
        then begin
         Gerador.wGrupo('refNF', '#398');
         Gerador.wCampoCNPJCPF('#399', '#400', CIOT.infCTeNorm.infCTeSub.tomaICMS.refNF.CNPJCPF, CODIGO_BRASIL);
         Gerador.wCampo(tcStr, '#401', 'mod      ', 02, 02, 1, CIOT.infCTeNorm.infCTeSub.tomaICMS.refNF.modelo, DSC_MOD);
         Gerador.wCampo(tcInt, '#402', 'serie    ', 01, 03, 1, CIOT.infCTeNorm.infCTeSub.tomaICMS.refNF.serie, DSC_SERIE);
         Gerador.wCampo(tcInt, '#403', 'subserie ', 01, 03, 0, CIOT.infCTeNorm.infCTeSub.tomaICMS.refNF.subserie, DSC_SERIE);
         Gerador.wCampo(tcInt, '#404', 'nro      ', 01, 06, 1, CIOT.infCTeNorm.infCTeSub.tomaICMS.refNF.nro, DSC_NNF);
         Gerador.wCampo(tcDe2, '#405', 'valor    ', 01, 15, 1, CIOT.infCTeNorm.infCTeSub.tomaICMS.refNF.valor, DSC_VDOC);
         Gerador.wCampo(tcDat, '#406', 'dEmi     ', 10, 10, 1, CIOT.infCTeNorm.infCTeSub.tomaICMS.refNF.dEmi, DSC_DEMI);
         Gerador.wGrupo('/refNF');
        end
        else begin
         Gerador.wCampo(tcEsp, '#407', 'refCte   ', 44, 44, 1, SomenteNumeros(CIOT.infCTeNorm.infCTeSub.tomaICMS.refCte), DSC_CHCTE);
         if SomenteNumeros(CIOT.infCTeNorm.infCTeSub.tomaICMS.refCte) <> '' then
          if not ValidarChave('NFe' + SomenteNumeros(CIOT.infCTeNorm.infCTeSub.tomaICMS.refCte)) then
           Gerador.wAlerta('#407', 'refCte', DSC_REFNFE, ERR_MSG_INVALIDO);
        end;
      end;
     Gerador.wGrupo('/tomaICMS');
    end
    else begin
     Gerador.wGrupo('tomaNaoICMS', '#408');
     Gerador.wCampo(tcEsp, '#409', 'refCteAnu ', 44, 44, 1, SomenteNumeros(CIOT.infCTeNorm.infCTeSub.tomaNaoICMS.refCteAnu), DSC_CHCTE);
     if SomenteNumeros(CIOT.infCTeNorm.infCTeSub.tomaNaoICMS.refCteAnu) <> '' then
      if not ValidarChave('NFe' + SomenteNumeros(CIOT.infCTeNorm.infCTeSub.tomaNaoICMS.refCteAnu)) then
       Gerador.wAlerta('#409', 'refCteAnu', DSC_REFNFE, ERR_MSG_INVALIDO);
     Gerador.wGrupo('/tomaNaoICMS');
    end;
   Gerador.wGrupo('/infCteSub');
  end;
end;

procedure TCIOTW.GerarInfCTeComp;
var
  i: integer;
begin
  if (CIOT.Ide.tpCTe = tcComplemento) then
  begin
    Gerador.wGrupo('infCteComp', '#410');
    Gerador.wCampo(tcEsp, '#411', 'chave   ', 44, 44, 1, SomenteNumeros(CIOT.infCTeComp.Chave), DSC_CHCTE);
    if SomenteNumeros(CIOT.infCTeComp.Chave) <> '' then
     if not ValidarChave('NFe' + SomenteNumeros(CIOT.infCTeComp.Chave)) then
      Gerador.wAlerta('#411', 'chave', DSC_REFNFE, ERR_MSG_INVALIDO);
    (*
    Gerador.wGrupo('vPresComp', '#411');
    Gerador.wCampo(tcDe2, '#412', 'vTPrest ', 01, 15, 1, CIOT.infCTeComp.vPresComp.vTPrest, DSC_VTPREST);

    for i := 0 to CIOT.InfCTeComp.vPresComp.compComp.Count - 1 do
    begin
      if (CIOT.InfCTeComp.vPresComp.compComp[i].xNome <> '') and
        (CIOT.InfCTeComp.vPresComp.compComp[i].vComp <> 0) then
        begin
          Gerador.wGrupo('compComp', '#413');
          Gerador.wCampo(tcStr, '#414', 'xNome ', 01, 15, 1, CIOT.InfCTeComp.vPresComp.compComp[i].xNome, DSC_XNOMEC);
          Gerador.wCampo(tcDe2, '#415', 'vComp ', 01, 15, 1, CIOT.InfCTeComp.vPresComp.compComp[i].vComp, DSC_VCOMP);
          Gerador.wGrupo('/compComp');
        end;
    end;

    Gerador.wGrupo('/vPresComp');

    GerarImpComp;
    *)
    Gerador.wGrupo('/infCteComp');
  end;
end;

procedure TCIOTW.GerarImpComp;
begin
  Gerador.wGrupo('impComp', '#416');
  GerarICMSComp;
  Gerador.wCampo(tcDe2, '#452', 'vTotTrib   ', 01, 15, 0, CIOT.InfCTeComp.impComp.vTotTrib, DSC_VCOMP);
  Gerador.wCampo(tcStr, '#453', 'infAdFisco ', 01, 1000, 0, CIOT.InfCTeComp.impComp.InfAdFisco, DSC_INFADFISCO);
  Gerador.wGrupo('/impComp');
end;

procedure TCIOTW.GerarICMSComp;
begin
  Gerador.wGrupo('ICMSComp', '#417');

  if CIOT.InfCTeComp.impComp.ICMSComp.SituTrib = cst00 then
    GerarCST00Comp
  else if CIOT.InfCTeComp.impComp.ICMSComp.SituTrib = cst20 then
    GerarCST20Comp
  else if ((CIOT.InfCTeComp.impComp.ICMSComp.SituTrib = cst40) or
           (CIOT.InfCTeComp.impComp.ICMSComp.SituTrib = cst41) or
           (CIOT.InfCTeComp.impComp.ICMSComp.SituTrib = cst51)) then
    GerarCST45Comp
  else if CIOT.InfCTeComp.impComp.ICMSComp.SituTrib = cst60 then
    GerarCST60Comp
  else if CIOT.InfCTeComp.impComp.ICMSComp.SituTrib = cst90 then
    GerarCST90Comp
  else if CIOT.InfCTeComp.impComp.ICMSComp.SituTrib = cstICMSOutraUF then
    GerarICMSOutraUFComp
  else if CIOT.InfCTeComp.impComp.ICMSComp.SituTrib = cstICMSSN then
    GerarICMSSNComp;

  Gerador.wGrupo('/ICMSComp');
end;

procedure TCIOTW.GerarCST00Comp;
begin
  Gerador.wGrupo('ICMS00', '#418');
  Gerador.wCampo(tcStr, '#419', 'CST   ', 02, 02, 1, CSTICMSTOStr(CIOT.InfCTeComp.impComp.ICMSComp.ICMS00.CST), DSC_CST);
  Gerador.wCampo(tcDe2, '#420', 'vBC   ', 01, 15, 1, CIOT.InfCTeComp.impComp.ICMSComp.ICMS00.vBC, DSC_VBC);
  Gerador.wCampo(tcDe2, '#421', 'pICMS ', 01, 05, 1, CIOT.InfCTeComp.impComp.ICMSComp.ICMS00.pICMS, DSC_PICMS);
  Gerador.wCampo(tcDe2, '#422', 'vICMS ', 01, 15, 1, CIOT.InfCTeComp.impComp.ICMSComp.ICMS00.vICMS, DSC_VICMS);
  Gerador.wGrupo('/ICMS00');
end;

procedure TCIOTW.GerarCST20Comp;
begin
  Gerador.wGrupo('ICMS20', '#423');
  Gerador.wCampo(tcStr, '#424', 'CST    ', 02, 02, 1, CSTICMSTOStr(CIOT.InfCTeComp.impComp.ICMSComp.ICMS20.CST), DSC_CST);
  Gerador.wCampo(tcDe2, '#425', 'pRedBC ', 01, 05, 1, CIOT.InfCTeComp.impComp.ICMSComp.ICMS20.pRedBC, DSC_PREDBC);
  Gerador.wCampo(tcDe2, '#426', 'vBC    ', 01, 15, 1, CIOT.InfCTeComp.impComp.ICMSComp.ICMS20.vBC, DSC_VBC);
  Gerador.wCampo(tcDe2, '#427', 'pICMS  ', 01, 05, 1, CIOT.InfCTeComp.impComp.ICMSComp.ICMS20.pICMS, DSC_PICMS);
  Gerador.wCampo(tcDe2, '#428', 'vICMS  ', 01, 15, 1, CIOT.InfCTeComp.impComp.ICMSComp.ICMS20.vICMS, DSC_VICMS);
  Gerador.wGrupo('/ICMS20');
end;

procedure TCIOTW.GerarCST45Comp;
begin
  Gerador.wGrupo('ICMS45', '#429');
  Gerador.wCampo(tcStr, '#430', 'CST ', 02, 02, 1, CSTICMSTOStr(CIOT.InfCTeComp.impComp.ICMSComp.ICMS45.CST), DSC_CST);
  Gerador.wGrupo('/ICMS45');
end;

procedure TCIOTW.GerarCST60Comp;
begin
  Gerador.wGrupo('ICMS60', '#431');
  Gerador.wCampo(tcStr, '#432', 'CST        ', 02, 02, 1, CSTICMSTOStr(CIOT.InfCTeComp.impComp.ICMSComp.ICMS60.CST), DSC_CST);
  Gerador.wCampo(tcDe2, '#433', 'vBCSTRet   ', 01, 15, 1, CIOT.InfCTeComp.impComp.ICMSComp.ICMS60.vBCSTRet, DSC_VBC);
  Gerador.wCampo(tcDe2, '#434', 'vICMSSTRet ', 01, 15, 1, CIOT.InfCTeComp.impComp.ICMSComp.ICMS60.vICMSSTRet, DSC_VICMS);
  Gerador.wCampo(tcDe2, '#435', 'pICMSSTRet ', 01, 05, 1, CIOT.InfCTeComp.impComp.ICMSComp.ICMS60.pICMSSTRet, DSC_PICMS);
  if CIOT.InfCTeComp.impComp.ICMSComp.ICMS60.vCred > 0 then
   Gerador.wCampo(tcDe2, '#436', 'vCred     ', 01, 15, 1, CIOT.InfCTeComp.impComp.ICMSComp.ICMS60.vCred, DSC_VCRED);
  Gerador.wGrupo('/ICMS60');
end;

procedure TCIOTW.GerarCST90Comp;
begin
  Gerador.wGrupo('ICMS90', '#437');
  Gerador.wCampo(tcStr, '#438', 'CST      ', 02, 02, 1, CSTICMSTOStr(CIOT.InfCTeComp.impComp.ICMSComp.ICMS90.CST), DSC_CST);
  if CIOT.InfCTeComp.impComp.ICMSComp.ICMS90.pRedBC > 0 then
    Gerador.wCampo(tcDe2, '#439', 'pRedBC ', 01, 05, 1, CIOT.InfCTeComp.impComp.ICMSComp.ICMS90.pRedBC, DSC_PREDBC);
  Gerador.wCampo(tcDe2, '#440', 'vBC      ', 01, 15, 1, CIOT.InfCTeComp.impComp.ICMSComp.ICMS90.vBC, DSC_VBC);
  Gerador.wCampo(tcDe2, '#441', 'pICMS    ', 01, 05, 1, CIOT.InfCTeComp.impComp.ICMSComp.ICMS90.pICMS, DSC_PICMS);
  Gerador.wCampo(tcDe2, '#442', 'vICMS    ', 01, 15, 1, CIOT.InfCTeComp.impComp.ICMSComp.ICMS90.vICMS, DSC_VICMS);
  if CIOT.InfCTeComp.impComp.ICMSComp.ICMS90.vCred > 0 then
    Gerador.wCampo(tcDe2, '#443', 'vCred  ', 01, 15, 1, CIOT.InfCTeComp.impComp.ICMSComp.ICMS90.vCred, DSC_VCRED);
  Gerador.wGrupo('/ICMS90');
end;

procedure TCIOTW.GerarICMSOutraUFComp;
begin
  Gerador.wGrupo('ICMSOutraUF', '#444');
  Gerador.wCampo(tcStr, '#445', 'CST             ', 02, 02, 1, CSTICMSTOStr(CIOT.InfCTeComp.impComp.ICMSComp.ICMSOutraUF.CST), DSC_CST);
  if CIOT.InfCTeComp.impComp.ICMSComp.ICMSOutraUF.pRedBCOutraUF > 0 then
    Gerador.wCampo(tcDe2, '#446', 'pRedBCOutraUF ', 01, 05, 1, CIOT.InfCTeComp.impComp.ICMSComp.ICMSOutraUF.pRedBCOutraUF, DSC_PREDBC);
  Gerador.wCampo(tcDe2, '#447', 'vBCOutraUF      ', 01, 15, 1, CIOT.InfCTeComp.impComp.ICMSComp.ICMSOutraUF.vBCOutraUF, DSC_VBC);
  Gerador.wCampo(tcDe2, '#448', 'pICMSOutraUF    ', 01, 05, 1, CIOT.InfCTeComp.impComp.ICMSComp.ICMSOutraUF.pICMSOutraUF, DSC_PICMS);
  Gerador.wCampo(tcDe2, '#449', 'vICMSOutraUF    ', 01, 15, 1, CIOT.InfCTeComp.impComp.ICMSComp.ICMSOutraUF.vICMSOutraUF, DSC_VICMS);
  Gerador.wGrupo('/ICMSOutraUF');
end;

procedure TCIOTW.GerarICMSSNComp;
begin
  Gerador.wGrupo('ICMSSN', '#450');
  Gerador.wCampo(tcInt, '#451', 'indSN ', 01, 01, 1, CIOT.InfCTeComp.impComp.ICMSComp.ICMSSN.indSN, DSC_INDSN);
  Gerador.wGrupo('/ICMSSN');
end;

procedure TCIOTW.GerarInfCTeAnu;
begin
  if (CIOT.Ide.tpCTe = tcAnulacao) then
  begin
    Gerador.wGrupo('infCteAnu', '#412');
    Gerador.wCampo(tcEsp, '#413', 'chCte ', 44, 44, 1, SomenteNumeros(CIOT.InfCTeAnu.chCTe), DSC_CHCTE);
    if SomenteNumeros(CIOT.InfCTeAnu.chCTe) <> '' then
     if not ValidarChave('NFe' + SomenteNumeros(CIOT.InfCTeAnu.chCTe)) then
      Gerador.wAlerta('#413', 'chCte', DSC_REFNFE, ERR_MSG_INVALIDO);
    Gerador.wCampo(tcDat, '#414', 'dEmi  ', 10, 10, 1, CIOT.InfCTeAnu.dEmi, DSC_DEMI);
    Gerador.wGrupo('/infCteAnu');
  end;
end;

procedure TCIOTW.GerarautXML;
var
  i: integer;
begin
  for i := 0 to CIOT.autXML.Count - 1 do
  begin
    Gerador.wGrupo('autXML', '#415');
    Gerador.wCampoCNPJCPF('#416', '#417', CIOT.autXML[i].CNPJCPF, CODIGO_BRASIL);
    Gerador.wGrupo('/autXML');
  end;
  if CIOT.autXML.Count > 10 then
    Gerador.wAlerta('#415', 'autXML', '', ERR_MSG_MAIOR_MAXIMO + '10');
end;

procedure TCIOTW.AjustarMunicipioUF(var xUF, xMun: string;
  var cMun: integer; cPais: integer; vxUF, vxMun: string; vcMun: integer);
var
  PaisBrasil: boolean;
begin
  PaisBrasil := cPais = CODIGO_BRASIL;
  cMun := IIf(PaisBrasil, vcMun, CMUN_EXTERIOR);
  xMun := IIf(PaisBrasil, vxMun, XMUN_EXTERIOR);
  xUF := IIf(PaisBrasil, vxUF, UF_EXTERIOR);
  xMun := ObterNomeMunicipio(xMun, xUF, cMun);
end;

function TCIOTW.ObterNomeMunicipio(const xMun, xUF: string;
  const cMun: integer): string;
var
  i: integer;
  PathArquivo, Codigo: string;
  List: TstringList;
begin
  result := '';
  if (FOpcoes.NormatizarMunicipios) and (cMun <> CMUN_EXTERIOR) then
  begin
    PathArquivo := FOpcoes.FPathArquivoMunicipios + 'MunIBGE-UF' + InttoStr(UFparaCodigo(xUF)) + '.txt';
    if FileExists(PathArquivo) then
    begin
      List := TstringList.Create;
      List.LoadFromFile(PathArquivo);
      Codigo := IntToStr(cMun);
      i := 0;
      while (i < list.count) and (result = '') do
      begin
        if pos(Codigo, List[i]) > 0 then
          result := Trim(stringReplace(list[i], codigo, '', []));
        inc(i);
      end;
      List.free;
    end;
  end;
  if result = '' then
    result := xMun;
end;


end.

