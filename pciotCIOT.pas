{$I ACBr.inc}

unit pciotCIOT;

interface uses

  SysUtils, Classes, Forms,

{$IFNDEF VER130}
  Variants,
{$ENDIF}

  ASCIOTUtil, ACBrUtil,
  smtpsend, ssl_openssl, mimemess, mimepart, // units para enviar email
  pcnAuxiliar, pcnConversao, pcnSignature;


type
  TOperacaoTransporte    = class;
  TContratante = class;
  TOptMotorista = class;
  TMotorista = class;
  TDestinatario = class;
  TContratado = class;
  TConsignatario = class;
  TImpostos = class;
  TSubcontratante = class;
  TEndereco = class;
  TTelefone = class;
  TTelefones = class;
  TInformacoesBancarias = class;
  TPagamentoCollection = class;
  TPagamentoCollectionItem = class;
  TViagemCollection = class;
  TViagemCollectionItem = class;
  TVeiculoCollection = class;
  TVeiculoCollectionItem = class;
  TNotaFiscalCollection     = class;
  TNotaFiscalCollectionItem = class;
  TValoresOT = class;
  TVeiculo = class;
  TIntegradora = class;
  TProprietario = class;
  TCancelamento = class;


  TIntegradora = class(TPersistent)
  private
    FSenha: string;
    FIdentificacao: string;
    FUsuario: string;
    FTecnologia: TpciotIntegradora;
  public
    constructor Create;
  published
    property Tecnologia: TpciotIntegradora read FTecnologia write FTecnologia;
    property Identificacao: string read FIdentificacao write FIdentificacao;
    property Usuario: string read FUsuario write FUsuario;
    property Senha: string read FSenha write FSenha;
  end;

  TVeiculo = class(TPersistent)
  private
    FOwner: TComponent;
    FCor: string;
    FChassi: string;
    FTara: double;
    FNumeroDeEixos: integer;
    FModelo: string;
    FAnoFabricacao: integer;
    FCapacidadeM3: double;
    FRNTRC: string;
    FTipoCarroceria: TpcteTipoCarroceria;
    FMarca: string;
    FPlaca: string;
    FRenavam: string;
    FCodigoMunicipio: integer;
    FCapacidadeKg: double;
    FTipoRodado: TpcteTipoRodado;
    FAnoModelo: integer;
    procedure setPlaca(const Value: string);
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;
    property Owner: TComponent read FOwner;
    procedure Limpar;
  published
    property AnoFabricacao: integer read FAnoFabricacao write FAnoFabricacao;
    property AnoModelo: integer read FAnoModelo write FAnoModelo;
    property CapacidadeKg: double read FCapacidadeKg  write FCapacidadeKg;
    property CapacidadeM3: double read FCapacidadeM3 write FCapacidadeM3;
    property Chassi: string read FChassi write FChassi;
    property CodigoMunicipio: integer read FCodigoMunicipio write FCodigoMunicipio;
    property Cor: string read FCor write FCor;
    property Marca: string read FMarca write FMarca;
    property Modelo: string read FModelo write FModelo;
    property NumeroDeEixos: integer read FNumeroDeEixos write FNumeroDeEixos;
    property Placa: string read FPlaca write setPlaca;
    property RNTRC: string read FRNTRC write FRNTRC;
    property Renavam: string read FRenavam write FRenavam;
    property Tara: double read FTara write FTara;
    property TipoCarroceria: TpcteTipoCarroceria read FTipoCarroceria write FTipoCarroceria;
    property TipoRodado: TpcteTipoRodado read FTipoRodado write FTipoRodado;
  end;


  TOperacaoTransporte = class(TCollectionItem)
  private
    FOwner: TComponent;
    FCodigoNCMNaturezaCarga: integer;
    FPesoCarga: double;
    FContratante: TContratante;
    FTipoViagem: TpciotTipoViagem;
    FMotorista: TOptMotorista;
    FDestinatario: TDestinatario;
    FEmissaoGratuita: Boolean;
    FIntegrador: string;
    FContratado: TContratado;
    FFilialCNPJ: string;
    FConsignatario: TConsignatario;
    FCodigoIdentificacaoOperacaoPrincipal: string;
    FObservacoesAoTransportador: string;
    FPagamentos: TPagamentoCollection;
    FVeiculos: TVeiculoCollection;
    FImpostos: TImpostos;
    FMatrizCNPJ: string;
    FDataFimViagem: TDate;
    FDataInicioViagem: TDate;
    FViagens: TViagemCollection;
    FIdOperacaoCliente: string;
    FObservacoesAoCredenciado: string;
    FSubcontratante: TSubcontratante;
    FNumeroCIOT: string;
    FDataRetificacao: TDateTime;
    FCancelamento: TCancelamento;
    FProtocoloEncerramento: string;

    function getVersao: integer;
    procedure setViagens(const Value: TViagemCollection);
    procedure setVeiculos(const Value: TVeiculoCollection);
    procedure setFilialCNPJ(const Value: string);
    procedure setMatrizCNPJ(const Value: string);
  public
//    constructor Create(AOwner: TComponent);
    constructor Create(Collection2: TCollection); override;
    destructor Destroy; override;

    property Owner: TComponent read FOwner;

    procedure Limpar;
  published
    property CodigoIdentificacaoOperacaoPrincipal: string read FCodigoIdentificacaoOperacaoPrincipal write FCodigoIdentificacaoOperacaoPrincipal;
    property CodigoNCMNaturezaCarga: integer read FCodigoNCMNaturezaCarga write FCodigoNCMNaturezaCarga;
    property Consignatario: TConsignatario read FConsignatario write FConsignatario;
    property Contratado: TContratado read FContratado write FContratado;
    property Contratante: TContratante read FContratante write FContratante;
    property DataFimViagem: TDate read FDataFimViagem write FDataFimViagem;
    property DataInicioViagem: TDate read FDataInicioViagem write FDataInicioViagem;
    property Destinatario: TDestinatario read FDestinatario write FDestinatario;
    property FilialCNPJ: string read FFilialCNPJ write setFilialCNPJ;
    property IdOperacaoCliente: string read FIdOperacaoCliente write FIdOperacaoCliente;
    property Integrador: string read FIntegrador write FIntegrador;
    property Impostos: TImpostos read FImpostos write FImpostos;
    property MatrizCNPJ: string read FMatrizCNPJ write setMatrizCNPJ;
    property Motorista: TOptMotorista read FMotorista write FMotorista;
    property Pagamentos: TPagamentoCollection read FPagamentos write FPagamentos;
    property PesoCarga: double read FPesoCarga write FPesoCarga;
    property Subcontratante: TSubcontratante read FSubcontratante write FSubcontratante;
    property TipoViagem: TpciotTipoViagem read FTipoViagem write FTipoViagem;
    property Veiculos: TVeiculoCollection read FVeiculos write setVeiculos;
    property Versao: integer read getVersao;//3
    property Viagens: TViagemCollection read FViagens write setViagens;
    property EmissaoGratuita: Boolean read FEmissaoGratuita write FEmissaoGratuita;
    property ObservacoesAoTransportador: string read FObservacoesAoTransportador write FObservacoesAoTransportador;
    property ObservacoesAoCredenciado: string read FObservacoesAoCredenciado write FObservacoesAoCredenciado;
    property Cancelamento: TCancelamento read FCancelamento write FCancelamento;

    property NumeroCIOT: string read FNumeroCIOT write FNumeroCIOT;
    property DataRetificacao: TDateTime read FDataRetificacao write FDataRetificacao;
    property ProtocoloEncerramento: string read FProtocoloEncerramento write FProtocoloEncerramento;
  end;


  TOperacoesTransporte = class(TOwnedCollection)
  private
    FOwner: TComponent;

    function GetItem(Index: Integer): TOperacaoTransporte;
    procedure SetItem(Index: Integer; const Value: TOperacaoTransporte);
  public
    constructor Create(AOwner: TPersistent; ItemClass: TCollectionItemClass);

    procedure GerarCTe;
    procedure Imprimir;

    function  Add: TOperacaoTransporte;
    function Insert(Index: Integer): TOperacaoTransporte;

    property Items[Index: Integer]: TOperacaoTransporte read GetItem         write SetItem;
    property Owner: TComponent                 read FOwner;
  end;


  TConsignatario = class(TPersistent)
  private
    FEMail: string;
    FResponsavelPeloPagamento: Boolean;
    FNomeOuRazaoSocial: string;
    FCpfOuCnpj: string;
    FTelefones: TTelefones;
    FEndereco: TEndereco;
    procedure SetCpfOuCnpj(const Value: string);
  public
    constructor Create(AOwner: TOperacaoTransporte);
    destructor Destroy; override;
    procedure Clear;
  published
    property CpfOuCnpj: string read FCpfOuCnpj write SetCpfOuCnpj;
    property EMail: string read FEMail write FEMail;
    property Endereco: TEndereco read FEndereco write FEndereco;
    property NomeOuRazaoSocial: string read FNomeOuRazaoSocial write FNomeOuRazaoSocial;
    property ResponsavelPeloPagamento: Boolean read FResponsavelPeloPagamento write FResponsavelPeloPagamento;
    property Telefones: TTelefones read FTelefones write FTelefones;
  end;

  TInformacoesBancarias = class(TPersistent)
  private
    FConta: string;
    FInstituicaoBancaria: string;
    FAgencia: string;
  public
    destructor Destroy; override;
  published
    property Agencia: string read FAgencia write FAgencia;
    property Conta: string read FConta write FConta;
    property InstituicaoBancaria: string read FInstituicaoBancaria write FInstituicaoBancaria;
  end;

  TContratado = class(TPersistent)
  private
    FCpfOuCnpj: string;
    FRNTRC: string;
    procedure setCpfOuCnpj(const Value: string);
  public
    destructor Destroy; override;
    procedure Clear;
  published
    property CpfOuCnpj: string read FCpfOuCnpj write setCpfOuCnpj;
    property RNTRC: string read FRNTRC write FRNTRC;
  end;

  TToleranciaDePerdaDeMercadoria = class(TPersistent)
  private
    FValor: currency;
    FTipo: TpciotTipoProporcao;
  public
    destructor Destroy; override;
  published
    property Tipo: TpciotTipoProporcao read FTipo write FTipo;
    property Valor: currency read FValor write FValor;
  end;

  TDiferencaFreteMargem = class(TPersistent)
  private
    FTipo: TpciotTipoProporcao;
    FValor: currency;
  public
  published
    property Tipo:  TpciotTipoProporcao  read FTipo write FTipo;
    property Valor: currency read FValor write FValor;
  end;

  TDiferencaDeFrete = class(TPersistent)
  private
    FTipo: TpciotDiferencaFreteTipo;
    FMargemGanho: TDiferencaFreteMargem;
    FTolerancia: TDiferencaFreteMargem;
    FBase: TpciotDiferencaFreteBaseCalculo;
    FMargemPerda: TDiferencaFreteMargem;
  public
    constructor Create;
    destructor Destroy; override;
  published
    property Tipo: TpciotDiferencaFreteTipo read FTipo write FTipo;
    property Base: TpciotDiferencaFreteBaseCalculo read FBase write FBase;
    property Tolerancia: TDiferencaFreteMargem read FTolerancia write FTolerancia;
    property MargemGanho: TDiferencaFreteMargem read FMargemGanho write FMargemGanho;
    property MargemPerda: TDiferencaFreteMargem read FMargemPerda write FMargemPerda;
  end;

  TContratante = class(TPersistent)
  private
    FEMail: string;
    FResponsavelPeloPagamento: Boolean;
    FNomeOuRazaoSocial: string;
    FCpfOuCnpj: string;
    FTelefones: TTelefones;
    FEndereco: TEndereco;
    FRNTRC: string;
    procedure setCpfOuCnpj(const Value: string);
  public
    constructor Create(AOwner: TOperacaoTransporte);
    destructor Destroy; override;
    procedure Clear;
  published
    property CpfOuCnpj: string read FCpfOuCnpj write setCpfOuCnpj;
    property RNTRC: string read FRNTRC write FRNTRC;
    property EMail: string read FEMail write FEMail;
    property Endereco: TEndereco read FEndereco write FEndereco;
    property NomeOuRazaoSocial: string read FNomeOuRazaoSocial write FNomeOuRazaoSocial;
    property ResponsavelPeloPagamento: Boolean read FResponsavelPeloPagamento write FResponsavelPeloPagamento;
    property Telefones: TTelefones read FTelefones write FTelefones;
  end;

  TSubcontratante = class(TPersistent)
  private
    FEMail: string;
    FResponsavelPeloPagamento: Boolean;
    FNomeOuRazaoSocial: string;
    FCpfOuCnpj: string;
    FTelefones: TTelefones;
    FEndereco: TEndereco;
    procedure setCpfOuCnpj(const Value: string);
  public
    constructor Create(AOwner: TOperacaoTransporte);
    destructor Destroy; override;
    procedure Clear;
  published
    property CpfOuCnpj: string read FCpfOuCnpj write setCpfOuCnpj;
    property EMail: string read FEMail write FEMail;
    property Endereco: TEndereco read FEndereco write FEndereco;
    property NomeOuRazaoSocial: string read FNomeOuRazaoSocial write FNomeOuRazaoSocial;
    property ResponsavelPeloPagamento: Boolean read FResponsavelPeloPagamento write FResponsavelPeloPagamento;
    property Telefones: TTelefones read FTelefones write FTelefones;
  end;

  TDestinatario = class(TPersistent)
  private
    FEMail: string;
    FResponsavelPeloPagamento: Boolean;
    FNomeOuRazaoSocial: string;
    FCpfOuCnpj: string;
    FTelefones: TTelefones;
    FEndereco: TEndereco;
    procedure setCpfOuCnpj(const Value: string);
  public
    constructor Create(AOwner: TOperacaoTransporte);
    destructor Destroy; override;
    procedure Clear;
  published
    property CpfOuCnpj: string read FCpfOuCnpj write setCpfOuCnpj;
    property EMail: string read FEMail write FEMail;
    property Endereco: TEndereco read FEndereco write FEndereco;
    property NomeOuRazaoSocial: string read FNomeOuRazaoSocial write FNomeOuRazaoSocial;
    property ResponsavelPeloPagamento: Boolean read FResponsavelPeloPagamento write FResponsavelPeloPagamento;
    property Telefones: TTelefones read FTelefones write FTelefones;
  end;

  TImpostos = class(TPersistent)
  private
    FOutrosImpostos: currency;
    FSestSenat: currency;
    FISSQN: currency;
    FDescricaoOutrosImpostos: string;
    FINSS: currency;
    FIRRF: currency;
  public
    destructor Destroy; override;
    procedure Clear;
  published
    property DescricaoOutrosImpostos: string read FDescricaoOutrosImpostos write FDescricaoOutrosImpostos;
    property INSS: currency read FINSS write FINSS;
    property IRRF: currency read FIRRF write FIRRF;
    property ISSQN: currency read FISSQN write FISSQN;
    property OutrosImpostos: currency read FOutrosImpostos write FOutrosImpostos;
    property SestSenat: currency read FSestSenat write FSestSenat;
  end;

  TMotorista = class(TPersistent)
  private
    FOwner: TComponent;
    FDataNascimento: TDate;
    FCPF: string;
    FCNH: string;
    FTelefones: TTelefones;
    FNomeDeSolteiraDaMae: string;
    FNome: string;
    FEndereco: TEndereco;
    procedure setCPF(const Value: string);
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;

    property Owner: TComponent read FOwner;

    procedure Limpar;
  published
    property CNH: string read FCNH write FCNH;
    property CPF: string read FCPF write setCPF;
    property DataNascimento: TDate read FDataNascimento write FDataNascimento;
    property Endereco: TEndereco read FEndereco write FEndereco;
    property Telefones: TTelefones read FTelefones write FTelefones;
    property Nome: string read FNome write FNome;
    property NomeDeSolteiraDaMae: string read FNomeDeSolteiraDaMae write FNomeDeSolteiraDaMae;
  end;

  TProprietario = class(TPersistent)
  private
    FOwner: TComponent;
    FTelefones: TTelefones;
    FNome: string;
    FEndereco: TEndereco;
    FCNPJ: string;
    FRazaoSocial: string;
    FRNTRC: string;
    FTACouEquiparado: Boolean;
    FDataValidadeRNTRC: TDateTime;
    FTipo: TpciotTipoProprietario;
    FRNTRCAtivo: Boolean;
    procedure setCNPJ(const Value: string);
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;

    property Owner: TComponent read FOwner;
    procedure Limpar;
  published
    property RNTRC: string read FRNTRC write FRNTRC;
    property CNPJ: string read FCNPJ write setCNPJ;
    property Endereco: TEndereco read FEndereco write FEndereco;
    property Telefones: TTelefones read FTelefones write FTelefones;
    property RazaoSocial: string read FRazaoSocial write FRazaoSocial;

    property Tipo: TpciotTipoProprietario read FTipo write FTipo;
    property TACouEquiparado: Boolean read FTACouEquiparado write FTACouEquiparado;
    property DataValidadeRNTRC: TDateTime read FDataValidadeRNTRC write FDataValidadeRNTRC;
    property RNTRCAtivo: Boolean read FRNTRCAtivo write FRNTRCAtivo;
  end;

  TOptMotorista = class(TPersistent)
  private
    FCpfOuCnpj: string;
    FCelular: TTelefone;
    FCNH: string;
    procedure setCpfOuCnpj(const Value: string);
  public
    constructor Create;
    destructor Destroy;
    procedure Clear;
  published
    property CpfOuCnpj: string read FCpfOuCnpj write setCpfOuCnpj;
    property Celular: TTelefone read FCelular write FCelular;
    property CNH: string read FCNH write FCNH;
  end;

  TEndereco = class(TPersistent)
  private
    FRua    : String;
    FNumero     : String;
    FComplemento    : String;
    FBairro : String;
    FCodigoMunicipio    : Integer;
    FxMunicipio    : String;
    FCEP     : string;
    procedure setCEP(const Value: string);
  public
    procedure Clear;
  published
    property Rua: String    read FRua    write FRua;
    property Numero: String     read FNumero     write FNumero;
    property Complemento: String    read FComplemento    write FComplemento;
    property Bairro: String read FBairro write FBairro;
    property CodigoMunicipio: Integer   read FCodigoMunicipio    write FCodigoMunicipio;
    property xMunicipio: String    read FxMunicipio    write FxMunicipio;
    property CEP: string    read FCEP     write setCEP;
  end;

  TTelefone = class(TPersistent)
  private
    FDDD: integer;
    FNumero: integer;
  public
    procedure Clear;
  published
    property DDD: integer read FDDD write FDDD;
    property Numero: integer read FNumero write FNumero;
  end;

  TTelefones = class(TPersistent)
  private
    FFixo: TTelefone;
    FFax: TTelefone;
    FCelular: TTelefone;
  public
    constructor Create;
    destructor Destroy;
    procedure Clear;
  published
    property Celular: TTelefone read FCelular write FCelular;
    property Fax: TTelefone read FFax write FFax;
    property Fixo: TTelefone read FFixo write FFixo;
  end;

  TCancelamento = class(TPersistent)
  private
    FMotivo: string;
    FProtocolo: string;
    FData: TDateTime;
    FIdPagamentoCliente: string;
  public
    procedure Clear;
  published
    property Motivo: string read FMotivo write FMotivo;
    property Data: TDateTime read FData write FData;
    property Protocolo: string read FProtocolo write FProtocolo;
    property IdPagamentoCliente: string read FIdPagamentoCliente write FIdPagamentoCliente;
  end;


////////////////////////////////////////////////////////////////////////////////

  TPagamentoCollection = class(TCollection)
  private
    function GetItem(Index: Integer): TPagamentoCollectionItem;
    procedure SetItem(Index: Integer; Value: TPagamentoCollectionItem);
  public
    constructor Create(AOwner: TPersistent);
    function Add: TPagamentoCollectionItem;
    property Items[Index: Integer]: TPagamentoCollectionItem read GetItem write SetItem; default;
  end;

  TPagamentoCollectionItem = class(TCollectionItem)
  private
    FValor: currency;
    FInformacaoAdicional: string;
    FIdPagamentoCliente: string;
    FDataDeLiberacao: TDate;
    FTipoPagamento: TpciotTipoPagamento;
    FInformacoesBancarias: TInformacoesBancarias;
    FDocumento: string;
    FCategoria: TpciotTipoCategoriaPagamento;
  public
    constructor Create; reintroduce;
    destructor Destroy; override;
  published
    property Categoria: TpciotTipoCategoriaPagamento read FCategoria write FCategoria;
    property DataDeLiberacao: TDate read FDataDeLiberacao write FDataDeLiberacao;
    property Documento: string read FDocumento write FDocumento;
    property IdPagamentoCliente: string read FIdPagamentoCliente write FIdPagamentoCliente;
    property InformacaoAdicional: string read FInformacaoAdicional write FInformacaoAdicional;
    property InformacoesBancarias: TInformacoesBancarias read FInformacoesBancarias write FInformacoesBancarias;
    property TipoPagamento: TpciotTipoPagamento read FTipoPagamento write FTipoPagamento;
    property Valor: currency read FValor write FValor;
  end;

////////////////////////////////////////////////////////////////////////////////

  TViagemCollection = class(TCollection)
  private
    FOT: TOperacaoTransporte;
    function GetItem(Index: Integer): TViagemCollectionItem;
    procedure SetItem(Index: Integer; Value: TViagemCollectionItem);
  public
    constructor Create(AOwner: TOperacaoTransporte);
    function Add: TViagemCollectionItem;
    property Items[Index: Integer]: TViagemCollectionItem read GetItem write SetItem; default;
  end;

  TViagemCollectionItem = class(TCollectionItem)
  private
    FValores: TValoresOT;
    FDocumentoViagem: string;
    FCodigoMunicipioDestino: integer;
    FNotasFiscais: TNotaFiscalCollection;
    FCodigoMunicipioOrigem: integer;
    FPagamentos: TPagamentoCollection;

    procedure setNotasFiscais(const Value: TNotaFiscalCollection);
    procedure setPagamentos(const Value: TPagamentoCollection);
  public
    constructor Create;
    destructor Destroy; override;
  published
    property CodigoMunicipioDestino: integer read FCodigoMunicipioDestino write FCodigoMunicipioDestino;
    property CodigoMunicipioOrigem: integer read FCodigoMunicipioOrigem write FCodigoMunicipioOrigem;
    property DocumentoViagem: string read FDocumentoViagem write FDocumentoViagem;
    property NotasFiscais: TNotaFiscalCollection read FNotasFiscais write setNotasFiscais;
    property Valores: TValoresOT read FValores write FValores;
    property Pagamentos: TPagamentoCollection read FPagamentos write setPagamentos;
  end;

  TValoresOT = class(TPersistent)
  private
    FJustificativaOutrosDebitos: string;
    FOutrosCreditos: currency;
    FSeguro: currency;
    FTotalDeAdiantamento: currency;
    FTotalOperacao: currency;
    FOutrosDebitos: currency;
    FPedagio: currency;
    FTotalViagem: currency;
    FCombustivel: currency;
    FJustificativaOutrosCreditos: string;
    FTotalDeQuitacao: currency;
  public
    constructor Create(AOwner: TViagemCollectionItem);
    destructor Destroy; override;
  published
    property Combustivel: currency read FCombustivel write FCombustivel;
    property OutrosCreditos: currency read FOutrosCreditos write FOutrosCreditos;
    property OutrosDebitos: currency read FOutrosDebitos write FOutrosDebitos;
    property Pedagio: currency read FPedagio write FPedagio;
    property Seguro: currency read FSeguro write FSeguro;
    property TotalDeAdiantamento: currency read FTotalDeAdiantamento write FTotalDeAdiantamento;
    property TotalDeQuitacao: currency read FTotalDeQuitacao write FTotalDeQuitacao;
    property TotalOperacao: currency read FTotalOperacao write FTotalOperacao;
    property TotalViagem: currency read FTotalViagem write FTotalViagem;
    property JustificativaOutrosCreditos: string read FJustificativaOutrosCreditos write FJustificativaOutrosCreditos;
    property JustificativaOutrosDebitos: string read FJustificativaOutrosDebitos write FJustificativaOutrosDebitos;
  end;

  TVeiculoCollection = class(TCollection)
  private
    function GetItem(Index: Integer): TVeiculoCollectionItem;
    procedure SetItem(Index: Integer; Value: TVeiculoCollectionItem);
  public
    constructor Create(AOwner: TOperacaoTransporte);
    function Add: TVeiculoCollectionItem;
    property Items[Index: Integer]: TVeiculoCollectionItem read GetItem write SetItem; default;
  end;

  TVeiculoCollectionItem = class(TCollectionItem)
  private
    FPlaca: String;
    procedure SetPlaca(const Value: String);
  public
    constructor Create;
    destructor Destroy; override;
  published
    property Placa: String read FPlaca  write SetPlaca;
  end;

  TNotaFiscalCollection = class(TCollection)
  private
    function GetItem(Index: Integer): TNotaFiscalCollectionItem;
    procedure SetItem(Index: Integer; Value: TNotaFiscalCollectionItem);
  public
    constructor Create(AOwner: TViagemCollectionItem);
    function Add: TNotaFiscalCollectionItem;
    property Items[Index: Integer]: TNotaFiscalCollectionItem read GetItem write SetItem; default;
  end;

  TNotaFiscalCollectionItem = class(TCollectionItem)
  private
    FCodigoNCMNaturezaCarga: integer;
    FValorDoFretePorUnidadeDeMercadoria: currency;
    FQuantidadeDaMercadoriaNoEmbarque: double;
    FSerie: string;
    FNumero: string;
    FValorTotal: currency;
    FUnidadeDeMedidaDaMercadoria: TpciotUnidadeDeMedidaDaMercadoria;
    FDescricaoDaMercadoria: string;
    FValorDaMercadoriaPorUnidade: currency;
    FTipoDeCalculo: TpciotViagemTipoDeCalculo;
    FData: TDate;
    FToleranciaDePerdaDeMercadoria: TToleranciaDePerdaDeMercadoria;
    FDiferencaDeFrete: TDiferencaDeFrete;
  public
    constructor Create; reintroduce;
    destructor Destroy; override;
  published
    property CodigoNCMNaturezaCarga: integer read FCodigoNCMNaturezaCarga write FCodigoNCMNaturezaCarga;
    property Data: TDate read FData write FData;
    property DescricaoDaMercadoria: string read FDescricaoDaMercadoria write FDescricaoDaMercadoria;
    property Numero: string read FNumero write FNumero;
    property QuantidadeDaMercadoriaNoEmbarque: double read FQuantidadeDaMercadoriaNoEmbarque write FQuantidadeDaMercadoriaNoEmbarque;
    property Serie: string read FSerie write FSerie;
    property TipoDeCalculo: TpciotViagemTipoDeCalculo read FTipoDeCalculo write FTipoDeCalculo;
    property ToleranciaDePerdaDeMercadoria: TToleranciaDePerdaDeMercadoria read FToleranciaDePerdaDeMercadoria write FToleranciaDePerdaDeMercadoria;
    property DiferencaDeFrete: TDiferencaDeFrete read FDiferencaDeFrete write FDiferencaDeFrete;
    property UnidadeDeMedidaDaMercadoria: TpciotUnidadeDeMedidaDaMercadoria read FUnidadeDeMedidaDaMercadoria write FUnidadeDeMedidaDaMercadoria;
    property ValorDaMercadoriaPorUnidade: currency read FValorDaMercadoriaPorUnidade write FValorDaMercadoriaPorUnidade;
    property ValorDoFretePorUnidadeDeMercadoria: currency read FValorDoFretePorUnidadeDeMercadoria write FValorDoFretePorUnidadeDeMercadoria;
    property ValorTotal: currency read FValorTotal write FValorTotal;
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

const
  CMUN_EXTERIOR : Integer = 9999999;
  XMUN_EXTERIOR : String  = 'EXTERIOR';
  UF_EXTERIOR   : String  = 'EX';

implementation

{ TCIOT }

constructor TOperacaoTransporte.Create(Collection2: TCollection);
begin
  inherited Create(Collection2);

  FOwner := TOperacoesTransporte(Collection).Owner;
  FCodigoNCMNaturezaCarga := 0;
  FPesoCarga := 0;
  FTipoViagem := indefinido;
  FEmissaoGratuita := True;
  FIntegrador := '';
  FFilialCNPJ := '';
  FCodigoIdentificacaoOperacaoPrincipal := '';
  FObservacoesAoTransportador := '';
  FMatrizCNPJ := '';

  FIdOperacaoCliente := '';
  FObservacoesAoCredenciado := '';

  FContratante := TContratante.Create(Self);
  FMotorista := TOptMotorista.Create;
  FDestinatario := TDestinatario.Create(Self);
  FContratado := TContratado.Create;
  FConsignatario := TConsignatario.Create(Self);
  FPagamentos := TPagamentoCollection.Create(Self);
  FVeiculos := TVeiculoCollection.Create(Self);
  FImpostos := TImpostos.Create;
  FViagens := TViagemCollection.Create(Self);
  FSubcontratante := TSubcontratante.Create(Self);
  FCancelamento := TCancelamento.Create;
end;

destructor TOperacaoTransporte.Destroy;
begin
  FContratante.Free;
  FMotorista.Free;
  FDestinatario.Free;
  FContratado.Free;
  FConsignatario.Free;
  FPagamentos.Free;
  FVeiculos.Free;
  FImpostos.Free;
  FViagens.Free;
  FSubcontratante.Free;
  FCancelamento.Free;

  inherited Destroy;
end;

function TOperacaoTransporte.getVersao: integer;
begin
  result := 3;
end;

procedure TOperacaoTransporte.Limpar;
begin
  CodigoIdentificacaoOperacaoPrincipal := '';
  CodigoNCMNaturezaCarga := 0;
  Consignatario.Clear;
  Contratado.Clear;
  Contratante.Clear;
  Destinatario.Clear;
  FilialCNPJ := '';
  IdOperacaoCliente := '';
  Integrador := '';
  Impostos.Clear;
  MatrizCNPJ := '';
  Motorista.Clear;
  Pagamentos.Clear;
  PesoCarga := 0;
  Subcontratante.Clear;
  TipoViagem := Indefinido;
  Veiculos.Clear;
  Viagens.Clear;
  EmissaoGratuita := True;
  ObservacoesAoTransportador := '';
  ObservacoesAoCredenciado := '';
  Cancelamento.Clear;
  NumeroCIOT := '';
  Viagens.Clear;
end;

procedure TOperacaoTransporte.setFilialCNPJ(const Value: string);
begin
  FFilialCNPJ := SomenteNumeros(Value);
end;

procedure TOperacaoTransporte.setMatrizCNPJ(const Value: string);
begin
  FMatrizCNPJ := SomenteNumeros(Value);
end;

procedure TOperacaoTransporte.setVeiculos(const Value: TVeiculoCollection);
begin
  FVeiculos := Value;
end;

procedure TOperacaoTransporte.setViagens(const Value: TViagemCollection);
begin
  FViagens := Value;
end;

{ TConsignatario }

constructor TConsignatario.Create(AOwner: TOperacaoTransporte);
begin
  inherited Create;
  FEndereco := TEndereco.Create;
  FTelefones := TTelefones.Create;
end;

destructor TConsignatario.Destroy;
begin
  inherited;
  FEndereco.Free;
  FTelefones.Free;
end;

procedure TConsignatario.Clear;
begin
  CpfOuCnpj := '';
  EMail := '';
  Endereco.Clear;
  NomeOuRazaoSocial := '';
  ResponsavelPeloPagamento := False;
  Telefones.Clear;
end;

procedure TConsignatario.SetCpfOuCnpj(const Value: string);
begin
  FCpfOuCnpj := SomenteNumeros(Value);
end;

{ TPagamentoCollection }

function TPagamentoCollection.Add: TPagamentoCollectionItem;
begin
  Result := TPagamentoCollectionItem(inherited Add);
  Result.create;
end;

constructor TPagamentoCollection.Create(AOwner: TPersistent);
begin
  inherited Create(TPagamentoCollectionItem);
end;

function TPagamentoCollection.GetItem(Index: Integer): TPagamentoCollectionItem;
begin
  Result := TPagamentoCollectionItem(inherited GetItem(Index));
end;

procedure TPagamentoCollection.SetItem(Index: Integer;
  Value: TPagamentoCollectionItem);
begin
  inherited SetItem(Index, Value);
end;

{ TPagamentoCollectionItem }

constructor TPagamentoCollectionItem.Create;
begin
  FInformacoesBancarias := TInformacoesBancarias.Create;
end;

destructor TPagamentoCollectionItem.Destroy;
begin
  FInformacoesBancarias.Free;
  inherited;
end;

{ TViagemCollection }

function TViagemCollection.Add: TViagemCollectionItem;
begin
  Result := TViagemCollectionItem(inherited Add);
  Result.Create;
end;

constructor TViagemCollection.Create(AOwner: TOperacaoTransporte);
begin
  FOT := AOwner;

  inherited Create(TViagemCollectionItem);
end;

function TViagemCollection.GetItem(Index: Integer): TViagemCollectionItem;
begin
  Result := TViagemCollectionItem(inherited GetItem(Index));
end;

procedure TViagemCollection.SetItem(Index: Integer;
  Value: TViagemCollectionItem);
begin
  inherited SetItem(Index, Value);
end;

{ TViagemCollectionItem }

constructor TViagemCollectionItem.Create;
begin
  FValores := TValoresOT.Create(Self);
  FNotasFiscais  := TNotaFiscalCollection.Create(Self);
  FPagamentos := TPagamentoCollection.Create(Self);
end;

destructor TViagemCollectionItem.Destroy;
begin
  FNotasFiscais.Free;
  FValores.Free;
  FPagamentos.Free;
  inherited;
end;

procedure TViagemCollectionItem.setNotasFiscais(const Value: TNotaFiscalCollection);
begin
  FNotasFiscais := Value;
end;


procedure TViagemCollectionItem.setPagamentos(const Value: TPagamentoCollection);
begin
  FPagamentos := Value;
end;

{ TinfUnidTranspNFCollection }

function TVeiculoCollection.Add: TVeiculoCollectionItem;
begin
  Result := TVeiculoCollectionItem(inherited Add);
  Result.create;
end;

constructor TVeiculoCollection.Create(AOwner: TOperacaoTransporte);
begin
  inherited Create(TVeiculoCollectionItem);
end;

function TVeiculoCollection.GetItem(
  Index: Integer): TVeiculoCollectionItem;
begin
  Result := TVeiculoCollectionItem(inherited GetItem(Index));
end;

procedure TVeiculoCollection.SetItem(Index: Integer;
  Value: TVeiculoCollectionItem);
begin
  inherited Create(TVeiculoCollectionItem);
end;

{ TlacUnidTranspCollection }

function TNotaFiscalCollection.Add: TNotaFiscalCollectionItem;
begin
  Result := TNotaFiscalCollectionItem(inherited Add);
  Result.create;
end;

constructor TNotaFiscalCollection.Create(AOwner: TViagemCollectionItem);
begin
  inherited Create(TNotaFiscalCollectionItem);
end;

function TNotaFiscalCollection.GetItem(Index: Integer): TNotaFiscalCollectionItem;
begin
  Result := TNotaFiscalCollectionItem(inherited GetItem(Index));
end;

procedure TNotaFiscalCollection.SetItem(Index: Integer; Value: TNotaFiscalCollectionItem);
begin
  inherited SetItem(Index, Value);
end;

{ TlacUnidTranspCollectionItem }

constructor TNotaFiscalCollectionItem.Create;
begin
  FToleranciaDePerdaDeMercadoria := TToleranciaDePerdaDeMercadoria.Create;
  FDiferencaDeFrete := TDiferencaDeFrete.Create;

  FCodigoNCMNaturezaCarga := 0001;
  FValorDoFretePorUnidadeDeMercadoria := 0;
  FQuantidadeDaMercadoriaNoEmbarque := 0;
  FSerie := '';
  FNumero := '';
  FValorTotal := 0;
  FDescricaoDaMercadoria := '';
  FValorDaMercadoriaPorUnidade := 0;
end;

destructor TNotaFiscalCollectionItem.Destroy;
begin
  FToleranciaDePerdaDeMercadoria.Free;
  FDiferencaDeFrete.Free;
  inherited;
end;

{ TContratado }

procedure TContratado.Clear;
begin
  CpfOuCnpj := '';
  RNTRC := '';
end;

destructor TContratado.Destroy;
begin

  inherited;
end;

procedure TContratado.setCpfOuCnpj(const Value: string);
begin
  FCpfOuCnpj := SomenteNumeros(Value);
end;

{ TImpostos }

procedure TImpostos.Clear;
begin
  DescricaoOutrosImpostos := '';
  INSS := 0;
  IRRF := 0;
  ISSQN := 0;
  OutrosImpostos := 0;
  SestSenat := 0;
end;

destructor TImpostos.Destroy;
begin

  inherited;
end;

{ TInformacoesBancarias }

destructor TInformacoesBancarias.Destroy;
begin

  inherited;
end;

{ TSubcontratante }

procedure TSubcontratante.Clear;
begin
  CpfOuCnpj := '';
  EMail := '';
  Endereco.Clear;
  NomeOuRazaoSocial := '';
  ResponsavelPeloPagamento := False;
  Telefones.Clear;
end;

constructor TSubcontratante.Create(AOwner: TOperacaoTransporte);
begin
  FEndereco := TEndereco.Create;
  FTelefones := TTelefones.Create;
end;

destructor TSubcontratante.Destroy;
begin
  FEndereco.Free;
  FTelefones.Free;
  inherited;
end;

procedure TSubcontratante.setCpfOuCnpj(const Value: string);
begin
  FCpfOuCnpj := SomenteNumeros(Value);
end;

{ TToleranciaDePerdaDeMercadoria }

destructor TToleranciaDePerdaDeMercadoria.Destroy;
begin

  inherited;
end;

{ TDiferencaDeFrete }

constructor TDiferencaDeFrete.Create;
begin
  Tolerancia := TDiferencaFreteMargem.Create;
  MargemGanho := TDiferencaFreteMargem.Create;
  MargemPerda := TDiferencaFreteMargem.Create;
end;

destructor TDiferencaDeFrete.Destroy;
begin
  Tolerancia.Free;
  MargemGanho.Free;
  MargemPerda.Free;
  inherited;
end;


{ TContratante }

procedure TContratante.Clear;
begin
  CpfOuCnpj := '';
  RNTRC := '';
  EMail := '';
  Endereco.Clear;
  NomeOuRazaoSocial := '';
  ResponsavelPeloPagamento := False;
  Telefones.Clear;
end;

constructor TContratante.Create(AOwner: TOperacaoTransporte);
begin
  FEndereco := TEndereco.Create;
  FTelefones := TTelefones.Create;
end;

destructor TContratante.Destroy;
begin
  FEndereco.Free;
  FTelefones.Free;
  inherited;
end;

procedure TContratante.setCpfOuCnpj(const Value: string);
begin
  FCpfOuCnpj := SomenteNumeros(Value);
end;

{ TDestinatario }

procedure TDestinatario.Clear;
begin
  CpfOuCnpj := '';
  EMail := '';
  Endereco.Clear;
  NomeOuRazaoSocial := '';
  ResponsavelPeloPagamento := False;
  Telefones.Clear;
end;

constructor TDestinatario.Create(AOwner: TOperacaoTransporte);
begin
  FEndereco := TEndereco.Create;
  FTelefones := TTelefones.Create;
end;

destructor TDestinatario.Destroy;
begin
  FEndereco.Free;
  FTelefones.Free;
  inherited;
end;

procedure TDestinatario.setCpfOuCnpj(const Value: string);
begin
  FCpfOuCnpj := SomenteNumeros(Value);
end;

{ TValoresOT }

constructor TValoresOT.Create(AOwner: TViagemCollectionItem);
begin

end;

destructor TValoresOT.Destroy;
begin

  inherited;
end;

{ TVeiculoCollectionItem }

constructor TVeiculoCollectionItem.Create;
begin

end;

destructor TVeiculoCollectionItem.Destroy;
begin

  inherited;
end;

procedure TVeiculoCollectionItem.SetPlaca(const Value: String);
begin
  FPlaca := RemoveStrings(Value, ['-', '|', '/', ' ']);
end;

{ TVeiculo }

constructor TVeiculo.Create(AOwner: TComponent);
begin
  FOwner := AOwner;
end;

destructor TVeiculo.Destroy;
begin

  inherited;
end;

procedure TVeiculo.Limpar;
begin

end;

procedure TVeiculo.setPlaca(const Value: string);
begin
  FPlaca := RemoveStrings(Value, [' ', '-', '/', '\', '*', '_']);
end;

{ TIntegradora }

constructor TIntegradora.Create;
begin
  FTecnologia := IeFrete;
end;

{ TMotorista }

constructor TMotorista.Create(AOwner: TComponent);
begin
  FOwner := AOwner;
  FTelefones := TTelefones.Create;
  FEndereco := TEndereco.Create;
end;

destructor TMotorista.Destroy;
begin
  FTelefones.Free;
  FEndereco.Free;
  inherited;
end;

procedure TMotorista.Limpar;
begin

end;

procedure TMotorista.setCPF(const Value: string);
begin
  FCPF := SomenteNumeros(Value);
end;

{ TProprietario }

constructor TProprietario.Create(AOwner: TComponent);
begin
  FOwner := AOwner;
  FTelefones := TTelefones.Create;
  FEndereco := TEndereco.Create;
end;

destructor TProprietario.Destroy;
begin
  FTelefones.Free;
  FEndereco.Free;

  inherited;
end;

procedure TProprietario.Limpar;
begin

end;

procedure TProprietario.setCNPJ(const Value: string);
begin
  FCNPJ := SomenteNumeros(Value);
end;

{ TTelefones }

procedure TTelefones.Clear;
begin
  FCelular.Clear;
  FFax.Clear;
  FFixo.Clear;
end;

constructor TTelefones.Create;
begin
  FCelular := TTelefone.Create;
  FFixo := TTelefone.Create;
  FFax := TTelefone.Create;
end;

destructor TTelefones.Destroy;
begin
  FCelular.Free;
  FFixo.Free;
  FFax.Free;
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
  if FException is Exception then
    Application.ShowException(FException)
  else
    SysUtils.ShowException(FException, nil);
end;

procedure TSendMailThread.Execute;
begin
  inherited;

end;

procedure TSendMailThread.HandleException;
begin

end;

{ TOptMotorista }

procedure TOptMotorista.Clear;
begin
  CpfOuCnpj := '';
  Celular.Clear;
  CNH := '';
end;

constructor TOptMotorista.Create;
begin
  FCelular := TTelefone.Create;
end;

destructor TOptMotorista.Destroy;
begin
  FCelular.Free;
end;

procedure TOptMotorista.setCpfOuCnpj(const Value: string);
begin
  FCpfOuCnpj := SomenteNumeros(Value);
end;

{ TEndereco }

procedure TEndereco.Clear;
begin
  Rua := '';
  Numero := '';
  Complemento := '';
  Bairro := '';
  CodigoMunicipio := 0;
  xMunicipio := '';
  CEP := '';
end;

procedure TEndereco.setCEP(const Value: string);
begin
  FCEP := SomenteNumeros(Value);
end;

{ TTelefone }

procedure TTelefone.Clear;
begin
  DDD := 0;
  Numero := 0;
end;

{ TCancelamento }

procedure TCancelamento.Clear;
begin
  Motivo := '';
  Protocolo := '';
end;

{ TOperacoesTransporte }

function TOperacoesTransporte.Add: TOperacaoTransporte;
begin
  Result := TOperacaoTransporte(inherited Add);
end;

constructor TOperacoesTransporte.Create(AOwner: TPersistent; ItemClass: TCollectionItemClass);
begin
  inherited;

  FOwner := TComponent(AOwner);
end;

procedure TOperacoesTransporte.GerarCTe;
begin

end;

function TOperacoesTransporte.GetItem(Index: Integer): TOperacaoTransporte;
begin
  Result := TOperacaoTransporte(inherited Items[Index]);
end;

procedure TOperacoesTransporte.Imprimir;
begin

end;

function TOperacoesTransporte.Insert(Index: Integer): TOperacaoTransporte;
begin
  Result := TOperacaoTransporte(inherited Insert(Index));
end;

procedure TOperacoesTransporte.SetItem(Index: Integer; const Value: TOperacaoTransporte);
begin
  Items[Index].Assign(Value);
end;

end.

