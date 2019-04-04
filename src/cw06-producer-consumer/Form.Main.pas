unit Form.Main;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes, System.Types,
  System.Generics.Collections,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls
  ;

type
  TForm1 = class(TForm)
    tmrConsumer: TTimer;
    ListBox1: TListBox;
    GroupBox1: TGroupBox;
    btnAddWriterThread: TButton;
    btnTermianteProducers: TButton;
    procedure FormCreate(Sender: TObject);
    procedure tmrConsumerTimer(Sender: TObject);
    procedure btnAddWriterThreadClick(Sender: TObject);
    procedure btnTermianteProducersClick(Sender: TObject);
  private
    MainQueue: TThreadedQueue<String>;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

{ * --------------------------------------------------------------
  * TWriterThread - w�tek roboczy - zapisuje dane z kolejki
  * -------------------------------------------------------------- }

type
  TWriterThread = class(TThread)
  private
    FQueue: TThreadedQueue<String>;
    FWriterName: string;
  protected
    procedure Execute; override;
  public
    constructor Create(const aWriterName:string; aQueue: TThreadedQueue<String>);
  end;

constructor TWriterThread.Create(const aWriterName:string;
  aQueue: TThreadedQueue<String>);
begin
  FWriterName := aWriterName;
  FQueue := aQueue;
  inherited Create(false);
end;

procedure TWriterThread.Execute;
begin
  while not Terminated do
  begin
    TThread.Sleep(100 + Random(600));
    FQueue.PushItem(Format('%s(%d)',[FWriterName,Random(256)]));
  end;
end;

{ * --------------------------------------------------------------
  * Aplikacja g��wna
  * -------------------------------------------------------------- }


function generateThreadName(btn:TButton): string;
var
  ch: Char;
begin
  ch := chr(ord('A') + btn.Tag);
  btn.Tag := btn.Tag + 1;
  Result := ch + ch;
end;


procedure TForm1.btnAddWriterThreadClick(Sender: TObject);
var
  n: string;
begin
  n := GenerateThreadName(btnAddWriterThread);
  TWriterThread.Create(n,MainQueue);
end;

procedure TForm1.btnTermianteProducersClick(Sender: TObject);
begin
  // TODO: Terminate all producer threads
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  MainQueue := TThreadedQueue<String>.Create();
end;

procedure TForm1.tmrConsumerTimer(Sender: TObject);
var
  s: string;
  itemCounter: Integer;
begin
  itemCounter:=MainQueue.QueueSize;
  while MainQueue.QueueSize>0 do
    s := s + MainQueue.PopItem() +', ';
  ListBox1.Items.Add(Format('%2d items | ',[itemCounter])+s);
  ListBox1.ItemIndex := ListBox1.Items.Count-1;
end;

end.