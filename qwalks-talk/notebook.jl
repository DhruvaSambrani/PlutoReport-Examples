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

# ╔═╡ 4a35ff54-5d10-11ed-3969-83c1ef512684
begin
	using Plots
	using QuantumInformation
	using LinearAlgebra
	using SparseArrays
	using HypertextLiteral
	using PlutoReport
	using PlutoUI
	using Luxor
	using StatsBase
	theme(:dark)
end

# ╔═╡ d0ad6f88-c906-44a5-908a-9996bd33bf0e
TableOfContents()

# ╔═╡ f9c42e32-8ec9-4bc7-ab27-d3260d587f5c
@htl("""
<script id="first">

	var editor = document.querySelector("pluto-editor")
	var prev = document.querySelector("button.changeslide.prev")
	var next = document.querySelector("button.changeslide.next")
	
	const click_background = (e => {
		// debugger;
		if (editor != e.target) return;
		e.preventDefault();		
		console.log(e.button);
		if (e.button === 2 && prev) {
			prev.click();
		} else if (e.button === 0 && next) {
			next.click();
		} 
	})
	editor.addEventListener("click", click_background)
	editor.addEventListener("contextmenu", click_background)

	invalidation.then(() => { 
		editor.removeEventListener("click", click_background);
		editor.removeEventListener("contextmenu", click_background);
	})
	
	return true;
</script>
""")

# ╔═╡ b3a75a22-3700-4a4a-ab13-d064715f2a08
html"<style>
.markdown{
	font-size: 20px;
}
main {
	max-width: 80%;
}
pluto-output>div>img {
	margin: auto;
	display: block;
}
</style>"

# ╔═╡ 504843f6-33ab-475c-9936-10992be19386
@bind pcon presentation_controls(aside=true)

# ╔═╡ 7de512e2-f43a-42aa-92bf-49a75170b3ed
@htl "$(apply_css_fixes()) $(presentation_ui(pcon))"

# ╔═╡ 62adfcd1-e110-40ae-a0bf-f2b2625b037e
Title("Quantum Resetting of Walks", "An exploration of the effect of stochastic and quantum resetting on classical and quantum walks", "Dhruva Sambrani, Supervised by Manabendra Nath Bera", "Dept of Physics, IISER - Mohali") # TODO Add image

# ╔═╡ 9bc0dc54-4e12-4d4d-b162-4ef738e6fd73
md"# Classical Walks and Stochastic Reset

Let us first define classical random walks and Stochastic resetting on classical random walks.
"

# ╔═╡ a20a8ab6-2f1d-4118-8135-e68d7882b285
md"""
## Classical Walks

Consider an infinite 1 D chain, with nodes marked by $\mathbb{Z}$.
"""

# ╔═╡ bced9c5d-5cbf-4d4c-b6d1-b500d76d4145
let
	d = Drawing(800, 200)
	origin()
	for i in -5:4
		setcolor("yellow")
		arc2r(Point(i*60+30, -20), Point(i*60, -30), Point(i*60+60, -30), action=:stroke)
		setcolor("lightgreen")
		arc2r(Point(i*60+30, -40), Point(i*60+60, -30), Point(i*60, -30), action=:stroke)
	end
	setcolor("yellow")
	arc2r(Point(-6*60+30, -20), Point(-6*60+30, -50), Point(-6*60+60, -30), action=:stroke)
	setcolor("lightgreen")
	arc2r(Point(-6*60+30, -40), Point(-6*60+60, -30), Point(-6*60+30, -20), action=:stroke)
	setcolor("yellow")
	arc2r(Point(5*60+30, -20), Point(5*60, -30), Point(5*60+30, -50), action=:stroke)
	setcolor("lightgreen")
	arc2r(Point(5*60+30, -40), Point(5*60+30, -10), Point(5*60, -30), action=:stroke)
	setfont("Helvetica", 24)
	for i in -5:5
		setcolor("white")
		settext("$(i)", Point(i*60, 20))
		setcolor("red")
		circle(Point(i*60, -30), 10, action=:fill)
	end
	setcolor("cyan")
	setfont("Helvetica", 16)
	settext("0.5", Point(20, -51))
	settext("0.5", Point(20, -10))
	finish()
	d
end

# ╔═╡ ae30bd04-5325-4f53-9f4f-c62751d528fd
md"""

Define the probability of hopping from node $i$ to node $j$

$$p_{ij} = \begin{cases}
	1/2 & |i - j| = 1 \\
	0 & \text{otherwise}
\end{cases}$$
"""

# ╔═╡ c06f87ae-3a73-4640-969a-c6d09d7b97bf
_walk = cumsum(rand([1, -1], 40));

# ╔═╡ d44250f8-9808-45fe-9a5c-b5eeb1c3f202
md"""
t = $(@bind _t1 Slider(0:40, show_value=true))
"""

# ╔═╡ 1ed2f6a3-c55a-428b-90aa-8fe44e8ab965
let
	d = Drawing(800, 170)
	origin()
	active = _t1==0 ? 0 : _walk[_t1]
	for i in -5:5
		setcolor("white")
		settext("$(i)", Point(i*60, 20))
		setcolor(active == i ? "cyan" : "red")
		circle(Point(i*60, -30), 10, action=:fill)
		setcolor("white")
	end
	setfont("Helvetica", 24)
	settext("Time = $(_t1)", Point(-50, 70))
	finish()
	d
end

# ╔═╡ 13a3f0c1-4ec6-4c1b-a1f5-de4c03ebc3a6
html"<hr>"

# ╔═╡ af257d96-60e4-46af-ba6b-2a9c3f761036
bm = cumsum(rand([1, -1], (200, 10)), dims=1);

# ╔═╡ 4fee1c6d-1d11-4211-b159-987a5db90a26
plot(bm, xlabel="\$t\$", ylabel="\$n\$", label=reshape(map(i->"W $(i)", (1:10)), 1, :), legend=:outerright, size=(700, 400), ylims=(-30, 30))

# ╔═╡ b2603222-0616-4674-b26e-cec578a91691
html"<hr>"

# ╔═╡ d27b1c85-6d45-45fa-afdf-a408e5a11511
cps = let 
	U = SymTridiagonal(fill(0., 31), fill(0.5, 30))
	init = fill(0., 31)
	init[16] = 1
	ps = accumulate(1:40, init=init) do old, _
		U * old
	end
	map(0:40) do t
		if t == 0
			init = fill(0., 31)
			init[16] = 1
			plot(-15:15, init, ylims=(0, 1), ylabel="\$P_t(n)\$", xlabel="\$n\$", title="\$P_t(n)\$ vs \$n\$ at \$t=$(t)\$", legend=false)
		else
			plot(-15:15, ps[t], ylims=(0, 1), ylabel="\$P_t(n)\$", xlabel="\$n\$", title="\$P_t(n)\$ vs \$n\$ at \$t=$(t)\$", legend=false)
		end
	end
end;

# ╔═╡ 90fd60dd-bb0c-4da5-8fe8-b4e6f1200340
md"""
t = $(@bind _t2 Slider(0:40, show_value=true))
"""

# ╔═╡ 0a9fdd6f-fd72-4fc3-b290-e82865fcb31e
cps[_t2+1]

# ╔═╡ cf36b7f7-65e7-4936-9603-528d84cca003
md"""
- Mean - $\mu(t) = 0$
- Std Dev - $\sigma(t) \propto \sqrt t$
- Walk is irreducible, null recurrent $\implies$ no steady state
"""

# ╔═╡ 48091c30-f8e4-4fcb-a48c-334e06e1809a
html"<hr>"

# ╔═╡ 11c81fba-0142-454c-9595-d8bdd8bcceec
md"""
## Stochastic Resetting
"""

# ╔═╡ ba15db0b-d58a-47b4-a7bd-c54c472e5989
md"""
Allow at each step, a jump to node $r_0$ with a probability $\gamma$.

$$p_{ij} = \begin{cases}
	(1-\gamma) \cdot 1/2 & |i - j| = 1 \\
	\gamma & j = r_0 \\
	0 & \text{otherwise}
\end{cases}$$

"""

# ╔═╡ 4ae4e125-dce7-4d7e-a010-712f91401bb3
_walk_r = accumulate(sample([-1, 0, 1], Weights([0.45, 0.1, 0.45]), 40), dims=1) do old, move
	move == 0 ? 0 : old+move
end;

# ╔═╡ 527011b4-3eeb-44ac-9ac7-b95c0c5cbf09
md"""
t = $(@bind _t3 Slider(0:40, show_value=true))
"""

# ╔═╡ a681ebcf-d356-4f4d-bfa2-5f035593dfe9
let
	d = Drawing(800, 170)
	origin()
	active = _t3==0 ? 0 : _walk_r[_t3]
	for i in -5:5
		setcolor("white")
		settext("$(i)", Point(i*60, 20))
		setcolor(active == i ? "cyan" : "red")
		circle(Point(i*60, -30), 10, action=:fill)
		setcolor("white")
	end
	setfont("Helvetica", 24)
	settext("Time = $(_t3)", Point(-50, 70))
	finish()
	d
end

# ╔═╡ 45310b40-e290-4223-9736-d1c05065093f
html"<hr>"

# ╔═╡ 5b8d5924-7b1f-4301-b567-1f3fc2fdc5ab
md"""
Reset location $r_0$ = $(@bind _r₀ Slider(-20:5:20, show_value=true, default=0))
"""

# ╔═╡ 4120652b-3af6-4828-8192-7c1bd1291170
bmr = accumulate(sample([-1, 0, 1], Weights([0.425, 0.05, 0.425]), (200, 10)), dims=1) do old, move
	move == 0 ? _r₀ : old+move
end;

# ╔═╡ 818b36c9-c7cc-43e2-a93f-a035887a302c
begin
	p = plot(bmr, xlabel="\$t\$", ylabel="\$n\$", label=reshape(map(i->"W $(i)", (1:10)), 1, :), legend=:outertopright, size=(690, 400), title="γ = 0.05, r₀=$(_r₀)", ylims=(-30,30))
	p
end

# ╔═╡ b62884e9-b4a2-42df-8890-a50266d3eb49
html"<hr>"

# ╔═╡ 1662bb71-5e85-44e3-bbd4-3e5c9f354969
cprs = let 
	U1 = sparse(SymTridiagonal(fill(0., 31), fill(0.5, 30)))
	R = fill(0., (31, 31))
	R[21,:] .= 1
	U = sparse(0.8 * U1 + 0.2 * R)
	init = fill(0., 31)
	init[16] = 1.
	ps = accumulate(1:100, init=init) do old, _
		U * old
	end
	map(0:100) do t
		if t == 0
			init = fill(0., 31)
			init[16] = 1
			plot(-15:15, init, ylims=(0, 1), ylabel="\$P_t(n)\$", xlabel="\$n\$", title="\$P_t(n)\$ vs \$n\$ at \$t=$(t)\$, \$\\gamma=0.2\$, \$r_0=5\$", legend=false)
		else
			plot(-15:15, ps[t], ylims=(0, 1), ylabel="\$P_t(n)\$", xlabel="\$n\$", title="\$P_t(n)\$ vs \$n\$ at \$t=$(t)\$, \$\\gamma=0.2\$, \$r_0=5\$", legend=false)
		end
	end
end;

# ╔═╡ cffc5d0e-32a5-4a40-956e-cdc62a7c0fce
md"""
t = $(@bind _t4 Slider(0:40, show_value=true))
"""

# ╔═╡ af2f2bb4-126a-41ef-ad09-8789dd4a22a4
cprs[_t4+1]

# ╔═╡ 9cc709f7-15c1-4731-93be-f97c3ad98fa5
md"""
- Mean - $\mu(\infty) = r_0$
- Std Dev depends only on $\gamma$
- Walk is irreducible, positive recurrent $\iff$ steady state exists, which in the continuous limit is an exponential decay on either side of the reset location
"""

# ╔═╡ 9c099f8e-a0f5-43e3-b0b2-9e8b3af1fc17
html"<hr>"

# ╔═╡ 116415bd-b2cc-4bff-9ddd-8c004555e248
LocalResource("crcw.gif")

# ╔═╡ 6159b286-c8b9-4dad-b6c3-9d6c1380987b
html"<hr>"

# ╔═╡ 9992a1e9-aece-41de-a1a2-9fd4c8f14a01
md"""
# Quantum Walks
"""

# ╔═╡ dffac009-e2d0-435c-9761-9f3405d5762f
md"""
## Quantum Walks

Encode the state of the walker in a discrete, infinite level system, and the walk dynamics encoded by a unitary matrix U.

$$|\psi(t)\rangle = U(t)|0\rangle$$

### Coined Quantum Walks

Also called **Szegedy Quantum Walks**

1. Attach a two level coin - states denoted by $|0\rangle$ and $|1\rangle$. Resulting state lies in $\mathcal{H}_C\otimes\mathcal{H}_W$
    - Let capital $\Psi$ denote the coin-walker system, and small $\psi$ denote $\text{Tr}_C(\Psi)$
2. Define Left shift $\left(\text{denoted by }L\right)$ and a Right shift $\left(\text{denoted by }R\right)$ operator -

$$L |i\rangle = |i-1\rangle$$
$$R |i\rangle = |i+1\rangle$$

!!! note "Unitarity of L and R"
	Operators $L, R$ are unitary, and $L^\dagger = R$.

Thus, the resulting walk unitary $U$ can be written as the shift operations controlled on the coin.

$U = |0\rangle\langle 0|\otimes L + |1\rangle\langle 1|\otimes R$

- Define a coin operator $H_C\otimes I_W$, $H_C$ is a hadamard operation on the coin
- Apply this after every application of $U$ to get a superposition in the coin.
"""

# ╔═╡ 12ee2c63-d92b-476d-a7bf-2a570b95388f
html"<hr>"

# ╔═╡ a02d89a0-f33b-466e-8326-7e28b5f32b72
begin
	R = collect(Tridiagonal(fill(1., 60), zeros(61), zeros(60)))
	R[1, end] = 1
	L = collect(Tridiagonal(zeros(60), zeros(61), fill(1., 60)))
	L[end, 1] = 1
	U = KrausOperators([sparse(proj(ket(1, 2)) ⊗ L + proj(ket(2, 2)) ⊗ R)])
	init_coin = 1/√2 * (ket(1,2) - 1im * ket(2,2))
	H = KrausOperators([sparse(hadamard(2)⊗I(61))])
end;

# ╔═╡ 534ab6dc-16d5-473e-94d8-8741402f5d6c
qps = let
	init_state = proj(init_coin ⊗ ket(31,61))
	ψ = [[init_state]; accumulate(1:40, init=init_state) do old, _
		H(U(old))
	end]
	map(real.(diag.(ptrace.(ψ, Ref([2, 61]), Ref([1]))))) do ps
		plot(-30:30, ps, ylims=(0, 1), xlabel="\$i\$", ylabel="\$\\langle i|\\psi\\rangle\$", legend=false)
	end
end;

# ╔═╡ 8e3af979-2fcb-4833-bef4-b5749ee46eea
md"""
t = $(@bind _t6 Slider(0:30, show_value=true))
"""

# ╔═╡ 6d154d71-fd01-4d74-a813-39937cf88046
qps[_t6+1]

# ╔═╡ 81d77c7d-6fb5-4974-8f75-e2584db3b9ab
md"""
Note, this is a single walker, not an ensemble of walkers as is the case in classical random walks. Quantum walks (without measurement), are completely deterministic.
"""

# ╔═╡ fc22a2c3-7005-4859-9f5c-62c3bc61be05
md"""
- Mean - $\mu(t) = 0$
- Std Dev - $\sigma(t) \propto t$
- Walk is irreducible, transient $\implies$ no steady state
"""

# ╔═╡ 70b96e73-a918-403f-8b15-e36e35645bad
html"<hr>"

# ╔═╡ 12aa128d-9603-4131-bc4f-2869a890fd8a
md"""
## Stochastic Reset of Quantum Walks

$$O_{SR}(\rho) = (1-\gamma)\left(U\rho U^\dagger\right) + \gamma \left(c_{\text{init}}\otimes|r_0\rangle\langle r_0|\right)$$
"""

# ╔═╡ e6d007a7-2b6c-4566-8dae-bf22a34431c2
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
	map(real.(diag.(ptrace.(ψ, Ref([2, n+1]), Ref([1]))))) do ps
		plot(-n÷2:n÷2, ps, ylims=(0, 1), xlabel="\$i\$", ylabel="\$\\langle i|\\psi\\rangle\$", legend=false, title="\$\\gamma\$ = $(γ) r = \$|5\\rangle\$")
	end
end;

# ╔═╡ 94b8bfe2-cf3e-46c5-932c-f948f8693094
qpsrs = swqw(60, 0.1);

# ╔═╡ 078e87db-352a-48d6-8d0e-e45b4b5fae96
md"""
t = $(@bind _t7 Slider(0:30, show_value=true))
"""

# ╔═╡ faa02f93-d318-438e-af27-704c1b792662
qpsrs[_t7+1]

# ╔═╡ 8710669a-4850-4af9-b1f3-6796d9703457
html"<hr>"

# ╔═╡ b3916731-9722-4613-896a-083c8e30634e
LocalResource("./srqw.gif", :style=>"max-height: 80vh;")

# ╔═╡ 016dfe25-fe8e-432e-9435-f1c4064df090
md"""
# Hit rates

Main question - **Optimizing hit times**. 

Final requirement of any sort of search algorithm - system is measured, maximize probability of a particular readout

However, we first solve the simpler problem of mean hit time, shortest hit time and success probability for the multiple variations of the walk.

For the classical case, this poses no problem, as measurement does not disturb the system. In the quantum case however, we need to be a bit more careful.
"""

# ╔═╡ 684e065f-ab4f-42d5-96e6-b4ba159e3c2b
html"<hr>"

# ╔═╡ 762aa4f9-0913-4f2f-add9-27681d6d1f42
md"""
## Measurement in the Quantum walk
- Constantly measured walker will freeze dynamics - **Quantum Zeno effect**
- **Solution:** Measure after every $\tau$ steps.

!!! warning "τ=1"
	The $\tau = 1$ case reduces the discrete time quantum walk to a classical random walk

"""

# ╔═╡ 90ea1cb7-905b-4599-9807-9e36bdd0d167
md"""
### Measured Quantum Walk
"""

# ╔═╡ dcc71d75-5083-427a-98f9-1fc3568868bb
lrs, mqps, τ = let
	τ = 9
	init_state = proj(init_coin ⊗ ket(31,61))
	k = 200
	ψ = [[(31, init_state)]; accumulate(1:k, init=(31, init_state)) do (lr, old), t
		ψ′ = H(U(old))
		if t % τ == 0
			coin = ptrace(ψ′, [2, 61], [2])
			lr = sample(1:61, Weights(real(diag(ptrace(ψ′, [2, 61], [1])))))
			ψ′ = coin ⊗ proj(ket(lr, 61))
		end
		(lr, ψ′)
	end]
	ρs = real.(diag.(ptrace.(last.(ψ), Ref([2, 61]), Ref([1]))))
	lrs = first.(ψ)[1:τ:k+1] .- 31
	lrs, map(1:length(ρs)) do p
		plot(-30:30, ρs[p], ylims=(0, 1), xlabel="\$i\$", ylabel="\$\\langle i|\\psi\\rangle\$", title="With the coin operator, τ=$(τ)", legend=false)
		plot!(lrs[1:(p-1)÷τ+1], fill(0.05, (p-1)÷τ+1), st=:scatter, markersize=6, color=theme_palette(:dark)[5])
	end, τ
end;

# ╔═╡ 677f3a62-08f4-4bc5-939c-29ebe14c80dd
md"""
t = $(@bind _t8 Slider(0:200, show_value=true))
"""

# ╔═╡ c4f79c6b-6412-4a95-8040-7ba1d55c28bd
mqps[_t8+1]

# ╔═╡ 903c2923-1325-4620-a24f-1c51c197bfcc
html"<hr>"

# ╔═╡ 5e6af01a-2001-4433-b8e4-e81485f8ac34
mqwts, mqwpaths = let
	init_state = proj(init_coin ⊗ ket(31,61))
	k = 200
	τ = 6
	ys = map(1:10) do _
		ψ = [[(31, init_state)]; accumulate(1:k, init=(31, init_state)) do (lr, old), t
			ψ′ = H(U(old))
			if t % τ == 0
				coin = ptrace(ψ′, [2, 61], [2])
				lr = sample(1:61, Weights(real(diag(ptrace(ψ′, [2, 61], [1])))))
				ψ′ = coin ⊗ proj(ket(lr, 61))
			end
			(lr, ψ′)
		end]
		first.(ψ)[1:τ:k+1] .- 31
	end
	0:τ:τ*(length(first(ys))-1), ys
end;

# ╔═╡ fa8bab93-c9e6-4e66-ad20-0e40025c78b6
plot(
	mqwts, mqwpaths, 
	ylims=(-30,30), 
	ylabel="\$n\$", xlabel="t", title="Readout Path \$\\tau=6\$", 
	labels=reshape(map(i->"W $(i)", 1:length(mqwpaths)), 1, :), legend=:outerright,
	size=(700, 400)
)

# ╔═╡ bc10f9b5-70f0-47cf-9596-819755a6e687
html"<hr>"

# ╔═╡ c4348577-8caf-443b-9a88-f72dbf382fc4
md"""
## Survival probability

Define the following
- Denote the readout at the nᵗʰ measurement (at $t=n\tau$) as $X_n$.
- Select a target node $\delta$
- Probability of first hit $F_n = P(X_n = \delta | X_i \ne \delta \forall i \in [0, n-1])$
- Success probability $S_n = \sum_{i=1}^{n}F_i = P(\exists i \in [0, n]| X_i = \delta)$
- Survival probability $=$ Failure probability $= \mathcal{S}_n = 1 - S_n$
- Asymptomatic versions of these terms are given by taking $n\to \infty$
"""

# ╔═╡ c1ccabda-d3cd-4e60-ab03-95fd262afa0d
md"""
!!! danger "Continuous Walks"
	The following results are for continous walks. We intend to do similar analysis for discrete walks.
"""

# ╔═╡ b31dba15-91e0-476f-9611-07e64a492ee1
html"<hr>"

# ╔═╡ f5c5f906-7044-4a59-9732-f850dd7dffd2
LocalResource("./11-09-13-03.png", "style"=>"width: 75%")

# ╔═╡ cf9456a7-f475-406c-b580-a186005606a4
md"""
### Observations
- The quantum walk has a fast rise in the initial phase but saturates at ~0.1
- The classical walk has a slow rise, but eventually reaches 1

So while the quantum walker is faster, the walk is now transient, which leads to a non zero asymptomatic failure rate.
"""

# ╔═╡ 1438ce70-8f44-46f1-8a20-07a1827973e5
html"<hr>"

# ╔═╡ b76f796d-9180-49dd-a9fd-7c6cee304003
md"""
## The Solution
"""

# ╔═╡ b1b1592f-d6f3-4bb7-8d21-29f48eaad864
md"""
If the walk is fast in the initial phase, but saturates, is it possible to restart the walk when it starts saturating? 

- Allows the initial speedup, but the saturation will not occur

Thus we restart after $r$ measurement events (at $t = r\tau$).
"""

# ╔═╡ 368b3dc0-584e-4484-bd0a-210a02839218
LocalResource("./11-09-15-08.png", "style"=>"width: 75%")

# ╔═╡ 98793912-08f9-400f-9a4c-ac68038d149e
@htl """
<details>
<summary>$(md"Legend")</summary>
$(md"1. Target $\delta: 10$
2. Measurement $\tau = 0.25$
3. Quantum: $r = 35$
4. Classical-1: $r = 35$
5. Classical-2: $r = 191$")
</details>"""

# ╔═╡ 836fdba8-dae9-46fe-accc-eb49bcadafb8
html"<hr>"

# ╔═╡ 149cb9d9-e942-4b6e-90b9-1651cf743589
md"""
## Observations
- Deterministic restart leads to zero asymptomatic failure rate
- Eager restarting leads to walker never reaching $\delta$, reducing success rates drastically
- Cautious restart reduces the effect of restart, reducing success rates.
- There exists an optimal $r$, but needs to be optimized, which is non trivial for general parameters
"""

# ╔═╡ 589993bf-d6c5-4ddc-a290-139ea03641cf
LocalResource("./11-09-15-51.png", "style"=>"width: 55%")

# ╔═╡ b4ac675b-947a-4e8a-8ab3-e13750edeee8
md"""
**Can stochastic restarting be better than sharp reset?**

No, because even if $\langle r\rangle = r_{\text{optimal}}$, $\langle t_f\rangle > \langle t_f\rangle_{\text{optimal}}$ due to the non-monotonic nature of the curve
"""

# ╔═╡ 05902f82-f995-4ce3-b831-ba2ec8939c72
html"<hr>"

# ╔═╡ e3a99564-0c3a-4e66-aee0-070b3319861b
md"## REDACTED"

# ╔═╡ 01a9105c-e6ba-44d2-93f1-d598621f1100
html"<hr>"

# ╔═╡ 93f19125-ed16-4869-8197-a26610bb9472
md"""
# REDACTED
"""

# ╔═╡ dbf63c5f-066d-4e00-9fb3-33bd010ce16e
md"""
## REDACTED
"""

# ╔═╡ 3f20db60-d209-4b08-baa9-c932d5a0b815
@bind ref References()

# ╔═╡ 7303daab-5934-4b56-b43e-a834d18cb5a5
display_bibliography("./MidwayThesis.bib", ref)

# ╔═╡ fae1b25d-3386-498e-a540-4f6e5355c3e8
md"""
# Appendix

## Classical Reset Flow analysis

Stable distribution can be found using Flow analysis at stability -

Let $A = \{-\infty, a\}, A^C = \{a+1, \infty\}, a>0$ 

$$F(A, A^C) = \frac{1-\gamma}{2}\pi_a$$

$$F(A^C, A) = \frac{1-\gamma}{2}\pi_{a+1} + \gamma\sum_{i=a+1}^{\infty} \pi_{i}$$

At stability, 

$$F(A, A^C) = \frac{1-\gamma}{2}\pi_a = \frac{1-\gamma}{2}\pi_{a+1} + \gamma\sum_{i=a+1}^{\infty} \pi_{i} = F(A^C, A)$$

$$\implies \pi_{a+1} - \pi_{a} = -2 \frac{\gamma}{1 - \gamma}\sum_{i=a+1}^{\infty} \pi_{i}$$

$$\implies \pi_{a+1} - \pi_{a} = -\frac{\gamma}{1 - \gamma} \left(2\sum_{i=a+1}^{\infty} \pi_{i}\right)$$

$$\implies \pi_{a+1} - \pi_{a} = -\frac{\gamma}{1 - \gamma} \left(1 - 2\sum_{i=0}^{a} \pi_{i}\right)$$

$$\implies \pi_{a+1} = \pi_{a} -\frac{\gamma}{1 - \gamma} \left(1 - 2\sum_{i=0}^{a} \pi_{i}\right)$$

Normalization of $\pi$ sets $\pi_0$ of the solution.
"""

# ╔═╡ 346839a2-eaf2-43a6-83c2-6ff461368cb7
md"""
## Why the coin operator is necessary
"""

# ╔═╡ e69b65e5-d761-4cd8-9be7-7f56f56cc58a
md"""
On the first application of $U$, the state of the coin and the shifted states get entangled. Therefore, no superposition exists after the first step.
"""

# ╔═╡ 20df1bef-fd64-438f-9724-1409ebe6e684
pqps = let
	init_state = proj(init_coin ⊗ ket(31,61))
	ψ = [[init_state]; accumulate(1:30, init=init_state) do old, _
		U(old)
	end]
	map(real.(diag.(ptrace.(ψ, Ref([2, 61]), Ref([1]))))) do ps
		plot(-30:30, ps, ylims=(0, 1), xlabel="\$i\$", ylabel="\$\\langle i|\\psi\\rangle\$", title="No Coin Operator", legend=false)
	end
end;

# ╔═╡ def9138d-facf-4fd3-b836-0bef4bb037fa
md"""
t = $(@bind _t5 Slider(0:30, show_value=true))
"""

# ╔═╡ 5b75467c-bd44-4a03-ad95-b0270f2b7326
pqps[_t5+1]

# ╔═╡ 0caa18a4-f269-4e11-90ab-5a239bfe2338


# ╔═╡ 68915b43-d635-40e9-a4a4-035ccb5ef3b9
md"""
## REDACTED
"""

# ╔═╡ f2ed0af8-29f9-4532-858a-34ac6cfb5dd7
style_citations(ref, "./midway-report/MidwayThesis.bib", css=JustBold, content=By_Number)

# ╔═╡ c18a5537-caef-480f-b411-e24d51ecac97
md"""
Refs: 
$(cite"yin_restart_2022")
$(cite"goldsmith_link_2022")
$(cite"bonnetain_finding_2022")
$(cite"ostrovsky_simple_2014")
$(cite"ortega_generalized_2022")
$(cite"qiskit_quantum")
$(cite"breloff_plotsjl_2022")
$(cite"sambrani_plutoreportjl")
$(cite"van_der_plas_fonspplutojl_2022")
$(cite"juliagraphics_luxorjl")
$(cite"griffin_investigation_2019")
$(cite"friedman_quantum_2017")
$(cite"bonomo_first_2021")
$(cite"psaltis_markov_2022")
$(cite"kempe_quantum_2003")
$(cite"metropolis_beginning")
$(cite"bae_source_2021")
$(cite"mukherjee_grover_2022")
$(cite"luo_yaojl_2020")
$(cite"bezanson_julia_2017")
$(cite"gawron_quantuminformationjljulia_2018")
$(cite"norris_markov_1998")
$(cite"glasserman_monte_2004")
$(cite"portugal_quantum_2018")
"""

# ╔═╡ e099a79a-33ef-43ad-8890-c134a1cbc053
begin
	centerslide = html"<h1></h1>"
end;

# ╔═╡ 9d801bc0-42b0-44bb-a2cd-9a43d7c80f17
md"""$(centerslide) ### Multiple Walks"""

# ╔═╡ cf279915-1766-4008-bbce-c96e1f2c0745
md"""$(centerslide) ### Probability mass of walkers"""

# ╔═╡ f06f0a1e-d112-4f0d-89e0-539c0ea5a9b6
md"""$(centerslide) ### Multiple Walks"""

# ╔═╡ 8eec20a2-dca6-4001-a9ee-19e5313c6893
md"""$(centerslide) ### Probability mass of walkers"""

# ╔═╡ 59b20b4b-4971-4172-a621-c1907ade0bf0
centerslide

# ╔═╡ 94602660-6f76-4110-b7a0-1b1be770d69f
md"""
$(centerslide) ### Probability of readout
"""

# ╔═╡ 0337a9eb-cdf0-4013-bba1-b2bcd7ec6f3f
centerslide

# ╔═╡ 9d673662-cbcb-470f-9148-c7f06a8091df
md"""
$(centerslide) ### Readout paths
"""

# ╔═╡ a7fb6d92-a9ad-481d-983b-b34eafcb03f3
centerslide

# ╔═╡ 63165326-7d47-4c24-b2d7-012ceb3b777a
centerslide

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

[compat]
HypertextLiteral = "~0.9.4"
Luxor = "~3.5.0"
Plots = "~1.36.6"
PlutoReport = "~0.4.0"
PlutoUI = "~0.7.49"
QuantumInformation = "~0.4.9"
StatsBase = "~0.33.21"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.3"
manifest_format = "2.0"
project_hash = "29f3c932b7305abfe0586afb24c20ee5b64275e4"

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

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg"]
git-tree-sha1 = "2ce8695e1e699b68702c03402672a69f54b8aca9"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2022.2.0+0"

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
git-tree-sha1 = "6dd9866473320c5ec5cd139f3a093cedbdf4cbb3"
uuid = "ab5eb977-4f23-42a0-954d-2743fb6218c4"
version = "0.4.0"

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
# ╟─4a35ff54-5d10-11ed-3969-83c1ef512684
# ╟─d0ad6f88-c906-44a5-908a-9996bd33bf0e
# ╟─7de512e2-f43a-42aa-92bf-49a75170b3ed
# ╟─f9c42e32-8ec9-4bc7-ab27-d3260d587f5c
# ╟─b3a75a22-3700-4a4a-ab13-d064715f2a08
# ╟─504843f6-33ab-475c-9936-10992be19386
# ╟─62adfcd1-e110-40ae-a0bf-f2b2625b037e
# ╟─9bc0dc54-4e12-4d4d-b162-4ef738e6fd73
# ╟─a20a8ab6-2f1d-4118-8135-e68d7882b285
# ╟─bced9c5d-5cbf-4d4c-b6d1-b500d76d4145
# ╟─ae30bd04-5325-4f53-9f4f-c62751d528fd
# ╟─c06f87ae-3a73-4640-969a-c6d09d7b97bf
# ╟─d44250f8-9808-45fe-9a5c-b5eeb1c3f202
# ╟─1ed2f6a3-c55a-428b-90aa-8fe44e8ab965
# ╟─13a3f0c1-4ec6-4c1b-a1f5-de4c03ebc3a6
# ╟─9d801bc0-42b0-44bb-a2cd-9a43d7c80f17
# ╟─af257d96-60e4-46af-ba6b-2a9c3f761036
# ╟─4fee1c6d-1d11-4211-b159-987a5db90a26
# ╟─b2603222-0616-4674-b26e-cec578a91691
# ╟─cf279915-1766-4008-bbce-c96e1f2c0745
# ╟─d27b1c85-6d45-45fa-afdf-a408e5a11511
# ╟─90fd60dd-bb0c-4da5-8fe8-b4e6f1200340
# ╟─0a9fdd6f-fd72-4fc3-b290-e82865fcb31e
# ╟─cf36b7f7-65e7-4936-9603-528d84cca003
# ╟─48091c30-f8e4-4fcb-a48c-334e06e1809a
# ╟─11c81fba-0142-454c-9595-d8bdd8bcceec
# ╟─ba15db0b-d58a-47b4-a7bd-c54c472e5989
# ╟─4ae4e125-dce7-4d7e-a010-712f91401bb3
# ╟─527011b4-3eeb-44ac-9ac7-b95c0c5cbf09
# ╟─a681ebcf-d356-4f4d-bfa2-5f035593dfe9
# ╟─45310b40-e290-4223-9736-d1c05065093f
# ╟─f06f0a1e-d112-4f0d-89e0-539c0ea5a9b6
# ╟─4120652b-3af6-4828-8192-7c1bd1291170
# ╟─5b8d5924-7b1f-4301-b567-1f3fc2fdc5ab
# ╟─818b36c9-c7cc-43e2-a93f-a035887a302c
# ╟─b62884e9-b4a2-42df-8890-a50266d3eb49
# ╟─8eec20a2-dca6-4001-a9ee-19e5313c6893
# ╟─1662bb71-5e85-44e3-bbd4-3e5c9f354969
# ╟─cffc5d0e-32a5-4a40-956e-cdc62a7c0fce
# ╟─af2f2bb4-126a-41ef-ad09-8789dd4a22a4
# ╟─9cc709f7-15c1-4731-93be-f97c3ad98fa5
# ╟─9c099f8e-a0f5-43e3-b0b2-9e8b3af1fc17
# ╟─59b20b4b-4971-4172-a621-c1907ade0bf0
# ╟─116415bd-b2cc-4bff-9ddd-8c004555e248
# ╟─6159b286-c8b9-4dad-b6c3-9d6c1380987b
# ╟─9992a1e9-aece-41de-a1a2-9fd4c8f14a01
# ╟─dffac009-e2d0-435c-9761-9f3405d5762f
# ╟─12ee2c63-d92b-476d-a7bf-2a570b95388f
# ╟─a02d89a0-f33b-466e-8326-7e28b5f32b72
# ╟─94602660-6f76-4110-b7a0-1b1be770d69f
# ╟─534ab6dc-16d5-473e-94d8-8741402f5d6c
# ╟─8e3af979-2fcb-4833-bef4-b5749ee46eea
# ╟─6d154d71-fd01-4d74-a813-39937cf88046
# ╟─81d77c7d-6fb5-4974-8f75-e2584db3b9ab
# ╟─fc22a2c3-7005-4859-9f5c-62c3bc61be05
# ╟─70b96e73-a918-403f-8b15-e36e35645bad
# ╟─12aa128d-9603-4131-bc4f-2869a890fd8a
# ╟─e6d007a7-2b6c-4566-8dae-bf22a34431c2
# ╟─94b8bfe2-cf3e-46c5-932c-f948f8693094
# ╟─078e87db-352a-48d6-8d0e-e45b4b5fae96
# ╟─faa02f93-d318-438e-af27-704c1b792662
# ╟─8710669a-4850-4af9-b1f3-6796d9703457
# ╟─0337a9eb-cdf0-4013-bba1-b2bcd7ec6f3f
# ╟─b3916731-9722-4613-896a-083c8e30634e
# ╟─016dfe25-fe8e-432e-9435-f1c4064df090
# ╟─684e065f-ab4f-42d5-96e6-b4ba159e3c2b
# ╟─762aa4f9-0913-4f2f-add9-27681d6d1f42
# ╟─90ea1cb7-905b-4599-9807-9e36bdd0d167
# ╟─dcc71d75-5083-427a-98f9-1fc3568868bb
# ╟─677f3a62-08f4-4bc5-939c-29ebe14c80dd
# ╟─c4f79c6b-6412-4a95-8040-7ba1d55c28bd
# ╟─903c2923-1325-4620-a24f-1c51c197bfcc
# ╟─9d673662-cbcb-470f-9148-c7f06a8091df
# ╟─5e6af01a-2001-4433-b8e4-e81485f8ac34
# ╟─fa8bab93-c9e6-4e66-ad20-0e40025c78b6
# ╟─bc10f9b5-70f0-47cf-9596-819755a6e687
# ╟─c4348577-8caf-443b-9a88-f72dbf382fc4
# ╟─c1ccabda-d3cd-4e60-ab03-95fd262afa0d
# ╟─b31dba15-91e0-476f-9611-07e64a492ee1
# ╟─a7fb6d92-a9ad-481d-983b-b34eafcb03f3
# ╟─f5c5f906-7044-4a59-9732-f850dd7dffd2
# ╟─cf9456a7-f475-406c-b580-a186005606a4
# ╟─1438ce70-8f44-46f1-8a20-07a1827973e5
# ╟─b76f796d-9180-49dd-a9fd-7c6cee304003
# ╟─b1b1592f-d6f3-4bb7-8d21-29f48eaad864
# ╟─368b3dc0-584e-4484-bd0a-210a02839218
# ╟─98793912-08f9-400f-9a4c-ac68038d149e
# ╟─836fdba8-dae9-46fe-accc-eb49bcadafb8
# ╟─149cb9d9-e942-4b6e-90b9-1651cf743589
# ╟─589993bf-d6c5-4ddc-a290-139ea03641cf
# ╟─b4ac675b-947a-4e8a-8ab3-e13750edeee8
# ╟─05902f82-f995-4ce3-b831-ba2ec8939c72
# ╟─e3a99564-0c3a-4e66-aee0-070b3319861b
# ╟─01a9105c-e6ba-44d2-93f1-d598621f1100
# ╟─93f19125-ed16-4869-8197-a26610bb9472
# ╟─dbf63c5f-066d-4e00-9fb3-33bd010ce16e
# ╟─3f20db60-d209-4b08-baa9-c932d5a0b815
# ╟─7303daab-5934-4b56-b43e-a834d18cb5a5
# ╟─fae1b25d-3386-498e-a540-4f6e5355c3e8
# ╟─346839a2-eaf2-43a6-83c2-6ff461368cb7
# ╟─e69b65e5-d761-4cd8-9be7-7f56f56cc58a
# ╟─20df1bef-fd64-438f-9724-1409ebe6e684
# ╟─def9138d-facf-4fd3-b836-0bef4bb037fa
# ╟─5b75467c-bd44-4a03-ad95-b0270f2b7326
# ╟─0caa18a4-f269-4e11-90ab-5a239bfe2338
# ╟─68915b43-d635-40e9-a4a4-035ccb5ef3b9
# ╟─63165326-7d47-4c24-b2d7-012ceb3b777a
# ╟─f2ed0af8-29f9-4532-858a-34ac6cfb5dd7
# ╟─c18a5537-caef-480f-b411-e24d51ecac97
# ╟─e099a79a-33ef-43ad-8890-c134a1cbc053
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
