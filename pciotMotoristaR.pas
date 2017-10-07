{$I ACBr.inc}

unit pciotMotoristaR;

interface

uses
  SysUtils, Classes,
{$IFNDEF VER130}
  Variants,
{$ENDIF}
  pcnAuxiliar, pcnConversao, pciotCIOT, ASCIOTUtil;

type

  TMotoristaR = class(TPersistent)
  private
    FLeitor: TLeitor;
    FMotorista: TMotorista;
    FSucesso: Boolean;
    FMensagem: String;
    FOperacao: TpciotOperacao;
  public
    constructor Create(AOwner: TMotorista; AOperacao: TpciotOperacao = opObter);
    destructor Destroy; override;
    function LerXml: boolean;

    property Sucesso: Boolean read FSucesso write FSucesso;
    property Mensagem: String read FMensagem write FMensagem;
  published
    property Leitor: TLeitor read FLeitor write FLeitor;
    property Motorista: TMotorista read FMotorista write FMotorista;
  end;

implementation

{ TMotoristaR }

constructor TMotoristaR.Create(AOwner: TMotorista; AOperacao: TpciotOperacao = opObter);
begin
  FLeitor := TLeitor.Create;
  FMotorista := AOwner;
  FOperacao := AOperacao;
end;

destructor TMotoristaR.Destroy;
begin
  FLeitor.Free;
  inherited Destroy;
end;

function TMotoristaR.LerXml: boolean;
begin
  case FOperacao of
    opObter:
      begin
        if Leitor.rExtrai(1, 'ObterResult') <> '' then
        begin
          FSucesso := Leitor.rCampo(tcStr, 'Sucesso ' + NAME_SPACE_EFRETE_OBJECTS, '/Sucesso') = 'true';
          FMensagem := Leitor.rCampo(tcStr, 'Mensagem');
        end;
      end;
    opAdicionar:
      begin
        if Leitor.rExtrai(1, 'GravarResult') <> '' then
        begin
          FSucesso := Leitor.rCampo(tcStr, 'Sucesso ' + NAME_SPACE_EFRETE_OBJECTS, '/Sucesso') = 'true';
          FMensagem := Leitor.rCampo(tcStr, 'Mensagem');
        end;
      end;
  end;

  if Leitor.rExtrai(1, 'Motorista') <> '' then
  begin
    with Motorista do
    begin
      CPF := Leitor.rCampo(tcStr, 'CPF');
      CNH := Leitor.rCampo(tcStr, 'CNH');
      DataNascimento := Leitor.rCampo(tcDat, 'DataNascimento');
      Nome := Leitor.rCampo(tcStr, 'Nome');
      NomeDeSolteiraDaMae := Leitor.rCampo(tcStr, 'NomeDeSolteiraDaMae');

      if Leitor.rExtrai(1, 'Endereco') <> '' then
      begin
        Endereco.Rua := Leitor.rCampo(tcStr, 'Rua ' + NAME_SPACE_EFRETE_OBJECTS, '/Rua');
        Endereco.Numero := Leitor.rCampo(tcStr, 'Numero ' + NAME_SPACE_EFRETE_OBJECTS, '/Numero');
        Endereco.Complemento := Leitor.rCampo(tcStr, 'Complemento ' + NAME_SPACE_EFRETE_OBJECTS, '/Complemento');
        Endereco.Bairro := Leitor.rCampo(tcStr, 'Bairro ' + NAME_SPACE_EFRETE_OBJECTS, '/Bairro');
        Endereco.CodigoMunicipio := Leitor.rCampo(tcInt, 'CodigoMunicipio ' + NAME_SPACE_EFRETE_OBJECTS, '/CodigoMunicipio');
        Endereco.CEP := Leitor.rCampo(tcInt, 'CEP ' + NAME_SPACE_EFRETE_OBJECTS, '/CEP');
      end;

      if Leitor.rExtrai(1, 'Telefones') <> '' then
      begin
        if Leitor.rExtrai(1, 'Celular ' + NAME_SPACE_EFRETE_OBJECTS, 'Celular') <> '' then
        begin
          Telefones.Celular.DDD := Leitor.rCampo(tcInt, 'DDD');
          Telefones.Celular.Numero := Leitor.rCampo(tcInt, 'Numero');
        end;
        if Leitor.rExtrai(1, 'Fax ' + NAME_SPACE_EFRETE_OBJECTS, 'Fax') <> '' then
        begin
          Telefones.Fax.DDD := Leitor.rCampo(tcInt, 'DDD');
          Telefones.Fax.Numero := Leitor.rCampo(tcInt, 'Numero');
        end;
        if Leitor.rExtrai(1, 'Fixo ' + NAME_SPACE_EFRETE_OBJECTS, 'Fixo') <> '' then
        begin
          Telefones.Fixo.DDD := Leitor.rCampo(tcInt, 'DDD');
          Telefones.Fixo.Numero := Leitor.rCampo(tcInt, 'Numero');
        end;
      end;
    end;
  end;

  Result := true;
end;

end.

