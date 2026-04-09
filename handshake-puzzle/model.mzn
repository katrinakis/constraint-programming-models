%%%%% Problem statement %%%%%
% A couple invites n - 1 other couples to dinner. 
% Once everyone arrives, each person shakes hands with everyone they don’t know. 
% Then, the host asks everyone how many hands they shook and each person replies with a different number. 
% Assuming that everyone knows his or her own spouse, how many hands did the hostess shake?

% Parameters
int: N;
set of int: PERSON = 1..2*N; % include host
PERSON: host = 1;

% Decision variables
array[PERSON] of var 0..2*N-2: answer; % how many hands each person shook
array[PERSON, PERSON] of var bool: couple; % p,q is true if p,q are a couple
array[PERSON, PERSON] of var bool: shake; % p,q is true if p and q shake hands

var PERSON: hostess; % who is the hostess?

%%%%% Constraints %%%%%

%%% Couple constraints %%%
% 1. There are N couples
constraint sum(p,q in PERSON where p<q) (bool2int(couple[p,q])) = N;

% 2. Monogamy
% If p is a couple with q, then they are not a couple with any other person
constraint forall(p,q in PERSON where p != q) (
              if couple[p,q] then 
                  forall(r in PERSON where r!= q) (couple[p,r] = false)
              else
                  true
              endif
);

% 3. Symmetry
% If p~q then q~p.
constraint forall(p,q in PERSON where p<q) (couple[p,q] <-> couple[q,p]);

% 4. No self marriage
constraint forall(p in PERSON) (couple[p, p] = false);

% 5. The hostess is married with the host
constraint forall(p in PERSON) (couple[hostess, host] = true);

%%% Answers %%%
% Channel answer to shake
constraint forall(p in PERSON) (
               answer[p] = sum(q in PERSON) (bool2int(shake[p,q]))
);

% The host gets 2n-1 different asnwers
include "alldifferent.mzn";
constraint alldifferent([ answer[p] | p in PERSON where p != host]);

%%% Handshake rules %%%
% Couples cannot shake hands
constraint forall(p,q in PERSON) ( couple[p,q] -> shake[p,q] = false );
% Can't shake your own hand
constraint forall(p in PERSON) (shake[p,p] = false);
% Symmetry
constraint forall(p,q in PERSON where p<q) (shake[p,q] <-> shake[q,p]);

%%%%% Solve & Output %%%%%
solve satisfy;

output ["\(N) couples total\n",
        "Handshakes per couple:\n",
        concat(["\(answer[p]) (\(p)) and \(answer[q]) (\(q))\n" | p,q in PERSON where fix(couple[p,q]) /\ p<q]),
        "hostess (\(hostess)) shakes \(answer[hostess]) hands."
        ];
