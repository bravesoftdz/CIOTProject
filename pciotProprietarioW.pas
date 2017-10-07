{$I ACBr.inc}

unit pciotProprietarioW;

interface

uses
  SysUtils, Classes, pcnConversao, pciotCIOT, ASCIOTUtil;


type
  TGeradorOpcoes = class;

  TProprietarioW = class(TPersistent)
  private
    FGerador: TGerador;
    FProprietario: TProprietario;
    FOperacao: TpciotOperacao;
    FOpcoes: TGeradorOpcoes;
  public
    constructor Create(AOwner: TProprietario; AOperacao: TpciotOperacao = opObter);
    destructor Destroy; override;
    function GerarXML: boolean;
  published
    property Gerador: TGerador read FGerador write FGerador;
    property Proprietario: TProprietario read FProprietario write FProprietario;
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


implementation

{ TProprietarioW }

uses ASCIOT;

constructor TProprietarioW.Create(AOwner: TProprietario; AOperacao: TpciotOperacao);
begin
  FProprietario := AOwner;
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

destructor TProprietarioW.Destroy;
begin
  FGerador.Free;
  FOpcoes.Free;
  inherited Destroy;
end;

function TProprietarioW.GerarXML: boolean;
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
        Gerador.wGrupo('ObterRequest ' + NAME_SPACE_EFRETE_PROPRIETARIOS_EFRETE);
        Gerador.wTexto('<Integrador ' + NAME_SPACE_EFRETE_OBJECTS + '>' + TAmsCIOT( FProprietario.Owner ).Configuracoes.Integradora.Identificacao + '</Integrador>');
        Gerador.wTexto('<Versao ' + NAME_SPACE_EFRETE_OBJECTS + '>2</Versao>');
        Gerador.wCampo(tcInt, '', 'CNPJ', 001, 014, 1, FProprietario.CNPJ, '');
        Gerador.wCampo(tcStr, '', 'RNTRC', 001, 008, 1, FProprietario.RNTRC, '');
        Gerador.wGrupo('/ObterRequest');
      end;
    opAdicionar:
      begin
        Gerador.wGrupo('GravarRequest ' + NAME_SPACE_EFRETE_PROPRIETARIOS_EFRETE, 'VP01');
        Gerador.wTexto('<Integrador ' + NAME_SPACE_EFRETE_OBJECTS + '>' + TAmsCIOT( FProprietario.Owner ).Configuracoes.Integradora.Identificacao + '</Integrador>');
        Gerador.wTexto('<Versao ' + NAME_SPACE_EFRETE_OBJECTS + '>2</Versao>');
        Gerador.wCampo(tcStr, 'PP03', 'CNPJ', 001, 014, 1, FProprietario.CNPJ, '');
        Gerador.wGrupo('Endereco', 'P04');
        Gerador.wCampo(tcStr, 'PP05', 'Bairro', 001, 001, 1, FProprietario.Endereco.Bairro, '', ' ' + NAME_SPACE_EFRETE_OBJECTS);
        Gerador.wCampo(tcStr, 'PP06', 'CEP', 001, 009, 1, Copy(FProprietario.Endereco.CEP, 1, 5) + '-' + Copy(FProprietario.Endereco.CEP, 6, 3), '', ' ' + NAME_SPACE_EFRETE_OBJECTS);
        Gerador.wCampo(tcStr, 'PP07', 'CodigoMunicipio', 001, 007, 1, FProprietario.Endereco.CodigoMunicipio, '', ' ' + NAME_SPACE_EFRETE_OBJECTS);
        Gerador.wCampo(tcStr, 'PP08', 'Rua', 001, 001, 1, FProprietario.Endereco.Rua, '', ' ' + NAME_SPACE_EFRETE_OBJECTS);
        Gerador.wCampo(tcStr, 'PP09', 'Numero', 001, 001, 1, FProprietario.Endereco.Numero, '', ' ' + NAME_SPACE_EFRETE_OBJECTS);
        Gerador.wCampo(tcStr, 'PP10', 'Complemento', 001, 001, 1, FProprietario.Endereco.Complemento, '', ' ' + NAME_SPACE_EFRETE_OBJECTS);
        Gerador.wGrupo('/Endereco');
        Gerador.wCampo(tcStr, 'PP11', 'RNTRC', 001, 008, 1, FProprietario.RNTRC, 'RNTRC do Proprietário');
        Gerador.wCampo(tcStr, 'PP12', 'RazaoSocial', 001, 001, 1, FProprietario.RazaoSocial, '');

        with FProprietario.Telefones do
        begin
          Gerador.wGrupo('Telefones', 'PP13');
          Gerador.wGrupo('Celular ' + NAME_SPACE_EFRETE_OBJECTS, 'PP14');
          Gerador.wCampo(tcInt, 'PP15', 'DDD', 001, 002, 1, Celular.DDD);
          Gerador.wCampo(tcInt, 'PP16', 'Numero', 001, 009, 1, Celular.Numero);
          Gerador.wGrupo('/Celular');

          Gerador.wGrupo('Fax ' + NAME_SPACE_EFRETE_OBJECTS, 'PP17');
          Gerador.wCampo(tcInt, 'PP18', 'DDD', 001, 002, 1, Fax.DDD);
          Gerador.wCampo(tcInt, 'PP19', 'Numero', 001, 009, 1, Fax.Numero);
          Gerador.wGrupo('/Fax');

          Gerador.wGrupo('Fixo ' + NAME_SPACE_EFRETE_OBJECTS, 'PP20');
          Gerador.wCampo(tcInt, 'PP21', 'DDD', 001, 002, 1, Fixo.DDD);
          Gerador.wCampo(tcInt, 'PP22', 'Numero', 001, 009, 1, Fixo.Numero);
          Gerador.wGrupo('/Fixo');

          Gerador.wGrupo('/Telefones');
        end;

        Gerador.wGrupo('/GravarRequest');
      end;
  end;

  Result := (Gerador.ListaDeAlertas.Count = 0);
end;

end.

