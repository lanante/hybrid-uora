% %New Formula
% %9/30
% clc
% clear


% % %Case 1 c<j
% %Theory
clear
clc
% c=1;
close all
% N_RUarray=[4];  %do not change
EOCWmaxArray=0:7;
EOCWmax=7;
EOCWminArray=0:7;
% j=ceil(log2(N_RU));
N_STA_Array=[55];   %fixed
tpreamblePHY=40e-6;   %40us
tTXOP=3.844e-3;
tSIFS=16e-6;
tTF=100e-6;
PHY=.8*1e6;
EP=round(PHY*(tTXOP-tpreamblePHY)/8);
tACK=68e-6;
tTO=16e-6;
%kappa
U=8;
Duration=1;
for u=1:U
    if u==1
        maxEffA(u)=exp(-1);
        tpdfA(u)=1;
        kA(u)=1;
    else
        maxEffA(u)=exp(maxEffA(u-1)-1);
        tpdfA(u)=1-maxEffA(u-1);
        kA(u)=kA(u-1)/((1-maxEffA(u-1))*kA(u-1)+maxEffA(u));
    end
end
ERetryMax=10;
R=16;
p1=linspace(1/1000,1-1/1000,1000);
for j=1:length(N_STA_Array)
    J=1e5*ones(8,8);
    N_STA=N_STA_Array(j);
    if R>N_STA
        r=N_STA;
    else
        r=R;
    end
    N_RU=r;
    for i=0:7
        W=2^i;
        for ii=i:7
            m=ii-i;
            if r>=W*2^m
                tau1=1;
                tau2=1;
                
            elseif r>W && r<W*2^m
                r=N_RU;
                c=floor(log2(N_RU));
                X1=-W*(1-(2*p1).^(c+1))./(1-2*p1)  +r*(1-(p1).^(c+1))./(1-p1);
                
                den=W*(1-(2*p1).^m)./(1-2*p1)+r./(1-p1)+W*((2*p1).^m)./(1-p1);
                tau1=2*r./((den+X1).*(1-p1));
                tau2=( 1 - (1 - p1).^(1/(N_STA-1)) )*N_RU;
                
            else
                if m==0
                    tau1=2*r/(W+r);
                    tau2=tau1;
                else
                    
                    den=W*(1-(2*p1).^m)./(1-2*p1)+r./(1-p1)+W*((2*p1).^m)./(1-p1);
                    % den=W+r+p1./(1-p1)*(2*W+r);
                    tau1=2*r./(den.*(1-p1));
                    tau2=( 1 - (1 - p1).^(1/(N_STA-1)) )*N_RU;
                end
            end
            
            [a,b,]=min(abs(tau1-tau2));
            tau=tau1(b);
            J(i+1,ii+1)=abs(tau-min(r/N_STA/(kA(end)),1)).^2;
            
        end
        
    end
    
    a=min(J);
    b=min(a);
    ind2=find(min(J)==b);
    ind1=find(J(:,ind2)==b);
    EOCWmaxS(j)=ind2(1)-1;
    EOCWminS(j)=ind1(1)-1;
end


dRS_Array=[-82:2:-62];
LdbArray=[5  10 20 inf];
for b=1:length(LdbArray)
b
n=50;
rD=10;
Pn=-104;
Pref=-30;
r_array=sqrt(rand(1,n)*rD^2);
phi_array=rand(1,n)*2*pi;
xA=r_array.*cos(phi_array);
yA=r_array.*sin(phi_array);
% plot(xA,yA,'*')
dA=sqrt((repmat(xA,n,1)-repmat(xA',1,n)).^2+(repmat(yA,n,1)-repmat(yA',1,n)).^2);
for i=1:n
dA(i,i)=sqrt(xA(i).^2+yA(i).^2).';
end
Ldb=LdbArray(b);
RSSI=Pref-35*log10(dA);
RSSI(RSSI>-30)=-30;
% DrsA=-12;
k=kA(1:U);
tpdf=tpdfA(1:U);
S0=50;

for a=1:length(dRS_Array)
% a=1;
Drs=dRS_Array(a);
[e1_Tput(b,a) e1_Efficiency(b,a) ready_tau e1_p e1_b_idle e1_B e1_Latency(b,a) nTF tTF]=randomaccess_nfb11(EOCWminS,EOCWmaxS,n,r,200,U,5,Duration,tpdf,k,RSSI,Ldb,Drs,Pn,S0);
    
end
end

% save Sim6Res
plot(dRS_Array,0.811*ones(1,length(dRS_Array)),'k--','LineWidth',1);hold on
plot(dRS_Array(1:length(e1_Efficiency)),e1_Efficiency(3,:),'r-d',dRS_Array(1:length(e1_Efficiency)),e1_Efficiency(4,:),'k-o','LineWidth',1);hold on
legend('Upper Bound','With Power Leakage','Without Power Leakage')

axis([-82 -62 0.4 1])
grid on
xlabel('RS threshold (dBm)')
ylabel('Success Probability')

