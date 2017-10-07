{$I ACBr.inc}

unit pciotProprietarioR;

interface

uses
  SysUtils, Classes,
{$IFNDEF VER130}
  Variants,
{$ENDIF}
  pcnConversao, pciotCIOT, ASCIOTUtil;

type

  TProprietarioR = class(TPersistent)
  private
    FLeitor: TLeitor;
    FProprietario: TProprietario;
    FSucesso: Boolean;
    FMensagem: String;

    FOperacao: TpciotOperacao;
  public
    constructor Create(AOwner: TProprietario; AOperacao: TpciotOperacao = opObter);
    destructor Destroy; override;
    function LerXml: boolean;

    property Sucesso: Boolean read FSucesso write FSucesso;
    property Mensagem: String read FMensagem write FMensagem;
  published
    property Leitor: TLeitor read FLeitor write FLeitor;
    property Proprietario: TProprietario read FProprietario write FProprietario;
  end;

implementation

{ TProprietarioR }

constructor TProprietarioR.Create(AOwner: TProprietario; AOperacao: TpciotOperacao = opObter);
begin
  FLeitor := TLeitor.Create;
  FProprietario := AOwner;
  FOperacao := AOperacao;
end;

destructor TProprietarioR.Destroy;
begin
  FLeitor.Free;
  inherited Destroy;
end;

function TProprietarioR.LerXml: boolean;
var
  ok: boolean;
begin
  case FOperacao of
    opObter:
      begin
        if Leitor.rExtrai(1, 'ObterResult') <> '' then
        begin
          FSucesso := Leitor.rCampo(tcStr, 'Sucesso ' + NAME_SPACE_EFRETE_OBJECTS, '/Sucesso') = 'true';
          FMensagem := Leitor.rCampo(tcStr, 'Mensagem');
        end;

        if Leitor.rExtrai(1, 'Proprietario') <> '' then
        begin
          with Proprietario do
          begin
            CNPJ := Leitor.rCampo(tcStr, 'CNPJ');
            RNTRC := Leitor.rCampo(tcStr, 'RNTRC');
            RazaoSocial := Leitor.rCampo(tcStr, 'RazaoSocial');

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
      end;
    opAdicionar:
      begin
        if Leitor.rExtrai(1, 'GravarResult') <> '' then
        begin
          FSucesso := Leitor.rCampo(tcStr, 'Sucesso ' + NAME_SPACE_EFRETE_OBJECTS, '/Sucesso') = true;
          FMensagem := Leitor.rCampo(tcStr, 'Mensagem');
        end;

        if Leitor.rExtrai(1, 'Proprietario') <> '' then
        begin
          with Proprietario do
          begin
            CNPJ := Leitor.rCampo(tcStr, 'CNPJ');
            RNTRC := Leitor.rCampo(tcStr, 'RNTRC');
            RazaoSocial := Leitor.rCampo(tcStr, 'RazaoSocial');
            Tipo := StrToTpProprietario(ok, Leitor.rCampo(tcStr, 'Tipo'));
            TACouEquiparado := Leitor.rCampo(tcStr, 'TACouEquiparado') = 'true';
            DataValidadeRNTRC := Leitor.rCampo(tcDat, 'DataValidadeRNTRC');

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
      end;
  end;

  Result := true;
end;

end.

