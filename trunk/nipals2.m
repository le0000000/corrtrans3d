%##############################################################
%#             Analyse en Composantes Principales             #
%##############################################################
%
%                    algorithme NIPALS de calcul
%                    des vecteurs propres et des
%                    valeurs propres
%_____________________________________________________________
%
%utilisation [T L pc]=nipals2(nb,x)
%
%         T : Matrice des valeurs propres
%         L : Matrice des vecteurs propres
%         pc: Pourcentage des composantes principales
%
%         nb: Nombre de composantes souhaitées
%         x : Tableau de valeurs
%
% http://www.galactic.com/Algorithms : 
% "Principal Component Analysis Methods"
% "Calculating the Principal Components, The NIPALS Algorithm "
%  
%  (c) Geoffrey MAHE, Mai 2004
%  Université de Reims Champagne Ardennes
%
%##############################################################
%#             Principal components analysis                  #
%##############################################################
%
%Use [T L pc]=nipals2(x,nb)
%
%where T :Matrix of eigvalues
%      L :Matrix of eigvectors
%      pc:Percentage of components
%   
%      x : Table of data
%      nb: Number of components desired
%
% PC are compute with NIPALS algorithm
%
% http://www.galactic.com/Algorithms : 
% "Principal Component Analysis Methods"
% "Calculating the Principal Components, The NIPALS Algorithm "
%
%  (c) Geoffrey MAHE, Mai 2004
%  Université de Reims Champagne Ardennes


function [Tprinc,Lprinc,pc]=nipals2(tab,nbp)
% added by alexei
pc=[];
% endof added by alexei
nb_ligne=size(tab,1);
E=tab;
nb=1;
Tprinc=ones(nb_ligne,nbp);
Lprinc=ones(nbp,length(E));
varo = norm( E ); varl = varo;
while nb<=nbp
voir=1;
   %etape 2 
   
L(nb,:)=E(1,:);
 Lprinc=Lprinc';
%etape 3
Tprinc(:,nb)=E*Lprinc(:,nb);    
%etape 4
j=1;
somme=1e15;
T=Tprinc(:,nb);
Lprinc=Lprinc';
L=Lprinc(nb,:);
	while somme>eps 
      L=T'*E;
 	 	L=L'/norm(L');  
	%etape 5 et 6
    	T=E*L;
    	if j~=1
      	somme=sum(T-Ttmp);
         somme=somme^2;
       end;
       voir=voir+1;
   	Ttmp=T;
   	j=j+1;
   end;
   L=L';
   Tprinc(:,nb)=T;
   Lprinc(nb,:)=L;
%etape 7
E=E-Tprinc(:,nb)*Lprinc(nb,:);   
var = norm( E );
pc = [ pc ( 100 * ( varl - var ) / varo ) ];
varl = var;

%etape 8
nb=nb+1;
end;
return