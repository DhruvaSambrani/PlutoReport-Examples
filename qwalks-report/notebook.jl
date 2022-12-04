### A Pluto.jl notebook ###
# v0.19.16

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 18e3a3f0-071b-4fac-9cc8-1858a998b220
begin
	using QuantumInformation
	using LinearAlgebra
	using SparseArrays
	using StatsBase
	using Yao
	using YaoPlots
	using PlutoUI
	using PlutoReport
	using Plots
	using Luxor
	using HypertextLiteral
end

# ╔═╡ 321a537b-421c-4333-9c9c-e782285c1e8d
@htl """<div style="height: 100vh; display: flex; align-items: center">
<div>
$(Title("Quantum Resetting of Walks", "An exploration of the effect of stochastic and quantum resetting on classical and quantum walks", "Dhruva Sambrani, supervised by Manabendra Nath Bera", "Dept of Physics, IISER - Mohali"))
</div>
</div>
"""

# ╔═╡ 282ac348-767d-4745-a195-685e154f8333
@htl """<div style="min-height: 100vh;">
<div>
$(TableOfContents(aside=false, depth=4))
</div>
</div>
"""

# ╔═╡ 3630155c-6a32-45c6-b9a4-cf73ca6f70a3
md"""
# §0 Introduction

Random walks are a commonly used tool in the arsenal of algorithms on Classical Computers to solve a variety of problems which do not have a known easy solution. The power of such methods can generally be attributed to the fact that while the space of possible solutions is vast, we generally only need to sample few solutions to come to a close solution. This power has been routinely exploited in the past to sample from Markov Chains using the MCMC algorithm which can be found in any  introductory textbook $(cite"norris_markov_1998::1") of markov processes, and they have recently been used in the fields of Financial engineering $(cite"glasserman_monte_2004::2"), fluid mechanics $(cite"griffin_investigation_2019::3"), fitting blackhole images $(cite"psaltis_markov_2022::4") and most famously in the Los Alamos project $(cite"metropolis_beginning::5").

With the advent of quantum algorithms, quantum walks have arisen as an obvious extension of classical walks in the quantum domain. The applications of quantum walks are just as many: ANN training $(cite"de_souza_quantum_2019::6"), Random Number Generation $(cite"bae_source_2021::7"), List coloring (Grover) $(cite"mukherjee_grover_2022::8"), collision finding $(cite"bonnetain_finding_2022::9"), link prediction $(cite"goldsmith_link_2022::10"). There has even been a recent foray into classifying and using a quantum-classical walk to speed up certain classical algorithms, namely the Google PageRank Algorithm $(cite"ortega_generalized_2022::11"). The increased interest in quantum walks can be attributed to the quadratic speed up which it grants the solution a-la the Grover algorithm, which itself can be considered as a Quantum Walk $(cite"qiskit_quantum::12"). While there is also interest in studying the physical implementation of the walks, we do not concern ourselves with these questions, since experimentalists are much better equipped to ask them.

In this report, we will define both the classical [(Section 1)](#e53b8390-225d-426f-ba38-b78a5e661ed0) and quantum [(Section 2)](#b5fe79fc-b3bf-4bb7-b50c-18a112fc2906) walks along with certain properties that are, while interesting in their own regard, problematic for certain scenarios [(Section 3)](#39f61061-9731-4582-8150-19198657aad5). Then, we look at previous attempts at finding a solution for this [(Section 4)](#5c1a23ba-bb8c-47d9-996f-4eca9b66dbc8), and discuss the shortcomings of the solution. Finally, we introduce a new mechanism [(Section 5)](#c13cbd97-f01f-4b31-a521-35976df5f18e) which may even eliminate the shortcomings, whose study will be continued in the second part of the Thesis Project.

Along with the theory, certain aspects of the implementation of the walks computationally are also added as necessary. This is done inline instead of in an appendix, which is the norm, since the author believes that such a presentation solidifies the readers' understanding of both, the model and the implementation.
"""

# ╔═╡ e53b8390-225d-426f-ba38-b78a5e661ed0
md"""
# §1 Classical Walks

Classical random walks are defined on a graph, with the walker being on some initial node $i_0$ with a probability $\lambda_i$, and "hopping" from node $i$ to $j$ in each time step with a probability given by $p_{ij}$. We can thus define a transition matrix $P := P_{ij} = p_{ij}$ which is row stochastic. Thus the probability mass function of the walker at timestep $t$ is given by $\lambda P^t$. Of course, the exact structure of the graph and the probabilities will decide the properties of the walk and there exists a vast amount of literature devoted to this analysis.
"""

# ╔═╡ c6cfff98-7ab7-4c0d-8551-5b923cac1c96
md"""
We however will restrict our discussion to the symmetric walk on the 1D chain. This is often called the 1D-Simple Symetric Random Walk, and defined in the following way.
"""

# ╔═╡ d23e90b6-7feb-4395-a853-95d03ddde970
md"""
## Definition

Consider an infinite 1 D chain, with nodes marked by $\mathbb{Z}$.
"""

# ╔═╡ 325bbfaa-f45e-4021-9a67-1671ff4f12af
let
	d = Drawing(800, 200)
	origin()
	for i in -5:4
		setcolor("purple")
		arc2r(Point(i*60+30, -20), Point(i*60, -30), Point(i*60+60, -30), action=:stroke)
		setcolor("darkgreen")
		arc2r(Point(i*60+30, -40), Point(i*60+60, -30), Point(i*60, -30), action=:stroke)
	end
	setcolor("purple")
	arc2r(Point(-6*60+30, -20), Point(-6*60+30, -50), Point(-6*60+60, -30), action=:stroke)
	setcolor("darkgreen")
	arc2r(Point(-6*60+30, -40), Point(-6*60+60, -30), Point(-6*60+30, -20), action=:stroke)
	setcolor("purple")
	arc2r(Point(5*60+30, -20), Point(5*60, -30), Point(5*60+30, -50), action=:stroke)
	setcolor("darkgreen")
	arc2r(Point(5*60+30, -40), Point(5*60+30, -10), Point(5*60, -30), action=:stroke)
	setfont("Helvetica", 24)
	for i in -5:5
		setcolor("#808080")
		settext("$(i)", Point(i*60, 20))
		setcolor("red")
		circle(Point(i*60, -30), 10, action=:fill)
	end
	setcolor("brown")
	setfont("Helvetica", 16)
	settext("0.5", Point(20, -51))
	settext("0.5", Point(20, -10))
	finish()
	d
end

# ╔═╡ 9c2c07c5-fb2e-4201-b95a-333395b847e6
md"""
Define the probability of hopping from node $i$ to node $j$

$$p_{ij} = \begin{cases}
	1/2 & |i - j| = 1 \\
	0 & \text{otherwise}
\end{cases}$$

And the initial state as

$$\lambda_{ij} = \begin{cases}
	1 & i = 0 \\
	0 & \text{otherwise}
\end{cases}$$

Thus, the hopper can only move to it nearest neighbors, starting from node 0.

Note that $P(X_t = i | \text{ HISTORY }) = P(X_t = i | X_{t-1})$, which means that the walk is a markov chain.
"""

# ╔═╡ 9a6a475f-e3b7-4b80-a42d-5ca5319d7cfd
md"""
## Multiple Walkers

The SSRW is clearly a stochastic process, and each run of this process will lead to different paths being chosen by the walker, and we are my interested in what the walker does on an average rather than what happens in a particular instance. Thus, we can observe multiple walks, and plot their paths to visualize how they would spread.

In order to simulate a walk, we sample $X_i \in \{-1, 1\}$ with equal probability, and add it to the previous position $S_{i-1}$ to get $S_i$. Note $S_0 = 0$. Thus, this is equivalent to sampling from `[1, -1]` uniformly `t` times and performing a cumulative sum. For `n` walkers, we can sample `(t, n)` such random numbers, and do a cumulative sum along the first dimension.
"""

# ╔═╡ e449eb90-c197-4bcf-97c9-c55e5d388e5b
bm = cumsum(rand([1, -1], (200, 15)), dims=1);

# ╔═╡ 9ec8b4fb-6010-46b9-95b8-1b03f0bc1d90
Plots.plot(bm, xlabel="\$t\$", ylabel="\$n\$", label=reshape(map(i->"W $(i)", (1:15)), 1, :), legend=:outerright, size=(700, 300).*0.8, ylims=(-40, 40))

# ╔═╡ 885813cb-5db7-44e1-943a-737e5e11cf86
md"""
## Probability mass function

Another common way to visualize the walk is to plot the probability that the walker is on node $i$ at time $t$. For this, we simply define the transition matrix and $\lambda$ appropriately and find $\lambda P^t$. Note however that the transition matrix for the SSRW is Tridiagonal with the Upper and Lower diagonals as 0.5 and the diagonal as 0, and there exist efficient storage and multiplication routines. Also, since we can only store a finite matrix, we limit the walk to some size. At the boundaries, we simply allow open conditions, because this is the easiest to implement.
"""

# ╔═╡ c4b059c2-9dba-4b64-8363-2a963dc60cc2
cps, cps_t = let 
	t = 21
	U = SymTridiagonal(fill(0., 31), fill(0.5, 30))
	λ = fill(0., 31)
	λ[16] = 1
	ps = accumulate(1:t, init=λ) do old, _
		U * old
	end[t÷3:t÷3:t], t÷3
end;

# ╔═╡ dc72c7b5-50db-4293-a6e0-362b0c144f81
Plots.plot(begin
	map(0:3) do i
		if i == 0
			init = fill(0., 31)
			init[16] = 1
			Plots.plot(-15:15, init, ylims=(0, 1), ylabel="\$P_t(n)\$", xlabel="\$n\$", title="\$t=$(i*cps_t)\$", legend=false)
		else
			Plots.plot(-15:15, cps[i], ylims=(0, 1), ylabel="\$P_t(n)\$", xlabel="\$n\$", title="\$t=$(i*cps_t)\$", legend=false)
		end
	end
end..., size=(400, 300))

# ╔═╡ e3043578-26ff-4d85-a916-dcba6164fa4a
md"""
## Properties of the walk

There are certain properties of the walk that are interesting for the problem we pose in the subsequent sections. Primarily, we are interested in the mean, standard deviation and recurrence of the graph.

The probability that a walker is on node $n$ at time $t$ is given by the expression

$$p(n, t) = \binom{t}{\frac{t+n}{2}} \frac{1}{2^t}$$

This equation is valid only if $t + n$ is even and $n \le t$. If $t + n$ is odd or $n > t$, the probability is zero

It should be obvious from the even symmetry of $p(n, t)$ that the mean $\mu(t) = \sum_n np(n,t) = 0$. This comes from the fact that the walk is symmetric.

The standard deviation of the walker position $\sigma(t) = \sqrt{\langle n^2 \rangle - \langle n\rangle^2} = \sqrt{\sum_n n^2p(n,t)} = \sqrt t$ $(cite"portugal_quantum_2018::13")
"""

# ╔═╡ b5fe79fc-b3bf-4bb7-b50c-18a112fc2906
md"""
# §2 Quantum Walks

## Introduction

Quantum walks are defined analogous to the classical walks.

First, our walker is quantum mechanical, and the position of the walker can be a superposition of the nodes. Thus, we define the state of the walker to be a superposition of the node states $|i\rangle$.

$$|\psi\rangle = \sum_i c_i|i\rangle$$

Let this Hilbert space be denoted as $\mathcal{H}_W$. The projection of the state on some node $i$ given by $|\langle i | \psi\rangle|^2 = |c_i|^2$ is understood as the probability that the walker will collapse to the state $|i\rangle$ on measurement.

To define the evolution of the node, we look back at the transition matrix $P_{ij}$. Thus we would define an operation in the following manner -

$$O |i\rangle = \sum_j \sqrt{p_{ij}} |j\rangle$$

and the walk proceeds by repeated application of $O$. 
While this expression is enough to define the walk, it is not immediately clear how one would explicitly realize such an operation. There are multiple formalisms to define such walks, but we shall use the coined quantum walk formalism which is very natural for regular graphs, as is the case for the 1D chain. Note that for the symmetric walks on nD lattices, like the 1D chain, the tight-binding model is already a well understood continous time quantum walk. However, we prefer a discrete time formalism.
"""

# ╔═╡ bb2c230e-ada1-4705-8e48-3d6a12646c45
md"""
## Coined Quantum Walk for 1D Chain

For the 1D chain, given a specific node, there are only 2 other nodes connected to it. Thus, we can add a 2 level system, which "decides" which node the walker jumps to. More formally, we attach a 2 level qubit system to the walker whose bases are denoted by $|0\rangle$ and $|1\rangle$. Let us denote this hilbert space as $\mathcal{H}_C$

Thus, we can define the shift operation as 

$S |0\rangle|i\rangle = |0\rangle|i-1\rangle$
$S |1\rangle|i\rangle = |1\rangle|i+1\rangle$

How would we define such an operation explicitly?

$S = |0\rangle\langle 0|\otimes S_L + |1\rangle\langle 1|\otimes S_R$

Where $S_L$ and $S_R$ are defined as

$S_L |i\rangle = |i-1\rangle,\ S_R |i\rangle = |i+1\rangle$

Note that $S$ operates on $\mathcal{H}_C\otimes\mathcal{H}_W$, whereas $S_L$ and $S_R$ operate on $\mathcal{H}_W$ only.

The superposition in the two choices at each step is recovered by putting the coin into a superposition of its basis states. This is achieved via a coin operator, which is commonly defined as $H\otimes I$, where $H$ is the single qubit hadamard operator.
"""

# ╔═╡ 12487390-e6e8-4d51-9756-152ecd1b5e5e
md"""
Let us explicitly write down two steps of the walk

$H\otimes I (|0\rangle |0\rangle) = \frac{|0\rangle |0\rangle + |1\rangle |0\rangle}{\sqrt 2}$
$S\left(\frac{|0\rangle |0\rangle + |1\rangle |0\rangle}{\sqrt 2}\right) = \frac{|0\rangle |-1\rangle + |1\rangle |1\rangle}{\sqrt 2}$
$H\otimes I \frac{|0\rangle |-1\rangle + |1\rangle |1\rangle}{\sqrt 2} = \frac{|0\rangle |-1\rangle + |1\rangle |-1\rangle + |0\rangle |1\rangle - |1\rangle |1\rangle}{2}$
$S \frac{|0\rangle |-1\rangle + |1\rangle |-1\rangle + |0\rangle |1\rangle - |1\rangle |1\rangle}{2} = \frac{|0\rangle |-2\rangle + (|1\rangle + |0\rangle) |0\rangle - |1\rangle |2\rangle}{2}$

!!! warning "Repeated application of Coin Operator"
	Note specifically the repeated application of the coin operator. If the coin operator is not applied in step 3, our state will end up in $\frac{1}{\sqrt{2}} (|0\rangle|-2\rangle + |1\rangle|2\rangle)$ which is not what we wanted. This is because the application of the controlled shift operation entangles the coin and the walker systems, and thus there is no superposition in each term of the system
"""

# ╔═╡ 73ab8819-8f61-402f-9854-7b83f707c9d8
md"""
## Computational Implementation

There are 2 ways to implement the Quantum walks, which are both interesting in their own ways. But the foremost thing to tackle would be how to store an infinite vector and an infinite dimensional operator. Since we cannot do either of these simply, we instead limit our walk to a node space of $2n$, and use periodic boundary conditions. 

!!! warning "Other Boundary Conditions"
	One could pick other boundary conditions too, such as the open or the absorbing boundary conditions, but both of these BCs lead to nonunitary operations, which complicate the definition and application of the gate.
"""

# ╔═╡ 2a885597-835b-4388-9231-4fe4ceaca160
md"""
### Matrix formalism

The first and more immediate method is to simply write down the matrix equivalent of the above operations. For the visualization of the implementations, we will assume that the walk occurs in a 1 D chain of size 4
"""

# ╔═╡ 0dc46d80-d78d-4ba0-8e3b-032f79889341
md"""
The coin is prefered to be in the $\frac{1}{\sqrt2}(|0\rangle + i |1\rangle)$ when we start so that the walk proceeds symmetrically $(cite"portugal_quantum_2018::13")
"""

# ╔═╡ 1f4b0340-3cf1-45c2-bbbf-a2efa43bd13d
init_coin = 1/√2 * (ket(1,2) - 1im * ket(2,2));

# ╔═╡ 2c80f1fc-5c19-4d49-8449-c610af29be84
md"""
The coin operator is trivial to write, 
"""

# ╔═╡ 193ebde4-055b-43ff-80d7-b8ec61475c2d
H = KrausOperators([sparse(hadamard(2)⊗I(4))])

# ╔═╡ 55dc5a3f-640c-4ca6-9f43-3620cb319b1e
md"""
The left and right shift operators can be defined in the following manner
"""

# ╔═╡ a0228700-fae0-4a34-bc7e-26a29630f6fd
begin
	R = collect(Tridiagonal(fill(1., 3), zeros(4), zeros(3)))
	R[1, end] = 1
	L = collect(Tridiagonal(zeros(3), zeros(4), fill(1., 3)))
	L[end, 1] = 1
	R, L
end

# ╔═╡ d90d3e9e-4e07-4c89-b8ba-fd8caf8db0df
md"""
Thus the shift operator is defined as
"""

# ╔═╡ b3b3d2a6-7d31-423e-99be-61021c26f85e
S = KrausOperators([sparse(proj(ket(1, 2)) ⊗ L + proj(ket(2, 2)) ⊗ R)])

# ╔═╡ e0dd1edb-52f3-46cd-8df6-0791c2665b65
md"""
Thus, we can repeatedly apply $S\circ H$ to the initial state and accumulate the results.
"""

# ╔═╡ a47aab64-dd71-41a9-8b73-653fc88cfe4a
begin
	init_state = proj(init_coin ⊗ ket(2,4))
	ψ = [[init_state]; accumulate(1:40, init=init_state) do old, _
		H(S(old))
	end]
end;

# ╔═╡ 5038a6a6-d8bf-4cbb-81bd-ecefa150c744
md"""
Now we can plot the readout statistics by partially tracing out the coin, and plotting the diagonal. The following is a walk on 61 nodes.
"""

# ╔═╡ c66ccef2-2b29-4257-8ed7-382290ae8fdc
qps = let
	R = collect(Tridiagonal(fill(1., 60), zeros(61), zeros(60)))
	R[1, end] = 1
	L = collect(Tridiagonal(zeros(60), zeros(61), fill(1., 60)))
	L[end, 1] = 1
	U = KrausOperators([sparse(proj(ket(1, 2)) ⊗ L + proj(ket(2, 2)) ⊗ R)])
	init_coin = 1/√2 * (ket(1,2) - 1im * ket(2,2))
	H = KrausOperators([sparse(hadamard(2)⊗I(61))])
	init_state = proj(init_coin ⊗ ket(31,61))
	ψ = [[init_state]; accumulate(1:40, init=init_state) do old, _
		H(U(old))
	end]
	map(enumerate(real.(diag.(ptrace.(ψ, Ref([2, 61]), Ref([1])))))) do (t, ps)
		Plots.plot(-30:30, ps, ylims=(0, 0.51), xlabel="\$i\$", ylabel="\$|\\langle i|\\psi\\rangle|^2\$", title="\$t=$(t-1)\$", legend=false)
	end
end;

# ╔═╡ 6c662f9d-5eb8-4405-8fb0-c6893b38a7f9
Plots.plot(qps[1], qps[14], qps[27], qps[40], size=(600, 400).*0.7)

# ╔═╡ 0bd7b11f-831f-4b27-b62b-85900bcb97e3
md"""
!!! note "Quantum Walks are not random"
	Note, this is a single walker, not an ensemble of walkers as is the case in classical random walks. Quantum walks (without measurement), are completely deterministic.
"""

# ╔═╡ f3e01cb0-799c-49ba-9e1b-4f90881cf542
md"""
### Circuit Formalism
"""

# ╔═╡ 56895409-dec3-4b31-a90b-29d6b07e7afe
md"""
While the matrix definition of the Quantum Walks are easy to formalize and understand, finally these need to be simulated on some sort of device which may require us to reformulate it. Further, we try to ensure that the reformulation allows for easy additions of other dynamics which we may want to study.

The advantages of using a Quantum Computer over a classical computer for a quantum walk should be obvious. The problem however is that the quantum walk is over a high dimensional space, and we rarely have access to such high dimensional systems which we can control easily. Instead we need to simulate such a system using the accessible 2 level systems available in quantum computers.

Let us define the basic components of our walk.
"""

# ╔═╡ 085ed711-e8e4-415a-a066-e6f623c41ce2
md"""
#### Nodes

- Each numbered node is then converted into its 2-ary $n$ length representation denoted by $(x_i)$. $n$ is chosen such that $2^n$ > $N$
- These bitstrings are encoded into an $n$ qubit computer, where each basis state in the computational basis corresponds to the node with the same bitstring.
- The amplitude of a particular basis corresponds to the amplitude of the walker in the corresponding node
"""

# ╔═╡ 4a3cabc6-65d3-4a32-b6c6-9cbb9402d887
md"""
#### Coin

- The Walk Coin is a two level system, as usual
"""

# ╔═╡ ec6802d7-923c-4da4-b6a9-07624288c340
md"""
#### Edges and Shifts

- Since shifts are only to adjacent nodes, the left (right) shift is equivalent of subtracting (adding) 1 from the bitstring of the state.
- From the Quantum adder circuit, we can set one input to be $(0)_{n-1}1$ and reduce the circuit to get the Quantum AddOne circuit. Shown below is the circuit for $n=4 $ $(N=16)$
"""

# ╔═╡ c5efcb81-24be-4c78-9ba2-e31e7e0f74bb
md"""
- We can similarly construct the SubOne circuit, but that is simplified by noting that the subone circuit is simply the inverse of the addone circuit, and this corresponds to just inverting the circuit (all gates are unitary)."""

# ╔═╡ 82c1e3a7-e8c6-4362-9baa-004a3fadec5a
begin
	rightshift(n) = chain(
		n, 
		map(n:-1:2) do i
			control(1:i-1, i=>X) end..., 
		put(1=>X)
	)
	leftshift(n) = rightshift(n)'
end

# ╔═╡ 32ee643b-8a6e-4cd3-acb4-679e9b51fe2c
YaoPlots.plot(rightshift(4))

# ╔═╡ 6ff3f999-f338-4846-9527-bea14bd2cd41
YaoPlots.plot(leftshift(4))

# ╔═╡ 32e242f7-c359-4f58-8593-1df6143edd37
md"""
The controlled shift operation is encoded as
"""

# ╔═╡ 9953da4f-c21a-4d3a-9136-26540c1477f4
shift(n) = chain(n+1,
	control(1, 2:n+1 => rightshift(n)),
	put(1 => X),
	control(1, 2:n+1 => leftshift(n)),
	put(1 => X),
)

# ╔═╡ a0d828f1-6c0e-4306-a5c3-be4cee6b0bb0
YaoPlots.plot(shift(4))

# ╔═╡ 3360078d-c0b2-4273-8967-e1eb5e5eadf5
md"""
#### Coin operator

We can add the coin operator as usual 
"""

# ╔═╡ 8a69232a-c37a-495d-a865-59116fae65c7
coin(n, c=Yao.H) = chain(n+1, put(1 => c))

# ╔═╡ 85c84ddc-5ca1-4a75-98ca-56f9dac1381a
YaoPlots.plot(coin(4))

# ╔═╡ 588717d2-9147-416a-ba33-1c6ac27ef149
md"""
#### Evolve Circuit

Putting these together, we get the operation for a single step of the evolution as below. Note that the top qubit rail is that of the coin, and the rest are those of the simulation of the system.

This circuit can be repeated to acheive any number of steps.
"""

# ╔═╡ a1ab11f1-335b-43c0-8b5d-e64fef827bef
evolve(n) = shift(n) * coin(n)

# ╔═╡ a5175ffc-58f7-473b-bf27-616c634d6a33
YaoPlots.plot(evolve(4))

# ╔═╡ 9e4db8fe-cf78-4b3c-9c47-e25d9fe11ec9
md"""
#### Prepare circuit

While we can already simulate the walk, an very useful helper function that we can define is the prepare circuit. 

Quantum registers are often initialized to the 0 state, and it is also easy to restart the walk from the 0 state. However, we often like to start the walk in the center of the chain instead of at node 0. Also, the coin is prefered to be in the $\frac{1}{\sqrt2}(|0\rangle + i |1\rangle)$ when we start so that the walk proceeds symmetrically $(cite"portugal_quantum_2018::13::renato: pg 30").

Hence, to perform these steps, we define the following `prepare` subroutine."""

# ╔═╡ a3f36cc0-1325-43fb-817c-2c4534337652
prepare(n) = chain(
	n+1, 
	put(1=>Yao.H), 
	put(1=>Yao.shift(-π/2)), 
	put(n+1=>X)
)

# ╔═╡ 54018ac9-c4ed-4891-9a48-d56901b21d69
YaoPlots.plot(prepare(3))

# ╔═╡ 796866ed-254d-420d-ba08-3caa074a844f
md"""
Similarly plotting as before, 
"""

# ╔═╡ cac791b2-95a4-4a30-ac77-a4c213a2e062
Plots.plot(map([1, 13, 26, 39]) do k
	zero_state(7) |> 
		prepare(6) |> 
		evolve(6)^k |> 
		r->density_matrix(r, 2:7) |>
		r->abs.(diag(r.state)) |>
		x->Plots.plot(-32:31, x, ylims=(0,0.5), xlabel="\$n\$", ylabel="\$|\\langle n|\\psi\\rangle|^2\$", legend=:none, title="\$t=$(k)\$")
end...)

# ╔═╡ 422d631e-0827-4d66-b5d3-f52a7b248a34
md"""
Thus we can see that the two formalisms are the same.
"""

# ╔═╡ 206b0a72-f033-4913-9f3c-c9b7b676d09c
md"""
## Properties of the walk

Similar to the classical random walk, the mean $\mu(t) = 0$.

However, a more interesting feature is that the standard deviation $\sigma(t) = 0.54 t$ $(cite"portugal_quantum_2018::13"). Compare this with the classical random walk, the quantum walk has a quadratic speed up. This the reason for the quadratic speedup commonly seen in the Grover search and other monte carlo problems.
"""

# ╔═╡ 0ac0bddc-290d-4456-a1c0-fd30937483d4
LocalResource("./11-23-15-35.png", "style"=>"max-width: 55%")

# ╔═╡ 39f61061-9731-4582-8150-19198657aad5
md"""
# §3 Markov Processes and Hit Rates

## Search Problems

A common application of walks is in search problems. In search problems, we generally have a black box function 

$$f(x) = \begin{cases}
	0 & x \in G\\
	1 & x \in G^C
\end{cases}$$

where $G \cup G^C = S$ which is the search space. We are interested in developing an algorithm to output some $x \in G$ by querying $f$. This problem however is much more complex, as we require some sort of "learning" by the walker to reach the output nodes. Instead, we look at a simpler problem of hitting a selected target node. Naturally, we not only want high success rates, but we also want low mean hit times.
"""

# ╔═╡ 3a207fea-9c6b-4b32-aafc-982750b4dc01
md"""
## Formalism

Define the following
- Denote the readout at the nᵗʰ measurement (at $t=n\tau$) as $X_n$.
- Select a target node $\delta$
- Probability of first hit in $n$ steps $F_n = P(X_n = \delta | X_i \ne \delta \forall i \in [0, n-1])$
- Mean hit time $\langle t_S \rangle = \sum_{i=0}^\infty i F_i$
- Success probability in $n$ steps $S_n = \sum_{i=1}^{n}F_i = P(\exists i \in [0, n]| X_i = \delta)$
- Survival probability $=$ Failure probability $= \mathcal{S}_n = 1 - S_n$
- Asymptomatic versions of these terms are given by taking $n\to \infty$
"""

# ╔═╡ 8538bc76-6f2d-422a-b225-48051876bc60
md"""
### Readout in Walks

To identify whether a walker has hit the target node, we need to track the location of the walker as it evolves in time.

For the classical case, this poses no problem, as measurement does not disturb the system. In the quantum case however, we need to be a bit more careful.

A constantly measured walker will freeze the dynamics of a quantum walker. This is known as the Quantum Zeno effect. The solution for this is to measure after every $\tau$ steps.

!!! note "τ=1"
	The quantum $\tau = 1$ case reduces the discrete time quantum walk to a classical random walk with $\tau=1$

Let us plot the readout trajectories of walkers with different paramters

"""

# ╔═╡ 21ef3cf8-7e34-410e-bd8d-4c28b327afcc
begin
	mqwts, mqwpaths = let
		R = collect(Tridiagonal(fill(1., 80), zeros(81), zeros(80)))
		R[1, end] = 1
		L = collect(Tridiagonal(zeros(80), zeros(81), fill(1., 80)))
		L[end, 1] = 1
		U = KrausOperators([sparse(proj(ket(1, 2)) ⊗ L + proj(ket(2, 2)) ⊗ R)])
		init_coin = 1/√2 * (ket(1,2) - 1im * ket(2,2))
		H = KrausOperators([sparse(hadamard(2)⊗I(81))])
		init_state = proj(init_coin ⊗ ket(41,81))
		k = 204
		τ = 6
		ys = map(1:15) do _
			ψ = [[(41, init_state)]; accumulate(1:k, init=(41, init_state)) do (lr, old), t
				ψ′ = H(U(old))
				if t % τ == 0
					coin = ptrace(ψ′, [2, 81], [2])
					lr = sample(1:81, Weights(real(diag(ptrace(ψ′, [2, 81], [1])))))
					ψ′ = coin ⊗ proj(ket(lr, 81))
				end
				(lr, ψ′)
			end]
			first.(ψ)[1:τ:k+1] .- 41
		end
		0:τ:τ*(length(first(ys))-1), ys
	end;
	mqwts_2, mqwpaths_2 = let
		R = collect(Tridiagonal(fill(1., 80), zeros(81), zeros(80)))
		R[1, end] = 1
		L = collect(Tridiagonal(zeros(80), zeros(81), fill(1., 80)))
		L[end, 1] = 1
		U = KrausOperators([sparse(proj(ket(1, 2)) ⊗ L + proj(ket(2, 2)) ⊗ R)])
		init_coin = 1/√2 * (ket(1,2) - 1im * ket(2,2))
		H = KrausOperators([sparse(hadamard(2)⊗I(81))])
		init_state = proj(init_coin ⊗ ket(41,81))
		k = 204
		τ = 10
		ys = map(1:15) do _
			ψ = [[(41, init_state)]; accumulate(1:k, init=(41, init_state)) do (lr, old), t
				ψ′ = H(U(old))
				if t % τ == 0
					coin = ptrace(ψ′, [2, 81], [2])
					lr = sample(1:81, Weights(real(diag(ptrace(ψ′, [2, 81], [1])))))
					ψ′ = coin ⊗ proj(ket(lr, 81))
				end
				(lr, ψ′)
			end]
			first.(ψ)[1:τ:k+1] .- 41
		end
		0:τ:τ*(length(first(ys))-1), ys
	end;
	mqwts_3, mqwpaths_3 = let
		R = collect(Tridiagonal(fill(1., 80), zeros(81), zeros(80)))
		R[1, end] = 1
		L = collect(Tridiagonal(zeros(80), zeros(81), fill(1., 80)))
		L[end, 1] = 1
		U = KrausOperators([sparse(proj(ket(1, 2)) ⊗ L + proj(ket(2, 2)) ⊗ R)])
		init_coin = 1/√2 * (ket(1,2) - 1im * ket(2,2))
		H = KrausOperators([sparse(hadamard(2)⊗I(81))])
		init_state = proj(init_coin ⊗ ket(41,81))
		k = 204
		τ = 1
		ys = map(1:15) do _
			ψ = [[(41, init_state)]; accumulate(1:k, init=(41, init_state)) do (lr, old), t
				ψ′ = H(U(old))
				if t % τ == 0
					coin = ptrace(ψ′, [2, 81], [2])
					lr = sample(1:81, Weights(real(diag(ptrace(ψ′, [2, 81], [1])))))
					ψ′ = coin ⊗ proj(ket(lr, 81))
				end
				(lr, ψ′)
			end]
			first.(ψ)[1:τ:k+1] .- 41
		end
		0:τ:τ*(length(first(ys))-1), ys
	end;
end;

# ╔═╡ 64adae71-0cdd-4518-8187-7e8f8b57cd7f
bm2 = cumsum(rand([1, -1], (205, 15)), dims=1)[mqwts.+1, :];

# ╔═╡ edf031c0-f91d-4a43-9efa-9bd356fef742
let 
	q = Plots.plot(
		mqwts, mqwpaths, 
		ylims=(-40, 40), 
		ylabel="\$n\$", xlabel="t", title="Quantum Readout Path, \$\\tau = 6\$", 
		labels=reshape(map(i->"W $(i)", 1:length(mqwpaths)), 1, :), legend=:outerright,
		size=(700, 400)
	)
	p = Plots.plot(
		mqwts, bm2, 
		ylims=(-40, 40), 
		ylabel="\$n\$", xlabel="t", title="Classical Readout Path, \$\\tau = 6\$", 
		labels=reshape(map(i->"W $(i)", 1:length(mqwpaths)), 1, :), legend=:outerright,
		size=(700, 400)
	)
	q2 = Plots.plot(
		mqwts_2, mqwpaths_2, 
		ylims=(-40, 40), 
		ylabel="\$n\$", xlabel="t", title="Quantum Readout Path, \$\\tau = 10\$", 
		labels=reshape(map(i->"W $(i)", 1:length(mqwpaths)), 1, :), legend=:outerright,
		size=(700, 400)
	)
	q3 = Plots.plot(
		mqwts_3, mqwpaths_3, 
		ylims=(-40, 40), 
		ylabel="\$n\$", xlabel="t", title="Classical Readout Path, \$\\tau = 1\$", 
		labels=reshape(map(i->"W $(i)", 1:length(mqwpaths)), 1, :), legend=:outerright,
		size=(700, 400)
	)
	k = Plots.plot(p, q, q2, q3, size=(1400, 800) .* 0.65)
end

# ╔═╡ fc0cafa0-141c-4c69-8dc3-cb3f1636ca7a
md"""
Note the very clear difference in the spread between the classical readout and the quantum readout for same $\tau$. Similarly note the spread between the quantum readouts for different $\tau$s.
"""

# ╔═╡ 6d0ae694-6afa-4d9b-af7d-2664aec95107
md"""
## Markov Chains and Walks

In the classical case, it is clear that the 1D SSRW is a markov process. In the appendix, we show that the quantum walk with measurement is also a markov process.

Consequently, we can use certain results from the theory of Markov processes to compare the two walks.
"""

# ╔═╡ eabbfd4c-beb9-4459-b84d-3f55bfa5be2a
md"""
### Irreducibilty and Recurrence

Under the usual definition of irreducibility $(cite"norris_markov_1998::1"),

!!! define "Definition: Irreducibility"
	If $\forall i, j \in S, \exists n, m | P^n_{ij} > 0, P^m_{ji}>0$, then the chain is called irreducible. 

It is trivial that in the 1D chain, $n = m = |i-j|\tau$ satisfies the condition.

Following $(cite"norris_markov_1998::1"),
!!! define "Definition: Recurrence"
	If $i \in S, \sum_{n=1}^\infty P^n_{ii} \to \inf$, then the state is called recurrent. Equivalently, $\sum_n F_n \to 1$ for recurrent nodes. If a chain is irreducible and one of its states is recurrent, all its states are recurrent and thus the chain is called recurrent.

It is a well known fact that the 1D SSRW is recurrent. It is just as well known a fact that the 3D SSRW is transient  $(cite"norris_markov_1998::1"). In the quantum case, it is not as clear whether any of the available definitions of the quantum markov process is more or less better than the others. Thus, the transience of quantum walks depends on the exact definition we are working under. In our definition however, it can be shown using symbolic computation $(cite"friedman_quantum_2017::14") that the walk is indeed transient. This poses an interesting problem.
"""

# ╔═╡ 04a1586f-a68f-4fbf-8648-e72e89a6459b
md"""
## Survival probability

We can thus measure and plot the $S_n - n$ curve for the quantum and classical walks to compare the efficiency of these walks in the first hit problem.

!!! danger "Continuous Walks"
	Note that the following results are for continuous time walks solved numerically using the analytical solution. Such a result for discrete time walks is harder due to the nature of the walk.	However we intend to reproduce the analytical results for the discrete time case too.
	
	Computationally too, due to the finite size of the walk space, the walk automatically becomes recurrent. However one can still observe qualitatively similar plots. Such a plot can be found in the next section.

Below are the plots from $(cite"yin_restart_2022::15") for the quantum and classical walks.

"""

# ╔═╡ 919d5e02-c238-45f0-9f01-3aa3c00fc3e2
htl"""
<center><h5>Success Probability vs Time</h5></center>
$(LocalResource("./11-26-00-48.png", "style"=>"max-width: 75%"))
"""

# ╔═╡ 03b23e63-ad05-475d-9696-ca4623d0f0f9
md"""
### Observations
- The quantum walk has a fast rise in the initial phase but saturates at ~0.1
- The classical walk has a slow rise, but eventually reaches 1

So while the quantum walker is faster, the walk is now transient, which leads to a non zero asymptomatic failure rate.
"""

# ╔═╡ 97f655bc-a0b1-47ef-8718-19571deb91ef
md"""
Clearly this is a problem. What this means physically is that for the first hit problem, if the quantum walk hits the target node, it does so faster than the classical walk, but a majority of the times, it doesn't hit the target node at all.
"""

# ╔═╡ 5c1a23ba-bb8c-47d9-996f-4eca9b66dbc8
md"""
# §4 The Solution: Resetting

The crux of the matter is this. The quantum walk is fast in the initial phase, but eventually saturates asymptotically to a success rate of < 1. This means that some of the walkers hit the target, and others do not. If that is the case, is it possible to restart the walk when it starts saturating? That is, can we restart the walk for the walkers that have not yet hit the target after $r\tau$ time?

For such dynamics, we will need to reformulate the walk slightly.
"""

# ╔═╡ 06f4f464-d63a-477b-93d6-26db971190bd
md"""
## Formalism

A reset of the walker implies that the walker returns to its initial state, and the walk dynamics continue from there.

However, we can vary when we reset the walker by considering multiple reset processes. A common reset process is the Poissonian reset, where the reset times are modelled as a poissonian process with some parameter $r$. This is particularly convenient in the case of continuous time walks.
"""

# ╔═╡ 90aa1b83-eb61-477b-b024-5f89b3c35c77
md"""
For the discrete walks, the geometric distribution is more natural.

$t \sim \text{Geom}(\gamma)$

that is, at each step, there is a $\gamma$ probability of reset.

This results in different dynamics, which can be seen in subsequent subsections, but it has an equally drastic effect on the recurrence of the walk.
"""

# ╔═╡ 882c7d4f-2afa-4e3f-bb42-24eaf40e13b4
md"""
### Recurrence and Resetting

In the geometric resetting case, it is clear that $P^n_{00} \ge \gamma$, and hence $\sum_n P^n_{00} \ge \sum_n \gamma$ which diverges as $n \to \infty$. Thus regardless of the initial walk, the final walk will definitely be recurrent. Thus the motivation for resetting the quantum walk which is transient should be immediately clear.
"""

# ╔═╡ ec6dafb9-eebf-4514-b30e-c98be9475aa6
md"""
#### Stochastic Reset Classical Walk

In the classical case, the transition probabilities change to 

$$p_{ij} = \begin{cases}
	(1-\gamma) \cdot 1/2 & |i - j| = 1 \\
	\gamma & j = r_0 \\
	0 & \text{otherwise}
\end{cases}$$

"""

# ╔═╡ 6d106756-d1a0-4521-94af-1d4948521b2f
cprs = let 
	U1 = sparse(SymTridiagonal(fill(0., 31), fill(0.5, 30)))
	R = fill(0., (31, 31))
	R[21,:] .= 1
	U = sparse(0.8 * U1 + 0.2 * R)
	init = fill(0., 31)
	init[16] = 1.
	ps = accumulate(1:40, init=init) do old, _
		U * old
	end
	map(0:40) do t
		if t == 0
			init = fill(0., 31)
			init[16] = 1
			Plots.plot(-15:15, init, ylims=(0, 1), ylabel="\$P_t(n)\$", xlabel="\$n\$", title="\$t=$(t)\$, \$\\gamma=0.2\$, \$r_0=5\$", legend=false)
		else
			Plots.plot(-15:15, ps[t], ylims=(0, 1), ylabel="\$P_t(n)\$", xlabel="\$n\$", title="\$t=$(t)\$, \$\\gamma=0.2\$, \$r_0=5\$", legend=false)
		end
	end
end;

# ╔═╡ d4bfdc20-33b0-44bc-8edd-32c8e0506fbf
Plots.plot(cprs[1], cprs[3], cprs[6], cprs[16])

# ╔═╡ b1d43b1b-8606-45cc-9c56-41d894ed8f2f
md"""
#### Stochastic Reset Quantum Walk

In the quantum case, the evolution changes from unitary dynamics to a nonunitary CPTP map of the following form.

$$O_{SR}(\rho) = (1-\gamma)\left(U\rho U^\dagger\right) + \gamma |r_0\rangle\langle r_0|$$

where $U$ is the walk unitary.
"""

# ╔═╡ 7fdbda85-3a10-4437-95d5-591e0c29d9f6
qpsrs = let
	function swqw(n, γ)
		R = collect(Tridiagonal(fill(1., n), zeros(n+1), zeros(n)))
		R[1, end] = 1
		L = collect(Tridiagonal(zeros(n), zeros(n+1), fill(1., n)))
		L[end, 1] = 1
		U = KrausOperators([sparse(proj(ket(1, 2)) ⊗ L + proj(ket(2, 2)) ⊗ R)])
		init_coin = 1/√2 * (ket(1,2) - 1im * ket(2,2))
		H = KrausOperators([sparse(hadamard(2)⊗I(n+1))])
		init_state = proj(init_coin ⊗ ket(n÷2 + 1, n+1))
		ψ = [[init_state]; accumulate(1:40, init=init_state) do old, _
			(1-γ)*H(U(old)) + γ*proj(init_coin ⊗ ket(n÷2+6, n+1))
		end]
		map(enumerate(real.(diag.(ptrace.(ψ, Ref([2, n+1]), Ref([1])))))) do (t, ps)
			Plots.plot(-n÷2:n÷2, ps, ylims=(0, 1), xlabel="\$i\$", ylabel="\$\\langle i|\\psi\\rangle\$", title="\$t=$(t), \\gamma=$(γ), r_0 = |5\\rangle \$", legend=false)
		end
	end
	swqw(60, 0.2)
end;

# ╔═╡ 9f9d7dde-b6b2-4ce1-9e34-0d8aced54017
Plots.plot(qpsrs[1], qpsrs[3], qpsrs[6], qpsrs[16])

# ╔═╡ 8baecd5c-0a53-40b2-bb46-aef6f1a4145b
md"""
## Effect of Resetting on First Hit problem
"""

# ╔═╡ d6b0ac63-3deb-474b-bd7f-f8151f7fb12c
md"""
For this analysis, we will consider the simpler "sharp reset" formalism, where the reset time is sampled from a distribution 

$t_r \sim \delta(t-r\tau)$

Thus we restart after $r$ measurement events (at $t = r\tau$). Once we understand the effect of this kind of reset, gaining intuition for reset times sampled differently is easier.
"""

# ╔═╡ 55c1fe20-da3a-4818-8984-80ef3279ba2b
md"""
The success probability vs time can now be plotted $(cite"yin_restart_2022::15") for the reset case.
"""

# ╔═╡ 36f3a7c2-a598-461d-9f9d-d6d0c324efc3
htl"""
<center><h5>Reset Success Probability vs Time</h5></center>
$(LocalResource("./11-26-00-57.png", "style"=>"max-width: 75%"))
"""

# ╔═╡ ddba1bac-9386-463b-9127-507388b243ef
md"""
Now we see that the success probability is drastically increased for both cases, but due to the ballistic nature of the quantum walk, we see that the reset quantum walk performs much better than the classical walk.
"""

# ╔═╡ 20ae60e2-2236-4012-9253-17c714dbdf8d
md"""
For a better understanding of the performance of the reset quantum walk with reference to changing reset rates ($r$) and measurement times ($\tau$), we can plot $(cite"yin_restart_2022::15") the mean first hitting time vs these parameters.
"""

# ╔═╡ 3ce7ba98-1e93-4e66-8f7c-7a958f9e05e2
LocalResource("./11-26-01-02.png", "style"=>"max-width: 55%")

# ╔═╡ c591256d-1e52-4f75-97c6-5144575bc3b9
md"""
### Observations
- Deterministic restart leads to zero asymptomatic failure rate
- Eager restarting leads to walker never reaching $\delta$, reducing success rates drastically
- Cautious restart reduces the effect of restart, reducing success rates.
- There exists an optimal $r$, but this needs to be optimized, which is non trivial for general $\tau$ and graph structures.

**Can stochastic restarting be better than sharp reset?**

No, because even if $\langle r\rangle = r_{\text{optimal}}$, $\langle t_f\rangle > \langle t_f\rangle_{\text{optimal}}$ due to the non-monotonic nature of the curve
"""

# ╔═╡ 7abebb64-0e9b-4058-a397-95a1cce567ee
md"""
## The Problem in the Solution

As discussed before, reset rates which are very high or low can end up being detrimental to the success times of the walk. Secondly, there is no clear path as to how to optimize the reset parameter for arbitrary graph structures.

Just as we harnessed the power of quantum superposition to speed up the walk, can we similarly have a superposition between the reset and evolution?
"""

# ╔═╡ c13cbd97-f01f-4b31-a521-35976df5f18e
md"""
# §5 REDACTED
"""

# ╔═╡ 4756d81b-dc4b-47f7-b4fa-23231da95d6b
md"""
# Future Directions and Methods

We intend to use computational simulations, symbolic analysis (possibly aided by a computer), along with a more general model for resetting, drawing inspiration from reference $(cite"bonomo_first_2021::17") to analyse this new formalism to see whether there are any benefits in the definition of the problem.

**REDACTED**

We will use, as used until now too, the Julia Language $(cite"bezanson_julia_2017::18") and Julia packages: Yao.jl $(cite"luo_yaojl_2020::19"), QuantumInformation.jl $(cite"gawron_quantuminformationjljulia_2018::20"), Pluto.jl $(cite"van_der_plas_fonspplutojl_2022::21"), Luxor.jl $(cite"juliagraphics_luxorjl::22") and PlutoReport.jl $(cite"sambrani_plutoreportjl::23")
"""

# ╔═╡ bf04a735-6173-4734-8247-160d727e8ccd
@bind ref References()

# ╔═╡ 8218ccf5-4c04-4abf-abf5-ce5c322b41c2
@htl """
$(display_bibliography("./MidwayThesis.bib", ref))
<script>
console.log(currentScript.parentElement.parentElement.parentElement.style.breakInside='auto')
</script>
"""

# ╔═╡ 143fdd64-1bc5-4a42-b4bd-d9b5464bb9a5
apply_css_fixes()

# ╔═╡ c5656a57-62a3-4389-9219-849d7510fc34
htl"""
<style>
@media print {
	main {
		max-width: 100%;
	}
	.markdown {
		font-size: 10pt;
	}
	#refresh_references {
		display: none;
	}
	pluto-cell {
		min-height: 0;
	}
	pluto-output {
		overflow: hidden;
	}
	.raw-html-wrapper span ol{
		break-inside: unset;
	}
}
.toc-row {
	padding: 0!important;
}
.cite {
	line-height: 0;
	color: unset;
	background-color: unset;
	font-weight: bold;
	font-size: 0.8rem;
	margin: 0;
	padding: 0!important;
	vertical-align: super;
}
</style>"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
Luxor = "ae8d54c2-7ccd-5906-9d76-62fc9837b5bc"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoReport = "ab5eb977-4f23-42a0-954d-2743fb6218c4"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
QuantumInformation = "3c0b384b-479c-5684-b2ef-9d7a46dd931e"
SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
StatsBase = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
Yao = "5872b779-8223-5990-8dd0-5abbb0748c8c"
YaoPlots = "32cfe2d9-419e-45f2-8191-2267705d8dbc"

[compat]
HypertextLiteral = "~0.9.4"
Luxor = "~3.5.0"
Plots = "~1.36.2"
PlutoReport = "~0.3.0"
PlutoUI = "~0.7.48"
QuantumInformation = "~0.4.9"
StatsBase = "~0.33.21"
Yao = "~0.8.5"
YaoPlots = "~0.8.1"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.3"
manifest_format = "2.0"
project_hash = "8f3574d148208c89f0d92cfdac5903cb7f243657"

[[deps.AMD]]
deps = ["Libdl", "LinearAlgebra", "SparseArrays", "Test"]
git-tree-sha1 = "00163dc02b882ca5ec032400b919e5f5011dbd31"
uuid = "14f7f29c-3bd6-536c-9a0b-7339e30b5a3e"
version = "0.5.0"

[[deps.AbstractFFTs]]
deps = ["ChainRulesCore", "LinearAlgebra"]
git-tree-sha1 = "69f7020bd72f069c219b5e8c236c1fa90d2cb409"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.2.1"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.AbstractTrees]]
git-tree-sha1 = "52b3b436f8f73133d7bc3a6c71ee7ed6ab2ab754"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.4.3"

[[deps.Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "195c5505521008abea5aee4f96930717958eac6f"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.4.0"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.ArrayInterfaceCore]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "c46fb7dd1d8ca1d213ba25848a5ec4e47a1a1b08"
uuid = "30b0a656-2188-435a-8636-2ec0e6a096e2"
version = "0.1.26"

[[deps.ArrayInterfaceGPUArrays]]
deps = ["Adapt", "ArrayInterfaceCore", "GPUArraysCore", "LinearAlgebra"]
git-tree-sha1 = "fc114f550b93d4c79632c2ada2924635aabfa5ed"
uuid = "6ba088a2-8465-4c0a-af30-387133b534db"
version = "0.2.2"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.BFloat16s]]
deps = ["LinearAlgebra", "Printf", "Random", "Test"]
git-tree-sha1 = "a598ecb0d717092b5539dbbe890c98bac842b072"
uuid = "ab4f0b2a-ad5b-11e8-123f-65d77653426b"
version = "0.2.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BenchmarkTools]]
deps = ["JSON", "Logging", "Printf", "Profile", "Statistics", "UUIDs"]
git-tree-sha1 = "d9a9701b899b30332bbcb3e1679c41cce81fb0e8"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.3.2"

[[deps.BibInternal]]
git-tree-sha1 = "3a760b38ba8da19e64d29244f06104823ff26f25"
uuid = "2027ae74-3657-4b95-ae00-e2f7d55c3e64"
version = "0.3.4"

[[deps.BibParser]]
deps = ["BibInternal", "DataStructures", "Dates", "JSONSchema", "YAML"]
git-tree-sha1 = "f24884311dceb5f8eafe11809b6f1d867b489a46"
uuid = "13533e5b-e1c2-4e57-8cef-cac5e52f6474"
version = "0.2.1"

[[deps.Bibliography]]
deps = ["BibInternal", "BibParser", "DataStructures", "Dates", "FileIO", "YAML"]
git-tree-sha1 = "b506db2482a8e110622ddf1fd0f78bce381af032"
uuid = "f1be7e48-bf82-45af-a471-ae754a193061"
version = "0.2.19"

[[deps.BitBasis]]
deps = ["LinearAlgebra", "StaticArrays"]
git-tree-sha1 = "f51ef0fdfa5d8643fb1c12df3899940fc8cf2bf4"
uuid = "50ba71b6-fa0f-514d-ae9a-0916efc90dcf"
version = "0.8.1"

[[deps.BitFlags]]
git-tree-sha1 = "43b1a4a8f797c1cddadf60499a8a077d4af2cd2d"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.7"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[deps.CEnum]]
git-tree-sha1 = "eb4cb44a499229b3b8426dcfb5dd85333951ff90"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.4.2"

[[deps.CUDA]]
deps = ["AbstractFFTs", "Adapt", "BFloat16s", "CEnum", "CompilerSupportLibraries_jll", "ExprTools", "GPUArrays", "GPUCompiler", "LLVM", "LazyArtifacts", "Libdl", "LinearAlgebra", "Logging", "Printf", "Random", "Random123", "RandomNumbers", "Reexport", "Requires", "SparseArrays", "SpecialFunctions", "TimerOutputs"]
git-tree-sha1 = "49549e2c28ffb9cc77b3689dc10e46e6271e9452"
uuid = "052768ef-5323-5732-b1bb-66c8b64840ba"
version = "3.12.0"

[[deps.CacheServers]]
deps = ["Distributed", "Test"]
git-tree-sha1 = "b584b04f236d3677b4334fab095796a128445bf8"
uuid = "a921213e-d44a-5460-ac04-5d720a99ba71"
version = "0.2.0"

[[deps.Cairo]]
deps = ["Cairo_jll", "Colors", "Glib_jll", "Graphics", "Libdl", "Pango_jll"]
git-tree-sha1 = "d0b3f8b4ad16cb0a2988c6788646a5e6a17b6b1b"
uuid = "159f3aea-2a34-519c-b102-8c37f9878175"
version = "1.0.5"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "e7ff6cadf743c098e08fca25c91103ee4303c9bb"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.15.6"

[[deps.ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "38f7a08f19d8810338d4f5085211c7dfa5d5bdd8"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.4"

[[deps.CodecBzip2]]
deps = ["Bzip2_jll", "Libdl", "TranscodingStreams"]
git-tree-sha1 = "2e62a725210ce3c3c2e1a3080190e7ca491f18d7"
uuid = "523fee87-0ab8-5b00-afb7-3ecf72e48cfd"
version = "0.7.2"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "Random", "SnoopPrecompile"]
git-tree-sha1 = "aa3edc8f8dea6cbfa176ee12f7c2fc82f0608ed3"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.20.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "SpecialFunctions", "Statistics", "TensorCore"]
git-tree-sha1 = "d08c20eef1f2cbc6e60fd3612ac4340b89fea322"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.9.9"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[deps.CommonSubexpressions]]
deps = ["MacroTools", "Test"]
git-tree-sha1 = "7b8a93dba8af7e3b42fecabf646260105ac373f7"
uuid = "bbf7d656-a473-5ed7-a52c-81e309532950"
version = "0.3.0"

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "00a2cccc7f098ff3b66806862d275ca3db9e6e5a"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.5.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "0.5.2+0"

[[deps.Contour]]
git-tree-sha1 = "d05d9e7b7aedff4e5b51a029dced05cfb6125781"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.2"

[[deps.Convex]]
deps = ["AbstractTrees", "BenchmarkTools", "LDLFactorizations", "LinearAlgebra", "MathOptInterface", "OrderedCollections", "SparseArrays", "Test"]
git-tree-sha1 = "c90364e06afb0da76e72728fc758b82857ed14e2"
uuid = "f65535da-76fb-5f13-bab9-19810c17039a"
version = "0.15.2"

[[deps.DataAPI]]
git-tree-sha1 = "e08915633fcb3ea83bf9d6126292e5bc5c739922"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.13.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "d1fff3a548102f48987a52a2e0d114fa97d730f0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.13"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[deps.DiffResults]]
deps = ["StaticArraysCore"]
git-tree-sha1 = "782dd5f4561f5d267313f23853baaaa4c52ea621"
uuid = "163ba53b-c6d8-5494-b064-1a9d43ac40c5"
version = "1.1.0"

[[deps.DiffRules]]
deps = ["IrrationalConstants", "LogExpFunctions", "NaNMath", "Random", "SpecialFunctions"]
git-tree-sha1 = "c5b6685d53f933c11404a3ae9822afe30d522494"
uuid = "b552c78f-8df3-52c6-915a-8e097449b14b"
version = "1.12.2"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "b19534d1895d702889b219c382a6e18010797f0b"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.6"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bad72f730e9e91c08d9427d5e8db95478a3c323d"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.4.8+0"

[[deps.ExponentialUtilities]]
deps = ["Adapt", "ArrayInterfaceCore", "ArrayInterfaceGPUArrays", "GPUArraysCore", "GenericSchur", "LinearAlgebra", "Printf", "SparseArrays", "libblastrampoline_jll"]
git-tree-sha1 = "9837d3f3a904c7a7ab9337759c0093d3abea1d81"
uuid = "d4d017d3-3776-5f7e-afef-a10c40355c18"
version = "1.22.0"

[[deps.ExprTools]]
git-tree-sha1 = "56559bbef6ca5ea0c0818fa5c90320398a6fbf8d"
uuid = "e2ba6199-217a-4e67-a87a-7c52f15ade04"
version = "0.1.8"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Pkg", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "74faea50c1d007c85837327f6775bea60b5492dd"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.2+2"

[[deps.FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "7be5f99f7d15578798f338f5433b6c432ea8037b"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.16.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "21efd19106a55620a188615da6d3d06cd7f6ee03"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.93+0"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.ForwardDiff]]
deps = ["CommonSubexpressions", "DiffResults", "DiffRules", "LinearAlgebra", "LogExpFunctions", "NaNMath", "Preferences", "Printf", "Random", "SpecialFunctions", "StaticArrays"]
git-tree-sha1 = "187198a4ed8ccd7b5d99c41b69c679269ea2b2d4"
uuid = "f6369f11-7733-5829-9624-2563aa707210"
version = "0.10.32"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "d972031d28c8c8d9d7b41a536ad7bb0c2579caca"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.8+0"

[[deps.GPUArrays]]
deps = ["Adapt", "GPUArraysCore", "LLVM", "LinearAlgebra", "Printf", "Random", "Reexport", "Serialization", "Statistics"]
git-tree-sha1 = "45d7deaf05cbb44116ba785d147c518ab46352d7"
uuid = "0c68f7d7-f131-5f86-a1c3-88cf8149b2d7"
version = "8.5.0"

[[deps.GPUArraysCore]]
deps = ["Adapt"]
git-tree-sha1 = "6872f5ec8fd1a38880f027a26739d42dcda6691f"
uuid = "46192b85-c4d5-4398-a991-12ede77f4527"
version = "0.1.2"

[[deps.GPUCompiler]]
deps = ["ExprTools", "InteractiveUtils", "LLVM", "Libdl", "Logging", "TimerOutputs", "UUIDs"]
git-tree-sha1 = "30488903139ebf4c88f965e7e396f2d652f988ac"
uuid = "61eb1bfa-7361-4325-ad38-22787b887f55"
version = "0.16.7"

[[deps.GR]]
deps = ["Artifacts", "Base64", "DelimitedFiles", "Downloads", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Preferences", "Printf", "Random", "Serialization", "Sockets", "TOML", "Tar", "Test", "UUIDs", "p7zip_jll"]
git-tree-sha1 = "051072ff2accc6e0e87b708ddee39b18aa04a0bc"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.71.1"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "501a4bf76fd679e7fcd678725d5072177392e756"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.71.1+0"

[[deps.GenericSchur]]
deps = ["LinearAlgebra", "Printf"]
git-tree-sha1 = "fb69b2a645fa69ba5f474af09221b9308b160ce6"
uuid = "c145ed77-6b09-5dd9-b285-bf645a82121e"
version = "0.5.3"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "fb83fbe02fe57f2c068013aa94bcdf6760d3a7a7"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.74.0+1"

[[deps.Graphics]]
deps = ["Colors", "LinearAlgebra", "NaNMath"]
git-tree-sha1 = "d61890399bc535850c4bf08e4e0d3a7ad0f21cbd"
uuid = "a2bd30eb-e257-5431-a919-1863eab51364"
version = "1.1.2"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "Dates", "IniFile", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "e1acc37ed078d99a714ed8376446f92a5535ca65"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.5.5"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.IniFile]]
git-tree-sha1 = "f550e6e32074c939295eb5ea6de31849ac2c9625"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.1"

[[deps.IntelOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d979e54b71da82f3a65b62553da4fc3d18c9004c"
uuid = "1d5cc7b8-4909-519e-a0f8-d0f5ad9712d0"
version = "2018.0.3+2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "49510dfcb407e572524ba94aeae2fced1f3feb0f"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.8"

[[deps.IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[deps.JLFzf]]
deps = ["Pipe", "REPL", "Random", "fzf_jll"]
git-tree-sha1 = "f377670cda23b6b7c1c0b3893e37451c5c1a2185"
uuid = "1019f520-868f-41f5-a6de-eb00f4b6a39c"
version = "0.1.5"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.JSON3]]
deps = ["Dates", "Mmap", "Parsers", "SnoopPrecompile", "StructTypes", "UUIDs"]
git-tree-sha1 = "84b10656a41ef564c39d2d477d7236966d2b5683"
uuid = "0f8b85d8-7281-11e9-16c2-39a750bddbf1"
version = "1.12.0"

[[deps.JSONSchema]]
deps = ["HTTP", "JSON", "URIs"]
git-tree-sha1 = "8d928db71efdc942f10e751564e6bbea1e600dfe"
uuid = "7d188eb4-7ad8-530c-ae41-71a32a6d4692"
version = "1.0.1"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b53380851c6e6664204efb2e62cd24fa5c47e4ba"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.2+0"

[[deps.Juno]]
deps = ["Base64", "Logging", "Media", "Profile"]
git-tree-sha1 = "07cb43290a840908a771552911a6274bc6c072c7"
uuid = "e5e0dc1b-0480-54bc-9374-aad01c23163d"
version = "0.8.4"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[deps.LDLFactorizations]]
deps = ["AMD", "LinearAlgebra", "SparseArrays", "Test"]
git-tree-sha1 = "743544bcdba7b4ad744bfd5d062c977a9df553a7"
uuid = "40e66cde-538c-5869-a4ad-c39174c6795b"
version = "0.9.0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bf36f528eec6634efc60d7ec062008f171071434"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "3.0.0+1"

[[deps.LLVM]]
deps = ["CEnum", "LLVMExtra_jll", "Libdl", "Printf", "Unicode"]
git-tree-sha1 = "088dd02b2797f0233d92583562ab669de8517fd1"
uuid = "929cbde3-209d-540e-8aea-75f648917ca0"
version = "4.14.1"

[[deps.LLVMExtra_jll]]
deps = ["Artifacts", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg", "TOML"]
git-tree-sha1 = "771bfe376249626d3ca12bcd58ba243d3f961576"
uuid = "dad2f222-ce93-54a1-a47d-0025e8a3acab"
version = "0.0.16+0"

[[deps.LRUCache]]
git-tree-sha1 = "d862633ef6097461037a00a13f709a62ae4bdfdd"
uuid = "8ac3fa9e-de4c-5943-b1dc-09c6b5f20637"
version = "1.4.0"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Printf", "Requires"]
git-tree-sha1 = "ab9aa169d2160129beb241cb2750ca499b4e90e9"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.17"

[[deps.LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

[[deps.LazyStack]]
deps = ["ChainRulesCore", "Compat", "LinearAlgebra"]
git-tree-sha1 = "fe426ebaf20ab5ffe983a5a2980fa1ff5f540217"
uuid = "1fad7336-0346-5a1a-a56f-a06ba010965b"
version = "0.1.1"

[[deps.LegibleLambdas]]
deps = ["MacroTools"]
git-tree-sha1 = "7946db4829eb8de47c399f92c19790f9cc0bbd07"
uuid = "f1f30506-32fe-5131-bd72-7c197988f9e5"
version = "0.3.0"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

[[deps.Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "6f73d1dd803986947b2c750138528a999a6c7733"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.6.0+0"

[[deps.Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "42b62845d70a619f063a7da093d995ec8e15e778"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+1"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[deps.Librsvg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pango_jll", "Pkg", "gdk_pixbuf_jll"]
git-tree-sha1 = "ae0923dab7324e6bc980834f709c4cd83dd797ed"
uuid = "925c91fb-5dd6-59dd-8e8c-345e74382d89"
version = "2.54.5+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "3eb79b0ca5764d4799c06699573fd8f533259713"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.4.0+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "946607f84feb96220f480e0422d3484c49c00239"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.19"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "cedb76b37bc5a6c702ade66be44f831fa23c681e"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.0.0"

[[deps.Luxor]]
deps = ["Base64", "Cairo", "Colors", "Dates", "FFMPEG", "FileIO", "Juno", "LaTeXStrings", "Random", "Requires", "Rsvg"]
git-tree-sha1 = "8fd7cb8db7dc4f575373825963079dbe54581f32"
uuid = "ae8d54c2-7ccd-5906-9d76-62fc9837b5bc"
version = "3.5.0"

[[deps.LuxurySparse]]
deps = ["InteractiveUtils", "LinearAlgebra", "Random", "SparseArrays", "StaticArrays"]
git-tree-sha1 = "660da52355791ea967982f86fd15aa8b4c9eae6d"
uuid = "d05aeea4-b7d4-55ac-b691-9e7fabb07ba2"
version = "0.7.0"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg"]
git-tree-sha1 = "2ce8695e1e699b68702c03402672a69f54b8aca9"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2022.2.0+0"

[[deps.MLStyle]]
git-tree-sha1 = "060ef7956fef2dc06b0e63b294f7dbfbcbdc7ea2"
uuid = "d8e11817-5142-5d16-987a-aa16d5891078"
version = "0.4.16"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "42324d08725e200c23d4dfb549e0d5d89dede2d2"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.10"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MathOptInterface]]
deps = ["BenchmarkTools", "CodecBzip2", "CodecZlib", "DataStructures", "ForwardDiff", "JSON", "LinearAlgebra", "MutableArithmetics", "NaNMath", "OrderedCollections", "Printf", "SparseArrays", "SpecialFunctions", "Test", "Unicode"]
git-tree-sha1 = "09c6964bf4bca818867494739a9387c0c9cf4e2c"
uuid = "b8f27783-ece8-5eb3-8dc8-9495eed66fee"
version = "1.11.0"

[[deps.MatrixEnsembles]]
deps = ["DocStringExtensions", "LinearAlgebra", "Random", "StatsBase"]
git-tree-sha1 = "7a752beaf68443cda54c1e839f43876234907d1d"
uuid = "c7015dd7-3fb7-4a4c-827e-526313618491"
version = "0.1.0"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "Random", "Sockets"]
git-tree-sha1 = "03a9b9718f5682ecb107ac9f7308991db4ce395b"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.7"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[deps.Measures]]
git-tree-sha1 = "c13304c81eec1ed3af7fc20e75fb6b26092a1102"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.2"

[[deps.Media]]
deps = ["MacroTools", "Test"]
git-tree-sha1 = "75a54abd10709c01f1b86b84ec225d26e840ed58"
uuid = "e89f7d12-3494-54d1-8411-f7d8b9ae1f27"
version = "0.5.0"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[deps.MutableArithmetics]]
deps = ["LinearAlgebra", "SparseArrays", "Test"]
git-tree-sha1 = "aa532179d4a643d4bd9f328589ca01fa20a0d197"
uuid = "d8a4904e-b15c-11e9-3269-09a3773c0cb0"
version = "1.1.0"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "a7c3d1da1189a1c2fe843a3bfa04d18d20eb3211"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.1"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[deps.OpenBLAS32_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c6c2ed4b7acd2137b878eb96c68e63b76199d0f"
uuid = "656ef2d0-ae68-5445-9ca0-591084a874a2"
version = "0.3.17+0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+0"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "df6830e37943c7aaa10023471ca47fb3065cc3c4"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.3.2"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6e9dba33f9f2c44e08a020b0caf6903be540004"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.19+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.40.0+0"

[[deps.Pango_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "FriBidi_jll", "Glib_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "84a314e3926ba9ec66ac097e3635e270986b0f10"
uuid = "36c8627f-9965-5494-a995-c6b170f724f3"
version = "1.50.9+0"

[[deps.Parsers]]
deps = ["Dates", "SnoopPrecompile"]
git-tree-sha1 = "b64719e8b4504983c7fca6cc9db3ebc8acc2a4d6"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.5.1"

[[deps.Pipe]]
git-tree-sha1 = "6842804e7867b115ca9de748a0cf6b364523c16d"
uuid = "b98c9c47-44ae-5843-9183-064241ee97a0"
version = "1.3.0"

[[deps.Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PlotThemes]]
deps = ["PlotUtils", "Statistics"]
git-tree-sha1 = "1f03a2d339f42dca4a4da149c7e15e9b896ad899"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "3.1.0"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "SnoopPrecompile", "Statistics"]
git-tree-sha1 = "21303256d239f6b484977314674aef4bb1fe4420"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.3.1"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "JLFzf", "JSON", "LaTeXStrings", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "RelocatableFolders", "Requires", "Scratch", "Showoff", "SnoopPrecompile", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun", "Unzip"]
git-tree-sha1 = "6a9521b955b816aa500462951aa67f3e4467248a"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.36.6"

[[deps.PlutoReport]]
deps = ["Bibliography", "Downloads", "HTTP", "HypertextLiteral", "JSON3", "PlutoUI", "Reexport"]
git-tree-sha1 = "dfe9fed6bfd1257b94fd9c6fabe90305dac12a36"
uuid = "ab5eb977-4f23-42a0-954d-2743fb6218c4"
version = "0.3.0"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "eadad7b14cf046de6eb41f13c9275e5aa2711ab6"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.49"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.Profile]]
deps = ["Printf"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"

[[deps.Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "0c03844e2231e12fda4d0086fd7cbe4098ee8dc5"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+2"

[[deps.QuantumInformation]]
deps = ["Convex", "DocStringExtensions", "LinearAlgebra", "MatrixEnsembles", "Pkg", "Random", "SCS", "StatsBase", "TensorCast", "TensorOperations"]
git-tree-sha1 = "df0e2133acc55bbd1e887b34de64d4ef7aa9aab2"
uuid = "3c0b384b-479c-5684-b2ef-9d7a46dd931e"
version = "0.4.9"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Random123]]
deps = ["Random", "RandomNumbers"]
git-tree-sha1 = "7a1a306b72cfa60634f03a911405f4e64d1b718b"
uuid = "74087812-796a-5b5d-8853-05524746bad3"
version = "1.6.0"

[[deps.RandomNumbers]]
deps = ["Random", "Requires"]
git-tree-sha1 = "043da614cc7e95c703498a491e2c21f58a2b8111"
uuid = "e6cf234a-135c-5ec9-84dd-332b85af5143"
version = "1.5.3"

[[deps.RecipesBase]]
deps = ["SnoopPrecompile"]
git-tree-sha1 = "18c35ed630d7229c5584b945641a73ca83fb5213"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.3.2"

[[deps.RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "RecipesBase", "SnoopPrecompile"]
git-tree-sha1 = "e974477be88cb5e3040009f3767611bc6357846f"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.6.11"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "90bc7a7c96410424509e4263e277e43250c05691"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.0"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.Rsvg]]
deps = ["Cairo", "Glib_jll", "Librsvg_jll"]
git-tree-sha1 = "3d3dc66eb46568fb3a5259034bfc752a0eb0c686"
uuid = "c4c386cf-5103-5370-be45-f3a111cca3b8"
version = "1.0.0"

[[deps.SCS]]
deps = ["MathOptInterface", "Requires", "SCS_GPU_jll", "SCS_MKL_jll", "SCS_jll", "SparseArrays"]
git-tree-sha1 = "2e3ca40559ecaed6ffe9410b06aabcc1e087215d"
uuid = "c946c3f1-0d1f-5ce8-9dea-7daa1f7e2d13"
version = "1.1.3"

[[deps.SCS_GPU_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "OpenBLAS32_jll", "Pkg"]
git-tree-sha1 = "2b3799ff650d0530a19c2a3bd4b158a4f3e4581a"
uuid = "af6e375f-46ec-5fa0-b791-491b0dfa44a4"
version = "3.2.1+0"

[[deps.SCS_MKL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "MKL_jll", "Pkg"]
git-tree-sha1 = "a4923177e60fdb7f802e1a42a73d0af400eea163"
uuid = "3f2553a9-4106-52be-b7dd-865123654657"
version = "3.2.2+0"

[[deps.SCS_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "OpenBLAS32_jll", "Pkg"]
git-tree-sha1 = "5544538910047c7522908cf87bb0c884a7afff92"
uuid = "f4f2fc5b-1d94-523c-97ea-2ab488bedf4b"
version = "3.2.1+0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "f94f779c94e58bf9ea243e77a37e16d9de9126bd"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.1"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "874e8867b33a00e784c8a7e4b60afe9e037b74e1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.1.0"

[[deps.SnoopPrecompile]]
git-tree-sha1 = "f604441450a3c0569830946e5b33b78c928e1a85"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.1"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "a4ada03f999bd01b3a25dcaa30b2d929fe537e00"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.1.0"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "d75bda01f8c31ebb72df80a46c88b25d1c79c56d"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.1.7"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "StaticArraysCore", "Statistics"]
git-tree-sha1 = "ffc098086f35909741f71ce21d03dadf0d2bfa76"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.5.11"

[[deps.StaticArraysCore]]
git-tree-sha1 = "6b7ba252635a5eff6a0b0664a41ee140a1c9e72a"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.0"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f9af7f195fb13589dd2e2d57fdb401717d2eb1f6"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.5.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "d1bf48bfcc554a3761a133fe3a9bb01488e06916"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.21"

[[deps.Strided]]
deps = ["LinearAlgebra", "TupleTools"]
git-tree-sha1 = "a7a664c91104329c88222aa20264e1a05b6ad138"
uuid = "5e0ebb24-38b0-5f93-81fe-25c709ecae67"
version = "1.2.3"

[[deps.StringEncodings]]
deps = ["Libiconv_jll"]
git-tree-sha1 = "50ccd5ddb00d19392577902f0079267a72c5ab04"
uuid = "69024149-9ee7-55f6-a4c4-859efe599b68"
version = "0.3.5"

[[deps.StructTypes]]
deps = ["Dates", "UUIDs"]
git-tree-sha1 = "ca4bccb03acf9faaf4137a9abc1881ed1841aa70"
uuid = "856f2bd8-1eba-4b0a-8007-ebc267875bd4"
version = "1.10.0"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.1"

[[deps.TensorCast]]
deps = ["ChainRulesCore", "Compat", "LazyStack", "LinearAlgebra", "MacroTools", "Random", "StaticArrays", "TransmuteDims"]
git-tree-sha1 = "88423a9e2a1eb7fb2e8c4dd7ede52e28bc5769eb"
uuid = "02d47bb6-7ce6-556a-be16-bb1710789e2b"
version = "0.4.6"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.TensorOperations]]
deps = ["CUDA", "LRUCache", "LinearAlgebra", "Requires", "Strided", "TupleTools"]
git-tree-sha1 = "c082dda2ace9de2bc71b644ae29e2adf1a8137b2"
uuid = "6aa20fa7-93e2-5fca-9bc0-fbd0db3c71a2"
version = "3.2.4"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TimerOutputs]]
deps = ["ExprTools", "Printf"]
git-tree-sha1 = "f2fd3f288dfc6f507b0c3a2eb3bac009251e548b"
uuid = "a759f4b9-e2f1-59dc-863e-4aeb61b1ea8f"
version = "0.5.22"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "e4bdc63f5c6d62e80eb1c0043fcc0360d5950ff7"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.10"

[[deps.TransmuteDims]]
deps = ["Adapt", "ChainRulesCore", "GPUArraysCore", "LinearAlgebra", "Requires", "Strided"]
git-tree-sha1 = "64df189c13692b9581924775109cb14a6b5aef8d"
uuid = "24ddb15e-299a-5cc3-8414-dbddc482d9ca"
version = "0.1.15"

[[deps.Tricks]]
git-tree-sha1 = "6bac775f2d42a611cdfcd1fb217ee719630c4175"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.6"

[[deps.TupleTools]]
git-tree-sha1 = "3c712976c47707ff893cf6ba4354aa14db1d8938"
uuid = "9d95972d-f1c8-5527-a6e0-b4b365fa01f6"
version = "1.3.0"

[[deps.URIs]]
git-tree-sha1 = "ac00576f90d8a259f2c9d823e91d1de3fd44d348"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.Unzip]]
git-tree-sha1 = "ca0969166a028236229f63514992fc073799bb78"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.2.0"

[[deps.Wayland_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "3e61f0b86f90dacb0bc0e73a0c5a83f6a8636e23"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.19.0+0"

[[deps.Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4528479aa01ee1b3b4cd0e6faef0e04cf16466da"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.25.0+0"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "58443b63fb7e465a8a7210828c91c08b92132dff"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.9.14+0"

[[deps.XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "5be649d550f3f4b95308bf0183b82e2582876527"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.6.9+4"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4e490d5c960c314f33885790ed410ff3a94ce67e"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.9+4"

[[deps.Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fe47bd2247248125c428978740e18a681372dd4"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.3+4"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[deps.Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "0e0dc7431e7a0587559f9294aeec269471c991a4"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "5.0.3+4"

[[deps.Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "89b52bc2160aadc84d707093930ef0bffa641246"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.7.10+4"

[[deps.Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll"]
git-tree-sha1 = "26be8b1c342929259317d8b9f7b53bf2bb73b123"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.4+4"

[[deps.Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "34cea83cb726fb58f325887bf0612c6b3fb17631"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.2+4"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[deps.Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6783737e45d3c59a4a4c4091f5f88cdcf0908cbb"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.0+3"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "daf17f441228e7a3833846cd048892861cff16d6"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.13.0+3"

[[deps.Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "926af861744212db0eb001d9e40b5d16292080b2"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.0+4"

[[deps.Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[deps.Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[deps.Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "4bcbf660f6c2e714f87e960a171b119d06ee163b"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.2+4"

[[deps.Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "5c8424f8a67c3f2209646d4425f3d415fee5931d"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.27.0+4"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[deps.YAML]]
deps = ["Base64", "Dates", "Printf", "StringEncodings"]
git-tree-sha1 = "dbc7f1c0012a69486af79c8bcdb31be820670ba2"
uuid = "ddb6d928-2868-570f-bddf-ab3f9cf99eb6"
version = "0.4.8"

[[deps.Yao]]
deps = ["BitBasis", "LinearAlgebra", "LuxurySparse", "Reexport", "YaoAPI", "YaoArrayRegister", "YaoBlocks", "YaoSym"]
git-tree-sha1 = "58573a875eb3705c752de1ac3e4e228e7cfbc781"
uuid = "5872b779-8223-5990-8dd0-5abbb0748c8c"
version = "0.8.5"

[[deps.YaoAPI]]
git-tree-sha1 = "4732ed765411aef7983123961d34cd9e9729da4f"
uuid = "0843a435-28de-4971-9e8b-a9641b2983a8"
version = "0.4.3"

[[deps.YaoArrayRegister]]
deps = ["Adapt", "BitBasis", "DocStringExtensions", "LegibleLambdas", "LinearAlgebra", "LuxurySparse", "MLStyle", "Random", "SparseArrays", "StaticArrays", "StatsBase", "TupleTools", "YaoAPI"]
git-tree-sha1 = "ef1054c7d6dd71c184c068c04ce862f86f9a468b"
uuid = "e600142f-9330-5003-8abb-0ebd767abc51"
version = "0.9.3"

[[deps.YaoBlocks]]
deps = ["BitBasis", "CacheServers", "ChainRulesCore", "DocStringExtensions", "ExponentialUtilities", "InteractiveUtils", "LegibleLambdas", "LinearAlgebra", "LuxurySparse", "MLStyle", "Random", "SparseArrays", "StaticArrays", "StatsBase", "TupleTools", "YaoAPI", "YaoArrayRegister"]
git-tree-sha1 = "6d991dc024d604c2cdb6746ea71d8781c10b1a03"
uuid = "418bc28f-b43b-5e0b-a6e7-61bbc1a2c1df"
version = "0.13.5"

[[deps.YaoPlots]]
deps = ["Luxor", "Yao"]
git-tree-sha1 = "84bd385d25be8263f483f115e54f5a0d31108c28"
uuid = "32cfe2d9-419e-45f2-8191-2267705d8dbc"
version = "0.8.1"

[[deps.YaoSym]]
deps = ["BitBasis", "LinearAlgebra", "LuxurySparse", "Requires", "SparseArrays", "YaoArrayRegister", "YaoBlocks"]
git-tree-sha1 = "118e2c434e810dd52a3564a1b99f7fd3a2bbb63e"
uuid = "3b27209a-d3d6-11e9-3c0f-41eb92b2cb9d"
version = "0.6.2"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+3"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e45044cd873ded54b6a5bac0eb5c971392cf1927"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.2+0"

[[deps.fzf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "868e669ccb12ba16eaf50cb2957ee2ff61261c56"
uuid = "214eeab7-80f7-51ab-84ad-2988db7cef09"
version = "0.29.0+0"

[[deps.gdk_pixbuf_jll]]
deps = ["Artifacts", "Glib_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pkg", "Xorg_libX11_jll", "libpng_jll"]
git-tree-sha1 = "e9190f9fb03f9c3b15b9fb0c380b0d57a3c8ea39"
uuid = "da03df04-f53b-5353-a52f-6a8b0620ced0"
version = "2.42.8+0"

[[deps.libaom_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3a2ea60308f0996d26f1e5354e10c24e9ef905d4"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.4.0+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "5982a94fcba20f02f42ace44b9894ee2b140fe47"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.1+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.1.1+0"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "b910cb81ef3fe6e78bf6acee440bda86fd6ae00c"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+1"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"

[[deps.xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "9ebfc140cc56e8c2156a15ceac2f0302e327ac0a"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "1.4.1+0"
"""

# ╔═╡ Cell order:
# ╟─321a537b-421c-4333-9c9c-e782285c1e8d
# ╟─282ac348-767d-4745-a195-685e154f8333
# ╟─3630155c-6a32-45c6-b9a4-cf73ca6f70a3
# ╟─e53b8390-225d-426f-ba38-b78a5e661ed0
# ╟─c6cfff98-7ab7-4c0d-8551-5b923cac1c96
# ╟─d23e90b6-7feb-4395-a853-95d03ddde970
# ╟─325bbfaa-f45e-4021-9a67-1671ff4f12af
# ╟─9c2c07c5-fb2e-4201-b95a-333395b847e6
# ╟─9a6a475f-e3b7-4b80-a42d-5ca5319d7cfd
# ╠═e449eb90-c197-4bcf-97c9-c55e5d388e5b
# ╟─9ec8b4fb-6010-46b9-95b8-1b03f0bc1d90
# ╟─885813cb-5db7-44e1-943a-737e5e11cf86
# ╠═c4b059c2-9dba-4b64-8363-2a963dc60cc2
# ╟─dc72c7b5-50db-4293-a6e0-362b0c144f81
# ╟─e3043578-26ff-4d85-a916-dcba6164fa4a
# ╟─b5fe79fc-b3bf-4bb7-b50c-18a112fc2906
# ╟─bb2c230e-ada1-4705-8e48-3d6a12646c45
# ╟─12487390-e6e8-4d51-9756-152ecd1b5e5e
# ╟─73ab8819-8f61-402f-9854-7b83f707c9d8
# ╟─2a885597-835b-4388-9231-4fe4ceaca160
# ╟─0dc46d80-d78d-4ba0-8e3b-032f79889341
# ╠═1f4b0340-3cf1-45c2-bbbf-a2efa43bd13d
# ╟─2c80f1fc-5c19-4d49-8449-c610af29be84
# ╠═193ebde4-055b-43ff-80d7-b8ec61475c2d
# ╟─55dc5a3f-640c-4ca6-9f43-3620cb319b1e
# ╠═a0228700-fae0-4a34-bc7e-26a29630f6fd
# ╟─d90d3e9e-4e07-4c89-b8ba-fd8caf8db0df
# ╠═b3b3d2a6-7d31-423e-99be-61021c26f85e
# ╟─e0dd1edb-52f3-46cd-8df6-0791c2665b65
# ╠═a47aab64-dd71-41a9-8b73-653fc88cfe4a
# ╟─5038a6a6-d8bf-4cbb-81bd-ecefa150c744
# ╟─c66ccef2-2b29-4257-8ed7-382290ae8fdc
# ╟─6c662f9d-5eb8-4405-8fb0-c6893b38a7f9
# ╟─0bd7b11f-831f-4b27-b62b-85900bcb97e3
# ╟─f3e01cb0-799c-49ba-9e1b-4f90881cf542
# ╟─56895409-dec3-4b31-a90b-29d6b07e7afe
# ╟─085ed711-e8e4-415a-a066-e6f623c41ce2
# ╟─4a3cabc6-65d3-4a32-b6c6-9cbb9402d887
# ╟─ec6802d7-923c-4da4-b6a9-07624288c340
# ╟─32ee643b-8a6e-4cd3-acb4-679e9b51fe2c
# ╟─c5efcb81-24be-4c78-9ba2-e31e7e0f74bb
# ╟─6ff3f999-f338-4846-9527-bea14bd2cd41
# ╠═82c1e3a7-e8c6-4362-9baa-004a3fadec5a
# ╟─32e242f7-c359-4f58-8593-1df6143edd37
# ╟─a0d828f1-6c0e-4306-a5c3-be4cee6b0bb0
# ╠═9953da4f-c21a-4d3a-9136-26540c1477f4
# ╟─3360078d-c0b2-4273-8967-e1eb5e5eadf5
# ╟─85c84ddc-5ca1-4a75-98ca-56f9dac1381a
# ╠═8a69232a-c37a-495d-a865-59116fae65c7
# ╟─588717d2-9147-416a-ba33-1c6ac27ef149
# ╟─a5175ffc-58f7-473b-bf27-616c634d6a33
# ╠═a1ab11f1-335b-43c0-8b5d-e64fef827bef
# ╟─9e4db8fe-cf78-4b3c-9c47-e25d9fe11ec9
# ╟─54018ac9-c4ed-4891-9a48-d56901b21d69
# ╠═a3f36cc0-1325-43fb-817c-2c4534337652
# ╟─796866ed-254d-420d-ba08-3caa074a844f
# ╟─cac791b2-95a4-4a30-ac77-a4c213a2e062
# ╟─422d631e-0827-4d66-b5d3-f52a7b248a34
# ╟─206b0a72-f033-4913-9f3c-c9b7b676d09c
# ╟─0ac0bddc-290d-4456-a1c0-fd30937483d4
# ╟─39f61061-9731-4582-8150-19198657aad5
# ╟─3a207fea-9c6b-4b32-aafc-982750b4dc01
# ╟─8538bc76-6f2d-422a-b225-48051876bc60
# ╟─21ef3cf8-7e34-410e-bd8d-4c28b327afcc
# ╟─64adae71-0cdd-4518-8187-7e8f8b57cd7f
# ╟─edf031c0-f91d-4a43-9efa-9bd356fef742
# ╟─fc0cafa0-141c-4c69-8dc3-cb3f1636ca7a
# ╟─6d0ae694-6afa-4d9b-af7d-2664aec95107
# ╟─eabbfd4c-beb9-4459-b84d-3f55bfa5be2a
# ╟─04a1586f-a68f-4fbf-8648-e72e89a6459b
# ╟─919d5e02-c238-45f0-9f01-3aa3c00fc3e2
# ╟─03b23e63-ad05-475d-9696-ca4623d0f0f9
# ╟─97f655bc-a0b1-47ef-8718-19571deb91ef
# ╟─5c1a23ba-bb8c-47d9-996f-4eca9b66dbc8
# ╟─06f4f464-d63a-477b-93d6-26db971190bd
# ╟─90aa1b83-eb61-477b-b024-5f89b3c35c77
# ╟─882c7d4f-2afa-4e3f-bb42-24eaf40e13b4
# ╟─ec6dafb9-eebf-4514-b30e-c98be9475aa6
# ╟─6d106756-d1a0-4521-94af-1d4948521b2f
# ╟─d4bfdc20-33b0-44bc-8edd-32c8e0506fbf
# ╟─b1d43b1b-8606-45cc-9c56-41d894ed8f2f
# ╟─7fdbda85-3a10-4437-95d5-591e0c29d9f6
# ╟─9f9d7dde-b6b2-4ce1-9e34-0d8aced54017
# ╟─8baecd5c-0a53-40b2-bb46-aef6f1a4145b
# ╟─d6b0ac63-3deb-474b-bd7f-f8151f7fb12c
# ╟─55c1fe20-da3a-4818-8984-80ef3279ba2b
# ╟─36f3a7c2-a598-461d-9f9d-d6d0c324efc3
# ╟─ddba1bac-9386-463b-9127-507388b243ef
# ╟─20ae60e2-2236-4012-9253-17c714dbdf8d
# ╟─3ce7ba98-1e93-4e66-8f7c-7a958f9e05e2
# ╟─c591256d-1e52-4f75-97c6-5144575bc3b9
# ╟─7abebb64-0e9b-4058-a397-95a1cce567ee
# ╟─c13cbd97-f01f-4b31-a521-35976df5f18e
# ╟─4756d81b-dc4b-47f7-b4fa-23231da95d6b
# ╟─bf04a735-6173-4734-8247-160d727e8ccd
# ╟─8218ccf5-4c04-4abf-abf5-ce5c322b41c2
# ╟─18e3a3f0-071b-4fac-9cc8-1858a998b220
# ╟─143fdd64-1bc5-4a42-b4bd-d9b5464bb9a5
# ╟─c5656a57-62a3-4389-9219-849d7510fc34
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
