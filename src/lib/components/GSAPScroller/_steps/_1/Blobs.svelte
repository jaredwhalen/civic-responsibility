<script>
	import { run } from 'svelte/legacy';
	import { getCSSVar } from '$lib/helpers/getCSSVar';
	import { onMount, tick } from 'svelte';
	import { fade } from 'svelte/transition';
	import * as d3 from 'd3';

	/**
	 * @typedef {Object} Props
	 * @property {number} [offset] - Range 0-1 from scroll
	 */

	/** @type {Props} */
	let { offset = 0, height, width } = $props();

	const start = 0.1;
	const end = 0.9;

	// 21 evenly spaced bins from -5 to 5
	const xValues = d3.range(-5, 5.01, 10 / 20);

	let svgContainer = $state();
	let democratLine = $state();
	let republicanLine = $state();

	// Generate consistent DEM/REP bell curves that just drift apart over time
	function generatePolarizationData({
		years = 10,
		bins = 21,
		sigma = 1.0, // standard deviation of both curves
		separationStart = 0.5, // initial separation between centers
		separationEnd = 5.0 // final separation between centers
	} = {}) {
		// Standard normal PDF
		const pdf = (x, mu, sig) =>
			Math.exp(-0.5 * ((x - mu) / sig) ** 2) / (sig * Math.sqrt(2 * Math.PI));

		// X-axis over ~±3σ (21 bins by default)
		const xs = Array.from({ length: bins }, (_, i) => {
			const t = i / (bins - 1); // 0..1
			return (t * 6 - 3) * sigma; // -3σ to +3σ
		});

		// Create one consistent bell curve shape
		function makeBell(mu, sig) {
			let arr = xs.map((x) => pdf(x, mu, sig));
			const sum = arr.reduce((a, b) => a + b, 0);
			return arr.map((v) => (v / sum) * 100);
		}

		const out = [];
		for (let y = 0; y < years; y++) {
			const t = years === 1 ? 0 : y / (years - 1); // 0..1 across years
			const separation = separationStart + t * (separationEnd - separationStart);

			// Center both around 0 and split separation symmetrically
			const muDem = -separation / 2;
			const muRep = separation / 2;

			// Build consistent bells (no jitter, same shape)
			const dem = makeBell(muDem, sigma);
			const rep = makeBell(muRep, sigma);

			out.push([
				{ name: 'Dem', data: dem.map((v) => +v.toFixed(2)) },
				{ name: 'REP', data: rep.map((v) => +v.toFixed(2)) }
			]);
		}
		return out;
	}

	// ---------- Generate data ----------
	const data = generatePolarizationData({
		years: 12, // number of "years" (arrays)
		bins: 21, // keep your 21-bin shape
		sigma: 1.0, // standard deviation (width) of both curves
		separationStart: 0.5, // initial separation between centers
		separationEnd: 4.0 // final separation between centers
	});

	onMount(async () => {
		await tick();
		width = svgContainer.clientWidth;
		drawChart();
	});

	const drawChart = () => {
		const localOffset = (offset - start) / (end - start);
		const clampedLocalOffset = Math.max(0, Math.min(1, localOffset));

		const frameCount = data.length;
		const exact = clampedLocalOffset * (frameCount - 1);
		const i0 = Math.floor(exact);
		const i1 = Math.min(i0 + 1, frameCount - 1);
		const t = exact - i0;

		const dem0 = data[i0][0].data;
		const rep0 = data[i0][1].data;
		const dem1 = data[i1][0].data;
		const rep1 = data[i1][1].data;

		const dem = d3.range(dem0.length).map((i) => dem0[i] * (1 - t) + dem1[i] * t);
		const rep = d3.range(rep0.length).map((i) => rep0[i] * (1 - t) + rep1[i] * t);

		const yMax = Math.max(...dem, ...rep);
		const xScale = d3.scaleLinear().domain([-5, 5]).range([0, width]);
		const yScale = d3.scaleLinear().domain([0, yMax]).range([height, 0]);

		const area = (vals) =>
			d3
				.area()
				.x((d, i) => xScale(xValues[i]))
				.y0(height)
				.y1((d) => yScale(d))
				.curve(d3.curveBasis);

		d3.select(democratLine).transition().duration(50).ease(d3.easeLinear).attr('d', area(dem)(dem));

		d3.select(republicanLine)
			.transition()
			.duration(50)
			.ease(d3.easeLinear)
			.attr('d', area(rep)(rep));
	};

	$effect(() => {
		drawChart();
	});

	const createGradients = () => {
		const svg = document.querySelector('svg');
		if (!svg) return;

		// Clear existing gradients
		const existingDefs = svg.querySelector('defs');
		if (existingDefs) existingDefs.remove();

		const defs = svg.appendChild(document.createElementNS('http://www.w3.org/2000/svg', 'defs'));

		// Helper function to create a gradient
		const createGradient = (id, startColor) => {
			const gradient = defs.appendChild(
				document.createElementNS('http://www.w3.org/2000/svg', 'radialGradient')
			);
			gradient.setAttribute('id', id);
			gradient.setAttribute('cx', '50%');
			gradient.setAttribute('cy', '50%');
			gradient.setAttribute('r', '100%');

			const stop1 = gradient.appendChild(
				document.createElementNS('http://www.w3.org/2000/svg', 'stop')
			);
			stop1.setAttribute('offset', '20%');
			stop1.setAttribute('stop-color', startColor);

			const stop2 = gradient.appendChild(
				document.createElementNS('http://www.w3.org/2000/svg', 'stop')
			);
			stop2.setAttribute('offset', '100%');
			stop2.setAttribute('stop-color', getCSSVar('--color-theme-blue'));
		};

		// Create both gradients
		createGradient('leftGradient', getCSSVar('--color-theme-dem-blue'));
		createGradient('rightGradient', getCSSVar('--color-theme-gop-red'));
	};

	onMount(async () => {
		await tick();
		createGradients();
	});
</script>

<div class="inner-container" in:fade|global={{ duration: 400, delay: 500 }}>
	<svg bind:this={svgContainer} width="100%" {height} transition:fade|global={{ duration: 400 }}>
		<g transform="translate(0, 1)">
			<path
				bind:this={democratLine}
				fill="url(#leftGradient)"
				opacity="0.8"
				stroke={getCSSVar('--color-theme-dem-blue')}
			/>
			<path
				bind:this={republicanLine}
				fill="url(#rightGradient)"
				opacity="0.8"
				stroke={getCSSVar('--color-theme-gop-red')}
			/>
		</g>
	</svg>
</div>

<style lang="scss">
	.inner-container {
		width: 100%;
		height: 100%;
		display: flex;
		align-items: center;
		justify-content: center;
		position: absolute;
		inset: 0;
		pointer-events: none;
		z-index: 2;
	}
	svg {
		display: block;
		width: 100%;
		height: auto;

		path {
			stroke-width: 2px;
			fill-opacity: 0.5;
			mix-blend-mode: overlay;
			mix-blend-mode: difference;
		}
	}
</style>
