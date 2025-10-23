<script>
	import { run } from 'svelte/legacy';
	import { fade } from 'svelte/transition';
	import { onMount } from 'svelte';

	import { geoAlbersUsa, geoPath } from 'd3-geo';

	import tippy, { followCursor } from 'tippy.js';
	import 'tippy.js/dist/tippy.css';
	import 'tippy.js/themes/light.css';

	import { extent } from 'd3-array';

	import geoJson from '$lib/data/states.json';

	let { data, duty, colorScale } = $props();

	let containerWidth = $state(0);
	let containerHeight = $state(0);
	let tippyInstances = $state([]);

	// Ensure map fits within container with some padding
	let width = $derived(Math.min(containerWidth, (containerHeight) * 1.67));
	let height = $derived(width / 1.67);

	let paths = $state([]);

	let projection = $derived(geoAlbersUsa().fitSize([width, height], geoJson));
	let pathGenerator = $derived(geoPath().projection(projection));

	run(() => {
		paths = geoJson.features.map((feature) => {
			const stateData = data.find((d) => d.state === feature.properties.NAME);
			const mean = stateData ? stateData.mean : null;

			return {
				d: pathGenerator(feature),
				state: feature.properties.NAME,
				mean: Number(mean),
				fill: mean !== null ? colorScale(Number(mean)) : '#ddd'
			};
		});
	});

	// Create tippy instances
	function createTippyInstances() {
		// Clean up existing instances
		tippyInstances.forEach((inst) => {
			try {
				inst?.destroy?.();
			} catch {}
		});
		tippyInstances = [];

		// Create new instances
		const elements = document.querySelectorAll('[data-tippy-content]');
		elements.forEach((el) => {
			try {
				const instance = tippy(el, {
					theme: 'light',
					duration: 0,
					followCursor: true,
					plugins: [followCursor],
					allowHTML: true
				});
				tippyInstances.push(instance);
			} catch (e) {
				console.warn('Error creating tippy instance:', e);
			}
		});
	}

	// Recreate tooltips when duty or data changes
	$effect(() => {
		if (duty && data) {
			// Depend on duty and data values
			duty;
			data.forEach((d) => d.mean);
			setTimeout(createTippyInstances, 0); // after DOM update
		}
	});

	onMount(() => {
		createTippyInstances();

		return () => {
			tippyInstances.forEach((inst) => {
				try {
					inst?.destroy?.();
				} catch {}
			});
			tippyInstances = [];
		};
	});
</script>

<div
	class="map-container"
	bind:clientWidth={containerWidth}
	bind:clientHeight={containerHeight}
	transition:fade
>
	<svg {width} {height}>
		{#each paths as { d, fill }}
			<path {d} {fill} stroke-width="0.5"></path>
		{/each}

		<g>
			{#each paths as { d, state, mean }}
				<path
					fill="transparent"
					stroke-width="1"
					data-state={state}
					data-mean={mean}
					data-duty={duty}
					data-tippy-content={`
            <em style="line-height: 1.5;">${duty}</em><br/>
            <b style="font-size: 1.2em;">${state}</b><br/>
          
            ${state && mean ? `Average: <b>${mean.toFixed(0)}%</b>` : 'Insufficient dataNo data'}
          
     
            `}
					class="outline"
					{d}
				></path>
			{/each}
		</g>
	</svg>
</div>

<style lang="scss">
	.map-container {
		width:100%;
		height: 100%;
		margin: 0 auto;
		display: flex;
		justify-content: center;
		align-items: center;
		overflow: hidden;
		max-width: 100%;
		max-height: 100%;
	}

	svg {
		margin-top: 10px;

		path {
			stroke: $color-theme-light;
			stroke-width: 1.2px;
		}

		path.outline {
			stroke: $color-theme-light;
			opacity: 0;
			&:hover {
				stroke: $color-theme-yellow;

				stroke-width: 2px;
				opacity: 1;
			}
		}

		path:focus {
			outline: none;
		}	
	}
</style>
