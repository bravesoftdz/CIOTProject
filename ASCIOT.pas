{$I ACBr.inc}

unit ASCIOT;

interface

uses
  Classes, Sysutils,
  {$IFDEF VisualCLX}
     QDialogs,
  {$ELSE}
     Dialogs,
  {$ENDIF}
  Forms,
  smtpsend, ssl_openssl, mimemess, mimepart, // units para enviar email
  pciotCIOT, pcnConversao,

  ACBrUtil, ACBrDFeUtil, ASCIOTUtil,
  ASCIOTConfiguracoes,
  ASCIOTWebServices;

const
  AmsCIOT_VERSAO = '1.00';

type
  TAmSCIOTAboutInfo = (ACBrCIOTAbout);

  EAmSCIOTException = class(Exception);

  { Evento para gerar log das mensagens do Componente }
  TAmSCIOTLog = procedure(const Mensagem : String) of object;

  TAmSCIOT = class(TComponent)
  private
    fsAbout: TAmSCIOTAboutInfo;
    FWebServices: TWebServices;
    FConfiguracoes: TConfiguracoes;
    FStatus : TStatusACBrCIOT;
    FOnStatusChange: TNotifyEvent;
    FOnGerarLog : TAmSCIOTLog;
    FVeiculos: TCIOTVeiculo;
    FMotoristas: TCIOTMotorista;
    FProprietario: TCIOTProprietario;
    FOT: TCIOTOperacaoTransporte;
    procedure EnviaEmailThread(const sSmtpHost, sSmtpPort, sSmtpUser,
      sSmtpPasswd, sFrom, sTo, sAssunto: String; sMensagem: TStrings;
      SSL: Boolean; sCC, Anexos: TStrings; PedeConfirma, AguardarEnvio: Boolean;
      NomeRemetente: String; TLS: Boolean; StreamCTe: TStringStream;
      NomeArq: String; HTML: Boolean = False);
    procedure EnviarEmailNormal(const sSmtpHost, sSmtpPort, sSmtpUser,
      sSmtpPasswd, sFrom, sTo, sAssunto: String; sMensagem: TStrings;
      SSL: Boolean; sCC, Anexos: TStrings; PedeConfirma, AguardarEnvio: Boolean;
      NomeRemetente: String; TLS: Boolean; StreamCTe: TStringStream;
      NomeArq: String);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property Veiculos: TCIOTVeiculo read FVeiculos write FVeiculos;
    property Motoristas: TCIOTMotorista read FMotoristas write FMotoristas;
    property Proprietario: TCIOTProprietario read FProprietario write FProprietario;
    property OT: TCIOTOperacaoTransporte read FOT write FOT;

    property WebServices: TWebServices read FWebServices write FWebServices;

    property Status: TStatusACBrCIOT read FStatus;
    procedure SetStatus( const stNewStatus : TStatusACBrCIOT );
    procedure EnviaEmail(const sSmtpHost,
                                  sSmtpPort,
                                  sSmtpUser,
                                  sSmtpPasswd,
                                  sFrom,
                                  sTo,
                                  sAssunto: String;
                                  sMensagem : TStrings;
                                  SSL : Boolean;
                                  sCC: TStrings = nil;
                                  Anexos:TStrings=nil;
                                  PedeConfirma: Boolean = False;
                                  AguardarEnvio: Boolean = False;
                                  NomeRemetente: String = '';
                                  TLS : Boolean = True;
                                  StreamCTe : TStringStream = nil;
                                  NomeArq : String = '';
                                  UsarThread: Boolean = True;
                                  HTML: Boolean = False);
  published
    property Configuracoes: TConfiguracoes read FConfiguracoes write FConfiguracoes;
    property OnStatusChange: TNotifyEvent read FOnStatusChange write FOnStatusChange;
    property AbouTAmSCIOT : TAmSCIOTAboutInfo read fsAbout write fsAbout
                          stored false;
    property OnGerarLog : TAmSCIOTLog read FOnGerarLog write FOnGerarLog;
  end;

procedure ACBrAboutDialog;

implementation

procedure ACBrAboutDialog;
var
  Msg : String;
begin
  Msg := 'Componente AmSCIOT'+#10+
         'Versão: '+AmSCIOT_VERSAO+#10+#10+
         'Automação Comercial Brasil'+#10+#10+
         'http://acbr.sourceforge.net'+#10+#10+
         'Projeto Cooperar - PCN'+#10+#10+
         'http://www.projetocooperar.org/pcn/';

  MessageDlg(Msg ,mtInformation ,[mbOk],0);
end;

{ TAmSCIOT }

constructor TAmSCIOT.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FConfiguracoes     := TConfiguracoes.Create( self );
  FConfiguracoes.Name:= 'Configuracoes';
  {$IFDEF COMPILER6_UP}
   FConfiguracoes.SetSubComponent( true );{ para gravar no DFM/XFM }
  {$ENDIF}

  FVeiculos := TCIOTVeiculo.Create(Self);
  FMotoristas := TCIOTMotorista.Create(Self);
  FProprietario := TCIOTProprietario.Create(Self);
  FOT := TCIOTOperacaoTransporte.Create(Self);

  FWebServices       := TWebServices.Create(Self);

  if FConfiguracoes.WebServices.Tentativas <= 0 then
     FConfiguracoes.WebServices.Tentativas := 5;
{$IFDEF ACBrCTeOpenSSL}
  if FConfiguracoes.Geral.IniFinXMLSECAutomatico then
   CIOTUtil.InitXmlSec;
{$ENDIF}
  FOnGerarLog := nil;
end;

destructor TAmSCIOT.Destroy;
begin
  FConfiguracoes.Free;

  FVeiculos.Free;
  FMotoristas.Free;
  FProprietario.Free;
  FOT.Free;

  FWebServices.Free;
{$IFDEF ACBrCTeOpenSSL}
  if FConfiguracoes.Geral.IniFinXMLSECAutomatico then
   CIOTUtil.ShutDownXmlSec;
{$ENDIF}

  inherited;
end;

procedure TAmSCIOT.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
end;

procedure TAmSCIOT.SetStatus( const stNewStatus : TStatusACBrCIOT );
begin
  if ( stNewStatus <> FStatus ) then
  begin
    FStatus := stNewStatus;
    if Assigned(fOnStatusChange) then
      FOnStatusChange(Self);
  end;
end;

procedure TAmSCIOT.EnviaEmailThread(const sSmtpHost, sSmtpPort, sSmtpUser,
  sSmtpPasswd, sFrom, sTo, sAssunto: String; sMensagem: TStrings;
  SSL: Boolean; sCC, Anexos: TStrings; PedeConfirma,
  AguardarEnvio: Boolean; NomeRemetente: String; TLS: Boolean;
  StreamCTe: TStringStream; NomeArq: String; HTML: Boolean = False);
var
 ThreadSMTP : TSendMailThread;
 m:TMimemess;
 p: TMimepart;
 i: Integer;
begin
 m:=TMimemess.create;

 ThreadSMTP := TSendMailThread.Create;  // Não Libera, pois usa FreeOnTerminate := True;
 try
    p := m.AddPartMultipart('mixed', nil);
    if sMensagem <> nil then
    begin
       if HTML = true then
          m.AddPartHTML(sMensagem, p)
       else
          m.AddPartText(sMensagem, p);
    end;

    if StreamCTe <> nil then
      m.AddPartBinary(StreamCTe,NomeArq, p);

    if assigned(Anexos) then
      for i := 0 to Anexos.Count - 1 do
      begin
        m.AddPartBinaryFromFile(Anexos[i], p);
      end;

    m.header.tolist.add(sTo);

    if Trim(NomeRemetente) <> '' then
      m.header.From := Format('%s<%s>', [NomeRemetente, sFrom])
    else
      m.header.From := sFrom;

    m.header.subject:= sAssunto;
    m.Header.ReplyTo := sFrom;
    if PedeConfirma then
       m.Header.CustomHeaders.Add('Disposition-Notification-To: '+sFrom);
    m.EncodeMessage;

    ThreadSMTP.sFrom := sFrom;
    ThreadSMTP.sTo   := sTo;
    if sCC <> nil then
       ThreadSMTP.sCC.AddStrings(sCC);
    ThreadSMTP.slmsg_Lines.AddStrings(m.Lines);

    ThreadSMTP.smtp.UserName := sSmtpUser;
    ThreadSMTP.smtp.Password := sSmtpPasswd;

    ThreadSMTP.smtp.TargetHost := sSmtpHost;
    if not DFeUtil.EstaVazio( sSmtpPort ) then     // Usa default
       ThreadSMTP.smtp.TargetPort := sSmtpPort;

    ThreadSMTP.smtp.FullSSL := SSL;
    ThreadSMTP.smtp.AutoTLS := TLS;

    if (TLS) then
      ThreadSMTP.smtp.StartTLS;

    SetStatus( stCIOTEmail );
    ThreadSMTP.Resume; // inicia a thread
    if AguardarEnvio then
    begin
      repeat
        Sleep(1000);
        Application.ProcessMessages;
      until ThreadSMTP.Terminado;
    end;
    SetStatus( stCIOTIdle );
 finally
    m.free;
 end;
end;

procedure TAmSCIOT.EnviarEmailNormal(const sSmtpHost, sSmtpPort, sSmtpUser,
  sSmtpPasswd, sFrom, sTo, sAssunto: String; sMensagem: TStrings;
  SSL: Boolean; sCC, Anexos: TStrings; PedeConfirma,
  AguardarEnvio: Boolean; NomeRemetente: String; TLS: Boolean;
  StreamCTe: TStringStream; NomeArq: String);
var
  smtp: TSMTPSend;
  msg_lines: TStringList;
  m:TMimemess;
  p: TMimepart;
  I : Integer;
  CorpoEmail: TStringList;
begin
  SetStatus( stCIOTEmail );

  msg_lines := TStringList.Create;
  CorpoEmail := TStringList.Create;
  smtp := TSMTPSend.Create;
  m:=TMimemess.create;
  try
     p := m.AddPartMultipart('mixed', nil);
     if sMensagem <> nil then
     begin
        CorpoEmail.Text := sMensagem.Text;
        m.AddPartText(CorpoEmail, p);
     end;

    if StreamCTe <> nil then
      m.AddPartBinary(StreamCTe, NomeArq, p);

     if assigned(Anexos) then
     for i := 0 to Anexos.Count - 1 do
     begin
        m.AddPartBinaryFromFile(Anexos[i], p);
     end;

     m.header.tolist.add(sTo);
     m.header.From := sFrom;
     m.header.subject := sAssunto;
     m.EncodeMessage;
     msg_lines.Add(m.Lines.Text);

     smtp.UserName := sSmtpUser;
     smtp.Password := sSmtpPasswd;

     smtp.TargetHost := sSmtpHost;
     smtp.TargetPort := sSmtpPort;

     smtp.FullSSL := SSL;
     smtp.AutoTLS := TLS;

     if (TLS) then
       smtp.StartTLS;

     if not smtp.Login then
       raise Exception.Create('SMTP ERROR: Login: ' + smtp.EnhCodeString+sLineBreak+smtp.FullResult.Text);

     if not smtp.MailFrom(sFrom, Length(sFrom)) then
       raise Exception.Create('SMTP ERROR: MailFrom: ' + smtp.EnhCodeString+sLineBreak+smtp.FullResult.Text);

     if not smtp.MailTo(sTo) then
       raise Exception.Create('SMTP ERROR: MailTo: ' + smtp.EnhCodeString+sLineBreak+smtp.FullResult.Text);

     if sCC <> nil then
     begin
       for I := 0 to sCC.Count - 1 do
       begin
         if not smtp.MailTo(sCC.Strings[i]) then
           raise Exception.Create('SMTP ERROR: MailTo: ' + smtp.EnhCodeString+sLineBreak+smtp.FullResult.Text);
       end;
     end;

     if not smtp.MailData(msg_lines) then
       raise Exception.Create('SMTP ERROR: MailData: ' + smtp.EnhCodeString+sLineBreak+smtp.FullResult.Text);

     if not smtp.Logout then
       raise Exception.Create('SMTP ERROR: Logout: ' + smtp.EnhCodeString+sLineBreak+smtp.FullResult.Text);
  finally
     msg_lines.Free;
     CorpoEmail.Free;
     smtp.Free;
     m.free;
     SetStatus( stCIOTIdle );
  end;
end;

procedure TAmSCIOT.EnviaEmail(const sSmtpHost, sSmtpPort, sSmtpUser,
  sSmtpPasswd, sFrom, sTo, sAssunto: String; sMensagem: TStrings;
  SSL: Boolean; sCC, Anexos: TStrings; PedeConfirma,
  AguardarEnvio: Boolean; NomeRemetente: String; TLS: Boolean;
  StreamCTe: TStringStream; NomeArq: String; UsarThread: Boolean; HTML: Boolean);
begin
  if UsarThread then
  begin
    EnviaEmailThread(
      sSmtpHost,
      sSmtpPort,
      sSmtpUser,
      sSmtpPasswd,
      sFrom,
      sTo,
      sAssunto,
      sMensagem,
      SSL,
      sCC,
      Anexos,
      PedeConfirma,
      AguardarEnvio,
      NomeRemetente,
      TLS,
      StreamCTe,
      NomeArq,
      HTML
    );
  end
  else
  begin
    EnviarEmailNormal(
      sSmtpHost,
      sSmtpPort,
      sSmtpUser,
      sSmtpPasswd,
      sFrom,
      sTo,
      sAssunto,
      sMensagem,
      SSL,
      sCC,
      Anexos,
      PedeConfirma,
      AguardarEnvio,
      NomeRemetente,
      TLS,
      StreamCTe,
      NomeArq
    );
  end;
end;


end.
