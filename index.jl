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
md"# Polyominoes tilings"

# ╔═╡ 5da0ce50-d477-4f7d-8ec1-010d8f5fc902
md"## Introduction"

# ╔═╡ 870e528d-678e-497e-893d-72d3b7b0eab0
md"""
Polygons are of the most basic building blocks in computational geometry. Many areas of study exist, including intersections and triangulations among others. One such area of study is that of _tesselations_ (or _plane tilings_).

Given a set of polygons $P$, can we fill the entire plane with copies of $p∈P$ so that no portion of the plane is left uncovered and with no overlapping. That is, can we put copies of the polygons next to each other without leaving gaps in between. This innocent-looking problem turns out to be a very difficult one.

For this problem, even polygons are much too complex to reason with. However, we may impose constraints on both the kind of tiling and the types of polygons that are used to create easier problems and perhaps grasp at a solution. We present here a version using only one _polyomino_ and in the context of _isohedral_ tilings.

A _polyomino_ is a polygon formed of glued-together unit-length squares with no inner holes. Whereas a tiling is said to be _isohedral_, if any two copies can be mapped to one another. Intuitively, it means that the tiling is locally similar, that is, taking any two copies and considering their neighbourhood, we cannot distinguish them from from one another.
"""

# ╔═╡ 13b287d8-6340-4570-9f7c-ed9eab4bdd2c
md"""
Here’s an example showing two tesselations of the plane with polyominoes. Both use only one shape, but only the second one is isohedral. In the first, only shapes of the same color may be mapped to one another.
"""

# ╔═╡ 306500a9-e4de-4ae8-a05b-57e768202170
PlutoUI.Resource(
	"https://upload.wikimedia.org/wikipedia/commons/thumb/1/17/Conway_criterion_false_negative_nonominoes.svg/1024px-Conway_criterion_false_negative_nonominoes.svg.png",
	:height => 350,
	:style => "margin: 0px auto 0px; display:block;"
)

# ╔═╡ f0942786-6415-4d2b-a41a-aa06d250f798
md"""
_Credits: Wikipedia_
"""

# ╔═╡ 45d3575a-c887-435c-84be-a26284ee5dcb
md"## Interactive showcase"

# ╔═╡ 3a52dfb0-ae3f-48a7-87ff-c456db61fe15
md"""
Before delving into the theoretical explanations of how we determine whether a polyomino can tile the plane, we propose first an interactive activity. The grid right below is a _polyomino builder_ and allows you to create your very own polyomino. You can click on the squares to add them to your polyomino and, once finished, hit the ‘Done’ button and see whether your polyomino can tile the plane!

This can be thought as a game in which you must guess whether the polyomino can tile the plane, before verifying your intuition. Have fun and try to find the most esoteric polyominoes tiling the plane!

> The notebook must be run in order to use the interactive elements.
"""

# ╔═╡ 6802038f-0d12-455e-9df6-875a11c0f7d3
md"""
### Polyomino Builder
"""

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
		border: 3px solid #FF7562;
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
		background-color: #FF7562;
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
		background-color: #83BF8A; 
	}
	
	.cmd-button:nth-child(2) {
		background-color: #5C8CCD; 
	}
	
	.cmd-button:nth-child(3) {
		background-color: #FF7562;
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
	var sizeOfBoundary = -1;

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

	function generateBoundaryWord() {
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
		sizeOfBoundary = getSizeOfBoundary();
		let bw = generateBoundaryWord();
		if ( bw !== null) {
			// Sending the BoundaryWord back to pluto
			span.value = bw;
			console.log(span.value);
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

# ╔═╡ 1544010c-9a45-4ea3-ab0a-6ffe24648ec8
md"""
### Plane Tiling
"""

# ╔═╡ c1587642-84ed-459f-855d-fdd07ac3f761
md"## Theoretical explanations"

# ╔═╡ 27aa8b5d-bb9c-493f-b256-8503c8d4177d
md"""
The problem may seem daunting at first since the plane is infinite and there are possibly infinitely many ways to arrange an infinite set of polyominoes, however, we shall note two things: first, we are only interested in whether there exists a tiling, and not in enumerating every tiling possible, and second since the tilings we study are isohedral, we may restrict ourselves to only the direct neighbourhood of one polyomino.

The last fact arises from the definition of isohedral, that is, in such a tiling we can map any polyomino of the plane to another by a set of transformations of the plane. For this to be possible, every polyomino must have the same neighbourhood as any other, otherwise the property would not hold. We can say that the plane must be locally congruent.

This is great news, we have reduced our problem of tiling the plane, to one of arranging copies of the polyomino around itself. We could think that finding a neighbourhood that leaves no gaps would solve the problem since we could just apply the same neighbourhood to each copy, however, this is not the case.
"""

# ╔═╡ 462623f2-1968-4fe5-89af-c9fbcdd5b49a
md"""
The following example shows a surrounding that leaves no gaps, yet doesn’t produce an isohedral tiling. We can convince ourselves by looking at the green and the red polyominoes. The red one has its notch filled by the short tail of the polyomino, which is not the case for the green one. Therefore, we cannot map the red one to the green one, and this cannot produce an isohedral tiling.
"""

# ╔═╡ 81196bee-bee2-4788-bf5f-3f60f7e668df
PlutoUI.Resource("https://i.imgur.com/p9v4oPn.png", :height => 200, :style => "margin: 0px auto 0px; display:block;")

# ╔═╡ 9e4e8ab1-dd18-4bc2-baac-9daece06905a
md"""
Fortunately, a set of configurations that produce isohedral tilings were established by previous papers [4] and [5]. They treat of general polygons, but since polyominoes are special cases, most are applicable here. Tough with our constrained problem, not all are possible. Eventually, we end up with 7 characterisations of the neighbourhood that determine whether an isohedral tiling exist. These configurations are called _boundary criteria_. The term will become clear in the next section.
"""

# ╔═╡ 3878e012-c80d-4b93-af22-901187b933d8
md"""
### Polyominoes as words
"""

# ╔═╡ aefb27b5-4d65-436d-8f5b-093473e7e3fb
md"""
One way to see the boundary of one polyomino is as one sees a polygon, that is as a set of points connected and separating a region of the plane. However, this is not very convenient to study them. Another way is that of the _boundary word_. Since all edges are either vertical or horizontal, and the lengths of the edges are integers (say one unit square is of size 1), we can picture the polyominoes as a sequence of instructions to build them.

The alphabet would be $Σ = \{r, u, l, d\}$ for the four directions (right, up, left, down). We then choose an arbitrary extremity $e$, and enurate the moves to walk along the boundary in clockwise order and get back to $e$. Here’s an example to better understand how it works:
"""

# ╔═╡ 8c471070-7629-4957-821f-61b50d52e936
PlutoUI.Resource("https://i.imgur.com/ITfAT1N.png", :height => 200, :style => "margin: 0px auto 0px; display:block;")

# ╔═╡ 917a93f6-153f-4eac-a740-04ee407a21a6
md"""
The boundary word of the polyomino $P$ right above is $𝑩(P) = rrrdlllu$, starting from the upper left corner. However, we could’ve started from any other point and, for example, $rdlllurr$ is just as valid a word boundary for this polyomino.

The fact that we now work with words instead of polyominoes means that we can use the many results, algorithms and data structures stemming from bioinformatics and general word processing to study our shapes. This is main idea of the paper at hand [1], to use strong structural results to find whether we can, from the word boundary, build one of the 7 factorisations that induce an isohedral tilings. A _factorisation_ is a splitting of the boundary word into subwords.

"""

# ╔═╡ 600d4c07-f5c2-418c-acbb-d6142155e74e
md"""
### Factorisations
"""

# ╔═╡ 556cc741-c004-4ea6-a7ad-8779a59f2962
md"""
Before presenting all possible factorisations, we introduce a few useful notions to understand them. The definitions we given here are more intuitive than formal, and we refer the interested reader to the paper in question [1]. We consider $W$ any word on the alphabet we defined before, not necessarily a boundary word.

If we see words as paths in the plane, the backtrack of $W$, written $\hat{W}$, is the sequence of directions taken if we walk along $W$ starting from the end. Practically, for $W = urrul$ we have $\hat{W} = rdlld$.

A word $W$ is a palindrome if we can place ourselves in the middle of the word and walk forwards and backwards and encounter the same letters in both directions up to the end. In other words, we can cut $W$ in two and the second half is the reverse of the first. The reverse being the letters considered from the end up to the beginning, which is different from the backtrack. As an example, $W = uurrdlldrruu$ is a palindrome whereas $W = urrld$ is not.

Similarly, a word is a 90-drome if we can split it in two and the second half is the result of a clockwise rotation by 90° of the first half in the plane. This being a bit rough, it is best understood with the example below where the 3rd word is 90-drome:

"""

# ╔═╡ 67a35fa9-b56a-467a-a0c7-126832af1b1c
PlutoUI.Resource("https://i.imgur.com/upipjCo.png", :style => "margin: 0px auto 0px; display:block;")

# ╔═╡ 0f69ef6a-831f-4dfe-b755-4016a9e2dd65
md"""
Lastly, the reflection of a word $W$ by $Θ°$, written $f_Θ(W)$, is the result of reflecting each of its letters across a line with angle Θ° from the x-axis. As with the 90-drome, it is better understood with an example. Both words below are a 45° reflection of each other:

"""

# ╔═╡ 177c821a-a75b-44f7-a15e-9dfc061556aa
PlutoUI.Resource("https://i.imgur.com/g3xLjl4.png", :style => "margin: 0px auto 0px; display:block;", :height => "250")

# ╔═╡ 2139c37b-422d-4524-9bf8-e59dbfa105fc
md"""

With this in mind, here are the 7 factorisations that induce a tiling:

- Translation: $ABC\hat{A}\hat{B}\hat{C}$
- Half-Turn: $ABC\hat{A}DE$ with $B$, $C$, $D$, $E$ palindromes
- Quarter-Turn: $ABC$ with $A$ a palindrome and $B$, $C$ 90-dromes
- Type-1 Reflection: $ABf_Θ(B)\hat{A}Cf_Φ(C)$ for some $Θ$, $Φ$
- Type-2 Reflection: $ABC\hat{A}f_Θ(C)f_Θ(B)$
- Type-1 Half-Turn-Reflection: $ABC\hat{A}Df_Θ(D)$ with $B$, $C$ palindromes
- Type-2 Half-Turn-Reflection: $ABCDf_Θ(B)f_Φ(D)$ with $A$, $C$ palindromes and $Θ - Φ = ±90°$
"""

# ╔═╡ 4409958c-8e80-43d5-9758-6a192b9e5a9a
md"""
#### Complexity
"""

# ╔═╡ b9e76e3f-9831-4b04-8870-29605561d189
md"""
A simple and straightforward algorithm to find a suitable factorisation would be a brute force algorithm trying all possible factorisations and checking whether they satisfy the constraints. We could improve the algorithm by introducing pruning and not going down a path if the first constraints are not satisfied. For example, for the _Quarter Turn_, when trying a specific $A$, we would not continue if it is not a palindrome. However, this doesn’t reduce the worst case complexity that is still $𝓞(n^6)$, as it is usually the case with such kinds of algorithms. 
"""

# ╔═╡ 6e95928e-b683-45e6-a4cc-9046420a6166
md"""
The main result of the studied paper however claims that we could decide whether one of these factorisations is possible in quasi-linear time, that is in $𝓞(n \log^2 n)$. Instead of trying all factorisations, it uses various structural results on words, considering them as only strings of characters and not specifically as polyomino boundaries.

The notions used are however quite complex to grasp and understand. Instead of going into the details and ending up copying the paper, we will give a higher level overview and try to build an intuition instead. We refer the reader interested in all the intermediary results and proofs to the original paper.
"""

# ╔═╡ bc4f92d1-59b1-4c6a-bebe-7541d2f3c02c
md"""
#### Tilings from factorisations
"""

# ╔═╡ 9aa159b7-59c3-41ba-a47c-7826f093cf02
md"""
Before diving into the factorisations, we digress a bit with how a tiling is built from a factorisation.

Once a factorisation is found for a given boundary, the induced tiling stems naturally from it. The procedure is very similar for all factorisations, and it consists of identifying the way neighbouring polyominoes should glue to one another according to a set of rules directly derived from the kind of factors identified.

The rules for gluing neighbouring polyominoes to an original polyomino $P$ are as follows:

- a factor $A$ and its backtrack $\hat{A}$: match the $A$ part of a first neighbour to the $\hat{A}$ of $P$, and the $\hat{A}$ of second neighbour to the $A$ of $P$. These neighbours are translations of $P$;
- a palindrome $A$: let $Q$ be a 180° rotation of $P$. Match the corresponding palindrome $A$ in $Q$ to that in $P$. This is valid because that rotation makes the $A$ in $Q$ a backtrack of the $A$ in $P$;
- a 90-drome $A$: the rule is similar to that for palindromes, except the rotation is by $90°$ and only half of the $A$ in the the rotation $Q$ can match the $A$ in $P$. Indeed, the other half will be matched by another neighbour, this time rotated by $-90°$;
- a factor $A$ and its reflection $f_Θ(A)$: let $Q$ this time be the reflection of $P$ along a line forming an angle of $Θ°$ with the $x$ axis. We can glue the $f_Θ(A)$ of $Q$ to the $A$ of $P$. Similarly, with another reflection, we can glue its $A$ to the $f_Θ(A)$ of $P$.

All these rules act only on parts of the boundary, but since we are guaranteed that a tiling exists, there will be no overlapping between neighbours. Perhaps, this is better visualized by showing a tiling of each kind and studying the direct neighbourhood. An example is shown below, with the dots representing the limits of the factors:
"""

# ╔═╡ a803c33f-8c24-4213-ab58-cfeb21bc4470
md"""
#### Translation Factorisation
"""

# ╔═╡ edfcac8e-31bf-427b-92bf-f905750d9952
md"""
> Factorisations of the form $W = ABC\hat{A}\hat{B}\hat{C}$

"""

# ╔═╡ 72a8fbe2-7688-42ea-85fb-2c14fd3cec89
md"""
The efficient algorithm for the translation factorisation comes in reality from a previous paper of one of the authors [2], and lays down the _modus operandi_ used in the later one for the remaining factorisations. It consists of finding useful properties on the factors and using them for an efficient algorithm.
"""

# ╔═╡ ab3e33c2-de7a-4308-aaf0-96a4a376eb5c
md"""
Two results proved in the paper lead to a linear algorithm to detect a translation factorisation. The first is that the number of possible such factorisations of a word $W$ is in $𝓞(n)$. And the second one is that any pair of factors $A$ and $\hat{A}$ in such a factorisation must be maximal, or as the paper defines them _admissible_. This means that these factors are contained in no other such pair of factors and we cannot make $A$ and $\hat{A}$ bigger.

For example, with $W = uurddr$ we could have a valid pair $A_1 =u$ and $\hat{A_1} = d$, but it is not maximal since we could make it bigger by considering $A_2 = uu$ and $\hat{A_2} = dd$. The first is not admissible because it is contained in the second, whereas the second is admissible.
"""

# ╔═╡ f6e375ec-82ae-4f7a-aa8b-1b3ad8b376f3
md"""
With these results, the devised algorithm is as follows. For each letter $l$ in $W$, find the admissible pair such that $l$ lies in the middle of its first half, $A$. This will gather  at most $𝓞(n)$ such pairs, one for each letter. A clever way is then used to combine these admissible factors in order to find all possible factorisations. All operations in this second part are also in $𝓞(n)$ and find all possible factorisations (linearly many). Therefore, the algorithm to find one is also linear.

This is very abridged version of the algorithm, but shows how analyzing the structure and properties of these pairs, called _gapped mirrors_, can yield a much better algorithm than the brute force one.

"""

# ╔═╡ cbc82b85-e756-4955-bc46-2cff64c1a845
md"""
#### Half-Turn Factorisations

"""

# ╔═╡ 704ea723-b649-46c9-9d61-1a6e2eb98e94
md"""
> Factorisations of the form $W = ABC\hat{A}DE$ with $B$, $C$, $D$, $E$ palindromes

"""

# ╔═╡ 16cb1a77-d27f-4f31-93ff-93747be1a286
md"""
Similarly to other factorisations, the _gapped mirror_ comprised of $A$ and $\hat{A}$ as well as the palindromes are admissible. Two other results are useful for the algorithm. The first is that we can in $𝓞(n \log n)$ determine the palindromes starting and ending at each letter of the word. And the second one is that we can gather the admissible palindromes of $W$ in linear time.

Considering these results, the algorithm will sort of consider all pairs of adjacent letters, and see whether an admissible palindrome starts at the second, and another one ends at the first. If that’s the case, we can be in either $BC$ or $DE$. We can then build up the admissible gapped mirror, and finally test whether the remaining part of the word is the concatenation of two admissible palindromes, which can also be verified efficiently. The total running time of the algorithm is in $𝓞(n \log^2 n)$.

This running time makes this factorisation the bottleneck of the procedure. That means that if an improvement can be made to this type of factorisation, then the lower bound of determining whether a polyomino can tile the plane isohedrally can be lowered.
"""

# ╔═╡ 06bdb6ac-20ca-4b8c-881c-29ce38176f47
md"""
#### Quarter-Turn
"""

# ╔═╡ a0bb1aa7-ae77-4964-94dd-109ba4134824
md"""
The quarter-turn factorisation is defined as such:

>A quarter-turn factorisation of a boundary word $W$ has the form:                            $W$ = $ABC$ with $A$ a palindrome and $B$, $C$ 90-dromes.

The claim for this factorisation is:
>Let $P$ be a polyomino with $|𝑩(P)| = n$. It can be decided in $𝓞(n)$ time if $B(P)$ has a quarter-turn factorisation.

The approach of the algorithm is to find factorisations with long palindrome or 90-drome factors separately by guessing the 90-drome factors, given either a long 90-drome factor or the location of the first or last letter of a long palindrome factor.

In this case, it was found that, by pigeonhole principle, a quarter-turn factorisation has at least one long factor of length at least $|W|/3$.

In order to achieve this in linear time we first need to do some preprocess of $W$.
For each letter $i$ in the word $W$, we need to compute a lenght-sorted lists of all admissible:

- 90-dromes that start at $W[i]$
- 90-dromes that end at $W[i]$
- Palindromes with center $W[i]$

>Note: These lists can all be computed in $𝓞(|W|)$ time and are structured such that the longest palindrome for each center can be found in $𝓞(1)$ time. It is also proven that, there are $𝓞(1)$ long 90-dromes, the long palidromes can be summerized by a $𝓞(1)$-sized set of letters and for any letter and that there are $𝓞(\log|W|)$ 90-drome factors that start (or end) at the letter, and thus $𝓞(\log^2 |W|)$ double 90-drome factors that start (or end) at the letter.

To find the factorisations starting from a long 90-drome, we scan through the lists we computed before and extract the $𝓞(1)$ long 90-dromes, then we rescan the list to find and combine the long 90-drome with another one that eiter ends just before or start right after him.
We then have an induced factorisation $W$ = $AD_1D_2$ with $D_1$ and $D_2$ admissible 90-dromes, we then just need to check for all factorisations that contain $D_1$ and $D_2$ wheter $A$ is a palindrome or not. All these operations take a maximum of $𝓞(log^2(W))$ time.

To find the factorisations starting from a long palindrome, we first build, similarily to the first search, the double admissible 90-dromes $D_1D_2$ starting at $W[i + 1]$ with $i$ either the fisrst or last letter of a long palindrome.
This again induces a factorisation $W = AD_1D_2$ (including $|D_2| = 0$) and we can check if $A$ is a long palindrome.
Then we repeat the process for $D_1D_2$ ending at $W[i - 1]$.

All these operations take a maximum of $𝓞(log^3(W))$ time.
The total time complexity is thus well $𝓞(n)$.
"""


# ╔═╡ 0bc986f7-791a-43a4-aeaa-962942d5a424
md"""
#### Type-1 Reflection
"""

# ╔═╡ 24b50179-70be-409e-8e05-98e262a4b59b
md"""
> Factorisations of the form $W = ABf_Θ(B)\hat{A}Cf_Φ(C)$ for some $Θ$, $Φ$

"""

# ╔═╡ 0c781874-bfc8-43a2-99b4-61fe857245b6
md"""
For this one, there are two important structural results to consider. First, all pairs of the form $Af_Θ(A)$, called _reflect squares_, can be enumerated in $𝓞(n \log n)$. And second, all factors in a factorisation of this kind are _admissible_, that is, we cannot make them bigger and still keep their properties.

With these two results, the algorithm consists of first collecting all reflect squares, and then for each of them, find the admissible adjacent pair, $A$ and $\hat{A}$, and test whether the remaining part of the word is also a reflect square. If it is the case, we have found a type-1 reflection factorisation.
"""

# ╔═╡ aa7b9d69-16a0-4e05-96ff-b9ae75d27af7
md"""
#### Type-2 Reflection
"""

# ╔═╡ e99222de-2cde-4b7d-8b7f-5a23c95ca611
md"""
The type-2 Reflection factorisation is defined as such:

> A type-2 reflection factorisation of a boundary word $W$ has the form:  $W=ABCCÂf_Θ(C)f_Θ(B)$ for some $Θ$.

The claim for this factorisation is:
>Let $P$ be a polyomino with $|𝑩(P)| = n$. It can be decided in $𝓞(n)$ time if $𝑩(P)$ has a type-2 reflection factorisation.

The algorithm is divided into two cases, this is because we can say that, for a type-2 reflection factorisation, without loss of generality, either $|A| ≥ |W|/6$ or $|B| ≥ |W|/6$. Thus, we have 1 case for each $|A| ≥ |W|/6$ or $|B| ≥ |W|/6$.

**Case 1: $|A| ≥ |W|/6$:**
In that case $A$ and $Â$ are admissible, the first step consists in computing all admissible factors $A$, then we compute the set $F$ of all factors for wich every $A$ with $|A| ≥ |W |/6$ is an affix factor of element of $F$ ($𝓞(|W|)$ time).

We then take the factors in $F$ and try to guess $B$ and $f_Θ(B)$, the candidates are the longest common suffixes of $X$ and $Y$ with $F=XY$ and $|Y| = ±|X|$, Then we compare the prefixes from $X$ and $Y$, it should be $A$ and $Â$ the remainig words before and after $Â$ should be $C$ and $f_Θ(C)$

**Case 2: $|B| ≥ |W|/6$:**
Here the trick is to guess pairs of $B$ and $f_Θ(B)$ and then apply the same reasonning as the first case.

Each case can be done in $𝓞(|W|)$, thus linear time.

"""

# ╔═╡ b56d0a2c-abb1-41b3-ac90-a00841e3c931
md"""
#### Type-1 Half-Turn Reflection
"""

# ╔═╡ 710df413-cdd8-4f37-b474-8f9b8c8ab043
md"""
> Factorisation of the form $W = ABC\hat{A}Df_Θ(D)$

"""

# ╔═╡ 9bc7265a-3c58-4aae-a5f7-a4974ebcd372
md"""
Similar to previous factorisations, the paper proves that the reflect square $Df_Θ(D)$ and the palindromes $B$ and $C$ are admissible, that is cannot be extended while keeping their properties.

The algorithm for this factorisation is splitted into two parts. The first gathers a set of factors that could potentially be splitted into two admissible palindromes, and, if they do, form a viable factorisation. And the second part, tries to split the factors from the first part into viable palindromes in order to build up factorisations.

The first step starts by finding the linearly sized set of reflect squares $Df_Θ(D)$ and building up potential factorisations for each by appending all potential $A$ and $\hat{A}$. Since these are not proved to be admissible, all possible should be considered. For each of these half-factorisations, the remaining part of the word is a _completion factor_. That is, if we can split it into two admissible palindromes, we have found a type-1 half-turn factorisation.

The second step collects all admissible palindromes in linear time, and then tries to match each completion factor from the first phase with two palindromes from here. If a match is found, then one of the completion factors can be split into two admissible palindromes, and we have a factorisation.
"""

# ╔═╡ 44c4f097-cc65-4a44-9a3c-f201545904a4
md"""
#### Type-2 Half-Turn-Reflection
"""

# ╔═╡ 195c6eb6-2479-4e3a-9a3f-7533ead36eb4
md"""
The type-2 Reflection factorisation is defined as such:

> A type-2 half-turn-reflection factorisation of a boundary word $W$ has the form: $W = ABCDfΘ(B)fΦ(D)$ with $A$, $C$ palindromes and $Θ◦ −Φ◦ = ±90◦$.

The claim for this factorisation is:
> Let $P$ be a polyomino with $|B(P)| = n$. It can be decided in $𝓞(n \log n)$ time if $B(P)$ has a type-2 half-turn-reflection factorisation.

Knowing that, without loss of generality, an element from ${A, B, C, D}$ has length at least $|W|/6$. And the cases of $A$ and $C$ are symmetric there are 3 cases to be handled by the algorithm.

**Case 1: $|B| ≥ |W|/6$:**
Here we first compute a set of all pairs of $B$ and $f_Θ(B)$ ($𝓞(|W|)$ size), then determining if each pair is compatible with the factorisation can be done in $𝓞(log |W|)$ time giving us a total of $𝓞(|W|\log|W|)$ time.

This is done by taking $B$ and $f_Θ(B)$ in two different factors and guessing the right pre/suffixes.

**Case 2: $|D| ≥ |W|/6$:**
This case is exactly handled as the last one, and we therefore have the same complexity, $𝓞(|W|\log|W|)$.

**Case 3: $|A| ≥ |W|/6$:**
Here we take, as we have done for other factorisations, a set $F$ of factors with a possible $A$ as affix, then we try to guess $D$ and $f_Θ(D)$ and apply the tricks we used in Case 2 and do the same for $B$ and $f_Θ(B)$.

The total time spend will thus be $𝓞(|W|log|W|)$.
"""

# ╔═╡ 2ee6cfb8-75be-4c8f-8ae3-313ee97902fd
md"""
## Conclusion
"""

# ╔═╡ c36faf5b-beed-4066-abec-2594794e039f
md"""
As we’ve seen, we can study tilings of polyominoes by introducing the notion of boundary word, which is a sort of path that encloses them. These boundary words can then be factorised into a sequence of subwords, called factorisation, and if some properties are satisfied by these factors, then an isohedral tiling exists. There exists 7 such configurations and the problem of determining whether a word can be factorised in one of them is decidable.

A immediate brute force algorithm in $𝓞(n^6)$ can be used, but we’ve shown that we a much better one exists in $𝓞(n \log^2 n)$ by using strong structural results on the words.
"""

# ╔═╡ 9f2236ba-0e22-4425-a951-6cc6ceed7520
md"# Appendix A: code"

# ╔═╡ 58bdacbe-0bd7-4e9b-8a39-c2c5c89f2f42
md"""
## Current factorisation state
"""

# ╔═╡ 2f74f271-3f59-4edc-bc7a-0a950cb24bd7
PLANE_WIN_X = 700

# ╔═╡ 2e92baef-efe4-4355-93a8-1c3797e17ece
PLANE_WIN_Y = 300

# ╔═╡ c699b23f-2341-4a07-9d72-ff85585110f4
MIN_SQ_UNIT = 10

# ╔═╡ 2bb6b38f-c1be-431e-a383-aa3604148c54
md"""
**Zoom** $(@bind UNIT Slider(MIN_SQ_UNIT:30))
"""

# ╔═╡ 2c2dfdc2-f365-4085-b2e5-4325ca3aaae5
md"""
**Zoom** $(@bind ex_UNIT Slider(MIN_SQ_UNIT:30))
"""

# ╔═╡ 77a355a2-7591-4d18-955b-bbf6c7e19dda
# No pretty, but otherwise the export is kinda messed up
boundary_word = try
	if isnothing(boundaryWord) || boundaryWord == "Illegal polyomino"
		""
	else
		boundaryWord
	end
catch e
	""
end

# ╔═╡ 8d359a24-7b62-4ead-b3ff-5c3fc8f3da32
transformations(bw::String, fact::Nothing) = []

# ╔═╡ 2513ee2c-669d-472f-8889-022ab04e658b
md"""
#### Tiling example
"""

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

# ╔═╡ a697e811-0507-4be4-b6fb-43fde5c7f9f5
function rotate(pts, θ; first_idx = 1)
	fst = pts[first_idx]

	if θ == 180
		pts .|> (pt -> pt .- fst) .|> (.-) .|> (pt -> pt .+ fst)
	elseif θ == 90
		pts .|> (pt -> pt .- fst) .|> (pt -> (pt[2], -pt[1])) .|> (pt -> pt .+ fst)
	elseif θ == -90
		pts .|> (pt -> pt .- fst) .|> (pt -> (-pt[2], pt[1])) .|> (pt -> pt .+ fst)
	end
end

# ╔═╡ 0c81f834-1194-4460-bfd7-45da0e051d2d
function mirror(pts, θ; first_idx = 1)
	@assert θ ∈ [-45, 0, 45, 90]
	
	fst = pts[first_idx]
	pts = pts .|> (pt -> pt .- fst)

	if θ == -45
		pts = pts .|> (pt -> (-pt[2], -pt[1]))
	elseif θ == 0
		pts = pts .|> (pt -> (pt[1], -pt[2]))
	elseif θ == 45
		pts = pts .|> (pt -> (pt[2], pt[1]))
	elseif θ == 90
		pts = pts .|> (pt -> (-pt[1], pt[2]))
	end

	pts .|> (pt -> pt .+ fst)
end

# ╔═╡ 37f103c4-65e4-4064-b651-eb5e3db06b60
@test rotate([(1, 1), (1, 2)], 180) == [(1,1), (1, 0)]

# ╔═╡ 7a29d558-f01c-4aba-b8c3-85d84ff88776
@test rotate(rotate([(1,1), (1,2)], 180), 180) == [(1, 1), (1,2)]

# ╔═╡ 15b49802-11c5-420d-8227-01555b99de2d
md"""
## Factorisations
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

Generate tiling of polygon described by `word`, of depth `size` and using the `transforms`. These last must be functions on sets of points, such as translations, rotations, etc. They depend on the factorisation.
"""
function generate_tiling(word::String, size::Integer, transforms)::Vector{Polygon}
	polygons = []
	pending = [(0, path_points(word))]

	while !isempty(pending)
		depth, curr = popfirst!(pending)
		while curr ∈ polygons
			depth, curr = if !isempty(pending)
				popfirst!(pending)
			else
				nothing, nothing
			end
		end

		if isnothing(curr)
			break
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

# ╔═╡ c15fbe9e-1bd8-43fa-89f2-a5fabde0e652
function generate_tiling(word::String, bounds::Tuple{Int64, Int64}, transforms)
	max_x = bounds[1] ÷ 2
	min_x = -max_x

	max_y = bounds[2] ÷ 2
	min_y = -max_y

	isinbounds(poly) = any(pt -> min_x ≤ pt[1] ≤ max_x && min_y ≤ pt[2] ≤ max_y, poly)
	
	polygons = []
	pending = [path_points(word)]

	while !isempty(pending)
		curr = popfirst!(pending)
		while curr ∈ polygons
			curr = if !isempty(pending)
				popfirst!(pending)
			else
				nothing
			end
		end

		if isnothing(curr)
			break
		end
		
		push!(polygons, curr)
		for transform ∈ transforms
			next = transform(curr)
			if !(next ∈ polygons) && isinbounds(next)
				push!(pending, next)
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

# ╔═╡ e053352a-9582-416b-a110-80ae726c0552
function getfirst(p, itr)
    for el in itr
        p(el) && return el
    end
    return nothing
end

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

# ╔═╡ a71c4616-be41-4460-a23f-543f46851517
@enum FactorizationKind begin
	Translation
	HalfTurn
	QuarterTurn
	TypeOneReflection
	TypeTwoReflection
	TypeOneHalfTurnReflection
	TypeTwoHalfTurnReflection
end

# ╔═╡ 92484363-fc03-4e94-8c60-dcb6c93e17af
@bind tiling_method Select([
	Translation
	HalfTurn
	QuarterTurn
	TypeOneReflection
	TypeTwoReflection
	TypeOneHalfTurnReflection
	TypeTwoHalfTurnReflection
]; default=Translation)

# ╔═╡ cc23edf7-3ac3-4dad-84b2-40186375c428
function example_word(method)
	if method == Translation
		"rrdldrruurrddrrulurrurddldrdlddlddllurullldlldrdlluuluuruluruu"
	elseif method == HalfTurn
		"rddrurdruuurdrdrdrdldrddrdllululdddluldluullurrulllllurruuur"
	elseif method == QuarterTurn
		"druuurddrurrddrdlldrrrdlddrdldluldluullurullurulluur"
	elseif method == TypeOneReflection
		"rrrdrdddrurdddddlulddlullldluululuuurururu"
	elseif method == TypeTwoReflection
		"ruuurddrrddldrrrdlddddllluuldddlulluuuuluulurrrurd"
	elseif method == TypeOneHalfTurnReflection
		"urrdrrdlddlddldrrrrdldllulldlullurrululurrullururr"
	elseif method == TypeTwoHalfTurnReflection
		"drdrdllddrurddddlllddldluurulluulluurdruurdruulurrur"
	end
end

# ╔═╡ a219c1b4-902f-44a4-a388-cc14008fbb1f
ex_boundaryword = example_word(tiling_method)

# ╔═╡ 9dac7d76-e344-4cce-bedd-ae6cb4bec111
const Factorization = Vector{Factor}

# ╔═╡ d75dc891-3b79-4be8-9564-6eef1bdba3da
"""
Word from factorisation, with first letter the first char of the first factor.
"""
function canonic_word(fact::Factorization)
	fact .|> (f -> f.content) |> join
end

# ╔═╡ ffd79659-26d5-4447-82cf-6e2a5f506dc6
struct BWFactorization
	fact::Factorization
	kind::FactorizationKind
end

# ╔═╡ 5c3bc705-0500-42ae-abce-a2e2da6f06fe
Base.length(factor::Factor) = length(factor.content)

# ╔═╡ 5592d3ff-30a3-4be7-9ce6-3894ef76c79d
function tθ(letter::Char, θ::Int64)
	@assert θ % 90 == 0

	rot = (θ ÷ 90) % 4
	idx = mod1(indexof(letter) + rot, length(ALPHABET))
	
	ALPHABET[idx]
end

# ╔═╡ 55990d0e-1418-4bd6-a1c1-f75cb74cb958
@test tθ('u', 360) == 'u'

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

# ╔═╡ 31124ccb-2e65-4281-85b8-c355ec6a9b4d
@test canonic_word([factor("hello", 2, 4), factor("hello", 5, 1)]) == "elloh"

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

# ╔═╡ e9d48d9d-c1fa-410f-8431-1fe4794ae3e4
function longest_common_suffix(a::String, b::String)
	max_bound = min(length(a), length(b))
	bound = 0
	
	while bound < max_bound && a[end - bound] == b[end - bound]
		bound += 1
	end
	
	a[end - bound + 1:end]
end

# ╔═╡ 368eab32-e52d-4cc8-9396-56602822e3ca
@test longest_common_suffix("abcd", "abcd") == "abcd"

# ╔═╡ 29cb373a-95ba-4938-87e8-401123dc517a
@test longest_common_suffix("abc", "def") == ""

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
Expand half BN factorisations to full ones.
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
function bn_factorization(word::String)::Union{BWFactorization, Nothing}
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

	if factorization == nothing
		nothing
	else
		BWFactorization(expand(factorization, length(word)), Translation)
	end
end

# ╔═╡ b77fe1fc-86f1-4226-8316-75862f5a2c76
@test !isnothing(bn_factorization("rrddrurddrdllldldluullurrruluu"))

# ╔═╡ a2c420e4-759f-48da-bc59-ffa568e1b23f
@test !isnothing(bn_factorization("ururdrrdldllul"))

# ╔═╡ 388568b4-2319-4ef6-98f1-306223d2dc41
@test !isnothing(bn_factorization("urdrrdldllulur"))

# ╔═╡ 7736febe-6492-4a3e-8bd4-3fcf590fe6fc
"""
	translation_vectors(word::String, fact::Factorization)::Vector{Vec2D}

Given a word and its BN factorisation, give the vectors to the adjacent tiles in a tiling.
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

Get translation vectors for a BN factorisation as transformations. Useful for `generate_tiling`.
"""
function bn_transformations(word::String, fact::Factorization)
	vecs = translation_vectors(word, fact)
	map(v -> (pts -> translate(pts, v)), vecs)
end

# ╔═╡ eb67c8bf-b5ac-4508-bdd8-88c0d01101f3
md"""
### Half-Turn Factorization
"""

# ╔═╡ a278b48b-a695-4ebe-a48b-5ce251fab378
function isΘdrome(w::String, θ::Int64)::Bool
	i = 1
	j = w |> length

	valid = true
	while i ≤ j && valid
		valid = tθ(w[i], θ+180) == w[j]
		i += 1
		j -= 1
	end

	valid	
end

# ╔═╡ b02c5236-bc24-40ab-b452-3b3e61853016
ispalindrome(w::String) = isΘdrome(w, 180)

# ╔═╡ 0699a9e9-c620-4456-8da7-630dee22441d
ispalindrome(f::Factor) = ispalindrome(f.content)

# ╔═╡ b259b15b-c3db-4d59-b11a-618868dbf698
ispalindrome(n::Nothing) = true

# ╔═╡ 4574f1dd-2eeb-4b76-93fe-f36d2bf1172e
@test ispalindrome("urdlldru")

# ╔═╡ 8c8cab8e-2922-4f39-8614-c9b45266ff9f
function half_turn(w::String)::Union{BWFactorization, Nothing}
	l = length(w)
	s(i) = mod1(i, l)
	
	for A_start ∈ 1:l

		B_max = A_start + (l - 4) ÷ 2
		for B_start ∈ A_start+1:B_max
			A = factor(w, A_start, s(B_start-1))

			C_max = A_start + l - 1 - 2 - length(A)
			for C_start ∈ B_start+1:C_max
				B = factor(w, s(B_start), s(C_start-1))
				if B.content |> ispalindrome

					Â_max = C_max + 1
					for Â_start ∈ C_start+1:Â_max
						D_start = Â_start + length(A)

						C = factor(w, s(C_start), s(Â_start-1))
						Â = factor(w, s(Â_start), s(D_start-1))
						
						if (C.content |> ispalindrome
							&& A.content == Â.content |> backtrack)

							E_max = A_start + l - 1
							for E_start ∈ D_start+1:E_max
								D = factor(w, s(D_start), s(E_start-1))
								E = factor(w, s(E_start), s(A_start+l-1))

								if (D.content |> ispalindrome
									&& E.content |> ispalindrome)
									return BWFactorization(
										[A, B, C, Â, D, E],
										HalfTurn
									)
								end
							end
						end
					end
				end
			end
		end
	end
	
	nothing
end

# ╔═╡ 2cea2c5c-3942-473c-a231-0d4450346bf6
@test !(half_turn("rddrurdruuurdrdrdrdldrddrdllululdddluldluullurrulllllurruuur") |> isnothing)

# ╔═╡ 1e6d83b3-de76-41c4-92f9-000e25670dbb
function half_turn_transformations(word::String, fact::Factorization)
	start = fact[1].start
	finish = fact[4].finish
	t1 = path_vector(extract(word, start, finish))
	
	[
		(pts -> translate(pts, t1)),
		(pts -> translate(pts, .-t1)),
		(pts -> begin
			r = rotate(pts, 180; first_idx = fact[2].start)
			te = pts[fact[3].start] .- pts[fact[2].start]
			translate(r, te)
		end),
		(pts -> begin
			r = rotate(pts, 180; first_idx = fact[3].start)
			te = pts[fact[4].start] .- pts[fact[3].start]
			translate(r, te)
		end),
		(pts -> begin
			r = rotate(pts, 180; first_idx = fact[5].start)
			te = pts[fact[6].start] .- pts[fact[5].start]
			translate(r, te)
		end),
		(pts -> begin
			r = rotate(pts, 180; first_idx = fact[6].start)
			te = pts[fact[1].start] .- pts[fact[6].start]
			translate(r, te)
		end),
	]
end

# ╔═╡ 8c141949-4bf2-45ed-bf65-c033a3039e2b
md"""
### Quarter-Turn factorisation
"""

# ╔═╡ aec03332-7823-4a88-aa1c-5d8ef8ce69da
is90drome(w::String) = isΘdrome(w, 90)

# ╔═╡ 1bc65291-fb75-4b3c-8db9-5816d21484af
is90drome(f::Factor) = isΘdrome(f.content, 90)

# ╔═╡ d30021de-db76-4e58-bb3f-be466f927cd5
@test is90drome("urrddr")

# ╔═╡ 1d446a2c-cf62-40b9-a01a-b05925f560d6
function quarter_turn_transformations(word::String, fact::Factorization)
	transforms = [
		(pts -> begin
			θ = fact[1] |> ispalindrome ? 180 : 90
			r = rotate(pts, θ; first_idx = fact[1].start)
			te = pts[fact[2].start] .- pts[fact[1].start]
			translate(r, te)
		end),
		(pts -> begin
			r = rotate(pts, 90; first_idx = fact[2].start)
			te = pts[fact[mod1(3, length(fact))].start] .- pts[fact[2].start]
			translate(r, te)
		end),
		(pts -> begin
			idx = mod1(fact[2].start + length(fact[2]) ÷ 2, length(word))
			rotate(pts, -90; first_idx = idx)
		end),
	]

	if fact |> length == 3
		append!(
			transforms,
			[
				(pts -> begin
					r = rotate(pts, 90; first_idx = fact[3].start)
					te = pts[fact[mod1(1, length(fact))].start] .- pts[fact[3].start]
					translate(r, te)
				end),
				(pts -> begin
					idx = mod1(fact[3].start + length(fact[3]) ÷ 2, length(word))
					rotate(pts, -90; first_idx = idx)
				end),
			]
		)
	end

	transforms
end

# ╔═╡ 9a6dde68-8b7d-4fec-9f18-5e03abb78e06
"""
Version with only two of three factors (one being empty).
"""
function quarter_turn_2(w::String)::Union{BWFactorization, Nothing}
	l = length(w)
	s(i) = mod1(i, l)
	
	for A_start ∈ 1:l
		for B_start ∈ A_start+1:A_start+l-1
			A = factor(w, A_start, s(B_start-1))
			B = factor(w, s(B_start), s(A_start+l-1))

			if (A |> ispalindrome || A |> is90drome) && B |> is90drome
				return BWFactorization(
					[A, B],
					QuarterTurn
				)
			end
		end
	end
	
	nothing
end

# ╔═╡ 40f2194b-264b-4d6b-8006-3a0bd3f82c6c
@test !(quarter_turn_2("rrrrrdddddlldlulluuruluu") |> isnothing)

# ╔═╡ 3d500ecf-281f-4f54-8848-90cb7bd21d23
"""
Version with the three factors (none is empty).
"""
function quarter_turn_3(w::String)::Union{BWFactorization, Nothing}
	l = length(w)
	s(i) = mod1(i, l)
	
	for A_start ∈ 1:l

		for B_start ∈ A_start+1:A_start+l-1-1
			A = factor(w, A_start, s(B_start-1))
			if A |> ispalindrome

				for C_start ∈ B_start+1:A_start+l-1
					B = factor(w, s(B_start), s(C_start-1))
					C = factor(w, s(C_start), s(A_start+l-1))

					if B |> is90drome && C |> is90drome
						return BWFactorization(
							[A, B, C],
							QuarterTurn
						)
					end
				end
			end
		end
	end
	
	nothing
end

# ╔═╡ 19d1ff0d-80c7-4060-88e7-707ab293fbbd
function quarter_turn(w::String)::Union{BWFactorization, Nothing}
	getfirst(!isnothing, [quarter_turn_2(w), quarter_turn_3(w)])
end

# ╔═╡ 1d406b44-350e-41b6-92e7-ab7eb406b0be
@test !(quarter_turn_3("druuurddrurrddrdlldrrrdlddrdldluldluullurullurulluur") |> isnothing)

# ╔═╡ 0b42e3a0-b10c-45cc-a71d-bc02a4d700cc
md"""
### Type-1 Reflection
"""

# ╔═╡ 1b70eda1-8aaa-4415-96a0-dfa042f8b536
function isreflection(a::String, b::String, θ::Int64)::Bool
	length(a) == length(b) && zip(a, b) .|> (p -> first(p) == fθ(last(p), θ)) |> all
end

# ╔═╡ a4092512-3cf2-4e1f-9ef3-188a7151b0a4
@test isreflection("rr", "uu", 45)

# ╔═╡ 3477d9cc-23a0-4feb-8518-c973b3b3834f
function isanyreflection(a::String, b::String)
	[-45, 0, 45, 90] .|> (θ -> isreflection(a, b, θ)) |> any
end

# ╔═╡ 36fe3ab8-832a-4b66-bde2-67ab323c5cef
isanyreflection(a::Factor, b::Factor) = isanyreflection(a.content, b.content)

# ╔═╡ aad243e7-aa8c-4a72-951a-8e98f81101a3
@test isanyreflection("rr", "ll")

# ╔═╡ b8662be9-ece0-4c22-b165-ac5f764dc876
function type_one_reflection(w::String)::Union{BWFactorization, Nothing}
	l = length(w)
	m = l ÷ 2
	s(i) = mod1(i, l)

	for A_start ∈ 1:l

		B_start_max = A_start + (l - 2) ÷ 2 - 1
		for B_start ∈ A_start+1:B_start_max

			for B_size ∈ 1:(l-2)÷2 - 1
				BF_start = B_start + B_size
				Â_start = BF_start + B_size
				
				C_start = Â_start + (B_start - A_start)
				CF_start = C_start + ((A_start + l) - C_start) ÷ 2

				A = factor(w, A_start, s(B_start-1))
				Â = factor(w, s(Â_start), s(C_start-1))
				
				B = factor(w, s(B_start), s(BF_start-1))
				BF = factor(w, s(BF_start), s(Â_start-1))
				
				C = factor(w, s(C_start), s(CF_start-1))
				CF = factor(w, s(CF_start), s(A_start + l - 1))

				if (A.content == Â.content |> backtrack
					&& isanyreflection(B, BF)
					&& isanyreflection(C, CF))
					return BWFactorization(
						[A, B, BF, Â, C, CF],
						TypeOneReflection
					)
				end
			end
		end
	end
	
	nothing
end

# ╔═╡ a25d4c5e-542f-4709-8f1f-b8adba8391c0
@test !(type_one_reflection("rrrdrdddrurdddddlulddlullldluululuuurururu") |> isnothing)

# ╔═╡ 255ee00f-eafb-458f-959f-97bc99023ea6
function reflection_angle(a::String, b::String)
	getfirst(θ -> isreflection(a, b, θ), [-45, 0, 45, 90])
end

# ╔═╡ 2058d788-5faa-460a-ba8f-ef40699b78e0
reflection_angle(a::Factor, b::Factor) = reflection_angle(a.content, b.content)

# ╔═╡ 0583a651-61e8-4193-8bf6-b03cd8de0179
function type_one_reflection_transformations(word::String, fact::Factorization)
	start = fact[1].start
	finish = fact[4].finish
	t1 = path_vector(extract(word, start, finish))

	bθ = reflection_angle(fact[2], fact[3])
	# Invert for 45 because the plane’s y axis is point downwards
	bθ = bθ ∈ [45, -45] ? -bθ : bθ

	cθ = reflection_angle(fact[5], fact[6])
	cθ = cθ ∈ [45, -45] ? -cθ : cθ
	
	[
		(pts -> translate(pts, t1)),
		(pts -> translate(pts, .-t1)),
		(pts -> begin
			m = mirror(pts, cθ; first_idx = fact[6].start)
			tc = pts[fact[1].start] .- pts[fact[6].start]
			translate(m, tc)
		end),
		(pts -> begin
			m = mirror(pts, cθ; first_idx = fact[6].start)
			tc = pts[fact[5].start] .- pts[fact[6].start]
			translate(m, tc)
		end),	
		(pts -> begin
			m = mirror(pts, bθ; first_idx = fact[3].start)
			tc = pts[fact[4].start] .- pts[fact[3].start]
			translate(m, tc)
		end),
		(pts -> begin
			m = mirror(pts, bθ; first_idx = fact[3].start)
			tc = pts[fact[2].start] .- pts[fact[3].start]
			translate(m, tc)
		end),
	]
end

# ╔═╡ 93359dda-78df-4f44-b15e-bc202c77b47d
md"""
### Type-2 Reflection
"""

# ╔═╡ 4eb10ee7-e5b9-4306-a8e1-9d7dfd5dc268
function type_two_reflection(w::String)
	l = length(w)
	m = l ÷ 2
	s(i) = mod1(i, l)

	for A_start ∈ 1:l
		Â_start = A_start + m

		for B_start ∈ A_start+1:Â_start-3
			CL_start = B_start + m

			A = factor(w, s(A_start), s(B_start-1))
			Â = factor(w, s(Â_start), s(CL_start-1))
			
			if A.content == Â.content |> backtrack

				for C_start ∈ B_start+2:Â_start-2
					BL_start = CL_start + (Â_start-C_start)

					B = factor(w, s(B_start), s(C_start-1))
					C = factor(w, s(C_start), s(Â_start-1))

					CL = factor(w, s(CL_start), s(BL_start-1))
					BL = factor(w, s(BL_start), s(A_start+l-1))

					if isanyreflection(B, BL) && isanyreflection(C, CL)
						return BWFactorization(
							[A, B, C, Â, CL, BL],
							TypeTwoReflection
						)
					end
				end
			end
		end
	end
	
	nothing
end

# ╔═╡ ed2d4fec-3523-4d67-992b-b8e8c6ce3fb9
@test !(type_two_reflection("ruuurddrrddldrrrdlddddllluuldddlulluuuuluulurrrurd") |> isnothing)

# ╔═╡ 9d3a0e5c-ea42-4924-bc0f-1fcb478626d7
function type_two_reflection_transformations(word::String, fact::Factorization)
	start = fact[1].start
	finish = fact[4].finish
	t1 = path_vector(extract(word, start, finish))

	# We can have only one reflection angle for both B and C, it’s used for tiling
	θ = reflection_angle(fact[2], fact[6])

	# Invert for 45 because the plane’s y axis is point downwards
	θ = θ ∈ [45, -45] ? -θ : θ
	
	[
		(pts -> translate(pts, t1)),
		(pts -> translate(pts, .-t1)),
		(pts -> begin
			m = mirror(pts, θ; first_idx = fact[3].start)
			tc = pts[fact[5].start] .- pts[fact[3].start]
			translate(m, tc)
		end),		
		(pts -> begin
			m = mirror(pts, θ; first_idx = fact[3].start)
			tc = pts[fact[1].start] .- pts[fact[3].start]
			translate(m, tc)
		end),		
		(pts -> begin
			m = mirror(pts, θ; first_idx = fact[6].start)
			tc = pts[fact[2].start] .- pts[fact[6].start]
			translate(m, tc)
		end),
		(pts -> begin
			m = mirror(pts, θ; first_idx = fact[6].start)
			tc = pts[fact[4].start] .- pts[fact[6].start]
			translate(m, tc)
		end),
	]
end

# ╔═╡ 4ce6ca14-fa12-4440-a7da-19adda76ed96
md"""
### Type-1 Half-Turn Reflection
"""

# ╔═╡ d2931638-3c5f-4c8a-beff-bf12bd7f60bf
function type_one_half_turn_reflection(w::String)
	l = length(w)
	s(i) = mod1(i, l)
	
	for A_start ∈ 1:l

		B_max = A_start + (l-4) ÷ 2
		for B_start ∈ A_start+1:B_max
			A = factor(w, A_start, s(B_start-1))

			C_max = B_start + 1 + l - 2 - length(A)
			for C_start ∈ B_start+1:C_max
				B = factor(w, s(B_start), s(C_start-1))
				if B.content |> ispalindrome

					Â_max = C_start + 1 + l - 2 - length(A) + 1
					for Â_start ∈ C_start+1:Â_max
						D_start = Â_start + (A |> length)
						DF_start = D_start + (A_start + l - D_start) ÷ 2
						
						C = factor(w, s(C_start), s(Â_start-1))
						Â = factor(w, s(Â_start), s(D_start-1))

						D = factor(w, s(D_start), s(DF_start-1))
						DF = factor(w, s(DF_start), s(A_start+l-1))

						if (C.content |> ispalindrome
							&& A.content == Â.content |> backtrack
							&& isanyreflection(D, DF))
							return BWFactorization(
								[A, B, C, Â, D, DF],
								TypeOneHalfTurnReflection
							)
						end
					end
				end
			end
		end
	end
	
	nothing
end

# ╔═╡ 112ad530-59ce-44d7-ae85-adc0b44286b1
@test !(type_one_half_turn_reflection("urrdrrdlddlddldrrrrdldllulldlullurrululurrullururr") |> isnothing)

# ╔═╡ 15162be0-722a-44f1-83a3-0894eb65afda
function type_one_half_turn_reflection_transformations(word::String, fact::Factorization)
	start = fact[1].start
	finish = fact[4].finish
	t1 = path_vector(extract(word, start, finish))

	θ = reflection_angle(fact[5], fact[6])

	# Invert for 45 because the plane’s y axis is point downwards
	θ = θ ∈ [45, -45] ? -θ : θ
	
	[
		(pts -> translate(pts, t1)),
		(pts -> translate(pts, .-t1)),
		(pts -> begin
			r = rotate(pts, 180; first_idx = fact[2].start)
			te = pts[fact[3].start] .- pts[fact[2].start]
			translate(r, te)
		end),
		(pts -> begin
			r = rotate(pts, 180; first_idx = fact[3].start)
			te = pts[fact[4].start] .- pts[fact[3].start]
			translate(r, te)
		end),
		(pts -> begin
			m = mirror(pts, θ; first_idx = fact[6].start)
			tc = pts[fact[5].start] .- pts[fact[6].start]
			translate(m, tc)
		end),		
		(pts -> begin
			m = mirror(pts, θ; first_idx = fact[6].start)
			tc = pts[fact[1].start] .- pts[fact[6].start]
			translate(m, tc)
		end),		
	]
end

# ╔═╡ 641980e2-3399-41b2-b951-f2dcf462d8f9
md"""
### Type-2 Half-Turn Reflection
"""

# ╔═╡ d6ad5f54-eb9c-43b1-acf9-da318b2e6848
function type_two_half_turn_reflection(w::String)
	l = length(w)
	s(i) = mod1(i, l)

	for A_start ∈ 1:l
		for B_start ∈ A_start+1:A_start+l-1-4
			A = factor(w, s(A_start), s(B_start-1))
			if A.content |> ispalindrome

				C_max = B_start + (l - length(A) - 3) ÷ 2
				for C_start ∈ B_start+1:C_max
					B = factor(w, s(B_start), s(C_start-1))

					D_max = A_start + l - 1 - 1 - length(B)
					for D_start ∈ C_start+1:D_max
						C = factor(w, s(C_start), s(D_start - 1))

						D_size = (l - length(A) - length(C) - 2 * length(B)) ÷ 2
						BF_start = D_start + D_size
						DF_start = BF_start + length(B)

						D = factor(w, s(D_start), s(BF_start-1))
						BF = factor(w, s(BF_start), s(DF_start-1))
						DF = factor(w, s(DF_start), s(A_start+l-1))

						if (C.content |> ispalindrome
							&& isanyreflection(B, BF)
							&& isanyreflection(D, DF))
							
							bθ = reflection_angle(B, BF)
							dθ = reflection_angle(D, DF)
							sm = bθ - dθ

							if sm == 90 || sm == -90
								return BWFactorization(
								[A, B, C, D, BF, DF],
								TypeTwoHalfTurnReflection
							)
							end
						end
					end
				end
			end
		end
	end

	nothing
end

# ╔═╡ 76061728-334e-4543-8d54-83520c3db87b
function factorize(word::String, method::FactorizationKind)
	if method == Translation
		bn_factorization(word)
	elseif method == HalfTurn
		half_turn(word)
	elseif method == QuarterTurn
		quarter_turn(word)
	elseif method == TypeOneReflection
		type_one_reflection(word)
	elseif method == TypeTwoReflection
		type_two_reflection(word)
	elseif method == TypeOneHalfTurnReflection
		type_one_half_turn_reflection(word)
	elseif method == TypeTwoHalfTurnReflection
		type_two_half_turn_reflection(word)
	end
end

# ╔═╡ 7ff92923-ff57-4411-8301-40cf013dbaa1
function anyfactorization(w::String)
	[
		Translation,
		HalfTurn,
		QuarterTurn,
		TypeOneReflection,
		TypeTwoReflection,
		TypeOneHalfTurnReflection,
		TypeTwoHalfTurnReflection
	] .|> (t -> factorize(w, t)) |> (f -> getfirst(!isnothing, f))
end

# ╔═╡ 56983584-7a5c-4792-a065-44af56e8f7dc
factorization = anyfactorization(boundary_word)

# ╔═╡ 7b9d22c3-c2de-40d8-b268-194adee6b58c
if ismissing(boundary_word) || isnothing(boundary_word) || isempty(boundary_word)
	Markdown.MD(Markdown.Admonition(
		"info",
		"No polyomino to work with",
		[md"Enter a valid polyomino to see whether it can tile the plane!"]
	))
elseif isnothing(factorization)
	Markdown.MD(Markdown.Admonition(
		"warning",
		"Tiling doesn’t exist",
		[md"There exists no isohedral tiling with this polyomino. Try another one!"]
	))
else
	Markdown.MD(Markdown.Admonition(
		"success",
		"Tiling exists",
		[md"An isohedral tiling with this polyomino exists, congratulations! Try another one!"]
	))
end

# ╔═╡ 78006f57-15e7-4e24-b94b-9effed36171b
ex_factorization = factorize(ex_boundaryword, tiling_method)

# ╔═╡ dccb6d2b-9c32-44f0-8e08-18489cee9a8c
ex_fact_starts = (ex_factorization.fact
	.|> (fact -> path_vector(ex_boundaryword[begin:mod1(fact.start-1, length(ex_boundaryword))])))

# ╔═╡ dd51011f-25e6-4a9a-bdc5-1710a3db8647
@test type_two_half_turn_reflection("drdrdllddrurddddlllddldluurulluulluurdruurdruulurrur") |> !isnothing

# rdrdr dllddrurdd ddllldd ldluurullu ulluurdruu rdruulurru

# ╔═╡ 719b60e8-98b3-439a-991d-ddbcabee3b63
function type_two_half_turn_reflection_transformations(word::String, fact::Factorization)

	bθ = reflection_angle(fact[2], fact[5])
	bθ = bθ ∈ [45, -45] ? -bθ : bθ

	dθ = reflection_angle(fact[4], fact[6])
	dθ = dθ ∈ [45, -45] ? -dθ : dθ
	
	[
		(pts -> begin
			r = rotate(pts, 180; first_idx = fact[1].start)
			te = pts[fact[2].start] .- pts[fact[1].start]
			translate(r, te)
		end),
		(pts -> begin
			r = rotate(pts, 180; first_idx = fact[3].start)
			te = pts[fact[4].start] .- pts[fact[3].start]
			translate(r, te)
		end),
		(pts -> begin
			m = mirror(pts, bθ; first_idx = fact[5].start)
			tc = pts[fact[2].start] .- pts[fact[5].start]
			translate(m, tc)
		end),		
		(pts -> begin
			m = mirror(pts, bθ; first_idx = fact[2].start)
			tc = pts[fact[5].start] .- pts[fact[2].start]
			translate(m, tc)
		end),		
		(pts -> begin
			m = mirror(pts, dθ; first_idx = fact[4].start)
			tc = pts[fact[6].start] .- pts[fact[4].start]
			translate(m, tc)
		end),		
		(pts -> begin
			m = mirror(pts, dθ; first_idx = fact[6].start)
			tc = pts[fact[4].start] .- pts[fact[6].start]
			translate(m, tc)
		end),		
	]
end

# ╔═╡ 5bd78da2-2445-4846-9b03-640f27917895
function transformations(bw::String, fact::BWFactorization)
	if fact.kind == Translation
		bn_transformations(bw, fact.fact)
	elseif fact.kind == HalfTurn
		half_turn_transformations(bw, fact.fact)
	elseif fact.kind == QuarterTurn
		quarter_turn_transformations(bw, fact.fact)
	elseif fact.kind == TypeOneReflection
		type_one_reflection_transformations(bw, fact.fact)
	elseif fact.kind == TypeTwoReflection
		type_two_reflection_transformations(bw, fact.fact)
	elseif fact.kind == TypeOneHalfTurnReflection
		type_one_half_turn_reflection_transformations(bw, fact.fact)
	elseif fact.kind == TypeTwoHalfTurnReflection
		type_two_half_turn_reflection_transformations(bw, fact.fact)
	end
end

# ╔═╡ 3c17a506-20c2-44dc-a786-399554523483
transforms = transformations(boundary_word, factorization)

# ╔═╡ 1507744e-f8ca-4d68-bb89-34dbe237b987
tile_polygons = generate_tiling(
	boundary_word,
	(PLANE_WIN_X ÷ MIN_SQ_UNIT, PLANE_WIN_Y ÷ MIN_SQ_UNIT),
	transforms
)

# ╔═╡ 49150d59-b330-4eb9-8fc0-2236d253bd3b
tiling = (tile_polygons
	.|> (p -> scale(p, UNIT))
	.|> (p -> translate(p, (PLANE_WIN_X ÷ 2, PLANE_WIN_Y ÷ 2))))

# ╔═╡ d963c97a-d24f-4ff0-a3d8-c810e1f55b6c

	@htl("""
	<script src="https://cdn.jsdelivr.net/npm/d3@6.2.0/dist/d3.min.js"></script>
	
	<script id="drawing">
	
	
	// const svg = this == null ? DOM.svg(600,300) : this
	// const s = this == null ? d3.select(svg) : this.s
	
	const svg = DOM.svg("100%", 300)
	const s = d3.select(svg)
	
	s.append("rect")
	    .attr("width", "100%")
	    .attr("height", "100%")
	    .attr("fill", "white");
	
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


# ╔═╡ e9008b9f-6acf-4e02-999d-99f3f4567ba2
ex_transforms = transformations(ex_boundaryword, ex_factorization)

# ╔═╡ c446bbc5-993f-4927-9148-ae56c72ef9e7
ex_tilepolygons = generate_tiling(ex_boundaryword, 1, ex_transforms)

# ╔═╡ f2d1b6bd-8d89-42b8-a229-919116e9876e
ex_ys = Iterators.flatten(ex_tilepolygons) .|> last

# ╔═╡ be756336-9cc5-4b96-bb41-f7d30d968604
ex_min_y, ex_max_y = minimum(ex_ys), maximum(ex_ys)

# ╔═╡ 8c8966b1-be86-46a7-9015-9bc0a14f32fa
ex_xs = Iterators.flatten(ex_tilepolygons) .|> first

# ╔═╡ 4fc0f208-d21c-4f66-9f6e-e994efe6e337
ex_min_x, ex_max_x = minimum(ex_xs), maximum(ex_xs)

# ╔═╡ b2e7e81f-1bc5-4b4d-b06c-bd6111bd7867
ex_center = (ex_max_x + ex_min_x, ex_max_y + ex_min_y) .÷ 2

# ╔═╡ fa59ade4-4698-406a-a2b5-18ca89dca035
ex_boundaries = (ex_fact_starts
	|> (p -> translate(p, .-ex_center))
	|> (p -> scale(p, ex_UNIT))
	|> (p -> translate(p, (PLANE_WIN_X ÷ 2, PLANE_WIN_Y ÷ 2))))

# ╔═╡ 128cf9fc-de5d-49a8-aef8-238be3977189
ex_tiling = (ex_tilepolygons
	.|> (p -> translate(p, .-ex_center))
	.|> (p -> scale(p, ex_UNIT))
	.|> (p -> translate(p, (PLANE_WIN_X ÷ 2, PLANE_WIN_Y ÷ 2))))

# ╔═╡ 459a2451-295d-40aa-b07c-9b3793aab20e
@htl("""
	<script src="https://cdn.jsdelivr.net/npm/d3@6.2.0/dist/d3.min.js"></script>
	
	<script id="drawing">
	
	
	// const svg = this == null ? DOM.svg(600,300) : this
	// const s = this == null ? d3.select(svg) : this.s
	
	const svg = DOM.svg("100%", 300)
	const s = d3.select(svg)
	
	s.append("rect")
	    .attr("width", "100%")
	    .attr("height", "100%")
	    .attr("fill", "white");
	
	const line = d3.line()
	let data = $ex_tiling
	
	data.forEach((polygon) => {
		s.append("path")
			.attr("d", line(polygon))
			.attr("stroke", "black")
			.attr("fill", "white")
	})

	let boundaries = $ex_boundaries

	boundaries.forEach((point) => {
		s.append("circle")
			.attr("cx", point[0])
			.attr("cy", point[1])
			.attr("r", $ex_UNIT/4)
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

- **Edem Lawson**:
  - polyomino builder
  - theoretical writeup
- **Boris Petrov**
  - website setup
  - graphics
  - factorisations implementation
  - tilings drawings
  - theoretical writeup
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
- [4] H. Heesch and O. Kienzle, Flächenschluß, vol. 6. in Wissenschaftliche Normung, vol. 6. Berlin, Heidelberg: Springer, 1963. doi: 10.1007/978-3-642-94883-1.
- [5] B. Grünbaum and G. C. Shephard, “The eighty-one types of isohedral tilings in the plane,” Mathematical Proceedings of the Cambridge Philosophical Society, vol. 82, no. 2, pp. 177–196, Sep. 1977, doi: 10.1017/S0305004100053810.



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

julia_version = "1.9.4"
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
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.4.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.0+1"

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
version = "1.52.0+1"

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
# ╟─306500a9-e4de-4ae8-a05b-57e768202170
# ╟─f0942786-6415-4d2b-a41a-aa06d250f798
# ╟─45d3575a-c887-435c-84be-a26284ee5dcb
# ╟─3a52dfb0-ae3f-48a7-87ff-c456db61fe15
# ╟─6802038f-0d12-455e-9df6-875a11c0f7d3
# ╟─6d4c526e-4d62-4d4c-88ca-728ea6b4fbf6
# ╟─8b41e978-f9cf-4515-9141-cbf8130521d9
# ╟─1544010c-9a45-4ea3-ab0a-6ffe24648ec8
# ╟─7b9d22c3-c2de-40d8-b268-194adee6b58c
# ╟─d963c97a-d24f-4ff0-a3d8-c810e1f55b6c
# ╟─2bb6b38f-c1be-431e-a383-aa3604148c54
# ╟─c1587642-84ed-459f-855d-fdd07ac3f761
# ╟─27aa8b5d-bb9c-493f-b256-8503c8d4177d
# ╟─462623f2-1968-4fe5-89af-c9fbcdd5b49a
# ╟─81196bee-bee2-4788-bf5f-3f60f7e668df
# ╟─9e4e8ab1-dd18-4bc2-baac-9daece06905a
# ╟─3878e012-c80d-4b93-af22-901187b933d8
# ╟─aefb27b5-4d65-436d-8f5b-093473e7e3fb
# ╟─8c471070-7629-4957-821f-61b50d52e936
# ╟─917a93f6-153f-4eac-a740-04ee407a21a6
# ╟─600d4c07-f5c2-418c-acbb-d6142155e74e
# ╟─556cc741-c004-4ea6-a7ad-8779a59f2962
# ╟─67a35fa9-b56a-467a-a0c7-126832af1b1c
# ╟─0f69ef6a-831f-4dfe-b755-4016a9e2dd65
# ╟─177c821a-a75b-44f7-a15e-9dfc061556aa
# ╟─2139c37b-422d-4524-9bf8-e59dbfa105fc
# ╟─4409958c-8e80-43d5-9758-6a192b9e5a9a
# ╟─b9e76e3f-9831-4b04-8870-29605561d189
# ╟─6e95928e-b683-45e6-a4cc-9046420a6166
# ╟─bc4f92d1-59b1-4c6a-bebe-7541d2f3c02c
# ╟─9aa159b7-59c3-41ba-a47c-7826f093cf02
# ╟─92484363-fc03-4e94-8c60-dcb6c93e17af
# ╟─459a2451-295d-40aa-b07c-9b3793aab20e
# ╟─2c2dfdc2-f365-4085-b2e5-4325ca3aaae5
# ╟─a803c33f-8c24-4213-ab58-cfeb21bc4470
# ╟─edfcac8e-31bf-427b-92bf-f905750d9952
# ╟─72a8fbe2-7688-42ea-85fb-2c14fd3cec89
# ╟─ab3e33c2-de7a-4308-aaf0-96a4a376eb5c
# ╟─f6e375ec-82ae-4f7a-aa8b-1b3ad8b376f3
# ╟─cbc82b85-e756-4955-bc46-2cff64c1a845
# ╟─704ea723-b649-46c9-9d61-1a6e2eb98e94
# ╟─16cb1a77-d27f-4f31-93ff-93747be1a286
# ╟─06bdb6ac-20ca-4b8c-881c-29ce38176f47
# ╟─a0bb1aa7-ae77-4964-94dd-109ba4134824
# ╟─0bc986f7-791a-43a4-aeaa-962942d5a424
# ╟─24b50179-70be-409e-8e05-98e262a4b59b
# ╟─0c781874-bfc8-43a2-99b4-61fe857245b6
# ╟─aa7b9d69-16a0-4e05-96ff-b9ae75d27af7
# ╟─e99222de-2cde-4b7d-8b7f-5a23c95ca611
# ╟─b56d0a2c-abb1-41b3-ac90-a00841e3c931
# ╟─710df413-cdd8-4f37-b474-8f9b8c8ab043
# ╟─9bc7265a-3c58-4aae-a5f7-a4974ebcd372
# ╟─44c4f097-cc65-4a44-9a3c-f201545904a4
# ╟─195c6eb6-2479-4e3a-9a3f-7533ead36eb4
# ╟─2ee6cfb8-75be-4c8f-8ae3-313ee97902fd
# ╟─c36faf5b-beed-4066-abec-2594794e039f
# ╟─9f2236ba-0e22-4425-a951-6cc6ceed7520
# ╠═86325fcc-348c-4108-bf77-3555a6fc243c
# ╟─58bdacbe-0bd7-4e9b-8a39-c2c5c89f2f42
# ╟─2f74f271-3f59-4edc-bc7a-0a950cb24bd7
# ╟─2e92baef-efe4-4355-93a8-1c3797e17ece
# ╟─c699b23f-2341-4a07-9d72-ff85585110f4
# ╟─77a355a2-7591-4d18-955b-bbf6c7e19dda
# ╟─56983584-7a5c-4792-a065-44af56e8f7dc
# ╟─3c17a506-20c2-44dc-a786-399554523483
# ╟─1507744e-f8ca-4d68-bb89-34dbe237b987
# ╟─49150d59-b330-4eb9-8fc0-2236d253bd3b
# ╟─7ff92923-ff57-4411-8301-40cf013dbaa1
# ╟─76061728-334e-4543-8d54-83520c3db87b
# ╟─5bd78da2-2445-4846-9b03-640f27917895
# ╟─8d359a24-7b62-4ead-b3ff-5c3fc8f3da32
# ╟─2513ee2c-669d-472f-8889-022ab04e658b
# ╟─cc23edf7-3ac3-4dad-84b2-40186375c428
# ╟─a219c1b4-902f-44a4-a388-cc14008fbb1f
# ╟─78006f57-15e7-4e24-b94b-9effed36171b
# ╟─e9008b9f-6acf-4e02-999d-99f3f4567ba2
# ╟─c446bbc5-993f-4927-9148-ae56c72ef9e7
# ╟─dccb6d2b-9c32-44f0-8e08-18489cee9a8c
# ╟─f2d1b6bd-8d89-42b8-a229-919116e9876e
# ╟─8c8966b1-be86-46a7-9015-9bc0a14f32fa
# ╟─4fc0f208-d21c-4f66-9f6e-e994efe6e337
# ╟─be756336-9cc5-4b96-bb41-f7d30d968604
# ╟─b2e7e81f-1bc5-4b4d-b06c-bd6111bd7867
# ╟─128cf9fc-de5d-49a8-aef8-238be3977189
# ╟─fa59ade4-4698-406a-a2b5-18ca89dca035
# ╟─18389ab9-4fc4-49f4-9bc9-b855b7c16232
# ╟─ee001f50-0809-4272-86fb-727fd0fdb654
# ╟─a0c1f409-c98a-40fb-aee9-93ce587c508e
# ╟─e25055d1-4ff6-4a2b-a915-4c5c34a44aec
# ╟─53eb421e-3f88-4789-b077-9e283d76a3c7
# ╟─7357539a-0888-4cf9-87d4-f03cf9063dd5
# ╟─2543a64f-f45a-4881-bcde-98aa94b30a58
# ╟─a697e811-0507-4be4-b6fb-43fde5c7f9f5
# ╟─0c81f834-1194-4460-bfd7-45da0e051d2d
# ╟─37f103c4-65e4-4064-b651-eb5e3db06b60
# ╟─7a29d558-f01c-4aba-b8c3-85d84ff88776
# ╟─1d99edae-0c8f-465a-bc22-198433d38e95
# ╟─06a216bd-e3c0-4561-a0bc-31d86aebd783
# ╟─603531e5-59d0-4be9-b6e9-37929f5afd06
# ╟─2868538a-ee1f-43ac-af62-6603ffff459d
# ╟─d75dc891-3b79-4be8-9564-6eef1bdba3da
# ╟─31124ccb-2e65-4281-85b8-c355ec6a9b4d
# ╟─ee24888e-2f89-4400-bd83-8caa73884c64
# ╟─c15fbe9e-1bd8-43fa-89f2-a5fabde0e652
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
# ╟─55990d0e-1418-4bd6-a1c1-f75cb74cb958
# ╟─556054b0-23e5-4bef-8356-ffdbb99cdcd2
# ╟─fe33290c-b27c-48bd-8aee-b6f3cd6a5184
# ╟─24c55137-7470-4b2a-9948-9e4ec23aa11c
# ╟─642e20fa-5582-418b-ae66-7ec493209736
# ╟─291e04ef-a5dd-4cd2-a598-f2256e6643e0
# ╟─e053352a-9582-416b-a110-80ae726c0552
# ╟─3e4a972f-6b44-41a6-91d2-3f949b9b7004
# ╠═70fba921-5e52-4b04-84e0-397087f0005c
# ╠═a71c4616-be41-4460-a23f-543f46851517
# ╠═9dac7d76-e344-4cce-bedd-ae6cb4bec111
# ╠═ffd79659-26d5-4447-82cf-6e2a5f506dc6
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
# ╟─e9d48d9d-c1fa-410f-8431-1fe4794ae3e4
# ╟─368eab32-e52d-4cc8-9396-56602822e3ca
# ╟─29cb373a-95ba-4938-87e8-401123dc517a
# ╟─ed19093c-0f09-4a19-9cfd-98e24005b7c8
# ╟─0806d4f5-89ed-46a1-8c65-f1e797dc6977
# ╟─abceaed4-8a67-416a-a8aa-f0c77f9c3b2a
# ╟─cb0f1693-50a1-4655-bf5f-dc2eeaf8e8fa
# ╟─f5cc61b3-b844-48d7-898b-4206506c0dae
# ╟─0ea45964-96b7-438c-a47a-609e4cd4fed0
# ╟─8d84c5dd-8c7d-456c-88fb-91d5a787846a
# ╟─830056cc-efb4-4305-9a69-4f19138eb6db
# ╟─99d849e7-f9cc-4ab8-af5a-dce0bc1f8543
# ╟─b77fe1fc-86f1-4226-8316-75862f5a2c76
# ╟─a2c420e4-759f-48da-bc59-ffa568e1b23f
# ╟─388568b4-2319-4ef6-98f1-306223d2dc41
# ╟─7736febe-6492-4a3e-8bd4-3fcf590fe6fc
# ╟─f5ee1318-b1a2-4cdc-a459-29d98b8d804e
# ╟─eb67c8bf-b5ac-4508-bdd8-88c0d01101f3
# ╟─a278b48b-a695-4ebe-a48b-5ce251fab378
# ╟─b02c5236-bc24-40ab-b452-3b3e61853016
# ╟─0699a9e9-c620-4456-8da7-630dee22441d
# ╟─b259b15b-c3db-4d59-b11a-618868dbf698
# ╟─4574f1dd-2eeb-4b76-93fe-f36d2bf1172e
# ╟─8c8cab8e-2922-4f39-8614-c9b45266ff9f
# ╟─2cea2c5c-3942-473c-a231-0d4450346bf6
# ╟─1e6d83b3-de76-41c4-92f9-000e25670dbb
# ╟─8c141949-4bf2-45ed-bf65-c033a3039e2b
# ╟─aec03332-7823-4a88-aa1c-5d8ef8ce69da
# ╟─1bc65291-fb75-4b3c-8db9-5816d21484af
# ╟─d30021de-db76-4e58-bb3f-be466f927cd5
# ╟─19d1ff0d-80c7-4060-88e7-707ab293fbbd
# ╟─1d446a2c-cf62-40b9-a01a-b05925f560d6
# ╟─9a6dde68-8b7d-4fec-9f18-5e03abb78e06
# ╟─40f2194b-264b-4d6b-8006-3a0bd3f82c6c
# ╟─3d500ecf-281f-4f54-8848-90cb7bd21d23
# ╟─1d406b44-350e-41b6-92e7-ab7eb406b0be
# ╟─0b42e3a0-b10c-45cc-a71d-bc02a4d700cc
# ╟─1b70eda1-8aaa-4415-96a0-dfa042f8b536
# ╟─a4092512-3cf2-4e1f-9ef3-188a7151b0a4
# ╟─3477d9cc-23a0-4feb-8518-c973b3b3834f
# ╟─aad243e7-aa8c-4a72-951a-8e98f81101a3
# ╟─36fe3ab8-832a-4b66-bde2-67ab323c5cef
# ╟─b8662be9-ece0-4c22-b165-ac5f764dc876
# ╟─a25d4c5e-542f-4709-8f1f-b8adba8391c0
# ╟─255ee00f-eafb-458f-959f-97bc99023ea6
# ╟─2058d788-5faa-460a-ba8f-ef40699b78e0
# ╟─0583a651-61e8-4193-8bf6-b03cd8de0179
# ╟─93359dda-78df-4f44-b15e-bc202c77b47d
# ╟─4eb10ee7-e5b9-4306-a8e1-9d7dfd5dc268
# ╟─ed2d4fec-3523-4d67-992b-b8e8c6ce3fb9
# ╟─9d3a0e5c-ea42-4924-bc0f-1fcb478626d7
# ╟─4ce6ca14-fa12-4440-a7da-19adda76ed96
# ╟─d2931638-3c5f-4c8a-beff-bf12bd7f60bf
# ╟─112ad530-59ce-44d7-ae85-adc0b44286b1
# ╟─15162be0-722a-44f1-83a3-0894eb65afda
# ╟─641980e2-3399-41b2-b951-f2dcf462d8f9
# ╟─d6ad5f54-eb9c-43b1-acf9-da318b2e6848
# ╟─dd51011f-25e6-4a9a-bdc5-1710a3db8647
# ╟─719b60e8-98b3-439a-991d-ddbcabee3b63
# ╟─3f57a6c8-d02d-4c29-8b0d-4e8871f60900
# ╠═49735ec6-6b0e-4e8e-995c-cc2e8c41e625
# ╠═e32b500b-68b1-4cea-aac5-f6755cfcc5b6
# ╟─985b959d-038e-4d05-85e7-2f2ca0ab2001
# ╟─46f79b8e-6c46-4499-9331-360c83096da5
# ╟─9e09d9bc-78d9-431c-952f-f42e98dbeb90
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
