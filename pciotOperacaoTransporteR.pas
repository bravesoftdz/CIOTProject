{$I ACBr.inc}

unit pciotOperacaoTransporteR;

interface

uses
  SysUtils, Classes,
{$IFNDEF VER130}
  Variants,
{$ENDIF}
  pcnAuxiliar, pcnConversao, pciotCIOT, Dialogs,

  SOAPHTTPTrans, WinInet, SOAPConst, Soap.InvokeRegistry, ASCIOTUtil, ACBRUtil,

  IdCoderMIME;

type

  TOperacaoTransporteR = class(TPersistent)
  private
    FLeitor: TLeitor;
    FOperacaoTransporte: TOperacaoTransporte;
    FSucesso: Boolean;
    FMensagem: String;

    FOperacao: TpciotOperacao;
  public
    constructor Create(AOwner: TOperacaoTransporte; AOperacao: TpciotOperacao = opObter);
    destructor Destroy; override;
    function LerXml: boolean;

    property Sucesso: Boolean read FSucesso write FSucesso;
    property Mensagem: String read FMensagem write FMensagem;
  published
    property Leitor: TLeitor read FLeitor write FLeitor;
    property OperacaoTransporte: TOperacaoTransporte read FOperacaoTransporte write FOperacaoTransporte;
  end;

implementation

{ TOperacaoTransporteR }

uses ASCIOT;

constructor TOperacaoTransporteR.Create(AOwner: TOperacaoTransporte; AOperacao: TpciotOperacao = opObter);
begin
  FLeitor := TLeitor.Create;
  FOperacaoTransporte := AOwner;
  FOperacao := AOperacao;
end;

destructor TOperacaoTransporteR.Destroy;
begin
  FLeitor.Free;
  inherited Destroy;
end;

function TOperacaoTransporteR.LerXml: boolean;
var
  ok: boolean;
  utf8: UTF8String;
  sPDF: WideString;
  stream: TMemoryStream;
  decoder: TIdDecoderMIME;
  sNomeArquivo: string;
  sArquivo: string;
begin
  case FOperacao of
    opObter:
      begin
        if Leitor.rExtrai(1, 'ObterOperacaoTransportePdfResult') <> '' then
        begin
          FSucesso := Leitor.rCampo(tcStr, 'Sucesso ' + NAME_SPACE_EFRETE_OBJECTS, '/Sucesso') = 'true';
          FMensagem := Leitor.rCampo(tcStr, 'Mensagem');

          sPDF := Leitor.rCampo(tcEsp, 'Pdf');

          try
            decoder := TIdDecoderMIME.Create(nil);
            stream := TMemoryStream.Create;

            decoder.DecodeStream(sPDF, stream);
            setString(utf8, PChar(stream.Memory), stream.Size);

            sArquivo := StringReplace(StringReplace(FOperacaoTransporte.NumeroCIOT, '\', '_', []), '/', '_', []) + '.pdf';

            sNomeArquivo := PathWithDelim(TAmSCIOT( FOperacaoTransporte.Owner ).Configuracoes.Arquivos.PathPDF);

            if not DirectoryExists(sNomeArquivo) then
              ForceDirectories(sNomeArquivo);

            sNomeArquivo := sNomeArquivo + sArquivo;

            stream.SaveToFile(sNomeArquivo);
          finally
            decoder.Free;
            stream.Free;
          end;
        end;
      end;
    opAdicionar:
      begin
        if Leitor.rExtrai(1, 'AdicionarOperacaoTransporteResult') <> '' then
        begin
          FSucesso := Leitor.rCampo(tcStr, 'Sucesso ' + NAME_SPACE_EFRETE_OBJECTS, '/Sucesso') = 'true';
          FMensagem := Leitor.rCampo(tcStr, 'Mensagem');
          FOperacaoTransporte.NumeroCIOT := Leitor.rCampo(tcStr, 'CodigoIdentificacaoOperacao');
        end;
      end;
    opRetificar:
      begin
        if Leitor.rExtrai(1, 'RetificarOperacaoTransporteResult') <> '' then
        begin
          FSucesso := Leitor.rCampo(tcStr, 'Sucesso ' + NAME_SPACE_EFRETE_OBJECTS, '/Sucesso') = 'true';
          FMensagem := Leitor.rCampo(tcStr, 'Mensagem');
          FOperacaoTransporte.DataRetificacao := Leitor.rCampo(tcDat, 'DataRetificacao');
        end;
      end;
    opCancelar:
      begin
        if Leitor.rExtrai(1, 'CancelarOperacaoTransporteResult') <> '' then
        begin
          FSucesso := Leitor.rCampo(tcStr, 'Sucesso ' + NAME_SPACE_EFRETE_OBJECTS, '/Sucesso') = 'true';
          FMensagem := Leitor.rCampo(tcStr, 'Mensagem');
          FOperacaoTransporte.Cancelamento.Data := Leitor.rCampo(tcDat, 'Data');
          FOperacaoTransporte.Cancelamento.Protocolo := Leitor.rCampo(tcStr, 'Protocolo');
        end;
      end;
    opAdicionarViagem:
      begin
        if Leitor.rExtrai(1, 'AdicionarViagemResult') <> '' then
        begin
          FSucesso := Leitor.rCampo(tcStr, 'Sucesso ' + NAME_SPACE_EFRETE_OBJECTS, '/Sucesso') = 'true';
          FMensagem := Leitor.rCampo(tcStr, 'Mensagem');

          if FSucesso then
          begin
            FMensagem := Leitor.rExtrai(1, 'AdicionarViagemResult');
          end;
        end;
      end;
    opAdicionarPagamento:
      begin
        if Leitor.rExtrai(1, 'AdicionarPagamentoResult') <> '' then
        begin
          FSucesso := Leitor.rCampo(tcStr, 'Sucesso ' + NAME_SPACE_EFRETE_OBJECTS, '/Sucesso') = 'true';
          FMensagem := Leitor.rCampo(tcStr, 'Mensagem');

          if FSucesso then
          begin
            FMensagem := Leitor.rExtrai(1, 'AdicionarPagamentoResult');
          end;
        end;
      end;
    opCancelarPagamento:
      begin
        if Leitor.rExtrai(1, 'CancelarPagamentoResult') <> '' then
        begin
          FSucesso := Leitor.rCampo(tcStr, 'Sucesso ' + NAME_SPACE_EFRETE_OBJECTS, '/Sucesso') = 'true';
          FMensagem := Leitor.rCampo(tcStr, 'Mensagem');
        end;
      end;
    opEncerrar:
      begin
        if Leitor.rExtrai(1, 'EncerrarOperacaoTransporteResult') <> '' then
        begin
          FSucesso := Leitor.rCampo(tcStr, 'Sucesso ' + NAME_SPACE_EFRETE_OBJECTS, '/Sucesso') = 'true';
          FMensagem := Leitor.rCampo(tcStr, 'Mensagem');
          FOperacaoTransporte.ProtocoloEncerramento := Leitor.rCampo(tcStr, 'Protocolo');
        end;
      end;
  end;

  Result := true;
end;

end.

