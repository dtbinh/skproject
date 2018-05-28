VERSION 5.00
Object = "{D323A622-1D13-11D4-8858-444553540000}#1.0#0"; "RPcoX.ocx"
Begin VB.Form frmMain 
   Caption         =   "Two Channel Play"
   ClientHeight    =   690
   ClientLeft      =   9930
   ClientTop       =   7935
   ClientWidth     =   2775
   LinkTopic       =   "Form1"
   ScaleHeight     =   690
   ScaleWidth      =   2775
   Begin RPCOXLib.RPcoX RP 
      Left            =   1170
      Top             =   936
      _Version        =   65536
      _ExtentX        =   661
      _ExtentY        =   661
      _StockProps     =   0
   End
   Begin VB.CommandButton btnMakeTones 
      Caption         =   "Make Tones"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   12
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   495
      Left            =   360
      TabIndex        =   0
      Top             =   120
      Width           =   2055
   End
End
Attribute VB_Name = "frmMain"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Const Circuit = "C:\TDT\ActiveX\ActXExamples\RP_files\TwoCh_Continuous_Play.rcx"
Dim t() As Single
Dim tones1() As Integer
Dim tones2() As Integer
Dim freq1, freq2 As Single
Dim bufpts As Long
Dim err1 As Long
Dim err2 As Long
Const PI = 3.14159265

Public Sub btnMakeTones_Click()

    If LoadCircuit = True Then
        If RunCircuit = True Then
        
            bufpts = RP.GetTagSize("datain") / 2
            ReDim t(bufpts - 1)
            ReDim tones1(0 To 1, bufpts - 1)
            ReDim tones2(0 To 1, bufpts - 1)
            
            freq1 = 500
            freq2 = 2000
            fs = 97656.25
    
            'load time array
            For z = 0 To bufpts - 1
                t(z) = z / fs
            Next z
        
            'main loop
            For n = 1 To 5
                freq3 = freq1 + 1000
                freq4 = freq2 + 1000
                freq1 = freq1 + 500
                freq2 = freq2 + 500
                
                'generate tone signals
                For z = 0 To bufpts - 1
                    tones1(0, z) = Round(Sin(2 * PI * t(z) * freq3) * 32760)
                    tones1(1, z) = Round(Sin(2 * PI * t(z) * freq4) * 32760)
                    tones2(0, z) = Round(Sin(2 * PI * t(z) * freq1) * 32760)
                    tones2(1, z) = Round(Sin(2 * PI * t(z) * freq2) * 32760)
                Next z
        
                'write to buffer
                If n = 1 Then
        
                    'write to entire buffer first time through
                    err1 = RP.WriteTagVEX("datain", 0, "I16", tones1())
                    err2 = RP.WriteTagVEX("datain", bufpts, "I16", tones2())
            
                    'begin playing
                    Call RP.SoftTrg(1)
                Else
                    sendtones
                End If
            Next n
    
            'stop playing
            Call RP.SoftTrg(2)
        End If
    End If
        
End Sub

Private Function LoadCircuit() As Boolean

    'connect to RP2
    If RP.ConnectRP2("GB", 1) = 0 Then
        If RP.ConnectRP2("USB", 1) = 0 Then
            MsgBox "Error connecting to RP device"
            End
        End If
    End If
    
    'load circuit
    Call RP.ClearCOF
    Call RP.LoadCOF(Circuit)
    
    'check status
    LoadCircuit = False
    Status = RP.GetStatus
    If (Status And 1) = 0 Then
        MsgBox "Error connecting to RP device; status: " & Status
        RP.Halt
    ElseIf (Status And 2) = 0 Then
        MsgBox "Error loading circuit; status: " & Status
        RP.Halt
    Else
        LoadCircuit = True
    End If
    
End Function

Private Function RunCircuit() As Boolean
    Call RP.Run
    
    'check status
    RunCircuit = False
    Status = RP.GetStatus
    If (Status And 4) = 0 Then
        MsgBox "Error running circuit; status: " & Status
        RP.Halt
    Else
        RunCircuit = True
    End If
End Function

Public Sub sendtones()

    curindex = RP.GetTagVal("index")
    
    'check buffer index
    While curindex < bufpts
        curindex = RP.GetTagVal("index")
    Wend
    
    'write first half
    err1 = RP.WriteTagVEX("datain", 0, "I16", tones1())
    
    curindex = RP.GetTagVal("index")
    
    'check transfer rate
    If curindex < bufpts Then
        MsgBox "Transfer rate too slow"
        Call RP.SoftTrg(2)
    End
    End If
    
    curindex = RP.GetTagVal("index")
    
    'check buffer index
    While curindex > bufpts
        curindex = RP.GetTagVal("index")
    Wend
    
    'write second half
    err2 = RP.WriteTagVEX("datain", bufpts, "I16", tones2())
    
    curindex = RP.GetTagVal("index")
    
    'check transfer rate
    If curindex > bufpts Then
        MsgBox "Transfer rate too slow"
        Call RP.SoftTrg(2)
    End
    End If
End Sub
