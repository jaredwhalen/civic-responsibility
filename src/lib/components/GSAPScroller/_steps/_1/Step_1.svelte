<script>
	import { onMount } from 'svelte';
	import { gsap } from 'gsap';
	import { ScrollTrigger } from 'gsap/ScrollTrigger';
	import Blobs from './Blobs.svelte';
	import { isMobile } from '$lib/stores/responsive.js';

	let stepElement;
	let textElement;
	let artElement;
	let progress = $state(0);

	// Reactive calculations based on scroll progress
	let textOpacity = $derived(progress >= 25 ? 1 : 0); // Text appears at 25% scroll
	let textY = $derived(progress >= 25 ? 0 : -50); // Text starts above and moves to center
	let artStart = 25;
	let artOpacity = $derived(progress >= artStart ? Math.min(1, (progress - artStart) * 0.04) : 0); // 2% per 1% progress
	let artProgress = $derived(progress >= artStart ? Math.min(1, (progress - artStart) * 0.02) : 0); // 2% per 1% progress for art animation
	let letterSpacing = $derived(artProgress * 0.5); // Letter spacing increases with art progress

	onMount(() => {
		gsap.registerPlugin(ScrollTrigger);
		// Reduce iOS viewport/URL bar resize thrash
		ScrollTrigger.config({ ignoreMobileResize: true });

		// Set initial states
		gsap.set(textElement, { opacity: 0, y: -50 });
		gsap.set(artElement, { opacity: 0 });

		// Create scroll trigger for this section
		const trigger = ScrollTrigger.create({
			trigger: stepElement,
			start: 'top bottom',
			end: 'bottom top',
			onUpdate: (self) => {
				progress = self.progress * 100;
			}
		});

		return () => {
			trigger.kill();
		};
	});

	// Watch for progress changes and update animations
	$effect(() => {
		if (textElement) {
			gsap.to(textElement, {
				opacity: textOpacity,
				y: textY,
				duration: 0.1,
				ease: 'none'
			});
		}

		if (artElement) {
			gsap.to(artElement, {
				opacity: artOpacity,
				duration: 0.1,
				ease: 'none'
			});
		}
	});

	let artHeight = $state();
	let artWidth = $state();
</script>

<div class="step-1" bind:this={stepElement}>
	<div class="text-content" bind:this={textElement}>
		<div class="text-body">
			Our country is growing more<br /><span
				class="text-accent"
				style="letter-spacing: {letterSpacing}em; --gradient-opacity: {artProgress}">polarized</span
			>
		</div>
	</div>

	<div
		class="art-content"
		bind:this={artElement}
		bind:clientHeight={artHeight}
		bind:clientWidth={artWidth}
	>
		{#if artHeight && artWidth}
			<Blobs offset={artProgress} height={artHeight} width={artWidth} />
		{/if}
	</div>
</div>

<style lang="scss">
	@import '../../../../styles/variables.scss';

	.step-1 {
		height: 150vh;
		position: relative;
		align-items: center;
		width: 100%;

		@include mq('mobile', 'max') {
			height: calc(150vh - 500px);
		}

		.text-content {
			position: sticky;
			top: 50vh;
			transform: translateY(-50%);
			width: 100%;
			height: 500px; // Match the art height so they scroll together
			display: flex;
			align-items: center;
			justify-content: center;
			padding: 2rem;
			text-align: center;
			z-index: 10;
			margin-bottom: 10rem;
			color: var(--color-theme-light);
			opacity: 0;
			will-change: transform, opacity; // GPU acceleration

			@include mq('mobile', 'max') {
				position: relative;
				top: 20vh;
				transform: none;
			}

			* {
				font-size: 4.5rem;

				@include mq('mobile', 'max') {
					font-size: 2rem;
				}
			}
			// text-shadow: 0 0 5px rgba(255, 255, 255, 1);
		}

		.text-accent {
			position: relative;
			display: inline-block;
		}

		.text-accent::before {
			content: '';
			position: absolute;
			top: 0;
			left: 0;
			right: 0;
			bottom: 0;
			background: linear-gradient(
				90deg,
				var(--color-theme-dem-blue),
				#ddd,
				var(--color-theme-gop-red)
			);
			background-clip: text;
			-webkit-background-clip: text;
			-webkit-text-fill-color: transparent;
			background-size: 100% 100%;
			opacity: var(--gradient-opacity, 0);
			transition: opacity 0.3s ease;
			z-index: 100;
		}

		.art-content {
			position: sticky;
			top: 50vh;
			transform: translateY(-50%);
			width: 100%;
			height: 500px; // Match the SVG height
			z-index: 1; // Lower z-index to appear behind text
			pointer-events: none; // Allow clicks to pass through to text
			opacity: 0;
			will-change: opacity; // GPU acceleration

			@include mq('mobile', 'max') {
				top: 0vh;
				transform: translateY(-100%);
			}
		}
	}
</style>
