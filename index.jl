### A Pluto.jl notebook ###
# v0.19.26

using Markdown
using InteractiveUtils

# ╔═╡ 86325fcc-348c-4108-bf77-3555a6fc243c
begin
	using Base.Iterators
	using PlutoTest
end

# ╔═╡ 49735ec6-6b0e-4e8e-995c-cc2e8c41e625
begin
	using PlutoUI
end

# ╔═╡ 16fdf9c8-975c-4608-af46-7ed6d20bad7a
md"# Polyominos tilings"

# ╔═╡ 5da0ce50-d477-4f7d-8ec1-010d8f5fc902
md"## Introduction"

# ╔═╡ 870e528d-678e-497e-893d-72d3b7b0eab0
md"""
A large chunk of computational geometry works with simple polygons, with them being one of the most basic building blocks. They are studied in contexts of intersections, triangulations, and many others. One such area of study is that of _plane tilings_ (or _tesselations_).

Given a set of polygons $P$, can we fill the entire plane with copies of $p∈P$ so that no portion of the plane is left uncovered. That is, can we put copies of the polygons next to each other without leaving gaps in between. This innocent-looking problem turns out to be a very difficult one.

For this problem, even polygons are much too complex to reason with. However, we may impose constraints on both the kind of tiling and the types of polygons that are used to create easier problems and perhaps grasp at a solution. We present here a version using only one _polyomino_ and in the context of _isohedral_ tilings.

A _polyomino_ is a polygon formed of glued-together unit-length squares with no inner holes. Whereas a tiling is said to be _isohedral_, if any two copies can be mapped to one another. Intuitively, it means that the tiling is locally similar, that is, taking any one copy independently and considering its neighborhood, we cannot distinguish it from the other copies.
"""

# ╔═╡ 13b287d8-6340-4570-9f7c-ed9eab4bdd2c
md"""
Here’s an example showing two tesselations of the plane with polyominos. Both use only one shape, but only the second one is isohedral. In the first, only shapes of the same color may be mapped to one another.

![](https://upload.wikimedia.org/wikipedia/commons/thumb/1/17/Conway_criterion_false_negative_nonominoes.svg/1024px-Conway_criterion_false_negative_nonominoes.svg.png)
"""

# ╔═╡ 45d3575a-c887-435c-84be-a26284ee5dcb
md"## Interactive showcase"

# ╔═╡ c1587642-84ed-459f-855d-fdd07ac3f761
md"## Theoretical explanations"

# ╔═╡ 151513d3-6b7b-4e0f-ad35-3a0fd3f9c905
md"""
Example of inline math ``x = 8`` and standalone:

```math
\sum_{i = 0}^{n} i = \frac{n(n+1)}{2}
```
"""

# ╔═╡ 5751c86d-ca45-4788-b0e2-5fee73595720
md"""
Plain markdown with *italics*, **bold** and other niceties.
"""

# ╔═╡ 852453e2-2802-4e2a-9614-accb986bc8e7
md"""
> Some note
"""

# ╔═╡ 9f2236ba-0e22-4425-a951-6cc6ceed7520
md"# Appendix A: code"

# ╔═╡ 092d59e2-d814-48e5-87ca-db6fdfbbe934
md"## Constants"

# ╔═╡ 3a0b058e-6921-4375-b514-7a05f19a26bb
const RIGHT = 'r'

# ╔═╡ 473faf5a-8152-44b7-b3f3-265a87d89391
const UP = 'u'

# ╔═╡ 3ce45f35-0ef0-4e87-a20c-7f72c03251df
const LEFT = 'l'

# ╔═╡ 5754ff07-4a06-40eb-b15e-9e1a2f135395
const DOWN = 'd'

# ╔═╡ dab01fba-d85b-4956-94c4-b8d2a6933165
const ALPHABET = [RIGHT, UP, LEFT, DOWN]

# ╔═╡ 9fd065ab-df8e-4058-b84a-d8824cfd60cc
md"## Helper functions"

# ╔═╡ ad8103a2-e5c9-4d9e-bd41-2e1e6b3e6d40
indexof(letter::Char) = findfirst(x -> x == letter, ALPHABET)

# ╔═╡ fe33290c-b27c-48bd-8aee-b6f3cd6a5184
complement(word::String) = String(map(complement, word))

# ╔═╡ 291e04ef-a5dd-4cd2-a598-f2256e6643e0
twice(word::String) = repeat(word, 2)

# ╔═╡ 3e4a972f-6b44-41a6-91d2-3f949b9b7004
md"""
### Factors
"""

# ╔═╡ 70fba921-5e52-4b04-84e0-397087f0005c
struct Factor
	content::String
	start::Int64
	finish::Int64
end

# ╔═╡ 5c3bc705-0500-42ae-abce-a2e2da6f06fe
Base.length(factor::Factor) = length(factor.content)

# ╔═╡ 5592d3ff-30a3-4be7-9ce6-3894ef76c79d
function tθ(letter::Char, θ::Int64)
	@assert θ % 90 == 0

	rot = (θ ÷ 90) % 3
	idx = mod1(indexof(letter) + rot, length(ALPHABET))
	
	ALPHABET[idx]
end

# ╔═╡ 556054b0-23e5-4bef-8356-ffdbb99cdcd2
complement(letter::Char) = tθ(letter, 180)

# ╔═╡ 642e20fa-5582-418b-ae66-7ec493209736
backtrack(word::String) = complement(reverse(word))

# ╔═╡ 24c55137-7470-4b2a-9948-9e4ec23aa11c
function fθ(letter::Char, θ::Int64)
	@assert θ ∈ [-45, 0, 45, 90]
	
	curr = indexof(letter)
	rotation = 0  # Do nothing by default
	
	if θ == -45
		rotation = isodd(curr) ? -90 : 90
	elseif θ == 0
		rotation = isodd(curr) ? 0 : 180
	elseif θ == 45
		rotation = isodd(curr) ? 90 : -90
	elseif θ == 90
		rotation = isodd(curr) ? 180 : 0
	end

	tθ(letter, rotation)
end

# ╔═╡ 19742340-925a-49cf-b2dd-109201492bb2
@test length(Factor("hello", 1, 5)) == 5

# ╔═╡ e9d30d5f-1ef9-4d9b-9a88-7475907faf3a
@test length(Factor("hello", 5, 1)) == 5

# ╔═╡ 78ea5c1f-1212-430c-811e-456a3542358e
"""
	extract(word::String, start::Int64, finish::Int64)::String

Extract the section in `word` starting at `start` and ending at `finish`. The word is assumed to be circular if `finish` < `start`.
"""
function extract(word::String, start::Int64, finish::Int64)::String
	if start <= finish
		word[start:finish]
	else
		word[start:end] * word[begin:finish]
	end
end

# ╔═╡ cd430387-c391-4360-921b-3ca958a70d47
"""
	factor(word::String, start::Int64, finish::Int64)::Factor

Create a factor in `word` from `start` to `finish`.
"""
function factor(word::String, start::Int64, finish::Int64)::Factor
	Factor(extract(word, start, finish), start, finish)
end

# ╔═╡ cd7d4c8f-b910-4b9f-95a5-0054c0e01ee7
@test factor("polyomino", 2, 7) == Factor("olyomi", 2, 7)

# ╔═╡ 5c94888b-2196-4124-b731-8d74b19c3f76
@test factor("polyomino", 7, 2) == Factor("inopo", 7, 2)

# ╔═╡ 425433a9-5fd8-4860-a5ad-58d5f5aeb7f0
@test extract("polyomino", 2, 4) == "oly"

# ╔═╡ ecc3548e-b639-4fdc-bf23-2f2096eecb71
@test extract("polyomino", 8, 4) == "nopoly"

# ╔═╡ 5ea887e6-e435-46fd-bd5b-62a88cb79241
md"""
### BN Factorization
"""

# ╔═╡ 1d86b240-d7d7-4988-960e-0a56030efca7
function common_prefix(a::String, b::String)
	max_bound = min(length(a), length(b))
	bound = 1
	
	while bound ≤ max_bound && a[bound] == b[bound]
		bound += 1
	end
	
	a[begin:bound-1]
end

# ╔═╡ f452ddf6-c03e-4aaa-9a52-32c98ae396b8
@test common_prefix("hello", "hella") == "hell"

# ╔═╡ 8a3d3c83-c88f-48d7-b54a-5d3c92d3b54c
@test common_prefix("abc", "def") == ""

# ╔═╡ 17c4fc0e-9be1-41ab-8958-ff66627ccd06
# ╠═╡ disabled = true
#=╠═╡
function longest_common_factor(a::String, b::String)::Union{String, Nothing}
	aa = a
    bb = b
	factor = ""
    for i ∈ eachindex(a)
		for j ∈ eachindex(b)
            s = 0
            while i+s ≤ length(a) && j+s ≤ length(b) && a[i+s] == b[j+s]
            	s += 1
            end
			if s != 0 && s > length(factor)
				factor = a[i:i+s-1]
			end
        end
    end
	factor
end
  ╠═╡ =#

# ╔═╡ aff885f3-1157-47d6-80b7-11c8b6344ec6
#=╠═╡
@test longest_common_factor("xhelloy", "yhellox") == "hello"
  ╠═╡ =#

# ╔═╡ 4bb7ad14-8698-4bd9-bc27-acbcb3aa6d5f
# ╠═╡ disabled = true
#=╠═╡
function admissible_factors(word::String)
	comp = twice(complement(word))
	rev  = twice(reverse(word))
	back = twice(backtrack(word))

	for i ∈ 1:length(word)
		start_word = i + 1
		start_back = mod1(length(word) ÷ 2 - (i + 1), length(word))
		R = longest_common_factor(word[start_word:end], back[start_back:end])
		
		start_rev = mod1(length(word) ÷ 2 - i, length(word))
		start_comp = i
		L = longest_common_factor(rev[start_rev:end], comp[start_comp:end])

		if length(R) == length(L) && !isempty(L)
			println("$i => $L$R")
		end
	end
end
  ╠═╡ =#

# ╔═╡ ed19093c-0f09-4a19-9cfd-98e24005b7c8
"""
	factors_by_start(factors::Set{Factor}, word_size::Int64)::Dict{Integer, Vector{Factor}}

Return a `Dict` with the keys being the positions in the word, and the values the factors starting at said position sorted by ascending length.
"""
function factors_by_start(factors::Set{Factor}, word_size::Int64)::Dict{Integer, Vector{Factor}}
	factors = sort(collect(factors); by=length)
	dict = Dict(i => [] for i ∈ 1:word_size)
	foreach(f -> push!(dict[f.start], f), factors)
	dict
end

# ╔═╡ 0806d4f5-89ed-46a1-8c65-f1e797dc6977
@test factors_by_start(
	Set([
		Factor("ab", 1, 2),
		Factor("ab", 2, 3),
		Factor("abc", 1, 3)
	]), 3) == Dict(
		1 => [Factor("ab", 1, 2), Factor("abc", 1, 3)],
		2 => [Factor("ab", 2, 3)],
		3 => []
	)

# ╔═╡ abceaed4-8a67-416a-a8aa-f0c77f9c3b2a
"""
	factors_by_finish(factors::Set{Factor}, word_size::Integer)::Dict{Integer, Vector{Factor}}

Return a `Dict` with the keys being the positions in the word, and the values the factors ending at said position sorted by ascending length.
"""
function factors_by_finish(factors::Set{Factor}, word_size::Integer)::Dict{Integer, Vector{Factor}}
	factors = sort(collect(factors); by=length)
	dict = Dict(i => [] for i ∈ 1:word_size)
	foreach(f -> push!(dict[f.finish], f), factors)
	dict
end

# ╔═╡ cb0f1693-50a1-4655-bf5f-dc2eeaf8e8fa
@test factors_by_finish(
	Set(
		[
			Factor("ab", 1, 2),
			Factor("ab", 2, 3),
			Factor("abc", 1, 3)
		]
	), 3) == Dict(
		1 => [],
		2 => [Factor("ab", 1, 2)],
		3 => [Factor("ab", 2, 3), Factor("abc", 1, 3)]
	)

# ╔═╡ f5cc61b3-b844-48d7-898b-4206506c0dae
"""
	admissible_factors(word::String)::Vector{Factor}

Return the admissible factors in `word`.
"""
function admissible_factors(word::String)::Set{Factor}
	backtracked = twice(backtrack(word))
	
	backed(idx) = length(word) - idx + 1
	s(idx) = mod1(idx, length(word))

	factors = Set()

	# With center of size 1
	for i ∈ 1:length(word)
		center = i
		diametral_opposite = s(length(word) ÷ 2 + center)

		fwd_idx = center
		bwd_idx = backed(diametral_opposite)
		R = common_prefix(word[fwd_idx:end], backtracked[bwd_idx:end])

		fwd_idx = diametral_opposite
		bwd_idx = backed(center)
		L = common_prefix(word[fwd_idx:end], backtracked[bwd_idx:end])

		if length(R) == length(L) && !isempty(L)
			start = s(center - length(L) + 1)
			finish = s(center + length(R) - 1)
			push!(factors, factor(word, start, finish))
		end
	end

	# With center of size 2
	for i ∈ 1:length(word)-1
		l_center = i
		r_center = i + 1

		opposite_l_center = s(length(word) ÷ 2 + l_center + 1)
		opposite_r_center = opposite_l_center - 1

		fwd_idx = r_center
		bwd_idx = backed(opposite_r_center)
		R = common_prefix(word[fwd_idx:end], backtracked[bwd_idx:end])

		fwd_idx = opposite_l_center
		bwd_idx = backed(l_center)
		L = common_prefix(word[fwd_idx:end], backtracked[bwd_idx:end])

		if length(R) == length(L) && !isempty(L)
			start = r_center - length(L)
			finish = l_center + length(R)
			push!(factors, factor(word, start, finish))
		end
	end

	factors
end

# ╔═╡ 0ea45964-96b7-438c-a47a-609e4cd4fed0
@test admissible_factors("uldr") == Set([
	Factor("d", 3, 3),
	Factor("r", 4, 4),
	Factor("u", 1, 1),
	Factor("l", 2, 2)
])

# ╔═╡ 8d84c5dd-8c7d-456c-88fb-91d5a787846a
# ╠═╡ disabled = true
#=╠═╡
#admissible_factors("urrrdlll")
#admissible_factors("rrddrurddrdllldldluullurrruluu")
admissible_factors("ururdrrdldllul")
  ╠═╡ =#

# ╔═╡ 830056cc-efb4-4305-9a69-4f19138eb6db
"""
Expand half BN factorizations to full ones.
"""
function expand(factors::Vector{Factor}, word_length::Integer)::Vector{Factor}
	half_length = word_length ÷ 2
	forward = factors
	backward = map(factors) do factor
		content = backtrack(factor.content)
		start = factor.start + half_length
		finish = factor.finish + half_length
		Factor(content, start, finish)
	end
	append!(forward, backward)
end

# ╔═╡ 99d849e7-f9cc-4ab8-af5a-dce0bc1f8543
function bn_factorization(word::String)::Union{Some{Vector{Factor}}, Nothing}
	adm_factors = admissible_factors(word)
	fac_by_start = factors_by_start(adm_factors, length(word))
	fac_by_finish = factors_by_finish(adm_factors, length(word))
	mid_len = length(word) ÷ 2
	factorization = nothing

	for starting_factors ∈ values(fac_by_start)
		for A ∈ starting_factors
			for B ∈	fac_by_start[mod1(A.finish + 1, length(word))]
				if length(A) + length(B) > mid_len
					break
				elseif length(A) + length(B) == mid_len
					factorization = [A, B]
				else
					start = mod1(B.finish + 1, length(word))
					finish = mod1(A.start + mid_len - 1, length(word))
					C = factor(word, start, finish)
					if C ∈ adm_factors
						factorization = [A, B, C]
					end
				end
			end
		end
	end

	for finishing_factors ∈ values(fac_by_finish)
		for C ∈ finishing_factors
			for B ∈	fac_by_finish[mod1(C.start - 1, length(word))]
				if length(C) + length(B) > mid_len
					break
				elseif length(C) + length(B) == mid_len
					factorization = [B, C]
				else
					finish = mod1(B.start - 1, length(word))
					start = mod1(C.finish - mid_len + 1, length(word))
					A = factor(word, start, finish)
					if A ∈ adm_factors
						factorization = [A, B, C]
					end
				end
			end
		end
	end

	factorization == nothing ? nothing : Some(expand(factorization, length(word)))
end

# ╔═╡ b77fe1fc-86f1-4226-8316-75862f5a2c76
bn_factorization("rrddrurddrdllldldluullurrruluu")

# ╔═╡ 3f57a6c8-d02d-4c29-8b0d-4e8871f60900
md"## Notebook related"

# ╔═╡ e32b500b-68b1-4cea-aac5-f6755cfcc5b6
TableOfContents()

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
PlutoTest = "cb4044da-4d16-4ffa-a6a3-8cad7f73ebdc"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
PlutoTest = "~0.2.2"
PlutoUI = "~0.7.52"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.3"
manifest_format = "2.0"
project_hash = "9d928b79cfbce5a4f4ea0b3c55830c00f8a3d4da"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "91bd53c39b9cbfb5ef4b015e8b582d344532bd0a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.2.0"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.5+0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

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
git-tree-sha1 = "d75853a0bdbfb1ac815478bacd89cd27b550ace6"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.3"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

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

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.10.11"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.21+4"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "716e24b21538abc91f6205fd1d8363f39b442851"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.7.2"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.9.2"

[[deps.PlutoTest]]
deps = ["HypertextLiteral", "InteractiveUtils", "Markdown", "Test"]
git-tree-sha1 = "17aa9b81106e661cffa1c4c36c17ee1c50a86eda"
uuid = "cb4044da-4d16-4ffa-a6a3-8cad7f73ebdc"
version = "0.2.2"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "e47cd150dbe0443c3a3651bc5b9cbd5576ab75b7"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.52"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "03b4c25b43cb84cee5c90aa9b5ea0a78fd848d2f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.0"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00805cd429dcb4870060ff49ef443486c262e38e"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.1"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.9.0"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "Pkg", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "5.10.1+6"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.Tricks]]
git-tree-sha1 = "eae1bb484cd63b36999ee58be2de6c178105112f"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.8"

[[deps.URIs]]
git-tree-sha1 = "67db6cc7b3821e19ebe75791a9dd19c9b1188f2b"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.8.0+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"
"""

# ╔═╡ Cell order:
# ╟─16fdf9c8-975c-4608-af46-7ed6d20bad7a
# ╟─5da0ce50-d477-4f7d-8ec1-010d8f5fc902
# ╟─870e528d-678e-497e-893d-72d3b7b0eab0
# ╟─13b287d8-6340-4570-9f7c-ed9eab4bdd2c
# ╟─45d3575a-c887-435c-84be-a26284ee5dcb
# ╟─c1587642-84ed-459f-855d-fdd07ac3f761
# ╟─151513d3-6b7b-4e0f-ad35-3a0fd3f9c905
# ╟─5751c86d-ca45-4788-b0e2-5fee73595720
# ╟─852453e2-2802-4e2a-9614-accb986bc8e7
# ╟─9f2236ba-0e22-4425-a951-6cc6ceed7520
# ╠═86325fcc-348c-4108-bf77-3555a6fc243c
# ╟─092d59e2-d814-48e5-87ca-db6fdfbbe934
# ╟─3a0b058e-6921-4375-b514-7a05f19a26bb
# ╟─473faf5a-8152-44b7-b3f3-265a87d89391
# ╟─3ce45f35-0ef0-4e87-a20c-7f72c03251df
# ╟─5754ff07-4a06-40eb-b15e-9e1a2f135395
# ╟─dab01fba-d85b-4956-94c4-b8d2a6933165
# ╟─9fd065ab-df8e-4058-b84a-d8824cfd60cc
# ╠═ad8103a2-e5c9-4d9e-bd41-2e1e6b3e6d40
# ╠═5592d3ff-30a3-4be7-9ce6-3894ef76c79d
# ╠═556054b0-23e5-4bef-8356-ffdbb99cdcd2
# ╠═fe33290c-b27c-48bd-8aee-b6f3cd6a5184
# ╠═24c55137-7470-4b2a-9948-9e4ec23aa11c
# ╠═642e20fa-5582-418b-ae66-7ec493209736
# ╠═291e04ef-a5dd-4cd2-a598-f2256e6643e0
# ╟─3e4a972f-6b44-41a6-91d2-3f949b9b7004
# ╠═70fba921-5e52-4b04-84e0-397087f0005c
# ╠═cd430387-c391-4360-921b-3ca958a70d47
# ╟─cd7d4c8f-b910-4b9f-95a5-0054c0e01ee7
# ╟─5c94888b-2196-4124-b731-8d74b19c3f76
# ╠═5c3bc705-0500-42ae-abce-a2e2da6f06fe
# ╟─19742340-925a-49cf-b2dd-109201492bb2
# ╟─e9d30d5f-1ef9-4d9b-9a88-7475907faf3a
# ╠═78ea5c1f-1212-430c-811e-456a3542358e
# ╟─425433a9-5fd8-4860-a5ad-58d5f5aeb7f0
# ╟─ecc3548e-b639-4fdc-bf23-2f2096eecb71
# ╟─5ea887e6-e435-46fd-bd5b-62a88cb79241
# ╟─1d86b240-d7d7-4988-960e-0a56030efca7
# ╟─f452ddf6-c03e-4aaa-9a52-32c98ae396b8
# ╟─8a3d3c83-c88f-48d7-b54a-5d3c92d3b54c
# ╟─17c4fc0e-9be1-41ab-8958-ff66627ccd06
# ╟─aff885f3-1157-47d6-80b7-11c8b6344ec6
# ╟─4bb7ad14-8698-4bd9-bc27-acbcb3aa6d5f
# ╟─ed19093c-0f09-4a19-9cfd-98e24005b7c8
# ╟─0806d4f5-89ed-46a1-8c65-f1e797dc6977
# ╟─abceaed4-8a67-416a-a8aa-f0c77f9c3b2a
# ╟─cb0f1693-50a1-4655-bf5f-dc2eeaf8e8fa
# ╠═f5cc61b3-b844-48d7-898b-4206506c0dae
# ╟─0ea45964-96b7-438c-a47a-609e4cd4fed0
# ╟─8d84c5dd-8c7d-456c-88fb-91d5a787846a
# ╠═830056cc-efb4-4305-9a69-4f19138eb6db
# ╠═99d849e7-f9cc-4ab8-af5a-dce0bc1f8543
# ╠═b77fe1fc-86f1-4226-8316-75862f5a2c76
# ╟─3f57a6c8-d02d-4c29-8b0d-4e8871f60900
# ╠═49735ec6-6b0e-4e8e-995c-cc2e8c41e625
# ╠═e32b500b-68b1-4cea-aac5-f6755cfcc5b6
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
