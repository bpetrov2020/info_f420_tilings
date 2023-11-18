### A Pluto.jl notebook ###
# v0.19.26

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

# ╔═╡ 86325fcc-348c-4108-bf77-3555a6fc243c
begin
	using Base.Iterators
	using PlutoTest
	using HypertextLiteral
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
		const validIndices = neighborIndices.filter(idx => 
		idx[0] >= 0 && 
		idx[0]< buttons.length &&
		(idx[0] == buttonIndex - 10 ||
		idx[0] == buttonIndex + 10 ||
		(idx[0] == buttonIndex - 1 && ~~(idx[0] / 10) == ~~(buttonIndex/ 10)) ||
		(idx[0] == buttonIndex + 1 && ~~(idx[0] / 10) == ~~(buttonIndex/ 10))
		));
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
	const span = currentScript.parentElement;
	const doneBtn = document.getElementById('done-btn');
	const editBtn = document.getElementById('edit-btn');
	const resetBtn = document.getElementById('reset-btn');
	var btns = document.querySelectorAll('.button');

	editBtn.disabled = true;

	function rotateLists(l1, l2, l3, rot) {
	    for (let i = 0; i < rot; i++) {
	        l1.unshift(l1.pop());
	        l2.unshift(l2.pop());
	        l3.unshift(l3.pop());
	    }
	}

	function getSizeOfBoundary() {
		let total = 0;
		let clickedBtns = document.querySelectorAll('.button.clicked');
		clickedBtns.forEach(btn => {
			let boundary = 4;
			if (btn.classList.contains('top')) { boundary--; }
			if (btn.classList.contains('bottom')) { boundary--; }
			if (btn.classList.contains('left')) { boundary--; }
			if (btn.classList.contains('right')) { boundary--; }
			total = total + boundary;
		});
		console.log("total size: " + total);
		return total;
	}

	function findStartBtn() {
		// Find the startBtn (top and/or leftmost clicked button)
	    let startBtnIdx = null;
		let rotate = false;
	    for (let i = 0; i < btns.length; i++) {
	        if (btns[i].classList.contains('clicked')) {
	            if (startBtnIdx === null ) {startBtnIdx = i;}
				else if (~~(i / 10) === ~~(startBtnIdx / 10)) {
					if((startBtnIdx + 10 < btns.length) && (!btns[startBtnIdx + 10].classList.contains('clicked'))) {
						console.log("start from botttom of lefttop:" + startBtnIdx);
						rotate = true;
						break;
					}
				} else {
					console.log("start from left of lefttop:" + startBtnIdx);
					break;
				}
	        }
	    }
		return [startBtnIdx, rotate];
	}

	function generateBoundaryWord(sizeOfBoundary) {
		let border = ['left', 'top', 'right', 'bottom'];
		let letters = ['u', 'r', 'd', 'l'];
		let shifts = [-1, -10, 1, 10];
		let btns = document.querySelectorAll('.button');
	    const bw = [];
		let visitedBoundaries = 0;
		let startRotate = findStartBtn();
	    let crntBtnIdx = startRotate[0];
		if (startRotate[1]){rotateLists(border, letters, shifts, 1);}
		do {
			for (let i = 0; i < 4; i++) {
	            if (!btns[crntBtnIdx].classList.contains(border[i])) {
					// if there is a border on the border[i] side
	                bw.push(letters[i]);
					visitedBoundaries++;
					if (visitedBoundaries >= sizeOfBoundary){break;}
	            } else {
	                crntBtnIdx += shifts[i];
	                rotateLists(border, letters, shifts, (5 - i) % 4);
	                break;
	            }
	        }
		} while (visitedBoundaries < sizeOfBoundary);

	    const boundaryWordString = bw.join('');
	    console.log("Boundary Word: " + boundaryWordString);
	    return boundaryWordString;
	}

	function disableGrid(flag) {
			btns.forEach(btn => btn.disabled = flag);
	}

	function fillPolyomino(flag) {
			const btns = document.querySelectorAll('.button');
			if (flag){
				btns.forEach(btn => {
					if (btn.classList.contains('clicked')) {
						btn.classList.toggle('fill-red');
					}
			});
			}else{
				btns.forEach(btn => {
					if (btn.classList.contains('fill-red')) {
						btn.classList.remove('fill-red');
					}
				});
			}
	}

	function clearGrid() {
		btns.forEach(btn => {
			btn.classList.remove('top');
			btn.classList.remove('bottom');
			btn.classList.remove('left');
			btn.classList.remove('right');
			btn.classList.remove('clicked');
		});
	}



	function getNeighbors(buttonIndex) {
		const neighbors = [];

		// Get Left, Right, Top and Bottom Neighbour
		const neighborIndices = [buttonIndex - 1
								,buttonIndex + 1
								,buttonIndex - 10
								,buttonIndex + 10];

		const validIndices = neighborIndices.filter(idx => 
		idx >= 0 && 
		idx < btns.length &&
		(idx == buttonIndex - 10 ||
		idx == buttonIndex + 10 ||
		(idx == buttonIndex - 1 && ~~(idx / 10) == ~~(buttonIndex/ 10)) ||
		(idx == buttonIndex + 1 && ~~(idx / 10) == ~~(buttonIndex/ 10))
		));

		validIndices.forEach(idx => neighbors.push(idx));
		return neighbors;
	}

	function isOnGridBorder(idx) {
		let line = ~~(idx / 10)
		let collumn = idx % 10
		if(line === 0 || line === 9 || collumn === 0 || collumn=== 9) {return true;}
		else {return false;}
	}

	function dfs(i, visited, flag) {
		let neigh = getNeighbors(i);
		for (let j = 0; j < neigh.length; j++) {
			if (flag){
				if(!btns[neigh[j]].classList.contains('clicked') && visited[neigh[j]] === 0) {
					visited[neigh[j]] = 1;
					dfs(neigh[j], visited, true);
				}
			} else {
				if(btns[neigh[j]].classList.contains('clicked') && visited[neigh[j]] === 0) {
					visited[neigh[j]] = 1;
					dfs(neigh[j], visited, false);
				}
			}
		}
	}

	function checkNoHoles() {
		//Any non-clicked button should have a non-clicked relative on grids border
		let visited = Array(100).fill(0);
		for (let i = 0; i < 100; i++) {
			if (visited[i] === 0 && isOnGridBorder(i) && !btns[i].classList.contains('clicked')){
				visited[i] = 1;
				dfs(i, visited, true);
			}
		}

		for (let i = 0; i < 100; i++) {
			if (!btns[i].classList.contains('clicked') && visited[i] === 0) {
				console.log("Hole found : " + i);
				return false;
			}
		}
		return true;
	}

	function checkNoIslands() {
		let visited = Array(100).fill(0);
		for (let i = 0; i < 100; i++) {
			if (visited[i] === 0 && btns[i].classList.contains('clicked')){
				visited[i] = 1;
				dfs(i, visited, false);
				break;
			}
		}
		for (let i = 0; i < 100; i++) {
			if (btns[i].classList.contains('clicked') && visited[i] === 0) {
				console.log("Island found : " + i);
				return false;
			}
		}
		return true;
	}

	function checkNotEmpty() {
		let notEmpty = false;
		for (let i = 0; i < 100; i++) {
			if (btns[i].classList.contains('clicked')) {
				notEmpty = true;
				break;
			}
		}
		if (!notEmpty) {console.log("Empty grid !");}
		return notEmpty;
	}

	function checkPolyomino() {
		let cnh = checkNoHoles();
		let cni = checkNoIslands();
		let notEmpty = checkNotEmpty();
		return (cnh && cni && notEmpty);
	}

	function handleDoneClick() {
		if (!checkPolyomino()) {
			console.log("Illegal polyomino");
			span.value = "Illegal polyomino";
			span.dispatchEvent(new CustomEvent("input"));
			return;
		}
		let sizeOfBoundary = getSizeOfBoundary();
		let bw = generateBoundaryWord(sizeOfBoundary);
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
md"""
Boundary word of Polyomino $P$, $𝐁(P)$= "$boundaryWord"

"""

# ╔═╡ 2bb6b38f-c1be-431e-a383-aa3604148c54
md"""
Size of square $(@bind UNIT Slider(5:20))
"""

# ╔═╡ 2c07967f-fd4e-4335-af4e-0fbc0313c134
md"""
Pan by x = $(@bind xpan Scrubbable(0:10:600)) and y = $(@bind ypan Scrubbable(0:10:300))
"""

# ╔═╡ ea3b3a3c-3fbd-4f0a-8410-c012ebb32bed
boundary_word = boundaryWord == nothing ? "" : boundaryWord

# ╔═╡ c1587642-84ed-459f-855d-fdd07ac3f761
md"## Theoretical explanations"

# ╔═╡ 9f2236ba-0e22-4425-a951-6cc6ceed7520
md"# Appendix A: code"

# ╔═╡ 18389ab9-4fc4-49f4-9bc9-b855b7c16232
md"""
## Tiling drawing
"""

# ╔═╡ ee001f50-0809-4272-86fb-727fd0fdb654
const Point = Tuple{Int64, Int64}

# ╔═╡ a0c1f409-c98a-40fb-aee9-93ce587c508e
const Vec2D = Tuple{Int64, Int64}

# ╔═╡ e25055d1-4ff6-4a2b-a915-4c5c34a44aec
const Polygon = Vector{Point}

# ╔═╡ 53eb421e-3f88-4789-b077-9e283d76a3c7
const DIR = [
	( 1,  0),
	( 0, -1),
	(-1,  0),
	( 0,  1)
]

# ╔═╡ 7357539a-0888-4cf9-87d4-f03cf9063dd5
translate(points, vec) = map(p -> p .+ vec, points)

# ╔═╡ 2543a64f-f45a-4881-bcde-98aa94b30a58
scale(points, scalar) = map(p -> p .* scalar, points)

# ╔═╡ 15b49802-11c5-420d-8227-01555b99de2d
md"""
## Factorizations
"""

# ╔═╡ 092d59e2-d814-48e5-87ca-db6fdfbbe934
md"### Constants"

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
md"### Helper functions"

# ╔═╡ ad8103a2-e5c9-4d9e-bd41-2e1e6b3e6d40
indexof(letter::Char) = findfirst(x -> x == letter, ALPHABET)

# ╔═╡ 1d99edae-0c8f-465a-bc22-198433d38e95
"""
	path_points(path::String)::Polygon

Sequence of points traversed on `path`, starting at `(0, 0)`.
"""
function path_points(path::String)::Polygon
	foldl(path; init=[(0, 0)]) do pts, move
		push!(pts, pts[end] .+ DIR[indexof(move)])
	end
end

# ╔═╡ 06a216bd-e3c0-4561-a0bc-31d86aebd783
@test path_points("urrdl") == [
	(0,  0),
	(0, -1),
	(1, -1),
	(2, -1),
	(2,  0),
	(1,  0)
]

# ╔═╡ ee24888e-2f89-4400-bd83-8caa73884c64
"""
	generate_tiling(word::String, size::Integer, transforms)::Vector{Polygon}

Generate tiling of polygon described by `word`, of depth `size` and using the `transforms`. These last must be functions on sets of points, such as translations, rotations, etc. They depend on the factorization.
"""
function generate_tiling(word::String, size::Integer, transforms)::Vector{Polygon}
	polygons = []
	pending = [(0, path_points(word))]

	while !isempty(pending)
		depth, curr = popfirst!(pending)
		while curr ∈ polygons
			depth, curr = popfirst!(pending)
		end
		
		push!(polygons, curr)
		for transform ∈ transforms
			next = transform(curr)
			next_depth = depth + 1
			if !(next ∈ polygons) && next_depth ≤ size
				push!(pending, (next_depth, next))
			end			
		end
	end

	polygons
end

# ╔═╡ 603531e5-59d0-4be9-b6e9-37929f5afd06
"""
	path_vector(path::String)::Vec2D

Vector from start to end of path, starting at `(0, 0)`.
"""
function path_vector(path::String)::Vec2D
	foldl((v, m) -> v .+ DIR[indexof(m)], path; init=(0, 0))
end

# ╔═╡ 2868538a-ee1f-43ac-af62-6603ffff459d
@test path_vector("ururdddl") == (1, 1)

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

# ╔═╡ 9dac7d76-e344-4cce-bedd-ae6cb4bec111
const Factorization = Vector{Factor}

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
# ╠═╡ disabled = true
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
	double_word = twice(word)
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
		R = common_prefix(double_word[fwd_idx:end], backtracked[bwd_idx:end])

		fwd_idx = diametral_opposite
		bwd_idx = backed(center)
		L = common_prefix(double_word[fwd_idx:end], backtracked[bwd_idx:end])

		if length(R) == length(L) && !isempty(L)
			start = s(center - length(L) + 1)
			finish = s(center + length(R) - 1)
			push!(factors, factor(word, start, finish))
		end
	end

	# With center of size 2
	for i ∈ 1:length(word)
		l_center = i
		r_center = s(i + 1)

		opposite_l_center = s(length(word) ÷ 2 + l_center + 1)
		opposite_r_center = opposite_l_center - 1

		fwd_idx = r_center
		bwd_idx = backed(opposite_r_center)
		R = common_prefix(double_word[fwd_idx:end], backtracked[bwd_idx:end])

		fwd_idx = opposite_l_center
		bwd_idx = backed(l_center)
		L = common_prefix(double_word[fwd_idx:end], backtracked[bwd_idx:end])

		if length(R) == length(L) && !isempty(L)
			start = s(r_center - length(L))
			finish = s(l_center + length(R))
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
#admissible_factors("urrrdlll")
admissible_factors("rrddrurddrdllldldluullurrruluu")
#admissible_factors("ururdrrdldllul")

# ╔═╡ 830056cc-efb4-4305-9a69-4f19138eb6db
"""
Expand half BN factorizations to full ones.
"""
function expand(factors::Vector{Factor}, word_length::Integer)::Vector{Factor}
	half_length = word_length ÷ 2
	s(idx) = mod1(idx, word_length)

	forward = factors
	backward = map(factors) do factor
		content = backtrack(factor.content)
		start = s(factor.start + half_length)
		finish = s(factor.finish + half_length)
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

# ╔═╡ cc4b08a6-f419-4af4-8c5b-dd779ea2ed7a
const factorization = try
	something(bn_factorization(boundaryWord))
catch e
	nothing
end

# ╔═╡ 3cf3931b-5c2e-4efa-a5ef-2a485eac2c0c
try
	if factorization != nothing
		md"There exists a BN factorization for this word!"
	else
		md"There doesn’t exist a BN factorization for this word…"
	end
catch e
	md"Enter a valid polyomino to evaluate it for a BN factorization."
end

# ╔═╡ b77fe1fc-86f1-4226-8316-75862f5a2c76
bn_factorization("rrddrurddrdllldldluullurrruluu")

# ╔═╡ a2c420e4-759f-48da-bc59-ffa568e1b23f
bn_factorization("ururdrrdldllul")

# ╔═╡ 388568b4-2319-4ef6-98f1-306223d2dc41
bn_factorization("urdrrdldllulur")

# ╔═╡ 7736febe-6492-4a3e-8bd4-3fcf590fe6fc
"""
	translation_vectors(word::String, fact::Factorization)::Vector{Vec2D}

Given a word and its BN factorization, give the vectors to the adjacent tiles in a tiling.
"""
function translation_vectors(word::String, fact::Factorization)::Vector{Vec2D}
	hf = length(fact) ÷ 2

	start = fact[1].start
	finish = fact[hf + 1].finish
	u = path_vector(extract(word, start, finish))

	start = fact[2].start
	finish = fact[hf + 2].finish
	v = path_vector(extract(word, start, finish))
	
	@. [u, v, v - u, -u, -v, u - v]
end

# ╔═╡ f5ee1318-b1a2-4cdc-a459-29d98b8d804e
"""
	bn_transformations(word::String, fact::Factorization)

Get translation vectors for a BN factorization as transformations. Useful for `generate_tiling`.
"""
function bn_transformations(word::String, fact::Factorization)
	vecs = translation_vectors(word, fact)
	map(v -> (pts -> translate(pts, v)), vecs)
end

# ╔═╡ a058e454-1da6-4882-b1b7-f48e9555378f
transforms = bn_transformations(boundary_word, factorization)

# ╔═╡ acc326a5-a4a2-44e7-8ca8-90214d0247bf
tile_polygons = generate_tiling(boundary_word, 20, transforms)

# ╔═╡ 83673640-43fd-4fdb-9757-b603f946d8a2
tiling = map(poly -> translate(poly, (xpan, ypan)), scale.(tile_polygons, UNIT))

# ╔═╡ d963c97a-d24f-4ff0-a3d8-c810e1f55b6c
@htl("""
<script src="https://cdn.jsdelivr.net/npm/d3@6.2.0/dist/d3.min.js"></script>

<script id="drawing">

// const svg = this == null ? DOM.svg(600,300) : this
// const s = this == null ? d3.select(svg) : this.s
const svg = DOM.svg(680, 300)
const s = d3.select(svg)

const line = d3.line()
let data = $tiling

data.forEach((polygon) => {
	s.append("path")
		.attr("d", line(polygon))
		.attr("stroke", "black")
		.attr("fill", "white")
})

const output = svg
output.s = s
return output

</script>

""")

# ╔═╡ 3f57a6c8-d02d-4c29-8b0d-4e8871f60900
md"## Notebook related"

# ╔═╡ e32b500b-68b1-4cea-aac5-f6755cfcc5b6
TableOfContents()

# ╔═╡ 985b959d-038e-4d05-85e7-2f2ca0ab2001
md"""
# Appendix B: Authors

- **Edem Lawson**: polyomino builder
- **Boris Petrov**: site setup, BN factorization, tilings drawing

"""

# ╔═╡ 46f79b8e-6c46-4499-9331-360c83096da5
md"""
# References
"""

# ╔═╡ 9e09d9bc-78d9-431c-952f-f42e98dbeb90
md"""
- [1] S. Langerman and A. Winslow, “A Quasilinear-Time Algorithm for Tiling the Plane Isohedrally with a Polyomino.” arXiv, Mar. 09, 2016. doi: 10.48550/arXiv.1507.02762.
- [2] A. Winslow, “An Optimal Algorithm for Tiling the Plane with a Translated Polyomino.” arXiv, Sep. 22, 2015. doi: 10.48550/arXiv.1504.07883.
- [3] S. Brlek, X. Provençal, and J.-M. Fédou, “On the tiling by translation problem,” Discrete Applied Mathematics, vol. 157, no. 3, pp. 464–475, Feb. 2009, doi: 10.1016/j.dam.2008.05.026.

"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
PlutoTest = "cb4044da-4d16-4ffa-a6a3-8cad7f73ebdc"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
HypertextLiteral = "~0.9.5"
PlutoTest = "~0.2.2"
PlutoUI = "~0.7.52"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.3"
manifest_format = "2.0"
project_hash = "1d21cefe31ea90f587d2d2e16ab29c4b55dd4464"

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
# ╟─6d4c526e-4d62-4d4c-88ca-728ea6b4fbf6
# ╟─8b41e978-f9cf-4515-9141-cbf8130521d9
# ╟─d1ae79ec-4058-4858-915e-54a7a9094d85
# ╟─3cf3931b-5c2e-4efa-a5ef-2a485eac2c0c
# ╟─cc4b08a6-f419-4af4-8c5b-dd779ea2ed7a
# ╟─2bb6b38f-c1be-431e-a383-aa3604148c54
# ╟─2c07967f-fd4e-4335-af4e-0fbc0313c134
# ╟─d963c97a-d24f-4ff0-a3d8-c810e1f55b6c
# ╟─ea3b3a3c-3fbd-4f0a-8410-c012ebb32bed
# ╟─a058e454-1da6-4882-b1b7-f48e9555378f
# ╟─acc326a5-a4a2-44e7-8ca8-90214d0247bf
# ╟─83673640-43fd-4fdb-9757-b603f946d8a2
# ╟─c1587642-84ed-459f-855d-fdd07ac3f761
# ╟─9f2236ba-0e22-4425-a951-6cc6ceed7520
# ╠═86325fcc-348c-4108-bf77-3555a6fc243c
# ╟─18389ab9-4fc4-49f4-9bc9-b855b7c16232
# ╟─ee001f50-0809-4272-86fb-727fd0fdb654
# ╟─a0c1f409-c98a-40fb-aee9-93ce587c508e
# ╟─e25055d1-4ff6-4a2b-a915-4c5c34a44aec
# ╟─53eb421e-3f88-4789-b077-9e283d76a3c7
# ╟─7357539a-0888-4cf9-87d4-f03cf9063dd5
# ╟─2543a64f-f45a-4881-bcde-98aa94b30a58
# ╟─1d99edae-0c8f-465a-bc22-198433d38e95
# ╟─06a216bd-e3c0-4561-a0bc-31d86aebd783
# ╟─603531e5-59d0-4be9-b6e9-37929f5afd06
# ╟─2868538a-ee1f-43ac-af62-6603ffff459d
# ╟─ee24888e-2f89-4400-bd83-8caa73884c64
# ╟─15b49802-11c5-420d-8227-01555b99de2d
# ╟─092d59e2-d814-48e5-87ca-db6fdfbbe934
# ╟─3a0b058e-6921-4375-b514-7a05f19a26bb
# ╟─473faf5a-8152-44b7-b3f3-265a87d89391
# ╟─3ce45f35-0ef0-4e87-a20c-7f72c03251df
# ╟─5754ff07-4a06-40eb-b15e-9e1a2f135395
# ╟─dab01fba-d85b-4956-94c4-b8d2a6933165
# ╟─9fd065ab-df8e-4058-b84a-d8824cfd60cc
# ╟─ad8103a2-e5c9-4d9e-bd41-2e1e6b3e6d40
# ╟─5592d3ff-30a3-4be7-9ce6-3894ef76c79d
# ╟─556054b0-23e5-4bef-8356-ffdbb99cdcd2
# ╟─fe33290c-b27c-48bd-8aee-b6f3cd6a5184
# ╟─24c55137-7470-4b2a-9948-9e4ec23aa11c
# ╟─642e20fa-5582-418b-ae66-7ec493209736
# ╟─291e04ef-a5dd-4cd2-a598-f2256e6643e0
# ╟─3e4a972f-6b44-41a6-91d2-3f949b9b7004
# ╠═70fba921-5e52-4b04-84e0-397087f0005c
# ╟─9dac7d76-e344-4cce-bedd-ae6cb4bec111
# ╟─cd430387-c391-4360-921b-3ca958a70d47
# ╟─cd7d4c8f-b910-4b9f-95a5-0054c0e01ee7
# ╟─5c94888b-2196-4124-b731-8d74b19c3f76
# ╠═5c3bc705-0500-42ae-abce-a2e2da6f06fe
# ╟─19742340-925a-49cf-b2dd-109201492bb2
# ╟─e9d30d5f-1ef9-4d9b-9a88-7475907faf3a
# ╟─78ea5c1f-1212-430c-811e-456a3542358e
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
# ╟─f5cc61b3-b844-48d7-898b-4206506c0dae
# ╟─0ea45964-96b7-438c-a47a-609e4cd4fed0
# ╟─8d84c5dd-8c7d-456c-88fb-91d5a787846a
# ╟─830056cc-efb4-4305-9a69-4f19138eb6db
# ╟─99d849e7-f9cc-4ab8-af5a-dce0bc1f8543
# ╠═b77fe1fc-86f1-4226-8316-75862f5a2c76
# ╠═a2c420e4-759f-48da-bc59-ffa568e1b23f
# ╠═388568b4-2319-4ef6-98f1-306223d2dc41
# ╟─7736febe-6492-4a3e-8bd4-3fcf590fe6fc
# ╟─f5ee1318-b1a2-4cdc-a459-29d98b8d804e
# ╟─3f57a6c8-d02d-4c29-8b0d-4e8871f60900
# ╠═49735ec6-6b0e-4e8e-995c-cc2e8c41e625
# ╠═e32b500b-68b1-4cea-aac5-f6755cfcc5b6
# ╟─985b959d-038e-4d05-85e7-2f2ca0ab2001
# ╟─46f79b8e-6c46-4499-9331-360c83096da5
# ╟─9e09d9bc-78d9-431c-952f-f42e98dbeb90
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
