%SuccessProb
clear
P=exp(-1);
tau=1;
U=0:16;
for u=1:length(U)
    Ps(u)=P;
   tau(u+1)=(1-P)
    P=exp(P-1);
  
end
plot(U,Ps,'k-*');
grid;
xlabel('Number of RS slots U')
ylabel('Maximum Success Probability')
axis([0 max(U) 0.3 1])

% plot(U,fliplr(tau(1:end-1)),'k-*');
% grid;
% xlabel('RS transmit slot index')
% ylabel('Optimal Transmit Probability per RA-RU')
% axis([0 max(U) 0.3 1])
% legend('Maximum Success Probability','Optimal Transmit Probability')