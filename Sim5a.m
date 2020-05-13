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
N_STA_Array=15:10:105;   %fixed
tpreamblePHY=40e-6;   %40us
tTXOP=5.484e-3;
tSIFS=16e-6;
tTF=100e-6;
PHY=14.7*1e6;
EP=round(PHY*(tTXOP-tpreamblePHY)/8);
tACK=68e-6;
tTO=16e-6;
%kappa
U=8;
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




for a=1:length(N_STA_Array)
    tic
    n=N_STA_Array(a);
    k=kA(1:U);
    tpdf=tpdfA(1:U);
    [e1_Tput(a) e1_Efficiency(a) ready_tau e1_p e1_b_idle e1_B e1_Latency(a) nTF tTF]=randomaccess_nfb10(EOCWminS(a),EOCWmaxS(a),n,r,200,U,5,20,tpdf,k);
    
    
    
    e=0;
    for c=1:length(EOCWmaxArray)
        for d=c:length(EOCWminArray)
            e=e+1;
            
                [ea_Tput(a,e) ea_Efficiency(a,e) ready_tau e1_p e1_b_idle e1_B ea_Latency(a,e) nTF tTF]=randomaccess_nfb10(EOCWminArray(d),EOCWmaxArray(c),n,r,200,U,5,5,tpdf,k);

        end
    end
    disp(['Just Finished U=' num2str(U) ' for n=' num2str(n) '. That took ' num2str(toc) ' seconds' ])
    
    
    
    
    
end
% save Sim5a
figure(1)
plot(N_STA_Array,0.811*ones(1,length(N_STA_Array)),'k--','LineWidth',2);hold on
plot(N_STA_Array(1:length(e1_Efficiency)),e1_Efficiency,'k-o','LineWidth',2);hold on
plot(N_STA_Array(1:size(ea_Efficiency,1)),ea_Efficiency,'k*');
legend('Upperbound','H-UORA with U=7','Random')

axis([15 105 0.1 1.2])
grid on
xlabel('Number of STAs')
ylabel('Success Probability')

figure(2)
plot(N_STA_Array,e1_Latency*1e3,'k-o','LineWidth',2);hold on
plot(N_STA_Array,ea_Latency*1e3,'k*');
legend('H-UORA with U=7','Random')
axis([15 105 0 80])
grid on
ylabel('Latency (ms)')
xlabel('Number of STAs')


