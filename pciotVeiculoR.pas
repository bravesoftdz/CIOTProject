{$I ACBr.inc}

unit pciotVeiculoR;

interface

uses
  SysUtils, Classes,
{$IFNDEF VER130}
  Variants,
{$ENDIF}
  pcnConversao, pciotCIOT, ASCIOTUtil;

type

  TVeiculoR = class(TPersistent)
  private
    FLeitor: TLeitor;
    FVeiculo: TVeiculo;
    FSucesso: Boolean;
    FMensagem: String;

    FOperacao: TpciotOperacao;
  public
    constructor Create(AOwner: TVeiculo; AOperacao: TpciotOperacao = opObter);
    destructor Destroy; override;
    function LerXml: boolean;
  published
    property Leitor: TLeitor read FLeitor write FLeitor;
    property Veiculo: TVeiculo read FVeiculo write FVeiculo;
    property Sucesso: Boolean read FSucesso write FSucesso;
    property Mensagem: String read FMensagem write FMensagem;
  end;

implementation

{ TVeiculoR }

constructor TVeiculoR.Create(AOwner: TVeiculo; AOperacao: TpciotOperacao = opObter);
begin
  FLeitor := TLeitor.Create;
  FVeiculo := AOwner;
  FOperacao := AOperacao;
end;

destructor TVeiculoR.Destroy;
begin
  FLeitor.Free;
  inherited Destroy;
end;

function TVeiculoR.LerXml: boolean;
var
  ok: boolean;
begin
  case FOperacao of
    opObter:
      begin
        if Leitor.rExtrai(1, 'ObterPorPlacaRequest') <> '' then
        begin
          FSucesso := Leitor.rCampo(tcStr, 'Sucesso ' + NAME_SPACE_EFRETE_OBJECTS, '/Sucesso') = 'true';
          FMensagem := Leitor.rCampo(tcStr, 'Mensagem');
        end;
      end;
    opAdicionar:
      begin
        if Leitor.rExtrai(1, 'GravarResult') <> '' then //GravarResponse
        begin
          FSucesso := Leitor.rCampo(tcStr, 'Sucesso ' + NAME_SPACE_EFRETE_OBJECTS, '/Sucesso') = 'true';
          FMensagem := Leitor.rCampo(tcStr, 'Mensagem');
        end;
      end;
  end;

  if Leitor.rExtrai(1, 'Veiculo') <> '' then
  begin
    Veiculo.AnoFabricacao := Leitor.rCampo(tcInt, 'AnoFabricacao');
    Veiculo.AnoModelo := Leitor.rCampo(tcInt, 'AnoModelo');
    Veiculo.CapacidadeKg := Leitor.rCampo(tcInt, 'CapacidadeKg');
    Veiculo.CapacidadeM3 := Leitor.rCampo(tcInt, 'CapacidadeM3');
    Veiculo.Chassi := Leitor.rCampo(tcStr, 'Chassi');
    Veiculo.Placa := Leitor.rCampo(tcStr, 'Placa');
    Veiculo.Cor := Leitor.rCampo(tcStr, 'Cor');
    Veiculo.Marca := Leitor.rCampo(tcStr, 'Marca');
    Veiculo.Modelo := Leitor.rCampo(tcStr, 'Modelo');
    Veiculo.NumeroDeEixos := Leitor.rCampo(tcInt, 'NumeroDeEixos');
    Veiculo.CodigoMunicipio := Leitor.rCampo(tcStr, 'CodigoMunicipio');
    Veiculo.RNTRC := Leitor.rCampo(tcInt, 'RNTRC');
    Veiculo.Renavam := Leitor.rCampo(tcInt, 'Renavam');
    Veiculo.Tara := Leitor.rCampo(tcInt, 'Tara');
    Veiculo.TipoCarroceria := StrToTpCarroceria(ok, Leitor.rCampo(tcStr, 'TipoCarroceria'));
    Veiculo.TipoRodado := StrToTpRodado(ok, Leitor.rCampo(tcStr, 'TipoRodado'));
  end;

  Result := true;
end;

end.

