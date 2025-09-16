<script>
	import { onMount } from 'svelte';
	import { gsap } from 'gsap';
	import { ScrollTrigger } from 'gsap/ScrollTrigger';
	import Blobs from './Blobs.svelte';

	let stepElement;
	let textElement;
	let artElement;
	let progress = $state(0);

	// Reactive calculations based on scroll progress
	let textOpacity = $derived(progress >= 25 ? 1 : 0); // Text appears at 25% scroll
	let textY = $derived(progress >= 25 ? 0 : -50); // Text starts above and moves to center
	let artOpacity = $derived(progress >= 45 ? Math.min(1, (progress - 45) * 0.04) : 0); // 2% per 1% progress
	let artProgress = $derived(progress >= 45 ? Math.min(1, (progress - 45) * 0.02) : 0); // 2% per 1% progress for art animation
	let letterSpacing = $derived(artProgress * 0.5); // Letter spacing increases with art progress

	onMount(() => {
		gsap.registerPlugin(ScrollTrigger);

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
</script>

<div class="step-1" bind:this={stepElement}>
	<div class="text-content" bind:this={textElement}>
		<div class="text-body">
			Our country is increasingly<br /><span
				class="text-accent"
				style="letter-spacing: {letterSpacing}em; --gradient-opacity: {artProgress}">polarized</span
			>.
		</div>
	</div>

	<div class="art-content" bind:this={artElement}>
		<Blobs offset={artProgress} />
	</div>
</div>

<style lang="scss">
	@import '../../../../styles/variables.scss';

	.step-1 {
		height: 150vh;
		position: relative;
		display: flex;
		align-items: center;
		width: 100%;

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
		}
	}
</style>
