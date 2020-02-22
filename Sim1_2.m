clear
clc
close all

lambdae=200;   %lambdae packet per TF. Can accomodate about 1/tTF/lambda users. full buffer if equal to inf
EOCWmin=4;
r=[16];
nA=[5];
EOCWmax=7;
UA=[1 2 4 8];
dh=5;
simtime=1;




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
        [e1_Tput(a,b) e1_Efficiency(a,b) ready_tau e1_p e1_b_idle e1_B e1_Latency(a,b) nTF tTF]=randomaccess_nfb10(EOCWmin,EOCWmax,n,r,lambdae,U,dh,simtime,tpdf,k);
        
        disp(['Just Finished U=' num2str(U) ' for n=' num2str(n) '. That took ' num2str(toc) ' seconds' ])
        
    end
end

% t1_Efficiency

% e1_Efficiency
figure(1)
plot(nA,e1_Efficiency(:,1),':k',nA,e1_Efficiency(:,2),'k-.',nA,e1_Efficiency(:,3),'k--',nA,e1_Efficiency(:,4),'k','LineWidth',2);

 legend('U=0','U=1','U=3','U=7')
grid
axis([min(nA) max(nA) 0 1])
xlabel('Number of STAs','FontName','Times New Roman');
ylabel('Success Probability','FontName','Times New Roman');

figure(2)
plot(nA,e1_Latency(:,1),':k',nA,e1_Latency(:,2),'k-.',nA,e1_Latency(:,3),'k--',nA,e1_Latency(:,4),'k','LineWidth',2);

 legend('U=0','U=1','U=3','U=7')
grid
axis([min(nA) max(nA) 0 0.15])
xlabel('Number of STAs','FontName','Times New Roman');
ylabel('Latency (s)','FontName','Times New Roman');
%
% E=t_Eff.';
% figure(1);
% plot(nA,E(1,:),'k-',nA,E(2,:),'k--',nA,E(3,:),'k-.','Linewidth',1)
% hold on
% E=e_Eff.';
% plot(nA,E(1,:),'ko',nA,E(2,:),'k+',nA,E(3,:),'k^','Linewidth',1)
% set(gca,'FontSize',12,'FontName','Times New Roman');
% axis([4 65 0.2 1.4])
% h=legend('Analytical U=1','Analytical U=4','Analytical U=16','Simulation U=1','Simulation U=4','Simulation U=16')
% set(h,'FontSize',10);

% grid on
%
% E=t1_Eff.';
% figure(2);
% plot(nA,E(1,:),'k-',nA,E(2,:),'k--',nA,E(3,:),'k-.','Linewidth',1)
% hold on
% E=e1_Eff.';
% plot(nA,E(1,:),'ko',nA,E(2,:),'k+',nA,E(3,:),'k^','Linewidth',1)
% set(gca,'FontSize',12,'FontName','Times New Roman');
% axis([4 65 0.2 1.4])
% h=legend('Analytical U=1','Analytical U=4','Analytical U=16','Simulation U=1','Simulation U=4','Simulation U=16')
% set(h,'FontSize',10);
% xlabel('Number of STAs','FontName','Times New Roman');
% ylabel('MAC Efficiency','FontName','Times New Roman');
% grid on
% % export_fig -transparent -nocrop 'C:\Users\LEONARDO\ownCloud\Papers\RandomAccessJournalPaper\IEEEtran\Figures\SFig1.eps'
