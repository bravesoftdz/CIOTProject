
{$I ACBr.inc}

unit pciotMotoristaW;

interface

uses
  SysUtils, Classes, pcnAuxiliar, pcnConversao, pciotCIOT, ASCIOTUtil;


type

  TGeradorOpcoes = class;

  TMotoristaW = class(TPersistent)
  private
    FGerador: TGerador;
    FMotorista: TMotorista;
    FOperacao: TpciotOperacao;
    FOpcoes: TGeradorOpcoes;
  public
    constructor Create(AOwner: TMotorista; AOperacao: TpciotOperacao = opObter);
    destructor Destroy; override;
    function GerarXML: boolean;
  published
    property Gerador: TGerador read FGerador write FGerador;
    property Motorista: TMotorista read FMotorista write FMotorista;
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

{ TMotoristaW }

uses ASCIOT;

constructor TMotoristaW.Create(AOwner: TMotorista; AOperacao: TpciotOperacao);
begin
  FMotorista := AOwner;
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

destructor TMotoristaW.Destroy;
begin
  FGerador.Free;
  FOpcoes.Free;
  inherited Destroy;
end;

function TMotoristaW.GerarXML: boolean;
var
  chave: AnsiString;
  Gerar: boolean;
  xProtCTe : String;
begin
  Gerador.ArquivoFormatoXML := '';
  Gerador.Opcoes.IdentarXML := True;

  case FOperacao of
    opObter:
      begin
        Gerador.wGrupo('ObterRequest ' + NAME_SPACE_EFRETE_MOTORISTAS_EFRETE);
        Gerador.wCampo(tcInt, 'CP2', 'CNH', 001, 007, 1, FMotorista.CNH, '');
        Gerador.wCampo(tcInt, 'CP03', 'CPF', 001, 008, 1, FMotorista.CPF, '');
        Gerador.wCampo(tcStr, 'CP04', 'Integrador', 001, 001, 1, TAmsCIOT( FMotorista.Owner ).Configuracoes.Integradora.Identificacao, '', ' ' + NAME_SPACE_EFRETE_OBJECTS);
        Gerador.wCampo(tcStr, 'CP06', 'Versao', 001, 001, 1, 2, '', ' ' + NAME_SPACE_EFRETE_OBJECTS);
        Gerador.wGrupo('/ObterRequest');
      end;
    opAdicionar:
      begin
        Gerador.wGrupo('GravarRequest ' + NAME_SPACE_EFRETE_MOTORISTAS_EFRETE, 'MP01');
        Gerador.wCampo(tcStr, 'MP02', 'Integrador', 001, 001, 1, TAmsCIOT( FMotorista.Owner ).Configuracoes.Integradora.Identificacao, '', ' ' + NAME_SPACE_EFRETE_OBJECTS);
        Gerador.wCampo(tcStr, 'MP04', 'Versao', 001, 001, 1, 1, '', ' ' + NAME_SPACE_EFRETE_OBJECTS);
        Gerador.wCampo(tcStr, 'MP05', 'CNH', 001, 001, 1, FMotorista.CNH, 'Número de CNH do motorista');
        Gerador.wCampo(tcStr, 'MP06', 'CPF', 001, 011, 1, FMotorista.CPF, 'CPF do motorista');
        Gerador.wCampo(tcDat, 'MP07', 'DataNascimento', 001, 001, 1, FMotorista.DataNascimento, '');

        with FMotorista do
        begin
          Gerador.wGrupo('Endereco', 'MP08');
          Gerador.wCampo(tcStr, 'MP09', 'Bairro', 001, 001, 1, Endereco.Bairro, '', ' ' + NAME_SPACE_EFRETE_OBJECTS);
          Gerador.wCampo(tcStr, 'MP10', 'CEP', 001, 009, 1, Copy(Endereco.CEP, 1, 5) + '-' + Copy(Endereco.CEP, 6, 3), '', ' ' + NAME_SPACE_EFRETE_OBJECTS);
          Gerador.wCampo(tcStr, 'MP11', 'CodigoMunicipio', 001, 007, 1, Endereco.CodigoMunicipio, '', ' ' + NAME_SPACE_EFRETE_OBJECTS);
          Gerador.wCampo(tcStr, 'MP12', 'Rua', 001, 001, 1, Endereco.Rua, '', ' ' + NAME_SPACE_EFRETE_OBJECTS);
          Gerador.wCampo(tcStr, 'MP13', 'Numero', 001, 001, 1, Endereco.Numero, '', ' ' + NAME_SPACE_EFRETE_OBJECTS);
          Gerador.wCampo(tcStr, 'MP14', 'Complemento', 001, 001, 1, Endereco.Complemento, '', ' ' + NAME_SPACE_EFRETE_OBJECTS);
          Gerador.wGrupo('/Endereco');
        end;

        Gerador.wCampo(tcStr, 'MP15', 'Nome', 001, 001, 1, FMotorista.Nome, '');
        Gerador.wCampo(tcStr, 'MP16', 'NomeDeSolteiraDaMae', 001, 001, 1, FMotorista.NomeDeSolteiraDaMae, 'Será utilizado para autenticação no caso de ligação do motorista para o serviço de 0800.');

        with FMotorista.Telefones do
        begin
          Gerador.wGrupo('Telefones', 'MP17');
          Gerador.wGrupo('Celular ' + NAME_SPACE_EFRETE_OBJECTS, 'MP18');
          Gerador.wCampo(tcInt, 'MP19', 'DDD', 001, 002, 1, Celular.DDD, '');
          Gerador.wCampo(tcInt, 'MP20', 'Numero', 001, 009, 1, Celular.Numero, '');
          Gerador.wGrupo('/Celular');

          Gerador.wGrupo('Fax ' + NAME_SPACE_EFRETE_OBJECTS, 'MP21');
          Gerador.wCampo(tcInt, 'MP22', 'DDD', 001, 002, 1, Fax.DDD, '');
          Gerador.wCampo(tcInt, 'MP23', 'Numero', 001, 009, 1, Fax.Numero, '');
          Gerador.wGrupo('/Fax');

          Gerador.wGrupo('Fixo ' + NAME_SPACE_EFRETE_OBJECTS, 'MP24');
          Gerador.wCampo(tcInt, 'MP25', 'DDD', 001, 002, 1, Fixo.DDD, '');
          Gerador.wCampo(tcInt, 'MP26', 'Numero', 001, 009, 1, Fixo.Numero, '');
          Gerador.wGrupo('/Fixo');

          Gerador.wGrupo('/Telefones');
        end;

        Gerador.wGrupo('/GravarRequest');
      end;
  end;

  Result := (Gerador.ListaDeAlertas.Count = 0);
end;

end.

