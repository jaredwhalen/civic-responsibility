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
	let { offset = 0 } = $props();

	const start = 0;
	const end = 0.75;

	// 21 evenly spaced bins from -5 to 5
	const xValues = d3.range(-5, 5.01, 10 / 20);

	let width = 0;
	const height = 500;
	let svgContainer = $state();
	let democratLine = $state();
	let republicanLine = $state();

	let data = [
		[{ name: "Dem", data: [.57, 1.6, 1.89, 3.49, 3.96, 6.56, 7.23, 8.54, 9.1, 9.45, 9.3, 9.15, 7.74, 6.8, 4.66, 4.32, 2.14, 1.95, .87, .57, .12] },
		 { name: "REP", data: [.03, .22, .28, 1.49, 1.66, 2.77, 3.26, 4.98, 5.36, 7.28, 7.72, 8.16, 8.86, 8.88, 8.64, 8, 6.2, 5.8, 4.87, 4.2, 1.34] }],
		// [{ name: "Dem", data: [1.22, 2.78, 3.28, 5.12, 6.15, 7.77, 8.24, 9.35, 9.73, 9.19, 8.83, 8.47, 5.98, 5.17, 3.62, 2.87, 1.06, .75, .2, .15, .04] },
		//  { name: "REP", data: [.23, .49, .65, 2.23, 2.62, 4.06, 5.02, 7.53, 7.7, 7.28, 7.72, 8.15, 8.87, 8.47, 7.08, 6.27, 4.29, 3.99, 3.54, 2.79, 1.03] }],
		// [{ name: "Dem", data: [2.07, 3.57, 4.21, 6.74, 7.95, 8.41, 8.58, 9.07, 8.98, 8.46, 8.47, 8.49, 5.39, 3.62, 2.11, 1.98, 1, .55, .17, .17, 0] },
		//  { name: "REP", data: [.19, .71, 1.04, 2.17, 2.07, 3.65, 4.92, 7.28, 8.26, 9.64, 9.59, 9.55, 7.91, 7.74, 6.84, 6.01, 4.37, 3.46, 2.09, 1.65, .86] }],
		// [{ name: "Dem", data: [2.97, 4.09, 4.28, 6.65, 7.9, 8.37, 8.16, 8.74, 8.61, 8.15, 7.74, 7.32, 4.88, 4.82, 2.79, 2.07, .96, .78, .41, .29, .02] },
		//  { name: "REP", data: [.04, .21, .28, .88, 1.29, 2.64, 3.08, 4.92, 5.84, 6.65, 6.79, 6.92, 8.5, 8.61, 8.05, 8, 7.52, 7.51, 5.61, 4.17, 2.5] }],
		// [{ name: "Dem", data: [4.81, 6.04, 6.57, 7.67, 7.84, 8.09, 8.24, 8.91, 8.6, 6.92, 6.69, 6.47, 4.22, 3.85, 1.97, 1.69, .66, .49, .14, .1, .03] },
		//  { name: "REP", data: [.11, .36, .49, 1.23, 1.35, 2.35, 2.83, 4.63, 5.09, 6.12, 6.27, 6.41, 7.88, 8.03, 7.58, 8.26, 8.12, 7.29, 6.38, 5.89, 3.34] }],
		[{ name: "Dem", data: [6.2, 6.68, 7.27, 7.46, 8.17, 8.22, 8.21, 8.23, 7.6, 6.13, 6.11, 6.09, 4.73, 3.99, 1.83, 1.42, .65, .56, .26, .17, .02] },
		 { name: "REP", data: [.04, .14, .28, .99, 1.27, 2.38, 2.84, 4.46, 4.78, 6.62, 7.03, 7.44, 7.7, 7.5, 7.81, 7.83, 7.32, 7.57, 6.82, 5.66, 3.51] }],
		[{ name: "Dem", data: [8.42, 9.23, 9.73, 10.61, 10.77, 9.32, 8.32, 6.26, 6.36, 4.93, 4.77, 4.6, 2.35, 1.95, .8, .7, .4, .3, .1, .1, 0] },
		 { name: "REP", data: [.04, .22, .34, 2.04, 2.36, 2.03, 2.57, 4.53, 4.79, 6.63, 7.02, 7.41, 7.3, 7.58, 7.46, 7.91, 8.67, 7.64, 6.04, 5.07, 2.35] }]
	];

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

		const dem = d3.range(dem0.length).map(i => dem0[i] * (1 - t) + dem1[i] * t);
		const rep = d3.range(rep0.length).map(i => rep0[i] * (1 - t) + rep1[i] * t);

		const yMax = Math.max(...dem, ...rep);
		const xScale = d3.scaleLinear().domain([-5, 5]).range([0, width]);
		const yScale = d3.scaleLinear().domain([0, yMax]).range([height, 0]);

		const area = (vals) => d3.area()
			.x((d, i) => xScale(xValues[i]))
			.y0(height)
			.y1(d => yScale(d))
			.curve(d3.curveBasis);

		d3.select(democratLine)
			.transition().duration(50).ease(d3.easeLinear)
			.attr('d', area(dem)(dem));

		d3.select(republicanLine)
			.transition().duration(50).ease(d3.easeLinear)
			.attr('d', area(rep)(rep));
	};

	$effect(() => {
		drawChart();
	});
</script>

<div class="inner-container" in:fade|global={{ duration: 400, delay: 500 }}>
	<svg bind:this={svgContainer} width="100%" height={height} transition:fade|global={{ duration: 400 }}>
		<path bind:this={democratLine} fill={getCSSVar('--color-theme-blue')} opacity="0.5" />
		<path bind:this={republicanLine} fill={getCSSVar('--color-theme-red')} opacity="0.5" />
	</svg>
</div>

<style>
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
		width: calc(100% - 2rem);
		height: auto;
	}
</style>
