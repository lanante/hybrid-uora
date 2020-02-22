%PRobability of idle
% clear
% tau=.2;
% n=2;
% r=1;
% p = sum(rand(n,r) <= tau/r)>0;


% lambdae=.1;   %0.1 packet per TF. Can accomodate about 1/tTF/lambda users. full buffer if equal to inf
%because tTF =1, ave should be more than 10, lambda should be
%less than 1/10

function [Tput Eff ready_tau p b_idle B Latency nTF tTF pC Pi]= randomaccess_nfb10(EOCWmin,EOCWmax,n,r,lambdae,S,dh,SimTime,tpdf,pk,EP)
% SimTime=5; %Simulation in seconds
% tTF=1;
tpreamblePHY=40e-6;   %40us
tSIFS=16e-6;
tPIFS=25e-6;
tTF=100e-6;
PHY=7.5*1e6;
% EP=round(PHY*(tTXOP-tpreamblePHY)/8);
tTXOP=EP*8/PHY+tpreamblePHY;

tACK=68e-6;
tTO=25e-6;
lambda=lambdae/tTXOP;



tim=1e-10;

for sta=1:n
    Nexts(sta,:)=exprnd_user(lambda,ceil(SimTime*lambda*1.2));  %All packets for all stations for the whole simulation tume
    CNexts(sta,:)=cumsum(Nexts(sta,:));
end

sendindex=ones(1,n);

Idle=zeros(n,ceil(SimTime*lambda));
Success=zeros(n,ceil(SimTime*lambda));
Waiting=zeros(n,ceil(SimTime*lambda));
Collision=zeros(n,ceil(SimTime*lambda));
Retries=zeros(n,ceil(SimTime*lambda));

OCWmax=2^EOCWmax-1;
OCWmin=2^EOCWmin-1;
A_BO=zeros(1,n);
A_OCW=OCWmin*ones(1,n);
BOarray=zeros(1,n);
CWarray=zeros(1,n);
tx=zeros(1,n);
Latencyarray=zeros(1,n);
nTFarray=zeros(1,n);
T_stamp=zeros(1,n);
nTF_stamp=zeros(1,n);
for i=1:1e10
    
    for j=1:n
        if CNexts(j,sendindex(j))>tim
            if i>1
                Idle(j,i)=Idle(j,i-1)+1;
            else
                Idle(j,i)=1;
            end
            Success(j,i)=0;
            Waiting(j,i)=0;
            Collision(j,i)=0;
            tx(j)=-1;
        else
            Idle(j,i)=0;
            if i>1
                if Success(j,i-1)==1  %New access
                    A_BO(j)=fresh_BO(A_OCW(j));
                    T_stamp(j)=tim;
                    nTF_stamp(j)=0;
                end
                                    tx(j)=A_BO(j)-r<=0;

            end
           
        end
    end
    Waiting(tx==0,i)=1; %Include New access->Wait, Waiting->Waiting, and Collission-> Waiting
    tx_sta=find(tx==1); %includes New access->transmit, Waiting->Transmit and collission->transmit
    if i==500
       disp('heY'); 
    end
    %     rus=randi(r,length(tx_sta),1);  %transmission in RUs, rus are the chosen RUs of STAs
%     Ss= randsample(1:length(tpdf),length(tx_sta),true,tpdf);
%         Ss=randi(S,length(tx_sta),1);
    CWarray(i,:)=log2(A_OCW+1);
    BOarray(i,:)=A_BO;
    rus=1:r;  %RUs index that are still idle
     na=r*prod(pk);
     ra=r;
     notx=isempty(tx_sta);
    if ~isempty(tx_sta)
        for s=1:S   %s=1 is the first
            if ~isempty(rus)
                nu=length(tx_sta);
                ru=length(rus);
               rn_factor=pk(end-s+1);
               y=rand(1,length(tx_sta));
               
% if s==S
% tp=1;
% 
% else
   tp=min(tpdf(end-s+1)*rn_factor,1); 
% end
               tx_sta_s=find(y<tp);
                rus_index=randi(length(rus),length(tx_sta_s),1);
                 for sta=1:length(tx_sta_s)
                    possiblecollSTA=find(rus_index==rus_index(sta));
                    if  length(possiblecollSTA)>1
                        %collide
                        Collision(tx_sta(tx_sta_s(sta)),i)=1;
                        if i>1
                            Retries(tx_sta(tx_sta_s(sta)),i)=Retries(tx_sta(tx_sta_s(sta)),i-1)+1;
                        else
                            Retries(tx_sta(tx_sta_s(sta)),i)=1;
                        end
                        Success(tx_sta(tx_sta_s(sta)),i)=0;
                        A_OCW(tx_sta(tx_sta_s(sta)))=inc_OCW( Retries(tx_sta(tx_sta_s(sta)),i),OCWmin,OCWmax);
                        A_BO(tx_sta(tx_sta_s(sta)))=fresh_BO(A_OCW(tx_sta(tx_sta_s(sta))));
                        nTF_stamp(tx_sta(tx_sta_s(sta)))=nTF_stamp(tx_sta(tx_sta_s(sta)))+1;
                    else
                        %success
                        Latencyarray(tx_sta(tx_sta_s(sta)),i)=tim-T_stamp(tx_sta(tx_sta_s(sta)));
                        nTFarray(tx_sta(tx_sta_s(sta)),i)=nTF_stamp(tx_sta(tx_sta_s(sta)));
                        Collision(tx_sta(tx_sta_s(sta)),i)=0;
                        Retries(tx_sta(tx_sta_s(sta)),i)=0;
                        Success(tx_sta(tx_sta_s(sta)),i)=1;
                        sendindex(tx_sta(tx_sta_s(sta)))=sendindex(tx_sta(tx_sta_s(sta)))+1; %#ok<FNDSB>
                        A_OCW(tx_sta(tx_sta_s(sta)))=OCWmin;
                        A_BO(tx_sta(tx_sta_s(sta)))=fresh_BO(A_OCW(tx_sta(tx_sta_s(sta))));
                        
                    end
                end
                rus=setdiff(rus, unique(rus(rus_index)));
                tx_sta=setdiff(tx_sta, tx_sta(tx_sta_s));
                na=(1-min(tpdf(end-s+1)*rn_factor,1))*na;
                 ra=ra*(1-min(tpdf(end-s+1)*rn_factor,1)/ra).^na;
            end
            
            
        end
        if ~isempty(tx_sta)
            %collide
            Collision(tx_sta,i)=1;
            if i>1
                Retries(tx_sta,i)=Retries(tx_sta,i-1)+1;
            else
                Retries(tx_sta,i)=1;
            end
            Success(tx_sta,i)=0;
            A_OCW(tx_sta)=inc_OCW( Retries(tx_sta,i),OCWmin,OCWmax);
            A_BO(tx_sta)=fresh_BO(A_OCW(tx_sta));
            nTF_stamp(tx_sta)=nTF_stamp(tx_sta)+1;
        end
    end
    %Backofffing STAs, update BO
    A_BO(Waiting(:,i)==1)=A_BO(Waiting(:,i)==1)-r;
    nTF_stamp(Waiting(:,i)==1)=nTF_stamp(Waiting(:,i)==1)+1;
    if i>1
        Retries(Waiting(:,i)==1,i)=Retries(Waiting(:,i)==1,i-1);
    end
    
    tim_prev=tim;
    if notx
        tim=tim+tTF+tTO;
    elseif sum(Success(:,i))==0  %All collide
        tim=tim+tTF+tTXOP+2*tSIFS;
    else %Some success
        tim=tim+tTF+tTXOP+3*tSIFS+tACK;
    end
    tTFarray(i)=tim-tim_prev;
    
    if tim>=SimTime
        nTFarray(n,end+1)=0;
        Latencyarray(n,end+1)=0;
        break;
    end
    
end
nTFs=i;
ready_tau=sum(sum(Collision+Success))/sum(sum(Waiting+Collision+Success));  %this is tau given not idle
psucc=sum(sum(Success))/nTFs/n;
pcoll=sum(sum(Collision))/nTFs/n;
b_idle=sum(sum(Idle>0))/nTFs/n;
Eff=psucc*n/r;
pC=pcoll;
pI=0;
Tput=sum(sum(Success))*EP/tim*8;
p=pcoll/(pcoll+psucc);
Txted=sum(Collision+Success);
cPidle=length(find(Txted(1:i)==0))/nTFs;
nTF=mean(nTFarray(find(Success==1)));
tTF=mean(tTFarray);
Latency=mean(Latencyarray(find(Success==1)));
tau=ready_tau;
Ptr=1-(1-tau)^(n-1);
Ps=n*tau/r*(1-tau/r)^(n-1);
Psucc=Ps*Ptr;
% PC=Ptr*(1-Ps)
% PI=(1-tau)^n;
Pi=(1-tau/r)^n;
pC=1-Ps-Pi;
% B=zeros(max(max(CWarray))+1,max(max(BOarray))+1);
% for i=1:EOCWmax-EOCWmin+1
%     a=find(CWarray==EOCWmin+i-1);
%     for j=1:2^EOCWmax-r
%         if j==1
%             B(i,j)=0;
%             for k=0:r
%        b=find(BOarray==k);
%          B(i,j)=B(i,j)+length(intersect(intersect(a,b),find(Idle'==0)))/nTFs/n;
%             end
%         else
%          b=find(BOarray==j+r-1);
%            B(i,j)=length(intersect(intersect(a,b),find(Idle'==0)))/nTFs/n;
%         end
%
%     end
%
% end
B=0;

end

function new_BO = fresh_BO(OCW)
for n_sta=1:length(OCW)
    new_BO=randi(OCW(n_sta)+1,1,length(OCW))-1;
end
end

function new_OCW=inc_OCW(Retry,OCWmin,OCWmax)
if length(find(Retry<0))==0
    new_OCW=(OCWmin+1)*2.^(Retry)-1;
    new_OCW(new_OCW>OCWmax)=OCWmax;
else
    error('Retry is negative!')
end
end

