
{$I ACBr.inc}

unit pciotVeiculoW;

interface

uses
  SysUtils, Classes, pcnConversao, pciotCIOT, ASCIOTUtil;


type
  TGeradorOpcoes = class;

  TVeiculoW = class(TPersistent)
  private
    FGerador: TGerador;
    FVeiculo: TVeiculo;
    FOperacao: TpciotOperacao;
    FOpcoes: TGeradorOpcoes;
  public
    constructor Create(AOwner: TVeiculo; AOperacao: TpciotOperacao = opObter);
    destructor Destroy; override;
    function GerarXML: boolean;
  published
    property Gerador: TGerador read FGerador write FGerador;
    property Veiculo: TVeiculo read FVeiculo write FVeiculo;
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

{ TVeiculoW }

uses ASCIOT;

constructor TVeiculoW.Create(AOwner: TVeiculo; AOperacao: TpciotOperacao);
begin
  FVeiculo := AOwner;
  FOperacao := AOperacao;

  FGerador := TGerador.Create;
  FGerador.FIgnorarTagNivel := '|?xml version|CTe xmlns|infCTe versao|obsCont|obsFisco|';
  FOpcoes := TGeradorOpcoes.Create;
  FOpcoes.FAjustarTagNro := True;
  FOpcoes.FNormatizarMunicipios := False;
  FOpcoes.FGerarTagAssinatura := taSomenteSeAssinada;
  FOpcoes.FValidarInscricoes := False;
  FOpcoes.FValidarListaServicos := False;
end;

destructor TVeiculoW.Destroy;
begin
  FGerador.Free;
  FOpcoes.Free;
  inherited Destroy;
end;

function TVeiculoW.GerarXML: boolean;
var
  chave: AnsiString;
  Gerar: boolean;
  xProtCTe : String;
begin
  Gerador.Opcoes.IdentarXML := True;
  Gerador.Opcoes.TagVaziaNoFormatoResumido := False;
  Gerador.ArquivoFormatoXML := '';

  case FOperacao of
    opObter:
      begin
        Gerador.wGrupo('ObterPorPlacaRequest ' + NAME_SPACE_EFRETE_VEICULOS_EFRETE);
        Gerador.wTexto('<Integrador ' + NAME_SPACE_EFRETE_OBJECTS + '>' + TAmsCIOT( FVeiculo.Owner ).Configuracoes.Integradora.Identificacao + '</Integrador>');
        Gerador.wTexto('<Versao ' + NAME_SPACE_EFRETE_OBJECTS + '>1</Versao>');
        Gerador.wCampo(tcStr, '', 'Placa', 001, 007, 1, FVeiculo.Placa, '');
        Gerador.wCampo(tcStr, '', 'RNTRC', 001, 008, 1, FVeiculo.RNTRC, '');
        Gerador.wGrupo('/ObterPorPlacaRequest');
      end;
    opAdicionar:
      begin
        Gerador.wGrupo('GravarRequest ' + NAME_SPACE_EFRETE_VEICULOS_EFRETE, 'VP01');
        Gerador.wTexto('<Integrador ' + NAME_SPACE_EFRETE_OBJECTS + '>' + TAmsCIOT( FVeiculo.Owner ).Configuracoes.Integradora.Identificacao + '</Integrador>');
        Gerador.wTexto('<Versao ' + NAME_SPACE_EFRETE_OBJECTS + '>1</Versao>');
        Gerador.wGrupo('Veiculo', 'VP04');
        Gerador.wCampo(tcInt, 'VP05', 'AnoFabricacao', 001, 004, 1, FVeiculo.AnoFabricacao, 'De 1930 até o ano atual.');
        Gerador.wCampo(tcInt, 'VP06', 'AnoModelo', 001, 004, 1, FVeiculo.AnoModelo, 'De 1930 até o ano atual.');
        Gerador.wCampo(tcInt, 'VP07', 'CapacidadeKg', 001, 001, 1, FVeiculo.CapacidadeKg, 'Capacidade do veículo em Kg.');
        Gerador.wCampo(tcInt, 'VP08', 'CapacidadeM3', 001, 001, 1, FVeiculo.CapacidadeM3, 'Capacidade do veículo em M3.');
        Gerador.wCampo(tcStr, 'VP09', 'Chassi', 001, 001, 1, FVeiculo.Chassi, 'Chassi do veículo.');
        Gerador.wCampo(tcStr, 'VP10', 'CodigoMunicipio', 001, 007, 1, FVeiculo.CodigoMunicipio, 'Código do Município segundo IBGE.');
        Gerador.wCampo(tcStr, 'VP11', 'Cor', 001, 001, 1, FVeiculo.Cor, 'Cor do veículo.');
        Gerador.wCampo(tcStr, 'VP12', 'Marca', 001, 001, 1, FVeiculo.Marca, 'Marca do veículo.');
        Gerador.wCampo(tcStr, 'VP13', 'Modelo', 001, 001, 1, FVeiculo.Modelo, 'Modelo do veículo.');
        Gerador.wCampo(tcInt, 'VP14', 'NumeroDeEixos', 001, 002, 1, FVeiculo.NumeroDeEixos, 'Numero de eixos do veículo.');
        Gerador.wCampo(tcStr, 'VP15', 'Placa', 001, 007, 7, FVeiculo.Placa, 'Exemplo: AAA1234.');
        Gerador.wCampo(tcStr, 'VP16', 'RNTRC', 001, 008, 1, FVeiculo.RNTRC, 'RNTRC do veículo.');
        Gerador.wCampo(tcStr, 'VP17', 'Renavam', 001, 001, 1, FVeiculo.Renavam, 'RENAVAM do veículo.');
        Gerador.wCampo(tcInt, 'VP18', 'Tara', 001, 08, 1, FVeiculo.Tara, 'Peso do veículo.');
        Gerador.wCampo(tcStr, 'VP19', 'TipoCarroceria', 001, 001, 1, TpCarroceriaToStrTxt(FVeiculo.TipoCarroceria), 'Restrito aos itens da enum: -NaoAplicavel -Aberta -FechadaOuBau -Graneleira -PortaContainer -Sider');
        Gerador.wCampo(tcStr, 'VP20', 'TipoRodado', 001, 001, 1, TpRodadoToStrTxt(FVeiculo.TipoRodado), 'Restrito aos itens da enum: -NaoAplicavel -Truck -Toco');
        Gerador.wGrupo('/Veiculo');
        Gerador.wGrupo('/GravarRequest');
      end;
  end;

  Result := (Gerador.ListaDeAlertas.Count = 0);
end;

end.

