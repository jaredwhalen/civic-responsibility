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
	const end = 0.9;

	// 21 evenly spaced bins from -5 to 5
	const xValues = d3.range(-5, 5.01, 10 / 20);

	let width = 0;
	const height = 500;
	let svgContainer = $state();
	let democratLine = $state();
	let republicanLine = $state();

// Generate smooth DEM/REP bell curves that drift apart over time
function generatePolarizationData({
  years = 10,
  bins = 21,
  sigma = 1.0,           // standard deviation of both curves (fixed)
  overlapStart = 0.70,   // ~70% overlap in year 0
  overlapEnd   = 0.30,   // ~30% overlap in last year
  jitter = 0.015,        // small smooth noise applied to each bin
  seed = 42              // deterministic randomness
} = {}) {
  // Simple seeded RNG for reproducibility
  let s = seed >>> 0;
  const rand = () => (s = (1664525 * s + 1013904223) >>> 0, (s & 0xfffffff) / 0xfffffff);

  // Standard normal PDF
  const pdf = (x, mu, sig) => Math.exp(-0.5 * ((x - mu) / sig) ** 2) / (sig * Math.sqrt(2 * Math.PI));

  // Acklam's inverse normal CDF approximation
  function invPhi(p) {
    if (p <= 0 || p >= 1) throw new RangeError("p must be in (0,1)");
    // Coefficients
    const a = [-3.969683028665376e+01,  2.209460984245205e+02, -2.759285104469687e+02,
               1.383577518672690e+02, -3.066479806614716e+01,  2.506628277459239e+00];
    const b = [-5.447609879822406e+01,  1.615858368580409e+02, -1.556989798598866e+02,
               6.680131188771972e+01, -1.328068155288572e+01];
    const c = [-7.784894002430293e-03, -3.223964580411365e-01, -2.400758277161838e+00,
               -2.549732539343734e+00,  4.374664141464968e+00,  2.938163982698783e+00];
    const d = [ 7.784695709041462e-03,  3.224671290700398e-01,  2.445134137142996e+00,
                3.754408661907416e+00];

    // Breakpoints
    const plow = 0.02425, phigh = 1 - plow;
    let q, r, x;

    if (p < plow) {
      q = Math.sqrt(-2 * Math.log(p));
      x = (((((c[0]*q + c[1])*q + c[2])*q + c[3])*q + c[4])*q + c[5]) /
          ((((d[0]*q + d[1])*q + d[2])*q + d[3])*q + 1);
    } else if (p > phigh) {
      q = Math.sqrt(-2 * Math.log(1 - p));
      x = -(((((c[0]*q + c[1])*q + c[2])*q + c[3])*q + c[4])*q + c[5]) /
            ((((d[0]*q + d[1])*q + d[2])*q + d[3])*q + 1);
    } else {
      q = p - 0.5;
      r = q * q;
      x = (((((a[0]*r + a[1])*r + a[2])*r + a[3])*r + a[4])*r + a[5]) * q /
          (((((b[0]*r + b[1])*r + b[2])*r + b[3])*r + b[4])*r + 1);
    }
    return x;
  }

  // Given desired overlap p and sigma, compute mean separation Δ
  const sepFromOverlap = (p, sig) => 2 * sig * invPhi(1 - p / 2);

  // X-axis over ~±3σ (21 bins by default)
  const xs = Array.from({ length: bins }, (_, i) => {
    const t = i / (bins - 1);  // 0..1
    return (t * 6 - 3) * sigma; // -3σ to +3σ
  });

  // Helper: build and normalize a bell to sum 100
  function makeBell(mu, sig, jitterAmt) {
    let arr = xs.map(x => pdf(x, mu, sig));
    // smooth per-bin jitter (always positive-ish, subtle)
    arr = arr.map(v => v * (1 + (rand() - 0.5) * 2 * jitterAmt));
    const sum = arr.reduce((a, b) => a + b, 0);
    return arr.map(v => (v / sum) * 100);
  }

  const out = [];
  for (let y = 0; y < years; y++) {
    const t = years === 1 ? 0 : y / (years - 1); // 0..1 across years
    const targetOverlap = overlapStart + t * (overlapEnd - overlapStart);
    const sep = sepFromOverlap(targetOverlap, sigma);

    // Center both around 0 and split separation symmetrically
    const muDem = -sep / 2;
    const muRep =  sep / 2;

    // Build bells
    const dem = makeBell(muDem, sigma, jitter);
    const rep = makeBell(muRep, sigma, jitter);

    out.push([
      { name: "Dem", data: dem.map(v => +v.toFixed(2)) },
      { name: "REP", data: rep.map(v => +v.toFixed(2)) }
    ]);
  }
  return out;
}

// ---------- Example usage ----------
const data = generatePolarizationData({
  years: 12,          // number of “years” (arrays)
  bins: 21,           // keep your 21-bin shape
  sigma: 1.0,
  overlapStart: 0.70, // ~70% overlap in first year
  overlapEnd: 0.20,   // ~30% overlap in last year
  jitter: 0.075,       // tiny variation so it’s not perfectly symmetric
  seed: 7
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
