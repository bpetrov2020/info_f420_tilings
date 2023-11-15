### A Pluto.jl notebook ###
# v0.19.32

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

# ╔═╡ 49735ec6-6b0e-4e8e-995c-cc2e8c41e625
begin
	using PlutoUI
end

# ╔═╡ c84c3cfb-46df-4d5a-93c3-4e34be505488
using HypertextLiteral

# ╔═╡ 16fdf9c8-975c-4608-af46-7ed6d20bad7a
md"# Polyominos tilings"

# ╔═╡ 5da0ce50-d477-4f7d-8ec1-010d8f5fc902
md"## Introduction"

# ╔═╡ 45d3575a-c887-435c-84be-a26284ee5dcb
md"## Interactive showcase"

# ╔═╡ 6d4c526e-4d62-4d4c-88ca-728ea6b4fbf6
@htl("""
<style>
	.button-grid {
		display: grid;
		grid-template-columns: repeat(10, 50px);
	}
	
	.button {
		width: 50px;
		height: 50px;
		border: 1px solid black;
		cursor: pointer;
		outline: none;
		font-weight: bold;
		background-color: white;
	}
	
	.button.clicked {
		border: 3px solid red;
	}
	.button.top {
		border-top: 1px dotted #8c8c8c;
	}
	.button.bottom {
		border-bottom: 1px dotted #8c8c8c;
	}
	.button.right {
		border-right: 1px dotted #8c8c8c;
	}
	.button.left {
		border-left: 1px dotted #8c8c8c;
	}

	.button.fill-red {
		background-color: red;
	}

	.button.fill-white {
		background-color: white;
	}
</style>

<div id="button-grid" class="button-grid"></div>
<script>
	// Generating the buttons
	const buttonContainer = document.getElementById('button-grid');
	for (let i = 1; i <= 100; i++) {
		const button = document.createElement('button');
		button.className = 'button';
		buttonContainer.appendChild(button);
	}

	// Bind click with neighbors 
	const buttons = document.querySelectorAll('.button');
	buttons.forEach(btn => btn.onclick = function() {
		buttonClick(btn, getNeighbors(btn));
	});
	
	function buttonClick(button, neighbors) {
		button.classList.toggle('clicked');
		neighbors.forEach(nb => {
			if (nb[0].classList.contains('clicked')) {
				switch(nb[1]){
					case 'T':
						button.classList.toggle('top');
						nb[0].classList.toggle('bottom');
						break;
					case 'B':
						button.classList.toggle('bottom');
						nb[0].classList.toggle('top');
						break;
					case 'R':
						button.classList.toggle('right');
						nb[0].classList.toggle('left');
						break;
					case 'L':
						button.classList.toggle('left');
						nb[0].classList.toggle('right');
						break;
					default:
						console.log("Something went wrong");
				}
			}
		});
	}
	
	function getNeighbors(button) {
		const neighbors = [];
		const buttons = document.querySelectorAll('.button');
		const buttonIndex = Array.from(buttons).indexOf(button);

		// Get Left, Right, Top and Bottom Neighbour
		const neighborIndices = [
		[buttonIndex - 1, 'L'],
		[buttonIndex + 1, 'R'],
		[buttonIndex - 10, 'T'],
		[buttonIndex + 10, 'B']];
		const validIndices = neighborIndices.filter(idx => idx[0] >= 0 && idx[0]< buttons.length);
		validIndices.forEach(idx => neighbors.push([buttons[idx[0]], idx[1]]));
		return neighbors;
	}
	</script>
""")

# ╔═╡ 8b41e978-f9cf-4515-9141-cbf8130521d9
@bind boundaryWord @htl("""
<span>
<style>
	.button-line {
		width: 505px;
		display: flex;
		justify-content: space-between;
	}
	
	.cmd-button {
		width: 80px;
		height: 35px;
		margin-right: 5px;
		color: white;
		border-radius: 5px;

		cursor: pointer;
	}
	
	.cmd-button:nth-child(1) {
		background-color: #00e600; 
	}
	
	.cmd-button:nth-child(2) {
		background-color: #668cff; 
	}
	
	.cmd-button:nth-child(3) {
		background-color: #ff1a1a;
	}
	
	.cmd-button:hover {
		opacity: 0.8;
	}

  	.cmd-button:disabled {
    	background-color: #bcbcde;
    	cursor: not-allowed; 
	}
</style>

<div class="button-line">
	<button class="cmd-button" id="done-btn">DONE</button>
	<button class="cmd-button" id="edit-btn">EDIT</button>
	<button class="cmd-button" id="reset-btn">RESET</button>
</div>
<script>
	// (enabled) Done => Checks for legal polyomino => Bw = generateBoundaryWord() => fill polyomino in grid => disable button and grid => enable Edit
	// (disabled) Edit => If done => Bw= None => enable grid and Done => unfill polyomino in grid
	// (enabled) Reset => Bw = None => Clears grid => enable grid and Done
	const span = currentScript.parentElement
	const doneBtn = document.getElementById('done-btn');
	const editBtn = document.getElementById('edit-btn');
	const resetBtn = document.getElementById('reset-btn');
	
	editBtn.disabled = true;

	function rotateLists(l1, l2, l3, rot) {
	    for (let i = 0; i < rot; i++) {
	        l1.unshift(l1.pop());
	        l2.unshift(l2.pop());
	        l3.unshift(l3.pop());
	    }
	}
	
	function generateBoundaryWord() {
	    const btns = document.querySelectorAll('.button');
	    const bw = [];
	    let border = ['left', 'top', 'right', 'bottom'];
	    let letters = ['u', 'r', 'd', 'l'];
	    let shifts = [-1, -10, 1, 10];
	
	    // Find the startBtn (top and/or leftmost clicked button)
	    let startBtnIdx = null;
	    for (let i = 0; i < btns.length; i++) {
	        if (btns[i].classList.contains('clicked')) {
	            if (startBtnIdx === null ) {startBtnIdx = i;}
				else if (~~(i / 10) === ~~(startBtnIdx / 10)) {
					// We have the top-leftmost
					rotateLists(border, letters, shifts, 1);
					break;
				} else  {
					break;
				}
	        }
	    }
	
	    let crntBtnIdx = startBtnIdx;
		console.log("current idx : " + crntBtnIdx);
	    do {
	        for (let i = 0; i < 4; i++) {
	            if (!btns[crntBtnIdx].classList.contains(border[i])) {
					// if there is a border on the border[i] side
					console.log("Border on " + border[i]);
	                bw.push(letters[i]);
	            } else {
					console.log("No Border on " + border[i]);
	                crntBtnIdx += shifts[i];
					console.log("current idx : " + crntBtnIdx);
	                rotateLists(border, letters, shifts, (5 - i) % 4);
					console.log("------------------");
	                break;
	            }
	        }
	    } while (crntBtnIdx !== startBtnIdx);
	
	    const boundaryWordString = bw.join('');
	    console.log("Boundary Word: " + boundaryWordString);
	    return boundaryWordString;
	}

	function disableGrid(flag) {
			const buttons = document.querySelectorAll('.button');
			buttons.forEach(btn => btn.disabled = flag);
	}

	function fillPolyomino(flag) {
			const buttons = document.querySelectorAll('.button');
			if (flag){
				buttons.forEach(btn => {
					if (btn.classList.contains('clicked')) {
						btn.classList.toggle('fill-red');
					}
			});
			}else{
				buttons.forEach(btn => {
					if (btn.classList.contains('fill-red')) {
						btn.classList.remove('fill-red');
					}
				});
			}
	}

	function clearGrid() {
		const buttons = document.querySelectorAll('.button');
		buttons.forEach(btn => {
			btn.classList.remove('top');
			btn.classList.remove('bottom');
			btn.classList.remove('left');
			btn.classList.remove('right');
			btn.classList.remove('clicked');
		});
	}

	function handleDoneClick() {
		// Checks for legal polyomino
		let bw = generateBoundaryWord()
		if ( bw !== null) {
			// Sending the BoundaryWord back to pluto
			span.value = bw;
			span.dispatchEvent(new CustomEvent("input"));
			fillPolyomino(true);
			disableGrid(true);
			doneBtn.disabled = true;
			editBtn.disabled = false;
		}
	}
	
	function handleEditClick() {
		if (doneBtn.disabled) {
			span.value = null;
			span.dispatchEvent(new CustomEvent("input"));
			// Enable grid
			fillPolyomino(false);
			disableGrid(false);
			doneBtn.disabled = false;
			editBtn.disabled = true;
		}
	}
	
	function handleResetClick() {
		span.value = null;
		span.dispatchEvent(new CustomEvent("input"));
		clearGrid()
		fillPolyomino(false);
		disableGrid(false);
		doneBtn.disabled = false;
		editBtn.disabled = true;
	}

	doneBtn.onclick = function() {handleDoneClick();};
	editBtn.onclick = function() {handleEditClick();};
	resetBtn.onclick = function() {handleResetClick();};
</script>
</span>
""")

# ╔═╡ d1ae79ec-4058-4858-915e-54a7a9094d85
boundaryWord

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

# ╔═╡ 5592d3ff-30a3-4be7-9ce6-3894ef76c79d
function tθ(letter::Char, θ::Int64)
	@assert θ % 90 == 0

	rot = (θ ÷ 90) % 3
	idx = mod1(indexof(letter) + rot, length(ALPHABET))
	
	ALPHABET[idx]
end

# ╔═╡ 556054b0-23e5-4bef-8356-ffdbb99cdcd2
complement(letter::Char) = tθ(letter, 180)

# ╔═╡ fe33290c-b27c-48bd-8aee-b6f3cd6a5184
complement(word::String) = complement.(word)

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

# ╔═╡ 642e20fa-5582-418b-ae66-7ec493209736
backtrack(word::String) = complement(reverse(word))

# ╔═╡ 3f57a6c8-d02d-4c29-8b0d-4e8871f60900
md"## Notebook related"

# ╔═╡ e32b500b-68b1-4cea-aac5-f6755cfcc5b6
TableOfContents()

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
HypertextLiteral = "~0.9.5"
PlutoUI = "~0.7.52"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.3"
manifest_format = "2.0"
project_hash = "98f4f9b67ee4d67da87eae57a18fa4e682f2e721"

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
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

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
# ╟─45d3575a-c887-435c-84be-a26284ee5dcb
# ╟─6d4c526e-4d62-4d4c-88ca-728ea6b4fbf6
# ╟─8b41e978-f9cf-4515-9141-cbf8130521d9
# ╠═d1ae79ec-4058-4858-915e-54a7a9094d85
# ╟─c1587642-84ed-459f-855d-fdd07ac3f761
# ╟─151513d3-6b7b-4e0f-ad35-3a0fd3f9c905
# ╟─5751c86d-ca45-4788-b0e2-5fee73595720
# ╟─852453e2-2802-4e2a-9614-accb986bc8e7
# ╟─9f2236ba-0e22-4425-a951-6cc6ceed7520
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
# ╟─3f57a6c8-d02d-4c29-8b0d-4e8871f60900
# ╠═49735ec6-6b0e-4e8e-995c-cc2e8c41e625
# ╠═c84c3cfb-46df-4d5a-93c3-4e34be505488
# ╠═e32b500b-68b1-4cea-aac5-f6755cfcc5b6
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
