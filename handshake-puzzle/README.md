# The Handshake Puzzle

This is a classic problem in Discrete Mathematics. The problem statement is as follows:

In a party of $N$ couples, the host asks every person how many hands they shook. He receives $2N-1$ different answers. If a person can't shake hands with their partner, how many people did the hostess greet?

This problem can be solved using the Pigeonhole Principle and induction.

**Solution:**
There are $2N-1$ possible answers because a person can't shake hands with their partner or themselves: $0..2N-2$. Since the host receives $2N-1$ different answers, from the pigeonhole principle, every answer in $0..2N-2$ is represented.

$$\forall k \in 0..2N-2 \quad \exists ! p \in 1..2N-1: f(p)=k $$

In other words, there exists a bijection from the set of possible answers to the set of all people (except the host).

Now the person who shook $2N-2$ hands, must be married to the person who shook $0$ hands. Otherwise, because person "$2N-2$" shook all possible hands, if person "$0$" were anyone else, "$2N-2$" would have shaken hands with them.  

If we remove this couple and apply the same logic to the remaining people, it follows that persons $1$ and $2N-3$ are married. 

We continue in this way until only the middle number remains: $N-1$. Since we removed $N-1$ couples, this must be the hostess. 

Therefore, the hostess (and the host) shook $N-1$ hands. 

## Modeling as a CSP
While this problem can be cleverly solved using discrete mathematics, I thought it would be interesting to model it as a Constraint Satisfaction Problem. 

By modeling it as a CSP, we can leverage the power of Constraint Programming solvers to find a solution for various $N$.

Modeling requires thinking in a completely different way: that of declarative programming. To make a model efficient we must also think carefully about how to represent our solution, and to make sure that a solution to our model corresponds to a solution to the real problem. 

### Key optimizations
While a naive CSP would eventually find the answer, the search space for this problem is inherently symmetrical. I implemented two specific techniques to ensure the models scales for large $N$:
1. **Symmetry breaking**: Because guest couples are indistinguishable, I enforced a lexicographical ordering on their handshake counts. This collapses $(N-1)!$ permutations into a single search path. 
2. **Fixed Relational Mapping**: Instead of allowing the solver to "search" for who is married to whom (an $O(P^2)$ boolean matrix), I pre-assigned couples to indices $(2i-1, 2i)$. This significantly reduced the number of decision variables as well as constraints. 

### Benchmarking
Without symmetry breaking, the solver can't solve more than $N=10$ couples. With symmetry breaking, the answer is almost instant for $N\leq 20$.

| N  | Original   | with symmetry breaking | Solver         |
|----|------------|------------------------|----------------|
| 5  | 62msec     | 51msec                 | Chuffed 0.13.2 |
| 10 | 7s 747msec | 56msec                 | Chuffed 0.13.2 |
| 15 | 42min+     | 68msec                 | Chuffed 0.13.2 |
| 20 | -          | 85msec                 | Chuffed 0.13.2 |