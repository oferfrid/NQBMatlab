function [MPN_R MPN_H MPN_L]= MPNindex(Dilution,Replicates,Positive)
%function [MPN_R MPN_H MPN_L]= MPNindex(Dilution,Replicates,Positive)
%translated from Excel version MPN Calculator by by Mike Curiale
%(http://www.i2workout.com/mcuriale/mpn/index.html mcuriale@gmail.com)
%translated by Ofer Fridman (oferfrid@hotmail.com)
numdil = length(Dilution);

%   Dim precision As Double
%     precision = 0.0000000001
precision = 0.0000000001;
%     Dim a As Double
%     a = precision
a = precision;
%     
%     'variables
%     Dim Lower As Variant
%         Lower = 0
Lower = 0;
%     Dim Upper As Variant
%         Upper = 1000000000
Upper = 1000000000;
%     Dim Midpoint As Variant
%     Dim c As Variant
%     'Dim d As String
%     Dim e As Variant
%     Dim MPN As Double
%     Dim stopvalue As Double
%     Dim vdn As Double
%     Dim vdp As Double
%          
%     MPN = Upper
MPN = Upper;
%     vdp = 2 'start values to end routine
vdp = 2;
%     vdn = 1
vdn = 1;
%     
%     While (vdn < vdp)
while vdn < vdp
%         Upper = Upper / 10
    Upper = Upper / 10;
%         MPN = Upper
    MPN = Upper;
%         vdp = 0
    vdp = 0;
%         vdn = 0
    vdn = 0;
%         For j = 1 To numdil
    for j=1:numdil
%             vdn = vdn + Dilution( j) * Replicates( j)
        vdn = vdn + Dilution( j) * Replicates( j);
%             vdp = vdp + (Dilution( j) * Positive( j) / (1 - Exp(-Dilution( j) * MPN)))
        vdp = vdp + (Dilution( j) * Positive( j) / (1 - exp(-Dilution( j) * MPN)));
    end
%             Next
%         Wend
end
    

%     
%     Upper = Upper * 10
Upper = Upper * 10;
%     While (vdn - vdp) > a Or (vdn - vdp) < -a
while ((vdn - vdp) > a) || ((vdn - vdp) < -a)
%         Midpoint = (Lower + Upper) / 2
    Midpoint = (Lower + Upper) / 2;
%         MPN = Midpoint
    MPN = Midpoint;
%         vdn = 0   'reset vdn and vdp
    vdn = 0;
%         vdp = 0
    vdp = 0;
%         For j = 1 To numdil
    for j = 1:numdil
%             vdn = vdn + Dilution( j) * Replicates( j)
        vdn = vdn + Dilution( j) * Replicates( j);
%             vdp = vdp + (Dilution( j) * Positive( j) / (1 - Exp(-Dilution( j) * MPN)))
        vdp = vdp + (Dilution( j) * Positive( j) / (1 - exp(-Dilution( j) * MPN)));
%             If MPN < 0.00001 Then
         if MPN < 0.00001
%                   MsgBox "Overflow calculation. Could not compute " & _
%                     "result. Reduce dilutions or number of tubes."
          fprintf('Overflow calculation. Could not compute result. Reduce dilutions or number of tubes.');
%                   errorflag = 1
%                   Exit Function
%                   End If
         end
%             Next
    end
%         If vdp > vdn Then
    if vdp>vdn
%             Lower = Midpoint
    Lower = Midpoint;
%             End If
    end
%         If vdp < vdn Then
    if vdp < vdn 
%             Upper = Midpoint
    Upper = Midpoint;
%             End If
    end
%     Wend
end
%        
%     '2 sig fig routine
%     'excel 97 does not have round function
%         
%     MPNindex = mpnprefix & sigfig(MPN, 2)

MPN_R = sigfig(MPN, 2);
%     
%     
%     Dim g2n As Double
%         g2n = 0 'initialize to zero
g2n = 0;
%     
%     Select Case MPNresult
%         
%     Case 2  'return  lower limit of 95% ci
%         If mpnprefix = "" Then
%             For j = 1 To numdil
for j = 1:numdil
%                 m = (Dilution( j) ^ 2 * Replicates( j))
    m = (Dilution( j) ^ 2 * Replicates( j));
%                 n = (Exp(Dilution( j) * MPN) - 1)
    n = (exp(Dilution( j) * MPN) - 1);
%                 g2n = g2n + m / n
    g2n = g2n + m / n;
%                 Next
end
%             g2n = (1 / (MPN ^ 2 * g2n)) ^ 0.5 / Log(10)
g2n = (1 / (MPN ^ 2 * g2n)) ^ 0.5 / log(10);
%             g2n = 10 ^ ((Log(MPN) / Log(10) - 1.96 * g2n))
g2n = 10 ^ ((log(MPN) / log(10) - 1.96 * g2n));
%             MPNindex = mpnprefix & sigfig(g2n, 2)
MPN_L = sigfig(g2n, 2);
%             Else
%             MPNindex = ""
%             End If
%         
%     Case 3   'return upper limit of 95% ci
%         If mpnprefix = "" Then
%             For j = 1 To numdil
g2n = 0;
for j=1:numdil
%                 m = (Dilution( j) ^ 2 * Replicates( j))
    m = (Dilution( j) ^ 2 * Replicates( j));
%                 n = (Exp(Dilution( j) * MPN) - 1)
    n = (exp(Dilution( j) * MPN) - 1);
%                 g2n = g2n + m / n
    g2n = g2n + m / n;
%                 Next
end

%             g2n = (1 / (MPN ^ 2 * g2n)) ^ 0.5 / Log(10)
g2n = (1 / (MPN ^ 2 * g2n)) ^ 0.5 / log(10);
%             g2n = 10 ^ ((Log(MPN) / Log(10) + 1.96 * g2n))
g2n = 10 ^ ((log(MPN) / log(10) + 1.96 * g2n));
%             MPNindex = mpnprefix & sigfig(g2n, 2)
MPN_H = sigfig(g2n, 2);
%             Else
%             MPNindex = ""
%             End If
%         
%     End Select
%         
%     End If 'error flag

end

function sigfig =  sigfig(GenNum, SigNum )
%    b = Log(GenNum) / 2.302585   'log is natural log
%     b = Int(b)
%     b = b - (SigNum - 1)
b=  floor(log10(GenNum)) -(SigNum -1);
%     c = GenNum / 10 ^ b
c=GenNum/(10^b);
%     d = Int(c)
%     d = c - d
fc=floor(c);
d= c - fc;
%     c = Int(c)
%     If d >= 0.5 Then
%         c = c + 1
%         End If
if d >= 0.5,
    fc=fc+1;
end
%         
%     'return value
%     sigfig = c * 10 ^ b
sigfig = fc*10^b;
end
