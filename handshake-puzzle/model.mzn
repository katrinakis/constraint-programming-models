%%%%% Problem statement %%%%%
% A couple invites N - 1 other couples to dinner. 
% Once everyone arrives, each person shakes hands with everyone they don’t know. 
% Then, the host asks everyone how many hands they shook and each person replies with a different number. 
% Assuming that everyone knows his or her own spouse, how many hands did the hostess shake?

% Parameters
int: N;
set of int: PERSON = 1..2*N; 
PERSON: host = 1;
PERSON: hostess = 2;

% Decision variables
array[PERSON] of var 0..2*N-2: answer; % how many hands each person shook
array[PERSON, PERSON] of var bool: shake; % p,q is true if p and q shake hands

%%%%% Constraints %%%%%

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
constraint forall(i in 1..N) (
    let {
        int: p1 = 2*i - 1,
        int: p2 = 2*i
     } in (
        % person 2i is a couple with 2i-1
        shake[p1, p2] = false /\ shake[p2, p1] = false
     )
);
% Can't shake your own hand
constraint forall(p in PERSON) (shake[p,p] = false);
% Symmetry
constraint forall(p,q in PERSON where p<q) (shake[p,q] <-> shake[q,p]);

%%% Symmetry breaking %%%
% Order guest couples by their first member's handshake count
constraint forall(i in 2..N-1) (
    answer[2*i - 1] < answer[2*(i+1) - 1]
);

%%%%% Solve & Output %%%%%
solve satisfy;

output ["\(N) couples\n",
        "Handshakes per couple:\n",
        concat(["Couple (\(2*i-1)),(\(2*i)) shook \(answer[2*i-1]) and \(answer[2*i]) hands\n" | i in 1..N]),
        "The hostess (\(hostess)) shook \(answer[hostess]) hands."
        ];
