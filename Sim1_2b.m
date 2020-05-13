clear
clc
close all

lambdae=200;   %lambdae packet per TF. Can accomodate about 1/tTF/lambda users. full buffer if equal to inf
EOCWmin=4;
r=[16];
nA=[5:10:105];
EOCWmax=7;
UA=[1 2 4 8 16];
dh=5;
simtime=1;

EPA=[100 1500 10000];

for c=1:length(EPA)
    EP=EPA(c);
for b=1:length(UA)
    U=UA(b);
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
    for a=1:length(nA)
        tic
        n=nA(a);
        
            k=kA(1:U);
    tpdf=tpdfA(1:U);
        [e1_Tput(a,b,c) e1_Efficiency(a,b,c) ready_tau e1_p e1_b_idle e1_B e1_Latency(a,b,c) nTF tTF]=randomaccess_nfb10a(EOCWmin,EOCWmax,n,r,lambdae,U,dh,simtime,tpdf,k,EP);
        
        disp(['Just Finished U=' num2str(U) ' for n=' num2str(n) '. That took ' num2str(toc) ' seconds' ])
        
    end
end
    for a=1:length(nA)
        tic
        n=nA(a);
        
        [e2_Tput(a,c) e2_Efficiency(a,c) ready_tau e2_p e2_b_idle e2_B e2_Latency(a,c) nTF tTF]=randomaccess_nfb10b(EOCWmin,EOCWmax,n,r,lambdae,1,dh,simtime,1,1,EP);
    end
end
% t1_Efficiency
% e1_Efficiency
% save Sim1_2_new_b
figure(1)
c=1;
plot(nA,e1_Tput(:,1,c)/1e6,':k',nA,e1_Tput(:,2,c)/1e6,'k-.',nA,e1_Tput(:,3,c)/1e6,'k--',nA,e1_Tput(:,4,c)/1e6,'k',nA,e2_Tput(:,c)/1e6,'r-+','LineWidth',2);

 legend('H-UORA with U=0','H-UORA with U=1','H-UORA with U=3','H-UORA with U=7', 'UORA-BSRP' )
grid
axis([min(nA) max(nA) 0 max(max(e1_Tput(:,:,c))/1e6)*2])
xlabel('Number of STAs','FontName','Times New Roman');
ylabel('System Throughput (Mbps)','FontName','Times New Roman');

figure(2)

c=2;
plot(nA,e1_Tput(:,1,c)/1e6,':k',nA,e1_Tput(:,2,c)/1e6,'k-.',nA,e1_Tput(:,3,c)/1e6,'k--',nA,e1_Tput(:,4,c)/1e6,'k',nA,e2_Tput(:,c)/1e6,'r-+','LineWidth',2);

 legend('H-UORA with U=0','H-UORA with U=1','H-UORA with U=3','H-UORA with U=7', 'UORA-BSRP' )
grid
axis([min(nA) max(nA) 0 max(max(e1_Tput(:,:,c))/1e6)*2])
xlabel('Number of STAs','FontName','Times New Roman');
% ylabel('System Throughput (Mbps)','FontName','Times New Roman');
figure(3)

c=3;
plot(nA,e1_Tput(:,1,c)/1e6,':k',nA,e1_Tput(:,2,c)/1e6,'k-.',nA,e1_Tput(:,3,c)/1e6,'k--',nA,e1_Tput(:,4,c)/1e6,'k',nA,e2_Tput(:,c)/1e6,'r-+','LineWidth',2);

 legend('H-UORA with U=0','H-UORA with U=1','H-UORA with U=3','H-UORA with U=7', 'UORA-BSRP' )
grid
axis([min(nA) max(nA) 0 max(max(e1_Tput(:,:,c))/1e6)*2])
xlabel('Number of STAs','FontName','Times New Roman');
% ylabel('System Throughput (Mbps)','FontName','Times New Roman');

% 

figure(4)
% subplot(1,2,1)
c=1;
plot(nA,e1_Latency(:,1,c)/1e-3,':k',nA,e1_Latency(:,2,c)/1e-3,'k-.',nA,e1_Latency(:,3,c)/1e-3,'k--',nA,e1_Latency(:,4,c)/1e-3,'k',nA,e2_Latency(:,c)/1e-3,'r-+','LineWidth',2);

 legend('H-UORA with U=0','H-UORA with U=1','H-UORA with U=3','H-UORA with U=7', 'UORA-BSRP' )
grid
axis([min(nA) max(nA) 0 max(max(e1_Latency(:,:,c))/1e-3)*2])
xlabel('Number of STAs','FontName','Times New Roman');
ylabel('Latency (ms)','FontName','Times New Roman');
% subplot(1,2,2)

figure(5)
c=2;
plot(nA,e1_Latency(:,1,c)/1e-3,':k',nA,e1_Latency(:,2,c)/1e-3,'k-.',nA,e1_Latency(:,3,c)/1e-3,'k--',nA,e1_Latency(:,4,c)/1e-3,'k',nA,e2_Latency(:,c)/1e-3,'r-+','LineWidth',2);

 legend('H-UORA with U=0','H-UORA with U=1','H-UORA with U=3','H-UORA with U=7', 'UORA-BSRP' )
grid
axis([min(nA) max(nA) 0 max(max(e1_Latency(:,:,c))/1e-3)*2])
xlabel('Number of STAs','FontName','Times New Roman');
% ylabel('Latency (ms)','FontName','Times New Roman');

figure(6)
c=3;
plot(nA,e1_Latency(:,1,c)/1e-3,':k',nA,e1_Latency(:,2,c)/1e-3,'k-.',nA,e1_Latency(:,3,c)/1e-3,'k--',nA,e1_Latency(:,4,c)/1e-3,'k',nA,e2_Latency(:,c)/1e-3,'r-+','LineWidth',2);

 legend('H-UORA with U=0','H-UORA with U=1','H-UORA with U=3','H-UORA with U=7', 'UORA-BSRP' )
grid
axis([min(nA) max(nA) 0 max(max(e1_Latency(:,:,c))/1e-3)*2])
xlabel('Number of STAs','FontName','Times New Roman');
% ylabel('Latency (ms)','FontName','Times New Roman');