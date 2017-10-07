{$I ACBr.inc}

unit pciotViagens;

interface

uses
  SysUtils, Classes, pcnAuxiliar, pcnConversao, pcnLeitor, pcnGerador, pciotCIOT;


type
  TGeradorOpcoes = class;


  TViagensR = class(TPersistent)
  private
    FLeitor: TLeitor;
    FSucesso: Boolean;
    FMensagem: String;
    FQTPagamentos: integer;
    FDocumentos: TStrings;
    FPagamentos: TStrings;
    FQTDocumentos: integer;
  public
    constructor Create;
    destructor Destroy; override;
    function LerXml: boolean;

    property Sucesso: Boolean read FSucesso write FSucesso;
    property Mensagem: String read FMensagem write FMensagem;
    property QTDocumentos: integer read FQTDocumentos write FQTDocumentos;
    property Documentos: TStrings read FDocumentos write FDocumentos;
    property QTPagamentos: integer read FQTPagamentos write FQTPagamentos;
    property Pagamentos: TStrings read FPagamentos write FPagamentos;
  published
    property Leitor: TLeitor read FLeitor write FLeitor;
  end;


  TViagensW = class(TPersistent)
  private
    FGerador: TGerador;
    FOperacaoTransporte: TOperacaoTransporte;
    FOpcoes: TGeradorOpcoes;
  public
    constructor Create(AOwner: TOperacaoTransporte);
    destructor Destroy; override;
    function GerarXML: boolean;
  published
    property Gerador: TGerador read FGerador write FGerador;
    property OperacaoTransporte: TOperacaoTransporte read FOperacaoTransporte write FOperacaoTransporte;
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

{ TViagensW }

uses ACBrCIOT;

constructor TViagensW.Create(AOwner: TOperacaoTransporte);
begin
  FOperacaoTransporte := AOwner;

  FGerador := TGerador.Create;
  FGerador.FIgnorarTagNivel := '|?xml version|CTe xmlns|infCTe versao|obsCont|obsFisco|';
  FOpcoes := TGeradorOpcoes.Create;
  FOpcoes.FAjustarTagNro := True;
  FOpcoes.FNormatizarMunicipios := False;
  FOpcoes.FGerarTagAssinatura := taSomenteSeAssinada;
  FOpcoes.FValidarInscricoes := False;
  FOpcoes.FValidarListaServicos := False;
end;

destructor TViagensW.Destroy;
begin
  FGerador.Free;
  FOpcoes.Free;
  inherited Destroy;
end;

function TViagensW.GerarXML: boolean;
var
  chave: AnsiString;
  Gerar: boolean;
  xProtCTe : String;
  I, J: integer;
begin
  Gerador.Opcoes.IdentarXML := True;
  Gerador.Opcoes.TagVaziaNoFormatoResumido := False;
  Gerador.ArquivoFormatoXML := '';

  Gerador.wGrupo('AdicionarViagemRequest ' + NAME_SPACE_EFRETE_OPERACAOTRANSPORTE_EFRETE, 'HP01');
  Gerador.wCampo(tcStr, 'HP02', 'NaoAdicionarParcialmente', 001, 001, 1, LowerCase(BoolToStr(false, false)), '');//NaoAdicionarParcialmente //E HP01 B 0-1 - - Indica se deseja ou não adicionar viagens / pagamentos de forma parcial. true: Caso um pagamento da requisição seja encontrado na base, nada é adicionado. False: A adição dos dados é incremental, se algum dos
                                                                                      //pagamentos da requisição não estiver presente na base ele é gravado, o pagamento que já estiver gravado não. Se a viagem já estiver gravada
                                                                                      //nenhum dos pagamentos informados na requisição é adicionado, para adicionar apenas pagamentos consultar o método AdicionarPagamento.
  Gerador.wCampo(tcStr, 'HP03', 'CodigoIdentificacaoOperacao', 001, 001, 1, FOperacaoTransporte.NumeroCIOT, '');
  Gerador.wCampo(tcStr, 'HP04', 'Integrador', 001, 001, 1, TACBrCIOT( FOperacaoTransporte.Owner ).Configuracoes.Integradora.Identificacao, '', ' ' + NAME_SPACE_EFRETE_OBJECTS);
  Gerador.wCampo(tcStr, 'HP06', 'Versao', 001, 001, 1, 2, '', ' ' + NAME_SPACE_EFRETE_OBJECTS);

  Gerador.wGrupo('Viagens ' + NAME_SPACE_EFRETE_PEFADICIONAR_OBJECTS, 'HP07');
  for I := 0 to FOperacaoTransporte.Viagens.Count -1 do
  begin
    with FOperacaoTransporte.Viagens.Items[I] do
    begin
      Gerador.wCampo(tcInt, 'HP08', 'CodigoMunicipioDestino', 001, 007, 1, CodigoMunicipioDestino);
      Gerador.wCampo(tcInt, 'HP09', 'CodigoMunicipioOrigem', 001, 007, 1, CodigoMunicipioOrigem);
      Gerador.wCampo(tcStr, 'HP10', 'DocumentoViagem', 001, 001, 1, DocumentoViagem, 'Exemplo: CT-e / Serie, CTRC / Serie, Ordem de Serviço.');

      Gerador.wGrupo('NotasFiscais', 'HP11');

      for J := 0 to NotasFiscais.Count -1 do
      begin
        with NotasFiscais.Items[J] do
        begin
          Gerador.wGrupo('NotaFiscal');
          Gerador.wCampo(tcInt, 'HP12', 'CodigoNCMNaturezaCarga', 001, 004, 1, CodigoNCMNaturezaCarga);
          Gerador.wCampo(tcDat, 'HP13', 'Data', 001, 004, 1, Data);
          Gerador.wCampo(tcStr, 'HP14', 'DescricaoDaMercadoria', 001, 060, 1, DescricaoDaMercadoria, 'Descrição adicional ao código NCM.');
          Gerador.wCampo(tcStr, 'HP15', 'Numero', 001, 010, 1, Numero);
          Gerador.wCampo(tcDe3, 'HP16', 'QuantidadeDaMercadoriaNoEmbarque', 001, 010, 1, QuantidadeDaMercadoriaNoEmbarque);
          Gerador.wCampo(tcStr, 'HP17', 'Serie', 001, 001, 1, Serie);
          Gerador.wCampo(tcStr, 'HP18', 'TipoDeCalculo', 001, 001, 1, TpVgTipoCalculoToStr(TipoDeCalculo));
          Gerador.wGrupo('ToleranciaDePerdaDeMercadoria', 'HP19');
          Gerador.wCampo(tcStr, 'HP20', 'Tipo', 001, 001, 1, TpProporcaoToStr(ToleranciaDePerdaDeMercadoria.Tipo));
          Gerador.wCampo(tcDe2, 'HP21', 'Valor', 001, 001, 1, ToleranciaDePerdaDeMercadoria.Valor);
          Gerador.wGrupo('/ToleranciaDePerdaDeMercadoria');

//                if DiferencaDeFrete.Tipo <> SemDiferenca then
//                begin
//                  Gerador.wGrupo('DiferencaDeFrete', 'AP147');
//                  Gerador.wCampo(tcStr, 'AP148', 'Tipo', 001, 001, 1, TpDifFreteToStr(DiferencaDeFrete.Tipo));
//                  Gerador.wCampo(tcStr, 'AP149', 'Base', 001, 001, 1, TpDiferencaFreteBCToStr(DiferencaDeFrete.Base));
//                  Gerador.wGrupo('Tolerancia', 'AP150');
//                  Gerador.wCampo(tcStr, 'AP151', 'Tipo', 001, 001, 1, TpProporcaoToStr(DiferencaDeFrete.Tolerancia.Tipo));
//                  Gerador.wCampo(tcDe2, 'AP152', 'Valor', 001, 001, 1, DiferencaDeFrete.Tolerancia.Valor);
//                  Gerador.wGrupo('/Tolerancia');
//                  Gerador.wGrupo('MargemGanho', 'AP153');
//                  Gerador.wCampo(tcStr, 'AP154', 'Tipo', 001, 001, 1, TpProporcaoToStr(DiferencaDeFrete.MargemGanho.Tipo));
//                  Gerador.wCampo(tcDe2, 'AP155', 'Valor', 001, 001, 1, DiferencaDeFrete.MargemGanho.Valor);
//                  Gerador.wGrupo('/MargemGanho');
//                  Gerador.wGrupo('MargemPerda', 'AP156');
//                  Gerador.wCampo(tcStr, 'AP157', 'Tipo', 001, 001, 1, TpProporcaoToStr(DiferencaDeFrete.MargemPerda.Tipo));
//                  Gerador.wCampo(tcDe2, 'AP158', 'Valor', 001, 001, 1, DiferencaDeFrete.MargemPerda.Valor);
//                  Gerador.wGrupo('/MargemPerda');
//                  Gerador.wGrupo('/DiferencaDeFrete');
//                end;

          Gerador.wCampo(tcStr, 'HP22', 'UnidadeDeMedidaDaMercadoria', 001, 001, 1, TpUnMedMercToStr(UnidadeDeMedidaDaMercadoria));
          Gerador.wCampo(tcDe2, 'HP23', 'ValorDaMercadoriaPorUnidade', 001, 001, 1, ValorDaMercadoriaPorUnidade);
          Gerador.wCampo(tcDe2, 'HP24', 'ValorDoFretePorUnidadeDeMercadoria', 001, 001, 1, ValorDoFretePorUnidadeDeMercadoria);
          Gerador.wCampo(tcDe2, 'HP25', 'ValorTotal', 001, 001, 1, ValorTotal);

          Gerador.wGrupo('/NotaFiscal');
        end;
      end;
      Gerador.wGrupo('/NotasFiscais');

      Gerador.wGrupo('Valores ' + NAME_SPACE_EFRETE_OPERACAOTRANSPORTE_EFRETE, 'HP26');
      with Valores do
      begin
        Gerador.wCampo(tcDe2, 'HP27', 'Combustivel', 001, 001, 1, Combustivel);
        Gerador.wCampo(tcStr, 'HP28', 'JustificativaOutrosCreditos', 001, 001, 1, JustificativaOutrosCreditos);
        Gerador.wCampo(tcStr, 'HP29', 'JustificativaOutrosDebitos', 001, 001, 1, JustificativaOutrosDebitos);
        Gerador.wCampo(tcDe2, 'HP30', 'OutrosCreditos', 001, 001, 1, OutrosCreditos);
        Gerador.wCampo(tcDe2, 'HP31', 'OutrosDebitos', 001, 001, 1, OutrosDebitos);
        Gerador.wCampo(tcDe2, 'HP32', 'Pedagio', 001, 001, 1, Pedagio);
        Gerador.wCampo(tcDe2, 'HP33', 'Seguro', 001, 001, 1, Seguro);
        Gerador.wCampo(tcDe2, 'HP34', 'TotalDeAdiantamento', 001, 001, 1, TotalDeAdiantamento);
        Gerador.wCampo(tcDe2, 'HP35', 'TotalDeQuitacao', 001, 001, 1, TotalDeQuitacao);
        Gerador.wCampo(tcDe2, 'HP36', 'TotalOperacao', 001, 001, 1, TotalOperacao);
        Gerador.wCampo(tcDe2, 'HP37', 'TotalViagem', 001, 001, 1, TotalViagem);
      end;
      Gerador.wGrupo('/Valores');

      for I := 0 to Pagamentos.Count -1 do
      begin
        with Pagamentos.Items[I] do
        begin
          Gerador.wGrupo('Pagamentos ' + NAME_SPACE_EFRETE_PEFADICIONAR_OBJECTS, 'HP38'); //Pagamentos registrados. - Pode existir mais de 1 pagamento com uma mesma categoria (exceto para Quitacao). - A soma dos pagamentos c/ categoria Adiantamento, deverá ter o mesmo valor apontado na tag TotalAdiantamento da tag Viagem/Valores, e neste caso, a tag Documento do pagamento deverá conter o mesmo valor da tag DocumentoViagem da tag Viagem . - Se a viagem possuir a tag TotalQuitacao maior que zero, deverá ter um pagamento correspondente, com Categoria Quitacao e com o Documento o mesmo valor apontado na tag DocumentoViagem .
          Gerador.wCampo(tcStr, 'HP39', 'Categoria', 001, 001, 1, TpCatPagToStr(Categoria), 'Categoria relacionada ao pagamento realizado. Restrita aos membros da ENUM: -Adiantamento, -Estadia, Quitacao, -SemCategoria ', ' ' + NAME_SPACE_EFRETE_OPERACAOTRANSPORTE_EFRETE);
          Gerador.wCampo(tcDat, 'HP40', 'DataDeLiberacao', 001, 001, 1, DataDeLiberacao);
          Gerador.wCampo(tcStr, 'HP41', 'Documento', 001, 020, 1, Documento, 'Documento relacionado a viagem.');
          Gerador.wCampo(tcStr, 'HP42', 'IdPagamentoCliente', 001, 020, 1, IdPagamentoCliente, 'Identificador do pagamento no sistema do Cliente. ');
          Gerador.wCampo(tcStr, 'HP43', 'InformacaoAdicional', 001, 000, 0, InformacaoAdicional, '');

          Gerador.wGrupo('InformacoesBancarias ' + NAME_SPACE_EFRETE_OPERACAOTRANSPORTE_EFRETE, 'HP44');
          with InformacoesBancarias do
          begin
            Gerador.wCampo(tcStr, 'HP45', 'Agencia', 001, 001, 1, Agencia);
            Gerador.wCampo(tcStr, 'HP46', 'Conta', 001, 001, 1, Conta);
            Gerador.wCampo(tcStr, 'HP47', 'InstituicaoBancaria', 001, 001, 1, InstituicaoBancaria);
          end;
          Gerador.wGrupo('/InformacoesBancarias');

          Gerador.wCampo(tcStr, 'HP48', 'TipoPagamento', 001, 020, 1, TpPagamentoToStr(TipoPagamento), 'Tipo de pagamento que será usado pelo contratante. Restrito aos itens da enum: -TransferenciaBancaria -eFRETE', ' ' + NAME_SPACE_EFRETE_OPERACAOTRANSPORTE_EFRETE);
          Gerador.wCampo(tcDe2, 'HP49', 'Valor', 001, 020, 1, Valor, 'Valor do pagamento.');
          Gerador.wGrupo('/Pagamentos');
        end;
      end;
    end;
  end;

  Gerador.wGrupo('/Viagens');
  Gerador.wGrupo('/AdicionarViagemRequest');

  Result := (Gerador.ListaDeAlertas.Count = 0);
end;

{ TViagensR }

constructor TViagensR.Create;
begin
  FLeitor := TLeitor.Create;
  FDocumentos := TStringList.Create;
  FPagamentos := TStringList.Create;
end;

destructor TViagensR.Destroy;
begin
  FLeitor.Free;
  FDocumentos.Free;
  FPagamentos.Free;

  inherited Destroy;
end;

function TViagensR.LerXml: boolean;
var
  ok: boolean;
begin
  if Leitor.rExtrai(1, 'AdicionarViagemResult') <> '' then
  begin
    FSucesso := Leitor.rCampo(tcStr, 'Sucesso ' + NAME_SPACE_EFRETE_OBJECTS, '/Sucesso') = 'true';
    FMensagem := Leitor.rCampo(tcStr, 'Mensagem');

    FQTPagamentos :=  Leitor.rCampo(tcInt, 'QuantidadePagamentos');
    FPagamentos.Text := Leitor.rCampo(tcStr, 'DocumentoPagamento');
    FQTDocumentos :=  Leitor.rCampo(tcInt, 'QuantidadeViagem');
    FDocumentos.Text := Leitor.rCampo(tcStr, 'DocumentoViagem');
  end;

  Result := true;
end;

end.

