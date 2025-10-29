<script>
	import { run } from 'svelte/legacy';
	import { fade } from 'svelte/transition';
	import { onMount } from 'svelte';
	import { isMobile } from '$lib/stores/responsive.js';
	import { geoAlbersUsa, geoPath } from 'd3-geo';

	import tippy, { followCursor } from 'tippy.js';
	import 'tippy.js/dist/tippy.css';
	import 'tippy.js/themes/light.css';

	import { extent } from 'd3-array';

	import geoJson from '$lib/data/states.json';

	let { data, duty, colorScale, clickedPaths = $bindable() } = $props();

	let containerWidth = $state(0);
	let containerHeight = $state(0);
	let tippyInstances = $state([]);
	let tippyMap = $state(new Map());

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
		tippyMap = new Map();

		// Create new instances
		const elements = document.querySelectorAll('[data-tippy-content][data-state-id]');
		elements.forEach((el) => {
			try {
				const stateId = el.getAttribute('data-state-id');
				const instance = tippy(el, {
					theme: 'light',
					duration: 0,
					offset: [0, !$isMobile ? -5 : 0],
					allowHTML: true,
					hideOnClick: false, // stay open unless we hide
					interactive: false,
					trigger: 'mouseenter click',
					appendTo: document.body // important for SVG
				});
				tippyInstances.push(instance);
				tippyMap.set(stateId, instance);

				// If pinned, force open initially
				if (clickedPaths?.has?.(stateId)) instance.show();
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

	// Sync only pinned tooltips (hide others)
	$effect(() => {
		if (!clickedPaths) return;
		
		const _ids = [...clickedPaths]; // establish dependency
		
		// On mobile, ensure only one tooltip shows (defensive check)
		if ($isMobile && clickedPaths.size > 1) {
			// Take the first item (since click handler ensures only one exists, this is just defensive)
			const firstId = clickedPaths.values().next().value;
			tippyMap.forEach((inst, id) => {
				if (id === firstId) {
					inst.show();
				} else {
					inst.hide();
				}
			});
			// Update clickedPaths to only contain one item
			clickedPaths = new Set([firstId]);
		} else {
			tippyMap.forEach((inst, id) => {
				if (clickedPaths.has(id)) {
					inst.show();
				} else {
					inst.hide();
				}
			});
		}
	});

	// Handle path click
	function handlePathClick(event, state) {
		event.stopPropagation();
		
		const stateId = `${duty}-${state}`;

		// Initialize clickedPaths if needed
		if (!clickedPaths) {
			clickedPaths = new Set();
		}

		// On mobile, only allow one tooltip at a time (the last clicked)
		if ($isMobile) {
			if (clickedPaths.has(stateId)) {
				// If clicking the same path, close it
				const next = new Set();
				clickedPaths = next;
				tippyMap.get(stateId)?.hide();
			} else {
				// Clear all previous and show only the new one
				tippyMap.forEach((inst, id) => {
					if (id !== stateId) inst.hide();
				});
				const next = new Set([stateId]);
				clickedPaths = next;
				tippyMap.get(stateId)?.show();
			}
		} else {
			// Desktop: toggle clickedPaths immutably + immediate show/hide
			if (clickedPaths.has(stateId)) {
				const next = new Set(clickedPaths);
				next.delete(stateId);
				clickedPaths = next;
				tippyMap.get(stateId)?.hide();
			} else {
				const next = new Set(clickedPaths);
				next.add(stateId);
				clickedPaths = next;
				tippyMap.get(stateId)?.show();
			}
		}
	}

	onMount(() => {
		createTippyInstances();

		// Optional: clicking document hides non-pinned tooltips
		const onDocClick = () => {
			if (!clickedPaths) return;
			tippyMap.forEach((inst, id) => {
				if (!clickedPaths.has(id)) inst.hide();
			});
		};
		document.addEventListener('click', onDocClick);

		return () => {
			document.removeEventListener('click', onDocClick);
			tippyInstances.forEach((inst) => {
				try {
					inst?.destroy?.();
				} catch {}
			});
			tippyInstances = [];
			tippyMap = new Map();
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
				{@const stateId = `${duty}-${state}`}
				<!-- svelte-ignore a11y_click_events_have_key_events -->
				<!-- svelte-ignore a11y_no_static_element_interactions -->
				<!-- svelte-ignore a11y_mouse_events_have_key_events -->
				<path
					fill="transparent"
					stroke-width="1"
					data-state={state}
					data-mean={mean}
					data-duty={duty}
					data-state-id={stateId}
					data-tippy-content={`
            <em style="line-height: 1.5;">${duty}</em><br/>
            <b style="font-size: 1.2em;">${state}</b><br/>
          
            ${state && mean ? `Average: <b>${mean.toFixed(0)}%</b>` : 'Insufficient data'}
          
     
            `}
					class="outline"
					class:clicked={clickedPaths?.has?.(stateId)}
					onclick={(e) => handlePathClick(e, state)}
					{d}
				></path>
			{/each}
		</g>
	</svg>
</div>

<style lang="scss">
	.map-container {
		width:100%;
		max-width: 1200px;
		height: 100%;
		margin: 0 auto;
		display: flex;
		justify-content: center;
		align-items: center;
		overflow: hidden;
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
			cursor: pointer;
			
			&:hover {
				stroke: var(--color-gray-1000);
				stroke-width: 2px;
				opacity: 1;
			}
			
			&.clicked {
				stroke: var(--color-gray-1000);
				stroke-width: 2px;
				opacity: 1;
			}
		}

		path:focus {
			outline: none;
		}	
	}
</style>
