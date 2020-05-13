%PRobability of idle
% clear
% tau=.2;
% n=2;
% r=1;
% p = sum(rand(n,r) <= tau/r)>0;


% lambdae=.1;   %0.1 packet per TF. Can accomodate about 1/tTF/lambda users. full buffer if equal to inf
%because tTF =1, ave should be more than 10, lambda should be
%less than 1/10

function [Tput Eff ready_tau p b_idle B Latency nTF tTF pC Pi]= randomaccess_nfb10(EOCWmin,EOCWmax,n,r,lambdae,S,dh,SimTime,tpdf,pk,RSSI,Ldb,Drs,Pn,S0)
% SimTime=5; %Simulation in seconds
% tTF=1;
tpreamblePHY=40e-6;   %40us
tTXOP=5.484e-3;
tSIFS=16e-6;
tTF=100e-6;
PHY=14.7*1e6;
EP=round(PHY*(tTXOP-tpreamblePHY)/8);
tACK=68e-6;
tTO=16e-6;
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
tx_sta=zeros(1,n);
for i=1:1e10
    for j=1:n
        if CNexts(j,sendindex(j))>tim %No transmit
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
    tx_sta(find(tx==1))=1; %includes New access->transmit, Waiting->Transmit and collission->transmit
    if i==500
        disp('heY');
    end
    %     rus=randi(r,length(tx_sta),1);  %transmission in RUs, rus are the chosen RUs of STAs
    %     Ss= randsample(1:length(tpdf),length(tx_sta),true,tpdf);
    %         Ss=randi(S,length(tx_sta),1);
    CWarray(i,:)=log2(A_OCW+1);
    BOarray(i,:)=A_BO;
    rus_state=repmat(zeros(1,r),n,1);  %RU map that have transmission
    sensed_rus=repmat(ones(1,r),n,1);  %RU map are idle as sensed by each STA
    
    na=r*prod(pk);
    ra=r;
    notx=sum(tx_sta)==0;
    if sum(tx_sta)>0
        %Transmitting STAs on RU
        for s=1:S   %s=1 is the first
            sta_index=find(tx_sta==1);
            for t=1:sum(tx_sta)
                tsta=sta_index(t);
                if sum(sensed_rus(tsta,:))>0
                    ru=sum(sensed_rus(tsta,:));
                    rn_factor=pk(end-s+1);
                    y(tsta)=rand;
                    tp=min(tpdf(end-s+1)*rn_factor,1);
                    if y(tsta)<tp
                        temp1=randi(sum(sensed_rus(tsta,:)));
                        temp2=find(sensed_rus(tsta,:)==1);
                        rus_state(tsta,temp2(temp1))=1;
                        tx_sta(tsta)=0;
                        sensed_rus(tsta,:)=sensed_rus(tsta,:)*0;  %disable sensing vector for stas that have transmitted
                    end
                end
            end
            %update idle sensed rus
            sta_index=find(tx_sta==1);
            for t=1:sum(tx_sta)
                tsta=sta_index(t);
                for rr=1:r
                    if rr==1
                        tempa=[];
                        temp=find(rus_state(:,rr)==1);
                        tempb=find(rus_state(:,rr+1)==1);
                        
                    elseif rr==r
                        tempa=find(rus_state(:,rr-1)==1);
                        temp=find(rus_state(:,rr)==1);
                        tempb=[];
                    else
                        tempa=find(rus_state(:,rr-1)==1);
                        temp=find(rus_state(:,rr)==1);
                        tempb=find(rus_state(:,rr+1)==1);
                    end
                    
                    if isempty(tempa)
                        temp3a(rr)=Pn-Ldb;
                    else
                        temp3a(rr)=10*log10(sum(10.^((RSSI(tsta,tempa)-Ldb)/10)));
                    end
                    if isempty(temp)
                        temp3(rr)=Pn;
                    else
                        temp3(rr)=10*log10(sum(10.^(RSSI(tsta,temp)/10)));
                    end
                    if isempty(tempb)
                        temp3b(rr)=Pn-Ldb;
                    else
                        temp3b(rr)=10*log10(sum(10.^((RSSI(tsta,tempb)-Ldb)/10)));
                    end
                end
                tempT=10*log10(10.^(temp3/10)+10.^(temp3a/10)+10.^(temp3b/10));
                sensed_rus(tsta,:)=tempT<Drs;
            end
            
            
            na=(1-min(tpdf(end-s+1)*rn_factor,1))*na;
            ra=ra*(1-min(tpdf(end-s+1)*rn_factor,1)/ra).^na;
        end
    end
    
    
    if sum(sum(rus_state))>0
        %find which STAs succeed
        for rs=1:r
            temp=find(rus_state(:,rs));
            if ~isempty(temp)
                clear temp4
                for xx=1:length(temp)
                    temp4(xx)=RSSI(temp(xx),temp(xx));
                end
                [aa,bb]=max(temp4);
                best_sta=temp(bb);
                coll_sta=temp(setdiff(1:length(temp),bb));
                cc=10*log10(sum(10.^(temp4(setdiff(1:length(temp),bb))/10)+10^(Pn/10)));
                if aa-cc>S0
                    Success(best_sta,i)=1;
                    Latencyarray(best_sta,i)=tim-T_stamp(best_sta);
                    nTFarray(best_sta,i)=nTF_stamp(best_sta);
                    Collision(best_sta,i)=0;
                    Retries(best_sta,i)=0;
                    Success(best_sta,i)=1;
                    sendindex(best_sta)=sendindex(best_sta)+1; %#ok<FNDSB>
                    A_OCW(best_sta)=OCWmin;
                    A_BO(best_sta)=fresh_BO(A_OCW(best_sta));
                else
                    coll_sta=[coll_sta; best_sta];
                end
                if ~isempty(coll_sta)
                    Collision(coll_sta,i)=1;
                    if i>1
                        Retries(coll_sta,i)=Retries(coll_sta,i-1)+1;
                    else
                        Retries(coll_sta,i)=1;
                    end
                    Success(coll_sta,i)=0;
                    A_OCW(coll_sta)=inc_OCW( Retries(coll_sta,i),OCWmin,OCWmax);
                    A_BO(coll_sta)=fresh_BO(A_OCW(coll_sta));
                    nTF_stamp(coll_sta)=nTF_stamp(coll_sta)+1;
                end
            end
        end
        
        %STAs that couldn't transmit. Consider collided
        if sum(tx_sta)~=0
            %collide
            Collision(find(tx_sta),i)=1;
            if i>1
                Retries(find(tx_sta),i)=Retries(find(tx_sta),i-1)+1;
            else
                Retries(find(tx_sta),i)=1;
            end
            Success(find(tx_sta),i)=0;
            A_OCW(find(tx_sta))=inc_OCW( Retries(find(tx_sta),i),OCWmin,OCWmax);
            A_BO(find(tx_sta))=fresh_BO(A_OCW(find(tx_sta)));
            nTF_stamp(find(tx_sta))=nTF_stamp(find(tx_sta))+1;
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

