<script>
	import { onMount, tick } from 'svelte';

	let paths = $state([]);
	let pathLengths = $state([]);

	onMount(async () => {
		// 1) Fetch the raw SVG from static
		const res = await fetch('/assets/svgs/liberty-bell.svg');
		if (!res.ok) {
			console.error('Could not load SVG:', res.status);
			return;
		}
		const svgText = await res.text();

		// 2) Parse it
		const doc = new DOMParser().parseFromString(svgText, 'image/svg+xml');
		paths = Array.from(doc.querySelectorAll('path')).map((p) => {
			const attrs = {};
			for (let i = 0; i < p.attributes.length; i++) {
				const { name, value } = p.attributes[i];
				attrs[name] = value;
			}
			return attrs;
		});

		// 3) Wait for Svelte to render
		await tick();

		// 4) Measure each path
		const svgEl = document.getElementById('liberty‑bell');
		svgEl.querySelectorAll('path').forEach((pathEl) => {
			pathLengths.push(pathEl.getTotalLength());
		});
	});
</script>

<svg id="liberty‑bell" viewBox="0 0 620 671" xmlns="http://www.w3.org/2000/svg">
	{#if paths.length}
		{#each paths as {d}, i}
			<path
				d={d}
				fill="none"
				style:--pathLength={pathLengths[i]}
				style:--fillColor={'black'}
				class="animated-path"
			/>
		{/each}
	{/if}
</svg>

<style lang="scss">
	:global {
		#liberty‑bell {
			width: 65vw;
			top: -10%;
			right: -15%;
			position: absolute;

			.animated-path {
				stroke: black;
				stroke-width: 2;
				fill: var(--bg-color);

				/* set up the dash */
				stroke-dasharray: var(--pathLength);
				stroke-dashoffset: var(--pathLength);
				animation:
					draw 2s ease-out forwards,
					fillIn 1s ease-in-out 2s forwards;
			}

			@keyframes draw {
				to {
					stroke-dashoffset: 0;
					stroke: none;
				}
			}

			@keyframes fillIn {
				to {
					fill: var(--fillColor);
					stroke: none;
				}
			}
		}
	}
</style>
