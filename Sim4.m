clear
clc
close all

lambdae=200;   %lambdae packet per TF. Can accomodate about 1/tTF/lambda users. full buffer if equal to inf
EOCWminA=[0 1 2 3 4 5 6 7];
r=[16];
n=[100];
EOCWmax=7;
UA=[1 2 4 8];
dh=5;
simtime=5;




for b=1:length(UA)
    U=UA(b);
     for u=1:U
        if u==1
            maxEff(u)=exp(-1);
            tpdf(u)=1;
              k(u)=1;
        else
            maxEff(u)=exp(maxEff(u-1)-1);
            tpdf(u)=1-maxEff(u-1);
            k(u)=k(u-1)*exp(-tpdf(u))+tpdf(u);
        end
    end
    for a=1:length(EOCWminA)
        tic
        EOCWmin=EOCWminA(a);
        
        
        [e1_Tput(a,b) e1_Efficiency(a,b) ready_tau e1_p e1_b_idle e1_B e1_Latency(a,b) nTF tTF]=randomaccess_nfb10(EOCWmin,EOCWmax,n,r,lambdae,U,dh,simtime,tpdf,prod(k));
        
        disp(['Just Finished U=' num2str(U) ' for n=' num2str(n) '. That took ' num2str(toc) ' seconds' ])
        
    end
end

% t1_Efficiency

% e1_Efficiency
plot(EOCWminA,e1_Efficiency(:,1),':k',EOCWminA,e1_Efficiency(:,2),'k-.',EOCWminA,e1_Efficiency(:,3),'k--',EOCWminA,e1_Efficiency(:,4),'k','LineWidth',2);
 legend('U=1','U=2','U=4','U=8')
grid
axis([min(EOCWminA) max(EOCWminA) 0 1])
xlabel('EOCWmin','FontName','Times New Roman');
ylabel('Success Probability','FontName','Times New Roman');


 plot(nA,e1_Latency)
 legend('U=1','U=2','U=4','U=8')
grid
% axis([min(nA) max(nA) 0 1])
xlabel('Number of STAs','FontName','Times New Roman');
ylabel('Latency[s]','FontName','Times New Roman');
%
% % E=t_Eff.';
% % figure(1);
% % plot(nA,E(1,:),'k-',nA,E(2,:),'k--',nA,E(3,:),'k-.','Linewidth',1)
% % hold on
% % E=e_Eff.';
% % plot(nA,E(1,:),'ko',nA,E(2,:),'k+',nA,E(3,:),'k^','Linewidth',1)
% % set(gca,'FontSize',12,'FontName','Times New Roman');
% % axis([4 65 0.2 1.4])
% % h=legend('Analytical U=1','Analytical U=4','Analytical U=16','Simulation U=1','Simulation U=4','Simulation U=16')
% % set(h,'FontSize',10);
% 
% % grid on
% %
% % E=t1_Eff.';
% % figure(2);
% % plot(nA,E(1,:),'k-',nA,E(2,:),'k--',nA,E(3,:),'k-.','Linewidth',1)
% % hold on
% % E=e1_Eff.';
% % plot(nA,E(1,:),'ko',nA,E(2,:),'k+',nA,E(3,:),'k^','Linewidth',1)
% % set(gca,'FontSize',12,'FontName','Times New Roman');
% % axis([4 65 0.2 1.4])
% % h=legend('Analytical U=1','Analytical U=4','Analytical U=16','Simulation U=1','Simulation U=4','Simulation U=16')
% % set(h,'FontSize',10);
% % xlabel('Number of STAs','FontName','Times New Roman');
% % ylabel('MAC Efficiency','FontName','Times New Roman');
% % grid on
% % % export_fig -transparent -nocrop 'C:\Users\LEONARDO\ownCloud\Papers\RandomAccessJournalPaper\IEEEtran\Figures\SFig1.eps'
