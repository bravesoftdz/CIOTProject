{$I ACBr.inc}

unit pciotOperacaoTransporteW;

interface

uses
  SysUtils, Classes, pcnAuxiliar, pcnConversao, pciotCIOT, ASCIOTUtil;


type
  TGeradorOpcoes = class;

  TOperacaoTransporteW = class(TPersistent)
  private
    FGerador: TGerador;
    FOperacaoTransporte: TOperacaoTransporte;
    FOperacao: TpciotOperacao;
    FOpcoes: TGeradorOpcoes;
  public
    constructor Create(AOwner: TOperacaoTransporte; AOperacao: TpciotOperacao = opObter);
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

{ TOperacaoTransporteW }

uses ASCIOT;

constructor TOperacaoTransporteW.Create(AOwner: TOperacaoTransporte; AOperacao: TpciotOperacao);
begin
  FOperacaoTransporte := AOwner;
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

destructor TOperacaoTransporteW.Destroy;
begin
  FGerador.Free;
  FOpcoes.Free;
  inherited Destroy;
end;

function TOperacaoTransporteW.GerarXML: boolean;
var
  chave: AnsiString;
  Gerar: boolean;
  xProtCTe : String;
  I, J: integer;
begin
  Gerador.Opcoes.IdentarXML := True;
  Gerador.Opcoes.TagVaziaNoFormatoResumido := False;
  Gerador.ArquivoFormatoXML := '';

  case FOperacao of
    opObter:
      begin
        Gerador.wGrupo('ObterOperacaoTransportePdfRequest ' + NAME_SPACE_EFRETE_OPERACAOTRANSPORTE_EFRETE);
        Gerador.wTexto('<Integrador ' +   NAME_SPACE_EFRETE_OBJECTS + '>' + TAmsCIOT( FOperacaoTransporte.Owner ).Configuracoes.Integradora.Identificacao + '</Integrador>');
        Gerador.wTexto('<Versao ' +   NAME_SPACE_EFRETE_OBJECTS + '>1</Versao>');
        Gerador.wCampo(tcStr, '', 'CodigoIdentificacaoOperacao', 001, 030, 1, FOperacaoTransporte.NumeroCIOT, '');
        Gerador.wGrupo('/ObterOperacaoTransportePdfRequest');
      end;
    opAdicionar:
      begin
        Gerador.wGrupo('AdicionarOperacaoTransporteRequest ' + NAME_SPACE_EFRETE_OPERACAOTRANSPORTE_EFRETE, 'AP01');
        Gerador.wCampo(tcStr, 'AP77', 'Integrador', 001, 001, 1, TAmsCIOT( FOperacaoTransporte.Owner ).Configuracoes.Integradora.Identificacao, '', ' ' + NAME_SPACE_EFRETE_OBJECTS);
        Gerador.wCampo(tcStr, 'AP131', 'Versao', 001, 001, 1, 3, '', ' ' + NAME_SPACE_EFRETE_OBJECTS);
        Gerador.wCampo(tcStr, 'AP02', 'CodigoIdentificacaoOperacaoPrincipal', 001, 001, 1, FOperacaoTransporte.CodigoIdentificacaoOperacaoPrincipal, '');

        if FOperacaoTransporte.TipoViagem = Padrao then
          Gerador.wCampo(tcInt, 'AP03', 'CodigoNCMNaturezaCarga', 001, 004, 1, FOperacaoTransporte.CodigoNCMNaturezaCarga); //0001

        if FOperacaoTransporte.Consignatario.CpfOuCnpj <> '' then
        begin
          Gerador.wGrupo('Consignatario', 'AP04');
          Gerador.wCampo(tcStr, 'AP05', 'CpfOuCnpj', 001, 001, 1, FOperacaoTransporte.Consignatario.CpfOuCnpj, 'CPF ou CNPJ do Consignatário');
          Gerador.wCampo(tcStr, 'AP06', 'EMail', 001, 001, 1, FOperacaoTransporte.Consignatario.EMail, 'Email do consignatário.');
                                
          with FOperacaoTransporte.Consignatario do
          begin
            Gerador.wGrupo('Endereco', 'AP07');
            Gerador.wCampo(tcStr, 'AP08', 'Bairro', 001, 001, 1, Endereco.Bairro, '', ' ' + NAME_SPACE_EFRETE_OBJECTS);
            Gerador.wCampo(tcStr, 'AP09', 'CEP', 001, 009, 1, Copy(Endereco.CEP, 1, 5) + '-' + Copy(Endereco.CEP, 6, 3), '', ' ' + NAME_SPACE_EFRETE_OBJECTS);
            Gerador.wCampo(tcStr, 'AP10', 'CodigoMunicipio', 001, 007, 1, Endereco.CodigoMunicipio, '', ' ' + NAME_SPACE_EFRETE_OBJECTS);
            Gerador.wCampo(tcStr, 'AP11', 'Rua', 001, 001, 1, Endereco.Rua, '', ' ' + NAME_SPACE_EFRETE_OBJECTS);
            Gerador.wCampo(tcStr, 'AP12', 'Numero', 001, 001, 1, Endereco.Numero, '', ' ' + NAME_SPACE_EFRETE_OBJECTS);
            Gerador.wCampo(tcStr, 'AP13', 'Complemento', 001, 001, 1, Endereco.Complemento, '', ' ' + NAME_SPACE_EFRETE_OBJECTS);
            Gerador.wGrupo('/Endereco');
          end;
                                           
          Gerador.wCampo(tcStr, 'AP14', 'Nome', 001, 001, 1, FOperacaoTransporte.Consignatario.NomeOuRazaoSocial, 'Nome ou Razão Social do Consignatário.');
          Gerador.wCampo(tcStr, 'AP15', 'ResponsavelPeloPagamento', 001, 001, 1, LowerCase(BoolToStr(FOperacaoTransporte.Consignatario.ResponsavelPeloPagamento, true)), 'Informar se é o responsável pelo pagamento da Operação de Transporte. True = Sim. False = Não');

          with FOperacaoTransporte.Consignatario.Telefones do
          begin
            Gerador.wGrupo('Telefones', 'AP16');
            Gerador.wGrupo('Celular ' + NAME_SPACE_EFRETE_OBJECTS, 'AP17');
            Gerador.wCampo(tcInt, 'AP18', 'DDD', 001, 002, 1, Celular.DDD, '');
            Gerador.wCampo(tcInt, 'AP19', 'Numero', 001, 009, 1, Celular.Numero, '');
            Gerador.wGrupo('/Celular');

            Gerador.wGrupo('Fax ' + NAME_SPACE_EFRETE_OBJECTS, 'AP20');
            Gerador.wCampo(tcInt, 'AP21', 'DDD', 001, 002, 1, Fax.DDD, '');
            Gerador.wCampo(tcInt, 'AP22', 'Numero', 001, 009, 1, Fax.Numero, '');
            Gerador.wGrupo('/Fax');

            Gerador.wGrupo('Fixo ' + NAME_SPACE_EFRETE_OBJECTS, 'AP23');
            Gerador.wCampo(tcInt, 'AP24', 'DDD', 001, 002, 1, Fixo.DDD, '');
            Gerador.wCampo(tcInt, 'AP25', 'Numero', 001, 009, 1, Fixo.Numero, '');
            Gerador.wGrupo('/Fixo');
            Gerador.wGrupo('/Telefones');
          end;
          Gerador.wGrupo('/Consignatario');
        end
        else
          Gerador.wCampo(tcStr, 'AP04', 'Consignatario', 001, 001, 1, '');

        Gerador.wGrupo('Contratado ' + NAME_SPACE_EFRETE_PEFADICIONAR_OBJECTS, 'AP26');
        Gerador.wCampo(tcStr, 'AP27', 'CpfOuCnpj', 001, 001, 1, FOperacaoTransporte.Contratado.CpfOuCnpj, '');
        Gerador.wCampo(tcStr, 'AP28', 'RNTRC', 001, 001, 1, FOperacaoTransporte.Contratado.RNTRC, '');
        Gerador.wGrupo('/Contratado');

        Gerador.wGrupo('Contratante', 'AP29');
        Gerador.wCampo(tcStr, 'AP30', 'CpfOuCnpj', 001, 001, 1, FOperacaoTransporte.Contratante.CpfOuCnpj);
        Gerador.wCampo(tcStr, 'AP31', 'EMail', 001, 001, 1, FOperacaoTransporte.Contratante.EMail);                        

        with FOperacaoTransporte.Contratante do
        begin
          Gerador.wGrupo('Endereco', 'AP32');
          Gerador.wCampo(tcStr, 'AP33', 'Bairro', 001, 001, 1, Endereco.Bairro, '', ' ' + NAME_SPACE_EFRETE_OBJECTS);
          Gerador.wCampo(tcStr, 'AP34', 'CEP', 001, 009, 1, Copy(Endereco.CEP, 1, 5) + '-' + Copy(Endereco.CEP, 6, 3), '', ' ' + NAME_SPACE_EFRETE_OBJECTS);
          Gerador.wCampo(tcStr, 'AP35', 'CodigoMunicipio', 001, 007, 1, Endereco.CodigoMunicipio, '', ' ' + NAME_SPACE_EFRETE_OBJECTS);
          Gerador.wCampo(tcStr, 'AP36', 'Rua', 001, 001, 1, Endereco.Rua, '', ' ' + NAME_SPACE_EFRETE_OBJECTS);
          Gerador.wCampo(tcStr, 'AP37', 'Numero', 001, 001, 1, Endereco.Numero, '', ' ' + NAME_SPACE_EFRETE_OBJECTS);
          Gerador.wCampo(tcStr, 'AP38', 'Complemento', 001, 001, 1, Endereco.Complemento, '', ' ' + NAME_SPACE_EFRETE_OBJECTS);
          Gerador.wGrupo('/Endereco');
        end;
                                           
        Gerador.wCampo(tcStr, 'AP39', 'NomeOuRazaoSocial', 001, 001, 1, FOperacaoTransporte.Contratante.NomeOuRazaoSocial, 'Nome ou Razão Social do Contratante.');
        Gerador.wCampo(tcStr, 'AP40', 'ResponsavelPeloPagamento', 001, 001, 1, LowerCase(BoolToStr(FOperacaoTransporte.Contratante.ResponsavelPeloPagamento, true)), 'Informar se é o responsável pelo pagamento da Operação de Transporte. True = Sim. False = Não');

        with FOperacaoTransporte.Consignatario.Telefones do
        begin
          Gerador.wGrupo('Telefones', 'AP41');
          Gerador.wGrupo('Celular ' + NAME_SPACE_EFRETE_OBJECTS, 'AP42');
          Gerador.wCampo(tcInt, 'AP43', 'DDD', 001, 002, 1, Celular.DDD, '');
          Gerador.wCampo(tcInt, 'AP44', 'Numero', 001, 009, 1, Celular.Numero, '');
          Gerador.wGrupo('/Celular');

          Gerador.wGrupo('Fax ' + NAME_SPACE_EFRETE_OBJECTS, 'AP45');
          Gerador.wCampo(tcInt, 'AP46', 'DDD', 001, 002, 1, Fax.DDD, '');
          Gerador.wCampo(tcInt, 'AP47', 'Numero', 001, 009, 1, Fax.Numero, '');
          Gerador.wGrupo('/Fax');

          Gerador.wGrupo('Fixo ' + NAME_SPACE_EFRETE_OBJECTS, 'AP48');
          Gerador.wCampo(tcInt, 'AP49', 'DDD', 001, 002, 1, Fixo.DDD, '');
          Gerador.wCampo(tcInt, 'AP50', 'Numero', 001, 009, 1, Fixo.Numero, '');
          Gerador.wGrupo('/Fixo');
          Gerador.wGrupo('/Telefones');
        end;

        Gerador.wCampo(tcStr, '', 'RNTRC', 001, 001, 1, FOperacaoTransporte.Contratante.RNTRC); 
        Gerador.wGrupo('/Contratante');                

        Gerador.wCampo(tcDat, 'AP51', 'DataFimViagem', 001, 001, 1, FOperacaoTransporte.DataFimViagem, 'Data prevista para o fim de viagem.');

        if FOperacaoTransporte.TipoViagem = Padrao then
        begin
          Gerador.wCampo(tcDat, 'AP52', 'DataInicioViagem', 001, 001, 1, FOperacaoTransporte.DataInicioViagem, 'Data de início da viagem. Operação do tipo 1 seu preenchimento é obrigatório.');

          Gerador.wGrupo('Destinatario', 'AP53');
          Gerador.wCampo(tcStr, 'AP54', 'CpfOuCnpj', 001, 001, 1, FOperacaoTransporte.Destinatario.CpfOuCnpj);
          Gerador.wCampo(tcStr, 'AP55', 'EMail', 001, 001, 1, FOperacaoTransporte.Destinatario.EMail);

          with FOperacaoTransporte.Destinatario do
          begin
            Gerador.wGrupo('Endereco', 'AP56');
            Gerador.wCampo(tcStr, 'AP57', 'Bairro', 001, 001, 1, Endereco.Bairro, '', ' ' + NAME_SPACE_EFRETE_OBJECTS);
            Gerador.wCampo(tcStr, 'AP58', 'CEP', 001, 009, 1, Copy(Endereco.CEP, 1, 5) + '-' + Copy(Endereco.CEP, 6, 3), '', ' ' + NAME_SPACE_EFRETE_OBJECTS);
            Gerador.wCampo(tcStr, 'AP59', 'CodigoMunicipio', 001, 007, 1, Endereco.CodigoMunicipio, '', ' ' + NAME_SPACE_EFRETE_OBJECTS);
            Gerador.wCampo(tcStr, 'AP60', 'Rua', 001, 001, 1, Endereco.Rua, '', ' ' + NAME_SPACE_EFRETE_OBJECTS);
            Gerador.wCampo(tcStr, 'AP61', 'Numero', 001, 001, 1, Endereco.Numero, '', ' ' + NAME_SPACE_EFRETE_OBJECTS);
            Gerador.wCampo(tcStr, 'AP62', 'Complemento', 001, 001, 1, Endereco.Complemento, '', ' ' + NAME_SPACE_EFRETE_OBJECTS);
            Gerador.wGrupo('/Endereco');
          end;
                                           
          Gerador.wCampo(tcStr, 'AP63', 'NomeOuRazaoSocial', 001, 001, 1, FOperacaoTransporte.Destinatario.NomeOuRazaoSocial, 'Nome ou Razão Social do Contratante.');
          Gerador.wCampo(tcStr, 'AP64', 'ResponsavelPeloPagamento', 001, 001, 1, LowerCase(BoolToStr(FOperacaoTransporte.Destinatario.ResponsavelPeloPagamento, true)), 'Informar se é o responsável pelo pagamento da Operação de Transporte. True = Sim. False = Não');

          with FOperacaoTransporte.Destinatario.Telefones do
          begin
            Gerador.wGrupo('Telefones', 'AP65');
            Gerador.wGrupo('Celular ' + NAME_SPACE_EFRETE_OBJECTS, 'AP66');
            Gerador.wCampo(tcInt, 'AP67', 'DDD', 001, 002, 1, Celular.DDD, '');
            Gerador.wCampo(tcInt, 'AP68', 'Numero', 001, 009, 1, Celular.Numero, '');
            Gerador.wGrupo('/Celular');

            Gerador.wGrupo('Fax ' + NAME_SPACE_EFRETE_OBJECTS, 'AP69');
            Gerador.wCampo(tcInt, 'AP70', 'DDD', 001, 002, 1, Fax.DDD, '');
            Gerador.wCampo(tcInt, 'AP71', 'Numero', 001, 009, 1, Fax.Numero, '');
            Gerador.wGrupo('/Fax');

            Gerador.wGrupo('Fixo ' + NAME_SPACE_EFRETE_OBJECTS, 'AP72');
            Gerador.wCampo(tcInt, 'AP73', 'DDD', 001, 002, 1, Fixo.DDD, '');
            Gerador.wCampo(tcInt, 'AP74', 'Numero', 001, 009, 1, Fixo.Numero, '');
            Gerador.wGrupo('/Fixo');
            Gerador.wGrupo('/Telefones');
          end;
          Gerador.wGrupo('/Destinatario');
        end;

        Gerador.wCampo(tcStr, 'AP75', 'FilialCNPJ', 001, 001, 1, FOperacaoTransporte.FilialCNPJ, 'CPNJ da filial do Contratante, que está realizando a operação de transporte, se necessário.'); 
        Gerador.wCampo(tcStr, 'AP76', 'IdOperacaoCliente', 001, 001, 1, FOperacaoTransporte.IdOperacaoCliente, 'Id / Chave primária da operação de transporte no sistema do Cliente.'); 

        Gerador.wGrupo('Impostos', 'AP78');
        Gerador.wCampo(tcStr, 'AP79', 'DescricaoOutrosImpostos', 001, 001, 1, FOperacaoTransporte.Impostos.DescricaoOutrosImpostos);
        Gerador.wCampo(tcDe2, 'AP80', 'INSS', 001, 020, 1, FOperacaoTransporte.Impostos.INSS, 'Valor destinado ao INSS. Este valor deverá fazer parte do valor de Adiantamento ou do valor de Quitação.');
        Gerador.wCampo(tcDe2, 'AP81', 'IRRF', 001, 020, 1, FOperacaoTransporte.Impostos.IRRF, 'Valor destinado ao IRRF. Este valor deverá fazer parte do valor de Adiantamento ou do valor de Quitação.');
        Gerador.wCampo(tcDe2, 'AP82', 'ISSQN', 001, 020, 1, FOperacaoTransporte.Impostos.ISSQN, 'Valor destinado ao ISSQN. Este valor deverá fazer parte do valor de Adiantamento ou do valor de Quitação.');
        Gerador.wCampo(tcDe2, 'AP83', 'OutrosImpostos', 001, 020, 1, FOperacaoTransporte.Impostos.OutrosImpostos, 'Valor destinado a outros impostos não previstos. Este valor deverá fazer parte do valor de Adiantamento ou do valor de Quitação.');
        Gerador.wCampo(tcDe2, 'AP84', 'SestSenat', 001, 020, 1, FOperacaoTransporte.Impostos.SestSenat, 'Valor destinado ao SEST / SENAT. Este valor deverá fazer parte do valor de Adiantamento ou do valor de Quitação.');
        Gerador.wGrupo('/Impostos');

        Gerador.wCampo(tcStr, 'AP85', 'MatrizCNPJ', 001, 001, 1, FOperacaoTransporte.MatrizCNPJ, 'CNPJ da Matriz da Transportadora.'); 

        Gerador.wGrupo('Motorista ' + NAME_SPACE_EFRETE_PEFADICIONAR_OBJECTS, 'AP86');        
        Gerador.wGrupo('Celular ' + NAME_SPACE_EFRETE_OPERACAOTRANSPORTE_EFRETE, 'AP87');
        with FOperacaoTransporte.Motorista do
        begin
          Gerador.wCampo(tcInt, 'AP88', 'DDD', 001, 002, 1, Celular.DDD, '', ' ' + NAME_SPACE_EFRETE_OBJECTS);
          Gerador.wCampo(tcInt, 'AP89', 'Numero', 001, 009, 1, Celular.Numero, '', ' ' + NAME_SPACE_EFRETE_OBJECTS);
        end;

        Gerador.wGrupo('/Celular');
        Gerador.wCampo(tcStr, 'AP90', 'CpfOuCnpj', 001, 001, 1, FOperacaoTransporte.Motorista.CpfOuCnpj, 'CPF ou CNPJ do Motorista.');
        Gerador.wCampo(tcInt, 'AP', 'CNH', 001, 007, 1, FOperacaoTransporte.Motorista.CNH, '');
        Gerador.wGrupo('/Motorista');        

        if FOperacaoTransporte.TipoViagem = Padrao then
        begin
          for I := 0 to FOperacaoTransporte.Pagamentos.Count -1 do
          begin
            with FOperacaoTransporte.Pagamentos.Items[I] do
            begin
              Gerador.wGrupo('Pagamentos ' + NAME_SPACE_EFRETE_PEFADICIONAR_OBJECTS, 'AP91'); //Pagamentos registrados. - Pode existir mais de 1 pagamento com uma mesma categoria (exceto para Quitacao). - A soma dos pagamentos c/ categoria Adiantamento, deverá ter o mesmo valor apontado na tag TotalAdiantamento da tag Viagem/Valores, e neste caso, a tag Documento do pagamento deverá conter o mesmo valor da tag DocumentoViagem da tag Viagem . - Se a viagem possuir a tag TotalQuitacao maior que zero, deverá ter um pagamento correspondente, com Categoria Quitacao e com o Documento o mesmo valor apontado na tag DocumentoViagem .
              Gerador.wCampo(tcStr, 'AP92', 'Categoria', 001, 001, 1, TpCatPagToStr(Categoria), 'Categoria relacionada ao pagamento realizado. Restrita aos membros da ENUM: -Adiantamento, -Estadia, Quitacao, -SemCategoria ', ' ' + NAME_SPACE_EFRETE_OPERACAOTRANSPORTE_EFRETE);
              Gerador.wCampo(tcDat, 'AP93', 'DataDeLiberacao', 001, 001, 1, DataDeLiberacao);
              Gerador.wCampo(tcStr, 'AP94', 'Documento', 001, 020, 1, Documento, 'Documento relacionado a viagem.');
              Gerador.wCampo(tcStr, 'AP94', 'IdPagamentoCliente', 001, 020, 1, IdPagamentoCliente, 'Identificador do pagamento no sistema do Cliente. ');
              Gerador.wCampo(tcStr, 'AP95', 'InformacaoAdicional', 001, 000, 0, InformacaoAdicional, '');

              Gerador.wGrupo('InformacoesBancarias ' + NAME_SPACE_EFRETE_OPERACAOTRANSPORTE_EFRETE, 'AP97');
              with InformacoesBancarias do
              begin
                Gerador.wCampo(tcStr, 'AP98', 'Agencia', 001, 001, 1, Agencia);
                Gerador.wCampo(tcStr, 'AP99', 'Conta', 001, 001, 1, Conta);
                Gerador.wCampo(tcStr, 'AP100', 'InstituicaoBancaria', 001, 001, 1, InstituicaoBancaria);
              end;
              Gerador.wGrupo('/InformacoesBancarias');
                          
              Gerador.wCampo(tcStr, 'AP101', 'TipoPagamento', 001, 020, 1, TpPagamentoToStr(TipoPagamento), 'Tipo de pagamento que será usado pelo contratante. Restrito aos itens da enum: -TransferenciaBancaria -eFRETE', ' ' + NAME_SPACE_EFRETE_OPERACAOTRANSPORTE_EFRETE);
              Gerador.wCampo(tcDe2, 'AP102', 'Valor', 001, 020, 1, Valor, 'Valor do pagamento.');
              Gerador.wGrupo('/Pagamentos');
            end;
          end;
        end;

        if (FOperacaoTransporte.PesoCarga > 0) and (FOperacaoTransporte.TipoViagem = Padrao) then
          Gerador.wCampo(tcDe6, 'AP103', 'PesoCarga', 001, 001, 1, FOperacaoTransporte.PesoCarga, 'Peso total da carga.');

        if FOperacaoTransporte.Subcontratante.CpfOuCnpj <> '' then
        begin
          Gerador.wGrupo('Subcontratante', 'AP104');
          Gerador.wCampo(tcStr, 'AP105', 'CpfOuCnpj', 001, 001, 1, FOperacaoTransporte.Subcontratante.CpfOuCnpj);
          Gerador.wCampo(tcStr, 'AP106', 'EMail', 001, 001, 1, FOperacaoTransporte.Subcontratante.EMail);

          with FOperacaoTransporte.Subcontratante do
          begin
            Gerador.wGrupo('Endereco', 'AP107');
            Gerador.wCampo(tcStr, 'AP108', 'Bairro', 001, 001, 1, Endereco.Bairro, '', ' ' + NAME_SPACE_EFRETE_OBJECTS);
            Gerador.wCampo(tcStr, 'AP109', 'CEP', 001, 009, 1, Copy(Endereco.CEP, 1, 5) + '-' + Copy(Endereco.CEP, 6, 3), '', ' ' + NAME_SPACE_EFRETE_OBJECTS);
            Gerador.wCampo(tcStr, 'AP110', 'CodigoMunicipio', 001, 007, 1, Endereco.CodigoMunicipio, '', ' ' + NAME_SPACE_EFRETE_OBJECTS);
            Gerador.wCampo(tcStr, 'AP112', 'Rua', 001, 001, 1, Endereco.Rua, '', ' ' + NAME_SPACE_EFRETE_OBJECTS);
            Gerador.wCampo(tcStr, 'AP113', 'Numero', 001, 001, 1, Endereco.Numero, '', ' ' + NAME_SPACE_EFRETE_OBJECTS);
            Gerador.wCampo(tcStr, 'AP114', 'Complemento', 001, 001, 1, Endereco.Complemento, '', ' ' + NAME_SPACE_EFRETE_OBJECTS);
            Gerador.wGrupo('/Endereco');
          end;
                                           
          Gerador.wCampo(tcStr, 'AP115', 'NomeOuRazaoSocial', 001, 001, 1, FOperacaoTransporte.Subcontratante.NomeOuRazaoSocial, 'Nome ou Razão Social do Contratante.');
          Gerador.wCampo(tcStr, 'AP116', 'ResponsavelPeloPagamento', 001, 001, 1, LowerCase(BoolToStr(FOperacaoTransporte.Subcontratante.ResponsavelPeloPagamento, true)), 'Informar se é o responsável pelo pagamento da Operação de Transporte. True = Sim. False = Não');

          with FOperacaoTransporte.Subcontratante.Telefones do
          begin
            Gerador.wGrupo('Telefones', 'AP117');
            Gerador.wGrupo('Celular ' + NAME_SPACE_EFRETE_OBJECTS, 'AP117');
            Gerador.wCampo(tcInt, 'AP119', 'DDD', 001, 002, 1, Celular.DDD, '');
            Gerador.wCampo(tcInt, 'AP120', 'Numero', 001, 009, 1, Celular.Numero, '');
            Gerador.wGrupo('/Celular');

            Gerador.wGrupo('Fax ' + NAME_SPACE_EFRETE_OBJECTS, 'AP121');
            Gerador.wCampo(tcInt, 'AP122', 'DDD', 001, 002, 1, Fax.DDD, '');
            Gerador.wCampo(tcInt, 'AP123', 'Numero', 001, 009, 1, Fax.Numero, '');
            Gerador.wGrupo('/Fax');

            Gerador.wGrupo('Fixo ' + NAME_SPACE_EFRETE_OBJECTS, 'AP124');
            Gerador.wCampo(tcInt, 'AP125', 'DDD', 001, 002, 1, Fixo.DDD, '');
            Gerador.wCampo(tcInt, 'AP126', 'Numero', 001, 009, 1, Fixo.Numero, '');
            Gerador.wGrupo('/Fixo');
            Gerador.wGrupo('/Telefones');
          end;
          Gerador.wGrupo('/Subcontratante');
        end
        else
          Gerador.wCampo(tcStr, 'AP104', 'Subcontratante', 001, 001, 1, '');
       
        Gerador.wCampo(tcStr, 'AP127', 'TipoViagem', 001, 001, 1, TpViagemToStr(FOperacaoTransporte.TipoViagem), 'Restrito aos itens da enum: -SemVinculoANTT -Padrao -TAC_Agregado');

        Gerador.wGrupo('Veiculos ' + NAME_SPACE_EFRETE_PEFADICIONAR_OBJECTS, 'AP129');
        for I := 0 to FOperacaoTransporte.Veiculos.Count -1 do
        begin                                                       
          with FOperacaoTransporte.Veiculos.Items[I] do
            Gerador.wCampo(tcStr, 'AP130', 'Placa', 001, 001, 1, Placa, 'Placa do veículo conforme exemplo: AAA1234.');
        end;
        Gerador.wGrupo('/Veiculos');

        if FOperacaoTransporte.TipoViagem = Padrao then
        begin
          Gerador.wGrupo('Viagens ' + NAME_SPACE_EFRETE_PEFADICIONAR_OBJECTS, 'AP132');
          for I := 0 to FOperacaoTransporte.Viagens.Count -1 do
          begin
            with FOperacaoTransporte.Viagens.Items[I] do
            begin
              Gerador.wCampo(tcInt, 'AP133', 'CodigoMunicipioDestino', 001, 007, 1, CodigoMunicipioDestino);
              Gerador.wCampo(tcInt, 'AP134', 'CodigoMunicipioOrigem', 001, 007, 1, CodigoMunicipioOrigem);
              Gerador.wCampo(tcStr, 'AP135', 'DocumentoViagem', 001, 001, 1, DocumentoViagem, 'Exemplo: CT-e / Serie, CTRC / Serie, Ordem de Serviço.');

              Gerador.wGrupo('NotasFiscais', 'AP136');

              for J := 0 to NotasFiscais.Count -1 do
              begin
                with NotasFiscais.Items[J] do
                begin
                  Gerador.wGrupo('NotaFiscal');
                  Gerador.wCampo(tcInt, 'AP137', 'CodigoNCMNaturezaCarga', 001, 004, 1, CodigoNCMNaturezaCarga);
                  Gerador.wCampo(tcDat, 'AP138', 'Data', 001, 004, 1, Data);
                  Gerador.wCampo(tcStr, 'AP139', 'DescricaoDaMercadoria', 001, 060, 1, DescricaoDaMercadoria, 'Descrição adicional ao código NCM.');
                  Gerador.wCampo(tcStr, 'AP140', 'Numero', 001, 010, 1, Numero);
                  Gerador.wCampo(tcDe3, 'AP141', 'QuantidadeDaMercadoriaNoEmbarque', 001, 010, 1, QuantidadeDaMercadoriaNoEmbarque);
                  Gerador.wCampo(tcStr, 'AP142', 'Serie', 001, 001, 1, Serie);
                  Gerador.wCampo(tcStr, 'AP143', 'TipoDeCalculo', 001, 001, 1, TpVgTipoCalculoToStr(TipoDeCalculo));
                  Gerador.wGrupo('ToleranciaDePerdaDeMercadoria', 'AP144');
                  Gerador.wCampo(tcStr, 'AP145', 'Tipo', 001, 001, 1, TpProporcaoToStr(ToleranciaDePerdaDeMercadoria.Tipo));
                  Gerador.wCampo(tcDe2, 'AP146', 'Valor', 001, 001, 1, ToleranciaDePerdaDeMercadoria.Valor);
                  Gerador.wGrupo('/ToleranciaDePerdaDeMercadoria');

                  if DiferencaDeFrete.Tipo <> SemDiferenca then
                  begin
                    Gerador.wGrupo('DiferencaDeFrete', 'AP147');
                    Gerador.wCampo(tcStr, 'AP148', 'Tipo', 001, 001, 1, TpDifFreteToStr(DiferencaDeFrete.Tipo));
                    Gerador.wCampo(tcStr, 'AP149', 'Base', 001, 001, 1, TpDiferencaFreteBCToStr(DiferencaDeFrete.Base));
                    Gerador.wGrupo('Tolerancia', 'AP150');
                    Gerador.wCampo(tcStr, 'AP151', 'Tipo', 001, 001, 1, TpProporcaoToStr(DiferencaDeFrete.Tolerancia.Tipo));
                    Gerador.wCampo(tcDe2, 'AP152', 'Valor', 001, 001, 1, DiferencaDeFrete.Tolerancia.Valor);
                    Gerador.wGrupo('/Tolerancia');
                    Gerador.wGrupo('MargemGanho', 'AP153');
                    Gerador.wCampo(tcStr, 'AP154', 'Tipo', 001, 001, 1, TpProporcaoToStr(DiferencaDeFrete.MargemGanho.Tipo));
                    Gerador.wCampo(tcDe2, 'AP155', 'Valor', 001, 001, 1, DiferencaDeFrete.MargemGanho.Valor);
                    Gerador.wGrupo('/MargemGanho');
                    Gerador.wGrupo('MargemPerda', 'AP156');
                    Gerador.wCampo(tcStr, 'AP157', 'Tipo', 001, 001, 1, TpProporcaoToStr(DiferencaDeFrete.MargemPerda.Tipo));
                    Gerador.wCampo(tcDe2, 'AP158', 'Valor', 001, 001, 1, DiferencaDeFrete.MargemPerda.Valor);
                    Gerador.wGrupo('/MargemPerda');
                    Gerador.wGrupo('/DiferencaDeFrete');
                  end;

                  Gerador.wCampo(tcStr, 'AP159', 'UnidadeDeMedidaDaMercadoria', 001, 001, 1, TpUnMedMercToStr(UnidadeDeMedidaDaMercadoria));
                  Gerador.wCampo(tcDe2, 'AP159', 'ValorDaMercadoriaPorUnidade', 001, 001, 1, ValorDaMercadoriaPorUnidade);
                  Gerador.wCampo(tcDe2, 'AP159', 'ValorDoFretePorUnidadeDeMercadoria', 001, 001, 1, ValorDoFretePorUnidadeDeMercadoria);
                  Gerador.wCampo(tcDe2, 'AP159', 'ValorTotal', 001, 001, 1, ValorTotal);

                  Gerador.wGrupo('/NotaFiscal');
                end;
              end;
              Gerador.wGrupo('/NotasFiscais');

              Gerador.wGrupo('Valores ' + NAME_SPACE_EFRETE_OPERACAOTRANSPORTE_EFRETE, 'AP163');
              with Valores do
              begin
                Gerador.wCampo(tcDe2, 'AP164', 'Combustivel', 001, 001, 1, Combustivel);
                Gerador.wCampo(tcStr, 'AP165', 'JustificativaOutrosCreditos', 001, 001, 1, JustificativaOutrosCreditos);
                Gerador.wCampo(tcStr, 'AP166', 'JustificativaOutrosDebitos', 001, 001, 1, JustificativaOutrosDebitos);
                Gerador.wCampo(tcDe2, 'AP167', 'OutrosCreditos', 001, 001, 1, OutrosCreditos);
                Gerador.wCampo(tcDe2, 'AP168', 'OutrosDebitos', 001, 001, 1, OutrosDebitos);
                Gerador.wCampo(tcDe2, 'AP169', 'Pedagio', 001, 001, 1, Pedagio);
                Gerador.wCampo(tcDe2, 'AP170', 'Seguro', 001, 001, 1, Seguro);
                Gerador.wCampo(tcDe2, 'AP171', 'TotalDeAdiantamento', 001, 001, 1, TotalDeAdiantamento);
                Gerador.wCampo(tcDe2, 'AP172', 'TotalDeQuitacao', 001, 001, 1, TotalDeQuitacao);
                Gerador.wCampo(tcDe2, 'AP173', 'TotalOperacao', 001, 001, 1, TotalOperacao);
                Gerador.wCampo(tcDe2, 'AP174', 'TotalViagem', 001, 001, 1, TotalViagem);
              end;
              Gerador.wGrupo('/Valores');
            end;
          end;

          Gerador.wGrupo('/Viagens');
        end;

        Gerador.wCampo(tcStr, 'AP175', 'EmissaoGratuita', 001, 001, 1, LowerCase(BoolToStr(FOperacaoTransporte.EmissaoGratuita, True)));
        Gerador.wCampo(tcStr, 'AP176', 'ObservacoesAoTransportador', 001, 001, 1, FOperacaoTransporte.ObservacoesAoTransportador);
        Gerador.wCampo(tcStr, 'AP177', 'ObservacoesAoCredenciado', 001, 001, 1, FOperacaoTransporte.ObservacoesAoCredenciado);

        Gerador.wGrupo('/AdicionarOperacaoTransporteRequest');
     end;
    opRetificar:
      begin
        Gerador.wGrupo('RetificarOperacaoTransporteRequest ' + NAME_SPACE_EFRETE_OPERACAOTRANSPORTE_EFRETE, 'WP01');
        Gerador.wCampo(tcStr, 'WP08', 'Integrador', 001, 001, 1, TAmsCIOT( FOperacaoTransporte.Owner ).Configuracoes.Integradora.Identificacao, '', ' ' + NAME_SPACE_EFRETE_OBJECTS);
        Gerador.wCampo(tcStr, 'WP13', 'Versao', 001, 001, 1, 1, '', ' ' + NAME_SPACE_EFRETE_OBJECTS);
        Gerador.wCampo(tcStr, 'WP02', 'CodigoIdentificacaoOperacao', 001, 001, 1, FOperacaoTransporte.NumeroCIOT, '');
        Gerador.wCampo(tcInt, 'WP03', 'CodigoMunicipioDestino', 001, 007, 1, FOperacaoTransporte.Viagens.Items[0].CodigoMunicipioDestino); //0001
        Gerador.wCampo(tcInt, 'WP04', 'CodigoMunicipioOrigem', 001, 007, 1, FOperacaoTransporte.Viagens.Items[0].CodigoMunicipioOrigem); //0001
        Gerador.wCampo(tcInt, 'WP05', 'CodigoNCMNaturezaCarga', 001, 004, 1, FOperacaoTransporte.CodigoNCMNaturezaCarga); //0001
        Gerador.wCampo(tcDat, 'WP06', 'DataFimViagem', 001, 001, 1, FOperacaoTransporte.DataFimViagem); //0001
        Gerador.wCampo(tcDat, 'WP07', 'DataInicioViagem', 001, 001, 1, FOperacaoTransporte.DataInicioViagem); //0001
        Gerador.wCampo(tcDe6, 'WP09', 'PesoCarga', 001, 001, 1, FOperacaoTransporte.PesoCarga); //0001

        Gerador.wGrupo('Veiculos ' + NAME_SPACE_EFRETE_PEFRETIFICAR_OBJECTS, 'WP11');
        for I := 0 to FOperacaoTransporte.Veiculos.Count -1 do
        begin
          with FOperacaoTransporte.Veiculos.Items[I] do
            Gerador.wCampo(tcStr, 'WP12', 'Placa', 001, 001, 1, Placa, 'Placa do veículo conforme exemplo: AAA1234.');
        end;
        Gerador.wGrupo('/Veiculos');
        Gerador.wGrupo('/RetificarOperacaoTransporteRequest');
      end;
    opCancelar:
      begin
        Gerador.wGrupo('CancelarOperacaoTransporteRequest ' + NAME_SPACE_EFRETE_OPERACAOTRANSPORTE_EFRETE, 'KP01');
        Gerador.wCampo(tcStr, 'KP03', 'Integrador', 001, 001, 1, TAmsCIOT( FOperacaoTransporte.Owner ).Configuracoes.Integradora.Identificacao, '', ' ' + NAME_SPACE_EFRETE_OBJECTS);
        Gerador.wCampo(tcStr, 'KP06', 'Versao', 001, 001, 1, 1, '', ' ' + NAME_SPACE_EFRETE_OBJECTS);
        Gerador.wCampo(tcStr, 'KP02', 'CodigoIdentificacaoOperacao', 001, 001, 1, FOperacaoTransporte.NumeroCIOT, '');
        Gerador.wCampo(tcStr, 'KP04', 'Motivo', 001, 001, 1, FOperacaoTransporte.Cancelamento.Motivo, '');
        Gerador.wGrupo('/CancelarOperacaoTransporteRequest');
      end;
    opAdicionarViagem:
      begin
        if FOperacaoTransporte.TipoViagem = TAC_Agregado then
        begin
          Gerador.wGrupo('AdicionarViagemRequest ' + NAME_SPACE_EFRETE_OPERACAOTRANSPORTE_EFRETE);
          Gerador.wCampo(tcStr, '', 'Integrador', 001, 001, 1, TAmsCIOT( FOperacaoTransporte.Owner ).Configuracoes.Integradora.Identificacao, '', ' ' + NAME_SPACE_EFRETE_OBJECTS);
          Gerador.wCampo(tcStr, '', 'Versao', 001, 001, 1, 2, '', ' ' + NAME_SPACE_EFRETE_OBJECTS);
          Gerador.wCampo(tcStr, '', 'CodigoIdentificacaoOperacao', 001, 030, 1, FOperacaoTransporte.NumeroCIOT, '');
          Gerador.wGrupo('Viagens ' + NAME_SPACE_EFRETE_PEFADICIONAR_VIAGEM, '');

          for I := 0 to FOperacaoTransporte.Viagens.Count -1 do
          begin
            Gerador.wGrupo('Viagem');
            with FOperacaoTransporte.Viagens.Items[I] do
            begin
              Gerador.wCampo(tcInt, 'AP133', 'CodigoMunicipioDestino', 001, 007, 1, CodigoMunicipioDestino);
              Gerador.wCampo(tcInt, 'AP134', 'CodigoMunicipioOrigem', 001, 007, 1, CodigoMunicipioOrigem);
              Gerador.wCampo(tcStr, 'AP135', 'DocumentoViagem', 001, 001, 1, DocumentoViagem, 'Exemplo: CT-e / Serie, CTRC / Serie, Ordem de Serviço.');

              for J := 0 to NotasFiscais.Count -1 do
              begin
                with NotasFiscais.Items[J] do
                begin
                  Gerador.wGrupo('NotasFiscais');
                  Gerador.wCampo(tcInt, 'AP137', 'CodigoNCMNaturezaCarga', 001, 004, 1, CodigoNCMNaturezaCarga);
                  Gerador.wCampo(tcDat, 'AP138', 'Data', 001, 004, 1, Data);
                  Gerador.wCampo(tcStr, 'AP139', 'DescricaoDaMercadoria', 001, 060, 1, DescricaoDaMercadoria, 'Descrição adicional ao código NCM.');
                  Gerador.wCampo(tcStr, 'AP140', 'Numero', 001, 010, 1, Numero);
                  Gerador.wCampo(tcDe3, 'AP141', 'QuantidadeDaMercadoriaNoEmbarque', 001, 010, 1, QuantidadeDaMercadoriaNoEmbarque);
                  Gerador.wCampo(tcStr, 'AP142', 'Serie', 001, 001, 1, Serie);
                  Gerador.wCampo(tcStr, 'AP143', 'TipoDeCalculo', 001, 001, 1, TpVgTipoCalculoToStr(TipoDeCalculo));
                  Gerador.wGrupo('ToleranciaDePerdaDeMercadoria', 'AP144');
                  Gerador.wCampo(tcStr, 'AP145', 'Tipo', 001, 001, 1, TpProporcaoToStr(ToleranciaDePerdaDeMercadoria.Tipo));
                  Gerador.wCampo(tcDe2, 'AP146', 'Valor', 001, 001, 1, ToleranciaDePerdaDeMercadoria.Valor);
                  Gerador.wGrupo('/ToleranciaDePerdaDeMercadoria');

                  if DiferencaDeFrete.Tipo <> SemDiferenca then
                  begin
                    Gerador.wGrupo('DiferencaDeFrete', 'AP147');
                    Gerador.wCampo(tcStr, 'AP148', 'Tipo', 001, 001, 1, TpDifFreteToStr(DiferencaDeFrete.Tipo));
                    Gerador.wCampo(tcStr, 'AP149', 'Base', 001, 001, 1, TpDiferencaFreteBCToStr(DiferencaDeFrete.Base));
                    Gerador.wGrupo('Tolerancia', 'AP150');
                    Gerador.wCampo(tcStr, 'AP151', 'Tipo', 001, 001, 1, TpProporcaoToStr(DiferencaDeFrete.Tolerancia.Tipo));
                    Gerador.wCampo(tcDe2, 'AP152', 'Valor', 001, 001, 1, DiferencaDeFrete.Tolerancia.Valor);
                    Gerador.wGrupo('/Tolerancia');
                    Gerador.wGrupo('MargemGanho', 'AP153');
                    Gerador.wCampo(tcStr, 'AP154', 'Tipo', 001, 001, 1, TpProporcaoToStr(DiferencaDeFrete.MargemGanho.Tipo));
                    Gerador.wCampo(tcDe2, 'AP155', 'Valor', 001, 001, 1, DiferencaDeFrete.MargemGanho.Valor);
                    Gerador.wGrupo('/MargemGanho');
                    Gerador.wGrupo('MargemPerda', 'AP156');
                    Gerador.wCampo(tcStr, 'AP157', 'Tipo', 001, 001, 1, TpProporcaoToStr(DiferencaDeFrete.MargemPerda.Tipo));
                    Gerador.wCampo(tcDe2, 'AP158', 'Valor', 001, 001, 1, DiferencaDeFrete.MargemPerda.Valor);
                    Gerador.wGrupo('/MargemPerda');
                    Gerador.wGrupo('/DiferencaDeFrete');
                  end;

                  Gerador.wCampo(tcStr, 'AP159', 'UnidadeDeMedidaDaMercadoria', 001, 001, 1, TpUnMedMercToStr(UnidadeDeMedidaDaMercadoria));
                  Gerador.wCampo(tcDe2, 'AP159', 'ValorDaMercadoriaPorUnidade', 001, 001, 1, ValorDaMercadoriaPorUnidade);
                  Gerador.wCampo(tcDe2, 'AP159', 'ValorDoFretePorUnidadeDeMercadoria', 001, 001, 1, ValorDoFretePorUnidadeDeMercadoria);
                  Gerador.wCampo(tcDe2, 'AP159', 'ValorTotal', 001, 001, 1, ValorTotal);

                  Gerador.wGrupo('/NotasFiscais');
                end;
              end;

              Gerador.wGrupo('Valores ' + NAME_SPACE_EFRETE_OPERACAOTRANSPORTE_EFRETE, 'AP163');
              with Valores do
              begin
                Gerador.wCampo(tcDe2, 'AP164', 'Combustivel', 001, 001, 1, Combustivel);
                Gerador.wCampo(tcStr, 'AP165', 'JustificativaOutrosCreditos', 001, 001, 1, JustificativaOutrosCreditos);
                Gerador.wCampo(tcStr, 'AP166', 'JustificativaOutrosDebitos', 001, 001, 1, JustificativaOutrosDebitos);
                Gerador.wCampo(tcDe2, 'AP167', 'OutrosCreditos', 001, 001, 1, OutrosCreditos);
                Gerador.wCampo(tcDe2, 'AP168', 'OutrosDebitos', 001, 001, 1, OutrosDebitos);
                Gerador.wCampo(tcDe2, 'AP169', 'Pedagio', 001, 001, 1, Pedagio);
                Gerador.wCampo(tcDe2, 'AP170', 'Seguro', 001, 001, 1, Seguro);
                Gerador.wCampo(tcDe2, 'AP171', 'TotalDeAdiantamento', 001, 001, 1, TotalDeAdiantamento);
                Gerador.wCampo(tcDe2, 'AP172', 'TotalDeQuitacao', 001, 001, 1, TotalDeQuitacao);
                Gerador.wCampo(tcDe2, 'AP173', 'TotalOperacao', 001, 001, 1, TotalOperacao);
                Gerador.wCampo(tcDe2, 'AP174', 'TotalViagem', 001, 001, 1, TotalViagem);
              end;
              Gerador.wGrupo('/Valores');
            end;

            Gerador.wGrupo('/Viagem');
          end;

          Gerador.wGrupo('/Viagens');

          Gerador.wGrupo('Pagamentos ' + NAME_SPACE_EFRETE_PEFADICIONAR_VIAGEM, '');

          for I := 0 to FOperacaoTransporte.Pagamentos.Count -1 do
          begin
            with FOperacaoTransporte.Pagamentos.Items[I] do
            begin
              Gerador.wGrupo('Pagamento');
              Gerador.wCampo(tcStr, 'AP92', 'Categoria', 001, 001, 1, TpCatPagToStr(Categoria), 'Categoria relacionada ao pagamento realizado. Restrita aos membros da ENUM: -Adiantamento, -Estadia, Quitacao, -SemCategoria ', ' ' + NAME_SPACE_EFRETE_OPERACAOTRANSPORTE_EFRETE);
              Gerador.wCampo(tcDat, 'AP93', 'DataDeLiberacao', 001, 001, 1, DataDeLiberacao);
              Gerador.wCampo(tcStr, 'AP94', 'Documento', 001, 020, 1, Documento, 'Documento relacionado a viagem.');
              Gerador.wCampo(tcStr, 'AP94', 'IdPagamentoCliente', 001, 020, 1, IdPagamentoCliente, 'Identificador do pagamento no sistema do Cliente. ');
              Gerador.wCampo(tcStr, 'AP95', 'InformacaoAdicional', 001, 000, 0, InformacaoAdicional, '');

              Gerador.wGrupo('InformacoesBancarias ' + NAME_SPACE_EFRETE_OPERACAOTRANSPORTE_EFRETE, 'AP97');
              with InformacoesBancarias do
              begin
                Gerador.wCampo(tcStr, 'AP98', 'Agencia', 001, 001, 1, Agencia);
                Gerador.wCampo(tcStr, 'AP99', 'Conta', 001, 001, 1, Conta);
                Gerador.wCampo(tcStr, 'AP100', 'InstituicaoBancaria', 001, 001, 1, InstituicaoBancaria);
              end;
              Gerador.wGrupo('/InformacoesBancarias');

              Gerador.wCampo(tcStr, 'AP101', 'TipoPagamento', 001, 020, 1, TpPagamentoToStr(TipoPagamento), 'Tipo de pagamento que será usado pelo contratante. Restrito aos itens da enum: -TransferenciaBancaria -eFRETE', ' ' + NAME_SPACE_EFRETE_OPERACAOTRANSPORTE_EFRETE);
              Gerador.wCampo(tcDe2, 'AP102', 'Valor', 001, 020, 1, Valor, 'Valor do pagamento.');
              Gerador.wGrupo('/Pagamento');
            end;
          end;

          Gerador.wGrupo('/Pagamentos');

          Gerador.wCampo(tcStr, '', 'NaoAdicionarParcialmente', 001, 001, 1, 'false', '');
          Gerador.wGrupo('/AdicionarViagemRequest');
        end;
      end;
    opAdicionarPagamento:
      begin
        if FOperacaoTransporte.TipoViagem = TAC_Agregado then
        begin
          Gerador.wGrupo('AdicionarPagamentoRequest ' + NAME_SPACE_EFRETE_OPERACAOTRANSPORTE_EFRETE);
          Gerador.wCampo(tcStr, '', 'Integrador', 001, 001, 1, TAmsCIOT( FOperacaoTransporte.Owner ).Configuracoes.Integradora.Identificacao, '', ' ' + NAME_SPACE_EFRETE_OBJECTS);
          Gerador.wCampo(tcStr, '', 'Versao', 001, 001, 1, 2, '', ' ' + NAME_SPACE_EFRETE_OBJECTS);
          Gerador.wCampo(tcStr, '', 'CodigoIdentificacaoOperacao', 001, 030, 1, FOperacaoTransporte.NumeroCIOT, '');
          Gerador.wGrupo('Pagamentos ' + NAME_SPACE_EFRETE_PEFADICIONAR_PAGAMENTOS, '');

          for I := 0 to FOperacaoTransporte.Pagamentos.Count -1 do
          begin
            with FOperacaoTransporte.Pagamentos.Items[I] do
            begin
              Gerador.wGrupo('Pagamento');
              Gerador.wCampo(tcStr, 'AP92', 'Categoria', 001, 001, 1, TpCatPagToStr(Categoria), 'Categoria relacionada ao pagamento realizado. Restrita aos membros da ENUM: -Adiantamento, -Estadia, Quitacao, -SemCategoria ', ' ' + NAME_SPACE_EFRETE_OPERACAOTRANSPORTE_EFRETE);
              Gerador.wCampo(tcDat, 'AP93', 'DataDeLiberacao', 001, 001, 1, DataDeLiberacao);
              Gerador.wCampo(tcStr, 'AP94', 'Documento', 001, 020, 1, Documento, 'Documento relacionado a viagem.');
              Gerador.wCampo(tcStr, 'AP94', 'IdPagamentoCliente', 001, 020, 1, IdPagamentoCliente, 'Identificador do pagamento no sistema do Cliente. ');
              Gerador.wCampo(tcStr, 'AP95', 'InformacaoAdicional', 001, 000, 0, InformacaoAdicional, '');

              Gerador.wGrupo('InformacoesBancarias ' + NAME_SPACE_EFRETE_OPERACAOTRANSPORTE_EFRETE, 'AP97');
              with InformacoesBancarias do
              begin
                Gerador.wCampo(tcStr, 'AP98', 'Agencia', 001, 001, 1, Agencia);
                Gerador.wCampo(tcStr, 'AP99', 'Conta', 001, 001, 1, Conta);
                Gerador.wCampo(tcStr, 'AP100', 'InstituicaoBancaria', 001, 001, 1, InstituicaoBancaria);
              end;
              Gerador.wGrupo('/InformacoesBancarias');

              Gerador.wCampo(tcStr, 'AP101', 'TipoPagamento', 001, 020, 1, TpPagamentoToStr(TipoPagamento), 'Tipo de pagamento que será usado pelo contratante. Restrito aos itens da enum: -TransferenciaBancaria -eFRETE', ' ' + NAME_SPACE_EFRETE_OPERACAOTRANSPORTE_EFRETE);
              Gerador.wCampo(tcDe2, 'AP102', 'Valor', 001, 020, 1, Valor, 'Valor do pagamento.');
              Gerador.wGrupo('/Pagamento');
            end;
          end;

          Gerador.wGrupo('/Pagamentos');
          Gerador.wGrupo('/AdicionarPagamentoRequest');
        end;
      end;
    opCancelarPagamento:
      begin
        if FOperacaoTransporte.TipoViagem = TAC_Agregado then
        begin
          Gerador.wGrupo('CancelarPagamentoRequest ' + NAME_SPACE_EFRETE_OPERACAOTRANSPORTE_EFRETE);
          Gerador.wCampo(tcStr, '', 'Integrador', 001, 001, 1, TAmsCIOT( FOperacaoTransporte.Owner ).Configuracoes.Integradora.Identificacao, '', ' ' + NAME_SPACE_EFRETE_OBJECTS);
          Gerador.wCampo(tcStr, '', 'Versao', 001, 001, 1, 1, '', ' ' + NAME_SPACE_EFRETE_OBJECTS);
          Gerador.wCampo(tcStr, '', 'CodigoIdentificacaoOperacao', 001, 030, 1, FOperacaoTransporte.NumeroCIOT, '');
          Gerador.wCampo(tcStr, '', 'IdPagamentoCliente', 001, 020, 1, FOperacaoTransporte.Cancelamento.IdPagamentoCliente, 'Identificador do pagamento no sistema do Cliente. ');
          Gerador.wCampo(tcStr, 'KP04', 'Motivo', 001, 001, 1, FOperacaoTransporte.Cancelamento.Motivo, '');
          Gerador.wGrupo('/CancelarPagamentoRequest');
        end;
      end;
    opEncerrar:
      begin
        Gerador.wGrupo('EncerrarOperacaoTransporteRequest ' + NAME_SPACE_EFRETE_OPERACAOTRANSPORTE_EFRETE);
        Gerador.wCampo(tcStr, '', 'Integrador', 001, 001, 1, TAmsCIOT( FOperacaoTransporte.Owner ).Configuracoes.Integradora.Identificacao, '', ' ' + NAME_SPACE_EFRETE_OBJECTS);
        Gerador.wCampo(tcStr, '', 'Versao', 001, 001, 1, 1, '', ' ' + NAME_SPACE_EFRETE_OBJECTS);
        Gerador.wCampo(tcStr, '', 'CodigoIdentificacaoOperacao', 001, 030, 1, FOperacaoTransporte.NumeroCIOT, '');
        Gerador.wCampo(tcDe6, '', 'PesoCarga', 001, 001, 1, FOperacaoTransporte.PesoCarga, 'Peso total da carga.');

        Gerador.wGrupo('Impostos', 'AP78');
        Gerador.wCampo(tcStr, 'AP79', 'DescricaoOutrosImpostos', 001, 001, 1, FOperacaoTransporte.Impostos.DescricaoOutrosImpostos);
        Gerador.wCampo(tcDe2, 'AP80', 'INSS', 001, 020, 1, FOperacaoTransporte.Impostos.INSS, 'Valor destinado ao INSS. Este valor deverá fazer parte do valor de Adiantamento ou do valor de Quitação.');
        Gerador.wCampo(tcDe2, 'AP81', 'IRRF', 001, 020, 1, FOperacaoTransporte.Impostos.IRRF, 'Valor destinado ao IRRF. Este valor deverá fazer parte do valor de Adiantamento ou do valor de Quitação.');
        Gerador.wCampo(tcDe2, 'AP82', 'ISSQN', 001, 020, 1, FOperacaoTransporte.Impostos.ISSQN, 'Valor destinado ao ISSQN. Este valor deverá fazer parte do valor de Adiantamento ou do valor de Quitação.');
        Gerador.wCampo(tcDe2, 'AP83', 'OutrosImpostos', 001, 020, 1, FOperacaoTransporte.Impostos.OutrosImpostos, 'Valor destinado a outros impostos não previstos. Este valor deverá fazer parte do valor de Adiantamento ou do valor de Quitação.');
        Gerador.wCampo(tcDe2, 'AP84', 'SestSenat', 001, 020, 1, FOperacaoTransporte.Impostos.SestSenat, 'Valor destinado ao SEST / SENAT. Este valor deverá fazer parte do valor de Adiantamento ou do valor de Quitação.');
        Gerador.wGrupo('/Impostos');

        Gerador.wGrupo('/EncerrarOperacaoTransporteRequest');
      end;
  end;
  
  Result := (Gerador.ListaDeAlertas.Count = 0);
end;

end.

