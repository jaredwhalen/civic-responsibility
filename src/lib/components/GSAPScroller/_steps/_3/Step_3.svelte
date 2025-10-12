<script>
	import { onMount } from 'svelte';
	import { gsap } from 'gsap';
	import { ScrollTrigger } from 'gsap/ScrollTrigger';

	let stepElement;
	let backgroundElement;
	let textElement;
	let progress = $state(0);

	// Reactive calculations based on scroll progress
	let textOpacity = $derived(progress >= 20 ? 1 : 0); // Text appears at 20% scroll
	let textY = $derived(progress >= 20 ? 0 : 30); // Text starts below and moves up
	let textParallax = $derived(progress * 10); // Subtle parallax effect for text
	let overlayOpacity = $derived(0.25 + (progress / 90) * 0.6); // Fade from 0.25 to 1.0 over 0-90% scroll
	let backgroundScale = $derived(1 + (progress / 100) * 0.2); // Background scales from 1 to 1.2 over full scroll

	onMount(() => {
		gsap.registerPlugin(ScrollTrigger);

		// Set initial states
		gsap.set(textElement, { opacity: 0, y: 30 });

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
				y: textY + textParallax,
				duration: 0.1,
				ease: 'none'
			});
		}

		if (backgroundElement) {
			gsap.to(backgroundElement.querySelector('.color-overlay'), {
				opacity: overlayOpacity,
				duration: 0.1,
				ease: 'none'
			});

			gsap.to(backgroundElement.querySelector('.background-image'), {
				scale: backgroundScale,
				duration: 0.1,
				ease: 'none'
			});
		}
	});
</script>

<div class="step-3" bind:this={stepElement}>
	<div class="background-container" bind:this={backgroundElement}>
		<div class="background-image"></div>
		<div class="color-overlay"></div>
	</div>

	<div class="text-overlay" bind:this={textElement}>
		<div class="text-body">
			As we approach America's 250th anniversary, it is important to remember the <b>civic responsibilities</b> we all share.
		</div>
	</div>
</div>

<style lang="scss">
	@import '../../../../styles/variables.scss';

	.step-3 {
		height: 110vh;
		position: relative;
		width: 100%;
		overflow: hidden;

		.background-container {
			position: absolute;
			top: 0;
			left: 0;
			width: 100%;
			height: 100%;
			z-index: 1;

			.background-image {
				width: 100%;
				height: 100%;
				background-image: url('/assets/images/dreamstime_xl_58534238.jpg');
				background-size: cover;
				background-position: center;
				background-repeat: no-repeat;
			}

			.color-overlay {
				position: absolute;
				top: 0;
				left: 0;
				width: 100%;
				height: 100%;
				background: var(--color-theme-blue);
				z-index: 2;
				opacity: 1; // Initial opacity, will be animated by GSAP
				// mix-blend-mode: color;
			}
		}

		.text-overlay {
			position: sticky;
			// top: 50vh;
			transform: translateY(-50%);
			width: 100%;
			max-width: 900px;
			margin: 0 auto;
			padding: 2rem;
			text-align: center;
			z-index: 10;
			text-shadow: 0 0 10px rgba(0, 0, 0, 0.8);
			color: white;
		}
	}
</style>
