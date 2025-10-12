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

	// Ensure map fits within container with some padding
	let width = $derived(Math.min(containerWidth - 40, containerHeight * 1.67 - 40));
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

	onMount(() => {
		tippy('[data-tippy-content]', {
			theme: 'light',
			duration: 0,
			followCursor: true,
			plugins: [followCursor],
			allowHTML: true
		});
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
					{d}
					fill="transparent"
					stroke-width="1"
					data-tippy-content={`
            <em style="line-height: 1.5;">${duty}</em><br/>
            <b style="font-size: 1.2em;">${state}</b><br/>
          
            ${state && mean ? `Mean: <b>${mean.toFixed(0)}%</b>` : 'No data'}
          
     
            `}
					class="outline"
				></path>
			{/each}
		</g>
	</svg>
</div>

<style lang="scss">
	.map-container {
		width: calc(100% - 60px);
		height: calc(100% - 60px);
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
	}
</style>
