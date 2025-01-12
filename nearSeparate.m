(* ::Package:: *)

(* ::Input:: *)
(*(* The following is the Mathematica code that accompanies my paper "Separating Variables in Bivariate Polynomial Ideals: the Local Case". It consists of two parts. The first part is the code Manuel wrote for the ISSAC paper "Separating Variables in Bivariate Polynomial Ideals". The second is an implementation of the algorithms outlined in the recent paper. *)*)


(* ::Input:: *)
(*(* first part... *)*)


(* ::Input:: *)
(*(*started by MK 2019-12-30*)(***)
(**Input:*)
(**--ideal:a list of bivariate polynomials over QQ generating an ideal of dimension 0.*--x,y:the variables with respect to which the polynomials are given**)
(**Output:*)
(**--a list of generators of the the algebra of separated polynomials**)Separate0D[ideal_List,x_,y_]:=Module[{xpure,ypure,terms,rems,G,vars,a,mixed},If[PolynomialGCD@@ideal=!=1,Throw["not zero dimensional"]];*)
(*{xpure,ypure}=First[GroebnerBasis[ideal,{First[#]},{Last[#]}]]&/@{{x,y},{y,x}};*)
(*If[xpure===1,Return[{{1,0},{x,0},{0,1},{0,y}}]];*)
(*terms=Join[{0,#}&/@Reverse[y^Range[0,Exponent[ypure,y]-1]],{#,0}&/@Reverse[x^Range[0,Exponent[xpure,x]-1]]];*)
(*vars=Array[a,Length[terms]];G=GroebnerBasis[ideal,{x,y}];*)
(*mixed=Transpose[terms] . #&/@NullSpace[Outer[Coefficient,Flatten[CoefficientList[(Last[PolynomialReduce[First[DeleteCases[{1,-1}*#,0]],G,{x,y}]]&/@terms) . vars,{x,y}]],vars]];*)
(*Return[Join[mixed,{#,0}&/@(xpure x^Range[0,Exponent[xpure,x]-1]),{0,#}&/@(ypure y^Range[0,Exponent[ypure,y]-1])]]]*)
(**)
(*(***)
(**Input:*)
(**--A0:a list of generators of the algebra of separated polynomials of a bivariate zero-dimensional ideal,as produced by the function Separate0D*--x,y:the variables with respect to which the polynomials are given**)
(**Output:*)
(**--a linear function which applied to a pair of polynomials produces a vector (a finite list of numbers) that is zero if and only if the input pair belongs to A0**)*)
(*MakeReductor[A0_,x_,y_]:=Module[{p,q,B,i,f},p=First[Cases[A0,{p_,0}:>p]];q=First[Cases[A0,{0,q_}:>q]];*)
(*B=(#/Last[CoefficientList[First[#],x]])&/@Sort[DeleteCases[A0,{_,0}|{0,_}],(Exponent[First[#1],x]>Exponent[First[#2],x])&];*)
(*f[{u_,v_}]:=Module[{u0,v0,t},u0=PolynomialRemainder[u,p,x];v0=PolynomialRemainder[v,q,y];*)
(*Do[{u0,v0}=Expand[{u0,v0}-Coefficient[u0,x,Exponent[First[b],x]]*b]+{t x^Exponent[First[b],x],0},{b,B}];*)
(*Return[Join[DeleteCases[Most[CoefficientList[u0+x^Exponent[p,x],x]],t],Most[CoefficientList[v0+y^Exponent[q,y],y]]]];];*)
(*Return[f];];*)
(**)
(*(***)
(**Input:*)
(**--poly:a univariate polynomial*--x:the variable in which the polynomial is stated**)
(**Output:*)
(**--a positive integer n such that poly=const*Cyclotomic[n,x],or-1 if no such n exists**)*)
(*CyclotomicQ[poly_,x_]:=Module[{phin,bound,n},phin=Exponent[poly,x];*)
(*If[Coefficient[poly,x,phin]=!=1,Return[CyclotomicQ[poly/Coefficient[poly,x,phin],x]]];*)
(*If[Expand[poly-(x-1)]===0,Return[1]];*)
(*If[Coefficient[poly,x,0]=!=1,Return[-1]];*)
(*For[n=0,n<3||n/(Exp[EulerGamma]Log[Log[n]]+3/Log[Log[n]])<=phin,n+=1,If[EulerPhi[n]==phin&&Expand[Cyclotomic[n,x]-poly]===0,Return[n]]];*)
(*Return[-1];];*)
(**)
(*(***)
(**Input:*)
(**--f:a bivariate polynomial*--x,y:the two variables in which f is stated**)
(**Output:*)
(**--a list of generators of the algebra of separated polynomials of the ideal generated by f**)*)
(*SeparatePrincipal[f_,x_,y_]:=Module[{h,t,n,alpha,index,a,b,i,j,sol,p,q},Which[Head[f]===List&&Length[f]==1,Return[SeparatePrincipal[First[f],x,y]],Expand[f]===0,Return[{{1,1}}],Expand[f]===1,Return[{{1,0},{x,0},{0,1},{0,y}}],FreeQ[Expand[f],x],Return[Prepend[{0,y^# f}&/@Range[0,Exponent[f,y]-1],{1,1}]],FreeQ[Expand[f],y],Return[Prepend[{x^# f,0}&/@Range[0,Exponent[f,x]-1],{1,1}]]];*)
(*p=Exponent[f/. y->0,x];q=Exponent[f/. x->0,y];(*f contains x^p and y^q*)If[!IntegerQ[p]||!IntegerQ[q],Return[{{1,1}}]];(*f has x or y as factor*)n=Exponent[h=Expand[Last[CoefficientList[f/. {x->x t^q,y->y t^p},t]]],x];(*omega(x^i*y^j)=q*i+p*j*)If[Expand[(h/.y->0)*(h/.x->0)]===0,Return[{{1,1}}]];(*nontrivial Newton polygon*)h=Expand[h/Coefficient[h,y,q]];alpha=ToNumberField[Coefficient[h,x,p]^(1/p)];(*normalize*)If[Length[Complement[Variables[h],{x,y}]]>0,Return[{{1,1}}]];(*no parameters beyond this point*)h=CyclotomicQ[#,x]&/@(MinimalPolynomial[Root[Function[x,First[#]],1],x]&)/@Select[FactorList[h/. {x->x/alpha,y->1},Extension->alpha],!FreeQ[#,x]&];*)
(*If[MemberQ[h,-1],Return[{{1,1}}]];*)
(*sol={Null,Null};n=LCM@@h+1;(*now n bounds the order of the roots of unity*)While[Length[sol]>1,n-=1;vars=Join[Table[a[i],{i,0,n}],Table[b[i],{i,1,n*q/p}]];*)
(*sol=Expand[Join[x^Range[0,n],y^Range[n*q/p]] . #]&/@NullSpace[Outer[Coefficient,Flatten[CoefficientList[PolynomialRemainder[vars . Join[x^Range[0,n],y^Range[n*q/p]],f,x],{x,y}]],vars]];];*)
(*Return[Prepend[Expand[{#/.y->0,(#/.y->0)-#}]&/@sol,{1,1}]]];*)
(**)
(*(***)
(**Input:*)
(**--ideal:a list of bivariate polynomials*--x,y:the two variables in which the ideal generators are stated**)
(**Output:*)
(**--a list of generators of the algebra of separated polynomials of the input ideal**)*)
(*Separate[ideal_,x_,y_]:=Module[{id,A0,A1,f,d,a,t,g,G,Delta,S,s,p},A1=SeparatePrincipal[id[1]=PolynomialGCD@@ideal,x,y];*)
(*A0=Separate0D[id[0]=GroebnerBasis[Together[ideal/id[1]],{x,y}],x,y];*)
(*Which[id[1]===1,Return[A0],id[0]==={1}||A1==={{1,1}},Return[A1],FreeQ[A1,y],p=First[GroebnerBasis[ideal,{x},{y}]];Return[{x^# p,0}&/@Range[0,Exponent[p,x]-1]],FreeQ[A1,x],p=First[GroebnerBasis[ideal,{y},{x}]];Return[{0,y^# p}&/@Range[0,Exponent[p,y]-1]]];*)
(*f=MakeReductor[A0,x,y];d=Length[f[{1,1}]];a=A1[[2]];G={{1,1}};g=0;Delta={};*)
(*While[True,Which[Length[Delta]==0,S=Range[d+1],Length[Delta]==1,S=Complement[Range[g*(d+1)],g*Range[d+1]],g!=1,S=Select[Range[g*(d+1)],Length[FrobeniusSolve[Delta,#,1]]===0&],True,S=Select[Range[FrobeniusNumber[Delta]],Length[FrobeniusSolve[Delta,#,1]]===0&];];*)
(*If[Length[S]>d,S=Take[S,d+1]];*)
(*If[Length[S]==0,Break[]];*)
(*p=NullSpace[Transpose[Table[f[a^s],{s,S}]]];*)
(*If[Length[p]==0,Break[],p=(#*LCM@@(Denominator/@#))&[Last[p]]];*)
(*AppendTo[G,Expand[Sum[p[[i]] a^S[[i]],{i,1,Length[S]}]]];*)
(*AppendTo[Delta,Exponent[p . (t^S),t]];*)
(*g=GCD[g,Last[Delta]];];*)
(*Return[G];];*)
(**)
(*(*the functions below are test functions*)*)
(**)
(*CheckSeparate0D[ideal_List,x_,y_]:=Module[{A0,G,u,v,a,b,dx},A0=Separate0D[ideal,x,y];*)
(*G=GroebnerBasis[ideal,{x,y}];*)
(*If[!MatchQ[Last[PolynomialReduce[#,G,{x,y}]]&/@(A0/. {u_,v_}:>u-v),{0..}],Throw["incorrect!"];];];*)
(**)
(*CheckSeparatePrincipal[f_,x_,y_]:=Module[{A1,dx,dy,a,b},A1=SeparatePrincipal[f,x,y];*)
(*If[Length[A1]>1&&!FreeQ[Denominator[Together[(A1[[2,1]]-A1[[2,2]])/f]],x|y],Throw["incorrect!"];];*)
(*dx=If[Length[A1]==1,10,Exponent[A1[[2,1]],x]-1];*)
(*dy=If[Length[A1]==1,10,Exponent[A1[[2,2]],y]-1];*)
(*If[Length[DeleteCases[First[Solve[Flatten[CoefficientList[Last[PolynomialReduce[Sum[a[i]x^i,{i,0,dx}]+Sum[b[i]y^i,{i,1,dy}],{f},{x,y}]],{x,y}]]==0]],_->0]]>0,Throw["incomplete!"];];];*)
(**)
(*CheckSeparate[ideal_,x_,y_]:=Module[{A,dx,dy,u,v,G,a,b,f},A=Separate[ideal,x,y];G=GroebnerBasis[ideal,{x,y}];*)
(*If[!MatchQ[Last[PolynomialReduce[#,G,{x,y}]]&/@(A/. {u_,v_}:>u-v),{0..}],Throw["incorrect!"];];*)
(*dx=If[Length[A]==1,10,Exponent[A[[2,1]],x]-1];*)
(*dy=If[Length[A]==1,10,Exponent[A[[2,2]],y]-1];*)
(*If[Length[DeleteCases[First[Solve[Flatten[CoefficientList[Last[PolynomialReduce[Sum[a[i]x^i,{i,0,dx}]+Sum[b[i]y^i,{i,1,dy}],{f},{x,y}]],{x,y}]]==0]],_->0]]>0,Throw["incomplete!"];];];*)


(* ::Input:: *)
(*(* second part... *)*)


(* ::Input:: *)
(*(* the following is an implementation of the algorithms outlined in "Separating Variables in Bivariate Polynomial Ideals: the Local Case" *)*)


(* ::Input:: *)
(*(* takes a polynomial and the set of its variables, and computes its support *)*)
(*Support[poly_, vars_]:=Module[ {},*)
(*     If[ Together[poly] === 0, Return[ {} ]];*)
(*Exponent[#,vars]&/@MonomialList[poly,vars]*)
(*]*)


(* ::Input:: *)
(*(* takes a polynomial and the set of its variables, and computes the vertices of its Newton polytope *)*)
(*NewtonPolytope[poly_, vars_] := Module[ {OutsideQ,points, p, P, x, CornerQ, e},*)
(* OutsideQ[p_, P_] := Module[ {v}, *)
(*    v = Array[x, Length[P]]; *)
(*!Resolve[e[v, *)
(*        And @@ Join[Thread[p == v . P],Thread[v >= 0], {Plus @@ v == 1}]] /. e -> Exists, Reals]];*)
(*      points = Support[poly, vars];*)
(*      Select[points, OutsideQ[#, DeleteCases[points, #]] &]*)
(*    ];*)


(* ::Input:: *)
(*(* takes the vertices of a polytope and computes its edges *)*)
(*GetEdges[polytope_] := Module[ {InnerQ,vertex, edges, possibleEdges, vector, vectors, p, e, E, *)
(*   x,ex},  *)
(*  InnerQ[e_, E_] := Module[ {v = Array[x, Length[E]]},*)
(*    Resolve[ex[v, And @@ Join[Thread[e == v . E], Thread[v >= 0]]] /. *)
(*      ex -> Exists, Reals] ];*)
(*  edges = {};*)
(*  Do[*)
(*   possibleEdges = {vertex, #} & /@ Complement[polytope, {vertex}];*)
(*   Do[*)
(*    vector = edge[[2]] - edge[[1]];*)
(*    If[*)
(*     InnerQ[vector, *)
(*      Complement[(#[[2]] - #[[1]]) & /@ possibleEdges, {vector}]],*)
(*     possibleEdges = Complement[possibleEdges, {edge}]*)
(*     ]*)
(*    , {edge, possibleEdges}];*)
(*   *)
(*   edges = Join[edges, possibleEdges]*)
(*   , {vertex, polytope}];*)
(*  Return[Union[Sort /@ edges]]*)
(*    ];*)


(* ::Input:: *)
(*(* takes the vertices of a polygon, and outputs a set of outward pointing normals for each of each edges *)*)
(*OuterNormal[polygon_,edge_]:=Module[{v,w},*)
(*v=edge[[2]]-edge[[1]];*)
(*w={-v[[2]],v[[1]]};*)
(*If[Max[(w . #)&/@(#-edge[[1]]&/@polygon)]<=0,Return[w],Return[-w]]*)
(*]*)


(* ::Input:: *)
(*(* some of the singularities of a separated multiple can be read off from some of the outward pointing normals of the edges of the Newton polygon, the following function identifies them *)*)
(*validNormals[vectorSet_]:=Module[{output,signVectors},*)
(*output={};*)
(*If[Length[vectorSet]==1,If[Sign[vectorSet[[1]][[1]]]==-1,Return[-vectorSet]]];*)
(*signVectors=Sign[vectorSet];*)
(**)
(*output=Join[output,Select[vectorSet,Sign[#]=={1,0}||Sign[#]=={1,1}||Sign[#]=={1,-1}&]];*)
(**)
(*If[MemberQ[signVectors,{1,1}],*)
(*output=Join[output,Select[vectorSet,Sign[#]=={0,1}||Sign[#]=={-1,1}&]]];*)
(**)
(*If[MemberQ[signVectors,{1,-1}],*)
(*output=Join[output,Select[vectorSet,Sign[#]=={0,-1}||Sign[#]=={-1,-1}&]]];*)
(**)
(*If[MemberQ[Sign/@output,{-1,1}]||MemberQ[Sign/@output,{-1,-1}],*)
(*output=Join[output,Select[vectorSet,Sign[#]=={-1,0}||Sign[#]=={-1,1}||Sign[#]=={-1,-1}&]]];*)
(*Return[Union[output]]*)
(*]*)


(* ::Input:: *)
(*(* takes a polynomial and the set of its variables, and outputs its outward pointing normals *)*)
(*GetAllWeights[poly_,vars_]:=Module[{polytope,edges},*)
(*polytope=NewtonPolytope[poly,vars];*)
(*edges=GetEdges[polytope];*)
(*OuterNormal[polytope,#]&/@edges*)
(*]*)


(* ::Input:: *)
(*(* takes a polynomial and the set of its variables, and outputs its valid outward pointing normals *)*)
(*GetWeights[poly_,vars_]:=Module[{polytope,edges},*)
(*polytope=NewtonPolytope[poly,vars];*)
(*edges=GetEdges[polytope];*)
(*validNormals[OuterNormal[polytope,#]&/@edges]*)
(*]*)


(* ::Input:: *)
(*(* computes the weight of a polynomial with respect to a weight function *)*)
(*Weight[poly_,vars_,w_]:=Module[{},*)
(*Max[w . #&/@Support[poly,vars]]*)
(*]*)


(* ::Input:: *)
(*(* computes the leading part of the transformation of a polynomial with respect to a weight function that matches a given pair of (potential) singularities *)*)
(*LeadingPart[poly_,vars_,singPair_]:=Module[{p,signVector,weightVectors, vector,weight,list},*)
(*p=poly;*)
(*If[singPair[[1]]!=Infinity,p=p/.vars[[1]]->vars[[1]]+singPair[[1]]];*)
(*If[singPair[[2]]!=Infinity,p=p/.vars[[2]]->vars[[2]]+singPair[[2]]];*)
(*p=Expand[FullSimplify[p]];*)
(*signVector={If[singPair[[1]]==Infinity,1,-1],If[singPair[[2]]==Infinity,1,-1]};*)
(*weightVectors=GetAllWeights[p,vars];*)
(**)
(*vector=If[Length[weightVectors]==1,weightVectors[[1]],Select[weightVectors,Sign[#]==signVector&][[1]]];*)
(*weight=Weight[p,vars,vector];*)
(**)
(*list=MonomialList[p,vars];*)
(*Return[Plus@@Select[list,Exponent[#,vars] . vector==weight&]]*)
(*]*)


(* ::Input:: *)
(*(* computes the leading part of a polynomial with respect to a given weight function *)*)
(*LeadingPartW[poly_,vars_,w_]:=Module[{weight,list},*)
(*weight=Weight[poly,vars,w];*)
(**)
(*list=MonomialList[poly,vars];*)
(*Return[Plus@@Select[list,Exponent[#,vars] . w==weight&]]*)
(*]*)


(* ::Input:: *)
(*(* computes a set of pairs of (potential) singularities that can be computed from the leading part of poly with respect to a given weight function *)*)
(*GetSing[poly_,vars_,weight_]:=Module[{lp,sing,factor},*)
(*output={};*)
(**)
(*If[weight[[1]]*weight[[2]]!=0,output={{If[weight[[1]]>0,Infinity,0],If[weight[[2]]>0,Infinity,0]}}; Return[output]];*)
(**)
(*If[weight[[1]]==0,*)
(*lp=LeadingPartW[poly,vars,weight];*)
(*factor=Times@@(#[[1]]&/@Select[FactorList[lp],!FreeQ[#,vars[[1]]]&&#[[1]]=!=vars[[1]]&]);*)
(*sing=vars[[1]]/.Solve[factor==0,vars[[1]]];*)
(*Return[{#,If[weight[[2]]>0,Infinity,0]}&/@(FullSimplify/@sing)]*)
(*];*)
(**)
(*If[weight[[2]]==0,*)
(*lp=LeadingPartW[poly,vars,weight];*)
(*factor=Times@@(#[[1]]&/@Select[FactorList[lp],!FreeQ[#,vars[[2]]]&&#[[1]]=!=vars[[2]]&]);*)
(*sing=vars[[2]]/.Solve[factor==0,vars[[2]]];*)
(*Return[{If[weight[[1]]>0,Infinity,0],#}&/@(FullSimplify/@sing)]*)
(*];*)
(*]*)
(**)


(* ::Input:: *)
(*(* takes a pair of (potential) singularities of which is different from 0 and infinity, performs a subsitution of variables, and looks for further singularities *)*)
(*GetFurtherSing[poly_,vars_,singPair_]:=Module[{p,polytope,edges,normals,weights,sings},*)
(*p=poly;*)
(*If[singPair[[1]]!=Infinity,p=p/.vars[[1]]->vars[[1]]+singPair[[1]]];*)
(*If[singPair[[2]]!=Infinity,p=p/.vars[[2]]->vars[[2]]+singPair[[2]]];*)
(*p=Expand[FullSimplify[p]];*)
(*polytope=NewtonPolytope[p,vars];*)
(*edges=GetEdges[polytope];*)
(*normals=OuterNormal[polytope,#]&/@edges;*)
(*weights=validNormals[normals];*)
(*If[singPair[[1]]!=Infinity&&MemberQ[Sign[normals],{-1,0}],AppendTo[weights,{-1,0}]];*)
(*If[singPair[[2]]!=Infinity&&MemberQ[Sign[normals],{0,-1}],AppendTo[weights,{0,-1}]];*)
(**)
(*sings=Flatten[GetSing[p,vars,#]&/@weights,1];*)
(*If[singPair[[1]]!=Infinity,sings={singPair[[1]],0}+#&/@sings];*)
(*If[singPair[[2]]!=Infinity,sings={0,singPair[[2]]}+#&/@sings];*)
(*Return[FullSimplify/@sings]*)
(*]*)


(* ::Input:: *)
(*(* function that computes the set of all pairs of potential singularities *)*)
(**)
(*getSing[poly_,vars_]:=Module[{sing,output,outputNew,degX,degY,poly1,singF,singFnew,solF,singG,singGnew,solG},*)
(**)
(*output={};*)
(**)
(*singF={};*)
(*singFnew={Infinity};*)
(*singG={};*)
(*singGnew={};*)
(**)
(*degX=Exponent[poly,vars[[1]]];*)
(*degY=Exponent[poly,vars[[2]]];*)
(**)
(*While[True,*)
(*(* finde Singularit\[ADoubleDot]ten von g *)*)
(*Do[*)
(*sing={};*)
(*If[s==Infinity,*)
(*poly1=Coefficient[poly,vars[[1]],degX],*)
(*poly1=Collect[Expand[poly/.vars[[1]]->s],vars[[2]],Simplify];*)
(*(*poly1=Collect[Expand[poly/.vars[[1]]->s],vars[[2]],Simplify]*)*)
(*];*)
(*If[Exponent[poly1,vars[[2]]]<degY,*)
(*singGnew=Union[singGnew,{Infinity}];*)
(*sing={Infinity};*)
(*];*)
(**)
(*If[Exponent[poly1,vars[[2]]]>0,*)
(*sing=Join[sing,Union[vars[[2]]/.Solve[poly1==0,vars[[2]]]]];*)
(*singGnew=Union[singGnew,sing]*)
(*];*)
(*output=Join[output,{s,#}&/@Complement[sing,singG]];*)
(*,{s,Complement[singFnew,singF]}];*)
(**)
(*If[SubsetQ[singG,singGnew],Return[Union[output]]];*)
(*singF=Union[singF,singFnew];*)
(*singFnew={};*)
(*(* finde Singularit\[ADoubleDot]ten von f *)*)
(*Do[*)
(*sing={};*)
(*If[s==Infinity,*)
(*poly1=Coefficient[poly,vars[[2]],degY],*)
(*poly1=Collect[Expand[poly/.vars[[2]]->s],vars[[1]],Simplify];*)
(*];*)
(**)
(*If[Exponent[poly1,vars[[1]]]<degX,*)
(*singFnew=Union[singFnew,{Infinity}]];*)
(*If[Exponent[poly1,vars[[1]]]>0,*)
(*sing=Join[sing,Union[vars[[1]]/.Solve[poly1==0,vars[[1]]]]];*)
(*singFnew=Join[singFnew,sing];*)
(*output=Join[output,{#,s}&/@Complement[sing,singF]];*)
(*];*)
(*,{s,Complement[singGnew,singG]}];*)
(*If[SubsetQ[singF,singFnew],Return[Union[output]]];*)
(*singG=Union[singG,singGnew];*)
(*singGnew={};*)
(*]*)
(*]*)
(*(*GetAllSing[poly_,vars_]:=Module[{polytope,edges,normals,weights,sings,singsUpdate},*)
(*polytope=NewtonPolytope[poly,vars];*)
(*edges=GetEdges[polytope];*)
(*normals=OuterNormal[polytope,#]&/@edges;*)
(*weights=validNormals[normals];*)
(*sings=Flatten[GetSing[poly,vars,#]&/@weights,1];*)
(*singsUpdate=sings;*)
(*Do[*)
(*If[pair!={Infinity,Infinity},*)
(*singsUpdate=Union[singsUpdate,GetFurtherSing[poly,vars,pair]]]*)
(*,{pair,sings}];*)
(**)
(*If[Union[sings]==Union[singsUpdate],Return[singsUpdate]];*)
(**)
(*While[sings!=singsUpdate,*)
(*sings=singsUpdate;*)
(*Do[*)
(*If[pair!={Infinity,Infinity},*)
(*singsUpdate=Union[singsUpdate,GetFurtherSing[poly,vars,pair]]]*)
(*,{pair,sings}];*)
(**)
(*];*)
(**)
(*Return[singsUpdate]*)
(*]*)*)


(* ::Input:: *)
(*getSingMult[poly_,vars_]:=Module[{p,polytope,edges,normals,weights,sings,singsUpdate,singsMult,pairMod,newSings},*)
(*sings=getSing[poly,vars];*)
(*singsMult={};*)
(*(* for each pair of singularities compute a leading part whose separated multiple gives information about its multiplicities *)*)
(*Do[*)
(*p=poly;*)
(*If[pair[[1]]!=Infinity,p=p/.vars[[1]]->vars[[1]]+pair[[1]]];*)
(*If[pair[[2]]!=Infinity,p=p/.vars[[2]]->vars[[2]]+pair[[2]]];*)
(*p=Expand[FullSimplify[p]];*)
(*pairMod={If[pair[[1]]!=Infinity,0,Infinity],If[pair[[2]]!=Infinity,0,Infinity]};*)
(*AppendTo[singsMult,{pair,LeadingPart[p,vars,pairMod]}];*)
(*,{pair,sings}];*)
(*Return[singsMult]*)
(*]*)


(* ::Input:: *)
(*(* modifies a homogeneous polynomial and separates the variables *)*)
(*nearSep[pairSing_,poly_,vars_]:=Module[{v,p,d1,d2},*)
(*v={If[pairSing[[1]]==Infinity,1,-1],If[pairSing[[2]]==Infinity,1,-1]};*)
(*p=Times@@(#[[1]]^#[[2]] &/@Select[FactorList[poly],!FreeQ[#,vars[[1]]]&&!FreeQ[#,vars[[2]]]&]);*)
(*If[v[[1]]<0,d1=Exponent[p,vars[[1]]];p=Expand[p/vars[[1]]^d1];p=p/.vars[[1]]->1/vars[[1]]];*)
(*If[v[[2]]<0,d2=Exponent[p,vars[[2]]];p=Expand[p/vars[[2]]^d2];p=p/.vars[[2]]->1/vars[[2]]];*)
(*p=Expand[FullSimplify[p]];*)
(*Return[Separate[{p},vars[[1]],vars[[2]]]]*)
(*]*)


(* ::Input:: *)
(*(* takes a list of pairs of pairs of singularities and pairs of homogeneous polynomials (the leading parts of some polynomial and its substitutions), and outputs their multiplicities *)*)
(*mult[pairSing_,vars_]:=Module[{list,sep},*)
(*list={};*)
(*Do[*)
(*sep=nearSep[pair[[1]],pair[[2]],vars];*)
(*If[Length[sep]==1,Throw["not separable, since a leading part is not separable"]];*)
(*AppendTo[list,{pair[[1]],{Exponent[sep[[2]][[1]],vars[[1]]],Exponent[sep[[2]][[2]],vars[[2]]]}}];*)
(*,{pair,pairSing}];*)
(**)
(*Return[list]*)
(**)
(*]*)


(* ::Input:: *)
(*(* takes a list of pairs, the first component of which is a pair of singularities, the second of which is a pair of positive integers, it indicates that the vector of the multiplicities of the singularities is a multiple of the given vector *)*)
(*linSystem[list_,m_,n_,k_]:=*)
(*Module[{f,equations,vars1,vars2,sol,solution,sol1,sol2},*)
(*f[_[x__]]:=x;*)
(*equations={};*)
(*Do[*)
(*AppendTo[equations,m[list[[i]][[1,1]]]-k[i]list[[i]][[2,1]]];*)
(*AppendTo[equations,n[list[[i]][[1,2]]]-k[i]list[[i]][[2,2]]];*)
(*,{i,Length[list]}];*)
(*vars1=Select[Variables[equations],!FreeQ[#,m]&];*)
(*vars2=Select[Variables[equations],!FreeQ[#,n]&];*)
(*solution=Solve[Thread[equations==0]];*)
(*sol1=Riffle[f/@vars1,First[vars1/.solution]];*)
(*sol2=Riffle[f/@vars2,First[vars2/.solution]];*)
(*Return[{sol1,sol2}]*)
(*]*)


(* ::Input:: *)
(*(* function, that makes an ansatz, according to the singularities and multiplicities found, and solves the linear system that results from comparing coefficients *)*)
(*separatedMultiple[poly_,vars_,singMult1_,singMult2_]:=Module[{f,fNumerator,fDenominator,g,gNumerator,gDenominator,d,q,qNumerator,pair,tupel,infBoolean,vv,solution,output},*)
(*fNumerator=1;*)
(*fDenominator=1;*)
(*gNumerator=1;*)
(*gDenominator=1;*)
(*pair={False,0};*)
(*Do[*)
(*If[singMult1[[i]]==Infinity,pair={True,singMult1[[i+1]]},*)
(*fDenominator=fDenominator*(vars[[1]]-singMult1[[i]])^singMult1[[i+1]]]*)
(*,{i,1,Length[singMult1],2}];*)
(**)
(*fNumerator=Sum[f[i]vars[[1]]^i,{i,0,Exponent[Expand[fDenominator],vars[[1]]]+pair[[2]]}];*)
(**)
(*pair={False,0};*)
(**)
(*Do[*)
(*If[singMult2[[i]]==Infinity,pair={True,singMult2[[i+1]]},*)
(*gDenominator=gDenominator*(vars[[2]]-singMult2[[i]])^singMult2[[i+1]]]*)
(*,{i,1,Length[singMult2],2}];*)
(**)
(*gNumerator=Sum[g[i]vars[[2]]^i,{i,0,Exponent[Expand[gDenominator],vars[[2]]]+pair[[2]]}];*)
(**)
(*d=Max[Exponent[fNumerator,vars[[1]]]+Exponent[Expand[gDenominator],vars[[2]]],Exponent[gNumerator,vars[[2]]]+Exponent[Expand[fDenominator],vars[[2]]]]-Min[Exponent[poly,vars[[1]]],Exponent[poly,vars[[2]]]];*)
(**)
(*qNumerator=Sum[q[i,j]vars[[1]]^i vars[[2]]^j,{i,0,d},{j,0,d-i}];*)
(**)
(*output={fNumerator/fDenominator,gNumerator /gDenominator};*)
(**)
(**)
(*vv=Join[Select[Variables[fNumerator],FreeQ[#,vars[[1]]]&],Select[Variables[gNumerator],FreeQ[#,vars[[2]]]&],Select[Variables[qNumerator],FreeQ[#,vars[[1]]]&&FreeQ[#,vars[[2]]]&]];*)
(*solution=Solve[Thread[Union[Flatten[CoefficientList[Expand[qNumerator*poly-fNumerator*gDenominator+gNumerator*fDenominator],{vars[[1]],vars[[2]]}]]]==0],vv];*)
(**)
(*If[Length[solution]==0,Return[{{1,1}}]];*)
(*solution=output/.solution;*)
(*Return[solution/.Thread[vv->1]]*)
(*]*)


(* ::Input:: *)
(**)


(* ::Input:: *)
(*(*getSingMult[poly_,vars_]:=Module[{p,polytope,edges,normals,weights,sings,singsUpdate,singsMult,pairMod,newSings},*)
(*(*polytope=NewtonPolytope[poly,vars];*)
(*edges=GetEdges[polytope];*)
(*normals=OuterNormal[polytope,#]&/@edges;*)
(*weights=validNormals[normals];*)
(*sings=Flatten[GetSing[poly,vars,#]&/@weights,1];*)*)
(*sings=getSing[poly,vars];*)
(*singsMult={};*)
(*(* for each pair of singularities compute a leading part whose separated multiple gives information about its multiplicities *)*)
(*Do[*)
(*p=poly;*)
(*If[pair[[1]]!=Infinity,p=p/.vars[[1]]->vars[[1]]+pair[[1]]];*)
(*If[pair[[2]]!=Infinity,p=p/.vars[[2]]->vars[[2]]+pair[[2]]];*)
(*p=Expand[FullSimplify[p]];*)
(*pairMod={If[pair[[1]]!=Infinity,0,Infinity],If[pair[[2]]!=Infinity,0,Infinity]};*)
(*AppendTo[singsMult,{pair,LeadingPart[p,vars,pairMod]}];*)
(*,{pair,sings}];*)
(**)
(*singsUpdate=sings;*)
(**)
(*(* suche nach weiteren Singularit\[ADoubleDot]ten, iteriere dabei \[UDoubleDot]ber alle Paare von Singularit\[ADoubleDot]ten *)*)
(**)
(*Do[*)
(*If[pair!={Infinity,Infinity},*)
(*newSings=GetFurtherSing[poly,vars,pair];*)
(*Do[*)
(*If[!MemberQ[sings,newPair],*)
(*AppendTo[singsUpdate,newPair];*)
(*p=poly;*)
(*If[newPair[[1]]!=Infinity,p=p/.vars[[1]]->vars[[1]]+newPair[[1]]];*)
(*If[newPair[[2]]!=Infinity,p=p/.vars[[2]]->vars[[2]]+newPair[[2]]];*)
(*p=Expand[p];*)
(*pairMod={If[newPair[[1]]!=Infinity,0,Infinity],If[newPair[[2]]!=Infinity,0,Infinity]};*)
(*AppendTo[singsMult,{newPair,LeadingPart[p,vars,pairMod]}];*)
(*];*)
(*,{newPair,newSings}]];*)
(*,{pair,sings}];*)
(**)
(*sings=Union[sings];*)
(*singsUpdate=Union[singsUpdate];*)
(*singsMult=Union[singsMult];*)
(**)
(*Print["sings: ",sings];*)
(*Print["singsUpdate: ",singsUpdate];*)
(**)
(*If[sings==singsUpdate,Return[singsMult]];*)
(**)
(*While[sings!=singsUpdate,*)
(*sings=singsUpdate;*)
(*(* Print[sings]; *)*)
(*Print[Length[sings]]; *)
(*Do[*)
(*If[pair!={Infinity,Infinity},*)
(*(* Print["pair: ",pair]; *)*)
(*newSings=Union[GetFurtherSing[poly,vars,pair]];*)
(**)
(*Do[*)
(*If[!MemberQ[sings,newPair],*)
(*Print[newPair];*)
(*AppendTo[singsUpdate,newPair];*)
(*p=poly;*)
(*If[newPair[[1]]!=Infinity,p=p/.vars[[1]]->vars[[1]]+newPair[[1]]];*)
(*If[newPair[[2]]!=Infinity,p=p/.vars[[2]]->vars[[2]]+newPair[[2]]];*)
(*p=Expand[p];*)
(*pairMod={If[newPair[[1]]!=Infinity,0,Infinity],If[newPair[[2]]!=Infinity,0,Infinity]};*)
(*AppendTo[singsMult,{newPair,LeadingPart[p,vars,pairMod]}];*)
(*];*)
(*,{newPair,newSings}]];*)
(*,{pair,sings}];*)
(*];*)
(*Return[singsMult]*)
(*]*)*)


(* ::Input:: *)
(*(* put the functions together *)*)


(* ::Input:: *)
(*nearSeparate[poly_,vars_]:=Module[{weights,sV1,sV2,list,polytope,edges,list1,list2,list3,m,n,k,int,numbers,var},*)
(*(* TODO: add a test that involves the shape of the Newton polygon of poly *)*)
(*(* compute the pairs of singularities and the associated leading parts which give information about their multiplicities  *)*)
(*list=FactorList[poly];*)
(*If[Length[list]>2||(Length[list]==2&&list[[2]][[2]]>1),Return["poly is not irreducible"]];*)
(*If[FreeQ[poly,vars[[1]]]||FreeQ[poly,vars[[2]]],Return["poly is univariate"]];*)
(*weights=GetAllWeights[poly,vars];*)
(*sV1=Sign/@weights;*)
(*sV2=Union[sV1];*)
(*If[Length[sV1]!=Length[sV2],Return[{{1,1}}]];*)
(**)
(*list1=Union[getSingMult[poly,vars]];*)
(*(* compute the multiplicities by solving the separation problem for the polynomials *)*)
(*list2=mult[list1,vars];*)
(*(* compute the 1-parameter family for the multiplicities of the singularities *)*)
(*list3=linSystem[list2,m,n,k];*)
(**)
(*numbers={};*)
(*var=Variables[list3][[1]];*)
(*Do[*)
(*AppendTo[numbers,Denominator[Coefficient[list3[[1]][[i]],var]]]*)
(*,{i,2,Length[list3[[1]]],2}];*)
(*Do[*)
(*AppendTo[numbers,Denominator[Coefficient[list3[[2]][[i]],var]]]*)
(*,{i,2,Length[list3[[2]]],2}];*)
(*list3=list3/.var->LCM@@numbers;*)
(*(* make an ansatz for a separated multiple *)*)
(*Return[separatedMultiple[poly,vars,list3[[1]],list3[[2]]]]*)
(*]*)


(* ::Input:: *)
(*(* let's do some testing... the following investigates some polynomials that arise in enumerative combinatorics; it seems that the algorithm has some issues with computing with algebraic numbers... if you find any (other) bugs, I would be glad if you let me know *)*)


(* ::Input:: *)
(*(* stepSets=Subsets[Tuples[{1,-1,0},2]];*)
(*stepSets1=Subsets[Tuples[{2,1,0,-1,2},2]]; *)*)


(* ::Input:: *)
(*(* stepsSetsList=Complement[stepSets1,stepSets]; *)*)


(* ::Input:: *)
(*(* Do[*)
(*poly=Expand[x y(1-Plus@@(Times@@({x,y}^#)&/@set))];*)
(*list=FactorList[poly];*)
(*If[Length[list]>2||(Length[list]==2&&list[[2]][[2]]>1),Continue[]];*)
(*Print[set];*)
(*Print[poly];*)
(*output=False;*)
(*Print[Timing[TimeConstrained[output=Catch[nearSeparate[poly,{x,y}]],5]]];*)
(*Print[Factor[Numerator[Together[output[[1]][[1]]-output[[1]][[2]]]]]];*)
(*,{set,stepSets}] *)*)
