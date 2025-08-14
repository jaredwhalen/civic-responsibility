<script>
	import { fade } from 'svelte/transition';

	let { offset = 0 } = $props();
	let innerWidth = $state(0);
	let innerHeight = $state(0);

	const totalDots = 150;
	const dotsPerGroup = totalDots / 2;
	const animationStart = 0.1; // Animation starts at 10% scroll
	const animationCompleteAt = 0.75; // Animation completes at 75% scroll

	let initialPositions = $state([]);
	let finalPositions = $state([]);

	function generatePositions() {
		const centerX = innerWidth / 2;
		const centerY = innerHeight / 2;
		const initialRadius = Math.min(innerWidth, innerHeight) * 0.2;
		const groupRadius = Math.min(innerWidth, innerHeight) * 0.25;
		const separation = Math.min(innerWidth, innerHeight) * 0.4;

		const newInitial = [];
		const newFinal = [];

		// Initial positions + a random image index 1–10
		for (let i = 0; i < totalDots; i++) {
			const r = Math.sqrt(Math.random()) * initialRadius;
			const θ = Math.random() * Math.PI * 2;
			const image = Math.floor(Math.random() * 33) + 1;

			newInitial.push({
				x: centerX + Math.cos(θ) * r,
				y: centerY + Math.sin(θ) * r,
				image
			});
		}

		// Final positions (two groups), no need to re-pick images here
		for (let i = 0; i < totalDots; i++) {
			const group = i < dotsPerGroup ? 0 : 1;
			const cx = centerX + (group === 0 ? -separation / 2 : separation / 2);
			const cy = centerY;
			const r = Math.sqrt(Math.random()) * groupRadius;
			const θ = Math.random() * Math.PI * 2;

			newFinal.push({
				x: cx + Math.cos(θ) * r,
				y: cy + Math.sin(θ) * r,
				group
			});
		}

		initialPositions = newInitial;
		finalPositions = newFinal;
	}

	$effect(() => {
		if (innerWidth && innerHeight) generatePositions();
	});

	function getCurrentPositions() {
		if (!initialPositions.length) return [];

		// Calculate animation progress between start and completion thresholds
		let animationProgress = 0;
		if (offset >= animationStart) {
			const animationRange = animationCompleteAt - animationStart;
			const currentProgress = offset - animationStart;
			animationProgress = Math.min(currentProgress / animationRange, 1);
		}

		return initialPositions.map((start, i) => {
			const end = finalPositions[i];
			return {
				x: start.x + (end.x - start.x) * animationProgress,
				y: start.y + (end.y - start.y) * animationProgress,
				image: start.image,
				group: finalPositions[i].group
			};
		});
	}

	let currentPositions = $derived(getCurrentPositions());

	// Group metrics - calculated once when dimensions are set
	let group0Center = $state({ x: 0, y: 0 });
	let group1Center = $state({ x: 0, y: 0 });
	let groupRadius = $state(0);

	// Calculate group positions once when dimensions are available
	$effect(() => {
		if (innerWidth && innerHeight && (groupRadius === 0 || group0Center.x === 0)) {
			const centerX = innerWidth / 2;
			const centerY = innerHeight / 2;
			const separation = Math.min(innerWidth, innerHeight) * 0.4;
			const radius = Math.min(innerWidth, innerHeight) * 0.25 + 50;

			group0Center = {
				x: centerX - separation / 2,
				y: centerY
			};
			group1Center = {
				x: centerX + separation / 2,
				y: centerY
			};
			groupRadius = radius;
		}
	});
</script>


<div class="people-container" bind:clientWidth={innerWidth} bind:clientHeight={innerHeight} transition:fade|global={{ duration: 400 }}>
	<svg
		xmlns="http://www.w3.org/2000/svg"
		width={innerWidth}
		height={innerHeight}
		viewBox={`0 0 ${innerWidth} ${innerHeight}`}
		style="display: block; margin: auto;"
	>
		<!-- Background circles for groups -->
		{#if offset > animationStart}
			{#if groupRadius > 0}
				{#if group0Center.x !== 0}
					<circle
						cx={group0Center.x}
						cy={group0Center.y}
						r={groupRadius *
							Math.min((offset - animationStart) / (animationCompleteAt - animationStart), 1)}
						fill="#c96b5b"
						opacity="0.3"
					/>
				{/if}
				{#if group1Center.x !== 0}
					<circle
						cx={group1Center.x}
						cy={group1Center.y}
						r={groupRadius *
							Math.min((offset - animationStart) / (animationCompleteAt - animationStart), 1)}
						fill="#5a7d97"
						opacity="0.3"
					/>
				{/if}
			{/if}
		{/if}

		<!-- Individual people icons -->
		{#each currentPositions as pos}
			<g transform={`translate(${pos.x}, ${pos.y})`}>
				<image
					href={`/assets/svgs/people/people-${pos.image}.svg`}
					width="25"
					height="50"
					preserveAspectRatio="xMidYMid meet"
				/>
			</g>
		{/each}
	</svg>
</div>

<style lang="scss">
	.people-container {
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
</style>
